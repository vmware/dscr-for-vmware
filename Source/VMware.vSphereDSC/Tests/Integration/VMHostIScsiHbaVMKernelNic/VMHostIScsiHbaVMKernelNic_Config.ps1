<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

Configuration VMHostIScsiHbaVMKernelNic_CreateStandardSwitchStandardPortGroupsAndVMKernelNics_Config {
    Import-DscResource -ModuleName 'VMware.vSphereDSC'

    Node $AllNodes.NodeName {
        StandardSwitch $AllNodes.StandardSwitchDscResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            Name = $AllNodes.StandardSwitchName
            Ensure = 'Present'
            NicDevice = @($AllNodes.PhysicalNicNames)
            ActiveNic = @($AllNodes.PhysicalNicNames)
        }

        StandardPortGroup $AllNodes.ManagementStandardPortGroupDscResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            Name = $AllNodes.ManagementStandardPortGroupName
            VssName = $AllNodes.StandardSwitchName
            Ensure = 'Present'
            ActiveNic = $AllNodes.PhysicalNicNames[0]
            DependsOn = $AllNodes.StandardSwitchDscResourceId
        }

        StandardPortGroup $AllNodes.VMotionStandardPortGroupDscResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            Name = $AllNodes.VMotionStandardPortGroupName
            VssName = $AllNodes.StandardSwitchName
            Ensure = 'Present'
            ActiveNic = $AllNodes.PhysicalNicNames[1]
            DependsOn = $AllNodes.StandardSwitchDscResourceId
        }

        VMHostVssNic $AllNodes.ManagementVMHostVssNicResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            VssName = $AllNodes.StandardSwitchName
            PortGroupName = $AllNodes.ManagementStandardPortGroupName
            Ensure = 'Present'
            ManagementTrafficEnabled = $AllNodes.ManagementTrafficEnabled
            DependsOn = $AllNodes.ManagementStandardPortGroupDscResourceId
        }

        VMHostVssNic $AllNodes.VMotionVMHostVssNicResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            VssName = $AllNodes.StandardSwitchName
            PortGroupName = $AllNodes.VMotionStandardPortGroupName
            Ensure = 'Present'
            VMotionEnabled = $AllNodes.VMotionEnabled
            DependsOn = $AllNodes.VMotionStandardPortGroupDscResourceId
        }
    }
}

Configuration VMHostIScsiHbaVMKernelNic_BindVMKernelNicsToIscsiHba_Config {
    Import-DscResource -ModuleName 'VMware.vSphereDSC'

    Node $AllNodes.NodeName {
        VMHostIScsiHbaVMKernelNic $AllNodes.VMHostIScsiHbaVMKernelNicDscResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            IScsiHbaName = $AllNodes.IScsiHbaName
            VMKernelNicNames = $AllNodes.VMKernelNicNames
            Ensure = 'Present'
        }
    }
}

Configuration VMHostIScsiHbaVMKernelNic_UnbindVMKernelNicsToIscsiHba_Config {
    Import-DscResource -ModuleName 'VMware.vSphereDSC'

    Node $AllNodes.NodeName {
        VMHostIScsiHbaVMKernelNic $AllNodes.VMHostIScsiHbaVMKernelNicDscResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            IScsiHbaName = $AllNodes.IScsiHbaName
            VMKernelNicNames = $AllNodes.VMKernelNicNames
            Ensure = 'Absent'
            Force = $AllNodes.UnbindVMKernelNicsForce
        }
    }
}

Configuration VMHostIScsiHbaVMKernelNic_RemoveStandardSwitchStandardPortGroupsAndVMKernelNics_Config {
    Import-DscResource -ModuleName 'VMware.vSphereDSC'

    Node $AllNodes.NodeName {
        VMHostVssNic $AllNodes.ManagementVMHostVssNicResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            VssName = $AllNodes.StandardSwitchName
            PortGroupName = $AllNodes.ManagementStandardPortGroupName
            Ensure = 'Absent'
        }

        VMHostVssNic $AllNodes.VMotionVMHostVssNicResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            VssName = $AllNodes.StandardSwitchName
            PortGroupName = $AllNodes.VMotionStandardPortGroupName
            Ensure = 'Absent'
        }

        StandardPortGroup $AllNodes.ManagementStandardPortGroupDscResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            Name = $AllNodes.ManagementStandardPortGroupName
            VssName = $AllNodes.StandardSwitchName
            Ensure = 'Absent'
            DependsOn = $AllNodes.ManagementVMHostVssNicResourceId
        }

        StandardPortGroup $AllNodes.VMotionStandardPortGroupDscResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            Name = $AllNodes.VMotionStandardPortGroupName
            VssName = $AllNodes.StandardSwitchName
            Ensure = 'Absent'
            DependsOn = $AllNodes.VMotionVMHostVssNicResourceId
        }

        StandardSwitch $AllNodes.StandardSwitchDscResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            Name = $AllNodes.StandardSwitchName
            Ensure = 'Absent'
            DependsOn = @($AllNodes.ManagementStandardPortGroupDscResourceId, $AllNodes.VMotionStandardPortGroupDscResourceId)
        }
    }
}
