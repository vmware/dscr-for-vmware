# VMHostAuthentication

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Credential** | Mandatory | PSCredential | The credentials needed for connection to the specified Server. ||
| **Name** | Key | string | The name of the VMHost which is going to join/leave the specified domain. The name should be the fully qualified domain name (FQDN). ||
| **DomainName** | Mandatory | string | The name of the domain to join/leave. ||
| **DomainAction** | Mandatory | DomainAction | Value indicating if the specified VMHost should join/leave the specified domain. | Join, Leave |
| **DomainCredential** | Optional | PSCredential | The credentials needed for joining the specified domain. ||

## Description

The resource is used to include/exclude the specified VMHost in/from the specified domain. When the DomainAction is **Leave**, the VMHost is excluded from the specified domain and all existing permissions on the Managed Objects for Active Directory users are deleted without confirmation.

## Examples

### Example 1

Includes the specified **VMHost** in the specified **domain**.

```powershell
Configuration VMHostAuthentication_JoinDomain_Config {
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
        $DomainName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $DomainCredential
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostAuthentication VMHostAuthentication {
            Server = $Server
            Credential = $Credential
            Name = $Name
            DomainName = $DomainName
            DomainAction = 'Join'
            DomainCredential = $DomainCredential
        }
    }
}
```

### Example 2

Excludes the specified **VMHost** from the specified **domain**. All existing permissions on the Managed Objects for Active Directory users are deleted without confirmation.

```powershell
Configuration VMHostAuthentication_LeaveDomain_Config {
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
        $DomainName
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostAuthentication VMHostAuthentication {
            Server = $Server
            Credential = $Credential
            Name = $Name
            DomainName = $DomainName
            DomainAction = 'Leave'
        }
    }
}
```
