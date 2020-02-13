<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

[DscResource()]
class VMHostAgentVM : VMHostBaseDSC {
    <#
    .DESCRIPTION

    Specifies the Datastore used for deploying Agent VMs on this host.
    #>
    [DscProperty()]
    [string] $AgentVmDatastore

    <#
    .DESCRIPTION

    Specifies the Management Network for Agent VMs on this host.
    #>
    [DscProperty()]
    [string] $AgentVmNetwork

    hidden [string] $AgentVmDatastoreName = 'AgentVmDatastore'
    hidden [string] $AgentVmNetworkName = 'AgentVmNetwork'
    hidden [string] $GetAgentVmDatastoreAsViewObjectMethodName = 'GetAgentVmDatastoreAsViewObject'
    hidden [string] $GetAgentVmNetworkAsViewObjectMethodName = 'GetAgentVmNetworkAsViewObject'

    [void] Set() {
        try {
            $this.ConnectVIServer()

            # vCenter Connection is needed to retrieve the EsxAgentHostManager.
            $this.EnsureConnectionIsvCenter()

            $vmHost = $this.GetVMHost()
            $esxAgentHostManager = $this.GetEsxAgentHostManager($vmHost)

            $this.UpdateAgentVMConfiguration($vmHost, $esxAgentHostManager)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()

            # vCenter Connection is needed to retrieve the EsxAgentHostManager.
            $this.EnsureConnectionIsvCenter()

            $vmHost = $this.GetVMHost()
            $esxAgentHostManager = $this.GetEsxAgentHostManager($vmHost)

            return !$this.ShouldUpdateAgentVMConfiguration($esxAgentHostManager)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostAgentVM] Get() {
        try {
            $result = [VMHostAgentVM]::new()
            $result.Server = $this.Server

            $this.ConnectVIServer()

            # vCenter Connection is needed to retrieve the EsxAgentHostManager.
            $this.EnsureConnectionIsvCenter()

            $vmHost = $this.GetVMHost()
            $esxAgentHostManager = $this.GetEsxAgentHostManager($vmHost)

            $result.Name = $vmHost.Name
            $this.PopulateResult($esxAgentHostManager, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Retrieves the EsxAgentHostManager of the specified VMHost from the server.
    #>
    [PSObject] GetEsxAgentHostManager($vmHost) {
        try {
            $esxAgentHostManager = Get-View -Server $this.Connection -Id $vmHost.ExtensionData.ConfigManager.EsxAgentHostManager -ErrorAction Stop
            return $esxAgentHostManager
        }
        catch {
            throw "Could not retrieve the EsxAgentHostManager of VMHost $($vmHost.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Retrieves the AgentVM Datastore of the EsxAgentHostManager of the specified VMHost from the server as a View Object.
    #>
    [PSObject] GetAgentVmDatastoreAsViewObject($esxAgentHostManager) {
        try {
            $datastoreAsViewObject = Get-View -Server $this.Connection -Id $esxAgentHostManager.ConfigInfo.AgentVmDatastore -ErrorAction Stop
            return $datastoreAsViewObject
        }
        catch {
            throw "Could not retrieve the AgentVM Datastore of the EsxAgentHostManager. For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Retrieves the AgentVM Network of the EsxAgentHostManager of the specified VMHost from the server as a View Object.
    #>
    [PSObject] GetAgentVmNetworkAsViewObject($esxAgentHostManager) {
        try {
            $networkAsViewObject = Get-View -Server $this.Connection -Id $esxAgentHostManager.ConfigInfo.AgentVmNetwork -ErrorAction Stop
            return $networkAsViewObject
        }
        catch {
            throw "Could not retrieve the AgentVM Network of the EsxAgentHostManager. For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Checks if the AgentVM Setting needs to be updated with the desired value.
    #>
    [bool] ShouldUpdateAgentVMSetting($esxAgentHostManager, $agentVmSetting, $agentVmSettingName, $getAgentVmSettingAsViewObjectMethodName) {
        if ($null -eq $agentVmSetting) {
            if ($null -ne $esxAgentHostManager.ConfigInfo.$agentVmSettingName) {
                return $true
            }
        }
        else {
            if ($null -eq $esxAgentHostManager.ConfigInfo.$agentVmSettingName) {
                return $true
            }
            else {
                $agentVmSettingAsViewObject = $this.$getAgentVmSettingAsViewObjectMethodName($esxAgentHostManager)
                if ($agentVmSetting -ne $agentVmSettingAsViewObject.Name) {
                    return $true
                }
            }
        }

        return $false
    }

    <#
    .DESCRIPTION

    Checks if the AgentVM Configuration needs to be updated with the desired values.
    #>
    [bool] ShouldUpdateAgentVMConfiguration($esxAgentHostManager) {
        if ($this.ShouldUpdateAgentVMSetting($esxAgentHostManager, $this.AgentVmDatastore, $this.AgentVmDatastoreName, $this.GetAgentVmDatastoreAsViewObjectMethodName)) {
            return $true
        }
        elseif ($this.ShouldUpdateAgentVMSetting($esxAgentHostManager, $this.AgentVmNetwork, $this.AgentVmNetworkName, $this.GetAgentVmNetworkAsViewObjectMethodName)) {
            return $true
        }
        else {
            return $false
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Datastore for AgentVM from the server if it exists.
    If the Datastore name is not passed it returns $null and if the Datastore does not exist
    it throws an exception.
    #>
    [PSObject] GetDatastoreForAgentVM($vmHost) {
        if ($null -eq $this.AgentVmDatastore) {
            return $null
        }

        try {
            $datastore = Get-Datastore -Server $this.Connection -Name $this.AgentVmDatastore -RelatedObject $vmHost -ErrorAction Stop
            return $datastore.ExtensionData.MoRef
        }
        catch {
            throw "Could not retrieve Datastore $($this.AgentVmDatastore) for VMHost $($vmHost.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Network for AgentVM from the specified VMHost if it exists.
    If the Network name is not passed it returns $null and if the Network does not exist
    it throws an exception.
    #>
    [PSObject] GetNetworkForAgentVM($vmHost) {
        if ($null -eq $this.AgentVmNetwork) {
            return $null
        }

        $foundNetwork = $null
        $networks = $vmHost.ExtensionData.Network

        foreach ($network in $networks) {
            $networkAsViewObject = Get-View -Server $this.Connection -Id $network
            if ($this.AgentVmNetwork -eq $networkAsViewObject.Name) {
                $foundNetwork = $network
                break
            }
        }

        if ($null -eq $foundNetwork) {
            throw "Could not find Network $($this.AgentVmNetwork) for VMHost $($vmHost.Name)."
        }

        return $foundNetwork
    }

    <#
    .DESCRIPTION

    Performs an update on the AgentVM Configuration of the specified VMHost by setting the Datastore and Network.
    #>
    [void] UpdateAgentVMConfiguration($vmHost, $esxAgentHostManager) {
        $datastore = $this.GetDatastoreForAgentVM($vmHost)
        $network = $this.GetNetworkForAgentVM($vmHost)

        $configInfo = New-Object VMware.Vim.HostEsxAgentHostManagerConfigInfo

        $configInfo.AgentVmDatastore = $datastore
        $configInfo.AgentVmNetwork = $network

        try {
            Update-AgentVMConfiguration -EsxAgentHostManager $esxAgentHostManager -EsxAgentHostManagerConfigInfo $configInfo
        }
        catch {
            throw "The AgentVM Configuration of VMHost $($vmHost.Name) could not be updated: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Returns the AgentVM Setting value from the Configuration on the server.
    #>
    [string] PopulateAgentVmSetting($esxAgentHostManager, $agentVmSettingName, $getAgentVmSettingAsViewObjectMethodName) {
        if ($null -eq $esxAgentHostManager.ConfigInfo.$agentVmSettingName) {
            return $null
        }
        else {
            $agentVmSettingAsViewObject = $this.$getAgentVmSettingAsViewObjectMethodName($esxAgentHostManager)
            return $agentVmSettingAsViewObject.Name
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the AgentVM Settings from the server.
    #>
    [void] PopulateResult($esxAgentHostManager, $result) {
        $result.AgentVmDatastore = $this.PopulateAgentVmSetting($esxAgentHostManager, $this.AgentVmDatastoreName, $this.GetAgentVmDatastoreAsViewObjectMethodName)
        $result.AgentVmNetwork = $this.PopulateAgentVmSetting($esxAgentHostManager, $this.AgentVmNetworkName, $this.GetAgentVmNetworkAsViewObjectMethodName)
    }
}
