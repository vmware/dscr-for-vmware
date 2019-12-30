# VMHostConfiguration

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Credential** | Mandatory | PSCredential | The credentials needed for connection to the specified Server. ||
| **Name** | Key | string | The name of the VMHost. ||
| **State** | Optional | VMHostState | The state of the VMHost. If there are powered on VMs on the VMHost, the VMHost can be set into Maintenance mode, only if it is a part of a Drs-enabled Cluster. Before entering Maintenance mode, if the VMHost is fully automated, all powered on VMs are relocated. If the VMHost is not fully automated, a Drs recommendation is generated and all powered on VMs are relocated or powered off. | Connected, Disconnected, Maintenance |
| **Evacuate** | Optional | bool | If the value is $true, vCenter Server system automatically reregisters the VMs that are compatible for reregistration. If they are not compatible, they remain on the VMHost. The Evacuate property is valid only when the connection is to a vCenter Server system and the State property is **Maintenance**. Also, the VMHost must be in a Drs-enabled Cluster. ||
| **VsanDataMigrationMode** | Optional | VsanDataMigrationMode | The special action to take regarding Virtual SAN data when moving in Maintenance mode. The VsanDataMigrationMode property is valid only when the connection is to a vCenter Server system and the State property is **Maintenance**. | Full, EnsureAccessibility, NoDataMigration |
| **LicenseKey** | Optional | string | The license key to be used by the VMHost. You can set the VMHost to evaluation mode by passing the **00000-00000-00000-00000-00000** evaluation key. ||
| **TimeZoneName** | Optional | string | The name of the Time Zone for the VMHost. ||
| **VMSwapfileDatastoreName** | Optional | string | The name of the Datastore that is visible to the VMHost and can be used for storing swapfiles for the VMs that run on the VMHost. Using a VMHost-specific swap location might degrade the VMotion performance. ||
| **VMSwapfilePolicy** | Optional | VMSwapfilePolicy | The swapfile placement policy. | InHostDatastore, WithVM |
| **HostProfileName** | Optional | string | The name of the host profile associated with the VMHost. If the value is an empty string, the current profile association should not exist. ||
| **KmsClusterName** | Optional | string | The name of the KmsCluster which is used to generate a key to set the VMHost. If the property is passed and the VMHost is not in CryptoSafe state, the DSC Resource makes the VMHost CryptoSafe. If the property is passed and the VMHost is already in CryptoSafe state, the DSC Resource resets the CryptoKey in the VMHost. ||

## Description

The resource is used to modify the configuration of the specified VMHost.

## Examples

### Example 1

Creates Vmfs Datastore **MyVmfsDatastore** on the specified VMHost. Sets the VMHost to evaluation mode by passing the **00000-00000-00000-00000-00000** evaluation key. Modifies the Time Zone to be **UTC**, and the VM swapfile settings - uses Datastore **MyVmfsDatastore** for storing the swapfiles and **InHostDatastore** for swapfile placement policy.

```powershell
Configuration VMHostConfiguration_ModifyVMHostLicenseKeyTimeZoneVMSwapfileDatastoreAndPolicy_Config {
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
        VmfsDatastore VmfsDatastore {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            Name = 'MyVmfsDatastore'
            Path = $ScsiLunCanonicalName
            Ensure = 'Present'
        }

        VMHostConfiguration VMHostConfiguration {
            Server = $Server
            Credential = $Credential
            Name = $VMHostName
            LicenseKey = '00000-00000-00000-00000-00000'
            TimeZoneName = 'UTC'
            VMSwapfileDatastoreName = 'MyVmfsDatastore'
            VMSwapfilePolicy = 'InHostDatastore'
            DependsOn = '[VmfsDatastore]VmfsDatastore'
        }
    }
}
```

### Example 2

Sets the VMHost into **Maintenance** mode. The vCenter Server system automatically reregisters the VMs that are compatible for reregistration. If they are not compatible, they remain on the VMHost. The special action to take regarding Virtual SAN data when moving in **Maintenance** mode is **Full**.

```powershell
Configuration VMHostConfiguration_ModifyVMHostState_Config {
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
        $Name
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostConfiguration VMHostConfiguration {
            Server = $Server
            Credential = $Credential
            Name = $Name
            State = 'Maintenance'
            Evacuate = $true
            VsanDataMigrationMode = 'Full'
        }
    }
}
```

### Example 3

Associates the specified Host Profile with the specified VMHost.

```powershell
Configuration VMHostConfiguration_ModifyVMHostHostProfileAssociation_Config {
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
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $HostProfileName
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostConfiguration VMHostConfiguration {
            Server = $Server
            Credential = $Credential
            Name = $Name
            HostProfileName = $HostProfileName
        }
    }
}
```

### Example 4

If the VMHost is not in **CryptoSafe** state, the DSC Resource makes the VMHost **CryptoSafe**. If the VMHost is already in **CryptoSafe** state, the DSC Resource resets the **CryptoKey** in the VMHost.

```powershell
Configuration VMHostConfiguration_ModifyVMHostCryptoKey_Config {
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
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $KmsClusterName
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostConfiguration VMHostConfiguration {
            Server = $Server
            Credential = $Credential
            Name = $Name
            KmsClusterName = $KmsClusterName
        }
    }
}
```
