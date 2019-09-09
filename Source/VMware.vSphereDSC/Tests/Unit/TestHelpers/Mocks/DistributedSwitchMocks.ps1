<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-DistributedSwitchProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $distributedSwitchProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        Name = $script:constants.DistributedSwitchName
        Ensure = 'Present'
        Location = [string]::Empty
        DatacenterName = $script:constants.DatacenterName
        DatacenterLocation = $script:constants.DatacenterLocationItemOne
    }

    $distributedSwitchProperties
}

function New-MocksForDistributedSwitch {
    [CmdletBinding()]

    $viServerMock = $script:viServer
    $rootFolderViewBaseObjectMock = $script:rootFolderViewBaseObject
    $inventoryRootFolderMock = $script:inventoryRootFolder
    $locationDatacenterLocationItemOneMock = $script:locationDatacenterLocationItemOne
    $datacenterWithDatacenterLocationItemOneAsParentMock = $script:datacenterWithDatacenterLocationItemOneAsParent
    $datacenterNetworkFolderViewBaseObjectMock = $script:datacenterNetworkFolderViewBaseObject
    $datacenterNetworkFolderMock = $script:datacenterNetworkFolder

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $rootFolderViewBaseObjectMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:viServer.ExtensionData.Content.RootFolder } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $inventoryRootFolderMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:rootFolderViewBaseObject.MoRef } -Verifiable
    Mock -CommandName Get-Folder -MockWith { return $locationDatacenterLocationItemOneMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-Datacenter -MockWith { return $datacenterWithDatacenterLocationItemOneAsParentMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $datacenterNetworkFolderViewBaseObjectMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:datacenterWithDatacenterLocationItemOneAsParent.ExtensionData.NetworkFolder } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $datacenterNetworkFolderMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:datacenterNetworkFolderViewBaseObject.MoRef } -Verifiable
}

function New-MocksWhenEnsurePresentNonExistingDistributedSwitchAndNoDistributedSwitchSettingsSpecified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $distributedSwitchProperties = New-DistributedSwitchProperties

    $newDistributedSwitchSuccessTaskMock = $script:newDistributedSwitchSuccessTask

    Mock -CommandName Get-VDSwitch -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName -and $Location -eq $script:datacenterNetworkFolder } -Verifiable
    Mock -CommandName New-VDSwitch -MockWith { return $newDistributedSwitchSuccessTaskMock }.GetNewClosure() -Verifiable
    Mock -CommandName Wait-Task -MockWith { return $null }.GetNewClosure() -Verifiable

    $distributedSwitchProperties
}

function New-MocksWhenEnsurePresentNonExistingDistributedSwitchAndDistributedSwitchSettingsSpecified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $distributedSwitchProperties = New-DistributedSwitchProperties

    $distributedSwitchProperties.ContactDetails = $script:constants.DistributedSwitchContactDetails
    $distributedSwitchProperties.ContactName = $script:constants.DistributedSwitchContactName
    $distributedSwitchProperties.LinkDiscoveryProtocol = $script:constants.DistributedSwitchLinkDiscoveryProtocol
    $distributedSwitchProperties.LinkDiscoveryProtocolOperation = $script:constants.DistributedSwitchLinkDiscoveryProtocolOperation
    $distributedSwitchProperties.MaxPorts = $script:constants.DistributedSwitchMaxPorts
    $distributedSwitchProperties.Mtu = $script:constants.DistributedSwitchMtu
    $distributedSwitchProperties.Notes = $script:constants.DistributedSwitchNotes
    $distributedSwitchProperties.NumUplinkPorts = $script:constants.DistributedSwitchNumUplinkPorts
    $distributedSwitchProperties.Version = $script:constants.DistributedSwitchVersion

    $newDistributedSwitchSuccessTaskMock = $script:newDistributedSwitchSuccessTask

    Mock -CommandName Get-VDSwitch -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName -and $Location -eq $script:datacenterNetworkFolder } -Verifiable
    Mock -CommandName New-VDSwitch -MockWith { return $newDistributedSwitchSuccessTaskMock }.GetNewClosure() -Verifiable
    Mock -CommandName Wait-Task -MockWith { return $null }.GetNewClosure() -Verifiable

    $distributedSwitchProperties
}

function New-MocksWhenEnsurePresentNonExistingDistributedSwitchAndReferenceDistributedSwitchSpecified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $distributedSwitchProperties = New-DistributedSwitchProperties

    $distributedSwitchProperties.ReferenceVDSwitch = $script:constants.ReferenceDistributedSwitch
    $distributedSwitchProperties.WithoutPortGroups = $script:constants.WithoutPortGroups

    $newDistributedSwitchSuccessTaskMock = $script:newDistributedSwitchSuccessTask

    Mock -CommandName Get-VDSwitch -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName -and $Location -eq $script:datacenterNetworkFolder } -Verifiable
    Mock -CommandName New-VDSwitch -MockWith { return $newDistributedSwitchSuccessTaskMock }.GetNewClosure() -Verifiable
    Mock -CommandName Wait-Task -MockWith { return $null }.GetNewClosure() -Verifiable

    $distributedSwitchProperties
}

function New-MocksInSetWhenEnsurePresentAndExistingDistributedSwitch {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $distributedSwitchProperties = New-DistributedSwitchProperties

    $distributedSwitchProperties.ContactDetails = $script:constants.DistributedSwitchContactDetails + $script:constants.DistributedSwitchContactDetails
    $distributedSwitchProperties.ContactName = $script:constants.DistributedSwitchContactName + $script:constants.DistributedSwitchContactName
    $distributedSwitchProperties.MaxPorts = $script:constants.DistributedSwitchMaxPorts + 1
    $distributedSwitchProperties.Mtu = $script:constants.DistributedSwitchMtu + 1

    $distributedSwitchMock = $script:distributedSwitch
    $updateDistributedSwitchSuccessTaskMock = $script:updateDistributedSwitchSuccessTask

    Mock -CommandName Get-VDSwitch -MockWith { return $distributedSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName -and $Location -eq $script:datacenterNetworkFolder } -Verifiable
    Mock -CommandName Set-VDSwitch -MockWith { return $updateDistributedSwitchSuccessTaskMock }.GetNewClosure() -Verifiable
    Mock -CommandName Wait-Task -MockWith { return $null }.GetNewClosure() -Verifiable

    $distributedSwitchProperties
}

function New-MocksInSetWhenEnsureAbsentAndExistingDistributedSwitch {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $distributedSwitchProperties = New-DistributedSwitchProperties

    $distributedSwitchProperties.Ensure = 'Absent'

    $distributedSwitchMock = $script:distributedSwitch
    $removeDistributedSwitchSuccessTaskMock = $script:removeDistributedSwitchSuccessTask

    Mock -CommandName Get-VDSwitch -MockWith { return $distributedSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName -and $Location -eq $script:datacenterNetworkFolder } -Verifiable
    Mock -CommandName Remove-VDSwitch -MockWith { return $removeDistributedSwitchSuccessTaskMock }.GetNewClosure() -Verifiable
    Mock -CommandName Wait-Task -MockWith { return $null }.GetNewClosure() -Verifiable

    $distributedSwitchProperties
}

function New-MocksInSetWhenEnsureAbsentAndNonExistingDistributedSwitch {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $distributedSwitchProperties = New-DistributedSwitchProperties

    $distributedSwitchProperties.Ensure = 'Absent'

    Mock -CommandName Get-VDSwitch -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName -and $Location -eq $script:datacenterNetworkFolder } -Verifiable
    Mock -CommandName Remove-VDSwitch -MockWith { return $null }.GetNewClosure()

    $distributedSwitchProperties
}

function New-MocksWhenEnsurePresentAndNonExistingDistributedSwitch {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $distributedSwitchProperties = New-DistributedSwitchProperties

    Mock -CommandName Get-VDSwitch -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName -and $Location -eq $script:datacenterNetworkFolder } -Verifiable

    $distributedSwitchProperties
}

function New-MocksWhenEnsurePresentExistingDistributedSwitchAndMatchingSettings {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $distributedSwitchProperties = New-DistributedSwitchProperties

    $distributedSwitchProperties.ContactDetails = $script:constants.DistributedSwitchContactDetails
    $distributedSwitchProperties.ContactName = $script:constants.DistributedSwitchContactName
    $distributedSwitchProperties.LinkDiscoveryProtocol = $script:constants.DistributedSwitchLinkDiscoveryProtocol
    $distributedSwitchProperties.LinkDiscoveryProtocolOperation = $script:constants.DistributedSwitchLinkDiscoveryProtocolOperation
    $distributedSwitchProperties.MaxPorts = $script:constants.DistributedSwitchMaxPorts
    $distributedSwitchProperties.Mtu = $script:constants.DistributedSwitchMtu
    $distributedSwitchProperties.Notes = $script:constants.DistributedSwitchNotes
    $distributedSwitchProperties.NumUplinkPorts = $script:constants.DistributedSwitchNumUplinkPorts
    $distributedSwitchProperties.Version = $script:constants.DistributedSwitchVersion

    $distributedSwitchMock = $script:distributedSwitch

    Mock -CommandName Get-VDSwitch -MockWith { return $distributedSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName -and $Location -eq $script:datacenterNetworkFolder } -Verifiable

    $distributedSwitchProperties
}

function New-MocksWhenEnsurePresentExistingDistributedSwitchAndNonMatchingSettings {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $distributedSwitchProperties = New-DistributedSwitchProperties

    $distributedSwitchProperties.ContactName = $script:constants.DistributedSwitchContactName + $script:constants.DistributedSwitchContactName
    $distributedSwitchProperties.Mtu = $script:constants.DistributedSwitchMtu + 1

    $distributedSwitchMock = $script:distributedSwitch

    Mock -CommandName Get-VDSwitch -MockWith { return $distributedSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName -and $Location -eq $script:datacenterNetworkFolder } -Verifiable

    $distributedSwitchProperties
}

function New-MocksWhenEnsurePresentAndNonExistingDistributedSwitch {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $distributedSwitchProperties = New-DistributedSwitchProperties

    $distributedSwitchProperties.ContactDetails = $script:constants.DistributedSwitchContactDetails
    $distributedSwitchProperties.ContactName = $script:constants.DistributedSwitchContactName
    $distributedSwitchProperties.LinkDiscoveryProtocol = $script:constants.DistributedSwitchLinkDiscoveryProtocol
    $distributedSwitchProperties.LinkDiscoveryProtocolOperation = $script:constants.DistributedSwitchLinkDiscoveryProtocolOperation
    $distributedSwitchProperties.MaxPorts = $script:constants.DistributedSwitchMaxPorts
    $distributedSwitchProperties.Mtu = $script:constants.DistributedSwitchMtu
    $distributedSwitchProperties.Notes = $script:constants.DistributedSwitchNotes
    $distributedSwitchProperties.NumUplinkPorts = $script:constants.DistributedSwitchNumUplinkPorts
    $distributedSwitchProperties.Version = $script:constants.DistributedSwitchVersion

    Mock -CommandName Get-VDSwitch -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName -and $Location -eq $script:datacenterNetworkFolder } -Verifiable

    $distributedSwitchProperties
}

function New-MocksWhenEnsurePresentAndExistingDistributedSwitch {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $distributedSwitchProperties = New-DistributedSwitchProperties

    $distributedSwitchMock = $script:distributedSwitch

    Mock -CommandName Get-VDSwitch -MockWith { return $distributedSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName -and $Location -eq $script:datacenterNetworkFolder } -Verifiable

    $distributedSwitchProperties
}

function New-MocksWhenEnsureAbsentAndNonExistingDistributedSwitch {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $distributedSwitchProperties = New-DistributedSwitchProperties

    $distributedSwitchProperties.Ensure = 'Absent'
    $distributedSwitchProperties.ContactDetails = $script:constants.DistributedSwitchContactDetails
    $distributedSwitchProperties.ContactName = $script:constants.DistributedSwitchContactName
    $distributedSwitchProperties.LinkDiscoveryProtocol = $script:constants.DistributedSwitchLinkDiscoveryProtocol
    $distributedSwitchProperties.LinkDiscoveryProtocolOperation = $script:constants.DistributedSwitchLinkDiscoveryProtocolOperation
    $distributedSwitchProperties.MaxPorts = $script:constants.DistributedSwitchMaxPorts
    $distributedSwitchProperties.Mtu = $script:constants.DistributedSwitchMtu
    $distributedSwitchProperties.Notes = $script:constants.DistributedSwitchNotes
    $distributedSwitchProperties.NumUplinkPorts = $script:constants.DistributedSwitchNumUplinkPorts
    $distributedSwitchProperties.Version = $script:constants.DistributedSwitchVersion

    Mock -CommandName Get-VDSwitch -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName -and $Location -eq $script:datacenterNetworkFolder } -Verifiable

    $distributedSwitchProperties
}

function New-MocksWhenEnsureAbsentAndExistingDistributedSwitch {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $distributedSwitchProperties = New-DistributedSwitchProperties

    $distributedSwitchProperties.Ensure = 'Absent'

    $distributedSwitchMock = $script:distributedSwitch

    Mock -CommandName Get-VDSwitch -MockWith { return $distributedSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName -and $Location -eq $script:datacenterNetworkFolder } -Verifiable

    $distributedSwitchProperties
}
