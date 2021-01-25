# VMHostVssPortGroupShaping

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | Name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Credential** | Mandatory | PSCredential | Credentials needed for connection to the specified Server. ||
| **VMHostName** | Key | string | The Name of the VMHost which is going to be used. ||
| **Name** | Key | string | The Name for the Port Group. ||
| **Ensure** | Mandatory | Ensure | Value indicating if the Port Group should be Present or Absent. | Present, Absent |
| **Enabled** | Optional | bool | The flag to indicate whether or not traffic shaper is enabled on the port. ||
| **AverageBandwidth** | Optional | long | The average bandwidth in bits per second if shaping is enabled on the port. ||
| **PeakBandwidth** | Optional | long | The peak bandwidth during bursts in bits per second if traffic shaping is enabled on the port. ||
| **BurstSize** | Optional | long | The maximum burst size allowed in bytes if shaping is enabled on the port. ||

## Description

The resource is used to update the Shaping Policy of the specified Virtual Port Group.

## Examples

### Example 1

The first Resource in the Configuration creates a new Standard Virtual Switch **MyVirtualSwitch** with MTU **1500**. The second Resource in the Configuration creates a new Virtual Port Group **MyVirtualPortGroup** which is associated with the Virtual Switch **MyVirtualSwitch** with VLanId set to **1**. The third Resource in the Configuration updates the Shaping Policy of Virtual Port Group **MyVirtualPortGroup** by enabling it and setting the **BurstSize**, **Average** and **Peak** bandwidths values.

```powershell
Configuration VMHostVssPortGroupShaping_Config {
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
        VMHostVss VMHostStandardSwitch {
            Server = $Server
            Credential = $Credential
            Name = $VMHostName
            VssName = 'MyVirtualSwitch'
            Ensure = 'Present'
            Mtu = 1500
        }

        VMHostVssPortGroup VMHostVssPortGroup {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            Name = 'MyVirtualPortGroup'
            VssName = 'MyVirtualSwitch'
            Ensure = 'Present'
            VLanId = 0
            DependsOn = "[VMHostVss]VMHostStandardSwitch"
        }

        VMHostVssPortGroupShaping VMHostVssPortGroupShaping {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            Name = 'MyVirtualPortGroup'
            Ensure = 'Present'
            Enabled = $true
            AverageBandwidth = 104857600000
            PeakBandwidth = 104857600000
            BurstSize = 107374182400
            DependsOn = "[VMHostVssPortGroup]VMHostVssPortGroup"
        }
    }
}
```
