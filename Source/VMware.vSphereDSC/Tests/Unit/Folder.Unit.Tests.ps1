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
    $script:resourceName = 'Folder'

    $script:user = 'user'
    $password = 'password' | ConvertTo-SecureString -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential($script:user, $password)

    $script:resourceProperties = @{
        Server = '10.23.80.58'
        Credential = $credential
        Name = 'MyDSCFolder'
        Ensure = 'Present'
        Datacenter = [string]::Empty
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
        DatacenterPathItemOne = 'MyDatacenterFolderOne'
        DatacenterPathItemTwoId = 'my-datacenter-folder-two'
        DatacenterPathItemTwo = 'MyDatacenterFolderTwo'
        DatacenterId = 'MyDatacenter-datacenter-1'
        DatacenterName = 'MyDatacenter'
        VmFolderId = 'group-h3'
        VmFolderName = 'VmFolder'
        DatacenterInventoryPathItemOneId = 'my-inventory-item-location-one'
        DatacenterInventoryPathItemOne = 'MyInventoryItemFolderOne'
        DatacenterInventoryPathItemTwoId = 'my-inventory-item-location-two'
        DatacenterInventoryPathItemTwo = 'MyInventoryItemFolderTwo'
    }

    $script:viServerScriptBlock = @'
        return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{
            Name = '$($script:resourceProperties.Server)'
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

    $script:inventoryRootFolderScriptBlock = @'
        return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
            Id = '$($script:constants.DatacentersFolderId)'
            Name = '$($script:constants.DatacentersFolderName)'
            ExtensionData = [VMware.Vim.Folder] @{
                ChildEntity = @(
                    [VMware.Vim.ManagedObjectReference] @{
                        Type = '$($script:constants.FolderType)'
                        Value = '$($script:constants.DatacenterPathItemOne)'
                    }
                )
            }
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
                VmFolder = [VMware.Vim.ManagedObjectReference] @{
                    Type = '$($script:constants.FolderType)'
                    Value = '$($script:constants.VmFolderId)'
                }
            }
        }
'@

    $script:vmFolderOfDatacenterViewBaseObjectScriptBlock = @'
        return [VMware.Vim.Folder] @{
            Name = '$($script:constants.VmFolderName)'
            MoRef = [VMware.Vim.ManagedObjectReference] @{
                Type = '$($script:constants.FolderType)'
                Value = '$($script:constants.VmFolderId)'
            }
        }
'@

    $script:vmFolderScriptBlock = @'
        return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
            Id = '$($script:constants.VmFolderId)'
            Name = '$($script:constants.VmFolderName)'
            Parent = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.DatacenterImpl] @{
                Name = '$($script:constants.DatacenterName)'
            }
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

    $script:locationInDatacenterParentScriptBlock = @'
        return [VMware.Vim.Folder] @{
            Name = '$($script:constants.DatacenterInventoryPathItemOne)'
            Parent = [VMware.Vim.ManagedObjectReference] @{
                Type = '$($script:constants.FolderType)'
                Value = '$($script:constants.DatacenterInventoryPathItemOneId)'
            }
        }
'@

    $script:folderScriptBlock = @'
        return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
            Name = '$($script:resourceProperties.Name)'
            ParentId = '$($script:constants.FolderId)'
        }
'@

    $script:folderInDatacenterScriptBlock = @'
        return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
            Name = '$($script:resourceProperties.Name)'
            ParentId = '$($script:constants.DatacenterInventoryPathItemTwoId)'
        }
'@

    $env:PSModulePath = $script:mockModuleLocation
    $vimAutomationModule = Get-Module -Name VMware.VimAutomation.Core
    if ($null -ne $vimAutomationModule -and $vimAutomationModule.Path -NotMatch 'TestHelpers') {
        throw 'The Original VMware.VimAutomation.Core Module is loaded in the current session. If you want to run the unit tests please open a new PowerShell session.'
    }

    Import-Module -Name VMware.VimAutomation.Core

    $script:viServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{
        Name = $script:resourceProperties.Server
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

    $script:folderLocation = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
        Id = $script:constants.FolderId
        Name = $script:constants.FolderName
        ParentId = $script:constants.PathItemTwoId
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

    $script:vmFolder = [VMware.Vim.ManagedObjectReference] @{
        Type = $script:constants.FolderType
        Value = $script:constants.VmFolderId
    }

    $script:vmFolderLocation = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
        Id = $script:constants.VmFolderId
        Name = $script:constants.VmFolderName
        Parent = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.DatacenterImpl] @{
            Name = $script:constants.DatacenterName
        }
    }

    $script:locationInDatacenterParent = [VMware.Vim.ManagedObjectReference] @{
        Type = $script:constants.FolderType
        Value = $script:constants.DatacenterInventoryPathItemOneId
    }

    $script:locationOfFolderInDatacenter = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
        Id = $script:constants.DatacenterInventoryPathItemTwoId
    }

    $script:folder = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
        Name = $script:resourceProperties.Name
        ParentId = $script:constants.FolderId
    }

    $script:folderInDatacenter = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
        Name = $script:resourceProperties.Name
        ParentId = $script:constants.DatacenterInventoryPathItemTwoId
    }
}

function Invoke-TestCleanup {
    Remove-Module -Name VMware.VimAutomation.Core
    $env:PSModulePath = $script:modulePath
}

function New-MocksWhenFolderTypeIsDatacenter() {
    $datacentersFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacentersFolderScriptBlock))
    $pathItemOneMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:pathItemOneScriptBlock))
    $pathItemTwoMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:pathItemTwoScriptBlock))
    $locationParentMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationParentScriptBlock))
    $locationMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:folderWithPathItemTwoAsParentScriptBlock))

    Mock -CommandName Get-Inventory -MockWith $datacentersFolderMock -ModuleName $script:moduleName
    Mock -CommandName Get-View -MockWith $pathItemOneMock -ParameterFilter { $Server -eq $script:viServer -and (($Id | ConvertTo-Json) -eq ($script:pathItemOne | ConvertTo-Json)) } -ModuleName $script:inventoryHelperModuleName
    Mock -CommandName Get-View -MockWith $pathItemTwoMock -ParameterFilter { $Server -eq $script:viServer -and (($Id | ConvertTo-Json) -eq ($script:pathItemTwo | ConvertTo-Json)) } -ModuleName $script:inventoryHelperModuleName
    Mock -CommandName Get-Inventory -MockWith $locationParentMock -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:locationParent } -ModuleName $script:inventoryHelperModuleName
    Mock -CommandName Get-Folder -MockWith $locationMock -ModuleName $script:inventoryHelperModuleName
}

function New-MocksWhenFolderTypeIsNotDatacenter() {
    $inventoryRootFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:inventoryRootFolderScriptBlock))
    $datacenterPathItemOneMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemOneScriptBlock))
    $datacenterPathItemTwoMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemTwoScriptBlock))
    $datacenterFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterFolderScriptBlock))
    $datacenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterWithPathItemTwoAsParentScriptBlock))
    $vmFolderViewBaseObjectMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vmFolderOfDatacenterViewBaseObjectScriptBlock))
    $vmFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vmFolderScriptBlock))
    $locationsMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationsScriptBlock))
    $locationViewBaseObjectMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationViewBaseObjectScriptBlock))
    $locationParentMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationInDatacenterParentScriptBlock))

    Mock -CommandName Get-Inventory -MockWith $inventoryRootFolderMock -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:rootFolder } -ModuleName $script:moduleName
    Mock -CommandName Get-View -MockWith $datacenterPathItemOneMock -ParameterFilter { $Server -eq $script:viServer -and (($Id | ConvertTo-Json) -eq ($script:datacenterPathItemOne | ConvertTo-Json)) } -ModuleName $script:inventoryHelperModuleName
    Mock -CommandName Get-View -MockWith $datacenterPathItemTwoMock -ParameterFilter { $Server -eq $script:viServer -and (($Id | ConvertTo-Json) -eq ($script:datacenterPathItemTwo | ConvertTo-Json)) } -ModuleName $script:inventoryHelperModuleName
    Mock -CommandName Get-Inventory -MockWith $datacenterFolderMock -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:datacenterLocation } -ModuleName $script:inventoryHelperModuleName
    Mock -CommandName Get-Datacenter -MockWith $datacenterMock -ModuleName $script:inventoryHelperModuleName
    Mock -CommandName Get-View -MockWith $vmFolderViewBaseObjectMock -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:vmFolder } -ModuleName $script:moduleName
    Mock -CommandName Get-Inventory -MockWith $vmFolderMock -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:vmFolder } -ModuleName $script:moduleName
    Mock -CommandName Get-Inventory -MockWith $locationsMock -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatacenterInventoryPathItemTwo -and $Location -eq $script:vmFolderLocation } -ModuleName $script:inventoryHelperModuleName
    Mock -CommandName Get-View -MockWith $locationViewBaseObjectMock -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:constants.DatacenterInventoryPathItemTwoId } -ModuleName $script:inventoryHelperModuleName
    Mock -CommandName Get-View -MockWith $locationParentMock -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:locationInDatacenterParent } -ModuleName $script:inventoryHelperModuleName
}

try {
    # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
    Invoke-TestSetup

    Describe 'Folder\GetFolder' -Tag 'GetFolder' {
        BeforeAll {
            # Arrange
            $viServerMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:viServerScriptBlock))
            $rootFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:rootFolderViewBaseObjectScriptBlock))

            Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $rootFolderMock -ModuleName $script:moduleName
        }

        Context 'Invoking with Ensure Present, Datacenter Folder Type and non existing Folder' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Path = "$($script:constants.PathItemOne)/$($script:constants.PathItemTwo)/$($script:constants.FolderName)"
                $script:resourceProperties.FolderType = 'Datacenter'

                # Creates the needed Mocks when the Folder Type is Datacenter
                New-MocksWhenFolderTypeIsDatacenter

                Mock -CommandName Get-Folder -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
                $resource.ConnectVIServer()
                $folderLocation = $resource.GetFolderLocation()
            }

            AfterAll {
                $script:resourceProperties.Path = [string]::Empty
                $script:resourceProperties.FolderType = [string]::Empty
            }

            It 'Should call the Get-Folder mock with the passed Server, Folder name and MyFolder location once' {
                # Act
                $resource.GetFolder($folderLocation)

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-Folder'
                    ParameterFilter = { $Server -eq $script:viServer -and $Name -eq $script:resourceProperties.Name -and $Location -eq $script:folderLocation }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Invoking with Ensure Present, Folder Type different from Datacenter and non existing Folder' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Path = "$($script:constants.DatacenterInventoryPathItemOne)/$($script:constants.DatacenterInventoryPathItemTwo)"
                $script:resourceProperties.Datacenter = "$($script:constants.DatacenterPathItemOne)/$($script:constants.DatacenterPathItemTwo)/$($script:constants.DatacenterName)"
                $script:resourceProperties.FolderType = 'Vm'

                # Creates the needed Mocks when the Folder Type is not Datacenter
                New-MocksWhenFolderTypeIsNotDatacenter

                Mock -CommandName Get-Folder -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
                $resource.ConnectVIServer()
            }

            AfterAll {
                $script:resourceProperties.Path = [string]::Empty
                $script:resourceProperties.Datacenter = [string]::Empty
                $script:resourceProperties.FolderType = [string]::Empty
            }

            It 'Should call the Get-View mock with the passed Server and VmFolder of the Datacenter once' {
                # Act
                $folderLocation = $resource.GetFolderLocation()
                $resource.GetFolder($folderLocation)

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-View'
                    ParameterFilter = { $Server -eq $script:viServer -and $Id -eq $script:vmFolder }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-Inventory mock with the passed Server and VmFolder of the Datacenter once' {
                # Act
                $folderLocation = $resource.GetFolderLocation()
                $resource.GetFolder($folderLocation)

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-Inventory'
                    ParameterFilter = { $Server -eq $script:viServer -and $Id -eq $script:vmFolder }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-Folder mock with the passed Server, Folder name and MyInventoryItemFolderTwo location once' {
                # Act
                $folderLocation = $resource.GetFolderLocation()
                $resource.GetFolder($folderLocation)

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-Folder'
                    ParameterFilter = { $Server -eq $script:viServer -and $Name -eq $script:resourceProperties.Name -and $Location -eq $script:locationOfFolderInDatacenter }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Invoking with Ensure Present, Datacenter Folder Type and existing Folder' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Path = "$($script:constants.PathItemOne)/$($script:constants.PathItemTwo)/$($script:constants.FolderName)"
                $script:resourceProperties.FolderType = 'Datacenter'

                $folderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:folderScriptBlock))

                # Creates the needed Mocks when the Folder Type is Datacenter
                New-MocksWhenFolderTypeIsDatacenter

                Mock -CommandName Get-Folder -MockWith $folderMock -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
                $resource.ConnectVIServer()
                $folderLocation = $resource.GetFolderLocation()
            }

            AfterAll {
                $script:resourceProperties.Path = [string]::Empty
                $script:resourceProperties.FolderType = [string]::Empty
            }

            It 'Should call the Get-Folder mock with the passed Server, Folder name and MyFolder location once' {
                # Act
                $resource.GetFolder($folderLocation)

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-Folder'
                    ParameterFilter = { $Server -eq $script:viServer -and $Name -eq $script:resourceProperties.Name -and $Location -eq $script:folderLocation }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Invoking with Ensure Present, Folder Type different from Datacenter and existing Folder' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Path = "$($script:constants.DatacenterInventoryPathItemOne)/$($script:constants.DatacenterInventoryPathItemTwo)"
                $script:resourceProperties.Datacenter = "$($script:constants.DatacenterPathItemOne)/$($script:constants.DatacenterPathItemTwo)/$($script:constants.DatacenterName)"
                $script:resourceProperties.FolderType = 'Vm'

                $folderInDatacenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:folderInDatacenterScriptBlock))

                # Creates the needed Mocks when the Folder Type is not Datacenter
                New-MocksWhenFolderTypeIsNotDatacenter

                Mock -CommandName Get-Folder -MockWith $folderInDatacenterMock -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
                $resource.ConnectVIServer()
            }

            AfterAll {
                $script:resourceProperties.Path = [string]::Empty
                $script:resourceProperties.Datacenter = [string]::Empty
                $script:resourceProperties.FolderType = [string]::Empty
            }

            It 'Should call the Get-View mock with the passed Server and VmFolder of the Datacenter once' {
                # Act
                $folderLocation = $resource.GetFolderLocation()
                $resource.GetFolder($folderLocation)

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-View'
                    ParameterFilter = { $Server -eq $script:viServer -and $Id -eq $script:vmFolder }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-Inventory mock with the passed Server and VmFolder of the Datacenter once' {
                # Act
                $folderLocation = $resource.GetFolderLocation()
                $resource.GetFolder($folderLocation)

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-Inventory'
                    ParameterFilter = { $Server -eq $script:viServer -and $Id -eq $script:vmFolder }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-Folder mock with the passed Server, Folder name and MyInventoryItemFolderTwo location once' {
                # Act
                $folderLocation = $resource.GetFolderLocation()
                $resource.GetFolder($folderLocation)

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-Folder'
                    ParameterFilter = { $Server -eq $script:viServer -and $Name -eq $script:resourceProperties.Name -and $Location -eq $script:locationOfFolderInDatacenter }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Invoking with Ensure Absent, Datacenter Folder Type and non existing Folder' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Ensure = 'Absent'
                $script:resourceProperties.Path = "$($script:constants.PathItemOne)/$($script:constants.PathItemTwo)/$($script:constants.FolderName)"
                $script:resourceProperties.FolderType = 'Datacenter'

                # Creates the needed Mocks when the Folder Type is Datacenter
                New-MocksWhenFolderTypeIsDatacenter

                Mock -CommandName Get-Folder -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
                $resource.ConnectVIServer()
                $folderLocation = $resource.GetFolderLocation()
            }

            AfterAll {
                $script:resourceProperties.Ensure = 'Present'
                $script:resourceProperties.Path = [string]::Empty
                $script:resourceProperties.FolderType = [string]::Empty
            }

            It 'Should call the Get-Folder mock with the passed Server, Folder name and MyFolder location once' {
                # Act
                $resource.GetFolder($folderLocation)

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-Folder'
                    ParameterFilter = { $Server -eq $script:viServer -and $Name -eq $script:resourceProperties.Name -and $Location -eq $script:folderLocation }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Invoking with Ensure Absent, Folder Type different from Datacenter and non existing Folder' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Ensure = 'Absent'
                $script:resourceProperties.Path = "$($script:constants.DatacenterInventoryPathItemOne)/$($script:constants.DatacenterInventoryPathItemTwo)"
                $script:resourceProperties.Datacenter = "$($script:constants.DatacenterPathItemOne)/$($script:constants.DatacenterPathItemTwo)/$($script:constants.DatacenterName)"
                $script:resourceProperties.FolderType = 'Vm'

                # Creates the needed Mocks when the Folder Type is not Datacenter
                New-MocksWhenFolderTypeIsNotDatacenter

                Mock -CommandName Get-Folder -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
                $resource.ConnectVIServer()
            }

            AfterAll {
                $script:resourceProperties.Ensure = 'Present'
                $script:resourceProperties.Path = [string]::Empty
                $script:resourceProperties.Datacenter = [string]::Empty
                $script:resourceProperties.FolderType = [string]::Empty
            }

            It 'Should call the Get-View mock with the passed Server and VmFolder of the Datacenter once' {
                # Act
                $folderLocation = $resource.GetFolderLocation()
                $resource.GetFolder($folderLocation)

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-View'
                    ParameterFilter = { $Server -eq $script:viServer -and $Id -eq $script:vmFolder }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-Inventory mock with the passed Server and VmFolder of the Datacenter once' {
                # Act
                $folderLocation = $resource.GetFolderLocation()
                $resource.GetFolder($folderLocation)

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-Inventory'
                    ParameterFilter = { $Server -eq $script:viServer -and $Id -eq $script:vmFolder }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-Folder mock with the passed Server, Folder name and MyInventoryItemFolderTwo location once' {
                # Act
                $folderLocation = $resource.GetFolderLocation()
                $resource.GetFolder($folderLocation)

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-Folder'
                    ParameterFilter = { $Server -eq $script:viServer -and $Name -eq $script:resourceProperties.Name -and $Location -eq $script:locationOfFolderInDatacenter }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Invoking with Ensure Absent, Datacenter Folder Type and existing Folder' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Ensure = 'Absent'
                $script:resourceProperties.Path = "$($script:constants.PathItemOne)/$($script:constants.PathItemTwo)/$($script:constants.FolderName)"
                $script:resourceProperties.FolderType = 'Datacenter'

                $folderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:folderScriptBlock))

                # Creates the needed Mocks when the Folder Type is Datacenter
                New-MocksWhenFolderTypeIsDatacenter

                Mock -CommandName Get-Folder -MockWith $folderMock -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
                $resource.ConnectVIServer()
                $folderLocation = $resource.GetFolderLocation()
            }

            AfterAll {
                $script:resourceProperties.Ensure = 'Present'
                $script:resourceProperties.Path = [string]::Empty
                $script:resourceProperties.FolderType = [string]::Empty
            }

            It 'Should call the Get-Folder mock with the passed Server, Folder name and MyFolder location once' {
                # Act
                $resource.GetFolder($folderLocation)

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-Folder'
                    ParameterFilter = { $Server -eq $script:viServer -and $Name -eq $script:resourceProperties.Name -and $Location -eq $script:folderLocation }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Invoking with Ensure Absent, Folder Type different from Datacenter and existing Folder' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Ensure = 'Absent'
                $script:resourceProperties.Path = "$($script:constants.DatacenterInventoryPathItemOne)/$($script:constants.DatacenterInventoryPathItemTwo)"
                $script:resourceProperties.Datacenter = "$($script:constants.DatacenterPathItemOne)/$($script:constants.DatacenterPathItemTwo)/$($script:constants.DatacenterName)"
                $script:resourceProperties.FolderType = 'Vm'

                $folderInDatacenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:folderInDatacenterScriptBlock))

                # Creates the needed Mocks when the Folder Type is not Datacenter
                New-MocksWhenFolderTypeIsNotDatacenter

                Mock -CommandName Get-Folder -MockWith $folderInDatacenterMock -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
                $resource.ConnectVIServer()
            }

            AfterAll {
                $script:resourceProperties.Ensure = 'Present'
                $script:resourceProperties.Path = [string]::Empty
                $script:resourceProperties.Datacenter = [string]::Empty
                $script:resourceProperties.FolderType = [string]::Empty
            }

            It 'Should call the Get-View mock with the passed Server and VmFolder of the Datacenter once' {
                # Act
                $folderLocation = $resource.GetFolderLocation()
                $resource.GetFolder($folderLocation)

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-View'
                    ParameterFilter = { $Server -eq $script:viServer -and $Id -eq $script:vmFolder }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-Inventory mock with the passed Server and VmFolder of the Datacenter once' {
                # Act
                $folderLocation = $resource.GetFolderLocation()
                $resource.GetFolder($folderLocation)

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-Inventory'
                    ParameterFilter = { $Server -eq $script:viServer -and $Id -eq $script:vmFolder }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-Folder mock with the passed Server, Folder name and MyInventoryItemFolderTwo location once' {
                # Act
                $folderLocation = $resource.GetFolderLocation()
                $resource.GetFolder($folderLocation)

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-Folder'
                    ParameterFilter = { $Server -eq $script:viServer -and $Name -eq $script:resourceProperties.Name -and $Location -eq $script:locationOfFolderInDatacenter }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }
    }

    Describe 'Folder\Set' -Tag 'Set' {
        BeforeEach {
            # Arrange
            $viServerMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:viServerScriptBlock))
            $rootFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:rootFolderViewBaseObjectScriptBlock))

            Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $rootFolderMock -ModuleName $script:moduleName
        }

        Context 'Invoking with Ensure Present, Datacenter Folder Type and non existing Folder' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Path = "$($script:constants.PathItemOne)/$($script:constants.PathItemTwo)/$($script:constants.FolderName)"
                $script:resourceProperties.FolderType = 'Datacenter'

                # Creates the needed Mocks when the Folder Type is Datacenter
                New-MocksWhenFolderTypeIsDatacenter

                Mock -CommandName Get-Folder -MockWith { return $null } -ModuleName $script:moduleName
                Mock -CommandName New-Folder -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.Path = [string]::Empty
                $script:resourceProperties.FolderType = [string]::Empty
            }

            It 'Should call the New-Folder mock with the passed Server, Folder name and MyFolder location once' {
                # Act
                $resource.Set()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'New-Folder'
                    ParameterFilter = { $Server -eq $script:viServer -and $Name -eq $script:resourceProperties.Name -and $Location -eq $script:folderLocation }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Invoking with Ensure Present, Folder Type different from Datacenter and non existing Folder' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Path = "$($script:constants.DatacenterInventoryPathItemOne)/$($script:constants.DatacenterInventoryPathItemTwo)"
                $script:resourceProperties.Datacenter = "$($script:constants.DatacenterPathItemOne)/$($script:constants.DatacenterPathItemTwo)/$($script:constants.DatacenterName)"
                $script:resourceProperties.FolderType = 'Vm'

                # Creates the needed Mocks when the Folder Type is not Datacenter
                New-MocksWhenFolderTypeIsNotDatacenter

                Mock -CommandName Get-Folder -MockWith { return $null } -ModuleName $script:moduleName
                Mock -CommandName New-Folder -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.Path = [string]::Empty
                $script:resourceProperties.Datacenter = [string]::Empty
                $script:resourceProperties.FolderType = [string]::Empty
            }

            It 'Should call the New-Folder mock with the passed Server, Folder name and MyInventoryItemFolderTwo location once' {
                # Act
                $resource.Set()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'New-Folder'
                    ParameterFilter = { $Server -eq $script:viServer -and $Name -eq $script:resourceProperties.Name -and $Location -eq $script:locationOfFolderInDatacenter }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Invoking with Ensure Present, Datacenter Folder Type and existing Folder' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Path = "$($script:constants.PathItemOne)/$($script:constants.PathItemTwo)/$($script:constants.FolderName)"
                $script:resourceProperties.FolderType = 'Datacenter'

                $folderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:folderScriptBlock))

                # Creates the needed Mocks when the Folder Type is Datacenter
                New-MocksWhenFolderTypeIsDatacenter

                Mock -CommandName Get-Folder -MockWith $folderMock -ModuleName $script:moduleName
                Mock -CommandName New-Folder -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.Path = [string]::Empty
                $script:resourceProperties.FolderType = [string]::Empty
            }

            It 'Should not call the New-Folder mock with the passed Server, Folder name and MyFolder location' {
                # Act
                $resource.Set()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'New-Folder'
                    ParameterFilter = { $Server -eq $script:viServer -and $Name -eq $script:resourceProperties.Name -and $Location -eq $script:folderLocation }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 0
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Invoking with Ensure Present, Folder Type different from Datacenter and existing Folder' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Path = "$($script:constants.DatacenterInventoryPathItemOne)/$($script:constants.DatacenterInventoryPathItemTwo)"
                $script:resourceProperties.Datacenter = "$($script:constants.DatacenterPathItemOne)/$($script:constants.DatacenterPathItemTwo)/$($script:constants.DatacenterName)"
                $script:resourceProperties.FolderType = 'Vm'

                $folderInDatacenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:folderInDatacenterScriptBlock))

                # Creates the needed Mocks when the Folder Type is not Datacenter
                New-MocksWhenFolderTypeIsNotDatacenter

                Mock -CommandName Get-Folder -MockWith $folderInDatacenterMock -ModuleName $script:moduleName
                Mock -CommandName New-Folder -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.Path = [string]::Empty
                $script:resourceProperties.Datacenter = [string]::Empty
                $script:resourceProperties.FolderType = [string]::Empty
            }

            It 'Should not call the New-Folder mock with the passed Server, Folder name and MyInventoryItemFolderTwo location' {
                # Act
                $resource.Set()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'New-Folder'
                    ParameterFilter = { $Server -eq $script:viServer -and $Name -eq $script:resourceProperties.Name -and $Location -eq $script:locationOfFolderInDatacenter }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 0
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Invoking with Ensure Absent, Datacenter Folder Type and non existing Folder' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Ensure = 'Absent'
                $script:resourceProperties.Path = "$($script:constants.PathItemOne)/$($script:constants.PathItemTwo)/$($script:constants.FolderName)"
                $script:resourceProperties.FolderType = 'Datacenter'

                # Creates the needed Mocks when the Folder Type is Datacenter
                New-MocksWhenFolderTypeIsDatacenter

                Mock -CommandName Get-Folder -MockWith { return $null } -ModuleName $script:moduleName
                Mock -CommandName Remove-Folder -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.Ensure = 'Present'
                $script:resourceProperties.Path = [string]::Empty
                $script:resourceProperties.FolderType = [string]::Empty
            }

            It 'Should not call the Remove-Folder mock with the passed Server and MyDSCFolder' {
                # Act
                $resource.Set()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Remove-Folder'
                    ParameterFilter = { $Server -eq $script:viServer -and $Folder -eq $script:folder }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 0
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Invoking with Ensure Absent, Folder Type different from Datacenter and non existing Folder' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Ensure = 'Absent'
                $script:resourceProperties.Path = "$($script:constants.DatacenterInventoryPathItemOne)/$($script:constants.DatacenterInventoryPathItemTwo)"
                $script:resourceProperties.Datacenter = "$($script:constants.DatacenterPathItemOne)/$($script:constants.DatacenterPathItemTwo)/$($script:constants.DatacenterName)"
                $script:resourceProperties.FolderType = 'Vm'

                # Creates the needed Mocks when the Folder Type is not Datacenter
                New-MocksWhenFolderTypeIsNotDatacenter

                Mock -CommandName Get-Folder -MockWith { return $null } -ModuleName $script:moduleName
                Mock -CommandName Remove-Folder -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.Ensure = 'Present'
                $script:resourceProperties.Path = [string]::Empty
                $script:resourceProperties.Datacenter = [string]::Empty
                $script:resourceProperties.FolderType = [string]::Empty
            }

            It 'Should not call the Remove-Folder mock with the passed Server and MyDSCFolder' {
                # Act
                $resource.Set()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Remove-Folder'
                    ParameterFilter = { $Server -eq $script:viServer -and $Folder -eq $script:folderInDatacenter }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 0
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Invoking with Ensure Absent, Datacenter Folder Type and existing Folder' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Ensure = 'Absent'
                $script:resourceProperties.Path = "$($script:constants.PathItemOne)/$($script:constants.PathItemTwo)/$($script:constants.FolderName)"
                $script:resourceProperties.FolderType = 'Datacenter'

                $folderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:folderScriptBlock))

                # Creates the needed Mocks when the Folder Type is Datacenter
                New-MocksWhenFolderTypeIsDatacenter

                Mock -CommandName Get-Folder -MockWith $folderMock -ModuleName $script:moduleName
                Mock -CommandName Remove-Folder -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.Ensure = 'Present'
                $script:resourceProperties.Path = [string]::Empty
                $script:resourceProperties.FolderType = [string]::Empty
            }

            It 'Should call the Remove-Folder mock with the passed Server and MyDSCFolder once' {
                # Act
                $resource.Set()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Remove-Folder'
                    ParameterFilter = { $Server -eq $script:viServer -and $Folder -eq $script:folder }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Invoking with Ensure Absent, Folder Type different from Datacenter and existing Folder' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Ensure = 'Absent'
                $script:resourceProperties.Path = "$($script:constants.DatacenterInventoryPathItemOne)/$($script:constants.DatacenterInventoryPathItemTwo)"
                $script:resourceProperties.Datacenter = "$($script:constants.DatacenterPathItemOne)/$($script:constants.DatacenterPathItemTwo)/$($script:constants.DatacenterName)"
                $script:resourceProperties.FolderType = 'Vm'

                $folderInDatacenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:folderInDatacenterScriptBlock))

                # Creates the needed Mocks when the Folder Type is not Datacenter
                New-MocksWhenFolderTypeIsNotDatacenter

                Mock -CommandName Get-Folder -MockWith $folderInDatacenterMock -ModuleName $script:moduleName
                Mock -CommandName Remove-Folder -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.Ensure = 'Present'
                $script:resourceProperties.Path = [string]::Empty
                $script:resourceProperties.Datacenter = [string]::Empty
                $script:resourceProperties.FolderType = [string]::Empty
            }

            It 'Should call the Remove-Folder mock with the passed Server and MyDSCFolder once' {
                # Act
                $resource.Set()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Remove-Folder'
                    ParameterFilter = { $Server -eq $script:viServer -and $Folder -eq $script:folderInDatacenter }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }
    }

    Describe 'Folder\Test' -Tag 'Test' {
        BeforeEach {
            # Arrange
            $viServerMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:viServerScriptBlock))
            $rootFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:rootFolderViewBaseObjectScriptBlock))

            Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $rootFolderMock -ModuleName $script:moduleName
        }

        Context 'Invoking with Ensure Present, Datacenter Folder Type and non existing Folder' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Path = "$($script:constants.PathItemOne)/$($script:constants.PathItemTwo)/$($script:constants.FolderName)"
                $script:resourceProperties.FolderType = 'Datacenter'

                # Creates the needed Mocks when the Folder Type is Datacenter
                New-MocksWhenFolderTypeIsDatacenter

                Mock -CommandName Get-Folder -MockWith { return $null } -ModuleName $script:moduleName
                Mock -CommandName New-Folder -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.Path = [string]::Empty
                $script:resourceProperties.FolderType = [string]::Empty
            }

            It 'Should return $false' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $false
            }
        }

        Context 'Invoking with Ensure Present, Folder Type different from Datacenter and non existing Folder' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Path = "$($script:constants.DatacenterInventoryPathItemOne)/$($script:constants.DatacenterInventoryPathItemTwo)"
                $script:resourceProperties.Datacenter = "$($script:constants.DatacenterPathItemOne)/$($script:constants.DatacenterPathItemTwo)/$($script:constants.DatacenterName)"
                $script:resourceProperties.FolderType = 'Vm'

                # Creates the needed Mocks when the Folder Type is not Datacenter
                New-MocksWhenFolderTypeIsNotDatacenter

                Mock -CommandName Get-Folder -MockWith { return $null } -ModuleName $script:moduleName
                Mock -CommandName New-Folder -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.Path = [string]::Empty
                $script:resourceProperties.Datacenter = [string]::Empty
                $script:resourceProperties.FolderType = [string]::Empty
            }

            It 'Should return $false' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $false
            }
        }

        Context 'Invoking with Ensure Present, Datacenter Folder Type and existing Folder' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Path = "$($script:constants.PathItemOne)/$($script:constants.PathItemTwo)/$($script:constants.FolderName)"
                $script:resourceProperties.FolderType = 'Datacenter'

                $folderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:folderScriptBlock))

                # Creates the needed Mocks when the Folder Type is Datacenter
                New-MocksWhenFolderTypeIsDatacenter

                Mock -CommandName Get-Folder -MockWith $folderMock -ModuleName $script:moduleName
                Mock -CommandName New-Folder -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.Path = [string]::Empty
                $script:resourceProperties.FolderType = [string]::Empty
            }

            It 'Should return $true' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $true
            }
        }

        Context 'Invoking with Ensure Present, Folder Type different from Datacenter and existing Folder' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Path = "$($script:constants.DatacenterInventoryPathItemOne)/$($script:constants.DatacenterInventoryPathItemTwo)"
                $script:resourceProperties.Datacenter = "$($script:constants.DatacenterPathItemOne)/$($script:constants.DatacenterPathItemTwo)/$($script:constants.DatacenterName)"
                $script:resourceProperties.FolderType = 'Vm'

                $folderInDatacenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:folderInDatacenterScriptBlock))

                # Creates the needed Mocks when the Folder Type is not Datacenter
                New-MocksWhenFolderTypeIsNotDatacenter

                Mock -CommandName Get-Folder -MockWith $folderInDatacenterMock -ModuleName $script:moduleName
                Mock -CommandName New-Folder -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.Path = [string]::Empty
                $script:resourceProperties.Datacenter = [string]::Empty
                $script:resourceProperties.FolderType = [string]::Empty
            }

            It 'Should return $true' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $true
            }
        }

        Context 'Invoking with Ensure Absent, Datacenter Folder Type and non existing Folder' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Ensure = 'Absent'
                $script:resourceProperties.Path = "$($script:constants.PathItemOne)/$($script:constants.PathItemTwo)/$($script:constants.FolderName)"
                $script:resourceProperties.FolderType = 'Datacenter'

                # Creates the needed Mocks when the Folder Type is Datacenter
                New-MocksWhenFolderTypeIsDatacenter

                Mock -CommandName Get-Folder -MockWith { return $null } -ModuleName $script:moduleName
                Mock -CommandName Remove-Folder -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.Ensure = 'Present'
                $script:resourceProperties.Path = [string]::Empty
                $script:resourceProperties.FolderType = [string]::Empty
            }

            It 'Should return $true' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $true
            }
        }

        Context 'Invoking with Ensure Absent, Folder Type different from Datacenter and non existing Folder' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Ensure = 'Absent'
                $script:resourceProperties.Path = "$($script:constants.DatacenterInventoryPathItemOne)/$($script:constants.DatacenterInventoryPathItemTwo)"
                $script:resourceProperties.Datacenter = "$($script:constants.DatacenterPathItemOne)/$($script:constants.DatacenterPathItemTwo)/$($script:constants.DatacenterName)"
                $script:resourceProperties.FolderType = 'Vm'

                # Creates the needed Mocks when the Folder Type is not Datacenter
                New-MocksWhenFolderTypeIsNotDatacenter

                Mock -CommandName Get-Folder -MockWith { return $null } -ModuleName $script:moduleName
                Mock -CommandName Remove-Folder -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.Ensure = 'Present'
                $script:resourceProperties.Path = [string]::Empty
                $script:resourceProperties.Datacenter = [string]::Empty
                $script:resourceProperties.FolderType = [string]::Empty
            }

            It 'Should return $true' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $true
            }
        }

        Context 'Invoking with Ensure Absent, Datacenter Folder Type and existing Folder' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Ensure = 'Absent'
                $script:resourceProperties.Path = "$($script:constants.PathItemOne)/$($script:constants.PathItemTwo)/$($script:constants.FolderName)"
                $script:resourceProperties.FolderType = 'Datacenter'

                $folderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:folderScriptBlock))

                # Creates the needed Mocks when the Folder Type is Datacenter
                New-MocksWhenFolderTypeIsDatacenter

                Mock -CommandName Get-Folder -MockWith $folderMock -ModuleName $script:moduleName
                Mock -CommandName Remove-Folder -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.Ensure = 'Present'
                $script:resourceProperties.Path = [string]::Empty
                $script:resourceProperties.FolderType = [string]::Empty
            }

            It 'Should return $false' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $false
            }
        }

        Context 'Invoking with Ensure Absent, Folder Type different from Datacenter and existing Folder' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Ensure = 'Absent'
                $script:resourceProperties.Path = "$($script:constants.DatacenterInventoryPathItemOne)/$($script:constants.DatacenterInventoryPathItemTwo)"
                $script:resourceProperties.Datacenter = "$($script:constants.DatacenterPathItemOne)/$($script:constants.DatacenterPathItemTwo)/$($script:constants.DatacenterName)"
                $script:resourceProperties.FolderType = 'Vm'

                $folderInDatacenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:folderInDatacenterScriptBlock))

                # Creates the needed Mocks when the Folder Type is not Datacenter
                New-MocksWhenFolderTypeIsNotDatacenter

                Mock -CommandName Get-Folder -MockWith $folderInDatacenterMock -ModuleName $script:moduleName
                Mock -CommandName Remove-Folder -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.Ensure = 'Present'
                $script:resourceProperties.Path = [string]::Empty
                $script:resourceProperties.Datacenter = [string]::Empty
                $script:resourceProperties.FolderType = [string]::Empty
            }

            It 'Should return $false' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $false
            }
        }
    }

    Describe 'Folder\Get' -Tag 'Get' {
        BeforeEach {
            # Arrange
            $viServerMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:viServerScriptBlock))
            $rootFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:rootFolderViewBaseObjectScriptBlock))

            Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $rootFolderMock -ModuleName $script:moduleName
        }

        Context 'Invoking with Ensure Present, Datacenter Folder Type and non existing Folder' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Path = "$($script:constants.PathItemOne)/$($script:constants.PathItemTwo)/$($script:constants.FolderName)"
                $script:resourceProperties.FolderType = 'Datacenter'

                # Creates the needed Mocks when the Folder Type is Datacenter
                New-MocksWhenFolderTypeIsDatacenter

                Mock -CommandName Get-Folder -MockWith { return $null } -ModuleName $script:moduleName
                Mock -CommandName New-Folder -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.Path = [string]::Empty
                $script:resourceProperties.FolderType = [string]::Empty
            }

            It 'Should retrieve the correct settings from the server' {
                # Act
                $result = $resource.Get()

                # Assert
                $result.Server | Should -Be $script:resourceProperties.Server
                $result.FolderType | Should -Be $script:resourceProperties.FolderType
                $result.Path | Should -Be $script:resourceProperties.Path
                $result.Datacenter | Should -Be $script:resourceProperties.Datacenter
                $result.Name | Should -Be $script:resourceProperties.Name
                $result.Ensure | Should -Be 'Absent'
            }
        }

        Context 'Invoking with Ensure Present, Folder Type different from Datacenter and non existing Folder' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Path = "$($script:constants.DatacenterInventoryPathItemOne)/$($script:constants.DatacenterInventoryPathItemTwo)"
                $script:resourceProperties.Datacenter = "$($script:constants.DatacenterPathItemOne)/$($script:constants.DatacenterPathItemTwo)/$($script:constants.DatacenterName)"
                $script:resourceProperties.FolderType = 'Vm'

                # Creates the needed Mocks when the Folder Type is not Datacenter
                New-MocksWhenFolderTypeIsNotDatacenter

                Mock -CommandName Get-Folder -MockWith { return $null } -ModuleName $script:moduleName
                Mock -CommandName New-Folder -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.Path = [string]::Empty
                $script:resourceProperties.Datacenter = [string]::Empty
                $script:resourceProperties.FolderType = [string]::Empty
            }

            It 'Should retrieve the correct settings from the server' {
                # Act
                $result = $resource.Get()

                # Assert
                $result.Server | Should -Be $script:resourceProperties.Server
                $result.FolderType | Should -Be $script:resourceProperties.FolderType
                $result.Path | Should -Be $script:resourceProperties.Path
                $result.Datacenter | Should -Be $script:resourceProperties.Datacenter
                $result.Name | Should -Be $script:resourceProperties.Name
                $result.Ensure | Should -Be 'Absent'
            }
        }

        Context 'Invoking with Ensure Present, Datacenter Folder Type and existing Folder' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Path = "$($script:constants.PathItemOne)/$($script:constants.PathItemTwo)/$($script:constants.FolderName)"
                $script:resourceProperties.FolderType = 'Datacenter'

                $folderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:folderScriptBlock))

                # Creates the needed Mocks when the Folder Type is Datacenter
                New-MocksWhenFolderTypeIsDatacenter

                Mock -CommandName Get-Folder -MockWith $folderMock -ModuleName $script:moduleName
                Mock -CommandName New-Folder -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.Path = [string]::Empty
                $script:resourceProperties.FolderType = [string]::Empty
            }

            It 'Should retrieve the correct settings from the server' {
                # Act
                $result = $resource.Get()

                # Assert
                $result.Server | Should -Be $script:resourceProperties.Server
                $result.FolderType | Should -Be $script:resourceProperties.FolderType
                $result.Path | Should -Be $script:resourceProperties.Path
                $result.Datacenter | Should -Be $script:resourceProperties.Datacenter
                $result.Name | Should -Be $script:folder.Name
                $result.Ensure | Should -Be 'Present'
            }
        }

        Context 'Invoking with Ensure Present, Folder Type different from Datacenter and existing Folder' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Path = "$($script:constants.DatacenterInventoryPathItemOne)/$($script:constants.DatacenterInventoryPathItemTwo)"
                $script:resourceProperties.Datacenter = "$($script:constants.DatacenterPathItemOne)/$($script:constants.DatacenterPathItemTwo)/$($script:constants.DatacenterName)"
                $script:resourceProperties.FolderType = 'Vm'

                $folderInDatacenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:folderInDatacenterScriptBlock))

                # Creates the needed Mocks when the Folder Type is not Datacenter
                New-MocksWhenFolderTypeIsNotDatacenter

                Mock -CommandName Get-Folder -MockWith $folderInDatacenterMock -ModuleName $script:moduleName
                Mock -CommandName New-Folder -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.Path = [string]::Empty
                $script:resourceProperties.Datacenter = [string]::Empty
                $script:resourceProperties.FolderType = [string]::Empty
            }

            It 'Should retrieve the correct settings from the server' {
                # Act
                $result = $resource.Get()

                # Assert
                $result.Server | Should -Be $script:resourceProperties.Server
                $result.FolderType | Should -Be $script:resourceProperties.FolderType
                $result.Path | Should -Be $script:resourceProperties.Path
                $result.Datacenter | Should -Be $script:resourceProperties.Datacenter
                $result.Name | Should -Be $script:folderInDatacenter.Name
                $result.Ensure | Should -Be 'Present'
            }
        }

        Context 'Invoking with Ensure Absent, Datacenter Folder Type and non existing Folder' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Ensure = 'Absent'
                $script:resourceProperties.Path = "$($script:constants.PathItemOne)/$($script:constants.PathItemTwo)/$($script:constants.FolderName)"
                $script:resourceProperties.FolderType = 'Datacenter'

                # Creates the needed Mocks when the Folder Type is Datacenter
                New-MocksWhenFolderTypeIsDatacenter

                Mock -CommandName Get-Folder -MockWith { return $null } -ModuleName $script:moduleName
                Mock -CommandName Remove-Folder -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.Ensure = 'Present'
                $script:resourceProperties.Path = [string]::Empty
                $script:resourceProperties.FolderType = [string]::Empty
            }

            It 'Should retrieve the correct settings from the server' {
                # Act
                $result = $resource.Get()

                # Assert
                $result.Server | Should -Be $script:resourceProperties.Server
                $result.FolderType | Should -Be $script:resourceProperties.FolderType
                $result.Path | Should -Be $script:resourceProperties.Path
                $result.Datacenter | Should -Be $script:resourceProperties.Datacenter
                $result.Name | Should -Be $script:resourceProperties.Name
                $result.Ensure | Should -Be 'Absent'
            }
        }

        Context 'Invoking with Ensure Absent, Folder Type different from Datacenter and non existing Folder' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Ensure = 'Absent'
                $script:resourceProperties.Path = "$($script:constants.DatacenterInventoryPathItemOne)/$($script:constants.DatacenterInventoryPathItemTwo)"
                $script:resourceProperties.Datacenter = "$($script:constants.DatacenterPathItemOne)/$($script:constants.DatacenterPathItemTwo)/$($script:constants.DatacenterName)"
                $script:resourceProperties.FolderType = 'Vm'

                # Creates the needed Mocks when the Folder Type is not Datacenter
                New-MocksWhenFolderTypeIsNotDatacenter

                Mock -CommandName Get-Folder -MockWith { return $null } -ModuleName $script:moduleName
                Mock -CommandName Remove-Folder -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.Ensure = 'Present'
                $script:resourceProperties.Path = [string]::Empty
                $script:resourceProperties.Datacenter = [string]::Empty
                $script:resourceProperties.FolderType = [string]::Empty
            }

            It 'Should retrieve the correct settings from the server' {
                # Act
                $result = $resource.Get()

                # Assert
                $result.Server | Should -Be $script:resourceProperties.Server
                $result.FolderType | Should -Be $script:resourceProperties.FolderType
                $result.Path | Should -Be $script:resourceProperties.Path
                $result.Datacenter | Should -Be $script:resourceProperties.Datacenter
                $result.Name | Should -Be $script:resourceProperties.Name
                $result.Ensure | Should -Be 'Absent'
            }
        }

        Context 'Invoking with Ensure Absent, Datacenter Folder Type and existing Folder' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Ensure = 'Absent'
                $script:resourceProperties.Path = "$($script:constants.PathItemOne)/$($script:constants.PathItemTwo)/$($script:constants.FolderName)"
                $script:resourceProperties.FolderType = 'Datacenter'

                $folderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:folderScriptBlock))

                # Creates the needed Mocks when the Folder Type is Datacenter
                New-MocksWhenFolderTypeIsDatacenter

                Mock -CommandName Get-Folder -MockWith $folderMock -ModuleName $script:moduleName
                Mock -CommandName Remove-Folder -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.Ensure = 'Present'
                $script:resourceProperties.Path = [string]::Empty
                $script:resourceProperties.FolderType = [string]::Empty
            }

            It 'Should retrieve the correct settings from the server' {
                # Act
                $result = $resource.Get()

                # Assert
                $result.Server | Should -Be $script:resourceProperties.Server
                $result.FolderType | Should -Be $script:resourceProperties.FolderType
                $result.Path | Should -Be $script:resourceProperties.Path
                $result.Datacenter | Should -Be $script:resourceProperties.Datacenter
                $result.Name | Should -Be $script:folder.Name
                $result.Ensure | Should -Be 'Present'
            }
        }

        Context 'Invoking with Ensure Absent, Folder Type different from Datacenter and existing Folder' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Ensure = 'Absent'
                $script:resourceProperties.Path = "$($script:constants.DatacenterInventoryPathItemOne)/$($script:constants.DatacenterInventoryPathItemTwo)"
                $script:resourceProperties.Datacenter = "$($script:constants.DatacenterPathItemOne)/$($script:constants.DatacenterPathItemTwo)/$($script:constants.DatacenterName)"
                $script:resourceProperties.FolderType = 'Vm'

                $folderInDatacenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:folderInDatacenterScriptBlock))

                # Creates the needed Mocks when the Folder Type is not Datacenter
                New-MocksWhenFolderTypeIsNotDatacenter

                Mock -CommandName Get-Folder -MockWith $folderInDatacenterMock -ModuleName $script:moduleName
                Mock -CommandName Remove-Folder -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.Ensure = 'Present'
                $script:resourceProperties.Path = [string]::Empty
                $script:resourceProperties.Datacenter = [string]::Empty
                $script:resourceProperties.FolderType = [string]::Empty
            }

            It 'Should retrieve the correct settings from the server' {
                # Act
                $result = $resource.Get()

                # Assert
                $result.Server | Should -Be $script:resourceProperties.Server
                $result.FolderType | Should -Be $script:resourceProperties.FolderType
                $result.Path | Should -Be $script:resourceProperties.Path
                $result.Datacenter | Should -Be $script:resourceProperties.Datacenter
                $result.Name | Should -Be $script:folderInDatacenter.Name
                $result.Ensure | Should -Be 'Present'
            }
        }
    }
}
finally {
	# Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
    Invoke-TestCleanup
}
