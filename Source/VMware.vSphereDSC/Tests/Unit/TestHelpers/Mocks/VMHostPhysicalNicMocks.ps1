<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-VMHostPhysicalNicProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostPhysicalNicProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        VMHostName = $script:constants.VMHostName
        Name = $script:constants.PhysicalNetworkAdapterName
    }

    $vmHostPhysicalNicProperties
}

function New-MocksForVMHostPhysicalNic {
    [CmdletBinding()]

    $viServerMock = $script:viServer
    $vmHostMock = $script:vmHost
    $physicalNetworkAdapterMock = $script:physicalNetworkAdapter

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.PhysicalNetworkAdapterName -and $VMHost -eq $script:vmHost -and $Physical } -Verifiable
}

function New-MocksWhenAutoNegotiateIsNotPassed {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostPhysicalNicProperties = New-VMHostPhysicalNicProperties

    $vmHostPhysicalNicProperties.Duplex = $script:constants.FullDuplex
    $vmHostPhysicalNicProperties.BitRatePerSecMb = $script:constants.BitRatePerSecMb

    Mock -CommandName Set-VMHostNetworkAdapter -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostPhysicalNicProperties
}

function New-MocksWhenAutoNegotiateIsSetToFalse {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostPhysicalNicProperties = New-VMHostPhysicalNicProperties

    $vmHostPhysicalNicProperties.Duplex = $script:constants.FullDuplex
    $vmHostPhysicalNicProperties.BitRatePerSecMb = $script:constants.BitRatePerSecMb
    $vmHostPhysicalNicProperties.AutoNegotiate = !$script:constants.AutoNegotiate

    Mock -CommandName Set-VMHostNetworkAdapter -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostPhysicalNicProperties
}

function New-MocksWhenAutoNegotiateIsSetToTrue {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostPhysicalNicProperties = New-VMHostPhysicalNicProperties

    $vmHostPhysicalNicProperties.Duplex = $script:constants.FullDuplex
    $vmHostPhysicalNicProperties.BitRatePerSecMb = $script:constants.BitRatePerSecMb
    $vmHostPhysicalNicProperties.AutoNegotiate = $script:constants.AutoNegotiate

    Mock -CommandName Set-VMHostNetworkAdapter -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostPhysicalNicProperties
}

function New-MocksWhenThePhysicalNetworkAdapterIsWithFullDuplex {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostPhysicalNicProperties = New-VMHostPhysicalNicProperties

    $vmHostPhysicalNicProperties.Duplex = $script:constants.HalfDuplex

    $vmHostPhysicalNicProperties
}

function New-MocksWhenThePhysicalNetworkAdapterIsWithHalfDuplex {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostPhysicalNicProperties = New-VMHostPhysicalNicProperties

    $vmHostPhysicalNicProperties.Duplex = $script:constants.FullDuplex

    $vmHostPhysicalNicProperties
}

function New-MocksInTestWhenAutoNegotiateIsSetToFalse {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostPhysicalNicProperties = New-VMHostPhysicalNicProperties

    $vmHostPhysicalNicProperties.Duplex = $script:constants.FullDuplex
    $vmHostPhysicalNicProperties.BitRatePerSecMb = $script:constants.BitRatePerSecMb
    $vmHostPhysicalNicProperties.AutoNegotiate = !$script:constants.AutoNegotiate

    $vmHostPhysicalNicProperties
}

function New-MocksInTestWhenAutoNegotiateIsSetToTrue {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostPhysicalNicProperties = New-VMHostPhysicalNicProperties

    $vmHostPhysicalNicProperties.Duplex = $script:constants.FullDuplex
    $vmHostPhysicalNicProperties.BitRatePerSecMb = $script:constants.BitRatePerSecMb
    $vmHostPhysicalNicProperties.AutoNegotiate = $script:constants.AutoNegotiate

    $vmHostPhysicalNicProperties
}
