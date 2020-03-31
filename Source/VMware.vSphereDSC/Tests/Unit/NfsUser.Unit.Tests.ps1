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
        $resourceName = 'NfsUser'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
        . "$unitTestsFolder\TestHelpers\Mocks\NfsUserMocks.ps1"

        Describe 'NfsUser\Set' -Tag 'Set' {
            BeforeAll {
                # Arrange
                New-MocksForNfsUser
            }

            Context 'When Ensure is Present, the Nfs User is not created and error occurs while creating the Nfs User' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentTheNfsUserIsNotCreatedAndErrorOccursWhileCreatingTheNfsUser
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

                It 'Should throw an exception with the correct message when error occurs while creating the Nfs User' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $resource.Set() } | Should -Throw "Could not create Nfs User $($script:constants.NfsUsername) on VMHost $($script:vmHost.Name). For more information: ScriptHalted"
                }
            }

            Context 'When Ensure is Present, the Nfs User is not created and no error occurs while creating the Nfs User' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentTheNfsUserIsNotCreatedAndNoErrorOccursWhileCreatingTheNfsUser
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the New-NfsUser mock with the specified username and password once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'New-NfsUser'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $Username -eq $script:constants.NfsUsername -and
                            $VMHost -eq $script:vmHost -and
                            $Password -eq $script:constants.NfsUserPasswordOne -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When Ensure is Present, the Nfs User is already created and error occurs while changing the password of the Nfs User' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentTheNfsUserIsAlreadyCreatedAndErrorOccursWhileChangingThePasswordOfTheNfsUser
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

                It 'Should throw an exception with the correct message when error occurs while changing the password of the Nfs User' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $resource.Set() } | Should -Throw "Could not change Nfs User $($script:constants.NfsUsername) password on VMHost $($script:vmHost.Name). For more information: ScriptHalted"
                }
            }

            Context 'When Ensure is Present, the Nfs User is already created and the password should be changed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentTheNfsUserIsAlreadyCreatedAndThePasswordShouldBeChanged
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the Set-NfsUser mock with the specified Nfs User and password once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Set-NfsUser'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $NfsUser -eq $script:nfsUser -and
                            $Password -eq $script:constants.NfsUserPasswordTwo -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When Ensure is Absent and the Nfs User is already removed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsAbsentAndTheNfsUserIsAlreadyRemoved
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should not invoke the Remove-NfsUser mock' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Remove-NfsUser'
                        ParameterFilter = {
                            $NfsUser -eq $script:nfsUser -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 0
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When Ensure is Absent, the Nfs User is not removed and error occurs while removing the Nfs User' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsAbsentTheNfsUserIsNotRemovedAndErrorOccursWhileRemovingTheNfsUser
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

                It 'Should throw an exception with the correct message when error occurs while removing the Nfs User' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $resource.Set() } | Should -Throw "Could not remove Nfs User $($script:constants.NfsUsername) from VMHost $($script:vmHost.Name). For more information: ScriptHalted"
                }
            }

            Context 'When Ensure is Absent, the Nfs User is not removed and no error occurs while removing the Nfs User' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsAbsentTheNfsUserIsNotRemovedAndNoErrorOccursWhileRemovingTheNfsUser
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the Remove-NfsUser mock with the specified Nfs User once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Remove-NfsUser'
                        ParameterFilter = {
                            $NfsUser -eq $script:nfsUser -and
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

        Describe 'NfsUser\Test' -Tag 'Test' {
            BeforeAll {
                # Arrange
                New-MocksForNfsUser
            }

            Context 'When Ensure is Present and the Nfs User is not created' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentAndTheNfsUserIsNotCreated
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when Ensure is Present and the Nfs User is not created' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'When Ensure is Present, the Nfs User is already created and Force property is specified' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentTheNfsUserIsAlreadyCreatedAndForcePropertyIsSpecified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when Ensure is Present, the Nfs User is already created and Force property is specified' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'When Ensure is Present, the Nfs User is already created and Force property is not specified' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentTheNfsUserIsAlreadyCreatedAndForcePropertyIsNotSpecified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when Ensure is Present, the Nfs User is already created and Force property is not specified' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }

            Context 'When Ensure is Absent and the Nfs User is already removed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsAbsentAndTheNfsUserIsAlreadyRemoved
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when Ensure is Absent and the Nfs User is already removed' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }

            Context 'When Ensure is Absent and the Nfs User is not removed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsAbsentAndTheNfsUserIsNotRemoved
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when Ensure is Absent and the Nfs User is not removed' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }
        }

        Describe 'NfsUser\Get' -Tag 'Get' {
            BeforeAll {
                # Arrange
                New-MocksForNfsUser
            }

            Context 'When Ensure is Present and the Nfs User is not created' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentAndTheNfsUserIsNotCreated
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Get()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should retrieve and return the correct values from the Resource properties' {
                    # Act
                    $result = $resource.Get()

                    # Assert
                    $result.Server | Should -Be $script:viServer.Name
                    $result.VMHostName | Should -Be $script:vmHost.Name
                    $result.Name | Should -Be $resourceProperties.Name
                    $result.Ensure | Should -Be 'Absent'
                    $result.Force | Should -Be $resourceProperties.Force
                }
            }

            Context 'When Ensure is Present and the Nfs User is already created' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentTheNfsUserIsAlreadyCreatedAndForcePropertyIsSpecified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Get()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should retrieve and return the correct values from the server' {
                    # Act
                    $result = $resource.Get()

                    # Assert
                    $result.Server | Should -Be $script:viServer.Name
                    $result.VMHostName | Should -Be $script:vmHost.Name
                    $result.Name | Should -Be $script:nfsUser.Username
                    $result.Ensure | Should -Be 'Present'
                    $result.Force | Should -Be $resourceProperties.Force
                }
            }

            Context 'When Ensure is Absent and the Nfs User is already removed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsAbsentAndTheNfsUserIsAlreadyRemoved
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Get()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should retrieve and return the correct values from the Resource properties' {
                    # Act
                    $result = $resource.Get()

                    # Assert
                    $result.Server | Should -Be $script:viServer.Name
                    $result.VMHostName | Should -Be $script:vmHost.Name
                    $result.Name | Should -Be $resourceProperties.Name
                    $result.Ensure | Should -Be 'Absent'
                    $result.Force | Should -Be $resourceProperties.Force
                }
            }

            Context 'When Ensure is Absent and the Nfs User is not removed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsAbsentAndTheNfsUserIsNotRemoved
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Get()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should retrieve and return the correct values from the server' {
                    # Act
                    $result = $resource.Get()

                    # Assert
                    $result.Server | Should -Be $script:viServer.Name
                    $result.VMHostName | Should -Be $script:vmHost.Name
                    $result.Name | Should -Be $script:nfsUser.Username
                    $result.Ensure | Should -Be 'Present'
                    $result.Force | Should -Be $resourceProperties.Force
                }
            }
        }
    }
    finally {
        # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
        Invoke-TestCleanup -ModulePath $modulePath
    }
}
