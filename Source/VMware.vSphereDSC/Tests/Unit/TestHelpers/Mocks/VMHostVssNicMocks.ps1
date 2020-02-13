<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-VMHostVssNicProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssNicProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        VMHostName = $script:constants.VMHostName
        VssName = $script:constants.VirtualSwitchName
        PortGroupName = $script:constants.VirtualPortGroupName
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

    $vmHostVssNicProperties
}

function New-MocksForVMHostVssNic {
    [CmdletBinding()]

    $viServerMock = $script:viServer
    $vmHostMock = $script:vmHost
    $virtualSwitchMock = $script:virtualSwitch

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure()
    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure()
    Mock -CommandName Get-VirtualSwitch -MockWith { return $virtualSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VirtualSwitchName -and $VMHost -eq $script:vmHost -and $Standard }
}

function New-MocksWhenEnsurePresentAndVMKernelNetworkAdapterDoesNotExist {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssNicProperties = New-VMHostVssNicProperties

    $vmHostNetworkAdapterMock = $script:vmHostNetworkAdapter

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $PortGroup -eq $script:constants.VirtualPortGroupName -and $VirtualSwitch -eq $script:virtualSwitch -and $VMHost -eq $script:vmHost -and $VMKernel }
    Mock -CommandName New-VMHostNetworkAdapter -MockWith { return $vmHostNetworkAdapterMock }.GetNewClosure()

    $vmHostVssNicProperties
}

function New-MocksWhenEnsurePresentAndVMKernelNetworkAdapterExists {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssNicProperties = New-VMHostVssNicProperties

    $vmHostNetworkAdapterMock = $script:vmHostNetworkAdapter

    $vmHostVssNicProperties.IPv6Enabled = !$script:constants.VMKernelNetworkAdapterIPv6Enabled

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmHostNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $PortGroup -eq $script:constants.VirtualPortGroupName -and $VirtualSwitch -eq $script:virtualSwitch -and $VMHost -eq $script:vmHost -and $VMKernel }
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmHostNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:vmHostNetworkAdapter.Name -and $VMHost -eq $script:vmHost -and $VMKernel }
    Mock -CommandName Set-VMHostNetworkAdapter -MockWith { return $null }.GetNewClosure()

    $vmHostVssNicProperties
}

function New-MocksWhenEnsureAbsentAndVMKernelNetworkAdapterDoesNotExist {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssNicProperties = New-VMHostVssNicProperties

    $vmHostVssNicProperties.Ensure = 'Absent'

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $PortGroup -eq $script:constants.VirtualPortGroupName -and $VirtualSwitch -eq $script:virtualSwitch -and $VMHost -eq $script:vmHost -and $VMKernel }
    Mock -CommandName Remove-VMHostNetworkAdapter -MockWith { return $null }.GetNewClosure()

    $vmHostVssNicProperties
}

function New-MocksWhenEnsureAbsentAndVMKernelNetworkAdapterExists {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssNicProperties = New-VMHostVssNicProperties

    $vmHostVssNicProperties.Ensure = 'Absent'

    $vmHostNetworkAdapterMock = $script:vmHostNetworkAdapter

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmHostNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $PortGroup -eq $script:constants.VirtualPortGroupName -and $VirtualSwitch -eq $script:virtualSwitch -and $VMHost -eq $script:vmHost -and $VMKernel }
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmHostNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:vmHostNetworkAdapter.Name -and $VMHost -eq $script:vmHost -and $VMKernel }
    Mock -CommandName Remove-VMHostNetworkAdapter -MockWith { return $null }.GetNewClosure()

    $vmHostVssNicProperties
}

function New-MocksWhenEnsurePresentVMKernelNetworkAdapterExistsAndMatchingSettings {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssNicProperties = New-VMHostVssNicProperties

    $vmHostNetworkAdapterMock = $script:vmHostNetworkAdapter

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmHostNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $PortGroup -eq $script:constants.VirtualPortGroupName -and $VirtualSwitch -eq $script:virtualSwitch -and $VMHost -eq $script:vmHost -and $VMKernel }

    $vmHostVssNicProperties
}

function New-MocksWhenEnsurePresentVMKernelNetworkAdapterExistsAndNonMatchingSettings {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssNicProperties = New-VMHostVssNicProperties

    $vmHostVssNicProperties.SubnetMask = $vmHostVssNicProperties.SubnetMask + $vmHostVssNicProperties.SubnetMask
    $vmHostVssNicProperties.VsanTrafficEnabled = $false

    $vmHostNetworkAdapterMock = $script:vmHostNetworkAdapter

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmHostNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $PortGroup -eq $script:constants.VirtualPortGroupName -and $VirtualSwitch -eq $script:virtualSwitch -and $VMHost -eq $script:vmHost -and $VMKernel }

    $vmHostVssNicProperties
}

function New-MocksInGet {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssNicProperties = New-VMHostVssNicProperties

    $vmHostNetworkAdapterMock = $script:vmHostNetworkAdapter

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmHostNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $PortGroup -eq $script:constants.VirtualPortGroupName -and $VirtualSwitch -eq $script:virtualSwitch -and $VMHost -eq $script:vmHost -and $VMKernel }

    $vmHostVssNicProperties
}
