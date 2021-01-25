# VMHostNtpSettings

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | Name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Name** | Key | string | Name of the VMHost to configure. ||
| **Credential** | Mandatory | PSCredential | Credentials needed for connection to the specified Server. ||
| **NtpServer** | Optional | string[] | List of domain name or IP address of the desired NTP Servers. ||
| **NtpServicePolicy** | Optional | ServicePolicy | Desired Policy of the VMHost 'ntpd' service activation. |Unset, On, Off, Automatic|

## Description

The resource is used to configure NTP Server property and the Service Policy of the 'ntpd' Service of a ESXi host.

## Examples

### Example 1

Updates the NTP Server array with the desired values and changes the 'ntpd' Service Policy to 'automatic' of the passed ESXi host.

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

Configuration VMHostNtpSettings_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        $Password = $Password | ConvertTo-SecureString -AsPlainText -Force
        $Credential = New-Object System.Management.Automation.PSCredential($User, $Password)

        VMHostNtpSettings vmHostNtpSettings {
            Name = $Name
            Server = $Server
            Credential = $Credential
            NtpServer = @("0.bg.pool.ntp.org", "1.bg.pool.ntp.org", "2.bg.pool.ntp.org")
            NtpServicePolicy = "automatic"
        }
    }
}
````
