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
    $script:datacenterInventoryBaseDSCClassName = 'DatacenterInventoryBaseDSC'

    $script:user = 'user'
    $password = 'password' | ConvertTo-SecureString -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential($script:user, $password)

    $script:datacenterInventoryBaseDSCProperties = @{
        Server = '10.23.80.58'
        Credential = $credential
        Name = 'InventoryItemName'
        Ensure = 'Present'
    }

    $script:constants = @{
        FolderType = 'Folder'
        RootFolderValue = 'group-d1'
        DatacentersFolderId = 'Folder-group-d1'
        DatacentersFolderName = 'Datacenters'
        DatacenterId = 'MyDatacenter-datacenter-1'
        DatacenterName = 'MyDatacenter'
        DatacenterPathItemOne = 'MyDatacenterFolderOne'
        DatacenterPathItemTwoId = 'my-datacenter-folder-two'
        DatacenterPathItemTwo = 'MyDatacenterFolderTwo'
        DatacenterFolderType = 'Host'
        HostFolderId = 'group-h4'
        HostFolderName = 'HostFolder'
        DatacenterInventoryPathItemOneId = 'my-inventory-item-location-one'
        DatacenterInventoryPathItemOne = 'MyInventoryItemFolderOne'
        DatacenterInventoryPathItemTwoId = 'my-inventory-item-location-two'
        DatacenterInventoryPathItemTwo = 'MyInventoryItemFolderTwo'
    }

	$script:vCenterScriptBlock = @'
        return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{
            Name = '$($script:datacenterInventoryBaseDSCProperties.Server)'
            User = '$($script:user)'
        }
'@

    $script:vCenterScriptBlock = @'
        return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{
            Name = '$($script:datacenterInventoryBaseDSCProperties.Server)'
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
            ChildEntity = @(
                [VMware.Vim.ManagedObjectReference] @{
                    Type = '$($script:constants.FolderType)'
                    Value = '$($script:constants.DatacenterPathItemOne)'
                }
            )
        }
'@

    $script:datacentersFolderScriptBlock = @'
        return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
            Id = '$($script:constants.DatacentersFolderId)'
            Name = '$($script:constants.DatacentersFolderName)'
        }
'@

    $script:datacenterScriptBlock = @'
        return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.DatacenterImpl] @{
            Id = '$($script:constants.DatacenterId)'
            Name = '$($script:constants.DatacenterName)'
            ParentFolderId = '$($script:constants.DatacentersFolderId)'
        }
'@

    $script:datacenterPathItemOneScriptBlock = @'
        return [VMware.Vim.Folder] @{
            Name = '$($script:constants.DatacenterPathItemOne)'
            ChildEntity = @(
                [VMware.Vim.ManagedObjectReference] @{
                    Type = '$($script:constants.FolderType)'
                    Value = '$($script:constants.DatacenterPathItemTwo)'
                }
            )
        }
'@

    $script:datacenterPathItemTwoScriptBlock = @'
        return [VMware.Vim.Folder] @{
            Name = '$($script:constants.DatacenterPathItemTwo)'
            ChildEntity = @(
                [VMware.Vim.ManagedObjectReference] @{
                    Type = '$($script:constants.FolderType)'
                    Value = 'DatacenterPathItemTwo Child Entity'
                }
            )
            MoRef = [VMware.Vim.ManagedObjectReference] @{
                Type = '$($script:constants.FolderType)'
                Value = '$($script:constants.DatacenterPathItemTwoId)'
            }
        }
'@

    $script:datacenterFolderScriptBlock = @'
        return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
            Id = '$($script:constants.DatacenterPathItemTwoId)'
            Name = '$($script:constants.DatacenterPathItemTwo)'
        }
'@

    $script:datacenterWithPathItemTwoAsParentScriptBlock = @'
        return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.DatacenterImpl] @{
            Id = '$($script:constants.DatacenterId)'
            Name = '$($script:constants.DatacenterName)'
            ParentFolderId = '$($script:constants.DatacenterPathItemTwoId)'
            ExtensionData = [VMware.Vim.Datacenter] @{
                HostFolder = [VMware.Vim.ManagedObjectReference] @{
                    Type = '$($script:constants.FolderType)'
                    Value = '$($script:constants.HostFolderId)'
                }
            }
        }
'@

    $script:hostFolderOfDatacenterViewBaseObjectScriptBlock = @'
        return [VMware.Vim.Folder] @{
            Name = '$($script:constants.HostFolderName)'
            MoRef = [VMware.Vim.ManagedObjectReference] @{
                Type = '$($script:constants.FolderType)'
                Value = '$($script:constants.HostFolderId)'
            }
        }
'@

    $script:hostFolderScriptBlock = @'
        return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
            Id = '$($script:constants.HostFolderId)'
            Name = '$($script:constants.HostFolderName)'
        }
'@

    $script:inventoryItemPathItemOneLocationScriptBlock = @'
        return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
            Id = '$($script:constants.DatacenterInventoryPathItemOneId)'
            Name = '$($script:constants.DatacenterInventoryPathItemOne)'
            ParentId = '$($script:constants.HostFolderId)'
        }
'@

    $script:locationsScriptBlock = @'
        return @(
            [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
                Id = '$($script:constants.DatacenterInventoryPathItemTwoId)'
            }
        )
'@

    $script:locationViewBaseObjectScriptBlock = @'
        return [VMware.Vim.Folder] @{
            Name = '$($script:constants.DatacenterInventoryPathItemTwo)'
            Parent = [VMware.Vim.ManagedObjectReference] @{
                Type = '$($script:constants.FolderType)'
                Value = '$($script:constants.DatacenterInventoryPathItemOneId)'
            }
        }
'@

    $script:locationInvalidParentScriptBlock = @'
        return [VMware.Vim.Folder] @{
            Name = '$($script:constants.HostFolderName)'
            Parent = [VMware.Vim.ManagedObjectReference] @{
                Type = '$($script:constants.FolderType)'
                Value = '$($script:constants.HostFolderId)'
            }
        }
'@

    $script:locationParentScriptBlock = @'
        return [VMware.Vim.Folder] @{
            Name = '$($script:constants.DatacenterInventoryPathItemOne)'
            Parent = [VMware.Vim.ManagedObjectReference] @{
                Type = '$($script:constants.FolderType)'
                Value = '$($script:constants.DatacenterInventoryPathItemOneId)'
            }
        }
'@

	$env:PSModulePath = $script:mockModuleLocation
    $vimAutomationModule = Get-Module -Name VMware.VimAutomation.Core
    if ($null -ne $vimAutomationModule -and $vimAutomationModule.Path -NotMatch 'TestHelpers') {
        throw 'The Original VMware.VimAutomation.Core Module is loaded in the current session. If you want to run the unit tests please open a new PowerShell session.'
    }

    Import-Module -Name VMware.VimAutomation.Core

    $script:vCenter = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{
        Name = $script:datacenterInventoryBaseDSCProperties.Server
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
    }

    $script:datacenterPathItemOne = @([VMware.Vim.ManagedObjectReference] @{
        Type = $script:constants.FolderType
        Value = $script:constants.DatacenterPathItemOne
    })

    $script:datacenterPathItemTwo = @([VMware.Vim.ManagedObjectReference] @{
        Type = $script:constants.FolderType
        Value = $script:constants.DatacenterPathItemTwo
    })

    $script:datacenterLocation = [VMware.Vim.ManagedObjectReference] @{
        Type = $script:constants.FolderType
        Value = $script:constants.DatacenterPathItemTwoId
    }

    $script:datacenterFolder = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
        Id = $script:constants.DatacenterPathItemTwoId
        Name = $script:constants.DatacenterPathItemTwo
    }

    $script:hostFolder = [VMware.Vim.ManagedObjectReference] @{
        Type = $script:constants.FolderType
        Value = $script:constants.HostFolderId
    }

    $script:hostFolderLocation = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
        Id = $script:constants.HostFolderId
        Name = $script:constants.HostFolderName
    }

    $script:locationParent = [VMware.Vim.ManagedObjectReference] @{
        Type = $script:constants.FolderType
        Value = $script:constants.DatacenterInventoryPathItemOneId
    }

    $script:validLocation = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
        Id = $script:constants.DatacenterInventoryPathItemTwoId
    }
}

function Invoke-TestCleanup {
    Remove-Module -Name VMware.VimAutomation.Core
    $env:PSModulePath = $script:modulePath
}

try {
	# Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
    Invoke-TestSetup

	Describe 'InventoryBaseDSC\GetDatacenterFromPath' -Tag 'GetDatacenterFromPath' {
        Context 'Empty Datacenter path is passed' {
            BeforeAll {
                # Arrange
                $script:datacenterInventoryBaseDSCProperties.Datacenter = [string]::Empty
                $vCenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vCenterScriptBlock))

                Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName

                $datacenterInventoryBaseDSC = New-Object -TypeName $script:datacenterInventoryBaseDSCClassName -Property $script:datacenterInventoryBaseDSCProperties
                $datacenterInventoryBaseDSC.ConnectVIServer()
            }

            AfterAll {
                $script:datacenterInventoryBaseDSCProperties.Datacenter = [string]::Empty
            }

            It 'Should throw when Empty Datacenter path is passed' {
                # Act && Assert
                { $datacenterInventoryBaseDSC.GetDatacenterFromPath() } | Should -Throw 'You have passed an empty path which is not a valid value.'
            }
        }

        Context 'Datacenter Path consists only of the Datacenter name and the Datacenter does not exist' {
            BeforeAll {
                # Arrange
                $script:datacenterInventoryBaseDSCProperties.Datacenter = $script:constants.DatacenterName

                $vCenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vCenterScriptBlock))
                $rootFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:rootFolderViewBaseObjectScriptBlock))
                $datacentersFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacentersFolderScriptBlock))

                Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $rootFolderMock -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $datacentersFolderMock -ModuleName $script:moduleName
                Mock -CommandName Get-Datacenter -MockWith { return $null } -ModuleName $script:moduleName

                $datacenterInventoryBaseDSC = New-Object -TypeName $script:datacenterInventoryBaseDSCClassName -Property $script:datacenterInventoryBaseDSCProperties
                $datacenterInventoryBaseDSC.ConnectVIServer()
            }

            AfterAll {
                $script:datacenterInventoryBaseDSCProperties.Datacenter = [string]::Empty
            }

            It 'Should throw when Datacenter Path consists only of the Datacenter name and the Datacenter does not exist' {
                # Act && Assert
                { $datacenterInventoryBaseDSC.GetDatacenterFromPath() } | Should -Throw "Datacenter with name $($script:datacenterInventoryBaseDSCProperties.Datacenter) was not found at Datacenters."
            }

            It 'Should call the Get-View mock with the passed Server and vCenter Root Folder once' {
                try {
                    # Act
                    $datacenterInventoryBaseDSC.GetDatacenterFromPath()
                }
                catch {
                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Get-View'
                        ParameterFilter = { $Server -eq $script:vCenter -and $Id -eq $rootFolder }
                        ModuleName = $script:moduleName
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            It 'Should call the Get-Inventory mock with the passed Server and Root Folder ViewBase Object once' {
                try {
                    # Act
                    $datacenterInventoryBaseDSC.GetDatacenterFromPath()
                }
                catch {
                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Get-Inventory'
                        ParameterFilter = { $Server -eq $script:vCenter -and $Id -eq $rootFolder }
                        ModuleName = $script:moduleName
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            It 'Should call the Get-Datacenter mock with the passed Server, Datacenter Name and Datacenters Folder Location once' {
                try {
                    # Act
                    $datacenterInventoryBaseDSC.GetDatacenterFromPath()
                }
                catch {
                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Get-Datacenter'
                        ParameterFilter = { $Server -eq $script:vCenter -and $Name -eq $script:datacenterInventoryBaseDSCProperties.Datacenter -and $Location -eq $script:datacentersFolder }
                        ModuleName = $script:moduleName
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }
        }

        Context 'Datacenter Path consists only of the Datacenter name and the Datacenter exists' {
            BeforeAll {
                # Arrange
                $script:datacenterInventoryBaseDSCProperties.Datacenter = $script:constants.DatacenterName
                $script:datacenterInventoryBaseDSCProperties.DatacenterInventoryPath = [string]::Empty

                $vCenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vCenterScriptBlock))
                $rootFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:rootFolderViewBaseObjectScriptBlock))
                $datacentersFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacentersFolderScriptBlock))
                $datacenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterScriptBlock))

                Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $rootFolderMock -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $datacentersFolderMock -ModuleName $script:moduleName
                Mock -CommandName Get-Datacenter -MockWith $datacenterMock -ModuleName $script:moduleName

                $datacenterInventoryBaseDSC = New-Object -TypeName $script:datacenterInventoryBaseDSCClassName -Property $script:datacenterInventoryBaseDSCProperties
                $datacenterInventoryBaseDSC.ConnectVIServer()
            }

            AfterAll {
                $script:datacenterInventoryBaseDSCProperties.Datacenter = [string]::Empty
                $script:datacenterInventoryBaseDSCProperties.DatacenterInventoryPath = [string]::Empty
            }

            It 'Should not throw when Datacenter Path consists only of the Datacenter name and the Datacenter exists' {
                # Act && Assert
                { $datacenterInventoryBaseDSC.GetDatacenterFromPath() } | Should -Not -Throw
            }

            It 'Should call the Get-View mock with the passed Server and vCenter Root Folder once' {
                # Act
                $datacenterInventoryBaseDSC.GetDatacenterFromPath()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-View'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Id -eq $script:rootFolder }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-Inventory mock with the passed Server and Root Folder ViewBase Object once' {
                # Act
                $datacenterInventoryBaseDSC.GetDatacenterFromPath()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-Inventory'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Id -eq $rootFolder }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-Datacenter mock with the passed Server, Datacenter Name and Datacenters Folder Location once' {
                # Act
                $datacenterInventoryBaseDSC.GetDatacenterFromPath()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-Datacenter'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Name -eq $script:datacenterInventoryBaseDSCProperties.Datacenter -and $Location -eq $script:datacentersFolder }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Datacenter Path consists of two Folders and the Datacenter name and the Datacenter does not exist' {
            BeforeAll {
                # Arrange
                $script:datacenterInventoryBaseDSCProperties.Datacenter = "$($script:constants.DatacenterPathItemOne)/$($script:constants.DatacenterPathItemTwo)/$($script:constants.DatacenterName)"

                $vCenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vCenterScriptBlock))
                $rootFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:rootFolderViewBaseObjectScriptBlock))
                $datacenterPathItemOneMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemOneScriptBlock))
                $datacenterPathItemTwoMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemTwoScriptBlock))
                $datacenterFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterFolderScriptBlock))

                Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $rootFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:rootFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $datacenterPathItemOneMock -ParameterFilter { $Server -eq $script:vCenter -and (($Id | ConvertTo-Json) -eq ($script:datacenterPathItemOne | ConvertTo-Json)) } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $datacenterPathItemTwoMock -ParameterFilter { $Server -eq $script:vCenter -and (($Id | ConvertTo-Json) -eq ($script:datacenterPathItemTwo | ConvertTo-Json)) } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $datacenterFolderMock -ModuleName $script:moduleName
                Mock -CommandName Get-Datacenter -MockWith { return $null } -ModuleName $script:moduleName

                $datacenterInventoryBaseDSC = New-Object -TypeName $script:datacenterInventoryBaseDSCClassName -Property $script:datacenterInventoryBaseDSCProperties
                $datacenterInventoryBaseDSC.ConnectVIServer()
            }

            AfterAll {
                $script:datacenterInventoryBaseDSCProperties.Datacenter = [string]::Empty
            }

            It 'Should throw when Datacenter Path consists of two Folders and the Datacenter name and the Datacenter does not exist' {
                # Act && Assert
                { $datacenterInventoryBaseDSC.GetDatacenterFromPath() } | Should -Throw "Datacenter with name $($script:constants.datacenterName) was not found."
            }

            It 'Should call the Get-View mock with the passed Server and vCenter Root Folder once' {
                try {
                    # Act
                    $datacenterInventoryBaseDSC.GetDatacenterFromPath()
                }
                catch {
                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Get-View'
                        ParameterFilter = { $Server -eq $script:vCenter -and $Id -eq $script:rootFolder }
                        ModuleName = $script:moduleName
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            It 'Should call the Get-View mock with the passed Server and MyDatacenterFolderOne once' {
                try {
                    # Act
                    $datacenterInventoryBaseDSC.GetDatacenterFromPath()
                }
                catch {
                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Get-View'
                        ParameterFilter = { $Server -eq $script:vCenter -and (($Id | ConvertTo-Json) -eq ($script:datacenterPathItemOne | ConvertTo-Json)) }
                        ModuleName = $script:moduleName
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            It 'Should call the Get-View mock with the passed Server and MyDatacenterFolderTwo once' {
                try {
                    # Act
                    $datacenterInventoryBaseDSC.GetDatacenterFromPath()
                }
                catch {
                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Get-View'
                        ParameterFilter = { $Server -eq $script:vCenter -and (($Id | ConvertTo-Json) -eq ($script:datacenterPathItemTwo | ConvertTo-Json)) }
                        ModuleName = $script:moduleName
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            It 'Should call the Get-Inventory mock with the passed Server and MyDatacenterFolderTwo once' {
                try {
                    # Act
                    $datacenterInventoryBaseDSC.GetDatacenterFromPath()
                }
                catch {
                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Get-Inventory'
                        ParameterFilter = { $Server -eq $script:vCenter -and $Id -eq $script:datacenterLocation }
                        ModuleName = $script:moduleName
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            It 'Should call the Get-Datacenter mock with the passed Server, Datacenter Name and MyDatacenterFolderTwo Location once' {
                try {
                    # Act
                    $datacenterInventoryBaseDSC.GetDatacenterFromPath()
                }
                catch {
                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Get-Datacenter'
                        ParameterFilter = { $Server -eq $script:vCenter -and $Name -eq $script:constants.DatacenterName -and $Location -eq $script:datacenterFolder }
                        ModuleName = $script:moduleName
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }
        }

        Context 'Datacenter Path consists of two Folders and the Datacenter name and the Datacenter exists' {
            BeforeAll {
                # Arrange
                $script:datacenterInventoryBaseDSCProperties.Datacenter = "$($script:constants.DatacenterPathItemOne)/$($script:constants.DatacenterPathItemTwo)/$($script:constants.DatacenterName)"

                $vCenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vCenterScriptBlock))
                $rootFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:rootFolderViewBaseObjectScriptBlock))
                $datacenterPathItemOneMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemOneScriptBlock))
                $datacenterPathItemTwoMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemTwoScriptBlock))
                $datacenterFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterFolderScriptBlock))
                $datacenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterWithPathItemTwoAsParentScriptBlock))

                Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $rootFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:rootFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $datacenterPathItemOneMock -ParameterFilter { $Server -eq $script:vCenter -and (($Id | ConvertTo-Json) -eq ($script:datacenterPathItemOne | ConvertTo-Json)) } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $datacenterPathItemTwoMock -ParameterFilter { $Server -eq $script:vCenter -and (($Id | ConvertTo-Json) -eq ($script:datacenterPathItemTwo | ConvertTo-Json)) } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $datacenterFolderMock -ModuleName $script:moduleName
                Mock -CommandName Get-Datacenter -MockWith $datacenterMock -ModuleName $script:moduleName

                $datacenterInventoryBaseDSC = New-Object -TypeName $script:datacenterInventoryBaseDSCClassName -Property $script:datacenterInventoryBaseDSCProperties
                $datacenterInventoryBaseDSC.ConnectVIServer()
            }

            AfterAll {
                $script:datacenterInventoryBaseDSCProperties.Datacenter = [string]::Empty
            }

            It 'Should not throw when Datacenter Path consists of two Folders and the Datacenter name and the Datacenter exists' {
                # Act && Assert
                { $datacenterInventoryBaseDSC.GetDatacenterFromPath() } | Should -Not -Throw
            }

            It 'Should call the Get-View mock with the passed Server and vCenter Root Folder once' {
                # Act
                $datacenterInventoryBaseDSC.GetDatacenterFromPath()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-View'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Id -eq $script:rootFolder }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-View mock with the passed Server and MyDatacenterFolderOne once' {
                # Act
                $datacenterInventoryBaseDSC.GetDatacenterFromPath()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-View'
                    ParameterFilter = { $Server -eq $script:vCenter -and (($Id | ConvertTo-Json) -eq ($script:datacenterPathItemOne | ConvertTo-Json)) }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-View mock with the passed Server and MyDatacenterFolderTwo once' {
                # Act
                $datacenterInventoryBaseDSC.GetDatacenterFromPath()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-View'
                    ParameterFilter = { $Server -eq $script:vCenter -and (($Id | ConvertTo-Json) -eq ($script:datacenterPathItemTwo | ConvertTo-Json)) }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-Inventory mock with the passed Server and MyDatacenterFolderTwo once' {
                # Act
                $datacenterInventoryBaseDSC.GetDatacenterFromPath()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-Inventory'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Id -eq $script:datacenterLocation }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-Datacenter mock with the passed Server, Datacenter Name and MyDatacenterFolderTwo Location once' {
                # Act
                $datacenterInventoryBaseDSC.GetDatacenterFromPath()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-Datacenter'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Name -eq $script:constants.DatacenterName -and $Location -eq $script:datacenterFolder }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }
    }

    Describe 'InventoryBaseDSC\GetDatacenterInventoryItemLocationFromPath' -Tag 'GetDatacenterInventoryItemLocationFromPath' {
        Context 'Empty Datacenter Inventory Path is passed' {
            BeforeAll {
                # Arrange
                $script:datacenterInventoryBaseDSCProperties.Datacenter = "$($script:constants.DatacenterPathItemOne)/$($script:constants.DatacenterPathItemTwo)/$($script:constants.DatacenterName)"
                $script:datacenterInventoryBaseDSCProperties.DatacenterInventoryPath = [string]::Empty

                $vCenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vCenterScriptBlock))
                $rootFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:rootFolderViewBaseObjectScriptBlock))
                $datacenterPathItemOneMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemOneScriptBlock))
                $datacenterPathItemTwoMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemTwoScriptBlock))
                $datacenterFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterFolderScriptBlock))
                $datacenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterWithPathItemTwoAsParentScriptBlock))
                $hostFolderViewBaseObjectMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:hostFolderOfDatacenterViewBaseObjectScriptBlock))
                $hostFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:hostFolderScriptBlock))

                Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $rootFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:rootFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $datacenterPathItemOneMock -ParameterFilter { $Server -eq $script:vCenter -and (($Id | ConvertTo-Json) -eq ($script:datacenterPathItemOne | ConvertTo-Json)) } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $datacenterPathItemTwoMock -ParameterFilter { $Server -eq $script:vCenter -and (($Id | ConvertTo-Json) -eq ($script:datacenterPathItemTwo | ConvertTo-Json)) } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $datacenterFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:datacenterLocation } -ModuleName $script:moduleName
                Mock -CommandName Get-Datacenter -MockWith $datacenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $hostFolderViewBaseObjectMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $hostFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder } -ModuleName $script:moduleName

                $datacenterInventoryBaseDSC = New-Object -TypeName $script:datacenterInventoryBaseDSCClassName -Property $script:datacenterInventoryBaseDSCProperties
                $datacenterInventoryBaseDSC.DatacenterFolderType = $script:constants.DatacenterFolderType
                $datacenterInventoryBaseDSC.ConnectVIServer()
                $foundDatacenter = $datacenterInventoryBaseDSC.GetDatacenterFromPath()
            }

            AfterAll {
                $script:datacenterInventoryBaseDSCProperties.Datacenter = [string]::Empty
                $script:datacenterInventoryBaseDSCProperties.DatacenterInventoryPath = [string]::Empty
            }

            It 'Should not throw when Empty Datacenter Inventory Path is passed' {
                # Act && Assert
                { $datacenterInventoryBaseDSC.GetDatacenterInventoryItemLocationFromPath($foundDatacenter) } | Should -Not -Throw
            }

            It 'Should call the Get-View mock with the passed Server and HostFolder of the Datacenter once' {
                # Act
                $datacenterInventoryBaseDSC.GetDatacenterInventoryItemLocationFromPath($foundDatacenter)

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-View'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-Inventory mock with the passed Server and HostFolder of the Datacenter once' {
                # Act
                $datacenterInventoryBaseDSC.GetDatacenterInventoryItemLocationFromPath($foundDatacenter)

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-Inventory'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Datacenter Inventory Path consists only of one Folder and the path is not valid' {
            BeforeAll {
                # Arrange
                $script:datacenterInventoryBaseDSCProperties.Datacenter = "$($script:constants.DatacenterPathItemOne)/$($script:constants.DatacenterPathItemTwo)/$($script:constants.DatacenterName)"
                $script:datacenterInventoryBaseDSCProperties.DatacenterInventoryPath = "$($script:constants.DatacenterInventoryPathItemOne)"

                $vCenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vCenterScriptBlock))
                $rootFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:rootFolderViewBaseObjectScriptBlock))
                $datacenterPathItemOneMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemOneScriptBlock))
                $datacenterPathItemTwoMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemTwoScriptBlock))
                $datacenterFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterFolderScriptBlock))
                $datacenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterWithPathItemTwoAsParentScriptBlock))
                $hostFolderViewBaseObjectMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:hostFolderOfDatacenterViewBaseObjectScriptBlock))
                $hostFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:hostFolderScriptBlock))

                Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $rootFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:rootFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $datacenterPathItemOneMock -ParameterFilter { $Server -eq $script:vCenter -and (($Id | ConvertTo-Json) -eq ($script:datacenterPathItemOne | ConvertTo-Json)) } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $datacenterPathItemTwoMock -ParameterFilter { $Server -eq $script:vCenter -and (($Id | ConvertTo-Json) -eq ($script:datacenterPathItemTwo | ConvertTo-Json)) } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $datacenterFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:datacenterLocation } -ModuleName $script:moduleName
                Mock -CommandName Get-Datacenter -MockWith $datacenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $hostFolderViewBaseObjectMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $hostFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith { return $null } -ModuleName $script:moduleName

                $datacenterInventoryBaseDSC = New-Object -TypeName $script:datacenterInventoryBaseDSCClassName -Property $script:datacenterInventoryBaseDSCProperties
                $datacenterInventoryBaseDSC.DatacenterFolderType = $script:constants.DatacenterFolderType
                $datacenterInventoryBaseDSC.ConnectVIServer()
                $foundDatacenter = $datacenterInventoryBaseDSC.GetDatacenterFromPath()
            }

            AfterAll {
                $script:datacenterInventoryBaseDSCProperties.Datacenter = [string]::Empty
                $script:datacenterInventoryBaseDSCProperties.DatacenterInventoryPath = [string]::Empty
            }

            It 'Should throw when Datacenter Inventory Path consists only of one Folder and the path is not valid' {
                # Act && Assert
                { $datacenterInventoryBaseDSC.GetDatacenterInventoryItemLocationFromPath($foundDatacenter) } | Should -Throw "The provided path $($script:datacenterInventoryBaseDSCProperties.DatacenterInventoryPath) is not a valid path in the Folder $($script:constants.HostFolderName)."
            }

            It 'Should call the Get-View mock with the passed Server and HostFolder of the Datacenter once' {
                try {
                    # Act
                    $datacenterInventoryBaseDSC.GetDatacenterInventoryItemLocationFromPath($foundDatacenter)
                }
                catch {
                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Get-View'
                        ParameterFilter = { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder }
                        ModuleName = $script:moduleName
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            It 'Should call the Get-Inventory mock with the passed Server and HostFolder of the Datacenter once' {
                try {
                    # Act
                    $datacenterInventoryBaseDSC.GetDatacenterInventoryItemLocationFromPath($foundDatacenter)
                }
                catch {
                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Get-Inventory'
                        ParameterFilter = { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder }
                        ModuleName = $script:moduleName
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            It 'Should call the Get-Inventory mock with the passed Server, MyInventoryItemFolderOne and HostFolder Location once' {
                try {
                    # Act
                    $datacenterInventoryBaseDSC.GetDatacenterInventoryItemLocationFromPath($foundDatacenter)
                }
                catch {
                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Get-Inventory'
                        ParameterFilter = { $Server -eq $script:vCenter -and $Name -eq $script:datacenterInventoryBaseDSCProperties.DatacenterInventoryPath -and $Location -eq $script:hostFolderLocation }
                        ModuleName = $script:moduleName
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }
        }

        Context 'Datacenter Inventory Path consists only of one Folder and the path is valid' {
            BeforeAll {
                # Arrange
                $script:datacenterInventoryBaseDSCProperties.Datacenter = "$($script:constants.DatacenterPathItemOne)/$($script:constants.DatacenterPathItemTwo)/$($script:constants.DatacenterName)"
                $script:datacenterInventoryBaseDSCProperties.DatacenterInventoryPath = "$($script:constants.DatacenterInventoryPathItemOne)"

                $vCenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vCenterScriptBlock))
                $rootFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:rootFolderViewBaseObjectScriptBlock))
                $datacenterPathItemOneMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemOneScriptBlock))
                $datacenterPathItemTwoMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemTwoScriptBlock))
                $datacenterFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterFolderScriptBlock))
                $datacenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterWithPathItemTwoAsParentScriptBlock))
                $hostFolderViewBaseObjectMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:hostFolderOfDatacenterViewBaseObjectScriptBlock))
                $hostFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:hostFolderScriptBlock))
                $inventoryItemPathItemOneLocationMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:inventoryItemPathItemOneLocationScriptBlock))

                Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $rootFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:rootFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $datacenterPathItemOneMock -ParameterFilter { $Server -eq $script:vCenter -and (($Id | ConvertTo-Json) -eq ($script:datacenterPathItemOne | ConvertTo-Json)) } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $datacenterPathItemTwoMock -ParameterFilter { $Server -eq $script:vCenter -and (($Id | ConvertTo-Json) -eq ($script:datacenterPathItemTwo | ConvertTo-Json)) } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $datacenterFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:datacenterLocation } -ModuleName $script:moduleName
                Mock -CommandName Get-Datacenter -MockWith $datacenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $hostFolderViewBaseObjectMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $hostFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $inventoryItemPathItemOneLocationMock -ModuleName $script:moduleName

                $datacenterInventoryBaseDSC = New-Object -TypeName $script:datacenterInventoryBaseDSCClassName -Property $script:datacenterInventoryBaseDSCProperties
                $datacenterInventoryBaseDSC.DatacenterFolderType = $script:constants.DatacenterFolderType
                $datacenterInventoryBaseDSC.ConnectVIServer()
                $foundDatacenter = $datacenterInventoryBaseDSC.GetDatacenterFromPath()
            }

            AfterAll {
                $script:datacenterInventoryBaseDSCProperties.Datacenter = [string]::Empty
                $script:datacenterInventoryBaseDSCProperties.DatacenterInventoryPath = [string]::Empty
            }

            It 'Should not throw when Datacenter Inventory Path consists only of one Folder and the path is valid' {
                # Act && Assert
                { $datacenterInventoryBaseDSC.GetDatacenterInventoryItemLocationFromPath($foundDatacenter) } | Should -Not -Throw
            }

            It 'Should call the Get-View mock with the passed Server and HostFolder of the Datacenter once' {
                # Act
                $datacenterInventoryBaseDSC.GetDatacenterInventoryItemLocationFromPath($foundDatacenter)

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-View'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-Inventory mock with the passed Server and HostFolder of the Datacenter once' {
                # Act
                $datacenterInventoryBaseDSC.GetDatacenterInventoryItemLocationFromPath($foundDatacenter)

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-Inventory'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-Inventory mock with the passed Server, MyInventoryItemFolderOne and HostFolder Location once' {
                # Act
                $datacenterInventoryBaseDSC.GetDatacenterInventoryItemLocationFromPath($foundDatacenter)

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-Inventory'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Name -eq $script:datacenterInventoryBaseDSCProperties.DatacenterInventoryPath -and $Location -eq $script:hostFolderLocation }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Datacenter Inventory Path consists of two Folders and the path is not valid' {
            BeforeAll {
                # Arrange
                $script:datacenterInventoryBaseDSCProperties.Datacenter = "$($script:constants.DatacenterPathItemOne)/$($script:constants.DatacenterPathItemTwo)/$($script:constants.DatacenterName)"
                $script:datacenterInventoryBaseDSCProperties.DatacenterInventoryPath = "$($script:constants.DatacenterInventoryPathItemOne)/$($script:constants.DatacenterInventoryPathItemTwo)"

                $vCenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vCenterScriptBlock))
                $rootFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:rootFolderViewBaseObjectScriptBlock))
                $datacenterPathItemOneMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemOneScriptBlock))
                $datacenterPathItemTwoMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemTwoScriptBlock))
                $datacenterFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterFolderScriptBlock))
                $datacenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterWithPathItemTwoAsParentScriptBlock))
                $hostFolderViewBaseObjectMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:hostFolderOfDatacenterViewBaseObjectScriptBlock))
                $hostFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:hostFolderScriptBlock))
                $locationsMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationsScriptBlock))
                $locationViewBaseObjectMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationViewBaseObjectScriptBlock))
                $locationInvalidParentMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationInvalidParentScriptBlock))

                Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $rootFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:rootFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $datacenterPathItemOneMock -ParameterFilter { $Server -eq $script:vCenter -and (($Id | ConvertTo-Json) -eq ($script:datacenterPathItemOne | ConvertTo-Json)) } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $datacenterPathItemTwoMock -ParameterFilter { $Server -eq $script:vCenter -and (($Id | ConvertTo-Json) -eq ($script:datacenterPathItemTwo | ConvertTo-Json)) } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $datacenterFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:datacenterLocation } -ModuleName $script:moduleName
                Mock -CommandName Get-Datacenter -MockWith $datacenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $hostFolderViewBaseObjectMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $hostFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $locationsMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $locationViewBaseObjectMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:constants.DatacenterInventoryPathItemTwoId } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $locationInvalidParentMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:locationParent } -ModuleName $script:moduleName

                $datacenterInventoryBaseDSC = New-Object -TypeName $script:datacenterInventoryBaseDSCClassName -Property $script:datacenterInventoryBaseDSCProperties
                $datacenterInventoryBaseDSC.DatacenterFolderType = $script:constants.DatacenterFolderType
                $datacenterInventoryBaseDSC.ConnectVIServer()
                $foundDatacenter = $datacenterInventoryBaseDSC.GetDatacenterFromPath()
            }

            AfterAll {
                $script:datacenterInventoryBaseDSCProperties.Datacenter = [string]::Empty
                $script:datacenterInventoryBaseDSCProperties.DatacenterInventoryPath = [string]::Empty
            }

            It 'Should return $null when Datacenter Inventory Path consists of two Folders and the path is not valid' {
                # Act
                $result = $datacenterInventoryBaseDSC.GetDatacenterInventoryItemLocationFromPath($foundDatacenter)

                # Assert
                $result | Should -Be $null
            }

            It 'Should call the Get-View mock with the passed Server and HostFolder of the Datacenter once' {
                # Act
                $datacenterInventoryBaseDSC.GetDatacenterInventoryItemLocationFromPath($foundDatacenter)

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-View'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-Inventory mock with the passed Server and HostFolder of the Datacenter once' {
                # Act
                $datacenterInventoryBaseDSC.GetDatacenterInventoryItemLocationFromPath($foundDatacenter)

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-Inventory'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-Inventory mock with the passed Server, MyInventoryItemFolderTwo and HostFolder Location once' {
                # Act
                $datacenterInventoryBaseDSC.GetDatacenterInventoryItemLocationFromPath($foundDatacenter)

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-Inventory'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Name -eq $script:constants.DatacenterInventoryPathItemTwo -and $Location -eq $script:hostFolderLocation }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-View mock with the passed Server and MyInventoryItemFolderTwo once' {
                # Act
                $datacenterInventoryBaseDSC.GetDatacenterInventoryItemLocationFromPath($foundDatacenter)

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-View'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Id -eq $script:constants.DatacenterInventoryPathItemTwoId }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-View mock with the passed Server and MyInventoryItemFolderOne once' {
                # Act
                $datacenterInventoryBaseDSC.GetDatacenterInventoryItemLocationFromPath($foundDatacenter)

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-View'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Id -eq $script:locationParent }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Datacenter Inventory Path consists of two Folders and the path is valid' {
            BeforeAll {
                # Arrange
                $script:datacenterInventoryBaseDSCProperties.Datacenter = "$($script:constants.DatacenterPathItemOne)/$($script:constants.DatacenterPathItemTwo)/$($script:constants.DatacenterName)"
                $script:datacenterInventoryBaseDSCProperties.DatacenterInventoryPath = "$($script:constants.DatacenterInventoryPathItemOne)/$($script:constants.DatacenterInventoryPathItemTwo)"

                $vCenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vCenterScriptBlock))
                $rootFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:rootFolderViewBaseObjectScriptBlock))
                $datacenterPathItemOneMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemOneScriptBlock))
                $datacenterPathItemTwoMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemTwoScriptBlock))
                $datacenterFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterFolderScriptBlock))
                $datacenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterWithPathItemTwoAsParentScriptBlock))
                $hostFolderViewBaseObjectMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:hostFolderOfDatacenterViewBaseObjectScriptBlock))
                $hostFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:hostFolderScriptBlock))
                $locationsMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationsScriptBlock))
                $locationViewBaseObjectMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationViewBaseObjectScriptBlock))
                $locationParentMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationParentScriptBlock))

                Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $rootFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:rootFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $datacenterPathItemOneMock -ParameterFilter { $Server -eq $script:vCenter -and (($Id | ConvertTo-Json) -eq ($script:datacenterPathItemOne | ConvertTo-Json)) } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $datacenterPathItemTwoMock -ParameterFilter { $Server -eq $script:vCenter -and (($Id | ConvertTo-Json) -eq ($script:datacenterPathItemTwo | ConvertTo-Json)) } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $datacenterFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:datacenterLocation } -ModuleName $script:moduleName
                Mock -CommandName Get-Datacenter -MockWith $datacenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $hostFolderViewBaseObjectMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $hostFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $locationsMock -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:constants.DatacenterInventoryPathItemTwo -and $Location -eq $script:hostFolderLocation } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $locationViewBaseObjectMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:constants.DatacenterInventoryPathItemTwoId } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $locationParentMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:locationParent } -ModuleName $script:moduleName

                $datacenterInventoryBaseDSC = New-Object -TypeName $script:datacenterInventoryBaseDSCClassName -Property $script:datacenterInventoryBaseDSCProperties
                $datacenterInventoryBaseDSC.DatacenterFolderType = $script:constants.DatacenterFolderType
                $datacenterInventoryBaseDSC.ConnectVIServer()
                $foundDatacenter = $datacenterInventoryBaseDSC.GetDatacenterFromPath()
            }

            AfterAll {
                $script:datacenterInventoryBaseDSCProperties.Datacenter = [string]::Empty
                $script:datacenterInventoryBaseDSCProperties.DatacenterInventoryPath = [string]::Empty
            }

            It 'Should return the correct Location when Datacenter Inventory Path consists of two Folders and the path is valid' {
                # Act
                $result = $datacenterInventoryBaseDSC.GetDatacenterInventoryItemLocationFromPath($foundDatacenter)

                # Assert
                $result | Should -Be $script:validLocation
            }

            It 'Should call the Get-View mock with the passed Server and HostFolder of the Datacenter once' {
                # Act
                $datacenterInventoryBaseDSC.GetDatacenterInventoryItemLocationFromPath($foundDatacenter)

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-View'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-Inventory mock with the passed Server and HostFolder of the Datacenter once' {
                # Act
                $datacenterInventoryBaseDSC.GetDatacenterInventoryItemLocationFromPath($foundDatacenter)

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-Inventory'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-Inventory mock with the passed Server, MyInventoryItemFolderTwo and HostFolder Location once' {
                # Act
                $datacenterInventoryBaseDSC.GetDatacenterInventoryItemLocationFromPath($foundDatacenter)

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-Inventory'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Name -eq $script:constants.DatacenterInventoryPathItemTwo -and $Location -eq $script:hostFolderLocation }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-View mock with the passed Server and MyInventoryItemFolderTwo once' {
                # Act
                $datacenterInventoryBaseDSC.GetDatacenterInventoryItemLocationFromPath($foundDatacenter)

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-View'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Id -eq $script:constants.DatacenterInventoryPathItemTwoId }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-View mock with the passed Server and MyInventoryItemFolderOne once' {
                # Act
                $datacenterInventoryBaseDSC.GetDatacenterInventoryItemLocationFromPath($foundDatacenter)

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-View'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Id -eq $script:locationParent }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }
    }

    Describe 'InventoryBaseDSC\GetInventoryItem' -Tag 'GetInventoryItem' {
        Context 'Datacenter Inventory Path consists of two Folders and the path is not valid' {
            BeforeAll {
                # Arrange
                $script:datacenterInventoryBaseDSCProperties.Datacenter = "$($script:constants.DatacenterPathItemOne)/$($script:constants.DatacenterPathItemTwo)/$($script:constants.DatacenterName)"
                $script:datacenterInventoryBaseDSCProperties.DatacenterInventoryPath = "$($script:constants.DatacenterInventoryPathItemOne)/$($script:constants.DatacenterInventoryPathItemTwo)"

                $vCenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vCenterScriptBlock))
                $rootFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:rootFolderViewBaseObjectScriptBlock))
                $datacenterPathItemOneMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemOneScriptBlock))
                $datacenterPathItemTwoMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemTwoScriptBlock))
                $datacenterFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterFolderScriptBlock))
                $datacenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterWithPathItemTwoAsParentScriptBlock))
                $hostFolderViewBaseObjectMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:hostFolderOfDatacenterViewBaseObjectScriptBlock))
                $hostFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:hostFolderScriptBlock))
                $locationsMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationsScriptBlock))
                $locationViewBaseObjectMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationViewBaseObjectScriptBlock))
                $locationInvalidParentMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationInvalidParentScriptBlock))

                Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $rootFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:rootFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $datacenterPathItemOneMock -ParameterFilter { $Server -eq $script:vCenter -and (($Id | ConvertTo-Json) -eq ($script:datacenterPathItemOne | ConvertTo-Json)) } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $datacenterPathItemTwoMock -ParameterFilter { $Server -eq $script:vCenter -and (($Id | ConvertTo-Json) -eq ($script:datacenterPathItemTwo | ConvertTo-Json)) } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $datacenterFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:datacenterLocation } -ModuleName $script:moduleName
                Mock -CommandName Get-Datacenter -MockWith $datacenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $hostFolderViewBaseObjectMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $hostFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $locationsMock -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:constants.DatacenterInventoryPathItemTwo -and $Location -eq $script:hostFolderLocation } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $locationViewBaseObjectMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:constants.DatacenterInventoryPathItemTwoId } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $locationInvalidParentMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:locationParent } -ModuleName $script:moduleName

                $datacenterInventoryBaseDSC = New-Object -TypeName $script:datacenterInventoryBaseDSCClassName -Property $script:datacenterInventoryBaseDSCProperties
                $datacenterInventoryBaseDSC.DatacenterFolderType = $script:constants.DatacenterFolderType
                $datacenterInventoryBaseDSC.ConnectVIServer()
                $foundDatacenter = $datacenterInventoryBaseDSC.GetDatacenterFromPath()
                $inventoryItemLocation = $datacenterInventoryBaseDSC.GetDatacenterInventoryItemLocationFromPath($foundDatacenter)
            }

            AfterAll {
                $script:datacenterInventoryBaseDSCProperties.Datacenter = [string]::Empty
                $script:datacenterInventoryBaseDSCProperties.DatacenterInventoryPath = [string]::Empty
            }

            It 'Should throw when Datacenter Inventory Path consists of two Folders and the path is not valid' {
                # Act && Assert
                { $datacenterInventoryBaseDSC.GetInventoryItem($foundDatacenter, $inventoryItemLocation) } | Should -Throw "The provided path $($script:datacenterInventoryBaseDSCProperties.DatacenterInventoryPath) is not a valid path in the Datacenter $($script:constants.DatacenterName)."
            }
        }

        Context 'Datacenter Inventory Path consists of two Folders and the path is valid' {
            BeforeAll {
                # Arrange
                $script:datacenterInventoryBaseDSCProperties.Datacenter = "$($script:constants.DatacenterPathItemOne)/$($script:constants.DatacenterPathItemTwo)/$($script:constants.DatacenterName)"
                $script:datacenterInventoryBaseDSCProperties.DatacenterInventoryPath = "$($script:constants.DatacenterInventoryPathItemOne)/$($script:constants.DatacenterInventoryPathItemTwo)"

                $vCenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vCenterScriptBlock))
                $rootFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:rootFolderViewBaseObjectScriptBlock))
                $datacenterPathItemOneMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemOneScriptBlock))
                $datacenterPathItemTwoMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemTwoScriptBlock))
                $datacenterFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterFolderScriptBlock))
                $datacenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterWithPathItemTwoAsParentScriptBlock))
                $hostFolderViewBaseObjectMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:hostFolderOfDatacenterViewBaseObjectScriptBlock))
                $hostFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:hostFolderScriptBlock))
                $locationsMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationsScriptBlock))
                $locationViewBaseObjectMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationViewBaseObjectScriptBlock))
                $locationParentMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationParentScriptBlock))

                Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $rootFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:rootFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $datacenterPathItemOneMock -ParameterFilter { $Server -eq $script:vCenter -and (($Id | ConvertTo-Json) -eq ($script:datacenterPathItemOne | ConvertTo-Json)) } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $datacenterPathItemTwoMock -ParameterFilter { $Server -eq $script:vCenter -and (($Id | ConvertTo-Json) -eq ($script:datacenterPathItemTwo | ConvertTo-Json)) } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $datacenterFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:datacenterLocation } -ModuleName $script:moduleName
                Mock -CommandName Get-Datacenter -MockWith $datacenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $hostFolderViewBaseObjectMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $hostFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $locationsMock -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:constants.DatacenterInventoryPathItemTwo -and $Location -eq $script:hostFolderLocation } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $locationViewBaseObjectMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:constants.DatacenterInventoryPathItemTwoId } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $locationParentMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:locationParent } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith { return $null } -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:datacenterInventoryBaseDSCProperties.Name -and $Location -eq $script:validLocation } -ModuleName $script:moduleName

                $datacenterInventoryBaseDSC = New-Object -TypeName $script:datacenterInventoryBaseDSCClassName -Property $script:datacenterInventoryBaseDSCProperties
                $datacenterInventoryBaseDSC.DatacenterFolderType = $script:constants.DatacenterFolderType
                $datacenterInventoryBaseDSC.ConnectVIServer()
                $foundDatacenter = $datacenterInventoryBaseDSC.GetDatacenterFromPath()
                $inventoryItemLocation = $datacenterInventoryBaseDSC.GetDatacenterInventoryItemLocationFromPath($foundDatacenter)
            }

            AfterAll {
                $script:datacenterInventoryBaseDSCProperties.Datacenter = [string]::Empty
                $script:datacenterInventoryBaseDSCProperties.DatacenterInventoryPath = [string]::Empty
            }

            It 'Should not throw when Datacenter Inventory Path consists of two Folders and the path is valid' {
                # Act && Assert
                { $datacenterInventoryBaseDSC.GetInventoryItem($foundDatacenter, $inventoryItemLocation) } | Should -Not -Throw
            }

            It 'Should call the Get-Inventory mock with the passed Server, InventoryItem Name and valid Location once' {
                # Act
                $datacenterInventoryBaseDSC.GetInventoryItem($foundDatacenter, $inventoryItemLocation)

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-Inventory'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Name -eq $script:datacenterInventoryBaseDSCProperties.Name -and $Location -eq $script:validLocation }
                    ModuleName = $script:moduleName
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
