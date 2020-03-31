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
        $resourceName = 'vCenterVMHost'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
        . "$unitTestsFolder\TestHelpers\Mocks\vCenterVMHostMocks.ps1"

        Describe 'vCenterVMHost\Set' -Tag 'Set' {
            BeforeAll {
                # Arrange
                New-MocksForvCenterVMHostInSet
            }

            Context 'When Ensure is Present, the VMHost is not added to the vCenter and error occurs while adding the VMHost to the vCenter' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentTheVMHostIsNotAddedToThevCenterAndErrorOccursWhileAddingTheVMHostToThevCenter
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

                It 'Should throw an exception with the correct message when error occurs while adding the VMHost to the vCenter' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $resource.Set() } | Should -Throw "Could not add VMHost $($script:constants.VMHostName) to vCenter $($script:viServer.Name) and location $($script:datacenterHostFolder.Name). For more information: ScriptHalted"
                }
            }

            Context 'When Ensure is Present, the VMHost is not added to the vCenter and no error occurs while adding the VMHost to the vCenter' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentTheVMHostIsNotAddedToThevCenterAndNoErrorOccursWhileAddingTheVMHostToThevCenter
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the Add-VMHost mock with the specified VMHost and credential once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Add-VMHost'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $Name -eq $script:constants.VMHostName -and
                            $Location -eq $script:datacenterHostFolder -and
                            $Credential -eq $script:credential -and
                            $Port -eq $script:constants.VMHostPort -and
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

            Context 'When Ensure is Present, the VMHost is already added to the vCenter and it is on the desired location' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentTheVMHostIsAlreadyAddedToThevCenterAndItIsOnTheDesiredLocation
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should not invoke the Move-VMHost mock' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Move-VMHost'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $VMHost -eq $script:vmHostWithDatacenterHostFolderAsParent -and
                            $Destination -eq $script:datacenterHostFolder -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 0
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When Ensure is Present, the VMHost is already added to the vCenter and error occurs while moving the VMHost to the desired location' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentTheVMHostIsAlreadyAddedToThevCenterAndErrorOccursWhileMovingTheVMHostToTheDesiredLocation
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

                It 'Should throw an exception with the correct message when error occurs while moving the VMHost to the desired location' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $resource.Set() } | Should -Throw "Could not move VMHost $($script:vmHostWithInventoryItemLocationItemOneAsParent.Name) to location $($script:datacenterHostFolder.Name) on vCenter $($script:viServer.Name). For more information: ScriptHalted"
                }
            }

            Context 'When Ensure is Present, the VMHost is already added to the vCenter and no error occurs while moving the VMHost to the desired location' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentTheVMHostIsAlreadyAddedToThevCenterAndNoErrorOccursWhileMovingTheVMHostToTheDesiredLocation
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the Move-VMHost mock with the specified VMHost and destination location once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Move-VMHost'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $VMHost -eq $script:vmHostWithInventoryItemLocationItemOneAsParent -and
                            $Destination -eq $script:datacenterHostFolder -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When Ensure is Absent and the VMHost is already removed from the vCenter' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsAbsentAndTheVMHostIsAlreadyRemovedFromThevCenter
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should not invoke the Remove-VMHost mock' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Remove-VMHost'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $VMHost -eq $script:vmHostWithDatacenterHostFolderAsParent -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 0
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When Ensure is Absent, the VMHost is not removed from the vCenter and error occurs while removing the VMHost from the vCenter' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsAbsentTheVMHostIsNotRemovedFromThevCenterAndErrorOccursWhileRemovingTheVMHostFromThevCenter
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

                It 'Should throw an exception with the correct message when error occurs while removing the VMHost from the vCenter' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $resource.Set() } | Should -Throw "Could not remove VMHost $($script:vmHostWithDatacenterHostFolderAsParent.Name) from vCenter $($script:viServer.Name). For more information: ScriptHalted"
                }
            }

            Context 'When Ensure is Absent, the VMHost is not removed from the vCenter and no error occurs while removing the VMHost from the vCenter' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsAbsentTheVMHostIsNotRemovedFromThevCenterAndNoErrorOccursWhileRemovingTheVMHostFromThevCenter
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the Remove-VMHost mock with the specified VMHost once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Remove-VMHost'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $VMHost -eq $script:vmHostWithDatacenterHostFolderAsParent -and
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

        Describe 'vCenterVMHost\Test' -Tag 'Test' {
            BeforeAll {
                # Arrange
                New-MocksForvCenterVMHost
            }

            Context 'When Ensure is Present and the VMHost is not added to the vCenter' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentAndTheVMHostIsNotAddedToThevCenter
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when Ensure is Present and the VMHost is not added to the vCenter' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'When Ensure is Present, the VMHost is already added to the vCenter but not on the desired location' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentTheVMHostIsAlreadyAddedToThevCenterButNotOnTheDesiredLocation
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when Ensure is Present, the VMHost is already added to the vCenter but not on the desired location' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'When Ensure is Present and the VMHost is already added to the desired location on the vCenter' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentAndTheVMHostIsAlreadyAddedToTheDesiredLocationOnThevCenter
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when Ensure is Present and the VMHost is already added to the desired location on the vCenter' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }

            Context 'When Ensure is Absent and the VMHost is already removed from the vCenter' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsAbsentAndTheVMHostIsAlreadyRemovedFromThevCenter
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when Ensure is Absent and the VMHost is already removed from the vCenter' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }

            Context 'When Ensure is Absent and the VMHost is not removed from the vCenter' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsAbsentAndTheVMHostIsNotRemovedFromThevCenter
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when Ensure is Absent and the VMHost is not removed from the vCenter' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }
        }

        Describe 'vCenterVMHost\Get' -Tag 'Get' {
            BeforeAll {
                # Arrange
                New-MocksForvCenterVMHost
            }

            Context 'When Ensure is Present and the VMHost is not added to the vCenter' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentAndTheVMHostIsNotAddedToThevCenter
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
                    $result.Name | Should -Be $resourceProperties.Name
                    $result.Location | Should -Be $resourceProperties.Location
                    $result.DatacenterName | Should -Be $resourceProperties.DatacenterName
                    $result.DatacenterLocation | Should -Be $resourceProperties.DatacenterLocation
                    $result.Ensure | Should -Be 'Absent'
                    $result.Port | Should -Be $resourceProperties.Port
                    $result.Force | Should -Be $resourceProperties.Force
                    $result.ResourcePoolLocation | Should -BeNullOrEmpty
                }
            }

            Context 'When Ensure is Present and the VMHost is already added to the vCenter' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentAndTheVMHostIsAlreadyAddedToThevCenter
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
                    $result.Name | Should -Be $script:vmHostWithDatacenterHostFolderAsParent.Name
                    $result.Location | Should -Be $resourceProperties.Location
                    $result.DatacenterName | Should -Be $resourceProperties.DatacenterName
                    $result.DatacenterLocation | Should -Be $resourceProperties.DatacenterLocation
                    $result.Ensure | Should -Be 'Present'
                    $result.Port | Should -Be $script:vmHostWithDatacenterHostFolderAsParent.ExtensionData.Summary.Config.Port
                    $result.Force | Should -Be $resourceProperties.Force
                    $result.ResourcePoolLocation | Should -BeNullOrEmpty
                }
            }

            Context 'When Ensure is Absent and the VMHost is already removed from the vCenter' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsAbsentAndTheVMHostIsAlreadyRemovedFromThevCenter
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
                    $result.Name | Should -Be $resourceProperties.Name
                    $result.Location | Should -Be $resourceProperties.Location
                    $result.DatacenterName | Should -Be $resourceProperties.DatacenterName
                    $result.DatacenterLocation | Should -Be $resourceProperties.DatacenterLocation
                    $result.Ensure | Should -Be 'Absent'
                    $result.Port | Should -Be $resourceProperties.Port
                    $result.Force | Should -Be $resourceProperties.Force
                    $result.ResourcePoolLocation | Should -BeNullOrEmpty
                }
            }

            Context 'When Ensure is Absent and the VMHost is not removed from the vCenter' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsAbsentAndTheVMHostIsNotRemovedFromThevCenter
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
                    $result.Name | Should -Be $script:vmHostWithDatacenterHostFolderAsParent.Name
                    $result.Location | Should -Be $resourceProperties.Location
                    $result.DatacenterName | Should -Be $resourceProperties.DatacenterName
                    $result.DatacenterLocation | Should -Be $resourceProperties.DatacenterLocation
                    $result.Ensure | Should -Be 'Present'
                    $result.Port | Should -Be $script:vmHostWithDatacenterHostFolderAsParent.ExtensionData.Summary.Config.Port
                    $result.Force | Should -Be $resourceProperties.Force
                    $result.ResourcePoolLocation | Should -BeNullOrEmpty
                }
            }
        }
    }
    finally {
        # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
        Invoke-TestCleanup -ModulePath $modulePath
    }
}
