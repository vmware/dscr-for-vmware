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
        $resourceName = 'VMHostPermission'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
        . "$unitTestsFolder\TestHelpers\Mocks\VMHostPermissionMocks.ps1"

        Describe 'VMHostPermission\Set' -Tag 'Set' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostPermission
            }

            Context 'When Ensure is Present, the Permission is not created and the Entity is a Datacenter' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentThePermissionIsNotCreatedAndTheEntityIsADatacenter
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the New-VIPermission mock with the specified Datacenter Entity, Principal and Role once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'New-VIPermission'
                        ParameterFilter = {
                            $Server -eq $script:esxiServer -and
                            $Entity -eq $script:datacenterEntity -and
                            $Principal -eq $script:principal -and
                            $Role -eq $script:vmHostRole -and
                            $Propagate -eq $script:constants.PropagatePermission -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When Ensure is Present, the Permission is not created and the Entity is a VMHost' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentThePermissionIsNotCreatedAndTheEntityIsAVMHost
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the New-VIPermission mock with the specified VMHost Entity, Principal and Role once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'New-VIPermission'
                        ParameterFilter = {
                            $Server -eq $script:esxiServer -and
                            $Entity -eq $script:vmHost -and
                            $Principal -eq $script:principal -and
                            $Role -eq $script:vmHostRole -and
                            $Propagate -eq $script:constants.PropagatePermission -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When Ensure is Present, the Permission is not created and the Entity is a Datastore' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentThePermissionIsNotCreatedAndTheEntityIsADatastore
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the New-VIPermission mock with the specified Datastore Entity, Principal and Role once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'New-VIPermission'
                        ParameterFilter = {
                            $Server -eq $script:esxiServer -and
                            $Entity -eq $script:datastoreEntity -and
                            $Principal -eq $script:principal -and
                            $Role -eq $script:vmHostRole -and
                            $Propagate -eq $script:constants.PropagatePermission -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When Ensure is Present, the Permission is not created and the Entity is a Resource Pool' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentThePermissionIsNotCreatedAndTheEntityIsAResourcePool
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the New-VIPermission mock with the specified Resource Pool Entity, Principal and Role once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'New-VIPermission'
                        ParameterFilter = {
                            $Server -eq $script:esxiServer -and
                            $Entity -eq $script:resourcePoolEntity -and
                            $Principal -eq $script:principal -and
                            $Role -eq $script:vmHostRole -and
                            $Propagate -eq $script:constants.PropagatePermission -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When Ensure is Present, the Permission is not created, the Entity is a VM and empty Entity location is passed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentThePermissionIsNotCreatedTheEntityIsAVMAndEmptyEntityLocationIsPassed
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the New-VIPermission mock with the specified VM Entity, Principal and Role once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'New-VIPermission'
                        ParameterFilter = {
                            $Server -eq $script:esxiServer -and
                            $Entity -eq $script:vmEntity -and
                            $Principal -eq $script:principal -and
                            $Role -eq $script:vmHostRole -and
                            $Propagate -eq $script:constants.PropagatePermission -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When Ensure is Present, the Permission is not created, the Entity is a VM and Entity location is one Resource Pool' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentThePermissionIsNotCreatedTheEntityIsAVMAndEntityLocationIsOneResourcePool
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the New-VIPermission mock with the specified VM Entity, Principal and Role once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'New-VIPermission'
                        ParameterFilter = {
                            $Server -eq $script:esxiServer -and
                            $Entity -eq $script:vmEntity -and
                            $Principal -eq $script:principal -and
                            $Role -eq $script:vmHostRole -and
                            $Propagate -eq $script:constants.PropagatePermission -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When Ensure is Present, the Permission is not created, the Entity is a VM and Entity location is one Resource Pool and one vApp' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentThePermissionIsNotCreatedTheEntityIsAVMAndEntityLocationIsOneResourcePoolAndOneVApp
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the New-VIPermission mock with the specified VM Entity, Principal and Role once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'New-VIPermission'
                        ParameterFilter = {
                            $Server -eq $script:esxiServer -and
                            $Entity -eq $script:vmEntity -and
                            $Principal -eq $script:principal -and
                            $Role -eq $script:vmHostRole -and
                            $Propagate -eq $script:constants.PropagatePermission -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When Ensure is Present and the Permission is already created' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksInSetWhenEnsureIsPresentAndThePermissionIsAlreadyCreated
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the Set-VIPermission mock with the specified Permission and Role once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Set-VIPermission'
                        ParameterFilter = {
                            $Server -eq $script:esxiServer -and
                            $Permission -eq $script:vmHostPermission -and
                            $Role -eq $script:vmHostRole -and
                            $Propagate -eq $script:constants.PropagatePermission -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When Ensure is Absent and the Permission is already removed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksInSetWhenEnsureIsAbsentAndThePermissionIsAlreadyRemoved
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should not invoke the Remove-VIPermission mock' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Remove-VIPermission'
                        ParameterFilter = {
                            $Permission -eq $script:vmHostPermission -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 0
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When Ensure is Absent and the Permission is not removed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksInSetWhenEnsureIsAbsentAndThePermissionIsNotRemoved
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the Remove-VIPermission mock with the specified Permission once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Remove-VIPermission'
                        ParameterFilter = {
                            $Permission -eq $script:vmHostPermission -and
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

        Describe 'VMHostPermission\Test' -Tag 'Test' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostPermission
            }

            Context 'When the Principal is part of a domain' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenThePrincipalIsPartOfADomain
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the Get-VIAccount mock with the specified domain and username once' {
                    # Act
                    $resource.Test()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Get-VIAccount'
                        ParameterFilter = {
                            $Server -eq $script:esxiServer -and
                            $Domain -eq $script:constants.DomainName -and
                            $User -and
                            $Id -eq $script:constants.PrincipalName
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When Ensure is Present and the Permission is not created' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentAndThePermissionIsNotCreated
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when Ensure is Present and the Permission is not created' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'When Ensure is Present, the Permission is already created and the desired Role and Propagate behaviour are different from the current Role and Propagate behaviour' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentThePermissionIsAlreadyCreatedAndTheDesiredRoleAndPropagateBehaviourAreDifferentFromTheCurrentRoleAndPropagateBehaviour
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when Ensure is Present, the Permission is already created and the desired Role and Propagate behaviour are different from the current Role and Propagate behaviour' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'When Ensure is Present, the Permission is already created and the desired Role and Propagate behaviour are the same as the current Role and Propagate behaviour' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentThePermissionIsAlreadyCreatedAndTheDesiredRoleAndPropagateBehaviourAreTheSameAsTheCurrentRoleAndPropagateBehaviour
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when Ensure is Present, the Permission is already created and the desired Role and Propagate behaviour are the same as the current Role and Propagate behaviour' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }

            Context 'When Ensure is Absent and the Permission is already removed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsAbsentAndThePermissionIsAlreadyRemoved
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when Ensure is Absent and the Permission is already removed' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }

            Context 'When Ensure is Absent and the Permission is not removed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsAbsentAndThePermissionIsNotRemoved
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when Ensure is Absent and the Permission is not removed' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }
        }

        Describe 'VMHostPermission\Get' -Tag 'Get' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostPermission
            }

            Context 'When Ensure is Present and the Permission is not created' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentAndThePermissionIsNotCreated
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
                    $result.Server | Should -Be $script:esxiServer.Name
                    $result.EntityName | Should -Be $resourceProperties.EntityName
                    $result.EntityLocation | Should -Be $resourceProperties.EntityLocation
                    $result.EntityType | Should -Be $resourceProperties.EntityType
                    $result.PrincipalName | Should -Be $resourceProperties.PrincipalName
                    $result.RoleName | Should -Be $resourceProperties.RoleName
                    $result.Ensure | Should -Be 'Absent'
                    $result.Propagate | Should -BeNullOrEmpty
                }
            }

            Context 'When Ensure is Present and the Permission is already created' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentAndThePermissionIsAlreadyCreated
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
                    $result.Server | Should -Be $script:esxiServer.Name
                    $result.EntityName | Should -Be $script:vmHostPermission.Entity.Name
                    $result.EntityLocation | Should -Be $resourceProperties.EntityLocation
                    $result.EntityType | Should -Be $resourceProperties.EntityType
                    $result.PrincipalName | Should -Be $script:vmHostPermission.Principal
                    $result.RoleName | Should -Be $script:vmHostPermission.Role
                    $result.Ensure | Should -Be 'Present'
                    $result.Propagate | Should -Be $script:vmHostPermission.Propagate
                }
            }

            Context 'When Ensure is Absent and the Permission is already removed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsAbsentAndThePermissionIsAlreadyRemoved
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
                    $result.Server | Should -Be $script:esxiServer.Name
                    $result.EntityName | Should -Be $resourceProperties.EntityName
                    $result.EntityLocation | Should -Be $resourceProperties.EntityLocation
                    $result.EntityType | Should -Be $resourceProperties.EntityType
                    $result.PrincipalName | Should -Be $resourceProperties.PrincipalName
                    $result.RoleName | Should -Be $resourceProperties.RoleName
                    $result.Ensure | Should -Be 'Absent'
                    $result.Propagate | Should -BeNullOrEmpty
                }
            }

            Context 'When Ensure is Absent and the Permission is not removed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsAbsentAndThePermissionIsNotRemoved
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
                    $result.Server | Should -Be $script:esxiServer.Name
                    $result.EntityName | Should -Be $script:vmHostPermission.Entity.Name
                    $result.EntityLocation | Should -Be $resourceProperties.EntityLocation
                    $result.EntityType | Should -Be $resourceProperties.EntityType
                    $result.PrincipalName | Should -Be $script:vmHostPermission.Principal
                    $result.RoleName | Should -Be $script:vmHostPermission.Role
                    $result.Ensure | Should -Be 'Present'
                    $result.Propagate | Should -Be $script:vmHostPermission.Propagate
                }
            }
        }
    }
    finally {
        # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
        Invoke-TestCleanup -ModulePath $modulePath
    }
}
