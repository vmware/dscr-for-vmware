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

$script:configurationData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
        }
    )
}

Configuration Folder_WhenAddingFolderWithLocationWithTwoFolders_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        $Password = $Password | ConvertTo-SecureString -AsPlainText -Force
        $Credential = New-Object System.Management.Automation.PSCredential($User, $Password)

        Folder MyFolder {
            Server = $Server
            Credential = $Credential
            Name = 'MyFolder'
            Location = ''
            DatacenterName = 'Datacenter'
            DatacenterLocation = ''
            Ensure = 'Present'
            FolderType = 'Host'
        }

        Folder MyClustersFolder {
            Server = $Server
            Credential = $Credential
            Name = 'MyClustersFolder'
            Location = 'MyFolder'
            DatacenterName = 'Datacenter'
            DatacenterLocation = ''
            Ensure = 'Present'
            FolderType = 'Host'
            DependsOn = "[Folder]MyFolder"
        }

        Folder MyHAClustersFolder {
            Server = $Server
            Credential = $Credential
            Name = 'MyHAClustersFolder'
            Location = 'MyFolder/MyClustersFolder'
            DatacenterName = 'Datacenter'
            DatacenterLocation = ''
            Ensure = 'Present'
            FolderType = 'Host'
            DependsOn = "[Folder]MyClustersFolder"
        }
    }
}

Configuration Folder_WhenRemovingFolderWithLocationWithTwoFolders_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        $Password = $Password | ConvertTo-SecureString -AsPlainText -Force
        $Credential = New-Object System.Management.Automation.PSCredential($User, $Password)

        Folder MyHAClustersFolder {
            Server = $Server
            Credential = $Credential
            Name = 'MyHAClustersFolder'
            Location = 'MyFolder/MyClustersFolder'
            DatacenterName = 'Datacenter'
            DatacenterLocation = ''
            Ensure = 'Absent'
            FolderType = 'Host'
        }

        Folder MyClustersFolder {
            Server = $Server
            Credential = $Credential
            Name = 'MyClustersFolder'
            Location = 'MyFolder'
            DatacenterName = 'Datacenter'
            DatacenterLocation = ''
            Ensure = 'Absent'
            FolderType = 'Host'
            DependsOn = "[Folder]MyHAClustersFolder"
        }

        Folder MyFolder {
            Server = $Server
            Credential = $Credential
            Name = 'MyFolder'
            Location = ''
            DatacenterName = 'Datacenter'
            DatacenterLocation = ''
            Ensure = 'Absent'
            FolderType = 'Host'
            DependsOn = "[Folder]MyClustersFolder"
        }
    }
}

Folder_WhenAddingFolderWithLocationWithTwoFolders_Config -ConfigurationData $script:configurationData
Folder_WhenRemovingFolderWithLocationWithTwoFolders_Config -ConfigurationData $script:configurationData
