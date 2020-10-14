<#
Desired State Configuration Resources for VMware

Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

# postFix used for naming nested configurations
$Script:NestedConfigPostFix = '___Configuration___Func'

<#
.Description
Compiles a dsc configuration into an object with the name of the configuration and an array of dsc resources

.Example
Compiling a basic configuration

Configuration Test
{
    Import-DscResource -ModuleName MyDscResource

    CustomResource myResource
    {
        Field = "Test field"
        Ensure = "Present"
    }
}

New-VmwDscConfiguration Test will output
[VmwDscConfiguration]@{
    InstanceName = 'Test'
    Resource = @(
        [VmwDscResource]@{
            InstanceName = 'myResource'
            ResourceType = 'CustomResource'
            ModuleName = 'MyDscResource'
            Property = @{
                Field = "Test field"
                Ensure = "Present"
            }
        }
    )
}
#>
function New-VmwDscConfiguration {
    [CmdletBinding()]
    [OutputType([VmwDscConfiguration])]
    param (
        [string]
        [Parameter(
        Mandatory   = $true,
        Position    = 0)]
        $ConfigName,            # Name of the Configuration
        
        [Parameter(
        Mandatory   = $false,
        Position    = 1)]
        [Hashtable]
        $CustomParams,          # User defined parameters of the configuration
        
        [Parameter(
        Mandatory   = $false,
        Position    = 2)]
        [HashTable]
        $ConfigurationData      # ConfigurationData for use in the configuration
    )

    Write-Progress 'Parsing Resources'

    $splatParams = @{
        ConfigName = $ConfigName
        CustomParams = $CustomParams
        ConfigurationData = $ConfigurationData
    }

    # parse and invoke the dsc configuration and get the dsc resources
    $dscResourceArr = GetResourcesFromConfiguration @splatParams

    Write-Progress 'Ordering Resources'
    # parse the dsc resources and their dependencies into a sorted array
    $sortedDscResourceArr = ParseDscResource $dscResourceArr

    [VmwDscConfiguration]::new(
        $ConfigName,
        $sortedDscResourceArr
    )
}

<#
.Description
Parses and then invokes the configuration with parameters and configuration data
to produce an array of Dsc Resources
#>
function GetResourcesFromConfiguration {
    [OutputType([VmwDscResource[]])]
    param (
        [string]
        [Parameter(Mandatory)]
        $ConfigName,            # Name of the Configuration

        [Hashtable]
        $CustomParams,          # User defined parameters of the configuration
        
        [HashTable]
        $ConfigurationData     # ConfigurationData for use in the configuration
    )

    $configCommand = $null

    # find the configuration with the given name
    $configCommand = Get-Command $ConfigName -ErrorAction SilentlyContinue

    if ($null -eq $configCommand) {
        throw ($Script:ConfigurationNotFoundException -f $ConfigName)
    }

    # check if found command is correct type
    if ($configCommand.CommandType -ne 'Configuration') {
        throw ($Script:CommandIsNotAConfigurationException -f $ConfigName, $configCommand.CommandType)
    }

    # this dictionary will contain the function definitions which are required in order to invoke the configuration
    # all dynamic keywords will be defined inside like Import-DscResource, Nodes and Nested Configurations
    $requiredInvokeFuncs = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,ScriptBlock]'([System.StringComparer]::OrdinalIgnoreCase)

    # parse configuration scriptblock
    $configScriptBlock = ParseConfigurationBlock $configCommand $requiredInvokeFuncs

    $requiredInvokeFuncs.Add('Import-DscResource', $Function:ImportDscResource) | Out-Null
    $requiredInvokeFuncs.Add('Node', $Function:VmwNode) | Out-Null

    $invokeConfigurationParams = @{
        RequiredInvokeFuncs = $requiredInvokeFuncs
        ConfigScriptBlock = $configScriptBlock 
        ConfigurationData = $ConfigurationData
        CustomParams = $CustomParams
    }

    $resArr = InvokeConfiguration @invokeConfigurationParams

    $resArr
}

<#
.Description
Invokes the parsed configuration scriptblock and returns an array of resources 
#>
function InvokeConfiguration {
    [OutputType([VmwDscResource[]])]
    param (
        [System.Collections.Generic.Dictionary[string,ScriptBlock]]
        $RequiredInvokeFuncs,

        [Scriptblock]
        $ConfigScriptBlock,

        [Hashtable]
        $ConfigurationData,

        [Hashtable]
        $CustomParams
    )

    # create the functions defined in RequiredInvokeFuncs
    foreach($nameKey in $RequiredInvokeFuncs.Keys) {
        $scriptBlockVal = $RequiredInvokeFuncs[$nameKey]

        $funcName = "Function:$nameKey"

        if ($null -ne (Get-Item $funcName -ErrorAction SilentlyContinue)) {
            continue
        }

        New-Item -Path "Function:$nameKey" -Value $scriptBlockVal | Out-Null
    }

    # create variables from the configurationData hashtable if it's valid
    if (IsConfigurationDataValid $ConfigurationData) {
        foreach ($item in $ConfigurationData.GetEnumerator()) {
            New-Variable -Name $item.Key -Value $item.Value
        }
    }

    # create variable for storing module names of the resources
    New-Variable -Name 'resourceNameToDeclaringModuleName' -Value @{}

    $resArr = $null

    # invoke the configuration block
    try {
        # results in resource array
        $resArr = & $ConfigScriptBlock @CustomParams
    } 
    catch {
        throw $_.Exception
    }

    $resArr
}

<#
.Description
Checks for duplicate resource id's and orders dsc resources based on their dependencies
#>
function ParseDscResource {
    [OutputType([VmwDscResource[]])]
    param (
        [VmwDscResource[]]
        $DscResources
    )

    # place resource in an oredered hashtable in order to check for duplicates
    $dscResOrderedDict = [ordered]@{}
    foreach ($resource in $DscResources) {
        $key = $resource.GetId()

        if ($dscResOrderedDict.Contains($key)) {
            throw ($Script:DuplicateResourceException -f $resource.InstanceName, $resource.ResourceType)
        }

        $dscResOrderedDict[$key] = $resource
    }

    # creates graph with the created ordered hashtable
    $resGraph = [VmwDscResourceGraph]::new($dscResOrderedDict)

    # sort the resources based on their dependencies
    $sortedDscResArr = $resGraph.TopologicalSort()

    $result = New-Object -TypeName 'System.Collections.ArrayList'

    # iterate the ordered resources to find composite resources and retrieve their inner resources
    for ($i = 0; $i -lt $sortedDscResArr.Count; $i++) {
        $resource = $sortedDscResArr[$i]

        if ($resource.GetIsComposite()) {
            $innerResources = $resource.GetInnerResources()

            # this sorts the composite resource dsc resources and handles inner DependsOn properties
            $parsedInnerResources = ParseDscResource $innerResources

            $resource.SetInnerResources($parsedInnerResources)
        } 

        $result.Add($resource) | Out-Null
    }

    $result.ToArray()
}

<#
.Description
Parses the configuration scriptblock ast inside a configuration command.
Adds function definitions for found resources and nested configurations
#>
function ParseConfigurationBlock {
    [OutputType([ScriptBlock])]
    param (
        [System.Management.Automation.ConfigurationInfo]
        $ConfigCommand,

        [System.Collections.Generic.Dictionary[string,ScriptBlock]]
        $RequiredInvokeFuncs
    )

    $configTextBlock = $ConfigCommand.ScriptBlock.Ast.Extent.Text

    # Remove the opening and closing brackets
    $configTextBlock = $configTextBlock.Substring(1)
    $configTextBlock = $configTextBlock.Substring(0, $configTextBlock.LastIndexOf('}')).Trim()

    # find all dynamic keywords inside the configuration
    $dynamicKeywords = $ConfigCommand.ScriptBlock.Ast.FindAll({
        $args[0] -is [System.Management.Automation.Language.DynamicKeywordStatementAst]
    }, $true)

    # list of configuration names used for finding if a resource in the configuration is a nested configuration
    $configurationsList = Get-Command -ListImported | Where-Object {
        $_.CommandType -eq 'Configuration'
    } | Select-Object -ExpandProperty Name

    foreach ($dynamicKeyword in $dynamicKeywords) {
        $itemName = $dynamicKeyword.CommandElements[0].Value

        # change positions of '{' to appear right next to the item
        # so that the scriptblock gets counted as a parameter to the
        # function that will be generated for the dynamic item
        <#
            Resource name
            {
                Prop = 'text'
            }
            needs to become
            Resource name {
                Prop = 'text
            }
        #>
        $itemFullName = "$itemName $($dynamicKeyword.CommandElements[1].Value)"
        $configTextBlock = ReplaceBracketWith $configTextBlock $itemFullName "{"

        # check if item is a nested configuration
        if (-not $RequiredInvokeFuncs.ContainsKey($itemName) -and $configurationsList.Contains($itemName)) {
            $nestedConfigInnerName = $dynamicKeyword.CommandElements[1].Value
            $nestedConfigNewName = $itemName + $Script:NestedConfigPostFix

            $target = "$itemName $nestedConfigInnerName"
            $replacement = "$nestedConfigNewName $nestedConfigInnerName"

            # rename configuration in the scriptblock to be the (original + NestedConfigPostFix)
            # in order to avoid conflict with same names as original configuration
            # and be able to assign a function that handles the invoke of the nested block during
            # script execution
            $configTextBlock = $configTextBlock -replace $target, $replacement

            $RequiredInvokeFuncs.Add($nestedConfigNewName, $Function:InvokeNestedConfiguration)
        }
    }
    
    [scriptblock]::Create($configTextBlock)
}

<#
.Description
Parses and invokes nested configurations and composite resources
#>
function InvokeNestedConfiguration {
    [OutputType([VmwDscResource])]
    param (
        [string]
        $ConfigName,

        [Scriptblock]
        $ParamScriptBlock
    )

    # gets the resource type by getting the callStack and selecting the top first call which is this function call
    $configType = Get-PSCallStack | Select-Object -First 1 | Select-Object -ExpandProperty Command

    $postFixIndex = $configType.IndexOf($Script:NestedConfigPostFix)
    $configWithoutPostFix = [string]::Empty

    # check if configType contains postFixIndex
    # if it's contained then config is defined outside of module and has to be removed
    # if it's not contained then config is composite resource from module and needs to be added
    if ($postFixIndex -ne -1) {
        $configWithoutPostFix = $configType.Substring(0, $postFixIndex)
        $configType = $configType.Substring(0, $postFixIndex)
    } else {
        $configWithoutPostFix = $configType
        $configType += $Script:NestedConfigPostFix
    }

    $moduleName = [string]::Empty

    # checks if the function is contained the hashtable and gets the name of the module in which it's contained
    if ($resourceNameToDeclaringModuleName.ContainsKey($configWithoutPostFix)) {
        $moduleName = $resourceNameToDeclaringModuleName[$configWithoutPostFix].Name
    }

    # parse prop scriptblock into a hashtable
    $propsAsText = $ParamScriptBlock.Ast.Extent.Text
    $propsAsText = $propsAsText.Insert(0, '@')
    $parsedProps = Invoke-Expression $propsAsText

    $dependsOn = $null

    # check if dependsOn property is present and removes it 
    if ($parsedProps.ContainsKey('DependsOn')) {
        $dependsOn = $parsedProps['DependsOn']
        $parsedProps.Remove('DependsOn')
    }

    # get the inner resources from the nested configuration or composite resource
    $resources = GetResourcesFromConfiguration -ConfigName $configType -CustomParams $parsedProps

    $properties = @{}

    # adds the dependsOn property on each resource in the composite resource
    if ($null -ne $dependsOn) {
        $properties['DependsOn'] = $dependsOn
    }

    $compositeResource = [VmwDscResource]::new(
        $ConfigName,
        $configWithoutPostFix,
        $moduleName,
        $properties,
        $resources
    )
    
    $compositeResource
}

<#
.Description
Function used define Node logic

.Notes
Currently skips the node and only runs the script body within it
#>
function VmwNode {
    param (
        [string]
        $Name,

        [ScriptBlock]
        $ScriptBlock
    )

    throw 'Nodes are not supported'

    $res = Invoke-Command -ScriptBlock $ScriptBlock

    $res
}

<#
.Synopsis
Checks if configuration data is in valid format

.Description
The Configuration data is valid if it's in the following format: 
1. Is a hashtable
2. Has a collection AllNodes
3. Allnodes is an collection of Hashtable
4. Each element of Allnodes has NodeName
5. Node Names are unique for each node

.Notes
This logic will be used when Node functionality becomes supported.
The requirements of the configurationData are based on Powershell PSDesiredStateConfiguration
#>
function IsConfigurationDataValid {
    [OutputType([bool])]
    param (
        [Hashtable]
        $ConfigurationData
    )

    # temp check before the implementation of Node logic
    return ($null -ne $ConfigurationData)

    # check for AllNodes key
    if(-not $ConfigurationData.ContainsKey('AllNodes')) {
       throw "ConfigurationData is missing AllNodes key"
    }

    # check for AllNodes type
    if($ConfigurationData.AllNodes -isnot [array]) {
        throw "AllNodes key must be an collection of Hashtables"
    }

    $nodeNames = New-Object -TypeName 'System.Collections.Generic.HashSet[string]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)
    $allNodeSettings = $null

    foreach($node in $ConfigurationData.AllNodes) {
        # validate node type
        if($node -isnot [hashtable]) {
            throw "Nodes must be hashtables"
        }

        # validate node Name
        if (-not $node.NodeName) {
            throw "Nodes must contain a 'NodeName' key"
        }

        # check for duplicate nodes
        if($nodeNames.Contains($node.NodeName)) {
            throw "Duplicate Node with name $($node.NodeName) found"
        }

        # special case for node logic that applies to all nodes
        if($node.NodeName -eq '*') {
            $allNodeSettings = $node
        }

        $nodeNames.Add($node.NodeName) | Out-Null
    }

    # Copy values from NodeName="*" to all node if they don't exist
    if($null -ne $allNodeSettings) {
        foreach($node in $configurationData.AllNodes) {
            if($node.NodeName -ne '*') {
                foreach($nodeKey in $allNodeSettings.Keys) {
                    if(-not $node.ContainsKey($nodeKey)) {
                        $node.Add($nodeKey, $allNodeSettings[$nodeKey])
                    }
                }
            }
        }

        $configurationData.AllNodes = @($configurationData.AllNodes | Where-Object -FilterScript {
                $_.NodeName -ne '*'
            }
        )
    }

    $true
}

<#
.Synopsis
This function is used for Import-DscResource definition
.Description
This function is used as a Import-DscResource substite.
It finds the dsc resource that match the search creteria of resource name, module name and version.
The found resource get inserted into a hashtable with key: resource name and value: module of resource
#>
function ImportDscResource {
    [OutputType([void])]
    param (
        [string]
        $Name,          # name of the dsc resource
        
        [string]
        $ModuleName,    # name of the module in which the resource is contained
        
        [string]
        $ModuleVersion  # the required version of the module
    )

    <#
        At least $Name or $ModuleName needs to be specified for this function
        The empty values get replaced with '*' for all
    #>
    if ([string]::IsNullOrEmpty($Name) -or [string]::IsNullOrWhiteSpace($Name)) {
        $Name = '*'
    }

    if ([string]::IsNullOrEmpty($ModuleName) -or [string]::IsNullOrWhiteSpace($ModuleName)) {
        $ModuleName = '*'
    }

    if ([string]::IsNullOrEmpty($ModuleVersion) -or [string]::IsNullOrWhiteSpace($ModuleVersion)) {
        $ModuleVersion = '*'
    }
    
    # finds the dsc resources which match the search criteria
    $importedResources = Get-DscResource -Name $Name -Module $ModuleName

    # finds the module by $ModuleVersion if present. 
    # if $Moduleversion is '*' it gets resource with highest version
    # all found resource which match the crieteria get inserted into the resource hash table
    foreach ($resource in $importedResources) {
        if ($ModuleVersion -eq '*' -or $resource.Version.ToString() -eq $ModuleVersion) {
            if ($resourceNameToDeclaringModuleName.ContainsKey($resource.Name) -and
                $resourceNameToDeclaringModuleName[$resource.Name].Version -gt $resource.Version) {
                continue
            }

            $resourceNameToDeclaringModuleName[$resource.Name] = $resource.Module

            SetResourceHandlerFuncs $resource
        }
    }
}

<#
.Description
Sets functions for invoking regular and composite dsc resource
#>
function SetResourceHandlerFuncs {
    [OutputType([void])]
    param (
        [Microsoft.PowerShell.DesiredStateConfiguration.DscResourceInfo]
        $Resource
    )
    
    if ($resource.ImplementedAs -eq [System.Management.Automation.ImplementedAsType]::Composite) {
        $resourceModuleInfo = Get-Module $resource.Name

        $resourceConfig = $resourceModuleInfo.ExportedFunctions[$resource.Name]

        # this functions contains the original configuration
        Set-Item -Path "Function:Script:$($resourceConfig.Name + $Script:NestedConfigPostFix)" -Value $resourceConfig.ScriptBlock | Out-Null

        # this function contains the function for config scriptblock execution 
        Set-Item -Path "Function:$($resourceConfig.Name)" -Value $Function:InvokeNestedConfiguration | Out-Null
    } else {
        Set-Item -Path "Function:Script:$($resource.Name)" -Value $Function:GetDscResourceData | Out-Null
    }
}

<#
.Synopsis
This function is used for Resource function definitions
.Description
This function is used to create the needed function definitons of the Resources in a dsc configuration.
The scriptblock gets parsed into a hashtable, because it contains the properties of the resource (ex. DependsOn, Ensure...).
The type of the resource gets found out during runtime by looking up the function name in the PSCallStack.
Outputs an object with the parameters, resource name, resource type and module name
#>
function GetDscResourceData {
    [OutputType([VmwDscResource])]
    param (
        [parameter(Mandatory)]
        [string]
        $Name,                  # name of the dsc resource
        
        [parameter(Mandatory)]
        [ScriptBlock]
        $Properties             # properties of the dsc resource
    )

    $propsAsText = $Properties.Ast.Extent.Text

    $propsAsText = $propsAsText.Insert(0, '@')

    $parsedProps = Invoke-Expression $propsAsText

    $moduleName = [string]::Empty

    # gets the resource type by getting the callStack and selecting the top first call which is this function call
    $resourceType = Get-PSCallStack | Select-Object -First 1 | Select-Object -ExpandProperty Command 

    # checks if the function is contained the hashtable and gets the name of the module in which it's contained
    if ($resourceNameToDeclaringModuleName.ContainsKey($resourceType)) {
        $moduleName = $resourceNameToDeclaringModuleName[$resourceType].Name
    }
    else {
        # if the resource is not found throws exception
        throw ($Script:DscResourceNotFoundException -f $resourceType)
    }

    $result = [VmwDscResource]::new(
        $Name,
        $resourceType,
        $moduleName,
        $parsedProps
    )

    $result
}

<#
.Description
Replaces the first found opening bracket after SearchString
and replaces it with StringToReplace in StringToChange
.Example
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
function ReplaceBracketWith {
    [OutputType([string])]
    param (
        [string]
        $StringToChange,

        [string]
        $SearchString,

        [string]
        $StringToReplaceWith
    )

    $regexStr = "$SearchString[\s]*{"
    $replacement = "$SearchString $StringToReplaceWith"

    $StringToChange = $StringToChange -replace $regexStr, $replacement

    $StringToChange
}

