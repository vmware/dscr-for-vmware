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

        $this.CompositeResourceToScriptBlock = @{}
        $this.ResourceNameToInfo = @{}
        $this.IsNested = $false
    }

    <#
    .DESCRIPTION
    Compiles the DSC Configuration and returns an configuration object
    #>
    [VmwDscConfiguration] CompileDscConfiguration() {
        Write-Verbose "Starting compilation process"

        Write-Verbose "Validating ConfigurationData"
        
        # validate the configurationData
        $this.ValidateConfigurationData()

        # retrieve the configuration command from loaded commands.
        $configCommand = $this.GetConfigCommand($this.ConfigName)

        # parse and compile the configuration
        $dscItems = $this.CompileDscConfigurationUtil($configCommand, $this.CustomParams)

        Write-Verbose "Handling nodes"

        # combine nodes of same instanceName and bundle nodeless resources
        $dscNodes = $this.CombineNodes($dscItems)

        for ($i = 0; $i -lt $dscNodes.Length; $i++) {
            Write-Verbose ("Ordering DSC Resources of node: " + $dscNodes[$i].InstanceName)

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

        Write-Verbose "Parsing configuration block of $($ConfigCommand.Name)"

        # parse the configuration, run Import-DscResource statements and retrieve the found resources/nested configurations
        $parseResult = $dscConfigurationParser.ParseDscConfiguration($configCommand)

        Write-Verbose "Preparing functions for dsc resources and nodes"

        $resources = $parseResult.ResourceNameToInfo
        $foundDscResourcesList = New-Object -TypeName 'System.Collections.ArrayList'
        # divide the regular resources and composite/nested into separate groups
        foreach ($resourceName in $resources.Keys) {
            $this.ResourceNameToInfo[$resourceName] = $resources[$resourceName]

            $resourceInfo = $this.ResourceNameToInfo[$resourceName]

            if (($resourceInfo.ImplementedAs.ToString() -eq 'Composite' -or $resourceInfo.ImplementedAs.ToString() -eq 'Configuration') -and
                (-not $this.CompositeResourceToScriptBlock.ContainsKey($resourceName))) {
                $this.CompositeResourceToScriptBlock[$resourceName] = (Get-Command $resourceName -ErrorAction 'SilentlyContinue')
            } else {
                $foundDscResourcesList.Add($resourceName) | Out-Null
            }
        }

        # create functions for nodes and resources to be used in InvokeWithContext
        $functionsToDefine = $this.CreateFunctionsToDefine($foundDscResourcesList.ToArray())

        Write-Verbose "Preparing default variables and variables from ConfigurationData"

        # create variable objects for InvokeWithContext from ConfigurationData and common dsc configuration variables
        $variablesToDefine = $this.CreateVariablesToDefine()

        $configScriptBlock = $parseResult.ScriptBlock

        Write-Verbose "Executing Configuration scriptblock to extract resources and nodes"

        $dscItems = $configScriptBlock.InvokeWithContext($functionsToDefine, $variablesToDefine, $CustomParams)

        return $dscItems
    }

    <#
    .DESCRIPTION
    Creates variables that will be used during the dsc configuration scriptblock execution
    #>
    hidden [Array] CreateVariablesToDefine() {
        $result = @(
            if ($null -ne $this.ConfigurationData) {
                New-Object -TypeName PSVariable -ArgumentList ('ConfigurationData', $this.ConfigurationData )
                New-Object -TypeName PSVariable -ArgumentList ('AllNodes', $this.ConfigurationData.AllNodes )
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

        # group nodeless resources
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
                $Properties
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

            # get type of the configuration from the stack
            $configType = Get-PSCallStack | Select-Object -First 1 | Select-Object -ExpandProperty Command

            # retrieve internal resources
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
            $vmwNodeResult = New-Object -TypeName 'System.Collections.ArrayList'

            # when multipe connections are specified for a node blocke
            # each connection gets made into a different node object
            foreach ($connection in $Connections) {
                $nodeObject = $null

                if ($type -eq 'Node') {
                    $nodeObject = [VmwDscNode]::new($connection, $dscResources)
                } elseif ($type -eq 'vSphereNode') {
                    $nodeObject = [VmwVsphereDscNode]::new($connection, $dscResources)
                }

                $vmwNodeResult.Add($nodeObject) | Out-Null
            }

            $vmwNodeResult.ToArray()
        }

        $functionsToDefine['Node'] = $nodeLogicScriptBlock
        $functionsToDefine['vSphereNode'] = $nodeLogicScriptBlock

        return $functionsToDefine
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
    [PsObject] ParseDscConfiguration([System.Management.Automation.ConfigurationInfo] $ConfigCommand) {
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

            $command = (Get-Command $itemName -ErrorAction 'SilentlyContinue')

            # case for nested configurations
            if ($null -ne $command -and -not $this.ResourceNameToInfo.ContainsKey($itemName)) {
                $this.ResourceNameToInfo[$itemName] = [PsObject]@{
                    ImplementedAs = 'Configuration'
                }
            }
        }

        $configTextBlock += ' @CustomParams'

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

<#
.DESCRIPTION
Base type for Invoke-VmwDscConfigurations results
#>
class BaseDscMethodResult {
    [string] $NodeName

    BaseDscMethodResult([string] $NodeName) {
        $this.NodeName = $NodeName
    }
}

<#
.DESCRIPTION
Used for get method result to represent composite resources
#>
class CompositeResourceGetMethodResult {
    [string] $Name
    
    [PsObject[]] $InnerResources

    CompositeResourceGetMethodResult([string] $Name, [PsObject[]] $InnerResources) {
        $this.Name = $Name
        $this.InnerResources = $InnerResources
    }
}

<#
.DESCRIPTION
Result type for Get-VmwDscConfiguration
#>
class DscGetMethodResult : BaseDscMethodResult {
    [PsObject[]] $ResourcesStates

    DscGetMethodResult([VmwDscNode] $Node, [PsObject[]]$Resources) : base($Node.InstanceName) {
        $this.FillResourceStates($Node, $Resources)
    }

    hidden [void] FillResourceStates([VmwDscNode] $Node, [PsObject[]]$Resources) {
        $result = New-Object 'System.Collections.ArrayList'

        for ($i = 0; $i -lt $Resources.Count; $i++) {
            $states = $Resources[$i]
            $objectToAdd = $null

            if ($states.Count -gt 1) {
                $objectToAdd = [CompositeResourceGetMethodResult]::new($Node.Resources[$i].InstanceName, $states)
            } else {
                $objectToAdd = $states
            }

            $result.Add($objectToAdd) | Out-Null
        }

        $this.ResourcesStates = $result.ToArray()
    }
}

<#
.DESCRIPTION
Result type for Test-VmwDscConfiguration with -Detailed flag switched on
#>
class DscTestMethodDetailedResult : BaseDscMethodResult {
    [bool] $InDesiredState

    [VmwDscResource[]] $ResourcesInDesiredState

    [VmwDscResource[]] $ResourcesNotInDesiredState

    DscTestMethodDetailedResult([VmwDscNode] $Node, [PsObject[]] $StateArr) : base($Node.InstanceName) {
        $this.NodeName = $Node.InstanceName

        $this.GroupResourcesByDesiredState($node.Resources, $StateArr)
    }

    hidden [void] GroupResourcesByDesiredState([VmwDscResource[]] $Resources, [PsObject[]] $StateArr) {
        $this.InDesiredState = $true
        $resInDesiredState = New-Object -TypeName 'System.Collections.ArrayList'
        $resNotInDesiredState = New-Object -TypeName 'System.Collections.ArrayList'

        for ($i = 0; $i -lt $Resources.Count; $i++) {
            # states can be an array due to composite resources having multiple inner resources
            $states = $StateArr[$i]
            $currInDesiredState = $true

            foreach ($state in $states) {
                if (-not $state.InDesiredState) {
                    $currInDesiredState = $false
                    break
                }
            }

            # add to correct array depending on the desired state
            if ($currInDesiredState) {
                $resInDesiredState.Add($Resources[$i]) | Out-Null
            } else {
                $resNotInDesiredState.Add($Resources[$i]) | Out-Null
                $this.InDesiredState = $false
            }
        }

        $this.ResourcesInDesiredState = $resInDesiredState.ToArray()
        $this.ResourcesNotInDesiredState = $resNotInDesiredState.ToArray()
    }
}

<#
.DESCRIPTION
Type used for checking uniqueness of dsc resource key properties
#>
class DscKeyPropertyResourceCheck {
    [string] $DscResourceType
      
    # can contain only string, int, enum values, because only properties of those types can be keys
    [Hashtable] $KeyPropertiesToValues

    DscKeyPropertyResourceCheck([string] $DscResourceType, [Hashtable] $KeyPropertiesToValues) {
        $this.DscResourceType = $DscResourceType
        $this.KeyPropertiesToValues = $KeyPropertiesToValues
    }

    [bool] Equals([Object] $other) {
        $comparisonResult = $true
        $other = $other -as [DscKeyPropertyResourceCheck]

        if (-not $this.DscResourceType.Equals($other.DscResourceType)) {
            $comparisonResult = $false
        } else {
            foreach ($key in $this.KeyPropertiesToValues.Keys) {
                if ((-not $other.KeyPropertiesToValues.ContainsKey($key)) -or (-not $this.KeyPropertiesToValues[$key].Equals($other.KeyPropertiesToValues[$key]))) {
                    $comparisonResult = $false
                    break
                }
            }
        }

        return $comparisonResult
    }

    [int] GetHashCode() {
        $hash = $this.CalculateHashCode()

        return $hash
    }

    <#
    .DESCRIPTION
    Calculates the hashcode via the Get-KeyPropertyResourceCheckDotNetHashCode cmdlet, because
    it uses a custom c# type that is created during runtime and can't be used inside a class due to it
    raising a parse error.
    #>
    [int] CalculateHashCode() {
        $splat = @{
            ResourceType = $this.ResourceType
            KeyPropertiesToValues = $this.KeyPropertiesToValues
        }

        $hash = Get-KeyPropertyResourceCheckDotNetHashCode @splat

        return $hash
    }
}

<#
.DESCRIPTION
Executes Configuration objects created from New-VmwDscConfiguration cmdlet.
#>
class DscConfigurationRunner {
    [VmwDscConfiguration] $Configuration
    [string] $DscMethod

    hidden [VmwDscNode[]] $ValidNodes

    DscConfigurationRunner([VmwDscConfiguration] $Configuration, [string] $DscMethod) {
        $this.Configuration = $Configuration
        $this.DscMethod = $DscMethod
    }

    <#
    .DESCRIPTION
    Invokes the configuration
    #>
    [Psobject] InvokeConfiguration() {
        $this.ValidateVsphereNodes()

        $invokeResult = New-Object 'System.Collections.ArrayList'

        foreach ($node in $this.ValidNodes) {
            Write-Verbose "Invoking node with name: $($node.InstanceName)"

            $this.ValidateDscKeyProperties($node.Resources)
            
            $result = $this.InvokeNodeResources($node.Resources)

            $nodeResult = [PsObject]@{
                OriginalNode = $node
                InvokeResult = $result
            }

            $invokeResult.Add($nodeResult) | Out-Null
        }

        return $invokeResult
    }

    <#
    .DESCRIPTION
    Checks if there are any vSphere Nodes and validates them.
    Sets ValidNodes property for use in invoking the nodes
    #>
    hidden [void] ValidateVsphereNodes() {
        $vSphereNodes = $this.Configuration.Nodes | Where-Object { $_ -is [VmwVsphereDscNode] }

        if ($null -eq $vSphereNodes -or $vSphereNodes.Count -eq 0) {
            $this.ValidNodes = $this.Configuration.Nodes

            return
        }

        # gets PSVersionTable via Get-Variable because automatic variables are not accessable in any other way inside classes
        $psVersionTableVariable = Get-Variable -Name PSVersionTable

        if ($psVersionTableVariable.Value['PSEdition'] -ne 'Core') {
            throw $Script:VsphereNodesAreOnlySupportedOnPowerShellCoreException
        }

        $validVsphereNodes = New-Object 'System.Collections.ArrayList'

        $viServersHashtable = $this.GetDefaultViServers()

        # check if any connections are established
        if ($null -eq $viServersHashtable -or $viServersHashtable.Count -eq 0) {
            throw $Script:NoVsphereConnectionsFoundException
        }

        foreach ($vSphereNode in $vSphereNodes) {
            $warningMessage = [string]::Empty

            if (-not $viServersHashtable.ContainsKey($vSphereNode.InstanceName)) {
                $warningMessage = ($Script:NoVsphereConnectionsFoundForNodeWarning -f $vSphereNode.InstanceName)
            } else {
                $this.SetResourcesConnection($vSphereNode.Resources, $viServersHashtable, $vSphereNode.InstanceName)

                $validVsphereNodes.Add($vSphereNode) | Out-Null
            }

            if (-not [string]::IsNullOrEmpty($warningMessage)) {
                # write warning for no connection on a vSphere node
                Write-Warning $warningMessage
            }
        }

        # combine valid vSphereNodes with all regular Nodes
        $this.ValidNodes = ($validVsphereNodes.ToArray()) + ($this.Configuration.Nodes | Where-Object { $_.GetType() -eq [VmwDscNode] })
    }

    <#
    .DESCRIPTION
    Sets the connection property of vSphereNode resources and composite resources.
    #>
    hidden [void] SetResourcesConnection([VmwDscResource[]] $Resources, [HashTable] $ViServers, [string] $nodeInstanceName) {
        foreach ($resource in $Resources) {
            if ($resource.GetIsComposite()) {
                $this.SetResourcesConnection($resource.GetInnerResources(), $ViServers, $nodeInstanceName)
            } else {
                $resource.Property['Connection'] = $ViServers[$nodeInstanceName]
            }
        }
    }

    <#
    .DESCRIPTION
    Invokes Resources
    #>
    [Psobject[]] InvokeNodeResources([VmwDscResource[]] $DscResources) {
        $result = New-Object -TypeName 'System.Collections.ArrayList'

        # invoke the dsc resources
        foreach ($dscResource in $DscResources) {
            $invokeResult = $null

            if ($dscResource.GetIsComposite()) {
                $invokeResult = $this.InvokeNodeResources($dscResource.GetInnerResources())
            } else {
                $invokeResult = $this.InvokeNodeResource($dscResource)
            }

            $result.Add($invokeResult) | Out-Null
        }

        return $result.ToArray()
    }

    <#
    .DESCRIPTION
    Invokes single resource.
    Uses Invoke-DscResource internaly.
    #>
    hidden [Psobject] InvokeNodeResource([VmwDscResource] $DscResource) {
        # parameters used for Invoke-DscResource cmdlet
        # Method property gets set later on inside switch, because it's variable
        $invokeSplatParams = @{
            Name = $DscResource.ResourceType
            ModuleName = $DscResource.ModuleName
            Property = $DscResource.Property
        }

        Write-Verbose "Invoking resource with id: $($DscResource.GetId())"

        $invokeResult = $null

        # ignore progress from internal Get-DscResource in Invoke-DscResource 
        $oldProgressPref = (Get-Variable 'ProgressPreference').Value
        Set-Variable -Name 'ProgressPreference' -Value 'SilentlyContinue' -Scope 'Global'

        try {
            if ($this.DscMethod -eq 'Test' -or $this.DscMethod -eq 'Get') {
                $invokeResult = Invoke-DscResource @invokeSplatParams -Method $this.DscMethod
            } else {
                # checks if the resource is in target state
                $isInDesiredState = Invoke-DscResource @invokeSplatParams -Method 'Test'
    
                # executes 'set' method only if state is not desired
                if (-not $isInDesiredState.InDesiredState) {
                    (Invoke-DscResource @invokeSplatParams -Method $this.DscMethod) | Out-Null
                }
            }
        } catch {
            if ($this.DscMethod -eq 'Test') {
                $invokeResult = [PSCustomObject]@{
                    InDesiredState = $false
                }
            }
        } finally {
            $this.HandleStreamOutputFromDscResources($DscResource)
        }

        # revert progresspreference
        Set-Variable -Name 'ProgressPreference' -Value $oldProgressPref -Scope 'Global'

        return $invokeResult
    }

    <#
    .DESCRIPTION
    Prints the output from the execution of a DSC Resource via the Invoke-DscResource cmdlet.
    The logs are extracted from a file, located in the Temp directory of the OS, where the execution occurred.
    This extraction and printing is required, because the streams are not available during the execution of the DSC Resource.
    #>
    hidden [void] HandleStreamOutputFromDscResources([VmwDscResource] $DscResource) {
        # The Temp folder is not available when executing the build procedure with Travis CI.
        if ($null -eq $env:TEMP) {
            return
        }

        $logsToExtract = @('Warning', 'Verbose')

        foreach ($logType in $logsToExtract) {
            # get stream preference
            # note: preference 
            $logPreference = (Get-Variable -Name ($logType + 'Preference')).Value

            if ($logPreference -ne 'Continue') {
                continue
            }

            $connectionName = [string]::Empty

            if ($DscResource.Property.ContainsKey('Connection')) {
                $connectionName = $DscResource.Property['Connection'].Name
            } elseif ($DscResource.Property.ContainsKey('Server')) {
                $connectionName = $DscResource.Property['Server']
            }

            $resourceName = $DscResource.ResourceType
            
            # attempt to retrieve stream data if file exists
            $logPath = Join-Path -Path $env:TEMP -ChildPath "__VMware.vSphereDSC_$($connectionName)_$($resourceName)_$($logType).TMP"

            if (-not (Test-Path -Path $logPath -PathType 'Leaf')) {
                continue
            }
        
            $rows = Get-Content -Path $logPath -ErrorAction 'SilentlyContinue'
        
            foreach ($row in $rows) {
                Invoke-Expression "Write-$LogType '$row'"
            }
        
            # remove the temp file
            Remove-Item -Path $logPath -ErrorAction 'SilentlyContinue' -Force
        }
    }

    <#
    .DESCRIPTION
    Finds and validates DSC Resource key properties.
    When two or more dsc resources of the same type have the same values for key properties an exception is thrown
    #>
    hidden [void] ValidateDscKeyProperties([VmwDscResource[]] $DscResources) {
        $resourcesQueue = New-Object 'System.Collections.Queue'
        $dscResourcesDuplicateChecker = New-Object 'System.Collections.Generic.HashSet[DscKeyPropertyResourceCheck]'

        $resourcesQueue.Enqueue($DscResources)

        while ($resourcesQueue.Count -gt 0) {
            $currentResources = $resourcesQueue.Dequeue()

            foreach ($currentResource in $currentResources) {
                if ($currentResource.GetIsComposite()) {
                    $resourcesQueue.Enqueue($currentResource.GetInnerResources())

                    continue
                }

                $resourceCheck = $this.GetDscResouceKeyProperties($currentResource)

                $isAdded = $dscResourcesDuplicateChecker.Add($resourceCheck)

                if (-not $isAdded) {
                    throw ($Script:DscResourcesWithDuplicateKeyPropertiesException -f $currentResource.ResourceType)
                }
            }
        }
    }

    <#
    .DESCRIPTION
    Finds the key properties of a dsc resource and
    wraps it in a DscKeyPropertyResourceCheck object with the resource type and key props array.
    #>
    hidden [DscKeyPropertyResourceCheck] GetDscResouceKeyProperties([VmwDscResource] $DscResource) {
        $moduleName = $DscResource.ModuleName.Name
        $moduleVersion = $DscResource.ModuleName.RequiredVersion.ToString()

        # load resource module with 'using module'
        # and find key properties via reflection
        $sbText = @"
                using module @{
                    ModuleName = '$moduleName'
                    RequiredVersion = '$moduleVersion'
                }

                `$dscProperties = [$($DscResource.ResourceType)].GetProperties()

                `$dscKeyProperties = New-Object -TypeName 'System.Collections.ArrayList'

                foreach (`$dscProperty in `$dscProperties) {
                    `$dscPropertyAttr = `$dscProperty.CustomAttributes | Where-Object {
                        `$_.AttributeType.ToString() -eq 'System.Management.Automation.DscPropertyAttribute'
                    }

                    # not a dsc property
                    if (`$null -eq `$dscPropertyAttr) {
                        continue
                    }

                    if (`$dscPropertyAttr.NamedArguments.MemberName -eq 'Key' -and `$dscPropertyAttr.NamedArguments.TypedValue.ToString() -eq '(Boolean)True') {
                        `$dscKeyProperties.Add(`$dscProperty.Name) | Out-Null
                    }
                }

                `$dscKeyProperties.ToArray()
"@

        $sb = [ScriptBlock]::Create($sbText)

        $dscResourceKeyProperties = & $sb

        $dscResourceKeyPropertiesHashTable = @{}

        foreach ($dscKeyProp in $dscResourceKeyProperties) {
            $dscResourceKeyPropertiesHashTable[$dscKeyProp] = $DscResource.Property[$dscKeyProp]
        }

        $resourceCheck = [DscKeyPropertyResourceCheck]::new(
            $DscResource.ResourceType,
            $dscResourceKeyPropertiesHashTable
        )

        return $resourceCheck
    }

    <#
    .DESCRIPTION
    Retrieves the global VI Servers array from VICore module and transforms it into
    a hashtable with key name and value the object
    #>
    hidden [Hashtable] GetDefaultViServers() {
        $serverList = $Global:DefaultVIServers

        if ($null -eq $serverList) {
            return $null
        }

        $serverHashtable = @{}

        foreach ($server in $serverList) {
            if ($serverHashtable.ContainsKey($server.Name)) {
                # more than one connection to the same VIServer
                throw ($Script:TooManyConnectionOnASingleVCenterException -f $server.Name)
            }

            $serverHashtable[$server.Name] = $server
        }

        return $serverHashtable
    }
}
