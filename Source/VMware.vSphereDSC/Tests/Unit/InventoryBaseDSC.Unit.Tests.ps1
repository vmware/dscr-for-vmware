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

function Invoke-TestSetup {
    $script:modulePath = $env:PSModulePath
    $script:unitTestsFolder = Join-Path (Join-Path (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase 'Tests') 'Unit'
    $script:mockModuleLocation = "$script:unitTestsFolder\TestHelpers"

    $script:moduleName = 'VMware.vSphereDSC'
    $script:inventoryHelperModuleName = 'VMware.vSphereDSC.Inventory.Helper'
    $script:inventoryBaseDSCClassName = 'InventoryBaseDSC'

    $script:user = 'user'
    $password = 'password' | ConvertTo-SecureString -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential($script:user, $password)

    $script:inventoryBaseDSCProperties = @{
        Server = '10.23.80.58'
        Credential = $credential
        Name = 'InventoryItemName'
        Path = [string]::Empty
        Ensure = 'Present'
    }

    $script:constants = @{
        FolderType = 'Folder'
        RootFolderValue = 'group-d1'
        DatacentersFolderId = 'Folder-group-d1'
        DatacentersFolderName = 'Datacenters'
        FolderId = 'MyFolder-folder-1'
        FolderName = 'MyFolder'
        PathItemOne = 'MyFolderOne'
        PathItemTwoId = 'my-folder-folder-two'
        PathItemTwo = 'MyFolderTwo'
    }

    $script:viServerScriptBlock = @'
        return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{
            Name = '$($script:inventoryBaseDSCProperties.Server)'
            User = '$($script:user)'
            ExtensionData = [VMware.Vim.ServiceInstance] @{
                Content = [VMware.Vim.ServiceContent] @{
                    RootFolder = [VMware.Vim.ManagedObjectReference] @{
                        Type = '$($script:constants.FolderType)'
                        Value = '$($script:constants.RootFolderValue)'
                    }
                }
            }
        }
'@

    $script:rootFolderViewBaseObjectScriptBlock = @'
        return [VMware.Vim.Folder] @{
            Name = '$($script:constants.DatacentersFolderName)'
            MoRef = [VMware.Vim.ManagedObjectReference] @{
                Type = '$($script:constants.FolderType)'
                Value = '$($script:constants.RootFolderValue)'
            }
        }
'@

    $script:datacentersFolderScriptBlock = @'
        return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
            Id = '$($script:constants.DatacentersFolderId)'
            Name = '$($script:constants.DatacentersFolderName)'
            ExtensionData = [VMware.Vim.Folder] @{
                ChildEntity = @(
                    [VMware.Vim.ManagedObjectReference] @{
                        Type = '$($script:constants.FolderType)'
                        Value = '$($script:constants.PathItemOne)'
                    }
                )
            }
        }
'@

    $script:folderScriptBlock = @'
        return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
            Id = '$($script:constants.FolderId)'
            Name = '$($script:constants.FolderName)'
            ParentId = '$($script:constants.DatacentersFolderId)'
        }
'@

    $script:pathItemOneScriptBlock = @'
        return [VMware.Vim.Folder] @{
            Name = '$($script:constants.PathItemOne)'
            ChildEntity = @(
                [VMware.Vim.ManagedObjectReference] @{
                    Type = '$($script:constants.FolderType)'
                    Value = '$($script:constants.PathItemTwo)'
                }
            )
        }
'@

    $script:pathItemTwoScriptBlock = @'
        return [VMware.Vim.Folder] @{
            Name = '$($script:constants.PathItemTwo)'
            ChildEntity = @(
                [VMware.Vim.ManagedObjectReference] @{
                    Type = '$($script:constants.FolderType)'
                    Value = 'PathItemTwo Child Entity'
                }
            )
            MoRef = [VMware.Vim.ManagedObjectReference] @{
                Type = '$($script:constants.FolderType)'
                Value = '$($script:constants.PathItemTwoId)'
            }
        }
'@

    $script:locationParentScriptBlock = @'
        return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
            Id = '$($script:constants.PathItemTwoId)'
            Name = '$($script:constants.PathItemTwo)'
        }
'@

    $script:folderWithPathItemTwoAsParentScriptBlock = @'
        return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
            Id = '$($script:constants.FolderId)'
            Name = '$($script:constants.FolderName)'
            ParentId = '$($script:constants.PathItemTwoId)'
        }
'@

    $env:PSModulePath = $script:mockModuleLocation
    $vimAutomationModule = Get-Module -Name VMware.VimAutomation.Core
    if ($null -ne $vimAutomationModule -and $vimAutomationModule.Path -NotMatch 'TestHelpers') {
        throw 'The Original VMware.VimAutomation.Core Module is loaded in the current session. If you want to run the unit tests please open a new PowerShell session.'
    }

    Import-Module -Name VMware.VimAutomation.Core

    $script:viServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{
        Name = $script:inventoryBaseDSCProperties.Server
        User = $script:user
        ExtensionData = [VMware.Vim.ServiceInstance] @{
            Content = [VMware.Vim.ServiceContent] @{
                RootFolder = [VMware.Vim.ManagedObjectReference] @{
                    Type = $script:constants.FolderType
                    Value = $script:constants.RootFolderValue
                }
            }
        }
    }

    $script:rootFolder = [VMware.Vim.ManagedObjectReference] @{
        Type = $script:constants.FolderType
        Value = $script:constants.RootFolderValue
    }

    $script:datacentersFolder = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
        Id = $script:constants.DatacentersFolderId
        Name = $script:constants.DatacentersFolderName
        ExtensionData = [VMware.Vim.Folder] @{
            ChildEntity = @(
                [VMware.Vim.ManagedObjectReference] @{
                    Type = $script:constants.FolderType
                    Value = $script:constants.PathItemOne
                }
            )
        }
    }

    $script:pathItemOne = @([VMware.Vim.ManagedObjectReference] @{
        Type = $script:constants.FolderType
        Value = $script:constants.PathItemOne
    })

    $script:pathItemTwo = @([VMware.Vim.ManagedObjectReference] @{
        Type = $script:constants.FolderType
        Value = $script:constants.PathItemTwo
    })

    $script:locationParent = [VMware.Vim.ManagedObjectReference] @{
        Type = $script:constants.FolderType
        Value = $script:constants.PathItemTwoId
    }

    $script:locationFolder = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
        Id = $script:constants.PathItemTwoId
        Name = $script:constants.PathItemTwo
    }
}

function Invoke-TestCleanup {
    Remove-Module -Name VMware.VimAutomation.Core
    $env:PSModulePath = $script:modulePath
}

try {
    # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
    Invoke-TestSetup

    Describe 'InventoryBaseDSC\GetRootFolderOfInventory' -Tag 'GetRootFolderOfInventory' {
        BeforeAll {
            # Arrange
            $viServerMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:viServerScriptBlock))
            $rootFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:rootFolderViewBaseObjectScriptBlock))
            $datacentersFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacentersFolderScriptBlock))

            Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $rootFolderMock -ModuleName $script:moduleName
            Mock -CommandName Get-Inventory -MockWith $datacentersFolderMock -ModuleName $script:moduleName

            $inventoryBaseDSC = New-Object -TypeName $script:inventoryBaseDSCClassName -Property $script:inventoryBaseDSCProperties
            $inventoryBaseDSC.ConnectVIServer()
        }

        It 'Should call the Get-View mock with the passed Server and VIServer Root Folder once' {
            # Act
            $inventoryBaseDSC.GetRootFolderOfInventory()

            # Assert
            $assertMockCalledParams = @{
                CommandName = 'Get-View'
                ParameterFilter = { $Server -eq $script:viServer -and $Id -eq $script:rootFolder }
                ModuleName = $script:moduleName
                Exactly = $true
                Times = 1
                Scope = 'It'
            }

            Assert-MockCalled @assertMockCalledParams
        }

        It 'Should call the Get-Inventory mock with the passed Server and Root Folder ViewBase Object once' {
            # Act
            $inventoryBaseDSC.GetRootFolderOfInventory()

            # Assert
            $assertMockCalledParams = @{
                CommandName = 'Get-Inventory'
                ParameterFilter = { $Server -eq $script:viServer -and $Id -eq $script:rootFolder }
                ModuleName = $script:moduleName
                Exactly = $true
                Times = 1
                Scope = 'It'
            }

            Assert-MockCalled @assertMockCalledParams
        }
    }

    Describe 'InventoryBaseDSC\GetInventoryItemLocationFromPath' -Tag 'GetInventoryItemLocationFromPath' {
        Context 'Empty Path is passed' {
            BeforeAll {
                # Arrange
                $viServerMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:viServerScriptBlock))
                $rootFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:rootFolderViewBaseObjectScriptBlock))
                $datacentersFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacentersFolderScriptBlock))

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $rootFolderMock -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $datacentersFolderMock -ModuleName $script:moduleName

                $inventoryBaseDSC = New-Object -TypeName $script:inventoryBaseDSCClassName -Property $script:inventoryBaseDSCProperties
                $inventoryBaseDSC.ConnectVIServer()
                $viServerRootFolder = $inventoryBaseDSC.GetRootFolderOfInventory()
            }

            It 'Should return the VIServer Root Folder' {
                # Act
                $result = $inventoryBaseDSC.GetInventoryItemLocationFromPath($viServerRootFolder)

                # Assert
                $result | Should -Be $script:datacentersFolder
            }
        }

        Context 'Path consists only of one Folder name and the Folder does not exist' {
            BeforeAll {
                # Arrange
                $script:inventoryBaseDSCProperties.Path = $script:constants.FolderName

                $viServerMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:viServerScriptBlock))
                $rootFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:rootFolderViewBaseObjectScriptBlock))
                $datacentersFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacentersFolderScriptBlock))

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $rootFolderMock -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $datacentersFolderMock -ModuleName $script:moduleName
                Mock -CommandName Get-Folder -MockWith { return $null } -ModuleName $script:inventoryHelperModuleName

                $inventoryBaseDSC = New-Object -TypeName $script:inventoryBaseDSCClassName -Property $script:inventoryBaseDSCProperties
                $inventoryBaseDSC.ConnectVIServer()
                $viServerRootFolder = $inventoryBaseDSC.GetRootFolderOfInventory()
            }

            AfterAll {
                $script:inventoryBaseDSCProperties.Path = [string]::Empty
            }

            It 'Should throw when Path consists only of one Folder name and the Folder does not exist' {
                # Act && Assert
                { $inventoryBaseDSC.GetInventoryItemLocationFromPath($viServerRootFolder) } | Should -Throw "Folder with name $($script:inventoryBaseDSCProperties.Path) was not found in $($script:datacentersFolder.Name)."
            }

            It 'Should call the Get-Folder mock with the passed Server, Folder name and Datacenters Folder Location once' {
                try {
                    # Act
                    $inventoryBaseDSC.GetInventoryItemLocationFromPath($viServerRootFolder)
                }
                catch {
                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Get-Folder'
                        ParameterFilter = { $Server -eq $script:viServer -and $Name -eq $script:inventoryBaseDSCProperties.Path -and $Location -eq $script:datacentersFolder }
                        ModuleName = $script:inventoryHelperModuleName
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }
        }

        Context 'Path consists only of one Folder name and the Folder exists' {
            BeforeAll {
                # Arrange
                $script:inventoryBaseDSCProperties.Path = $script:constants.FolderName

                $viServerMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:viServerScriptBlock))
                $rootFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:rootFolderViewBaseObjectScriptBlock))
                $datacentersFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacentersFolderScriptBlock))
                $folderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:folderScriptBlock))

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $rootFolderMock -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $datacentersFolderMock -ModuleName $script:moduleName
                Mock -CommandName Get-Folder -MockWith $folderMock -ModuleName $script:inventoryHelperModuleName

                $inventoryBaseDSC = New-Object -TypeName $script:inventoryBaseDSCClassName -Property $script:inventoryBaseDSCProperties
                $inventoryBaseDSC.ConnectVIServer()
                $viServerRootFolder = $inventoryBaseDSC.GetRootFolderOfInventory()
            }

            AfterAll {
                $script:inventoryBaseDSCProperties.Path = [string]::Empty
            }

            It 'Should not throw when Path consists only of one Folder name and the Folder exists' {
                # Act && Assert
                { $inventoryBaseDSC.GetInventoryItemLocationFromPath($viServerRootFolder) } | Should -Not -Throw
            }

            It 'Should call the Get-Folder mock with the passed Server, Folder name and Datacenters Folder Location once' {
                # Act
                $inventoryBaseDSC.GetInventoryItemLocationFromPath($viServerRootFolder)

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-Folder'
                    ParameterFilter = { $Server -eq $script:viServer -and $Name -eq $script:inventoryBaseDSCProperties.Path -and $Location -eq $script:datacentersFolder }
                    ModuleName = $script:inventoryHelperModuleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Path consists of two Folders and the Location name of the Inventory Item and the Location does not exist' {
            BeforeAll {
                # Arrange
                $script:inventoryBaseDSCProperties.Path = "$($script:constants.PathItemOne)/$($script:constants.PathItemTwo)/$($script:constants.FolderName)"

                $viServerMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:viServerScriptBlock))
                $rootFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:rootFolderViewBaseObjectScriptBlock))
                $datacentersFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacentersFolderScriptBlock))
                $pathItemOneMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:pathItemOneScriptBlock))
                $pathItemTwoMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:pathItemTwoScriptBlock))
                $locationParentMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationParentScriptBlock))

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $rootFolderMock -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:rootFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $datacentersFolderMock -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:rootFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $pathItemOneMock -ParameterFilter { $Server -eq $script:viServer -and (($Id | ConvertTo-Json) -eq ($script:pathItemOne | ConvertTo-Json)) } -ModuleName $script:inventoryHelperModuleName
                Mock -CommandName Get-View -MockWith $pathItemTwoMock -ParameterFilter { $Server -eq $script:viServer -and (($Id | ConvertTo-Json) -eq ($script:pathItemTwo | ConvertTo-Json)) } -ModuleName $script:inventoryHelperModuleName
                Mock -CommandName Get-Inventory -MockWith $locationParentMock -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:locationParent } -ModuleName $script:inventoryHelperModuleName
                Mock -CommandName Get-Folder -MockWith { return $null } -ModuleName $script:inventoryHelperModuleName

                $inventoryBaseDSC = New-Object -TypeName $script:inventoryBaseDSCClassName -Property $script:inventoryBaseDSCProperties
                $inventoryBaseDSC.ConnectVIServer()
                $viServerRootFolder = $inventoryBaseDSC.GetRootFolderOfInventory()
            }

            AfterAll {
                $script:inventoryBaseDSCProperties.Path = [string]::Empty
            }

            It 'Should throw when Path consists of two Folders and the Location name of the Inventory Item and the Location does not exist' {
                # Act && Assert
                { $inventoryBaseDSC.GetInventoryItemLocationFromPath($viServerRootFolder) } | Should -Throw "The Location of Inventory Item $($script:inventoryBaseDSCProperties.Name) was not found in the specified Inventory."
            }

            It 'Should call the Get-View mock with the passed Server and MyFolderOne once' {
                try {
                    # Act
                    $inventoryBaseDSC.GetInventoryItemLocationFromPath($viServerRootFolder)
                }
                catch {
                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Get-View'
                        ParameterFilter = { $Server -eq $script:viServer -and (($Id | ConvertTo-Json) -eq ($script:pathItemOne | ConvertTo-Json)) }
                        ModuleName = $script:inventoryHelperModuleName
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            It 'Should call the Get-View mock with the passed Server and MyFolderTwo once' {
                try {
                    # Act
                    $inventoryBaseDSC.GetInventoryItemLocationFromPath($viServerRootFolder)
                }
                catch {
                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Get-View'
                        ParameterFilter = { $Server -eq $script:viServer -and (($Id | ConvertTo-Json) -eq ($script:pathItemTwo | ConvertTo-Json)) }
                        ModuleName = $script:inventoryHelperModuleName
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            It 'Should call the Get-Inventory mock with the passed Server and MyFolderTwo once' {
                try {
                    # Act
                    $inventoryBaseDSC.GetInventoryItemLocationFromPath($viServerRootFolder)
                }
                catch {
                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Get-Inventory'
                        ParameterFilter = { $Server -eq $script:viServer -and $Id -eq $script:locationParent }
                        ModuleName = $script:inventoryHelperModuleName
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            It 'Should call the Get-Folder mock with the passed Server, Location Name and MyFolderTwo Location once' {
                try {
                    # Act
                    $inventoryBaseDSC.GetInventoryItemLocationFromPath($viServerRootFolder)
                }
                catch {
                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Get-Folder'
                        ParameterFilter = { $Server -eq $script:viServer -and $Name -eq $script:constants.FolderName -and $Location -eq $script:locationFolder }
                        ModuleName = $script:inventoryHelperModuleName
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }
        }

        Context 'Path consists of two Folders and the Location name of the Inventory Item and the Location exists' {
            BeforeAll {
                # Arrange
                $script:inventoryBaseDSCProperties.Path = "$($script:constants.PathItemOne)/$($script:constants.PathItemTwo)/$($script:constants.FolderName)"

                $viServerMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:viServerScriptBlock))
                $rootFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:rootFolderViewBaseObjectScriptBlock))
                $datacentersFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacentersFolderScriptBlock))
                $pathItemOneMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:pathItemOneScriptBlock))
                $pathItemTwoMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:pathItemTwoScriptBlock))
                $locationParentMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationParentScriptBlock))
                $locationMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:folderWithPathItemTwoAsParentScriptBlock))

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $rootFolderMock -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:rootFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $datacentersFolderMock -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:rootFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $pathItemOneMock -ParameterFilter { $Server -eq $script:viServer -and (($Id | ConvertTo-Json) -eq ($script:pathItemOne | ConvertTo-Json)) } -ModuleName $script:inventoryHelperModuleName
                Mock -CommandName Get-View -MockWith $pathItemTwoMock -ParameterFilter { $Server -eq $script:viServer -and (($Id | ConvertTo-Json) -eq ($script:pathItemTwo | ConvertTo-Json)) } -ModuleName $script:inventoryHelperModuleName
                Mock -CommandName Get-Inventory -MockWith $locationParentMock -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:locationParent } -ModuleName $script:inventoryHelperModuleName
                Mock -CommandName Get-Folder -MockWith $locationMock -ModuleName $script:inventoryHelperModuleName

                $inventoryBaseDSC = New-Object -TypeName $script:inventoryBaseDSCClassName -Property $script:inventoryBaseDSCProperties
                $inventoryBaseDSC.ConnectVIServer()
                $viServerRootFolder = $inventoryBaseDSC.GetRootFolderOfInventory()
            }

            AfterAll {
                $script:inventoryBaseDSCProperties.Path = [string]::Empty
            }

            It 'Should not throw when Path consists of two Folders and the Location name of the Inventory Item and the Location does not exist' {
                # Act && Assert
                { $inventoryBaseDSC.GetInventoryItemLocationFromPath($viServerRootFolder) } | Should -Not -Throw
            }

            It 'Should call the Get-View mock with the passed Server and MyFolderOne once' {
                # Act
                $inventoryBaseDSC.GetInventoryItemLocationFromPath($viServerRootFolder)

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-View'
                    ParameterFilter = { $Server -eq $script:viServer -and (($Id | ConvertTo-Json) -eq ($script:pathItemOne | ConvertTo-Json)) }
                    ModuleName = $script:inventoryHelperModuleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-View mock with the passed Server and MyFolderTwo once' {
                # Act
                $inventoryBaseDSC.GetInventoryItemLocationFromPath($viServerRootFolder)

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-View'
                    ParameterFilter = { $Server -eq $script:viServer -and (($Id | ConvertTo-Json) -eq ($script:pathItemTwo | ConvertTo-Json)) }
                    ModuleName = $script:inventoryHelperModuleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-Inventory mock with the passed Server and MyFolderTwo once' {
                # Act
                $inventoryBaseDSC.GetInventoryItemLocationFromPath($viServerRootFolder)

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-Inventory'
                    ParameterFilter = { $Server -eq $script:viServer -and $Id -eq $script:locationParent }
                    ModuleName = $script:inventoryHelperModuleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-Folder mock with the passed Server, Location Name and MyFolderTwo Location once' {
                # Act
                $inventoryBaseDSC.GetInventoryItemLocationFromPath($viServerRootFolder)

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-Folder'
                    ParameterFilter = { $Server -eq $script:viServer -and $Name -eq $script:constants.FolderName -and $Location -eq $script:locationFolder }
                    ModuleName = $script:inventoryHelperModuleName
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
    Invoke-TestCleanup
}
