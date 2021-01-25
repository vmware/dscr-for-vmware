# VMHostVdsNic

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Credential** | Mandatory | PSCredential | The credentials needed for connection to the specified Server. ||
| **Name** | Key | string | The name of the VMKernel NIC connected to the specified Distributed Port Group on the specified VDSwitch. ||
| **VMHostName** | Key | string | The name of the VMHost. ||
| **VdsName** | Key | string | The name of the VDSwitch to which the VMKernel NIC is added. ||
| **PortGroupName** | Key | string | The name of the Distributed Port Group to which the VMKernel NIC is connected. ||
| **Ensure** | Mandatory | Ensure | Specifies whether the VMKernel NIC should be present or absent. | Present, Absent |
| **Dhcp** | Optional | bool | Specifies whether the VMKernel NIC uses a Dhcp server. ||
| **IP** | Optional | string | The IP address for the VMKernel NIC. All IP addresses are specified using IPv4 dot notation. If IP is not specified, DHCP mode is enabled. ||
| **SubnetMask** | Optional | string | The Subnet Mask for the VMKernel NIC. ||
| **Mac** | Optional | string | The media access control (MAC) address for the VMKernel NIC. ||
| **AutomaticIPv6** | Optional | bool | Indicates that the IPv6 address is obtained through a router advertisement. ||
| **IPv6** | Optional | string[] | Specifies multiple static addresses using the following format: `<IPv6>`/<subnet_prefix_length> or `<IPv6>`. If you skip <subnet_prefix_length>, the default value of 64 is used. ||
| **IPv6ThroughDhcp** | Optional | bool | Indicates that the IPv6 address is obtained through DHCP. ||
| **Mtu** | Optional | int | The MTU size. ||
| **IPv6Enabled** | Optional | bool | Indicates that IPv6 configuration is enabled. Setting this parameter to $false disables all IPv6-related parameters. If the value is $true, you need to provide values for at least one of the IPv6 parameters. ||
| **ManagementTrafficEnabled** | Optional | bool | Indicates that you want to enable the VMKernel NIC for management traffic. ||
| **FaultToleranceLoggingEnabled** | Optional | bool | Indicates that the VMKernel NIC is enabled for Fault Tolerance (FT) logging. ||
| **VMotionEnabled** | Optional | bool | Indicates that you want to use the VMKernel NIC for VMotion. ||
| **VsanTrafficEnabled** | Optional | bool | Indicates that Virtual SAN traffic is enabled on this VMKernel NIC. ||

## Description

The resource is used to modify the settings or remove VMKernel NICs connected to the specified Distributed Port Group on the specified VDSwitch. The resource can't be used to create VMKernel NICs connected to Distributed Port Groups. This limitation is due to the fact that more than one VMKernel NIC can be created and connected to the same Distributed Port Group. This way the created VMKernel NIC can't be uniquely identified via the specified VDSwitch and Distributed Port Group. The VMKernel NIC's name can't be used as an identifier because it can't be specified when the VMKernel NIC's is being created, it is assigned automatically by the server. The solution is to create a VMKernel NIC on a Standard Switch with the [VMHostVssNic DSC Resource](https://github.com/vmware/dscr-for-vmware/wiki/VMHostVssNic) and then migrate it to the desired VDSwitch and connect it to the desired Distributed Port Group via the [VMHostVDSwitchMigration DSC Resource](https://github.com/vmware/dscr-for-vmware/wiki/VMHostVDSwitchMigration). Then the VMKernel NIC can be configured via the current DSC Resource by specifying its' name to uniquely identify it.

## Examples

### Example 1

Enables all available services (VMotion, Vsan traffic, Management traffic and Fault Tolerance logging) for VMKernel NIC **vmk0** connected to Distributed Port Group **DscVDPortGroup** on VDSwitch **DscVDSwitch**.

```powershell
Configuration VMHostVdsNic_EnableAvailableServices_Config {
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
        VMHostVdsNic VMHostVdsNic {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            Name = 'vmk0'
            VdsName = 'DscVDSwitch'
            PortGroupName = 'DscVDPortGroup'
            Ensure = 'Present'
            ManagementTrafficEnabled = $true
            FaultToleranceLoggingEnabled = $true
            VMotionEnabled = $true
            VsanTrafficEnabled = $true
        }
    }
}
```

### Example 2

Removes VMKernel NIC **vmk0** connected to Distributed Port Group **DscVDPortGroup** on VDSwitch **DscVDSwitch**.

```powershell
Configuration VMHostVdsNic_RemoveVMKernelNic_Config {
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
        VMHostVdsNic VMHostVdsNic {
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            Name = 'vmk0'
            VdsName = 'DscVDSwitch'
            PortGroupName = 'DscVDPortGroup'
            Ensure = 'Absent'
        }
    }
}
```
