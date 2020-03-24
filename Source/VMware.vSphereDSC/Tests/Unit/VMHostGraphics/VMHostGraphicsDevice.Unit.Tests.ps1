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
        $resourceName = 'VMHostGraphicsDevice'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
        . "$unitTestsFolder\TestHelpers\Mocks\VMHostGraphicsDeviceMocks.ps1"

        Describe 'VMHostGraphicsDevice\Set' -Tag 'Set' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostGraphicsDevice

                <#
                The Product Line should be modified here to avoid infinite loop in the EnsureVMHostIsInDesiredState()
                because when the Connection is a vCenter and the ESXi is restarted the VMHost State changes from 'Maintenance' to
                'NotResponding' and again to 'Maintenance'. This behaviour cannot be mocked in the Tests.
                #>
                $script:viServer.ProductLine = $script:constants.ESXiProductId

                # Arrange
                $resourceProperties = New-MocksInSet
                $resource = New-Object -TypeName $resourceName -Property $resourceProperties
            }

            It 'Should call all defined mocks' {
                # Act
                $resource.Set()

                # Assert
                Assert-VerifiableMock
            }

            It 'Should call the Update-GraphicsConfig mock once' {
                # Act
                $resource.Set()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Update-GraphicsConfig'
                    ParameterFilter = { $VMHostGraphicsManager -eq $script:vmHostGraphicsManager -and $VMHostGraphicsConfig -eq $script:vmHostGraphicsConfigWithGraphicsDevice }
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Restart-VMHost mock once' {
                # Act
                $resource.Set()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Restart-VMHost'
                    ParameterFilter = { $Server -eq $script:viServer -and $VMHost -eq $script:vmHost -and !$Confirm }
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            AfterAll {
                # The Product Line should be set to its default value after all Tests in this Context block.
                $script:viServer.ProductLine = $script:constants.vCenterProductId
            }
        }

        Describe 'VMHostGraphicsDevice\Test' -Tag 'Test' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostGraphicsDevice
            }

            Context 'Invoking with Graphics Device that is not existing' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenGraphicsDeviceIsNotExisting
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    try {
                        # Act
                        $resource.Test()
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw the correct error when the Graphics Device does not exist' {
                    # Act && Assert
                    { $resource.Test() } | Should -Throw "Device $($script:constants.GraphicsDeviceId + $script:constants.GraphicsDeviceId) was not found in the available Graphics devices."
                }
            }

            Context 'Invoking with Graphics Device Type value not equal to Graphics Configuration Graphics Device Type value' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenGraphicsDeviceTypeValueIsNotEqualToGraphicsConfigurationGraphicsDeviceTypeValue
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when Graphics Device Type value is not equal to Graphics Configuration Graphics Device Type value' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'Invoking with Graphics Device Type value equal to Graphics Configuration Graphics Device Type value' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenGraphicsDeviceTypeValueIsEqualToGraphicsConfigurationGraphicsDeviceTypeValue
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when Graphics Device Type value is equal to Graphics Configuration Graphics Device Type value' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }
        }

        Describe 'VMHostGraphicsDevice\Get' -Tag 'Get' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostGraphicsDevice
            }

            Context 'Invoking with Graphics Device that is not existing' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenGraphicsDeviceIsNotExisting
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    try {
                        # Act
                        $resource.Get()
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw the correct error when the Graphics Device does not exist' {
                    # Act && Assert
                    { $resource.Get() } | Should -Throw "Device $($script:constants.GraphicsDeviceId + $script:constants.GraphicsDeviceId) was not found in the available Graphics devices."
                }
            }

            Context 'Invoking with existing Graphics Device' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenGraphicsDeviceIsExisting
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
                    $result.RestartTimeoutMinutes | Should -Be $script:constants.DefaultVMHostRestartTimeoutMinutes
                    $result.Id | Should -Be $script:constants.GraphicsDeviceId
                    $result.GraphicsType | Should -Be $script:constants.DefaultGraphicsType
                }
            }
        }
    }
    finally {
        # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
        Invoke-TestCleanup -ModulePath $modulePath
    }
}
