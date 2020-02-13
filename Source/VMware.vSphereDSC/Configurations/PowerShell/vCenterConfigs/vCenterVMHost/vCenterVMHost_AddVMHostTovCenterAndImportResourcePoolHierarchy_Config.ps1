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
    $Password,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $VMHostName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $VMHostUser,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $VMHostPassword
)

$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (ConvertTo-SecureString -String $Password -AsPlainText -Force)
$VMHostCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $VMHostUser, (ConvertTo-SecureString -String $VMHostPassword -AsPlainText -Force)

$script:configurationData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
            Server = $Server
            Credential = $Credential
            VMHostName = $VMHostName
            VMHostCredential = $VMHostCredential
        }
    )
}

<#
.DESCRIPTION

1. Creates Datacenter 'MyDatacenter' in the Root Folder of the specified Inventory.
2. Creates Folder 'MyFolder' in the Host Folder of Datacenter 'MyDatacenter'.
3. Creates Cluster 'MyCluster' located in Folder 'MyFolder' in Datacenter 'MyDatacenter' and enables Drs.
4. Adds the specified VMHost to Cluster 'MyCluster'. The port for connecting to the VMHost is specified to be '443'.
   'Force' is used to ignore the invalid SSL certificate of the VMHost.
   The VMHost's Root Resource Pool becomes the Resource Pool 'Resources' that is the Root Resource Pool of Cluster 'MyCluster'
   and the VMHost Resource Pool hierarchy is imported into the new nested Resource Pool.
#>
Configuration vCenterVMHost_AddVMHostTovCenterAndImportResourcePoolHierarchy_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        Datacenter Datacenter {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = 'MyDatacenter'
            Location = ''
            Ensure = 'Present'
        }

        Folder Folder {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = 'MyFolder'
            Location = ''
            DatacenterName = 'MyDatacenter'
            DatacenterLocation = ''
            Ensure = 'Present'
            FolderType = 'Host'
            DependsOn = '[Datacenter]Datacenter'
        }

        Cluster Cluster {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = 'MyCluster'
            Location = 'MyFolder'
            DatacenterName = 'MyDatacenter'
            DatacenterLocation = ''
            Ensure = 'Present'
            DrsEnabled = $true
            DependsOn = '[Folder]Folder'
        }

        vCenterVMHost vCenterVMHost {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = $AllNodes.VMHostName
            Location = 'MyFolder/MyCluster'
            DatacenterName = 'MyDatacenter'
            DatacenterLocation = ''
            Ensure = 'Present'
            VMHostCredential = $AllNodes.VMHostCredential
            ResourcePoolLocation = '/'
            Port = 443
            Force = $true
            DependsOn = '[Cluster]Cluster'
        }
    }
}

vCenterVMHost_AddVMHostTovCenterAndImportResourcePoolHierarchy_Config -ConfigurationData $script:configurationData
