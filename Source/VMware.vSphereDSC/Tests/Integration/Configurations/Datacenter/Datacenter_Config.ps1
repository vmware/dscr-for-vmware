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

$script:datacenterName = 'MyTestDatacenter'
$script:folderName = 'MyTestDatacenterFolder'
$script:emptyLocation = [string]::Empty
$script:locationWithOneFolder = $script:folderName
$script:locationWithTwoFolders = "$script:folderName/$script:folderName"

$script:folderWithEmptyLocationResourceName = 'DatacenterFolder_With_EmptyLocation'
$script:folderWithLocationWithOneFolderResourceName = 'DatacenterFolder_With_LocationWithOneFolder'

$script:folderWithEmptyLocationResourceId = "[DatacenterFolder]$script:folderWithEmptyLocationResourceName"
$script:folderWithLocationWithOneFolderResourceId = "[DatacenterFolder]$script:folderWithLocationWithOneFolderResourceName"

$script:datacenterWithEmptyLocationResourceName = 'Datacenter_With_EmptyLocation'
$script:datacenterWithLocationWithOneFolderResourceName = 'Datacenter_With_LocationWithOneFolder'
$script:datacenterWithLocationWithTwoFoldersResourceName = 'Datacenter_With_LocationWithTwoFolders'

$script:datacenterWithLocationWithOneFolderResourceId = "[Datacenter]$script:datacenterWithLocationWithOneFolderResourceName"
$script:datacenterWithLocationWithTwoFoldersResourceId = "[Datacenter]$script:datacenterWithLocationWithTwoFoldersResourceName"

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

Configuration Datacenter_WhenAddingDatacenterWithEmptyLocation_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        Datacenter $script:datacenterWithEmptyLocationResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:datacenterName
            Location = $script:emptyLocation
            Ensure = 'Present'
        }
    }
}

Configuration Datacenter_WhenAddingDatacenterWithLocationWithOneFolder_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        DatacenterFolder $script:folderWithEmptyLocationResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:folderName
            Location = $script:emptyLocation
            Ensure = 'Present'
        }

        Datacenter $script:datacenterWithLocationWithOneFolderResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:datacenterName
            Location = $script:locationWithOneFolder
            Ensure = 'Present'
            DependsOn = $script:folderWithEmptyLocationResourceId
        }
    }
}

Configuration Datacenter_WhenAddingDatacenterWithLocationWithTwoFolders_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        DatacenterFolder $script:folderWithEmptyLocationResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:folderName
            Location = $script:emptyLocation
            Ensure = 'Present'
        }

        DatacenterFolder $script:folderWithLocationWithOneFolderResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:folderName
            Location = $script:locationWithOneFolder
            Ensure = 'Present'
            DependsOn = $script:folderWithEmptyLocationResourceId
        }

        Datacenter $script:datacenterWithLocationWithTwoFoldersResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:datacenterName
            Location = $script:locationWithTwoFolders
            Ensure = 'Present'
            DependsOn = $script:folderWithLocationWithOneFolderResourceId
        }
    }
}

Configuration Datacenter_WhenRemovingDatacenterWithEmptyLocation_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        Datacenter $script:datacenterWithEmptyLocationResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:datacenterName
            Location = $script:emptyLocation
            Ensure = 'Absent'
        }
    }
}

Configuration Datacenter_WhenRemovingDatacenterWithLocationWithOneFolder_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        Datacenter $script:datacenterWithLocationWithOneFolderResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:datacenterName
            Location = $script:locationWithOneFolder
            Ensure = 'Absent'
        }

        DatacenterFolder $script:folderWithEmptyLocationResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:folderName
            Location = $script:emptyLocation
            Ensure = 'Absent'
            DependsOn = $script:datacenterWithLocationWithOneFolderResourceId
        }
    }
}

Configuration Datacenter_WhenRemovingDatacenterWithLocationWithTwoFolders_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        Datacenter $script:datacenterWithLocationWithTwoFoldersResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:datacenterName
            Location = $script:locationWithTwoFolders
            Ensure = 'Absent'
        }

        DatacenterFolder $script:folderWithLocationWithOneFolderResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:folderName
            Location = $script:locationWithOneFolder
            Ensure = 'Absent'
            DependsOn = $script:datacenterWithLocationWithTwoFoldersResourceId
        }

        DatacenterFolder $script:folderWithEmptyLocationResourceName {
            Server = $Server
            Credential = $script:viServerCredential
            Name = $script:folderName
            Location = $script:emptyLocation
            Ensure = 'Absent'
            DependsOn = $script:folderWithLocationWithOneFolderResourceId
        }
    }
}

Datacenter_WhenAddingDatacenterWithEmptyLocation_Config -OutputPath "$integrationTestsFolderPath\Datacenter_WhenAddingDatacenterWithEmptyLocation_Config" -ConfigurationData $script:configurationData
Datacenter_WhenAddingDatacenterWithLocationWithOneFolder_Config -OutputPath "$integrationTestsFolderPath\Datacenter_WhenAddingDatacenterWithLocationWithOneFolder_Config" -ConfigurationData $script:configurationData
Datacenter_WhenAddingDatacenterWithLocationWithTwoFolders_Config -OutputPath "$integrationTestsFolderPath\Datacenter_WhenAddingDatacenterWithLocationWithTwoFolders_Config" -ConfigurationData $script:configurationData
Datacenter_WhenRemovingDatacenterWithEmptyLocation_Config -OutputPath "$integrationTestsFolderPath\Datacenter_WhenRemovingDatacenterWithEmptyLocation_Config" -ConfigurationData $script:configurationData
Datacenter_WhenRemovingDatacenterWithLocationWithOneFolder_Config -OutputPath "$integrationTestsFolderPath\Datacenter_WhenRemovingDatacenterWithLocationWithOneFolder_Config" -ConfigurationData $script:configurationData
Datacenter_WhenRemovingDatacenterWithLocationWithTwoFolders_Config -OutputPath "$integrationTestsFolderPath\Datacenter_WhenRemovingDatacenterWithLocationWithTwoFolders_Config" -ConfigurationData $script:configurationData
