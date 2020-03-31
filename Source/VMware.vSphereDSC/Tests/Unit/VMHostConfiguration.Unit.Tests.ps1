<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

Using module '..\..\VMware.vSphereDSC.psm1'

$script:moduleName = 'VMware.vSphereDSC'

InModuleScope -ModuleName $script:moduleName {
    try {
        $unitTestsFolder = Join-Path (Join-Path (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase 'Tests') 'Unit'
        $modulePath = $env:PSModulePath
        $resourceName = 'VMHostConfiguration'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
        . "$unitTestsFolder\TestHelpers\Mocks\VMHostConfigurationMocks.ps1"

        Describe 'VMHostConfiguration\Set' -Tag 'Set' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostConfiguration
            }

            Context 'When the VMHost configuration needs to be modified and error occurs while retrieving the Time Zone' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTheVMHostConfigurationNeedsToBeModifiedAndErrorOccursWhileRetrievingTheTimeZone
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    try {
                        # Act
                        $resource.Set()
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw an exception with the correct message when error occurs while retrieving the Time Zone' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $resource.Set() } | Should -Throw "Could not retrieve Time Zone $($script:constants.VMHostUTCTimeZoneName) available on VMHost $($script:vmHostWithClusterWithManualDrsAutomationLevelAsParentAndSettingsToModify.Name). For more information: ScriptHalted"
                }
            }

            Context 'When the VMHost configuration needs to be modified and error occurs while retrieving the VM Swapfile Datastore' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTheVMHostConfigurationNeedsToBeModifiedAndErrorOccursWhileRetrievingTheVMSwapFileDatastore
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    try {
                        # Act
                        $resource.Set()
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw an exception with the correct message when error occurs while retrieving the VM Swapfile Datastore' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $resource.Set() } | Should -Throw "Could not retrieve Datastore $($script:constants.VMSwapfileDatastoreTwoName) from VMHost $($script:vmHostWithClusterWithManualDrsAutomationLevelAsParentAndSettingsToModify.Name). For more information: ScriptHalted"
                }
            }

            Context 'When the VMHost configuration needs to be modified and Drs Recommendation should be generated and applied' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTheVMHostConfigurationNeedsToBeModifiedAndDrsRecommendationShouldBeGeneratedAndApplied
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the Set-VMHost mock with the specified VMHost and configuration parameters to modify once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Set-VMHost'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $VMHost -eq $script:vmHostWithClusterWithManualDrsAutomationLevelAsParentAndSettingsToModify -and
                            $State -eq $script:constants.VMHostMaintenanceState -and
                            $Evacuate -eq $script:constants.EvacuateVMs -and
                            $VsanDataMigrationMode -eq $script:constants.VsanDataMigrationMode -and
                            $LicenseKey -eq $script:constants.VMHostLicenseKeyTwo -and
                            $TimeZone -eq $script:vmHostUTCTimeZone -and
                            $VMSwapfileDatastore -eq $script:vmSwapfileDatastoreTwo -and
                            $VMSwapfilePolicy -eq $script:constants.WithVMDatastoreVMSwapfilePolicy -and
                            $Profile -eq $script:hostProfile -and
                            $RunAsync -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When the VMHost configuration needs to be modified without generating a Drs Recommendation' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTheVMHostConfigurationNeedsToBeModifiedWithoutGeneratingADrsRecommendation
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the Set-VMHost mock with the specified VMHost and configuration parameters to modify once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Set-VMHost'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $VMHost -eq $script:vmHostWithClusterWithFullyAutomatedDrsAutomationLevelAsParentAndSettingsToModify -and
                            $State -eq $script:constants.VMHostMaintenanceState -and
                            $Evacuate -eq $script:constants.EvacuateVMs -and
                            $VsanDataMigrationMode -eq $script:constants.VsanDataMigrationMode -and
                            $LicenseKey -eq $script:constants.VMHostLicenseKeyTwo -and
                            $TimeZone -eq $script:vmHostUTCTimeZone -and
                            $VMSwapfileDatastore -eq $script:vmSwapfileDatastoreTwo -and
                            $VMSwapfilePolicy -eq $script:constants.WithVMDatastoreVMSwapfilePolicy -and
                            $Profile -eq $script:hostProfile -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When the CryptoKey of the VMHost needs to be modified' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTheCryptoKeyOfTheVMHostNeedsToBeModified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the Set-VMHost mock with the specified VMHost and Kms Cluster once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Set-VMHost'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $VMHost -eq $script:vmHostWithClusterWithFullyAutomatedDrsAutomationLevelAsParentAndSettingsToModify -and
                            $KmsCluster -eq $script:kmsCluster -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }
        }

        Describe 'VMHostConfiguration\Test' -Tag 'Test' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostConfiguration
            }

            Context 'When the VMHost configuration does not need to be modified' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTheVMHostConfigurationDoesNotNeedToBeModified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when the VMHost configuration does not need to be modified' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }

            Context 'When the VMHost configuration needs to be modified' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTheVMHostConfigurationNeedsToBeModified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when the VMHost configuration needs to be modified' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }
        }

        Describe 'VMHostConfiguration\Get' -Tag 'Get' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostConfiguration
            }

            Context 'When the Host Profile and Kms Cluster names are not specified' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTheHostProfileAndKmsClusterNamesAreNotSpecified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Get()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should retrieve and return the correct values' {
                    # Act
                    $result = $resource.Get()

                    # Assert
                    $result.Server | Should -Be $script:viServer.Name
                    $result.Name | Should -Be $script:vmHostWithoutSettingsToModify.Name
                    $result.State | Should -Be $script:vmHostWithoutSettingsToModify.ConnectionState.ToString()
                    $result.Evacuate | Should -Be $resourceProperties.Evacuate
                    $result.VsanDataMigrationMode | Should -Be $resourceProperties.VsanDataMigrationMode
                    $result.LicenseKey | Should -Be $script:vmHostWithoutSettingsToModify.LicenseKey
                    $result.TimeZoneName | Should -Be $script:vmHostWithoutSettingsToModify.TimeZone.Name
                    $result.VMSwapfileDatastoreName | Should -Be $script:vmHostWithoutSettingsToModify.VMSwapfileDatastore.Name
                    $result.VMSwapfilePolicy | Should -Be $script:vmHostWithoutSettingsToModify.VMSwapfilePolicy.ToString()
                    $result.HostProfileName | Should -BeNullOrEmpty
                    $result.KmsClusterName | Should -BeNullOrEmpty
                }
            }
        }
    }
    finally {
        # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
        Invoke-TestCleanup -ModulePath $modulePath
    }
}
