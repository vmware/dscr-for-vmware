# VMHostIScsiHba

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Credential** | Mandatory | PSCredential | The credentials needed for connection to the specified Server. ||
| **VMHostName** | Key | string | The name of the VMHost. ||
| **Name** | Key | string | The name of the iSCSI Host Bus Adapter. ||
| **ChapType** | Optional | ChapType | The type of the CHAP (Challenge Handshake Authentication Protocol). | Prohibited, Discouraged, Preferred, Required |
| **ChapName** | Optional | string | The CHAP authentication name. ||
| **ChapPassword** | Optional | string | The CHAP authentication password. ||
| **MutualChapEnabled** | Optional | bool | Indicates that Mutual CHAP is enabled. ||
| **MutualChapName** | Optional | string | The Mutual CHAP authentication name. ||
| **MutualChapPassword** | Optional | string | The Mutual CHAP authentication password. ||
| **Force** | Optional | bool | Specifies whether to change the password for CHAP, Mutual CHAP or both. When the property is not specified or its value is **$false**, it is ignored. If the property is **$true** the passwords for CHAP and Mutual CHAP are changed to their desired values. ||

## Description

The resource is used to modify the CHAP settings of the specified iSCSI Host Bus Adapter on the specified VMHost.

## Examples

### Example 1

Configures the CHAP settings of the specified iSCSI Host Bus Adapter by specifiying the CHAP type as **Required** with CHAP name **AdminOne** and CHAP password **AdminPasswordOne**.
Also the Mutual CHAP is enabled with Mutual CHAP name **AdminTwo** and Mutual CHAP password **AdminPasswordTwo**.

```powershell
Configuration VMHostIScsiHba_ConfigureCHAPSettingsOfIScsiHostBusAdapterWithRequiredChapType_Config {
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
        VMHostIScsiHba VMHostIScsiHba {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            Name = $IScsiHbaName
            ChapType = 'Required'
            ChapName = 'AdminOne'
            ChapPassword = 'AdminPasswordOne'
            MutualChapEnabled = $true
            MutualChapName = 'AdminTwo'
            MutualChapPassword = 'AdminPasswordTwo'
        }
    }
}
```

### Example 2

Configures the CHAP settings of the specified iSCSI Host Bus Adapter by specifiying the CHAP type as **Prohibited**.

```powershell
Configuration VMHostIScsiHba_ConfigureCHAPSettingsOfIScsiHostBusAdapterWithProhibitedChapType_Config {
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
        VMHostIScsiHba VMHostIScsiHba {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            Name = $IScsiHbaName
            ChapType = 'Prohibited'
        }
    }
}
```
