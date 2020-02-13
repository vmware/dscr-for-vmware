<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

Configuration VMHostScsiLun_ModifyVMHostScsiLunConfigurationWithRoundRobinMultipathPolicy_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostScsiLun $AllNodes.VMHostScsiLunResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            CanonicalName = $AllNodes.ScsiLunCanonicalName
            MultipathPolicy = $AllNodes.ScsiLunRoundRobinMultipathPolicy
            PreferredScsiLunPathName = $AllNodes.ScsiLunPathName
            BlocksToSwitchPath = $AllNodes.ScsiLunBlocksToSwitchPath
            CommandsToSwitchPath = $AllNodes.ScsiLunCommandsToSwitchPath
            IsLocal = $AllNodes.ScsiLunIsLocal
            IsSsd = $AllNodes.ScsiLunIsSsd
        }
    }
}

Configuration VMHostScsiLun_ModifyVMHostScsiLunConfigurationWithFixedMultipathPolicy_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostScsiLun $AllNodes.VMHostScsiLunResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            CanonicalName = $AllNodes.ScsiLunCanonicalName
            MultipathPolicy = $AllNodes.ScsiLunFixedMultipathPolicy
            PreferredScsiLunPathName = $AllNodes.ScsiLunPathName
            BlocksToSwitchPath = $AllNodes.ScsiLunBlocksToSwitchPath
            CommandsToSwitchPath = $AllNodes.ScsiLunCommandsToSwitchPath
            IsLocal = $AllNodes.ScsiLunIsLocal
            IsSsd = $AllNodes.ScsiLunIsSsd
        }
    }
}

Configuration VMHostScsiLun_ModifyVMHostScsiLunConfigurationToInitialState_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostScsiLun $AllNodes.VMHostScsiLunResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            CanonicalName = $AllNodes.ScsiLunCanonicalName
            MultipathPolicy = $AllNodes.InitialScsiLunMultipathPolicy
            PreferredScsiLunPathName = $AllNodes.ScsiLunPathName
            BlocksToSwitchPath = $AllNodes.InitialScsiLunBlocksToSwitchPath
            CommandsToSwitchPath = $AllNodes.InitialScsiLunCommandsToSwitchPath
            IsLocal = $AllNodes.InitialScsiLunIsLocal
            IsSsd = $AllNodes.InitialScsiLunIsSsd
        }
    }
}
