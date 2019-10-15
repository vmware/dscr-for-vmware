# VDPortGroup

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The name of the Server we are trying to connect to. The Server can only be a vCenter. ||
| **Credential** | Mandatory | PSCredential | The credentials needed for connection to the specified Server. ||
| **Name** | Key | string | The name of the Distributed Port Group. ||
| **VdsName** | Mandatory | string | The name of the vSphere Distributed Switch associated with the Distributed Port Group. ||
| **Ensure** | Mandatory | Ensure | Value indicating if the Distributed Port Group should be Present or Absent. | Present, Absent |
| **Notes** | Optional | string | The description for the Distributed Port Group. ||
| **NumPorts** | Optional | int | The number of ports that the Distributed Port Group will have. If the parameter is not specified, the number of ports for the Distributed Port Group is 128. ||
| **PortBinding** | Optional | PortBinding | The port binding setting for the Distributed Port Group. | Static, Dynamic, Ephemeral |
| **ReferenceVDPortGroupName** | Optional | string | The name for the reference Distributed Port Group. The properties of the new Distributed Port Group will be cloned from the reference Distributed Port Group. ||

## Description

The resource is used to create, modify the configuration or remove the specified Distributed Port Group.

## Examples

### Example 1

Creates a new Datacenter **Datacenter** in the **Root Folder** of the Inventory. Creates a new vSphere Distributed Switch **MyVDSwitch** in the **Network Folder** of Datacenter **Datacenter**. Creates a new Distributed Port Group **MyVDPortGroup** on vSphere Distributed Switch **MyVDSwitch** with **Static** Port Binding and **128** Ports.

```powershell
Configuration VDPortGroup_CreateVDPortGroup_Config {
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
        Datacenter Datacenter {
            Server = $Server
            Credential = $Credential
            Name = 'Datacenter'
            Location = ''
            Ensure = 'Present'
        }

        VDSwitch VDSwitch {
            Server = $Server
            Credential = $Credential
            Name = 'MyVDSwitch'
            Location = ''
            DatacenterName = 'Datacenter'
            DatacenterLocation = ''
            Ensure = 'Present'
            DependsOn = '[Datacenter]Datacenter'
        }

        VDPortGroup VDPortGroup {
            Server = $Server
            Credential = $Credential
            Name = 'MyVDPortGroup'
            VdsName = 'MyVDSwitch'
            Ensure = 'Present'
            NumPorts = 128
            Notes = 'MyVDPortGroup Notes'
            PortBinding = 'Static'
            DependsOn = '[VDSwitch]VDSwitch'
        }
    }
}
```

### Example 2

Creates a new Datacenter **Datacenter** in the **Root Folder** of the Inventory. Creates a new vSphere Distributed Switch **MyVDSwitch** in the **Network Folder** of Datacenter **Datacenter**. Creates a new Distributed Port Group **MyVDPortGroup** on vSphere Distributed Switch **MyVDSwitch** with **Static** Port Binding and **128** Ports. Creates a new Distributed Port Group **MyVDPortGroupViaReferenceVDPortGroup** on vSphere Distributed Switch **MyVDSwitch**. The properties of the new Distributed Port Group will be cloned from the Reference Distributed Port Group **MyVDPortGroup**.

```powershell
Configuration VDPortGroup_CreateVDPortGroupViaReferenceVDPortGroup_Config {
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
        Datacenter Datacenter {
            Server = $Server
            Credential = $Credential
            Name = 'Datacenter'
            Location = ''
            Ensure = 'Present'
        }

        VDSwitch VDSwitch {
            Server = $Server
            Credential = $Credential
            Name = 'MyVDSwitch'
            Location = ''
            DatacenterName = 'Datacenter'
            DatacenterLocation = ''
            Ensure = 'Present'
            DependsOn = '[Datacenter]Datacenter'
        }

        VDPortGroup VDPortGroup {
            Server = $Server
            Credential = $Credential
            Name = 'MyVDPortGroup'
            VdsName = 'MyVDSwitch'
            Ensure = 'Present'
            NumPorts = 128
            Notes = 'MyVDPortGroup Notes'
            PortBinding = 'Static'
            DependsOn = '[VDSwitch]VDSwitch'
        }

        VDPortGroup VDPortGroupViaReferenceVDPortGroup {
            Server = $Server
            Credential = $Credential
            Name = 'MyVDPortGroupViaReferenceVDPortGroup'
            VdsName = 'MyVDSwitch'
            Ensure = 'Present'
            ReferenceVDPortGroupName = 'MyVDPortGroup'
            DependsOn = '[VDPortGroup]VDPortGroup'
        }
    }
}
```

### Example 3

Removes Distributed Port Group **MyVDPortGroup** on vSphere Distributed Switch **MyVDSwitch**.

```powershell
Configuration VDPortGroup_RemoveVDPortGroup_Config {
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
        VDPortGroup VDPortGroup {
            Server = $Server
            Credential = $Credential
            Name = 'MyVDPortGroup'
            VdsName = 'MyVDSwitch'
            Ensure = 'Absent'
        }
    }
}
```
