# vCenterSettings

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | Name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Credential** | Mandatory | PSCredential | Credentials needed for connection to the specified Server. ||
| **LoggingLevel** | Optional | LoggingLevel | Logging Level Advanced Setting value. |Unset, None, Error, Warning, Info, Verbose, Trivia|
| **EventMaxAgeEnabled** | Optional | bool | Event Max Age Enabled Advanced Setting value. ||
| **EventMaxAge** | Optional | int | Event Max Age Advanced Setting value. ||
| **TaskMaxAgeEnabled** | Optional | bool | Task Max Age Enabled Advanced Setting value. ||
| **TaskMaxAge** | Optional | int | Task Max Age Advanced Setting value. ||
| **Motd** | Optional | string | Motd Advanced Setting value. ||
| **MotdClear** | Optional | bool | Indicates whether the Motd content should be cleared. ||
| **Issue** | Optional | string | Issue Advanced Setting value. ||
| **IssueClear** | Optional | bool | Indicates whether the Issue content should be cleared. ||

## Description

The resource is used to Update EventMaxAge Settings, TaskMaxAge Settings, Motd Setting, Issue Setting and the Logging Level of a vCenter.

## Examples

### Example 1

Updates the EventMaxAge Settings, TaskMaxAge Settings and the Logging Level of the passed vCenter.

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

Configuration vCenterSettings_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        $Password = $Password | ConvertTo-SecureString -AsPlainText -Force
        $Credential = New-Object System.Management.Automation.PSCredential($User, $Password)

        vCenterSettings vCenterSettings {
            Server = $Server
            Credential = $Credential
            LoggingLevel = 'Warning'
            EventMaxAgeEnabled = $false
            EventMaxAge = 40
            TaskMaxAgeEnabled = $false
            TaskMaxAge = 40
        }
    }
}
````

### Example 2

Updates the Motd and Issue Settings of the passed vCenter.

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

Configuration vCenterSettings_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        $Password = $Password | ConvertTo-SecureString -AsPlainText -Force
        $Credential = New-Object System.Management.Automation.PSCredential($User, $Password)

        vCenterSettings vCenterSettings {
            Server = $Server
            Credential = $Credential
            Motd = 'Hello World from motd!'
            Issue = 'Hello World from issue!'
        }
    }
}
````
