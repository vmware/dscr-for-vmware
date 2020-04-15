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
class DatastoreCluster : DatacenterInventoryBaseDSC {
    DatastoreCluster() {
        $this.InventoryItemFolderType = [FolderType]::Datastore
    }

    <#
    .DESCRIPTION

    Specifies the maximum I/O latency in milliseconds allowed before Storage DRS is triggered for the Datastore Cluster.
    Valid values are in the range of 5 to 100. If the value of IOLoadBalancing is $false, the setting for the I/O latency threshold is not applied.
    #>
    [DscProperty()]
    [nullable[int]] $IOLatencyThresholdMillisecond

    <#
    .DESCRIPTION

    Specifies whether I/O load balancing is enabled for the Datastore Cluster. If the value is $false, I/O load balancing is disabled
    and the settings for the I/O latency threshold and utilized space threshold are not applied.
    #>
    [DscProperty()]
    [nullable[bool]] $IOLoadBalanceEnabled

    <#
    .DESCRIPTION

    Specifies the Storage DRS automation level for the Datastore Cluster. Valid values are Disabled, Manual and FullyAutomated.
    #>
    [DscProperty()]
    [DrsAutomationLevel] $SdrsAutomationLevel = [DrsAutomationLevel]::Unset

    <#
    .DESCRIPTION

    Specifies the maximum percentage of consumed space allowed before Storage DRS is triggered for the Datastore Cluster.
    Valid values are in the range of 50 to 100. If the value of IOLoadBalancing is $false, the setting for the utilized space threshold is not applied.
    #>
    [DscProperty()]
    [nullable[int]] $SpaceUtilizationThresholdPercent

    hidden [string] $CreateDatastoreClusterMessage = "Creating Datastore Cluster {0} in Folder {1}."
    hidden [string] $ModifyDatastoreClusterMessage = "Modifying Datastore Cluster {0} configuration."
    hidden [string] $RemoveDatastoreClusterMessage = "Removing Datastore Cluster {0}."

    hidden [string] $CouldNotCreateDatastoreClusterMessage = "Could not create Datastore Cluster {0} in Folder {1}. For more information: {2}"
    hidden [string] $CouldNotModifyDatastoreClusterMessage = "Could not modify Datastore Cluster {0} configuration. For more information: {1}"
    hidden [string] $CouldNotRemoveDatastoreClusterMessage = "Could not remove Datastore Cluster {0}. For more information: {1}"

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()

            $datacenter = $this.GetDatacenter()
            $datacenterFolderName = "$($this.InventoryItemFolderType)Folder"
            $datastoreClusterLocation = $this.GetInventoryItemLocationInDatacenter($datacenter, $datacenterFolderName)

            $datastoreCluster = $this.GetDatastoreCluster($datastoreClusterLocation)
            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $datastoreCluster) {
                    $datastoreCluster = $this.NewDatastoreCluster($datastoreClusterLocation)
                }

                if ($this.ShouldModifyDatastoreCluster($datastoreCluster)) {
                    $this.ModifyDatastoreCluster($datastoreCluster)
                }
            }
            else {
                if ($null -ne $datastoreCluster) {
                    $this.RemoveDatastoreCluster($datastoreCluster)
                }
            }
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.SetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [bool] Test() {
        try {
            Write-VerboseLog -Message $this.TestMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()

            $datacenter = $this.GetDatacenter()
            $datacenterFolderName = "$($this.InventoryItemFolderType)Folder"
            $datastoreClusterLocation = $this.GetInventoryItemLocationInDatacenter($datacenter, $datacenterFolderName)

            $datastoreCluster = $this.GetDatastoreCluster($datastoreClusterLocation)
            $result = $null

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $datastoreCluster) {
                    $result = $false
                }
                else {
                    $result = !$this.ShouldModifyDatastoreCluster($datastoreCluster)
                }
            }
            else {
                $result = ($null -eq $datastoreCluster)
            }

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [DatastoreCluster] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [DatastoreCluster]::new()

            $this.ConnectVIServer()

            $datacenter = $this.GetDatacenter()
            $datacenterFolderName = "$($this.InventoryItemFolderType)Folder"
            $datastoreClusterLocation = $this.GetInventoryItemLocationInDatacenter($datacenter, $datacenterFolderName)

            $datastoreCluster = $this.GetDatastoreCluster($datastoreClusterLocation)
            $this.PopulateResult($result, $datastoreCluster)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Datastore Cluster with the specified name located in the specified Folder if it exists.
    #>
    [PSObject] GetDatastoreCluster($datastoreClusterLocation) {
        $getDatastoreClusterParams = @{
            Server = $this.Connection
            Name = $this.Name
            Location = $datastoreClusterLocation
            ErrorAction = 'SilentlyContinue'
            Verbose = $false
        }

        $whereObjectParams = @{
            FilterScript = {
                $_.ExtensionData.Parent -eq $datastoreClusterLocation.ExtensionData.MoRef
            }
        }

        <#
            Multiple Datastore Clusters with the same name can be present in a Datacenter. So we need to filter
            by the direct Parent Folder of the Datastore Cluster to retrieve the desired one.
        #>
        return Get-DatastoreCluster @getDatastoreClusterParams | Where-Object @whereObjectParams
    }

    <#
    .DESCRIPTION

    Checks if the specified Datastore Cluster configuration should be modified.
    #>
    [bool] ShouldModifyDatastoreCluster($datastoreCluster) {
        $shouldModifyDatastoreCluster = @()

        $shouldModifyDatastoreCluster += ($null -ne $this.IOLatencyThresholdMillisecond -and $this.IOLatencyThresholdMillisecond -ne $datastoreCluster.IOLatencyThresholdMillisecond)
        $shouldModifyDatastoreCluster += ($null -ne $this.IOLoadBalanceEnabled -and $this.IOLoadBalanceEnabled -ne $datastoreCluster.IOLoadBalanceEnabled)
        $shouldModifyDatastoreCluster += ($this.SdrsAutomationLevel -ne [DrsAutomationLevel]::Unset -and $this.SdrsAutomationLevel.ToString() -ne $datastoreCluster.SdrsAutomationLevel.ToString())
        $shouldModifyDatastoreCluster += ($null -ne $this.SpaceUtilizationThresholdPercent -and $this.SpaceUtilizationThresholdPercent -ne $datastoreCluster.SpaceUtilizationThresholdPercent)

        return ($shouldModifyDatastoreCluster -Contains $true)
    }

    <#
    .DESCRIPTION

    Creates a new Datastore Cluster with the specified name located in the specified Folder.
    #>
    [PSObject] NewDatastoreCluster($datastoreClusterLocation) {
        $newDatastoreClusterParams = @{
            Server = $this.Connection
            Name = $this.Name
            Location = $datastoreClusterLocation
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        try {
            Write-VerboseLog -Message $this.CreateDatastoreClusterMessage -Arguments @($this.Name, $datastoreClusterLocation.Name)
            return New-DatastoreCluster @newDatastoreClusterParams
        }
        catch {
            throw ($this.CouldNotCreateDatastoreClusterMessage -f $this.Name, $datastoreClusterLocation.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Modifies the configuration of the specified Datastore Cluster.
    #>
    [void] ModifyDatastoreCluster($datastoreCluster) {
        $setDatastoreClusterParams = @{
            Server = $this.Connection
            DatastoreCluster = $datastoreCluster
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        if ($null -ne $this.IOLatencyThresholdMillisecond) { $setDatastoreClusterParams.IOLatencyThresholdMillisecond = $this.IOLatencyThresholdMillisecond }
        if ($null -ne $this.IOLoadBalanceEnabled) { $setDatastoreClusterParams.IOLoadBalanceEnabled = $this.IOLoadBalanceEnabled }
        if ($this.SdrsAutomationLevel -ne [DrsAutomationLevel]::Unset) { $setDatastoreClusterParams.SdrsAutomationLevel = $this.SdrsAutomationLevel.ToString() }
        if ($null -ne $this.SpaceUtilizationThresholdPercent) { $setDatastoreClusterParams.SpaceUtilizationThresholdPercent = $this.SpaceUtilizationThresholdPercent }

        try {
            Write-VerboseLog -Message $this.ModifyDatastoreClusterMessage -Arguments @($datastoreCluster.Name)
            Set-DatastoreCluster @setDatastoreClusterParams
        }
        catch {
            throw ($this.CouldNotModifyDatastoreClusterMessage -f $datastoreCluster.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Removes the specified Datastore Cluster.
    #>
    [void] RemoveDatastoreCluster($datastoreCluster) {
        $removeDatastoreClusterParams = @{
            Server = $this.Connection
            DatastoreCluster = $datastoreCluster
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        try {
            Write-VerboseLog -Message $this.RemoveDatastoreClusterMessage -Arguments @($datastoreCluster.Name)
            Remove-DatastoreCluster @removeDatastoreClusterParams
        }
        catch {
            throw ($this.CouldNotRemoveDatastoreClusterMessage -f $datastoreCluster.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $datastoreCluster) {
        $result.Server = $this.Server
        $result.Location = $this.Location
        $result.DatacenterName = $this.DatacenterName
        $result.DatacenterLocation = $this.DatacenterLocation

        if ($null -ne $datastoreCluster) {
            $result.Name = $datastoreCluster.Name
            $result.Ensure = [Ensure]::Present
            $result.IOLatencyThresholdMillisecond = $datastoreCluster.IOLatencyThresholdMillisecond
            $result.IOLoadBalanceEnabled = $datastoreCluster.IOLoadBalanceEnabled
            $result.SdrsAutomationLevel = $datastoreCluster.SdrsAutomationLevel.ToString()
            $result.SpaceUtilizationThresholdPercent = $datastoreCluster.SpaceUtilizationThresholdPercent
        }
        else {
            $result.Name = $this.Name
            $result.Ensure = [Ensure]::Absent
            $result.IOLatencyThresholdMillisecond = $this.IOLatencyThresholdMillisecond
            $result.IOLoadBalanceEnabled = $this.IOLoadBalanceEnabled
            $result.SdrsAutomationLevel = $this.SdrsAutomationLevel
            $result.SpaceUtilizationThresholdPercent = $this.SpaceUtilizationThresholdPercent
        }
    }
}
