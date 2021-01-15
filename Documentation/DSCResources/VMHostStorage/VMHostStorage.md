# VMHostStorage

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Credential** | Mandatory | PSCredential | The credentials needed for connection to the specified Server. ||
| **Name** | Key | string | The name of the VMHost. ||
| **Enabled** | Mandatory | bool | Whether the software iSCSI is enabled on the VMHost storage. ||

## Description

The resource is used to enable or disable the software iSCSI support for the specified VMHost.

## Examples

### Example 1

Enables the software iSCSI for the specified VMHost.

```powershell
Configuration VMHostStorage_EnableSoftwareIscsi_Config {
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
        $VMHostName
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostStorage VMHostStorage {
            Server = $Server
            Credential = $Credential
            Name = $VMHostName
            Enabled = $true
        }
    }
}
```
