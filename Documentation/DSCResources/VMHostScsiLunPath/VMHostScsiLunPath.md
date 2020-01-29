# VMHostScsiLunPath

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Credential** | Mandatory | PSCredential | The credentials needed for connection to the specified Server. ||
| **VMHostName** | Key | string | The name of the VMHost. ||
| **Name** | Key | string | The name of the SCSI Lun path to the specified SCSI device in **ScsiLunCanonicalName** key property. ||
| **ScsiLunCanonicalName** | Key | string | The canonical name of the SCSI device for the specified SCSI Lun path in **Name** key property. ||
| **Active** | Optional | bool | Specifies whether the SCSI Lun path should be active. ||
| **Preferred** | Optional | bool | Specifies whether the SCSI Lun path should be preferred. Only one SCSI Lun path can be preferred, so when a SCSI Lun path is made preferred, the preference is removed from the previously preferred SCSI Lun path. ||

## Description

The resource is used to configure the specified SCSI Lun path to the specified SCSI device on the specified VMHost.

## Examples

### Example 1

Configures the specified SCSI Lun path to the specified SCSI device to be **Active** and **Preferred**.

```powershell
Configuration VMHostScsiLunPath_ConfigureScsiLunPathToBeActiveAndPreferred_Config {
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
        $VMHostName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ScsiLunCanonicalName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ScsiLunPathName
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostScsiLunPath VMHostScsiLunPath {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            Name = $ScsiLunPathName
            ScsiLunCanonicalName = $ScsiLunCanonicalName
            Active = $true
            Preferred = $true
        }
    }
}
```
