<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

using module VMware.vSphereDSC

function Invoke-TestSetup {
    $script:modulePath = $env:PSModulePath
    $script:unitTestsFolder = Join-Path (Join-Path (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase 'Tests') 'Unit'
    $script:mockModuleLocation = "$script:unitTestsFolder\TestHelpers"

    $script:moduleName = 'VMware.vSphereDSC'
    $script:resourceName = 'DrsCluster'

    $script:user = 'user'
    $password = 'password' | ConvertTo-SecureString -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential($script:user, $password)

    $script:resourceProperties = @{
        Server = '10.23.80.58'
        Credential = $credential
        Name = 'MyCluster'
        Ensure = 'Present'
    }

    $script:constants = @{
        FolderType = 'Folder'
        RootFolderValue = 'group-d1'
        DatacentersFolderName = 'Datacenters'
        DatacenterId = 'MyDatacenter-datacenter-1'
        DatacenterName = 'MyDatacenter'
        DatacenterPathItemOne = 'MyDatacenterFolderOne'
        DatacenterPathItemTwoId = 'my-datacenter-folder-two'
        DatacenterPathItemTwo = 'MyDatacenterFolderTwo'
        HostFolderId = 'group-h4'
        HostFolderName = 'HostFolder'
        InventoryPathItemOneId = 'my-cluster-location-one'
        InventoryPathItemOne = 'MyClusterFolderOne'
        InventoryPathItemTwoId = 'my-cluster-location-two'
        InventoryPathItemTwo = 'MyClusterFolderTwo'
        ClusterId = 'my-cluster-id'
        ClusterName = 'MyCluster'
        DrsEnabled = $true
        DrsAutomationLevel = 'FullyAutomated'
        DrsMigrationThreshold = 5
        DrsDistribution = 0
        MemoryLoadBalancing = 100
        CPUOverCommitment = 500
    }

    $script:vCenterWithRootFolderScriptBlock = @'
        return [VMware.Vim.VCenter] @{
            Name = '$($script:resourceProperties.Server)'
            User = '$($script:user)'
            ExtensionData = [VMware.Vim.VCenterExtensionData] @{
                Content = [VMware.Vim.ServiceContent] @{
                    RootFolder = [VMware.Vim.ManagedObjectReference] @{
                        Type = '$($script:constants.FolderType)'
                        Value = '$($script:constants.RootFolderValue)'
                    }
                }
            }
        }
'@

    $script:rootFolderViewBaseObjectScriptBlock = @'
        return [VMware.Vim.Folder] @{
            Name = '$($script:constants.DatacentersFolderName)'
            MoRef = [VMware.Vim.ManagedObjectReference] @{
                Type = '$($script:constants.FolderType)'
                Value = '$($script:constants.RootFolderValue)'
            }
            ChildEntity = @(
                [VMware.Vim.ManagedObjectReference] @{
                    Type = '$($script:constants.FolderType)'
                    Value = '$($script:constants.DatacenterPathItemOne)'
                }
            )
        }
'@

    $script:datacenterPathItemOneScriptBlock = @'
        return [VMware.Vim.Folder] @{
            Name = '$($script:constants.DatacenterPathItemOne)'
            ChildEntity = @(
                [VMware.Vim.ManagedObjectReference] @{
                    Type = '$($script:constants.FolderType)'
                    Value = '$($script:constants.DatacenterPathItemTwo)'
                }
            )
        }
'@

    $script:datacenterPathItemTwoScriptBlock = @'
        return [VMware.Vim.Folder] @{
            Name = '$($script:constants.DatacenterPathItemTwo)'
            MoRef = [VMware.Vim.ManagedObjectReference] @{
                Type = '$($script:constants.FolderType)'
                Value = '$($script:constants.DatacenterPathItemTwoId)'
            }
        }
'@

    $script:datacenterFolderScriptBlock = @'
        return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
            Id = '$($script:constants.DatacenterPathItemTwoId)'
            Name = '$($script:constants.DatacenterPathItemTwo)'
        }
'@

    $script:datacenterWithPathItemTwoAsParentScriptBlock = @'
        return [VMware.VimAutomation.VICore.Impl.V1.Inventory.DatacenterImpl] @{
            Id = '$($script:constants.DatacenterId)'
            Name = '$($script:constants.DatacenterName)'
            ParentFolderId = '$($script:constants.DatacenterPathItemTwoId)'
            ExtensionData = [VMware.Vim.Datacenter] @{
                HostFolder = [VMware.Vim.ManagedObjectReference] @{
                    Type = '$($script:constants.FolderType)'
                    Value = '$($script:constants.HostFolderId)'
                }
            }
        }
'@

    $script:hostFolderOfDatacenterViewBaseObjectScriptBlock = @'
        return [VMware.Vim.Folder] @{
            Name = '$($script:constants.HostFolderName)'
            MoRef = [VMware.Vim.ManagedObjectReference] @{
                Type = '$($script:constants.FolderType)'
                Value = '$($script:constants.HostFolderId)'
            }
    }
'@

    $script:hostFolderScriptBlock = @'
        return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
            Id = '$($script:constants.HostFolderId)'
            Name = '$($script:constants.HostFolderName)'
        }
'@

    $script:locationsScriptBlock = @'
        return @(
            @{
                Id = [VMware.Vim.ManagedObjectReference] @{
                    Type = '$($script:constants.FolderType)'
                    Value = '$($script:constants.InventoryPathItemTwoId)'
                }
                ExtensionData = [VMware.Vim.Folder] @{
                    Name = '$($script:constants.InventoryPathItemTwo)'
                    MoRef = [VMware.Vim.ManagedObjectReference] @{
                        Type = '$($script:constants.FolderType)'
                        Value = '$($script:constants.InventoryPathItemTwoId)'
                    }
                }
            }
        )
'@

    $script:locationViewBaseObjectScriptBlock = @'
        return [VMware.Vim.Folder] @{
            Name = '$($script:constants.InventoryPathItemTwo)'
            Parent = [VMware.Vim.ManagedObjectReference] @{
                Type = '$($script:constants.FolderType)'
                Value = '$($script:constants.InventoryPathItemOneId)'
            }
        }
'@

    $script:locationParentScriptBlock = @'
        return [VMware.Vim.Folder] @{
            Name = '$($script:constants.InventoryPathItemOne)'
            Parent = [VMware.Vim.ManagedObjectReference] @{
                Type = '$($script:constants.FolderType)'
                Value = '$($script:constants.InventoryPathItemOneId)'
            }
        }
'@

    $script:clusterScriptBlock = @'
        return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.ClusterImpl] @{
            Id = '$($script:constants.ClusterId)'
            Name = '$($script:constants.ClusterName)'
            ParentId = [VMware.Vim.ManagedObjectReference] @{
                Type = '$($script:constants.FolderType)'
                Value = '$($script:constants.InventoryPathItemTwoId)'
            }
            ExtensionData = [VMware.Vim.ClusterComputeResource] @{
                ConfigurationEx = [VMware.Vim.ClusterConfigInfoEx] @{
                    DrsConfig = [VMware.Vim.ClusterDrsConfigInfo] @{
                        Enabled = '$($true)'
                        DefaultVmBehavior = 'Manual'
                        VmotionRate = 3
                        Option = @(
                            [VMware.Vim.OptionValue] @{
                                Key = 'LimitVMsPerESXHostPercent'
                                Value = 10
                            },
                            [VMware.Vim.OptionValue] @{
                                Key = 'PercentIdleMBInMemDemand'
                                Value = 200
                            },
                            [VMware.Vim.OptionValue] @{
                                Key = 'MaxVcpusPerClusterPct'
                                Value = 400
                            }
                        )
                    }
                }
            }
        }
'@

    $env:PSModulePath = $script:mockModuleLocation
    $vimAutomationModule = Get-Module -Name VMware.VimAutomation.Core
    if ($null -ne $vimAutomationModule -and $vimAutomationModule.Path -NotMatch 'TestHelpers') {
        throw 'The Original VMware.VimAutomation.Core Module is loaded in the current session. If you want to run the unit tests please open a new PowerShell session.'
    }

    Import-Module -Name VMware.VimAutomation.Core

    $script:vCenter = [VMware.Vim.VCenter] @{
        Name = $script:resourceProperties.Server
        User = $script:user
    }

    $script:rootFolder = [VMware.Vim.ManagedObjectReference] @{
        Type = $script:constants.FolderType
        Value = $script:constants.RootFolderValue
    }

    $script:datacenterPathItemOne = [VMware.Vim.ManagedObjectReference] @{
        Type = $script:constants.FolderType
        Value = $script:constants.DatacenterPathItemOne
    }

    $script:datacenterPathItemTwo = [VMware.Vim.ManagedObjectReference] @{
        Type = $script:constants.FolderType
        Value = $script:constants.DatacenterPathItemTwo
    }

    $script:hostFolder = [VMware.Vim.ManagedObjectReference] @{
        Type = $script:constants.FolderType
        Value = $script:constants.HostFolderId
    }

    $script:hostFolderLocation = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
        Id = $script:constants.HostFolderId
        Name = $script:constants.HostFolderName
    }

    $script:location = [VMware.Vim.ManagedObjectReference] @{
        Type = $script:constants.FolderType
        Value = $script:constants.InventoryPathItemTwoId
    }

    $script:locationParent = [VMware.Vim.ManagedObjectReference] @{
        Type = $script:constants.FolderType
        Value = $script:constants.InventoryPathItemOneId
    }

    $script:clusterLocation = @{
        Id = [VMware.Vim.ManagedObjectReference] @{
            Type = $script:constants.FolderType
            Value = $script:constants.InventoryPathItemTwoId
        }
    }

    $script:folder = [VMware.Vim.Folder] @{
        Name = $script:constants.InventoryPathItemTwo
        MoRef = [VMware.Vim.ManagedObjectReference] @{
            Type = $script:constants.FolderType
            Value = $script:constants.InventoryPathItemTwoId
        }
    }

    $script:clusterSpecWithoutDrsSettings = [VMware.Vim.ClusterConfigSpecEx] @{
        DrsConfig = [VMware.Vim.ClusterDrsConfigInfo] @{
            Option = @(
            )
        }
    }

    $script:clusterSpecWithDrsSettings = [VMware.Vim.ClusterConfigSpecEx] @{
        DrsConfig = [VMware.Vim.ClusterDrsConfigInfo] @{
            Enabled = $script:constants.DrsEnabled
            DefaultVmBehavior = $script:constants.DrsAutomationLevel
            VmotionRate = $script:constants.DrsMigrationThreshold
            Option = @(
                [VMware.Vim.OptionValue] @{
                    Key = 'LimitVMsPerESXHostPercent'
                    Value = $script:constants.DrsDistribution
                },
                [VMware.Vim.OptionValue] @{
                    Key = 'PercentIdleMBInMemDemand'
                    Value = $script:constants.MemoryLoadBalancing
                },
                [VMware.Vim.OptionValue] @{
                    Key = 'MaxVcpusPerClusterPct'
                    Value = $script:constants.CPUOverCommitment
                }
            )
        }
    }

    $script:clusterComputeResource = [VMware.Vim.ClusterComputeResource] @{
        ConfigurationEx = [VMware.Vim.ClusterConfigInfoEx] @{
            DrsConfig = [VMware.Vim.ClusterDrsConfigInfo] @{
                Enabled = $true
                DefaultVmBehavior = 'Manual'
                VmotionRate = 3
                Option = @(
                    [VMware.Vim.OptionValue] @{
                        Key = 'LimitVMsPerESXHostPercent'
                        Value = 10
                    },
                    [VMware.Vim.OptionValue] @{
                        Key = 'PercentIdleMBInMemDemand'
                        Value = 200
                    },
                    [VMware.Vim.OptionValue] @{
                        Key = 'MaxVcpusPerClusterPct'
                        Value = 400
                    }
                )
            }
        }
    }
}

function Invoke-TestCleanup {
    Remove-Module -Name VMware.VimAutomation.Core
    $env:PSModulePath = $script:modulePath
}

try {
    # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
    Invoke-TestSetup

    Describe 'DrsCluster\Set' -Tag 'Set' {
        BeforeEach {
            # Arrange
            $script:resourceProperties.Datacenter = "$($script:constants.DatacenterPathItemOne)/$($script:constants.DatacenterPathItemTwo)/$($script:constants.DatacenterName)"
            $script:resourceProperties.InventoryPath = "$($script:constants.InventoryPathItemOne)/$($script:constants.InventoryPathItemTwo)"

            $vCenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vCenterWithRootFolderScriptBlock))
            $rootFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:rootFolderViewBaseObjectScriptBlock))
            $datacenterPathItemOne = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemOneScriptBlock))
            $datacenterPathItemTwo = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemTwoScriptBlock))
            $datacenterFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterFolderScriptBlock))
            $datacenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterWithPathItemTwoAsParentScriptBlock))
            $hostFolderViewBaseObjectMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:hostFolderOfDatacenterViewBaseObjectScriptBlock))
            $hostFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:hostFolderScriptBlock))
            $locationsMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationsScriptBlock))
            $locationViewBaseObjectMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationViewBaseObjectScriptBlock))
            $locationParentMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationParentScriptBlock))

            Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $rootFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:rootFolder } -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $datacenterPathItemOne -ParameterFilter { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemOne } -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $datacenterPathItemTwo -ParameterFilter { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemTwo } -ModuleName $script:moduleName
            Mock -CommandName Get-Inventory -MockWith $datacenterFolderMock -ModuleName $script:moduleName
            Mock -CommandName Get-Datacenter -MockWith $datacenterMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $hostFolderViewBaseObjectMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder } -ModuleName $script:moduleName
            Mock -CommandName Get-Inventory -MockWith $hostFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder } -ModuleName $script:moduleName
            Mock -CommandName Get-Inventory -MockWith $locationsMock -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:constants.InventoryPathItemTwo -and $Location -eq $script:hostFolderLocation } -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $locationViewBaseObjectMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:location } -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $locationParentMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:locationParent } -ModuleName $script:moduleName

            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
        }

        AfterEach {
            $script:resourceProperties.Datacenter = [string]::Empty
            $script:resourceProperties.InventoryPath = [string]::Empty
        }

        Context 'Invoking with Ensure Present, non existing Cluster and no Drs settings specified' {
            BeforeAll {
                # Arrange
                Mock -CommandName Get-Inventory -MockWith { return $null } -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.Name -and $Location.Id -eq $script:clusterLocation.Id } -ModuleName $script:moduleName
                Mock -CommandName Add-Cluster -MockWith { return $null } -ModuleName $script:moduleName
            }

            It 'Should call the Add-Cluster mock with the passed parameters once' {
                # Act
                $resource.Set()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Add-Cluster'
                    ParameterFilter = { $Folder -eq $script:folder -and $Name -eq $script:resourceProperties.Name -and $Spec -eq $script:clusterSpecWithoutDrsSettings }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Invoking with Ensure Present, non existing Cluster and Drs settings specified' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.DrsEnabled = $script:constants.DrsEnabled
                $script:resourceProperties.DrsAutomationLevel = $script:constants.DrsAutomationLevel
                $script:resourceProperties.DrsMigrationThreshold = $script:constants.DrsMigrationThreshold
                $script:resourceProperties.DrsDistribution = $script:constants.DrsDistribution
                $script:resourceProperties.MemoryLoadBalancing = $script:constants.MemoryLoadBalancing
                $script:resourceProperties.CPUOverCommitment = $script:constants.CPUOverCommitment

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

                Mock -CommandName Get-Inventory -MockWith { return $null } -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.Name -and $Location.Id -eq $script:clusterLocation.Id } -ModuleName $script:moduleName
                Mock -CommandName Add-Cluster -MockWith { return $null } -ModuleName $script:moduleName
            }

            AfterAll {
                $script:resourceProperties.DrsEnabled = $null
                $script:resourceProperties.DrsAutomationLevel = 'Unset'
                $script:resourceProperties.DrsMigrationThreshold = $null
                $script:resourceProperties.DrsDistribution = $null
                $script:resourceProperties.MemoryLoadBalancing = $null
                $script:resourceProperties.CPUOverCommitment = $null
            }

            It 'Should call the Add-Cluster mock with the passed parameters once' {
                # Act
                $resource.Set()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Add-Cluster'
                    ParameterFilter = { $Folder -eq $script:folder -and $Name -eq $script:resourceProperties.Name -and $Spec -eq $script:clusterSpecWithDrsSettings }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Invoking with Ensure Present, existing Cluster and no Drs settings specified' {
            BeforeAll {
                # Arrange
                $clusterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:clusterScriptBlock))

                Mock -CommandName Get-Inventory -MockWith $clusterMock -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.Name -and $Location.Id -eq $script:clusterLocation.Id } -ModuleName $script:moduleName
                Mock -CommandName Update-ClusterComputeResource -MockWith { return $null } -ModuleName $script:moduleName
            }

            It 'Should call the Update-ClusterComputeResource mock with the passed parameters once' {
                # Act
                $resource.Set()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Update-ClusterComputeResource'
                    ParameterFilter = { $ClusterComputeResource -eq $script:clusterComputeResource -and $Spec -eq $script:clusterSpecWithoutDrsSettings }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Invoking with Ensure Present, existing Cluster and Drs settings specified' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.DrsEnabled = $script:constants.DrsEnabled
                $script:resourceProperties.DrsAutomationLevel = $script:constants.DrsAutomationLevel
                $script:resourceProperties.DrsMigrationThreshold = $script:constants.DrsMigrationThreshold
                $script:resourceProperties.DrsDistribution = $script:constants.DrsDistribution
                $script:resourceProperties.MemoryLoadBalancing = $script:constants.MemoryLoadBalancing
                $script:resourceProperties.CPUOverCommitment = $script:constants.CPUOverCommitment

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

                $clusterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:clusterScriptBlock))

                Mock -CommandName Get-Inventory -MockWith $clusterMock -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.Name -and $Location.Id -eq $script:clusterLocation.Id } -ModuleName $script:moduleName
                Mock -CommandName Update-ClusterComputeResource -MockWith { return $null } -ModuleName $script:moduleName
            }

            AfterAll {
                $script:resourceProperties.DrsEnabled = $null
                $script:resourceProperties.DrsAutomationLevel = 'Unset'
                $script:resourceProperties.DrsMigrationThreshold = $null
                $script:resourceProperties.DrsDistribution = $null
                $script:resourceProperties.MemoryLoadBalancing = $null
                $script:resourceProperties.CPUOverCommitment = $null
            }

            It 'Should call the Update-ClusterComputeResource mock with the passed parameters once' {
                # Act
                $resource.Set()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Update-ClusterComputeResource'
                    ParameterFilter = { $ClusterComputeResource -eq $script:clusterComputeResource -and $Spec -eq $script:clusterSpecWithDrsSettings }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Invoking with Ensure Absent and existing Cluster' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Ensure = 'Absent'
                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

                $clusterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:clusterScriptBlock))

                Mock -CommandName Get-Inventory -MockWith $clusterMock -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.Name -and $Location.Id -eq $script:clusterLocation.Id } -ModuleName $script:moduleName
                Mock -CommandName Remove-ClusterComputeResource -MockWith { return $null } -ModuleName $script:moduleName
            }

            AfterAll {
                $script:resourceProperties.Ensure = 'Present'
            }

            It 'Should call the Remove-ClusterComputeResource mock with the passed parameters once' {
                # Act
                $resource.Set()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Remove-ClusterComputeResource'
                    ParameterFilter = { $ClusterComputeResource -eq $script:clusterComputeResource }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Invoking with Ensure Absent and non existing Cluster' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Ensure = 'Absent'
                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

                Mock -CommandName Get-Inventory -MockWith { return $null } -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.Name -and $Location.Id -eq $script:clusterLocation.Id } -ModuleName $script:moduleName
                Mock -CommandName Remove-ClusterComputeResource -MockWith { return $null } -ModuleName $script:moduleName
            }

            AfterAll {
                $script:resourceProperties.Ensure = 'Present'
            }

            It 'Should not call the Remove-ClusterComputeResource mock' {
                # Act
                $resource.Set()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Remove-ClusterComputeResource'
                    ParameterFilter = { $ClusterComputeResource -eq $script:clusterComputeResource }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 0
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }
    }

    Describe 'DrsCluster\Test' -Tag 'Test' {
        BeforeEach {
            # Arrange
            $script:resourceProperties.Datacenter = "$($script:constants.DatacenterPathItemOne)/$($script:constants.DatacenterPathItemTwo)/$($script:constants.DatacenterName)"
            $script:resourceProperties.InventoryPath = "$($script:constants.InventoryPathItemOne)/$($script:constants.InventoryPathItemTwo)"

            $vCenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vCenterWithRootFolderScriptBlock))
            $rootFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:rootFolderViewBaseObjectScriptBlock))
            $datacenterPathItemOne = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemOneScriptBlock))
            $datacenterPathItemTwo = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemTwoScriptBlock))
            $datacenterFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterFolderScriptBlock))
            $datacenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterWithPathItemTwoAsParentScriptBlock))
            $hostFolderViewBaseObjectMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:hostFolderOfDatacenterViewBaseObjectScriptBlock))
            $hostFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:hostFolderScriptBlock))
            $locationsMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationsScriptBlock))
            $locationViewBaseObjectMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationViewBaseObjectScriptBlock))
            $locationParentMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationParentScriptBlock))

            Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $rootFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:rootFolder } -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $datacenterPathItemOne -ParameterFilter { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemOne } -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $datacenterPathItemTwo -ParameterFilter { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemTwo } -ModuleName $script:moduleName
            Mock -CommandName Get-Inventory -MockWith $datacenterFolderMock -ModuleName $script:moduleName
            Mock -CommandName Get-Datacenter -MockWith $datacenterMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $hostFolderViewBaseObjectMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder } -ModuleName $script:moduleName
            Mock -CommandName Get-Inventory -MockWith $hostFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder } -ModuleName $script:moduleName
            Mock -CommandName Get-Inventory -MockWith $locationsMock -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:constants.InventoryPathItemTwo -and $Location -eq $script:hostFolderLocation } -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $locationViewBaseObjectMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:location } -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $locationParentMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:locationParent } -ModuleName $script:moduleName

            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
        }

        AfterEach {
            $script:resourceProperties.Datacenter = [string]::Empty
            $script:resourceProperties.InventoryPath = [string]::Empty
        }

        Context 'Invoking with Ensure Present and non existing Cluster' {
            BeforeAll {
                # Arrange
                Mock -CommandName Get-Inventory -MockWith { return $null } -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.Name -and $Location.Id -eq $script:clusterLocation.Id } -ModuleName $script:moduleName
            }

            It 'Should return $false' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $false
            }
        }

        Context 'Invoking with Ensure Present, existing Cluster and matching settings' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.DrsEnabled = $script:constants.DrsEnabled
                $script:resourceProperties.DrsAutomationLevel = 'Manual'
                $script:resourceProperties.DrsMigrationThreshold = 3
                $script:resourceProperties.DrsDistribution = 10
                $script:resourceProperties.MemoryLoadBalancing = 200
                $script:resourceProperties.CPUOverCommitment = 400

                $clusterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:clusterScriptBlock))
                Mock -CommandName Get-Inventory -MockWith $clusterMock -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.Name -and $Location.Id -eq $script:clusterLocation.Id } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.DrsEnabled = $null
                $script:resourceProperties.DrsAutomationLevel = 'Unset'
                $script:resourceProperties.DrsMigrationThreshold = $null
                $script:resourceProperties.DrsDistribution = $null
                $script:resourceProperties.MemoryLoadBalancing = $null
                $script:resourceProperties.CPUOverCommitment = $null
            }

            It 'Should return $true' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $true
            }
        }

        Context 'Invoking with Ensure Present, existing Cluster and non matching settings' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.DrsEnabled = $script:constants.DrsEnabled
                $script:resourceProperties.DrsAutomationLevel = $script:constants.DrsAutomationLevel
                $script:resourceProperties.DrsMigrationThreshold = $script:constants.DrsMigrationThreshold
                $script:resourceProperties.DrsDistribution = $script:constants.DrsDistribution
                $script:resourceProperties.MemoryLoadBalancing = $script:constants.MemoryLoadBalancing
                $script:resourceProperties.CPUOverCommitment = $script:constants.CPUOverCommitment

                $clusterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:clusterScriptBlock))
                Mock -CommandName Get-Inventory -MockWith $clusterMock -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.Name -and $Location.Id -eq $script:clusterLocation.Id } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.DrsEnabled = $null
                $script:resourceProperties.DrsAutomationLevel = 'Unset'
                $script:resourceProperties.DrsMigrationThreshold = $null
                $script:resourceProperties.DrsDistribution = $null
                $script:resourceProperties.MemoryLoadBalancing = $null
                $script:resourceProperties.CPUOverCommitment = $null
            }

            It 'Should return $false' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $false
            }
        }

        Context 'Invoking with Ensure Absent and non existing Cluster' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Ensure = 'Absent'
                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

                Mock -CommandName Get-Inventory -MockWith { return $null } -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.Name -and $Location.Id -eq $script:clusterLocation.Id } -ModuleName $script:moduleName
            }

            AfterAll {
                $script:resourceProperties.Ensure = 'Present'
            }

            It 'Should return $true' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $true
            }
        }

        Context 'Invoking with Ensure Absent and existing Cluster' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Ensure = 'Absent'
                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

                $clusterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:clusterScriptBlock))
                Mock -CommandName Get-Inventory -MockWith $clusterMock -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.Name -and $Location.Id -eq $script:clusterLocation.Id } -ModuleName $script:moduleName
            }

            AfterAll {
                $script:resourceProperties.Ensure = 'Present'
            }

            It 'Should return $false' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $false
            }
        }
    }

    Describe 'DrsCluster\Get' -Tag 'Get' {
        BeforeEach {
            # Arrange
            $script:resourceProperties.Datacenter = "$($script:constants.DatacenterPathItemOne)/$($script:constants.DatacenterPathItemTwo)/$($script:constants.DatacenterName)"
            $script:resourceProperties.InventoryPath = "$($script:constants.InventoryPathItemOne)/$($script:constants.InventoryPathItemTwo)"
            $script:resourceProperties.DrsEnabled = $script:constants.DrsEnabled
            $script:resourceProperties.DrsAutomationLevel = $script:constants.DrsAutomationLevel
            $script:resourceProperties.DrsMigrationThreshold = $script:constants.DrsMigrationThreshold
            $script:resourceProperties.DrsDistribution = $script:constants.DrsDistribution
            $script:resourceProperties.MemoryLoadBalancing = $script:constants.MemoryLoadBalancing
            $script:resourceProperties.CPUOverCommitment = $script:constants.CPUOverCommitment

            $vCenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vCenterWithRootFolderScriptBlock))
            $rootFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:rootFolderViewBaseObjectScriptBlock))
            $datacenterPathItemOne = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemOneScriptBlock))
            $datacenterPathItemTwo = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemTwoScriptBlock))
            $datacenterFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterFolderScriptBlock))
            $datacenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterWithPathItemTwoAsParentScriptBlock))
            $hostFolderViewBaseObjectMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:hostFolderOfDatacenterViewBaseObjectScriptBlock))
            $hostFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:hostFolderScriptBlock))
            $locationsMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationsScriptBlock))
            $locationViewBaseObjectMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationViewBaseObjectScriptBlock))
            $locationParentMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationParentScriptBlock))

            Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $rootFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:rootFolder } -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $datacenterPathItemOne -ParameterFilter { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemOne } -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $datacenterPathItemTwo -ParameterFilter { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemTwo } -ModuleName $script:moduleName
            Mock -CommandName Get-Inventory -MockWith $datacenterFolderMock -ModuleName $script:moduleName
            Mock -CommandName Get-Datacenter -MockWith $datacenterMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $hostFolderViewBaseObjectMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder } -ModuleName $script:moduleName
            Mock -CommandName Get-Inventory -MockWith $hostFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder } -ModuleName $script:moduleName
            Mock -CommandName Get-Inventory -MockWith $locationsMock -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:constants.InventoryPathItemTwo -and $Location -eq $script:hostFolderLocation } -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $locationViewBaseObjectMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:location } -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $locationParentMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:locationParent } -ModuleName $script:moduleName

            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
        }

        AfterEach {
            $script:resourceProperties.Datacenter = [string]::Empty
            $script:resourceProperties.InventoryPath = [string]::Empty
            $script:resourceProperties.DrsEnabled = $null
            $script:resourceProperties.DrsAutomationLevel = 'Unset'
            $script:resourceProperties.DrsMigrationThreshold = $null
            $script:resourceProperties.DrsDistribution = $null
            $script:resourceProperties.MemoryLoadBalancing = $null
            $script:resourceProperties.CPUOverCommitment = $null
        }

        Context 'Invoking with Ensure Present and non existing Cluster' {
            BeforeAll {
                # Arrange
                Mock -CommandName Get-Inventory -MockWith { return $null } -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.Name -and $Location.Id -eq $script:clusterLocation.Id } -ModuleName $script:moduleName
            }

            It 'Should retrieve the correct settings from the server' {
                # Act
                $result = $resource.Get()

                # Assert
                $result.Server | Should -Be $script:resourceProperties.Server
                $result.InventoryPath | Should -Be $script:resourceProperties.InventoryPath
                $result.Datacenter | Should -Be $script:resourceProperties.Datacenter
                $result.Name | Should -Be $script:resourceProperties.Name
                $result.Ensure | Should -Be 'Absent'
                $result.DrsEnabled | Should -Be $script:resourceProperties.DrsEnabled
                $result.DrsAutomationLevel | Should -Be $script:resourceProperties.DrsAutomationLevel
                $result.DrsMigrationThreshold | Should -Be $script:resourceProperties.DrsMigrationThreshold
                $result.DrsDistribution | Should -Be $script:resourceProperties.DrsDistribution
                $result.MemoryLoadBalancing | Should -Be $script:resourceProperties.MemoryLoadBalancing
                $result.CPUOverCommitment | Should -Be $script:resourceProperties.CPUOverCommitment
            }
        }

        Context 'Invoking with Ensure Present and existing Cluster' {
            BeforeAll {
                # Arrange
                $clusterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:clusterScriptBlock))

                Mock -CommandName Get-Inventory -MockWith $clusterMock -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.Name -and $Location.Id -eq $script:clusterLocation.Id } -ModuleName $script:moduleName
            }

            It 'Should retrieve the correct settings from the server' {
                # Act
                $result = $resource.Get()

                # Assert
                $result.Server | Should -Be $script:resourceProperties.Server
                $result.InventoryPath | Should -Be $script:resourceProperties.InventoryPath
                $result.Datacenter | Should -Be $script:resourceProperties.Datacenter
                $result.Name | Should -Be $script:resourceProperties.Name
                $result.Ensure | Should -Be 'Present'
                $result.DrsEnabled | Should -Be $script:clusterComputeResource.ConfigurationEx.DrsConfig.Enabled
                $result.DrsAutomationLevel | Should -Be $script:clusterComputeResource.ConfigurationEx.DrsConfig.DefaultVmBehavior
                $result.DrsMigrationThreshold | Should -Be $script:clusterComputeResource.ConfigurationEx.DrsConfig.VmotionRate
                $result.DrsDistribution | Should -Be ($script:clusterComputeResource.ConfigurationEx.DrsConfig.Option | Where-Object { $_.Key -eq 'LimitVMsPerESXHostPercent' }).Value
                $result.MemoryLoadBalancing | Should -Be ($script:clusterComputeResource.ConfigurationEx.DrsConfig.Option | Where-Object { $_.Key -eq 'PercentIdleMBInMemDemand' }).Value
                $result.CPUOverCommitment | Should -Be ($script:clusterComputeResource.ConfigurationEx.DrsConfig.Option | Where-Object { $_.Key -eq 'MaxVcpusPerClusterPct' }).Value
            }
        }

        Context 'Invoking with Ensure Absent and non existing Cluster' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Ensure = 'Absent'
                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

                Mock -CommandName Get-Inventory -MockWith { return $null } -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.Name -and $Location.Id -eq $script:clusterLocation.Id } -ModuleName $script:moduleName
            }

            AfterAll {
                $script:resourceProperties.Ensure = 'Present'
            }

            It 'Should retrieve the correct settings from the server' {
                # Act
                $result = $resource.Get()

                # Assert
                $result.Server | Should -Be $script:resourceProperties.Server
                $result.InventoryPath | Should -Be $script:resourceProperties.InventoryPath
                $result.Datacenter | Should -Be $script:resourceProperties.Datacenter
                $result.Name | Should -Be $script:resourceProperties.Name
                $result.Ensure | Should -Be 'Absent'
                $result.DrsEnabled | Should -Be $script:resourceProperties.DrsEnabled
                $result.DrsAutomationLevel | Should -Be $script:resourceProperties.DrsAutomationLevel
                $result.DrsMigrationThreshold | Should -Be $script:resourceProperties.DrsMigrationThreshold
                $result.DrsDistribution | Should -Be $script:resourceProperties.DrsDistribution
                $result.MemoryLoadBalancing | Should -Be $script:resourceProperties.MemoryLoadBalancing
                $result.CPUOverCommitment | Should -Be $script:resourceProperties.CPUOverCommitment
            }
        }

        Context 'Invoking with Ensure Absent and existing Cluster' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Ensure = 'Absent'
                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

                $clusterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:clusterScriptBlock))
                Mock -CommandName Get-Inventory -MockWith $clusterMock -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.Name -and $Location.Id -eq $script:clusterLocation.Id } -ModuleName $script:moduleName
            }

            AfterAll {
                $script:resourceProperties.Ensure = 'Present'
            }

            It 'Should retrieve the correct settings from the server' {
                # Act
                $result = $resource.Get()

                # Assert
                $result.Server | Should -Be $script:resourceProperties.Server
                $result.InventoryPath | Should -Be $script:resourceProperties.InventoryPath
                $result.Datacenter | Should -Be $script:resourceProperties.Datacenter
                $result.Name | Should -Be $script:resourceProperties.Name
                $result.Ensure | Should -Be 'Present'
                $result.DrsEnabled | Should -Be $script:clusterComputeResource.ConfigurationEx.DrsConfig.Enabled
                $result.DrsAutomationLevel | Should -Be $script:clusterComputeResource.ConfigurationEx.DrsConfig.DefaultVmBehavior
                $result.DrsMigrationThreshold | Should -Be $script:clusterComputeResource.ConfigurationEx.DrsConfig.VmotionRate
                $result.DrsDistribution | Should -Be ($script:clusterComputeResource.ConfigurationEx.DrsConfig.Option | Where-Object { $_.Key -eq 'LimitVMsPerESXHostPercent' }).Value
                $result.MemoryLoadBalancing | Should -Be ($script:clusterComputeResource.ConfigurationEx.DrsConfig.Option | Where-Object { $_.Key -eq 'PercentIdleMBInMemDemand' }).Value
                $result.CPUOverCommitment | Should -Be ($script:clusterComputeResource.ConfigurationEx.DrsConfig.Option | Where-Object { $_.Key -eq 'MaxVcpusPerClusterPct' }).Value
            }
        }
    }
}
finally {
    # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
    Invoke-TestCleanup
}
