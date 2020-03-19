<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

$script:configurationData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
            Server = '<server>'
            User = '<user>'
            Password = '<password>'
            VMHostName = '<vmhost name>'
            VMHostUser = '<vmhost user>'
            VMHostPassword = '<vmhost password>'
            NicDevice = @('<physical nic name 1>', '<physical nic name 2>')
            ActiveNic = @('<physical nic name 1>')
            StandbyNic = @('<physical nic name 2>')
        }
    )
}

<#
.DESCRIPTION

Creates Datacenter 'Datacenter' in the 'root' folder of the Inventory.

Adds the specified VMHost to Datacenter 'Datacenter'. The port for connecting to the VMHost is specified to be '443'.
    Force is used to ignore the invalid SSL certificate of the VMHost.

Creates/modifies Standard Switch 'MyStandardSwitch' with maximum transmission unit '1500' bytes. The specified Physical Network Adapters are bridged to
    Standard Switch 'MyStandardSwitch' with configured beacon probing and link discovery protocol type 'CDP' and operation 'Listen'.
    'Promiscuous mode', 'Forged Transmits' and 'Mac Changes' are enabled for Standard Switch 'MyStandardSwitch'.
    The shaping policy for Standard Switch 'MyStandardSwitch' is 'enabled' with average bandwidth in bits per second '104857600000',
    peak bandwidth during bursts in bits per second '104857600000' and the maximum burst size allowed in bytes '107374182400'.
    The active and standby Nics are the specified ones, the Network Adapter teaming policy is 'LoadBalanceSrcId'. The Physical Network Adapters are notified
    if a link fails. Rolling policy when restoring links is not used. Beacon probing as a method to validate the link status of a Physical Network Adapter is not enabled.

Creates/modifies Standard Port Group 'MyStandardPortGroup' which belongs to Standard Switch 'MyStandardSwitch' with VLanId set to '1'.
    Enables the Shaping Policy and sets the 'BurstSize', 'Average' and 'Peak bandwidth' values.
    Enables 'Promiscuous mode', 'Forged Transmits' and 'Mac Changes'. The Security Policy settings are not inherited from the parent Standard Switch 'MyStandardSwitch'.
    Sets the active Nics to be the specified ones, the LoadBalancing Policy to 'LoadBalanceIP' and the NetworkFailover Policy to 'LinkStatus'. The Teaming Policy
    settings are not inherited from the parent Standard Switch 'MyStandardSwitch'.

Creates VMKernel Network Adapter with the the specified IPv4 and IPv6 addresses adding it to Standard Switch 'MyStandardSwitch' and
    Standard Port Group 'MyStandardPortGroup'. vMotion is 'enabled' for the created VMKernel Network Adapter.
#>
Configuration VMHost_Network_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $AllNodes.User, (ConvertTo-SecureString -String $AllNodes.Password -AsPlainText -Force)
        $VMHostCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $AllNodes.VMHostUser, (ConvertTo-SecureString -String $AllNodes.VMHostPassword -AsPlainText -Force)

        Datacenter Datacenter {
            Server = $AllNodes.Server
            Credential = $Credential
            Name = 'Datacenter'
            Location = ''
            Ensure = 'Present'
        }

        vCenterVMHost vCenterVMHost {
            Server = $AllNodes.Server
            Credential = $Credential
            Name = $AllNodes.VMHostName
            Location = ''
            DatacenterName = 'Datacenter'
            DatacenterLocation = ''
            Ensure = 'Present'
            VMHostCredential = $VMHostCredential
            Port = 443
            Force = $true
            DependsOn = '[Datacenter]Datacenter'
        }

        StandardSwitch StandardSwitch {
            Server = $AllNodes.Server
            Credential = $Credential
            VMHostName = $AllNodes.VMHostName
            Name = 'MyStandardSwitch'
            Ensure = 'Present'
            Mtu = 1500
            NicDevice = $AllNodes.NicDevice
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
            ActiveNic = $AllNodes.ActiveNic
            StandbyNic = $AllNodes.StandbyNic
            NotifySwitches = $true
            Policy = 'Loadbalance_srcid'
            RollingOrder = $false
            DependsOn = '[vCenterVMHost]vCenterVMHost'
        }

        StandardPortGroup StandardPortGroup {
            Server = $AllNodes.Server
            Credential = $Credential
            VMHostName = $AllNodes.VMHostName
            Name = 'MyStandardPortGroup'
            VssName = 'MyStandardSwitch'
            Ensure = 'Present'
            VLanId = 1
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
            ActiveNic = $AllNodes.ActiveNic
            StandbyNic = $AllNodes.StandbyNic
            UnusedNic = @()
            NetworkFailoverDetectionPolicy = 'LinkStatus'
            NotifySwitches = $false
            InheritFailback = $false
            InheritFailoverOrder = $false
            InheritLoadBalancingPolicy = $false
            InheritNetworkFailoverDetectionPolicy = $false
            InheritNotifySwitches = $false
            DependsOn = '[StandardSwitch]StandardSwitch'
        }

        VMHostVssNic VMHostVssNic {
            Server = $AllNodes.Server
            Credential = $Credential
            VMHostName = $AllNodes.VMHostName
            VssName = 'MyStandardSwitch'
            PortGroupName = 'MyStandardPortGroup'
            Ensure = 'Present'
            IP = '192.168.0.1'
            SubnetMask = '255.255.255.0'
            Mac = '00:50:56:63:5b:0e'
            AutomaticIPv6 = $true
            IPv6 = @('fe80::250:56ff:fe63:5b0e/64', '200:2342::1/32')
            IPv6ThroughDhcp = $true
            Mtu = 4000
            ManagementTrafficEnabled = $false
            FaultToleranceLoggingEnabled = $false
            VMotionEnabled = $true
            VsanTrafficEnabled = $false
            DependsOn = '[StandardPortGroup]StandardPortGroup'
        }
    }
}

VMHost_Network_Config -ConfigurationData $script:configurationData
