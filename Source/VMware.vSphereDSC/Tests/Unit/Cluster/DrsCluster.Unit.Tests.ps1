<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

Using module '..\..\..\VMware.vSphereDSC.psm1'

$script:moduleName = 'VMware.vSphereDSC'

InModuleScope -ModuleName $script:moduleName {
    try {
        $unitTestsFolder = Join-Path (Join-Path (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase 'Tests') 'Unit'
        $modulePath = $env:PSModulePath
        $resourceName = 'DrsCluster'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
        . "$unitTestsFolder\TestHelpers\Mocks\DrsClusterMocks.ps1"

        Describe 'DrsCluster\Set' -Tag 'Set' {
            BeforeAll {
                # Arrange
                New-MocksForDrsCluster
            }

            Context 'Invoking with Ensure Present, non existing Cluster and no Drs settings specified' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsurePresentNonExistingClusterAndNoDrsSettingsSpecified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Add-Cluster mock without Drs settings specified once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Add-Cluster'
                        ParameterFilter = { $Name -eq $resourceProperties.Name -and $Folder -eq $script:foundLocationsForCluster[0].ExtensionData -and $Spec -eq $script:clusterSpecWithoutDrsSettings }
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
                    $resourceProperties = New-MocksWhenEnsurePresentNonExistingClusterAndDrsSettingsSpecified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Add-Cluster mock with Drs settings specified once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Add-Cluster'
                        ParameterFilter = { $Name -eq $resourceProperties.Name -and $Folder -eq $script:foundLocationsForCluster[0].ExtensionData -and $Spec -eq $script:clusterSpecWithDrsSettings }
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
                    $resourceProperties = New-MocksWhenEnsurePresentExistingClusterAndNoDrsSettingsSpecified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Update-ClusterComputeResource mock without Drs settings specified once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Update-ClusterComputeResource'
                        ParameterFilter = { $ClusterComputeResource -eq $script:clusterComputeResource -and $Spec -eq $script:clusterSpecWithoutDrsSettings }
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
                    $resourceProperties = New-MocksWhenEnsurePresentExistingClusterAndDrsSettingsSpecified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Update-ClusterComputeResource mock with Drs settings specified once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Update-ClusterComputeResource'
                        ParameterFilter = { $ClusterComputeResource -eq $script:clusterComputeResource -and $Spec -eq $script:clusterSpecWithDrsSettings }
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
                    $resourceProperties = New-MocksWhenEnsureAbsentAndExistingCluster
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Remove-ClusterComputeResource mock once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Remove-ClusterComputeResource'
                        ParameterFilter = { $ClusterComputeResource -eq $script:clusterComputeResource }
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
                    $resourceProperties = New-MocksWhenEnsureAbsentAndNonExistingCluster
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should not call the Remove-ClusterComputeResource mock' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Remove-ClusterComputeResource'
                        ParameterFilter = { $ClusterComputeResource -eq $script:clusterComputeResource }
                        Exactly = $true
                        Times = 0
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }
        }

        Describe 'DrsCluster\Test' -Tag 'Test' {
            BeforeAll {
                # Arrange
                New-MocksForDrsCluster
            }

            Context 'Invoking with Ensure Present and non existing Cluster' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsurePresentAndNonExistingCluster
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when the Cluster does not exist' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'Invoking with Ensure Present, existing Cluster and matching settings' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsurePresentExistingClusterAndMatchingSettings
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when the Cluster exists and the Drs settings are equal' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }

            Context 'Invoking with Ensure Present, existing Cluster and non matching settings' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsurePresentExistingClusterAndNonMatchingSettings
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when the Cluster exists and the Drs settings are not equal' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'Invoking with Ensure Absent and non existing Cluster' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksInTestWhenEnsureAbsentAndNonExistingCluster
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when the Cluster does not exist' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }

            Context 'Invoking with Ensure Absent and existing Cluster' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksInTestWhenEnsureAbsentAndExistingCluster
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when the Cluster exists' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }
        }

        Describe 'DrsCluster\Get' -Tag 'Get' {
            BeforeAll {
                # Arrange
                New-MocksForDrsCluster
            }

            Context 'Invoking with Ensure Present and non existing Cluster' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksInGetWhenEnsurePresentAndNonExistingCluster
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Get()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should retrieve the correct settings from the Resource properties and Ensure should be set to Absent' {
                    # Act
                    $result = $resource.Get()

                    # Assert
                    $result.Server | Should -Be $resourceProperties.Server
                    $result.Name | Should -Be $resourceProperties.Name
                    $result.Location | Should -Be $resourceProperties.Location
                    $result.DatacenterName | Should -Be $resourceProperties.DatacenterName
                    $result.DatacenterLocation | Should -Be $resourceProperties.DatacenterLocation
                    $result.Ensure | Should -Be 'Absent'
                    $result.DrsEnabled | Should -Be $resourceProperties.DrsEnabled
                    $result.DrsAutomationLevel | Should -Be $resourceProperties.DrsAutomationLevel
                    $result.DrsMigrationThreshold | Should -Be $resourceProperties.DrsMigrationThreshold
                    $result.DrsDistribution | Should -Be $resourceProperties.DrsDistribution
                    $result.MemoryLoadBalancing | Should -Be $resourceProperties.MemoryLoadBalancing
                    $result.CPUOverCommitment | Should -Be $resourceProperties.CPUOverCommitment
                }
            }

            Context 'Invoking with Ensure Present and existing Cluster' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksInGetWhenEnsurePresentAndExistingCluster
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Get()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should retrieve the correct settings from the Server and Ensure should be set to Present' {
                    # Act
                    $result = $resource.Get()

                    # Assert
                    $result.Server | Should -Be $resourceProperties.Server
                    $result.Name | Should -Be $script:cluster.Name
                    $result.Location | Should -Be $resourceProperties.Location
                    $result.DatacenterName | Should -Be $resourceProperties.DatacenterName
                    $result.DatacenterLocation | Should -Be $resourceProperties.DatacenterLocation
                    $result.Ensure | Should -Be 'Present'
                    $result.DrsEnabled | Should -Be $script:cluster.ExtensionData.ConfigurationEx.DrsConfig.Enabled
                    $result.DrsAutomationLevel | Should -Be $script:cluster.ExtensionData.ConfigurationEx.DrsConfig.DefaultVmBehavior.ToString()
                    $result.DrsMigrationThreshold | Should -Be $script:cluster.ExtensionData.ConfigurationEx.DrsConfig.VmotionRate
                    $result.DrsDistribution | Should -Be ($script:cluster.ExtensionData.ConfigurationEx.DrsConfig.Option[0]).Value
                    $result.MemoryLoadBalancing | Should -Be ($script:cluster.ExtensionData.ConfigurationEx.DrsConfig.Option[1]).Value
                    $result.CPUOverCommitment | Should -Be ($script:cluster.ExtensionData.ConfigurationEx.DrsConfig.Option[2]).Value
                }
            }

            Context 'Invoking with Ensure Absent and non existing Cluster' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksInGetWhenEnsureAbsentAndNonExistingCluster
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Get()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should retrieve the correct settings from the Resource properties and Ensure should be set to Absent' {
                    # Act
                    $result = $resource.Get()

                    # Assert
                    $result.Server | Should -Be $resourceProperties.Server
                    $result.Name | Should -Be $resourceProperties.Name
                    $result.Location | Should -Be $resourceProperties.Location
                    $result.DatacenterName | Should -Be $resourceProperties.DatacenterName
                    $result.DatacenterLocation | Should -Be $resourceProperties.DatacenterLocation
                    $result.Ensure | Should -Be 'Absent'
                    $result.DrsEnabled | Should -Be $resourceProperties.DrsEnabled
                    $result.DrsAutomationLevel | Should -Be $resourceProperties.DrsAutomationLevel
                    $result.DrsMigrationThreshold | Should -Be $resourceProperties.DrsMigrationThreshold
                    $result.DrsDistribution | Should -Be $resourceProperties.DrsDistribution
                    $result.MemoryLoadBalancing | Should -Be $resourceProperties.MemoryLoadBalancing
                    $result.CPUOverCommitment | Should -Be $resourceProperties.CPUOverCommitment
                }
            }

            Context 'Invoking with Ensure Absent and existing Cluster' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksInGetWhenEnsureAbsentAndExistingCluster
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Get()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should retrieve the correct settings from the Server and Ensure should be set to Present' {
                    # Act
                    $result = $resource.Get()

                    # Assert
                    $result.Server | Should -Be $resourceProperties.Server
                    $result.Name | Should -Be $script:cluster.Name
                    $result.Location | Should -Be $resourceProperties.Location
                    $result.DatacenterName | Should -Be $resourceProperties.DatacenterName
                    $result.DatacenterLocation | Should -Be $resourceProperties.DatacenterLocation
                    $result.Ensure | Should -Be 'Present'
                    $result.DrsEnabled | Should -Be $script:cluster.ExtensionData.ConfigurationEx.DrsConfig.Enabled
                    $result.DrsAutomationLevel | Should -Be $script:cluster.ExtensionData.ConfigurationEx.DrsConfig.DefaultVmBehavior.ToString()
                    $result.DrsMigrationThreshold | Should -Be $script:cluster.ExtensionData.ConfigurationEx.DrsConfig.VmotionRate
                    $result.DrsDistribution | Should -Be ($script:cluster.ExtensionData.ConfigurationEx.DrsConfig.Option[0]).Value
                    $result.MemoryLoadBalancing | Should -Be ($script:cluster.ExtensionData.ConfigurationEx.DrsConfig.Option[1]).Value
                    $result.CPUOverCommitment | Should -Be ($script:cluster.ExtensionData.ConfigurationEx.DrsConfig.Option[2]).Value
                }
            }
        }
    }
    finally {
        # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
        Invoke-TestCleanup -ModulePath $modulePath
    }
}
