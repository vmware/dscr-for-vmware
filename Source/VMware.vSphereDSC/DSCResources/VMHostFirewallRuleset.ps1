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
class VMHostFirewallRuleset : VMHostEntityBaseDSC {
    <#
    .DESCRIPTION

    Specifies the name of the firewall ruleset.
    #>
    [DscProperty(Key)]
    [string] $Name

    <#
    .DESCRIPTION

    Specifies whether the firewall ruleset should be enabled or disabled.
    #>
    [DscProperty()]
    [nullable[bool]] $Enabled

    <#
    .DESCRIPTION

    Specifies whether the firewall ruleset allows connections from any IP address.
    #>
    [DscProperty()]
    [nullable[bool]] $AllIP

    <#
    .DESCRIPTION

    Specifies the list of IP addresses. All IPv4 addresses are specified using dotted decimal format. For example '192.0.20.10'.
    IPv6 addresses are 128-bit addresses represented as eight fields of up to four hexadecimal digits. A colon separates each field (:).
    For example 2001:DB8:101::230:6eff:fe04:d9ff. The address can also consist of symbol '::' to represent multiple 16-bit groups of contiguous 0's only once in an address.
    #>
    [DscProperty()]
    [string[]] $IPAddresses

    hidden [string] $ModifyVMHostFirewallRulesetStateMessage = "Modifying the state of firewall ruleset {0} on VMHost {1}."
    hidden [string] $ModifyVMHostFirewallRulesetAllowedIPAddressesListMessage = "Modifying the allowed IP addresses list of firewall ruleset {0} on VMHost {1}."

    hidden [string] $CouldNotRetrieveFirewallSystemOfVMHostMessage = "Could not retrieve the FirewallSystem managed object of VMHost {0}. For more information: {1}"
    hidden [string] $CouldNotRetrieveFirewallRulesetMessage = "Could not retrieve firewall ruleset {0} from VMHost {1}. For more information: {2}"
    hidden [string] $CouldNotModifyVMHostFirewallRulesetStateMessage = "Could not modify the state of firewall ruleset {0} on VMHost {1}. For more information: {2}"
    hidden [string] $CouldNotModifyVMHostFirewallRulesetAllowedIPAddressesListMessage = "Could not modify the allowed IP addresses list of firewall ruleset {0} on VMHost {1}. For more information: {2}"

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()

            $this.RetrieveVMHost()
            $vmHostFirewallRuleset = $this.GetVMHostFirewallRuleset()

            if ($this.ShouldModifyVMHostFirewallRulesetState($vmHostFirewallRuleset)) {
                $this.ModifyVMHostFirewallRulesetState($vmHostFirewallRuleset)
            }

            if ($this.ShouldModifyVMHostFirewallRulesetAllowedIPAddressesList($vmHostFirewallRuleset)) {
                $vmHostFirewallSystem = $this.GetVMHostFirewallSystem()
                $this.ModifyVMHostFirewallRulesetAllowedIPAddressesList($vmHostFirewallSystem, $vmHostFirewallRuleset)
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

            $this.RetrieveVMHost()
            $vmHostFirewallRuleset = $this.GetVMHostFirewallRuleset()

            $result = !($this.ShouldModifyVMHostFirewallRulesetState($vmHostFirewallRuleset) -or $this.ShouldModifyVMHostFirewallRulesetAllowedIPAddressesList($vmHostFirewallRuleset))

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [VMHostFirewallRuleset] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [VMHostFirewallRuleset]::new()

            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $vmHostFirewallRuleset = $this.GetVMHostFirewallRuleset()

            $this.PopulateResult($result, $vmHostFirewallRuleset)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the FirewallSystem of the specified VMHost.
    #>
    [PSObject] GetVMHostFirewallSystem() {
        try {
            $firewallSystem = Get-View -Server $this.Connection -Id $this.VMHost.ExtensionData.ConfigManager.FirewallSystem -ErrorAction Stop -Verbose:$false
            return $firewallSystem
        }
        catch {
            throw ($this.CouldNotRetrieveFirewallSystemOfVMHostMessage -f $this.VMHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the firewall ruleset with the specified name on the specified VMHost.
    #>
    [PSObject] GetVMHostFirewallRuleset() {
        try {
            $vmHostFirewallRuleset = Get-VMHostFirewallException -Server $this.Connection -Name $this.Name -VMHost $this.VMHost -ErrorAction Stop -Verbose:$false
            return $vmHostFirewallRuleset
        }
        catch {
            throw ($this.CouldNotRetrieveFirewallRulesetMessage -f $this.Name, $this.VMHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Converts the passed string array containing IP networks in the following format: '10.20.120.12/22' to HostFirewallRulesetIpNetwork array,
    where the 'Network' is '10.23.120.12' and the 'PrefixLength' is '22'.
    #>
    [array] ConvertIPNetworksToHostFirewallRulesetIpNetworks($ipNetworks) {
        $hostFirewallRulesetIpNetworks = @()

        foreach ($ipNetwork in $ipNetworks) {
            $ipNetworkParts = $ipNetwork -Split '/'

            $hostFirewallRulesetIpNetwork = New-Object -TypeName VMware.Vim.HostFirewallRulesetIpNetwork
            $hostFirewallRulesetIpNetwork.Network = $ipNetworkParts[0]
            $hostFirewallRulesetIpNetwork.PrefixLength = $ipNetworkParts[1]

            $hostFirewallRulesetIpNetworks += $hostFirewallRulesetIpNetwork
        }

        return $hostFirewallRulesetIpNetworks
    }

    <#
    .DESCRIPTION

    Converts the passed HostFirewallRulesetIpNetwork array containing IP networks in the following format: 'Network' = '10.23.120.12' and 'PrefixLength' = '22' to string array,
    where each IP network is in the following format: '10.23.120.12/22'.
    #>
    [array] ConvertHostFirewallRulesetIpNetworksToIPNetworks($hostFirewallRulesetIpNetworks) {
        $ipNetworks = @()

        foreach ($hostFirewallRulesetIpNetwork in $hostFirewallRulesetIpNetworks) {
            $ipNetwork = $hostFirewallRulesetIpNetwork.Network + '/' + $hostFirewallRulesetIpNetwork.PrefixLength
            $ipNetworks += $ipNetwork
        }

        return $ipNetworks
    }

    <#
    .DESCRIPTION

    Checks if the current firewall ruleset state (enabled or disabled) is equal to the desired firewall ruleset state.
    #>
    [bool] ShouldModifyVMHostFirewallRulesetState($vmHostFirewallRuleset) {
        return ($this.Enabled -ne $null -and $this.Enabled -ne $vmHostFirewallRuleset.Enabled)
    }

    <#
    .DESCRIPTION

    Checks if the current firewall ruleset IP addresses allowed list is equal to the desired firewall ruleset IP addresses allowed list.
    #>
    [bool] ShouldModifyVMHostFirewallRulesetAllowedIPAddressesList($vmHostFirewallRuleset) {
        $vmHostFirewallRulesetAllowedHosts = $vmHostFirewallRuleset.ExtensionData.AllowedHosts

        $shouldModifyVMHostFirewallRulesetAllowedIPAddressesList = @()
        $shouldModifyVMHostFirewallRulesetAllowedIPAddressesList += ($null -ne $this.AllIP -and $this.AllIP -ne $vmHostFirewallRulesetAllowedHosts.AllIp)

        if ($null -ne $this.IPAddresses) {
            $desiredIPAddresses = $this.IPAddresses -NotMatch '/'
            $desiredIPNetworks = $this.IPAddresses -Match '/'

            $shouldModifyVMHostFirewallRulesetAllowedIPAddressesList += $this.ShouldUpdateArraySetting($vmHostFirewallRulesetAllowedHosts.IpAddress, $desiredIPAddresses)
            $shouldModifyVMHostFirewallRulesetAllowedIPAddressesList += $this.ShouldUpdateArraySetting($this.ConvertHostFirewallRulesetIpNetworksToIPNetworks($vmHostFirewallRulesetAllowedHosts.IpNetwork), $desiredIPNetworks)
        }

        return ($shouldModifyVMHostFirewallRulesetAllowedIPAddressesList -Contains $true)
    }

    <#
    .DESCRIPTION

    Modifies the firewall ruleset state depending on the specified value (enables or disables the firewall ruleset).
    #>
    [void] ModifyVMHostFirewallRulesetState($vmHostFirewallRuleset) {
        $setVMHostFirewallExceptionParams = @{
            Exception = $vmHostFirewallRuleset
            Enabled = $this.Enabled
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        try {
            Write-VerboseLog -Message $this.ModifyVMHostFirewallRulesetStateMessage -Arguments @($vmHostFirewallRuleset.Name, $this.VMHost.Name)
            Set-VMHostFirewallException @setVMHostFirewallExceptionParams
        }
        catch {
            throw ($this.CouldNotModifyVMHostFirewallRulesetStateMessage -f $vmHostFirewallRuleset.Name, $this.VMHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Modifies the firewall ruleset IP addresses allowed list.
    #>
    [void] ModifyVMHostFirewallRulesetAllowedIPAddressesList($vmHostFirewallSystem, $vmHostFirewallRuleset) {
        $vmHostFirewallRulesetSpec = New-Object -TypeName VMware.Vim.HostFirewallRulesetRulesetSpec
        $vmHostFirewallRulesetSpec.AllowedHosts = New-Object -TypeName VMware.Vim.HostFirewallRulesetIpList

        if ($null -ne $this.AllIP) { $vmHostFirewallRulesetSpec.AllowedHosts.AllIp = $this.AllIP }

        if ($null -ne $this.IPAddresses) {
            $desiredIPAddresses = $this.IPAddresses -NotMatch '/'
            $desiredIPNetworks = $this.IPAddresses -Match '/'

            $vmHostFirewallRulesetSpec.AllowedHosts.IpAddress = $desiredIPAddresses
            $vmHostFirewallRulesetSpec.AllowedHosts.IpNetwork = $this.ConvertIPNetworksToHostFirewallRulesetIpNetworks($desiredIPNetworks)
        }

        try {
            Write-VerboseLog -Message $this.ModifyVMHostFirewallRulesetAllowedIPAddressesListMessage -Arguments @($vmHostFirewallRuleset.Name, $this.VMHost.Name)
            Update-VMHostFirewallRuleset -VMHostFirewallSystem $vmHostFirewallSystem -VMHostFirewallRulesetId $vmHostFirewallRuleset.ExtensionData.Key -VMHostFirewallRulesetSpec $vmHostFirewallRulesetSpec
        }
        catch {
            throw ($this.CouldNotModifyVMHostFirewallRulesetAllowedIPAddressesListMessage -f $vmHostFirewallRuleset.Name, $this.VMHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $vmHostFirewallRuleset) {
        $result.Server = $this.Connection.Name
        $result.VMHostName = $this.VMHost.Name
        $result.Name = $vmHostFirewallRuleset.Name
        $result.Enabled = $vmHostFirewallRuleset.Enabled

        $vmHostFirewallRulesetAllowedHosts = $vmHostFirewallRuleset.ExtensionData.AllowedHosts
        $result.AllIP = $vmHostFirewallRulesetAllowedHosts.AllIp
        $result.IPAddresses = $vmHostFirewallRulesetAllowedHosts.IpAddress + $this.ConvertHostFirewallRulesetIpNetworksToIPNetworks($vmHostFirewallRulesetAllowedHosts.IpNetwork)
    }
}
