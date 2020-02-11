# StandardSwitch

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Credential** | Mandatory | PSCredential | The credentials needed for connection to the specified Server. ||
| **VMHostName** | Key | string | The name of the VMHost. ||
| **Name** | Key | string | The name of the Standard Switch. ||
| **Ensure** | Mandatory | Ensure | Specifies whether the Standard Switch should be present or absent. | Present, Absent |
| **Mtu** | Optional | int | The maximum transmission unit (MTU) in bytes associated with the Standard Switch. ||
| **NicDevice** | Optional | string[] | The names of the Physical Network Adapters that are bridged to the Standard Switch. ||
| **BeaconInterval** | Optional | int | Determines how often, in seconds, a beacon should be sent. ||
| **LinkDiscoveryProtocolType** | Optional | string | The discovery protocol type. Standard Switches support only CDP (Cisco Discovery Protocol). | CDP |
| **LinkDiscoveryProtocolOperation** | Optional | string | Specifies whether to advertise or listen. | Advertise, Both, Listen, None |
| **AllowPromiscuous** | Optional | bool | A flag indicating whether or not all traffic is seen on the port. ||
| **ForgedTransmits** | Optional | bool | A flag indicating whether or not the Virtual Network Adapter should be allowed to send network traffic with a different MAC address. ||
| **MacChanges** | Optional | bool | A flag indicating whether or not the Media Access Control (MAC) address can be changed. ||
| **Enabled** | Optional | bool | A flag indicating whether or not traffic shaper is enabled on the port. ||
| **AverageBandwidth** | Optional | long | The average bandwidth in bits per second if shaping is enabled on the port. ||
| **PeakBandwidth** | Optional | long | The peak bandwidth during bursts in bits per second if traffic shaping is enabled on the port. ||
| **BurstSize** | Optional | long | The maximum burst size allowed in bytes if shaping is enabled on the port. ||
| **CheckBeacon** | Optional | bool | A flag indicating whether or not to enable beacon probing as a method to validate the link status of a Physical Network Adapter. ||
| **ActiveNic** | Optional | string[] | List of active Network Adapters used for load balancing. ||
| **StandbyNic** | Optional | string[] | Standby Network Adapters used for failover. ||
| **NotifySwitches** | Optional | bool | A flag specifying whether or not to notify the Physical Switch if a link fails. ||
| **Policy** | Optional | NicTeamingPolicy | The Network adapter teaming policy. |  LoadBalance_IP, LoadBalance_SrcMAC, LoadBalance_SrcId, Failover_Explicit |
| **RollingOrder** | Optional | bool | A flag indicating whether or not to use a rolling policy when restoring links. ||

## Description

The resource is used to create, modify and remove Standard Switches on the specified VMHost. The resource also modifies the different policies of the Standard Switch - Security, Shaping and Teaming policies as well as creating a bridge to connect the Standard Switch to Physical Network Adapters.

## Examples

### Example 1

Creates/modifies Standard Switch **MyStandardSwitch** with maximum transmission unit **1500 bytes**. Physical Network Adapters **vmnic2** and **vmnic3** are bridged to Standard Switch **MyStandardSwitch** with configured beacon probing and link discovery protocol type **CDP** and operation **Listen**. **Promiscuous mode**, **Forged Transmits** and **Mac Changes** are enabled for Standard Switch **MyStandardSwitch**. The shaping policy for Standard Switch **MyStandardSwitch** is **enabled** with average bandwidth in bits per second **104857600000**, peak bandwidth during bursts in bits per second **104857600000** and the maximum burst size allowed in bytes **107374182400**. The active Nic is **vmnic2**, the standby Nic is **vmnnic3**, the Network Adapter teaming policy is **LoadBalanceSrcId**. The Physical Network Adapters are notified if a link fails. Rolling policy when restoring links is not used. Beacon probing as a method to validate the link status of a Physical Network Adapter is not enabled.

```powershell
Configuration StandardSwitch_Config {
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
        StandardSwitch StandardSwitch {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            Name = 'MyStandardSwitch'
            Ensure = 'Present'
            Mtu = 1500
            NicDevice = @('vmnic2', 'vmnic3')
            BeaconInterval = 1
            LinkDiscoveryProtocolType = 'CDP'
            LinkDiscoveryProtocolOperation = 'Listen'
            AllowPromiscuous = $true
            ForgedTransmits = $true
            MacChanges = $true
            Enabled = $true
            AverageBandwidth = 104857600000
            PeakBandwidth = 104857600000
            BurstSize = 107374182400
            CheckBeacon = $false
            ActiveNic = @('vmnic2')
            StandbyNic = @('vmnic3')
            NotifySwitches = $true
            Policy = 'Loadbalance_srcid'
            RollingOrder = $false
        }
    }
}
```
