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
        $resourceName = 'VMHostScsiLun'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
        . "$unitTestsFolder\TestHelpers\Mocks\VMHostScsiLunMocks.ps1"

        Describe 'VMHostScsiLun\Set' -Tag 'Set' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostScsiLun
            }

            Context 'When error occurs while modifying the SCSI Lun configuration' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenErrorOccursWhileModifyingTheScsiLunConfiguration
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

                It 'Should throw an exception with the correct message when error occurs while modifying the SCSI Lun configuration' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $resource.Set() } | Should -Throw "Could not modify the configuration of SCSI device $($script:constants.VMHostScsiLunCanonicalName) from VMHost $($script:vmHost.Name). For more information: ScriptHalted"
                }
            }

            Context 'When no error occurs while modifying the SCSI Lun configuration' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenNoErrorOccursWhileModifyingTheScsiLunConfiguration
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the Set-ScsiLun mock with the specified SCSI Lun and desired settings to configure once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Set-ScsiLun'
                        ParameterFilter = {
                            $ScsiLun -eq $script:vmHostScsiLun -and
                            $MultipathPolicy -eq $script:constants.VMHostScsiLunMultipathPolicy -and
                            $PreferredPath -eq $script:vmHostScsiLunPath -and
                            $DeletePartitions -eq $script:constants.VMHostScsiLunDeletePartitions -and
                            $IsLocal -eq $script:constants.VMHostScsiLunIsLocal -and
                            $IsSsd -eq $script:constants.VMHostScsiLunIsSsd -and
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

        Describe 'VMHostScsiLun\Test' -Tag 'Test' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostScsiLun
            }

            Context 'When the ScsiLun is not found' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTheScsiLunIsNotFound
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

                It 'Should throw an exception with the correct message when the ScsiLun is not found' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $resource.Test() } | Should -Throw "Could not retrieve SCSI device $($script:constants.VMHostScsiLunCanonicalName) from VMHost $($script:vmHost.Name). For more information: ScriptHalted"
                }
            }

            Context 'When the SCSI Lun path is not found' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTheScsiLunPathIsNotFound
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

                It 'Should throw an exception with the correct message when the SCSI Lun path is not found' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $resource.Test() } | Should -Throw "Could not retrieve SCSI Lun path $($script:constants.VMHostScsiLunPathName) to SCSI device $($script:constants.VMHostScsiLunCanonicalName) from VMHost $($script:vmHost.Name). For more information: ScriptHalted"
                }
            }

            Context 'When the SCSI Lun configuration does not need to be modified' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTheScsiLunConfigurationDoesNotNeedToBeModified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when the SCSI Lun configuration does not need to be modified' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }

            Context 'When the SCSI Lun path is not preferred' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTheScsiLunPathIsNotPreferred
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when the SCSI Lun path is not preferred' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'When disk partitions exist and DeletePartitions is specified' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenDiskPartitionsExistAndDeletePartitionsIsSpecified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when disk partitions exist and DeletePartitions is specified' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }
        }

        Describe 'VMHostScsiLun\Get' -Tag 'Get' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostScsiLun

                $resourceProperties = New-MocksInGet
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
                $result.CanonicalName | Should -Be $script:constants.VMHostScsiLunCanonicalName
                $result.MultipathPolicy | Should -Be $script:constants.VMHostScsiLunMultipathPolicy
                $result.PreferredScsiLunPathName | Should -Be $script:constants.VMHostScsiLunPathName
                $result.BlocksToSwitchPath | Should -Be $script:constants.VMHostScsiLunBlocksToSwitchPath
                $result.CommandsToSwitchPath | Should -Be $script:constants.VMHostScsiLunCommandsToSwitchPath
                $result.DeletePartitions | Should -Be $script:constants.VMHostScsiLunDeletePartitions
                $result.IsLocal | Should -Be $script:constants.VMHostScsiLunIsLocal
                $result.IsSsd | Should -Be $script:constants.VMHostScsiLunIsSsd
            }
        }
    }
    finally {
        # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
        Invoke-TestCleanup -ModulePath $modulePath
    }
}
