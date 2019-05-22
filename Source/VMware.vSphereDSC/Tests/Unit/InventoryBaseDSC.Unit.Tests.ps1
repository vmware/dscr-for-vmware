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
        $inventoryBaseDSCClassName = 'InventoryBaseDSC'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
        . "$unitTestsFolder\TestHelpers\Mocks\InventoryBaseDSCMocks.ps1"

        Describe 'InventoryBaseDSC\GetInventoryItemLocation' -Tag 'GetInventoryItemLocation' {
            Context 'Empty Location is passed' {
                BeforeAll {
                    # Arrange
                    $inventoryBaseDSCProperties = New-MocksWhenEmptyLocationIsPassed

                    $inventoryBaseDSC = New-Object -TypeName $inventoryBaseDSCClassName -Property $inventoryBaseDSCProperties
                    $inventoryBaseDSC.ConnectVIServer()
                }

                It 'Should return the Inventory Root Folder' {
                    # Act
                    $result = $inventoryBaseDSC.GetInventoryItemLocation()

                    # Assert
                    $result | Should -Be $script:inventoryRootFolder
                }

                It 'Should call the Get-View mock with the passed Server and Inventory Root Folder once' {
                    # Act
                    $inventoryBaseDSC.GetInventoryItemLocation()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Get-View'
                        ParameterFilter = { $Server -eq $script:viServer -and $Id -eq $script:viServer.ExtensionData.Content.RootFolder }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }

                It 'Should call the Get-Inventory mock with the passed Server and Inventory Root Folder MoRef once' {
                    # Act
                    $inventoryBaseDSC.GetInventoryItemLocation()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Get-Inventory'
                        ParameterFilter = { $Server -eq $script:viServer -and $Id -eq $script:rootFolderViewBaseObject.MoRef }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Location consists of only one Folder and the Folder does not exist' {
                BeforeAll {
                    # Arrange
                    $inventoryBaseDSCProperties = New-MocksWhenLocationConsistsOfOnlyOneFolderAndTheFolderDoesNotExist

                    $inventoryBaseDSC = New-Object -TypeName $inventoryBaseDSCClassName -Property $inventoryBaseDSCProperties
                    $inventoryBaseDSC.ConnectVIServer()
                }

                It 'Should throw when the Location does not exist' {
                    # Act && Assert
                    { $inventoryBaseDSC.GetInventoryItemLocation() } | Should -Throw "Folder $($inventoryBaseDSCProperties.Location) was not found at $($script:inventoryRootFolder.Name)."
                }

                It 'Should call the Get-View mock with the passed Server and Inventory Root Folder once' {
                    try {
                        # Act
                        $inventoryBaseDSC.GetInventoryItemLocation()
                    }
                    catch {
                        # Assert
                        $assertMockCalledParams = @{
                            CommandName = 'Get-View'
                            ParameterFilter = { $Server -eq $script:viServer -and $Id -eq $script:viServer.ExtensionData.Content.RootFolder }
                            Exactly = $true
                            Times = 1
                            Scope = 'It'
                        }

                        Assert-MockCalled @assertMockCalledParams
                    }
                }

                It 'Should call the Get-Inventory mock with the passed Server and Inventory Root Folder MoRef once' {
                    try {
                        # Act
                        $inventoryBaseDSC.GetInventoryItemLocation()
                    }
                    catch {
                        # Assert
                        $assertMockCalledParams = @{
                            CommandName = 'Get-Inventory'
                            ParameterFilter = { $Server -eq $script:viServer -and $Id -eq $script:rootFolderViewBaseObject.MoRef }
                            Exactly = $true
                            Times = 1
                            Scope = 'It'
                        }

                        Assert-MockCalled @assertMockCalledParams
                    }
                }

                It 'Should call the Get-Inventory mock with the passed Server, Datacenter Location Item One and Inventory Root Folder Location once' {
                    try {
                        # Act
                        $inventoryBaseDSC.GetInventoryItemLocation()
                    }
                    catch {
                        # Assert
                        $assertMockCalledParams = @{
                            CommandName = 'Get-Inventory'
                            ParameterFilter = { $Server -eq $script:viServer -and $Name -eq $inventoryBaseDSCProperties.Location -and $Location -eq $script:inventoryRootFolder }
                            Exactly = $true
                            Times = 1
                            Scope = 'It'
                        }

                        Assert-MockCalled @assertMockCalledParams
                    }
                }
            }

            Context 'Location consists of only one Folder and the Folder exists' {
                BeforeAll {
                    # Arrange
                    $inventoryBaseDSCProperties = New-MocksWhenLocationConsistsOfOnlyOneFolderAndTheFolderExists

                    $inventoryBaseDSC = New-Object -TypeName $inventoryBaseDSCClassName -Property $inventoryBaseDSCProperties
                    $inventoryBaseDSC.ConnectVIServer()
                }

                It 'Should return the Location: Datacenter Location Item One' {
                    # Act
                    $result = $inventoryBaseDSC.GetInventoryItemLocation()

                    # Assert
                    $result | Should -Be $script:locationDatacenterLocationItemOne
                }

                It 'Should call the Get-View mock with the passed Server and Inventory Root Folder once' {
                    # Act
                    $inventoryBaseDSC.GetInventoryItemLocation()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Get-View'
                        ParameterFilter = { $Server -eq $script:viServer -and $Id -eq $script:viServer.ExtensionData.Content.RootFolder }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }

                It 'Should call the Get-Inventory mock with the passed Server and Inventory Root Folder MoRef once' {
                    # Act
                    $inventoryBaseDSC.GetInventoryItemLocation()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Get-Inventory'
                        ParameterFilter = { $Server -eq $script:viServer -and $Id -eq $script:rootFolderViewBaseObject.MoRef }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }

                It 'Should call the Get-Inventory mock with the passed Server, Datacenter Location Item One and Inventory Root Folder Location once' {
                    # Act
                    $inventoryBaseDSC.GetInventoryItemLocation()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Get-Inventory'
                        ParameterFilter = { $Server -eq $script:viServer -and $Name -eq $inventoryBaseDSCProperties.Location -and $Location -eq $script:inventoryRootFolder }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Location consists of two Folders and the Location is valid' {
                BeforeAll {
                    # Arrange
                    $inventoryBaseDSCProperties = New-MocksWhenLocationConsistsOfTwoFoldersAndTheLocationIsValid

                    $inventoryBaseDSC = New-Object -TypeName $inventoryBaseDSCClassName -Property $inventoryBaseDSCProperties
                    $inventoryBaseDSC.ConnectVIServer()
                }

                It 'Should return the Location: Datacenter Location Item Two' {
                    # Act
                    $result = $inventoryBaseDSC.GetInventoryItemLocation()

                    # Assert
                    $result | Should -Be $script:locationDatacenterLocationItemTwo
                }

                It 'Should call the Get-View mock with the passed Server and Inventory Root Folder once' {
                    # Act
                    $inventoryBaseDSC.GetInventoryItemLocation()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Get-View'
                        ParameterFilter = { $Server -eq $script:viServer -and $Id -eq $script:viServer.ExtensionData.Content.RootFolder }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }

                It 'Should call the Get-Inventory mock with the passed Server and Inventory Root Folder MoRef once' {
                    # Act
                    $inventoryBaseDSC.GetInventoryItemLocation()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Get-Inventory'
                        ParameterFilter = { $Server -eq $script:viServer -and $Id -eq $script:rootFolderViewBaseObject.MoRef }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }

                It 'Should call the Get-View mock with the passed Server and Inventory Root Folder Child Entity once' {
                    # Act
                    $inventoryBaseDSC.GetInventoryItemLocation()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Get-View'
                        ParameterFilter = { $Server -eq $script:viServer -and (($Id | ConvertTo-Json) -eq ($script:inventoryRootFolder.ExtensionData.ChildEntity | ConvertTo-Json)) }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }

                It 'Should call the Get-View mock with the passed Server and Datacenter Location Item One Child Entity once' {
                    # Act
                    $inventoryBaseDSC.GetInventoryItemLocation()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Get-View'
                        ParameterFilter = { $Server -eq $script:viServer -and (($Id | ConvertTo-Json) -eq ($script:datacenterLocationItemOne.ChildEntity | ConvertTo-Json)) }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }

                It 'Should call the Get-View mock with the passed Server and Datacenter Location Item Two Child Entity once' {
                    # Act
                    $inventoryBaseDSC.GetInventoryItemLocation()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Get-View'
                        ParameterFilter = { $Server -eq $script:viServer -and (($Id | ConvertTo-Json) -eq ($script:datacenterLocationItemTwo.ChildEntity | ConvertTo-Json)) }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }

                It 'Should call the Get-Inventory mock with the passed Server and Datacenter Location Item Two MoRef once' {
                    # Act
                    $inventoryBaseDSC.GetInventoryItemLocation()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Get-Inventory'
                        ParameterFilter = { $Server -eq $script:viServer -and $Id -eq $script:datacenterLocationItemTwo.MoRef }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }
        }
    }
    finally {
        # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
        Invoke-TestCleanup -ModulePath $modulePath
    }
}
