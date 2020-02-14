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
    $Password,

    [Parameter(Mandatory = $true)]
    [string]
    $LogHostOne,

    [Parameter(Mandatory = $true)]
    [string]
    $LogHostTwo
)

$moduleFolderPath = (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase
$integrationTestsFolderPath = Join-Path (Join-Path $moduleFolderPath 'Tests') 'Integration'

. (Join-Path -Path (Join-Path -Path $integrationTestsFolderPath -ChildPath 'TestHelpers') -ChildPath 'IntegrationTests.Constants.ps1')

$Password = $Password | ConvertTo-SecureString -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential($User, $Password)

$script:configurationData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
        }
    )
}

Configuration VMHostSyslog_WithDefaultSettings_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostSyslog vmHostSyslogSettings {
            Name = $Name
            Server = $Server
            Credential = $Credential
            Loghost = $LogHostOne
            CheckSslCerts = $script:checkSslCerts
            DefaultRotate = $script:defaultRotate
            DefaultSize = $script:defaultSize
            DefaultTimeout = $script:defaultTimeout
            Logdir = $script:logdirOne
            LogdirUnique = $script:logdirUnique
            DropLogRotate = $script:dropLogRotate
            DropLogSize = $script:dropLogSize
            QueueDropMark = $script:queueDropMark
        }
    }
}

Configuration VMHostSyslog_WithNotDefaultSettings_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostSyslog vmHostSyslogSettings {
            Name = $Name
            Server = $Server
            Credential = $Credential
            Loghost = $LogHostTwo
            CheckSslCerts = !$script:checkSslCerts
            DefaultRotate = $script:defaultRotate + 1
            DefaultSize = $script:defaultSize + 1
            DefaultTimeout = $script:defaultTimeout + 1
            Logdir = $script:logdirTwo
            LogdirUnique = !$script:logdirUnique
            DropLogRotate = $script:dropLogRotate + 1
            DropLogSize = $script:dropLogSize + 1
            QueueDropMark = $script:queueDropMark + 1
        }
    }
}

VMHostSyslog_WithDefaultSettings_Config -OutputPath "$integrationTestsFolderPath\VMHostSyslog_WithDefaultSettings_Config" -ConfigurationData $script:configurationData
VMHostSyslog_WithNotDefaultSettings_Config -OutputPath "$integrationTestsFolderPath\VMHostSyslog_WithNotDefaultSettings_Config" -ConfigurationData $script:configurationData
