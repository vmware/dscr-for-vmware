# DistributedSwitch

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | Name of the Server we are trying to connect to. The Server can only be a vCenter. ||
| **Credential** | Mandatory | PSCredential | Credentials needed for connection to the specified Server. ||
| **Name** | Key | string | Name of the Distributed Switch located in the Datacenter specified in 'DatacenterName' key property. ||
| **Location** | Key | string | Location of the Distributed Switch with name specified in 'Name' key property in the Datacenter specified in the 'DatacenterName' key property. Location consists of 0 or more Inventory Items. Empty Location means that the Distributed Switch is in the Network Folder of the Datacenter. The Root Folders of the Datacenter are not part of the Location. Inventory Item names in Location are separated by "/". Example Location for a Distributed Switch: "MySwitches/MyDistributedSwitches". ||
| **DatacenterName** | Key | string | Name of the Datacenter we will use from the specified Inventory. ||
| **DatacenterLocation** | Key | string | Location of the Datacenter we will use from the Inventory. Root Folder of the Inventory is not part of the Location. Empty Location means that the Datacenter is in the Root Folder of the Inventory. Folder names in Location are separated by "/". Example Location: "MyDatacentersFolder". ||
| **Ensure** | Mandatory | Ensure | Value indicating if the Distributed Switch should be Present or Absent. | Present, Absent |
| **ContactDetails** | Optional | string | The contact details of the vSphere Distributed Switch administrator. ||
| **ContactName** | Optional | string | The name of the vSphere Distributed Switch administrator. ||
| **LinkDiscoveryProtocol** | Optional | LinkDiscoveryProtocolProtocol | The discovery protocol type of the vSphere Distributed Switch that you want to create. If you do not set a value for this parameter, the default server setting is used. | CDP, LLDP, Unset |
| **LinkDiscoveryProtocolOperation** | Optional | LinkDiscoveryProtocolOperation | The link discovery protocol operation for the vSphere Distributed Switch that you want to create. If you do not set a value for this parameter, the default server setting is used. | Advertise, Both, Listen, None, Unset |
| **MaxPorts** | Optional | int | The maximum number of ports allowed on the vSphere Distributed Switch that you want to create. ||
| **Mtu** | Optional | int | The maximum MTU size for the vSphere Distributed Switch that you want to create. Valid values are positive integers only. ||
| **Notes** | Optional | string | The description for the vSphere Distributed Switch that you want to create. ||
| **NumUplinkPorts** | Optional | int | The number of uplink ports on the vSphere Distributed Switch that you want to create. ||
| **ReferenceVDSwitch** | Optional | string | The reference vSphere Distributed Switch. The properties of the new vSphere Distributed Switch will be cloned from the reference vSphere Distributed Switch. ||
| **Version** | Optional | string | The version of the vSphere Distributed Switch that you want to create. You cannot specify a version that is incompatible with the version of the vCenter Server system you are connected to. ||
| **WithoutPortGroups** | Optional | bool | Indicates whether the new vSphere Distributed Switch will be created without importing the port groups from the specified reference vSphere Distributed Switch. ||

## Description
The resource is used to create, update and remove vSphere Distributed Switches.

## Examples

### Example 1

Creates a new Distributed Switch **MyDistributedSwitch** with the specified settings in the **Network** folder of Datacenter **Datacenter**.

```powershell
Configuration DistributedSwitch_Config {
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Server,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $Credential
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        DistributedSwitch DistributedSwitch {
            Server = $Server
            Credential = $Credential
            Name = 'MyDistributedSwitch'
            Location = ''
            DatacenterName = 'Datacenter'
            DatacenterLocation = ''
            Ensure = 'Present'
            ContactDetails = 'My Contact Details'
            ContactName = 'My Contact Name'
            LinkDiscoveryProtocol = 'CDP'
            LinkDiscoveryProtocolOperation = 'Advertise'
            MaxPorts = 100
            Mtu = 2000
            Notes = 'My Notes for Distributed Switch'
            NumUplinkPorts = 10
            Version = '6.6.0'
        }
    }
}
```

### Example 2

Creates a new Distributed Switch **MyDistributedSwitch** with the specified settings in the **Network** folder of Datacenter **Datacenter**. It also creates a new Distributed Switch **MyDistributedSwitchViaReferenceVDSwitch** with the settings from the Distributed Switch **MyDistributedSwitch** in the **Network** folder of Datacenter **Datacenter**. The new vSphere Distributed Switch will be created without importing the port groups from the specified reference vSphere Distributed Switch.

```powershell
Configuration DistributedSwitch_Config {
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Server,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $Credential
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        DistributedSwitch DistributedSwitch {
            Server = $Server
            Credential = $Credential
            Name = 'MyDistributedSwitch'
            Location = ''
            DatacenterName = 'Datacenter'
            DatacenterLocation = ''
            Ensure = 'Present'
            ContactDetails = 'My Contact Details'
            ContactName = 'My Contact Name'
            LinkDiscoveryProtocol = 'CDP'
            LinkDiscoveryProtocolOperation = 'Advertise'
            MaxPorts = 100
            Mtu = 2000
            Notes = 'My Notes for Distributed Switch'
            NumUplinkPorts = 10
            Version = '6.6.0'
        }

        DistributedSwitch DistributedSwitchViaReferenceVDSwitch {
            Server = $Server
            Credential = $Credential
            Name = 'MyDistributedSwitchViaReferenceVDSwitch'
            Location = ''
            DatacenterName = 'Datacenter'
            DatacenterLocation = ''
            Ensure = 'Present'
            ReferenceVDSwitch = 'MyDistributedSwitch'
            WithoutPortGroups = $true
            DependsOn = "[DistributedSwitch]DistributedSwitch"
        }
    }
}
```

### Example 3

Removes the Distributed Switch **MyDistributedSwitch** from the **Network** folder of Datacenter **Datacenter**.

```powershell
Configuration DistributedSwitch_Config {
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Server,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $Credential
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        DistributedSwitch DistributedSwitch {
            Server = $Server
            Credential = $Credential
            Name = 'MyDistributedSwitch'
            Location = ''
            DatacenterName = 'Datacenter'
            DatacenterLocation = ''
            Ensure = 'Absent'
        }
    }
}
```
