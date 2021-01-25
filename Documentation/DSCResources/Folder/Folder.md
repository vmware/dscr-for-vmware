# Folder

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | Name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Credential** | Mandatory | PSCredential | Credentials needed for connection to the specified Server. ||
| **Name** | Key | string | Name of the Folder located in the Datacenter specified in 'DatacenterName' key property. ||
| **Location** | Key | string | Location of the Folder with name specified in 'Name' key property in the Datacenter specified in the 'DatacenterName' key property. Location consists of 0 or more Folders. Empty Location means that the Folder is in the Root Folder of the Datacenter specified in the 'FolderType' property. The Root Folders of the Datacenter are not part of the Location. Folder names in Location are separated by "/". Example Location for a Folder Inventory Item: "MyFolder/MyClustersFolder". ||
| **DatacenterName** | Key | string | Name of the Datacenter we will use from the specified Inventory. ||
| **DatacenterLocation** | Key | string | Location of the Datacenter we will use from the Inventory. Root Folder of the Inventory is not part of the Location. Empty Location means that the Datacenter is in the Root Folder of the Inventory. Folder names in Location are separated by "/". Example Location: "MyDatacentersFolder". ||
| **FolderType** | Key | FolderType | The type of Root Folder in the Datacenter in which the Folder is located. Possible values are VM, Network, Datastore, Host. ||
| **Ensure** | Mandatory | Ensure | Value indicating if the Folder should be Present or Absent. | Present, Absent |

## Description

The resource is used to create and delete Folders in a specified Datacenter.

## Examples

### Example 1

The first Resource in the Configuration creates a new Folder 'MyFolder' in the Datacenter 'Datacenter' in the Host Folder of the Datacenter. The second Resource in the Configuration creates a new Folder 'MyClustersFolder' in the Datacenter 'Datacenter' in 'MyFolder' Folder. The third Resource in the Configuration creates a new Folder 'MyHAClustersFolder' in the Datacenter 'Datacenter' in 'MyClustersFolder' Folder.

```powershell
Configuration Folder_Config {
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
        Folder MyFolder {
            Server = $Server
            Credential = $Credential
            Name = 'MyFolder'
            Location = ''
            DatacenterName = 'Datacenter'
            DatacenterLocation = ''
            Ensure = 'Present'
            FolderType = 'Host'
        }

        Folder MyClustersFolder {
            Server = $Server
            Credential = $Credential
            Name = 'MyClustersFolder'
            Location = 'MyFolder'
            DatacenterName = 'Datacenter'
            DatacenterLocation = ''
            Ensure = 'Present'
            FolderType = 'Host'
            DependsOn = "[Folder]MyFolder"
        }

        Folder MyHAClustersFolder {
            Server = $Server
            Credential = $Credential
            Name = 'MyHAClustersFolder'
            Location = 'MyFolder/MyClustersFolder'
            DatacenterName = 'Datacenter'
            DatacenterLocation = ''
            Ensure = 'Present'
            FolderType = 'Host'
            DependsOn = "[Folder]MyClustersFolder"
        }
    }
}
```

### Example 2

The first Resource in the Configuration removes the Folder 'MyHAClustersFolder' in the Datacenter 'Datacenter' in the 'MyClustersFolder' Folder. The second Resource in the Configuration removes the Folder 'MyClustersFolder' in the Datacenter 'Datacenter' in 'MyFolder' Folder. The third Resource in the Configuration removes the Folder 'MyFolder' in the Datacenter 'Datacenter' in the Host Folder of the Datacenter.

```powershell
Configuration Folder_Config {
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
        Folder MyHAClustersFolder {
            Server = $Server
            Credential = $Credential
            Name = 'MyHAClustersFolder'
            Location = 'MyFolder/MyClustersFolder'
            DatacenterName = 'Datacenter'
            DatacenterLocation = ''
            Ensure = 'Absent'
            FolderType = 'Host'
        }

        Folder MyClustersFolder {
            Server = $Server
            Credential = $Credential
            Name = 'MyClustersFolder'
            Location = 'MyFolder'
            DatacenterName = 'Datacenter'
            DatacenterLocation = ''
            Ensure = 'Absent'
            FolderType = 'Host'
            DependsOn = "[Folder]MyHAClustersFolder"
        }

        Folder MyFolder {
            Server = $Server
            Credential = $Credential
            Name = 'MyFolder'
            Location = ''
            DatacenterName = 'Datacenter'
            DatacenterLocation = ''
            Ensure = 'Absent'
            FolderType = 'Host'
            DependsOn = "[Folder]MyClustersFolder"
        }
    }
}
```
