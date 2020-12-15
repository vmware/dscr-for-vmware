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
class VMHostDnsSettings : VMHostBaseDSC {
    <#
    .DESCRIPTION


    List of domain name or IP address of the DNS Servers.
    #>
    [DscProperty()]
    [string[]] $Address

    <#
    .DESCRIPTION

    Indicates whether DHCP is used to determine DNS configuration.
    #>
    [DscProperty(Mandatory)]
    [bool] $Dhcp

    <#
    .DESCRIPTION

    Domain Name portion of the DNS name. For example, "vmware.com".
    #>
    [DscProperty(Mandatory)]
    [string] $DomainName

    <#
    .DESCRIPTION

    Host Name portion of DNS name. For example, "esx01".
    #>
    [DscProperty(Mandatory)]
    [string] $HostName

    <#
    .DESCRIPTION

    Desired value for the VMHost DNS Ipv6VirtualNicDevice.
    #>
    [DscProperty()]
    [string] $Ipv6VirtualNicDevice

    <#
    .DESCRIPTION

    Domain in which to search for hosts, placed in order of preference.
    #>
    [DscProperty()]
    [string[]] $SearchDomain

    <#
    .DESCRIPTION

    Desired value for the VMHost DNS VirtualNicDevice.
    #>
    [DscProperty()]
    [string] $VirtualNicDevice

    [void] Set() {
        try {
            $this.ConnectVIServer()

            $this.WriteLogUtil('Verbose', $this.SetMethodStartMessage, @($this.DscResourceName))

            $vmHost = $this.GetVMHost()

            $this.UpdateDns($vmHost)
        }
        finally {
            $this.WriteLogUtil('Verbose', $this.SetMethodEndMessage, @($this.DscResourceName))

            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()

            $this.WriteLogUtil('Verbose', $this.TestMethodStartMessage, @($this.DscResourceName))

            $vmHost = $this.GetVMHost()

            $vmHostDnsConfig = $vmHost.ExtensionData.Config.Network.DnsConfig

            $result = !((
                $this.ShouldUpdateDscResourceSetting('Dhcp', $vmHostDnsConfig.Dhcp, $this.Dhcp),
                $this.ShouldUpdateDscResourceSetting('DomainName', $vmHostDnsConfig.DomainName, $this.DomainName),
                $this.ShouldUpdateDscResourceSetting('HostName', $vmHostDnsConfig.HostName, $this.HostName),
                $this.ShouldUpdateDscResourceSetting('Ipv6VirtualNicDevice', $vmHostDnsConfig.Ipv6VirtualNicDevice, $this.Ipv6VirtualNicDevice),
                $this.ShouldUpdateDscResourceSetting('VirtualNicDevice', $vmHostDnsConfig.VirtualNicDevice, $this.VirtualNicDevice),
                $this.ShouldUpdateArraySetting('Address', $vmHostDnsConfig.Address, $this.Address),
                $this.ShouldUpdateArraySetting('SearchDomain', $vmHostDnsConfig.SearchDomain, $this.SearchDomain)
            ) -Contains $true)

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.WriteLogUtil('Verbose', $this.TestMethodEndMessage, @($this.DscResourceName))

            $this.DisconnectVIServer()
        }
    }

    [VMHostDnsSettings] Get() {
        try {
            $this.ConnectVIServer()

            $this.WriteLogUtil('Verbose', $this.GetMethodStartMessage, @($this.DscResourceName))

            $result = [VMHostDnsSettings]::new()

            $vmHost = $this.GetVMHost()
            $vmHostDnsConfig = $vmHost.ExtensionData.Config.Network.DnsConfig

            $result.Name = $vmHost.Name
            $result.Server = $this.Server
            $result.Address = $vmHostDnsConfig.Address
            $result.Dhcp = $vmHostDnsConfig.Dhcp
            $result.DomainName = $vmHostDnsConfig.DomainName
            $result.HostName = $vmHostDnsConfig.HostName
            $result.Ipv6VirtualNicDevice = $vmHostDnsConfig.Ipv6VirtualNicDevice
            $result.SearchDomain = $vmHostDnsConfig.SearchDomain
            $result.VirtualNicDevice = $vmHostDnsConfig.VirtualNicDevice

            return $result
        }
        finally {
            $this.WriteLogUtil('Verbose', $this.GetMethodEndMessage, @($this.DscResourceName))

            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Updates the DNS Config of the VMHost with the Desired DNS Config.
    #>
    [void] UpdateDns($vmHost) {
        $dnsConfigArgs = @{
            Address = $this.Address
            Dhcp = $this.Dhcp
            DomainName = $this.DomainName
            HostName = $this.HostName
            Ipv6VirtualNicDevice = $this.Ipv6VirtualNicDevice
            SearchDomain = $this.SearchDomain
            VirtualNicDevice = $this.VirtualNicDevice
        }

        $dnsConfig = New-DNSConfig @dnsConfigArgs

        $getViewParams = @{
            Server = $this.Connection
            Id = $vmHost.ExtensionData.ConfigManager.NetworkSystem
            ErrorAction = 'Stop'
            Verbose = $false
        }
        $networkSystem = Get-View @getViewParams

        try {
            Update-DNSConfig -NetworkSystem $networkSystem -DnsConfig $dnsConfig
        }
        catch {
            throw "The DNS Config could not be updated: $($_.Exception.Message)"
        }
    }
}
