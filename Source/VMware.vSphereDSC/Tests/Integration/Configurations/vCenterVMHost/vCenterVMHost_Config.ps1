<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

Configuration vCenterVMHost_CreateDatacenter_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        Datacenter $AllNodes.DatacenterResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.DatacenterName
            Location = $AllNodes.DatacenterLocation
            Ensure = 'Present'
        }
    }
}

Configuration vCenterVMHost_CreateFolder_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        Folder $AllNodes.FolderResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.FolderName
            Location = $AllNodes.FolderLocation
            DatacenterName = $AllNodes.DatacenterName
            DatacenterLocation = $AllNodes.DatacenterLocation
            Ensure = 'Present'
            FolderType = $AllNodes.HostFolderType
        }
    }
}

Configuration vCenterVMHost_CreateCluster_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        Cluster $AllNodes.ClusterResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.ClusterName
            Location = $AllNodes.ClusterLocation
            DatacenterName = $AllNodes.DatacenterName
            DatacenterLocation = $AllNodes.DatacenterLocation
            Ensure = 'Present'
            DrsEnabled = $AllNodes.DrsEnabled
        }
    }
}

Configuration vCenterVMHost_AddVMHostTovCenter_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        vCenterVMHost $AllNodes.vCenterVMHostResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.VMHostName
            Location = $AllNodes.VMHostDatacenterLocation
            DatacenterName = $AllNodes.DatacenterName
            DatacenterLocation = $AllNodes.DatacenterLocation
            Ensure = 'Present'
            VMHostCredential = $AllNodes.VMHostCredential
            Port = $AllNodes.VMHostPort
            Force = $AllNodes.Force
        }
    }
}

Configuration vCenterVMHost_MoveVMHostToFolder_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        vCenterVMHost $AllNodes.vCenterVMHostResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.VMHostName
            Location = $AllNodes.VMHostFolderLocation
            DatacenterName = $AllNodes.DatacenterName
            DatacenterLocation = $AllNodes.DatacenterLocation
            Ensure = 'Present'
            VMHostCredential = $AllNodes.VMHostCredential
        }
    }
}

Configuration vCenterVMHost_MoveVMHostToCluster_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        vCenterVMHost $AllNodes.vCenterVMHostResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.VMHostName
            Location = $AllNodes.VMHostClusterLocation
            DatacenterName = $AllNodes.DatacenterName
            DatacenterLocation = $AllNodes.DatacenterLocation
            Ensure = 'Present'
            VMHostCredential = $AllNodes.VMHostCredential
        }
    }
}

Configuration vCenterVMHost_MoveVMHostToClusterAndImportResourcePoolHierarchy_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        vCenterVMHost $AllNodes.vCenterVMHostResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.VMHostName
            Location = $AllNodes.VMHostClusterLocation
            DatacenterName = $AllNodes.DatacenterName
            DatacenterLocation = $AllNodes.DatacenterLocation
            Ensure = 'Present'
            VMHostCredential = $AllNodes.VMHostCredential
            ResourcePoolLocation = $AllNodes.ResourcePoolLocation
        }
    }
}

Configuration vCenterVMHost_RemoveVMHostFromvCenter_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        vCenterVMHost $AllNodes.vCenterVMHostResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.VMHostName
            Location = $AllNodes.VMHostDatacenterLocation
            DatacenterName = $AllNodes.DatacenterName
            DatacenterLocation = $AllNodes.DatacenterLocation
            Ensure = 'Absent'
            VMHostCredential = $AllNodes.VMHostCredential
        }
    }
}

Configuration vCenterVMHost_RemoveCluster_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        Cluster $AllNodes.ClusterResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.ClusterName
            Location = $AllNodes.ClusterLocation
            DatacenterName = $AllNodes.DatacenterName
            DatacenterLocation = $AllNodes.DatacenterLocation
            Ensure = 'Absent'
        }
    }
}

Configuration vCenterVMHost_RemoveFolder_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        Folder $AllNodes.FolderResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.FolderName
            Location = $AllNodes.FolderLocation
            DatacenterName = $AllNodes.DatacenterName
            DatacenterLocation = $AllNodes.DatacenterLocation
            Ensure = 'Absent'
            FolderType = $AllNodes.HostFolderType
        }
    }
}

Configuration vCenterVMHost_RemoveDatacenter_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        Datacenter $AllNodes.DatacenterResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.DatacenterName
            Location = $AllNodes.DatacenterLocation
            Ensure = 'Absent'
        }
    }
}
