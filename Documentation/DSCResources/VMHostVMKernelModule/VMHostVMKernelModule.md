# VMHostVMKernelModule

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Credential** | Mandatory | PSCredential | The credentials needed for connection to the specified Server. ||
| **Name** | Key | string | The name of the VMHost. ||
| **Module** | Key | string | The name of the VMKernel module. ||
| **Enabled** | Mandatory | bool | Specifies whether the module should be enabled or disabled. ||
| **Force** | Optional | bool | Specifies whether to skip the VMkernel module validity checks. ||

## Description

The resource is used to enable and disable the specified VMKernel module on the specified VMHost.

## Examples

### Example 1

Enables the specified VMKernel module on the specified VMHost and skips the module validity checks.

```powershell
Configuration VMHostVMKernelModule_EnableVMKernelModule_Config {
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
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $VMKernelModule
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostVMKernelModule VMHostVMKernelModule {
            Server = $Server
            Credential = $Credential
            Name = $Name
            Module = $VMKernelModule
            Enabled = $true
            Force = $true
        }
    }
}
```
