<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

$script:ModuleRoot = $PSScriptRoot
$script:ProjectRoot = (Get-Item -Path $script:ModuleRoot).Parent.Parent.FullName
$script:ModuleName = Split-Path -Path $script:ModuleRoot -Leaf

$script:PsmPath = Join-Path -Path $script:ModuleRoot -ChildPath "$($script:ModuleName).psm1"
$script:PsdPath = Join-Path -Path $script:ModuleRoot -ChildPath "$($script:ModuleName).psd1"

$script:LicensePath = Join-Path -Path $script:ProjectRoot -ChildPath "LICENSE.txt"
# This is used to skip the lines from LICENSE.txt containing the repository name and the empty line after it.
$script:LicenseSkipLines = 2
$script:LicenseFileContent = Get-Content -Path $script:LicensePath | Select-Object -Skip $script:LicenseSkipLines

$script:EnumsFolder = Join-Path -Path $script:ModuleRoot -ChildPath "Enums"
$script:ClassesFolder = Join-Path -Path $script:ModuleRoot -ChildPath "Classes"
$script:ClassesFiles = Get-ChildItem -Path $script:ClassesFolder -File -Filter *.ps1 -Recurse
$script:DSCResourcesFolder = Join-Path -Path $script:ModuleRoot -ChildPath "DSCResources"

function Update-OrderOfFiles {
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        [System.Object[]] $Files
    )

    $orderedFiles = @()

    foreach ($file in $Files) {
        $fileContent = Get-Content -Path $file.FullName
        $errors = $null

        $fileTokens = [System.Management.Automation.PSParser]::Tokenize($fileContent, [ref] $errors)
        $classToken = $fileTokens | Where-Object -Property Content -eq 'class'
        $classTokenIndex = $fileTokens.IndexOf($classToken)
        $tokensCount = 3

        <#
        Here we modify the tokens array to contain only the tokens of the line which contains the 'class' keyword.
        The class line could be one of the following:
        1. class <ChildClass> : <ParentClass>
        2. class <ChildClass>
        #>
        $fileTokens = $fileTokens[($classTokenIndex + 1)..($classTokenIndex + $tokensCount)]

        $childClassToken = $fileTokens[0]
        $inheritanceOperatorToken = $fileTokens[1]
        $parentClassToken = $fileTokens[2]

        # Here we check if the tokens array contains tokens that tackle the case when the class is inheriting from another class.
        if ($childClassToken.Type -eq 'Type' -and $inheritanceOperatorToken.Type -eq 'Unknown' -and $parentClassToken.Type -eq 'Type') {
            $parentFileName = "$($parentClassToken.Content).ps1"
            $childFileName = "$($childClassToken.Content).ps1"

            $parentFile = $Files | Where-Object -Property Name -eq $parentFileName
            $childFile = $Files | Where-Object -Property Name -eq $childFileName

            <#
            If the parent and child classes already exists in the ordered files we do not add anything.
            Otherwise we first add the parent class, and then the child class to avoid exceptions when
            the child class is defined before the parent class.
            #>

            $existingParentClassFile = $orderedFiles | Where-Object -Property Name -eq $parentFileName
            if ($null -eq $existingParentClassFile) {

                <#
                If the parent class does not exist, there are two options:
                1. The child class is already in the array, so we need to put the parent class before the child class.
                2. The child class is not in the array, so we first add the parent class and then the child class.
                #>
                $existingChildClassFile = $orderedFiles | Where-Object -Property Name -eq $childFileName
                if ($null -ne $existingChildClassFile) {
                    $childClassFilePosition = $orderedFiles.IndexOf($existingChildClassFile)
                    $childClassFile = $orderedFiles[$childClassFilePosition]

                    $orderedFiles[$childClassFilePosition] = $parentFile
                    $orderedFiles += $childClassFile
                }
                else {
                    $orderedFiles += $parentFile
                    $orderedFiles += $childFile
                }
            }

            <#
            We need to check again if the child class is in the array in the case the parent class already exists
            in the array and the child class was not added via the above logic.
            #>
            $existingChildClassFile = $orderedFiles | Where-Object -Property Name -eq $childFileName
            if ($null -eq $existingChildClassFile) {
                $orderedFiles += $childFile
            }
        }
        else {
            $childFileName = "$($childClassToken.Content).ps1"
            $childFile = $Files | Where-Object -Property Name -eq $childFileName

            $existingChildClass = $orderedFiles | Where-Object -Property Name -eq $childFileName
            if ($null -eq $existingChildClass) {
                $orderedFiles += $childFile
            }
        }
    }

    return $orderedFiles
}

function Get-LinesRange {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [System.Object[]] $FileContent,
        [string] $StartLinePattern,
        [string] $EndLinePattern
    )

    $range = @{}

    $index = 1
    $startLine = 0
    $endLine = 0

    foreach ($line in $FileContent) {
        if ($line -Like $StartLinePattern) {
            $startLine = $index
        }

        if ($line.Trim().EndsWith($EndLinePattern) -and $startLine -ne 0) {
            $endLine = $index
            break
        }

        $index++
    }

    $range.StartLine = $startLine
    $range.EndLine = $endLine

    return $range
}

function Update-ContentOfModuleFile {
    [CmdletBinding()]
    param(
        [string] $Folder,
        [System.Object[]] $Files
    )

    if (Test-Path -Path $Folder) {
        if ($null -eq $Files) {
            $Files = Get-ChildItem -Path $Folder -File -Filter *.ps1 -Recurse
        }

        foreach ($file in $Files) {
            $fileContent = Get-Content -Path $file.FullName

            $range = Get-LinesRange -FileContent $fileContent -StartLinePattern '*Copyright*' -EndLinePattern '#>'
            $endLine = $range.EndLine

            # We skip the comment lines for the License and the License text for each file.
            $fileContent = $fileContent[$endLine..($fileContent.Length - 1)]
            $fileContent | ForEach-Object { $_ | Out-File -FilePath $script:PsmPath -Encoding Default -Append }
        }
    }
}

# Add License to psm1 file.
"<#" | Out-File -FilePath $script:PsmPath -Encoding Default
$script:LicenseFileContent | ForEach-Object { $_ | Out-File -FilePath $script:PsmPath -Encoding Default -Append }
"#>" + [System.Environment]::NewLine | Out-File -FilePath $script:PsmPath -Encoding Default -Append

# Add helper module to psm1 file.
"Using module '.\VMware.vSphereDSC.Helper.psm1'" | Out-File -FilePath $script:PsmPath -Encoding Default -Append

# Updating VMware.vSphereDSC.psm1 content with enums.
Update-ContentOfModuleFile -Folder $script:EnumsFolder

# Updating VMware.vSphereDSC.psm1 content with classes.
$orderedClassesFiles = Update-OrderOfFiles -Files $script:ClassesFiles
Update-ContentOfModuleFile -Folder $script:ClassesFolder -Files $orderedClassesFiles

# Updating VMware.vSphereDSC.psm1 content with DSC Resources.
Update-ContentOfModuleFile -Folder $script:DSCResourcesFolder

# Updating VMware.vSphereDSC.psd1 content with DSC Resources to export.
if (Test-Path -Path $script:DSCResourcesFolder) {
    $resources = (Get-ChildItem -Path $script:DSCResourcesFolder -File -Filter *.ps1 -Recurse | Select-Object -ExpandProperty BaseName) -join "', '"
    $resources = "'{0}'" -f $resources
    $dscResourcesToExport = "DscResourcesToExport = @($resources)"

    $psdFileContent = Get-Content -Path $script:PsdPath

    $range = Get-LinesRange -FileContent $psdFileContent -StartLinePattern '*DscResourcesToExport*' -EndLinePattern ')'
    $startLine = $range.StartLine
    $endLine = $range.EndLine

    $psdFileContent = $psdFileContent[0..($startLine - 2)], $dscResourcesToExport, $psdFileContent[$endLine..($psdFileContent.Length - 1)]
    $psdFileContent | Out-File -FilePath $script:PsdPath -Encoding Default
}
