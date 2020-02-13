<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-VMHostNicBaseDSCProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostNetworkAdapterBaseDSCProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        VMHostName = $script:constants.VMHostName
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

    $vmHostNetworkAdapterBaseDSCProperties
}

function New-MocksForVMHostNicBaseDSC {
    [CmdletBinding()]

    $viServerMock = $script:viServer
    $vmHostMock = $script:vmHost

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable
}

function New-MocksWhenVMKernelNetworkAdapterExists {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostNetworkAdapterBaseDSCProperties = New-VMHostNicBaseDSCProperties

    $vmHostNetworkAdapterMock = $script:vmHostNetworkAdapter

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmHostNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $PortGroup -eq $script:constants.VirtualPortGroupName -and $VirtualSwitch -eq $script:virtualSwitch -and $VMHost -eq $script:vmHost -and $VMKernel } -Verifiable

    $vmHostNetworkAdapterBaseDSCProperties
}

function New-MocksWhenVMKernelNetworkAdapterDoesNotExist {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostNetworkAdapterBaseDSCProperties = New-VMHostNicBaseDSCProperties

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $PortGroup -eq $script:constants.VirtualPortGroupName -and $VirtualSwitch -eq $script:virtualSwitch -and $VMHost -eq $script:vmHost -and $VMKernel } -Verifiable

    $vmHostNetworkAdapterBaseDSCProperties
}

function New-MocksWhenVMKernelNetworkAdapterSettingsMatch {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostNetworkAdapterBaseDSCProperties = New-VMHostNicBaseDSCProperties

    $vmHostNetworkAdapterMock = $script:vmHostNetworkAdapter

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmHostNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $PortGroup -eq $script:constants.VirtualPortGroupName -and $VirtualSwitch -eq $script:virtualSwitch -and $VMHost -eq $script:vmHost -and $VMKernel } -Verifiable

    $vmHostNetworkAdapterBaseDSCProperties
}

function New-MocksWhenVMKernelNetworkAdapterSettingsDoesNotMatch {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostNetworkAdapterBaseDSCProperties = New-VMHostNicBaseDSCProperties

    $vmHostNetworkAdapterBaseDSCProperties.Mac = $vmHostNetworkAdapterBaseDSCProperties.Mac + $vmHostNetworkAdapterBaseDSCProperties.Mac
    $vmHostNetworkAdapterBaseDSCProperties.Dhcp = $false
    $vmHostNetworkAdapterBaseDSCProperties.ManagementTrafficEnabled = $false

    $vmHostNetworkAdapterMock = $script:vmHostNetworkAdapter

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmHostNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $PortGroup -eq $script:constants.VirtualPortGroupName -and $VirtualSwitch -eq $script:virtualSwitch -and $VMHost -eq $script:vmHost -and $VMKernel } -Verifiable

    $vmHostNetworkAdapterBaseDSCProperties
}

function New-MocksWhenVMKernelNetworkAdapterSettingsResultsInAnError {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostNetworkAdapterBaseDSCProperties = New-VMHostNicBaseDSCProperties

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $PortGroup -eq $script:constants.VirtualPortGroupName -and $VirtualSwitch -eq $script:virtualSwitch -and $VMHost -eq $script:vmHost -and $VMKernel } -Verifiable
    Mock -CommandName New-VMHostNetworkAdapter -MockWith { throw }.GetNewClosure() -Verifiable

    $vmHostNetworkAdapterBaseDSCProperties
}

function New-MocksWhenAddingVMKernelNetworkAdapter {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostNetworkAdapterBaseDSCProperties = New-VMHostNicBaseDSCProperties

    $vmHostNetworkAdapterMock = $script:vmHostNetworkAdapter

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $PortGroup -eq $script:constants.VirtualPortGroupName -and $VirtualSwitch -eq $script:virtualSwitch -and $VMHost -eq $script:vmHost -and $VMKernel } -Verifiable
    Mock -CommandName New-VMHostNetworkAdapter -MockWith { return $vmHostNetworkAdapterMock }.GetNewClosure() -Verifiable

    $vmHostNetworkAdapterBaseDSCProperties
}

function New-MocksWhenUpdatingVMKernelNetworkAdapterSettingsResultsInAnError {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostNetworkAdapterBaseDSCProperties = New-VMHostNicBaseDSCProperties

    $vmHostNetworkAdapterMock = $script:vmHostNetworkAdapter

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmHostNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $PortGroup -eq $script:constants.VirtualPortGroupName -and $VirtualSwitch -eq $script:virtualSwitch -and $VMHost -eq $script:vmHost -and $VMKernel } -Verifiable
    Mock -CommandName Set-VMHostNetworkAdapter -MockWith { throw }.GetNewClosure() -Verifiable

    $vmHostNetworkAdapterBaseDSCProperties
}

function New-MocksWhenUpdatingVMKernelNetworkAdapterWithoutDhcpAndIPv6Enabled {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostNetworkAdapterBaseDSCProperties = New-VMHostNicBaseDSCProperties

    $vmHostNetworkAdapterBaseDSCProperties.Mac = $vmHostNetworkAdapterBaseDSCProperties.Mac + $vmHostNetworkAdapterBaseDSCProperties.Mac
    $vmHostNetworkAdapterBaseDSCProperties.ManagementTrafficEnabled = $false

    $vmHostNetworkAdapterMock = $script:vmHostNetworkAdapter

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmHostNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $PortGroup -eq $script:constants.VirtualPortGroupName -and $VirtualSwitch -eq $script:virtualSwitch -and $VMHost -eq $script:vmHost -and $VMKernel } -Verifiable
    Mock -CommandName Set-VMHostNetworkAdapter -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostNetworkAdapterBaseDSCProperties
}

function New-MocksWhenUpdatingVMKernelNetworkAdapterWithDhcpAndIPv6Enabled {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostNetworkAdapterBaseDSCProperties = New-VMHostNicBaseDSCProperties

    $vmHostNetworkAdapterBaseDSCProperties.Dhcp = !($script:constants.VMKernelNetworkAdapterDhcp)
    $vmHostNetworkAdapterBaseDSCProperties.IPv6Enabled = !($script:constants.VMKernelNetworkAdapterIPv6Enabled)

    $vmHostNetworkAdapterMock = $script:vmHostNetworkAdapter

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmHostNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $PortGroup -eq $script:constants.VirtualPortGroupName -and $VirtualSwitch -eq $script:virtualSwitch -and $VMHost -eq $script:vmHost -and $VMKernel } -Verifiable
    Mock -CommandName Set-VMHostNetworkAdapter -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostNetworkAdapterBaseDSCProperties
}

function New-MocksWhenRemovingVMKernelNetworkAdapterResultsInAnError {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostNetworkAdapterBaseDSCProperties = New-VMHostNicBaseDSCProperties

    $vmHostNetworkAdapterMock = $script:vmHostNetworkAdapter

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmHostNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $PortGroup -eq $script:constants.VirtualPortGroupName -and $VirtualSwitch -eq $script:virtualSwitch -and $VMHost -eq $script:vmHost -and $VMKernel } -Verifiable
    Mock -CommandName Remove-VMHostNetworkAdapter -MockWith { throw }.GetNewClosure() -Verifiable

    $vmHostNetworkAdapterBaseDSCProperties
}

function New-MocksWhenRemovingVMKernelNetworkAdapter {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostNetworkAdapterBaseDSCProperties = New-VMHostNicBaseDSCProperties

    $vmHostNetworkAdapterMock = $script:vmHostNetworkAdapter

    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmHostNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $PortGroup -eq $script:constants.VirtualPortGroupName -and $VirtualSwitch -eq $script:virtualSwitch -and $VMHost -eq $script:vmHost -and $VMKernel } -Verifiable
    Mock -CommandName Remove-VMHostNetworkAdapter -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostNetworkAdapterBaseDSCProperties
}
