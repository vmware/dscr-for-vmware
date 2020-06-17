<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-VMHostVdsNicDscResourceProperties {
    [OutputType([System.Collections.Hashtable])]

    $VMHostVdsNicDscResourceProperties = @{
        Server = $script:Constants.VIServer
        Credential = $script:Credential
        Name = $script:Constants.VMKernelNICName
        VMHostName = $script:Constants.VMHostName
        VdsName = $script:Constants.VDSwitchName
        PortGroupName = $script:Constants.DistributedPortGroupName
        IP = $script:Constants.IP
        SubnetMask = $script:Constants.SubnetMask
        VMotionEnabled = $script:Constants.VMotionEnabled
    }

    $VMHostVdsNicDscResourceProperties
}

function New-MocksForVMHostVdsNicDscResource {
    $viServerMock = $script:VIServer
    $vmHostMock = $script:VMHost
    $vdSwitchMock = $script:VDSwitch

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable
    Mock -CommandName Disconnect-VIServer -MockWith { return $null }.GetNewClosure() -Verifiable

    $getVDSwitchMockParams = @{
        CommandName = 'Get-VDSwitch'
        MockWith = { return $vdSwitchMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $Name -eq $script:Constants.VDSwitchName
        }
        Verifiable = $true
    }
    Mock @getVDSwitchMockParams
}

function New-MocksInSetWhenEnsureIsPresentAndTheVMKernelNICExists {
    [OutputType([System.Collections.Hashtable])]

    $VMHostVdsNicDscResourceProperties = New-VMHostVdsNicDscResourceProperties
    $VMHostVdsNicDscResourceProperties.Ensure = 'Present'

    $vmKernelNICMock = $script:VMKernelNIC

    $getVMHostNetworkAdapterMockParams = @{
        CommandName = 'Get-VMHostNetworkAdapter'
        MockWith = { return $vmKernelNICMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $VMHost -eq $script:VMHost -and
            $Name -eq $script:Constants.VMKernelNICName -and
            $VirtualSwitch -eq $script:VDSwitch -and
            $PortGroup -eq $script:Constants.DistributedPortGroupName -and
            $VMKernel -eq $true
        }
        Verifiable = $true
    }
    Mock @getVMHostNetworkAdapterMockParams

    Mock -CommandName 'Set-VMHostNetworkAdapter' -MockWith { return $null }.GetNewClosure() -Verifiable

    $VMHostVdsNicDscResourceProperties
}

function New-MocksInSetWhenEnsureIsAbsentAndTheVMKernelNICDoesNotExist {
    [OutputType([System.Collections.Hashtable])]

    $VMHostVdsNicDscResourceProperties = New-VMHostVdsNicDscResourceProperties
    $VMHostVdsNicDscResourceProperties.Ensure = 'Absent'

    $getVMHostNetworkAdapterMockParams = @{
        CommandName = 'Get-VMHostNetworkAdapter'
        MockWith = { return $null }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $VMHost -eq $script:VMHost -and
            $Name -eq $script:Constants.VMKernelNICName -and
            $VirtualSwitch -eq $script:VDSwitch -and
            $PortGroup -eq $script:Constants.DistributedPortGroupName -and
            $VMKernel -eq $true
        }
        Verifiable = $true
    }
    Mock @getVMHostNetworkAdapterMockParams

    Mock -CommandName 'Remove-VMHostNetworkAdapter' -MockWith { return $null }.GetNewClosure()

    $VMHostVdsNicDscResourceProperties
}

function New-MocksInSetWhenEnsureIsAbsentAndTheVMKernelNICExists {
    [OutputType([System.Collections.Hashtable])]

    $VMHostVdsNicDscResourceProperties = New-VMHostVdsNicDscResourceProperties
    $VMHostVdsNicDscResourceProperties.Ensure = 'Absent'

    $vmKernelNICMock = $script:VMKernelNIC

    $getVMHostNetworkAdapterMockParams = @{
        CommandName = 'Get-VMHostNetworkAdapter'
        MockWith = { return $vmKernelNICMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $VMHost -eq $script:VMHost -and
            $Name -eq $script:Constants.VMKernelNICName -and
            $VirtualSwitch -eq $script:VDSwitch -and
            $PortGroup -eq $script:Constants.DistributedPortGroupName -and
            $VMKernel -eq $true
        }
        Verifiable = $true
    }
    Mock @getVMHostNetworkAdapterMockParams

    Mock -CommandName 'Remove-VMHostNetworkAdapter' -MockWith { return $null }.GetNewClosure() -Verifiable

    $VMHostVdsNicDscResourceProperties
}

function New-MocksWhenEnsureIsPresentTheVMKernelNICExistsAndTheVMKernelNICSettingsShouldNotBeModified {
    [OutputType([System.Collections.Hashtable])]

    $VMHostVdsNicDscResourceProperties = New-VMHostVdsNicDscResourceProperties
    $VMHostVdsNicDscResourceProperties.Ensure = 'Present'

    $vmKernelNICMock = $script:VMKernelNIC

    $getVMHostNetworkAdapterMockParams = @{
        CommandName = 'Get-VMHostNetworkAdapter'
        MockWith = { return $vmKernelNICMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $VMHost -eq $script:VMHost -and
            $Name -eq $script:Constants.VMKernelNICName -and
            $VirtualSwitch -eq $script:VDSwitch -and
            $PortGroup -eq $script:Constants.DistributedPortGroupName -and
            $VMKernel -eq $true
        }
        Verifiable = $true
    }
    Mock @getVMHostNetworkAdapterMockParams

    $VMHostVdsNicDscResourceProperties
}

function New-MocksWhenEnsureIsPresentTheVMKernelNICExistsAndTheVMKernelNICSettingsShouldBeModified {
    [OutputType([System.Collections.Hashtable])]

    $VMHostVdsNicDscResourceProperties = New-VMHostVdsNicDscResourceProperties

    $VMHostVdsNicDscResourceProperties.Ensure = 'Present'
    $VMHostVdsNicDscResourceProperties.ManagementTrafficEnabled = $script:Constants.ManagementTrafficEnabled

    $vmKernelNICMock = $script:VMKernelNIC

    $getVMHostNetworkAdapterMockParams = @{
        CommandName = 'Get-VMHostNetworkAdapter'
        MockWith = { return $vmKernelNICMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $VMHost -eq $script:VMHost -and
            $Name -eq $script:Constants.VMKernelNICName -and
            $VirtualSwitch -eq $script:VDSwitch -and
            $PortGroup -eq $script:Constants.DistributedPortGroupName -and
            $VMKernel -eq $true
        }
        Verifiable = $true
    }
    Mock @getVMHostNetworkAdapterMockParams

    $VMHostVdsNicDscResourceProperties
}

function New-MocksWhenEnsureIsAbsentAndTheVMKernelNICDoesNotExist {
    [OutputType([System.Collections.Hashtable])]

    $VMHostVdsNicDscResourceProperties = New-VMHostVdsNicDscResourceProperties
    $VMHostVdsNicDscResourceProperties.Ensure = 'Absent'

    $getVMHostNetworkAdapterMockParams = @{
        CommandName = 'Get-VMHostNetworkAdapter'
        MockWith = { return $null }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $VMHost -eq $script:VMHost -and
            $Name -eq $script:Constants.VMKernelNICName -and
            $VirtualSwitch -eq $script:VDSwitch -and
            $PortGroup -eq $script:Constants.DistributedPortGroupName -and
            $VMKernel -eq $true
        }
        Verifiable = $true
    }
    Mock @getVMHostNetworkAdapterMockParams

    $VMHostVdsNicDscResourceProperties
}

function New-MocksWhenEnsureIsAbsentAndTheVMKernelNICExists {
    [OutputType([System.Collections.Hashtable])]

    $VMHostVdsNicDscResourceProperties = New-VMHostVdsNicDscResourceProperties
    $VMHostVdsNicDscResourceProperties.Ensure = 'Absent'

    $vmKernelNICMock = $script:VMKernelNIC

    $getVMHostNetworkAdapterMockParams = @{
        CommandName = 'Get-VMHostNetworkAdapter'
        MockWith = { return $vmKernelNICMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $VMHost -eq $script:VMHost -and
            $Name -eq $script:Constants.VMKernelNICName -and
            $VirtualSwitch -eq $script:VDSwitch -and
            $PortGroup -eq $script:Constants.DistributedPortGroupName -and
            $VMKernel -eq $true
        }
        Verifiable = $true
    }
    Mock @getVMHostNetworkAdapterMockParams

    $VMHostVdsNicDscResourceProperties
}
