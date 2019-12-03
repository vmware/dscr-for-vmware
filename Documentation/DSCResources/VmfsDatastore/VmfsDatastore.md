# VmfsDatastore

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Credential** | Mandatory | PSCredential | The credentials needed for connection to the specified Server. ||
| **VMHostName** | Key | string | The name of the VMHost which is going to be used. ||
| **Name** | Key | string | The name of the Vmfs Datastore. ||
| **Path** | Mandatory | string | The canonical name of the Scsi logical unit that contains the Vmfs Datastore. ||
| **Ensure** | Mandatory | Ensure | Specifies whether the Vmfs Datastore should be present or absent. | Present, Absent |
| **FileSystemVersion** | Optional | string | The file system that is used on the Vmfs Datastore. ||
| **BlockSizeMB** | Optional | int | The maximum file size of Vmfs in megabytes (MB). If no value is specified, the maximum file size for the current system platform is used. ||
| **CongestionThresholdMillisecond** | Optional | int | The latency period beyond which the storage array is considered congested. The range of this value is between 10 to 100 milliseconds. ||
| **StorageIOControlEnabled** | Optional | bool | Indicates whether the IO control is enabled. ||

## Description

The resource is used to create, modify and remove Vmfs Datastores on the specified VMHost.

## Examples

### Example 1

Creates or modifies Vmfs Datastore **MyVmfsDatastore** with **version 5** File System and maximum file size of Vmfs: **1MB** on the specified VMHost. The StorageIOControl is **enabled** and the latency period beyond which the storage array is considered congested is **100 milliseconds**.

```powershell
Configuration VmfsDatastore_CreateVmfsDatastore_Config {
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
        [string]
        $ScsiLunCanonicalName
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VmfsDatastore VmfsDatastore {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            Name = 'MyVmfsDatastore'
            Path = $ScsiLunCanonicalName
            Ensure = 'Present'
            FileSystemVersion = '5'
            BlockSizeMB = 1
            StorageIOControlEnabled = $true
            CongestionThresholdMillisecond = 100
        }
    }
}
```

### Example 2

Removes Vmfs Datastore **MyVmfsDatastore** from the specified VMHost.

```powershell
Configuration VmfsDatastore_RemoveVmfsDatastore_Config {
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
        [string]
        $ScsiLunCanonicalName
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VmfsDatastore VmfsDatastore {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            Name = 'MyVmfsDatastore'
            Path = $ScsiLunCanonicalName
            Ensure = 'Absent'
        }
    }
}
```
