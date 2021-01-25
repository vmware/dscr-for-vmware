# VMHostPowerPolicy

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | Name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Name** | Key | string | Name of the VMHost to configure. ||
| **Credential** | Mandatory | PSCredential | Credentials needed for connection to the specified Server. ||
| **PowerPolicy** | Mandatory | PowerPolicy | The Power Management Policy for the specified VMHost. | HighPerformance, Balanced, LowPower, Custom |

## Description

The resource is used to update the Power Management Policy of the specified VMHost.

## Examples

### Example 1

Performs an Update operation by setting the Power Management Policy of the specified VMHost to **Balanced**.

```powershell
Configuration VMHostPowerPolicy_Config {
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
        VMHostPowerPolicy VMHostPowerPolicy {
            Name = $Name
            Server = $Server
            Credential = $Credential
            PowerPolicy = 'Balanced'
        }
    }
}
```
