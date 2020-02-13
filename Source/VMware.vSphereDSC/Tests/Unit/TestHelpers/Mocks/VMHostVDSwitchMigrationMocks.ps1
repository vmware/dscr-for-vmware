<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-VMHostVDSwitchMigrationProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVDSwitchMigrationProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        VMHostName = $script:constants.VMHostAddedToDistributedSwitchOneName
        VdsName = $script:constants.DistributedSwitchName
    }

    $vmHostVDSwitchMigrationProperties
}

function New-MocksForVMHostVDSwitchMigration {
    [CmdletBinding()]

    $viServerMock = $script:viServer
    $vmHostMock = $script:vmHostAddedToDistributedSwitchOne
    $distributedSwitchMock = $script:distributedSwitch

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure()
    Mock -CommandName Get-VDSwitch -MockWith { return $distributedSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName }
    Mock -CommandName Disconnect-VIServer -MockWith { return $null }.GetNewClosure() -Verifiable
}

function New-MocksWhenOneDisconnectedPhysicalNetworkAdapterIsPassedAndServerErrorOccursDuringMigration {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVDSwitchMigrationProperties = New-VMHostVDSwitchMigrationProperties

    $vmHostVDSwitchMigrationProperties.PhysicalNicNames = @($script:constants.DisconnectedPhysicalNetworkAdapterOneName)

    $physicalNetworkAdapterMock = $script:disconnectedPhysicalNetworkAdapterOne

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DisconnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $Physical } -Verifiable
    Mock -CommandName Add-VDSwitchPhysicalNetworkAdapter -MockWith { throw }.GetNewClosure() -Verifiable

    $vmHostVDSwitchMigrationProperties
}

function New-MocksWhenOneDisconnectedPhysicalNetworkAdapterIsPassed {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVDSwitchMigrationProperties = New-VMHostVDSwitchMigrationProperties

    $vmHostVDSwitchMigrationProperties.PhysicalNicNames = @($script:constants.DisconnectedPhysicalNetworkAdapterOneName)

    $physicalNetworkAdapterMock = $script:disconnectedPhysicalNetworkAdapterOne

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DisconnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $Physical } -Verifiable
    Mock -CommandName Add-VDSwitchPhysicalNetworkAdapter -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostVDSwitchMigrationProperties
}

function New-MocksWhenTwoDisconnectedPhysicalNetworkAdaptersArePassedAndServerErrorOccursDuringMigration {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVDSwitchMigrationProperties = New-VMHostVDSwitchMigrationProperties

    $vmHostVDSwitchMigrationProperties.PhysicalNicNames = @($script:constants.DisconnectedPhysicalNetworkAdapterOneName, $script:constants.DisconnectedPhysicalNetworkAdapterTwoName)

    $physicalNetworkAdapterOneMock = $script:disconnectedPhysicalNetworkAdapterOne
    $physicalNetworkAdapterTwoMock = $script:disconnectedPhysicalNetworkAdapterTwo

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterOneMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DisconnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $Physical } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterTwoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DisconnectedPhysicalNetworkAdapterTwoName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $Physical } -Verifiable
    Mock -CommandName Add-VDSwitchPhysicalNetworkAdapter -MockWith { throw }.GetNewClosure() -Verifiable

    $vmHostVDSwitchMigrationProperties
}

function New-MocksWhenTwoDisconnectedPhysicalNetworkAdaptersArePassed {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVDSwitchMigrationProperties = New-VMHostVDSwitchMigrationProperties

    $vmHostVDSwitchMigrationProperties.PhysicalNicNames = @($script:constants.DisconnectedPhysicalNetworkAdapterOneName, $script:constants.DisconnectedPhysicalNetworkAdapterTwoName)

    $physicalNetworkAdapterOneMock = $script:disconnectedPhysicalNetworkAdapterOne
    $physicalNetworkAdapterTwoMock = $script:disconnectedPhysicalNetworkAdapterTwo

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterOneMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DisconnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $Physical } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterTwoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DisconnectedPhysicalNetworkAdapterTwoName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $Physical } -Verifiable
    Mock -CommandName Add-VDSwitchPhysicalNetworkAdapter -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostVDSwitchMigrationProperties
}

function New-MocksWhenTwoConnectedAndOneDisconnectedPhysicalNetworkAdaptersArePassedAndServerErrorOccursDuringMigration {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVDSwitchMigrationProperties = New-VMHostVDSwitchMigrationProperties

    $vmHostVDSwitchMigrationProperties.PhysicalNicNames = @(
        $script:constants.ConnectedPhysicalNetworkAdapterOneName,
        $script:constants.ConnectedPhysicalNetworkAdapterTwoName,
        $script:constants.DisconnectedPhysicalNetworkAdapterOneName
    )

    $physicalNetworkAdapterOneMock = $script:connectedPhysicalNetworkAdapterOne
    $physicalNetworkAdapterTwoMock = $script:connectedPhysicalNetworkAdapterTwo
    $physicalNetworkAdapterThreeMock = $script:disconnectedPhysicalNetworkAdapterOne

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterOneMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.ConnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $Physical } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterTwoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.ConnectedPhysicalNetworkAdapterTwoName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $Physical } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterThreeMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DisconnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $Physical } -Verifiable
    Mock -CommandName Add-VDSwitchPhysicalNetworkAdapter -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $DistributedSwitch -eq $script:distributedSwitch -and [System.Linq.Enumerable]::SequenceEqual($VMHostPhysicalNic, [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.Nic.PhysicalNic[]] @($script:connectedPhysicalNetworkAdapterOne)) -and !$Confirm } -Verifiable
    Mock -CommandName Add-VDSwitchPhysicalNetworkAdapter -MockWith { throw }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $DistributedSwitch -eq $script:distributedSwitch -and [System.Linq.Enumerable]::SequenceEqual($VMHostPhysicalNic, [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.Nic.PhysicalNic[]] @($script:connectedPhysicalNetworkAdapterTwo, $script:disconnectedPhysicalNetworkAdapterOne)) -and !$Confirm } -Verifiable

    $vmHostVDSwitchMigrationProperties
}

function New-MocksWhenTwoConnectedAndOneDisconnectedPhysicalNetworkAdaptersArePassed {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVDSwitchMigrationProperties = New-VMHostVDSwitchMigrationProperties

    $vmHostVDSwitchMigrationProperties.PhysicalNicNames = @(
        $script:constants.ConnectedPhysicalNetworkAdapterOneName,
        $script:constants.ConnectedPhysicalNetworkAdapterTwoName,
        $script:constants.DisconnectedPhysicalNetworkAdapterOneName
    )

    $physicalNetworkAdapterOneMock = $script:connectedPhysicalNetworkAdapterOne
    $physicalNetworkAdapterTwoMock = $script:connectedPhysicalNetworkAdapterTwo
    $physicalNetworkAdapterThreeMock = $script:disconnectedPhysicalNetworkAdapterOne

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterOneMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.ConnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $Physical } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterTwoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.ConnectedPhysicalNetworkAdapterTwoName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $Physical } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterThreeMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DisconnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $Physical } -Verifiable
    Mock -CommandName Add-VDSwitchPhysicalNetworkAdapter -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostVDSwitchMigrationProperties
}

function New-MocksWhenOneDisconnectedPhysicalNetworkAdapterTwoVMKernelNetworkAdaptersAndOnePortGroupArePassedAndServerErrorOccursDuringMigration {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVDSwitchMigrationProperties = New-VMHostVDSwitchMigrationProperties

    $vmHostVDSwitchMigrationProperties.PhysicalNicNames = @($script:constants.DisconnectedPhysicalNetworkAdapterOneName)
    $vmHostVDSwitchMigrationProperties.VMKernelNicNames = @($script:constants.VMKernelNetworkAdapterOneName, $script:constants.VMKernelNetworkAdapterTwoName)
    $vmHostVDSwitchMigrationProperties.PortGroupNames = @($script:constants.PortGroupOneName)

    $physicalNetworkAdapterMock = $script:disconnectedPhysicalNetworkAdapterOne
    $vmKernelNetworkAdapterOneMock = $script:vmKernelNetworkAdapterOne
    $vmKernelNetworkAdapterTwoMock = $script:vmKernelNetworkAdapterTwo

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DisconnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $Physical } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmKernelNetworkAdapterOneMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMKernelNetworkAdapterOneName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $VMKernel } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmKernelNetworkAdapterTwoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMKernelNetworkAdapterTwoName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $VMKernel } -Verifiable
    Mock -CommandName Get-VDPortgroup -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.PortGroupOneName -and $VDSwitch -eq $script:distributedSwitch } -Verifiable
    Mock -CommandName New-VDPortgroup -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.PortGroupOneName -and $VDSwitch -eq $script:distributedSwitch } -Verifiable
    Mock -CommandName Add-VDSwitchPhysicalNetworkAdapter -MockWith { throw }.GetNewClosure() -Verifiable

    $vmHostVDSwitchMigrationProperties
}

function New-MocksWhenOneDisconnectedPhysicalNetworkAdapterTwoVMKernelNetworkAdaptersAndOnePortGroupArePassed {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVDSwitchMigrationProperties = New-VMHostVDSwitchMigrationProperties

    $vmHostVDSwitchMigrationProperties.PhysicalNicNames = @($script:constants.DisconnectedPhysicalNetworkAdapterOneName)
    $vmHostVDSwitchMigrationProperties.VMKernelNicNames = @($script:constants.VMKernelNetworkAdapterOneName, $script:constants.VMKernelNetworkAdapterTwoName)
    $vmHostVDSwitchMigrationProperties.PortGroupNames = @($script:constants.PortGroupOneName)

    $physicalNetworkAdapterMock = $script:disconnectedPhysicalNetworkAdapterOne
    $vmKernelNetworkAdapterOneMock = $script:vmKernelNetworkAdapterOne
    $vmKernelNetworkAdapterTwoMock = $script:vmKernelNetworkAdapterTwo

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DisconnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $Physical } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmKernelNetworkAdapterOneMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMKernelNetworkAdapterOneName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $VMKernel } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmKernelNetworkAdapterTwoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMKernelNetworkAdapterTwoName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $VMKernel } -Verifiable
    Mock -CommandName Get-VDPortgroup -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.PortGroupOneName -and $VDSwitch -eq $script:distributedSwitch } -Verifiable
    Mock -CommandName New-VDPortgroup -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.PortGroupOneName -and $VDSwitch -eq $script:distributedSwitch } -Verifiable
    Mock -CommandName Add-VDSwitchPhysicalNetworkAdapter -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostVDSwitchMigrationProperties
}

function New-MocksWhenOneDisconnectedPhysicalNetworkAdapterTwoVMKernelNetworkAdaptersAndTwoPortGroupsArePassed {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVDSwitchMigrationProperties = New-VMHostVDSwitchMigrationProperties

    $vmHostVDSwitchMigrationProperties.PhysicalNicNames = @($script:constants.DisconnectedPhysicalNetworkAdapterOneName)
    $vmHostVDSwitchMigrationProperties.VMKernelNicNames = @($script:constants.VMKernelNetworkAdapterOneName, $script:constants.VMKernelNetworkAdapterTwoName)
    $vmHostVDSwitchMigrationProperties.PortGroupNames = @($script:constants.PortGroupOneName, $script:constants.PortGroupTwoName)

    $physicalNetworkAdapterMock = $script:disconnectedPhysicalNetworkAdapterOne
    $vmKernelNetworkAdapterOneMock = $script:vmKernelNetworkAdapterOne
    $vmKernelNetworkAdapterTwoMock = $script:vmKernelNetworkAdapterTwo

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DisconnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $Physical } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmKernelNetworkAdapterOneMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMKernelNetworkAdapterOneName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $VMKernel } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmKernelNetworkAdapterTwoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMKernelNetworkAdapterTwoName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $VMKernel } -Verifiable
    Mock -CommandName Get-VDPortgroup -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.PortGroupOneName -and $VDSwitch -eq $script:distributedSwitch } -Verifiable
    Mock -CommandName Get-VDPortgroup -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.PortGroupTwoName -and $VDSwitch -eq $script:distributedSwitch } -Verifiable
    Mock -CommandName New-VDPortgroup -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.PortGroupOneName -and $VDSwitch -eq $script:distributedSwitch } -Verifiable
    Mock -CommandName New-VDPortgroup -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.PortGroupTwoName -and $VDSwitch -eq $script:distributedSwitch } -Verifiable
    Mock -CommandName Add-VDSwitchPhysicalNetworkAdapter -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostVDSwitchMigrationProperties
}

function New-MocksWhenTwoDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndOnePortGroupArePassedAndServerErrorOccursDuringMigration {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVDSwitchMigrationProperties = New-VMHostVDSwitchMigrationProperties

    $vmHostVDSwitchMigrationProperties.PhysicalNicNames = @($script:constants.DisconnectedPhysicalNetworkAdapterOneName, $script:constants.DisconnectedPhysicalNetworkAdapterTwoName)
    $vmHostVDSwitchMigrationProperties.VMKernelNicNames = @($script:constants.VMKernelNetworkAdapterOneName, $script:constants.VMKernelNetworkAdapterTwoName)
    $vmHostVDSwitchMigrationProperties.PortGroupNames = @($script:constants.PortGroupOneName)

    $physicalNetworkAdapterOneMock = $script:disconnectedPhysicalNetworkAdapterOne
    $physicalNetworkAdapterTwoMock = $script:disconnectedPhysicalNetworkAdapterTwo
    $vmKernelNetworkAdapterOneMock = $script:vmKernelNetworkAdapterOne
    $vmKernelNetworkAdapterTwoMock = $script:vmKernelNetworkAdapterTwo

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterOneMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DisconnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $Physical } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterTwoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DisconnectedPhysicalNetworkAdapterTwoName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $Physical } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmKernelNetworkAdapterOneMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMKernelNetworkAdapterOneName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $VMKernel } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmKernelNetworkAdapterTwoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMKernelNetworkAdapterTwoName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $VMKernel } -Verifiable
    Mock -CommandName Get-VDPortgroup -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.PortGroupOneName -and $VDSwitch -eq $script:distributedSwitch } -Verifiable
    Mock -CommandName New-VDPortgroup -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.PortGroupOneName -and $VDSwitch -eq $script:distributedSwitch } -Verifiable
    Mock -CommandName Add-VDSwitchPhysicalNetworkAdapter -MockWith { throw }.GetNewClosure() -Verifiable

    $vmHostVDSwitchMigrationProperties
}

function New-MocksWhenTwoDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndOnePortGroupArePassed {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVDSwitchMigrationProperties = New-VMHostVDSwitchMigrationProperties

    $vmHostVDSwitchMigrationProperties.PhysicalNicNames = @($script:constants.DisconnectedPhysicalNetworkAdapterOneName, $script:constants.DisconnectedPhysicalNetworkAdapterTwoName)
    $vmHostVDSwitchMigrationProperties.VMKernelNicNames = @($script:constants.VMKernelNetworkAdapterOneName, $script:constants.VMKernelNetworkAdapterTwoName)
    $vmHostVDSwitchMigrationProperties.PortGroupNames = @($script:constants.PortGroupOneName)

    $physicalNetworkAdapterOneMock = $script:disconnectedPhysicalNetworkAdapterOne
    $physicalNetworkAdapterTwoMock = $script:disconnectedPhysicalNetworkAdapterTwo
    $vmKernelNetworkAdapterOneMock = $script:vmKernelNetworkAdapterOne
    $vmKernelNetworkAdapterTwoMock = $script:vmKernelNetworkAdapterTwo

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterOneMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DisconnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $Physical } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterTwoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DisconnectedPhysicalNetworkAdapterTwoName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $Physical } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmKernelNetworkAdapterOneMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMKernelNetworkAdapterOneName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $VMKernel } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmKernelNetworkAdapterTwoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMKernelNetworkAdapterTwoName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $VMKernel } -Verifiable
    Mock -CommandName Get-VDPortgroup -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.PortGroupOneName -and $VDSwitch -eq $script:distributedSwitch } -Verifiable
    Mock -CommandName New-VDPortgroup -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.PortGroupOneName -and $VDSwitch -eq $script:distributedSwitch } -Verifiable
    Mock -CommandName Add-VDSwitchPhysicalNetworkAdapter -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostVDSwitchMigrationProperties
}

function New-MocksWhenTwoDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndTwoPortGroupsArePassed {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVDSwitchMigrationProperties = New-VMHostVDSwitchMigrationProperties

    $vmHostVDSwitchMigrationProperties.PhysicalNicNames = @($script:constants.DisconnectedPhysicalNetworkAdapterOneName, $script:constants.DisconnectedPhysicalNetworkAdapterTwoName)
    $vmHostVDSwitchMigrationProperties.VMKernelNicNames = @($script:constants.VMKernelNetworkAdapterOneName, $script:constants.VMKernelNetworkAdapterTwoName)
    $vmHostVDSwitchMigrationProperties.PortGroupNames = @($script:constants.PortGroupOneName, $script:constants.PortGroupTwoName)

    $physicalNetworkAdapterOneMock = $script:disconnectedPhysicalNetworkAdapterOne
    $physicalNetworkAdapterTwoMock = $script:disconnectedPhysicalNetworkAdapterTwo
    $vmKernelNetworkAdapterOneMock = $script:vmKernelNetworkAdapterOne
    $vmKernelNetworkAdapterTwoMock = $script:vmKernelNetworkAdapterTwo

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterOneMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DisconnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $Physical } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterTwoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DisconnectedPhysicalNetworkAdapterTwoName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $Physical } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmKernelNetworkAdapterOneMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMKernelNetworkAdapterOneName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $VMKernel } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmKernelNetworkAdapterTwoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMKernelNetworkAdapterTwoName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $VMKernel } -Verifiable
    Mock -CommandName Get-VDPortgroup -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.PortGroupOneName -and $VDSwitch -eq $script:distributedSwitch } -Verifiable
    Mock -CommandName Get-VDPortgroup -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.PortGroupTwoName -and $VDSwitch -eq $script:distributedSwitch } -Verifiable
    Mock -CommandName New-VDPortgroup -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.PortGroupOneName -and $VDSwitch -eq $script:distributedSwitch } -Verifiable
    Mock -CommandName New-VDPortgroup -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.PortGroupTwoName -and $VDSwitch -eq $script:distributedSwitch } -Verifiable
    Mock -CommandName Add-VDSwitchPhysicalNetworkAdapter -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostVDSwitchMigrationProperties
}

function New-MocksWhenTwoConnectedAndOneDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndOnePortGroupArePassed {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVDSwitchMigrationProperties = New-VMHostVDSwitchMigrationProperties

    $vmHostVDSwitchMigrationProperties.PhysicalNicNames = @(
        $script:constants.ConnectedPhysicalNetworkAdapterOneName,
        $script:constants.ConnectedPhysicalNetworkAdapterTwoName,
        $script:constants.DisconnectedPhysicalNetworkAdapterOneName
    )
    $vmHostVDSwitchMigrationProperties.VMKernelNicNames = @($script:constants.VMKernelNetworkAdapterOneName, $script:constants.VMKernelNetworkAdapterTwoName)
    $vmHostVDSwitchMigrationProperties.PortGroupNames = @($script:constants.PortGroupOneName)

    $physicalNetworkAdapterOneMock = $script:connectedPhysicalNetworkAdapterOne
    $physicalNetworkAdapterTwoMock = $script:connectedPhysicalNetworkAdapterTwo
    $physicalNetworkAdapterThreeMock = $script:disconnectedPhysicalNetworkAdapterOne
    $vmKernelNetworkAdapterOneMock = $script:vmKernelNetworkAdapterOne
    $vmKernelNetworkAdapterTwoMock = $script:vmKernelNetworkAdapterTwo

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterOneMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.ConnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $Physical } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterTwoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.ConnectedPhysicalNetworkAdapterTwoName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $Physical } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterThreeMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DisconnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $Physical } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmKernelNetworkAdapterOneMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMKernelNetworkAdapterOneName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $VMKernel } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmKernelNetworkAdapterTwoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMKernelNetworkAdapterTwoName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $VMKernel } -Verifiable
    Mock -CommandName Get-VDPortgroup -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.PortGroupOneName -and $VDSwitch -eq $script:distributedSwitch } -Verifiable
    Mock -CommandName New-VDPortgroup -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.PortGroupOneName -and $VDSwitch -eq $script:distributedSwitch } -Verifiable
    Mock -CommandName Add-VDSwitchPhysicalNetworkAdapter -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostVDSwitchMigrationProperties
}

function New-MocksWhenTwoConnectedAndOneDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndTwoPortGroupsArePassed {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVDSwitchMigrationProperties = New-VMHostVDSwitchMigrationProperties

    $vmHostVDSwitchMigrationProperties.PhysicalNicNames = @(
        $script:constants.ConnectedPhysicalNetworkAdapterOneName,
        $script:constants.ConnectedPhysicalNetworkAdapterTwoName,
        $script:constants.DisconnectedPhysicalNetworkAdapterOneName
    )
    $vmHostVDSwitchMigrationProperties.VMKernelNicNames = @($script:constants.VMKernelNetworkAdapterOneName, $script:constants.VMKernelNetworkAdapterTwoName)
    $vmHostVDSwitchMigrationProperties.PortGroupNames = @($script:constants.PortGroupOneName, $script:constants.PortGroupTwoName)

    $physicalNetworkAdapterOneMock = $script:connectedPhysicalNetworkAdapterOne
    $physicalNetworkAdapterTwoMock = $script:connectedPhysicalNetworkAdapterTwo
    $physicalNetworkAdapterThreeMock = $script:disconnectedPhysicalNetworkAdapterOne
    $vmKernelNetworkAdapterOneMock = $script:vmKernelNetworkAdapterOne
    $vmKernelNetworkAdapterTwoMock = $script:vmKernelNetworkAdapterTwo

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterOneMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.ConnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $Physical } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterTwoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.ConnectedPhysicalNetworkAdapterTwoName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $Physical } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterThreeMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DisconnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $Physical } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmKernelNetworkAdapterOneMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMKernelNetworkAdapterOneName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $VMKernel } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmKernelNetworkAdapterTwoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMKernelNetworkAdapterTwoName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $VMKernel } -Verifiable
    Mock -CommandName Get-VDPortgroup -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.PortGroupOneName -and $VDSwitch -eq $script:distributedSwitch } -Verifiable
    Mock -CommandName Get-VDPortgroup -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.PortGroupTwoName -and $VDSwitch -eq $script:distributedSwitch } -Verifiable
    Mock -CommandName New-VDPortgroup -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.PortGroupOneName -and $VDSwitch -eq $script:distributedSwitch } -Verifiable
    Mock -CommandName New-VDPortgroup -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.PortGroupTwoName -and $VDSwitch -eq $script:distributedSwitch } -Verifiable
    Mock -CommandName Add-VDSwitchPhysicalNetworkAdapter -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostVDSwitchMigrationProperties
}

function New-MocksWhenVMHostIsNotAddedToTheDistributedSwitch {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVDSwitchMigrationProperties = New-VMHostVDSwitchMigrationProperties

    $vmHostVDSwitchMigrationProperties.VMHostName = $script:constants.VMHostName

    $vmHostMock = $script:vmHost

    # We need to mock Get-VMHost again here to change the ESXi we use in all the other tests.
    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -ParameterFilter { $Server -eq $viServer -and $Name -eq $script:constants.VMHostName } -Verifiable

    $vmHostVDSwitchMigrationProperties
}

function New-MocksWhenOnePhysicalNetworkAdapterIsPassedAndNoPhysicalNetworkAdaptersAreAddedToTheDistributedSwitch {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVDSwitchMigrationProperties = New-VMHostVDSwitchMigrationProperties

    $vmHostVDSwitchMigrationProperties.VdsName = $script:constants.DistributedSwitchWithoutAddedPhysicalNetworkAdaptersName
    $vmHostVDSwitchMigrationProperties.PhysicalNicNames = @($script:constants.ConnectedPhysicalNetworkAdapterOneName)

    $distributedSwitchMock = $script:distributedSwitchWithoutAddedPhysicalNetworkAdapters

    # We need to mock Get-VDSwitch again here to change the Distributed Switch we use in all the other tests.
    Mock -CommandName Get-VDSwitch -MockWith { return $distributedSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchWithoutAddedPhysicalNetworkAdaptersName } -Verifiable

    $vmHostVDSwitchMigrationProperties
}

function New-MocksWhenTwoPhysicalNetworkAdaptersArePassedAndTheSecondIsNotAddedToTheDistributedSwitch {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVDSwitchMigrationProperties = New-VMHostVDSwitchMigrationProperties

    $vmHostVDSwitchMigrationProperties.PhysicalNicNames = @($script:constants.ConnectedPhysicalNetworkAdapterOneName, $script:constants.ConnectedPhysicalNetworkAdapterTwoName)

    $distributedSwitchMock = $script:distributedSwitchWithAddedPhysicalNetworkAdapters
    $physicalNetworkAdapterOneMock = $script:connectedPhysicalNetworkAdapterOne
    $physicalNetworkAdapterTwoMock = $script:connectedPhysicalNetworkAdapterTwo

    # We need to mock Get-VDSwitch again here to change the Distributed Switch we use in all the other tests.
    Mock -CommandName Get-VDSwitch -MockWith { return $distributedSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterOneMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.ConnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $Physical } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterTwoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.ConnectedPhysicalNetworkAdapterTwoName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $Physical } -Verifiable

    $vmHostVDSwitchMigrationProperties
}

function New-MocksWhenOnePhysicalNetworkAdapterIsPassedAndItIsAddedToTheDistributedSwitchAndNoVMKernelNetworkAdaptersAndPortGroupsArePassed {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVDSwitchMigrationProperties = New-VMHostVDSwitchMigrationProperties

    $vmHostVDSwitchMigrationProperties.PhysicalNicNames = @($script:constants.ConnectedPhysicalNetworkAdapterOneName)

    $distributedSwitchMock = $script:distributedSwitchWithAddedPhysicalNetworkAdapters
    $physicalNetworkAdapterMock = $script:connectedPhysicalNetworkAdapterOne

    # We need to mock Get-VDSwitch again here to change the Distributed Switch we use in all the other tests.
    Mock -CommandName Get-VDSwitch -MockWith { return $distributedSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.ConnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $Physical } -Verifiable

    $vmHostVDSwitchMigrationProperties
}

function New-MocksWhenOneVMKernelNetworkAdapterAndZeroPortGroupsArePassed {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVDSwitchMigrationProperties = New-VMHostVDSwitchMigrationProperties

    $vmHostVDSwitchMigrationProperties.PhysicalNicNames = @($script:constants.ConnectedPhysicalNetworkAdapterOneName)
    $vmHostVDSwitchMigrationProperties.VMKernelNicNames = @($script:constants.VMKernelNetworkAdapterOneName)
    $vmHostVDSwitchMigrationProperties.PortGroupNames = @()

    $distributedSwitchMock = $script:distributedSwitchWithAddedPhysicalNetworkAdapters
    $physicalNetworkAdapterMock = $script:connectedPhysicalNetworkAdapterOne

    # We need to mock Get-VDSwitch again here to change the Distributed Switch we use in all the other tests.
    Mock -CommandName Get-VDSwitch -MockWith { return $distributedSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.ConnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $Physical } -Verifiable

    $vmHostVDSwitchMigrationProperties
}

function New-MocksWhenZeroVMKernelNetworkAdaptersAndOnePortGroupArePassed {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVDSwitchMigrationProperties = New-VMHostVDSwitchMigrationProperties

    $vmHostVDSwitchMigrationProperties.PhysicalNicNames = @($script:constants.ConnectedPhysicalNetworkAdapterOneName)
    $vmHostVDSwitchMigrationProperties.VMKernelNicNames = @()
    $vmHostVDSwitchMigrationProperties.PortGroupNames = @($script:constants.PortGroupOneName)

    $distributedSwitchMock = $script:distributedSwitchWithAddedPhysicalNetworkAdapters
    $physicalNetworkAdapterMock = $script:connectedPhysicalNetworkAdapterOne

    # We need to mock Get-VDSwitch again here to change the Distributed Switch we use in all the other tests.
    Mock -CommandName Get-VDSwitch -MockWith { return $distributedSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.ConnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $Physical } -Verifiable

    $vmHostVDSwitchMigrationProperties
}

function New-MocksWhenTwoVMKernelNetworkAdaptersAndOnePortGroupArePassedAndTheSecondVMKernelNetworkAdapterIsNotAddedToTheDistributedSwitch {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVDSwitchMigrationProperties = New-VMHostVDSwitchMigrationProperties

    $vmHostVDSwitchMigrationProperties.PhysicalNicNames = @($script:constants.ConnectedPhysicalNetworkAdapterOneName)
    $vmHostVDSwitchMigrationProperties.VMKernelNicNames = @($script:constants.VMKernelNetworkAdapterOneName, $script:constants.VMKernelNetworkAdapterTwoName)
    $vmHostVDSwitchMigrationProperties.PortGroupNames = @($script:constants.PortGroupOneName)

    $distributedSwitchMock = $script:distributedSwitchWithAddedPhysicalNetworkAdapters
    $physicalNetworkAdapterMock = $script:connectedPhysicalNetworkAdapterOne
    $vmKernelNetworkAdapterMock = $script:vmKernelNetworkAdapterOne

    # We need to mock Get-VDSwitch again here to change the Distributed Switch we use in all the other tests.
    Mock -CommandName Get-VDSwitch -MockWith { return $distributedSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.ConnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $Physical } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmKernelNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMKernelNetworkAdapterOneName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $VirtualSwitch -eq $script:distributedSwitchWithAddedPhysicalNetworkAdapters -and $PortGroup -eq $script:constants.PortGroupOneName -and $VMKernel } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMKernelNetworkAdapterTwoName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $VirtualSwitch -eq $script:distributedSwitchWithAddedPhysicalNetworkAdapters -and $PortGroup -eq $script:constants.PortGroupOneName -and $VMKernel } -Verifiable

    $vmHostVDSwitchMigrationProperties
}

function New-MocksWhenTwoVMKernelNetworkAdaptersAndTwoPortGroupsArePassedAndTheSecondVMKernelNetworkAdapterIsNotAddedToTheDistributedSwitch {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVDSwitchMigrationProperties = New-VMHostVDSwitchMigrationProperties

    $vmHostVDSwitchMigrationProperties.PhysicalNicNames = @($script:constants.ConnectedPhysicalNetworkAdapterOneName)
    $vmHostVDSwitchMigrationProperties.VMKernelNicNames = @($script:constants.VMKernelNetworkAdapterOneName, $script:constants.VMKernelNetworkAdapterTwoName)
    $vmHostVDSwitchMigrationProperties.PortGroupNames = @($script:constants.PortGroupOneName, $script:constants.PortGroupTwoName)

    $distributedSwitchMock = $script:distributedSwitchWithAddedPhysicalNetworkAdapters
    $physicalNetworkAdapterMock = $script:connectedPhysicalNetworkAdapterOne
    $vmKernelNetworkAdapterMock = $script:vmKernelNetworkAdapterOne

    # We need to mock Get-VDSwitch again here to change the Distributed Switch we use in all the other tests.
    Mock -CommandName Get-VDSwitch -MockWith { return $distributedSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.ConnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $Physical } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmKernelNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMKernelNetworkAdapterOneName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $VirtualSwitch -eq $script:distributedSwitchWithAddedPhysicalNetworkAdapters -and $PortGroup -eq $script:constants.PortGroupOneName -and $VMKernel } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMKernelNetworkAdapterTwoName -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $VirtualSwitch -eq $script:distributedSwitchWithAddedPhysicalNetworkAdapters -and $PortGroup -eq $script:constants.PortGroupTwoName -and $VMKernel } -Verifiable

    $vmHostVDSwitchMigrationProperties
}

function New-MocksInGet {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVDSwitchMigrationProperties = New-VMHostVDSwitchMigrationProperties

    $vmHostVDSwitchMigrationProperties.VMKernelNicNames = @($script:constants.VMKernelNetworkAdapterOneName, $script:constants.VMKernelNetworkAdapterTwoName)

    $distributedSwitchMock = $script:distributedSwitchWithAddedPhysicalNetworkAdapters
    $vmKernelNetworkAdaptersMock = @($script:vmKernelNetworkAdapterOne, $script:vmKernelNetworkAdapterTwo)

    # We need to mock Get-VDSwitch again here to change the Distributed Switch we use in all the other tests.
    Mock -CommandName Get-VDSwitch -MockWith { return $distributedSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmKernelNetworkAdaptersMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $VirtualSwitch -eq $script:distributedSwitchWithAddedPhysicalNetworkAdapters -and $VMKernel } -Verifiable

    $vmHostVDSwitchMigrationProperties
}
