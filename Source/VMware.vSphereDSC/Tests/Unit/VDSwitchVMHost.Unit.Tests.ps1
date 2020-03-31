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
        $resourceName = 'VDSwitchVMHost'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
        . "$unitTestsFolder\TestHelpers\Mocks\VDSwitchVMHostMocks.ps1"

        Describe 'VDSwitchVMHost\Set' -Tag 'Set' {
            BeforeAll {
                # Arrange
                New-MocksForVDSwitchVMHost
            }

            Context 'Invoking with Ensure Present, two VMHosts and one of them is already added to the Distributed Switch' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsurePresentTwoVMHostsAndOneOfThemIsAlreadyAddedToTheDistributedSwitch
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Add-VDSwitchVMHost mock once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Add-VDSwitchVMHost'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $VDSwitch -eq $script:distributedSwitch -and
                            [System.Linq.Enumerable]::SequenceEqual($VMHost, [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]] @($script:vmHostRemovedFromDistributedSwitchOne))
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Invoking with Ensure Present and two VMHosts that are not added to the Distributed Switch' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsurePresentAndTwoVMHostsThatAreNotAddedToTheDistributedSwitch
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Add-VDSwitchVMHost mock once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Add-VDSwitchVMHost'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $VDSwitch -eq $script:distributedSwitch -and
                            [System.Linq.Enumerable]::SequenceEqual($VMHost, [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]] @($script:vmHostRemovedFromDistributedSwitchOne, $script:vmHostRemovedFromDistributedSwitchTwo))
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Invoking with Ensure Absent and two VMHosts and one of them is already removed from the Distributed Switch' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureAbsentTwoVMHostsAndOneOfThemIsAlreadyRemovedFromTheDistributedSwitch
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Remove-VDSwitchVMHost mock once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Remove-VDSwitchVMHost'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $VDSwitch -eq $script:distributedSwitch -and
                            [System.Linq.Enumerable]::SequenceEqual($VMHost, [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]] @($script:vmHostAddedToDistributedSwitchOne))
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Invoking with Ensure Absent and two VMHosts that are not removed from the Distributed Switch' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureAbsentAndTwoVMHostsThatAreNotRemovedFromTheDistributedSwitch
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Remove-VDSwitchVMHost mock once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Remove-VDSwitchVMHost'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $VDSwitch -eq $script:distributedSwitch -and
                            [System.Linq.Enumerable]::SequenceEqual($VMHost, [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]] @($script:vmHostAddedToDistributedSwitchOne, $script:vmHostAddedToDistributedSwitchTwo))
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }
        }

        Describe 'VDSwitchVMHost\Test' -Tag 'Test' {
            BeforeAll {
                # Arrange
                New-MocksForVDSwitchVMHost
            }

            Context 'Invoking with Ensure Present and VMHost that is not added to the Distributed Switch' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsurePresentAndVMHostThatIsNotAddedToTheDistributedSwitch
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when the VMHost is not added to the Distributed Switch' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'Invoking with Ensure Present and VMHost that is added to the Distributed Switch' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsurePresentAndVMHostThatIsAddedToTheDistributedSwitch
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when the VMHost is added to the Distributed Switch' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }

            Context 'Invoking with Ensure Absent and VMHost that is not removed from the Distributed Switch' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureAbsentAndVMHostThatIsNotRemovedFromTheDistributedSwitch
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when the VMHost is not removed from the Distributed Switch' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'Invoking with Ensure Absent and VMHost that is removed from the Distributed Switch' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureAbsentAndVMHostThatIsRemovedFromTheDistributedSwitch
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when the VMHost is removed from the Distributed Switch' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }
        }

        Describe 'VDSwitchVMHost\Get' -Tag 'Get' {
            BeforeAll {
                # Arrange
                New-MocksForVDSwitchVMHost

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
                $result.Server | Should -Be $script:viServer.Name
                $result.VdsName | Should -Be $script:distributedSwitch.Name
                $result.VMHostNames | Should -Be $resourceProperties.VMHostNames
                $result.Ensure | Should -Be $resourceProperties.Ensure
            }
        }
    }
    finally {
        # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
        Invoke-TestCleanup -ModulePath $modulePath
    }
}
