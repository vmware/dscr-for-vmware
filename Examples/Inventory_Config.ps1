<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

$script:configurationData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
            VCenters = @(
                @{
                    Server = '<server>'
                    User = '<user>'
                    Password = '<password>'
                },
                @{
                    Server = '<server>'
                    User = '<user>'
                    Password = '<password>'
                }
            )
        }
    )
}

Configuration Inventory_WhenAddingInventoryItems_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        foreach ($vCenter in $AllNodes.VCenters) {
            $Server = $vCenter.Server
            $User = $vCenter.User
            $Password = $vCenter.Password | ConvertTo-SecureString -asPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential($User, $Password)

            DatacenterFolder "MyDatacentersFolder_$($Server)" {
                Server = $Server
                Credential = $Credential
                Name = 'MyDatacentersFolder'
                Location = ''
                Ensure = 'Present'
            }

            Datacenter "MyDatacenter_$($Server)" {
                Server = $Server
                Credential = $Credential
                Name = 'MyDatacenter'
                Location = 'MyDatacentersFolder'
                Ensure = 'Present'
                DependsOn = "[DatacenterFolder]MyDatacentersFolder_$($Server)"
            }

            Folder "MyFolder_$($Server)" {
                Server = $Server
                Credential = $Credential
                Name = 'MyFolder'
                Location = ''
                DatacenterName = 'MyDatacenter'
                DatacenterLocation = 'MyDatacentersFolder'
                Ensure = 'Present'
                FolderType = 'Host'
                DependsOn = "[Datacenter]MyDatacenter_$($Server)"
            }

            Folder "MyClustersFolder_$($Server)" {
                Server = $Server
                Credential = $Credential
                Name = 'MyClustersFolder'
                Location = 'MyFolder'
                DatacenterName = 'MyDatacenter'
                DatacenterLocation = 'MyDatacentersFolder'
                Ensure = 'Present'
                FolderType = 'Host'
                DependsOn = "[Folder]MyFolder_$($Server)"
            }

            Cluster "MyCluster_$($Server)" {
                Server = $Server
                Credential = $Credential
                Name = 'MyCluster'
                Location = 'MyFolder/MyClustersFolder'
                DatacenterName = 'MyDatacenter'
                DatacenterLocation = 'MyDatacentersFolder'
                Ensure = 'Present'
                HAEnabled = $true
                HAAdmissionControlEnabled = $true
                HAFailoverLevel = 3
                HAIsolationResponse = 'DoNothing'
                HARestartPriority = 'Low'
                DrsEnabled = $true
                DrsAutomationLevel = 'FullyAutomated'
                DrsMigrationThreshold = 5
                DrsDistribution = 0
                MemoryLoadBalancing = 100
                CPUOverCommitment = 500
                DependsOn = "[Folder]MyClustersFolder_$($Server)"
            }
        }
    }
}

Configuration Inventory_WhenRemovingInventoryItems_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        foreach ($vCenter in $AllNodes.VCenters) {
            $Server = $vCenter.Server
            $User = $vCenter.User
            $Password = $vCenter.Password | ConvertTo-SecureString -asPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential($User, $Password)

            Cluster "MyCluster_$($Server)" {
                Server = $Server
                Credential = $Credential
                Name = 'MyCluster'
                Location = 'MyFolder/MyClustersFolder'
                DatacenterName = 'MyDatacenter'
                DatacenterLocation = 'MyDatacentersFolder'
                Ensure = 'Absent'
                HAEnabled = $true
                HAAdmissionControlEnabled = $true
                HAFailoverLevel = 3
                HAIsolationResponse = 'DoNothing'
                HARestartPriority = 'Low'
                DrsEnabled = $true
                DrsAutomationLevel = 'FullyAutomated'
                DrsMigrationThreshold = 5
                DrsDistribution = 0
                MemoryLoadBalancing = 100
                CPUOverCommitment = 500
            }

            Folder "MyClustersFolder_$($Server)" {
                Server = $Server
                Credential = $Credential
                Name = 'MyClustersFolder'
                Location = 'MyFolder'
                DatacenterName = 'MyDatacenter'
                DatacenterLocation = 'MyDatacentersFolder'
                Ensure = 'Absent'
                FolderType = 'Host'
                DependsOn = "[Cluster]MyCluster_$($Server)"
            }

            Folder "MyFolder_$($Server)" {
                Server = $Server
                Credential = $Credential
                Name = 'MyFolder'
                Location = ''
                DatacenterName = 'MyDatacenter'
                DatacenterLocation = 'MyDatacentersFolder'
                Ensure = 'Absent'
                FolderType = 'Host'
                DependsOn = "[Folder]MyClustersFolder_$($Server)"
            }

            Datacenter "MyDatacenter_$($Server)" {
                Server = $Server
                Credential = $Credential
                Name = 'MyDatacenter'
                Location = 'MyDatacentersFolder'
                Ensure = 'Absent'
                DependsOn = "[Folder]MyFolder_$($Server)"
            }

            DatacenterFolder "MyDatacentersFolder_$($Server)" {
                Server = $Server
                Credential = $Credential
                Name = 'MyDatacentersFolder'
                Location = ''
                Ensure = 'Absent'
                DependsOn = "[Datacenter]MyDatacenter_$($Server)"
            }
        }
    }
}

Inventory_WhenAddingInventoryItems_Config -ConfigurationData $script:configurationData
Inventory_WhenRemovingInventoryItems_Config -ConfigurationData $script:configurationData
