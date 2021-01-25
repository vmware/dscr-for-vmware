# VMHostVssPortGroupTeaming

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | Name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Credential** | Mandatory | PSCredential | Credentials needed for connection to the specified Server. ||
| **VMHostName** | Key | string | The Name of the VMHost which is going to be used. ||
| **Name** | Key | string | The Name for the Port Group. ||
| **Ensure** | Mandatory | Ensure | Value indicating if the Port Group should be Present or Absent. | Present, Absent |
| **FailbackEnabled** | Optional | bool | Specifies how a Physical Adapter is returned to active duty after recovering from a failure. ||
| **LoadBalancingPolicy** | Optional | LoadBalancingPolicy | Determines how network traffic is distributed between the network Adapters assigned to a Switch. | LoadBalanceIP, LoadBalanceSrcMac, LoadBalanceSrcId, ExplicitFailover |
| **ActiveNic** | Optional | string[] | The Adapters you want to continue to use when the network Adapter connectivity is available and active. ||
| **StandbyNic** | Optional | string[] | The Adapters you want to use if one of the active Adapter's connectivity is unavailable. ||
| **UnusedNic** | Optional | string[] | The Adapters you do not want to use. ||
| **NetworkFailoverDetectionPolicy** | Optional | NetworkFailoverDetectionPolicy | Specifies how to reroute traffic in the event of an Adapter failure. | LinkStatus, BeaconProbing |
| **NotifySwitches** | Optional | bool | Indicates that whenever a virtual NIC is connected to the Virtual Switch or whenever that virtual NIC's traffic is routed over a different physical NIC in the team because of a failover event, a notification is sent over the network to update the lookup tables on the physical Switches. ||
| **InheritFailback** | Optional | bool | Indicates that the value of the FailbackEnabled parameter is inherited from the Virtual Switch. ||
| **InheritFailoverOrder** | Optional | bool | Indicates that the values of the ActiveNic, StandbyNic, and UnusedNic parameters are inherited from the Virtual Switch. ||
| **InheritLoadBalancingPolicy** | Optional | bool | Indicates that the value of the LoadBalancingPolicy parameter is inherited from the Virtual Switch. ||
| **InheritNetworkFailoverDetectionPolicy** | Optional | bool | Indicates that the value of the NetworkFailoverDetectionPolicy parameter is inherited from the Virtual Switch. ||
| **InheritNotifySwitches** | Optional | bool | Indicates that the value of the NotifySwitches parameter is inherited from the Virtual Switch. ||

## Description

The resource is used to update the Teaming Policy of the specified Virtual Port Group.

## Examples

### Example 1

The first Resource in the Configuration creates a new Standard Virtual Switch **MyVirtualSwitch** with MTU **1500**. The second Resource in the Configuration connects Standard Virtual Switch **MyVirtualSwitch** to **vmnic2** and **vmnic3** Physical Network Adapters. The third Resource in the Configuration updates the Teaming Policy of Standard Virtual Switch **MyVirtualSwitch**. The fourth Resource in the Configuration creates a new Virtual Port Group **MyVirtualPortGroup** which is associated with the Virtual Switch **MyVirtualSwitch** with VLanId set to **1**. The fifth Resource in the Configuration updates the Teaming Policy of Virtual Port Group **MyVirtualPortGroup**. The Teaming Policy settings are not inherited from the parent Standard Virtual Switch.

```powershell
Configuration VMHostVssPortGroupTeaming_Config {
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

        VMHostVssBridge VMHostVssBridge {
            Server = $Server
            Credential = $Credential
            Name = $VMHostName
            VssName = 'MyVirtualSwitch'
            Ensure = 'Present'
            BeaconInterval = 1
            LinkDiscoveryProtocolOperation = 'Listen'
            LinkDiscoveryProtocolProtocol = 'CDP'
            NicDevice = @('vmnic2', 'vmnic3')
            DependsOn = "[VMHostVss]VMHostStandardSwitch"
        }

        VMHostVssTeaming VMHostVssTeaming {
            Server = $Server
            Credential = $Credential
            Name = $VMHostName
            VssName = 'MyVirtualSwitch'
            Ensure = 'Present'
            CheckBeacon = $true
            ActiveNic = @('vmnic2', 'vmnic3')
            StandbyNic = @()
            NotifySwitches = $false
            Policy = 'Loadbalance_ip'
            RollingOrder = $true
            DependsOn = "[VMHostVssBridge]VMHostVssBridge"
        }

        VMHostVssPortGroup VMHostVssPortGroup {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            Name = 'MyVirtualPortGroup'
            VssName = 'MyVirtualSwitch'
            Ensure = 'Present'
            VLanId = 0
            DependsOn = "[VMHostVssTeaming]VMHostVssTeaming"
        }

        VMHostVssPortGroupTeaming VMHostVssPortGroupTeaming {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            Name = 'MyVirtualPortGroup'
            Ensure = 'Present'
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
            DependsOn = "[VMHostVssPortGroup]VMHostVssPortGroup"
        }
    }
}
```
