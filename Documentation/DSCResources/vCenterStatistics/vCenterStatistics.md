# vCenterStatistics

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | Name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Credential** | Mandatory | PSCredential | Credentials needed for connection to the specified Server. ||
| **Period** | Key | Period | The unit of period. Statistics can be stored separatelly for each of the {Day, Week, Month, Year} period units. |Day, Week, Month, Year|
| **PeriodLength** | Optional | long | Period for which the statistics are saved. ||
| **Level** | Optional | int | Specified Level value for the vCenter Statistics. ||
| **Enabled** | Optional | bool | If collecting statistics for the specified period unit is enabled. ||
| **IntervalMinutes** | Optional | long | Interval in Minutes, indicating the period for collecting statistics. ||

## Description

The resource is used to configure the Statistics Settings of a vCenter.

## Examples

### Example 1

Updates the Statistics settings of the passed vCenter by changing the level to 2 for the Day period.

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

Configuration vCenterStatistics_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        $Password = $Password | ConvertTo-SecureString -AsPlainText -Force
        $Credential = New-Object System.Management.Automation.PSCredential($User, $Password)

        vCenterStatistics vCenterStatistics {
            Server = $Server
            Credential = $Credential
            Period = "Day"
            Level = 2
        }
    }
}
````
