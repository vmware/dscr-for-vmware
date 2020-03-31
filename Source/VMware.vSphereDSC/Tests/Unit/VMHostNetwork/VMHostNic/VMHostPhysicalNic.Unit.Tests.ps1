<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

Using module '..\..\..\..\VMware.vSphereDSC.psm1'

$script:moduleName = 'VMware.vSphereDSC'

InModuleScope -ModuleName $script:moduleName {
    try {
        $unitTestsFolder = Join-Path (Join-Path (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase 'Tests') 'Unit'
        $modulePath = $env:PSModulePath
        $resourceName = 'VMHostPhysicalNic'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
        . "$unitTestsFolder\TestHelpers\Mocks\VMHostPhysicalNicMocks.ps1"

        Describe 'VMHostPhysicalNic\Set' -Tag 'Set' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostPhysicalNic
            }

            Context 'Invoking without specifying AutoNegotiate' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenAutoNegotiateIsNotPassed
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Set-VMHostNetworkAdapter mock once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Set-VMHostNetworkAdapter'
                        ParameterFilter = { $PhysicalNic -eq $script:physicalNetworkAdapter -and `
                                            $Duplex -eq $script:constants.FullDuplex -and `
                                            $BitRatePerSecMb -eq $script:constants.BitRatePerSecMb }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Invoking with AutoNegotiate set to $false' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenAutoNegotiateIsSetToFalse
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Set-VMHostNetworkAdapter mock once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Set-VMHostNetworkAdapter'
                        ParameterFilter = { $PhysicalNic -eq $script:physicalNetworkAdapter -and `
                                            $Duplex -eq $script:constants.FullDuplex -and `
                                            $BitRatePerSecMb -eq $script:constants.BitRatePerSecMb }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Invoking with AutoNegotiate set to $true' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenAutoNegotiateIsSetToTrue
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Set-VMHostNetworkAdapter mock once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Set-VMHostNetworkAdapter'
                        ParameterFilter = { $PhysicalNic -eq $script:physicalNetworkAdapter -and `
                                            $AutoNegotiate -eq $script:constants.AutoNegotiate }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }
        }

        Describe 'VMHostPhysicalNic\Test' -Tag 'Test' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostPhysicalNic
            }

            Context 'Invoking with Physical Network Adapter Full Duplex' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenThePhysicalNetworkAdapterIsWithFullDuplex
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when the Physical Network Adapter has Full Duplex and Half Duplex is passed' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'Invoking with Physical Network Adapter Half Duplex' {
                BeforeAll {
                    # Arrange
                    # The Duplex server value should be modified here before the mocking occurs.
                    $script:physicalNetworkAdapter.FullDuplex = $false

                    $resourceProperties = New-MocksWhenThePhysicalNetworkAdapterIsWithHalfDuplex
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when the Physical Network Adapter has Half Duplex and Full Duplex is passed' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }

                AfterAll {
                    # The Duplex server value should be set to its default value.
                    $script:physicalNetworkAdapter.FullDuplex = $true
                }
            }

            Context 'Invoking with AutoNegotiate set to $false' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksInTestWhenAutoNegotiateIsSetToFalse
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when the Physical Network Adapter speed/duplex settings are not configured automatically' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }

            Context 'Invoking with AutoNegotiate set to $true' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksInTestWhenAutoNegotiateIsSetToTrue
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when the Physical Network Adapter speed/duplex settings are not configured automatically' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }
        }

        Describe 'VMHostPhysicalNic\Get' -Tag 'Get' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostPhysicalNic
            }

            Context 'Invoking with Physical Network Adapter Full Duplex' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenThePhysicalNetworkAdapterIsWithFullDuplex
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
                    $result.VMHostName | Should -Be $script:constants.VMHostName
                    $result.Name | Should -Be $script:constants.PhysicalNetworkAdapterName
                    $result.Duplex | Should -Be $script:constants.FullDuplex
                    $result.BitRatePerSecMb | Should -Be $script:constants.BitRatePerSecMb
                    $result.AutoNegotiate | Should -BeNullOrEmpty
                }
            }

            Context 'Invoking with Physical Network Adapter Half Duplex' {
                BeforeAll {
                    # Arrange
                    # The Duplex server value should be modified here before the mocking occurs.
                    $script:physicalNetworkAdapter.FullDuplex = $false

                    $resourceProperties = New-MocksWhenThePhysicalNetworkAdapterIsWithHalfDuplex
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
                    $result.VMHostName | Should -Be $script:constants.VMHostName
                    $result.Name | Should -Be $script:constants.PhysicalNetworkAdapterName
                    $result.Duplex | Should -Be $script:constants.HalfDuplex
                    $result.BitRatePerSecMb | Should -Be $script:constants.BitRatePerSecMb
                    $result.AutoNegotiate | Should -BeNullOrEmpty
                }

                AfterAll {
                    # The Duplex server value should be set to its default value.
                    $script:physicalNetworkAdapter.FullDuplex = $true
                }
            }
        }
    }
    finally {
        # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
        Invoke-TestCleanup -ModulePath $modulePath
    }
}
