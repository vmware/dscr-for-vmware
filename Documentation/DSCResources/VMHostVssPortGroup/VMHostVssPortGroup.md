# VMHostVssPortGroup

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The Name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Credential** | Mandatory | PSCredential | Credentials needed for connection to the specified Server. ||
| **VMHostName** | Key | string | The Name of the VMHost which is going to be used. ||
| **Name** | Key | string | The Name for the Port Group. ||
| **VssName** | Mandatory | string | The Name of the Virtual Switch associated with the Port Group. The Virtual Switch must be a Standard Virtual Switch. ||
| **Ensure** | Mandatory | Ensure | Value indicating if the Port Group should be Present or Absent. | Present, Absent |
| **VLanId** | Optional | int | The VLAN ID for ports using this Port Group. | 0 - 4095 |

## Description

The resource is used to create, update and delete Port Groups which are associated with the specified Virtual Switch. If Ensure is 'Absent', all VMs connected to the Port Group must be **PoweredOff** to successfully remove the Port Group. If one or more of the VMs are **PoweredOn**, the removal would not be successful because the Port Group is used by the VMs.

## Examples

### Example 1

The first Resource in the Configuration creates a new Virtual Switch **MyVirtualSwitch** with Mtu **1500**. The second Resource in the Configuration creates a new Port Group **MyVirtualPortGroup** which is associated with Virtual Switch **MyVirtualSwitch** with VLanId set to **1**.

```powershell
Configuration VMHostVssPortGroup_Config {
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
        $VMHostName
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostVss VMHostVss {
            Server = $Server
            Credential = $Credential
            Name = $VMHostName
            VssName = 'MyVirtualSwitch'
            Ensure = 'Present'
            Mtu = 1500
        }

        VMHostVssPortGroup VMHostVssPortGroup {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            Name = 'MyVirtualPortGroup'
            VssName = 'MyVirtualSwitch'
            Ensure = 'Present'
            VLanId = 1
            DependsOn = "[VMHostVss]VMHostVss"
        }
    }
}
```

### Example 2

The first Resource in the Configuration removes the Port Group **MyVirtualPortGroup** which is associated with Virtual Switch **MyVirtualSwitch**. The second Resource in the Configuration removes the Virtual Switch **MyVirtualSwitch** with Mtu **1500**.

```powershell
Configuration VMHostVirtualPortGroup_Config {
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
        $VMHostName
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostVssPortGroup VMHostVssPortGroup {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            Name = 'MyVirtualPortGroup'
            VssName = 'MyVirtualSwitch'
            Ensure = 'Absent'
        }

        VMHostVss VMHostVss {
            Server = $Server
            Credential = $Credential
            Name = $VMHostName
            VssName = 'MyVirtualSwitch'
            Ensure = 'Absent'
            Mtu = 1500
            DependsOn = "[VMHostVssPortGroup]VMHostVssPortGroup"
        }
    }
}
```
