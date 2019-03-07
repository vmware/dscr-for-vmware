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
$script:vCenterCredential = New-Object System.Management.Automation.PSCredential($User, $Password)

$script:clusterName = 'MyCluster'
$script:inventoryPath = [string]::Empty
$script:inventoryPathWithCustomFolder = 'MyClusterFolder'
$script:datacenter = 'Datacenter'

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

Configuration HACluster_WithClusterToAdd_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        HACluster haCluster {
            Server = $Server
            Credential = $script:vCenterCredential
            Ensure = 'Present'
            InventoryPath = $script:inventoryPath
            Datacenter = $script:datacenter
            Name = $script:clusterName
            HAEnabled = $true
            HAAdmissionControlEnabled = $true
            HAFailoverLevel = 3
            HAIsolationResponse = 'DoNothing'
            HARestartPriority = 'Low'
        }
    }
}

Configuration HACluster_WithClusterToAddInCustomFolder_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        HACluster haCluster {
            Server = $Server
            Credential = $script:vCenterCredential
            Ensure = 'Present'
            InventoryPath = $script:inventoryPathWithCustomFolder
            Datacenter = $script:datacenter
            Name = $script:clusterName
            HAEnabled = $true
            HAAdmissionControlEnabled = $true
            HAFailoverLevel = 2
            HAIsolationResponse = 'PowerOff'
            HARestartPriority = 'High'
        }
    }
}

Configuration HACluster_WithClusterToUpdate_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        HACluster haCluster {
            Server = $Server
            Credential = $script:vCenterCredential
            Ensure = 'Present'
            InventoryPath = $script:inventoryPath
            Datacenter = $script:datacenter
            Name = $script:clusterName
            HAAdmissionControlEnabled = $false
            HAIsolationResponse = 'PowerOff'
        }
    }
}

Configuration HACluster_WithClusterToUpdateInCustomFolder_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        HACluster haCluster {
            Server = $Server
            Credential = $script:vCenterCredential
            Ensure = 'Present'
            InventoryPath = $script:inventoryPathWithCustomFolder
            Datacenter = $script:datacenter
            Name = $script:clusterName
            HAFailoverLevel = 4
            HARestartPriority = 'Medium'
        }
    }
}

Configuration HACluster_WithClusterToRemove_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        HACluster haCluster {
            Server = $Server
            Credential = $script:vCenterCredential
            Ensure = 'Absent'
            InventoryPath = $script:inventoryPath
            Datacenter = $script:datacenter
            Name = $script:clusterName
        }
    }
}

Configuration HACluster_WithClusterToRemoveInCustomFolder_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        HACluster haCluster {
            Server = $Server
            Credential = $script:vCenterCredential
            Ensure = 'Absent'
            InventoryPath = $script:inventoryPathWithCustomFolder
            Datacenter = $script:datacenter
            Name = $script:clusterName
        }
    }
}

HACluster_WithClusterToAdd_Config -OutputPath "$integrationTestsFolderPath\HACluster_WithClusterToAdd_Config" -ConfigurationData $script:configurationData
HACluster_WithClusterToAddInCustomFolder_Config -OutputPath "$integrationTestsFolderPath\HACluster_WithClusterToAddInCustomFolder_Config" -ConfigurationData $script:configurationData
HACluster_WithClusterToUpdate_Config -OutputPath "$integrationTestsFolderPath\HACluster_WithClusterToUpdate_Config" -ConfigurationData $script:configurationData
HACluster_WithClusterToUpdateInCustomFolder_Config -OutputPath "$integrationTestsFolderPath\HACluster_WithClusterToUpdateInCustomFolder_Config" -ConfigurationData $script:configurationData
HACluster_WithClusterToRemove_Config -OutputPath "$integrationTestsFolderPath\HACluster_WithClusterToRemove_Config" -ConfigurationData $script:configurationData
HACluster_WithClusterToRemoveInCustomFolder_Config -OutputPath "$integrationTestsFolderPath\HACluster_WithClusterToRemoveInCustomFolder_Config" -ConfigurationData $script:configurationData
