<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

Configuration VMHostSNMPAgent_ModifyVMHostSNMPAgentConfiguration_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostSNMPAgent $AllNodes.VMHostSNMPAgentResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.VMHostName
            Authentication = $AllNodes.SNMPAgentAuthenticationProtocol
            Enable = $AllNodes.EnableSNMPAgent
            Hwsrc = $AllNodes.SNMPAgentHwsrc
            LargeStorage = $AllNodes.SNMPAgentLargeStorage
            LogLevel = $AllNodes.SNMPAgentLogLevel
            Port = $AllNodes.SNMPAgentPort
            Privacy = $AllNodes.SNMPAgentPrivacyProtocol
        }
    }
}

Configuration VMHostSNMPAgent_ResetVMHostSNMPAgentConfiguration_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostSNMPAgent $AllNodes.VMHostSNMPAgentResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.VMHostName
            Reset = $AllNodes.ResetSNMPAgent
        }
    }
}

Configuration VMHostSNMPAgent_ModifyVMHostSNMPAgentConfigurationToInitialState_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostSNMPAgent $AllNodes.VMHostSNMPAgentResourceName {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.VMHostName
            Authentication = $AllNodes.InitialVMHostSNMPAgentAuthentication
            Communities = $AllNodes.InitialVMHostSNMPAgentCommunities
            Enable = $AllNodes.InitialVMHostSNMPAgentEnableState
            EngineId = $AllNodes.InitialVMHostSNMPAgentEngineId
            Hwsrc = $AllNodes.InitialVMHostSNMPAgentHwsrc
            LargeStorage = $AllNodes.InitialVMHostSNMPAgentLargeStorage
            LogLevel = $AllNodes.InitialVMHostSNMPAgentLogLevel
            NoTraps = $AllNodes.InitialVMHostSNMPAgentNoTraps
            Port = $AllNodes.InitialVMHostSNMPAgentPort
            Privacy = $AllNodes.InitialVMHostSNMPAgentPrivacy
            RemoteUsers = $AllNodes.InitialVMHostSNMPAgentRemoteUsers
            SysContact = $AllNodes.InitialVMHostSNMPAgentSysContact
            SysLocation = $AllNodes.InitialVMHostSNMPAgentSysLocation
            Targets = $AllNodes.InitialVMHostSNMPAgentTargets
            Users = $AllNodes.InitialVMHostSNMPAgentUsers
            V3Targets = $AllNodes.InitialVMHostSNMPAgentV3Targets
        }
    }
}
