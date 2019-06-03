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
    $Server,

    [Parameter(Mandatory = $true)]
    [string]
    $User,

    [Parameter(Mandatory = $true)]
    [string]
    $Password
)

$Password = $Password | ConvertTo-SecureString -AsPlainText -Force
$script:viServerCredential = New-Object System.Management.Automation.PSCredential($User, $Password)

$script:folderName = 'MyTestFolder'
$script:emptyLocation = [string]::Empty
$script:locationWithOneFolder = $script:folderName
$script:locationWithTwoFolders = "$script:folderName/$script:folderName"
$script:datacenterName = 'Datacenter'
$script:datacenterLocation = [string]::Empty
$script:folderType = 'Host'

$script:folderWithEmptyLocationResourceName = 'Folder_With_EmptyLocation'
$script:folderWithLocationWithOneFolderResourceName = 'Folder_With_LocationWithOneFolder'
$script:folderWithLocationWithTwoFoldersResourceName = 'Folder_With_LocationWithTwoFolders'

$script:folderWithEmptyLocationResourceId = "[Folder]$script:folderWithEmptyLocationResourceName"
$script:folderWithLocationWithOneFolderResourceId = "[Folder]$script:folderWithLocationWithOneFolderResourceName"
$script:folderWithLocationWithTwoFoldersResourceId = "[Folder]$script:folderWithLocationWithTwoFoldersResourceName"

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

Configuration Folder_WhenAddingFolderWithEmptyLocation_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        Folder $script:folderWithEmptyLocationResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:folderName
            Location = $script:emptyLocation
            DatacenterName = $script:datacenterName
            DatacenterLocation = $script:datacenterLocation
            Ensure = 'Present'
            FolderType = $script:folderType
        }
    }
}

Configuration Folder_WhenAddingFolderWithLocationWithOneFolder_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        Folder $script:folderWithEmptyLocationResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:folderName
            Location = $script:emptyLocation
            DatacenterName = $script:datacenterName
            DatacenterLocation = $script:datacenterLocation
            Ensure = 'Present'
            FolderType = $script:folderType
        }

        Folder $script:folderWithLocationWithOneFolderResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:folderName
            Location = $script:locationWithOneFolder
            DatacenterName = $script:datacenterName
            DatacenterLocation = $script:datacenterLocation
            Ensure = 'Present'
            FolderType = $script:folderType
            DependsOn = $script:folderWithEmptyLocationResourceId
        }
    }
}

Configuration Folder_WhenAddingFolderWithLocationWithTwoFolders_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        Folder $script:folderWithEmptyLocationResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:folderName
            Location = $script:emptyLocation
            DatacenterName = $script:datacenterName
            DatacenterLocation = $script:datacenterLocation
            Ensure = 'Present'
            FolderType = $script:folderType
        }

        Folder $script:folderWithLocationWithOneFolderResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:folderName
            Location = $script:locationWithOneFolder
            DatacenterName = $script:datacenterName
            DatacenterLocation = $script:datacenterLocation
            Ensure = 'Present'
            FolderType = $script:folderType
            DependsOn = $script:folderWithEmptyLocationResourceId
        }

        Folder $script:folderWithLocationWithTwoFoldersResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:folderName
            Location = $script:locationWithTwoFolders
            DatacenterName = $script:datacenterName
            DatacenterLocation = $script:datacenterLocation
            Ensure = 'Present'
            FolderType = $script:folderType
            DependsOn = $script:folderWithLocationWithOneFolderResourceId
        }
    }
}

Configuration Folder_WhenRemovingFolderWithEmptyLocation_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        Folder $script:folderWithEmptyLocationResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:folderName
            Location = $script:emptyLocation
            DatacenterName = $script:datacenterName
            DatacenterLocation = $script:datacenterLocation
            Ensure = 'Absent'
            FolderType = $script:folderType
        }
    }
}

Configuration Folder_WhenRemovingFolderWithLocationWithOneFolder_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        Folder $script:folderWithLocationWithOneFolderResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:folderName
            Location = $script:locationWithOneFolder
            DatacenterName = $script:datacenterName
            DatacenterLocation = $script:datacenterLocation
            Ensure = 'Absent'
            FolderType = $script:folderType
        }

        Folder $script:folderWithEmptyLocationResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:folderName
            Location = $script:emptyLocation
            DatacenterName = $script:datacenterName
            DatacenterLocation = $script:datacenterLocation
            Ensure = 'Absent'
            FolderType = $script:folderType
            DependsOn = $script:folderWithLocationWithOneFolderResourceId
        }
    }
}

Configuration Folder_WhenRemovingFolderWithLocationWithTwoFolders_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        Folder $script:folderWithLocationWithTwoFoldersResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:folderName
            Location = $script:locationWithTwoFolders
            DatacenterName = $script:datacenterName
            DatacenterLocation = $script:datacenterLocation
            Ensure = 'Absent'
            FolderType = $script:folderType
        }

        Folder $script:folderWithLocationWithOneFolderResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:folderName
            Location = $script:locationWithOneFolder
            DatacenterName = $script:datacenterName
            DatacenterLocation = $script:datacenterLocation
            Ensure = 'Absent'
            FolderType = $script:folderType
            DependsOn = $script:folderWithLocationWithTwoFoldersResourceId
        }

        Folder $script:folderWithEmptyLocationResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:folderName
            Location = $script:emptyLocation
            DatacenterName = $script:datacenterName
            DatacenterLocation = $script:datacenterLocation
            Ensure = 'Absent'
            FolderType = $script:folderType
            DependsOn = $script:folderWithLocationWithOneFolderResourceId
        }
    }
}

Folder_WhenAddingFolderWithEmptyLocation_Config -OutputPath "$integrationTestsFolderPath\Folder_WhenAddingFolderWithEmptyLocation_Config" -ConfigurationData $script:configurationData
Folder_WhenAddingFolderWithLocationWithOneFolder_Config -OutputPath "$integrationTestsFolderPath\Folder_WhenAddingFolderWithLocationWithOneFolder_Config" -ConfigurationData $script:configurationData
Folder_WhenAddingFolderWithLocationWithTwoFolders_Config -OutputPath "$integrationTestsFolderPath\Folder_WhenAddingFolderWithLocationWithTwoFolders_Config" -ConfigurationData $script:configurationData
Folder_WhenRemovingFolderWithEmptyLocation_Config -OutputPath "$integrationTestsFolderPath\Folder_WhenRemovingFolderWithEmptyLocation_Config" -ConfigurationData $script:configurationData
Folder_WhenRemovingFolderWithLocationWithOneFolder_Config -OutputPath "$integrationTestsFolderPath\Folder_WhenRemovingFolderWithLocationWithOneFolder_Config" -ConfigurationData $script:configurationData
Folder_WhenRemovingFolderWithLocationWithTwoFolders_Config -OutputPath "$integrationTestsFolderPath\Folder_WhenRemovingFolderWithLocationWithTwoFolders_Config" -ConfigurationData $script:configurationData
