# StandardPortGroup

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Credential** | Mandatory | PSCredential | The credentials needed for connection to the specified Server. ||
| **VMHostName** | Key | string | The name of the VMHost which is going to be used. ||
| **Name** | Key | string | The name of the Standard Port Group. ||
| **VssName** | Mandatory | string | The name of the Standard Switch to which the Standard Port Group belongs to. ||
| **Ensure** | Mandatory | Ensure | Value indicating if the Standard Port Group should be Present or Absent. | Present, Absent |
| **VLanId** | Optional | int | The VLanId for ports using this Standard Port Group. | 0 - 4095 |
| **Enabled** | Optional | bool | The flag to indicate whether or not traffic shaper is enabled on the port. ||
| **AverageBandwidth** | Optional | long | The average bandwidth in bits per second if shaping is enabled on the port. ||
| **PeakBandwidth** | Optional | long | The peak bandwidth during bursts in bits per second if traffic shaping is enabled on the port. ||
| **BurstSize** | Optional | long | The maximum burst size allowed in bytes if shaping is enabled on the port. ||
| **AllowPromiscuous** | Optional | bool | Specifies whether promiscuous mode is enabled for the corresponding Standard Port Group. ||
| **AllowPromiscuousInherited** | Optional | bool | Specifies whether the AllowPromiscuous setting is inherited from the parent Standard Switch. ||
| **ForgedTransmits** | Optional | bool | Specifies whether forged transmits are enabled for the corresponding Standard Port Group. ||
| **ForgedTransmitsInherited** | Optional | bool | Specifies whether the ForgedTransmits setting is inherited from the parent Standard Switch. ||
| **MacChanges** | Optional | bool | Specifies whether MAC address changes are enabled for the corresponding Standard Port Group. ||
| **MacChangesInherited** | Optional | bool | Specifies whether the MacChanges setting is inherited from the parent Standard Switch. ||
| **FailbackEnabled** | Optional | bool | Specifies how a Physical Adapter is returned to active duty after recovering from a failure. ||
| **LoadBalancingPolicy** | Optional | LoadBalancingPolicy | Determines how network traffic is distributed between the network Adapters assigned to a Switch. | LoadBalanceIP, LoadBalanceSrcMac, LoadBalanceSrcId, ExplicitFailover |
| **ActiveNic** | Optional | string[] | The Adapters you want to continue to use when the network Adapter connectivity is available and active. ||
| **StandbyNic** | Optional | string[] | The Adapters you want to use if one of the active Adapter's connectivity is unavailable. ||
| **UnusedNic** | Optional | string[] | The Adapters you do not want to use. ||
| **NetworkFailoverDetectionPolicy** | Optional | NetworkFailoverDetectionPolicy | Specifies how to reroute traffic in the event of an Adapter failure. | LinkStatus, BeaconProbing |
| **NotifySwitches** | Optional | bool | Indicates that whenever a virtual NIC is connected to the Standard Switch or whenever that virtual NIC's traffic is routed over a different physical NIC in the team because of a failover event, a notification is sent over the network to update the lookup tables on the physical Switches. ||
| **InheritFailback** | Optional | bool | Indicates that the value of the FailbackEnabled parameter is inherited from the Standard Switch. ||
| **InheritFailoverOrder** | Optional | bool | Indicates that the values of the ActiveNic, StandbyNic, and UnusedNic parameters are inherited from the Standard Switch. ||
| **InheritLoadBalancingPolicy** | Optional | bool | Indicates that the value of the LoadBalancingPolicy parameter is inherited from the Standard Switch. ||
| **InheritNetworkFailoverDetectionPolicy** | Optional | bool | Indicates that the value of the NetworkFailoverDetectionPolicy parameter is inherited from the Standard Switch. ||
| **InheritNotifySwitches** | Optional | bool | Indicates that the value of the NotifySwitches parameter is inherited from the Standard Switch. ||

## Description

The resource is used to create, modify and remove Port Groups which are associated with the specified Standard Switch. If Ensure is 'Absent', all VMs connected to the Port Group must be **PoweredOff** and no VMKernel Network Adapters should be connected to it to successfully remove the Port Group. If one or more of the VMs are **PoweredOn** and at least one VMKernel Network Adapter is connected to the Port Group, the removal would not be successful because the Port Group is used by the VMs and there are connected VMKernel Network Adapters to it.

## Examples

### Example 1

The Configuration does the following:

1. Creates/Updates Port Group **MyStandardPortGroup** which belongs to Standard Switch **MyStandardSwitch** with VLanId set to **1**.
2. Enables the Shaping Policy and sets the **BurstSize**, **Average** and **Peak bandwidth** values.
3. Enables **Promiscuous mode**, **Forged Transmits** and **Mac Changes**. The Security Policy settings are not inherited from the parent Standard Switch **MyStandardSwitch**.
4. Sets the active Nics to be **vmnic2** and **vmnnic3**, the LoadBalancing Policy to **LoadBalanceIP** and the NetworkFailover Policy to **LinkStatus**.
The Teaming Policy settings are not inherited from the parent Standard Switch **MyStandardSwitch**.

```powershell
Configuration StandardPortGroup_Config {
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
        StandardPortGroup StandardPortGroup {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            Name = 'MyStandardPortGroup'
            VssName = 'MyStandardSwitch'
            Ensure = 'Present'
            VLanId = 0
            Enabled = $true
            AverageBandwidth = 104857600000
            PeakBandwidth = 104857600000
            BurstSize = 107374182400
            AllowPromiscuous = $true
            AllowPromiscuousInherited = $false
            ForgedTransmits = $true
            ForgedTransmitsInherited = $false
            MacChanges = $true
            MacChangesInherited = $false
            FailbackEnabled = $false
            LoadBalancingPolicy = 'LoadBalanceIP'
            ActiveNic = @('vmnic2', 'vmnic3')
            StandbyNic = @()
            UnusedNic = @()
            NetworkFailoverDetectionPolicy = 'LinkStatus'
            NotifySwitches = $false
            InheritFailback = $false
            InheritFailoverOrder = $false
            InheritLoadBalancingPolicy = $false
            InheritNetworkFailoverDetectionPolicy = $false
            InheritNotifySwitches = $false
        }
    }
}
```
