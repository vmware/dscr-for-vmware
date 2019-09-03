# VMHostVirtualPortGroup

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | Name of the Server we are trying to connect to. The Server can only be a vCenter. ||
| **Name** | Key | string | Name of the VMHost to configure. ||
| **Credential** | Mandatory | PSCredential | Credentials needed for connection to the specified Server. ||
| **PortGroupName** | Key | string | The name for the Port Group. ||
| **VirtualSwitch** | Mandatory | string | The Virtual Switch associated with the Port Group. The Virtual Switch must be a Standard Virtual Switch. ||
| **Ensure** | Mandatory | Ensure | Value indicating if the Port Group should be Present or Absent. | Present, Absent |
| **VLanId** | Optional | int | The VLAN ID for ports using this Port Group. | 0 - 4095 |

## Description
The resource is used to create, update and delete Port Groups which are associated with the specified Virtual Switch.

## Examples

### Example 1

The first Resource in the Configuration creates a new Virtual Switch **MyVirtualSwitch** with Mtu **1500**. The second Resource in the Configuration creates a new Port Group **MyVirtualPortGroup** which is associated with the Virtual Switch **MyVirtualSwitch** with VLanId set to **1**.

```powershell
Configuration VMHostVirtualPortGroup_Config {
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

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
        VMHostVss VMHostVss {
            Name = $Name
            Server = $Server
            Credential = $Credential
            VssName = 'MyVirtualSwitch'
            Ensure = 'Present'
            Mtu = 1500
        }

        VMHostVirtualPortGroup VMHostVirtualPortGroup {
            Name = $Name
            Server = $Server
            Credential = $Credential
            PortGroupName = 'MyVirtualPortGroup'
            VirtualSwitch = 'MyVirtualSwitch'
            Ensure = 'Present'
            VLanId = 1
            DependsOn = "[VMHostVss]VMHostVss"
        }
    }
}
```

### Example 2

The first Resource in the Configuration creates a new Virtual Switch **MyVirtualSwitch** with Mtu **1500**. The second Resource in the Configuration removes the Port Group **MyVirtualPortGroup** which is associated with the Virtual Switch **MyVirtualSwitch**.

```powershell
Configuration VMHostVirtualPortGroup_Config {
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

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
        VMHostVss VMHostVss {
            Name = $Name
            Server = $Server
            Credential = $Credential
            VssName = 'MyVirtualSwitch'
            Ensure = 'Present'
            Mtu = 1500
        }

        VMHostVirtualPortGroup VMHostVirtualPortGroup {
            Name = $Name
            Server = $Server
            Credential = $Credential
            PortGroupName = 'MyVirtualPortGroup'
            VirtualSwitch = 'MyVirtualSwitch'
            Ensure = 'Absent'
            DependsOn = "[VMHostVss]VMHostVss"
        }
    }
}
```
