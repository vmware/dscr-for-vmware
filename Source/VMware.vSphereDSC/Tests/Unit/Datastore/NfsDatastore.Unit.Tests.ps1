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
        $resourceName = 'NfsDatastore'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
        . "$unitTestsFolder\TestHelpers\Mocks\NfsDatastoreMocks.ps1"

        Describe 'NfsDatastore\Set' -Tag 'Set' {
            BeforeAll {
                # Arrange
                New-MocksForNfsDatastore
            }

            Context 'When Ensure is Present, the Nfs Datastore is not created and AccessMode and AuthenticationMethod are not specified' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentTheNfsDatastoreIsNotCreatedAndAccessModeAndAuthenticationMethodAreNotSpecified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke the New-Datastore mock without ReadOnly and Kerberos once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'New-Datastore'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $Name -eq $script:constants.DatastoreName -and
                            $VMHost -eq $script:vmHost -and
                            $Path -eq $script:constants.NfsPath -and
                            $Nfs -and
                            $NfsHost -eq $script:constants.NfsHost -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When Ensure is Present, the Nfs Datastore is not created and AccessMode and AuthenticationMethod are specified' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentTheNfsDatastoreIsNotCreatedAndAccessModeAndAuthenticationMethodAreSpecified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke the New-Datastore mock with ReadOnly and Kerberos once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'New-Datastore'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $Name -eq $script:constants.DatastoreName -and
                            $VMHost -eq $script:vmHost -and
                            $Path -eq $script:constants.NfsPath -and
                            $Nfs -and
                            $NfsHost -eq $script:constants.NfsHost -and
                            $ReadOnly -and
                            $Kerberos -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When Ensure is Present, the Nfs Datastore is not created and StorageIOControlEnabled and CongestionThresholdMillisecond are specified' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentTheNfsDatastoreIsNotCreatedAndStorageIOControlEnabledAndCongestionThresholdMillisecondAreSpecified
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
                            $Path -eq $script:constants.NfsPath -and
                            $Nfs -and
                            $NfsHost -eq $script:constants.NfsHost -and
                            $ReadOnly -and
                            $Kerberos -and
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
                            $Datastore -eq $script:nfsDatastore -and
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

            Context 'When Ensure is Absent and the Nfs Datastore is already removed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsAbsentAndTheNfsDatastoreIsAlreadyRemoved
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
                            $Datastore -eq $script:nfsDatastore -and
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

            Context 'When Ensure is Absent and the Nfs Datastore is not removed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsAbsentAndTheNfsDatastoreIsNotRemoved
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
                            $Datastore -eq $script:nfsDatastore -and
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

        Describe 'NfsDatastore\Test' -Tag 'Test' {
            BeforeAll {
                # Arrange
                New-MocksForNfsDatastore
            }

            Context 'When Ensure is Present and the Nfs Datastore is not created' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentAndTheNfsDatastoreIsNotCreated
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should return $false when Ensure is Present and the Nfs Datastore is not created' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'When Ensure is Present, the Nfs Datastore is already created and Datastore CongestionThresholdMillisecond and StorageIOControlEnabled values do not need to be modified' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentTheNfsDatastoreIsAlreadyCreatedAndDatastoreCongestionThresholdMillisecondAndStorageIOControlEnabledValuesDoNotNeedToBeModified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should return $true when Ensure is Present, the Nfs Datastore is already created and Datastore CongestionThresholdMillisecond and StorageIOControlEnabled values do not need to be modified' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }

            Context 'When Ensure is Present, the Nfs Datastore is already created and Datastore CongestionThresholdMillisecond and StorageIOControlEnabled values need to be modified' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsPresentTheNfsDatastoreIsAlreadyCreatedAndDatastoreCongestionThresholdMillisecondAndStorageIOControlEnabledValuesNeedToBeModified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should return $false when Ensure is Present, the Nfs Datastore is already created and Datastore CongestionThresholdMillisecond and StorageIOControlEnabled values need to be modified' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'When Ensure is Absent and the Nfs Datastore is already removed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsAbsentAndTheNfsDatastoreIsAlreadyRemoved
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should return $true when Ensure is Absent and the Nfs Datastore is already removed' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }

            Context 'When Ensure is Absent and the Nfs Datastore is not removed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureIsAbsentAndTheNfsDatastoreIsNotRemoved
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should return $false when Ensure is Absent and the Nfs Datastore is not removed' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }
        }

        Describe 'NfsDatastore\Get' -Tag 'Get' {
            BeforeAll {
                # Arrange
                New-MocksForNfsDatastore
            }

            Context 'When the Nfs Datastore does not exist' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTheNfsDatastoreDoesNotExist
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should retrieve and return the correct values from the class properties' {
                    # Act
                    $result = $resource.Get()

                    # Assert
                    $result.NfsHost | Should -Be $resourceProperties.NfsHost
                    $result.Path | Should -Be $resourceProperties.Path
                    $result.AccessMode | Should -Be $resource.AccessMode
                    $result.AuthenticationMethod | Should -Be $resource.AuthenticationMethod
                }
            }

            Context 'When the Nfs Datastore exists' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTheNfsDatastoreExists
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should retrieve and return the correct values from the server' {
                    # Act
                    $result = $resource.Get()

                    # Assert
                    $result.NfsHost | Should -Be $script:nfsDatastore.RemoteHost
                    $result.Path | Should -Be $script:nfsDatastore.RemotePath
                    $result.AccessMode | Should -Be $script:nfsDatastore.ExtensionData.Host.MountInfo.AccessMode
                    $result.AuthenticationMethod | Should -Be $script:nfsDatastore.AuthenticationMethod.ToString()
                }
            }
        }
    }
    finally {
        # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
        Invoke-TestCleanup -ModulePath $modulePath
    }
}
