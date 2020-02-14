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
    $Password
)

$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (ConvertTo-SecureString -String $Password -AsPlainText -Force)

$script:configurationData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
            Server = $Server
            Credential = $Credential
        }
    )
}

<#
.DESCRIPTION

Creates a new Datacenter 'Datacenter' in the Root Folder of the Inventory.
Creates a new vSphere Distributed Switch 'MyVDSwitch' in the Network Folder of Datacenter 'Datacenter'.
Creates a new Distributed Port Group 'MyVDPortGroup' on vSphere Distributed Switch 'MyVDSwitch' with
Static Port Binding and 128 Ports.
#>
Configuration VDPortGroup_CreateVDPortGroup_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        Datacenter Datacenter {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = 'Datacenter'
            Location = ''
            Ensure = 'Present'
        }

        VDSwitch VDSwitch {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = 'MyVDSwitch'
            Location = ''
            DatacenterName = 'Datacenter'
            DatacenterLocation = ''
            Ensure = 'Present'
            DependsOn = '[Datacenter]Datacenter'
        }

        VDPortGroup VDPortGroup {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = 'MyVDPortGroup'
            VdsName = 'MyVDSwitch'
            Ensure = 'Present'
            NumPorts = 128
            Notes = 'MyVDPortGroup Notes'
            PortBinding = 'Static'
            DependsOn = '[VDSwitch]VDSwitch'
        }
    }
}

VDPortGroup_CreateVDPortGroup_Config -ConfigurationData $script:configurationData
