# VMHostDnsSettings

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | Name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Name** | Key | string | Name of the VMHost to configure. ||
| **Credential** | Mandatory | PSCredential | Credentials needed for connection to the specified Server. ||
| **Address** | Optional | string[] | List of domain name or IP address of the DNS Servers. ||
| **Dhcp** | Mandatory | bool | Indicates whether DHCP is used to determine DNS configuration. ||
| **DomainName** | Mandatory | string | Domain Name portion of the DNS name. For example, "vmware.com". ||
| **HostName** | Mandatory | string | Host Name portion of DNS name. For example, "esx01". ||
| **Ipv6VirtualNicDevice** | Optional | string | Desired value for the VMHost DNS Ipv6VirtualNicDevice. ||
| **SearchDomain** | Optional | string[] | Domain in which to search for hosts, placed in order of preference. ||
| **VirtualNicDevice** | Optional | string | Desired value for the VMHost DNS VirtualNicDevice. ||

## Description

The resource is used to configure the DNS Settings of a ESXi host.

## Examples

### Example 1

Updates the DNS Config of the passed ESXi host.

````powershell
param(
        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        [Parameter(Mandatory = $true)]
        [string]
        $Server,

        [Parameter(Mandatory = $true)]
        [string]
        $User,

        [Parameter(Mandatory = $true)]
        [string]
        $Password
)

$script:configurationData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
        }
    )
}

Configuration VMHostDnsSettings_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        $Password = $Password | ConvertTo-SecureString -AsPlainText -Force
        $Credential = New-Object System.Management.Automation.PSCredential($User, $Password)

        VMHostDnsSettings vmHostDnsSettings {
            Name = $Name
            Server = $Server
            Credential = $Credential
            HostName = "esx-server1"
            DomainName = "eng.vmware.com"
            Dhcp = $false
            Address = @("10.23.83.229", "10.23.108.1")
            SearchDomain = @("eng.vmware.com")
        }
    }
}
````
