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
        $resourceName = 'VMHostIScsiHba'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
        . "$unitTestsFolder\TestHelpers\Mocks\VMHostIScsiHbaMocks.ps1"

        Describe 'VMHostIScsiHba\Set' -Tag 'Set' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostIScsiHba
            }

            Context 'When error occurs while configuring the iSCSI Host Bus Adapter CHAP settings' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenErrorOccursWhileConfiguringTheiSCSIHostBusAdapterCHAPSettings
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

                It 'Should throw an exception with the correct message when error occurs while configuring the iSCSI Host Bus Adapter CHAP settings' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $resource.Set() } | Should -Throw "Could not configure CHAP settings of iSCSI Host Bus Adapter $($script:constants.IScsiHbaDeviceName) from VMHost $($script:vmHost.Name). For more information: ScriptHalted"
                }
            }

            Context 'When no error occurs while configuring the iSCSI Host Bus Adapter CHAP settings' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenNoErrorOccursWhileConfiguringTheiSCSIHostBusAdapterCHAPSettings
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the Set-VMHostHba mock with the specified iSCSI Host Bus Adapter and CHAP settings once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Set-VMHostHba'
                        ParameterFilter = {
                            $IScsiHba -eq $script:iScsiHba -and
                            $ChapType -eq $script:constants.ChapTypeProhibited -and
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

        Describe 'VMHostIScsiHba\Test' -Tag 'Test' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostIScsiHba
            }

            Context 'When the CHAP settings of the iSCSI Host Bus Adapter do not need to be modified' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTheCHAPSettingsOfTheiSCSIHostBusAdapterDoNotNeedToBeModified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when the CHAP settings of the iSCSI Host Bus Adapter do not need to be modified' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -BeTrue
                }
            }

            Context 'When the CHAP settings of the iSCSI Host Bus Adapter need to be modified' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTheCHAPSettingsOfTheiSCSIHostBusAdapterNeedToBeModified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when the CHAP settings of the iSCSI Host Bus Adapter need to be modified' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -BeFalse
                }
            }
        }

        Describe 'VMHostIScsiHba\Get' -Tag 'Get' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostIScsiHba

                $resourceProperties = New-VMHostIScsiHbaProperties
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
                $result.Name | Should -Be $script:iScsiHba.Device
                $result.ChapType | Should -Be $script:iScsiHba.AuthenticationProperties.ChapType
                $result.ChapName | Should -Be $script:iScsiHba.AuthenticationProperties.ChapName
                $result.MutualChapEnabled | Should -Be $script:iScsiHba.AuthenticationProperties.MutualChapEnabled
                $result.MutualChapName | Should -Be $script:iScsiHba.AuthenticationProperties.MutualChapName
            }
        }
    }
    finally {
        # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
        Invoke-TestCleanup -ModulePath $modulePath
    }
}
