# VMKernelDumpPartition

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Credential** | Mandatory | PSCredential | The credentials needed for connection to the specified Server. ||
| **Name** | Key | string | The name of the VMHost. ||
| **Enable** | Optional | bool | Specifies whether the VMKernel dump partition should be enabled or disabled. This option cannot be specified when unconfiguring the dump partition. ||
| **Smart** | Optional | bool | Specifies whether to select the best available partition using the smart selection algorithm. Can only be used when **Enabled** property is specified with **$true** value. ||
| **Unconfigure** | Optional | bool | Specifies whether the dump partition should go into an unconfigured state. It will remove the current configured dump partition for the next boot. It will result in the smart activate algorithm being used at the next boot. ||

## Description

The resource is used to enable, disable and unconfigure the VMKernel dump partition of the specified VMHost.

## Examples

### Example 1

Enables the VMKernel dump partition on the specified VMHost by selecting the best available partition using the smart selection algorithm.

```powershell
Configuration VMHostVMKernelDumpPartition_EnableVMKernelDumpPartition_Config {
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
        VMHostVMKernelDumpPartition VMHostVMKernelDumpPartition {
            Server = $Server
            Credential = $Credential
            Name = $Name
            Enable = $true
            Smart = $true
        }
    }
}
```

### Example 2

The VMKernel dump partition of the specified VMHost goes into an unconfigured state. Removes the current configured dump partition for the next boot.

```powershell
Configuration VMHostVMKernelDumpPartition_UnconfigureVMKernelDumpPartition_Config {
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
        VMHostVMKernelDumpPartition VMHostVMKernelDumpPartition {
            Server = $Server
            Credential = $Credential
            Name = $Name
            Unconfigure = $true
        }
    }
}
```
