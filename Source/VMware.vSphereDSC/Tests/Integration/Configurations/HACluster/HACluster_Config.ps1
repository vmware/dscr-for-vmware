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

Configuration HACluster_WhenAddingClusterWithEmptyLocation_Config {
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

        HACluster $script:haClusterWithEmptyLocationResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:clusterName
            Location = $script:clusterWithEmptyLocation
            DatacenterName = $script:datacenterName
            DatacenterLocation = $script:datacenterLocationWithOneFolder
            Ensure = 'Present'
            HAEnabled = $true
            HAAdmissionControlEnabled = $true
            HAFailoverLevel = 3
            HAIsolationResponse = 'DoNothing'
            HARestartPriority = 'Low'
            DependsOn = $script:datacenterWithLocationWithOneFolderResourceId
        }
    }
}

Configuration HACluster_WhenAddingClusterWithLocationWithOneFolder_Config {
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

        HACluster $script:haClusterWithLocationWithOneFolderResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:clusterName
            Location = $script:clusterWithLocationWithOneFolder
            DatacenterName = $script:datacenterName
            DatacenterLocation = $script:datacenterLocationWithOneFolder
            Ensure = 'Present'
            HAEnabled = $true
            HAFailoverLevel = 2
            HAIsolationResponse = 'PowerOff'
            HARestartPriority = 'High'
            DependsOn = $script:folderWithEmptyLocationResourceId
        }
    }
}

Configuration HACluster_WhenAddingClusterWithLocationWithTwoFolders_Config {
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

        HACluster $script:haClusterWithLocationWithTwoFoldersResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:clusterName
            Location = $script:clusterWithLocationWithTwoFolders
            DatacenterName = $script:datacenterName
            DatacenterLocation = $script:datacenterLocationWithOneFolder
            Ensure = 'Present'
            HAEnabled = $true
            HAAdmissionControlEnabled = $true
            HAFailoverLevel = 1
            HAIsolationResponse = 'Shutdown'
            HARestartPriority = 'Medium'
            DependsOn = $script:folderWithLocationWithOneFolderResourceId
        }
    }
}

Configuration HACluster_WhenUpdatingCluster_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        HACluster $script:haClusterWithEmptyLocationResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:clusterName
            Location = $script:clusterWithEmptyLocation
            DatacenterName = $script:datacenterName
            DatacenterLocation = $script:datacenterLocationWithOneFolder
            Ensure = 'Present'
            HAAdmissionControlEnabled = $false
            HAIsolationResponse = 'PowerOff'
            HARestartPriority = 'Disabled'
        }
    }
}

Configuration HACluster_WhenRemovingClusterWithEmptyLocation_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        HACluster $script:haClusterWithEmptyLocationResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:clusterName
            Location = $script:clusterWithEmptyLocation
            DatacenterName = $script:datacenterName
            DatacenterLocation = $script:datacenterLocationWithOneFolder
            Ensure = 'Absent'
        }

        Datacenter $script:datacenterWithLocationWithOneFolderResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:datacenterName
            Location = $script:datacenterLocationWithOneFolder
            Ensure = 'Absent'
            DependsOn = $script:haClusterWithEmptyLocationResourceId
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

Configuration HACluster_WhenRemovingClusterWithLocationWithOneFolder_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        HACluster $script:haClusterWithLocationWithOneFolderResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:clusterName
            Location = $script:clusterWithLocationWithOneFolder
            DatacenterName = $script:datacenterName
            DatacenterLocation = $script:datacenterLocationWithOneFolder
            Ensure = 'Absent'
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
            DependsOn = $script:haClusterWithLocationWithOneFolderResourceId
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

Configuration HACluster_WhenRemovingClusterWithLocationWithTwoFolders_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        HACluster $script:haClusterWithLocationWithTwoFoldersResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:clusterName
            Location = $script:clusterWithLocationWithTwoFolders
            DatacenterName = $script:datacenterName
            DatacenterLocation = $script:datacenterLocationWithOneFolder
            Ensure = 'Absent'
        }

        Folder $script:folderWithLocationWithOneFolderResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:folderName
            Location = $script:folderWithLocationWithOneFolder
            DatacenterName = $script:datacenterName
            DatacenterLocation = $script:datacenterLocationWithOneFolder
            Ensure = 'Absent'
            FolderType = $script:folderType
            DependsOn = $script:haClusterWithLocationWithTwoFoldersResourceId
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

HACluster_WhenAddingClusterWithEmptyLocation_Config -OutputPath "$integrationTestsFolderPath\HACluster_WhenAddingClusterWithEmptyLocation_Config" -ConfigurationData $script:configurationData
HACluster_WhenAddingClusterWithLocationWithOneFolder_Config -OutputPath "$integrationTestsFolderPath\HACluster_WhenAddingClusterWithLocationWithOneFolder_Config" -ConfigurationData $script:configurationData
HACluster_WhenAddingClusterWithLocationWithTwoFolders_Config -OutputPath "$integrationTestsFolderPath\HACluster_WhenAddingClusterWithLocationWithTwoFolders_Config" -ConfigurationData $script:configurationData
HACluster_WhenUpdatingCluster_Config -OutputPath "$integrationTestsFolderPath\HACluster_WhenUpdatingCluster_Config" -ConfigurationData $script:configurationData
HACluster_WhenRemovingClusterWithEmptyLocation_Config -OutputPath "$integrationTestsFolderPath\HACluster_WhenRemovingClusterWithEmptyLocation_Config" -ConfigurationData $script:configurationData
HACluster_WhenRemovingClusterWithLocationWithOneFolder_Config -OutputPath "$integrationTestsFolderPath\HACluster_WhenRemovingClusterWithLocationWithOneFolder_Config" -ConfigurationData $script:configurationData
HACluster_WhenRemovingClusterWithLocationWithTwoFolders_Config -OutputPath "$integrationTestsFolderPath\HACluster_WhenRemovingClusterWithLocationWithTwoFolders_Config" -ConfigurationData $script:configurationData
