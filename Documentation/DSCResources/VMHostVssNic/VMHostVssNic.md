# VMHostVssNic

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Credential** | Mandatory | PSCredential | The credentials needed for connection to the specified Server. ||
| **VMHostName** | Key | string | The name of the VMHost which is going to be used. ||
| **VssName** | Key | string | The name of the Virtual Switch to which the VMKernel Network Adapter should be connected. The Switch must be a Standard Switch. ||
| **PortGroupName** | Key | string | The name of the Port Group to which the VMKernel Network Adapter should be connected. If the Port Group is non-existent, a new Port Group with the specified name will be created and the VMKernel Network Adapter will be connected to it. ||
| **Ensure** | Mandatory | Ensure | Value indicating if the VMKernel Network Adapter should be Present or Absent. | Present, Absent |
| **Dhcp** | Optional | bool | Indicates whether the VMKernel Network Adapter uses a Dhcp server. ||
| **IP** | Optional | string | The IP address for the VMKernel Network Adapter. All IP addresses are specified using IPv4 dot notation. If IP is not specified, DHCP mode is enabled. ||
| **SubnetMask** | Optional | string | The Subnet Mask for the VMKernel Network Adapter. ||
| **Mac** | Optional | string | The media access control (MAC) address for the VMKernel Network Adapter. ||
| **AutomaticIPv6** | Optional | bool | Indicates that the IPv6 address is obtained through a router advertisement. ||
| **IPv6** | Optional | string[] | Specifies multiple static addresses using the following format: `<IPv6>`/<subnet_prefix_length> or `<IPv6>`. If you skip <subnet_prefix_length>, the default value of 64 is used. ||
| **IPv6ThroughDhcp** | Optional | bool | Indicates that the IPv6 address is obtained through DHCP. ||
| **Mtu** | Optional | int | The MTU size. ||
| **IPv6Enabled** | Optional | bool | Indicates that IPv6 configuration is enabled. Setting this parameter to $false disables all IPv6-related parameters. If the value is $true, you need to provide values for at least one of the IPv6 parameters. ||
| **ManagementTrafficEnabled** | Optional | bool | Indicates that you want to enable the VMKernel Network Adapter for management traffic. ||
| **FaultToleranceLoggingEnabled** | Optional | bool | Indicates that the VMKernel Network Adapter is enabled for Fault Tolerance (FT) logging. ||
| **VMotionEnabled** | Optional | bool | Indicates that you want to use the VMKernel Network Adapter for VMotion. ||
| **VsanTrafficEnabled** | Optional | bool | Indicates that Virtual SAN traffic is enabled on this VMKernel Network Adapter. ||

## Description

The resource is used to create, update and remove VMKernel Network Adapters added to the specified Standard Switch and Port Group. If the Port Group is not existing, it will be created and the VMKernel Network Adapter will be connected to it.

## Examples

### Example 1

Creates a new VMKernel Network Adapter with the specified settings adding it to Standard Switch **MyVirtualSwitch** and Port Group **MyVirtualPortGroup**.

```powershell
Configuration VMHostVssNic_Config {
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
        VMHostVssNic VMHostVssNic {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            VssName = 'MyVirtualSwitch'
            PortGroupName = 'MyVirtualPortGroup'
            Ensure = 'Present'
            IP = '192.168.0.1'
            SubnetMask = '255.255.255.0'
            Mac = '00:50:56:63:5b:0e'
            AutomaticIPv6 = $true
            IPv6 = @('fe80::250:56ff:fe63:5b0e/64', '200:2342::1/32')
            IPv6ThroughDhcp = $true
            Mtu = 4000
            ManagementTrafficEnabled = $true
            FaultToleranceLoggingEnabled = $true
            VMotionEnabled = $true
            VsanTrafficEnabled = $true
        }
    }
}
```

### Example 2

The first Configuration creates a new VMKernel Network Adapter with the specified settings adding it to Standard Switch **MyVirtualSwitch** and Port Group **MyVirtualPortGroup**. The second Configuration updates the VMKernel Network Adapter added to Standard Switch **MyVirtualSwitch** and Port Group **MyVirtualPortGroup** by disabling IPv6 and enabling Dhcp.

```powershell
Configuration VMHostVssNic_WhenAddingVMKernelNetworkAdapter_Config {
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
        VMHostVssNic VMHostVssNic {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            VssName = 'MyVirtualSwitch'
            PortGroupName = 'MyVirtualPortGroup'
            Ensure = 'Present'
            IP = '192.168.0.1'
            SubnetMask = '255.255.255.0'
            Mac = '00:50:56:63:5b:0e'
            AutomaticIPv6 = $true
            IPv6 = @('fe80::250:56ff:fe63:5b0e/64', '200:2342::1/32')
            IPv6ThroughDhcp = $true
            Mtu = 4000
            ManagementTrafficEnabled = $true
            FaultToleranceLoggingEnabled = $true
            VMotionEnabled = $true
            VsanTrafficEnabled = $true
        }
    }
}

Configuration VMHostVssNic_WhenUpdatingVMKernelNetworkAdapter_Config {
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
        $Name
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostVssNic VMHostVssNic {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            VssName = 'MyVirtualSwitch'
            PortGroupName = 'MyVirtualPortGroup'
            Ensure = 'Present'
            IPv6Enabled = $false
            Dhcp = $true
        }
    }
}
```

### Example 3

Removes the VMKernel Network Adapter added to Standard Switch **MyVirtualSwitch** and Port Group **MyVirtualPortGroup**.

```powershell
Configuration VMHostVssNic_Config {
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
        $Name
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostVssNic VMHostVssNic {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            VssName = 'MyVirtualSwitch'
            PortGroupName = 'MyVirtualPortGroup'
            Ensure = 'Absent'
        }
    }
}
```
