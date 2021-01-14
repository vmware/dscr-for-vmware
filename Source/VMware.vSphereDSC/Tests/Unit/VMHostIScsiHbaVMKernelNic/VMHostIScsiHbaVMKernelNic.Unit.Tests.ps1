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
        $script:DscResourceName = 'VMHostIScsiHbaVMKernelNic'

        . (Join-Path -Path $PSScriptRoot -ChildPath 'VMHostIScsiHbaVMKernelNic.Mocks.Data.ps1')
        . (Join-Path -Path $PSScriptRoot -ChildPath 'VMHostIScsiHbaVMKernelNic.Mocks.ps1')

        Describe "$script:DscResourceName\Set" -Tag 'Set' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostIScsiHbaVMKernelNicDscResource
            }

            Context 'When Ensure is Present and two VMKernel Network Adapters are passed, one bound and one unbound' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsPresentAndTwoVMKernelNetworkAdaptersArePassedOneBoundAndOneUnbound
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResource.Set()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the Update-IScsiHbaBoundNics mock with the iSCSI Host Bus Adapter and unbound VMKernel Network Adapter once' {
                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Update-IScsiHbaBoundNics'
                        ParameterFilter = {
                            $EsxCli -eq $script:EsxCli -and
                            $IScsiHbaName -eq $script:IScsiHba.Device -and
                            $VMKernelNicName -eq $script:UnboundVMKernelNic.Name -and
                            $Operation -eq 'Add' -and
                            $Force -eq $null
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'Context'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'When Ensure is Absent and two VMKernel Network Adapters are passed, one bound and one unbound' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsAbsentAndTwoVMKernelNetworkAdaptersArePassedOneBoundAndOneUnbound
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResource.Set()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should invoke the Update-IScsiHbaBoundNics mock with the iSCSI Host Bus Adapter and bound VMKernel Network Adapter once' {
                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Update-IScsiHbaBoundNics'
                        ParameterFilter = {
                            $EsxCli -eq $script:EsxCli -and
                            $IScsiHbaName -eq $script:IScsiHba.Device -and
                            $VMKernelNicName -eq $script:BoundVMKernelNic.Name -and
                            $Operation -eq 'Remove' -and
                            $Force -eq $true
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
                New-MocksForVMHostIScsiHbaVMKernelNicDscResource
            }

            Context 'When Ensure is Present and two VMKernel Network Adapters are passed, one bound and one unbound' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsPresentAndTwoVMKernelNetworkAdaptersArePassedOneBoundAndOneUnbound
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResourceTestMethodResult = $dscResource.Test()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when Ensure is Present and two VMKernel Network Adapters are passed, one bound and one unbound' {
                    # Assert
                    $dscResourceTestMethodResult | Should -BeFalse
                }
            }

            Context 'When Ensure is Absent and two VMKernel Network Adapters are passed, one bound and one unbound' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsAbsentAndTwoVMKernelNetworkAdaptersArePassedOneBoundAndOneUnbound
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResourceTestMethodResult = $dscResource.Test()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when Ensure is Absent and two VMKernel Network Adapters are passed, one bound and one unbound' {
                    # Assert
                    $dscResourceTestMethodResult | Should -BeFalse
                }
            }

            Context 'When Ensure is Present and one bound VMKernel Network Adapter is passed' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsPresentAndOneBoundVMKernelNetworkAdapterIsPassed
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResourceTestMethodResult = $dscResource.Test()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when Ensure is Present and one bound VMKernel Network Adapter is passed' {
                    # Assert
                    $dscResourceTestMethodResult | Should -BeTrue
                }
            }

            Context 'When Ensure is Absent and one unbound VMKernel Network Adapter is passed' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenEnsureIsAbsentAndOneUnboundVMKernelNetworkAdapterIsPassed
                    $dscResource = New-Object -TypeName $script:DscResourceName -Property $dscResourceProperties

                    # Act
                    $dscResourceTestMethodResult = $dscResource.Test()
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when Ensure is Absent and one unbound VMKernel Network Adapter is passed' {
                    # Assert
                    $dscResourceTestMethodResult | Should -BeTrue
                }
            }
        }

        Describe "$script:DscResourceName\Get" -Tag 'Get' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostIScsiHbaVMKernelNicDscResource
            }

            Context 'When iSCSI Host Bus Adapter without bound VMKernel Network Adapters is passed' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenIScsiHostBusAdapterWithoutBoundVMKernelNetworkAdaptersIsPassed
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
                    $dscResourceGetMethodResult.VMHostName | Should -Be $dscResourceProperties.VMHostName
                    $dscResourceGetMethodResult.IScsiHbaName | Should -Be $dscResourceProperties.IScsiHbaName
                    $dscResourceGetMethodResult.VMKernelNicNames | Should -Be $dscResourceProperties.VMKernelNicNames
                    $dscResourceGetMethodResult.Ensure | Should -Be 'Absent'
                    $dscResourceGetMethodResult.Force | Should -BeNullOrEmpty
                }
            }

            Context 'When iSCSI Host Bus Adapter with bound VMKernel Network Adapters is passed' {
                BeforeAll {
                    # Arrange
                    $dscResourceProperties = New-MocksWhenIScsiHostBusAdapterWithBoundVMKernelNetworkAdaptersIsPassed
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
                    $dscResourceGetMethodResult.VMHostName | Should -Be $dscResourceProperties.VMHostName
                    $dscResourceGetMethodResult.IScsiHbaName | Should -Be $dscResourceProperties.IScsiHbaName
                    $dscResourceGetMethodResult.VMKernelNicNames | Should -Be @($script:Constants.BoundVMKernelNicName)
                    $dscResourceGetMethodResult.Ensure | Should -Be 'Present'
                    $dscResourceGetMethodResult.Force | Should -BeFalse
                }
            }
        }
    }
}
finally {
    # Removes the mocked 'VMware.VimAutomation.Core' module from the current session after all tests have executed.
    Invoke-TestCleanup -ModulePath $script:PSModulePath
}
