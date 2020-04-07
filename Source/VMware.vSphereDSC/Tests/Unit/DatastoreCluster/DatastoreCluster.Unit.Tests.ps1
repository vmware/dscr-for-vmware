<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

$script:PSModulePath = $env:PSModulePath
$script:ModuleName = 'VMware.vSphereDSC'

$script:UnitTestsPath = Join-Path (Join-Path (Get-Module -Name $script:ModuleName -ListAvailable).ModuleBase 'Tests') 'Unit'
. (Join-Path -Path (Join-Path -Path $script:UnitTestsPath -ChildPath 'TestHelpers') -ChildPath 'TestUtils.ps1')

Import-VMwareVSphereDSCModule

# Imports the mocked 'VMware.VimAutomation.Core' module in the current session before all tests are executed.
Invoke-TestSetup

try {
    InModuleScope -ModuleName $script:ModuleName {
        $script:DscResourceName = 'DatastoreCluster'

        . (Join-Path -Path $PSScriptRoot -ChildPath 'DatastoreCluster.Mocks.Data.ps1')
        . (Join-Path -Path $PSScriptRoot -ChildPath 'DatastoreCluster.Mocks.ps1')

        Describe "$script:DscResourceName\Set" -Tag 'Set' {
            BeforeAll {
                # Arrange
                New-MocksForDatastoreClusterDscResource
            }

            Context 'When Ensure is Present, the Datastore Cluster does not exist and error occurs while creating the Datastore Cluster' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsPresentTheDatastoreClusterDoesNotExistAndErrorOccursWhileCreatingTheDatastoreCluster
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResourceSetMethodError = { $dscResource.Set() } | Should -Throw -PassThru
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should throw an exception with the correct message when error occurs while creating the Datastore Cluster' {
                    # Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    $exceptionMessage = "Could not create Datastore Cluster {0} in Folder {1}. For more information: ScriptHalted" -f @(
                        $dscResourceProperties.Name,
                        $script:DatacenterDatastoreFolder.Name
                    )
                    $dscResourceSetMethodError.Exception.Message | Should -Be $exceptionMessage
                }
            }

            Context 'When Ensure is Present, the Datastore Cluster does not exist and no error occurs while creating the Datastore Cluster' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsPresentTheDatastoreClusterDoesNotExistAndNoErrorOccursWhileCreatingTheDatastoreCluster
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResource.Set()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the New-DatastoreCluster mock with the specified name and Datacenter Datastore Folder location once' {
                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'New-DatastoreCluster'
                        ParameterFilter = {
                            $Server -eq $script:VIServer -and
                            $Name -eq $dscResourceProperties.Name -and
                            $Location -eq $script:DatacenterDatastoreFolder -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'Context'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When Ensure is Present, the Datastore Cluster exists and error occurs while modifying the Datastore Cluster configuration' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsPresentTheDatastoreClusterExistsAndErrorOccursWhileModifyingTheDatastoreClusterConfiguration
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResourceSetMethodError = { $dscResource.Set() } | Should -Throw -PassThru
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should throw an exception with the correct message when error occurs while creating the Datastore Cluster' {
                    # Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    $exceptionMessage = "Could not modify Datastore Cluster {0} configuration. For more information: ScriptHalted" -f @(
                        $script:DatastoreCluster.Name
                    )
                    $dscResourceSetMethodError.Exception.Message | Should -Be $exceptionMessage
                }
            }

            Context 'When Ensure is Present, the Datastore Cluster does not exist and Datastore Cluster settings are specified' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsPresentTheDatastoreClusterDoesNotExistAndDatastoreClusterSettingsAreSpecified
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResource.Set()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the New-DatastoreCluster mock with the specified name and Datacenter Datastore Folder location once' {
                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'New-DatastoreCluster'
                        ParameterFilter = {
                            $Server -eq $script:VIServer -and
                            $Name -eq $dscResourceProperties.Name -and
                            $Location -eq $script:DatacenterDatastoreFolder -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'Context'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }

                It 'Should invoke the Set-DatastoreCluster mock with the specified Datastore Cluster settings once' {
                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Set-DatastoreCluster'
                        ParameterFilter = {
                            $Server -eq $script:VIServer -and
                            $DatastoreCluster -eq $script:DatastoreCluster -and
                            $IOLatencyThresholdMillisecond -eq $script:Constants.IOLatencyThresholdMillisecond -and
                            $IOLoadBalanceEnabled -eq !$script:Constants.IOLoadBalanceEnabled -and
                            $SdrsAutomationLevel -eq $script:Constants.SdrsAutomationLevel -and
                            $SpaceUtilizationThresholdPercent -eq $script:Constants.SpaceUtilizationThresholdPercent -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'Context'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When Ensure is Absent and the Datastore Cluster does not exist' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksInSetWhenEnsureIsAbsentAndTheDatastoreClusterDoesNotExist
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResource.Set()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should not invoke the Remove-DatastoreCluster mock' {
                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Remove-DatastoreCluster'
                        ParameterFilter = {
                            $Server -eq $script:VIServer -and
                            $DatastoreCluster -eq $script:DatastoreCluster -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 0
                        Scope = 'Context'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When Ensure is Absent, the Datastore Cluster exists and error occurs while removing the Datastore Cluster' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsAbsentTheDatastoreClusterExistsAndErrorOccursWhileRemovingTheDatastoreCluster
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResourceSetMethodError = { $dscResource.Set() } | Should -Throw -PassThru
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should throw an exception with the correct message when error occurs while creating the Datastore Cluster' {
                    # Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    $exceptionMessage = "Could not remove Datastore Cluster {0}. For more information: ScriptHalted" -f @(
                        $script:DatastoreCluster.Name
                    )
                    $dscResourceSetMethodError.Exception.Message | Should -Be $exceptionMessage
                }
            }

            Context 'When Ensure is Absent and the Datastore Cluster exists' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksInSetWhenEnsureIsAbsentAndTheDatastoreClusterExists
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResource.Set()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the Remove-DatastoreCluster mock with the specified Datastore Cluster once' {
                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Remove-DatastoreCluster'
                        ParameterFilter = {
                            $Server -eq $script:VIServer -and
                            $DatastoreCluster -eq $script:DatastoreCluster -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'Context'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }
        }

        Describe "$script:DscResourceName\Test" -Tag 'Test' {
            BeforeAll {
                # Arrange
                New-MocksForDatastoreClusterDscResource
            }

            Context 'When Ensure is Present and the Datastore Cluster does not exist' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsPresentAndTheDatastoreClusterDoesNotExist
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResourceTestMethodResult = $dscResource.Test()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when Ensure is Present and the Datastore Cluster does not exist' {
                    # Assert
                    $dscResourceTestMethodResult | Should -BeFalse
                }
            }

            Context 'When Ensure is Present, the Datastore Cluster exists and the Datastore Cluster configuration should not be modified' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsPresentTheDatastoreClusterExistsAndTheDatastoreClusterConfigurationShouldNotBeModified
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResourceTestMethodResult = $dscResource.Test()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when Ensure is Present, the Datastore Cluster exists and the Datastore Cluster configuration should not be modified' {
                    # Assert
                    $dscResourceTestMethodResult | Should -BeTrue
                }
            }

            Context 'When Ensure is Present, the Datastore Cluster exists and the Datastore Cluster configuration should be modified' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsPresentTheDatastoreClusterExistsAndTheDatastoreClusterConfigurationShouldBeModified
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResourceTestMethodResult = $dscResource.Test()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when Ensure is Present, the Datastore Cluster exists and the Datastore Cluster configuration should be modified' {
                    # Assert
                    $dscResourceTestMethodResult | Should -BeFalse
                }
            }

            Context 'When Ensure is Absent and the Datastore Cluster does not exist' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsAbsentAndTheDatastoreClusterDoesNotExist
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResourceTestMethodResult = $dscResource.Test()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when Ensure is Absent and the Datastore Cluster does not exist' {
                    # Assert
                    $dscResourceTestMethodResult | Should -BeTrue
                }
            }

            Context 'When Ensure is Absent and the Datastore Cluster exists' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsAbsentAndTheDatastoreClusterExists
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResourceTestMethodResult = $dscResource.Test()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when Ensure is Absent and the Datastore Cluster exists' {
                    # Assert
                    $dscResourceTestMethodResult | Should -BeFalse
                }
            }
        }

        Describe "$script:DscResourceName\Get" -Tag 'Get' {
            BeforeAll {
                # Arrange
                New-MocksForDatastoreClusterDscResource
            }

            Context 'When Ensure is Present and the Datastore Cluster does not exist' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsPresentAndTheDatastoreClusterDoesNotExist
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResourceGetMethodResult = $dscResource.Get()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should retrieve and return the correct values from the DSC Resource properties' {
                    # Assert
                    $dscResourceGetMethodResult.Server | Should -Be $dscResourceProperties.Server
                    $dscResourceGetMethodResult.Name | Should -Be $dscResourceProperties.Name
                    $dscResourceGetMethodResult.Location | Should -Be $dscResourceProperties.Location
                    $dscResourceGetMethodResult.DatacenterName | Should -Be $dscResourceProperties.DatacenterName
                    $dscResourceGetMethodResult.DatacenterLocation | Should -Be $dscResourceProperties.DatacenterLocation
                    $dscResourceGetMethodResult.Ensure | Should -Be 'Absent'
                    $dscResourceGetMethodResult.IOLatencyThresholdMillisecond | Should -Be $dscResourceProperties.IOLatencyThresholdMillisecond
                    $dscResourceGetMethodResult.IOLoadBalanceEnabled | Should -Be $dscResourceProperties.IOLoadBalanceEnabled
                    $dscResourceGetMethodResult.SdrsAutomationLevel | Should -Be $dscResourceProperties.SdrsAutomationLevel
                    $dscResourceGetMethodResult.SpaceUtilizationThresholdPercent | Should -Be $dscResourceProperties.SpaceUtilizationThresholdPercent
                }
            }

            Context 'When Ensure is Present and the Datastore Cluster exists' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsPresentAndTheDatastoreClusterExists
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResourceGetMethodResult = $dscResource.Get()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should retrieve and return the correct values from the server' {
                    # Assert
                    $dscResourceGetMethodResult.Server | Should -Be $dscResourceProperties.Server
                    $dscResourceGetMethodResult.Name | Should -Be $script:DatastoreCluster.Name
                    $dscResourceGetMethodResult.Location | Should -Be $dscResourceProperties.Location
                    $dscResourceGetMethodResult.DatacenterName | Should -Be $dscResourceProperties.DatacenterName
                    $dscResourceGetMethodResult.DatacenterLocation | Should -Be $dscResourceProperties.DatacenterLocation
                    $dscResourceGetMethodResult.Ensure | Should -Be 'Present'
                    $dscResourceGetMethodResult.IOLatencyThresholdMillisecond | Should -Be $script:DatastoreCluster.IOLatencyThresholdMillisecond
                    $dscResourceGetMethodResult.IOLoadBalanceEnabled | Should -Be $script:DatastoreCluster.IOLoadBalanceEnabled
                    $dscResourceGetMethodResult.SdrsAutomationLevel | Should -Be $script:DatastoreCluster.SdrsAutomationLevel.ToString()
                    $dscResourceGetMethodResult.SpaceUtilizationThresholdPercent | Should -Be $script:DatastoreCluster.SpaceUtilizationThresholdPercent
                }
            }

            Context 'When Ensure is Absent and the Datastore Cluster does not exist' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsAbsentAndTheDatastoreClusterDoesNotExist
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResourceGetMethodResult = $dscResource.Get()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should retrieve and return the correct values from the DSC Resource properties' {
                    # Assert
                    $dscResourceGetMethodResult.Server | Should -Be $dscResourceProperties.Server
                    $dscResourceGetMethodResult.Name | Should -Be $dscResourceProperties.Name
                    $dscResourceGetMethodResult.Location | Should -Be $dscResourceProperties.Location
                    $dscResourceGetMethodResult.DatacenterName | Should -Be $dscResourceProperties.DatacenterName
                    $dscResourceGetMethodResult.DatacenterLocation | Should -Be $dscResourceProperties.DatacenterLocation
                    $dscResourceGetMethodResult.Ensure | Should -Be 'Absent'
                    $dscResourceGetMethodResult.IOLatencyThresholdMillisecond | Should -Be $dscResourceProperties.IOLatencyThresholdMillisecond
                    $dscResourceGetMethodResult.IOLoadBalanceEnabled | Should -Be $dscResourceProperties.IOLoadBalanceEnabled
                    $dscResourceGetMethodResult.SdrsAutomationLevel | Should -Be $dscResourceProperties.SdrsAutomationLevel
                    $dscResourceGetMethodResult.SpaceUtilizationThresholdPercent | Should -Be $dscResourceProperties.SpaceUtilizationThresholdPercent
                }
            }

            Context 'When Ensure is Absent and the Datastore Cluster exists' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsAbsentAndTheDatastoreClusterExists
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResourceGetMethodResult = $dscResource.Get()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should retrieve and return the correct values from the server' {
                    # Assert
                    $dscResourceGetMethodResult.Server | Should -Be $dscResourceProperties.Server
                    $dscResourceGetMethodResult.Name | Should -Be $script:DatastoreCluster.Name
                    $dscResourceGetMethodResult.Location | Should -Be $dscResourceProperties.Location
                    $dscResourceGetMethodResult.DatacenterName | Should -Be $dscResourceProperties.DatacenterName
                    $dscResourceGetMethodResult.DatacenterLocation | Should -Be $dscResourceProperties.DatacenterLocation
                    $dscResourceGetMethodResult.Ensure | Should -Be 'Present'
                    $dscResourceGetMethodResult.IOLatencyThresholdMillisecond | Should -Be $script:DatastoreCluster.IOLatencyThresholdMillisecond
                    $dscResourceGetMethodResult.IOLoadBalanceEnabled | Should -Be $script:DatastoreCluster.IOLoadBalanceEnabled
                    $dscResourceGetMethodResult.SdrsAutomationLevel | Should -Be $script:DatastoreCluster.SdrsAutomationLevel.ToString()
                    $dscResourceGetMethodResult.SpaceUtilizationThresholdPercent | Should -Be $script:DatastoreCluster.SpaceUtilizationThresholdPercent
                }
            }
        }
    }
}
finally {
    # Removes the mocked 'VMware.VimAutomation.Core' module from the current session after all tests have executed.
    Invoke-TestCleanup -ModulePath $script:PSModulePath
}
