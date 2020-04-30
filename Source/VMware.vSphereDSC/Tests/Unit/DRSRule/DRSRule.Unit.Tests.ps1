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
        $script:DscResourceName = 'DRSRule'

        . (Join-Path -Path $PSScriptRoot -ChildPath 'DRSRule.Mocks.Data.ps1')
        . (Join-Path -Path $PSScriptRoot -ChildPath 'DRSRule.Mocks.ps1')

        Describe "$script:DscResourceName\Set" -Tag 'Set' {
            BeforeAll {
                # Arrange
                New-MocksForDRSRuleDscResource
            }

            Context 'When Ensure is Present, the DRS rule does not exist and error occurs while creating the DRS rule' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsPresentTheDRSRuleDoesNotExistAndErrorOccursWhileCreatingTheDRSRule
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResourceSetMethodError = { $dscResource.Set() } | Should -Throw -PassThru
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should throw an exception with the correct message when error occurs while creating the DRS rule' {
                    # Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    $exceptionMessage = "Could not create DRS rule {0} for Cluster {1}. For more information: ScriptHalted" -f @(
                        $dscResourceProperties.Name,
                        $script:Cluster.Name
                    )
                    $dscResourceSetMethodError.Exception.Message | Should -Be $exceptionMessage
                }
            }

            Context 'When Ensure is Present, the DRS rule does not exist and no error occurs while creating the DRS rule' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsPresentTheDRSRuleDoesNotExistAndNoErrorOccursWhileCreatingTheDRSRule
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResource.Set()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the New-DrsRule mock with the specified name, Cluster location and Virtual Machines once' {
                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'New-DrsRule'
                        ParameterFilter = {
                            $Server -eq $script:VIServer -and
                            $Name -eq $dscResourceProperties.Name -and
                            $Cluster -eq $script:Cluster -and
                            $KeepTogether -eq $true -and
                            [System.Linq.Enumerable]::SequenceEqual(
                                $VM,
                                [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]] $script:VirtualMachines
                            ) -and
                            $Enabled -eq $script:Constants.DrsRuleEnabled -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'Context'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When Ensure is Present, the DRS rule exists and error occurs while modifying the DRS rule' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsPresentTheDRSRuleExistsAndErrorOccursWhileModifyingTheDRSRule
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResourceSetMethodError = { $dscResource.Set() } | Should -Throw -PassThru
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should throw an exception with the correct message when error occurs while creating the DRS rule' {
                    # Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    $exceptionMessage = "Could not modify DRS rule {0} for Cluster {1}. For more information: ScriptHalted" -f @(
                        $script:DrsRule.Name,
                        $script:Cluster.Name
                    )
                    $dscResourceSetMethodError.Exception.Message | Should -Be $exceptionMessage
                }
            }

            Context 'When Ensure is Present, the DRS rule exists and Virtual Machines are specified' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsPresentTheDRSRuleExistsAndVirtualMachinesAreSpecified
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResource.Set()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the Set-DrsRule mock with the specified DRS rule and Virtual Machines once' {
                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Set-DrsRule'
                        ParameterFilter = {
                            $Server -eq $script:VIServer -and
                            $Rule -eq $script:DrsRule -and
                            [System.Linq.Enumerable]::SequenceEqual(
                                $VM,
                                [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]] $script:VirtualMachines
                            ) -and
                            $Enabled -eq !$script:Constants.DrsRuleEnabled -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'Context'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When Ensure is Absent and the DRS rule does not exist' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksInSetWhenEnsureIsAbsentAndTheDRSRuleDoesNotExist
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResource.Set()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should not invoke the Remove-DrsRule mock' {
                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Remove-DrsRule'
                        ParameterFilter = {
                            $Rule -eq $script:DrsRule -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 0
                        Scope = 'Context'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When Ensure is Absent, the DRS rule exists and error occurs while removing the DRS rule' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsAbsentTheDRSRuleExistsAndErrorOccursWhileRemovingTheDRSRule
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResourceSetMethodError = { $dscResource.Set() } | Should -Throw -PassThru
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should throw an exception with the correct message when error occurs while removing the DRS rule' {
                    # Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    $exceptionMessage = "Could not remove DRS rule {0} for Cluster {1}. For more information: ScriptHalted" -f @(
                        $script:DrsRule.Name,
                        $script:Cluster.Name
                    )
                    $dscResourceSetMethodError.Exception.Message | Should -Be $exceptionMessage
                }
            }

            Context 'When Ensure is Absent and the DRS rule exists' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksInSetWhenEnsureIsAbsentAndTheDRSRuleExists
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResource.Set()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the Remove-DrsRule mock with the specified DRS rule once' {
                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Remove-DrsRule'
                        ParameterFilter = {
                            $Rule -eq $script:DrsRule -and
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
                New-MocksForDRSRuleDscResource
            }

            Context 'When Ensure is Present and the DRS rule does not exist' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsPresentAndTheDRSRuleDoesNotExist
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResourceTestMethodResult = $dscResource.Test()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when Ensure is Present and the DRS rule does not exist' {
                    # Assert
                    $dscResourceTestMethodResult | Should -BeFalse
                }
            }

            Context 'When Ensure is Present, the DRS rule exists and the Virtual Machines referenced by the DRS rule should not be modified' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsPresentTheDRSRuleExistsAndTheVirtualMachinesReferencedByTheDRSRuleShouldNotBeModified
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResourceTestMethodResult = $dscResource.Test()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when Ensure is Present, DRS rule exists and the Virtual Machines referenced by the DRS rule should not be modified' {
                    # Assert
                    $dscResourceTestMethodResult | Should -BeTrue
                }
            }

            Context 'When Ensure is Present, the DRS rule exists and the Virtual Machines referenced by the DRS rule should be modified' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsPresentTheDRSRuleExistsAndTheVirtualMachinesReferencedByTheDRSRuleShouldBeModified
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResourceTestMethodResult = $dscResource.Test()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when Ensure is Present, the DRS rule exists and the Virtual Machines referenced by the DRS rule should be modified' {
                    # Assert
                    $dscResourceTestMethodResult | Should -BeFalse
                }
            }

            Context 'When Ensure is Absent and the DRS rule does not exist' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsAbsentAndTheDRSRuleDoesNotExist
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResourceTestMethodResult = $dscResource.Test()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when Ensure is Absent and the DRS rule does not exist' {
                    # Assert
                    $dscResourceTestMethodResult | Should -BeTrue
                }
            }

            Context 'When Ensure is Absent and the DRS rule exists' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsAbsentAndTheDRSRuleExists
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResourceTestMethodResult = $dscResource.Test()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when Ensure is Absent and the DRS rule exists' {
                    # Assert
                    $dscResourceTestMethodResult | Should -BeFalse
                }
            }
        }

        Describe "$script:DscResourceName\Get" -Tag 'Get' {
            BeforeAll {
                # Arrange
                New-MocksForDRSRuleDscResource
            }

            Context 'When Ensure is Present and the DRS rule does not exist' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsPresentAndTheDRSRuleDoesNotExist
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
                    $dscResourceGetMethodResult.DatacenterName | Should -Be $script:Datacenter.Name
                    $dscResourceGetMethodResult.DatacenterLocation | Should -Be $dscResourceProperties.DatacenterLocation
                    $dscResourceGetMethodResult.ClusterName | Should -Be $script:Cluster.Name
                    $dscResourceGetMethodResult.ClusterLocation | Should -Be $dscResourceProperties.ClusterLocation
                    $dscResourceGetMethodResult.DRSRuleType | Should -Be $dscResourceProperties.DRSRuleType
                    $dscResourceGetMethodResult.VMNames | Should -Be $dscResourceProperties.VMNames
                    $dscResourceGetMethodResult.Ensure | Should -Be 'Absent'
                    $dscResourceGetMethodResult.Enabled | Should -Be $dscResourceProperties.Enabled
                }
            }

            Context 'When Ensure is Present and the DRS rule exists' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsPresentAndTheDRSRuleExists
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
                    $dscResourceGetMethodResult.Name | Should -Be $script:DrsRule.Name
                    $dscResourceGetMethodResult.DatacenterName | Should -Be $script:Datacenter.Name
                    $dscResourceGetMethodResult.DatacenterLocation | Should -Be $dscResourceProperties.DatacenterLocation
                    $dscResourceGetMethodResult.ClusterName | Should -Be $script:Cluster.Name
                    $dscResourceGetMethodResult.ClusterLocation | Should -Be $dscResourceProperties.ClusterLocation
                    $dscResourceGetMethodResult.DRSRuleType | Should -Be ([string] $script:DrsRule.Type)
                    $dscResourceGetMethodResult.VMNames | Should -Be $script:Constants.VirtualMachineNames
                    $dscResourceGetMethodResult.Ensure | Should -Be 'Present'
                    $dscResourceGetMethodResult.Enabled | Should -Be $script:DrsRule.Enabled
                }
            }

            Context 'When Ensure is Absent and the DRS rule does not exist' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsAbsentAndTheDRSRuleDoesNotExist
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
                    $dscResourceGetMethodResult.DatacenterName | Should -Be $script:Datacenter.Name
                    $dscResourceGetMethodResult.DatacenterLocation | Should -Be $dscResourceProperties.DatacenterLocation
                    $dscResourceGetMethodResult.ClusterName | Should -Be $script:Cluster.Name
                    $dscResourceGetMethodResult.ClusterLocation | Should -Be $dscResourceProperties.ClusterLocation
                    $dscResourceGetMethodResult.DRSRuleType | Should -Be $dscResourceProperties.DRSRuleType
                    $dscResourceGetMethodResult.VMNames | Should -Be $dscResourceProperties.VMNames
                    $dscResourceGetMethodResult.Ensure | Should -Be 'Absent'
                    $dscResourceGetMethodResult.Enabled | Should -Be $dscResourceProperties.Enabled
                }
            }

            Context 'When Ensure is Absent and the DRS rule exists' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsAbsentAndTheDRSRuleExists
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
                    $dscResourceGetMethodResult.Name | Should -Be $script:DrsRule.Name
                    $dscResourceGetMethodResult.DatacenterName | Should -Be $script:Datacenter.Name
                    $dscResourceGetMethodResult.DatacenterLocation | Should -Be $dscResourceProperties.DatacenterLocation
                    $dscResourceGetMethodResult.ClusterName | Should -Be $script:Cluster.Name
                    $dscResourceGetMethodResult.ClusterLocation | Should -Be $dscResourceProperties.ClusterLocation
                    $dscResourceGetMethodResult.DRSRuleType | Should -Be ([string] $script:DrsRule.Type)
                    $dscResourceGetMethodResult.VMNames | Should -Be $script:Constants.VirtualMachineNames
                    $dscResourceGetMethodResult.Ensure | Should -Be 'Present'
                    $dscResourceGetMethodResult.Enabled | Should -Be $script:DrsRule.Enabled
                }
            }
        }
    }
}
finally {
    # Removes the mocked 'VMware.VimAutomation.Core' module from the current session after all tests have executed.
    Invoke-TestCleanup -ModulePath $script:PSModulePath
}
