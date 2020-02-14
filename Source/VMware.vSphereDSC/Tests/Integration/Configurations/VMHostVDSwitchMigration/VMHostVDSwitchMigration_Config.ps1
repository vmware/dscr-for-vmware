<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

Configuration VMHostVDSwitchMigration_CreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitch_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostVss $AllNodes.VMHostVssResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.VMHostName
            VssName = $AllNodes.StandardSwitchName
            Ensure = 'Present'
        }

        VMHostVssPortGroup $AllNodes.VMHostVssPortGroupResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            Name = $AllNodes.PortGroupName
            VssName = $AllNodes.StandardSwitchName
            Ensure = 'Present'
            DependsOn = $AllNodes.VMHostVssResourceId
        }

        VDSwitch $AllNodes.VDSwitchResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.VDSwitchName
            Location = $AllNodes.VDSwitchLocation
            DatacenterName = $AllNodes.DatacenterName
            DatacenterLocation = $AllNodes.DatacenterLocation
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

Configuration VMHostVDSwitchMigration_CreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapter_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostVssNic $AllNodes.VMHostVssManagementNicResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            VssName = $AllNodes.StandardSwitchName
            PortGroupName = $AllNodes.ManagementPortGroupName
            Ensure = 'Present'
            ManagementTrafficEnabled = $AllNodes.ManagementTrafficEnabled
        }

        VMHostVssNic $AllNodes.VMHostVssvMotionNicResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            VssName = $AllNodes.StandardSwitchName
            PortGroupName = $AllNodes.VMotionPortGroupName
            Ensure = 'Present'
            VMotionEnabled = $AllNodes.VMotionEnabled
        }
    }
}

Configuration VMHostVDSwitchMigration_MigrateThreePhysicalNetworkAdaptersToStandardSwitch_Config {
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

Configuration VMHostVDSwitchMigration_MigrateOneDisconnectedPhysicalNetworkAdapter_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostVDSwitchMigration $AllNodes.VMHostVDSwitchMigrationResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            VdsName = $AllNodes.VDSwitchName
            PhysicalNicNames = @($AllNodes.PhysicalNetworkAdapterNames[0])
        }
    }
}

Configuration VMHostVDSwitchMigration_MigrateTwoDisconnectedPhysicalNetworkAdapters_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostVDSwitchMigration $AllNodes.VMHostVDSwitchMigrationResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            VdsName = $AllNodes.VDSwitchName
            PhysicalNicNames = @($AllNodes.PhysicalNetworkAdapterNames[0], $AllNodes.PhysicalNetworkAdapterNames[1])
        }
    }
}

Configuration VMHostVDSwitchMigration_MigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdapters_Config {
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

Configuration VMHostVDSwitchMigration_MigrateOneDisconnectedPhysicalNetworkAdapterTwoVMKernelNetworkAdaptersAndOnePortGroup_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostVDSwitchMigration $AllNodes.VMHostVDSwitchMigrationResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            VdsName = $AllNodes.VDSwitchName
            PhysicalNicNames = @($AllNodes.PhysicalNetworkAdapterNames[0])
            VMKernelNicNames = $AllNodes.VMKernelNetworkAdapterNames
            PortGroupNames = @($AllNodes.PortGroupName)
        }
    }
}

Configuration VMHostVDSwitchMigration_MigrateOneDisconnectedPhysicalNetworkAdapterTwoVMKernelNetworkAdaptersAndTwoPortGroups_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostVDSwitchMigration $AllNodes.VMHostVDSwitchMigrationResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            VdsName = $AllNodes.VDSwitchName
            PhysicalNicNames = @($AllNodes.PhysicalNetworkAdapterNames[0])
            VMKernelNicNames = $AllNodes.VMKernelNetworkAdapterNames
            PortGroupNames = @($AllNodes.ManagementPortGroupName, $AllNodes.VMotionPortGroupName)
        }
    }
}

Configuration VMHostVDSwitchMigration_MigrateTwoDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndOnePortGroup_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostVDSwitchMigration $AllNodes.VMHostVDSwitchMigrationResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            VdsName = $AllNodes.VDSwitchName
            PhysicalNicNames = @($AllNodes.PhysicalNetworkAdapterNames[0], $AllNodes.PhysicalNetworkAdapterNames[1])
            VMKernelNicNames = $AllNodes.VMKernelNetworkAdapterNames
            PortGroupNames = @($AllNodes.PortGroupName)
        }
    }
}

Configuration VMHostVDSwitchMigration_MigrateTwoDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndTwoPortGroups_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostVDSwitchMigration $AllNodes.VMHostVDSwitchMigrationResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            VdsName = $AllNodes.VDSwitchName
            PhysicalNicNames = @($AllNodes.PhysicalNetworkAdapterNames[0], $AllNodes.PhysicalNetworkAdapterNames[1])
            VMKernelNicNames = $AllNodes.VMKernelNetworkAdapterNames
            PortGroupNames = @($AllNodes.ManagementPortGroupName, $AllNodes.VMotionPortGroupName)
        }
    }
}

Configuration VMHostVDSwitchMigration_MigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndOnePortGroup_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostVDSwitchMigration $AllNodes.VMHostVDSwitchMigrationResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            VdsName = $AllNodes.VDSwitchName
            PhysicalNicNames = $AllNodes.PhysicalNetworkAdapterNames
            VMKernelNicNames = $AllNodes.VMKernelNetworkAdapterNames
            PortGroupNames = @($AllNodes.PortGroupName)
        }
    }
}

Configuration VMHostVDSwitchMigration_MigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndTwoPortGroups_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostVDSwitchMigration $AllNodes.VMHostVDSwitchMigrationResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            VdsName = $AllNodes.VDSwitchName
            PhysicalNicNames = $AllNodes.PhysicalNetworkAdapterNames
            VMKernelNicNames = $AllNodes.VMKernelNetworkAdapterNames
            PortGroupNames = @($AllNodes.ManagementPortGroupName, $AllNodes.VMotionPortGroupName)
        }
    }
}

Configuration VMHostVDSwitchMigration_RemoveVDSwitchStandardSwitchAndStandardPortGroup_Config {
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

        VMHostVssPortGroup $AllNodes.VMHostVssPortGroupResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            Name = $AllNodes.PortGroupName
            VssName = $AllNodes.StandardSwitchName
            Ensure = 'Absent'
            DependsOn = $AllNodes.VDSwitchResourceId
        }

        VMHostVss $AllNodes.VMHostVssResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.VMHostName
            VssName = $AllNodes.StandardSwitchName
            Ensure = 'Absent'
            DependsOn = $AllNodes.VMHostVssPortGroupResourceId
        }
    }
}

Configuration VMHostVDSwitchMigration_MigratePhysicalNetworkAdaptersToInitialVirtualSwitches_Config {
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
