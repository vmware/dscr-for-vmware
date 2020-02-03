# VMHostScsiLun

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Credential** | Mandatory | PSCredential | The credentials needed for connection to the specified Server. ||
| **VMHostName** | Key | string | The name of the VMHost. ||
| **CanonicalName** | Key | string | The canonical name of the SCSI device. An example of a SCSI canonical name is **vmhba0:0:0:0**. ||
| **MultipathPolicy** | Optional | MultipathPolicy | The policy that the Lun must use when choosing a path. **Fixed** - uses the preferred SCSI Lun path whenever possible. **RoundRobin** - load balance. **MostRecentlyUsed** - uses the most recently used SCSI Lun path. | Fixed, RoundRobin, MostRecentlyUsed, Unknown |
| **PreferredScsiLunPathName** | Optional | string | The name of the preferred SCSI Lun path to access the SCSI Lun. ||
| **BlocksToSwitchPath** | Optional | int | The maximum number of I/O blocks to be issued on a given path before the system tries to select a different path. Modifying this setting affects all SCSI Lun devices that are connected to the same VMHost. The default value is **2048**. Setting this parameter to **zero (0)** disables switching based on blocks. ||
| **CommandsToSwitchPath** | Optional | int | The maximum number of I/O requests to be issued on a given path before the system tries to select a different path. Modifying this setting affects all SCSI Lun devices that are connected to the same VMHost. The default value is **50**. Setting this parameter to **zero (0)** disables switching based on commands. This parameter is not supported on vCenter Server **4.x.** ||
| **DeletePartitions** | Optional | bool | Specifies whether to remove all partitions from the SCSI disk. ||
| **IsLocal** | Optional | bool | Marks the SCSI disk as **local** or **remote**. If the value is **$true**, the SCSI disk is local. If the value is **$false**, the SCSI disk is remote. ||
| **IsSsd** | Optional | bool | Marks the SCSI disk as an **SSD** or **HDD**. If the value is **$true**, the SCSI disk is **SSD** type. If the value is **$false**, the SCSI disk is **HDD** type. ||

## Description

The resource is used to modify the configuration of the specified SCSI Lun on the specified VMHost.

## Examples

### Example 1

Modifies the configuration of the specified SCSI device by changing the Multipath policy to **RoundRobin**, the maximum number of I/O blocks to be issued on a given path to **2048**, the maximum number of I/O requests to be issued on a given path to **50**. The SCSI disk is marked as **local** and **SSD**.

```powershell
Configuration VMHostScsiLun_ModifyVMHostScsiLunConfigurationWithRoundRobinMultipathPolicy_Config {
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
        $ScsiLunCanonicalName
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostScsiLun VMHostScsiLun {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            CanonicalName = $ScsiLunCanonicalName
            MultipathPolicy = 'RoundRobin'
            BlocksToSwitchPath = 2048
            CommandsToSwitchPath = 50
            IsLocal = $true
            IsSsd = $true
        }
    }
}
```

### Example 2

Modifies the configuration of the specified SCSI device by changing the Multipath policy to **Fixed** and setting the preferred SCSI Lun path to access the SCSI Lun to be the specified SCSI Lun path.

```powershell
Configuration VMHostScsiLun_ModifyVMHostScsiLunConfigurationWithFixedMultipathPolicy_Config {
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
        VMHostScsiLun VMHostScsiLun {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            CanonicalName = $ScsiLunCanonicalName
            MultipathPolicy = 'Fixed'
            PreferredScsiLunPathName = $ScsiLunPathName
        }
    }
}
```

### Example 3

Removes all partitions from the specified SCSI disk.

```powershell
Configuration VMHostScsiLun_RemoveScsiDiskPartitions_Config {
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
        $ScsiLunCanonicalName
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostScsiLun VMHostScsiLun {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            CanonicalName = $ScsiLunCanonicalName
            DeletePartitions = $true
        }
    }
}
```
