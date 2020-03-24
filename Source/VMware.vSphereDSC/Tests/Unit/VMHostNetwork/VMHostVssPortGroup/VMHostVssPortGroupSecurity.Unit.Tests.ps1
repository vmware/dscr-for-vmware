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
        $resourceName = 'VMHostVssPortGroupSecurity'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
        . "$unitTestsFolder\TestHelpers\Mocks\VMHostVssPortGroupSecurityMocks.ps1"

        Describe 'VMHostVssPortGroupSecurity\Set' -Tag 'Set' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostVssPortGroupSecurity
            }

            Context 'Invoking with Security Policy Settings and Security Policy Settings Inherited are not passed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenSecurityPolicySettingsArePassedAndSecurityPolicySettingsInheritedAreNotPassed
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Set-SecurityPolicy mock once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Set-SecurityPolicy'
                        ParameterFilter = { $AllowPromiscuous -eq $script:constants.AllowPromiscuous -and `
                                            $ForgedTransmits -eq $script:constants.ForgedTransmits -and `
                                            $MacChanges -eq $script:constants.MacChanges }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Invoking with Security Policy Settings and Security Policy Settings Inherited set to $false' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenSecurityPolicySettingsArePassedAndSecurityPolicySettingsInheritedAreSetToFalse
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Set-SecurityPolicy mock once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Set-SecurityPolicy'
                        ParameterFilter = { $AllowPromiscuous -eq $script:constants.AllowPromiscuous -and $AllowPromiscuousInherited -eq $script:constants.AllowPromiscuousInherited -and `
                                            $ForgedTransmits -eq $script:constants.ForgedTransmits -and $ForgedTransmitsInherited -eq $script:constants.ForgedTransmitsInherited -and `
                                            $MacChanges -eq $script:constants.MacChanges -and $MacChangesInherited -eq $script:constants.MacChangesInherited }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Invoking with Security Policy Settings and Security Policy Settings Inherited set to $true' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenSecurityPolicySettingsArePassedAndSecurityPolicySettingsInheritedAreSetToTrue
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Set-SecurityPolicy mock once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Set-SecurityPolicy'
                        ParameterFilter = { $AllowPromiscuousInherited -eq !$script:constants.AllowPromiscuousInherited -and `
                                            $ForgedTransmitsInherited -eq !$script:constants.ForgedTransmitsInherited -and `
                                            $MacChangesInherited -eq !$script:constants.MacChangesInherited }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }
        }

        Describe 'VMHostVssPortGroupSecurity\Test' -Tag 'Test' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostVssPortGroupSecurity
            }

            Context 'Invoking with non matching Security Policy Settings' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTheSecurityPolicySettingsAreNonMatching
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when the Security Policy Settings are not equal' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'Invoking with matching Security Policy Settings' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTheSecurityPolicySettingsAreMatching
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when the Security Policy Settings are equal' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }
        }

        Describe 'VMHostVssPortGroupSecurity\Get' -Tag 'Get' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostVssPortGroupSecurity

                $resourceProperties = New-MocksInGet
                $resource = New-Object -TypeName $resourceName -Property $resourceProperties
            }

            It 'Should retrieve the correct settings from the Server' {
                # Act
                $result = $resource.Get()

                # Assert
                $result.Server | Should -Be $resourceProperties.Server
                $result.VMHostName | Should -Be $script:constants.VMHostName
                $result.Name | Should -Be $script:constants.VirtualPortGroupName
                $result.Ensure | Should -Be $resourceProperties.Ensure
                $result.AllowPromiscuous | Should -Be $script:constants.AllowPromiscuous
                $result.AllowPromiscuousInherited | Should -Be $script:constants.AllowPromiscuousInherited
                $result.ForgedTransmits | Should -Be $script:constants.ForgedTransmits
                $result.ForgedTransmitsInherited | Should -Be $script:constants.ForgedTransmitsInherited
                $result.MacChanges | Should -Be $script:constants.MacChanges
                $result.MacChangesInherited | Should -Be $script:constants.MacChangesInherited
            }
        }

    }
    finally {
        # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
        Invoke-TestCleanup -ModulePath $modulePath
    }
}
