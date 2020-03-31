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
        $resourceName = 'VMHostVssMigration'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
        . "$unitTestsFolder\TestHelpers\Mocks\VMHostVssMigrationMocks.ps1"

        Describe 'VMHostVssMigration\Set' -Tag 'Set' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostVssMigration
            }

            Context 'Server error occurs during Standard Switch retrieval' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenServerErrorOccursDuringStandardSwitchRetrieval
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

                It 'Should throw the correct error when Server error occurs during Standard Switch retrieval' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $resource.Set() } | Should -Throw "Could not retrieve Standard Switch $($resourceProperties.VssName). For more information: ScriptHalted"
                }
            }

            Context 'Two Physical Network Adapters are passed and Server error occurs during migration' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTwoPhysicalNetworkAdaptersArePassedAndServerErrorOccursDuringMigration
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

                It 'Should throw the correct error when two Physical Network Adapters are passed and Server error occurs during migration' {
                    # Act && Assert
                    $vmHostPhysicalNetworkAdaptersToMigrate = @($script:connectedPhysicalNetworkAdapterOne, $script:disconnectedPhysicalNetworkAdapterOne)

                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $resource.Set() } | Should -Throw "Could not migrate Physical Network Adapters $vmHostPhysicalNetworkAdaptersToMigrate to Standard Switch $($script:virtualSwitch.Name). For more information: ScriptHalted"
                }
            }

            Context 'Two Physical Network Adapters are passed and both are not added the the passed Standard Switch' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTwoPhysicalNetworkAdaptersArePassedAndBothAreNotAddedToThePassedStandardSwitch
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Add-VirtualSwitchPhysicalNetworkAdapter mock with the Standard Switch and the two passed Physical Network Adapters once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $expectedVMHostPhysicalNic = @($script:connectedPhysicalNetworkAdapterOne, $script:disconnectedPhysicalNetworkAdapterOne)

                    $assertMockCalledParams = @{
                        CommandName = 'Add-VirtualSwitchPhysicalNetworkAdapter'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $VirtualSwitch -eq $script:virtualSwitch -and
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

            Context 'Two Physical Network Adapters, One VMKernel Network Adapter and One Port Group are passed and Server error occurs during migration' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTwoPhysicalNetworkAdaptersOneVMKernelNetworkAdapterAndOnePortGroupArePassedAndServerErrorOccursDuringMigration
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

                It 'Should throw the correct error when two Physical Network Adapters, One VMKernel Network Adapter and One Port Group are passed and Server error occurs during migration' {
                    # Act && Assert
                    $vmHostPhysicalNetworkAdaptersToMigrate = @($script:connectedPhysicalNetworkAdapterOne, $script:disconnectedPhysicalNetworkAdapterOne)
                    $vmHostVMKernelNetworkAdaptersToMigrate = @($script:vmKernelNetworkAdapterOne)

                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $resource.Set() } | Should -Throw "Could not migrate Physical Network Adapters $vmHostPhysicalNetworkAdaptersToMigrate and VMKernel Network Adapters $vmHostVMKernelNetworkAdaptersToMigrate to Standard Switch $($script:standardSwitchWithOnePhysicalNetworkAdapter.Name). For more information: ScriptHalted"
                }
            }

            Context 'Two Physical Network Adapters, One VMKernel Network Adapter and One Port Group are passed, the Port Group does not exist and Server error occurs during Port Group creation' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTwoPhysicalNetworkAdaptersOneVMKernelNetworkAdapterAndOnePortGroupArePassedThePortGroupDoesNotExistAndServerErrorOccursDuringPortGroupCreation
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

                It 'Should throw the correct error when two Physical Network Adapters, One VMKernel Network Adapter and One Port Group are passed, the Port Group does not exist and Server error occurs during Port Group creation' {
                    # Act && Assert
                    # When the Throw statement does not appear in a Catch block, and it does not include an expression, it generates a ScriptHalted error.
                    { $resource.Set() } | Should -Throw "Cannot create Standard Port Group $($script:constants.PortGroupOneName) on Standard Switch $($script:standardSwitchWithOnePhysicalNetworkAdapter.Name). For more information: ScriptHalted"
                }
            }

            Context 'Two Physical Network Adapters, One VMKernel Network Adapter and One Port Group are passed and the Port Group does not exist' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTwoPhysicalNetworkAdaptersOneVMKernelNetworkAdapterAndOnePortGroupArePassedAndThePortGroupDoesNotExist
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Add-VirtualSwitchPhysicalNetworkAdapter mock with the Standard Switch, the first passed Physical Network Adapter, the VMKernel Network Adapter and Port Group once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $expectedVMHostPhysicalNic = @($script:connectedPhysicalNetworkAdapterOne, $script:disconnectedPhysicalNetworkAdapterOne)
                    $expectedVMHostVirtualNic = @($script:vmKernelNetworkAdapterOne)
                    $expectedVirtualNicPortgroup = @($script:constants.PortGroupOneName)

                    $assertMockCalledParams = @{
                        CommandName = 'Add-VirtualSwitchPhysicalNetworkAdapter'
                        ParameterFilter = {
                            $Server -eq $script:viServer -and
                            $VirtualSwitch -eq $script:standardSwitchWithOnePhysicalNetworkAdapter -and
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

        Describe 'VMHostVssMigration\Test' -Tag 'Test' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostVssMigration
            }

            Context 'One Physical Network Adapter is passed and is not present on the Server' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenOnePhysicalNetworkAdapterIsPassedAndIsNotPresentOnTheServer
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

                It 'Should throw the correct error when one Physical Network Adapter is passed and is not present on the Server' {
                    # Act && Assert
                    { $resource.Test() } | Should -Throw "At least one Physical Network Adapter needs to be specified."
                }
            }

            Context 'One Physical Network Adapter is passed and the Standard Switch does not have Physical Network Adapters added to it' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenOnePhysicalNetworkAdapterIsPassedAndTheStandardSwitchDoesNotHavePhysicalNetworkAdaptersAddedToIt
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when one Physical Network Adapter is passed and the Standard Switch does not have Physical Network Adapters added to it' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'One Physical Network Adapter is passed and it is not added to the Standard Switch' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenOnePhysicalNetworkAdapterIsPassedAndItIsNotAddedToTheStandardSwitch
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when one Physical Network Adapter is passed and it is not added to the Standard Switch' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'One Physical Network Adapter is passed and it is added to the Standard Switch' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenOnePhysicalNetworkAdapterIsPassedAndItIsAddedToTheStandardSwitch
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when one Physical Network Adapter is passed and it is added to the Standard Switch' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }

            Context 'Two VMKernel Network Adapters and one Port Group are passed' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTwoVMKernelNetworkAdaptersAndOnePortGroupArePassed
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

                It 'Should throw the correct error when two VMKernel Network Adapters and one Port Group are passed' {
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
                    { $resource.Test() } | Should -Throw "$($resourceProperties.VMKernelNicNames.Length) VMKernel Network Adapters specified and $($resourceProperties.PortGroupNames.Length) Port Groups specified which is not valid."
                }
            }

            Context 'One VMKernel Network Adapter and one Port Group are passed and the VMKernel Network Adapter is not added to the Standard Switch' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenOneVMKernelNetworkAdapterAndOnePortGroupArePassedAndTheVMKernelNetworkAdapterIsNotAddedToTheStandardSwitch
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when one VMKernel Network Adapter and one Port Group are passed and the VMKernel Network Adapter is not added to the Standard Switch' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'One VMKernel Network Adapter and one Port Group are passed and the VMKernel Network Adapter is added to the Standard Switch' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenOneVMKernelNetworkAdapterAndOnePortGroupArePassedAndTheVMKernelNetworkAdapterIsAddedToTheStandardSwitch
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when one VMKernel Network Adapter and one Port Group are passed and the VMKernel Network Adapter is added to the Standard Switch' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }
        }

        Describe 'VMHostVssMigration\Get' -Tag 'Get' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostVssMigration

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
                $expectedPhysicalNicNames = @($script:constants.DisconnectedPhysicalNetworkAdapterOneName)
                $expectedVMKernelNicNames = @($script:constants.VMKernelNetworkAdapterOneName)
                $expectedPortGroupNames = @($script:constants.PortGroupOneName)

                $result.Server | Should -Be $script:viServer.Name
                $result.VMHostName | Should -Be $script:vmHost.Name
                $result.VssName | Should -Be $script:standardSwitchWithOnePhysicalNetworkAdapter.Name
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
