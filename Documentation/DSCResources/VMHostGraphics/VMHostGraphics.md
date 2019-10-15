# VMHostGraphics

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | Name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Name** | Key | string | Name of the VMHost to configure. ||
| **Credential** | Mandatory | PSCredential | Credentials needed for connection to the specified Server. ||
| **GraphicsType** | Mandatory | GraphicsType | The default graphics type for the specified VMHost. | Shared, SharedDirect |
| **SharedPassthruAssignmentPolicy** | Mandatory | SharedPassthruAssignmentPolicy | The policy for assigning shared passthrough VMs to a host graphics device. | Performance, Consolidation |
| **RestartTimeoutMinutes** | Optional | int | The time in minutes to wait for the VMHost to restart before timing out and aborting the operation. The default value is 5 minutes. ||

## Prerequisite

The specified VMHost must be in **Maintenance** mode.

## Description

The resource is used to update the Graphics configuration by changing the DefaultGraphicsType and SharedPassthruAssignmentPolicy values. The resource also restarts the VMHost after a successful Update operation.

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
            GraphicsType = 'Shared'
            SharedPassthruAssignmentPolicy = 'Performance'
            RestartTimeoutMinutes = 10
        }
    }
}
```
