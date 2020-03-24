<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

Using module '..\..\..\..\VMware.vSphereDSC.psm1'

$script:moduleName = 'VMware.vSphereDSC'

InModuleScope -ModuleName $script:moduleName {
    try {
        $unitTestsFolder = Join-Path (Join-Path (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase 'Tests') 'Unit'
        $modulePath = $env:PSModulePath
        $resourceName = 'VMHostVssPortGroupTeaming'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
        . "$unitTestsFolder\TestHelpers\Mocks\VMHostVssPortGroupTeamingMocks.ps1"

        Describe 'VMHostVssPortGroupTeaming\Set' -Tag 'Set' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostVssPortGroupTeaming
            }

            Context 'Invoking with Teaming Policy Settings and Teaming Policy Settings Inherited are not passed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTeamingPolicySettingsArePassedAndTeamingPolicySettingsInheritedAreNotPassed
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Set-NicTeamingPolicy mock once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Set-NicTeamingPolicy'
                        ParameterFilter = { $FailbackEnabled -eq $script:constants.FailbackEnabled -and `
                                            $LoadBalancingPolicy -eq $script:constants.LoadBalancingPolicyIP -and `
                                            $NetworkFailoverDetectionPolicy -eq $script:constants.NetworkFailoverDetectionPolicy -and `
                                            $NotifySwitches -eq $script:constants.NotifySwitches -and `
                                            [System.Linq.Enumerable]::SequenceEqual($MakeNicActive, [string[]] $script:constants.ActiveNic) -and `
                                            [System.Linq.Enumerable]::SequenceEqual($MakeNicStandby, [string[]] $script:constants.StandbyNic) -and `
                                            [System.Linq.Enumerable]::SequenceEqual($MakeNicUnused, [string[]] $script:constants.UnusedNic) }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Invoking with Teaming Policy Settings and Teaming Policy Settings Inherited set to $false' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTeamingPolicySettingsArePassedAndTeamingPolicySettingsInheritedAreSetToFalse
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Set-NicTeamingPolicy mock once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Set-NicTeamingPolicy'
                        ParameterFilter = { $FailbackEnabled -eq $script:constants.FailbackEnabled -and `
                                            $LoadBalancingPolicy -eq $script:constants.LoadBalancingPolicyIP -and `
                                            $NetworkFailoverDetectionPolicy -eq $script:constants.NetworkFailoverDetectionPolicy -and `
                                            $NotifySwitches -eq $script:constants.NotifySwitches -and `
                                            [System.Linq.Enumerable]::SequenceEqual($MakeNicActive, [string[]] $script:constants.ActiveNic) -and `
                                            [System.Linq.Enumerable]::SequenceEqual($MakeNicStandby, [string[]] $script:constants.StandbyNic) -and `
                                            [System.Linq.Enumerable]::SequenceEqual($MakeNicUnused, [string[]] $script:constants.UnusedNic) -and `
                                            $InheritFailback -eq $script:constants.InheritFailback -and `
                                            $InheritFailoverOrder -eq $script:constants.InheritFailoverOrder -and `
                                            $InheritLoadBalancingPolicy -eq $script:constants.InheritLoadBalancingPolicy -and `
                                            $InheritNetworkFailoverDetectionPolicy -eq $script:constants.InheritNetworkFailoverDetectionPolicy -and `
                                            $InheritNotifySwitches -eq $script:constants.InheritNotifySwitches }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Invoking with Teaming Policy Settings and Teaming Policy Settings Inherited set to $true' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTeamingPolicySettingsArePassedAndTeamingPolicySettingsInheritedAreSetToTrue
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Set-NicTeamingPolicy mock once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Set-NicTeamingPolicy'
                        ParameterFilter = { $InheritFailback -eq !$script:constants.InheritFailback -and `
                                            $InheritFailoverOrder -eq !$script:constants.InheritFailoverOrder -and `
                                            $InheritLoadBalancingPolicy -eq !$script:constants.InheritLoadBalancingPolicy -and `
                                            $InheritNetworkFailoverDetectionPolicy -eq !$script:constants.InheritNetworkFailoverDetectionPolicy -and `
                                            $InheritNotifySwitches -eq !$script:constants.InheritNotifySwitches }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }
        }

        Describe 'VMHostVssPortGroupTeaming\Test' -Tag 'Test' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostVssPortGroupTeaming
            }

            Context 'Invoking with non matching Teaming Policy Settings' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTheTeamingPolicySettingsAreNonMatching
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when the Teaming Policy Settings are not equal' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'Invoking with matching Teaming Policy Settings' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTheTeamingPolicySettingsAreMatching
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when the Teaming Policy Settings are equal' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }
        }

        Describe 'VMHostVssPortGroupTeaming\Get' -Tag 'Get' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostVssPortGroupTeaming

                $resourceProperties = New-MocksInGet
                $resource = New-Object -TypeName $resourceName -Property $resourceProperties
            }

            It 'Should retrieve the correct settings from the Server' {
                # Act
                $result = $resource.Get()

                # Assert
                $result.Server | Should -Be $resourceProperties.Server
                $result.VMHostName | Should -Be $script:constants.VMHostName
                $result.Name | Should -Be $script:constants.VirtualPortGroupName
                $result.Ensure | Should -Be $resourceProperties.Ensure
                $result.FailbackEnabled | Should -Be $script:constants.FailbackEnabled
                $result.LoadBalancingPolicy | Should -Be $script:constants.LoadBalancingPolicyIP
                $result.NetworkFailoverDetectionPolicy | Should -Be $script:constants.NetworkFailoverDetectionPolicy
                $result.NotifySwitches | Should -Be $script:constants.NotifySwitches
                $result.ActiveNic | Should -Be $script:constants.ActiveNic
                $result.StandbyNic | Should -Be $script:constants.StandbyNic
                $result.UnusedNic | Should -Be $script:constants.UnusedNic
                $result.InheritFailback | Should -Be $script:constants.InheritFailback
                $result.InheritFailoverOrder | Should -Be $script:constants.InheritFailoverOrder
                $result.InheritLoadBalancingPolicy | Should -Be $script:constants.InheritLoadBalancingPolicy
                $result.InheritNetworkFailoverDetectionPolicy | Should -Be $script:constants.InheritNetworkFailoverDetectionPolicy
                $result.InheritNotifySwitches | Should -Be $script:constants.InheritNotifySwitches
            }
        }

    }
    finally {
        # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
        Invoke-TestCleanup -ModulePath $modulePath
    }
}
