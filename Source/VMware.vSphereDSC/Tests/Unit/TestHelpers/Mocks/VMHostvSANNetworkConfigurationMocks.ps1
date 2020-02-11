<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-VMHostvSANNetworkConfigurationProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostvSANNetworkConfigurationProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        Name = $script:constants.VMHostName
    }

    $vmHostvSANNetworkConfigurationProperties
}

function New-MocksInSetForVMHostvSANNetworkConfiguration {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostvSANNetworkConfigurationProperties = New-VMHostvSANNetworkConfigurationProperties

    $vmHostvSANNetworkConfigurationProperties.InterfaceName = $script:constants.VMHostvSanNetworkConfigurationInterfaceOneName
    $vmHostvSANNetworkConfigurationProperties.Ensure = 'Present'

    $viServerMock = $script:viServer
    $vmHostMock = $script:vmHost
    $esxCliMock = $script:esxCli
    $esxCliSetMethodArgsMock = $script:constants.EsxCliSetMethodArgs

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-EsxCli -MockWith { return $esxCliMock }.GetNewClosure() -Verifiable
    Mock -CommandName Invoke-Expression -MockWith { return $esxCliSetMethodArgsMock }.GetNewClosure() -Verifiable
    Mock -CommandName Invoke-EsxCliCommandMethod -MockWith { return $null }.GetNewClosure() -Verifiable
    Mock -CommandName Disconnect-VIServer -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostvSANNetworkConfigurationProperties
}

function New-MocksForVMHostvSANNetworkConfiguration {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostvSANNetworkConfigurationProperties = New-VMHostvSANNetworkConfigurationProperties

    $viServerMock = $script:viServer
    $vmHostMock = $script:vmHost
    $esxCliMock = $script:esxCli
    $esxCliListMethodMock = $script:vmHostvSanNetworkConfigurationIPInterface

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-EsxCli -MockWith { return $esxCliMock }.GetNewClosure() -Verifiable
    Mock -CommandName Invoke-Expression -MockWith { return $esxCliListMethodMock }.GetNewClosure() -Verifiable
    Mock -CommandName Disconnect-VIServer -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostvSANNetworkConfigurationProperties
}

function New-MocksWhenTheVMHostvSANNetworkConfigurationIPInterfaceDoesNotExistAndEnsureIsPresent {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostvSANNetworkConfigurationProperties = New-VMHostvSANNetworkConfigurationProperties

    $vmHostvSANNetworkConfigurationProperties.InterfaceName = $script:constants.VMHostvSanNetworkConfigurationInterfaceTwoName
    $vmHostvSANNetworkConfigurationProperties.AgentV6McAddr = $script:constants.VMHostvSanNetworkConfigurationAgentGroupIPv6MulticastAddress
    $vmHostvSANNetworkConfigurationProperties.AgentMcAddr = $script:constants.VMHostvSanNetworkConfigurationAgentGroupMulticastAddress
    $vmHostvSANNetworkConfigurationProperties.AgentMcPort = $script:constants.VMHostvSanNetworkConfigurationAgentGroupMulticastPort
    $vmHostvSANNetworkConfigurationProperties.HostUcPort = $script:constants.VMHostvSanNetworkConfigurationHostUnicastChannelBoundPort
    $vmHostvSANNetworkConfigurationProperties.MasterV6McAddr = $script:constants.VMHostvSanNetworkConfigurationMasterGroupIPv6MulticastAddress
    $vmHostvSANNetworkConfigurationProperties.MasterMcAddr = $script:constants.VMHostvSanNetworkConfigurationMasterGroupMulticastAddress
    $vmHostvSANNetworkConfigurationProperties.MasterMcPort = $script:constants.VMHostvSanNetworkConfigurationMasterGroupMulticastPort
    $vmHostvSANNetworkConfigurationProperties.MulticastTtl = $script:constants.VMHostvSanNetworkConfigurationMulticastTTL
    $vmHostvSANNetworkConfigurationProperties.TrafficType = $script:constants.VMHostvSanNetworkConfigurationTrafficType
    $vmHostvSANNetworkConfigurationProperties.Ensure = 'Present'

    $vmHostvSANNetworkConfigurationProperties
}

function New-MocksWhenTheVMHostvSANNetworkConfigurationIPInterfaceExistsAndEnsureIsPresent {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostvSANNetworkConfigurationProperties = New-VMHostvSANNetworkConfigurationProperties

    $vmHostvSANNetworkConfigurationProperties.InterfaceName = $script:constants.VMHostvSanNetworkConfigurationInterfaceOneName
    $vmHostvSANNetworkConfigurationProperties.Ensure = 'Present'

    $vmHostvSANNetworkConfigurationProperties
}

function New-MocksWhenTheVMHostvSANNetworkConfigurationIPInterfaceDoesNotExistAndEnsureIsAbsent {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostvSANNetworkConfigurationProperties = New-VMHostvSANNetworkConfigurationProperties

    $vmHostvSANNetworkConfigurationProperties.InterfaceName = $script:constants.VMHostvSanNetworkConfigurationInterfaceTwoName
    $vmHostvSANNetworkConfigurationProperties.AgentV6McAddr = $script:constants.VMHostvSanNetworkConfigurationAgentGroupIPv6MulticastAddress
    $vmHostvSANNetworkConfigurationProperties.AgentMcAddr = $script:constants.VMHostvSanNetworkConfigurationAgentGroupMulticastAddress
    $vmHostvSANNetworkConfigurationProperties.AgentMcPort = $script:constants.VMHostvSanNetworkConfigurationAgentGroupMulticastPort
    $vmHostvSANNetworkConfigurationProperties.HostUcPort = $script:constants.VMHostvSanNetworkConfigurationHostUnicastChannelBoundPort
    $vmHostvSANNetworkConfigurationProperties.MasterV6McAddr = $script:constants.VMHostvSanNetworkConfigurationMasterGroupIPv6MulticastAddress
    $vmHostvSANNetworkConfigurationProperties.MasterMcAddr = $script:constants.VMHostvSanNetworkConfigurationMasterGroupMulticastAddress
    $vmHostvSANNetworkConfigurationProperties.MasterMcPort = $script:constants.VMHostvSanNetworkConfigurationMasterGroupMulticastPort
    $vmHostvSANNetworkConfigurationProperties.MulticastTtl = $script:constants.VMHostvSanNetworkConfigurationMulticastTTL
    $vmHostvSANNetworkConfigurationProperties.TrafficType = $script:constants.VMHostvSanNetworkConfigurationTrafficType
    $vmHostvSANNetworkConfigurationProperties.Ensure = 'Absent'

    $vmHostvSANNetworkConfigurationProperties
}

function New-MocksWhenTheVMHostvSANNetworkConfigurationIPInterfaceExistsAndEnsureIsAbsent {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostvSANNetworkConfigurationProperties = New-VMHostvSANNetworkConfigurationProperties

    $vmHostvSANNetworkConfigurationProperties.InterfaceName = $script:constants.VMHostvSanNetworkConfigurationInterfaceOneName
    $vmHostvSANNetworkConfigurationProperties.Ensure = 'Absent'

    $vmHostvSANNetworkConfigurationProperties
}
