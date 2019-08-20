# VMHostGraphics

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | Name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Name** | Key | string | Name of the VMHost to configure. ||
| **Credential** | Mandatory | PSCredential | Credentials needed for connection to the specified Server. ||
| **DefaultGraphicsType** | Mandatory | GraphicsType | The default graphics type for the specified VMHost. This default value is overridden if an individual device graphics type is specified. If the specified VMHost supports a single graphics type, specifying an individual graphics device is optional. | Shared, SharedDirect |
| **SharedPassthruAssignmentPolicy** | Mandatory | SharedPassthruAssignmentPolicy | The policy for assigning shared passthrough VMs to a host graphics device. | Performance, Consolidation |
| **DeviceId** | Optional | string | The Graphics device identifier (ex. PCI ID). ||
| **DeviceGraphicsType** | Optional | GraphicsType | The graphics type for the specified Device in 'DeviceId' property. | Shared, SharedDirect, Unset |

## Prerequisite
The specified VMHost must be in **Maintenance** mode.

## Description
The resource is used to update the Graphics configuration by changing the DefaultGraphicsType and SharedPassthruAssignmentPolicy values. If a Graphics Device is specified it also changes its Graphics Type value. The resource also restarts the VMHost after a successful Update operation.

## Examples

### Example 1

Performs an Update operation by setting the DefaultGraphicsType to **Shared** and SharedPassthruAssignmentPolicy to **Performance**. After that it restarts the specified VMHost to apply the changes.

```powershell
Configuration VMHostGraphics_Config {
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
        VMHostGraphics VMHostGraphics {
            Name = $Name
            Server = $Server
            Credential = $Credential
            DefaultGraphicsType = 'Shared'
            SharedPassthruAssignmentPolicy = 'Performance'
        }
    }
}
```

### Example 2

Performs an Update operation by setting the DefaultGraphicsType to **Shared** and SharedPassthruAssignmentPolicy to **Consolidation**. It also changes the Graphics Type for the specified device to **SharedDirect**. After that it restarts the specified VMHost to apply the changes.

```powershell
Configuration VMHostGraphics_Config {
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
        VMHostGraphics VMHostGraphics {
            Name = $Name
            Server = $Server
            Credential = $Credential
            DefaultGraphicsType = 'Shared'
            SharedPassthruAssignmentPolicy = 'Consolidation'
            DeviceId = '0000:00:00.0'
            DeviceGraphicsType = 'SharedDirect'
        }
    }
}
```
