# VMHostvSANNetworkConfiguration

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Credential** | Mandatory | PSCredential | The credentials needed for connection to the specified Server. ||
| **Name** | Key | string | The name of the VMHost. ||
| **InterfaceName** | Key | string | The name of the interface. ||
| **Ensure** | Mandatory | Ensure | Specifies whether the IP interface of the vSAN network configuration should be present or absent. ||
| **AgentMcAddr** | Optional | string | The IPv4 multicast address for the agent group. ||
| **AgentV6McAddr** | Optional | string | The IPv6 multicast address for the agent group. ||
| **AgentMcPort** | Optional | long | The multicast address port for the agent group. ||
| **HostUcPort** | Optional | long | The unicast address port for the VMHost unicast channel. ||
| **MasterMcAddr** | Optional | string | The IPv4 multicast address for the master group. ||
| **MasterV6McAddr** | Optional | string | The IPv6 multicast address for the master group. ||
| **MasterMcPort** | Optional | long | The multicast address port for the master group. ||
| **MulticastTtl** | Optional | long | The time-to-live for multicast packets. ||
| **TrafficType** | Optional | string[] | The network transmission type of the vSAN traffic through a virtual network adapter. Supported values are vsan and witness. Type **vsan** means general vSAN transmission, which is used for both data and witness transmission, if there is no virtual adapter configured with **witness** traffic type; Type **witness** indicates that, vSAN vmknic is used for vSAN witness transmission. Once a virtual adapter is configured with **witness** traffic type, vSAN witness data transmission will stop using virtual adapter with **vsan** traffic type, and use first dicovered virtual adapter with **witness** traffic type. Multiple traffic types can be provided in format -T type1 -T type2. Default value is **vsan**, if the property is not specified. ||
| **Force** | Optional | bool | Specifies whether to notify vSAN subsystem of the removal of the IP Interface, even if is not configured. ||

## Description

The resource is used to add and remove vSAN network configuration IP Interfaces on the specified VMHost.

## Examples

### Example 1

Adds a new vSAN network configuration IP Interface where the interface name is the specified VMKernel Network Adapter name. The time-to-live for multicast packets is **5** and the traffic type is **vsan**. Also specified are the settings for the **Agent** and **Master** groups as well as the unicast address port for the VMHost unicast channel: **12321**.

```powershell
Configuration VMHostvSANNetworkConfiguration_AddVMHostvSANNetworkConfigurationIPInterface_Config {
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
        $VMHostVMKernelNetworkAdapterName
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostvSANNetworkConfiguration VMHostvSANNetworkConfiguration {
            Server = $Server
            Credential = $Credential
            Name = $Name
            InterfaceName = $VMHostVMKernelNetworkAdapterName
            Ensure = 'Present'
            AgentV6McAddr = 'ff19::2:3:4'
            AgentMcAddr = '224.2.3.4'
            AgentMcPort = 23451
            HostUcPort = 12321
            MasterV6McAddr = 'ff19::1:2:3'
            MasterMcAddr = '224.1.2.3'
            MasterMcPort = 12345
            MulticastTtl = 5
            TrafficType = 'vsan'
        }
    }
}
```

### Example 2

Removes the vSAN network configuration IP Interface where the interface name is the specified VMKernel Network Adapter name. The vSAN subsystem is notified of the removal of the IP Interface.

```powershell
Configuration VMHostvSANNetworkConfiguration_RemoveVMHostvSANNetworkConfigurationIPInterface_Config {
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
        $VMHostVMKernelNetworkAdapterName
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostvSANNetworkConfiguration VMHostvSANNetworkConfiguration {
            Server = $Server
            Credential = $Credential
            Name = $Name
            InterfaceName = $VMHostVMKernelNetworkAdapterName
            Ensure = 'Absent'
            Force = $true
            AgentV6McAddr = 'ff19::2:3:4'
            AgentMcAddr = '224.2.3.4'
            AgentMcPort = 23451
            HostUcPort = 12321
            MasterV6McAddr = 'ff19::1:2:3'
            MasterMcAddr = '224.1.2.3'
            MasterMcPort = 12345
            MulticastTtl = 5
            TrafficType = 'vsan'
        }
    }
}
```
