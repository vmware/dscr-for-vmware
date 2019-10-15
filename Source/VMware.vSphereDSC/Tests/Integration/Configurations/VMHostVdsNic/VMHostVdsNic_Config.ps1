<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

Configuration VMHostVdsNic_CreateVDSwitchVDPortGroupAndAddVMHostToVDSwitch_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VDSwitch $AllNodes.VDSwitchResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.VDSwitchName
            Location = $AllNodes.VDSwitchLocation
            DatacenterName = $AllNodes.DatacenterName
            DatacenterLocation = $AllNodes.DatacenterLocation
            Ensure = 'Present'
        }

        VDPortGroup $AllNodes.VDPortGroupResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.VDPortGroupName
            VdsName = $AllNodes.VDSwitchName
            Ensure = 'Present'
            DependsOn = $AllNodes.VDSwitchResourceId
        }

        VDSwitchVMHost $AllNodes.VDSwitchVMHostResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VdsName = $AllNodes.VDSwitchName
            VMHostNames = @($AllNodes.VMHostName)
            Ensure = 'Present'
            DependsOn = $AllNodes.VDPortGroupResourceId
        }
    }
}

Configuration VMHostVdsNic_CreateVMHostVDSwitchNicWithoutPortId_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostVdsNic $AllNodes.VDSwitchNicResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            VdsName = $AllNodes.VDSwitchName
            PortGroupName = $AllNodes.VDPortGroupName
            Ensure = 'Present'
            IP = $AllNodes.IP1
            SubnetMask = $AllNodes.SubnetMask1
            Mac = $AllNodes.Mac
            AutomaticIPv6 = $AllNodes.AutomaticIPv6
            IPv6 = $AllNodes.IPv6
            IPv6ThroughDhcp = $AllNodes.IPv6ThroughDhcp
            Mtu = $AllNodes.VMKernelNetworkAdapterMtu
            ManagementTrafficEnabled = $AllNodes.ManagementTrafficEnabled
            FaultToleranceLoggingEnabled = $AllNodes.FaultToleranceLoggingEnabled
            VMotionEnabled = $AllNodes.VMotionEnabled
            VsanTrafficEnabled = $AllNodes.VsanTrafficEnabled
        }
    }
}

Configuration VMHostVdsNic_CreateVMHostVDSwitchNicWithPortId_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostVdsNic $AllNodes.VDSwitchNicResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            VdsName = $AllNodes.VDSwitchName
            PortGroupName = $AllNodes.VDPortGroupName
            PortId = $AllNodes.PortId
            Ensure = 'Present'
            IP = $AllNodes.IP1
            SubnetMask = $AllNodes.SubnetMask1
            Mac = $AllNodes.Mac
            AutomaticIPv6 = $AllNodes.AutomaticIPv6
            IPv6 = $AllNodes.IPv6
            IPv6ThroughDhcp = $AllNodes.IPv6ThroughDhcp
            Mtu = $AllNodes.VMKernelNetworkAdapterMtu
            ManagementTrafficEnabled = $AllNodes.ManagementTrafficEnabled
            FaultToleranceLoggingEnabled = $AllNodes.FaultToleranceLoggingEnabled
            VMotionEnabled = $AllNodes.VMotionEnabled
            VsanTrafficEnabled = $AllNodes.VsanTrafficEnabled
        }
    }
}

Configuration VMHostVdsNic_UpdateVMHostVDSwitchNicMtuAndAvailableServices_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostVdsNic $AllNodes.VDSwitchNicResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            VdsName = $AllNodes.VDSwitchName
            PortGroupName = $AllNodes.VDPortGroupName
            PortId = $AllNodes.PortId
            Ensure = 'Present'
            IP = $AllNodes.IP1
            SubnetMask = $AllNodes.SubnetMask1
            Mac = $AllNodes.Mac
            IPv6 = $AllNodes.IPv6
            Mtu = $AllNodes.VMKernelNetworkAdapterUpdatedMtu
            ManagementTrafficEnabled = !$AllNodes.ManagementTrafficEnabled
            FaultToleranceLoggingEnabled = !$AllNodes.FaultToleranceLoggingEnabled
            VMotionEnabled = !$AllNodes.VMotionEnabled
            VsanTrafficEnabled = !$AllNodes.VsanTrafficEnabled
        }
    }
}

Configuration VMHostVdsNic_UpdateVMHostVDSwitchNicIPAndSubnetMask_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostVdsNic $AllNodes.VDSwitchNicResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            VdsName = $AllNodes.VDSwitchName
            PortGroupName = $AllNodes.VDPortGroupName
            PortId = $AllNodes.PortId
            Ensure = 'Present'
            IP = $AllNodes.IP2
            SubnetMask = $AllNodes.SubnetMask2
            Mac = $AllNodes.Mac
            IPv6 = $AllNodes.IPv6
            Mtu = $AllNodes.VMKernelNetworkAdapterMtu
            ManagementTrafficEnabled = $AllNodes.ManagementTrafficEnabled
            FaultToleranceLoggingEnabled = $AllNodes.FaultToleranceLoggingEnabled
            VMotionEnabled = $AllNodes.VMotionEnabled
            VsanTrafficEnabled = $AllNodes.VsanTrafficEnabled
        }
    }
}

Configuration VMHostVdsNic_UpdateVMHostVDSwitchNicIPv6Settings_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostVdsNic $AllNodes.VDSwitchNicResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            VdsName = $AllNodes.VDSwitchName
            PortGroupName = $AllNodes.VDPortGroupName
            PortId = $AllNodes.PortId
            Ensure = 'Present'
            IP = $AllNodes.IP1
            SubnetMask = $AllNodes.SubnetMask1
            Mac = $AllNodes.Mac
            AutomaticIPv6 = !$AllNodes.AutomaticIPv6
            IPv6 = @()
            IPv6ThroughDhcp = !$AllNodes.IPv6ThroughDhcp
            Mtu = $AllNodes.VMKernelNetworkAdapterMtu
            ManagementTrafficEnabled = $AllNodes.ManagementTrafficEnabled
            FaultToleranceLoggingEnabled = $AllNodes.FaultToleranceLoggingEnabled
            VMotionEnabled = $AllNodes.VMotionEnabled
            VsanTrafficEnabled = $AllNodes.VsanTrafficEnabled
        }
    }
}

Configuration VMHostVdsNic_UpdateVMHostVDSwitchNicDhcpAndIPv6_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostVdsNic $AllNodes.VDSwitchNicResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            VdsName = $AllNodes.VDSwitchName
            PortGroupName = $AllNodes.VDPortGroupName
            PortId = $AllNodes.PortId
            Ensure = 'Present'
            IP = $AllNodes.DefaultIP
            SubnetMask = $AllNodes.DefaultSubnetMask
            Mac = $AllNodes.Mac
            Dhcp = $AllNodes.Dhcp
            AutomaticIPv6 = !$AllNodes.AutomaticIPv6
            IPv6 = $AllNodes.DefaultIPv6
            IPv6ThroughDhcp = !$AllNodes.IPv6ThroughDhcp
            Mtu = $AllNodes.VMKernelNetworkAdapterMtu
            IPv6Enabled = !$AllNodes.IPv6Enabled
            ManagementTrafficEnabled = $AllNodes.ManagementTrafficEnabled
            FaultToleranceLoggingEnabled = $AllNodes.FaultToleranceLoggingEnabled
            VMotionEnabled = $AllNodes.VMotionEnabled
            VsanTrafficEnabled = $AllNodes.VsanTrafficEnabled
        }
    }
}

Configuration VMHostVdsNic_RemoveVMHostVDSwitchNic_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostVdsNic $AllNodes.VDSwitchNicResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            VdsName = $AllNodes.VDSwitchName
            PortGroupName = $AllNodes.VDPortGroupName
            PortId = $AllNodes.PortId
            Ensure = 'Absent'
        }
    }
}

Configuration VMHostVdsNic_RemoveVMHostVDSwitchNicVDPortGroupAndVDSwitch_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostVdsNic $AllNodes.VDSwitchNicResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            VdsName = $AllNodes.VDSwitchName
            PortGroupName = $AllNodes.VDPortGroupName
            Ensure = 'Absent'
        }

        VDSwitch $AllNodes.VDSwitchResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.VDSwitchName
            Location = $AllNodes.VDSwitchLocation
            DatacenterName = $AllNodes.DatacenterName
            DatacenterLocation = $AllNodes.DatacenterLocation
            Ensure = 'Absent'
            DependsOn = $AllNodes.VDSwitchNicResourceId
        }
    }
}
