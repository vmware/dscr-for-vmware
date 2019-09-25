<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

Configuration VMHostVirtualPortGroupShapingPolicy_WhenAddingVirtualPortGroupAndStandardSwitch_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostVss $AllNodes.StandardSwitchResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.Name
            VssName = $AllNodes.StandardSwitchName
            Ensure = 'Present'
            Mtu = $AllNodes.Mtu
        }

        VMHostVirtualPortGroup $AllNodes.VirtualPortGroupResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.Name
            PortGroupName = $AllNodes.VirtualPortGroupName
            VirtualSwitch = $AllNodes.StandardSwitchName
            Ensure = 'Present'
            VLanId = $AllNodes.VLanId
            DependsOn = $AllNodes.StandardSwitchResourceId
        }
    }
}

Configuration VMHostVirtualPortGroupShapingPolicy_WhenUpdatingShapingPolicyWithEnabledSetToTrue_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostVirtualPortGroupShapingPolicy $AllNodes.VirtualPortGroupShapingPolicyResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.Name
            PortGroup = $AllNodes.VirtualPortGroupName
            Enabled = $AllNodes.ShapingEnabled
            AverageBandwidth = $AllNodes.AverageBandwidth
            PeakBandwidth = $AllNodes.PeakBandwidth
            BurstSize = $AllNodes.BurstSize
        }
    }
}

Configuration VMHostVirtualPortGroupShapingPolicy_WhenUpdatingShapingPolicyWithEnabledSetToFalse_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostVirtualPortGroupShapingPolicy $AllNodes.VirtualPortGroupShapingPolicyResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.Name
            PortGroup = $AllNodes.VirtualPortGroupName
            Enabled = !$AllNodes.ShapingEnabled
            BurstSize = $AllNodes.BurstSize
        }
    }
}

Configuration VMHostVirtualPortGroupShapingPolicy_WhenRemovingVirtualPortGroupAndStandardSwitch_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostVirtualPortGroup $AllNodes.VirtualPortGroupResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.Name
            PortGroupName = $AllNodes.VirtualPortGroupName
            VirtualSwitch = $AllNodes.StandardSwitchName
            Ensure = 'Absent'
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
