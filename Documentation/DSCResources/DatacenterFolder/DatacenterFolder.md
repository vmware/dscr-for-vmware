# DatacenterFolder

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | Name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Credential** | Mandatory | PSCredential | Credentials needed for connection to the specified Server. ||
| **Name** | Key | string | Name of the Folder located in the Folder specified in the 'Location' property. ||
| **Location** | Key | string | Location of the Folder with name specified in 'Name' key property in the specified Inventory. Location consists of 0 or more Folders. Empty Location means that the Folder is in the Root Folder of the specified Inventory. The Root Folder of the Inventory is not part of the Location. Folder names in Location are separated by "/". Example Location for a Folder Inventory Item: "MyFolder/MyDatacentersFolder". ||
| **Ensure** | Mandatory | Ensure | Value indicating if the Folder should be Present or Absent. | Present, Absent |

## Description

The resource is used to create and delete Folders in a specified Inventory.

## Examples

### Example 1

The first Resource in the Configuration creates a new Folder 'MyFolder' in the Root Folder of the specified Inventory. The second Resource in the Configuration creates a new Folder 'MyDatacentersFolder' in the 'MyFolder' Folder.

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
    }
}
```

### Example 2

The first Resource in the Configuration removes the Folder 'MyDatacentersFolder' in the 'MyFolder' Folder. The second Resource in the Configuration removes the Folder 'MyFolder' in the Root Folder of the Inventory.

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
        DatacenterFolder MyDatacentersFolder {
            Server = $Server
            Credential = $Credential
            Name = 'MyDatacentersFolder'
            Location = 'MyFolder'
            Ensure = 'Absent'
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
