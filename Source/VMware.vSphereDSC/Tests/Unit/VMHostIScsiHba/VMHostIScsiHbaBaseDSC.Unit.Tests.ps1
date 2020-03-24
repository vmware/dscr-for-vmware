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
        $vmHostIScsiHbaBaseDSCClassName = 'VMHostIScsiHbaBaseDSC'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
        . "$unitTestsFolder\TestHelpers\Mocks\VMHostIScsiHbaBaseDSCMocks.ps1"

        Describe 'VMHostIScsiHbaBaseDSCBaseDSC\GetIScsiHba' -Tag 'GetIScsiHba' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostIScsiHbaBaseDSC
            }

            Context 'When error occurs while retrieving the iSCSI Host Bus Adapter' {
                BeforeAll {
                    # Arrange
                    $vmHostIScsiHbaBaseDSCProperties = New-MocksWhenErrorOccursWhileRetrievingTheiSCSIHostBusAdapter
                    $vmHostIScsiHbaBaseDSC = New-Object -TypeName $vmHostIScsiHbaBaseDSCClassName -Property $vmHostIScsiHbaBaseDSCProperties

                    $vmHostIScsiHbaBaseDSC.ConnectVIServer()
                    $vmHostIScsiHbaBaseDSC.RetrieveVMHost()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    try {
                        # Act
                        $vmHostIScsiHbaBaseDSC.GetIScsiHba($script:constants.IScsiHbaDeviceName)
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw an exception with the correct message when error occurs while retrieving the iSCSI Host Bus Adapter' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $vmHostIScsiHbaBaseDSC.GetIScsiHba($script:constants.IScsiHbaDeviceName) } | Should -Throw "Could not retrieve iSCSI Host Bus Adapter $($script:constants.IScsiHbaDeviceName) from VMHost $($script:vmHost.Name). For more information: ScriptHalted"
                }
            }

            Context 'When the iSCSI Host Bus Adapter is retrieved successfully' {
                BeforeAll {
                    # Arrange
                    $vmHostIScsiHbaBaseDSCProperties = New-MocksWhenTheiSCSIHostBusAdapterIsRetrievedSuccessfully
                    $vmHostIScsiHbaBaseDSC = New-Object -TypeName $vmHostIScsiHbaBaseDSCClassName -Property $vmHostIScsiHbaBaseDSCProperties

                    $vmHostIScsiHbaBaseDSC.ConnectVIServer()
                    $vmHostIScsiHbaBaseDSC.RetrieveVMHost()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $vmHostIScsiHbaBaseDSC.GetIScsiHba($script:constants.IScsiHbaDeviceName)

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return the iSCSI Host Bus Adapter with the specified name when the iSCSI Host Bus Adapter exists' {
                    # Act
                    $iScsiHba = $vmHostIScsiHbaBaseDSC.GetIScsiHba($script:constants.IScsiHbaDeviceName)

                    # Assert
                    $iScsiHba | Should -Be $script:iScsiHba
                }
            }
        }

        Describe 'VMHostIScsiHbaBaseDSCBaseDSC\ShouldModifyCHAPSettings' -Tag 'ShouldModifyCHAPSettings' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostIScsiHbaBaseDSC
            }

            Context 'When the CHAP settings of the iSCSI Host Bus Adapter do not need to be modified' {
                BeforeAll {
                    # Arrange
                    $vmHostIScsiHbaBaseDSCProperties = New-MocksWhenTheCHAPSettingsOfTheiSCSIHostBusAdapterDoNotNeedToBeModified
                    $vmHostIScsiHbaBaseDSC = New-Object -TypeName $vmHostIScsiHbaBaseDSCClassName -Property $vmHostIScsiHbaBaseDSCProperties

                    $vmHostIScsiHbaBaseDSC.ConnectVIServer()
                    $vmHostIScsiHbaBaseDSC.RetrieveVMHost()
                }

                It 'Should return $false when the CHAP settings of the iSCSI Host Bus Adapter do not need to be modified' {
                    # Act
                    $result = $vmHostIScsiHbaBaseDSC.ShouldModifyCHAPSettings($script:iScsiHba.AuthenticationProperties, $null, $null)

                    # Assert
                    $result | Should -BeFalse
                }
            }

            Context 'When the CHAP settings of the iSCSI Host Bus Adapter need to be modified' {
                BeforeAll {
                    # Arrange
                    $vmHostIScsiHbaBaseDSCProperties = New-MocksWhenTheCHAPSettingsOfTheiSCSIHostBusAdapterNeedToBeModified
                    $vmHostIScsiHbaBaseDSC = New-Object -TypeName $vmHostIScsiHbaBaseDSCClassName -Property $vmHostIScsiHbaBaseDSCProperties

                    $vmHostIScsiHbaBaseDSC.ConnectVIServer()
                    $vmHostIScsiHbaBaseDSC.RetrieveVMHost()
                }

                It 'Should return $true when the CHAP settings of the iSCSI Host Bus Adapter need to be modified' {
                    # Act
                    $result = $vmHostIScsiHbaBaseDSC.ShouldModifyCHAPSettings($script:iScsiHba.AuthenticationProperties, $null, $null)

                    # Assert
                    $result | Should -BeTrue
                }
            }
        }

        Describe 'VMHostIScsiHbaBaseDSCBaseDSC\PopulateCmdletParametersWithCHAPSettings' -Tag 'PopulateCmdletParametersWithCHAPSettings' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostIScsiHbaBaseDSC
            }

            Context 'When InheritChap and InheritMutualChap are not specified and ChapType is Required' {
                BeforeAll {
                    # Arrange
                    $vmHostIScsiHbaBaseDSCProperties = New-MocksWhenInheritChapAndInheritMutualChapAreNotSpecifiedAndChapTypeIsRequired
                    $vmHostIScsiHbaBaseDSC = New-Object -TypeName $vmHostIScsiHbaBaseDSCClassName -Property $vmHostIScsiHbaBaseDSCProperties

                    $vmHostIScsiHbaBaseDSC.ConnectVIServer()
                    $vmHostIScsiHbaBaseDSC.RetrieveVMHost()
                    $cmdletParams = @{}
                }

                It 'Should populate the cmdlet parameters hashtable with the CHAP and MutualCHAP settings' {
                    # Act
                    $vmHostIScsiHbaBaseDSC.PopulateCmdletParametersWithCHAPSettings($cmdletParams, $null, $null)

                    # Assert
                    $cmdletParams.Keys.Count | Should -Be 6
                    $cmdletParams.ChapType | Should -Be $script:constants.ChapTypeRequired
                    $cmdletParams.ChapName | Should -Be $script:constants.ChapName
                    $cmdletParams.ChapPassword | Should -Be $script:constants.ChapPassword
                    $cmdletParams.MutualChapEnabled | Should -Be $script:constants.MutualChapEnabled
                    $cmdletParams.MutualChapName | Should -Be $script:constants.MutualChapName
                    $cmdletParams.MutualChapPassword | Should -Be $script:constants.MutualChapPassword
                }
            }

            Context 'When InheritChap and InheritMutualChap are not specified and ChapType is Prohibited' {
                BeforeAll {
                    # Arrange
                    $vmHostIScsiHbaBaseDSCProperties = New-MocksWhenInheritChapAndInheritMutualChapAreNotSpecifiedAndChapTypeIsProhibited
                    $vmHostIScsiHbaBaseDSC = New-Object -TypeName $vmHostIScsiHbaBaseDSCClassName -Property $vmHostIScsiHbaBaseDSCProperties

                    $vmHostIScsiHbaBaseDSC.ConnectVIServer()
                    $vmHostIScsiHbaBaseDSC.RetrieveVMHost()
                    $cmdletParams = @{}
                }

                It 'Should populate the cmdlet parameters hashtable without the CHAP and MutualCHAP settings' {
                    # Act
                    $vmHostIScsiHbaBaseDSC.PopulateCmdletParametersWithCHAPSettings($cmdletParams, $null, $null)

                    # Assert
                    $cmdletParams.Keys.Count | Should -Be 1
                    $cmdletParams.ChapType | Should -Be $script:constants.ChapTypeProhibited
                }
            }

            Context 'When InheritChap and InheritMutualChap are not specified, ChapType is Required and MutualChapEnabled is $false' {
                BeforeAll {
                    # Arrange
                    $vmHostIScsiHbaBaseDSCProperties = New-MocksWhenInheritChapAndInheritMutualChapAreNotSpecifiedChapTypeIsRequiredAndMutualChapEnabledIsFalse
                    $vmHostIScsiHbaBaseDSC = New-Object -TypeName $vmHostIScsiHbaBaseDSCClassName -Property $vmHostIScsiHbaBaseDSCProperties

                    $vmHostIScsiHbaBaseDSC.ConnectVIServer()
                    $vmHostIScsiHbaBaseDSC.RetrieveVMHost()
                    $cmdletParams = @{}
                }

                It 'Should populate the cmdlet parameters hashtable with the CHAP settings and without the MutualChapName and MutualChapPassword settings' {
                    # Act
                    $vmHostIScsiHbaBaseDSC.PopulateCmdletParametersWithCHAPSettings($cmdletParams, $null, $null)

                    # Assert
                    $cmdletParams.Keys.Count | Should -Be 4
                    $cmdletParams.ChapType | Should -Be $script:constants.ChapTypeRequired
                    $cmdletParams.ChapName | Should -Be $script:constants.ChapName
                    $cmdletParams.ChapPassword | Should -Be $script:constants.ChapPassword
                    $cmdletParams.MutualChapEnabled | Should -Be (!$script:constants.MutualChapEnabled)
                }
            }

            Context 'When InheritChap and InheritMutualChap are both specified with $false value' {
                BeforeAll {
                    # Arrange
                    $vmHostIScsiHbaBaseDSCProperties = New-MocksWhenInheritChapAndInheritMutualChapAreBothSpecifiedWithFalseValue
                    $vmHostIScsiHbaBaseDSC = New-Object -TypeName $vmHostIScsiHbaBaseDSCClassName -Property $vmHostIScsiHbaBaseDSCProperties

                    $vmHostIScsiHbaBaseDSC.ConnectVIServer()
                    $vmHostIScsiHbaBaseDSC.RetrieveVMHost()
                    $cmdletParams = @{}
                }

                It 'Should populate the cmdlet parameters hashtable with the CHAP, MutualCHAP, InheritChap and InheritMutualChap settings' {
                    # Act
                    $vmHostIScsiHbaBaseDSC.PopulateCmdletParametersWithCHAPSettings($cmdletParams, !$script:constants.ChapInherited, !$script:constants.MutualChapInherited)

                    # Assert
                    $cmdletParams.Keys.Count | Should -Be 8
                    $cmdletParams.ChapType | Should -Be $script:constants.ChapTypeRequired
                    $cmdletParams.InheritChap | Should -Be (!$script:constants.ChapInherited)
                    $cmdletParams.ChapName | Should -Be $script:constants.ChapName
                    $cmdletParams.ChapPassword | Should -Be $script:constants.ChapPassword
                    $cmdletParams.InheritMutualChap | Should -Be (!$script:constants.MutualChapInherited)
                    $cmdletParams.MutualChapEnabled | Should -Be $script:constants.MutualChapEnabled
                    $cmdletParams.MutualChapName | Should -Be $script:constants.MutualChapName
                    $cmdletParams.MutualChapPassword | Should -Be $script:constants.MutualChapPassword
                }
            }

            Context 'When InheritChap and InheritMutualChap are both specified with $true value' {
                BeforeAll {
                    # Arrange
                    $vmHostIScsiHbaBaseDSCProperties = New-MocksWhenInheritChapAndInheritMutualChapAreBothSpecifiedWithTrueValue
                    $vmHostIScsiHbaBaseDSC = New-Object -TypeName $vmHostIScsiHbaBaseDSCClassName -Property $vmHostIScsiHbaBaseDSCProperties

                    $vmHostIScsiHbaBaseDSC.ConnectVIServer()
                    $vmHostIScsiHbaBaseDSC.RetrieveVMHost()
                    $cmdletParams = @{}
                }

                It 'Should populate the cmdlet parameters hashtable with the InheritChap and InheritMutualChap settings and without the CHAP and Mutual CHAP settings' {
                    # Act
                    $vmHostIScsiHbaBaseDSC.PopulateCmdletParametersWithCHAPSettings($cmdletParams, $script:constants.ChapInherited, $script:constants.MutualChapInherited)

                    # Assert
                    $cmdletParams.Keys.Count | Should -Be 2
                    $cmdletParams.InheritChap | Should -Be $script:constants.ChapInherited
                    $cmdletParams.InheritMutualChap | Should -Be $script:constants.MutualChapInherited
                }
            }
        }
    }
    finally {
        # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
        Invoke-TestCleanup -ModulePath $modulePath
    }
}
