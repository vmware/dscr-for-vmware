<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-HAClusterProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $haClusterProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        Name = $script:constants.InventoryItemName
        Ensure = 'Present'
        Location = "$($script:constants.InventoryItemLocationItemOne)/$($script:constants.InventoryItemLocationItemTwo)"
        DatacenterName = $script:constants.DatacenterName
        DatacenterLocation = "$($script:constants.DatacenterLocationItemOne)"
    }

    $haClusterProperties
}

function New-MocksForHACluster {
    [CmdletBinding()]

    $viServerMock = $script:viServer
    $rootFolderViewBaseObjectMock = $script:rootFolderViewBaseObject
    $inventoryRootFolderMock = $script:inventoryRootFolder
    $locationDatacenterLocationItemOneMock = $script:locationDatacenterLocationItemOne
    $datacenterWithDatacenterLocationItemOneAsParentMock = $script:datacenterWithDatacenterLocationItemOneAsParent
    $datacenterHostFolderViewBaseObjectMock = $script:datacenterHostFolderViewBaseObject
    $datacenterHostFolderMock = $script:datacenterHostFolder
    $foundLocationsMock = $script:foundLocations
    $inventoryItemLocationViewBaseObjectMock = $script:inventoryItemLocationViewBaseObject
    $inventoryItemLocationWithInventoryItemLocationItemOneAsParentMock = $script:inventoryItemLocationWithInventoryItemLocationItemOneAsParent

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $rootFolderViewBaseObjectMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:viServer.ExtensionData.Content.RootFolder } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $inventoryRootFolderMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:rootFolderViewBaseObject.MoRef } -Verifiable
    Mock -CommandName Get-Folder -MockWith { return $locationDatacenterLocationItemOneMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-Datacenter -MockWith { return $datacenterWithDatacenterLocationItemOneAsParentMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $datacenterHostFolderViewBaseObjectMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:datacenterWithDatacenterLocationItemOneAsParent.ExtensionData.HostFolder } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $datacenterHostFolderMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:datacenterHostFolderViewBaseObject.MoRef } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $foundLocationsMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemLocationItemTwo -and $Location -eq $script:datacenterHostFolder } -Verifiable
    Mock -CommandName Get-View -MockWith { return $inventoryItemLocationViewBaseObjectMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:constants.InventoryItemLocationItemTwoId } -Verifiable
    Mock -CommandName Get-View -MockWith { return $inventoryItemLocationWithInventoryItemLocationItemOneAsParentMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:inventoryItemLocationViewBaseObject.Parent } -Verifiable
}

function New-MocksWhenEnsurePresentNonExistingClusterAndNoHASettingsSpecified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $haClusterProperties = New-HAClusterProperties

    Mock -CommandName Get-Inventory -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:foundLocations[0] } -Verifiable
    Mock -CommandName New-Cluster -MockWith { return $null }.GetNewClosure() -Verifiable

    $haClusterProperties
}

function New-MocksWhenEnsurePresentNonExistingClusterAndHASettingsSpecified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $haClusterProperties = New-HAClusterProperties

    $haClusterProperties.HAEnabled = $script:constants.HAEnabled
    $haClusterProperties.HAAdmissionControlEnabled = $script:constants.HAAdmissionControlEnabled
    $haClusterProperties.HAFailoverLevel = $script:constants.HAFailoverLevel
    $haClusterProperties.HAIsolationResponse = $script:constants.HAIsolationResponse
    $haClusterProperties.HARestartPriority = $script:constants.HARestartPriority

    Mock -CommandName Get-Inventory -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:foundLocations[0] } -Verifiable
    Mock -CommandName New-Cluster -MockWith { return $null }.GetNewClosure() -Verifiable

    $haClusterProperties
}

function New-MocksWhenEnsurePresentExistingClusterAndNoHASettingsSpecified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $haClusterProperties = New-HAClusterProperties

    $clusterMock = $script:cluster

    Mock -CommandName Get-Inventory -MockWith { return $clusterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:foundLocations[0] } -Verifiable
    Mock -CommandName Set-Cluster -MockWith { return $null }.GetNewClosure() -Verifiable

    $haClusterProperties
}

function New-MocksWhenEnsurePresentExistingClusterAndHASettingsSpecified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $haClusterProperties = New-HAClusterProperties

    $haClusterProperties.HAEnabled = !$script:constants.HAEnabled
    $haClusterProperties.HAAdmissionControlEnabled = !$script:constants.HAAdmissionControlEnabled
    $haClusterProperties.HAFailoverLevel = $script:constants.HAFailoverLevel
    $haClusterProperties.HAIsolationResponse = $script:constants.HAIsolationResponse
    $haClusterProperties.HARestartPriority = $script:constants.HARestartPriority

    $clusterMock = $script:cluster

    Mock -CommandName Get-Inventory -MockWith { return $clusterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:foundLocations[0] } -Verifiable
    Mock -CommandName Set-Cluster -MockWith { return $null }.GetNewClosure() -Verifiable

    $haClusterProperties
}

function New-MocksWhenEnsureAbsentAndExistingCluster {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $haClusterProperties = New-HAClusterProperties
    $haClusterProperties.Ensure = 'Absent'

    $clusterMock = $script:cluster

    Mock -CommandName Get-Inventory -MockWith { return $clusterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:foundLocations[0] } -Verifiable
    Mock -CommandName Remove-Cluster -MockWith { return $null }.GetNewClosure() -Verifiable

    $haClusterProperties
}

function New-MocksWhenEnsureAbsentAndNonExistingCluster {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $haClusterProperties = New-HAClusterProperties
    $haClusterProperties.Ensure = 'Absent'

    Mock -CommandName Get-Inventory -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:foundLocations[0] } -Verifiable
    Mock -CommandName Remove-Cluster -MockWith { return $null }.GetNewClosure()

    $haClusterProperties
}

function New-MocksWhenEnsurePresentAndNonExistingCluster {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $haClusterProperties = New-HAClusterProperties

    Mock -CommandName Get-Inventory -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:foundLocations[0] } -Verifiable

    $haClusterProperties
}

function New-MocksWhenEnsurePresentExistingClusterAndMatchingSettings {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $haClusterProperties = New-HAClusterProperties

    $haClusterProperties.HAEnabled = $script:constants.HAEnabled
    $haClusterProperties.HAAdmissionControlEnabled = $script:constants.HAAdmissionControlEnabled
    $haClusterProperties.HAFailoverLevel = $script:constants.HAFailoverLevel
    $haClusterProperties.HAIsolationResponse = $script:constants.HAIsolationResponse
    $haClusterProperties.HARestartPriority = $script:constants.HARestartPriority

    $clusterMock = $script:cluster

    Mock -CommandName Get-Inventory -MockWith { return $clusterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:foundLocations[0] } -Verifiable

    $haClusterProperties
}

function New-MocksWhenEnsurePresentExistingClusterAndNonMatchingSettings {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $haClusterProperties = New-HAClusterProperties

    $haClusterProperties.HAEnabled = $script:constants.HAEnabled
    $haClusterProperties.HAAdmissionControlEnabled = $script:constants.HAAdmissionControlEnabled
    $haClusterProperties.HAFailoverLevel = $script:constants.HAFailoverLevel
    $haClusterProperties.HAIsolationResponse = $script:constants.HAIsolationResponse
    $haClusterProperties.HARestartPriority = 'Disabled'

    $clusterMock = $script:cluster

    Mock -CommandName Get-Inventory -MockWith { return $clusterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:foundLocations[0] } -Verifiable

    $haClusterProperties
}

function New-MocksInTestWhenEnsureAbsentAndNonExistingCluster {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $haClusterProperties = New-HAClusterProperties
    $haClusterProperties.Ensure = 'Absent'

    Mock -CommandName Get-Inventory -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:foundLocations[0] } -Verifiable

    $haClusterProperties
}

function New-MocksInTestWhenEnsureAbsentAndExistingCluster {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $haClusterProperties = New-HAClusterProperties
    $haClusterProperties.Ensure = 'Absent'

    $clusterMock = $script:cluster

    Mock -CommandName Get-Inventory -MockWith { return $clusterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:foundLocations[0] } -Verifiable

    $haClusterProperties
}

function New-MocksInGetWhenEnsurePresentAndNonExistingCluster {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $haClusterProperties = New-HAClusterProperties

    $haClusterProperties.HAEnabled = $script:constants.HAEnabled
    $haClusterProperties.HAAdmissionControlEnabled = $script:constants.HAAdmissionControlEnabled
    $haClusterProperties.HAFailoverLevel = $script:constants.HAFailoverLevel
    $haClusterProperties.HAIsolationResponse = $script:constants.HAIsolationResponse
    $haClusterProperties.HARestartPriority = $script:constants.HARestartPriority

    Mock -CommandName Get-Inventory -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:foundLocations[0] } -Verifiable

    $haClusterProperties
}

function New-MocksInGetWhenEnsurePresentAndExistingCluster {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $haClusterProperties = New-HAClusterProperties

    $haClusterProperties.HAEnabled = !$script:constants.HAEnabled
    $haClusterProperties.HAAdmissionControlEnabled = !$script:constants.HAAdmissionControlEnabled
    $haClusterProperties.HAFailoverLevel = $script:constants.HAFailoverLevel + 1
    $haClusterProperties.HAIsolationResponse = 'Shutdown'
    $haClusterProperties.HARestartPriority = 'Disabled'

    $clusterMock = $script:cluster

    Mock -CommandName Get-Inventory -MockWith { return $clusterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:foundLocations[0] } -Verifiable

    $haClusterProperties
}

function New-MocksInGetWhenEnsureAbsentAndNonExistingCluster {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $haClusterProperties = New-HAClusterProperties

    $haClusterProperties.Ensure = 'Absent'
    $haClusterProperties.HAEnabled = $script:constants.HAEnabled
    $haClusterProperties.HAAdmissionControlEnabled = $script:constants.HAAdmissionControlEnabled
    $haClusterProperties.HAFailoverLevel = $script:constants.HAFailoverLevel
    $haClusterProperties.HAIsolationResponse = $script:constants.HAIsolationResponse
    $haClusterProperties.HARestartPriority = $script:constants.HARestartPriority

    Mock -CommandName Get-Inventory -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:foundLocations[0] } -Verifiable

    $haClusterProperties
}

function New-MocksInGetWhenEnsureAbsentAndExistingCluster {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $haClusterProperties = New-HAClusterProperties

    $haClusterProperties.Ensure = 'Absent'
    $haClusterProperties.HAEnabled = !$script:constants.HAEnabled
    $haClusterProperties.HAAdmissionControlEnabled = !$script:constants.HAAdmissionControlEnabled
    $haClusterProperties.HAFailoverLevel = $script:constants.HAFailoverLevel + 1
    $haClusterProperties.HAIsolationResponse = 'Shutdown'
    $haClusterProperties.HARestartPriority = 'Disabled'

    $clusterMock = $script:cluster

    Mock -CommandName Get-Inventory -MockWith { return $clusterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:foundLocations[0] } -Verifiable

    $haClusterProperties
}
