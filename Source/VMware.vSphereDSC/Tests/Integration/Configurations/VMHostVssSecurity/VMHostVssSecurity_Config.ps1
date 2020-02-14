<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]
    $Name,

    [Parameter(Mandatory = $true)]
    [string]
    $Server,

    [Parameter(Mandatory = $true)]
    [string]
    $User,

    [Parameter(Mandatory = $true)]
    [string]
    $Password
)

$Password = $Password | ConvertTo-SecureString -AsPlainText -Force
$script:vmHostCredential = New-Object System.Management.Automation.PSCredential($User, $Password)

$script:VssName = 'VSSDSC'
$script:Mtu = 1500
$script:EnsurePresent = 'Present'
$script:EnsureAbsent = 'Absent'
$script:AllowPromiscuous = $false
$script:ForgedTransmits = $true
$script:MacChanges = $true

$script:configurationData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
        }
    )
}

$moduleFolderPath = (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase
$integrationTestsFolderPath = Join-Path (Join-Path $moduleFolderPath 'Tests') 'Integration'

Configuration VMHostVssSecurity_Modify_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostVss vmHostVssSettings {
            Name = $Name
            Server = $Server
            Credential = $script:vmHostCredential
            VssName = $script:VssName
            Ensure = $script:EnsurePresent
            Mtu = $script:Mtu
        }

        VMHostVssSecurity vmHostVssSecuritySettings {
            Name = $Name
            Server = $Server
            Credential = $script:vmHostCredential
            VssName = $script:VssName
            Ensure = $script:EnsurePresent
            AllowPromiscuous = -not $script:AllowPromiscuous
            ForgedTransmits = -not $script:ForgedTransmits
            MacChanges = -not $script:MacChanges
            DependsOn = "[VMHostVss]vmHostVssSettings"
        }
    }
}

Configuration VMHostVssSecurity_Remove_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostVss vmHostVssSettings {
            Name = $Name
            Server = $Server
            Credential = $script:vmHostCredential
            VssName = $script:VssName
            Ensure = $script:EnsurePresent
            Mtu = $script:Mtu
        }

        VMHostVssSecurity vmHostVssSecuritySettings {
            Name = $Name
            Server = $Server
            Credential = $script:vmHostCredential
            VssName = $script:VssName
            Ensure = $script:Absent
            DependsOn = "[VMHostVss]vmHostVssSettings"
        }
    }
}

VMHostVssSecurity_Modify_Config -OutputPath "$integrationTestsFolderPath\VMHostVssSecurity_Modify_Config" -ConfigurationData $script:configurationData
VMHostVssSecurity_Remove_Config -OutputPath "$integrationTestsFolderPath\VMHostVssSecurity_Remove_Config" -ConfigurationData $script:configurationData
