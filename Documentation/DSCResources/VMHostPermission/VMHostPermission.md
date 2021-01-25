# VMHostPermission

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The name of the Server we are trying to connect to. The Server can only be an ESXi. ||
| **Credential** | Mandatory | PSCredential | The credentials needed for connection to the specified Server. ||
| **EntityName** | Key | string | The name of the Entity to which the Permission applies. ||
| **EntityLocation** | Key | string | The location of the Entity with name specified in **EntityName** key property. Location consists of 0 or more Inventory Items. When the Entity is a **Datacenter**, a **VMHost** or a **Datastore**, the property is ignored. If the Entity is a **Virtual Machine**, a **Resource Pool** or a **vApp** and empty location is passed, the Entity should be located in the Root Resource Pool of the VMHost. Inventory Item names in the location are separated by '/'. Example location for a **Datastore** Inventory Item: ''. Example location for a **Virtual Machine** Inventory Item: 'MyResourcePoolOne/MyResourcePoolTwo/MyvApp'. ||
| **EntityType** | Key | EntityType | The type of the Entity of the Permission. | Datacenter, VMHost, Datastore, VM, ResourcePool, VApp |
| **PrincipalName** | Key | string | The name of the User to which the Permission applies. If the User is a **Domain User**, the Principal name should be in one of the following formats: `<Domain Name>`/`<User name>` or `<User name>`@`<Domain Name>`. Example Principal name for Domain User: **MyDomain/MyDomainUser** or **MyDomainUser@MyDomain**. ||
| **RoleName** | Key | string | The name of the Role to which the Permission applies. ||
| **Ensure** | Mandatory | Ensure | Specifies whether the Permission should be present or absent. | Present, Absent |
| **Propagate** | Optional | bool | Specifies whether to propagate the Permission to the child Inventory Items. ||

## Description

The resource is used to create, modify and remove Permissions for the specified Entity, Principal and Role on the specified VMHost. If the **Propagate** property is not specified, the Permission is propagated to the child Inventory Items of the specified Entity.

## Examples

### Example 1

Creates or modifies the Permission for Datacenter Entity **ha-datacenter**, Principal **MyDscPrincipal** and Role **MyDscRole** on the specified VMHost. The Permission is propagated to the child Inventory Items of Datacenter Entity **ha-datacenter**.

```powershell
Configuration VMHostPermission_CreateVMHostPermissionForDatacenterEntity_Config {
    Param(
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
        VMHostPermission VMHostPermission {
            Server = $Server
            Credential = $Credential
            EntityName = 'ha-datacenter'
            EntityLocation = ''
            EntityType = 'Datacenter'
            PrincipalName = 'MyDscPrincipal'
            RoleName = 'MyDscRole'
            Ensure = 'Present'
            Propagate = $true
        }
    }
}
```

### Example 2

Creates or modifies the Permission for VMHost Entity, Principal **MyDscPrincipal** and Role **MyDscRole** on the specified VMHost. The Permission is not propagated to the child Inventory Items of VMHost Entity.

```powershell
Configuration VMHostPermission_CreateVMHostPermissionForVMHostEntity_Config {
    Param(
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
        VMHostPermission VMHostPermission {
            Server = $Server
            Credential = $Credential
            EntityName = $Server
            EntityLocation = ''
            EntityType = 'VMHost'
            PrincipalName = 'MyDscPrincipal'
            RoleName = 'MyDscRole'
            Ensure = 'Present'
            Propagate = $false
        }
    }
}
```

### Example 3

Creates or modifies the Permission for Datastore Entity **MyDscDatastore**, Principal **MyDscPrincipal** and Role **MyDscRole** on the specified VMHost.

```powershell
Configuration VMHostPermission_CreateVMHostPermissionForDatastoreEntity_Config {
    Param(
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
        VMHostPermission VMHostPermission {
            Server = $Server
            Credential = $Credential
            EntityName = 'MyDscDatastore'
            EntityLocation = ''
            EntityType = 'Datastore'
            PrincipalName = 'MyDscPrincipal'
            RoleName = 'MyDscRole'
            Ensure = 'Present'
        }
    }
}
```

### Example 4

Creates or modifies the Permission for Resource Pool Entity **MyDscResourcePool**, Principal **MyDscPrincipal** and Role **MyDscRole** on the specified VMHost. The Resource Pool Entity **MyDscResourcePool** is located in the Root Resource Pool of the specified VMHost.

```powershell
Configuration VMHostPermission_CreateVMHostPermissionForResourcePoolEntity_Config {
    Param(
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
        VMHostPermission VMHostPermission {
            Server = $Server
            Credential = $Credential
            EntityName = 'MyDscResourcePool'
            EntityLocation = ''
            EntityType = 'ResourcePool'
            PrincipalName = 'MyDscPrincipal'
            RoleName = 'MyDscRole'
            Ensure = 'Present'
        }
    }
}
```

### Example 5

Creates or modifies the Permission for Virtual Machine Entity **MyDscVM**, Principal **MyDscPrincipal** and Role **MyDscRole** on the specified VMHost. The Virtual Machine Entity **MyDscVM** is located in the **MyDscvApp** vApp which is located in **MyDscResourcePool** Resource Pool of the specified VMHost.

```powershell
Configuration VMHostPermission_CreateVMHostPermissionForVMEntity_Config {
    Param(
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
        VMHostPermission VMHostPermission {
            Server = $Server
            Credential = $Credential
            EntityName = 'MyDscVM'
            EntityLocation = 'MyDscResourcePool/MyDscvApp'
            EntityType = 'VM'
            PrincipalName = 'MyDscPrincipal'
            RoleName = 'MyDscRole'
            Ensure = 'Present'
        }
    }
}
```

### Example 6

Removes the Permission for Virtual Machine Entity **MyDscVM**, Principal **MyDscPrincipal** and Role **MyDscRole** from the specified VMHost.

```powershell
Configuration VMHostPermission_RemoveVMHostPermission_Config {
    Param(
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
        VMHostPermission VMHostPermission {
            Server = $Server
            Credential = $Credential
            EntityName = 'MyDscVM'
            EntityLocation = 'MyDscResourcePool/MyDscvApp'
            EntityType = 'VM'
            PrincipalName = 'MyDscPrincipal'
            RoleName = 'MyDscRole'
            Ensure = 'Absent'
        }
    }
}
```
