# VMHostNetworkCoreDump

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Credential** | Mandatory | PSCredential | The credentials needed for connection to the specified Server. ||
| **Name** | Key | string | The name of the VMHost. ||
| **Enable** | Optional | bool | Specifies whether to enable network coredump. ||
| **InterfaceName** | Optional | string | The active interface to be used for the network coredump. ||
| **ServerIp** | Optional | string | The IP address of the coredump server (IPv4 or IPv6). ||
| **ServerPort** | Optional | long | The port on which the coredump server is listening. ||

## Description

The resource is used to modify the network coredump configuration of the specified VMHost.

## Examples

### Example 1

Modifies the configuration of the network coredump of the VMHost by setting the active interface to be the passed VMKernel Network Adapter, the IP address of the coredump server is **10.11.12.13**
and the port on which the coredump server is listening is **6500**. It also enables the network coredump.

```powershell
Configuration VMHostNetworkCoreDump_ModifyVMHostNetworkCoreDumpConfiguration_Config {
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
        $VMHostVMKernelNetworkAdapterName
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostNetworkCoreDump VMHostNetworkCoreDump {
            Server = $Server
            Credential = $Credential
            Name = $Name
            Enable = $true
            InterfaceName = $VMHostVMKernelNetworkAdapterName
            ServerIp = '10.11.12.13'
            ServerPort = 6500
        }
    }
}
```
