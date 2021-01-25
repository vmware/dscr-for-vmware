# VMHostGraphicsDevice

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | Name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Name** | Key | string | Name of the VMHost to configure. ||
| **Credential** | Mandatory | PSCredential | Credentials needed for connection to the specified Server. ||
| **Id** | Key | string | The Graphics device identifier (ex. PCI ID). ||
| **GraphicsType** | Mandatory | GraphicsType | The graphics type for the specified Device in 'Id' property. | Shared, SharedDirect |
| **RestartTimeoutMinutes** | Optional | int | The time in minutes to wait for the VMHost to restart before timing out and aborting the operation. The default value is 5 minutes. ||

## Prerequisite

The specified VMHost must be in **Maintenance** mode.

## Description

The resource is used to update the Graphics Type of the specified Graphics Device. The resource also restarts the VMHost after a successful Update operation.

## Examples

### Example 1

Performs an Update operation by setting the Graphics Type for the specified device to **SharedDirect**. After that it restarts the specified VMHost to apply the changes.

```powershell
Configuration VMHostGraphicsDevice_Config {
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
        VMHostGraphicsDevice VMHostGraphicsDevice {
            Name = $Name
            Server = $Server
            Credential = $Credential
            Id = '0000:00:00.0'
            GraphicsType = 'SharedDirect'
            RestartTimeoutMinutes = 10
        }
    }
}
```
