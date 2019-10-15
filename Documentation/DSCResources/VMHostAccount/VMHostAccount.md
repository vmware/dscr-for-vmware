# VMHostAccount

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | Name of the Server we are trying to connect to. The Server can only be ESXi. ||
| **Credential** | Mandatory | PSCredential | Credentials needed for connection to the specified Server. ||
| **Id** | Key | string | Specifies the ID for the host account. ||
| **Ensure** | Mandatory | Ensure | Value indicating if the Resource should be Present or Absent. |Present, Absent|
| **Role** | Mandatory | string | Permission on the VMHost entity is created for the specified User Id with the specified Role. ||
| **AccountPassword** | Optional | string | Specifies the Password for the host account. ||
| **Description** | Optional | string | Provides a description for the host account. The maximum length of the text is 255 symbols. ||

## Description

The resource is used to create, update and delete VMHost Accounts in the specified VMHost we are connected to.

## Examples

### Example 1

Creates a new VMHostAccount in the specified VMHost we are connected to. The Resource also creates new 'Admin' Role Permission for the newly created VMHostAccount.

````powershell
param(
        [Parameter(Mandatory = $true)]
        [string]
        $Server,

        [Parameter(Mandatory = $true)]
        [string]
        $User,

        [Parameter(Mandatory = $true)]
        [string]
        $Password
)

$script:configurationData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
        }
    )
}

Configuration VMHostAccount_WithAccountToAdd_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        $Password = $Password | ConvertTo-SecureString -AsPlainText -Force
        $Credential = New-Object System.Management.Automation.PSCredential($User, $Password)

        VMHostAccount vmHostAccount {
            Server = $Server
            Credential = $Credential
            Id = 'MyVMHostAccount'
            Ensure = 'Present'
            Role = 'Admin'
            AccountPassword = 'MyAccountPass1!'
            Description = 'MyVMHostAccount Description'
        }
    }
}
````

### Example 2

Removes the VMHost Account in the specified VMHost we are connected to.

````powershell
param(
        [Parameter(Mandatory = $true)]
        [string]
        $Server,

        [Parameter(Mandatory = $true)]
        [string]
        $User,

        [Parameter(Mandatory = $true)]
        [string]
        $Password
)

$script:configurationData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
        }
    )
}

Configuration VMHostAccount_WithAccountToRemove_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        $Password = $Password | ConvertTo-SecureString -AsPlainText -Force
        $Credential = New-Object System.Management.Automation.PSCredential($User, $Password)

        VMHostAccount vmHostAccount {
            Server = $Server
            Credential = $Credential
            Id = 'MyVMHostAccount'
            Ensure = 'Absent'
            Role = 'Admin'
        }
    }
}
````
