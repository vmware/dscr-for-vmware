<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

[DscResource()]
class VMHostvSANNetworkConfiguration : EsxCliBaseDSC {
    VMHostvSANNetworkConfiguration() {
        $this.EsxCliCommand = 'vsan.network.ip'
    }

    <#
    .DESCRIPTION

    Specifies the name of the interface.
    #>
    [DscProperty(Key)]
    [string] $InterfaceName

    <#
    .DESCRIPTION

    Specifies whether the IP interface of the vSAN network configuration should be present or absent.
    #>
    [DscProperty(Mandatory = $true)]
    [Ensure] $Ensure

    <#
    .DESCRIPTION

    Specifies the IPv4 multicast address for the agent group.
    #>
    [DscProperty()]
    [string] $AgentMcAddr

    <#
    .DESCRIPTION

    Specifies the IPv6 multicast address for the agent group.
    #>
    [DscProperty()]
    [string] $AgentV6McAddr

    <#
    .DESCRIPTION

    Specifies the multicast address port for the agent group.
    #>
    [DscProperty()]
    [nullable[long]] $AgentMcPort

    <#
    .DESCRIPTION

    Specifies the unicast address port for the VMHost unicast channel.
    #>
    [DscProperty()]
    [nullable[long]] $HostUcPort

    <#
    .DESCRIPTION

    Specifies the IPv4 multicast address for the master group.
    #>
    [DscProperty()]
    [string] $MasterMcAddr

    <#
    .DESCRIPTION

    Specifies the IPv6 multicast address for the master group.
    #>
    [DscProperty()]
    [string] $MasterV6McAddr

    <#
    .DESCRIPTION

    Specifies the multicast address port for the master group.
    #>
    [DscProperty()]
    [nullable[long]] $MasterMcPort

    <#
    .DESCRIPTION

    Specifies the time-to-live for multicast packets.
    #>
    [DscProperty()]
    [nullable[long]] $MulticastTtl

    <#
    .DESCRIPTION

    Specifies the network transmission type of the vSAN traffic through a virtual network adapter. Supported values are vsan and witness. Type 'vsan' means general vSAN transmission, which is used for both
    data and witness transmission, if there is no virtual adapter configured with 'witness' traffic type; Type 'witness' indicates that, vSAN vmknic is used for vSAN witness transmission.
    Once a virtual adapter is configured with 'witness' traffic type, vSAN witness data transmission will stop using virtual adapter with 'vsan' traffic type, and use first dicovered virtual adapter with 'witness' traffic type.
    Multiple traffic types can be provided in format -T type1 -T type2. Default value is 'vsan', if the property is not specified.
    #>
    [DscProperty()]
    [string[]] $TrafficType

    <#
    .DESCRIPTION

    Specifies whether to notify vSAN subsystem of the removal of the IP Interface, even if is not configured.
    #>
    [DscProperty()]
    [nullable[bool]] $Force

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            $vSanNetworkConfigurationIPInterface = $this.GetvSanNetworkConfigurationIPInterface()
            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $vSanNetworkConfigurationIPInterface) {
                    $this.ExecuteEsxCliModifyMethod($this.EsxCliAddMethodName)
                }
            }
            else {
                if ($null -ne $vSanNetworkConfigurationIPInterface) {
                    $this.ExecuteEsxCliModifyMethod($this.EsxCliRemoveMethodName)
                }
            }
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.SetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [bool] Test() {
        try {
            Write-VerboseLog -Message $this.TestMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            $result = $this.IsvSanNetworkConfigurationIPInterfaceInDesiredState()

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [VMHostvSANNetworkConfiguration] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [VMHostvSANNetworkConfiguration]::new()

            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            $this.PopulateResult($result, $vmHost)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the IP interface with the specified name of the vSAN network configuration.
    #>
    [PSObject] GetvSanNetworkConfigurationIPInterface() {
        <#
        The 'list' method of the command is not on the same element as the 'add' and 'remove' methods. So the different methods
        need to be executed with different commands.
        #>
        $initialEsxCliCommand = $this.EsxCliCommand
        $this.EsxCliCommand = 'vsan.network'

        $esxCliListMethodResult = $this.ExecuteEsxCliRetrievalMethod($this.EsxCliListMethodName)

        # The command needs to be restored to its initial value, so that it can be used by the 'add' and 'remove' methods.
        $this.EsxCliCommand = $initialEsxCliCommand

        return ($esxCliListMethodResult | Where-Object -FilterScript { $_.VmkNicName -eq $this.InterfaceName })
    }

    <#
    .DESCRIPTION

    Checks if the vSan network configuration IP interface is in a Desired State depending on the value of the 'Ensure' property.
    #>
    [bool] IsvSanNetworkConfigurationIPInterfaceInDesiredState() {
        $vSanNetworkConfigurationIPInterface = $this.GetvSanNetworkConfigurationIPInterface()

        $result = $false
        if ($this.Ensure -eq [Ensure]::Present) {
            $result = ($null -ne $vSanNetworkConfigurationIPInterface)
        }
        else {
            $result = ($null -eq $vSanNetworkConfigurationIPInterface)
        }

        return $result
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $vmHost) {
        $result.Server = $this.Connection.Name
        $result.Name = $vmHost.Name
        $result.Force = $this.Force

        $vSanNetworkConfigurationIPInterface = $this.GetvSanNetworkConfigurationIPInterface()
        if ($null -ne $vSanNetworkConfigurationIPInterface) {
            $result.InterfaceName = $vSanNetworkConfigurationIPInterface.VmkNicName
            $result.AgentMcAddr = $vSanNetworkConfigurationIPInterface.AgentGroupMulticastAddress
            $result.AgentMcPort = [long] $vSanNetworkConfigurationIPInterface.AgentGroupMulticastPort
            $result.AgentV6McAddr = $vSanNetworkConfigurationIPInterface.AgentGroupIPv6MulticastAddress
            $result.HostUcPort = [long] $vSanNetworkConfigurationIPInterface.HostUnicastChannelBoundPort
            $result.MasterMcAddr = $vSanNetworkConfigurationIPInterface.MasterGroupMulticastAddress
            $result.MasterMcPort = [long] $vSanNetworkConfigurationIPInterface.MasterGroupMulticastPort
            $result.MasterV6McAddr = $vSanNetworkConfigurationIPInterface.MasterGroupIPv6MulticastAddress
            $result.MulticastTtl = [long] $vSanNetworkConfigurationIPInterface.MulticastTTL
            $result.TrafficType = $vSanNetworkConfigurationIPInterface.TrafficType
            $result.Ensure = [Ensure]::Present
        }
        else {
            $result.InterfaceName = $this.InterfaceName
            $result.AgentMcAddr = $this.AgentMcAddr
            $result.AgentMcPort = $this.AgentMcPort
            $result.AgentV6McAddr = $this.AgentV6McAddr
            $result.HostUcPort = $this.HostUcPort
            $result.MasterMcAddr = $this.MasterMcAddr
            $result.MasterMcPort = $this.MasterMcPort
            $result.MasterV6McAddr = $this.MasterV6McAddr
            $result.MulticastTtl = $this.MulticastTtl
            $result.TrafficType = $this.TrafficType
            $result.Ensure = [Ensure]::Absent
        }
    }
}
