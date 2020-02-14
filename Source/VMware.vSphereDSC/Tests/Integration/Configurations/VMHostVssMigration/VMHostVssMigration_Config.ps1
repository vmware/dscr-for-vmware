<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

Configuration VMHostVssMigration_CreateVDSwitchTwoVDPortGroupsStandardSwitchAndAddVMHostToVDSwitch_Config {
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

        VDPortGroup $AllNodes.ManagementVDPortGroupResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.ManagementPortGroupName
            VdsName = $AllNodes.VDSwitchName
            Ensure = 'Present'
            DependsOn = $AllNodes.VDSwitchResourceId
        }

        VDPortGroup $AllNodes.VMotionVDPortGroupResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.VMotionPortGroupName
            VdsName = $AllNodes.VDSwitchName
            Ensure = 'Present'
            DependsOn = $AllNodes.VDSwitchResourceId
        }

        VMHostVss $AllNodes.VMHostVssResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.VMHostName
            VssName = $AllNodes.StandardSwitchName
            Ensure = 'Present'
        }

        VDSwitchVMHost $AllNodes.VDSwitchVMHostResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VdsName = $AllNodes.VDSwitchName
            VMHostNames = @($AllNodes.VMHostName)
            Ensure = 'Present'
            DependsOn = $AllNodes.VDSwitchResourceId
        }
    }
}

Configuration VMHostVssMigration_MigrateThreePhysicalNetworkAdaptersToDistributedSwitch_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostVDSwitchMigration $AllNodes.VMHostVDSwitchMigrationResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            VdsName = $AllNodes.VDSwitchName
            PhysicalNicNames = $AllNodes.PhysicalNetworkAdapterNames
        }
    }
}

Configuration VMHostVssMigration_MigrateThreePhysicalNetworkAdaptersToStandardSwitch_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostVssMigration $AllNodes.VMHostVssMigrationResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            VssName = $AllNodes.StandardSwitchName
            PhysicalNicNames = $AllNodes.PhysicalNetworkAdapterNames
        }
    }
}

Configuration VMHostVssMigration_MigrateThreePhysicalNetworkAdaptersAndTwoVMKernelNetworkAdaptersToStandardSwitch_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostVssMigration $AllNodes.VMHostVssMigrationResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            VssName = $AllNodes.StandardSwitchName
            PhysicalNicNames = $AllNodes.PhysicalNetworkAdapterNames
            VMKernelNicNames = $AllNodes.VMKernelNetworkAdapterNames
        }
    }
}

Configuration VMHostVssMigration_MigrateThreePhysicalNetworkAdaptersAndTwoVMKernelNetworkAdaptersWithPortGroupsToStandardSwitch_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostVssMigration $AllNodes.VMHostVssMigrationResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            VssName = $AllNodes.StandardSwitchName
            PhysicalNicNames = $AllNodes.PhysicalNetworkAdapterNames
            VMKernelNicNames = $AllNodes.VMKernelNetworkAdapterNames
            PortGroupNames = @($AllNodes.ManagementPortGroupName, $AllNodes.VMotionPortGroupName)
        }
    }
}

Configuration VMHostVssMigration_RemoveManagementAndvMotionVMKernelNetworkAdaptersWithPortGroupsWithVMKernelPrefixFromStandardSwitch_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostVssNic $AllNodes.VMHostVssManagementNicResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            VssName = $AllNodes.StandardSwitchName
            PortGroupName = $AllNodes.PortGroupNamesWithVMKernelPrefix[0]
            Ensure = 'Absent'
        }

        VMHostVssNic $AllNodes.VMHostVssvMotionNicResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            VssName = $AllNodes.StandardSwitchName
            PortGroupName = $AllNodes.PortGroupNamesWithVMKernelPrefix[1]
            Ensure = 'Absent'
        }
    }
}

Configuration VMHostVssMigration_RemoveManagementAndvMotionVMKernelNetworkAdaptersFromStandardSwitch_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostVssNic $AllNodes.VMHostVssManagementNicResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            VssName = $AllNodes.StandardSwitchName
            PortGroupName = $AllNodes.ManagementPortGroupName
            Ensure = 'Absent'
        }

        VMHostVssNic $AllNodes.VMHostVssvMotionNicResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            VssName = $AllNodes.StandardSwitchName
            PortGroupName = $AllNodes.VMotionPortGroupName
            Ensure = 'Absent'
        }
    }
}

Configuration VMHostVssMigration_RemoveVDSwitchAndStandardSwitch_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VDSwitch $AllNodes.VDSwitchResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.VDSwitchName
            Location = $AllNodes.VDSwitchLocation
            DatacenterName = $AllNodes.DatacenterName
            DatacenterLocation = $AllNodes.DatacenterLocation
            Ensure = 'Absent'
        }

        VMHostVssPortGroup $AllNodes.ManagementStandardPortGroupResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            Name = $AllNodes.ManagementPortGroupName
            VssName = $AllNodes.StandardSwitchName
            Ensure = 'Absent'
        }

        VMHostVssPortGroup $AllNodes.VMotionStandardPortGroupResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            Name = $AllNodes.VMotionPortGroupName
            VssName = $AllNodes.StandardSwitchName
            Ensure = 'Absent'
        }

        foreach ($portGroupNameWithVMKernelPrefix in $AllNodes.PortGroupNamesWithVMKernelPrefix) {
            VMHostVssPortGroup $portGroupNameWithVMKernelPrefix {
                Server = $AllNodes.Server
                Credential = $AllNodes.Credential
                VMHostName = $AllNodes.VMHostName
                Name = $portGroupNameWithVMKernelPrefix
                VssName = $AllNodes.StandardSwitchName
                Ensure = 'Absent'
            }
        }

        VMHostVss $AllNodes.VMHostVssResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.VMHostName
            VssName = $AllNodes.StandardSwitchName
            Ensure = 'Absent'
            DependsOn = @($AllNodes.ManagementStandardPortGroupResourceId, $AllNodes.VMotionStandardPortGroupResourceId)
        }
    }
}

Configuration VMHostVssMigration_MigratePhysicalNetworkAdaptersToInitialVirtualSwitches_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        foreach ($virtualSwitchName in $AllNodes.VirtualSwitches.Keys) {
            VMHostVssBridge ($AllNodes.VMHostVssBridgeResourceName + $virtualSwitchName) {
                Server = $AllNodes.Server
                Credential = $AllNodes.Credential
                Name = $AllNodes.VMHostName
                VssName = $virtualSwitchName
                Ensure = 'Present'
                NicDevice = $AllNodes.VirtualSwitches.$virtualSwitchName.Nic
                LinkDiscoveryProtocolOperation = $AllNodes.LinkDiscoveryProtocolOperation
                LinkDiscoveryProtocolProtocol = $AllNodes.LinkDiscoveryProtocolProtocol
            }

            VMHostVssTeaming ($AllNodes.VMHostVssTeamingResourceName + $virtualSwitchName) {
                Server = $AllNodes.Server
                Credential = $AllNodes.Credential
                Name = $AllNodes.VMHostName
                VssName = $virtualSwitchName
                Ensure = 'Present'
                ActiveNic = $AllNodes.VirtualSwitches.$virtualSwitchName.ActiveNic
                StandbyNic = $AllNodes.VirtualSwitches.$virtualSwitchName.StandbyNic
                CheckBeacon = $AllNodes.VirtualSwitches.$virtualSwitchName.FailureCriteria.CheckBeacon
                NotifySwitches = $AllNodes.VirtualSwitches.$virtualSwitchName.NotifySwitches
                Policy = $AllNodes.VirtualSwitches.$virtualSwitchName.Policy
                RollingOrder = $AllNodes.VirtualSwitches.$virtualSwitchName.RollingOrder
                DependsOn = "[$($AllNodes.VMHostVssBridgeResourceName)]$($AllNodes.VMHostVssBridgeResourceName)$virtualSwitchName"
            }
        }
    }
}
