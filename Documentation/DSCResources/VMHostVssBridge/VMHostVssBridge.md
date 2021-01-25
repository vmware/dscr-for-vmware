# VMHostVssBridge

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | Name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Name** | Key | string | Name of the VMHost to configure. ||
| **Credential** | Mandatory | PSCredential | Credentials needed for connection to the specified Server. ||
| **Ensure** | Mandatory | Ensure | Value indicating if the VSS should be Present or Absent. | Present, Absent |
| **VssName** | Key | string | The name of the VSS. ||
| **NicDevice** | Optional | string[] | The list of keys of the physical network adapters to be bridged. ||
| **BeaconInterval** | Optional | int | Determines how often, in seconds, a beacon should be sent. ||
| **LinkDiscoveryProtocolType** | Optional | string | The discovery protocol type. VSS only supports CDP. | CDP |
| **LinkDiscoveryProtocolOperation** | Optional | string | Whether to advertise or listen. | Advertise, Both, Listen, None |

## Description

A bridge connects a virtual switch (VSS) to (a) physical network adapter(s). The VSS needs to exist.

## Examples

### Example 1

Configures the teaming settings of the specified Virtual Switch.

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

Configuration VMHostVssBridge_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        $Password = $Password | ConvertTo-SecureString -AsPlainText -Force
        $Credential = New-Object System.Management.Automation.PSCredential($User, $Password)

        VMHostVss vmHostVssSettings {
            Name = $Name
            Server = $Server
            Credential = $Credential
            VssName = 'VSS1'
            Ensure = 'Present'
            Mtu = 1500
        }

        VMHostVssBridge vmHostVssBridge {
            Name = $Name
            Server = $Server
            Credential = $Credential
            VssName = 'VSS1'
            Ensure = 'Present'
            NicDevice = @('vmnic1','vmnic2')
            BeaconInterval = 1
            LinkDiscoveryProtocolType = [LinkDiscoveryProtocolProtocol]::CDP
            LinkDiscoveryProtocolOperation = [LinkDiscoveryProtocolOperation]::Listen
            DependsOn = "[VMHostVss]vmHostVssSettings"
        }
    }
}
````
