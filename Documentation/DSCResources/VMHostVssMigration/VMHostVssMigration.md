# VMHostVssMigration

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The name of the Server we are trying to connect to. The Server can only be a vCenter. ||
| **Credential** | Mandatory | PSCredential | The credentials needed for connection to the specified Server. ||
| **VMHostName** | Key | string | The name of the VMHost which is going to be used. ||
| **VssName** | Key | string | The name of the Standard Switch to which the passed Physical Network Adapters, VMKernel Network Adapters and Port Groups should be part of. ||
| **PhysicalNicNames** | Mandatory | string[] | The names of the Physical Network Adapters that should be part of the Standard Switch. ||
| **VMKernelNicNames** | Optional | string[] | The names of the VMKernel Network Adapters that should be part of the Standard Switch. ||
| **PortGroupNames** | Optional | string[] | The names of the Port Groups to which the specified VMKernel Network Adapters should be attached. Accepts the same number of Port Groups as the number of VMKernel Network Adapters specified. The first Adapter is attached to the first Port Group, the second Adapter to the second Port Group, and so on. ||

## Description

The resource is used to migrate Physical Network Adapters and VMKernel Network Adapters attached to the specified Port Groups to the specified Standard Switch. If the specified Port Groups are not present on the Standard Switch, they are created before performing the migration process.

## Examples

### Example 1

Migrates Physical Network Adapters **vmnic0** and **vmnic1** to Standard Switch **MyStandardSwitch**.

```powershell
Configuration VMHostVssMigration_MigratePhysicalNics_Config {
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
        VMHostVssMigration VMHostVssMigration {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            VssName = 'MyStandardSwitch'
            PhysicalNicNames = @('vmnic0', 'vmnic1')
        }
    }
}
```

### Example 2

Migrates Physical Network Adapters **vmnic0** and **vmnic1** to Standard Switch **MyStandardSwitch**. Migrates VMKernel Network Adapters **vmk0** and **vmk1** to Standard Switch **MyStandardSwitch** and attaches them to Port Groups **Management Network** and **VM Network** respectively.

```powershell
Configuration VMHostVssMigration_MigratePhysicalNicsAndVMKernelNicsWithPortGroups_Config {
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
        VMHostVssMigration VMHostVssMigration {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            VssName = 'MyStandardSwitch'
            PhysicalNicNames = @('vmnic0', 'vmnic1')
            VMKernelNicNames = @('vmk0', 'vmk1')
            PortGroupNames = @('Management Network', 'VM Network')
        }
    }
}
```

### Example 3

Migrates Physical Network Adapters **vmnic0** and **vmnic1** to Standard Switch **MyStandardSwitch**. Migrates VMKernel Network Adapters **vmk0** and **vmk1** to Standard Switch **MyStandardSwitch**. The VMKernel Network Adapters are attached to newly created Port Groups which name has the **VMKernel** prefix.

```powershell
Configuration VMHostVssMigration_MigratePhysicalNicsAndVMKernelNics_Config {
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
        VMHostVssMigration VMHostVssMigration {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            VssName = 'MyStandardSwitch'
            PhysicalNicNames = @('vmnic0', 'vmnic1')
            VMKernelNicNames = @('vmk0', 'vmk1')
        }
    }
}
```
