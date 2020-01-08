# NfsUser

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Credential** | Mandatory | PSCredential | The credentials needed for connection to the specified Server. ||
| **VMHostName** | Key | string | The name of the VMHost which is going to be used. ||
| **Name** | Key | string | The Nfs User name used for Kerberos authentication. ||
| **Password** | Optional | string | The Nfs User password used for Kerberos authentication. ||
| **Ensure** | Mandatory | Ensure | Specifies whether the Nfs User should be present or absent. | Present, Absent |
| **Force** | Optional | bool | Specifies whether to change the password of the Nfs User. When the property is not specified or is $false, it is ignored. If the property is $true and the Nfs User exists, the password of the Nfs User is changed. ||

## Description

The resource is used to create, change the password and remove Nfs Users on the specified VMHost. The VMHost must be in Active Directory domain.

## Examples

### Example 1

Creates Nfs User **MyNfsUser** with password **MyNfsUserPassword1!** on the specified VMHost. The VMHost must be in Active Directory domain for the Nfs User to be created.

```powershell
Configuration NfsUser_CreateNfsUser_Config {
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
        NfsUser NfsUser {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            Name = 'MyNfsUser'
            Password = 'MyNfsUserPassword1!'
            Ensure = 'Present'
        }
    }
}
```

### Example 2

Changes the password of Nfs User **MyNfsUser** to **MyNfsUserPassword2!** on the specified VMHost.

```powershell
Configuration NfsUser_ChangeNfsUserPassword_Config {
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
        NfsUser NfsUser {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            Name = 'MyNfsUser'
            Password = 'MyNfsUserPassword2!'
            Ensure = 'Present'
            Force = $true
        }
    }
}
```

### Example 3

Removes Nfs User **MyNfsUser** from the specified VMHost.

```powershell
Configuration NfsUser_RemoveNfsUser_Config {
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
        NfsUser NfsUser {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            Name = 'MyNfsUser'
            Ensure = 'Absent'
        }
    }
}
```
