# VMHostFirewallRuleset

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Credential** | Mandatory | PSCredential | The credentials needed for connection to the specified Server. ||
| **VMHostName** | Key | string | The name of the VMHost. ||
| **Name** | Key | string | The name of the firewall ruleset. ||
| **Enabled** | Optional | bool | Specifies whether the firewall ruleset should be enabled or disabled. ||
| **AllIP** | Optional | bool | Specifies whether the firewall ruleset allows connections from any IP address. ||
| **IPAddresses** | Optional | string[] | The list of IP addresses. All IPv4 addresses are specified using dotted decimal format. For example **192.0.20.10**. IPv6 addresses are 128-bit addresses represented as eight fields of up to four hexadecimal digits. A colon separates each field (**:**). For example **2001:DB8:101::230:6eff:fe04:d9ff**. The address can also consist of symbol **'::'** to represent multiple 16-bit groups of contiguous 0's only once in an address. ||

## Description

The resource is used to enable/disable the specified firewall ruleset from the VMHost. It also modifies the allowed IP addresses list of the firewall ruleset.

## Examples

### Example 1

Enables the specified VMHost firewall ruleset and modifies the allowed IP addresses list to be: **192.0.20.10**, **192.0.20.11**, **192.0.20.12**, **10.20.120.12/22**, **10.20.120.12/23**, **10.20.120.12/24**.
All IPs for the firewall ruleset are **disabled**.

```powershell
Configuration VMHostFirewallRuleset_EnableVMHostFirewallRulesetAndModifyTheAllowedIPAddressesList_Config {
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Server,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $VMHostName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $VMHostFirewallRulesetName
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostFirewallRuleset VMHostFirewallRuleset {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            Name = $VMHostFirewallRulesetName
            Enabled = $true
            AllIP = $false
            IPAddresses = @('192.0.20.10', '192.0.20.11', '192.0.20.12', '10.20.120.12/22', '10.20.120.12/23', '10.20.120.12/24')
        }
    }
}
```
