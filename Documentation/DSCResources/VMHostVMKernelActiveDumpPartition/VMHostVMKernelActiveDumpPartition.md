# VMHostVMKernelActiveDumpPartition

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Credential** | Mandatory | PSCredential | The credentials needed for connection to the specified Server. ||
| **Name** | Key | string | The name of the VMHost. ||
| **Enable** | Optional | bool | Specifies whether the VMKernel dump partition should be enabled or disabled. ||
| **Smart** | Optional | bool | Specifies whether to select the best available partition using the smart selection algorithm. Can only be used when **Enabled** property is specified with **$true** value. ||

## Description

The resource is used to enable and disable the VMKernel dump partition on the specified VMHost.

## Examples

### Example 1

Enables the VMKernel dump partition on the specified VMHost by selecting the best available partition using the smart selection algorithm.

```powershell
Configuration VMHostVMKernelActiveDumpPartition_EnableVMKernelDumpPartition_Config {
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
        VMHostVMKernelActiveDumpPartition VMHostVMKernelActiveDumpPartition {
            Server = $Server
            Credential = $Credential
            Name = $Name
            Enable = $true
            Smart = $true
        }
    }
}
```
