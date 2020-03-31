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
        $resourceName = 'HACluster'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
        . "$unitTestsFolder\TestHelpers\Mocks\HAClusterMocks.ps1"

        Describe 'HACluster\Set' -Tag 'Set' {
            BeforeAll {
                # Arrange
                New-MocksForHACluster
            }

            Context 'Invoking with Ensure Present, non existing Cluster and no HA settings specified' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsurePresentNonExistingClusterAndNoHASettingsSpecified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the New-Cluster mock without HA settings specified once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'New-Cluster'
                        ParameterFilter = { $Server -eq $script:viServer -and $Name -eq $resourceProperties.Name -and $Location -eq $script:foundLocations[0] -and !$Confirm }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Invoking with Ensure Present, non existing Cluster and HA settings specified' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsurePresentNonExistingClusterAndHASettingsSpecified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the New-Cluster mock with HA settings specified once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'New-Cluster'
                        ParameterFilter = { $Server -eq $script:viServer -and $Name -eq $resourceProperties.Name -and $Location -eq $script:foundLocations[0] -and `
                                            !$Confirm -and $HAEnabled -eq $script:constants.HAEnabled -and $HAAdmissionControlEnabled -eq $script:constants.HAAdmissionControlEnabled -and `
                                            $HAFailoverLevel -eq $script:constants.HAFailoverLevel -and $HAIsolationResponse -eq $script:constants.HAIsolationResponse -and `
                                            $HARestartPriority -eq $script:constants.HARestartPriority }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Invoking with Ensure Present, existing Cluster and no HA settings specified' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsurePresentExistingClusterAndNoHASettingsSpecified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Set-Cluster mock without HA settings specified once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Set-Cluster'
                        ParameterFilter = { $Cluster -eq $script:cluster -and $Server -eq $script:viServer -and !$Confirm }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Invoking with Ensure Present, existing Cluster and HA settings specified' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsurePresentExistingClusterAndHASettingsSpecified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Set-Cluster mock with HA settings specified once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Set-Cluster'
                        ParameterFilter = { $Cluster -eq $script:cluster -and $Server -eq $script:viServer -and !$Confirm -and $HAEnabled -eq !$script:constants.HAEnabled }
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

                It 'Should call the Remove-Cluster mock once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Remove-Cluster'
                        ParameterFilter = { $Cluster -eq $script:cluster -and $Server -eq $script:viServer -and !$Confirm }
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

                It 'Should not call the Remove-Cluster mock' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Remove-Cluster'
                        ParameterFilter = { $Cluster -eq $script:cluster -and $Server -eq $script:viServer -and !$Confirm }
                        Exactly = $true
                        Times = 0
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }
        }

        Describe 'HACluster\Test' -Tag 'Test' {
            BeforeAll {
                # Arrange
                New-MocksForHACluster
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

                It 'Should return $true when the Cluster exists and the HA settings are equal' {
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

                It 'Should return $false when the Cluster exists and the HA settings are not equal' {
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

        Describe 'HACluster\Get' -Tag 'Get' {
            BeforeAll {
                # Arrange
                New-MocksForHACluster
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
                    $result.HAEnabled | Should -Be $resourceProperties.HAEnabled
                    $result.HAAdmissionControlEnabled | Should -Be $resourceProperties.HAAdmissionControlEnabled
                    $result.HAFailoverLevel | Should -Be $resourceProperties.HAFailoverLevel
                    $result.HAIsolationResponse | Should -Be $resourceProperties.HAIsolationResponse
                    $result.HARestartPriority | Should -Be $resourceProperties.HARestartPriority
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
                    $result.HAEnabled | Should -Be $script:cluster.HAEnabled
                    $result.HAAdmissionControlEnabled | Should -Be $script:cluster.HAAdmissionControlEnabled
                    $result.HAFailoverLevel | Should -Be $script:cluster.HAFailoverLevel
                    $result.HAIsolationResponse.ToString() | Should -Be $script:cluster.HAIsolationResponse.ToString()
                    $result.HARestartPriority.ToString() | Should -Be $script:cluster.HARestartPriority.ToString()
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
                    $result.HAEnabled | Should -Be $resourceProperties.HAEnabled
                    $result.HAAdmissionControlEnabled | Should -Be $resourceProperties.HAAdmissionControlEnabled
                    $result.HAFailoverLevel | Should -Be $resourceProperties.HAFailoverLevel
                    $result.HAIsolationResponse | Should -Be $resourceProperties.HAIsolationResponse
                    $result.HARestartPriority | Should -Be $resourceProperties.HARestartPriority
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
                    $result.HAEnabled | Should -Be $script:cluster.HAEnabled
                    $result.HAAdmissionControlEnabled | Should -Be $script:cluster.HAAdmissionControlEnabled
                    $result.HAFailoverLevel | Should -Be $script:cluster.HAFailoverLevel
                    $result.HAIsolationResponse.ToString() | Should -Be $script:cluster.HAIsolationResponse.ToString()
                    $result.HARestartPriority.ToString() | Should -Be $script:cluster.HARestartPriority.ToString()
                }
            }
        }
    }
    finally {
        # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
        Invoke-TestCleanup -ModulePath $modulePath
    }
}
