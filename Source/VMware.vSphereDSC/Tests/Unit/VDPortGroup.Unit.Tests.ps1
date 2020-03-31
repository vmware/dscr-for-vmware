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
        $resourceName = 'VDPortGroup'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
        . "$unitTestsFolder\TestHelpers\Mocks\VDPortGroupMocks.ps1"

        Describe 'VDPortGroup\Set' -Tag 'Set' {
            BeforeAll {
                # Arrange
                New-MocksForVDPortGroup
            }

            Context 'Distributed Port Group does not exist, Distributed Port Group settings are not passed and Ensure is Present' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenDistributedPortGroupDoesNotExistDistributedPortGroupSettingsAreNotPassedAndEnsureIsPresent
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the New-VDPortGroup mock without Distributed Port Group settings once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'New-VDPortGroup'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $Name -eq $script:constants.DistributedPortGroupName -and
                            $VDSwitch -eq $script:distributedSwitch -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Distributed Port Group does not exist, Distributed Port Group settings are passed and Ensure is Present' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenDistributedPortGroupDoesNotExistDistributedPortGroupSettingsArePassedAndEnsureIsPresent
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the New-VDPortGroup mock with Distributed Port Group settings once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'New-VDPortGroup'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $Name -eq $script:constants.DistributedPortGroupName -and
                            $VDSwitch -eq $script:distributedSwitch -and
                            $Notes -eq $script:constants.DistributedPortGroupNotes -and
                            $NumPorts -eq $script:constants.DistributedPortGroupNumPorts -and
                            $PortBinding -eq $script:constants.DistributedPortGroupStaticPortBinding -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Distributed Port Group does not exist, Reference Distributed Port Group is passed and Ensure is Present' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenDistributedPortGroupDoesNotExistReferenceDistributedPortGroupIsPassedAndEnsureIsPresent
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the New-VDPortGroup mock with the Reference Distributed Port Group once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'New-VDPortGroup'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $Name -eq $script:constants.DistributedPortGroupName -and
                            $VDSwitch -eq $script:distributedSwitch -and
                            $ReferencePortgroup -eq $script:constants.ReferenceDistributedPortGroupName -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Distributed Port Group exists, Distributed Port Group settings are passed and need to be updated and Ensure is Present' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenDistributedPortGroupExistsDistributedPortGroupSettingsArePassedAndNeedToBeUpdatedAndEnsureIsPresent
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Set-VDPortGroup mock with the Distributed Port Group settings that need to be updated once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Set-VDPortGroup'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $VDPortgroup -eq $script:distributedPortGroup -and
                            $NumPorts -eq ($script:constants.DistributedPortGroupNumPorts + $script:constants.DistributedPortGroupNumPorts) -and
                            $PortBinding -eq $script:constants.DistributedPortGroupDynamicPortBinding -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Distributed Port Group does not exist and Ensure is Absent' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksInSetWhenDistributedPortGroupDoesNotExistAndEnsureIsAbsent
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should not call the Remove-VDPortGroup mock with the Distributed Port Group' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Remove-VDPortGroup'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $VDPortgroup -eq $script:distributedPortGroup -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 0
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Distributed Port Group exists and Ensure is Absent' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksInSetWhenDistributedPortGroupExistsAndEnsureIsAbsent
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Remove-VDPortGroup mock with the Distributed Port Group once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Remove-VDPortGroup'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $VDPortgroup -eq $script:distributedPortGroup -and
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

        Describe 'VDPortGroup\Test' -Tag 'Test' {
            BeforeAll {
                # Arrange
                New-MocksForVDPortGroup
            }

            Context 'Distributed Port Group does not exist and Ensure is Present' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenDistributedPortGroupDoesNotExistAndEnsureIsPresent
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when the Distributed Port Group does not exist and Ensure is Present' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'Distributed Port Group exists, passed Distributed Port Group settings are equal to the Server settings and Ensure is Present' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenDistributedPortGroupExistsPassedDistributedPortGroupSettingsAreEqualToTheServerSettingsAndEnsureIsPresent
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when the Distributed Port Group exists, the passed Distributed Port Group settings are equal to the Server settings and Ensure is Present' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }

            Context 'Distributed Port Group exists, passed Distributed Port Group settings are not equal to the Server settings and Ensure is Present' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenDistributedPortGroupExistsPassedDistributedPortGroupSettingsAreNotEqualToTheServerSettingsAndEnsureIsPresent
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when the Distributed Port Group exists, the passed Distributed Port Group settings are not equal to the Server settings and Ensure is Present' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'Distributed Port Group does not exist and Ensure is Absent' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenDistributedPortGroupDoesNotExistAndEnsureIsAbsent
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when the Distributed Port Group does not exist and Ensure is Absent' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }

            Context 'Distributed Port Group exists and Ensure is Absent' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenDistributedPortGroupExistsAndEnsureIsAbsent
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when the Distributed Port Group exists and Ensure is Absent' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }
        }

        Describe 'VDPortGroup\Get' -Tag 'Get' {
            BeforeAll {
                # Arrange
                New-MocksForVDPortGroup
            }

            Context 'Distributed Port Group does not exist and Ensure is Present' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenDistributedPortGroupDoesNotExistAndEnsureIsPresent
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    # Act
                    $resource.Get()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should retrieve the correct settings from the Resource properties and Ensure should be Absent' {
                    # Act
                    $result = $resource.Get()

                    # Assert
                    $result.Server | Should -Be $script:viServer.Name
                    $result.Name | Should -Be $resourceProperties.Name
                    $result.VdsName | Should -Be $resourceProperties.VdsName
                    $result.Ensure | Should -Be 'Absent'
                    $result.Notes | Should -BeNullOrEmpty
                    $result.NumPorts | Should -Be $resourceProperties.NumPorts
                    $result.PortBinding | Should -Be 'Unset'
                    $result.ReferenceVDPortGroupName | Should -BeNullOrEmpty
                }
            }

            Context 'Distributed Port Group exists and Ensure is Present' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenDistributedPortGroupExistsAndEnsureIsPresent
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    # Act
                    $resource.Get()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should retrieve the correct settings from the Server and Ensure should be Present' {
                    # Act
                    $result = $resource.Get()

                    # Assert
                    $result.Server | Should -Be $script:viServer.Name
                    $result.Name | Should -Be $script:distributedPortGroup.Name
                    $result.VdsName | Should -Be $script:distributedPortGroup.VDSwitch.Name
                    $result.Ensure | Should -Be 'Present'
                    $result.Notes | Should -Be $script:distributedPortGroup.Notes
                    $result.NumPorts | Should -Be $script:distributedPortGroup.NumPorts
                    $result.PortBinding | Should -Be $script:distributedPortGroup.PortBinding
                    $result.ReferenceVDPortGroupName | Should -BeNullOrEmpty
                }
            }

            Context 'Distributed Port Group does not exist and Ensure is Absent' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenDistributedPortGroupDoesNotExistAndEnsureIsAbsent
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    # Act
                    $resource.Get()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should retrieve the correct settings from the Resource properties and Ensure should be Absent' {
                    # Act
                    $result = $resource.Get()

                    # Assert
                    $result.Server | Should -Be $script:viServer.Name
                    $result.Name | Should -Be $resourceProperties.Name
                    $result.VdsName | Should -Be $resourceProperties.VdsName
                    $result.Ensure | Should -Be 'Absent'
                    $result.Notes | Should -BeNullOrEmpty
                    $result.NumPorts | Should -Be $resourceProperties.NumPorts
                    $result.PortBinding | Should -Be 'Unset'
                    $result.ReferenceVDPortGroupName | Should -BeNullOrEmpty
                }
            }

            Context 'Distributed Port Group exists and Ensure is Absent' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenDistributedPortGroupExistsAndEnsureIsAbsent
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    # Act
                    $resource.Get()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should retrieve the correct settings from the Server and Ensure should be Present' {
                    # Act
                    $result = $resource.Get()

                    # Assert
                    $result.Server | Should -Be $script:viServer.Name
                    $result.Name | Should -Be $script:distributedPortGroup.Name
                    $result.VdsName | Should -Be $script:distributedPortGroup.VDSwitch.Name
                    $result.Ensure | Should -Be 'Present'
                    $result.Notes | Should -Be $script:distributedPortGroup.Notes
                    $result.NumPorts | Should -Be $script:distributedPortGroup.NumPorts
                    $result.PortBinding | Should -Be $script:distributedPortGroup.PortBinding
                    $result.ReferenceVDPortGroupName | Should -BeNullOrEmpty
                }
            }
        }
    }
    finally {
        # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
        Invoke-TestCleanup -ModulePath $modulePath
    }
}
