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
        $resourceName = 'VMHostPciPassthrough'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
        . "$unitTestsFolder\TestHelpers\Mocks\VMHostPciPassthroughMocks.ps1"

        Describe 'VMHostPciPassthrough\Set' -Tag 'Set' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostPciPassthrough
            }

            Context 'Invoking with PCI Device that is not existing' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenPCIDeviceIsNotExisting
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

                It 'Should throw the correct error when the PCI Device does not exist' {
                    # Act && Assert
                    { $resource.Set() } | Should -Throw "The specified PCI Device $($script:constants.PciDeviceId + $script:constants.PciDeviceId) does not exist for VMHost $($script:vmHost.Name)."
                }
            }

            Context 'Invoking with existing PCI Device that is not Passthrough capable' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenPCIDeviceIsExistingButIsNotPassthroughCapable
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

                It 'Should throw the correct error when the PCI Device exists but is not Passthrough capable' {
                    # Act && Assert
                    { $resource.Set() } | Should -Throw "Cannot configure PCI-Passthrough on incapable device $($script:constants.PciDeviceId).0."
                }
            }

            Context 'Invoking with existing PCI Device' {
                BeforeAll {
                    <#
                    The Product Line should be modified here to avoid infinite loop in the EnsureVMHostIsInDesiredState()
                    because when the Connection is a vCenter and the ESXi is restarted the VMHost State changes from 'Maintenance' to
                    'NotResponding' and again to 'Maintenance'. This behaviour cannot be mocked in the Tests.
                    #>
                    $script:viServer.ProductLine = $script:constants.ESXiProductId

                    # Arrange
                    $resourceProperties = New-MocksWhenPCIDeviceIsExisting
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Update-PassthruConfig mock once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Update-PassthruConfig'
                        ParameterFilter = { $VMHostPciPassthruSystem -eq $script:vmHostPciPassthruSystem -and $VMHostPciPassthruConfig -eq $script:vmHostPciPassthruConfig }
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
        }

        Describe 'VMHostPciPassthrough\Test' -Tag 'Test' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostPciPassthrough
            }

            Context 'Invoking with Enabled value not equal to PCI Device Passthrough Enabled value' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnabledValueIsNotEqualToPCIDevicePassthroughEnabledValue
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when Enabled value is not equal to PCI Device Passthrough Enabled value' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'Invoking with Enabled value equal to PCI Device Passthrough Enabled value' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnabledValueIsEqualToPCIDevicePassthroughEnabledValue
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when Enabled value is equal to PCI Device Passthrough Enabled value' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }
        }

        Describe 'VMHostPciPassthrough\Get' -Tag 'Get' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostPciPassthrough

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
                $result.RestartTimeoutMinutes | Should -Be $script:constants.DefaultVMHostRestartTimeoutMinutes
                $result.Id | Should -Be $script:constants.PciDeviceId
                $result.Enabled | Should -Be $script:constants.PciDeviceEnabled
            }
        }
    }
    finally {
        # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
        Invoke-TestCleanup -ModulePath $modulePath
    }
}
