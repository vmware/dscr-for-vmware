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
        $datastoreBaseDSCClassName = 'DatastoreBaseDSC'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
        . "$unitTestsFolder\TestHelpers\Mocks\DatastoreBaseDSCMocks.ps1"

        Describe 'DatastoreBaseDSC\GetDatastore' -Tag 'GetDatastore' {
            BeforeAll {
                # Arrange
                New-MocksForDatastoreBaseDSC
            }

            Context 'When the Datastore does not exist' {
                BeforeAll {
                    # Arrange
                    $datastoreBaseDSCProperties = New-MocksWhenTheDatastoreDoesNotExist
                    $datastoreBaseDSC = New-Object -TypeName $datastoreBaseDSCClassName -Property $datastoreBaseDSCProperties

                    $datastoreBaseDSC.ConnectVIServer()
                    $datastoreBaseDSC.RetrieveVMHost()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $datastoreBaseDSC.GetDatastore()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $null when the Datastore does not exist' {
                    # Act
                    $datastore = $datastoreBaseDSC.GetDatastore()

                    # Assert
                    $datastore | Should -BeNullOrEmpty
                }
            }

            Context 'When the Datastore exists' {
                BeforeAll {
                    # Arrange
                    $datastoreBaseDSCProperties = New-MocksWhenTheDatastoreExists
                    $datastoreBaseDSC = New-Object -TypeName $datastoreBaseDSCClassName -Property $datastoreBaseDSCProperties

                    $datastoreBaseDSC.ConnectVIServer()
                    $datastoreBaseDSC.RetrieveVMHost()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $datastoreBaseDSC.GetDatastore()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return the Datastore with the specified name when the Datastore exists' {
                    # Act
                    $datastore = $datastoreBaseDSC.GetDatastore()

                    # Assert
                    $datastore | Should -Be $script:datastore
                }
            }
        }

        Describe 'DatastoreBaseDSC\ShouldModifyDatastore' -Tag 'ShouldModifyDatastore' {
            BeforeAll {
                # Arrange
                New-MocksForDatastoreBaseDSC
            }

            Context 'When CongestionThresholdMillisecond and StorageIOControlEnabled are not specified' {
                BeforeAll {
                    # Arrange
                    $datastoreBaseDSCProperties = New-MocksWhenTheDatastoreExists
                    $datastoreBaseDSC = New-Object -TypeName $datastoreBaseDSCClassName -Property $datastoreBaseDSCProperties

                    $datastoreBaseDSC.ConnectVIServer()
                    $datastoreBaseDSC.RetrieveVMHost()
                    $datastore = $datastoreBaseDSC.GetDatastore()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $datastoreBaseDSC.ShouldModifyDatastore($datastore)

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when CongestionThresholdMillisecond and StorageIOControlEnabled are not specified' {
                    # Act
                    $result = $datastoreBaseDSC.ShouldModifyDatastore($datastore)

                    # Assert
                    $result | Should -BeFalse
                }
            }

            Context 'When Datastore CongestionThresholdMillisecond and StorageIOControlEnabled values do not need to be modified' {
                BeforeAll {
                    # Arrange
                    $datastoreBaseDSCProperties = New-MocksWhenDatastoreCongestionThresholdMillisecondAndStorageIOControlEnabledValuesDoNotNeedToBeModified
                    $datastoreBaseDSC = New-Object -TypeName $datastoreBaseDSCClassName -Property $datastoreBaseDSCProperties

                    $datastoreBaseDSC.ConnectVIServer()
                    $datastoreBaseDSC.RetrieveVMHost()
                    $datastore = $datastoreBaseDSC.GetDatastore()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $datastoreBaseDSC.ShouldModifyDatastore($datastore)

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when Datastore CongestionThresholdMillisecond and StorageIOControlEnabled values do not need to be modified' {
                    # Act
                    $result = $datastoreBaseDSC.ShouldModifyDatastore($datastore)

                    # Assert
                    $result | Should -BeFalse
                }
            }

            Context 'When Datastore CongestionThresholdMillisecond and StorageIOControlEnabled values need to be modified' {
                BeforeAll {
                    # Arrange
                    $datastoreBaseDSCProperties = New-MocksWhenDatastoreCongestionThresholdMillisecondAndStorageIOControlEnabledValuesNeedToBeModified
                    $datastoreBaseDSC = New-Object -TypeName $datastoreBaseDSCClassName -Property $datastoreBaseDSCProperties

                    $datastoreBaseDSC.ConnectVIServer()
                    $datastoreBaseDSC.RetrieveVMHost()
                    $datastore = $datastoreBaseDSC.GetDatastore()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $datastoreBaseDSC.ShouldModifyDatastore($datastore)

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when Datastore CongestionThresholdMillisecond and StorageIOControlEnabled values need to be modified' {
                    # Act
                    $result = $datastoreBaseDSC.ShouldModifyDatastore($datastore)

                    # Assert
                    $result | Should -BeTrue
                }
            }
        }

        Describe 'DatastoreBaseDSC\NewDatastore' -Tag 'NewDatastore' {
            BeforeAll {
                # Arrange
                New-MocksForDatastoreBaseDSC
            }

            Context 'When error occurs while creating the Datastore' {
                BeforeAll {
                    # Arrange
                    $datastoreBaseDSCProperties = New-MocksWhenErrorOccursWhileCreatingTheDatastore
                    $datastoreBaseDSC = New-Object -TypeName $datastoreBaseDSCClassName -Property $datastoreBaseDSCProperties

                    $datastoreBaseDSC.ConnectVIServer()
                    $datastoreBaseDSC.RetrieveVMHost()
                    $newDatastoreParams = @{}
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    try {
                        # Act
                        $datastoreBaseDSC.NewDatastore($newDatastoreParams)
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw an exception with the correct message when error occurs while creating the Datastore' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $datastoreBaseDSC.NewDatastore($newDatastoreParams) } | Should -Throw "Could not create Datastore $($datastoreBaseDSCProperties.Name) on VMHost $($script:vmHost.Name). For more information: ScriptHalted"
                }
            }

            Context 'When FileSystemVersion is not specified' {
                BeforeAll {
                    # Arrange
                    $datastoreBaseDSCProperties = New-MocksWhenFileSystemVersionIsNotSpecified
                    $datastoreBaseDSC = New-Object -TypeName $datastoreBaseDSCClassName -Property $datastoreBaseDSCProperties

                    $datastoreBaseDSC.ConnectVIServer()
                    $datastoreBaseDSC.RetrieveVMHost()
                    $newDatastoreParams = @{}
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $datastoreBaseDSC.NewDatastore($newDatastoreParams)

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return the created Datastore' {
                    # Act
                    $datastore = $datastoreBaseDSC.NewDatastore($newDatastoreParams)

                    # Assert
                    $datastore | Should -Be $script:datastore
                }
            }

            Context 'When FileSystemVersion is specified' {
                BeforeAll {
                    # Arrange
                    $datastoreBaseDSCProperties = New-MocksWhenFileSystemVersionIsSpecified
                    $datastoreBaseDSC = New-Object -TypeName $datastoreBaseDSCClassName -Property $datastoreBaseDSCProperties

                    $datastoreBaseDSC.ConnectVIServer()
                    $datastoreBaseDSC.RetrieveVMHost()
                    $newDatastoreParams = @{}
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $datastoreBaseDSC.NewDatastore($newDatastoreParams)

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return the created Datastore' {
                    # Act
                    $datastore = $datastoreBaseDSC.NewDatastore($newDatastoreParams)

                    # Assert
                    $datastore | Should -Be $script:datastore
                }
            }
        }

        Describe 'DatastoreBaseDSC\ModifyDatastore' -Tag 'ModifyDatastore' {
            BeforeAll {
                # Arrange
                New-MocksForDatastoreBaseDSC
            }

            Context 'When error occurs while modifying the Datastore' {
                BeforeAll {
                    # Arrange
                    $datastoreBaseDSCProperties = New-MocksWhenErrorOccursWhileModifyingTheDatastore
                    $datastoreBaseDSC = New-Object -TypeName $datastoreBaseDSCClassName -Property $datastoreBaseDSCProperties

                    $datastoreBaseDSC.ConnectVIServer()
                    $datastoreBaseDSC.RetrieveVMHost()
                    $datastore = $datastoreBaseDSC.GetDatastore()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    try {
                        # Act
                        $datastoreBaseDSC.ModifyDatastore($datastore)
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw an exception with the correct message when error occurs while modifying the Datastore' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $datastoreBaseDSC.ModifyDatastore($datastore) } | Should -Throw "Could not modify Datastore $($datastore.Name) on VMHost $($script:vmHost.Name). For more information: ScriptHalted"
                }
            }

            Context 'When StorageIOControlEnabled and CongestionThresholdMillisecond are not specified' {
                BeforeAll {
                    # Arrange
                    $datastoreBaseDSCProperties = New-MocksWhenStorageIOControlEnabledAndCongestionThresholdMillisecondAreNotSpecified
                    $datastoreBaseDSC = New-Object -TypeName $datastoreBaseDSCClassName -Property $datastoreBaseDSCProperties

                    $datastoreBaseDSC.ConnectVIServer()
                    $datastoreBaseDSC.RetrieveVMHost()
                    $datastore = $datastoreBaseDSC.GetDatastore()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $datastoreBaseDSC.ModifyDatastore($datastore)

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the Set-Datastore mock without StorageIOControlEnabled and CongestionThresholdMillisecond once' {
                    # Act
                    $datastoreBaseDSC.ModifyDatastore($datastore)

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Set-Datastore'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $Datastore -eq $script:datastore -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When StorageIOControlEnabled and CongestionThresholdMillisecond are specified' {
                BeforeAll {
                    # Arrange
                    $datastoreBaseDSCProperties = New-MocksWhenStorageIOControlEnabledAndCongestionThresholdMillisecondAreSpecified
                    $datastoreBaseDSC = New-Object -TypeName $datastoreBaseDSCClassName -Property $datastoreBaseDSCProperties

                    $datastoreBaseDSC.ConnectVIServer()
                    $datastoreBaseDSC.RetrieveVMHost()
                    $datastore = $datastoreBaseDSC.GetDatastore()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $datastoreBaseDSC.ModifyDatastore($datastore)

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the Set-Datastore mock with the specified StorageIOControlEnabled and CongestionThresholdMillisecond once' {
                    # Act
                    $datastoreBaseDSC.ModifyDatastore($datastore)

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Set-Datastore'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $Datastore -eq $script:datastore -and
                            $StorageIOControlEnabled -eq $script:constants.StorageIOControlEnabled -and
                            $CongestionThresholdMillisecond -eq $script:constants.MaxCongestionThresholdMillisecond -and
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

        Describe 'DatastoreBaseDSC\RemoveDatastore' -Tag 'RemoveDatastore' {
            BeforeAll {
                # Arrange
                New-MocksForDatastoreBaseDSC
            }

            Context 'When error occurs while removing the Datastore' {
                BeforeAll {
                    # Arrange
                    $datastoreBaseDSCProperties = New-MocksWhenErrorOccursWhileRemovingTheDatastore
                    $datastoreBaseDSC = New-Object -TypeName $datastoreBaseDSCClassName -Property $datastoreBaseDSCProperties

                    $datastoreBaseDSC.ConnectVIServer()
                    $datastoreBaseDSC.RetrieveVMHost()
                    $datastore = $datastoreBaseDSC.GetDatastore()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    try {
                        # Act
                        $datastoreBaseDSC.RemoveDatastore($datastore)
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw an exception with the correct message when error occurs while removing the Datastore' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $datastoreBaseDSC.RemoveDatastore($datastore) } | Should -Throw "Could not remove Datastore $($datastore.Name) from VMHost $($script:vmHost.Name). For more information: ScriptHalted"
                }
            }

            Context 'When no error occurs while removing the Datastore' {
                BeforeAll {
                    # Arrange
                    $datastoreBaseDSCProperties = New-MocksWhenNoErrorOccursWhileRemovingTheDatastore
                    $datastoreBaseDSC = New-Object -TypeName $datastoreBaseDSCClassName -Property $datastoreBaseDSCProperties

                    $datastoreBaseDSC.ConnectVIServer()
                    $datastoreBaseDSC.RetrieveVMHost()
                    $datastore = $datastoreBaseDSC.GetDatastore()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $datastoreBaseDSC.RemoveDatastore($datastore)

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the Remove-Datastore mock with the specified Datastore and VMHost once' {
                    # Act
                    $datastoreBaseDSC.RemoveDatastore($datastore)

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Remove-Datastore'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $Datastore -eq $script:datastore -and
                            $VMHost -eq $script:vmHost -and
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

        Describe 'DatastoreBaseDSC\PopulateResult' -Tag 'PopulateResult' {
            BeforeAll {
                # Arrange
                New-MocksForDatastoreBaseDSC
            }

            Context 'When the Datastore does not exist' {
                BeforeAll {
                    # Arrange
                    $datastoreBaseDSCProperties = New-MocksWhenTheDatastoreDoesNotExist
                    $datastoreBaseDSC = New-Object -TypeName $datastoreBaseDSCClassName -Property $datastoreBaseDSCProperties

                    $datastoreBaseDSC.ConnectVIServer()
                    $datastoreBaseDSC.RetrieveVMHost()
                    $result = New-Object -TypeName $datastoreBaseDSCClassName
                    $datastore = $datastoreBaseDSC.GetDatastore()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $datastoreBaseDSC.PopulateResult($result, $datastore)

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should retrieve and return the correct values from the class properties' {
                    # Act
                    $datastoreBaseDSC.PopulateResult($result, $datastore)

                    # Assert
                    $result.Server | Should -Be $script:viServer.Name
                    $result.VMHostName | Should -Be $script:vmHost.Name
                    $result.Name | Should -Be $datastoreBaseDSCProperties.Name
                    $result.Ensure | Should -Be 'Absent'
                    $result.FileSystemVersion | Should -BeNullOrEmpty
                    $result.CongestionThresholdMillisecond | Should -BeNullOrEmpty
                    $result.StorageIOControlEnabled | Should -BeNullOrEmpty
                }
            }

            Context 'When the Datastore exists' {
                BeforeAll {
                    # Arrange
                    $datastoreBaseDSCProperties = New-MocksWhenTheDatastoreExists
                    $datastoreBaseDSC = New-Object -TypeName $datastoreBaseDSCClassName -Property $datastoreBaseDSCProperties

                    $datastoreBaseDSC.ConnectVIServer()
                    $datastoreBaseDSC.RetrieveVMHost()
                    $result = New-Object -TypeName $datastoreBaseDSCClassName
                    $datastore = $datastoreBaseDSC.GetDatastore()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $datastoreBaseDSC.PopulateResult($result, $datastore)

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should retrieve and return the correct values from the server' {
                    # Act
                    $datastoreBaseDSC.PopulateResult($result, $datastore)

                    # Assert
                    $result.Server | Should -Be $script:viServer.Name
                    $result.VMHostName | Should -Be $script:vmHost.Name
                    $result.Name | Should -Be $script:datastore.Name
                    $result.Ensure | Should -Be 'Present'
                    $result.FileSystemVersion | Should -Be $script:datastore.FileSystemVersion
                    $result.CongestionThresholdMillisecond | Should -Be $script:datastore.CongestionThresholdMillisecond
                    $result.StorageIOControlEnabled | Should -Be $script:datastore.StorageIOControlEnabled
                }
            }
        }
    }
    finally {
        # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
        Invoke-TestCleanup -ModulePath $modulePath
    }
}
