<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

Using module '..\..\..\VMware.vSphereDSC.psm1'

$script:moduleName = 'VMware.vSphereDSC'

InModuleScope -ModuleName $script:moduleName {
    try {
        $unitTestsFolder = Join-Path (Join-Path (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase 'Tests') 'Unit'
        $modulePath = $env:PSModulePath
        $resourceName = 'VMHostIScsiHbaTarget'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
        . "$unitTestsFolder\TestHelpers\Mocks\VMHostIScsiHbaTargetMocks.ps1"

        Describe 'VMHostIScsiHbaTarget\Set' -Tag 'Set' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostIScsiHbaTarget
            }

            Context 'When Ensure is Present, the iSCSI Host Bus Adapter target is not created and error occurs while creating the iSCSI Host Bus Adapter target' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentTheiSCSIHostBusAdapterTargetIsNotCreatedAndErrorOccursWhileCreatingTheiSCSIHostBusAdapterTarget
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

                It 'Should throw an exception with the correct message when error occurs while creating the iSCSI Host Bus Adapter target' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $resource.Set() } | Should -Throw "Could not create iSCSI Host Bus Adapter target with IP address $($script:constants.IScsiIPEndPoint) on iSCSI Host Bus Adapter device $($script:iScsiHba.Device). For more information: ScriptHalted"
                }
            }

            Context 'When Ensure is Present, the iSCSI Host Bus Adapter target is not created and no error occurs while creating the iSCSI Host Bus Adapter Send target' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentTheiSCSIHostBusAdapterTargetIsNotCreatedAndNoErrorOccursWhileCreatingTheiSCSIHostBusAdapterSendTarget
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the New-IScsiHbaTarget mock with the specified Address, Port and iSCSI Host Bus Adapter once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'New-IScsiHbaTarget'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $Address -eq $script:constants.IScsiHbaTargetAddress -and
                            $Port -eq $script:constants.IScsiHbaTargetPort -and
                            $IScsiHba -eq $script:iScsiHba -and
                            $Type -eq $script:constants.IScsiHbaSendTargetType -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When Ensure is Present, the iSCSI Host Bus Adapter target is not created and no error occurs while creating the iSCSI Host Bus Adapter Static target' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentTheiSCSIHostBusAdapterTargetIsNotCreatedAndNoErrorOccursWhileCreatingTheiSCSIHostBusAdapterStaticTarget
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the New-IScsiHbaTarget mock with the specified Address, Port, IScsiName and iSCSI Host Bus Adapter once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'New-IScsiHbaTarget'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $Address -eq $script:constants.IScsiHbaTargetAddress -and
                            $Port -eq $script:constants.IScsiHbaTargetPort -and
                            $IScsiHba -eq $script:iScsiHba -and
                            $Type -eq $script:constants.IScsiHbaStaticTargetType -and
                            $IScsiName -eq $script:constants.IScsiName -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When Ensure is Present, the iSCSI Host Bus Adapter target is already created and error occurs while modifying the CHAP settings of the iSCSI Host Bus Adapter target' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentTheiSCSIHostBusAdapterTargetIsAlreadyCreatedAndErrorOccursWhileModifyingTheCHAPSettingsOfTheiSCSIHostBusAdapterTarget
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

                It 'Should throw an exception with the correct message when error occurs while modifying the CHAP settings of the iSCSI Host Bus Adapter target' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $resource.Set() } | Should -Throw "Could not modify CHAP settings of iSCSI Host Bus Adapter target with IP address $($script:constants.IScsiIPEndPoint) on iSCSI Host Bus Adapter device $($script:iScsiHba.Device). For more information: ScriptHalted"
                }
            }

            Context 'When Ensure is Present, the iSCSI Host Bus Adapter target is already created and the no error occurs while modifying the CHAP settings of the iSCSI Host Bus Adapter target' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentTheiSCSIHostBusAdapterTargetIsAlreadyCreatedAndNoErrorOccursWhileModifyingTheCHAPSettingsOfTheiSCSIHostBusAdapterTarget
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the Set-IScsiHbaTarget mock with the specified iSCSI Host Bus Adapter target once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Set-IScsiHbaTarget'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $Target -eq $script:iScsiHbaTarget -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When Ensure is Absent and the iSCSI Host Bus Adapter target is already removed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsAbsentAndTheiSCSIHostBusAdapterTargetIsAlreadyRemoved
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should not invoke the Remove-IScsiHbaTarget mock' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Remove-IScsiHbaTarget'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $Target -eq $script:iScsiHbaTarget -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 0
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When Ensure is Absent, the iSCSI Host Bus Adapter target is not removed and error occurs while removing the iSCSI Host Bus Adapter target' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsAbsentTheiSCSIHostBusAdapterTargetIsNotRemovedAndErrorOccursWhileRemovingTheiSCSIHostBusAdapterTarget
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

                It 'Should throw an exception with the correct message when error occurs while removing the iSCSI Host Bus Adapter target' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $resource.Set() } | Should -Throw "Could not remove iSCSI Host Bus Adapter target with IP address $($script:constants.IScsiIPEndPoint) from iSCSI Host Bus Adapter device $($script:iScsiHba.Device). For more information: ScriptHalted"
                }
            }

            Context 'When Ensure is Absent, the iSCSI Host Bus Adapter target is not removed and no error occurs while removing the iSCSI Host Bus Adapter target' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsAbsentTheiSCSIHostBusAdapterTargetIsNotRemovedAndNoErrorOccursWhileRemovingTheiSCSIHostBusAdapterTarget
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the Remove-IScsiHbaTarget mock with the specified iSCSI Host Bus Adapter target once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Remove-IScsiHbaTarget'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $Target -eq $script:iScsiHbaTarget -and
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

        Describe 'VMHostIScsiHbaTarget\Test' -Tag 'Test' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostIScsiHbaTarget
            }

            Context 'When Ensure is Present and the iSCSI Host Bus Adapter target is not created' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentAndTheiSCSIHostBusAdapterTargetIsNotCreated
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when Ensure is Present and the iSCSI Host Bus Adapter target is not created' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -BeFalse
                }
            }

            Context 'When Ensure is Present, the iSCSI Host Bus Adapter target is already created and CHAP settings do not need to be modified' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentTheiSCSIHostBusAdapterTargetIsAlreadyCreatedAndCHAPSettingsDoNotNeedToBeModified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when Ensure is Present, the iSCSI Host Bus Adapter target is already created and CHAP settings do not need to be modified' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -BeTrue
                }
            }

            Context 'When Ensure is Present, the iSCSI Host Bus Adapter target is already created and CHAP settings need to be modified' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentTheiSCSIHostBusAdapterTargetIsAlreadyCreatedAndCHAPSettingsNeedToBeModified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when Ensure is Present, the iSCSI Host Bus Adapter target is already created and CHAP settings need to be modified' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -BeFalse
                }
            }

            Context 'When Ensure is Absent and the iSCSI Host Bus Adapter target is already removed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsAbsentAndTheiSCSIHostBusAdapterTargetIsAlreadyRemoved
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when Ensure is Absent and the iSCSI Host Bus Adapter target is already removed' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -BeTrue
                }
            }

            Context 'When Ensure is Absent and the iSCSI Host Bus Adapter target is not removed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsAbsentAndTheiSCSIHostBusAdapterTargetIsNotRemoved
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when Ensure is Absent and the iSCSI Host Bus Adapter target is not removed' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -BeFalse
                }
            }
        }

        Describe 'VMHostIScsiHbaTarget\Get' -Tag 'Get' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostIScsiHbaTarget
            }

            Context 'When Ensure is Present and the iSCSI Host Bus Adapter target is not created' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentAndTheiSCSIHostBusAdapterTargetIsNotCreated
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
                    $result.Force | Should -Be $resourceProperties.Force
                    $result.Address | Should -Be $resourceProperties.Address
                    $result.Port | Should -Be $resourceProperties.Port
                    $result.IScsiHbaName | Should -Be $resourceProperties.IScsiHbaName
                    $result.TargetType | Should -Be $resourceProperties.TargetType
                    $result.IScsiName | Should -Be $resourceProperties.IScsiName
                    $result.InheritChap | Should -BeNull
                    $result.ChapType | Should -Be 'Unset'
                    $result.ChapName | Should -BeNullOrEmpty
                    $result.InheritMutualChap | Should -BeNull
                    $result.MutualChapEnabled | Should -BeNull
                    $result.MutualChapName | Should -BeNullOrEmpty
                    $result.Ensure | Should -Be 'Absent'
                }
            }

            Context 'When Ensure is Present and the iSCSI Host Bus Adapter target is already created' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentTheiSCSIHostBusAdapterTargetIsAlreadyCreatedAndCHAPSettingsDoNotNeedToBeModified
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
                    $result.Force | Should -Be $resourceProperties.Force
                    $result.Address | Should -Be $script:iScsiHbaTarget.Address
                    $result.Port | Should -Be $script:iScsiHbaTarget.Port
                    $result.IScsiHbaName | Should -Be $script:iScsiHbaTarget.IScsiHbaName
                    $result.TargetType | Should -Be $script:iScsiHbaTarget.Type
                    $result.IScsiName | Should -Be ([string] $script:iScsiHbaTarget.IScsiName)
                    $result.InheritChap | Should -Be $script:iScsiHbaTarget.AuthenticationProperties.ChapInherited
                    $result.ChapType | Should -Be $script:iScsiHbaTarget.AuthenticationProperties.ChapType
                    $result.ChapName | Should -Be $script:iScsiHbaTarget.AuthenticationProperties.ChapName
                    $result.InheritMutualChap | Should -Be $script:iScsiHbaTarget.AuthenticationProperties.MutualChapInherited
                    $result.MutualChapEnabled | Should -Be $script:iScsiHbaTarget.AuthenticationProperties.MutualChapEnabled
                    $result.MutualChapName | Should -Be $script:iScsiHbaTarget.AuthenticationProperties.MutualChapName
                    $result.Ensure | Should -Be 'Present'
                }
            }

            Context 'When Ensure is Absent and the iSCSI Host Bus Adapter target is already removed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsAbsentAndTheiSCSIHostBusAdapterTargetIsAlreadyRemoved
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
                    $result.Force | Should -Be $resourceProperties.Force
                    $result.Address | Should -Be $resourceProperties.Address
                    $result.Port | Should -Be $resourceProperties.Port
                    $result.IScsiHbaName | Should -Be $resourceProperties.IScsiHbaName
                    $result.TargetType | Should -Be $resourceProperties.TargetType
                    $result.IScsiName | Should -Be $resourceProperties.IScsiName
                    $result.InheritChap | Should -BeNull
                    $result.ChapType | Should -Be 'Unset'
                    $result.ChapName | Should -BeNullOrEmpty
                    $result.InheritMutualChap | Should -BeNull
                    $result.MutualChapEnabled | Should -BeNull
                    $result.MutualChapName | Should -BeNullOrEmpty
                    $result.Ensure | Should -Be 'Absent'
                }
            }

            Context 'When Ensure is Absent and the iSCSI Host Bus Adapter target is not removed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsAbsentAndTheiSCSIHostBusAdapterTargetIsNotRemoved
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
                    $result.Force | Should -Be $resourceProperties.Force
                    $result.Address | Should -Be $script:iScsiHbaTarget.Address
                    $result.Port | Should -Be $script:iScsiHbaTarget.Port
                    $result.IScsiHbaName | Should -Be $script:iScsiHbaTarget.IScsiHbaName
                    $result.TargetType | Should -Be $script:iScsiHbaTarget.Type
                    $result.IScsiName | Should -Be ([string] $script:iScsiHbaTarget.IScsiName)
                    $result.InheritChap | Should -Be $script:iScsiHbaTarget.AuthenticationProperties.ChapInherited
                    $result.ChapType | Should -Be $script:iScsiHbaTarget.AuthenticationProperties.ChapType
                    $result.ChapName | Should -Be $script:iScsiHbaTarget.AuthenticationProperties.ChapName
                    $result.InheritMutualChap | Should -Be $script:iScsiHbaTarget.AuthenticationProperties.MutualChapInherited
                    $result.MutualChapEnabled | Should -Be $script:iScsiHbaTarget.AuthenticationProperties.MutualChapEnabled
                    $result.MutualChapName | Should -Be $script:iScsiHbaTarget.AuthenticationProperties.MutualChapName
                    $result.Ensure | Should -Be 'Present'
                }
            }
        }
    }
    finally {
        # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
        Invoke-TestCleanup -ModulePath $modulePath
    }
}
