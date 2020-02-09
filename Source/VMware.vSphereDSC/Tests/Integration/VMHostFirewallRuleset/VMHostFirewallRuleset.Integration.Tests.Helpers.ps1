<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

<#
.DESCRIPTION

Retrieves the initial configuration of the VMHost firewall ruleset that is used in the Integration Tests.
#>
function Get-VMHostFirewallRulesetInitialConfiguration {
    [CmdletBinding()]
    [OutputType([hashtable])]

    $viServer = Connect-VIServer -Server $Server -Credential $Credential -ErrorAction Stop -Verbose:$false

    $vmHost = Get-VMHost -Server $viServer -Name $Name -ErrorAction Stop -Verbose:$false
    $vmHostFirewallRuleset = Get-VMHostFirewallException -Server $viServer -VMHost $vmHost -ErrorAction Stop -Verbose:$false |
                             Select-Object -First 1

    if ($null -eq $vmHostFirewallRuleset) {
        throw "No VMHost firewall rulesets available on VMHost $($vmHost.Name)."
    }

    $vmHostFirewallRulesetAllowedHosts = $vmHostFirewallRuleset.ExtensionData.AllowedHosts
    $ipNetworks = @()
    foreach ($hostFirewallRulesetIpNetwork in $vmHostFirewallRulesetAllowedHosts.IpNetwork) {
        $ipNetwork = $hostFirewallRulesetIpNetwork.Network + '/' + $hostFirewallRulesetIpNetwork.PrefixLength
        $ipNetworks += $ipNetwork
    }

    $vmHostFirewallRulesetInitialConfiguration = @{
        RulesetName = $vmHostFirewallRuleset.Name
        RulesetEnabled = $vmHostFirewallRuleset.Enabled
        AllIP = $vmHostFirewallRulesetAllowedHosts.AllIp
        IPAddresses = $vmHostFirewallRulesetAllowedHosts.IpAddress + $ipNetworks
    }

    Disconnect-VIServer -Server $Server -Confirm:$false -ErrorAction Stop -Verbose:$false

    $vmHostFirewallRulesetInitialConfiguration
}
