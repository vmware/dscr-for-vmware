<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

Configuration VMHostVssPortGroupTeaming_WhenAddingVirtualPortGroupAndStandardSwitch_Config {
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

        VMHostVssBridge $AllNodes.StandardSwitchBridgeResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.Name
            VssName = $AllNodes.StandardSwitchName
            Ensure = 'Present'
            BeaconInterval = $AllNodes.BeaconInterval
            LinkDiscoveryProtocolOperation = $AllNodes.LinkDiscoveryProtocolOperation
            LinkDiscoveryProtocolProtocol = $AllNodes.LinkDiscoveryProtocolProtocol
            NicDevice = $AllNodes.Nic
            DependsOn = $AllNodes.StandardSwitchResourceId
        }

        VMHostVssTeaming $AllNodes.StandardSwitchTeamingPolicyResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.Name
            VssName = $AllNodes.StandardSwitchName
            Ensure = 'Present'
            CheckBeacon = $AllNodes.CheckBeacon
            ActiveNic = $AllNodes.StandardSwitchActiveNic
            StandbyNic = $AllNodes.StandardSwitchStandbyNic
            NotifySwitches = $AllNodes.NotifySwitches
            Policy = $AllNodes.NicTeamingPolicy
            RollingOrder = $AllNodes.RollingOrder
            DependsOn = $AllNodes.StandardSwitchBridgeResourceId
        }

        VMHostVssPortGroup $AllNodes.VirtualPortGroupResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.Name
            Name = $AllNodes.VirtualPortGroupName
            VssName = $AllNodes.StandardSwitchName
            Ensure = 'Present'
            VLanId = $AllNodes.VLanId
            DependsOn = $AllNodes.StandardSwitchTeamingPolicyResourceId
        }
    }
}

Configuration VMHostVssPortGroupTeaming_WhenUpdatingTeamingPolicyWithoutInheritSettings_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostVssPortGroupTeaming $AllNodes.VirtualPortGroupTeamingPolicyResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.Name
            Name = $AllNodes.VirtualPortGroupName
            Ensure = 'Present'
            FailbackEnabled = $AllNodes.FailbackEnabled
            LoadBalancingPolicy = $AllNodes.LoadBalancingPolicy
            ActiveNic = $AllNodes.ActiveNic
            StandbyNic = $AllNodes.StandbyNic
            UnusedNic = $AllNodes.DefaultUnusedNic
            NetworkFailoverDetectionPolicy = $AllNodes.NetworkFailoverDetectionPolicyLinkStatus
            NotifySwitches = $AllNodes.NotifySwitches
        }
    }
}

Configuration VMHostVssPortGroupTeaming_WhenUpdatingTeamingPolicyWithInheritSettingsSetToFalse_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostVssPortGroupTeaming $AllNodes.VirtualPortGroupTeamingPolicyResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.Name
            Name = $AllNodes.VirtualPortGroupName
            Ensure = 'Present'
            FailbackEnabled = $AllNodes.FailbackEnabled
            LoadBalancingPolicy = $AllNodes.LoadBalancingPolicy
            ActiveNic = $AllNodes.ActiveNic
            StandbyNic = $AllNodes.DefaultStandbyNic
            UnusedNic = $AllNodes.UnusedNic
            NetworkFailoverDetectionPolicy = $AllNodes.NetworkFailoverDetectionPolicyLinkStatus
            NotifySwitches = $AllNodes.NotifySwitches
            InheritFailback = $AllNodes.InheritFailback
            InheritLoadBalancingPolicy = $AllNodes.InheritLoadBalancingPolicy
            InheritNetworkFailoverDetectionPolicy = $AllNodes.InheritNetworkFailoverDetectionPolicy
            InheritNotifySwitches = $AllNodes.InheritNotifySwitches
        }
    }
}

Configuration VMHostVssPortGroupTeaming_WhenUpdatingTeamingPolicyWithInheritSettingsSetToTrue_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostVssPortGroupTeaming $AllNodes.VirtualPortGroupTeamingPolicyResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.Name
            Name = $AllNodes.VirtualPortGroupName
            Ensure = 'Present'
            FailbackEnabled = $AllNodes.FailbackEnabled
            LoadBalancingPolicy = $AllNodes.LoadBalancingPolicy
            ActiveNic = $AllNodes.Nic
            StandbyNic = $AllNodes.DefaultStandbyNic
            UnusedNic = $AllNodes.DefaultUnusedNic
            NetworkFailoverDetectionPolicy = $AllNodes.NetworkFailoverDetectionPolicyBeaconProbing
            NotifySwitches = $AllNodes.NotifySwitches
            InheritFailback = !$AllNodes.InheritFailback
            InheritFailoverOrder = !$AllNodes.InheritFailoverOrder
            InheritLoadBalancingPolicy = !$AllNodes.InheritLoadBalancingPolicy
            InheritNetworkFailoverDetectionPolicy = !$AllNodes.InheritNetworkFailoverDetectionPolicy
            InheritNotifySwitches = !$AllNodes.InheritNotifySwitches
        }
    }
}

Configuration VMHostVssPortGroupTeaming_WhenRemovingVirtualPortGroupAndStandardSwitch_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostVssPortGroup $AllNodes.VirtualPortGroupResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.Name
            Name = $AllNodes.VirtualPortGroupName
            VssName = $AllNodes.StandardSwitchName
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
