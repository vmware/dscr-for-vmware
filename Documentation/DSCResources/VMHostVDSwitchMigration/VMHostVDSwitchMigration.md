# VMHostVDSwitchMigration

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The name of the Server we are trying to connect to. The Server can only be a vCenter. ||
| **Credential** | Mandatory | PSCredential | The credentials needed for connection to the specified Server. ||
| **VMHostName** | Key | string | The name of the VMHost which is going to be used. ||
| **VdsName** | Key | string | The name of the vSphere Distributed Switch to which the VMHost and its Network should be part of. VMHost Network consists of the passed Physical Network Adapters, VMKernel Network Adapters and Port Groups. ||
| **PhysicalNicNames** | Mandatory | string[] | The names of the Physical Network Adapters that should be part of the vSphere Distributed Switch. ||
| **VMKernelNicNames** | Optional | string[] | The names of the VMKernel Network Adapters that should be part of the vSphere Distributed Switch. ||
| **PortGroupNames** | Optional | string[] | The names of the Port Groups to which the specified VMKernel Network Adapters should be attached. Accepts either one Port Group or the same number of Port Groups as the number of VMKernel Network Adapters specified. If one Port Group is specified, all Adapters are attached to that Port Group. If the same number of Port Groups as the number of VMKernel Network Adapters are specified, the first Adapter is attached to the first Port Group, the second Adapter to the second Port Group, and so on. ||

## Description

The resource is used to migrate Physical Network Adapters and VMKernel Network Adapters attached to the specified Port Groups to the specified vSphere Distributed Switch. If the specified VMHost is not part of the vSphere Distributed Switch, the DSC Resource takes care to add it before performing the migration process. If the specified Port Groups are not present on the vSphere Distributed Switch, they are created before performing the migration process.

## Examples

### Example 1

Migrates Physical Network Adapters **vmnic0** and **vmnic1** to vSphere Distributed Switch **MyVDSwitch**.

```powershell
Configuration VMHostVDSwitchMigration_MigratePhysicalNics_Config {
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
        $VMHostName
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostVDSwitchMigration VMHostVDSwitchMigration {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            VdsName = 'MyVDSwitch'
            PhysicalNicNames = @('vmnic0', 'vmnic1')
        }
    }
}
```

### Example 2

Migrates Physical Network Adapters **vmnic0** and **vmnic1** to vSphere Distributed Switch **MyVDSwitch**. Migrates VMKernel Network Adapters **vmk0** and **vmk1** to vSphere Distributed Switch **MyVDSwitch** and attaches them to Port Group **Management Network**.

```powershell
Configuration VMHostVDSwitchMigration_MigratePhysicalNicsAndVMKernelNicsAttachedToTheSamePortGroup_Config {
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
        $VMHostName
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostVDSwitchMigration VMHostVDSwitchMigration {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            VdsName = 'MyVDSwitch'
            PhysicalNicNames = @('vmnic0', 'vmnic1')
            VMKernelNicNames = @('vmk0', 'vmk1')
            PortGroupNames = @('Management Network')
        }
    }
}
```

### Example 3

Migrates Physical Network Adapters **vmnic0** and **vmnic1** to vSphere Distributed Switch **MyVDSwitch**. Migrates VMKernel Network Adapters **vmk0** and **vmk1** to vSphere Distributed Switch **MyVDSwitch** and attaches them to Port Groups **Management Network** and **VM Network** respectively.

```powershell
Configuration VMHostVDSwitchMigration_MigratePhysicalNicsAndVMKernelNicsAttachedToDifferentPortGroups_Config {
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
        $VMHostName
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostVDSwitchMigration VMHostVDSwitchMigration {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            VdsName = 'MyVDSwitch'
            PhysicalNicNames = @('vmnic0', 'vmnic1')
            VMKernelNicNames = @('vmk0', 'vmk1')
            PortGroupNames = @('Management Network', 'VM Network')
        }
    }
}
```
