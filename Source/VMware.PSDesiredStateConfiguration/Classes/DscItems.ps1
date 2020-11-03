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

<#
.DESCRIPTION
Base class for DSC items
#>
class DscItem {
    [ValidateNotNullOrEmpty()]
    [string] $InstanceName

    DscItem($InstanceName) {
        $this.InstanceName = $InstanceName
    }
}

<#
.DESCRIPTION
Class that defines a DSC configuration
#>
class VmwDscConfiguration : DscItem {
    [VmwDscNode[]] $Nodes

    VmwDscConfiguration($InstanceName, $Nodes) : base($InstanceName) {
        $this.Nodes = $Nodes
    }
}

<#
.DESCRIPTION
Class that defines a regular DSC Node
#>
class VmwDscNode : DscItem {
    [VmwDscResource[]] $Resources

    VmwDscNode($Connection, $Resources) : base($Connection) {
        $this.Resources = $Resources
    }
}

<#
.DESCRIPTION
Class that defines a vSphere DSC Node
#>
class VmwVsphereDscNode : VmwDscNode {
    VmwVsphereDscNode($Connection, $Resources) : base ($Connection, $Resources) { }
}

<#
.DESCRIPTION
Class that defines a dsc resource
#>
class VmwDscResource : DscItem {
    [ValidateNotNullOrEmpty()]
    [string] $InstanceName

    [ValidateNotNullOrEmpty()]
    [string] $ResourceType

    [ValidateNotNull()]
    [Hashtable] $Property

    [Microsoft.PowerShell.Commands.ModuleSpecification]
    $ModuleName

    hidden [VmwDscResource[]] $InnerResources

    VmwDscResource($InstanceName, $ResourceType, $ModuleName, $Property, $InnerResources) : base($InstanceName) {
        $this.Init($ResourceType, $ModuleName, $Property, $InnerResources)
    }

    VmwDscResource($InstanceName, $ResourceType, $ModuleName, $Property) : base($InstanceName) {
        $this.Init($ResourceType, $ModuleName, $Property, $null)
    }

    VmwDscResource($InstanceName, $ResourceType, $ModuleName) : base($InstanceName) {
        $this.Init($ResourceType, $ModuleName, @{}, $null)
    }

    # init function sets the values of properties, because powershell does not support chaining constructors
    hidden [void] Init($ResourceType, $ModuleName, $Property, $InnerResources) {
        $this.ResourceType = $ResourceType
        $this.Property = $Property
        $this.innerResources = $InnerResources

        if ($null -ne $ModuleName) {
            $this.ModuleName = $ModuleName -as [Microsoft.PowerShell.Commands.ModuleSpecification]
        }
    }

    # return flag if the dsc resource is composite
    [bool] GetIsComposite() {
        return $null -ne $this.InnerResources
    }

    # returns inner resources for composite dsc resources
    [VmwDscResource[]] GetInnerResources() {
        return $this.innerResources
    }

    # sets innerresources for a composite resource
    [void] SetInnerResources([VmwDscResource[]] $innerResources) {
        if ($null -eq $innerResources) {
            throw '$innerResources must not be null!'
        }
        
        $this.innerResources = $innerResources
    }

    # gets the unique id of the resource
    [string] GetId() {
        return "[$($this.ResourceType)]$($this.InstanceName)"
    }

    [string] ToString() {
        return "$($this.ResourceType) $($this.InstanceName)"
    }
}

<#
.DESCRIPTION
This graph is used to sort Resources by their 'DependsOn' key in the 'Property' property
#>
class VmwDscResourceGraph {
    [System.Collections.Specialized.OrderedDictionary] 
    hidden $Edges

    [System.Collections.Specialized.OrderedDictionary]
    hidden $Resources

    VmwDscResourceGraph([System.Collections.Specialized.OrderedDictionary] $Resources) {
        $this.Resources = $Resources
        $this.FillEdges()
    }

    <#
    .DESCRIPTION
    Sorts the resources in the graph so that
    the resources get ordered based on their dependencies
    #>
    [System.Array] TopologicalSort() {
        # bool array for keeping track of visited resources
        $visited = New-Object 'System.Collections.Generic.HashSet[string]'
        # hashtable for detecting circular dependencies
        $cycles = New-Object 'System.Collections.Generic.HashSet[string]'
        # resource keys wil be kept inside this stack
        $sortedResourceKeys = New-Object -TypeName 'System.Collections.Stack'

        $keysArr = @($this.Edges.Keys)

        for ($i = 0; $i -lt $keysArr.Count; $i++) {
            $ind = $this.edges.Count - 1 - $i
            $key = $keysArr[$ind]
            $this.TopologicalSortUtil($key, $sortedResourceKeys, $visited, $cycles)
        }

        $result = New-Object -TypeName 'System.Collections.Arraylist'

        foreach ($resKey in $sortedResourceKeys) {
            $result.Add($this.Resources[$resKey]) | Out-Null
        }

        return $result.ToArray()
    }

    <#
    .DESCRIPTION
    Uses DFS in order to traverse the graph
    #>
    [void] hidden TopologicalSortUtil(
    [string] $ResKey,
    [System.Collections.Stack] $sortedResourceKeys,
    [System.Collections.Generic.HashSet[string]] $Visited,
    [System.Collections.Generic.HashSet[string]] $Cycles) {
        if ($Cycles.Contains($ResKey)) {
            throw "Cycle detected with key: $ResKey"
        }
    
        if ($Visited.Contains($ResKey)) {
            return
        }
    
        $Visited.Add($ResKey) | Out-Null
        $Cycles.Add($ResKey) | Out-Null 
    
        foreach ($child in $this.Edges[$ResKey]) {
            $this.TopologicalSortUtil($child, $sortedResourceKeys, $visited, $cycles)
        }
    
        $Cycles.Remove($ResKey) | Out-Null
        $SortedResourceKeys.Push($ResKey) | Out-Null
    }

    <#
    .DESCRIPTION
    Fills $Edges ordered dictionary from $Resources ordered dictionary
    #>
    [void] hidden FillEdges() {
        # adjecency list representing dependencies between resources
        $this.Edges = [ordered]@{}

        # initialize lists
        foreach ($key in $this.Resources.Keys) {
            $children = New-Object -TypeName 'System.Collections.ArrayList'
            $this.Edges[$key] = $children
        }

        # insert dependencies into edges
        foreach ($key in $this.Resources.Keys) {
            if (-not $this.Resources[$key].Property.ContainsKey('DependsOn')) {
                continue
            }

            $dependencies = $this.Resources[$key].Property['DependsOn']

            foreach ($dependency in $dependencies) {
                if (-not $this.Edges.Contains($dependency)) {
                    throw ($Script:DependsOnResourceNotFoundException -f $this.Resources[$key].InstanceName, $dependency)
                }
        
                # remove DependsOn item so that it does not conflict with Invoke-DscResource later on
                $this.Resources[$key].Property.Remove('DependsOn') | Out-Null
        
                $this.Edges[$dependency].Add($key) | Out-Null
            }
        }
    }
}

<#
.DESCRIPTION
Used for parsing and compiling a DSC Configuration into a DSC object.
#>
class DscConfigurationCompiler {
    hidden [string] $ConfigName
    hidden [Hashtable] $CustomParams
    hidden [Hashtable] $ConfigurationData
    hidden [Hashtable] $ResourceNameToInfo
    hidden [Hashtable] $CompositeResourceToScriptBlock
    hidden [bool] $IsNested

    DscConfigurationCompiler([string] $ConfigName, [Hashtable] $CustomParams, [Hashtable] $ConfigurationData) {
        $this.ConfigName = $ConfigName
        $this.CustomParams = $CustomParams
        $this.ConfigurationData = $ConfigurationData

        $this.ResourceNameToInfo = @{}
        $this.CompositeResourceToScriptBlock = @{}
        $this.IsNested = $false
    }

    <#
    .DESCRIPTION
    Compiles the DSC Configuration and returns an configuration object
    #>
    [VmwDscConfiguration] CompileDscConfiguration() {
        # validate the configurationData
        $this.ValidateConfigurationData()

        # retrieve the configuration command from loaded commands.
        $configCommand = $this.GetConfigCommand($this.ConfigName)

        # parse and compile the configuration
        $dscItems = $this.CompileDscConfigurationUtil($configCommand, $this.CustomParams)

        # combine nodes of same instanceName and bundle nodeless resources
        $dscNodes = $this.CombineNodes($dscItems)

        for ($i = 0; $i -lt $dscNodes.Length; $i++) {
            # parse the dsc resources and their dependencies into a sorted array
            $dscNodes[$i].Resources = $this.OrderResources($dscNodes[$i].Resources)
        }

        $dscConfigurationObject = [VmwDscConfiguration]::new(
            $this.ConfigName,
            $dscNodes
        )

        return $dscConfigurationObject
    }

    <#
    .DESCRIPTION
    Ensures ConfigurationData is valid if present.
    Throws an exception if ConfigurationData is invalid.
    #>
    hidden [void] ValidateConfigurationData() {
        # if the configurationData is null nothing is validated
        if ($null -eq $this.ConfigurationData) {
            return
        }

        # must contain AllNodes key
        if (-not $this.ConfigurationData.ContainsKey('AllNodes')) {
            throw $Script:ConfigurationDataDoesNotContainAllNodesException
        }

        # AllNodes key must be array
        if ($this.ConfigurationData['AllNodes'] -isnot [Array]) {
            throw $Script:ConfigurationDataAllNodesKeyIsNotAnArrayException
        }

        # hashset for detecting entries with same nodeName property
        $duplicateNodeNameSet = New-Object -TypeName 'System.Collections.Generic.HashSet[string]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)
        
        # will contain the common nodes setting marked with '*'
        $commonNodesConfiguration = $null

        foreach ($nodeConfiguration in $this.ConfigurationData['AllNodes']) {
            # each node entry must be a hashtable
            if ($nodeConfiguration -isnot [Hashtable]) {
                throw $Script:ConfigurationDataNodeEntryInAllNodesIsNotAHashtableException
            }

            # each node entry must have a NodeName property
            if (-not $nodeConfiguration.ContainsKey('NodeName')) {
                throw $Script:ConfigurationDataNodeEntryInAllNodesDoesNotContainNodeNameException
            }

            # checks if nodeName is added to the hashset or if it's already in.
            $isNodeNameAdded = $duplicateNodeNameSet.Add($nodeConfiguration['NodeName'])

            if (-not $isNodeNameAdded) {
                throw $Script:DuplicateEntryInAllNodesException
            }

            if($nodeConfiguration['NodeName'] -eq '*')
            {
                $commonNodesConfiguration = $nodeConfiguration
            }
        }

        # remove the common node settings entry
        $this.ConfigurationData['AllNodes'] = $this.ConfigurationData['AllNodes'] | Where-Object { $_.NodeName -ne '*' }

        # add the common node settings entry properties to each node configuration
        if ($null -ne $commonNodesConfiguration) {
            foreach($nodeConfiguration in $this.ConfigurationData['AllNodes']) {
                foreach($nodeKey in $commonNodesConfiguration.Keys)
                {
                    if(-not $nodeConfiguration.ContainsKey($nodeKey))
                    {
                        $nodeConfiguration[$nodeKey] = $commonNodesConfiguration[$nodeKey]
                    }
                }
            }
        }
    }

    <#
    .DESCRIPTION
    Orders a collection of Dsc resources based on their DependsOn property and check for duplicate ids.
    When a duplicate is found an exception is thrown.
    #>
    hidden [VmwDscResource[]] OrderResources([VmwDscResource[]] $DscResources) {
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
                $parsedInnerResources = $this.OrderResources($innerResources)
    
                $resource.SetInnerResources($parsedInnerResources)
            } 
    
            $result.Add($resource) | Out-Null
        }
    
        return $result.ToArray()
    }

    <#
    .DESCRIPTION
    Handles the main logic for compiling a dsc configuration
    #>
    hidden [DscItem[]] CompileDscConfigurationUtil([System.Management.Automation.ConfigurationInfo] $ConfigCommand, [Hashtable] $CustomParams) {
        $dscConfigurationParser = [DscConfigurationParser]::new()

        $foundDscResourcesList = New-Object -TypeName 'System.Collections.ArrayList'
        $configScriptBlock = $dscConfigurationParser.ParseDscConfiguration($configCommand, $foundDscResourcesList, $this.CompositeResourceToScriptBlock, $this.ResourceNameToInfo)
        $functionsToDefine = $this.CreateFunctionsToDefine($foundDscResourcesList.ToArray())

        $variablesToDefine = $this.CreateVariablesToDefine()

        $dscItems = $configScriptBlock.InvokeWithContext($functionsToDefine, $variablesToDefine, $CustomParams)

        return $dscItems
    }

    hidden [Array] CreateVariablesToDefine() {
        $result = @(
            if ($null -ne $this.ConfigurationData) {
                New-Object -TypeName PSVariable -ArgumentList ('ConfigurationData', $this.ConfigurationData )
                New-Object -TypeName PSVariable -ArgumentList ('ConfigurationData', $this.ConfigurationData.AllNodes )
            }
        )
        
        return $result
    }

    <#
    .DESCRIPTION
    Combines nodes of same name and adds nodeless resources to a default localhost node.
    #>
    hidden [VmwDscNode[]] CombineNodes([DscItem[]] $DscItemsArr) {
        $nodeLessResources = New-Object -TypeName 'System.Collections.ArrayList'
        $connectionNodes = [ordered]@{}

        for ($i = 0; $i -lt $DscItemsArr.Count; $i++) {
            # can be a node or nodeless resource 
            $dscItem = $DscItemsArr[$i]

            # keep nodeless resources in a separate array in order to add them to the default 'localhost' node
            if ($dscItem -is [VmwDscResource]) {
                $nodeLessResources.Add($dscItem) | Out-Null

                continue
            }

            if ($dscItem -is [VmwDscNode]) {
                if (-not $connectionNodes.Contains($dscItem.InstanceName)) {
                    $connectionNodes[$dscItem.InstanceName] = $dscItem
                } else {
                    $connectionNodes[$dscItem.InstanceName] += $dscItem
                }

                continue
            }

            foreach ($connection in $dscItem.Connections) {
                if (-not $connectionNodes.Contains($connection)) {
                    $nodeObject = New-Object -TypeName $dscItem.Type -ArgumentList $connection, $dscItem.Resources

                    $connectionNodes[$connection] = $nodeObject

                    continue
                }

                $connectionNodes[$connection].Resources += $dscItem.Resources
            }
        }

        if ($nodeLessResources.Count -gt 0) {
            $localHostConnection = 'localhost'
            
            if ($connectionNodes.Contains($localHostConnection)) {
                $connectionNodes[$localHostConnection].Resources += $nodeLessResources.ToArray()
            } else {
                $localhostNode = [VmwDscNode]::new(
                    $localHostConnection,
                    $nodeLessResources.ToArray()
                )

                $connectionNodes[$localHostConnection] = $localHostNode
            }
        }

        return @( $connectionNodes.Values )
    }

    <#
    .DESCRIPTION
    Creates functions for handling the dsc resources and dynamic keywords.
    #>
    hidden [Hashtable] CreateFunctionsToDefine([System.String[]] $foundDscResourcesArr) {
        $functionsToDefine = @{}

        $dscResourceScriptBlock = {
            Param(
                [string]
                $Name,
                [ScriptBlock]
                $Properties
            )

            $this.ParseDscResource($Name, $Properties)
        }

        foreach ($dscResourceName in $foundDscResourcesArr) {
            $functionsToDefine[$dscResourceName] = $dscResourceScriptBlock
        }

        $nestedConfigAndCompositeResScriptBlock = {
            Param(
                [string]
                $NestedConfigName,
                [ScriptBlock]
                $Properties,
                [string]
                $ResourceOrConfigType = ''
            )

            if ($this.IsNested) {
                throw $Script:NestedMoreThanASingleLevelException
            }

            $this.IsNested = $true

            # parse prop scriptblock into a hashtable
            $propsAsText = $Properties.Ast.Extent.Text
            $propsAsText = $propsAsText.Insert(0, '@')
            $parsedProps = Invoke-Expression $propsAsText

            $dependsOn = $null

            # check if dependsOn property is present and removes it 
            if ($parsedProps.ContainsKey('DependsOn')) {
                $dependsOn = $parsedProps['DependsOn']
                $parsedProps.Remove('DependsOn')
            }

            $configType = Get-PSCallStack | Select-Object -First 1 | Select-Object -ExpandProperty Command

            $innerResources = $this.CompileDscConfigurationUtil($this.CompositeResourceToScriptBlock[$configType], $parsedProps)

            $compositeResourceProps = @{}

            # adds the dependsOn property on each resource in the composite resource
            if ($null -ne $dependsOn) {
                $compositeResourceProps['DependsOn'] = $dependsOn
            }

            $moduleName = $null
            if ($this.ResourceNameToInfo.ContainsKey($configType)) {
                $moduleName = @{
                    ModuleName = $this.ResourceNameToInfo[$configType].ModuleName
                    RequiredVersion = $this.ResourceNameToInfo[$configType].Version
                } 
            }

            $compositeResource = [VmwDscResource]::new(
                $NestedConfigName,
                $configType,
                $moduleName,
                $compositeResourceProps,
                $innerResources
            )

            $this.IsNested = $false

            return $compositeResource
        }

        foreach ($configName in $this.CompositeResourceToScriptBlock.Keys) {
            $functionsToDefine[$configName] = $nestedConfigAndCompositeResScriptBlock
        }

        $nodeLogicScriptBlock = {
            Param (
                [string[]]
                $Connections,
        
                [ScriptBlock]
                $ScriptBlock
            )

            if ($this.IsNested) {
                throw $Script:NestedNodesAreNotSupportedException
            }
        
            $dscResources = . $ScriptBlock

            $type = Get-PSCallStack | Select-Object -First 1 -ExpandProperty Command
            $vmwNodeResult = $null

            if ($type -eq 'Node') {
                $vmwNodeResult = [VmwDscNode]::new($Connections, $dscResources)
            } elseif ($type -eq 'vSphereNode') {
                $vmwNodeResult = [VmwVsphereDscNode]::new($Connections, $dscResources)
            }
            
            $vmwNodeResult
        }

        $functionsToDefine['Node'] = $nodeLogicScriptBlock
        $functionsToDefine['vSphereNode'] = $nodeLogicScriptBlock

        return $functionsToDefine
    }
    
    <#
    .DESCRIPTION
    Handles the logic for Import-DscResource.
    #>
    hidden [void] ParseImportDscResource([string[]] $Name, $ModuleName) {
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

    <#
    .DESCRIPTION
    Handles the logic for dsc resources and composite dsc resources.
    #>
    hidden [VmwDscResource] ParseDscResource([string] $Name, [ScriptBlock] $Properties) {
        $moduleName = [string]::Empty

        # gets the resource type by getting the callStack and selecting the top first call which is this function call
        $resourceType = Get-PSCallStack | Select-Object -Skip 1 -First 1 -ExpandProperty Command

        if (-not $this.ResourceNameToInfo.ContainsKey($resourceType)) {
             # if the resource is not found throws exception
             throw ($Script:DscResourceNotFoundException -f $resourceType)
        }

        $resourceInfo = $this.ResourceNameToInfo[$resourceType]
        $moduleName = @{
            ModuleName = $resourceInfo.Module.Name
            RequiredVersion = $resourceInfo.Module.Version
        }
    
        $propsAsText = $Properties.Ast.Extent.Text
        $propsAsText = $propsAsText.Insert(0, '@')
        $parsedProps = Invoke-Expression $propsAsText
    
        $result = [VmwDscResource]::new(
            $Name,
            $resourceType,
            $moduleName,
            $parsedProps
        )
    
        return $result
    }

    <#
    .DESCRIPTION
    Validates that the command is of type Configuration and returns it.
    #>
    hidden [System.Management.Automation.ConfigurationInfo] GetConfigCommand([string] $ConfigName) {
        # find the configuration with the given name
        $foundConfigCommand = Get-Command $ConfigName -ErrorAction SilentlyContinue

        if ($null -eq $foundConfigCommand) {
            throw ($Script:ConfigurationNotFoundException -f $ConfigName)
        }

        # check if found command is correct type
        if ($foundConfigCommand.CommandType -ne 'Configuration') {
            throw ($Script:CommandIsNotAConfigurationException -f $ConfigName, $foundConfigCommand.CommandType)
        }

        return $foundConfigCommand
    }
}

<#
.DESCRIPTION
Class that handles the parsing of the DSC 
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
    [ScriptBlock] ParseDscConfiguration([System.Management.Automation.ConfigurationInfo] $ConfigCommand,
    [System.Collections.ArrayList] $FoundDscResourcesList,
    [Hashtable] $NestedConfigToScriptBlock,
    [Hashtable] $ResourceNameToInfo) {
        $configTextBlock = $ConfigCommand.ScriptBlock.Ast.Extent.Text
        
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

        foreach ($resource in $this.ResourceNameToInfo.Keys) {
            $ResourceNameToInfo[$resource] = $this.ResourceNameToInfo[$resource]
        }

        $configTextBlock = $configTextBlock.Insert(0, 'Param( $CustomParams ) . ')

        # find all dynamic keywords inside the configuration
        # nodes are removed from the list as they are executed separately
        $dynamicKeywords = $ConfigCommand.ScriptBlock.Ast.FindAll({
            $args[0] -is [System.Management.Automation.Language.DynamicKeywordStatementAst]
        }, $true)

        # set bracket placement
        foreach ($dynamicKeyword in $dynamicKeywords) {
            $itemName = $dynamicKeyword.CommandElements[0].Value
    
            $itemFullName = "$itemName $($dynamicKeyword.CommandElements[1].Extent.Text)"
            $configTextBlock = $this.ReplaceBracketWith($configTextBlock, $itemFullName, "{")

            if ($itemName -eq 'Node') {
                continue
            }

            # check if resource is nested configuration
            $nestedConfigCommand = Get-Command $itemName -ErrorAction 'SilentlyContinue'

            if (($null -ne $nestedConfigCommand) -and ($nestedConfigCommand.CommandType.ToString() -eq 'Configuration')) {
                $NestedConfigToScriptBlock[$itemName] = $nestedConfigCommand
            } else {
                $FoundDscResourcesList.Add($itemName) | Out-Null
            }
        }

        $configTextBlock += ' @CustomParams'

        # return created scriptblock
        return [ScriptBlock]::Create($configTextBlock)
    }

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
