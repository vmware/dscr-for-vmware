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
        $datacenterInventoryBaseDSCClassName = 'DatacenterInventoryBaseDSC'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
        . "$unitTestsFolder\TestHelpers\Mocks\DatacenterInventoryBaseDSCMocks.ps1"

        Describe 'DatacenterInventoryBaseDSC\GetDatacenter' -Tag 'GetDatacenter' {
            Context 'Empty Datacenter Location is passed and the Datacenter does not exist' {
                BeforeAll {
                    # Arrange
                    $datacenterInventoryBaseDSCProperties = New-MocksWhenEmptyDatacenterLocationIsPassedAndTheDatacenterDoesNotExist

                    $datacenterInventoryBaseDSC = New-Object -TypeName $datacenterInventoryBaseDSCClassName -Property $datacenterInventoryBaseDSCProperties
                    $datacenterInventoryBaseDSC.ConnectVIServer()
                }

                It 'Should call all defined mocks' {
                    try {
                        # Act
                        $datacenterInventoryBaseDSC.GetDatacenter()
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw the correct error when the Datacenter does not exist' {
                    # Act && Assert
                    { $datacenterInventoryBaseDSC.GetDatacenter() } | Should -Throw "Datacenter $($datacenterInventoryBaseDSCProperties.DatacenterName) was not found at $($script:inventoryRootFolder.Name)."
                }
            }

            Context 'Empty Datacenter Location is passed and the Datacenter exists' {
                BeforeAll {
                    # Arrange
                    $datacenterInventoryBaseDSCProperties = New-MocksWhenEmptyDatacenterLocationIsPassedAndTheDatacenterExists

                    $datacenterInventoryBaseDSC = New-Object -TypeName $datacenterInventoryBaseDSCClassName -Property $datacenterInventoryBaseDSCProperties
                    $datacenterInventoryBaseDSC.ConnectVIServer()
                }

                It 'Should call all defined mocks' {
                    # Act
                    $datacenterInventoryBaseDSC.GetDatacenter()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return the correct Datacenter with the correct parent: MyDatacenter with parent Inventory Root Folder' {
                    # Act
                    $result = $datacenterInventoryBaseDSC.GetDatacenter()

                    # Assert
                    $result | Should -Be $script:datacenterWithInventoryRootFolderAsParent
                }
            }

            Context 'Datacenter Location consists of only one Folder and the Folder does not exist' {
                BeforeAll {
                    # Arrange
                    $datacenterInventoryBaseDSCProperties = New-MocksWhenDatacenterLocationConsistsOfOnlyOneFolderAndTheFolderDoesNotExist

                    $datacenterInventoryBaseDSC = New-Object -TypeName $datacenterInventoryBaseDSCClassName -Property $datacenterInventoryBaseDSCProperties
                    $datacenterInventoryBaseDSC.ConnectVIServer()
                }

                It 'Should call all defined mocks' {
                    try {
                        # Act
                        $datacenterInventoryBaseDSC.GetDatacenter()
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw the correct error when the Folder Location does not exist' {
                    # Act && Assert
                    { $datacenterInventoryBaseDSC.GetDatacenter() } | Should -Throw "Folder $($script:constants.DatacenterLocationItemOne) was not found at $($script:inventoryRootFolder.Name)."
                }
            }

            Context 'Datacenter Location consists of only one Folder, the Folder exists and the Datacenter does not exist' {
                BeforeAll {
                    # Arrange
                    $datacenterInventoryBaseDSCProperties = New-MocksWhenDatacenterLocationConsistsOfOnlyOneFolderTheFolderExistsAndTheDatacenterDoesNotExist

                    $datacenterInventoryBaseDSC = New-Object -TypeName $datacenterInventoryBaseDSCClassName -Property $datacenterInventoryBaseDSCProperties
                    $datacenterInventoryBaseDSC.ConnectVIServer()
                }

                It 'Should call all defined mocks' {
                    try {
                        # Act
                        $datacenterInventoryBaseDSC.GetDatacenter()
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw the correct error when the Datacenter does not exist' {
                    # Act && Assert
                    { $datacenterInventoryBaseDSC.GetDatacenter() } | Should -Throw "Datacenter $($datacenterInventoryBaseDSCProperties.DatacenterName) was not found at $($script:constants.DatacenterLocationItemOne)."
                }
            }

            Context 'Datacenter Location consists of only one Folder, the Folder exists and the Datacenter exists' {
                BeforeAll {
                    # Arrange
                    $datacenterInventoryBaseDSCProperties = New-MocksWhenDatacenterLocationConsistsOfOnlyOneFolderTheFolderExistsAndTheDatacenterExists

                    $datacenterInventoryBaseDSC = New-Object -TypeName $datacenterInventoryBaseDSCClassName -Property $datacenterInventoryBaseDSCProperties
                    $datacenterInventoryBaseDSC.ConnectVIServer()
                }

                It 'Should call all defined mocks' {
                    # Act
                    $datacenterInventoryBaseDSC.GetDatacenter()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return the correct Datacenter with the correct parent: MyDatacenter with parent Datacenter Location Item One' {
                    # Act
                    $result = $datacenterInventoryBaseDSC.GetDatacenter()

                    # Assert
                    $result | Should -Be $script:datacenterWithDatacenterLocationItemOneAsParent
                }
            }

            Context 'Datacenter Location consists of two Inventory Items and one of them is a Datacenter' {
                BeforeAll {
                    # Arrange
                    $datacenterInventoryBaseDSCProperties = New-MocksWhenDatacenterLocationConsistsOfTwoInventoryItemsAndOneOfThemIsADatacenter

                    $datacenterInventoryBaseDSC = New-Object -TypeName $datacenterInventoryBaseDSCClassName -Property $datacenterInventoryBaseDSCProperties
                    $datacenterInventoryBaseDSC.ConnectVIServer()
                }

                It 'Should call all defined mocks' {
                    try {
                        # Act
                        $datacenterInventoryBaseDSC.GetDatacenter()
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw the correct error when the Datacenter Location contains a Datacenter' {
                    # Act && Assert
                    { $datacenterInventoryBaseDSC.GetDatacenter() } | Should -Throw "The Location $($datacenterInventoryBaseDSCProperties.DatacenterLocation) contains another Datacenter $($script:constants.DatacenterName)."
                }
            }

            Context 'Datacenter Location consists of two Folders and the Location is not valid' {
                BeforeAll {
                    # Arrange
                    $datacenterInventoryBaseDSCProperties = New-MocksWhenDatacenterLocationConsistsOfTwoFoldersAndTheLocationIsNotValid

                    $datacenterInventoryBaseDSC = New-Object -TypeName $datacenterInventoryBaseDSCClassName -Property $datacenterInventoryBaseDSCProperties
                    $datacenterInventoryBaseDSC.ConnectVIServer()
                }

                It 'Should call all defined mocks' {
                    try {
                        # Act
                        $datacenterInventoryBaseDSC.GetDatacenter()
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw the correct error when the Datacenter Location is not valid' {
                    # Act && Assert
                    { $datacenterInventoryBaseDSC.GetDatacenter() } | Should -Throw "Datacenter $($datacenterInventoryBaseDSCProperties.DatacenterName) with Location $($datacenterInventoryBaseDSCProperties.DatacenterLocation) was not found because $($script:constants.DatacenterLocationItemThree) folder cannot be found below $($script:InventoryRootFolder.Name)."
                }
            }

            Context 'Datacenter Location consists of two Folders, the Location is valid and the Datacenter does not exist' {
                BeforeAll {
                    # Arrange
                    $datacenterInventoryBaseDSCProperties = New-MocksWhenDatacenterLocationConsistsOfTwoFoldersTheLocationIsValidAndTheDatacenterDoesNotExist

                    $datacenterInventoryBaseDSC = New-Object -TypeName $datacenterInventoryBaseDSCClassName -Property $datacenterInventoryBaseDSCProperties
                    $datacenterInventoryBaseDSC.ConnectVIServer()
                }

                It 'Should call all defined mocks' {
                    try {
                        # Act
                        $datacenterInventoryBaseDSC.GetDatacenter()
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw the correct error when the Datacenter does not exist' {
                    # Act && Assert
                    { $datacenterInventoryBaseDSC.GetDatacenter() } | Should -Throw "Datacenter $($datacenterInventoryBaseDSCProperties.DatacenterName) with Location $($datacenterInventoryBaseDSCProperties.DatacenterLocation) was not found."
                }
            }

            Context 'Datacenter Location consists of two Folders, the Location is valid and the Datacenter exists' {
                BeforeAll {
                    # Arrange
                    $datacenterInventoryBaseDSCProperties = New-MocksWhenDatacenterLocationConsistsOfTwoFoldersTheLocationIsValidAndTheDatacenterExists

                    $datacenterInventoryBaseDSC = New-Object -TypeName $datacenterInventoryBaseDSCClassName -Property $datacenterInventoryBaseDSCProperties
                    $datacenterInventoryBaseDSC.ConnectVIServer()
                }

                It 'Should call all defined mocks' {
                    # Act
                    $datacenterInventoryBaseDSC.GetDatacenter()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return the correct Datacenter with the correct parent: MyDatacenter with parent Datacenter Location Item Two' {
                    # Act
                    $result = $datacenterInventoryBaseDSC.GetDatacenter()

                    # Assert
                    $result | Should -Be $script:datacenterWithDatacenterLocationItemTwoAsParent
                }
            }
        }

        Describe 'DatacenterInventoryBaseDSC\GetInventoryItemLocationInDatacenter' -Tag 'GetInventoryItemLocationInDatacenter' {
            Context 'Empty Location is passed' {
                BeforeAll {
                    # Arrange
                    $datacenterInventoryBaseDSCProperties = New-MocksWhenEmptyLocationIsPassed

                    $datacenterInventoryBaseDSC = New-Object -TypeName $datacenterInventoryBaseDSCClassName -Property $datacenterInventoryBaseDSCProperties
                    $datacenterInventoryBaseDSC.ConnectVIServer()
                    $datacenter = $datacenterInventoryBaseDSC.GetDatacenter()
                }

                It 'Should call all defined mocks' {
                    # Act
                    $datacenterInventoryBaseDSC.GetInventoryItemLocationInDatacenter($datacenter, 'HostFolder')

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return the correct Location with the correct parent: Datacenter Host Folder with parent My Datacenter' {
                    # Act
                    $result = $datacenterInventoryBaseDSC.GetInventoryItemLocationInDatacenter($datacenter, 'HostFolder')

                    # Assert
                    $result | Should -Be $script:datacenterHostFolder
                }
            }

            Context 'Location consists of one Inventory Item and the Inventory Item does not exist' {
                BeforeAll {
                    # Arrange
                    $datacenterInventoryBaseDSCProperties = New-MocksWhenLocationConsistsOfOneInventoryItemAndTheInventoryItemDoesNotExist

                    $datacenterInventoryBaseDSC = New-Object -TypeName $datacenterInventoryBaseDSCClassName -Property $datacenterInventoryBaseDSCProperties
                    $datacenterInventoryBaseDSC.ConnectVIServer()
                    $datacenter = $datacenterInventoryBaseDSC.GetDatacenter()
                }

                It 'Should call all defined mocks' {
                    try {
                        # Act
                        $datacenterInventoryBaseDSC.GetInventoryItemLocationInDatacenter($datacenter, 'HostFolder')
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw the correct error when the Inventory Item from the Location does not exist' {
                    # Act && Assert
                    { $datacenterInventoryBaseDSC.GetInventoryItemLocationInDatacenter($datacenter, 'HostFolder') } | Should -Throw "Location $($datacenterInventoryBaseDSCProperties.Location) of Inventory Item $($datacenterInventoryBaseDSCProperties.Name) was not found in Folder $($script:datacenterHostFolder.Name)."
                }
            }

            Context 'Location consists of one Inventory Item and the Inventory Item exists' {
                BeforeAll {
                    # Arrange
                    $datacenterInventoryBaseDSCProperties = New-MocksWhenLocationConsistsOfOneInventoryItemAndTheInventoryItemExists

                    $datacenterInventoryBaseDSC = New-Object -TypeName $datacenterInventoryBaseDSCClassName -Property $datacenterInventoryBaseDSCProperties
                    $datacenterInventoryBaseDSC.ConnectVIServer()
                    $datacenter = $datacenterInventoryBaseDSC.GetDatacenter()
                }

                It 'Should call all defined mocks' {
                    # Act
                    $datacenterInventoryBaseDSC.GetInventoryItemLocationInDatacenter($datacenter, 'HostFolder')

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return the correct Location with the correct parent: Inventory Item Location Item One with parent Datacenter Host Folder' {
                    # Act
                    $result = $datacenterInventoryBaseDSC.GetInventoryItemLocationInDatacenter($datacenter, 'HostFolder')

                    # Assert
                    $result | Should -Be $script:inventoryItemLocationItemOne
                }
            }

            Context 'Location consists of two Inventory Items and the Location is not valid' {
                BeforeAll {
                    # Arrange
                    $datacenterInventoryBaseDSCProperties = New-MocksWhenLocationConsistsOfTwoInventoryItemsAndTheLocationIsNotValid

                    $datacenterInventoryBaseDSC = New-Object -TypeName $datacenterInventoryBaseDSCClassName -Property $datacenterInventoryBaseDSCProperties
                    $datacenterInventoryBaseDSC.ConnectVIServer()
                    $datacenter = $datacenterInventoryBaseDSC.GetDatacenter()
                }

                It 'Should call all defined mocks' {
                    try {
                        # Act
                        $datacenterInventoryBaseDSC.GetInventoryItemLocationInDatacenter($datacenter, 'HostFolder')
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw the correct error when the Location is not valid' {
                    # Act && Assert
                    { $datacenterInventoryBaseDSC.GetInventoryItemLocationInDatacenter($datacenter, 'HostFolder') } | Should -Throw "Location $($datacenterInventoryBaseDSCProperties.Location) of Inventory Item $($datacenterInventoryBaseDSCProperties.Name) was not found in Datacenter $($datacenterInventoryBaseDSCProperties.DatacenterName)."
                }
            }

            Context 'Location consists of two Inventory Items and the Location is valid' {
                BeforeAll {
                    # Arrange
                    $datacenterInventoryBaseDSCProperties = New-MocksWhenLocationConsistsOfTwoInventoryItemsAndTheLocationIsValid

                    $datacenterInventoryBaseDSC = New-Object -TypeName $datacenterInventoryBaseDSCClassName -Property $datacenterInventoryBaseDSCProperties
                    $datacenterInventoryBaseDSC.ConnectVIServer()
                    $datacenter = $datacenterInventoryBaseDSC.GetDatacenter()
                }

                It 'Should call all defined mocks' {
                    # Act
                    $datacenterInventoryBaseDSC.GetInventoryItemLocationInDatacenter($datacenter, 'HostFolder')

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return the correct Location with the correct parent: Inventory Item Location Item Two with parent Inventory Item Location Item One' {
                    # Act
                    $result = $datacenterInventoryBaseDSC.GetInventoryItemLocationInDatacenter($datacenter, 'HostFolder')

                    # Assert
                    $result | Should -Be $script:foundLocations[0]
                }
            }
        }

        Describe 'DatacenterInventoryBaseDSC\GetInventoryItem' -Tag 'GetInventoryItem' {
            Context 'The Inventory Item does not exist at the specified Location' {
                BeforeAll {
                    # Arrange
                    $datacenterInventoryBaseDSCProperties = New-MocksWhenTheInventoryItemDoesNotExistAtTheSpecifiedLocation

                    $datacenterInventoryBaseDSC = New-Object -TypeName $datacenterInventoryBaseDSCClassName -Property $datacenterInventoryBaseDSCProperties
                    $datacenterInventoryBaseDSC.ConnectVIServer()
                    $datacenter = $datacenterInventoryBaseDSC.GetDatacenter()
                    $inventoryItemLocation = $datacenterInventoryBaseDSC.GetInventoryItemLocationInDatacenter($datacenter, 'HostFolder')
                }

                It 'Should call all defined mocks' {
                    # Act
                    $datacenterInventoryBaseDSC.GetInventoryItem($inventoryItemLocation)

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $null when the Inventory Item does not exist' {
                    # Act
                    $result = $datacenterInventoryBaseDSC.GetInventoryItem($inventoryItemLocation)

                    # Assert
                    $result | Should -Be $null
                }
            }

            Context 'The Inventory Item exists at the specified Location' {
                BeforeAll {
                    # Arrange
                    $datacenterInventoryBaseDSCProperties = New-MocksWhenTheInventoryItemExistsAtTheSpecifiedLocation

                    $datacenterInventoryBaseDSC = New-Object -TypeName $datacenterInventoryBaseDSCClassName -Property $datacenterInventoryBaseDSCProperties
                    $datacenterInventoryBaseDSC.ConnectVIServer()
                    $datacenter = $datacenterInventoryBaseDSC.GetDatacenter()
                    $inventoryItemLocation = $datacenterInventoryBaseDSC.GetInventoryItemLocationInDatacenter($datacenter, 'HostFolder')
                }

                It 'Should call all defined mocks' {
                    # Act
                    $datacenterInventoryBaseDSC.GetInventoryItem($inventoryItemLocation)

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return the Inventory Item My Resource Pool at the specified Location' {
                    # Act
                    $result = $datacenterInventoryBaseDSC.GetInventoryItem($inventoryItemLocation)

                    # Assert
                    $result | Should -Be $script:inventoryItemWithInventoryItemLocationItemTwoAsParent
                }
            }
        }
    }
    finally {
        # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
        Invoke-TestCleanup -ModulePath $modulePath
    }
}
