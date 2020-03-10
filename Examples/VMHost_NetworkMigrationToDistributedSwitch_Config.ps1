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
            PhysicalNicNames = @('<physical nic name 1>', '<physical nic name 2>')
            VMKernelNicNames = @('<vmkernel nic name 1>', '<vmkernel nic name 2>')
        }
    )
}

<#
.DESCRIPTION

Creates Datacenter 'Datacenter' in the 'root' folder of the Inventory.

Creates Distributed Switch 'MyVDSwitch' with the specified version, maximum number of ports and link discovery protocol settings in the
    'network' folder of Datacenter 'Datacenter'.

Creates two Distributed Port Groups 'Management Network' and 'VM Network' on vSphere Distributed Switch 'MyVDSwitch' with 'Static' Port Binding and '8' Ports.

Adds the specified VMHost to vSphere Distributed Switch 'MyVDSwitch'.

Migrates the specified Physical Network Adapters to vSphere Distributed Switch 'MyVDSwitch'. Migrates the specified VMKernel Network Adapters to
    vSphere Distributed Switch 'MyVDSwitch' and attaches them to Port Groups 'Management Network' and 'VM Network' respectively.
#>
Configuration VMHost_NetworkMigrationToDistributedSwitch_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $AllNodes.User, (ConvertTo-SecureString -String $AllNodes.Password -AsPlainText -Force)

        Datacenter Datacenter {
            Server = $AllNodes.Server
            Credential = $Credential
            Name = 'Datacenter'
            Location = ''
            Ensure = 'Present'
        }

        VDSwitch VDSwitch {
            Server = $AllNodes.Server
            Credential = $Credential
            Name = 'MyVDSwitch'
            Location = ''
            DatacenterName = 'Datacenter'
            DatacenterLocation = ''
            Ensure = 'Present'
            ContactDetails = 'My Contact Details'
            ContactName = 'My Contact Name'
            LinkDiscoveryProtocol = 'CDP'
            LinkDiscoveryProtocolOperation = 'Advertise'
            MaxPorts = 100
            Mtu = 2000
            Notes = 'My Notes for Distributed Switch'
            NumUplinkPorts = 10
            Version = '6.6.0'
            DependsOn = '[Datacenter]Datacenter'
        }

        VDPortGroup VDPortGroupManagementNetwork {
            Server = $AllNodes.Server
            Credential = $Credential
            Name = 'Management Network'
            VdsName = 'MyVDSwitch'
            Ensure = 'Present'
            NumPorts = 8
            Notes = 'Management Network Notes'
            PortBinding = 'Static'
            DependsOn = '[VDSwitch]VDSwitch'
        }

        VDPortGroup VDPortGroupVMNetwork {
            Server = $AllNodes.Server
            Credential = $Credential
            Name = 'VM Network'
            VdsName = 'MyVDSwitch'
            Ensure = 'Present'
            NumPorts = 8
            Notes = 'VM Network Notes'
            PortBinding = 'Static'
            DependsOn = '[VDSwitch]VDSwitch'
        }

        VDSwitchVMHost VDSwitchVMHost {
            Server = $AllNodes.Server
            Credential = $Credential
            VdsName = 'MyVDSwitch'
            VMHostNames = @($AllNodes.VMHostName)
            Ensure = 'Present'
            DependsOn = '[VDSwitch]VDSwitch'
        }

        VMHostVDSwitchMigration VMHostVDSwitchMigration {
            Server = $AllNodes.Server
            Credential = $Credential
            VMHostName = $AllNodes.VMHostName
            VdsName = 'MyVDSwitch'
            PhysicalNicNames = $AllNodes.PhysicalNicNames
            VMKernelNicNames = $AllNodes.VMKernelNicNames
            PortGroupNames = @('Management Network', 'VM Network')
            DependsOn = @('[VDPortGroup]VDPortGroupManagementNetwork', '[VDPortGroup]VDPortGroupVMNetwork', '[VDSwitchVMHost]VDSwitchVMHost')
        }
    }
}

VMHost_NetworkMigrationToDistributedSwitch_Config -ConfigurationData $script:configurationData
