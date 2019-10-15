# VMHostSettings

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | Name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Name** | Key | string | Name of the VMHost to configure. ||
| **Credential** | Mandatory | PSCredential | Credentials needed for connection to the specified Server. ||
| **Motd** | Optional | string | Motd Advanced Setting value. ||
| **MotdClear** | Optional | bool | Indicates whether the Motd content should be cleared. ||
| **Issue** | Optional | string | Issue Advanced Setting value. ||
| **IssueClear** | Optional | bool | Indicates whether the Issue content should be cleared. ||

## Description

The resource is used to Update Motd Setting and Issue Setting of the passed ESXi host.

## Examples

### Example 1

Updates the Motd Setting and Issue Setting of the passed ESXi host.

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

Configuration VMHostSettings_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        $Password = $Password | ConvertTo-SecureString -AsPlainText -Force
        $Credential = New-Object System.Management.Automation.PSCredential($User, $Password)

        VMHostSettings vmHostSettings {
            Name = $Name
            Server = $Server
            Credential = $Credential
            Motd = 'Hello World from motd!'
            Issue = 'Hello World from issue!'
        }
    }
}
````
