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
        $resourceName = 'VMHostVDSwitchMigration'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
        . "$unitTestsFolder\TestHelpers\Mocks\VMHostVDSwitchMigrationMocks.ps1"

        Describe 'VMHostVDSwitchMigration\Set' -Tag 'Set' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostVDSwitchMigration
            }

            Context 'One disconnected Physical Network Adapter is passed and Server error occurs during migration' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenOneDisconnectedPhysicalNetworkAdapterIsPassedAndServerErrorOccursDuringMigration
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    try {
                        # Act
                        $resource.Set()
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw the correct error when one disconnected Physical Network Adapter is passed and Server error occurs during migration' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $resource.Set() } | Should -Throw "Could not migrate Physical Network Adapter $script:disconnectedPhysicalNetworkAdapterOne to Distributed Switch $($script:distributedSwitch.Name). For more information: ScriptHalted"
                }
            }

            Context 'One disconnected Physical Network Adapter is passed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenOneDisconnectedPhysicalNetworkAdapterIsPassed
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Add-VDSwitchPhysicalNetworkAdapter mock with the Distributed Switch and the one disconnected Physical Network Adapter once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $expectedVMHostPhysicalNic = @($script:disconnectedPhysicalNetworkAdapterOne)

                    $assertMockCalledParams = @{
                        CommandName = 'Add-VDSwitchPhysicalNetworkAdapter'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $DistributedSwitch -eq $script:distributedSwitch -and
                            [System.Linq.Enumerable]::SequenceEqual($VMHostPhysicalNic, [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.Nic.PhysicalNic[]] $expectedVMHostPhysicalNic) -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Two disconnected Physical Network Adapters are passed and Server error occurs during migration' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTwoDisconnectedPhysicalNetworkAdaptersArePassedAndServerErrorOccursDuringMigration
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    try {
                        # Act
                        $resource.Set()
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw the correct error when two disconnected Physical Network Adapters are passed and Server error occurs during migration' {
                    # Act && Assert
                    $vmHostPhysicalNetworkAdaptersToMigrate = @($script:disconnectedPhysicalNetworkAdapterOne, $script:disconnectedPhysicalNetworkAdapterTwo)

                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $resource.Set() } | Should -Throw "Could not migrate Physical Network Adapters $vmHostPhysicalNetworkAdaptersToMigrate to Distributed Switch $($script:distributedSwitch.Name). For more information: ScriptHalted"
                }
            }

            Context 'Two disconnected Physical Network Adapters are passed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTwoDisconnectedPhysicalNetworkAdaptersArePassed
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Add-VDSwitchPhysicalNetworkAdapter mock with the Distributed Switch and the two disconnected Physical Network Adapters once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $expectedVMHostPhysicalNic = @($script:disconnectedPhysicalNetworkAdapterOne, $script:disconnectedPhysicalNetworkAdapterTwo)

                    $assertMockCalledParams = @{
                        CommandName = 'Add-VDSwitchPhysicalNetworkAdapter'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $DistributedSwitch -eq $script:distributedSwitch -and
                            [System.Linq.Enumerable]::SequenceEqual($VMHostPhysicalNic, [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.Nic.PhysicalNic[]] $expectedVMHostPhysicalNic) -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Two connected and one disconnected Physical Network Adapters are passed and Server error occurs during migration' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTwoConnectedAndOneDisconnectedPhysicalNetworkAdaptersArePassedAndServerErrorOccursDuringMigration
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    try {
                        # Act
                        $resource.Set()
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw the correct error when two connected and one disconnected Physical Network Adapters are passed and Server error occurs during migration' {
                    # Act && Assert
                    $vmHostPhysicalNetworkAdaptersToMigrate = @($script:connectedPhysicalNetworkAdapterTwo, $script:disconnectedPhysicalNetworkAdapterOne)

                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $resource.Set() } | Should -Throw "Could not migrate Physical Network Adapters $vmHostPhysicalNetworkAdaptersToMigrate to Distributed Switch $($script:distributedSwitch.Name). For more information: ScriptHalted"
                }
            }

            Context 'Two connected and one disconnected Physical Network Adapters are passed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTwoConnectedAndOneDisconnectedPhysicalNetworkAdaptersArePassed
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Add-VDSwitchPhysicalNetworkAdapter mock with the Distributed Switch and the first connected Physical Network Adapter once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $expectedVMHostPhysicalNic = @($script:connectedPhysicalNetworkAdapterOne)

                    $assertMockCalledParams = @{
                        CommandName = 'Add-VDSwitchPhysicalNetworkAdapter'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $DistributedSwitch -eq $script:distributedSwitch -and
                            [System.Linq.Enumerable]::SequenceEqual($VMHostPhysicalNic, [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.Nic.PhysicalNic[]] $expectedVMHostPhysicalNic) -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }

                It 'Should call the Add-VDSwitchPhysicalNetworkAdapter mock with the Distributed Switch and the second connected and first disconnected Physical Network Adapters once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $expectedVMHostPhysicalNic = @($script:connectedPhysicalNetworkAdapterTwo, $script:disconnectedPhysicalNetworkAdapterOne)

                    $assertMockCalledParams = @{
                        CommandName = 'Add-VDSwitchPhysicalNetworkAdapter'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $DistributedSwitch -eq $script:distributedSwitch -and
                            [System.Linq.Enumerable]::SequenceEqual($VMHostPhysicalNic, [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.Nic.PhysicalNic[]] $expectedVMHostPhysicalNic) -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'One disconnected Physical Network Adapter, two VMKernel Network Adapters and one Port Group are passed and Server error occurs during migration' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenOneDisconnectedPhysicalNetworkAdapterTwoVMKernelNetworkAdaptersAndOnePortGroupArePassedAndServerErrorOccursDuringMigration
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    try {
                        # Act
                        $resource.Set()
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw the correct error when one disconnected Physical Network Adapter, two VMKernel Network Adapters and one Port Group are passed and Server error occurs during migration' {
                    # Act && Assert
                    $vmHostPhysicalNetworkAdaptersToMigrate = @($script:disconnectedPhysicalNetworkAdapterOne)

                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $resource.Set() } | Should -Throw "Could not migrate Physical Network Adapter $vmHostPhysicalNetworkAdaptersToMigrate to Distributed Switch $($script:distributedSwitch.Name). For more information: ScriptHalted"
                }
            }

            Context 'One disconnected Physical Network Adapter, two VMKernel Network Adapters and one Port Group are passed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenOneDisconnectedPhysicalNetworkAdapterTwoVMKernelNetworkAdaptersAndOnePortGroupArePassed
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Add-VDSwitchPhysicalNetworkAdapter mock with the Distributed Switch, the disconnected Physical Network Adapter, the two VMKernel Network Adapters and the Port Group once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $expectedVMHostPhysicalNic = @($script:disconnectedPhysicalNetworkAdapterOne)
                    $expectedVMHostVirtualNic = @($script:vmKernelNetworkAdapterOne, $script:vmKernelNetworkAdapterTwo)
                    $expectedVirtualNicPortgroup = @($script:constants.PortGroupOneName)

                    $assertMockCalledParams = @{
                        CommandName = 'Add-VDSwitchPhysicalNetworkAdapter'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $DistributedSwitch -eq $script:distributedSwitch -and
                            [System.Linq.Enumerable]::SequenceEqual($VMHostPhysicalNic, [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.Nic.PhysicalNic[]] $expectedVMHostPhysicalNic) -and
                            [System.Linq.Enumerable]::SequenceEqual($VMHostVirtualNic, [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.Nic.HostVirtualNic[]] $expectedVMHostVirtualNic) -and
                            [System.Linq.Enumerable]::SequenceEqual($VirtualNicPortgroup, [string[]] $expectedVirtualNicPortgroup) -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'One disconnected Physical Network Adapter, two VMKernel Network Adapters and two Port Groups are passed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenOneDisconnectedPhysicalNetworkAdapterTwoVMKernelNetworkAdaptersAndTwoPortGroupsArePassed
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Add-VDSwitchPhysicalNetworkAdapter mock with the Distributed Switch, the disconnected Physical Network Adapter, the two VMKernel Network Adapters and the two Port Groups once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $expectedVMHostPhysicalNic = @($script:disconnectedPhysicalNetworkAdapterOne)
                    $expectedVMHostVirtualNic = @($script:vmKernelNetworkAdapterOne, $script:vmKernelNetworkAdapterTwo)
                    $expectedVirtualNicPortgroup = @($script:constants.PortGroupOneName, $script:constants.PortGroupTwoName)

                    $assertMockCalledParams = @{
                        CommandName = 'Add-VDSwitchPhysicalNetworkAdapter'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $DistributedSwitch -eq $script:distributedSwitch -and
                            [System.Linq.Enumerable]::SequenceEqual($VMHostPhysicalNic, [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.Nic.PhysicalNic[]] $expectedVMHostPhysicalNic) -and
                            [System.Linq.Enumerable]::SequenceEqual($VMHostVirtualNic, [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.Nic.HostVirtualNic[]] $expectedVMHostVirtualNic) -and
                            [System.Linq.Enumerable]::SequenceEqual($VirtualNicPortgroup, [string[]] $expectedVirtualNicPortgroup) -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Two disconnected Physical Network Adapters, two VMKernel Network Adapters and one Port Group are passed and Server error occurs during migration' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTwoDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndOnePortGroupArePassedAndServerErrorOccursDuringMigration
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    try {
                        # Act
                        $resource.Set()
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw the correct error when two disconnected Physical Network Adapters, two VMKernel Network Adapters and one Port Group are passed and Server error occurs during migration' {
                    # Act && Assert
                    $vmHostPhysicalNetworkAdaptersToMigrate = @($script:disconnectedPhysicalNetworkAdapterOne, $script:disconnectedPhysicalNetworkAdapterTwo)
                    $vmKernelNetworkAdaptersToMigrate = @($script:vmKernelNetworkAdapterOne, $script:vmKernelNetworkAdapterTwo)

                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $resource.Set() } | Should -Throw "Could not migrate Physical Network Adapters $vmHostPhysicalNetworkAdaptersToMigrate and $vmKernelNetworkAdaptersToMigrate to Distributed Switch $($script:distributedSwitch.Name). For more information: ScriptHalted"
                }
            }

            Context 'Two disconnected Physical Network Adapters, two VMKernel Network Adapters and one Port Group are passed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTwoDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndOnePortGroupArePassed
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Add-VDSwitchPhysicalNetworkAdapter mock with the Distributed Switch, the two disconnected Physical Network Adapters, the two VMKernel Network Adapters and the Port Group once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $expectedVMHostPhysicalNic = @($script:disconnectedPhysicalNetworkAdapterOne, $script:disconnectedPhysicalNetworkAdapterTwo)
                    $expectedVMHostVirtualNic = @($script:vmKernelNetworkAdapterOne, $script:vmKernelNetworkAdapterTwo)
                    $expectedVirtualNicPortgroup = @($script:constants.PortGroupOneName)

                    $assertMockCalledParams = @{
                        CommandName = 'Add-VDSwitchPhysicalNetworkAdapter'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $DistributedSwitch -eq $script:distributedSwitch -and
                            [System.Linq.Enumerable]::SequenceEqual($VMHostPhysicalNic, [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.Nic.PhysicalNic[]] $expectedVMHostPhysicalNic) -and
                            [System.Linq.Enumerable]::SequenceEqual($VMHostVirtualNic, [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.Nic.HostVirtualNic[]] $expectedVMHostVirtualNic) -and
                            [System.Linq.Enumerable]::SequenceEqual($VirtualNicPortgroup, [string[]] $expectedVirtualNicPortgroup) -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Two disconnected Physical Network Adapters, two VMKernel Network Adapters and two Port Groups are passed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTwoDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndTwoPortGroupsArePassed
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Add-VDSwitchPhysicalNetworkAdapter mock with the Distributed Switch, the two disconnected Physical Network Adapters, the two VMKernel Network Adapters and the two Port Groups once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $expectedVMHostPhysicalNic = @($script:disconnectedPhysicalNetworkAdapterOne, $script:disconnectedPhysicalNetworkAdapterTwo)
                    $expectedVMHostVirtualNic = @($script:vmKernelNetworkAdapterOne, $script:vmKernelNetworkAdapterTwo)
                    $expectedVirtualNicPortgroup = @($script:constants.PortGroupOneName, $script:constants.PortGroupTwoName)

                    $assertMockCalledParams = @{
                        CommandName = 'Add-VDSwitchPhysicalNetworkAdapter'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $DistributedSwitch -eq $script:distributedSwitch -and
                            [System.Linq.Enumerable]::SequenceEqual($VMHostPhysicalNic, [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.Nic.PhysicalNic[]] $expectedVMHostPhysicalNic) -and
                            [System.Linq.Enumerable]::SequenceEqual($VMHostVirtualNic, [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.Nic.HostVirtualNic[]] $expectedVMHostVirtualNic) -and
                            [System.Linq.Enumerable]::SequenceEqual($VirtualNicPortgroup, [string[]] $expectedVirtualNicPortgroup) -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Two connected and one disconnected Physical Network Adapters, two VMKernel Network Adapters and one Port Group are passed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTwoConnectedAndOneDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndOnePortGroupArePassed
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Add-VDSwitchPhysicalNetworkAdapter mock with the Distributed Switch and the first connected Physical Network Adapter once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $expectedVMHostPhysicalNic = @($script:connectedPhysicalNetworkAdapterOne)

                    $assertMockCalledParams = @{
                        CommandName = 'Add-VDSwitchPhysicalNetworkAdapter'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $DistributedSwitch -eq $script:distributedSwitch -and
                            [System.Linq.Enumerable]::SequenceEqual($VMHostPhysicalNic, [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.Nic.PhysicalNic[]] $expectedVMHostPhysicalNic) -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }

                It 'Should call the Add-VDSwitchPhysicalNetworkAdapter mock with the Distributed Switch, the second connected and first disconnected Physical Network Adapters, the two VMKernel Network Adapters and the Port Group once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $expectedVMHostPhysicalNic = @($script:connectedPhysicalNetworkAdapterTwo, $script:disconnectedPhysicalNetworkAdapterOne)
                    $expectedVMHostVirtualNic = @($script:vmKernelNetworkAdapterOne, $script:vmKernelNetworkAdapterTwo)
                    $expectedVirtualNicPortgroup = @($script:constants.PortGroupOneName)

                    $assertMockCalledParams = @{
                        CommandName = 'Add-VDSwitchPhysicalNetworkAdapter'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $DistributedSwitch -eq $script:distributedSwitch -and
                            [System.Linq.Enumerable]::SequenceEqual($VMHostPhysicalNic, [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.Nic.PhysicalNic[]] $expectedVMHostPhysicalNic) -and
                            [System.Linq.Enumerable]::SequenceEqual($VMHostVirtualNic, [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.Nic.HostVirtualNic[]] $expectedVMHostVirtualNic) -and
                            [System.Linq.Enumerable]::SequenceEqual($VirtualNicPortgroup, [string[]] $expectedVirtualNicPortgroup) -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Two connected and one disconnected Physical Network Adapters, two VMKernel Network Adapters and two Port Groups are passed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTwoConnectedAndOneDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndTwoPortGroupsArePassed
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Add-VDSwitchPhysicalNetworkAdapter mock with the Distributed Switch and the first connected Physical Network Adapter once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $expectedVMHostPhysicalNic = @($script:connectedPhysicalNetworkAdapterOne)

                    $assertMockCalledParams = @{
                        CommandName = 'Add-VDSwitchPhysicalNetworkAdapter'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $DistributedSwitch -eq $script:distributedSwitch -and
                            [System.Linq.Enumerable]::SequenceEqual($VMHostPhysicalNic, [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.Nic.PhysicalNic[]] $expectedVMHostPhysicalNic) -and
                            !$Confirm
                        }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }

                It 'Should call the Add-VDSwitchPhysicalNetworkAdapter mock with the Distributed Switch, the second connected and first disconnected Physical Network Adapters, the two VMKernel Network Adapters and the two Port Groups once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $expectedVMHostPhysicalNic = @($script:connectedPhysicalNetworkAdapterTwo, $script:disconnectedPhysicalNetworkAdapterOne)
                    $expectedVMHostVirtualNic = @($script:vmKernelNetworkAdapterOne, $script:vmKernelNetworkAdapterTwo)
                    $expectedVirtualNicPortgroup = @($script:constants.PortGroupOneName, $script:constants.PortGroupTwoName)

                    $assertMockCalledParams = @{
                        CommandName = 'Add-VDSwitchPhysicalNetworkAdapter'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $DistributedSwitch -eq $script:distributedSwitch -and
                            [System.Linq.Enumerable]::SequenceEqual($VMHostPhysicalNic, [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.Nic.PhysicalNic[]] $expectedVMHostPhysicalNic) -and
                            [System.Linq.Enumerable]::SequenceEqual($VMHostVirtualNic, [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.Nic.HostVirtualNic[]] $expectedVMHostVirtualNic) -and
                            [System.Linq.Enumerable]::SequenceEqual($VirtualNicPortgroup, [string[]] $expectedVirtualNicPortgroup) -and
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

        Describe 'VMHostVDSwitchMigration\Test' -Tag 'Test' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostVDSwitchMigration
            }

            Context 'One VMKernel Network Adapter and zero Port Groups are passed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenOneVMKernelNetworkAdapterAndZeroPortGroupsArePassed
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    try {
                        # Act
                        $resource.Test()
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw the correct error when one VMKernel Network Adapter and zero Port Groups are passed' {
                    # Act && Assert
                    { $resource.Test() } | Should -Throw "$($resourceProperties.VMKernelNicNames.Length) VMKernel Network Adapters specified and $($resourceProperties.PortGroupNames.Length) Port Groups specified which is not valid."
                }
            }

            Context 'Zero VMKernel Network Adapters and one Port Group are passed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenZeroVMKernelNetworkAdaptersAndOnePortGroupArePassed
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    try {
                        # Act
                        $resource.Test()
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw the correct error when zero VMKernel Network Adapters and one Port Group are passed' {
                    # Act && Assert
                    { $resource.Test() } | Should -Throw "$($resourceProperties.PortGroupNames.Length) Port Groups specified and no VMKernel Network Adapters specified which is not valid."
                }
            }

            Context 'VMHost is not added to the Distributed Switch' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenVMHostIsNotAddedToTheDistributedSwitch
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when the VMHost is not added to the Distributed Switch' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'One Physical Network Adapter is passed and no Physical Network Adapters are added to the Distributed Switch' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenOnePhysicalNetworkAdapterIsPassedAndNoPhysicalNetworkAdaptersAreAddedToTheDistributedSwitch
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when one Physical Network Adapter is passed and no Physical Network Adapters are added to the Distributed Switch' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'Two Physical Network Adapters are passed and the second is not added to the Distributed Switch' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTwoPhysicalNetworkAdaptersArePassedAndTheSecondIsNotAddedToTheDistributedSwitch
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when two Physical Network Adapters are passed and the second is not added to the Distributed Switch' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'One Physical Network Adapter is passed and is added to the Distributed Switch and no VMKernel Network Adapters and Port Groups are passed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenOnePhysicalNetworkAdapterIsPassedAndItIsAddedToTheDistributedSwitchAndNoVMKernelNetworkAdaptersAndPortGroupsArePassed
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when one Physical Network Adapter is passed and is added to the Distributed Switch and no VMKernel Network Adapters and Port Groups are passed' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }

            Context 'Two VMKernel Network Adapters and one Port Group are passed and the second VMKernel Network Adapter is not added to the Distributed Switch' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTwoVMKernelNetworkAdaptersAndOnePortGroupArePassedAndTheSecondVMKernelNetworkAdapterIsNotAddedToTheDistributedSwitch
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when two VMKernel Network Adapters and one Port Group are passed and the second VMKernel Network Adapter is not added to the Distributed Switch' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'Two VMKernel Network Adapters and two Port Groups are passed and the second VMKernel Network Adapter is not added to the Distributed Switch' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTwoVMKernelNetworkAdaptersAndTwoPortGroupsArePassedAndTheSecondVMKernelNetworkAdapterIsNotAddedToTheDistributedSwitch
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when two VMKernel Network Adapters and two Port Groups are passed and the second VMKernel Network Adapter is not added to the Distributed Switch' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }
        }

        Describe 'VMHostVDSwitchMigration\Get' -Tag 'Get' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostVDSwitchMigration

                $resourceProperties = New-MocksInGet
                $resource = New-Object -TypeName $resourceName -Property $resourceProperties
            }

            It 'Should call all defined mocks with the correct parameters' {
                # Act
                $resource.Get()

                # Assert
                Assert-VerifiableMock
            }

            It 'Should retrieve the Resource properties from the Server' {
                # Act
                $result = $resource.Get()

                # Assert
                $expectedPhysicalNicNames = @($script:constants.ConnectedPhysicalNetworkAdapterOneName, $script:constants.DisconnectedPhysicalNetworkAdapterOneName)
                $expectedVMKernelNicNames = @($script:constants.VMKernelNetworkAdapterOneName, $script:constants.VMKernelNetworkAdapterTwoName)
                $expectedPortGroupNames = @($script:constants.PortGroupOneName, $script:constants.PortGroupTwoName)

                $result.Server | Should -Be $script:viServer.Name
                $result.VMHostName | Should -Be $script:vmHostAddedToDistributedSwitchOne.Name
                $result.VdsName | Should -Be $script:distributedSwitch.Name
                $result.PhysicalNicNames | Should -Be $expectedPhysicalNicNames
                $result.VMKernelNicNames | Should -Be $expectedVMKernelNicNames
                $result.PortGroupNames | Should -Be $expectedPortGroupNames
            }
        }
    }
    finally {
        # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
        Invoke-TestCleanup -ModulePath $modulePath
    }
}
