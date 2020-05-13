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
        $script:DscResourceName = 'DatastoreClusterAddDatastore'

        . (Join-Path -Path $PSScriptRoot -ChildPath 'DatastoreClusterAddDatastore.Mocks.Data.ps1')
        . (Join-Path -Path $PSScriptRoot -ChildPath 'DatastoreClusterAddDatastore.Mocks.ps1')

        Describe "$script:DscResourceName\Set" -Tag 'Set' {
            BeforeAll {
                # Arrange
                New-MocksForDatastoreClusterAddDatastoreDscResource
            }

            Context 'When error occurs while adding Datastores to Datastore Cluster' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenErrorOccursWhileAddingDatastoresToDatastoreCluster
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResourceSetMethodError = { $dscResource.Set() } | Should -Throw -PassThru
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should throw an exception with the correct message when error occurs while adding Datastores to Datastore Cluster' {
                    # Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    $exceptionMessage = "Could not add Datastores {0} to Datastore Cluster {1}. For more information: ScriptHalted" -f @(
                        ($script:Datastores.Name -Join ', '),
                        $script:DatastoreCluster.Name
                    )
                    $dscResourceSetMethodError.Exception.Message | Should -Be $exceptionMessage
                }
            }

            Context 'When no error occurs while adding Datastores to Datastore Cluster' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenNoErrorOccursWhileAddingDatastoresToDatastoreCluster
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResource.Set()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the Move-Datastore mock with the specified Datastores and Datastore Cluster once' {
                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Move-Datastore'
                        ParameterFilter = {
                            $Server -eq $script:VIServer -and
                            [System.Linq.Enumerable]::SequenceEqual(
                                $Datastore,
                                [VMware.VimAutomation.ViCore.Types.V1.DatastoreManagement.Datastore[]] $script:Datastores
                            ) -and
                            $Destination -eq $script:DatastoreCluster -and
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
                New-MocksForDatastoreClusterAddDatastoreDscResource
            }

            Context 'When Datastores should be added to Datastore Cluster' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenDatastoresShouldBeAddedToDatastoreCluster
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResourceTestMethodResult = $dscResource.Test()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when Datastores should be added to Datastore Cluster' {
                    # Assert
                    $dscResourceTestMethodResult | Should -BeFalse
                }
            }

            Context 'When Datastores should not be added to Datastore Cluster' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenDatastoresShouldNotBeAddedToDatastoreCluster
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResourceTestMethodResult = $dscResource.Test()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when Datastores should not be added to Datastore Cluster' {
                    # Assert
                    $dscResourceTestMethodResult | Should -BeTrue
                }
            }
        }

        Describe "$script:DscResourceName\Get" -Tag 'Get' {
            BeforeAll {
                # Arrange
                New-MocksForDatastoreClusterAddDatastoreDscResource

                $dscResourceProperties = New-MocksInGet
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
                $dscResourceGetMethodResult.DatacenterName | Should -Be $script:Datacenter.Name
                $dscResourceGetMethodResult.DatacenterLocation | Should -Be $dscResourceProperties.DatacenterLocation
                $dscResourceGetMethodResult.DatastoreClusterName | Should -Be $script:DatastoreCluster.Name
                $dscResourceGetMethodResult.DatastoreClusterLocation | Should -Be $dscResourceProperties.DatastoreClusterLocation
                $dscResourceGetMethodResult.DatastoreNames | Should -Be ($script:Datastores | Select-Object -ExpandProperty Name)
            }
        }
    }
}
finally {
    # Removes the mocked 'VMware.VimAutomation.Core' module from the current session after all tests have executed.
    Invoke-TestCleanup -ModulePath $script:PSModulePath
}
