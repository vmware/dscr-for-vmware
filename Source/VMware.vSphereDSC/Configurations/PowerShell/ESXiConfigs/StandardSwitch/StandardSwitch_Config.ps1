<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

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
    $VMHostName
)

$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (ConvertTo-SecureString -String $Password -AsPlainText -Force)

$script:configurationData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
        }
    )
}

<#
.DESCRIPTION

Creates/modifies Standard Switch 'MyStandardSwitch' with maximum transmission unit '1500 bytes'.
Physical Network Adapters 'vmnic2' and 'vmnic3' are bridged to Standard Switch 'MyStandardSwitch' with configured beacon probing and link discovery protocol type 'CDP' and operation 'Listen'.
'Promiscuous mode', 'Forged Transmits' and 'Mac Changes' are enabled for Standard Switch 'MyStandardSwitch'.
The shaping policy for Standard Switch 'MyStandardSwitch' is 'enabled' with average bandwidth in bits per second '104857600000', peak bandwidth during bursts in bits per second '104857600000' and
the maximum burst size allowed in bytes '107374182400'. The active Nic is 'vmnic2', the standby Nic is 'vmnnic3', the Network Adapter teaming policy is 'LoadBalanceSrcId'. The Physical Network Adapters are
notified if a link fails. Rolling policy when restoring links is not used. Beacon probing as a method to validate the link status of a Physical Network Adapter is not enabled.
#>
Configuration StandardSwitch_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        StandardSwitch StandardSwitch {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            Name = 'MyStandardSwitch'
            Ensure = 'Present'
            Mtu = 1500
            NicDevice = @('vmnic2', 'vmnic3')
            BeaconInterval = 1
            LinkDiscoveryProtocolType = 'CDP'
            LinkDiscoveryProtocolOperation = 'Listen'
            AllowPromiscuous = $true
            ForgedTransmits = $true
            MacChanges = $true
            Enabled = $true
            AverageBandwidth = 104857600000
            PeakBandwidth = 104857600000
            BurstSize = 107374182400
            CheckBeacon = $false
            ActiveNic = @('vmnic2')
            StandbyNic = @('vmnic3')
            NotifySwitches = $true
            Policy = 'Loadbalance_srcid'
            RollingOrder = $false
        }
    }
}

StandardSwitch_Config -ConfigurationData $script:configurationData
