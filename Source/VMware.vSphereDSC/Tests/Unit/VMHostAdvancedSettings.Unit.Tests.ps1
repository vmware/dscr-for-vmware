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
        $resourceName = 'VMHostAdvancedSettings'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
        . "$unitTestsFolder\TestHelpers\Mocks\VMHostAdvancedSettingsMocks.ps1"

        Describe 'VMHostAdvancedSettings\Set' -Tag 'Set' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostAdvancedSettingsWithOptionManager
            }

            Context 'Invoking with hashtable where all Advanced Settings need to be updated' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksInSetWhenHashtableContainsAdvancedSettingsAndAllOfThemNeedToBeUpdated
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Update-VMHostAdvancedSettings mock once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Update-VMHostAdvancedSettings'
                        ParameterFilter = { $OptionManager -eq $script:optionManager -and $null -eq (Compare-Object -ReferenceObject $Options -DifferenceObject $script:allAdvancedOptionsToUpdate) }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Invoking with hashtable where not all Advanced Settings need to be updated' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksInSetWhenHashtableContainsAdvancedSettingsAndNotAllOfThemNeedToBeUpdated
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Update-VMHostAdvancedSettings mock once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Update-VMHostAdvancedSettings'
                        ParameterFilter = { $OptionManager -eq $script:optionManager -and $null -eq (Compare-Object -ReferenceObject $Options -DifferenceObject $script:notAllAdvancedOptionsToUpdate) }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Invoking with hashtable where no Advanced Settings need to be updated' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksInSetWhenHashtableContainsAdvancedSettingsAndNoneOfThemNeedToBeUpdated
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should not call the Update-VMHostAdvancedSettings mock' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Update-VMHostAdvancedSettings'
                        Exactly = $true
                        Times = 0
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }
        }

        Describe 'VMHostAdvancedSettings\Test' -Tag 'Test' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostAdvancedSettings
            }

            Context 'Invoking with hashtable where at least one Advanced Setting needs to be updated' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenHashtableContainsAtLeastOneAdvancedSettingThatNeedsToBeUpdated
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when at least one Advanced Setting needs to be updated' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'Invoking with hashtable where no Advanced Settings need to be updated' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenHashtableDoesNotContainAdvancedSettingsThatNeedToBeUpdated
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when no Advanced Settings need to be updated' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }
        }

        Describe 'VMHostAdvancedSettings\Get' -Tag 'Get' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostAdvancedSettings

                $resourceProperties = New-MocksInGet
                $resource = New-Object -TypeName $resourceName -Property $resourceProperties
            }

            It 'Should call all defined mocks' {
                # Act
                $resource.Get()

                # Assert
                Assert-VerifiableMock
            }

            It 'Should retrieve the correct settings from the Server' {
                # Act
                $result = $resource.Get()

                # Assert
                $result.Server | Should -Be $resourceProperties.Server
                $result.Name | Should -Be $script:constants.VMHostName
                $result.AdvancedSettings.Count | Should -Be $script:vmHostAdvancedSettings.Count

                foreach ($advancedSettingName in $result.AdvancedSettings.Keys) {
                    $vmHostAdvancedSetting = $script:vmHostAdvancedSettings | Where-Object { $_.Name -eq $advancedSettingName }
                    $result.AdvancedSettings[$advancedSettingName] | Should -Be $vmHostAdvancedSetting.Value.ToString()
                }
            }
        }
    }
    finally {
        # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
        Invoke-TestCleanup -ModulePath $modulePath
    }
}
