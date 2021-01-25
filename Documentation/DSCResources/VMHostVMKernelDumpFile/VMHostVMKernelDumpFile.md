# VMHostVMKernelDumpFile

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Credential** | Mandatory | PSCredential | The credentials needed for connection to the specified Server. ||
| **Name** | Key | string | The name of the VMHost. ||
| **DatastoreName** | Key | string | The name of the datastore for the dump file. ||
| **FileName** | Key | string | The file name of the dump file. ||
| **Ensure** | Mandatory | Ensure | Specifies whether the VMKernel dump Vmfs file should be present or absent. ||
| **Size** | Optional | long | The size in MB of the dump file. If not provided, a default size for the current machine is calculated. ||
| **Force** | Optional | bool | Specifies whether to deactivate and unconfigure the dump file being removed. This option is required if the file is active. ||

## Description

The resource is used to create and remove VMKernel dump files on the specified Datastore on the specified VMHost.

## Examples

### Example 1

Creates VMKernel dump file **MyDumpFile** with size **1181 MB** on Datastore **MyDatastore** on the specified VMHost.

```powershell
Configuration VMHostVMKernelDumpFile_CreateVMKernelDumpFile_Config {
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
        $Name
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostVMKernelDumpFile VMHostVMKernelDumpFile {
            Server = $Server
            Credential = $Credential
            Name = $Name
            DatastoreName = 'MyDatastore'
            FileName = 'MyDumpFile'
            Size = 1181
            Ensure = 'Present'
        }
    }
}
```

### Example 2

Removes the VMKernel dump file **MyDumpFile** on Datastore **MyDatastore** on the specified VMHost.

```powershell
Configuration VMHostVMKernelDumpFile_RemoveVMKernelDumpFile_Config {
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
        $Name
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostVMKernelDumpFile VMHostVMKernelDumpFile {
            Server = $Server
            Credential = $Credential
            Name = $Name
            DatastoreName = 'MyDatastore'
            FileName = 'MyDumpFile'
            Ensure = 'Absent'
            Force = $true
        }
    }
}
```
