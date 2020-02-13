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
    $Server,

    [Parameter(Mandatory = $true)]
    [string]
    $User,

    [Parameter(Mandatory = $true)]
    [string]
    $Password
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

Configuration Datacenter_WhenAddingDatacenterWithEmptyLocation_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        Datacenter $script:datacenterWithEmptyLocationResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:datacenterName
            Location = $script:datacenterEmptyLocation
            Ensure = 'Present'
        }
    }
}

Configuration Datacenter_WhenAddingDatacenterWithLocationWithOneFolder_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        DatacenterFolder $script:datacenterFolderWithEmptyLocationResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:datacenterFolderName
            Location = $script:datacenterEmptyLocation
            Ensure = 'Present'
        }

        Datacenter $script:datacenterWithLocationWithOneFolderResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:datacenterName
            Location = $script:datacenterLocationWithOneFolder
            Ensure = 'Present'
            DependsOn = $script:datacenterFolderWithEmptyLocationResourceId
        }
    }
}

Configuration Datacenter_WhenAddingDatacenterWithLocationWithTwoFolders_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        DatacenterFolder $script:datacenterFolderWithEmptyLocationResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:datacenterFolderName
            Location = $script:datacenterEmptyLocation
            Ensure = 'Present'
        }

        DatacenterFolder $script:datacenterFolderWithLocationWithOneFolderResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:datacenterFolderName
            Location = $script:datacenterLocationWithOneFolder
            Ensure = 'Present'
            DependsOn = $script:datacenterFolderWithEmptyLocationResourceId
        }

        Datacenter $script:datacenterWithLocationWithTwoFoldersResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:datacenterName
            Location = $script:datacenterLocationWithTwoFolders
            Ensure = 'Present'
            DependsOn = $script:datacenterFolderWithLocationWithOneFolderResourceId
        }
    }
}

Configuration Datacenter_WhenRemovingDatacenterWithEmptyLocation_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        Datacenter $script:datacenterWithEmptyLocationResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:datacenterName
            Location = $script:datacenterEmptyLocation
            Ensure = 'Absent'
        }
    }
}

Configuration Datacenter_WhenRemovingDatacenterWithLocationWithOneFolder_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        Datacenter $script:datacenterWithLocationWithOneFolderResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:datacenterName
            Location = $script:datacenterLocationWithOneFolder
            Ensure = 'Absent'
        }

        DatacenterFolder $script:datacenterFolderWithEmptyLocationResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:datacenterFolderName
            Location = $script:datacenterEmptyLocation
            Ensure = 'Absent'
            DependsOn = $script:datacenterWithLocationWithOneFolderResourceId
        }
    }
}

Configuration Datacenter_WhenRemovingDatacenterWithLocationWithTwoFolders_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        Datacenter $script:datacenterWithLocationWithTwoFoldersResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:datacenterName
            Location = $script:datacenterLocationWithTwoFolders
            Ensure = 'Absent'
        }

        DatacenterFolder $script:datacenterFolderWithLocationWithOneFolderResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:datacenterFolderName
            Location = $script:datacenterLocationWithOneFolder
            Ensure = 'Absent'
            DependsOn = $script:datacenterWithLocationWithTwoFoldersResourceId
        }

        DatacenterFolder $script:datacenterFolderWithEmptyLocationResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:datacenterFolderName
            Location = $script:datacenterEmptyLocation
            Ensure = 'Absent'
            DependsOn = $script:datacenterFolderWithLocationWithOneFolderResourceId
        }
    }
}

Datacenter_WhenAddingDatacenterWithEmptyLocation_Config -OutputPath "$integrationTestsFolderPath\Datacenter_WhenAddingDatacenterWithEmptyLocation_Config" -ConfigurationData $script:configurationData
Datacenter_WhenAddingDatacenterWithLocationWithOneFolder_Config -OutputPath "$integrationTestsFolderPath\Datacenter_WhenAddingDatacenterWithLocationWithOneFolder_Config" -ConfigurationData $script:configurationData
Datacenter_WhenAddingDatacenterWithLocationWithTwoFolders_Config -OutputPath "$integrationTestsFolderPath\Datacenter_WhenAddingDatacenterWithLocationWithTwoFolders_Config" -ConfigurationData $script:configurationData
Datacenter_WhenRemovingDatacenterWithEmptyLocation_Config -OutputPath "$integrationTestsFolderPath\Datacenter_WhenRemovingDatacenterWithEmptyLocation_Config" -ConfigurationData $script:configurationData
Datacenter_WhenRemovingDatacenterWithLocationWithOneFolder_Config -OutputPath "$integrationTestsFolderPath\Datacenter_WhenRemovingDatacenterWithLocationWithOneFolder_Config" -ConfigurationData $script:configurationData
Datacenter_WhenRemovingDatacenterWithLocationWithTwoFolders_Config -OutputPath "$integrationTestsFolderPath\Datacenter_WhenRemovingDatacenterWithLocationWithTwoFolders_Config" -ConfigurationData $script:configurationData
