# vCenterVMHost

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The name of the Server we are trying to connect to. The Server can only be a vCenter. ||
| **Credential** | Mandatory | PSCredential | The credentials needed for connection to the specified Server. ||
| **Name** | Key | string | The name of the VMHost. ||
| **Location** | Key | string | The location in the vCenter Server system of the VMHost with name specified in **Name** key property in Datacenter specified in **DatacenterName** key property. Location consists of 0 or more Inventory Items. Empty location means that the VMHost is located in the Host Folder of the Datacenter. The Root Folders of the Datacenter are not part of the location. Inventory Item names in location are separated by '/'. Example location for the VMHost: 'MyFolder/MyCluster'. ||
| **DatacenterName** | Key | string | The name of the Datacenter where the VMHost is located. ||
| **DatacenterLocation** | Key | string | The location in the vCenter Server system of the Datacenter with name specified in **DatacenterName** key property. Location consists of 0 or more Folders. Empty location means that the Datacenter is located in the Root Folder of the Inventory. The Root Folder of the Inventory is not part of the location. Folder names in location are separated by '/'. Example location for Datacenter: 'MyDatacentersFolder'. ||
| **Ensure** | Mandatory | Ensure | Specifies whether the VMHost should be present or absent from the vCenter Server system. | Present, Absent |
| **VMHostCredential** | Mandatory | PSCredential | The credentials needed for authenticating with the VMHost. ||
| **ResourcePoolLocation** | Optional | string | The location of the Resource Pool in the Cluster. Location consists of 0 or more Resource Pools. The Root Resource Pool of the Cluster is not part of the location. If '/' location is passed, the Resource Pool is the Root Resource Pool of the Cluster. Resource Pools names in the location are separated by '/'. The VMHost's Root Resource Pool becomes the last Resource Pool specified in the location and the VMHost Resource Pool hierarchy is imported into the new nested Resource Pool. Example location for a Resource Pool: 'MyResourcePoolOne/MyResourcePoolTwo'. ||
| **Port** | Optional | int | The port on the VMHost used for the connection. ||
| **Force** | Optional | bool | Indicates whether the VMHost is added to the vCenter if the authenticity of the VMHost SSL certificate cannot be verified. ||

## Description

The resource is used to add, move to another location or remove VMHosts on the specified vCenter Server system.

## Examples

### Example 1

Creates Datacenter **MyDatacenter** in the Root Folder of the specified Inventory. Creates Folder **MyFolder** in the Host Folder of Datacenter **MyDatacenter**. Creates Cluster **MyCluster** located in Folder **MyFolder** in Datacenter **MyDatacenter**. Adds the specified VMHost to Cluster **MyCluster**. The port for connecting to the VMHost is specified to be **443**. **Force** is used to ignore the invalid SSL certificate of the VMHost.

```powershell
Configuration vCenterVMHost_AddVMHostTovCenter_Config {
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
        $VMHostName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $VMHostCredential
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        Datacenter Datacenter {
            Server = $Server
            Credential = $Credential
            Name = 'MyDatacenter'
            Location = ''
            Ensure = 'Present'
        }

        Folder Folder {
            Server = $Server
            Credential = $Credential
            Name = 'MyFolder'
            Location = ''
            DatacenterName = 'MyDatacenter'
            DatacenterLocation = ''
            Ensure = 'Present'
            FolderType = 'Host'
            DependsOn = '[Datacenter]Datacenter'
        }

        Cluster Cluster {
            Server = $Server
            Credential = $Credential
            Name = 'MyCluster'
            Location = 'MyFolder'
            DatacenterName = 'MyDatacenter'
            DatacenterLocation = ''
            Ensure = 'Present'
            DependsOn = '[Folder]Folder'
        }

        vCenterVMHost vCenterVMHost {
            Server = $Server
            Credential = $Credential
            Name = $VMHostName
            Location = 'MyFolder/MyCluster'
            DatacenterName = 'MyDatacenter'
            DatacenterLocation = ''
            Ensure = 'Present'
            VMHostCredential = $VMHostCredential
            Port = 443
            Force = $true
            DependsOn = '[Cluster]Cluster'
        }
    }
}
```

### Example 2

Creates Datacenter **MyDatacenter** in the Root Folder of the specified Inventory. Creates Folder **MyFolder** in the Host Folder of Datacenter **MyDatacenter**. Creates Cluster **MyCluster** located in Folder **MyFolder** in Datacenter **MyDatacenter** and enables Drs. Adds the specified VMHost to Cluster **MyCluster**. The port for connecting to the VMHost is specified to be **443**. **Force** is used to ignore the invalid SSL certificate of the VMHost. The VMHost's Root Resource Pool becomes the Resource Pool **Resources** that is the Root Resource Pool of Cluster **MyCluster** and the VMHost Resource Pool hierarchy is imported into the new nested Resource Pool.

```powershell
Configuration vCenterVMHost_AddVMHostTovCenterAndImportResourcePoolHierarchy_Config {
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
        $VMHostName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $VMHostCredential
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        Datacenter Datacenter {
            Server = $Server
            Credential = $Credential
            Name = 'MyDatacenter'
            Location = ''
            Ensure = 'Present'
        }

        Folder Folder {
            Server = $Server
            Credential = $Credential
            Name = 'MyFolder'
            Location = ''
            DatacenterName = 'MyDatacenter'
            DatacenterLocation = ''
            Ensure = 'Present'
            FolderType = 'Host'
            DependsOn = '[Datacenter]Datacenter'
        }

        Cluster Cluster {
            Server = $Server
            Credential = $Credential
            Name = 'MyCluster'
            Location = 'MyFolder'
            DatacenterName = 'MyDatacenter'
            DatacenterLocation = ''
            Ensure = 'Present'
            DrsEnabled = $true
            DependsOn = '[Folder]Folder'
        }

        vCenterVMHost vCenterVMHost {
            Server = $Server
            Credential = $Credential
            Name = $VMHostName
            Location = 'MyFolder/MyCluster'
            DatacenterName = 'MyDatacenter'
            DatacenterLocation = ''
            Ensure = 'Present'
            VMHostCredential = $VMHostCredential
            ResourcePoolLocation = '/'
            Port = 443
            Force = $true
            DependsOn = '[Cluster]Cluster'
        }
    }
}
```

### Example 3

Removes the specified VMHost located in Datacenter **Datacenter** from the specified vCenter Server.

```powershell
Configuration vCenterVMHost_RemoveVMHostFromvCenter_Config {
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
        $VMHostName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $VMHostCredential
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        vCenterVMHost vCenterVMHost {
            Server = $Server
            Credential = $Credential
            Name = $VMHostName
            Location = ''
            DatacenterName = 'Datacenter'
            DatacenterLocation = ''
            Ensure = 'Absent'
            VMHostCredential = $VMHostCredential
        }
    }
}
```
