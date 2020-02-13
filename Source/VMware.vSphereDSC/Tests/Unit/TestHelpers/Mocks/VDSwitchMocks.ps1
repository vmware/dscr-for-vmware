<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-VDSwitchProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vdSwitchProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        Name = $script:constants.DistributedSwitchName
        Ensure = 'Present'
        Location = [string]::Empty
        DatacenterName = $script:constants.DatacenterName
        DatacenterLocation = $script:constants.DatacenterLocationItemOne
    }

    $vdSwitchProperties
}

function New-MocksForVDSwitch {
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

    $vdSwitchProperties = New-VDSwitchProperties

    Mock -CommandName Get-VDSwitch -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName -and $Location -eq $script:datacenterNetworkFolder } -Verifiable
    Mock -CommandName New-VDSwitch -MockWith { return $null }.GetNewClosure() -Verifiable

    $vdSwitchProperties
}

function New-MocksWhenEnsurePresentNonExistingDistributedSwitchAndDistributedSwitchSettingsSpecified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vdSwitchProperties = New-VDSwitchProperties

    $vdSwitchProperties.ContactDetails = $script:constants.DistributedSwitchContactDetails
    $vdSwitchProperties.ContactName = $script:constants.DistributedSwitchContactName
    $vdSwitchProperties.LinkDiscoveryProtocol = $script:constants.DistributedSwitchLinkDiscoveryProtocol
    $vdSwitchProperties.LinkDiscoveryProtocolOperation = $script:constants.DistributedSwitchLinkDiscoveryProtocolOperation
    $vdSwitchProperties.MaxPorts = $script:constants.DistributedSwitchMaxPorts
    $vdSwitchProperties.Mtu = $script:constants.DistributedSwitchMtu
    $vdSwitchProperties.Notes = $script:constants.DistributedSwitchNotes
    $vdSwitchProperties.NumUplinkPorts = $script:constants.DistributedSwitchNumUplinkPorts
    $vdSwitchProperties.Version = $script:constants.DistributedSwitchVersion

    Mock -CommandName Get-VDSwitch -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName -and $Location -eq $script:datacenterNetworkFolder } -Verifiable
    Mock -CommandName New-VDSwitch -MockWith { return $null }.GetNewClosure() -Verifiable

    $vdSwitchProperties
}

function New-MocksWhenEnsurePresentNonExistingDistributedSwitchAndReferenceDistributedSwitchNameSpecified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vdSwitchProperties = New-VDSwitchProperties

    $vdSwitchProperties.ReferenceVDSwitchName = $script:constants.ReferenceDistributedSwitchName
    $vdSwitchProperties.WithoutPortGroups = $script:constants.WithoutPortGroups

    Mock -CommandName Get-VDSwitch -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName -and $Location -eq $script:datacenterNetworkFolder } -Verifiable
    Mock -CommandName New-VDSwitch -MockWith { return $null }.GetNewClosure() -Verifiable

    $vdSwitchProperties
}

function New-MocksInSetWhenEnsurePresentAndExistingDistributedSwitch {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vdSwitchProperties = New-VDSwitchProperties

    $vdSwitchProperties.ContactDetails = $script:constants.DistributedSwitchContactDetails + $script:constants.DistributedSwitchContactDetails
    $vdSwitchProperties.ContactName = $script:constants.DistributedSwitchContactName + $script:constants.DistributedSwitchContactName
    $vdSwitchProperties.MaxPorts = $script:constants.DistributedSwitchMaxPorts + 1
    $vdSwitchProperties.Mtu = $script:constants.DistributedSwitchMtu + 1

    $distributedSwitchMock = $script:distributedSwitch

    Mock -CommandName Get-VDSwitch -MockWith { return $distributedSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName -and $Location -eq $script:datacenterNetworkFolder } -Verifiable
    Mock -CommandName Set-VDSwitch -MockWith { return $null }.GetNewClosure() -Verifiable

    $vdSwitchProperties
}

function New-MocksInSetWhenEnsureAbsentAndExistingDistributedSwitch {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vdSwitchProperties = New-VDSwitchProperties

    $vdSwitchProperties.Ensure = 'Absent'

    $distributedSwitchMock = $script:distributedSwitch

    Mock -CommandName Get-VDSwitch -MockWith { return $distributedSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName -and $Location -eq $script:datacenterNetworkFolder } -Verifiable
    Mock -CommandName Remove-VDSwitch -MockWith { return $null }.GetNewClosure() -Verifiable

    $vdSwitchProperties
}

function New-MocksInSetWhenEnsureAbsentAndNonExistingDistributedSwitch {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vdSwitchProperties = New-VDSwitchProperties

    $vdSwitchProperties.Ensure = 'Absent'

    Mock -CommandName Get-VDSwitch -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName -and $Location -eq $script:datacenterNetworkFolder } -Verifiable
    Mock -CommandName Remove-VDSwitch -MockWith { return $null }.GetNewClosure()

    $vdSwitchProperties
}

function New-MocksWhenEnsurePresentAndNonExistingDistributedSwitch {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vdSwitchProperties = New-VDSwitchProperties

    Mock -CommandName Get-VDSwitch -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName -and $Location -eq $script:datacenterNetworkFolder } -Verifiable

    $vdSwitchProperties
}

function New-MocksWhenEnsurePresentExistingDistributedSwitchAndMatchingSettings {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vdSwitchProperties = New-VDSwitchProperties

    $vdSwitchProperties.ContactDetails = $script:constants.DistributedSwitchContactDetails
    $vdSwitchProperties.ContactName = $script:constants.DistributedSwitchContactName
    $vdSwitchProperties.LinkDiscoveryProtocol = $script:constants.DistributedSwitchLinkDiscoveryProtocol
    $vdSwitchProperties.LinkDiscoveryProtocolOperation = $script:constants.DistributedSwitchLinkDiscoveryProtocolOperation
    $vdSwitchProperties.MaxPorts = $script:constants.DistributedSwitchMaxPorts
    $vdSwitchProperties.Mtu = $script:constants.DistributedSwitchMtu
    $vdSwitchProperties.Notes = $script:constants.DistributedSwitchNotes
    $vdSwitchProperties.NumUplinkPorts = $script:constants.DistributedSwitchNumUplinkPorts
    $vdSwitchProperties.Version = $script:constants.DistributedSwitchVersion

    $distributedSwitchMock = $script:distributedSwitch

    Mock -CommandName Get-VDSwitch -MockWith { return $distributedSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName -and $Location -eq $script:datacenterNetworkFolder } -Verifiable

    $vdSwitchProperties
}

function New-MocksWhenEnsurePresentExistingDistributedSwitchAndNonMatchingSettings {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vdSwitchProperties = New-VDSwitchProperties

    $vdSwitchProperties.ContactName = $script:constants.DistributedSwitchContactName + $script:constants.DistributedSwitchContactName
    $vdSwitchProperties.Mtu = $script:constants.DistributedSwitchMtu + 1

    $distributedSwitchMock = $script:distributedSwitch

    Mock -CommandName Get-VDSwitch -MockWith { return $distributedSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName -and $Location -eq $script:datacenterNetworkFolder } -Verifiable

    $vdSwitchProperties
}

function New-MocksWhenEnsurePresentAndNonExistingDistributedSwitch {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vdSwitchProperties = New-VDSwitchProperties

    $vdSwitchProperties.ContactDetails = $script:constants.DistributedSwitchContactDetails
    $vdSwitchProperties.ContactName = $script:constants.DistributedSwitchContactName
    $vdSwitchProperties.LinkDiscoveryProtocol = $script:constants.DistributedSwitchLinkDiscoveryProtocol
    $vdSwitchProperties.LinkDiscoveryProtocolOperation = $script:constants.DistributedSwitchLinkDiscoveryProtocolOperation
    $vdSwitchProperties.MaxPorts = $script:constants.DistributedSwitchMaxPorts
    $vdSwitchProperties.Mtu = $script:constants.DistributedSwitchMtu
    $vdSwitchProperties.Notes = $script:constants.DistributedSwitchNotes
    $vdSwitchProperties.NumUplinkPorts = $script:constants.DistributedSwitchNumUplinkPorts
    $vdSwitchProperties.Version = $script:constants.DistributedSwitchVersion

    Mock -CommandName Get-VDSwitch -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName -and $Location -eq $script:datacenterNetworkFolder } -Verifiable

    $vdSwitchProperties
}

function New-MocksWhenEnsurePresentAndExistingDistributedSwitch {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vdSwitchProperties = New-VDSwitchProperties

    $distributedSwitchMock = $script:distributedSwitch

    Mock -CommandName Get-VDSwitch -MockWith { return $distributedSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName -and $Location -eq $script:datacenterNetworkFolder } -Verifiable

    $vdSwitchProperties
}

function New-MocksWhenEnsureAbsentAndNonExistingDistributedSwitch {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vdSwitchProperties = New-VDSwitchProperties

    $vdSwitchProperties.Ensure = 'Absent'
    $vdSwitchProperties.ContactDetails = $script:constants.DistributedSwitchContactDetails
    $vdSwitchProperties.ContactName = $script:constants.DistributedSwitchContactName
    $vdSwitchProperties.LinkDiscoveryProtocol = $script:constants.DistributedSwitchLinkDiscoveryProtocol
    $vdSwitchProperties.LinkDiscoveryProtocolOperation = $script:constants.DistributedSwitchLinkDiscoveryProtocolOperation
    $vdSwitchProperties.MaxPorts = $script:constants.DistributedSwitchMaxPorts
    $vdSwitchProperties.Mtu = $script:constants.DistributedSwitchMtu
    $vdSwitchProperties.Notes = $script:constants.DistributedSwitchNotes
    $vdSwitchProperties.NumUplinkPorts = $script:constants.DistributedSwitchNumUplinkPorts
    $vdSwitchProperties.Version = $script:constants.DistributedSwitchVersion

    Mock -CommandName Get-VDSwitch -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName -and $Location -eq $script:datacenterNetworkFolder } -Verifiable

    $vdSwitchProperties
}

function New-MocksWhenEnsureAbsentAndExistingDistributedSwitch {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vdSwitchProperties = New-VDSwitchProperties

    $vdSwitchProperties.Ensure = 'Absent'

    $distributedSwitchMock = $script:distributedSwitch

    Mock -CommandName Get-VDSwitch -MockWith { return $distributedSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName -and $Location -eq $script:datacenterNetworkFolder } -Verifiable

    $vdSwitchProperties
}
