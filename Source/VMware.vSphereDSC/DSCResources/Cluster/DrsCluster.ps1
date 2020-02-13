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
class DrsCluster : DatacenterInventoryBaseDSC {
    DrsCluster() {
        $this.InventoryItemFolderType = [FolderType]::Host
    }

    <#
    .DESCRIPTION

    Indicates that VMware DRS (Distributed Resource Scheduler) is enabled.
    #>
    [DscProperty()]
    [nullable[bool]] $DrsEnabled

    <#
    .DESCRIPTION

    Specifies a DRS (Distributed Resource Scheduler) automation level. The valid values are FullyAutomated, Manual, PartiallyAutomated, Disabled and Unset.
    #>
    [DscProperty()]
    [DrsAutomationLevel] $DrsAutomationLevel = [DrsAutomationLevel]::Unset

    <#
    .DESCRIPTION

    Threshold for generated ClusterRecommendations. DRS generates only those recommendations that are above the specified vmotionRate. Ratings vary from 1 to 5.
    This setting applies to Manual, PartiallyAutomated, and FullyAutomated DRS Clusters.
    #>
    [DscProperty()]
    [nullable[int]] $DrsMigrationThreshold

    <#
    .DESCRIPTION

    For availability, distributes a more even number of virtual machines across hosts.
    #>
    [DscProperty()]
    [nullable[int]] $DrsDistribution

    <#
    .DESCRIPTION

    Load balance based on consumed memory of virtual machines rather than active memory.
    This setting is recommended for clusters where host memory is not over-committed.
    #>
    [DscProperty()]
    [nullable[int]] $MemoryLoadBalancing

    <#
    .DESCRIPTION

    Controls CPU over-commitment in the cluster.
    Min value is 0 and Max value is 500.
    #>
    [DscProperty()]
    [nullable[int]] $CPUOverCommitment

    hidden [string] $DrsEnabledConfigPropertyName = 'Enabled'
    hidden [string] $DrsAutomationLevelConfigPropertyName = 'DefaultVmBehavior'
    hidden [string] $DrsMigrationThresholdConfigPropertyName = 'VmotionRate'
    hidden [string] $DrsDistributionSettingName = 'LimitVMsPerESXHostPercent'
    hidden [string] $MemoryLoadBalancingSettingName = 'PercentIdleMBInMemDemand'
    hidden [string] $CPUOverCommitmentSettingName = 'MaxVcpusPerClusterPct'

    [void] Set() {
        try {
            $this.ConnectVIServer()

            $datacenter = $this.GetDatacenter()
            $datacenterFolderName = "$($this.InventoryItemFolderType)Folder"
            $clusterLocation = $this.GetInventoryItemLocationInDatacenter($datacenter, $datacenterFolderName)
            $cluster = $this.GetInventoryItem($clusterLocation)

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $cluster) {
                    $this.AddCluster($clusterLocation)
                }
                else {
                    $this.UpdateCluster($cluster)
                }
            }
            else {
                if ($null -ne $cluster) {
                    $this.RemoveCluster($cluster)
                }
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()

            $datacenter = $this.GetDatacenter()
            $datacenterFolderName = "$($this.InventoryItemFolderType)Folder"
            $clusterLocation = $this.GetInventoryItemLocationInDatacenter($datacenter, $datacenterFolderName)
            $cluster = $this.GetInventoryItem($clusterLocation)

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $cluster) {
                    return $false
                }

                return !$this.ShouldUpdateCluster($cluster)
            }
            else {
                return ($null -eq $cluster)
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [DrsCluster] Get() {
        try {
            $result = [DrsCluster]::new()
            $result.Server = $this.Server
            $result.Location = $this.Location
            $result.DatacenterName = $this.DatacenterName
            $result.DatacenterLocation = $this.DatacenterLocation

            $this.ConnectVIServer()

            $datacenter = $this.GetDatacenter()
            $datacenterFolderName = "$($this.InventoryItemFolderType)Folder"
            $clusterLocation = $this.GetInventoryItemLocationInDatacenter($datacenter, $datacenterFolderName)
            $cluster = $this.GetInventoryItem($clusterLocation)

            $this.PopulateResult($cluster, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Checks if the Cluster option should be updated.
    #>
    [bool] ShouldUpdateOptionValue($options, $key, $desiredValue) {
        if ($null -ne $desiredValue) {
            $currentValue = ($options | Where-Object { $_.Key -eq $key }).Value

            if ($null -eq $currentValue) {
                return $true
            }
            else {
                return $desiredValue -ne $currentValue
            }
        }

        return $false
    }

    <#
    .DESCRIPTION

    Checks if the Cluster should be updated.
    #>
    [bool] ShouldUpdateCluster($cluster) {
        $drsConfig = $cluster.ExtensionData.ConfigurationEx.DrsConfig

        $shouldUpdateCluster = @()
        $shouldUpdateCluster += ($null -ne $this.DrsEnabled -and $this.DrsEnabled -ne $drsConfig.Enabled)
        $shouldUpdateCluster += ($this.DrsAutomationLevel -ne [DrsAutomationLevel]::Unset -and $this.DrsAutomationLevel.ToString() -ne $drsConfig.DefaultVmBehavior)
        $shouldUpdateCluster += ($null -ne $this.DrsMigrationThreshold -and $this.DrsMigrationThreshold -ne $drsConfig.VmotionRate)

        if ($null -ne $drsConfig.Option) {
            $shouldUpdateCluster += $this.ShouldUpdateOptionValue($drsConfig.Option, $this.DrsDistributionSettingName, $this.DrsDistribution)
            $shouldUpdateCluster += $this.ShouldUpdateOptionValue($drsConfig.Option, $this.MemoryLoadBalancingSettingName, $this.MemoryLoadBalancing)
            $shouldUpdateCluster += $this.ShouldUpdateOptionValue($drsConfig.Option, $this.CPUOverCommitmentSettingName, $this.CPUOverCommitment)
        }
        else {
            $shouldUpdateCluster += ($null -ne $this.DrsDistribution -or $null -ne $this.MemoryLoadBalancing -or $null -ne $this.CPUOverCommitment)
        }

        return ($shouldUpdateCluster -Contains $true)
    }

    <#
    .DESCRIPTION

    Populates the DrsConfig property with the desired value.
    #>
    [void] PopulateDrsConfigProperty($drsConfig, $propertyName, $propertyValue) {
        <#
            Special case where the passed property value is enum type. These type of properties
            should be populated only when their value is not equal to Unset.
            Unset means that the property was not specified in the Configuration.
        #>
        if ($propertyValue -is [DrsAutomationLevel]) {
            if ($propertyValue -ne [DrsAutomationLevel]::Unset) {
                $drsConfig.$propertyName = $propertyValue.ToString()
            }
        }
        elseif ($null -ne $propertyValue) {
            $drsConfig.$propertyName = $propertyValue
        }
    }

    <#
    .DESCRIPTION

    Returns the Option array for the DrsConfig with the specified options in the Configuration.
    #>
    [PSObject] GetOptionsForDrsConfig($allOptions) {
        $drsConfigOptions = @()

        foreach ($key in $allOptions.Keys) {
            if ($null -ne $allOptions.$key) {
                $option = New-Object VMware.Vim.OptionValue

                $option.Key = $key
                $option.Value = $allOptions.$key.ToString()

                $drsConfigOptions += $option
            }
        }

        return $drsConfigOptions
    }

    <#
    .DESCRIPTION

    Returns the populated Cluster Spec with the specified values in the Configuration.
    #>
    [PSObject] GetPopulatedClusterSpec() {
        $clusterSpec = New-Object VMware.Vim.ClusterConfigSpecEx
        $clusterSpec.DrsConfig = New-Object VMware.Vim.ClusterDrsConfigInfo

        $this.PopulateDrsConfigProperty($clusterSpec.DrsConfig, $this.DrsEnabledConfigPropertyName, $this.DrsEnabled)
        $this.PopulateDrsConfigProperty($clusterSpec.DrsConfig, $this.DrsAutomationLevelConfigPropertyName, $this.DrsAutomationLevel)
        $this.PopulateDrsConfigProperty($clusterSpec.DrsConfig, $this.DrsMigrationThresholdConfigPropertyName, $this.DrsMigrationThreshold)

        $allOptions = [ordered] @{
            $this.DrsDistributionSettingName = $this.DrsDistribution
            $this.MemoryLoadBalancingSettingName = $this.MemoryLoadBalancing
            $this.CPUOverCommitmentSettingName = $this.CPUOverCommitment
        }

        $clusterSpec.DrsConfig.Option = $this.GetOptionsForDrsConfig($allOptions)

        return $clusterSpec
    }

    <#
    .DESCRIPTION

    Creates a new Cluster with the specified properties at the specified location.
    #>
    [void] AddCluster($clusterLocation) {
        $clusterSpec = $this.GetPopulatedClusterSpec()

        try {
            Add-Cluster -Folder $clusterLocation.ExtensionData -Name $this.Name -Spec $clusterSpec
        }
        catch {
            throw "Server operation failed with the following error: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Updates the Cluster with the specified properties.
    #>
    [void] UpdateCluster($cluster) {
        $clusterSpec = $this.GetPopulatedClusterSpec()

        try {
            Update-ClusterComputeResource -ClusterComputeResource $cluster.ExtensionData -Spec $clusterSpec
        }
        catch {
            throw "Server operation failed with the following error: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Removes the Cluster from the specified Datacenter.
    #>
    [void] RemoveCluster($cluster) {
        try {
            Remove-ClusterComputeResource -ClusterComputeResource $cluster.ExtensionData
        }
        catch {
            throw "Server operation failed with the following error: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the Cluster from the server.
    #>
    [void] PopulateResult($cluster, $result) {
        if ($null -ne $cluster) {
            $drsConfig = $cluster.ExtensionData.ConfigurationEx.DrsConfig

            $result.Name = $cluster.Name
            $result.Ensure = [Ensure]::Present
            $result.DrsEnabled = $drsConfig.Enabled

            if ($null -eq $drsConfig.DefaultVmBehavior) {
                $result.DrsAutomationLevel = [DrsAutomationLevel]::Unset
            }
            else {
                $result.DrsAutomationLevel = $drsConfig.DefaultVmBehavior.ToString()
            }

            $result.DrsMigrationThreshold = $drsConfig.VmotionRate

            if ($null -ne $drsConfig.Option) {
                $options = $drsConfig.Option

                $result.DrsDistribution = ($options | Where-Object { $_.Key -eq $this.DrsDistributionSettingName }).Value
                $result.MemoryLoadBalancing = ($options | Where-Object { $_.Key -eq $this.MemoryLoadBalancingSettingName }).Value
                $result.CPUOverCommitment = ($options | Where-Object { $_.Key -eq $this.CPUOverCommitmentSettingName }).Value
            }
            else {
                $result.DrsDistribution = $null
                $result.MemoryLoadBalancing = $null
                $result.CPUOverCommitment = $null
            }
        }
        else {
            $result.Name = $this.Name
            $result.Ensure = [Ensure]::Absent
            $result.DrsEnabled = $this.DrsEnabled
            $result.DrsAutomationLevel = $this.DrsAutomationLevel
            $result.DrsMigrationThreshold = $this.DrsMigrationThreshold
            $result.DrsDistribution = $this.DrsDistribution
            $result.MemoryLoadBalancing = $this.MemoryLoadBalancing
            $result.CPUOverCommitment = $this.CPUOverCommitment
        }
    }
}
