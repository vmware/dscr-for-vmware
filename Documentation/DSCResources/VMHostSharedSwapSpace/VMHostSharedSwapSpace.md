# VMHostSharedSwapSpace

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Credential** | Mandatory | PSCredential | The credentials needed for connection to the specified Server. ||
| **Name** | Key | string | The name of the VMHost. ||
| **DatastoreEnabled** | Optional | bool | Specifies if the Datastore option should be enabled or not. ||
| **DatastoreName** | Optional | string | The name of the Datastore used by the Datastore option. ||
| **DatastoreOrder** | Optional | long | The order of the Datastore option in the preference of the options of the system-wide shared swap space. ||
| **HostCacheEnabled** | Optional | bool | Specifies if the host cache option should be enabled or not. ||
| **HostCacheOrder** | Optional | long | The order of the host cache option in the preference of the options of the system-wide shared swap space. ||
| **HostLocalSwapEnabled** | Optional | bool | Specifies if the host local swap option should be enabled or not. ||
| **HostLocalSwapOrder** | Optional | long | The order of the host local swap option in the preference of the options of the system-wide shared swap space. ||

## Description

The resource is used to modify the configuration of system-wide shared swap space on the specified VMHost.

## Examples

### Example 1

Enables the Datastore option and uses the Datastore with the specified name. Disables the host cache option. Disabled the host local swap option. The preference of the options is: 0. host local swap option, 1. Datastore option, 2. host cache option.

```powershell
Configuration VMHostSharedSwapSpace_ModifySharedSwapSpaceConfiguration_Config {
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
        $Name,

        [[Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $DatastoreName
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostSharedSwapSpace VMHostSharedSwapSpace {
            Server = $Server
            Credential = $Credential
            Name = $Name
            DatastoreEnabled = $true
            DatastoreName = $DatastoreName
            DatastoreOrder = 1
            HostCacheEnabled = $false
            HostCacheOrder = 2
            HostLocalSwapEnabled = $false
            HostLocalSwapOrder = 0
        }
    }
}
```
