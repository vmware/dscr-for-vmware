<#
Copyright (c) 2018-2021 VMware, Inc.  All rights reserved

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

Configuration Datacenter_WhenAddingDatacenterWithLocationWithTwoFolders_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        $Password = $Password | ConvertTo-SecureString -AsPlainText -Force
        $Credential = New-Object System.Management.Automation.PSCredential($User, $Password)

        DatacenterFolder MyFolder {
            Server = $Server
            Credential = $Credential
            Name = 'MyFolder'
            Location = ''
            Ensure = 'Present'
        }

        DatacenterFolder MyDatacentersFolder {
            Server = $Server
            Credential = $Credential
            Name = 'MyDatacentersFolder'
            Location = 'MyFolder'
            Ensure = 'Present'
            DependsOn = "[DatacenterFolder]MyFolder"
        }

        Datacenter MyDatacenter {
            Server = $Server
            Credential = $Credential
            Name = 'MyDatacenter'
            Location = 'MyFolder/MyDatacentersFolder'
            Ensure = 'Present'
            DependsOn = "[DatacenterFolder]MyDatacentersFolder"
        }
    }
}

Configuration Datacenter_WhenRemovingDatacenterWithLocationWithTwoFolders_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        $Password = $Password | ConvertTo-SecureString -AsPlainText -Force
        $Credential = New-Object System.Management.Automation.PSCredential($User, $Password)

        Datacenter MyDatacenter {
            Server = $Server
            Credential = $Credential
            Name = 'MyDatacenter'
            Location = 'MyFolder/MyDatacentersFolder'
            Ensure = 'Absent'
        }

        DatacenterFolder MyDatacentersFolder {
            Server = $Server
            Credential = $Credential
            Name = 'MyDatacentersFolder'
            Location = 'MyFolder'
            Ensure = 'Absent'
            DependsOn = "[Datacenter]MyDatacenter"
        }

        DatacenterFolder MyFolder {
            Server = $Server
            Credential = $Credential
            Name = 'MyFolder'
            Location = ''
            Ensure = 'Absent'
            DependsOn = "[DatacenterFolder]MyDatacentersFolder"
        }
    }
}

Datacenter_WhenAddingDatacenterWithLocationWithTwoFolders_Config -ConfigurationData $script:configurationData
Datacenter_WhenRemovingDatacenterWithLocationWithTwoFolders_Config -ConfigurationData $script:configurationData
