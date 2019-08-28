# VMHostVssShaping

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | Name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Name** | Key | string | Name of the VMHost to configure. ||
| **Credential** | Mandatory | PSCredential | Credentials needed for connection to the specified Server. ||
| **Ensure** | Mandatory | Ensure | Value indicating if the VSS should be Present or Absent. | Present, Absent |
| **VssName** | Key | string | The name of the VSS. ||
| **AverageBandwidth** | Optional | long | The average bandwidth in bits per second if shaping is enabled on the port. ||
| **BurstSize** | Optional | long | The maximum burst size allowed in bytes if shaping is enabled on the port. ||
| **Enabled** | Optional | boolean | The flag to indicate whether or not traffic shaper is enabled on the port. ||
| **PeakBandwidth** | Optional | long | The peak bandwidth during bursts in bits per second if traffic shaping is enabled on the port. ||

## Description

The resource is used to configure the traffic shaping policy for ports of a Virtual Switch (VSS). The VSS needs to exist.

## Examples

### Example 1

Configures the security settings of the specified Virtual Switch.

````powershell
param(
    [Parameter(Mandatory = $true)]
    [string]
    $Name,

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

Configuration VMHostVssShaping_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        $Password = $Password | ConvertTo-SecureString -AsPlainText -Force
        $Credential = New-Object System.Management.Automation.PSCredential($User, $Password)

        VMHostVss vmHostVssSettings {
            Name = $Name
            Server = $Server
            Credential = $vmHostCredential
            VssName = 'VSS1'
            Ensure = 'Present'
            Mtu = 1500
        }

        VMHostVssShaping vmHostVSSShaping {
            Name = $Name
            Server = $Server
            Credential = $Credential
            VssName = 'VSS1'
            Ensure = 'Present'
            AverageBandwidth = 100000
            BurstSize = 100000
            Enabled = $true
            PeakBandwidth = 100000
            DependsOn = "[VMHostVss]vmHostVssSettings"
        }
    }
}
````
