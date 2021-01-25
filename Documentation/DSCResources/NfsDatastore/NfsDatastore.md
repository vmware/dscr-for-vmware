# NfsDatastore

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Credential** | Mandatory | PSCredential | The credentials needed for connection to the specified Server. ||
| **VMHostName** | Key | string | The name of the VMHost which is going to be used. ||
| **Name** | Key | string | The name of the Nfs Datastore. ||
| **Path** | Mandatory | string | The remote path of the Nfs mount point. ||
| **Ensure** | Mandatory | Ensure | Specifies whether the Nfs Datastore should be present or absent. | Present, Absent |
| **NfsHost** | Mandatory | string[] | The Nfs Host for the Datastore. ||
| **FileSystemVersion** | Optional | string | The file system that is used on the Nfs Datastore. ||
| **AccessMode** | Optional | AccessMode | The access mode for the Nfs Datastore. The default access mode is **ReadWrite**. | ReadWrite, ReadOnly |
| **AuthenticationMethod** | Optional | AuthenticationMethod | The authentication method for the Nfs Datastore. The default authentication method is **AUTH_SYS**. | AUTH_SYS, Kerberos |
| **CongestionThresholdMillisecond** | Optional | int | The latency period beyond which the storage array is considered congested. The range of this value is between 10 to 100 milliseconds. ||
| **StorageIOControlEnabled** | Optional | bool | Indicates whether the IO control is enabled. ||

## Description

The resource is used to create, modify and remove Nfs Datastores on the specified Nfs Host and VMHost.

## Examples

### Example 1

Creates Nfs Datastore **MyNfsDatastore** with **version 3** File System on the specified Nfs Host and VMHost. The access mode is **ReadOnly** and the Authentication method is **AUTH_SYS**.

```powershell
Configuration NfsDatastore_CreateNfsDatastoreWithReadOnlyAccessMode_Config {
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
        [string[]]
        $NfsHost,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $NfsPath
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        NfsDatastore NfsDatastore {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            Name = 'MyNfsDatastore'
            Path = $NfsPath
            Ensure = 'Present'
            NfsHost = $NfsHost
            FileSystemVersion = '3'
            AccessMode = 'ReadOnly'
            AuthenticationMethod = 'AUTH_SYS'
        }
    }
}
```

### Example 2

Creates or modifies Nfs Datastore **MyNfsDatastore** with **version 3** File System on the specified Nfs Host and VMHost. The access mode is **ReadWrite** and the Authentication method is **AUTH_SYS**. The StorageIOControl is **enabled** and the latency period beyond which the storage array is considered congested is **10 milliseconds**.

```powershell
Configuration NfsDatastore_CreateNfsDatastoreWithReadWriteAccessMode_Config {
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
        [string[]]
        $NfsHost,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $NfsPath
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        NfsDatastore NfsDatastore {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            Name = 'MyNfsDatastore'
            Path = $NfsPath
            Ensure = 'Present'
            NfsHost = $NfsHost
            FileSystemVersion = '3'
            AccessMode = 'ReadWrite'
            AuthenticationMethod = 'AUTH_SYS'
            StorageIOControlEnabled = $true
            CongestionThresholdMillisecond = 10
        }
    }
}
```

### Example 3

Removes Nfs Datastore **MyNfsDatastore** from the specified Nfs Host and VMHost.

```powershell
Configuration NfsDatastore_RemoveNfsDatastore_Config {
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
        [string[]]
        $NfsHost,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $NfsPath
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        NfsDatastore NfsDatastore {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            Name = 'MyNfsDatastore'
            Path = $NfsPath
            Ensure = 'Absent'
            NfsHost = $NfsHost
        }
    }
}
```
