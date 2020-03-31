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
        $resourceName = 'VMHostScsiLunPath'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
        . "$unitTestsFolder\TestHelpers\Mocks\VMHostScsiLunPathMocks.ps1"

        Describe 'VMHostScsiLunPath\Set' -Tag 'Set' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostScsiLunPath
            }

            Context 'When error occurs while configuring the SCSI Lun path' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenErrorOccursWhileConfiguringTheScsiLunPath
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

                It 'Should throw an exception with the correct message when error occurs while configuring the SCSI Lun path' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $resource.Set() } | Should -Throw "Could not configure SCSI Lun path $($script:constants.VMHostScsiLunPathName) to SCSI device $($script:constants.VMHostScsiLunCanonicalName) from VMHost $($script:vmHost.Name). For more information: ScriptHalted"
                }
            }

            Context 'When no error occurs while configuring the SCSI Lun path' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenNoErrorOccursWhileConfiguringTheScsiLunPath
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the Set-ScsiLunPath mock with the specified SCSI Lun path and active and preferred values once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Set-ScsiLunPath'
                        ParameterFilter = {
                            $ScsiLunPath -eq $script:vmHostScsiLunPath -and
                            $Active -eq $script:constants.VMHostActiveScsiLunPath -and
                            $Preferred -eq $script:constants.VMHostPreferredScsiLunPath -and
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

        Describe 'VMHostScsiLunPath\Test' -Tag 'Test' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostScsiLunPath
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

            Context 'When the SCSI Lun path state is Active and the Active property is $true' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTheScsiLunPathStateIsActiveAndTheActivePropertyIsTrue
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when the SCSI Lun path state is Active and the Active property is $true' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }

            Context 'When the SCSI Lun path state is Active and the Active property is $false' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTheScsiLunPathStateIsActiveAndTheActivePropertyIsFalse
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when the SCSI Lun path state is Active and the Active property is $false' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'When the SCSI Lun path is Preferred and the Preferred property is $true' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTheScsiLunPathIsPreferredAndThePreferredPropertyIsTrue
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when the SCSI Lun path is Preferred and the Preferred property is $true' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }

            Context 'When the SCSI Lun path is Preferred and the Preferred property is $false' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTheScsiLunPathIsPreferredAndThePreferredPropertyIsFalse
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when the SCSI Lun path is Preferred and the Preferred property is $false' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }
        }

        Describe 'VMHostScsiLunPath\Get' -Tag 'Get' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostScsiLunPath

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
                $result.Name | Should -Be $script:vmHostScsiLunPath.Name
                $result.ScsiLunCanonicalName | Should -Be $script:vmHostScsiLunPath.ScsiLun.CanonicalName
                $result.Active | Should -BeTrue
                $result.Preferred | Should -Be $script:vmHostScsiLunPath.Preferred
            }
        }
    }
    finally {
        # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
        Invoke-TestCleanup -ModulePath $modulePath
    }
}
