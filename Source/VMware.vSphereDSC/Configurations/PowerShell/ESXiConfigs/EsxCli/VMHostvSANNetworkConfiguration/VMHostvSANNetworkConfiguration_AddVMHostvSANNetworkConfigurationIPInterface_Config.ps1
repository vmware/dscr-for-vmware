<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

Param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Server,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $User,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Password,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Name,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $VMHostVMKernelNetworkAdapterName
)

$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (ConvertTo-SecureString -String $Password -AsPlainText -Force)

$script:configurationData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
            Server = $Server
            Credential = $Credential
            Name = $Name
            VMHostVMKernelNetworkAdapterName = $VMHostVMKernelNetworkAdapterName
        }
    )
}

<#
.DESCRIPTION

Adds a new vSAN network configuration IP Interface where the interface name is the specified VMKernel Network Adapter name. The time-to-live for multicast packets is '5' and the traffic type is 'vsan'.
Also specified are the settings for the 'Agent' and 'Master' groups as well as the unicast address port for the VMHost unicast channel: '12321'.
#>
Configuration VMHostvSANNetworkConfiguration_AddVMHostvSANNetworkConfigurationIPInterface_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostvSANNetworkConfiguration VMHostvSANNetworkConfiguration {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.Name
            InterfaceName = $AllNodes.VMHostVMKernelNetworkAdapterName
            Ensure = 'Present'
            AgentV6McAddr = 'ff19::2:3:4'
            AgentMcAddr = '224.2.3.4'
            AgentMcPort = 23451
            HostUcPort = 12321
            MasterV6McAddr = 'ff19::1:2:3'
            MasterMcAddr = '224.1.2.3'
            MasterMcPort = 12345
            MulticastTtl = 5
            TrafficType = 'vsan'
        }
    }
}

VMHostvSANNetworkConfiguration_AddVMHostvSANNetworkConfigurationIPInterface_Config -ConfigurationData $script:configurationData
