# VMHostRole

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The name of the Server we are trying to connect to. The Server can only be an ESXi. ||
| **Credential** | Mandatory | PSCredential | The credentials needed for connection to the specified Server. ||
| **Name** | Key | string | The name of the Role on the VMHost. ||
| **Ensure** | Mandatory | Ensure | Specifies whether the Role on the VMHost should be present or absent. | Present, Absent |
| **PrivilegeIds** | Optional | string[] | The ids of the Privileges for the Role on the VMHost. The Privilege ids should be in the following format: `<Privilege Group id>`.`<Privilege Item id>`. Exampe Privilege id: 'VirtualMachine.Inventory.Create' where 'VirtualMachine.Inventory' is the Privilege Group id and 'Create' is the id of the Privilege item. ||

## Description

The resource is used to create, modify and remove Roles on the specified VMHost. If Ensure is **Absent**, all Permissions associated with the Role will be removed as well.

## Examples

### Example 1

Creates or modifies Role **MyDscRole** on the specified VMHost. The applied Privileges of Role **MyDscRole** should be: **Host.Inventory.AddStandaloneHost**, **Host.Inventory.CreateCluster**, **Host.Inventory.MoveHost**, **System.Anonymous**, **System.Read** and **System.View**.

```powershell
Configuration VMHostRole_CreateRoleWithPrivileges_Config {
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
        VMHostRole VMHostRole {
            Server = $Server
            Credential = $Credential
            Name = 'MyDscRole'
            Ensure = 'Present'
            PrivilegeIds = @(
                'Host.Inventory.AddStandaloneHost',
                'Host.Inventory.CreateCluster',
                'Host.Inventory.MoveHost',
                'System.Anonymous',
                'System.Read',
                'System.View'
            )
        }
    }
}
```

### Example 2

Removes Role **MyDscRole** from the specified VMHost. All Permissions associated with Role **MyDscRole** will be removed as well.

```powershell
Configuration VMHostRole_RemoveRole_Config {
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
        VMHostRole VMHostRole {
            Server = $Server
            Credential = $Credential
            Name = 'MyDscRole'
            Ensure = 'Absent'
        }
    }
}
```
