<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-DrsClusterProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $drsClusterProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        Name = $script:constants.InventoryItemName
        Ensure = 'Present'
        Location = "$($script:constants.InventoryItemLocationItemOne)/$($script:constants.InventoryItemLocationItemTwo)"
        DatacenterName = $script:constants.DatacenterName
        DatacenterLocation = "$($script:constants.DatacenterLocationItemOne)"
    }

    $drsClusterProperties
}

function New-MocksForDrsCluster {
    [CmdletBinding()]

    $viServerMock = $script:viServer
    $rootFolderViewBaseObjectMock = $script:rootFolderViewBaseObject
    $inventoryRootFolderMock = $script:inventoryRootFolder
    $locationDatacenterLocationItemOneMock = $script:locationDatacenterLocationItemOne
    $datacenterWithDatacenterLocationItemOneAsParentMock = $script:datacenterWithDatacenterLocationItemOneAsParent
    $datacenterHostFolderViewBaseObjectMock = $script:datacenterHostFolderViewBaseObject
    $datacenterHostFolderMock = $script:datacenterHostFolder
    $foundLocationsForClusterMock = $script:foundLocationsForCluster
    $inventoryItemLocationViewBaseObjectMock = $script:inventoryItemLocationViewBaseObject
    $inventoryItemLocationWithInventoryItemLocationItemOneAsParentMock = $script:inventoryItemLocationWithInventoryItemLocationItemOneAsParent

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $rootFolderViewBaseObjectMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:viServer.ExtensionData.Content.RootFolder } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $inventoryRootFolderMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:rootFolderViewBaseObject.MoRef } -Verifiable
    Mock -CommandName Get-Folder -MockWith { return $locationDatacenterLocationItemOneMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-Datacenter -MockWith { return $datacenterWithDatacenterLocationItemOneAsParentMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $datacenterHostFolderViewBaseObjectMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:datacenterWithDatacenterLocationItemOneAsParent.ExtensionData.HostFolder } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $datacenterHostFolderMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:datacenterHostFolderViewBaseObject.MoRef } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $foundLocationsForClusterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemLocationItemTwo -and $Location -eq $script:datacenterHostFolder } -Verifiable
    Mock -CommandName Get-View -MockWith { return $inventoryItemLocationViewBaseObjectMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:constants.InventoryItemLocationItemTwoId } -Verifiable
    Mock -CommandName Get-View -MockWith { return $inventoryItemLocationWithInventoryItemLocationItemOneAsParentMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:inventoryItemLocationViewBaseObject.Parent } -Verifiable
}

function New-MocksWhenEnsurePresentNonExistingClusterAndNoDrsSettingsSpecified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $drsClusterProperties = New-DrsClusterProperties

    Mock -CommandName Get-Inventory -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:foundLocationsForCluster[0] } -Verifiable
    Mock -CommandName Add-Cluster -MockWith { return $null }.GetNewClosure() -Verifiable

    $drsClusterProperties
}

function New-MocksWhenEnsurePresentNonExistingClusterAndDrsSettingsSpecified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $drsClusterProperties = New-DrsClusterProperties

    $drsClusterProperties.DrsEnabled = $script:constants.DrsEnabled
    $drsClusterProperties.DrsAutomationLevel = $script:constants.DrsAutomationLevel
    $drsClusterProperties.DrsMigrationThreshold = $script:constants.DrsMigrationThreshold
    $drsClusterProperties.DrsDistribution = $script:constants.DrsDistribution
    $drsClusterProperties.MemoryLoadBalancing = $script:constants.MemoryLoadBalancing
    $drsClusterProperties.CPUOverCommitment = $script:constants.CPUOverCommitment

    Mock -CommandName Get-Inventory -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:foundLocationsForCluster[0] } -Verifiable
    Mock -CommandName Add-Cluster -MockWith { return $null }.GetNewClosure() -Verifiable

    $drsClusterProperties
}

function New-MocksWhenEnsurePresentExistingClusterAndNoDrsSettingsSpecified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $drsClusterProperties = New-DrsClusterProperties

    $clusterMock = $script:cluster

    Mock -CommandName Get-Inventory -MockWith { return $clusterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:foundLocationsForCluster[0] } -Verifiable
    Mock -CommandName Update-ClusterComputeResource -MockWith { return $null }.GetNewClosure() -Verifiable

    $drsClusterProperties
}

function New-MocksWhenEnsurePresentExistingClusterAndDrsSettingsSpecified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $drsClusterProperties = New-DrsClusterProperties

    $drsClusterProperties.DrsEnabled = $script:constants.DrsEnabled
    $drsClusterProperties.DrsAutomationLevel = $script:constants.DrsAutomationLevel
    $drsClusterProperties.DrsMigrationThreshold = $script:constants.DrsMigrationThreshold
    $drsClusterProperties.DrsDistribution = $script:constants.DrsDistribution
    $drsClusterProperties.MemoryLoadBalancing = $script:constants.MemoryLoadBalancing
    $drsClusterProperties.CPUOverCommitment = $script:constants.CPUOverCommitment

    $clusterMock = $script:cluster

    Mock -CommandName Get-Inventory -MockWith { return $clusterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:foundLocationsForCluster[0] } -Verifiable
    Mock -CommandName Update-ClusterComputeResource -MockWith { return $null }.GetNewClosure() -Verifiable

    $drsClusterProperties
}

function New-MocksWhenEnsureAbsentAndExistingCluster {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $drsClusterProperties = New-DrsClusterProperties
    $drsClusterProperties.Ensure = 'Absent'

    $clusterMock = $script:cluster

    Mock -CommandName Get-Inventory -MockWith { return $clusterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:foundLocationsForCluster[0] } -Verifiable
    Mock -CommandName Remove-ClusterComputeResource -MockWith { return $null }.GetNewClosure() -Verifiable

    $drsClusterProperties
}

function New-MocksWhenEnsureAbsentAndNonExistingCluster {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $drsClusterProperties = New-DrsClusterProperties
    $drsClusterProperties.Ensure = 'Absent'

    Mock -CommandName Get-Inventory -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:foundLocationsForCluster[0] } -Verifiable
    Mock -CommandName Remove-ClusterComputeResource -MockWith { return $null }.GetNewClosure()

    $drsClusterProperties
}

function New-MocksWhenEnsurePresentAndNonExistingCluster {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $drsClusterProperties = New-DrsClusterProperties

    Mock -CommandName Get-Inventory -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:foundLocationsForCluster[0] } -Verifiable

    $drsClusterProperties
}

function New-MocksWhenEnsurePresentExistingClusterAndMatchingSettings {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $drsClusterProperties = New-DrsClusterProperties

    $drsClusterProperties.DrsEnabled = $script:cluster.ExtensionData.ConfigurationEx.DrsConfig.Enabled
    $drsClusterProperties.DrsAutomationLevel = $script:cluster.ExtensionData.ConfigurationEx.DrsConfig.DefaultVmBehavior.ToString()
    $drsClusterProperties.DrsMigrationThreshold = $script:cluster.ExtensionData.ConfigurationEx.DrsConfig.VmotionRate
    $drsClusterProperties.DrsDistribution = ($script:cluster.ExtensionData.ConfigurationEx.DrsConfig.Option[0]).Value
    $drsClusterProperties.MemoryLoadBalancing = ($script:cluster.ExtensionData.ConfigurationEx.DrsConfig.Option[1]).Value
    $drsClusterProperties.CPUOverCommitment = ($script:cluster.ExtensionData.ConfigurationEx.DrsConfig.Option[2]).Value

    $clusterMock = $script:cluster

    Mock -CommandName Get-Inventory -MockWith { return $clusterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:foundLocationsForCluster[0] } -Verifiable

    $drsClusterProperties
}

function New-MocksWhenEnsurePresentExistingClusterAndNonMatchingSettings {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $drsClusterProperties = New-DrsClusterProperties

    $drsClusterProperties.DrsEnabled = $script:constants.DrsEnabled
    $drsClusterProperties.DrsAutomationLevel = $script:constants.DrsAutomationLevel
    $drsClusterProperties.DrsMigrationThreshold = $script:constants.DrsMigrationThreshold
    $drsClusterProperties.DrsDistribution = $script:constants.DrsDistribution
    $drsClusterProperties.MemoryLoadBalancing = $script:constants.MemoryLoadBalancing
    $drsClusterProperties.CPUOverCommitment = $script:constants.CPUOverCommitment

    $clusterMock = $script:cluster

    Mock -CommandName Get-Inventory -MockWith { return $clusterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:foundLocationsForCluster[0] } -Verifiable

    $drsClusterProperties
}

function New-MocksInTestWhenEnsureAbsentAndNonExistingCluster {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $drsClusterProperties = New-DrsClusterProperties
    $drsClusterProperties.Ensure = 'Absent'

    Mock -CommandName Get-Inventory -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:foundLocationsForCluster[0] } -Verifiable

    $drsClusterProperties
}

function New-MocksInTestWhenEnsureAbsentAndExistingCluster {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $drsClusterProperties = New-DrsClusterProperties
    $drsClusterProperties.Ensure = 'Absent'

    $clusterMock = $script:cluster

    Mock -CommandName Get-Inventory -MockWith { return $clusterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:foundLocationsForCluster[0] } -Verifiable

    $drsClusterProperties
}

function New-MocksInGetWhenEnsurePresentAndNonExistingCluster {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $drsClusterProperties = New-DrsClusterProperties

    $drsClusterProperties.DrsEnabled = $script:constants.DrsEnabled
    $drsClusterProperties.DrsAutomationLevel = $script:constants.DrsAutomationLevel
    $drsClusterProperties.DrsMigrationThreshold = $script:constants.DrsMigrationThreshold
    $drsClusterProperties.DrsDistribution = $script:constants.DrsDistribution
    $drsClusterProperties.MemoryLoadBalancing = $script:constants.MemoryLoadBalancing
    $drsClusterProperties.CPUOverCommitment = $script:constants.CPUOverCommitment

    Mock -CommandName Get-Inventory -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:foundLocationsForCluster[0] } -Verifiable

    $drsClusterProperties
}

function New-MocksInGetWhenEnsurePresentAndExistingCluster {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $drsClusterProperties = New-DrsClusterProperties

    $drsClusterProperties.DrsEnabled = $script:cluster.ExtensionData.ConfigurationEx.DrsConfig.Enabled
    $drsClusterProperties.DrsAutomationLevel = $script:cluster.ExtensionData.ConfigurationEx.DrsConfig.DefaultVmBehavior.ToString()
    $drsClusterProperties.DrsMigrationThreshold = $script:cluster.ExtensionData.ConfigurationEx.DrsConfig.VmotionRate
    $drsClusterProperties.DrsDistribution = ($script:cluster.ExtensionData.ConfigurationEx.DrsConfig.Option[0]).Value
    $drsClusterProperties.MemoryLoadBalancing = ($script:cluster.ExtensionData.ConfigurationEx.DrsConfig.Option[1]).Value
    $drsClusterProperties.CPUOverCommitment = ($script:cluster.ExtensionData.ConfigurationEx.DrsConfig.Option[2]).Value

    $clusterMock = $script:cluster

    Mock -CommandName Get-Inventory -MockWith { return $clusterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:foundLocationsForCluster[0] } -Verifiable

    $drsClusterProperties
}

function New-MocksInGetWhenEnsureAbsentAndNonExistingCluster {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $drsClusterProperties = New-DrsClusterProperties

    $drsClusterProperties.Ensure = 'Absent'
    $drsClusterProperties.DrsEnabled = $script:constants.DrsEnabled
    $drsClusterProperties.DrsAutomationLevel = $script:constants.DrsAutomationLevel
    $drsClusterProperties.DrsMigrationThreshold = $script:constants.DrsMigrationThreshold
    $drsClusterProperties.DrsDistribution = $script:constants.DrsDistribution
    $drsClusterProperties.MemoryLoadBalancing = $script:constants.MemoryLoadBalancing
    $drsClusterProperties.CPUOverCommitment = $script:constants.CPUOverCommitment

    Mock -CommandName Get-Inventory -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:foundLocationsForCluster[0] } -Verifiable

    $drsClusterProperties
}

function New-MocksInGetWhenEnsureAbsentAndExistingCluster {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $drsClusterProperties = New-DrsClusterProperties

    $drsClusterProperties.Ensure = 'Absent'
    $drsClusterProperties.DrsEnabled = $script:cluster.ExtensionData.ConfigurationEx.DrsConfig.Enabled
    $drsClusterProperties.DrsAutomationLevel = $script:cluster.ExtensionData.ConfigurationEx.DrsConfig.DefaultVmBehavior.ToString()
    $drsClusterProperties.DrsMigrationThreshold = $script:cluster.ExtensionData.ConfigurationEx.DrsConfig.VmotionRate
    $drsClusterProperties.DrsDistribution = ($script:cluster.ExtensionData.ConfigurationEx.DrsConfig.Option[0]).Value
    $drsClusterProperties.MemoryLoadBalancing = ($script:cluster.ExtensionData.ConfigurationEx.DrsConfig.Option[1]).Value
    $drsClusterProperties.CPUOverCommitment = ($script:cluster.ExtensionData.ConfigurationEx.DrsConfig.Option[2]).Value

    $clusterMock = $script:cluster

    Mock -CommandName Get-Inventory -MockWith { return $clusterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:foundLocationsForCluster[0] } -Verifiable

    $drsClusterProperties
}
