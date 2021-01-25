# Datacenter

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | Name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Credential** | Mandatory | PSCredential | Credentials needed for connection to the specified Server. ||
| **Name** | Key | string | Name of the Datacenter located in the Folder specified in the 'Location' property. ||
| **Location** | Key | string | Location of the Datacenter with name specified in 'Name' key property in the specified Inventory. Location consists of 0 or more Folders. Empty Location means that the Datacenter is in the Root Folder of the specified Inventory. The Root Folder of the Inventory is not part of the Location. Folder names in Location are separated by "/". Example Location for a Datacenter Inventory Item: "MyFolder/MyDatacentersFolder". ||
| **Ensure** | Mandatory | Ensure | Value indicating if the Datacenter should be Present or Absent. | Present, Absent |

## Description

The resource is used to create and delete Datacenters in a specified Inventory.

## Examples

### Example 1

The first Resource in the Configuration creates a new Folder 'MyFolder' in the Root Folder of the specified Inventory. The second Resource in the Configuration creates a new Folder 'MyDatacentersFolder' in the 'MyFolder' Folder. The third Resource in the Configuration creates a new Datacenter 'MyDatacenter' in the 'MyDatacentersFolder' Folder.

```powershell
Configuration Datacenter_Config {
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
        DatacenterFolder MyFolder {
            Server = $Server
            Credential = $Credential
            Name = 'MyFolder'
            Location = ''
            Ensure = 'Present'
        }

        DatacenterFolder MyDatacentersFolder {
            Server = $Server
            Credential = $Credential
            Name = 'MyDatacentersFolder'
            Location = 'MyFolder'
            Ensure = 'Present'
            DependsOn = "[DatacenterFolder]MyFolder"
        }

        Datacenter MyDatacenter {
            Server = $Server
            Credential = $Credential
            Name = 'MyDatacenter'
            Location = 'MyFolder/MyDatacentersFolder'
            Ensure = 'Present'
            DependsOn = "[DatacenterFolder]MyDatacentersFolder"
        }
    }
}
```

### Example 2

The first Resource in the Configuration removes the Datacenter 'MyDatacenter' in the 'MyDatacentersFolder' Folder. The second Resource in the Configuration removes the Folder 'MyDatacentersFolder' in the 'MyFolder' Folder. The third Resource in the Configuration removes the Folder 'MyFolder' in the Root Folder of the Inventory.

```powershell
Configuration DatacenterFolder_Config {
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
        Datacenter MyDatacenter {
            Server = $Server
            Credential = $Credential
            Name = 'MyDatacenter'
            Location = 'MyFolder/MyDatacentersFolder'
            Ensure = 'Absent'
        }

        DatacenterFolder MyDatacentersFolder {
            Server = $Server
            Credential = $Credential
            Name = 'MyDatacentersFolder'
            Location = 'MyFolder'
            Ensure = 'Absent'
            DependsOn = "[Datacenter]MyDatacenter"
        }

        DatacenterFolder MyFolder {
            Server = $Server
            Credential = $Credential
            Name = 'MyFolder'
            Location = ''
            Ensure = 'Absent'
            DependsOn = "[DatacenterFolder]MyDatacentersFolder"
        }
    }
}
```
