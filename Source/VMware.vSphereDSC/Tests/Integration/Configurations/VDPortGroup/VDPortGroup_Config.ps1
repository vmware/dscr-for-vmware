<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

Configuration VDPortGroup_CreateDatacenterAndVDSwitch_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        Datacenter $AllNodes.DatacenterResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.DatacenterName
            Location = $AllNodes.DatacenterLocation
            Ensure = 'Present'
        }

        VDSwitch $AllNodes.VDSwitchResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.VDSwitchName
            Location = $AllNodes.VDSwitchLocation
            DatacenterName = $AllNodes.DatacenterName
            DatacenterLocation = $AllNodes.DatacenterLocation
            Ensure = 'Present'
            DependsOn = $AllNodes.DatacenterResourceId
        }
    }
}

Configuration VDPortGroup_CreateVDPortGroup_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VDPortGroup $AllNodes.VDPortGroupResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.VDPortGroupName
            VdsName = $AllNodes.VDSwitchName
            Ensure = 'Present'
            Notes = $AllNodes.VDPortGroupNotes
            NumPorts = $AllNodes.VDPortGroupNumPorts
            PortBinding = $AllNodes.VDPortGroupPortBinding
        }
    }
}

Configuration VDPortGroup_CreateVDPortGroupViaReferenceVDPortGroup_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VDPortGroup $AllNodes.ReferenceVDPortGroupResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.ReferenceVDPortGroupName
            VdsName = $AllNodes.VDSwitchName
            Ensure = 'Present'
            ReferenceVDPortGroupName = $AllNodes.VDPortGroupName
        }
    }
}

Configuration VDPortGroup_ModifyVDPortGroupNotesAndNumPorts_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VDPortGroup $AllNodes.VDPortGroupResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.VDPortGroupName
            VdsName = $AllNodes.VDSwitchName
            Ensure = 'Present'
            Notes = $AllNodes.VDPortGroupDefaultNotes
            NumPorts = $AllNodes.VDPortGroupDefaultNumPorts
            PortBinding = $AllNodes.VDPortGroupPortBinding
        }
    }
}

Configuration VDPortGroup_RemoveVDPortGroup_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VDPortGroup $AllNodes.VDPortGroupResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.VDPortGroupName
            VdsName = $AllNodes.VDSwitchName
            Ensure = 'Absent'
        }
    }
}

Configuration VDPortGroup_RemoveDatacenterVDSwitchAndVDPortGroup_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VDPortGroup $AllNodes.ReferenceVDPortGroupResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.ReferenceVDPortGroupName
            VdsName = $AllNodes.VDSwitchName
            Ensure = 'Absent'
        }

        VDPortGroup $AllNodes.VDPortGroupResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.VDPortGroupName
            VdsName = $AllNodes.VDSwitchName
            Ensure = 'Absent'
            DependsOn = $AllNodes.ReferenceVDPortGroupResourceId
        }

        VDSwitch $AllNodes.VDSwitchResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.VDSwitchName
            Location = $AllNodes.VDSwitchLocation
            DatacenterName = $AllNodes.DatacenterName
            DatacenterLocation = $AllNodes.DatacenterLocation
            Ensure = 'Absent'
            DependsOn = $AllNodes.VDPortGroupResourceId
        }

        Datacenter $AllNodes.DatacenterResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.DatacenterName
            Location = $AllNodes.DatacenterLocation
            Ensure = 'Absent'
            DependsOn = $AllNodes.VDSwitchResourceId
        }
    }
}
