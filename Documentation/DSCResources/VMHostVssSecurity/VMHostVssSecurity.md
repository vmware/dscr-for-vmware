# VMHostVssSecurity

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | Name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Name** | Key | string | Name of the VMHost to configure. ||
| **Credential** | Mandatory | PSCredential | Credentials needed for connection to the specified Server. ||
| **Ensure** | Mandatory | Ensure | Value indicating if the VSS should be Present or Absent. | Present, Absent |
| **VssName** | Key | string | The name of the VSS. ||
| **AllowPromiscuous** | Optional | boolean | The flag to indicate whether or not all traffic is seen on the port. ||
| **ForgedTransmits** | Optional | boolean | The flag to indicate whether or not the virtual network adapter should be allowed to send network traffic with a different MAC address. ||
| **MacChanges** | Optional | boolean | The flag to indicate whether or not the Media Access Control (MAC) address can be changed. ||

## Description

The resource is used to configure the security policy governing ports of a Virtual Switch.

## Examples

### Example 1

Configures the security settings of the specified Virtual Switch.

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

Configuration VMHostVssSecurity_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        $Password = $Password | ConvertTo-SecureString -AsPlainText -Force
        $Credential = New-Object System.Management.Automation.PSCredential($User, $Password)

        VMHostVssSecurity vmHostVSSSecurity {
            Name = $Name
            Server = $Server
            Credential = $Credential
            VssName = 'VSS1'
            AllowPromiscuous = $true
            ForgedTransmits = $true
            MacChanges = $true
        }
    }
}
````
