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
        $resourceName = 'VDSwitch'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
        . "$unitTestsFolder\TestHelpers\Mocks\VDSwitchMocks.ps1"

        Describe 'VDSwitch\Set' -Tag 'Set' {
            BeforeAll {
                # Arrange
                New-MocksForVDSwitch
            }

            Context 'Invoking with Ensure Present, non existing Distributed Switch and no Distributed Switch settings specified' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsurePresentNonExistingDistributedSwitchAndNoDistributedSwitchSettingsSpecified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the New-VDSwitch mock once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'New-VDSwitch'
                        ParameterFilter = { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName -and `
                                            $Location -eq $script:datacenterNetworkFolder -and !$Confirm }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Invoking with Ensure Present, non existing Distributed Switch and Distributed Switch settings specified' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsurePresentNonExistingDistributedSwitchAndDistributedSwitchSettingsSpecified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the New-VDSwitch mock once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'New-VDSwitch'
                        ParameterFilter = { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName -and $Location -eq $script:datacenterNetworkFolder -and `
                                            $ContactDetails -eq $script:constants.DistributedSwitchContactDetails -and $ContactName -eq $script:constants.DistributedSwitchContactName -and `
                                            $LinkDiscoveryProtocol -eq $script:constants.DistributedSwitchLinkDiscoveryProtocol -and `
                                            $LinkDiscoveryProtocolOperation -eq $script:constants.DistributedSwitchLinkDiscoveryProtocolOperation -and `
                                            $MaxPorts -eq $script:constants.DistributedSwitchMaxPorts -and $Mtu -eq $script:constants.DistributedSwitchMtu -and `
                                            $Notes -eq $script:constants.DistributedSwitchNotes -and $NumUplinkPorts -eq $script:constants.DistributedSwitchNumUplinkPorts -and `
                                            $Version -eq $script:constants.DistributedSwitchVersion -and !$Confirm }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Invoking with Ensure Present, non existing Distributed Switch and Reference Distributed Switch Name specified' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsurePresentNonExistingDistributedSwitchAndReferenceDistributedSwitchNameSpecified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the New-VDSwitch mock once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'New-VDSwitch'
                        ParameterFilter = { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName -and $Location -eq $script:datacenterNetworkFolder -and `
                                            $ReferenceVDSwitch -eq $script:constants.ReferenceDistributedSwitchName -and $WithoutPortGroups -eq $script:constants.WithoutPortGroups -and !$Confirm }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Invoking with Ensure Present and existing Distributed Switch' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksInSetWhenEnsurePresentAndExistingDistributedSwitch
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Set-VDSwitch mock once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Set-VDSwitch'
                        ParameterFilter = { $Server -eq $script:viServer -and $VDSwitch -eq $script:distributedSwitch -and !$Confirm -and `
                                            $ContactDetails -eq ($script:constants.DistributedSwitchContactDetails + $script:constants.DistributedSwitchContactDetails) -and `
                                            $ContactName -eq ($script:constants.DistributedSwitchContactName + $script:constants.DistributedSwitchContactName) -and `
                                            $MaxPorts -eq ($script:constants.DistributedSwitchMaxPorts + 1) -and $Mtu -eq ($script:constants.DistributedSwitchMtu + 1) }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Invoking with Ensure Absent and non existing Distributed Switch' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksInSetWhenEnsureAbsentAndNonExistingDistributedSwitch
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should not call the Remove-VDSwitch mock' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Remove-VDSwitch'
                        ParameterFilter = { $Server -eq $script:viServer -and $VDSwitch -eq $script:distributedSwitch -and !$Confirm }
                        Exactly = $true
                        Times = 0
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Invoking with Ensure Absent and existing Distributed Switch' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksInSetWhenEnsureAbsentAndExistingDistributedSwitch
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Remove-VDSwitch mock once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Remove-VDSwitch'
                        ParameterFilter = { $Server -eq $script:viServer -and $VDSwitch -eq $script:distributedSwitch -and !$Confirm }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }
        }

        Describe 'VDSwitch\Test' -Tag 'Test' {
            BeforeAll {
                # Arrange
                New-MocksForVDSwitch
            }

            Context 'Invoking with Ensure Present and non existing Distributed Switch' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsurePresentAndNonExistingDistributedSwitch
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when the Distributed Switch does not exist' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'Invoking with Ensure Present, existing Distributed Switch and matching settings' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsurePresentExistingDistributedSwitchAndMatchingSettings
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when the Distributed Switch exists and the Distributed Switch settings are equal' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }

            Context 'Invoking with Ensure Present, existing Distributed Switch and non matching settings' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsurePresentExistingDistributedSwitchAndNonMatchingSettings
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when the Distributed Switch exists and the Distributed Switch settings are not equal' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'Invoking with Ensure Absent and non existing Distributed Switch' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureAbsentAndNonExistingDistributedSwitch
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when the Distributed Switch does not exist' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }

            Context 'Invoking with Ensure Absent and existing Distributed Switch' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureAbsentAndExistingDistributedSwitch
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when the Distributed Switch exists' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }
        }

        Describe 'VDSwitch\Get' -Tag 'Get' {
            BeforeAll {
                # Arrange
                New-MocksForVDSwitch
            }

            Context 'Invoking with Ensure Present and non existing Distributed Switch' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsurePresentAndNonExistingDistributedSwitch
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Get()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should retrieve the correct settings from the Resource properties and Ensure should be set to Absent' {
                    # Act
                    $result = $resource.Get()

                    # Assert
                    $result.Server | Should -Be $resourceProperties.Server
                    $result.Name | Should -Be $resourceProperties.Name
                    $result.Location | Should -Be $resourceProperties.Location
                    $result.DatacenterName | Should -Be $resourceProperties.DatacenterName
                    $result.DatacenterLocation | Should -Be $resourceProperties.DatacenterLocation
                    $result.Ensure | Should -Be 'Absent'

                    $result.ReferenceVDSwitchName | Should -BeNullOrEmpty
                    $result.WithoutPortGroups | Should -Be $resourceProperties.WithoutPortGroups
                    $result.ContactDetails | Should -Be $resourceProperties.ContactDetails
                    $result.ContactName | Should -Be $resourceProperties.ContactName
                    $result.LinkDiscoveryProtocol.ToString() | Should -Be $resourceProperties.LinkDiscoveryProtocol.ToString()
                    $result.LinkDiscoveryProtocolOperation.ToString() | Should -Be $resourceProperties.LinkDiscoveryProtocolOperation.ToString()
                    $result.MaxPorts | Should -Be $resourceProperties.MaxPorts
                    $result.Mtu | Should -Be $resourceProperties.Mtu
                    $result.Notes | Should -Be $resourceProperties.Notes
                    $result.NumUplinkPorts | Should -Be $resourceProperties.NumUplinkPorts
                    $result.Version | Should -Be $resourceProperties.Version
                }
            }

            Context 'Invoking with Ensure Present and existing Distributed Switch' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsurePresentAndExistingDistributedSwitch
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Get()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should retrieve the correct settings from the Server and Ensure should be set to Present' {
                    # Act
                    $result = $resource.Get()

                    # Assert
                    $result.Server | Should -Be $resourceProperties.Server
                    $result.Name | Should -Be $script:constants.DistributedSwitchName
                    $result.Location | Should -Be $resourceProperties.Location
                    $result.DatacenterName | Should -Be $resourceProperties.DatacenterName
                    $result.DatacenterLocation | Should -Be $resourceProperties.DatacenterLocation
                    $result.Ensure | Should -Be 'Present'
                    $result.ReferenceVDSwitchName | Should -BeNullOrEmpty
                    $result.WithoutPortGroups | Should -Be $resourceProperties.WithoutPortGroups
                    $result.ContactDetails | Should -Be $script:constants.DistributedSwitchContactDetails
                    $result.ContactName | Should -Be $script:constants.DistributedSwitchContactName
                    $result.LinkDiscoveryProtocol.ToString() | Should -Be $script:constants.DistributedSwitchLinkDiscoveryProtocol.ToString()
                    $result.LinkDiscoveryProtocolOperation.ToString() | Should -Be $script:constants.DistributedSwitchLinkDiscoveryProtocolOperation.ToString()
                    $result.MaxPorts | Should -Be $script:constants.DistributedSwitchMaxPorts
                    $result.Mtu | Should -Be $script:constants.DistributedSwitchMtu
                    $result.Notes | Should -Be $script:constants.DistributedSwitchNotes
                    $result.NumUplinkPorts | Should -Be $script:constants.DistributedSwitchNumUplinkPorts
                    $result.Version | Should -Be $script:constants.DistributedSwitchVersion
                }
            }

            Context 'Invoking with Ensure Absent and non existing Distributed Switch' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureAbsentAndNonExistingDistributedSwitch
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Get()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should retrieve the correct settings from the Resource properties and Ensure should be set to Absent' {
                    # Act
                    $result = $resource.Get()

                    # Assert
                    $result.Server | Should -Be $resourceProperties.Server
                    $result.Name | Should -Be $resourceProperties.Name
                    $result.Location | Should -Be $resourceProperties.Location
                    $result.DatacenterName | Should -Be $resourceProperties.DatacenterName
                    $result.DatacenterLocation | Should -Be $resourceProperties.DatacenterLocation
                    $result.Ensure | Should -Be 'Absent'
                    $result.ReferenceVDSwitchName | Should -BeNullOrEmpty
                    $result.WithoutPortGroups | Should -Be $resourceProperties.WithoutPortGroups
                    $result.ContactDetails | Should -Be $resourceProperties.ContactDetails
                    $result.ContactName | Should -Be $resourceProperties.ContactName
                    $result.LinkDiscoveryProtocol.ToString() | Should -Be $resourceProperties.LinkDiscoveryProtocol.ToString()
                    $result.LinkDiscoveryProtocolOperation.ToString() | Should -Be $resourceProperties.LinkDiscoveryProtocolOperation.ToString()
                    $result.MaxPorts | Should -Be $resourceProperties.MaxPorts
                    $result.Mtu | Should -Be $resourceProperties.Mtu
                    $result.Notes | Should -Be $resourceProperties.Notes
                    $result.NumUplinkPorts | Should -Be $resourceProperties.NumUplinkPorts
                    $result.Version | Should -Be $resourceProperties.Version
                }
            }

            Context 'Invoking with Ensure Absent and existing Distributed Switch' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureAbsentAndExistingDistributedSwitch
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Get()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should retrieve the correct settings from the Server and Ensure should be set to Present' {
                    # Act
                    $result = $resource.Get()

                    # Assert
                    $result.Server | Should -Be $resourceProperties.Server
                    $result.Name | Should -Be $script:constants.DistributedSwitchName
                    $result.Location | Should -Be $resourceProperties.Location
                    $result.DatacenterName | Should -Be $resourceProperties.DatacenterName
                    $result.DatacenterLocation | Should -Be $resourceProperties.DatacenterLocation
                    $result.Ensure | Should -Be 'Present'
                    $result.ReferenceVDSwitchName | Should -BeNullOrEmpty
                    $result.WithoutPortGroups | Should -Be $resourceProperties.WithoutPortGroups
                    $result.ContactDetails | Should -Be $script:constants.DistributedSwitchContactDetails
                    $result.ContactName | Should -Be $script:constants.DistributedSwitchContactName
                    $result.LinkDiscoveryProtocol.ToString() | Should -Be $script:constants.DistributedSwitchLinkDiscoveryProtocol.ToString()
                    $result.LinkDiscoveryProtocolOperation.ToString() | Should -Be $script:constants.DistributedSwitchLinkDiscoveryProtocolOperation.ToString()
                    $result.MaxPorts | Should -Be $script:constants.DistributedSwitchMaxPorts
                    $result.Mtu | Should -Be $script:constants.DistributedSwitchMtu
                    $result.Notes | Should -Be $script:constants.DistributedSwitchNotes
                    $result.NumUplinkPorts | Should -Be $script:constants.DistributedSwitchNumUplinkPorts
                    $result.Version | Should -Be $script:constants.DistributedSwitchVersion
                }
            }
        }
    }
    finally {
        # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
        Invoke-TestCleanup -ModulePath $modulePath
    }
}
