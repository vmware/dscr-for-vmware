<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-VMHostIScsiHbaVMKernelNicDscResourceProperties {
    [OutputType([System.Collections.Hashtable])]

    $VMHostIScsiHbaVMKernelNicDscResourceProperties = @{
        Server = $script:Constants.VIServer
        Credential = $script:Credential
        VMHostName = $script:Constants.VMHostName
        IScsiHbaName = $script:Constants.IScsiHbaDeviceName
    }

    $VMHostIScsiHbaVMKernelNicDscResourceProperties
}

function New-MocksForVMHostIScsiHbaVMKernelNicDscResource {
    $viServerMock = $script:VIServer
    $vmHostMock = $script:VMHost
    $esxCliMock = $script:EsxCli
    $iScsiHbaMock = $script:IScsiHba

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable
    Mock -CommandName Disconnect-VIServer -MockWith { return $null }.GetNewClosure() -Verifiable

    $getEsxCliMockParams = @{
        CommandName = 'Get-EsxCli'
        MockWith = { return $esxCliMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $VMHost -eq $script:VMHost -and
            $V2 -eq $true
        }
        Verifiable = $true
    }
    Mock @getEsxCliMockParams

    $getVMHostHbaMockParams = @{
        CommandName = 'Get-VMHostHba'
        MockWith = { return $iScsiHbaMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $VMHost -eq $script:VMHost -and
            $Device -eq $script:Constants.IScsiHbaDeviceName -and
            $Type -eq $script:Constants.IScsiDeviceType
        }
        Verifiable = $true
    }
    Mock @getVMHostHbaMockParams
}

function New-MocksWhenEnsureIsPresentAndTwoVMKernelNetworkAdaptersArePassedOneBoundAndOneUnbound {
    [OutputType([System.Collections.Hashtable])]

    $vmHostIScsiHbaVMKernelNicDscResourceProperties = New-VMHostIScsiHbaVMKernelNicDscResourceProperties
    $vmHostIScsiHbaVMKernelNicDscResourceProperties.VMKernelNicNames = @($script:Constants.BoundVMKernelNicName, $script:Constants.UnboundVMKernelNicName)
    $vmHostIScsiHbaVMKernelNicDscResourceProperties.Ensure = 'Present'

    $vmKernelNicsMock = @($script:BoundVMKernelNic, $script:UnboundVMKernelNic)
    $bindedVMKernelNicsMock = @($script:EsxCliBoundVMKernelNic)

    $getVMHostNetworkAdapterMockParams = @{
        CommandName = 'Get-VMHostNetworkAdapter'
        MockWith = { return $vmKernelNicsMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $VMHost -eq $script:VMHost -and
            $VMKernel -eq $true
        }
        Verifiable = $true
    }
    Mock @getVMHostNetworkAdapterMockParams

    $getIScsiHbaBoundNicsMockParams = @{
        CommandName = 'Get-IScsiHbaBoundNics'
        MockWith = { return $bindedVMKernelNicsMock }.GetNewClosure()
        ParameterFilter = {
            $EsxCli -eq $script:EsxCli -and
            $IScsiHbaName -eq $script:IScsiHba.Device
        }
        Verifiable = $true
    }
    Mock @getIScsiHbaBoundNicsMockParams

    Mock -CommandName 'Update-IScsiHbaBoundNics' -MockWith { return $null }.GetNewClosure()

    $vmHostIScsiHbaVMKernelNicDscResourceProperties
}

function New-MocksWhenEnsureIsAbsentAndTwoVMKernelNetworkAdaptersArePassedOneBoundAndOneUnbound {
    [OutputType([System.Collections.Hashtable])]

    $vmHostIScsiHbaVMKernelNicDscResourceProperties = New-VMHostIScsiHbaVMKernelNicDscResourceProperties
    $vmHostIScsiHbaVMKernelNicDscResourceProperties.VMKernelNicNames = @($script:Constants.BoundVMKernelNicName, $script:Constants.UnboundVMKernelNicName)
    $vmHostIScsiHbaVMKernelNicDscResourceProperties.Ensure = 'Absent'
    $vmHostIScsiHbaVMKernelNicDscResourceProperties.Force = $true

    $vmKernelNicsMock = @($script:BoundVMKernelNic, $script:UnboundVMKernelNic)
    $bindedVMKernelNicsMock = @($script:EsxCliBoundVMKernelNic)

    $getVMHostNetworkAdapterMockParams = @{
        CommandName = 'Get-VMHostNetworkAdapter'
        MockWith = { return $vmKernelNicsMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $VMHost -eq $script:VMHost -and
            $VMKernel -eq $true
        }
        Verifiable = $true
    }
    Mock @getVMHostNetworkAdapterMockParams

    $getIScsiHbaBoundNicsMockParams = @{
        CommandName = 'Get-IScsiHbaBoundNics'
        MockWith = { return $bindedVMKernelNicsMock }.GetNewClosure()
        ParameterFilter = {
            $EsxCli -eq $script:EsxCli -and
            $IScsiHbaName -eq $script:IScsiHba.Device
        }
        Verifiable = $true
    }
    Mock @getIScsiHbaBoundNicsMockParams

    Mock -CommandName 'Update-IScsiHbaBoundNics' -MockWith { return $null }.GetNewClosure()

    $vmHostIScsiHbaVMKernelNicDscResourceProperties
}

function New-MocksWhenEnsureIsPresentAndOneBoundVMKernelNetworkAdapterIsPassed {
    [OutputType([System.Collections.Hashtable])]

    $vmHostIScsiHbaVMKernelNicDscResourceProperties = New-VMHostIScsiHbaVMKernelNicDscResourceProperties
    $vmHostIScsiHbaVMKernelNicDscResourceProperties.VMKernelNicNames = @($script:Constants.BoundVMKernelNicName)
    $vmHostIScsiHbaVMKernelNicDscResourceProperties.Ensure = 'Present'

    $vmKernelNicsMock = @($script:BoundVMKernelNic)
    $bindedVMKernelNicsMock = @($script:EsxCliBoundVMKernelNic)

    $getVMHostNetworkAdapterMockParams = @{
        CommandName = 'Get-VMHostNetworkAdapter'
        MockWith = { return $vmKernelNicsMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $VMHost -eq $script:VMHost -and
            $VMKernel -eq $true
        }
        Verifiable = $true
    }
    Mock @getVMHostNetworkAdapterMockParams

    $getIScsiHbaBoundNicsMockParams = @{
        CommandName = 'Get-IScsiHbaBoundNics'
        MockWith = { return $bindedVMKernelNicsMock }.GetNewClosure()
        ParameterFilter = {
            $EsxCli -eq $script:EsxCli -and
            $IScsiHbaName -eq $script:IScsiHba.Device
        }
        Verifiable = $true
    }
    Mock @getIScsiHbaBoundNicsMockParams

    $vmHostIScsiHbaVMKernelNicDscResourceProperties
}

function New-MocksWhenEnsureIsAbsentAndOneUnboundVMKernelNetworkAdapterIsPassed {
    [OutputType([System.Collections.Hashtable])]

    $vmHostIScsiHbaVMKernelNicDscResourceProperties = New-VMHostIScsiHbaVMKernelNicDscResourceProperties
    $vmHostIScsiHbaVMKernelNicDscResourceProperties.VMKernelNicNames = @($script:Constants.UnboundVMKernelNicName)
    $vmHostIScsiHbaVMKernelNicDscResourceProperties.Ensure = 'Absent'

    $vmKernelNicsMock = @($script:UnboundVMKernelNic)
    $bindedVMKernelNicsMock = @($script:EsxCliBoundVMKernelNic)

    $getVMHostNetworkAdapterMockParams = @{
        CommandName = 'Get-VMHostNetworkAdapter'
        MockWith = { return $vmKernelNicsMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $VMHost -eq $script:VMHost -and
            $VMKernel -eq $true
        }
        Verifiable = $true
    }
    Mock @getVMHostNetworkAdapterMockParams

    $getIScsiHbaBoundNicsMockParams = @{
        CommandName = 'Get-IScsiHbaBoundNics'
        MockWith = { return $bindedVMKernelNicsMock }.GetNewClosure()
        ParameterFilter = {
            $EsxCli -eq $script:EsxCli -and
            $IScsiHbaName -eq $script:IScsiHba.Device
        }
        Verifiable = $true
    }
    Mock @getIScsiHbaBoundNicsMockParams

    $vmHostIScsiHbaVMKernelNicDscResourceProperties
}

function New-MocksWhenIScsiHostBusAdapterWithoutBoundVMKernelNetworkAdaptersIsPassed {
    [OutputType([System.Collections.Hashtable])]

    $vmHostIScsiHbaVMKernelNicDscResourceProperties = New-VMHostIScsiHbaVMKernelNicDscResourceProperties
    $vmHostIScsiHbaVMKernelNicDscResourceProperties.VMKernelNicNames = @($script:Constants.BoundVMKernelNicName, $script:Constants.UnboundVMKernelNicName)
    $vmHostIScsiHbaVMKernelNicDscResourceProperties.Ensure = 'Present'

    $bindedVMKernelNicsMock = @()

    $getIScsiHbaBoundNicsMockParams = @{
        CommandName = 'Get-IScsiHbaBoundNics'
        MockWith = { return $bindedVMKernelNicsMock }.GetNewClosure()
        ParameterFilter = {
            $EsxCli -eq $script:EsxCli -and
            $IScsiHbaName -eq $script:IScsiHba.Device
        }
        Verifiable = $true
    }
    Mock @getIScsiHbaBoundNicsMockParams

    $vmHostIScsiHbaVMKernelNicDscResourceProperties
}

function New-MocksWhenIScsiHostBusAdapterWithBoundVMKernelNetworkAdaptersIsPassed {
    [OutputType([System.Collections.Hashtable])]

    $vmHostIScsiHbaVMKernelNicDscResourceProperties = New-VMHostIScsiHbaVMKernelNicDscResourceProperties
    $vmHostIScsiHbaVMKernelNicDscResourceProperties.VMKernelNicNames = @($script:Constants.BoundVMKernelNicName, $script:Constants.UnboundVMKernelNicName)
    $vmHostIScsiHbaVMKernelNicDscResourceProperties.Ensure = 'Absent'
    $vmHostIScsiHbaVMKernelNicDscResourceProperties.Force = $false

    $bindedVMKernelNicsMock = @($script:EsxCliBoundVMKernelNic)

    $getIScsiHbaBoundNicsMockParams = @{
        CommandName = 'Get-IScsiHbaBoundNics'
        MockWith = { return $bindedVMKernelNicsMock }.GetNewClosure()
        ParameterFilter = {
            $EsxCli -eq $script:EsxCli -and
            $IScsiHbaName -eq $script:IScsiHba.Device
        }
        Verifiable = $true
    }
    Mock @getIScsiHbaBoundNicsMockParams

    $vmHostIScsiHbaVMKernelNicDscResourceProperties
}
