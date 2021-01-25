# VMHostPciPassthrough

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | Name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Name** | Key | string | Name of the VMHost to configure. ||
| **Credential** | Mandatory | PSCredential | Credentials needed for connection to the specified Server. ||
| **Id** | Key | string | The Id of the PCI Device, composed of "bus:slot.function". ||
| **Enabled** | Mandatory | bool | Value indicating whether passThru has been configured for this device. ||
| **RestartTimeoutMinutes** | Optional | int | The time in minutes to wait for the VMHost to restart before timing out and aborting the operation. The default value is 5 minutes. ||

## Prerequisite

The specified VMHost must be in **Maintenance** mode.

## Description

The resource is used to update the PciPassthru configuration by changing the Passthrough enabled value of the specified PCI Device on the specified VMHost. The resource also restarts the VMHost after a successful Update operation.

## Examples

### Example 1

Performs an Update operation by enabling Passthrough on the specified PCI Device. After that it restarts the specified VMHost to apply the changes.

```powershell
Configuration VMHostPciPassthrough_Config {
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
        VMHostPciPassthrough VMHostPciPassthrough {
            Name = $Name
            Server = $Server
            Credential = $Credential
            Id = '0000:00:00.0'
            Enabled = $true
            RestartTimeoutMinutes = 10
        }
    }
}
```
