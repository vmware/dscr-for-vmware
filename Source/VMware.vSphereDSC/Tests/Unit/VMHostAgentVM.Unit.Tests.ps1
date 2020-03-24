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
        $resourceName = 'VMHostAgentVM'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
        . "$unitTestsFolder\TestHelpers\Mocks\VMHostAgentVMMocks.ps1"

        Describe 'VMHostAgentVM\Set' -Tag 'Set' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostAgentVMWithEsxAgentHostManagerWithNullAgentVmSettings
            }

            Context 'Invoking with AgentVmDatastore set to $null and AgentVmNetwork set to $null' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-VMHostAgentVMProperties
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Update-AgentVMConfiguration mock once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Update-AgentVMConfiguration'
                        ParameterFilter = { $EsxAgentHostManager -eq $script:esxAgentHostManagerWithNullAgentVmSettings -and $EsxAgentHostManagerConfigInfo -eq $script:esxAgentHostManagerConfigInfoWithNullAgentVmSettings }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Invoking with AgentVmDatastore that is an existing Datastore and AgentVmNetwork that is an existing Network' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenAgentVmDatastoreIsAnExistingDatastoreAndAgentVmNetworkIsAnExistingNetwork
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Update-AgentVMConfiguration mock once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Update-AgentVMConfiguration'
                        ParameterFilter = { $EsxAgentHostManager -eq $script:esxAgentHostManagerWithNullAgentVmSettings -and $EsxAgentHostManagerConfigInfo -eq $script:esxAgentHostManagerConfigWithNotNullAgentVmSettings }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Invoking with AgentVmDatastore that is not an exisitng Datastore' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenAgentVmDatastoreIsNotAnExistingDatastore
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    try {
                        # Act
                        $resource.Set()
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw the correct error when the Datastore does not exist' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $resource.Set() } | Should -Throw "Could not retrieve Datastore $($resourceProperties.AgentVmDatastore) for VMHost $($script:vmHost.Name). For more information: ScriptHalted"
                }
            }

            Context 'Invoking with AgentVmNetwork that is not an existing Network' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenAgentVmNetworkIsNotAnExistingNetwork
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    try {
                        # Act
                        $resource.Set()
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw the correct error when the Network does not exist' {
                    # Act && Assert
                    { $resource.Set() } | Should -Throw "Could not find Network $($resourceProperties.AgentVmNetwork) for VMHost $($script:vmHost.Name)."
                }
            }
        }

        Describe 'VMHostAgentVM\Test' -Tag 'Test' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostAgentVM
            }

            Context 'Invoking with AgentVm Settings set to $null and Server values not equal to $null' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenAgentVmSettingsAreSetToNullAndServerValuesAreNotEqualToNull
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when AgentVm Settings are set to $null and Server values are not equal to $null' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'Invoking with AgentVm Settings set to $null and Server values equal to $null' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenAgentVmSettingsAreSetToNullAndServerValuesAreEqualToNull
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when AgentVm Settings are set to $null and Server values are equal to $null' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }

            Context 'Invoking with AgentVm Settings not set to $null and Server values equal to $null' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenAgentVmSettingsAreNotSetToNullAndServerValuesAreEqualToNull
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when AgentVm Settings are not set to $null and Server values are equal to $null' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'Invoking with AgentVm Settings not equal to Server values' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenAgentVmSettingsAreNotEqualToServerValues
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when AgentVm Settings are not equal to Server values' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'Invoking with AgentVm Settings equal to Server values' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenAgentVmSettingsAreEqualToServerValues
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when AgentVm Settings are equal to Server values' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }
        }

        Describe 'VMHostAgentVM\Get' -Tag 'Get' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostAgentVM
            }

            Context 'Invoking with AgentVm Settings from the Server equal to $null' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenAgentVmSettingsFromTheServerAreEqualToNull
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Get()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should retrieve the correct settings from the Server' {
                    # Act
                    $result = $resource.Get()

                    # Assert
                    $result.Server | Should -Be $resourceProperties.Server
                    $result.Name | Should -Be $script:constants.VMHostName

                    <#
                    In the Resource Implementation when setting the property value to $null,
                    PowerShell converts it to an empty string, so the comparison should be against
                    empty string instead of $null.
                    #>
                    $agentVmSettingEmptyValue = [string]::Empty

                    $result.AgentVmDatastore | Should -Be $agentVmSettingEmptyValue
                    $result.AgentVmNetwork | Should -Be $agentVmSettingEmptyValue
                }
            }

            Context 'Invoking with AgentVm Settings from the Server not equal to $null' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenAgentVmSettingsFromTheServerAreNotEqualToNull
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Get()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should retrieve the correct settings from the Server' {
                    # Act
                    $result = $resource.Get()

                    # Assert
                    $result.Server | Should -Be $resourceProperties.Server
                    $result.Name | Should -Be $script:constants.VMHostName
                    $result.AgentVmDatastore | Should -Be $script:constants.DatastoreName
                    $result.AgentVmNetwork | Should -Be $script:constants.NetworkName
                }
            }
        }
    }
    finally {
        # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
        Invoke-TestCleanup -ModulePath $modulePath
    }
}
