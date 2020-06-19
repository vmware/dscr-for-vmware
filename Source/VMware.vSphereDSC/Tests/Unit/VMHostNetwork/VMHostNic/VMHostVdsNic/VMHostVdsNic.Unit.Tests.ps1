<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

$script:PSModulePath = $env:PSModulePath
$script:ModuleName = 'VMware.vSphereDSC'

$script:UnitTestsPath = Join-Path (Join-Path (Get-Module -Name $script:ModuleName -ListAvailable).ModuleBase 'Tests') 'Unit'
. (Join-Path -Path (Join-Path -Path $script:UnitTestsPath -ChildPath 'TestHelpers') -ChildPath 'TestUtils.ps1')

Import-VMwareVSphereDSCModule

# Imports the mocked 'VMware.VimAutomation.Core' module in the current session before all tests are executed.
Invoke-TestSetup

try {
    InModuleScope -ModuleName $script:ModuleName {
        $script:DscResourceName = 'VMHostVdsNic'

        . (Join-Path -Path $PSScriptRoot -ChildPath 'VMHostVdsNic.Mocks.Data.ps1')
        . (Join-Path -Path $PSScriptRoot -ChildPath 'VMHostVdsNic.Mocks.ps1')

        Describe "$script:DscResourceName\Set" -Tag 'Set' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostVdsNicDscResource
            }

            Context 'When Ensure is Present and the VMKernel NIC exists' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksInSetWhenEnsureIsPresentAndTheVMKernelNICExists
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResource.Set()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the Set-VMHostNetworkAdapter mock with the specified VMKernel NIC once' {
                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Set-VMHostNetworkAdapter'
                        ParameterFilter = {
                            $VirtualNic -eq $script:VMKernelNIC
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'Context'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When Ensure is Absent and the VMKernel NIC does not exist' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksInSetWhenEnsureIsAbsentAndTheVMKernelNICDoesNotExist
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResource.Set()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should not invoke the Remove-VMHostNetworkAdapter mock' {
                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Remove-VMHostNetworkAdapter'
                        ParameterFilter = {
                            $Nic -eq $script:VMKernelNIC
                        }
                        Exactly = $true
                        Times = 0
                        Scope = 'Context'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When Ensure is Absent and the VMKernel NIC exists' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksInSetWhenEnsureIsAbsentAndTheVMKernelNICExists
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResource.Set()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the Remove-VMHostNetworkAdapter mock with the specified VMKernel NIC once' {
                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Remove-VMHostNetworkAdapter'
                        ParameterFilter = {
                            $Nic -eq $script:VMKernelNIC
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'Context'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }
        }

        Describe "$script:DscResourceName\Test" -Tag 'Test' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostVdsNicDscResource
            }

            Context 'When Ensure is Present, the VMKernel NIC exists and the VMKernel NIC settings should not be modified' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsPresentTheVMKernelNICExistsAndTheVMKernelNICSettingsShouldNotBeModified
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResourceTestMethodResult = $dscResource.Test()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when Ensure is Present, the VMKernel NIC exists and the VMKernel NIC settings should not be modified' {
                    # Assert
                    $dscResourceTestMethodResult | Should -BeTrue
                }
            }

            Context 'When Ensure is Present, the VMKernel NIC exists and the VMKernel NIC settings should be modified' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsPresentTheVMKernelNICExistsAndTheVMKernelNICSettingsShouldBeModified
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResourceTestMethodResult = $dscResource.Test()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when Ensure is Present, the VMKernel NIC exists and the VMKernel NIC settings should be modified' {
                    # Assert
                    $dscResourceTestMethodResult | Should -BeFalse
                }
            }

            Context 'When Ensure is Absent and the VMKernel NIC does not exist' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsAbsentAndTheVMKernelNICDoesNotExist
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResourceTestMethodResult = $dscResource.Test()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when Ensure is Absent and the VMKernel NIC does not exist' {
                    # Assert
                    $dscResourceTestMethodResult | Should -BeTrue
                }
            }

            Context 'When Ensure is Absent and the VMKernel NIC exists' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsAbsentAndTheVMKernelNICExists
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResourceTestMethodResult = $dscResource.Test()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when Ensure is Absent and the VMKernel NIC exists' {
                    # Assert
                    $dscResourceTestMethodResult | Should -BeFalse
                }
            }
        }

        Describe "$script:DscResourceName\Get" -Tag 'Get' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostVdsNicDscResource
            }

            Context 'When Ensure is Present and the VMKernel NIC exists' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsPresentTheVMKernelNICExistsAndTheVMKernelNICSettingsShouldNotBeModified
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResourceGetMethodResult = $dscResource.Get()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should retrieve and return the VMKernel NIC and VDSwitch names from the server' {
                    # Assert
                    $dscResourceGetMethodResult.VdsName | Should -Be $script:VDSwitch.Name
                    $dscResourceGetMethodResult.Name | Should -Be $script:VMKernelNIC.Name
                }
            }

            Context 'When Ensure is Absent and the VMKernel NIC does not exist' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsAbsentAndTheVMKernelNICDoesNotExist
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResourceGetMethodResult = $dscResource.Get()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should retrieve and return the VMKernel NIC and VDSwitch names from the DSC Resource properties' {
                    # Assert
                    $dscResourceGetMethodResult.VdsName | Should -Be $dscResourceProperties.VdsName
                    $dscResourceGetMethodResult.Name | Should -Be $dscResourceProperties.Name
                }
            }

            Context 'When Ensure is Absent and the VMKernel NIC exists' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsAbsentAndTheVMKernelNICExists
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResourceGetMethodResult = $dscResource.Get()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should retrieve and return the VMKernel NIC and VDSwitch names from the server' {
                    # Assert
                    $dscResourceGetMethodResult.VdsName | Should -Be $script:VDSwitch.Name
                    $dscResourceGetMethodResult.Name | Should -Be $script:VMKernelNIC.Name
                }
            }
        }
    }
}
finally {
    # Removes the mocked 'VMware.VimAutomation.Core' module from the current session after all tests have executed.
    Invoke-TestCleanup -ModulePath $script:PSModulePath
}
