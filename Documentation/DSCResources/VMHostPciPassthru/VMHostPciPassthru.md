# VMHostPciPassthru

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | Name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Name** | Key | string | Name of the VMHost to configure. ||
| **Credential** | Mandatory | PSCredential | Credentials needed for connection to the specified Server. ||
| **Id** | Mandatory | string | The Id of the PCI Device, composed of "bus:slot.function". ||
| **Enabled** | Mandatory | bool | Value indicating whether passThru has been configured for this device. ||

## Description
The resource is used to update the PciPassthru configuration by changing the Passthrough enabled value of the specified PCI Device on the specified VMHost.

## Examples

### Example 1

Performs an Update operation by enabling Passthrough on the specified PCI Device.

```powershell
Configuration VMHostPciPassthru_Config {
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Server,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $Credential
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostPciPassthru VMHostPciPassthru {
            Name = $Name
            Server = $Server
            Credential = $Credential
            Id = '0000:00:00.0'
            Enabled = $true
        }
    }
}
```
