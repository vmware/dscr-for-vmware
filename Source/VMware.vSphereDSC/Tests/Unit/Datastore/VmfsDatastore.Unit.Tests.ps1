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
        $resourceName = 'VmfsDatastore'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
        . "$unitTestsFolder\TestHelpers\Mocks\VmfsDatastoreMocks.ps1"

        Describe 'VmfsDatastore\Set' -Tag 'Set' {
            BeforeAll {
                # Arrange
                New-MocksForVmfsDatastore
            }

            Context 'When Ensure is Present, the Vmfs Datastore is not created and BlockSizeMB is not specified' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentTheVmfsDatastoreIsNotCreatedAndBlockSizeMBIsNotSpecified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke the New-Datastore mock without BlockSizeMB once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'New-Datastore'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $Name -eq $script:constants.DatastoreName -and
                            $VMHost -eq $script:vmHost -and
                            $Path -eq $script:constants.ScsiLunCanonicalName -and
                            $Vmfs -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When Ensure is Present, the Vmfs Datastore is not created and BlockSizeMB is specified' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentTheVmfsDatastoreIsNotCreatedAndBlockSizeMBIsSpecified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke the New-Datastore mock with the specified BlockSizeMB once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'New-Datastore'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $Name -eq $script:constants.DatastoreName -and
                            $VMHost -eq $script:vmHost -and
                            $Path -eq $script:constants.ScsiLunCanonicalName -and
                            $BlockSizeMB -eq $script:constants.BlockSizeMB
                            $Vmfs -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When Ensure is Present, the Vmfs Datastore is not created and StorageIOControlEnabled and CongestionThresholdMillisecond are specified' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentTheVmfsDatastoreIsNotCreatedAndStorageIOControlEnabledAndCongestionThresholdMillisecondAreSpecified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke the New-Datastore mock with the specified BlockSizeMB once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'New-Datastore'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $Name -eq $script:constants.DatastoreName -and
                            $VMHost -eq $script:vmHost -and
                            $Path -eq $script:constants.ScsiLunCanonicalName -and
                            $BlockSizeMB -eq $script:constants.BlockSizeMB
                            $Vmfs -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }

                It 'Should invoke the Set-Datastore mock with the specified StorageIOControlEnabled and CongestionThresholdMillisecond once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Set-Datastore'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $Datastore -eq $script:datastore -and
                            $StorageIOControlEnabled -eq !$script:constants.StorageIOControlEnabled -and
                            $CongestionThresholdMillisecond -eq $script:constants.CongestionThresholdMillisecond -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When Ensure is Absent and the Vmfs Datastore is already removed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsAbsentAndTheVmfsDatastoreIsAlreadyRemoved
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should not invoke the Remove-Datastore mock' {
                    # Act
                    $resource.Set()

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
                        Times = 0
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When Ensure is Absent and the Vmfs Datastore is not removed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsAbsentAndTheVmfsDatastoreIsNotRemoved
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke the Remove-Datastore mock with the specified Datastore and VMHost once' {
                    # Act
                    $resource.Set()

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

        Describe 'VmfsDatastore\Test' -Tag 'Test' {
            BeforeAll {
                # Arrange
                New-MocksForVmfsDatastore
            }

            Context 'When Ensure is Present and the Vmfs Datastore is not created' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentAndTheVmfsDatastoreIsNotCreated
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should return $false when Ensure is Present and the Vmfs Datastore is not created' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'When Ensure is Present, the Vmfs Datastore is already created and Datastore CongestionThresholdMillisecond and StorageIOControlEnabled values do not need to be modified' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentTheVmfsDatastoreIsAlreadyCreatedAndDatastoreCongestionThresholdMillisecondAndStorageIOControlEnabledValuesDoNotNeedToBeModified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should return $true when Ensure is Present, the Vmfs Datastore is already created and Datastore CongestionThresholdMillisecond and StorageIOControlEnabled values do not need to be modified' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }

            Context 'When Ensure is Present, the Vmfs Datastore is already created and Datastore CongestionThresholdMillisecond and StorageIOControlEnabled values need to be modified' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentTheVmfsDatastoreIsAlreadyCreatedAndDatastoreCongestionThresholdMillisecondAndStorageIOControlEnabledValuesNeedToBeModified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should return $false when Ensure is Present, the Vmfs Datastore is already created and Datastore CongestionThresholdMillisecond and StorageIOControlEnabled values need to be modified' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'When Ensure is Absent and the Vmfs Datastore is already removed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsAbsentAndTheVmfsDatastoreIsAlreadyRemoved
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should return $true when Ensure is Absent and the Vmfs Datastore is already removed' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }

            Context 'When Ensure is Absent and the Vmfs Datastore is not removed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsAbsentAndTheVmfsDatastoreIsNotRemoved
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should return $false when Ensure is Absent and the Vmfs Datastore is not removed' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }
        }

        Describe 'VmfsDatastore\Get' -Tag 'Get' {
            BeforeAll {
                # Arrange
                New-MocksForVmfsDatastore
            }

            Context 'When the Vmfs Datastore does not exist' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTheVmfsDatastoreDoesNotExist
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should retrieve and return the correct values from the class properties' {
                    # Act
                    $result = $resource.Get()

                    # Assert
                    $result.BlockSizeMB | Should -Be $resourceProperties.BlockSizeMB
                    $result.Path | Should -Be $resourceProperties.Path
                }
            }

            Context 'When the Vmfs Datastore exists' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTheVmfsDatastoreExists
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should retrieve and return the correct values from the server' {
                    # Act
                    $result = $resource.Get()

                    # Assert
                    $result.BlockSizeMB | Should -Be $script:datastore.ExtensionData.Info.Vmfs.BlockSizeMB
                    $result.Path | Should -Be $script:datastore.ExtensionData.Info.Vmfs.Extent.DiskName
                }
            }
        }
    }
    finally {
        # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
        Invoke-TestCleanup -ModulePath $modulePath
    }
}
