<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

using module VMware.vSphereDSC

$script:moduleName = 'VMware.vSphereDSC'

InModuleScope -ModuleName $script:moduleName {
    try {
        $unitTestsFolder = Join-Path (Join-Path (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase 'Tests') 'Unit'
        $modulePath = $env:PSModulePath
        $resourceName = 'VMHostVdsNic'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
        . "$unitTestsFolder\TestHelpers\Mocks\VMHostVdsNicMocks.ps1"

        Describe 'VMHostVdsNic\Set' -Tag 'Set' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostVdsNic
            }

            Context 'VMKernel Network Adapter does not exist, PortId is not passed and Ensure is Present' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenVMKernelNetworkAdapterDoesNotExistPortIdIsNotPassedAndEnsureIsPresent
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call the New-VMHostNetworkAdapter mock without the PortId once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'New-VMHostNetworkAdapter'
                        ParameterFilter = { $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and $VirtualSwitch -eq $script:distributedSwitch }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'VMKernel Network Adapter does not exist, PortId is passed and Ensure is Present' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenVMKernelNetworkAdapterDoesNotExistPortIdIsPassedAndEnsureIsPresent
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call the New-VMHostNetworkAdapter mock with the PortId once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'New-VMHostNetworkAdapter'
                        ParameterFilter = {
                            $VMHost -eq $script:vmHostAddedToDistributedSwitchOne -and
                            $VirtualSwitch -eq $script:distributedSwitch -and
                            $PortId -eq $script:constants.DistributedPortGroupPortId
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'VMKernel Network Adapter exists and Ensure is Present' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenVMKernelNetworkAdapterExistsAndEnsureIsPresent
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call the Set-VMHostNetworkAdapter mock with the VMKernel Network Adapter once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Set-VMHostNetworkAdapter'
                        ParameterFilter = { $VirtualNic -eq $script:vmHostNetworkAdapterConnectedToDistributedSwitch }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'VMKernel Network Adapter does not exist and Ensure is Absent' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenVMKernelNetworkAdapterDoesNotExistAndEnsureIsAbsent
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should not call the Remove-VMHostNetworkAdapter mock with the VMKernel Network Adapter' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Remove-VMHostNetworkAdapter'
                        ParameterFilter = { $Nic -eq $script:vmHostNetworkAdapterConnectedToDistributedSwitch }
                        Exactly = $true
                        Times = 0
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'VMKernel Network Adapter exists and Ensure is Absent' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenVMKernelNetworkAdapterExistsAndEnsureIsAbsent
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call the Remove-VMHostNetworkAdapter mock with the VMKernel Network Adapter once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Remove-VMHostNetworkAdapter'
                        ParameterFilter = { $Nic -eq $script:vmHostNetworkAdapterConnectedToDistributedSwitch }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }
        }

        Describe 'VMHostVdsNic\Test' -Tag 'Test' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostVdsNic
            }

            Context 'VMKernel Network Adapter does not exist and Ensure is Present' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenVMKernelNetworkAdapterDoesNotExistAndEnsureIsPresent
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should return $false when the VMKernel Network Adapter does not exist and Ensure is Present' {
                   # Act
                   $result = $resource.Test()

                   # Assert
                   $result | Should -Be $false
                }
            }

            Context 'VMKernel Network Adapter exists, the VMKernel Network Adapter settings are equal to the Server settings and Ensure is Present' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenVMKernelNetworkAdapterExistsAndEnsureIsPresent
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should return $true when the VMKernel Network Adapter exists, the passed VMKernel Network Adapter settings are equal to the Server settings and Ensure is Present' {
                   # Act
                   $result = $resource.Test()

                   # Assert
                   $result | Should -Be $true
                }
            }

            Context 'VMKernel Network Adapter exists, the VMKernel Network Adapter settings are not equal to the Server settings and Ensure is Present' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenVMKernelNetworkAdapterExistsTheVMKernelNetworkAdapterSettingsAreNotEqualToTheServerSettingsAndEnsureIsPresent
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should return $false when the VMKernel Network Adapter exists, the passed VMKernel Network Adapter settings are not equal to the Server settings and Ensure is Present' {
                   # Act
                   $result = $resource.Test()

                   # Assert
                   $result | Should -Be $false
                }
            }

            Context 'VMKernel Network Adapter does not exist and Ensure is Absent' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenVMKernelNetworkAdapterDoesNotExistAndEnsureIsAbsent
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should return $true when the VMKernel Network Adapter does not exist and Ensure is Absent' {
                   # Act
                   $result = $resource.Test()

                   # Assert
                   $result | Should -Be $true
                }
            }

            Context 'VMKernel Network Adapter exists and Ensure is Absent' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenVMKernelNetworkAdapterExistsAndEnsureIsAbsent
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should return $false when the VMKernel Network Adapter exists and Ensure is Absent' {
                   # Act
                   $result = $resource.Test()

                   # Assert
                   $result | Should -Be $false
                }
            }
        }

        Describe 'VMHostVdsNic\Get' -Tag 'Get' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostVdsNic
            }

            Context 'VMKernel Network Adapter does not exist' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenVMKernelNetworkAdapterDoesNotExist
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should retrieve the Distributed Switch name from the Server and the PortId from the Resource properties' {
                    # Act
                    $result = $resource.Get()

                    # Assert
                    $result.VdsName | Should -Be $script:distributedSwitch.Name
                    $result.PortId | Should -BeNullOrEmpty
                }
            }

            Context 'VMKernel Network Adapter exists' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenVMKernelNetworkAdapterExists
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should retrieve the Distributed Switch name and the PortId from the Server' {
                    # Act
                    $result = $resource.Get()

                    # Assert
                    $result.VdsName | Should -Be $script:distributedSwitch.Name
                    $result.PortId | Should -Be $script:constants.DistributedPortGroupPortId
                }
            }
        }
    }
    finally {
        # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
        Invoke-TestCleanup -ModulePath $modulePath
    }
}
