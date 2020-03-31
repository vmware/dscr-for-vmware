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
        $resourceName = 'VMHostCache'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
        . "$unitTestsFolder\TestHelpers\Mocks\VMHostCacheMocks.ps1"

        Describe 'VMHostCache\Set' -Tag 'Set' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostCache
            }

            Context 'Invoking with negative Swap Size' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenPassedSwapSizeIsNegative
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    try {
                        # Act
                        $resource.Set()
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw the correct error when the Swap Size is negative' {
                    # Act && Assert
                    { $resource.Set() } | Should -Throw "The passed Swap Size $($script:constants.NegativeSwapSize) is less than zero."
                }
            }

            Context 'Invoking with Swap Size bigger than Datastore Free Space' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenPassedSwapSizeIsBiggerThanDatastoreFreeSpace
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    try {
                        # Act
                        $resource.Set()
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw the correct error when the Swap Size is bigger than the Datastore Free Space' {
                    # Act && Assert
                    { $resource.Set() } | Should -Throw "The passed Swap Size $($script:constants.OverflowingSwapSize) is larger than the free space of the Datastore $($script:datastore.Name)."
                }
            }

            Context 'Invoking with Swap Size that results in an Error' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenUpdateCacheConfigurationResultsInError
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    try {
                        # Act
                        $resource.Set()
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw the correct error when the Update of the Cache Configuration results in an error' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $resource.Set() } | Should -Throw "An error occured while updating Cache Configuration for VMHost $($script:vmHost.Name). For more information: ScriptHalted"
                }
            }

            Context 'Invoking with Swap Size that results in a Success' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenUpdateCacheConfigurationResultsInSuccess
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Update-HostCacheConfiguration mock once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Update-HostCacheConfiguration'
                        ParameterFilter = { $VMHostCacheConfigurationManager -eq $script:vmHostCacheConfigurationManager -and $Spec -eq $script:hostCacheConfigurationSpec }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }

                It 'Should call the Get-Task mock once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Get-Task'
                        ParameterFilter = { $Server -eq $script:viServer -and $Id -eq $script:hostCacheConfigurationResult }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }

                It 'Should call the Wait-Task mock once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Wait-Task'
                        ParameterFilter = { $Task -eq $script:hostCacheConfigurationSuccessTask }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }
        }

        Describe 'VMHostCache\Test' -Tag 'Test' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostCache
            }

            Context 'Invoking with Swap Size not equal to current Swap Size' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenSwapSizeIsNotEqualToCurrentSwapSize
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when the Swap Size is not equal to the current Swap Size' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'Invoking with Swap Size equal to current Swap Size' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenSwapSizeIsEqualToCurrentSwapSize
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when the Swap Size is equal to the current Swap Size' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }
        }

        Describe 'VMHostCache\Get' -Tag 'Get' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostCache

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
                $result.DatastoreName | Should -Be $script:datastore.Name
                $result.SwapSizeGB | Should -Be $script:constants.SwapSizeGB
            }
        }
    }
    finally {
        # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
        Invoke-TestCleanup -ModulePath $modulePath
    }
}
