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
        $vmHostNicBaseDSCClassName = 'VMHostNicBaseDSC'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
        . "$unitTestsFolder\TestHelpers\Mocks\VMHostNicBaseDSCMocks.ps1"

        Describe 'VMHostNicBaseDSC\GetVMHostNetworkAdapter' -Tag 'GetVMHostNetworkAdapter' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostNicBaseDSC
            }

            Context 'Invoking with existing VMKernel Network Adapter' {
                BeforeAll {
                    # Arrange
                    $vmHostNicBaseDSCProperties = New-MocksWhenVMKernelNetworkAdapterExists
                    $vmHostNicBaseDSC = New-Object -TypeName $vmHostNicBaseDSCClassName -Property $vmHostNicBaseDSCProperties

                    $vmHostNicBaseDSC.ConnectVIServer()
                    $vmHostNicBaseDSC.RetrieveVMHost()
                }

                It 'Should call all defined mocks' {
                    # Act
                    $vmHostNicBaseDSC.GetVMHostNetworkAdapter($script:virtualSwitch)

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return the VMKernel Network Adapter from the server' {
                    # Act
                    $vmHostNetworkAdapter = $vmHostNicBaseDSC.GetVMHostNetworkAdapter($script:virtualSwitch)

                    # Assert
                    $vmHostNetworkAdapter | Should -Be $script:vmHostNetworkAdapter
                }
            }

            Context 'Invoking with non existing VMKernel Network Adapter' {
                BeforeAll {
                    # Arrange
                    $vmHostNicBaseDSCProperties = New-MocksWhenVMKernelNetworkAdapterDoesNotExist
                    $vmHostNicBaseDSC = New-Object -TypeName $vmHostNicBaseDSCClassName -Property $vmHostNicBaseDSCProperties

                    $vmHostNicBaseDSC.ConnectVIServer()
                    $vmHostNicBaseDSC.RetrieveVMHost()
                }

                It 'Should call all defined mocks' {
                    # Act
                    $vmHostNicBaseDSC.GetVMHostNetworkAdapter($script:virtualSwitch)

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $null' {
                    # Act
                    $vmHostNetworkAdapter = $vmHostNicBaseDSC.GetVMHostNetworkAdapter($script:virtualSwitch)

                    # Assert
                    $vmHostNetworkAdapter | Should -BeNullOrEmpty
                }
            }
        }

        Describe 'VMHostNicBaseDSC\ShouldUpdateVMHostNetworkAdapter' -Tag 'ShouldUpdateVMHostNetworkAdapter' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostNicBaseDSC
            }

            Context 'Invoking with matching VMKernel Network Adapter settings' {
                BeforeAll {
                    # Arrange
                    $vmHostNicBaseDSCProperties = New-MocksWhenVMKernelNetworkAdapterSettingsMatch
                    $vmHostNicBaseDSC = New-Object -TypeName $vmHostNicBaseDSCClassName -Property $vmHostNicBaseDSCProperties

                    $vmHostNicBaseDSC.ConnectVIServer()
                    $vmHostNicBaseDSC.RetrieveVMHost()
                    $vmHostNetworkAdapter = $vmHostNicBaseDSC.GetVMHostNetworkAdapter($script:virtualSwitch)
                }

                It 'Should call all defined mocks' {
                    # Act
                    $vmHostNicBaseDSC.ShouldUpdateVMHostNetworkAdapter($vmHostNetworkAdapter)

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when VMKernel Network Adapter settings match' {
                    # Act
                    $result = $vmHostNicBaseDSC.ShouldUpdateVMHostNetworkAdapter($vmHostNetworkAdapter)

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'Invoking with non matching VMKernel Network Adapter settings' {
                BeforeAll {
                    # Arrange
                    $vmHostNicBaseDSCProperties = New-MocksWhenVMKernelNetworkAdapterSettingsDoesNotMatch
                    $vmHostNicBaseDSC = New-Object -TypeName $vmHostNicBaseDSCClassName -Property $vmHostNicBaseDSCProperties

                    $vmHostNicBaseDSC.ConnectVIServer()
                    $vmHostNicBaseDSC.RetrieveVMHost()
                    $vmHostNetworkAdapter = $vmHostNicBaseDSC.GetVMHostNetworkAdapter($script:virtualSwitch)
                }

                It 'Should call all defined mocks' {
                    # Act
                    $vmHostNicBaseDSC.ShouldUpdateVMHostNetworkAdapter($vmHostNetworkAdapter)

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when VMKernel Network Adapter settings does not match' {
                    # Act
                    $result = $vmHostNicBaseDSC.ShouldUpdateVMHostNetworkAdapter($vmHostNetworkAdapter)

                    # Assert
                    $result | Should -Be $true
                }
            }
        }

        Describe 'VMHostNicBaseDSC\AddVMHostNetworkAdapter' -Tag 'AddVMHostNetworkAdapter' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostNicBaseDSC
            }

            Context 'Invoking with VMKernel Network Adapter settings that results in an Error' {
                BeforeAll {
                    # Arrange
                    $vmHostNicBaseDSCProperties = New-MocksWhenVMKernelNetworkAdapterSettingsResultsInAnError
                    $vmHostNicBaseDSC = New-Object -TypeName $vmHostNicBaseDSCClassName -Property $vmHostNicBaseDSCProperties

                    $vmHostNicBaseDSC.ConnectVIServer()
                    $vmHostNicBaseDSC.RetrieveVMHost()
                    $vmHostNetworkAdapter = $vmHostNicBaseDSC.GetVMHostNetworkAdapter($script:virtualSwitch)
                }

                It 'Should call all defined mocks' {
                    try {
                        # Act
                        $vmHostNicBaseDSC.AddVMHostNetworkAdapter($script:virtualSwitch, $null)
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw the correct error when Adding new VMKernel Network Adapter results in an error' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $vmHostNicBaseDSC.AddVMHostNetworkAdapter($script:virtualSwitch, $null) } | Should -Throw "Cannot create VMKernel Network Adapter connected to Virtual Switch $($script:virtualSwitch.Name) and Port Group $($vmHostNicBaseDSCProperties.PortGroupName). For more information: ScriptHalted"
                }
            }

            Context 'Invoking without Port Id' {
                BeforeAll {
                    # Arrange
                    $vmHostNicBaseDSCProperties = New-MocksWhenAddingVMKernelNetworkAdapter
                    $vmHostNicBaseDSC = New-Object -TypeName $vmHostNicBaseDSCClassName -Property $vmHostNicBaseDSCProperties

                    $vmHostNicBaseDSC.ConnectVIServer()
                    $vmHostNicBaseDSC.RetrieveVMHost()
                    $vmHostNetworkAdapter = $vmHostNicBaseDSC.GetVMHostNetworkAdapter($script:virtualSwitch)
                }

                It 'Should call all defined mocks' {
                    # Act
                    $vmHostNicBaseDSC.AddVMHostNetworkAdapter($script:virtualSwitch, $null)

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the New-VMHostNetworkAdapter mock once' {
                    # Act
                    $vmHostNicBaseDSC.AddVMHostNetworkAdapter($script:virtualSwitch, $null)

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'New-VMHostNetworkAdapter'
                        ParameterFilter = { $Server -eq $script:viServer -and $VMHost -eq $script:vmHost -and $VirtualSwitch -eq $script:virtualSwitch -and $PortGroup -eq $script:constants.VirtualPortGroupName -and `
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

                It 'Should return the correct VMKernel Network Adapter' {
                    # Act
                    $result = $vmHostNicBaseDSC.AddVMHostNetworkAdapter($script:virtualSwitch, $null)

                    # Assert
                    $result | Should -Be $script:vmHostNetworkAdapter
                }
            }

            Context 'Invoking with Port Id' {
                BeforeAll {
                    # Arrange
                    $vmHostNicBaseDSCProperties = New-MocksWhenAddingVMKernelNetworkAdapter
                    $vmHostNicBaseDSC = New-Object -TypeName $vmHostNicBaseDSCClassName -Property $vmHostNicBaseDSCProperties

                    $vmHostNicBaseDSC.ConnectVIServer()
                    $vmHostNicBaseDSC.RetrieveVMHost()
                    $vmHostNetworkAdapter = $vmHostNicBaseDSC.GetVMHostNetworkAdapter($script:virtualSwitch)
                }

                It 'Should call all defined mocks' {
                    # Act
                    $vmHostNicBaseDSC.AddVMHostNetworkAdapter($script:virtualSwitch, $script:constants.VMKernelNetworkAdapterPortId)

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the New-VMHostNetworkAdapter mock once' {
                    # Act
                    $vmHostNicBaseDSC.AddVMHostNetworkAdapter($script:virtualSwitch, $script:constants.VMKernelNetworkAdapterPortId)

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'New-VMHostNetworkAdapter'
                        ParameterFilter = { $Server -eq $script:viServer -and $VMHost -eq $script:vmHost -and $VirtualSwitch -eq $script:virtualSwitch -and $PortId -eq $script:constants.VMKernelNetworkAdapterPortId -and `
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

                It 'Should return the correct VMKernel Network Adapter' {
                    # Act
                    $result = $vmHostNicBaseDSC.AddVMHostNetworkAdapter($script:virtualSwitch, $script:constants.VMKernelNetworkAdapterPortId)

                    # Assert
                    $result | Should -Be $script:vmHostNetworkAdapter
                }
            }
        }

        Describe 'VMHostNicBaseDSC\UpdateVMHostNetworkAdapter' -Tag 'UpdateVMHostNetworkAdapter' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostNicBaseDSC
            }

            Context 'Invoking with VMKernel Network Adapter settings to update that results in an Error' {
                BeforeAll {
                    # Arrange
                    $vmHostNicBaseDSCProperties = New-MocksWhenUpdatingVMKernelNetworkAdapterSettingsResultsInAnError
                    $vmHostNicBaseDSC = New-Object -TypeName $vmHostNicBaseDSCClassName -Property $vmHostNicBaseDSCProperties

                    $vmHostNicBaseDSC.ConnectVIServer()
                    $vmHostNicBaseDSC.RetrieveVMHost()
                    $vmHostNetworkAdapter = $vmHostNicBaseDSC.GetVMHostNetworkAdapter($script:virtualSwitch)
                }

                It 'Should call all defined mocks' {
                    try {
                        # Act
                        $vmHostNicBaseDSC.UpdateVMHostNetworkAdapter($vmHostNetworkAdapter)
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw the correct error when Updating the VMKernel Network Adapter results in an error' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $vmHostNicBaseDSC.UpdateVMHostNetworkAdapter($vmHostNetworkAdapter) } | Should -Throw "Cannot update VMKernel Network Adapter $($script:constants.VMKernelNetworkAdapterName). For more information: ScriptHalted"
                }
            }

            Context 'Invoking without Dhcp and IPv6Enabled' {
                BeforeAll {
                    # Arrange
                    $vmHostNicBaseDSCProperties = New-MocksWhenUpdatingVMKernelNetworkAdapterWithoutDhcpAndIPv6Enabled
                    $vmHostNicBaseDSC = New-Object -TypeName $vmHostNicBaseDSCClassName -Property $vmHostNicBaseDSCProperties

                    $vmHostNicBaseDSC.ConnectVIServer()
                    $vmHostNicBaseDSC.RetrieveVMHost()
                    $vmHostNetworkAdapter = $vmHostNicBaseDSC.GetVMHostNetworkAdapter($script:virtualSwitch)
                }

                It 'Should call all defined mocks' {
                    # Act
                    $vmHostNicBaseDSC.UpdateVMHostNetworkAdapter($vmHostNetworkAdapter)

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Set-VMHostNetworkAdapter mock once' {
                    # Act
                    $vmHostNicBaseDSC.UpdateVMHostNetworkAdapter($vmHostNetworkAdapter)

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
                    $vmHostNicBaseDSCProperties = New-MocksWhenUpdatingVMKernelNetworkAdapterWithDhcpAndIPv6Enabled
                    $vmHostNicBaseDSC = New-Object -TypeName $vmHostNicBaseDSCClassName -Property $vmHostNicBaseDSCProperties

                    $vmHostNicBaseDSC.ConnectVIServer()
                    $vmHostNicBaseDSC.RetrieveVMHost()
                    $vmHostNetworkAdapter = $vmHostNicBaseDSC.GetVMHostNetworkAdapter($script:virtualSwitch)
                }

                It 'Should call all defined mocks' {
                    # Act
                    $vmHostNicBaseDSC.UpdateVMHostNetworkAdapter($vmHostNetworkAdapter)

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Set-VMHostNetworkAdapter mock once' {
                    # Act
                    $vmHostNicBaseDSC.UpdateVMHostNetworkAdapter($vmHostNetworkAdapter)

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

        Describe 'VMHostNicBaseDSC\RemoveVMHostNetworkAdapter' -Tag 'RemoveVMHostNetworkAdapter' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostNicBaseDSC
            }

            Context 'Invoking with VMKernel Network Adapter settings to remove that results in an Error' {
                BeforeAll {
                    # Arrange
                    $vmHostNicBaseDSCProperties = New-MocksWhenRemovingVMKernelNetworkAdapterResultsInAnError
                    $vmHostNicBaseDSC = New-Object -TypeName $vmHostNicBaseDSCClassName -Property $vmHostNicBaseDSCProperties

                    $vmHostNicBaseDSC.ConnectVIServer()
                    $vmHostNicBaseDSC.RetrieveVMHost()
                    $vmHostNetworkAdapter = $vmHostNicBaseDSC.GetVMHostNetworkAdapter($script:virtualSwitch)
                }

                It 'Should call all defined mocks' {
                    try {
                        # Act
                        $vmHostNicBaseDSC.RemoveVMHostNetworkAdapter($vmHostNetworkAdapter)
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw the correct error when Removing the VMKernel Network Adapter results in an error' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $vmHostNicBaseDSC.RemoveVMHostNetworkAdapter($vmHostNetworkAdapter) } | Should -Throw "Cannot remove VMKernel Network Adapter $($script:constants.VMKernelNetworkAdapterName). For more information: ScriptHalted"
                }
            }

            Context 'Invoking with VMKernel Network Adapter settings to remove that results in a Success' {
                BeforeAll {
                    # Arrange
                    $vmHostNicBaseDSCProperties = New-MocksWhenRemovingVMKernelNetworkAdapter
                    $vmHostNicBaseDSC = New-Object -TypeName $vmHostNicBaseDSCClassName -Property $vmHostNicBaseDSCProperties

                    $vmHostNicBaseDSC.ConnectVIServer()
                    $vmHostNicBaseDSC.RetrieveVMHost()
                    $vmHostNetworkAdapter = $vmHostNicBaseDSC.GetVMHostNetworkAdapter($script:virtualSwitch)
                }

                It 'Should call all defined mocks' {
                    # Act
                    $vmHostNicBaseDSC.RemoveVMHostNetworkAdapter($vmHostNetworkAdapter)

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Remove-VMHostNetworkAdapter mock once' {
                    # Act
                    $vmHostNicBaseDSC.RemoveVMHostNetworkAdapter($vmHostNetworkAdapter)

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

        Describe 'VMHostNicBaseDSC\PopulateResult' -Tag 'PopulateResult' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostNicBaseDSC
            }

            Context 'Invoking with existing VMKernel Network Adapter' {
                BeforeAll {
                    # Arrange
                    $vmHostNicBaseDSCProperties = New-MocksWhenVMKernelNetworkAdapterExists
                    $vmHostNicBaseDSC = New-Object -TypeName $vmHostNicBaseDSCClassName -Property $vmHostNicBaseDSCProperties

                    $vmHostNicBaseDSC.ConnectVIServer()
                    $vmHostNicBaseDSC.RetrieveVMHost()
                    $vmHostNetworkAdapter = $vmHostNicBaseDSC.GetVMHostNetworkAdapter($script:virtualSwitch)
                    $result = New-Object -TypeName $vmHostNicBaseDSCClassName
                }

                It 'Should call all defined mocks' {
                    # Act
                    $vmHostNicBaseDSC.PopulateResult($vmHostNetworkAdapter, $result)

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should retrieve the correct settings from the Server and Ensure should be set to Present' {
                    # Act
                    $vmHostNicBaseDSC.PopulateResult($vmHostNetworkAdapter, $result)

                    # Assert
                    $result.Server | Should -Be $script:viServer.Name
                    $result.VMHostName | Should -Be $script:vmHost.Name
                    $result.PortGroupName | Should -Be $script:constants.VirtualPortGroupName
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
                    $vmHostNicBaseDSCProperties = New-MocksWhenVMKernelNetworkAdapterDoesNotExist
                    $vmHostNicBaseDSC = New-Object -TypeName $vmHostNicBaseDSCClassName -Property $vmHostNicBaseDSCProperties

                    $vmHostNicBaseDSC.ConnectVIServer()
                    $vmHostNicBaseDSC.RetrieveVMHost()
                    $vmHostNetworkAdapter = $vmHostNicBaseDSC.GetVMHostNetworkAdapter($script:virtualSwitch)
                    $result = New-Object -TypeName $vmHostNicBaseDSCClassName
                }

                It 'Should call all defined mocks' {
                    # Act
                    $vmHostNicBaseDSC.PopulateResult($vmHostNetworkAdapter, $result)

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should retrieve the correct settings from the Resource properties and Ensure should be set to Absent' {
                    # Act
                    $vmHostNicBaseDSC.PopulateResult($vmHostNetworkAdapter, $result)

                    # Assert
                    $result.Server | Should -Be $script:viServer.Name
                    $result.VMHostName | Should -Be $script:vmHost.Name
                    $result.PortGroupName | Should -Be $vmHostNicBaseDSCProperties.PortGroupName
                    $result.Ensure | Should -Be 'Absent'
                    $result.IP | Should -Be $vmHostNicBaseDSCProperties.IP
                    $result.SubnetMask | Should -Be $vmHostNicBaseDSCProperties.SubnetMask
                    $result.Mac | Should -Be $vmHostNicBaseDSCProperties.Mac
                    $result.AutomaticIPv6 | Should -Be $vmHostNicBaseDSCProperties.AutomaticIPv6
                    $result.IPv6 | Should -Be @()
                    $result.IPv6ThroughDhcp | Should -Be $vmHostNicBaseDSCProperties.IPv6ThroughDhcp
                    $result.Mtu | Should -Be $vmHostNicBaseDSCProperties.Mtu
                    $result.Dhcp | Should -BeNullOrEmpty
                    $result.IPv6Enabled | Should -BeNullOrEmpty
                    $result.ManagementTrafficEnabled | Should -Be $vmHostNicBaseDSCProperties.ManagementTrafficEnabled
                    $result.FaultToleranceLoggingEnabled | Should -Be $vmHostNicBaseDSCProperties.FaultToleranceLoggingEnabled
                    $result.VMotionEnabled | Should -Be $vmHostNicBaseDSCProperties.VMotionEnabled
                    $result.VsanTrafficEnabled | Should -Be $vmHostNicBaseDSCProperties.VsanTrafficEnabled
                }
            }
        }
    }
    finally {
        # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
        Invoke-TestCleanup -ModulePath $modulePath
    }
}
