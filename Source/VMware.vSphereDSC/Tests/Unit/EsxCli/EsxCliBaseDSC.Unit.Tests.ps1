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
        $esxCliBaseDSCClassName = 'EsxCliBaseDSC'
        $esxCliBaseDSCChildClassName = 'EsxCliBaseDSCChild'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
        . "$unitTestsFolder\TestHelpers\Mocks\EsxCliBaseDSCMocks.ps1"

        Describe 'EsxCliBaseDSC\GetEsxCli' -Tag 'GetEsxCli' {
            BeforeAll {
                # Arrange
                New-MocksForEsxCliBaseDSC
            }

            Context 'When error occurs while retrieving the EsxCli interface' {
                BeforeAll {
                    # Arrange
                    $esxCliBaseDSCProperties = New-MocksWhenErrorOccursWhileRetrievingTheEsxCliInterface
                    $esxCliBaseDSC = New-Object -TypeName $esxCliBaseDSCClassName -Property $esxCliBaseDSCProperties

                    $esxCliBaseDSC.ConnectVIServer()
                    $vmHost = $esxCliBaseDSC.GetVMHost()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    try {
                        # Act
                        $esxCliBaseDSC.GetEsxCli($vmHost)
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw an exception with the correct message when error occurs while retrieving the EsxCli interface' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $esxCliBaseDSC.GetEsxCli($vmHost) } | Should -Throw "Could not retrieve EsxCli interface for VMHost $($script:vmHost.Name). For more information: ScriptHalted"
                }
            }

            Context 'When the EsxCli interface is retrieved successfully' {
                BeforeAll {
                    # Arrange
                    $esxCliBaseDSCProperties = New-MocksWhenTheEsxCliInterfaceIsRetrievedSuccessfully
                    $esxCliBaseDSC = New-Object -TypeName $esxCliBaseDSCClassName -Property $esxCliBaseDSCProperties

                    $esxCliBaseDSC.ConnectVIServer()
                    $vmHost = $esxCliBaseDSC.GetVMHost()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $esxCliBaseDSC.GetEsxCli($vmHost)

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should populate the EsxCli property of the class with the EsxCli interface' {
                    # Act
                    $esxCliBaseDSC.GetEsxCli($vmHost)

                    # Assert
                    $esxCliBaseDSC.EsxCli | Should -Be $script:esxCli
                }
            }
        }

        Describe 'EsxCliBaseDSC\ExecuteEsxCliModifyMethod' -Tag 'ExecuteEsxCliModifyMethod' {
            BeforeAll {
                # Arrange
                New-MocksForEsxCliBaseDSC

                # A child class is needed to test the arguments population inside ExecuteEsxCliModifyMethod().
                class EsxCliBaseDSCChild : EsxCliBaseDSC {
                    [string] $Layout
                    [nullable[bool]] $Enable
                    [nullable[long]] $Size
                    [int[]] $ParameterKeys
                }
            }

            Context 'When error occurs while creating the arguments for the EsxCli command' {
                BeforeAll {
                    # Arrange
                    $esxCliBaseDSCProperties = New-MocksWhenErrorOccursWhileCreatingTheArgumentsForTheEsxCliCommand
                    $esxCliBaseDSC = New-Object -TypeName $esxCliBaseDSCClassName -Property $esxCliBaseDSCProperties

                    $esxCliBaseDSC.EsxCliCommand = $script:constants.EsxCliDCUIKeyboardCommand

                    $esxCliBaseDSC.ConnectVIServer()
                    $vmHost = $esxCliBaseDSC.GetVMHost()
                    $esxCliBaseDSC.GetEsxCli($vmHost)
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    try {
                        # Act
                        $esxCliBaseDSC.ExecuteEsxCliModifyMethod($script:constants.EsxCliCommandSetMethodName)
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw an exception with the correct message when error occurs while creating the arguments for the EsxCli command' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $esxCliBaseDSC.ExecuteEsxCliModifyMethod($script:constants.EsxCliCommandSetMethodName) } | Should -Throw "Could not create arguments for $($script:constants.EsxCliCommandSetMethodName) method. For more information: ScriptHalted"
                }
            }

            Context 'When error occurs while invoking the EsxCli command method' {
                BeforeAll {
                    # Arrange
                    $esxCliBaseDSCProperties = New-MocksWhenErrorOccursWhileInvokingTheEsxCliCommandMethod
                    $esxCliBaseDSC = New-Object -TypeName $esxCliBaseDSCClassName -Property $esxCliBaseDSCProperties

                    $esxCliBaseDSC.EsxCliCommand = $script:constants.EsxCliDCUIKeyboardCommand

                    $esxCliBaseDSC.ConnectVIServer()
                    $vmHost = $esxCliBaseDSC.GetVMHost()
                    $esxCliBaseDSC.GetEsxCli($vmHost)
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    try {
                        # Act
                        $esxCliBaseDSC.ExecuteEsxCliModifyMethod($script:constants.EsxCliCommandSetMethodName)
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw an exception with the correct message when error occurs while invoking the EsxCli command method' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $esxCliBaseDSC.ExecuteEsxCliModifyMethod($script:constants.EsxCliCommandSetMethodName) } | Should -Throw "EsxCli command esxcli.$($script:constants.EsxCliDCUIKeyboardCommand) failed to execute successfully. For more information: ScriptHalted"
                }
            }

            Context 'When the EsxCli command method is executed successfully' {
                BeforeAll {
                    # Arrange
                    $esxCliBaseDSCChildProperties = New-MocksWhenTheEsxCliCommandMethodIsExecutedSuccessfully
                    $esxCliBaseDSCChild = New-Object -TypeName $esxCliBaseDSCChildClassName -Property $esxCliBaseDSCChildProperties

                    $esxCliBaseDSCChild.Layout = $script:constants.EsxCliSetMethodPopulatedArgs.layout
                    $esxCliBaseDSCChild.Size = $script:constants.EsxCliSetMethodPopulatedArgs.size
                    $esxCliBaseDSCChild.ParameterKeys = $script:constants.EsxCliSetMethodPopulatedArgs.parameterkeys
                    $esxCliBaseDSCChild.EsxCliCommand = $script:constants.EsxCliDCUIKeyboardCommand

                    $esxCliBaseDSCChild.ConnectVIServer()
                    $vmHost = $esxCliBaseDSCChild.GetVMHost()
                    $esxCliBaseDSCChild.GetEsxCli($vmHost)
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $esxCliBaseDSCChild.ExecuteEsxCliModifyMethod($script:constants.EsxCliCommandSetMethodName)

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the Invoke-EsxCliCommandMethod mock with the specified EsxCli command method and arguments hashtable once' {
                    # Act
                    $esxCliBaseDSCChild.ExecuteEsxCliModifyMethod($script:constants.EsxCliCommandSetMethodName)

                    # Assert

                    # The 'enable' key of the arguments hashtable is not populated, so it should have a default value in the cloned arguments hashtable before the comparison.
                    $expectedEsxCliSetMethodArgs = $script:constants.EsxCliSetMethodPopulatedArgs.Clone()
                    $expectedEsxCliSetMethodArgs.enable = $script:constants.EsxCliSetMethodArgs.enable

                    $assertMockCalledParams = @{
                        CommandName = 'Invoke-EsxCliCommandMethod'
                        ParameterFilter = {
                            $EsxCli -eq $script:esxCli -and
                            $EsxCliCommandMethod -eq $script:constants.EsxCliSetMethodInvoke -and
                            (Compare-Hashtables -HashtableOne $EsxCliCommandMethodArguments -HashtableTwo $expectedEsxCliSetMethodArgs)
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }
        }

        Describe 'EsxCliBaseDSC\ExecuteEsxCliRetrievalMethod' -Tag 'ExecuteEsxCliRetrievalMethod' {
            BeforeAll {
                # Arrange
                New-MocksForEsxCliBaseDSC
            }

            Context 'When error occurs while invoking the EsxCli command retrieval method' {
                BeforeAll {
                    # Arrange
                    $esxCliBaseDSCProperties = New-MocksWhenErrorOccursWhileInvokingTheEsxCliCommandRetrievalMethod
                    $esxCliBaseDSC = New-Object -TypeName $esxCliBaseDSCClassName -Property $esxCliBaseDSCProperties

                    $esxCliBaseDSC.EsxCliCommand = $script:constants.EsxCliDCUIKeyboardCommand

                    $esxCliBaseDSC.ConnectVIServer()
                    $vmHost = $esxCliBaseDSC.GetVMHost()
                    $esxCliBaseDSC.GetEsxCli($vmHost)
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    try {
                        # Act
                        $esxCliBaseDSC.ExecuteEsxCliRetrievalMethod($script:constants.EsxCliCommandGetMethodName)
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw an exception with the correct message when error occurs while invoking the EsxCli command method' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $esxCliBaseDSC.ExecuteEsxCliRetrievalMethod($script:constants.EsxCliCommandGetMethodName) } | Should -Throw "EsxCli command esxcli.$($script:constants.EsxCliDCUIKeyboardCommand) failed to execute successfully. For more information: ScriptHalted"
                }
            }

            Context 'When the EsxCli command retrieval method is executed successfully' {
                BeforeAll {
                    # Arrange
                    $esxCliBaseDSCProperties = New-MocksWhenTheEsxCliCommandRetrievalMethodIsExecutedSuccessfully
                    $esxCliBaseDSC = New-Object -TypeName $esxCliBaseDSCClassName -Property $esxCliBaseDSCProperties

                    $esxCliBaseDSC.EsxCliCommand = $script:constants.EsxCliDCUIKeyboardCommand

                    $esxCliBaseDSC.ConnectVIServer()
                    $vmHost = $esxCliBaseDSC.GetVMHost()
                    $esxCliBaseDSC.GetEsxCli($vmHost)
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $esxCliBaseDSC.ExecuteEsxCliRetrievalMethod($script:constants.EsxCliCommandGetMethodName)

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return the correct retrieval method result' {
                    # Act
                    $esxCliGetMethodResult = $esxCliBaseDSC.ExecuteEsxCliRetrievalMethod($script:constants.EsxCliCommandGetMethodName)

                    # Assert
                    $esxCliGetMethodResult | Should -Be $script:constants.DCUIKeyboardUSDefaultLayout
                }
            }
        }
    }
    finally {
        # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
        Invoke-TestCleanup -ModulePath $modulePath
    }
}
