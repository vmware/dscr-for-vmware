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
        $resourceName = 'VMHostAuthentication'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
        . "$unitTestsFolder\TestHelpers\Mocks\VMHostAuthenticationMocks.ps1"

        Describe 'VMHostAuthentication\Set' -Tag 'Set' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostAuthentication
            }

            Context 'When Domain Action is Join and error occurs while including the VMHost to the domain' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenDomainActionIsJoinAndErrorOccursWhileIncludingTheVMHostToTheDomain
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    try {
                        # Act
                        $resource.Set()
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw an exception with the correct message when Domain Action is Join and error occurs while including the VMHost to the domain' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $resource.Set() } | Should -Throw "Could not include VMHost $($script:vmHost.Name) in domain $($resourceProperties.DomainName). For more information: ScriptHalted"
                }
            }

            Context 'When Domain Action is Join' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenDomainActionIsJoin
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the Set-VMHostAuthentication mock with the specified domain and credentials once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Set-VMHostAuthentication'
                        ParameterFilter = {
                            $VMHostAuthentication -eq $script:vmHostAuthenticationInfoWithoutDomain -and
                            $Domain -eq $resourceProperties.DomainName -and
                            $Credential -eq $resourceProperties.DomainCredential -and
                            $JoinDomain -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When Domain Action is Leave and error occurs while excluding the VMHost from the domain' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenDomainActionIsLeaveAndErrorOccursWhileExcludingTheVMHostFromTheDomain
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    try {
                        # Act
                        $resource.Set()
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw an exception with the correct message when Domain Action is Leave and error occurs while excluding the VMHost from the domain' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $resource.Set() } | Should -Throw "Could not exclude VMHost $($script:vmHost.Name) from domain $($resourceProperties.DomainName). For more information: ScriptHalted"
                }
            }

            Context 'When Domain Action is Leave' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenDomainActionIsLeave
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the Set-VMHostAuthentication mock with the LeaveDomain and Force parameters once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Set-VMHostAuthentication'
                        ParameterFilter = {
                            $VMHostAuthentication -eq $script:vmHostAuthenticationInfoWithDomain -and
                            $LeaveDomain -and
                            $Force -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }
        }

        Describe 'VMHostAuthentication\Test' -Tag 'Test' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostAuthentication
            }

            Context 'When error occurs while retrieving the VMHost Authentication info' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenErrorOccursWhileRetrievingTheVMHostAuthenticationInfo
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    try {
                        # Act
                        $resource.Test()
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw an exception with the correct message when error occurs while retrieving the VMHost Authentication info' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $resource.Test() } | Should -Throw "Could not retrieve Authentication information for VMHost $($script:vmHost.Name). For more information: ScriptHalted"
                }
            }

            Context 'When Domain Action is Join and the VMHost is not included in the specified domain' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenDomainActionIsJoinAndTheVMHostIsNotIncludedInTheSpecifiedDomain
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when Domain Action is Join and the VMHost is not included in the specified domain' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'When Domain Action is Join and the VMHost is included in the specified domain' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenDomainActionIsJoinAndTheVMHostIsIncludedInTheSpecifiedDomain
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when Domain Action is Join and the VMHost is included in the specified domain' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }

            Context 'When Domain Action is Leave and the VMHost is not excluded from the specified domain' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenDomainActionIsLeaveAndTheVMHostIsNotExcludedFromTheSpecifiedDomain
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when Domain Action is Leave and the VMHost is not excluded from the specified domain' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'When Domain Action is Leave and the VMHost is excluded from the specified domain' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenDomainActionIsLeaveAndTheVMHostIsExcludedFromTheSpecifiedDomain
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when Domain Action is Leave and the VMHost is excluded from the specified domain' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }
        }

        Describe 'VMHostAuthentication\Get' -Tag 'Get' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostAuthentication
            }

            Context 'When the VMHost is included in the specified domain' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTheVMHostIsIncludedInTheSpecifiedDomain
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Get()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return the correct values' {
                    # Act
                    $result = $resource.Get()

                    # Assert
                    $result.Server | Should -Be $script:viServer.Name
                    $result.Name | Should -Be $script:vmHost.Name
                    $result.DomainName | Should -Be $script:vmHostAuthenticationInfoWithDomain.Domain
                    $result.DomainAction | Should -Be $script:constants.DomainActionJoin
                }
            }

            Context 'When the VMHost is excluded from the specified domain' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTheVMHostIsExcludedFromTheSpecifiedDomain
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Get()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return the correct values' {
                    # Act
                    $result = $resource.Get()

                    # Assert
                    $result.Server | Should -Be $script:viServer.Name
                    $result.Name | Should -Be $script:vmHost.Name
                    $result.DomainName | Should -Be $resourceProperties.DomainName
                    $result.DomainAction | Should -Be $script:constants.DomainActionLeave
                }
            }
        }
    }
    finally {
        # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
        Invoke-TestCleanup -ModulePath $modulePath
    }
}
