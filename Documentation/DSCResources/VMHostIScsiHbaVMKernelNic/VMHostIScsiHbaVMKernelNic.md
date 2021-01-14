# VMHostIScsiHbaVMKernelNic

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Credential** | Mandatory | PSCredential | The credentials needed for connection to the specified Server. ||
| **VMHostName** | Key | string | The name of the VMHost. ||
| **IScsiHbaName** | Key | string | The name of the iSCSI Host Bus Adapter. ||
| **VMKernelNicNames** | Mandatory | string[] | The names of the VMKernel Network Adapters that should be bound/unbound to/from the specified iSCSI Host Bus Adapter. ||
| **Ensure** | Mandatory | Ensure | Value indicating if the VMKernel Network Adapters should be bound/unbound to/from the specified iSCSI Host Bus Adapter. | Present, Absent |
| **Force** | Optional | bool | Whether to bind VMKernel Network Adapters to iSCSI Host Bus Adapter when VMKernel Network Adapters aren't compatible for iSCSI multipathing. Whether to unbind VMKernel Network Adapters from iSCSI Host Bus Adapter when there're active sessions using the VMKernel Network Adapters. ||

## Description

The resource is used to bind/unbind VMKernel Network Adapters to/from the specified iSCSI Host Bus Adapter.

## Examples

### Example 1

Binds the specified VMKernel Network Adapters to the specified iSCSI Host Bus Adapter.

```powershell
Configuration VMHostIScsiHbaVMKernelNic_BindVMKernelNicsToIscsiHba_Config {
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Server,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $User,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Password,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $VMHostName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $IScsiHbaName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $VMKernelNicNames
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostIScsiHbaVMKernelNic VMHostIScsiHbaVMKernelNic {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            IScsiHbaName = $IScsiHbaName
            VMKernelNicNames = $VMKernelNicNames
            Ensure = 'Present'
        }
    }
}
```

### Example 2

Unbinds the specified VMKernel Network Adapters from the specified iSCSI Host Bus Adapter.

```powershell
Configuration VMHostIScsiHbaVMKernelNic_UnbindVMKernelNicsToIscsiHba_Config {
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Server,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $User,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Password,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $VMHostName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $IScsiHbaName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $VMKernelNicNames
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostIScsiHbaVMKernelNic VMHostIScsiHbaVMKernelNic {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            IScsiHbaName = $IScsiHbaName
            VMKernelNicNames = $VMKernelNicNames
            Ensure = 'Absent'
            Force = $true
        }
    }
}
```
