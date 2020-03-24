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
        $resourceName = 'VMHostFirewallRuleset'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
        . "$unitTestsFolder\TestHelpers\Mocks\VMHostFirewallRulesetMocks.ps1"

        Describe 'VMHostFirewallRuleset\Set' -Tag 'Set' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostFirewallRuleset
            }

            Context 'When error occurs while modifying the state of the VMHost firewall ruleset' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenErrorOccursWhileModifyingTheStateOfTheVMHostFirewallRuleset
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

                It 'Should throw an exception with the correct message when error occurs while modifying the state of the VMHost firewall ruleset' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $resource.Set() } | Should -Throw "Could not modify the state of firewall ruleset $($script:constants.FirewallRulesetName) on VMHost $($script:vmHost.Name). For more information: ScriptHalted"
                }
            }

            Context 'When no error occurs while modifying the state of the VMHost firewall ruleset' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenNoErrorOccursWhileModifyingTheStateOfTheVMHostFirewallRuleset
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the Set-VMHostFirewallException mock with the specified firewall ruleset once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Set-VMHostFirewallException'
                        ParameterFilter = {
                            $Exception -eq $script:vmHostFirewallRuleset -and
                            $Enabled -eq !$script:constants.FirewallRulesetEnabled -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When error occurs while modifying the allowed IP addresses list of the VMHost firewall ruleset' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenErrorOccursWhileModifyingTheAllowedIPAddressesListOfTheVMHostFirewallRuleset
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

                It 'Should throw an exception with the correct message when error occurs while modifying the allowed IP addresses list of the VMHost firewall ruleset' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $resource.Set() } | Should -Throw "Could not modify the allowed IP addresses list of firewall ruleset $($script:constants.FirewallRulesetName) on VMHost $($script:vmHost.Name). For more information: ScriptHalted"
                }
            }

            Context 'When no error occurs while modifying the allowed IP addresses list of the VMHost firewall ruleset' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenNoErrorOccursWhileModifyingTheAllowedIPAddressesListOfTheVMHostFirewallRuleset
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the Update-VMHostFirewallRuleset mock with the specified IP addresses and IP networks once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Update-VMHostFirewallRuleset'
                        ParameterFilter = {
                            $VMHostFirewallSystem -eq $script:vmHostFirewallSystem -and
                            $VMHostFirewallRulesetId -eq $script:vmHostFirewallRuleset.ExtensionData.Key -and
                            $VMHostFirewallRulesetSpec -eq $script:vmHostFirewallRulesetSpec
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }
        }

        Describe 'VMHostFirewallRuleset\Test' -Tag 'Test' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostFirewallRuleset
            }

            Context 'When the state of the VMHost firewall ruleset does not need to be modified' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTheStateOfTheVMHostFirewallRulesetDoesNotNeedToBeModified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when the state of the VMHost firewall ruleset does not need to be modified' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -BeTrue
                }
            }

            Context 'When the state of the VMHost firewall ruleset needs to be modified' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTheStateOfTheVMHostFirewallRulesetNeedsToBeModified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when the state of the VMHost firewall ruleset needs to be modified' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -BeFalse
                }
            }

            Context 'When the allowed IP addresses list of the VMHost firewall ruleset does not need to be modified' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTheAllowedIPAddressesListOfTheVMHostFirewallRulesetDoesNotNeedToBeModified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when the allowed IP addresses list of the VMHost firewall ruleset does not need to be modified' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -BeTrue
                }
            }

            Context 'When the allowed IP addresses list of the VMHost firewall ruleset needs to be modified' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTheAllowedIPAddressesListOfTheVMHostFirewallRulesetNeedsToBeModified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when the allowed IP addresses list of the VMHost firewall ruleset needs to be modified' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -BeFalse
                }
            }
        }

        Describe 'VMHostFirewallRuleset\Get' -Tag 'Get' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostFirewallRuleset

                $resourceProperties = New-VMHostFirewallRulesetProperties
                $resource = New-Object -TypeName $resourceName -Property $resourceProperties
            }

            It 'Should invoke all defined mocks with the correct parameters' {
                # Act
                $resource.Get()

                # Assert
                Assert-VerifiableMock
            }

            It 'Should retrieve and return the correct values from the Server' {
                # Act
                $result = $resource.Get()

                # Assert
                $result.Server | Should -Be $script:viServer.Name
                $result.VMHostName | Should -Be $script:vmHost.Name
                $result.Name | Should -Be $script:vmHostFirewallRuleset.Name
                $result.Enabled | Should -Be $script:vmHostFirewallRuleset.Enabled
                $result.AllIP | Should -Be $script:vmHostFirewallRuleset.ExtensionData.AllowedHosts.AllIp
                $result.IPAddresses | Should -Be ($script:vmHostFirewallRuleset.ExtensionData.AllowedHosts.IPAddress + $script:constants.FirewallRulesetIPNetworksOne)
            }
        }
    }
    finally {
        # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
        Invoke-TestCleanup -ModulePath $modulePath
    }
}
