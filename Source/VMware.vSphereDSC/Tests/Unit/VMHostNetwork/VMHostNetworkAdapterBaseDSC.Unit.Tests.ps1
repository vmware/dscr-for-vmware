<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

using module VMware.vSphereDSC

$script:moduleName = 'VMware.vSphereDSC'

InModuleScope -ModuleName $script:moduleName {
    try {
        $unitTestsFolder = Join-Path (Join-Path (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase 'Tests') 'Unit'
        $modulePath = $env:PSModulePath
        $vmHostNetworkAdapterBaseDSCClassName = 'VMHostNetworkAdapterBaseDSC'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
        . "$unitTestsFolder\TestHelpers\Mocks\VMHostNetworkAdapterBaseDSCMocks.ps1"

        Describe 'VMHostNetworkAdapterBaseDSC\GetVMHostNetworkAdapter' -Tag 'GetVMHostNetworkAdapter' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostNetworkAdapterBaseDSC
            }

            Context 'Invoking with existing VMKernel Network Adapter' {
                BeforeAll {
                    # Arrange
                    $vmHostNetworkAdapterBaseDSCProperties = New-MocksWhenVMKernelNetworkAdapterExists
                    $vmHostNetworkAdapterBaseDSC = New-Object -TypeName $vmHostNetworkAdapterBaseDSCClassName -Property $vmHostNetworkAdapterBaseDSCProperties

                    $vmHostNetworkAdapterBaseDSC.ConnectVIServer()
                    $vmHost = $vmHostNetworkAdapterBaseDSC.GetVMHost()
                    $virtualSwitch = $vmHostNetworkAdapterBaseDSC.GetVirtualSwitch($vmHost, $vmHostNetworkAdapterBaseDSCProperties.VirtualSwitch)
                }

                It 'Should call all defined mocks' {
                    # Act
                    $vmHostNetworkAdapterBaseDSC.GetVMHostNetworkAdapter($vmHost, $virtualSwitch)

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return the VMKernel Network Adapter from the server' {
                    # Act
                    $vmHostNetworkAdapter = $vmHostNetworkAdapterBaseDSC.GetVMHostNetworkAdapter($vmHost, $virtualSwitch)

                    # Assert
                    $vmHostNetworkAdapter | Should -Be $script:vmHostNetworkAdapter
                }
            }

            Context 'Invoking with non existing VMKernel Network Adapter' {
                BeforeAll {
                    # Arrange
                    $vmHostNetworkAdapterBaseDSCProperties = New-MocksWhenVMKernelNetworkAdapterDoesNotExist
                    $vmHostNetworkAdapterBaseDSC = New-Object -TypeName $vmHostNetworkAdapterBaseDSCClassName -Property $vmHostNetworkAdapterBaseDSCProperties

                    $vmHostNetworkAdapterBaseDSC.ConnectVIServer()
                    $vmHost = $vmHostNetworkAdapterBaseDSC.GetVMHost()
                    $virtualSwitch = $vmHostNetworkAdapterBaseDSC.GetVirtualSwitch($vmHost, $vmHostNetworkAdapterBaseDSCProperties.VirtualSwitch)
                }

                It 'Should call all defined mocks' {
                    # Act
                    $vmHostNetworkAdapterBaseDSC.GetVMHostNetworkAdapter($vmHost, $virtualSwitch)

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $null' {
                    # Act
                    $vmHostNetworkAdapter = $vmHostNetworkAdapterBaseDSC.GetVMHostNetworkAdapter($vmHost, $virtualSwitch)

                    # Assert
                    $vmHostNetworkAdapter | Should -BeNullOrEmpty
                }
            }
        }

        Describe 'VMHostNetworkAdapterBaseDSC\ShouldUpdateVMHostNetworkAdapter' -Tag 'ShouldUpdateVMHostNetworkAdapter' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostNetworkAdapterBaseDSC
            }

            Context 'Invoking with matching VMKernel Network Adapter settings' {
                BeforeAll {
                    # Arrange
                    $vmHostNetworkAdapterBaseDSCProperties = New-MocksWhenVMKernelNetworkAdapterSettingsMatch
                    $vmHostNetworkAdapterBaseDSC = New-Object -TypeName $vmHostNetworkAdapterBaseDSCClassName -Property $vmHostNetworkAdapterBaseDSCProperties

                    $vmHostNetworkAdapterBaseDSC.ConnectVIServer()
                    $vmHost = $vmHostNetworkAdapterBaseDSC.GetVMHost()
                    $virtualSwitch = $vmHostNetworkAdapterBaseDSC.GetVirtualSwitch($vmHost, $vmHostNetworkAdapterBaseDSCProperties.VirtualSwitch)
                    $vmHostNetworkAdapter = $vmHostNetworkAdapterBaseDSC.GetVMHostNetworkAdapter($vmHost, $virtualSwitch)
                }

                It 'Should call all defined mocks' {
                    # Act
                    $vmHostNetworkAdapterBaseDSC.ShouldUpdateVMHostNetworkAdapter($vmHostNetworkAdapter)

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when VMKernel Network Adapter settings match' {
                    # Act
                    $result = $vmHostNetworkAdapterBaseDSC.ShouldUpdateVMHostNetworkAdapter($vmHostNetworkAdapter)

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'Invoking with non matching VMKernel Network Adapter settings' {
                BeforeAll {
                    # Arrange
                    $vmHostNetworkAdapterBaseDSCProperties = New-MocksWhenVMKernelNetworkAdapterSettingsDoesNotMatch
                    $vmHostNetworkAdapterBaseDSC = New-Object -TypeName $vmHostNetworkAdapterBaseDSCClassName -Property $vmHostNetworkAdapterBaseDSCProperties

                    $vmHostNetworkAdapterBaseDSC.ConnectVIServer()
                    $vmHost = $vmHostNetworkAdapterBaseDSC.GetVMHost()
                    $virtualSwitch = $vmHostNetworkAdapterBaseDSC.GetVirtualSwitch($vmHost, $vmHostNetworkAdapterBaseDSCProperties.VirtualSwitch)
                    $vmHostNetworkAdapter = $vmHostNetworkAdapterBaseDSC.GetVMHostNetworkAdapter($vmHost, $virtualSwitch)
                }

                It 'Should call all defined mocks' {
                    # Act
                    $vmHostNetworkAdapterBaseDSC.ShouldUpdateVMHostNetworkAdapter($vmHostNetworkAdapter)

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when VMKernel Network Adapter settings does not match' {
                    # Act
                    $result = $vmHostNetworkAdapterBaseDSC.ShouldUpdateVMHostNetworkAdapter($vmHostNetworkAdapter)

                    # Assert
                    $result | Should -Be $true
                }
            }
        }

        Describe 'VMHostNetworkAdapterBaseDSC\AddVMHostNetworkAdapter' -Tag 'AddVMHostNetworkAdapter' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostNetworkAdapterBaseDSC
            }

            Context 'Invoking with VMKernel Network Adapter settings that results in an Error' {
                BeforeAll {
                    # Arrange
                    $vmHostNetworkAdapterBaseDSCProperties = New-MocksWhenVMKernelNetworkAdapterSettingsResultsInAnError
                    $vmHostNetworkAdapterBaseDSC = New-Object -TypeName $vmHostNetworkAdapterBaseDSCClassName -Property $vmHostNetworkAdapterBaseDSCProperties

                    $vmHostNetworkAdapterBaseDSC.ConnectVIServer()
                    $vmHost = $vmHostNetworkAdapterBaseDSC.GetVMHost()
                    $virtualSwitch = $vmHostNetworkAdapterBaseDSC.GetVirtualSwitch($vmHost, $vmHostNetworkAdapterBaseDSCProperties.VirtualSwitch)
                    $vmHostNetworkAdapter = $vmHostNetworkAdapterBaseDSC.GetVMHostNetworkAdapter($vmHost, $virtualSwitch)
                }

                It 'Should call all defined mocks' {
                    try {
                        # Act
                        $vmHostNetworkAdapterBaseDSC.AddVMHostNetworkAdapter($virtualSwitch, $null)
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw the correct error when Adding new VMKernel Network Adapter results in an error' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $vmHostNetworkAdapterBaseDSC.AddVMHostNetworkAdapter($virtualSwitch, $null) } | Should -Throw "Cannot create VMKernel Network Adapter connected to Virtual Switch $($virtualSwitch.Name) and Port Group $($vmHostNetworkAdapterBaseDSCProperties.PortGroup). For more information: ScriptHalted"
                }
            }

            Context 'Invoking without Port Id' {
                BeforeAll {
                    # Arrange
                    $vmHostNetworkAdapterBaseDSCProperties = New-MocksWhenAddingVMKernelNetworkAdapter
                    $vmHostNetworkAdapterBaseDSC = New-Object -TypeName $vmHostNetworkAdapterBaseDSCClassName -Property $vmHostNetworkAdapterBaseDSCProperties

                    $vmHostNetworkAdapterBaseDSC.ConnectVIServer()
                    $vmHost = $vmHostNetworkAdapterBaseDSC.GetVMHost()
                    $virtualSwitch = $vmHostNetworkAdapterBaseDSC.GetVirtualSwitch($vmHost, $vmHostNetworkAdapterBaseDSCProperties.VirtualSwitch)
                    $vmHostNetworkAdapter = $vmHostNetworkAdapterBaseDSC.GetVMHostNetworkAdapter($vmHost, $virtualSwitch)
                }

                It 'Should call all defined mocks' {
                    # Act
                    $vmHostNetworkAdapterBaseDSC.AddVMHostNetworkAdapter($virtualSwitch, $null)

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the New-VMHostNetworkAdapter mock once' {
                    # Act
                    $vmHostNetworkAdapterBaseDSC.AddVMHostNetworkAdapter($virtualSwitch, $null)

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'New-VMHostNetworkAdapter'
                        ParameterFilter = { $Server -eq $script:viServer -and $VirtualSwitch -eq $virtualSwitch -and $PortGroup -eq $script:constants.VirtualPortGroupName -and `
                                            $IP -eq $script:constants.VMKernelNetworkAdapterIP -and $SubnetMask -eq $script:constants.VMKernelNetworkAdapterSubnetMask -and `
                                            $Mac -eq $script:constants.VMKernelNetworkAdapterMac -and $AutomaticIPv6 -eq $script:constants.VMKernelNetworkAdapterAutomaticIPv6 -and `
                                            [System.Linq.Enumerable]::SequenceEqual($IPv6, @()) -and $IPv6ThroughDhcp -eq $script:constants.VMKernelNetworkAdapterIPv6ThroughDhcp -and `
                                            $Mtu -eq $script:constants.VMKernelNetworkAdapterMtu -and $ManagementTrafficEnabled -eq $script:constants.VMKernelNetworkAdapterManagementTrafficEnabled -and `
                                            $FaultToleranceLoggingEnabled -eq $script:constants.VMKernelNetworkAdapterFaultToleranceLoggingEnabled -and `
                                            $VMotionEnabled -eq $script:constants.VMKernelNetworkAdapterVMotionEnabled -and `
                                            $VsanTrafficEnabled -eq $script:constants.VMKernelNetworkAdapterVsanTrafficEnabled -and !$Confirm }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Invoking with Port Id' {
                BeforeAll {
                    # Arrange
                    $vmHostNetworkAdapterBaseDSCProperties = New-MocksWhenAddingVMKernelNetworkAdapter
                    $vmHostNetworkAdapterBaseDSC = New-Object -TypeName $vmHostNetworkAdapterBaseDSCClassName -Property $vmHostNetworkAdapterBaseDSCProperties

                    $vmHostNetworkAdapterBaseDSC.ConnectVIServer()
                    $vmHost = $vmHostNetworkAdapterBaseDSC.GetVMHost()
                    $virtualSwitch = $vmHostNetworkAdapterBaseDSC.GetVirtualSwitch($vmHost, $vmHostNetworkAdapterBaseDSCProperties.VirtualSwitch)
                    $vmHostNetworkAdapter = $vmHostNetworkAdapterBaseDSC.GetVMHostNetworkAdapter($vmHost, $virtualSwitch)
                }

                It 'Should call all defined mocks' {
                    # Act
                    $vmHostNetworkAdapterBaseDSC.AddVMHostNetworkAdapter($virtualSwitch, $script:constants.VMKernelNetworkAdapterPortId)

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the New-VMHostNetworkAdapter mock once' {
                    # Act
                    $vmHostNetworkAdapterBaseDSC.AddVMHostNetworkAdapter($virtualSwitch, $script:constants.VMKernelNetworkAdapterPortId)

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'New-VMHostNetworkAdapter'
                        ParameterFilter = { $Server -eq $script:viServer -and $VirtualSwitch -eq $virtualSwitch -and $PortId -eq $script:constants.VMKernelNetworkAdapterPortId -and `
                                            $IP -eq $script:constants.VMKernelNetworkAdapterIP -and $SubnetMask -eq $script:constants.VMKernelNetworkAdapterSubnetMask -and `
                                            $Mac -eq $script:constants.VMKernelNetworkAdapterMac -and $AutomaticIPv6 -eq $script:constants.VMKernelNetworkAdapterAutomaticIPv6 -and `
                                            [System.Linq.Enumerable]::SequenceEqual($IPv6, @()) -and $IPv6ThroughDhcp -eq $script:constants.VMKernelNetworkAdapterIPv6ThroughDhcp -and `
                                            $Mtu -eq $script:constants.VMKernelNetworkAdapterMtu -and $ManagementTrafficEnabled -eq $script:constants.VMKernelNetworkAdapterManagementTrafficEnabled -and `
                                            $FaultToleranceLoggingEnabled -eq $script:constants.VMKernelNetworkAdapterFaultToleranceLoggingEnabled -and `
                                            $VMotionEnabled -eq $script:constants.VMKernelNetworkAdapterVMotionEnabled -and `
                                            $VsanTrafficEnabled -eq $script:constants.VMKernelNetworkAdapterVsanTrafficEnabled -and !$Confirm }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }
        }

        Describe 'VMHostNetworkAdapterBaseDSC\UpdateVMHostNetworkAdapter' -Tag 'UpdateVMHostNetworkAdapter' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostNetworkAdapterBaseDSC
            }

            Context 'Invoking with VMKernel Network Adapter settings to update that results in an Error' {
                BeforeAll {
                    # Arrange
                    $vmHostNetworkAdapterBaseDSCProperties = New-MocksWhenUpdatingVMKernelNetworkAdapterSettingsResultsInAnError
                    $vmHostNetworkAdapterBaseDSC = New-Object -TypeName $vmHostNetworkAdapterBaseDSCClassName -Property $vmHostNetworkAdapterBaseDSCProperties

                    $vmHostNetworkAdapterBaseDSC.ConnectVIServer()
                    $vmHost = $vmHostNetworkAdapterBaseDSC.GetVMHost()
                    $virtualSwitch = $vmHostNetworkAdapterBaseDSC.GetVirtualSwitch($vmHost, $vmHostNetworkAdapterBaseDSCProperties.VirtualSwitch)
                    $vmHostNetworkAdapter = $vmHostNetworkAdapterBaseDSC.GetVMHostNetworkAdapter($vmHost, $virtualSwitch)
                }

                It 'Should call all defined mocks' {
                    try {
                        # Act
                        $vmHostNetworkAdapterBaseDSC.UpdateVMHostNetworkAdapter($vmHostNetworkAdapter)
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw the correct error when Updating the VMKernel Network Adapter results in an error' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $vmHostNetworkAdapterBaseDSC.UpdateVMHostNetworkAdapter($vmHostNetworkAdapter) } | Should -Throw "Cannot update VMKernel Network Adapter $($script:constants.VMKernelNetworkAdapterName). For more information: ScriptHalted"
                }
            }

            Context 'Invoking without Dhcp and IPv6Enabled' {
                BeforeAll {
                    # Arrange
                    $vmHostNetworkAdapterBaseDSCProperties = New-MocksWhenUpdatingVMKernelNetworkAdapterWithoutDhcpAndIPv6Enabled
                    $vmHostNetworkAdapterBaseDSC = New-Object -TypeName $vmHostNetworkAdapterBaseDSCClassName -Property $vmHostNetworkAdapterBaseDSCProperties

                    $vmHostNetworkAdapterBaseDSC.ConnectVIServer()
                    $vmHost = $vmHostNetworkAdapterBaseDSC.GetVMHost()
                    $virtualSwitch = $vmHostNetworkAdapterBaseDSC.GetVirtualSwitch($vmHost, $vmHostNetworkAdapterBaseDSCProperties.VirtualSwitch)
                    $vmHostNetworkAdapter = $vmHostNetworkAdapterBaseDSC.GetVMHostNetworkAdapter($vmHost, $virtualSwitch)
                }

                It 'Should call all defined mocks' {
                    # Act
                    $vmHostNetworkAdapterBaseDSC.UpdateVMHostNetworkAdapter($vmHostNetworkAdapter)

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Set-VMHostNetworkAdapter mock once' {
                    # Act
                    $vmHostNetworkAdapterBaseDSC.UpdateVMHostNetworkAdapter($vmHostNetworkAdapter)

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Set-VMHostNetworkAdapter'
                        ParameterFilter = { $VirtualNic -eq $vmHostNetworkAdapter -and $Mac -eq ($script:constants.VMKernelNetworkAdapterMac + $script:constants.VMKernelNetworkAdapterMac) -and `
                                            $ManagementTrafficEnabled -eq !($script:constants.VMKernelNetworkAdapterManagementTrafficEnabled) -and !$Confirm }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Invoking with Dhcp and IPv6Enabled' {
                BeforeAll {
                    # Arrange
                    $vmHostNetworkAdapterBaseDSCProperties = New-MocksWhenUpdatingVMKernelNetworkAdapterWithDhcpAndIPv6Enabled
                    $vmHostNetworkAdapterBaseDSC = New-Object -TypeName $vmHostNetworkAdapterBaseDSCClassName -Property $vmHostNetworkAdapterBaseDSCProperties

                    $vmHostNetworkAdapterBaseDSC.ConnectVIServer()
                    $vmHost = $vmHostNetworkAdapterBaseDSC.GetVMHost()
                    $virtualSwitch = $vmHostNetworkAdapterBaseDSC.GetVirtualSwitch($vmHost, $vmHostNetworkAdapterBaseDSCProperties.VirtualSwitch)
                    $vmHostNetworkAdapter = $vmHostNetworkAdapterBaseDSC.GetVMHostNetworkAdapter($vmHost, $virtualSwitch)
                }

                It 'Should call all defined mocks' {
                    # Act
                    $vmHostNetworkAdapterBaseDSC.UpdateVMHostNetworkAdapter($vmHostNetworkAdapter)

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Set-VMHostNetworkAdapter mock once' {
                    # Act
                    $vmHostNetworkAdapterBaseDSC.UpdateVMHostNetworkAdapter($vmHostNetworkAdapter)

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Set-VMHostNetworkAdapter'
                        ParameterFilter = { $VirtualNic -eq $vmHostNetworkAdapter -and $Dhcp -eq !($script:constants.VMKernelNetworkAdapterDhcp) -and `
                                            $IPv6Enabled -eq !($script:constants.VMKernelNetworkAdapterIPv6Enabled) -and !$Confirm }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }
        }

        Describe 'VMHostNetworkAdapterBaseDSC\RemoveVMHostNetworkAdapter' -Tag 'RemoveVMHostNetworkAdapter' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostNetworkAdapterBaseDSC
            }

            Context 'Invoking with VMKernel Network Adapter settings to remove that results in an Error' {
                BeforeAll {
                    # Arrange
                    $vmHostNetworkAdapterBaseDSCProperties = New-MocksWhenRemovingVMKernelNetworkAdapterResultsInAnError
                    $vmHostNetworkAdapterBaseDSC = New-Object -TypeName $vmHostNetworkAdapterBaseDSCClassName -Property $vmHostNetworkAdapterBaseDSCProperties

                    $vmHostNetworkAdapterBaseDSC.ConnectVIServer()
                    $vmHost = $vmHostNetworkAdapterBaseDSC.GetVMHost()
                    $virtualSwitch = $vmHostNetworkAdapterBaseDSC.GetVirtualSwitch($vmHost, $vmHostNetworkAdapterBaseDSCProperties.VirtualSwitch)
                    $vmHostNetworkAdapter = $vmHostNetworkAdapterBaseDSC.GetVMHostNetworkAdapter($vmHost, $virtualSwitch)
                }

                It 'Should call all defined mocks' {
                    try {
                        # Act
                        $vmHostNetworkAdapterBaseDSC.RemoveVMHostNetworkAdapter($vmHost, $vmHostNetworkAdapter)
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw the correct error when Removing the VMKernel Network Adapter results in an error' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $vmHostNetworkAdapterBaseDSC.RemoveVMHostNetworkAdapter($vmHost, $vmHostNetworkAdapter) } | Should -Throw "Cannot remove VMKernel Network Adapter $($script:constants.VMKernelNetworkAdapterName). For more information: ScriptHalted"
                }
            }

            Context 'Invoking with VMKernel Network Adapter settings to remove that results in a Success' {
                BeforeAll {
                    # Arrange
                    $vmHostNetworkAdapterBaseDSCProperties = New-MocksWhenRemovingVMKernelNetworkAdapter
                    $vmHostNetworkAdapterBaseDSC = New-Object -TypeName $vmHostNetworkAdapterBaseDSCClassName -Property $vmHostNetworkAdapterBaseDSCProperties

                    $vmHostNetworkAdapterBaseDSC.ConnectVIServer()
                    $vmHost = $vmHostNetworkAdapterBaseDSC.GetVMHost()
                    $virtualSwitch = $vmHostNetworkAdapterBaseDSC.GetVirtualSwitch($vmHost, $vmHostNetworkAdapterBaseDSCProperties.VirtualSwitch)
                    $vmHostNetworkAdapter = $vmHostNetworkAdapterBaseDSC.GetVMHostNetworkAdapter($vmHost, $virtualSwitch)
                }

                It 'Should call all defined mocks' {
                    # Act
                    $vmHostNetworkAdapterBaseDSC.RemoveVMHostNetworkAdapter($vmHost, $vmHostNetworkAdapter)

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Remove-VMHostNetworkAdapter mock once' {
                    # Act
                    $vmHostNetworkAdapterBaseDSC.RemoveVMHostNetworkAdapter($vmHost, $vmHostNetworkAdapter)

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Remove-VMHostNetworkAdapter'
                        ParameterFilter = { $Nic -eq $vmHostNetworkAdapter -and !$Confirm }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }
        }

        Describe 'VMHostNetworkAdapterBaseDSC\PopulateResult' -Tag 'PopulateResult' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostNetworkAdapterBaseDSC
            }

            Context 'Invoking with existing VMKernel Network Adapter' {
                BeforeAll {
                    # Arrange
                    $vmHostNetworkAdapterBaseDSCProperties = New-MocksWhenVMKernelNetworkAdapterExists
                    $vmHostNetworkAdapterBaseDSC = New-Object -TypeName $vmHostNetworkAdapterBaseDSCClassName -Property $vmHostNetworkAdapterBaseDSCProperties

                    $vmHostNetworkAdapterBaseDSC.ConnectVIServer()
                    $vmHost = $vmHostNetworkAdapterBaseDSC.GetVMHost()
                    $virtualSwitch = $vmHostNetworkAdapterBaseDSC.GetVirtualSwitch($vmHost, $vmHostNetworkAdapterBaseDSCProperties.VirtualSwitch)
                    $vmHostNetworkAdapter = $vmHostNetworkAdapterBaseDSC.GetVMHostNetworkAdapter($vmHost, $virtualSwitch)
                    $result = New-Object -TypeName $vmHostNetworkAdapterBaseDSCClassName
                }

                It 'Should call all defined mocks' {
                    # Act
                    $vmHostNetworkAdapterBaseDSC.PopulateResult($vmHostNetworkAdapter, $result)

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should retrieve the correct settings from the Server and Ensure should be set to Present' {
                    # Act
                    $vmHostNetworkAdapterBaseDSC.PopulateResult($vmHostNetworkAdapter, $result)

                    # Assert
                    $result.PortGroup | Should -Be $script:constants.VirtualPortGroupName
                    $result.Ensure | Should -Be 'Present'
                    $result.IP | Should -Be $script:constants.VMKernelNetworkAdapterIP
                    $result.SubnetMask | Should -Be $script:constants.VMKernelNetworkAdapterSubnetMask
                    $result.Mac | Should -Be $script:constants.VMKernelNetworkAdapterMac
                    $result.AutomaticIPv6 | Should -Be $script:constants.VMKernelNetworkAdapterAutomaticIPv6
                    $result.IPv6 | Should -Be @()
                    $result.IPv6ThroughDhcp | Should -Be $script:constants.VMKernelNetworkAdapterIPv6ThroughDhcp
                    $result.Mtu | Should -Be $script:constants.VMKernelNetworkAdapterMtu
                    $result.Dhcp | Should -Be $script:constants.VMKernelNetworkAdapterDhcp
                    $result.IPv6Enabled | Should -Be $script:constants.VMKernelNetworkAdapterIPv6Enabled
                    $result.ManagementTrafficEnabled | Should -Be $script:constants.VMKernelNetworkAdapterManagementTrafficEnabled
                    $result.FaultToleranceLoggingEnabled | Should -Be $script:constants.VMKernelNetworkAdapterFaultToleranceLoggingEnabled
                    $result.VMotionEnabled | Should -Be $script:constants.VMKernelNetworkAdapterVMotionEnabled
                    $result.VsanTrafficEnabled | Should -Be $script:constants.VMKernelNetworkAdapterVsanTrafficEnabled
                }
            }

            Context 'Invoking with non existing VMKernel Network Adapter' {
                BeforeAll {
                    # Arrange
                    $vmHostNetworkAdapterBaseDSCProperties = New-MocksWhenVMKernelNetworkAdapterDoesNotExist
                    $vmHostNetworkAdapterBaseDSC = New-Object -TypeName $vmHostNetworkAdapterBaseDSCClassName -Property $vmHostNetworkAdapterBaseDSCProperties

                    $vmHostNetworkAdapterBaseDSC.ConnectVIServer()
                    $vmHost = $vmHostNetworkAdapterBaseDSC.GetVMHost()
                    $virtualSwitch = $vmHostNetworkAdapterBaseDSC.GetVirtualSwitch($vmHost, $vmHostNetworkAdapterBaseDSCProperties.VirtualSwitch)
                    $vmHostNetworkAdapter = $vmHostNetworkAdapterBaseDSC.GetVMHostNetworkAdapter($vmHost, $virtualSwitch)
                    $result = New-Object -TypeName $vmHostNetworkAdapterBaseDSCClassName
                }

                It 'Should call all defined mocks' {
                    # Act
                    $vmHostNetworkAdapterBaseDSC.PopulateResult($vmHostNetworkAdapter, $result)

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should retrieve the correct settings from the Resource properties and Ensure should be set to Absent' {
                    # Act
                    $vmHostNetworkAdapterBaseDSC.PopulateResult($vmHostNetworkAdapter, $result)

                    # Assert
                    $result.PortGroup | Should -Be $vmHostNetworkAdapterBaseDSCProperties.PortGroup
                    $result.Ensure | Should -Be 'Absent'
                    $result.IP | Should -Be $vmHostNetworkAdapterBaseDSCProperties.IP
                    $result.SubnetMask | Should -Be $vmHostNetworkAdapterBaseDSCProperties.SubnetMask
                    $result.Mac | Should -Be $vmHostNetworkAdapterBaseDSCProperties.Mac
                    $result.AutomaticIPv6 | Should -Be $vmHostNetworkAdapterBaseDSCProperties.AutomaticIPv6
                    $result.IPv6 | Should -Be @()
                    $result.IPv6ThroughDhcp | Should -Be $vmHostNetworkAdapterBaseDSCProperties.IPv6ThroughDhcp
                    $result.Mtu | Should -Be $vmHostNetworkAdapterBaseDSCProperties.Mtu
                    $result.Dhcp | Should -BeNullOrEmpty
                    $result.IPv6Enabled | Should -BeNullOrEmpty
                    $result.ManagementTrafficEnabled | Should -Be $vmHostNetworkAdapterBaseDSCProperties.ManagementTrafficEnabled
                    $result.FaultToleranceLoggingEnabled | Should -Be $vmHostNetworkAdapterBaseDSCProperties.FaultToleranceLoggingEnabled
                    $result.VMotionEnabled | Should -Be $vmHostNetworkAdapterBaseDSCProperties.VMotionEnabled
                    $result.VsanTrafficEnabled | Should -Be $vmHostNetworkAdapterBaseDSCProperties.VsanTrafficEnabled
                }
            }
        }
    }
    finally {
        # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
        Invoke-TestCleanup -ModulePath $modulePath
    }
}
