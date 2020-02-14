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
            VMHosts = @(
                @{
                    Server = '<server>'
                    User = '<user>'
                    Password = '<password>'
                },
                @{
                    Server = '<server>'
                    User = '<user>'
                    Password = '<password>'
                }
            )
        }
    )
}

Configuration Vss_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        foreach ($vmHost in $AllNodes.VMHosts) {
            $Server = $vmHost.Server
            $User = $vmHost.User
            $Password = $vmHost.Password | ConvertTo-SecureString -asPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential($User, $Password)

            VMHostVss "VMHostVSS_$Server" {
                Name = $Server
                Server = $Server
                Credential = $Credential
                Ensure = 'Present'
                VssName = 'VSSDSC'
                Mtu = 1500
            }

            VMHostVssSecurity "VMHostVSSSecurity_$Server" {
                Name = $Server
                Server = $Server
                Credential = $Credential
                Ensure = 'Present'
                VssName = 'VSSDSC'
                AllowPromiscuous = $true
                ForgedTransmits = $true
                MacChanges = $true
                DependsOn = "[VMHostVss]VMHostVSS_$Server"
            }

            VMHostVssShaping "VMHostVSSShaping_$Server" {
                Name = $Server
                Server = $Server
                Credential = $Credential
                Ensure = 'Present'
                VssName = 'VSSDSC'
                AverageBandwidth = 100000
                BurstSize = 100000
                Enabled = $true
                PeakBandwidth = 100000
                DependsOn = "[VMHostVss]VMHostVSS_$Server"
            }

            VMHostVssBridge "VMHostVSSBridge_$Server" {
                Name = $Server
                Server = $Server
                Credential = $Credential
                Ensure = 'Present'
                VssName = 'VSSDSC'
                BeaconInterval = 1
                LinkDiscoveryProtocolOperation = 'Listen'
                LinkDiscoveryProtocolProtocol = 'CDP'
                NicDevice = @('vmnic2', 'vmnic3')
                DependsOn = "[VMHostVss]VMHostVSS_$Server"
            }

            VMHostVssTeaming "VMHostVSSTeaming_$Server" {
                Name = $Server
                Server = $Server
                Credential = $Credential
                Ensure = 'Present'
                VssName = 'VSSDSC'
                CheckBeacon = $false
                ActiveNic = @('vmnic2')
                StandbyNic = @('vmnic3')
                NotifySwitches = $true
                Policy = 'Loadbalance_srcid'
                RollingOrder = $false
                DependsOn = "[VMHostVssBridge]VMHostVSSBridge_$Server"
            }
        }
    }
}

Vss_Config -ConfigurationData $script:configurationData
