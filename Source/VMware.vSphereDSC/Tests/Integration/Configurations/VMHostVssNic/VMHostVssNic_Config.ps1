<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

Configuration VMHostVssNic_WhenAddingVMKernelNetworkAdapter_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostVss $AllNodes.StandardSwitchResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.Name
            VssName = $AllNodes.StandardSwitchName
            Ensure = 'Present'
            Mtu = $AllNodes.StandardSwitchMtu
        }

        VMHostVssNic $AllNodes.StandardSwitchNetworkAdapterResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.Name
            VssName = $AllNodes.StandardSwitchName
            PortGroupName = $AllNodes.PortGroup
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
            DependsOn = $AllNodes.StandardSwitchResourceId
        }
    }
}

Configuration VMHostVssNic_WhenUpdatingVMKernelNetworkAdapterMtuAndAvailableServices_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostVssNic $AllNodes.StandardSwitchNetworkAdapterResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.Name
            VssName = $AllNodes.StandardSwitchName
            PortGroupName = $AllNodes.PortGroup
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

Configuration VMHostVssNic_WhenUpdatingVMKernelNetworkAdapterIPAndSubnetMask_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostVssNic $AllNodes.StandardSwitchNetworkAdapterResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.Name
            VssName = $AllNodes.StandardSwitchName
            PortGroupName = $AllNodes.PortGroup
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

Configuration VMHostVssNic_WhenUpdatingVMKernelNetworkAdapterIPv6Settings_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostVssNic $AllNodes.StandardSwitchNetworkAdapterResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.Name
            VssName = $AllNodes.StandardSwitchName
            PortGroupName = $AllNodes.PortGroup
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

Configuration VMHostVssNic_WhenUpdatingVMKernelNetworkAdapterDhcpAndIPv6_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostVssNic $AllNodes.StandardSwitchNetworkAdapterResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.Name
            VssName = $AllNodes.StandardSwitchName
            PortGroupName = $AllNodes.PortGroup
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

Configuration VMHostVssNic_WhenRemovingVMKernelNetworkAdapter_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostVssNic $AllNodes.StandardSwitchNetworkAdapterResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.Name
            VssName = $AllNodes.StandardSwitchName
            PortGroupName = $AllNodes.PortGroup
            Ensure = 'Absent'
        }
    }
}

Configuration VMHostVssNic_WhenRemovingVMKernelNetworkAdapterAndStandardSwitch_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostVssNic $AllNodes.StandardSwitchNetworkAdapterResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.Name
            VssName = $AllNodes.StandardSwitchName
            PortGroupName = $AllNodes.PortGroup
            Ensure = 'Absent'
        }

        VMHostVssPortGroup $AllNodes.VirtualPortGroupResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.Name
            Name = $AllNodes.PortGroup
            VssName = $AllNodes.StandardSwitchName
            Ensure = 'Absent'
            DependsOn = $AllNodes.StandardSwitchNetworkAdapterResourceId
        }

        VMHostVss $AllNodes.StandardSwitchResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.Name
            VssName = $AllNodes.StandardSwitchName
            Ensure = 'Absent'
            DependsOn = $AllNodes.VirtualPortGroupResourceId
        }
    }
}
