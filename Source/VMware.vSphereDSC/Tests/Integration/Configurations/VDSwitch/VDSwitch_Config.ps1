<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

Configuration VDSwitch_WhenAddingDistributedSwitch_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        Datacenter $AllNodes.DatacenterResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.DatacenterName
            Location = $AllNodes.DatacenterLocation
            Ensure = 'Present'
        }

        VDSwitch $AllNodes.DistributedSwitchResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.DistributedSwitchName
            Location = $AllNodes.Location
            DatacenterName = $AllNodes.DatacenterName
            DatacenterLocation = $AllNodes.DatacenterLocation
            Ensure = 'Present'
            ContactDetails = $AllNodes.ContactDetails
            ContactName = $AllNodes.ContactName
            LinkDiscoveryProtocol = $AllNodes.LinkDiscoveryProtocol
            LinkDiscoveryProtocolOperation = $AllNodes.LinkDiscoveryProtocolOperationAdvertise
            MaxPorts = $AllNodes.MaxPorts
            Mtu = $AllNodes.Mtu
            Notes = $AllNodes.Notes
            NumUplinkPorts = $AllNodes.NumUplinkPorts
            Version = $AllNodes.Version
            DependsOn = $AllNodes.DatacenterResourceId
        }
    }
}

Configuration VDSwitch_WhenAddingDistributedSwitchViaReferenceVDSwitch_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VDSwitch $AllNodes.ReferenceVDSwitchResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.ReferenceVDSwitchName
            Location = $AllNodes.Location
            DatacenterName = $AllNodes.DatacenterName
            DatacenterLocation = $AllNodes.DatacenterLocation
            Ensure = 'Present'
            ReferenceVDSwitchName = $AllNodes.DistributedSwitchName
            WithoutPortGroups = $AllNodes.WithoutPortGroups
        }
    }
}

Configuration VDSwitch_WhenUpdatingDistributedSwitch_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VDSwitch $AllNodes.DistributedSwitchResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.DistributedSwitchName
            Location = $AllNodes.Location
            DatacenterName = $AllNodes.DatacenterName
            DatacenterLocation = $AllNodes.DatacenterLocation
            Ensure = 'Present'
            ContactName = $AllNodes.UpdatedContactName
            LinkDiscoveryProtocolOperation = $AllNodes.LinkDiscoveryProtocolOperationListen
            Mtu = $AllNodes.UpdatedMtu
        }
    }
}

Configuration VDSwitch_WhenRemovingDistributedSwitch_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VDSwitch $AllNodes.DistributedSwitchResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.DistributedSwitchName
            Location = $AllNodes.Location
            DatacenterName = $AllNodes.DatacenterName
            DatacenterLocation = $AllNodes.DatacenterLocation
            Ensure = 'Absent'
        }
    }
}

Configuration VDSwitch_WhenRemovingDistributedSwitchesAndDatacenter_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VDSwitch $AllNodes.ReferenceVDSwitchResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.ReferenceVDSwitchName
            Location = $AllNodes.Location
            DatacenterName = $AllNodes.DatacenterName
            DatacenterLocation = $AllNodes.DatacenterLocation
            Ensure = 'Absent'
        }

        VDSwitch $AllNodes.DistributedSwitchResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.DistributedSwitchName
            Location = $AllNodes.Location
            DatacenterName = $AllNodes.DatacenterName
            DatacenterLocation = $AllNodes.DatacenterLocation
            Ensure = 'Absent'
            DependsOn = $AllNodes.ReferenceVDSwitchResourceId
        }

        Datacenter $AllNodes.DatacenterResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.DatacenterName
            Location = $AllNodes.DatacenterLocation
            Ensure = 'Absent'
            DependsOn = $AllNodes.DistributedSwitchResourceId
        }
    }
}
