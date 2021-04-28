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

Executes Configuration objects created from New-VmwDscConfiguration cmdlet.
#>
class DscConfigurationRunner {
    [VmwDscConfiguration] $Configuration
    [string] $DscMethod

    hidden [VmwDscNode[]] $ValidNodes

    DscConfigurationRunner([VmwDscConfiguration] $configuration, [string] $dscMethod) {
        $this.Configuration = $configuration
        $this.DscMethod = $dscMethod
    }

    <#
    .DESCRIPTION
    Invokes the configuration
    #>
    [PSCustomObject] InvokeConfiguration() {
        $this.ValidateVsphereNodes()

        $invokeResult = New-Object 'System.Collections.ArrayList'

        foreach ($node in $this.ValidNodes) {
            Write-Verbose -Message "Invoking DSC Configuration for Node: $($node.InstanceName)"

            $this.ValidateDscKeyProperties($node.Resources)

            $result = $this.InvokeNodeResources($node.Resources)

            $nodeResult = [PSCustomObject] @{
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
            throw $script:VsphereNodesAreOnlySupportedOnPowerShellCoreException
        }

        $validVsphereNodes = New-Object 'System.Collections.ArrayList'

        $viServersHashtable = $this.GetDefaultViServers()

        # check if any connections are established
        if ($null -eq $viServersHashtable -or $viServersHashtable.Count -eq 0) {
            throw $script:NoVsphereConnectionsFoundException
        }

        foreach ($vSphereNode in $vSphereNodes) {
            $warningMessage = [string]::Empty

            if (-not $viServersHashtable.ContainsKey($vSphereNode.InstanceName)) {
                $warningMessage = ($script:NoVsphereConnectionsFoundForNodeWarning -f $vSphereNode.InstanceName)
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
            Verbose = $false
            ErrorAction = 'Stop'
        }

        $logs = New-Object -TypeName 'System.Collections.ArrayList'

        <#
            On PowerShell 5.1, System.Management.Automation.PSReference
            cannot be serialized into CimInstance. So the logs are only
            available for the PowerShell Core version.
        #>
        if ($Global:PSVersionTable.PSEdition -eq 'Core') {
            $invokeSplatParams.Property['Logs'] = [ref] $logs
        }

        Write-Verbose -Message "Invoking DSC Resource with id: $($DscResource.GetId())"

        $invokeResult = $null

        # ignore progress from internal Get-DscResource in Invoke-DscResource
        $oldProgressPref = (Get-Variable 'ProgressPreference').Value
        Set-Variable -Name 'ProgressPreference' -Value 'SilentlyContinue' -Scope 'Global'

        try {
            if ($this.DscMethod -eq 'Test' -or $this.DscMethod -eq 'Get') {
                $invokeSplatParams.Method = $this.DscMethod
                $invokeResult = Invoke-DscResource @invokeSplatParams
            } else {
                # checks if the resource is in target state
                $invokeSplatParams.Method = 'Test'
                $isInDesiredState = Invoke-DscResource @invokeSplatParams

                # executes 'set' method only if state is not desired
                if (-not $isInDesiredState.InDesiredState) {
                    $invokeSplatParams.Method = $this.DscMethod
                    (Invoke-DscResource @invokeSplatParams) | Out-Null
                }
            }
        } catch {
            $message = "{0} method of {1} DSC Resource failed with the following error: {2}"
            $arguments = @($this.DscMethod, $invokeSplatParams.Name, $_.Exception.Message)
            $dscResourceErrorMessage = [string]::Format($message, $arguments)

            throw $dscResourceErrorMessage
        } finally {
            $this.HandleStreamOutputFromDscResources($logs)
        }

        # revert progresspreference
        Set-Variable -Name 'ProgressPreference' -Value $oldProgressPref -Scope 'Global'

        return $invokeResult
    }

    <#
    .DESCRIPTION
    Prints the output from the execution of a DSC Resource via the Invoke-DscResource cmdlet.
    The logs are extracted from a log arrayList that gets passed via 'Property'
    #>
    hidden [void] HandleStreamOutputFromDscResources([System.Collections.ArrayList] $Logs) {
        foreach ($log in $logs) {
            $logType = $Log.Type
            $message = $log.Message

            if ($logType -eq 'Verbose') {
                Write-Verbose -Message $message
            } elseif ($logType -eq 'Warning') {
                Write-Warning -Message $message
            }
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

                <#
                    The Verbose preference is set to 'SilentlyContinue' to suppress the
                    Verbose output of 'using module' when importing the 'VMware.vSphereDSC' module.
                #>
                $savedVerbosePreference = $Global:VerbosePreference
                $Global:VerbosePreference = 'SilentlyContinue'

                $resourceCheck = $this.GetDscResouceKeyProperties($currentResource)

                $Global:VerbosePreference = $savedVerbosePreference

                $isAdded = $dscResourcesDuplicateChecker.Add($resourceCheck)

                if (-not $isAdded) {
                    throw ($script:DscResourcesWithDuplicateKeyPropertiesException -f $currentResource.ResourceType)
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
            if ($null -eq $DscResource.Property[$dscKeyProp]) {
               # DSC Key Property cannot be null, throw configuration error
               throw "Incorrect DSC Configuration: Key Property '$dscKeyProp' of resource $($DscResource.GetId()) is NULL"
            }
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
                throw ($script:TooManyConnectionOnASingleVCenterException -f $server.Name)
            }

            $serverHashtable[$server.Name] = $server
        }

        return $serverHashtable
    }
}
