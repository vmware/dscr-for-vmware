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
    $VMHostName
)

$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (ConvertTo-SecureString -String $Password -AsPlainText -Force)

<#
The helper function is needed because currently there is no DSC Resource to add VMHosts
to a specified Datacenter. So the Configuration relies that the passed VMHost is already
added to a vCenter and just retrieves the Datacenter information.
#>
. "$PSScriptRoot\VMHostVdsNic.Configs.Helper.ps1"
$Datacenter = Get-DatacenterInformation -Server $Server -Credential $Credential -VMHostName $VMHostName

$script:configurationData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            DatacenterName = $Datacenter.Name
            DatacenterLocation = $Datacenter.Location
        }
    )
}

<#
.DESCRIPTION

Creates a new vSphere Distributed Switch 'MyVDSwitch' in the Network Folder of the Datacenter of the specified VMHost.
Creates a new Distributed Port Group 'MyVDPortGroup' on vSphere Distributed Switch 'MyVDSwitch'.
Adds the specified VMHost to vSphere Distributed Switch 'MyVDSwitch'.
Creates a new VMKernel Network Adapter with the specified settings, connected to vSphere Distributed Switch 'MyVDSwitch' and
Distributed Port Group 'MyVDPortGroup'.
#>
Configuration VMHostVdsNic_CreateVMHostVDSwitchNicWithoutPortId_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VDSwitch VDSwitch {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = 'MyVDSwitch'
            Location = ''
            DatacenterName = $AllNodes.DatacenterName
            DatacenterLocation = $AllNodes.DatacenterLocation
            Ensure = 'Present'
        }

        VDPortGroup VDPortGroup {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = 'MyVDPortGroup'
            VdsName = 'MyVDSwitch'
            Ensure = 'Present'
            DependsOn = '[VDSwitch]VDSwitch'
        }

        VDSwitchVMHost VDSwitchVMHost {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VdsName = 'MyVDSwitch'
            VMHostNames = @($AllNodes.VMHostName)
            Ensure = 'Present'
            DependsOn = '[VDPortGroup]VDPortGroup'
        }

        VMHostVdsNic VMHostVdsNic {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            VMHostName = $AllNodes.VMHostName
            VdsName = 'MyVDSwitch'
            PortGroupName = 'MyVDPortGroup'
            Ensure = 'Present'
            IP = '192.168.0.1'
            SubnetMask = '255.255.255.0'
            Mac = '00:50:56:63:5b:0e'
            AutomaticIPv6 = $true
            IPv6 = @('fe80::250:56ff:fe63:5b0e/64', '200:2342::1/32')
            IPv6ThroughDhcp = $true
            Mtu = 4000
            ManagementTrafficEnabled = $true
            FaultToleranceLoggingEnabled = $true
            VMotionEnabled = $true
            VsanTrafficEnabled = $true
            DependsOn = '[VDSwitchVMHost]VDSwitchVMHost'
        }
    }
}

VMHostVdsNic_CreateVMHostVDSwitchNicWithoutPortId_Config -ConfigurationData $script:configurationData
