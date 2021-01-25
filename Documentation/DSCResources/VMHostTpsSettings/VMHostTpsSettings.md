# VMHostTpsSettings

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | Name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Name** | Key | string | Name of the VMHost to configure. ||
| **Credential** | Mandatory | PSCredential | Credentials needed for connection to the specified Server. ||
| **ShareScanTime** | Optional | int | Share Scan Time Advanced Setting value. ||
| **ShareScanGHz** | Optional | int | Share Scan GHz Advanced Setting value. ||
| **ShareRateMax** | Optional | int | Share Rate Max Advanced Setting value. ||
| **ShareForceSalting** | Optional | int | Share Force Salting Advanced Setting value. ||

## Description

The resource is used to configure TPS Settings of a ESXi host.

## Examples

### Example 1

Updates the ShareScanTime and ShareForceSalting Advanced Settings values of the passed ESXi host.

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

Configuration VMHostTpsSettings_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        $Password = $Password | ConvertTo-SecureString -AsPlainText -Force
        $Credential = New-Object System.Management.Automation.PSCredential($User, $Password)

        VMHostTpsSettings vmHostTpsSettings {
            Name = $Name
            Server = $Server
            Credential = $Credential
            ShareScanTime = 50
            ShareForceSalting = 1
        }
    }
}
````
