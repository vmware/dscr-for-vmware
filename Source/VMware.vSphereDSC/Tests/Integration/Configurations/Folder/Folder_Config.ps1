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

Configuration Folder_WhenAddingFolderWithEmptyLocation_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        Datacenter $script:datacenterWithEmptyLocationResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:datacenterName
            Location = $script:datacenterEmptyLocation
            Ensure = 'Present'
        }

        Folder $script:folderWithEmptyLocationResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:folderName
            Location = $script:folderWithEmptyLocation
            DatacenterName = $script:datacenterName
            DatacenterLocation = $script:datacenterEmptyLocation
            Ensure = 'Present'
            FolderType = $script:folderType
            DependsOn = $script:datacenterWithEmptyLocationResourceId
        }
    }
}

Configuration Folder_WhenAddingFolderWithLocationWithOneFolder_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        DatacenterFolder $script:datacenterFolderWithEmptyLocationResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:datacenterFolderName
            Location = $script:datacenterFolderEmptyLocation
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

        Folder $script:folderWithEmptyLocationResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:folderName
            Location = $script:folderWithEmptyLocation
            DatacenterName = $script:datacenterName
            DatacenterLocation = $script:datacenterLocationWithOneFolder
            Ensure = 'Present'
            FolderType = $script:folderType
            DependsOn = $script:datacenterWithLocationWithOneFolderResourceId
        }

        Folder $script:folderWithLocationWithOneFolderResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:folderName
            Location = $script:folderWithLocationWithOneFolder
            DatacenterName = $script:datacenterName
            DatacenterLocation = $script:datacenterLocationWithOneFolder
            Ensure = 'Present'
            FolderType = $script:folderType
            DependsOn = $script:folderWithEmptyLocationResourceId
        }
    }
}

Configuration Folder_WhenAddingFolderWithLocationWithTwoFolders_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        DatacenterFolder $script:datacenterFolderWithEmptyLocationResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:datacenterFolderName
            Location = $script:datacenterFolderEmptyLocation
            Ensure = 'Present'
        }

        DatacenterFolder $script:datacenterFolderWithLocationWithOneFolderResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:datacenterFolderName
            Location = $script:datacenterFolderLocationWithOneFolder
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

        Folder $script:folderWithEmptyLocationResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:folderName
            Location = $script:folderWithEmptyLocation
            DatacenterName = $script:datacenterName
            DatacenterLocation = $script:datacenterLocationWithTwoFolders
            Ensure = 'Present'
            FolderType = $script:folderType
            DependsOn = $script:datacenterWithLocationWithTwoFoldersResourceId
        }

        Folder $script:folderWithLocationWithOneFolderResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:folderName
            Location = $script:folderWithLocationWithOneFolder
            DatacenterName = $script:datacenterName
            DatacenterLocation = $script:datacenterLocationWithTwoFolders
            Ensure = 'Present'
            FolderType = $script:folderType
            DependsOn = $script:folderWithEmptyLocationResourceId
        }

        Folder $script:folderWithLocationWithTwoFoldersResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:folderName
            Location = $script:folderWithLocationWithTwoFolders
            DatacenterName = $script:datacenterName
            DatacenterLocation = $script:datacenterLocationWithTwoFolders
            Ensure = 'Present'
            FolderType = $script:folderType
            DependsOn = $script:folderWithLocationWithOneFolderResourceId
        }
    }
}

Configuration Folder_WhenRemovingFolderWithEmptyLocation_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        Folder $script:folderWithEmptyLocationResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:folderName
            Location = $script:folderWithEmptyLocation
            DatacenterName = $script:datacenterName
            DatacenterLocation = $script:datacenterEmptyLocation
            Ensure = 'Absent'
            FolderType = $script:folderType
        }

        Datacenter $script:datacenterWithEmptyLocationResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:datacenterName
            Location = $script:datacenterEmptyLocation
            Ensure = 'Absent'
            DependsOn = $script:folderWithEmptyLocationResourceId
        }
    }
}

Configuration Folder_WhenRemovingFolderWithLocationWithOneFolder_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        Folder $script:folderWithLocationWithOneFolderResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:folderName
            Location = $script:folderWithLocationWithOneFolder
            DatacenterName = $script:datacenterName
            DatacenterLocation = $script:datacenterLocationWithOneFolder
            Ensure = 'Absent'
            FolderType = $script:folderType
        }

        Folder $script:folderWithEmptyLocationResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:folderName
            Location = $script:folderWithEmptyLocation
            DatacenterName = $script:datacenterName
            DatacenterLocation = $script:datacenterLocationWithOneFolder
            Ensure = 'Absent'
            FolderType = $script:folderType
            DependsOn = $script:folderWithLocationWithOneFolderResourceId
        }

        Datacenter $script:datacenterWithLocationWithOneFolderResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:datacenterName
            Location = $script:datacenterLocationWithOneFolder
            Ensure = 'Absent'
            DependsOn = $script:folderWithEmptyLocationResourceId
        }

        DatacenterFolder $script:datacenterFolderWithEmptyLocationResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:datacenterFolderName
            Location = $script:datacenterFolderEmptyLocation
            Ensure = 'Absent'
            DependsOn = $script:datacenterWithLocationWithOneFolderResourceId
        }
    }
}

Configuration Folder_WhenRemovingFolderWithLocationWithTwoFolders_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        Folder $script:folderWithLocationWithTwoFoldersResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:folderName
            Location = $script:folderWithLocationWithTwoFolders
            DatacenterName = $script:datacenterName
            DatacenterLocation = $script:datacenterLocationWithTwoFolders
            Ensure = 'Absent'
            FolderType = $script:folderType
        }

        Folder $script:folderWithLocationWithOneFolderResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:folderName
            Location = $script:folderWithLocationWithOneFolder
            DatacenterName = $script:datacenterName
            DatacenterLocation = $script:datacenterLocationWithTwoFolders
            Ensure = 'Absent'
            FolderType = $script:folderType
            DependsOn = $script:folderWithLocationWithTwoFoldersResourceId
        }

        Folder $script:folderWithEmptyLocationResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:folderName
            Location = $script:folderWithEmptyLocation
            DatacenterName = $script:datacenterName
            DatacenterLocation = $script:datacenterLocationWithTwoFolders
            Ensure = 'Absent'
            FolderType = $script:folderType
            DependsOn = $script:folderWithLocationWithOneFolderResourceId
        }

        Datacenter $script:datacenterWithLocationWithTwoFoldersResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:datacenterName
            Location = $script:datacenterLocationWithTwoFolders
            Ensure = 'Absent'
            DependsOn = $script:folderWithEmptyLocationResourceId
        }

        DatacenterFolder $script:datacenterFolderWithLocationWithOneFolderResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:datacenterFolderName
            Location = $script:datacenterFolderLocationWithOneFolder
            Ensure = 'Absent'
            DependsOn = $script:datacenterWithLocationWithTwoFoldersResourceId
        }

        DatacenterFolder $script:datacenterFolderWithEmptyLocationResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:datacenterFolderName
            Location = $script:datacenterFolderEmptyLocation
            Ensure = 'Absent'
            DependsOn = $script:datacenterFolderWithLocationWithOneFolderResourceId
        }
    }
}

Folder_WhenAddingFolderWithEmptyLocation_Config -OutputPath "$integrationTestsFolderPath\Folder_WhenAddingFolderWithEmptyLocation_Config" -ConfigurationData $script:configurationData
Folder_WhenAddingFolderWithLocationWithOneFolder_Config -OutputPath "$integrationTestsFolderPath\Folder_WhenAddingFolderWithLocationWithOneFolder_Config" -ConfigurationData $script:configurationData
Folder_WhenAddingFolderWithLocationWithTwoFolders_Config -OutputPath "$integrationTestsFolderPath\Folder_WhenAddingFolderWithLocationWithTwoFolders_Config" -ConfigurationData $script:configurationData
Folder_WhenRemovingFolderWithEmptyLocation_Config -OutputPath "$integrationTestsFolderPath\Folder_WhenRemovingFolderWithEmptyLocation_Config" -ConfigurationData $script:configurationData
Folder_WhenRemovingFolderWithLocationWithOneFolder_Config -OutputPath "$integrationTestsFolderPath\Folder_WhenRemovingFolderWithLocationWithOneFolder_Config" -ConfigurationData $script:configurationData
Folder_WhenRemovingFolderWithLocationWithTwoFolders_Config -OutputPath "$integrationTestsFolderPath\Folder_WhenRemovingFolderWithLocationWithTwoFolders_Config" -ConfigurationData $script:configurationData
