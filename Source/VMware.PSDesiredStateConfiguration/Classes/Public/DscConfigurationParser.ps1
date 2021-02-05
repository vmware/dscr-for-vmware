<#
Copyright (c) 2018-2021 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

<#
.DESCRIPTION

Class that handles the parsing of the DSC.
#>
class DscConfigurationParser {
    hidden [Hashtable] $ResourceNameToInfo

    DscConfigurationParser() {
        $this.ResourceNameToInfo = @{}
    }

    <#
    .DESCRIPTION
    Parses the Configuration scriptblock into an invokable form and retrieves a list dsc resources
    and a hashtable of local configuration names to their scriptblock
    #>
    [PsObject] ParseDscConfiguration([DscConfigurationBlock] $dscConfigurationBlock) {
        $configTextBlock = $dscConfigurationBlock.Extent.Text

        # find and extract the import-dscresource statements so that they can be executed first
        $searchScriptBlock = [ScriptBlock]::Create($configTextBlock)
        $constantItemStatements = $searchScriptBlock.Ast.FindAll({
            $args[0] -is [System.Management.Automation.Language.StringConstantExpressionAst]
        }, $true) | Where-Object { $_.Value -eq 'Import-DscResource' }

        $statements = New-Object -TypeName 'System.Collections.ArrayList'

        foreach ($item in $constantItemStatements) {
            $fullExpr = $item.Parent.ToString()

            $expressionIndex = $configTextBlock.IndexOf($fullExpr)
            $configTextBlock = $configTextBlock.Remove($expressionIndex, $fullExpr.Length)

            $statements.Add($fullExpr) | Out-Null
        }

        # invoke the import-dscresource statements
        $this.InvokeImportDscResource($statements.ToArray())

        $configTextBlock = $configTextBlock.Insert(0, 'Param( $Parameters ) . ')

        # find all dynamic keywords inside the configuration
        # nodes are removed from the list as they are executed separately
        $dscConfigurationBlockAsScriptBlock = $this.ConvertDscConfigurationBlockToScriptBlock($dscConfigurationBlock)
        $dynamicKeywords = $dscConfigurationBlockAsScriptBlock.Ast.FindAll({
            $args[0] -is [System.Management.Automation.Language.DynamicKeywordStatementAst]
        }, $true)

        # set bracket placement
        foreach ($dynamicKeyword in $dynamicKeywords) {
            $itemName = $dynamicKeyword.CommandElements[0].Value
            if ($itemName -eq 'Import-DscResource') {
                continue
            }

            $itemFullName = "$itemName $($dynamicKeyword.CommandElements[1].Extent.Text)"
            $configTextBlock = $this.ReplaceBracketWith($configTextBlock, $itemFullName, "{")

            $command = (Get-Command $itemName -ErrorAction 'SilentlyContinue')

            # case for nested configurations
            if ($null -ne $command -and -not $this.ResourceNameToInfo.ContainsKey($itemName)) {
                $this.ResourceNameToInfo[$itemName] = [PsObject]@{
                    ImplementedAs = 'Configuration'
                }
            }
        }

        $configTextBlock += ' @Parameters'

        return [PsObject]@{
            ScriptBlock = [ScriptBlock]::Create($configTextBlock)
            ResourceNameToInfo = $this.ResourceNameToInfo
        }
    }

    <#
    .DESCRIPTION
    Invokes all the found Import-DscResource statements
    #>
    hidden [void] InvokeImportDscResource([string[]] $statements) {
        $importDscResourceLogic = {
            Param (
                [string[]]
                $Name,          # names of the dsc resources to import
                # string[] or Microsoft.PowerShell.Commands.ModuleSpecification
                $ModuleName,    # names of the modules to import or module specification
                [string]
                $ModuleVersion  # the required version of the module
            )

            if ([string]::IsNullOrEmpty($Name) -or [string]::IsNullOrWhiteSpace($Name)) {
                $Name = '*'
            }

            if ([string]::IsNullOrEmpty($ModuleName) -or [string]::IsNullOrWhiteSpace($ModuleName)) {
                $ModuleName = '*'
            }

            if ((-not [string]::IsNullOrEmpty($ModuleVersion)) -and (-not [string]::IsNullOrWhiteSpace($ModuleVersion))) {
                if ($ModuleName -is [Microsoft.PowerShell.Commands.ModuleSpecification]) {
                    $ModuleName = @{
                        ModuleName = $ModuleName.ModuleName
                        RequiredVersion = $ModuleVersion
                    }
                } else {
                    $ModuleName = @{
                        ModuleName = $ModuleName
                        RequiredVersion = $ModuleVersion
                    }
                }
            }

            $getDscResourceSplatParams = @{
                Name = $Name
                Module = $ModuleName
            }

            $oldProgPref = $Global:ProgressPreference
            $Global:ProgressPreference = 'SilentlyContinue'

            $importedResources = Get-DscResource @getDscResourceSplatParams

            $Global:ProgressPreference = $oldProgPref

            foreach ($importedResource in $importedResources) {
                $this.ResourceNameToInfo[$importedResource.Name] = $importedResource
            }
        }

        $funcToDefine = @{
            'Import-DscResource' = $importDscResourceLogic
        }

        foreach ($statement in $statements) {
            $sb = [scriptblock]::Create($statement)

            $sb.InvokeWithContext($funcToDefine, $null)
        }
    }

    <#
    .DESCRIPTION

    Converts the specified DSC Configuration Block to Script Block by adding the Configuration keyword and the
    Configuration name to the text of the DSC Configuration.
    #>
    hidden [ScriptBlock] ConvertDscConfigurationBlockToScriptBlock([DscConfigurationBlock] $dscConfigurationBlock) {
        $script = 'Configuration ' + $dscConfigurationBlock.Name + [System.Environment]::NewLine
        $script += $dscConfigurationBlock.Extent.Text

        return [ScriptBlock]::Create($script)
    }

    <#
    .DESCRIPTION
    Replaces the first found opening bracket after SearchString
    and replaces it with StringToReplace in StringToChange
    .EXAMPLE
    ReplaceBracketWith -StringToChange @"
    TestResource test
    {
    }
    "@ `
    -SearchString 'TestResource test' `
    -StringToReplaceWith '{'
    Outputs
    TestResource test {
    }
    #>
    hidden [string] ReplaceBracketWith([string] $StringToChange, [string] $SearchString, [string] $StringToReplaceWith) {
        $regexPattern = "$SearchString[\s]*{"
        $replacement = "$SearchString $StringToReplaceWith"

        $StringToChange = $StringToChange -replace $regexPattern, $replacement

        return $StringToChange
    }
}
