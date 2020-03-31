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
        $resourceName = 'VMHostVssNic'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
        . "$unitTestsFolder\TestHelpers\Mocks\VMHostVssNicMocks.ps1"

        Describe 'VMHostVssNic\Set' -Tag 'Set' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostVssNic
            }

            Context 'Invoking with Ensure Present and non existing VMKernel Network Adapter' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsurePresentAndVMKernelNetworkAdapterDoesNotExist
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call the New-VMHostNetworkAdapter mock once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'New-VMHostNetworkAdapter'
                        ParameterFilter = { $VMHost -eq $script:vmHost -and $VirtualSwitch -eq $script:virtualSwitch }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Invoking with Ensure Present and existing VMKernel Network Adapter' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsurePresentAndVMKernelNetworkAdapterExists
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call the Set-VMHostNetworkAdapter mock once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Set-VMHostNetworkAdapter'
                        ParameterFilter = { $VirtualNic -eq $script:vmHostNetworkAdapter -and $IPv6Enabled -eq !$script:constants.VMKernelNetworkAdapterIPv6Enabled }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Invoking with Ensure Absent and non existing VMKernel Network Adapter' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureAbsentAndVMKernelNetworkAdapterDoesNotExist
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should not call the Remove-VMHostNetworkAdapter mock' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Remove-VMHostNetworkAdapter'
                        ParameterFilter = { $Nic -eq $script:vmHostNetworkAdapter }
                        Exactly = $true
                        Times = 0
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Invoking with Ensure Absent and existing VMKernel Network Adapter' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureAbsentAndVMKernelNetworkAdapterExists
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call the Remove-VMHostNetworkAdapter mock once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Remove-VMHostNetworkAdapter'
                        ParameterFilter = { $Nic -eq $script:vmHostNetworkAdapter }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }
        }

        Describe 'VMHostVssNic\Test' -Tag 'Test' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostVssNic
            }

            Context 'Invoking with Ensure Present and non existing VMKernel Network Adapter' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsurePresentAndVMKernelNetworkAdapterDoesNotExist
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should return $false when the VMKernel Network Adapter does not exist' {
                   # Act
                   $result = $resource.Test()

                   # Assert
                   $result | Should -Be $false
                }
            }

            Context 'Invoking with Ensure Present, existing VMKernel Network Adapter and matching settings' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsurePresentVMKernelNetworkAdapterExistsAndMatchingSettings
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should return $true when the VMKernel Network Adapter exists and the VMKernel Network Adapter settings are equal' {
                   # Act
                   $result = $resource.Test()

                   # Assert
                   $result | Should -Be $true
                }
            }

            Context 'Invoking with Ensure Present, existing VMKernel Network Adapter and non matching settings' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsurePresentVMKernelNetworkAdapterExistsAndNonMatchingSettings
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should return $false when the VMKernel Network Adapter exists and the VMKernel Network Adapter settings are not equal' {
                   # Act
                   $result = $resource.Test()

                   # Assert
                   $result | Should -Be $false
                }
            }

            Context 'Invoking with Ensure Absent and non existing VMKernel Network Adapter' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureAbsentAndVMKernelNetworkAdapterDoesNotExist
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should return $true when the VMKernel Network Adapter does not exist' {
                   # Act
                   $result = $resource.Test()

                   # Assert
                   $result | Should -Be $true
                }
            }

            Context 'Invoking with Ensure Absent and existing VMKernel Network Adapter' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureAbsentAndVMKernelNetworkAdapterExists
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should return $false when the VMKernel Network Adapter exists' {
                   # Act
                   $result = $resource.Test()

                   # Assert
                   $result | Should -Be $false
                }
            }
        }

        Describe 'VMHostVssNic\Get' -Tag 'Get' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostVssNic

                $resourceProperties = New-MocksInGet
                $resource = New-Object -TypeName $resourceName -Property $resourceProperties
            }

            It 'Should retrieve the correct settings from the Server' {
                # Act
                $result = $resource.Get()

                # Assert
                $result.VssName | Should -Be $script:constants.VirtualSwitchName
            }
        }
    }
    finally {
        # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
        Invoke-TestCleanup -ModulePath $modulePath
    }
}
