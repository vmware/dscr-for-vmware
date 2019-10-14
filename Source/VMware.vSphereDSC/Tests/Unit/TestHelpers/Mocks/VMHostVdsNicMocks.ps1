<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-VMHostVdsNicProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVdsNicProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        VMHostName = $script:constants.VMHostAddedToDistributedSwitchOneName
        VdsName = $script:constants.DistributedSwitchName
        PortGroupName = $script:constants.DistributedPortGroupName
        Ensure = 'Present'
        IP = $script:constants.VMKernelNetworkAdapterIP
        SubnetMask = $script:constants.VMKernelNetworkAdapterSubnetMask
        Mac = $script:constants.VMKernelNetworkAdapterMac
        AutomaticIPv6 = $script:constants.VMKernelNetworkAdapterAutomaticIPv6
        IPv6 = @()
        IPv6ThroughDhcp = $script:constants.VMKernelNetworkAdapterIPv6ThroughDhcp
        Mtu = $script:constants.VMKernelNetworkAdapterMtu
        ManagementTrafficEnabled = $script:constants.VMKernelNetworkAdapterManagementTrafficEnabled
        FaultToleranceLoggingEnabled = $script:constants.VMKernelNetworkAdapterFaultToleranceLoggingEnabled
        VMotionEnabled = $script:constants.VMKernelNetworkAdapterVMotionEnabled
        VsanTrafficEnabled = $script:constants.VMKernelNetworkAdapterVsanTrafficEnabled
    }

    $vmHostVdsNicProperties
}

function New-MocksForVMHostVdsNic {
    [CmdletBinding()]

    $viServerMock = $script:viServer
    $vmHostMock = $script:vmHostAddedToDistributedSwitchOne
    $distributedSwitchMock = $script:distributedSwitch

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure()
    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure()
    Mock -CommandName Get-VDSwitch -MockWith { return $distributedSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName }
}

function New-MocksWhenVMKernelNetworkAdapterDoesNotExistPortIdIsNotPassedAndEnsureIsPresent {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVdsNicProperties = New-VMHostVdsNicProperties

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $PortGroup -eq $script:constants.DistributedPortGroupName -and $VirtualSwitch -eq $script:distributedSwitch -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $VMKernel }
    Mock -CommandName New-VMHostNetworkAdapter -MockWith { return $null }.GetNewClosure()

    $vmHostVdsNicProperties
}

function New-MocksWhenVMKernelNetworkAdapterDoesNotExistPortIdIsPassedAndEnsureIsPresent {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVdsNicProperties = New-VMHostVdsNicProperties

    $vmHostVdsNicProperties.PortId = $script:constants.DistributedPortGroupPortId

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $PortGroup -eq $script:constants.DistributedPortGroupName -and $VirtualSwitch -eq $script:distributedSwitch -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $VMKernel }
    Mock -CommandName New-VMHostNetworkAdapter -MockWith { return $null }.GetNewClosure()

    $vmHostVdsNicProperties
}

function New-MocksWhenVMKernelNetworkAdapterExistsAndEnsureIsPresent {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVdsNicProperties = New-VMHostVdsNicProperties

    $vmHostNetworkAdapterMock = $script:vmHostNetworkAdapterConnectedToDistributedSwitch

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmHostNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $PortGroup -eq $script:constants.DistributedPortGroupName -and $VirtualSwitch -eq $script:distributedSwitch -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $VMKernel }
    Mock -CommandName Set-VMHostNetworkAdapter -MockWith { return $null }.GetNewClosure()

    $vmHostVdsNicProperties
}

function New-MocksWhenVMKernelNetworkAdapterDoesNotExistAndEnsureIsAbsent {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVdsNicProperties = New-VMHostVdsNicProperties

    $vmHostVdsNicProperties.Ensure = 'Absent'

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $PortGroup -eq $script:constants.DistributedPortGroupName -and $VirtualSwitch -eq $script:distributedSwitch -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $VMKernel }
    Mock -CommandName Remove-VMHostNetworkAdapter -MockWith { return $null }.GetNewClosure()

    $vmHostVdsNicProperties
}

function New-MocksWhenVMKernelNetworkAdapterExistsAndEnsureIsAbsent {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVdsNicProperties = New-VMHostVdsNicProperties

    $vmHostVdsNicProperties.Ensure = 'Absent'

    $vmHostNetworkAdapterMock = $script:vmHostNetworkAdapterConnectedToDistributedSwitch

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmHostNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $PortGroup -eq $script:constants.DistributedPortGroupName -and $VirtualSwitch -eq $script:distributedSwitch -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $VMKernel }
    Mock -CommandName Remove-VMHostNetworkAdapter -MockWith { return $null }.GetNewClosure()

    $vmHostVdsNicProperties
}

function New-MocksWhenVMKernelNetworkAdapterDoesNotExistAndEnsureIsPresent {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVdsNicProperties = New-VMHostVdsNicProperties

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $PortGroup -eq $script:constants.DistributedPortGroupName -and $VirtualSwitch -eq $script:distributedSwitch -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $VMKernel }

    $vmHostVdsNicProperties
}

function New-MocksWhenVMKernelNetworkAdapterExistsTheVMKernelNetworkAdapterSettingsAreNotEqualToTheServerSettingsAndEnsureIsPresent {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVdsNicProperties = New-VMHostVdsNicProperties

    $vmHostVdsNicProperties.SubnetMask = $vmHostVdsNicProperties.SubnetMask + $vmHostVdsNicProperties.SubnetMask
    $vmHostVdsNicProperties.VsanTrafficEnabled = $false

    $vmHostNetworkAdapterMock = $script:vmHostNetworkAdapterConnectedToDistributedSwitch

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmHostNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $PortGroup -eq $script:constants.DistributedPortGroupName -and $VirtualSwitch -eq $script:distributedSwitch -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $VMKernel }

    $vmHostVdsNicProperties
}

function New-MocksWhenVMKernelNetworkAdapterDoesNotExist {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVdsNicProperties = New-VMHostVdsNicProperties

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $PortGroup -eq $script:constants.DistributedPortGroupName -and $VirtualSwitch -eq $script:distributedSwitch -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $VMKernel }

    $vmHostVdsNicProperties
}

function New-MocksWhenVMKernelNetworkAdapterExists {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVdsNicProperties = New-VMHostVdsNicProperties

    $vmHostNetworkAdapterMock = $script:vmHostNetworkAdapterConnectedToDistributedSwitch

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmHostNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $PortGroup -eq $script:constants.DistributedPortGroupName -and $VirtualSwitch -eq $script:distributedSwitch -and $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $VMKernel }

    $vmHostVdsNicProperties
}
