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

$script:ntpServerAddUseCase = @("0.bg.pool.ntp.org", "1.bg.pool.ntp.org", "2.bg.pool.ntp.org")
$script:ntpServerRemoveUseCase = @("0.bg.pool.ntp.org", "1.bg.pool.ntp.org")
$script:ntpServicePolicy = "Automatic"

$script:vmhost = Get-VMHost -Name $Name
$script:vmhostNtpServicePolicyValue = ($script:vmhost.ExtensionData.Config.Service.Service | Where-Object { $_.Key -eq "ntpd" }).Policy

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

Configuration VMHostNtpSettings_WithoutNtpServerAndNtpServicePolicy_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostNtpSettings vmHostNtpSettings {
            Name = $Name
            Server = $Server
            Credential = $script:vmHostCredential
        }
    }
}

Configuration VMHostNtpSettings_WithEmptyArrayNtpServer_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostNtpSettings vmHostNtpSettings {
            Name = $Name
            Server = $Server
            Credential = $script:vmHostCredential
            NtpServer = @()
        }
    }
}

Configuration VMHostNtpSettings_WithNtpServerAddUseCase_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostNtpSettings vmHostNtpSettings {
            Name = $Name
            Server = $Server
            Credential = $script:vmHostCredential
            NtpServer = $script:ntpServerAddUseCase
        }
    }
}

Configuration VMHostNtpSettings_WithNtpServerRemoveUseCase_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostNtpSettings vmHostNtpSettings {
            Name = $Name
            Server = $Server
            Credential = $script:vmHostCredential
            NtpServer = $script:ntpServerRemoveUseCase
        }
    }
}

Configuration VMHostNtpSettings_WithTheSameNtpServicePolicy_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostNtpSettings vmHostNtpSettings {
            Name = $Name
            Server = $Server
            Credential = $script:vmHostCredential
            NtpServicePolicy = $script:vmhostNtpServicePolicyValue
        }
    }
}

Configuration VMHostNtpSettings_WithNtpServicePolicy_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostNtpSettings vmHostNtpSettings {
            Name = $Name
            Server = $Server
            Credential = $script:vmHostCredential
            NtpServicePolicy = $script:ntpServicePolicy
        }
    }
}

VMHostNtpSettings_WithoutNtpServerAndNtpServicePolicy_Config -OutputPath "$integrationTestsFolderPath\VMHostNtpSettings_WithoutNtpServerAndNtpServicePolicy_Config" -ConfigurationData $script:configurationData
VMHostNtpSettings_WithEmptyArrayNtpServer_Config -OutputPath "$integrationTestsFolderPath\VMHostNtpSettings_WithEmptyArrayNtpServer_Config" -ConfigurationData $script:configurationData
VMHostNtpSettings_WithNtpServerAddUseCase_Config -OutputPath "$integrationTestsFolderPath\VMHostNtpSettings_WithNtpServerAddUseCase_Config" -ConfigurationData $script:configurationData
VMHostNtpSettings_WithNtpServerRemoveUseCase_Config -OutputPath "$integrationTestsFolderPath\VMHostNtpSettings_WithNtpServerRemoveUseCase_Config" -ConfigurationData $script:configurationData
VMHostNtpSettings_WithTheSameNtpServicePolicy_Config -OutputPath "$integrationTestsFolderPath\VMHostNtpSettings_WithTheSameNtpServicePolicy_Config" -ConfigurationData $script:configurationData
VMHostNtpSettings_WithNtpServicePolicy_Config -OutputPath "$integrationTestsFolderPath\VMHostNtpSettings_WithNtpServicePolicy_Config" -ConfigurationData $script:configurationData