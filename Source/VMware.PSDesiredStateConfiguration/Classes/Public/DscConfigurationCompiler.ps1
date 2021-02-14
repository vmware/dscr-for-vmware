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

Used for parsing and compiling a DSC Configuration into a DSC object.
#>
class DscConfigurationCompiler {
    hidden [string] $ConfigName
    hidden [Hashtable] $Parameters
    hidden [Hashtable] $ConfigurationData
    hidden [Hashtable] $ResourceNameToInfo
    hidden [Hashtable] $CompositeResourceToScriptBlock
    hidden [bool] $IsNested

    DscConfigurationCompiler([string] $ConfigName, [Hashtable] $Parameters, [Hashtable] $ConfigurationData) {
        $this.ConfigName = $ConfigName
        $this.Parameters = $Parameters

        # configurationData gets cloned because it's state gets mutated during execution.
        if ($null -ne $ConfigurationData) {
            $this.ConfigurationData = $this.DeepCloneUtil($ConfigurationData)
        }

        $this.CompositeResourceToScriptBlock = @{}
        $this.ResourceNameToInfo = @{}
        $this.IsNested = $false
    }

    <#
    .DESCRIPTION
    Compiles the DSC Configuration and returns an configuration object
    #>
    [VmwDscConfiguration] CompileDscConfiguration([DscConfigurationBlock] $dscConfigurationBlock) {
        Write-Verbose "Starting compilation process"

        Write-Verbose "Validating ConfigurationData"

        # validate the configurationData
        $this.ValidateConfigurationData()

        # parse and compile the configuration
        $dscItems = $this.CompileDscConfigurationUtil($dscConfigurationBlock, $this.Parameters)

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

    Creates a deep clone of an object.
    #>
    hidden [PsObject] DeepCloneUtil([PsObject] $ObjectToClone) {
        $memStream = New-Object -TypeName 'IO.MemoryStream'
        $formatter = new-object -TypeName 'Runtime.Serialization.Formatters.Binary.BinaryFormatter'

        $formatter.Serialize($memStream, $ObjectToClone)

        $memStream.Position = 0

        $clonedObject = $formatter.Deserialize($memStream)

        return $clonedObject
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
            throw $script:ConfigurationDataDoesNotContainAllNodesException
        }

        # AllNodes key must be array
        if ($this.ConfigurationData['AllNodes'] -isnot [Array]) {
            throw $script:ConfigurationDataAllNodesKeyIsNotAnArrayException
        }

        # hashset for detecting entries with same nodeName property
        $duplicateNodeNameSet = New-Object -TypeName 'System.Collections.Generic.HashSet[string]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)

        # will contain the common nodes setting marked with '*'
        $commonNodesConfiguration = $null

        foreach ($nodeConfiguration in $this.ConfigurationData['AllNodes']) {
            # each node entry must be a hashtable
            if ($nodeConfiguration -isnot [Hashtable]) {
                throw $script:ConfigurationDataNodeEntryInAllNodesIsNotAHashtableException
            }

            # each node entry must have a NodeName property
            if (-not $nodeConfiguration.ContainsKey('NodeName')) {
                throw $script:ConfigurationDataNodeEntryInAllNodesDoesNotContainNodeNameException
            }

            # checks if nodeName is added to the hashset or if it's already in.
            $isNodeNameAdded = $duplicateNodeNameSet.Add($nodeConfiguration['NodeName'])

            if (-not $isNodeNameAdded) {
                throw $script:DuplicateEntryInAllNodesException
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
                throw ($script:DuplicateResourceException -f $resource.InstanceName, $resource.ResourceType)
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
    hidden [DscItem[]] CompileDscConfigurationUtil([DscConfigurationBlock] $dscConfigurationBlock, [Hashtable] $Parameters) {
        $dscConfigurationParser = [DscConfigurationParser]::new()

        Write-Verbose "Parsing configuration block of $($dscConfigurationBlock.Name)"

        <#
            The Verbose preference is set to 'SilentlyContinue' to suppress the
            Verbose output of 'Import-DscResource' when importing the 'VMware.vSphereDSC' module.
        #>
        $savedVerbosePreference = $Global:VerbosePreference
        $Global:VerbosePreference = 'SilentlyContinue'

        # parse the configuration, run Import-DscResource statements and retrieve the found resources/nested configurations
        $parseResult = $dscConfigurationParser.ParseDscConfiguration($dscConfigurationBlock)

        $Global:VerbosePreference = $savedVerbosePreference

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

        $dscItems = $configScriptBlock.InvokeWithContext($functionsToDefine, $variablesToDefine, $Parameters)

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
                throw $script:NestedMoreThanASingleLevelException
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
            $compositeDscResource = $this.CompositeResourceToScriptBlock[$configType]
            $dscConfigurationBlock = $this.MapCompositeDSCResourceToDscConfigurationBlock($compositeDscResource)
            $innerResources = $this.CompileDscConfigurationUtil($dscConfigurationBlock, $parsedProps)

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
                $scriptBlock
            )

            if ($this.IsNested) {
                throw $script:NestedNodesAreNotSupportedException
            }

            $type = Get-PSCallStack | Select-Object -First 1 -ExpandProperty Command
            $vmwNodeResult = New-Object -TypeName 'System.Collections.ArrayList'

            # when multipe connections are specified for a node blocke
            # each connection gets made into a different node object
            foreach ($connection in $Connections) {
                $nodeObject = $null

                # resources are created here to avoid duplicates via reference
                $dscResources = . $scriptBlock

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

    Maps the specified PowerShell ConfigurationInfo object to a DSC Configuration Block by retrieving the name of the DSC Configuration and the text
    information for it - start and end line and also the text of the DSC Configuration.
    #>
    hidden [DscConfigurationBlock] MapCompositeDSCResourceToDscConfigurationBlock([System.Management.Automation.ConfigurationInfo] $compositeDscResource) {
        $dscConfigurationBlock = [DscConfigurationBlock]::new()

        $dscConfigurationBlock.Name = $compositeDscResource.Name
        $dscConfigurationBlock.Extent = [DscConfigurationBlockExtent]::new()

        $dscConfigurationBlock.Extent.StartLine = $compositeDscResource.ScriptBlock.Ast.Extent.StartLineNumber
        $dscConfigurationBlock.Extent.EndLine = $compositeDscResource.ScriptBlock.Ast.Extent.EndLineNumber
        $dscConfigurationBlock.Extent.Text = $compositeDscResource.ScriptBlock.Ast.Extent.Text

        return $dscConfigurationBlock
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
             throw ($script:DscResourceNotFoundException -f $resourceType)
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
}
