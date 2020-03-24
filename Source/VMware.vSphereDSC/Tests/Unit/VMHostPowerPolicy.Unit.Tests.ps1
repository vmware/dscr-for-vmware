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
        $resourceName = 'VMHostPowerPolicy'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
        . "$unitTestsFolder\TestHelpers\Mocks\VMHostPowerPolicyMocks.ps1"

        Describe 'VMHostPowerPolicy\Set' -Tag 'Set' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostPowerPolicy
            }

            Context 'Invoking with Balanced Power Policy and no Server errors' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenPowerPolicyIsBalancedAndNoServerErrors
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Update-PowerPolicy mock once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Update-PowerPolicy'
                        ParameterFilter = { $VMHostPowerSystem -eq $script:vmHostPowerSystem -and $PowerPolicy -eq $script:constants.PowerPolicy.Balanced }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Invoking with High Performance Power Policy and Power System Server error' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenPowerPolicyIsHighPerformanceAndPowerSystemServerError
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

                It 'Should throw the correct error when Power System Server error occurs' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $resource.Set() } | Should -Throw "Could not retrieve the Power System of VMHost $($script:vmHost.Name). For more information: ScriptHalted"
                }
            }

            Context 'Invoking with Custom Power Policy and Update Power Policy Server error' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenPowerPolicyIsCustomAndUpdatePowerPolicyServerError
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

                It 'Should throw the correct error when Update Power Policy Server error occurs' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $resource.Set() } | Should -Throw "The Power Policy of VMHost $($script:vmHost.Name) could not be updated: ScriptHalted"
                }
            }
        }

        Describe 'VMHostPowerPolicy\Test' -Tag 'Test' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostPowerPolicy
            }

            Context 'Invoking with Power Policy not equal to current Power Policy' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenDesiredPowerPolicyIsNotEqualToCurrentPowerPolicy
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when Desired Power Policy is not equal to current Power Policy' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'Invoking with Power Policy equal to current Power Policy' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenDesiredPowerPolicyIsEqualToCurrentPowerPolicy
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when Desired Power Policy is equal to current Power Policy' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }
        }

        Describe 'VMHostPowerPolicy\Get' -Tag 'Get' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostPowerPolicy

                $resourceProperties = New-VMHostPowerPolicyProperties
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

                # Here GetEnumerator() is needed because $script:constants.PowerPolicy is a hashtable and wtihout it you can't iterate over the Key-Value pairs.
                $powerPolicy = $script:constants.PowerPolicy.GetEnumerator() | Where-Object { $_.Value -eq $script:vmHost.ExtensionData.Config.PowerSystemInfo.CurrentPolicy.Key }
                $result.PowerPolicy | Should -Be $powerPolicy.Key
            }
        }
    }
    finally {
        # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
        Invoke-TestCleanup -ModulePath $modulePath
    }
}
