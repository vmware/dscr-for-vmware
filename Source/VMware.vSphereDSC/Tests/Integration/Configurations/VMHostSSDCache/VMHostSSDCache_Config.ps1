<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

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
    $DatastoreName
)

$moduleFolderPath = (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase
$integrationTestsFolderPath = Join-Path (Join-Path $moduleFolderPath 'Tests') 'Integration'

. (Join-Path -Path (Join-Path -Path $integrationTestsFolderPath -ChildPath 'TestHelpers') -ChildPath 'IntegrationTests.Constants.ps1')

$Password = $Password | ConvertTo-SecureString -AsPlainText -Force
$script:viServerCredential = New-Object System.Management.Automation.PSCredential($User, $Password)

$script:configurationData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
        }
    )
}

Configuration VMHostSSDCache_WhenSwapSizeIsZeroGigabytes_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostSSDCache vmHostSSDCache {
            Name = $Name
            Server = $Server
            Credential = $script:viServerCredential
            Datastore = $DatastoreName
            SwapSize = $script:zeroGigabytesSwapSize
        }
    }
}

Configuration VMHostSSDCache_WhenSwapSizeIsHalfGigabyte_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostSSDCache vmHostSSDCache {
            Name = $Name
            Server = $Server
            Credential = $script:viServerCredential
            Datastore = $DatastoreName
            SwapSize = $script:halfGigabyteSwapSize
        }
    }
}

Configuration VMHostSSDCache_WhenSwapSizeIsOneGigabyte_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostSSDCache vmHostSSDCache {
            Name = $Name
            Server = $Server
            Credential = $script:viServerCredential
            Datastore = $DatastoreName
            SwapSize = $script:oneGigabyteSwapSize
        }
    }
}

Configuration VMHostSSDCache_WhenSwapSizeIsTwoGigabytesWithoutOneMegabyte_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostSSDCache vmHostSSDCache {
            Name = $Name
            Server = $Server
            Credential = $script:viServerCredential
            Datastore = $DatastoreName
            SwapSize = $script:twoGigabytesWithoutOneMegabyteSwapSize
        }
    }
}

Configuration VMHostSSDCache_WhenSwapSizeIsTwoGigabytes_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        VMHostSSDCache vmHostSSDCache {
            Name = $Name
            Server = $Server
            Credential = $script:viServerCredential
            Datastore = $DatastoreName
            SwapSize = $script:twoGigabytesSwapSize
        }
    }
}

VMHostSSDCache_WhenSwapSizeIsZeroGigabytes_Config -OutputPath "$integrationTestsFolderPath\VMHostSSDCache_WhenSwapSizeIsZeroGigabytes_Config" -ConfigurationData $script:configurationData
VMHostSSDCache_WhenSwapSizeIsHalfGigabyte_Config -OutputPath "$integrationTestsFolderPath\VMHostSSDCache_WhenSwapSizeIsHalfGigabyte_Config" -ConfigurationData $script:configurationData
VMHostSSDCache_WhenSwapSizeIsOneGigabyte_Config -OutputPath "$integrationTestsFolderPath\VMHostSSDCache_WhenSwapSizeIsOneGigabyte_Config" -ConfigurationData $script:configurationData
VMHostSSDCache_WhenSwapSizeIsTwoGigabytesWithoutOneMegabyte_Config -OutputPath "$integrationTestsFolderPath\VMHostSSDCache_WhenSwapSizeIsTwoGigabytesWithoutOneMegabyte_Config" -ConfigurationData $script:configurationData
VMHostSSDCache_WhenSwapSizeIsTwoGigabytes_Config -OutputPath "$integrationTestsFolderPath\VMHostSSDCache_WhenSwapSizeIsTwoGigabytes_Config" -ConfigurationData $script:configurationData
