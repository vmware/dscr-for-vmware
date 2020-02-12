# VMHostIScsiHbaTarget

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Credential** | Mandatory | PSCredential | The credentials needed for connection to the specified Server. ||
| **VMHostName** | Key | string | The name of the VMHost. ||
| **Address** | Key | string | The address of the iSCSI Host Bus Adapter target. ||
| **Port** | Key | int | The TCP port of the iSCSI Host Bus Adapter target. ||
| **IScsiHbaName** | Key | string | The name of the iSCSI Host Bus Adapter of the iSCSI Host Bus Adapter target. ||
| **TargetType** | Key | IScsiHbaTargetType | The type of the iSCSI Host Bus Adapter target. | Static, Send |
| **Ensure** | Mandatory | Ensure | Specifies whether the iSCSI Host Bus Adapter target should be present or absent. | Present, Absent |
| **IScsiName** | Optional | string | The iSCSI name of the iSCSI Host Bus Adapter target. It is required for Static iSCSI Host Bus Adapter targets. ||
| **ChapType** | Optional | ChapType | The type of the CHAP (Challenge Handshake Authentication Protocol). | Prohibited, Discouraged, Preferred, Required |
| **InheritChap** | Optional | bool | Indicates that the CHAP setting is inherited from the iSCSI Host Bus Adapter. ||
| **ChapName** | Optional | string | The CHAP authentication name. ||
| **ChapPassword** | Optional | string | The CHAP authentication password. ||
| **InheritMutualChap** | Optional | bool | Indicates that the Mutual CHAP setting is inherited from the iSCSI Host Bus Adapter. ||
| **MutualChapEnabled** | Optional | bool | Indicates that Mutual CHAP is enabled. ||
| **MutualChapName** | Optional | string | The Mutual CHAP authentication name. ||
| **MutualChapPassword** | Optional | string | The Mutual CHAP authentication password. ||
| **Force** | Optional | bool | Specifies whether to change the password for CHAP, Mutual CHAP or both. When the property is not specified or its value is **$false**, it is ignored. If the property is **$true** the passwords for CHAP and Mutual CHAP are changed to their desired values. ||

## Description

The resource is used to create, modify the CHAP settings and remove iSCSI Host Bus Adapter targets from the specified iSCSI Host Bus Adapter.

## Examples

### Example 1

Creates a new iSCSI Host Bus Adapter Send target with address **10.23.84.73** on port **3260** for the specified iSCSI Host Bus Adapter. Also it configures the CHAP settings of the iSCSI Host Bus Adapter target by specifiying the CHAP type as **Required** with CHAP name **AdminOne** and CHAP password **AdminPasswordOne**. The Mutual CHAP is enabled with Mutual CHAP name **AdminTwo** and Mutual CHAP password **AdminPasswordTwo**. CHAP and Mutual CHAP settings are not inherited from the iSCSI Host Bus Adapter.

```powershell
Configuration VMHostIScsiHbaTarget_CreateIScsiHostBusAdapterSendTargetWithRequiredChapType_Config {
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
        $IScsiHbaName
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostIScsiHbaTarget VMHostIScsiHbaTarget {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            Address = '10.23.84.73'
            Port = 3260
            IScsiHbaName = $IScsiHbaName
            TargetType = 'Send'
            Ensure = 'Present'
            InheritChap = $false
            ChapType = 'Required'
            ChapName = 'AdminOne'
            ChapPassword = 'AdminPasswordOne'
            InheritMutualChap = $false
            MutualChapEnabled = $true
            MutualChapName = 'AdminTwo'
            MutualChapPassword = 'AdminPasswordTwo'
        }
    }
}
```

### Example 2

Creates a new iSCSI Host Bus Adapter Static target with address **10.23.84.73** on port **3260** with the specified iSCSI name for the specified iSCSI Host Bus Adapter. CHAP and Mutual CHAP settings are inherited from the iSCSI Host Bus Adapter.

```powershell
Configuration VMHostIScsiHbaTarget_CreateIScsiHostBusAdapterStaticTargetWithInheritedChapSettings_Config {
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
        $IScsiHbaName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $IScsiName
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostIScsiHbaTarget VMHostIScsiHbaTarget {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            Address = '10.23.84.73'
            Port = 3260
            IScsiHbaName = $IScsiHbaName
            TargetType = 'Static'
            Ensure = 'Present'
            IScsiName = $IScsiName
            InheritChap = $true
            InheritMutualChap = $true
        }
    }
}
```

### Example 3

Removes the iSCSI Host Bus Adapter Send target with address **10.23.84.73** on port **3260** from the specified iSCSI Host Bus Adapter.

```powershell
Configuration VMHostIScsiHbaTarget_RemoveIScsiHostBusAdapterSendTarget_Config {
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
        $IScsiHbaName
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostIScsiHbaTarget VMHostIScsiHbaTarget {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            Address = '10.23.84.73'
            Port = 3260
            IScsiHbaName = $IScsiHbaName
            TargetType = 'Send'
            Ensure = 'Absent'
        }
    }
}
```
