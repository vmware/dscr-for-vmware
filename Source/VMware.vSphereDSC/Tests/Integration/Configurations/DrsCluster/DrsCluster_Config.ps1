<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCDrsNTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SDrsLL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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

Configuration DrsCluster_WithClusterToAdd_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        DrsCluster drsCluster {
            Server = $Server
            Credential = $script:vCenterCredential
            Ensure = 'Present'
            InventoryPath = $script:inventoryPath
            Datacenter = $script:datacenter
            Name = $script:clusterName
            DrsEnabled = $true
            DrsAutomationLevel = 'FullyAutomated'
            DrsMigrationThreshold = 5
            DrsDistribution = 0
            MemoryLoadBalancing = 100
            CPUOverCommitment = 500
        }
    }
}

Configuration DrsCluster_WithClusterToAddInCustomFolder_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        DrsCluster drsCluster {
            Server = $Server
            Credential = $script:vCenterCredential
            Ensure = 'Present'
            InventoryPath = $script:inventoryPathWithCustomFolder
            Datacenter = $script:datacenter
            Name = $script:clusterName
            DrsEnabled = $true
            DrsAutomationLevel = 'PartiallyAutomated'
            DrsMigrationThreshold = 3
            DrsDistribution = 1
            MemoryLoadBalancing = 200
            CPUOverCommitment = 400
        }
    }
}

Configuration DrsCluster_WithClusterToUpdate_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        DrsCluster drsCluster {
            Server = $Server
            Credential = $script:vCenterCredential
            Ensure = 'Present'
            InventoryPath = $script:inventoryPath
            Datacenter = $script:datacenter
            Name = $script:clusterName
            DrsAutomationLevel = 'Manual'
            DrsMigrationThreshold = 1
        }
    }
}

Configuration DrsCluster_WithClusterToUpdateInCustomFolder_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        DrsCluster drsCluster {
            Server = $Server
            Credential = $script:vCenterCredential
            Ensure = 'Present'
            InventoryPath = $script:inventoryPathWithCustomFolder
            Datacenter = $script:datacenter
            Name = $script:clusterName
            DrsDistribution = 2
            MemoryLoadBalancing = 50
            CPUOverCommitment = 300
        }
    }
}

Configuration DrsCluster_WithClusterToRemove_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        DrsCluster drsCluster {
            Server = $Server
            Credential = $script:vCenterCredential
            Ensure = 'Absent'
            InventoryPath = $script:inventoryPath
            Datacenter = $script:datacenter
            Name = $script:clusterName
        }
    }
}

Configuration DrsCluster_WithClusterToRemoveInCustomFolder_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        DrsCluster drsCluster {
            Server = $Server
            Credential = $script:vCenterCredential
            Ensure = 'Absent'
            InventoryPath = $script:inventoryPathWithCustomFolder
            Datacenter = $script:datacenter
            Name = $script:clusterName
        }
    }
}

DrsCluster_WithClusterToAdd_Config -OutputPath "$integrationTestsFolderPath\DrsCluster_WithClusterToAdd_Config" -ConfigurationData $script:configurationData
DrsCluster_WithClusterToAddInCustomFolder_Config -OutputPath "$integrationTestsFolderPath\DrsCluster_WithClusterToAddInCustomFolder_Config" -ConfigurationData $script:configurationData
DrsCluster_WithClusterToUpdate_Config -OutputPath "$integrationTestsFolderPath\DrsCluster_WithClusterToUpdate_Config" -ConfigurationData $script:configurationData
DrsCluster_WithClusterToUpdateInCustomFolder_Config -OutputPath "$integrationTestsFolderPath\DrsCluster_WithClusterToUpdateInCustomFolder_Config" -ConfigurationData $script:configurationData
DrsCluster_WithClusterToRemove_Config -OutputPath "$integrationTestsFolderPath\DrsCluster_WithClusterToRemove_Config" -ConfigurationData $script:configurationData
DrsCluster_WithClusterToRemoveInCustomFolder_Config -OutputPath "$integrationTestsFolderPath\DrsCluster_WithClusterToRemoveInCustomFolder_Config" -ConfigurationData $script:configurationData
