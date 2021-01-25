# VMHostService

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | Name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Name** | Key | string | Name of the VMHost to configure. ||
| **Credential** | Mandatory | PSCredential | Credentials needed for connection to the specified Server. ||
| **Key** | Key | string | The key value of the service. ||
| **Policy** | Optional | ServicePolicy | The state of the service after a VMHost reboot. |Unset, On, Off, Automatic|
| **Running** | Optional | bool | The current state of the service. ||

## Description

The resource is used to configure the host services on an ESXi host.

## Examples

### Example 1

Updates the Policy and Running state of the SSH service on the passed ESXi host.

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

Configuration VMHostService_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        $Password = $Password | ConvertTo-SecureString -AsPlainText -Force
        $Credential = New-Object System.Management.Automation.PSCredential($User, $Password)

        VMHostService vmHostService {
            Name = $Name
            Server = $Server
            Credential = $Credential
            Key = 'TSM-SSH'
            Policy = 'On'
            Running = $true
        }
    }
}
````
