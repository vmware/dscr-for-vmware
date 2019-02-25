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
    $script:resourceName = 'HACluster'

    $script:user = 'user'
    $password = 'password' | ConvertTo-SecureString -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential($script:user, $password)

    $script:resourceProperties = @{
        Server = '10.23.80.58'
        Credential = $credential
        Name = 'MyCluster'
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
        HostFolderId = 'group-h4'
        HostFolderName = 'HostFolder'
        InventoryPathItemOneId = 'my-cluster-location-one'
        InventoryPathItemOne = 'MyClusterFolderOne'
        InventoryPathItemTwoId = 'my-cluster-location-two'
        InventoryPathItemTwo = 'MyClusterFolderTwo'
        ClusterId = 'my-cluster-id'
        ClusterName = 'MyCluster'
    }

    $script:vCenterScriptBlock = @'
        return [VMware.Vim.VCenter] @{
            Name = '$($script:resourceProperties.Server)'
            User = '$($script:user)'
        }
'@

    $script:vCenterWithRootFolderScriptBlock = @'
        return [VMware.Vim.VCenter] @{
            Name = '$($script:resourceProperties.Server)'
            User = '$($script:user)'
            ExtensionData = [VMware.Vim.VCenterExtensionData] @{
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
        return [VMware.VimAutomation.VICore.Impl.V1.Inventory.DatacenterImpl] @{
            Id = '$($script:constants.DatacenterId)'
            Name = '$($script:constants.DatacenterName)'
            ParentFolderId = '$($script:constants.DatacentersFolderId)'
        }
'@

    $script:datacenterWithPathItemTwoAsParentScriptBlock = @'
        return [VMware.VimAutomation.VICore.Impl.V1.Inventory.DatacenterImpl] @{
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

    $script:clusterPathItemOneLocationScriptBlock = @'
        return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
            Id = '$($script:constants.InventoryPathItemOneId)'
            Name = '$($script:constants.InventoryPathItemOne)'
            ParentId = '$($script:constants.HostFolderId)'
        }
'@

    $script:locationsScriptBlock = @'
        return @(
            @{
                Id = [VMware.Vim.ManagedObjectReference] @{
                    Type = '$($script:constants.FolderType)'
                    Value = '$($script:constants.InventoryPathItemTwoId)'
                }
            }
        )
'@

    $script:locationViewBaseObjectScriptBlock = @'
        return [VMware.Vim.Folder] @{
            Name = '$($script:constants.InventoryPathItemTwo)'
            Parent = [VMware.Vim.ManagedObjectReference] @{
                Type = '$($script:constants.FolderType)'
                Value = '$($script:constants.InventoryPathItemOneId)'
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
            Name = '$($script:constants.InventoryPathItemOne)'
            Parent = [VMware.Vim.ManagedObjectReference] @{
                Type = '$($script:constants.FolderType)'
                Value = '$($script:constants.InventoryPathItemOneId)'
            }
        }
'@

    $script:clusterScriptBlock = @'
        return @{
            Id = '$($script:constants.ClusterId)'
            Name = '$($script:constants.ClusterName)'
            ParentId = [VMware.Vim.ManagedObjectReference] @{
                Type = '$($script:constants.FolderType)'
                Value = '$($script:constants.InventoryPathItemTwoId)'
            }
            HAEnabled = '$($true)'
            HAAdmissionControlEnabled = '$($true)'
            HAFailoverLevel = 4
            HAIsolationResponse = 'DoNothing'
            HARestartPriority = 'High'
        }
'@

    $env:PSModulePath = $script:mockModuleLocation
    $vimAutomationModule = Get-Module -Name VMware.VimAutomation.Core
    if ($null -ne $vimAutomationModule -and $vimAutomationModule.Path -NotMatch 'TestHelpers') {
        throw 'The Original VMware.VimAutomation.Core Module is loaded in the current session. If you want to run the unit tests please open a new PowerShell session.'
    }

    Import-Module -Name VMware.VimAutomation.Core

    $script:vCenter = [VMware.Vim.VCenter] @{
        Name = $script:resourceProperties.Server
        User = $script:user
    }

    $script:rootFolder = [VMware.Vim.ManagedObjectReference] @{
        Type = $script:constants.FolderType
        Value = $script:constants.RootFolderValue
    }

    $script:datacentersFolder = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
        Id = $script:constants.DatacentersFolderId
        Name = $script:constants.DatacentersFolderName
    }

    $script:datacenterPathItemOne = [VMware.Vim.ManagedObjectReference] @{
        Type = $script:constants.FolderType
        Value = $script:constants.DatacenterPathItemOne
    }

    $script:datacenterPathItemTwo = [VMware.Vim.ManagedObjectReference] @{
        Type = $script:constants.FolderType
        Value = $script:constants.DatacenterPathItemTwo
    }

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

    $script:location = [VMware.Vim.ManagedObjectReference] @{
        Type = $script:constants.FolderType
        Value = $script:constants.InventoryPathItemTwoId
    }

    $script:locationParent = [VMware.Vim.ManagedObjectReference] @{
        Type = $script:constants.FolderType
        Value = $script:constants.InventoryPathItemOneId
    }

    $script:clusterLocation = @{
        Id = [VMware.Vim.ManagedObjectReference] @{
            Type = $script:constants.FolderType
            Value = $script:constants.InventoryPathItemTwoId
        }
    }

    $script:cluster = @{
        Id = $script:constants.ClusterId
        Name = $script:constants.ClusterName
        ParentId = [VMware.Vim.ManagedObjectReference] @{
            Type = $script:constants.FolderType
            Value = $script:constants.InventoryPathItemTwoId
        }
        HAEnabled = $true
        HAAdmissionControlEnabled = $true
        HAFailoverLevel = 4
        HAIsolationResponse = 'DoNothing'
        HARestartPriority = 'High'
    }
}

function Invoke-TestCleanup {
    Remove-Module -Name VMware.VimAutomation.Core
    $env:PSModulePath = $script:modulePath
}

try {
    # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
    Invoke-TestSetup

    Describe 'HACluster\GetClusterData' -Tag 'GetClusterData' {
        Context 'Empty Datacenter path is passed' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Datacenter = [string]::Empty

                $vCenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vCenterScriptBlock))

                Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
            }

            AfterAll {
                $script:resourceProperties.Datacenter = [string]::Empty
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call the Connect-VIServer mock with the passed Server and Credentials once' {
                # Act
                { $resource.GetClusterData() } | Should -Throw 'You have passed an empty path which is not a valid value.'

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Connect-VIServer'
                    ParameterFilter = { $Server -eq $script:resourceProperties.Server -and $Credential -eq $script:resourceProperties.Credential }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Datacenter Path consists only of the Datacenter name and the Datacenter does not exist' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Datacenter = $script:constants.DatacenterName

                $vCenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vCenterWithRootFolderScriptBlock))
                $rootFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:rootFolderViewBaseObjectScriptBlock))
                $datacentersFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacentersFolderScriptBlock))

                Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $rootFolderMock -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $datacentersFolderMock -ModuleName $script:moduleName
                Mock -CommandName Get-Datacenter -MockWith { return $null } -ModuleName $script:moduleName
            }

            AfterAll {
                $script:resourceProperties.Datacenter = [string]::Empty
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call the Connect-VIServer mock with the passed Server and Credentials once' {
                # Act
                { $resource.GetClusterData() } | Should -Throw "Datacenter with name $($script:resourceProperties.Datacenter) was not found at Datacenters."

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Connect-VIServer'
                    ParameterFilter = { $Server -eq $script:resourceProperties.Server -and $Credential -eq $script:resourceProperties.Credential }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-View mock with the passed Server and vCenter Root Folder once' {
                # Act
                { $resource.GetClusterData() } | Should -Throw "Datacenter with name $($script:resourceProperties.Datacenter) was not found at Datacenters."

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
                { $resource.GetClusterData() } | Should -Throw "Datacenter with name $($script:resourceProperties.Datacenter) was not found at Datacenters."

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-Inventory'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Id -eq $script:rootFolder }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-Datacenter mock with the passed Server, Datacenter Name and Datacenters Folder Location once' {
                # Act
                { $resource.GetClusterData() } | Should -Throw "Datacenter with name $($script:resourceProperties.Datacenter) was not found at Datacenters."

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-Datacenter'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.Datacenter -and $Location -eq $script:datacentersFolder }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Datacenter Path consists only of the Datacenter name and the Datacenter exists' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Datacenter = $script:constants.DatacenterName
                $script:resourceProperties.InventoryPath = [string]::Empty

                $vCenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vCenterWithRootFolderScriptBlock))
                $rootFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:rootFolderViewBaseObjectScriptBlock))
                $datacentersFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacentersFolderScriptBlock))
                $datacenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterScriptBlock))

                Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $rootFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:rootFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $datacentersFolderMock -ModuleName $script:moduleName
                Mock -CommandName Get-Datacenter -MockWith $datacenterMock -ModuleName $script:moduleName
            }

            AfterAll {
                $script:resourceProperties.Datacenter = [string]::Empty
                $script:resourceProperties.InventoryPath = [string]::Empty
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call the Connect-VIServer mock with the passed Server and credentials once' {
                # Act
                { $resource.GetClusterData() } | Should -Not -Throw

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Connect-VIServer'
                    ParameterFilter = { $Server -eq $script:resourceProperties.Server -and $Credential -eq $script:resourceProperties.Credential }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-View mock with the passed Server and vCenter Root Folder once' {
                # Act
                { $resource.GetClusterData() } | Should -Not -Throw

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
                { $resource.GetClusterData() } | Should -Not -Throw

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-Inventory'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Id -eq $script:rootFolder }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-Datacenter mock with the passed Server, Datacenter Name and Datacenters Folder Location once' {
                # Act
                { $resource.GetClusterData() } | Should -Not -Throw

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-Datacenter'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.Datacenter -and $Location -eq $script:datacentersFolder }
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
                $script:resourceProperties.Datacenter = "$($script:constants.DatacenterPathItemOne)/$($script:constants.DatacenterPathItemTwo)/$($script:constants.DatacenterName)"

                $vCenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vCenterWithRootFolderScriptBlock))
                $rootFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:rootFolderViewBaseObjectScriptBlock))
                $datacenterPathItemOne = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemOneScriptBlock))
                $datacenterPathItemTwo = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemTwoScriptBlock))
                $datacenterFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterFolderScriptBlock))

                Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $rootFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:rootFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $datacenterPathItemOne -ParameterFilter { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemOne } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $datacenterPathItemTwo -ParameterFilter { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemTwo } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $datacenterFolderMock -ModuleName $script:moduleName
                Mock -CommandName Get-Datacenter -MockWith { return $null } -ModuleName $script:moduleName
            }

            AfterAll {
                $script:resourceProperties.Datacenter = [string]::Empty
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call the Connect-VIServer mock with the passed Server and credentials once' {
                # Act
                { $resource.GetClusterData() } | Should -Throw "Datacenter with name $($script:constants.datacenterName) was not found."

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Connect-VIServer'
                    ParameterFilter = { $Server -eq $script:resourceProperties.Server -and $Credential -eq $script:resourceProperties.Credential }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-View mock with the passed Server and vCenter Root Folder once' {
                # Act
                { $resource.GetClusterData() } | Should -Throw "Datacenter with name $($script:constants.datacenterName) was not found."

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
                { $resource.GetClusterData() } | Should -Throw "Datacenter with name $($script:constants.datacenterName) was not found."

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-View'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemOne }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-View mock with the passed Server and MyDatacenterFolderTwo once' {
                # Act
                { $resource.GetClusterData() } | Should -Throw "Datacenter with name $($script:constants.datacenterName) was not found."

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-View'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemTwo }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-Inventory mock with the passed Server and MyDatacenterFolderTwo once' {
                # Act
                { $resource.GetClusterData() } | Should -Throw "Datacenter with name $($script:constants.datacenterName) was not found."

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
                { $resource.GetClusterData() } | Should -Throw "Datacenter with name $($script:constants.datacenterName) was not found."

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

        Context 'Datacenter Path consists of two Folders and the Datacenter name and the Datacenter exists' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Datacenter = "$($script:constants.DatacenterPathItemOne)/$($script:constants.DatacenterPathItemTwo)/$($script:constants.DatacenterName)"

                $vCenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vCenterWithRootFolderScriptBlock))
                $rootFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:rootFolderViewBaseObjectScriptBlock))
                $datacenterPathItemOne = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemOneScriptBlock))
                $datacenterPathItemTwo = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemTwoScriptBlock))
                $datacenterFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterFolderScriptBlock))
                $datacenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterWithPathItemTwoAsParentScriptBlock))

                Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $rootFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:rootFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $datacenterPathItemOne -ParameterFilter { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemOne } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $datacenterPathItemTwo -ParameterFilter { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemTwo } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $datacenterFolderMock -ModuleName $script:moduleName
                Mock -CommandName Get-Datacenter -MockWith $datacenterMock -ModuleName $script:moduleName
            }

            AfterAll {
                $script:resourceProperties.Datacenter = [string]::Empty
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call the Connect-VIServer mock with the passed Server and credentials once' {
                # Act
                { $resource.GetClusterData() } | Should -Not -Throw

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Connect-VIServer'
                    ParameterFilter = { $Server -eq $script:resourceProperties.Server -and $Credential -eq $script:resourceProperties.Credential }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-View mock with the passed Server and vCenter Root Folder once' {
                # Act
                { $resource.GetClusterData() } | Should -Not -Throw

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
                { $resource.GetClusterData() } | Should -Not -Throw

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-View'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemOne }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-View mock with the passed Server and MyDatacenterFolderTwo once' {
                # Act
                { $resource.GetClusterData() } | Should -Not -Throw

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-View'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemTwo }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-Inventory mock with the passed Server and MyDatacenterFolderTwo once' {
                # Act
                { $resource.GetClusterData() } | Should -Not -Throw

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
                { $resource.GetClusterData() } | Should -Not -Throw

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

        Context 'Empty Inventory Path is passed' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Datacenter = "$($script:constants.DatacenterPathItemOne)/$($script:constants.DatacenterPathItemTwo)/$($script:constants.DatacenterName)"
                $script:resourceProperties.InventoryPath = [string]::Empty

                $vCenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vCenterWithRootFolderScriptBlock))
                $rootFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:rootFolderViewBaseObjectScriptBlock))
                $datacenterPathItemOne = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemOneScriptBlock))
                $datacenterPathItemTwo = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemTwoScriptBlock))
                $datacenterFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterFolderScriptBlock))
                $datacenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterWithPathItemTwoAsParentScriptBlock))
                $hostFolderViewBaseObjectMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:hostFolderOfDatacenterViewBaseObjectScriptBlock))
                $hostFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:hostFolderScriptBlock))

                Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $rootFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:rootFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $datacenterPathItemOne -ParameterFilter { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemOne } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $datacenterPathItemTwo -ParameterFilter { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemTwo } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $datacenterFolderMock -ModuleName $script:moduleName
                Mock -CommandName Get-Datacenter -MockWith $datacenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $hostFolderViewBaseObjectMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $hostFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder } -ModuleName $script:moduleName
            }

            AfterAll {
                $script:resourceProperties.Datacenter = [string]::Empty
                $script:resourceProperties.InventoryPath = [string]::Empty
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call the Connect-VIServer mock with the passed Server and credentials once' {
                # Act
                { $resource.GetClusterData() } | Should -Not -Throw

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Connect-VIServer'
                    ParameterFilter = { $Server -eq $script:resourceProperties.Server -and $Credential -eq $script:resourceProperties.Credential }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-View mock with the passed Server and vCenter Root Folder once' {
                # Act
                { $resource.GetClusterData() } | Should -Not -Throw

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
                { $resource.GetClusterData() } | Should -Not -Throw

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-View'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemOne }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-View mock with the passed Server and MyDatacenterFolderTwo once' {
                # Act
                { $resource.GetClusterData() } | Should -Not -Throw

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-View'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemTwo }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-Inventory mock with the passed Server and MyDatacenterFolderTwo once' {
                # Act
                { $resource.GetClusterData() } | Should -Not -Throw

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
                { $resource.GetClusterData() } | Should -Not -Throw

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

            It 'Should call the Get-View mock with the passed Server and HostFolder of the Datacenter once' {
                # Act
                { $resource.GetClusterData() } | Should -Not -Throw

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
                { $resource.GetClusterData() } | Should -Not -Throw

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

        Context 'Inventory Path consists only of one Folder and the path is not valid' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Datacenter = "$($script:constants.DatacenterPathItemOne)/$($script:constants.DatacenterPathItemTwo)/$($script:constants.DatacenterName)"
                $script:resourceProperties.InventoryPath = "$($script:constants.InventoryPathItemOne)"

                $vCenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vCenterWithRootFolderScriptBlock))
                $rootFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:rootFolderViewBaseObjectScriptBlock))
                $datacenterPathItemOne = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemOneScriptBlock))
                $datacenterPathItemTwo = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemTwoScriptBlock))
                $datacenterFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterFolderScriptBlock))
                $datacenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterWithPathItemTwoAsParentScriptBlock))
                $hostFolderViewBaseObjectMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:hostFolderOfDatacenterViewBaseObjectScriptBlock))
                $hostFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:hostFolderScriptBlock))

                Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $rootFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:rootFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $datacenterPathItemOne -ParameterFilter { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemOne } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $datacenterPathItemTwo -ParameterFilter { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemTwo } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $datacenterFolderMock -ModuleName $script:moduleName
                Mock -CommandName Get-Datacenter -MockWith $datacenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $hostFolderViewBaseObjectMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $hostFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith { return $null } -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.InventoryPath -and $Location -eq $script:hostFolderLocation } -ModuleName $script:moduleName
            }

            AfterAll {
                $script:resourceProperties.Datacenter = [string]::Empty
                $script:resourceProperties.InventoryPath = [string]::Empty
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call the Connect-VIServer mock with the passed Server and credentials once' {
                # Act
                { $resource.GetClusterData() } | Should -Throw "The provided path $($script:resourceProperties.InventoryPath) is not a valid path in the Folder $($script:constants.HostFolderName)."

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Connect-VIServer'
                    ParameterFilter = { $Server -eq $script:resourceProperties.Server -and $Credential -eq $script:resourceProperties.Credential }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-View mock with the passed Server and vCenter Root Folder once' {
                # Act
                { $resource.GetClusterData() } | Should -Throw "The provided path $($script:resourceProperties.InventoryPath) is not a valid path in the Folder $($script:constants.HostFolderName)."

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
                { $resource.GetClusterData() } | Should -Throw "The provided path $($script:resourceProperties.InventoryPath) is not a valid path in the Folder $($script:constants.HostFolderName)."

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-View'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemOne }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-View mock with the passed Server and MyDatacenterFolderTwo once' {
                # Act
                { $resource.GetClusterData() } | Should -Throw "The provided path $($script:resourceProperties.InventoryPath) is not a valid path in the Folder $($script:constants.HostFolderName)."

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-View'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemTwo }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-Inventory mock with the passed Server and MyDatacenterFolderTwo once' {
                # Act
                { $resource.GetClusterData() } | Should -Throw "The provided path $($script:resourceProperties.InventoryPath) is not a valid path in the Folder $($script:constants.HostFolderName)."

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
                { $resource.GetClusterData() } | Should -Throw "The provided path $($script:resourceProperties.InventoryPath) is not a valid path in the Folder $($script:constants.HostFolderName)."

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

            It 'Should call the Get-View mock with the passed Server and HostFolder of the Datacenter once' {
                # Act
                { $resource.GetClusterData() } | Should -Throw "The provided path $($script:resourceProperties.InventoryPath) is not a valid path in the Folder $($script:constants.HostFolderName)."

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
                { $resource.GetClusterData() } | Should -Throw "The provided path $($script:resourceProperties.InventoryPath) is not a valid path in the Folder $($script:constants.HostFolderName)."

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

            It 'Should call the Get-Inventory mock with the passed Server, MyClusterFolderOne and HostFolder Location once' {
                # Act
                { $resource.GetClusterData() } | Should -Throw "The provided path $($script:resourceProperties.InventoryPath) is not a valid path in the Folder $($script:constants.HostFolderName)."

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-Inventory'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.InventoryPath -and $Location -eq $script:hostFolderLocation }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Inventory Path consists only of one Folder and the path is valid' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Datacenter = "$($script:constants.DatacenterPathItemOne)/$($script:constants.DatacenterPathItemTwo)/$($script:constants.DatacenterName)"
                $script:resourceProperties.InventoryPath = "$($script:constants.InventoryPathItemOne)"

                $vCenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vCenterWithRootFolderScriptBlock))
                $rootFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:rootFolderViewBaseObjectScriptBlock))
                $datacenterPathItemOne = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemOneScriptBlock))
                $datacenterPathItemTwo = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemTwoScriptBlock))
                $datacenterFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterFolderScriptBlock))
                $datacenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterWithPathItemTwoAsParentScriptBlock))
                $hostFolderViewBaseObjectMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:hostFolderOfDatacenterViewBaseObjectScriptBlock))
                $clusterPathItemOneLocationMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:clusterPathItemOneLocationScriptBlock))

                Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $rootFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:rootFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $datacenterPathItemOne -ParameterFilter { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemOne } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $datacenterPathItemTwo -ParameterFilter { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemTwo } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $datacenterFolderMock -ModuleName $script:moduleName
                Mock -CommandName Get-Datacenter -MockWith $datacenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $hostFolderViewBaseObjectMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $hostFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $clusterPathItemOneLocationMock -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.InventoryPath -and $Location -eq $script:hostFolderLocation } -ModuleName $script:moduleName
            }

            AfterAll {
                $script:resourceProperties.Datacenter = [string]::Empty
                $script:resourceProperties.InventoryPath = [string]::Empty
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call the Connect-VIServer mock with the passed Server and credentials once' {
                # Act
                { $resource.GetClusterData() } | Should -Not -Throw

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Connect-VIServer'
                    ParameterFilter = { $Server -eq $script:resourceProperties.Server -and $Credential -eq $script:resourceProperties.Credential }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-View mock with the passed Server and vCenter Root Folder once' {
                # Act
                { $resource.GetClusterData() } | Should -Not -Throw

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
                { $resource.GetClusterData() } | Should -Not -Throw

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-View'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemOne }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-View mock with the passed Server and MyDatacenterFolderTwo once' {
                # Act
                { $resource.GetClusterData() } | Should -Not -Throw

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-View'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemTwo }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-Inventory mock with the passed Server and MyDatacenterFolderTwo once' {
                # Act
                { $resource.GetClusterData() } | Should -Not -Throw

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
                { $resource.GetClusterData() } | Should -Not -Throw

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

            It 'Should call the Get-View mock with the passed Server and HostFolder of the Datacenter once' {
                # Act
                { $resource.GetClusterData() } | Should -Not -Throw

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
                { $resource.GetClusterData() } | Should -Not -Throw

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

            It 'Should call the Get-Inventory mock with the passed Server, MyClusterFolderOne and HostFolder Location once' {
                # Act
                { $resource.GetClusterData() } | Should -Not -Throw

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-Inventory'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.InventoryPath -and $Location -eq $script:hostFolderLocation }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Inventory Path consists of two Folders and the path is not valid' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Datacenter = "$($script:constants.DatacenterPathItemOne)/$($script:constants.DatacenterPathItemTwo)/$($script:constants.DatacenterName)"
                $script:resourceProperties.InventoryPath = "$($script:constants.InventoryPathItemOne)/$($script:constants.InventoryPathItemTwo)"

                $vCenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vCenterWithRootFolderScriptBlock))
                $rootFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:rootFolderViewBaseObjectScriptBlock))
                $datacenterPathItemOne = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemOneScriptBlock))
                $datacenterPathItemTwo = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemTwoScriptBlock))
                $datacenterFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterFolderScriptBlock))
                $datacenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterWithPathItemTwoAsParentScriptBlock))
                $hostFolderViewBaseObjectMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:hostFolderOfDatacenterViewBaseObjectScriptBlock))
                $locationsMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationsScriptBlock))
                $locationViewBaseObjectMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationViewBaseObjectScriptBlock))
                $locationInvalidParentMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationInvalidParentScriptBlock))

                Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $rootFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:rootFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $datacenterPathItemOne -ParameterFilter { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemOne } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $datacenterPathItemTwo -ParameterFilter { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemTwo } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $datacenterFolderMock -ModuleName $script:moduleName
                Mock -CommandName Get-Datacenter -MockWith $datacenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $hostFolderViewBaseObjectMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $hostFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $locationsMock -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:constants.InventoryPathItemTwo -and $Location -eq $script:hostFolderLocation } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $locationViewBaseObjectMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:location } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $locationInvalidParentMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:locationParent } -ModuleName $script:moduleName
            }

            AfterAll {
                $script:resourceProperties.Datacenter = [string]::Empty
                $script:resourceProperties.InventoryPath = [string]::Empty
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call the Connect-VIServer mock with the passed Server and credentials once' {
                # Act
                { $resource.GetClusterData() } | Should -Throw "The provided path $($script:resourceProperties.InventoryPath) is not a valid path in the Datacenter $($script:constants.DatacenterName)."

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Connect-VIServer'
                    ParameterFilter = { $Server -eq $script:resourceProperties.Server -and $Credential -eq $script:resourceProperties.Credential }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-View mock with the passed Server and vCenter Root Folder once' {
                # Act
                { $resource.GetClusterData() } | Should -Throw "The provided path $($script:resourceProperties.InventoryPath) is not a valid path in the Datacenter $($script:constants.DatacenterName)."

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
                { $resource.GetClusterData() } | Should -Throw "The provided path $($script:resourceProperties.InventoryPath) is not a valid path in the Datacenter $($script:constants.DatacenterName)."

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-View'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemOne }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-View mock with the passed Server and MyDatacenterFolderTwo once' {
                # Act
                { $resource.GetClusterData() } | Should -Throw "The provided path $($script:resourceProperties.InventoryPath) is not a valid path in the Datacenter $($script:constants.DatacenterName)."

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-View'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemTwo }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-Inventory mock with the passed Server and MyDatacenterFolderTwo once' {
                # Act
                { $resource.GetClusterData() } | Should -Throw "The provided path $($script:resourceProperties.InventoryPath) is not a valid path in the Datacenter $($script:constants.DatacenterName)."

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
                { $resource.GetClusterData() } | Should -Throw "The provided path $($script:resourceProperties.InventoryPath) is not a valid path in the Datacenter $($script:constants.DatacenterName)."

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

            It 'Should call the Get-View mock with the passed Server and HostFolder of the Datacenter once' {
                # Act
                { $resource.GetClusterData() } | Should -Throw "The provided path $($script:resourceProperties.InventoryPath) is not a valid path in the Datacenter $($script:constants.DatacenterName)."

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
                { $resource.GetClusterData() } | Should -Throw "The provided path $($script:resourceProperties.InventoryPath) is not a valid path in the Datacenter $($script:constants.DatacenterName)."

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

            It 'Should call the Get-Inventory mock with the passed Server, MyClusterFolderTwo and HostFolder Location once' {
                # Act
                { $resource.GetClusterData() } | Should -Throw "The provided path $($script:resourceProperties.InventoryPath) is not a valid path in the Datacenter $($script:constants.DatacenterName)."

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-Inventory'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Name -eq $script:constants.InventoryPathItemTwo -and $Location -eq $script:hostFolderLocation }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-View mock with the passed Server and MyClusterFolderTwo once' {
                # Act
                { $resource.GetClusterData() } | Should -Throw "The provided path $($script:resourceProperties.InventoryPath) is not a valid path in the Datacenter $($script:constants.DatacenterName)."

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-View'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Id -eq $script:location }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-View mock with the passed Server and MyClusterFolderOne once' {
                # Act
                { $resource.GetClusterData() } | Should -Throw "The provided path $($script:resourceProperties.InventoryPath) is not a valid path in the Datacenter $($script:constants.DatacenterName)."

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

        Context 'Inventory Path consists of two Folders and the path is valid' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Datacenter = "$($script:constants.DatacenterPathItemOne)/$($script:constants.DatacenterPathItemTwo)/$($script:constants.DatacenterName)"
                $script:resourceProperties.InventoryPath = "$($script:constants.InventoryPathItemOne)/$($script:constants.InventoryPathItemTwo)"

                $vCenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vCenterWithRootFolderScriptBlock))
                $rootFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:rootFolderViewBaseObjectScriptBlock))
                $datacenterPathItemOne = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemOneScriptBlock))
                $datacenterPathItemTwo = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemTwoScriptBlock))
                $datacenterFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterFolderScriptBlock))
                $datacenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterWithPathItemTwoAsParentScriptBlock))
                $hostFolderViewBaseObjectMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:hostFolderOfDatacenterViewBaseObjectScriptBlock))
                $locationsMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationsScriptBlock))
                $locationViewBaseObjectMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationViewBaseObjectScriptBlock))
                $locationParentMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationParentScriptBlock))

                Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $rootFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:rootFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $datacenterPathItemOne -ParameterFilter { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemOne } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $datacenterPathItemTwo -ParameterFilter { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemTwo } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $datacenterFolderMock -ModuleName $script:moduleName
                Mock -CommandName Get-Datacenter -MockWith $datacenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $hostFolderViewBaseObjectMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $hostFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith $locationsMock -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:constants.InventoryPathItemTwo -and $Location -eq $script:hostFolderLocation } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $locationViewBaseObjectMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:location } -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $locationParentMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:locationParent } -ModuleName $script:moduleName
                Mock -CommandName Get-Inventory -MockWith { return $null } -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.Name -and $Location.Id -eq $script:clusterLocation.Id } -ModuleName $script:moduleName
            }

            AfterAll {
                $script:resourceProperties.Datacenter = [string]::Empty
                $script:resourceProperties.InventoryPath = [string]::Empty
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call the Connect-VIServer mock with the passed Server and credentials once' {
                # Act
                { $resource.GetClusterData() } | Should -Not -Throw

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Connect-VIServer'
                    ParameterFilter = { $Server -eq $script:resourceProperties.Server -and $Credential -eq $script:resourceProperties.Credential }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-View mock with the passed Server and vCenter Root Folder once' {
                # Act
                { $resource.GetClusterData() } | Should -Not -Throw

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
                { $resource.GetClusterData() } | Should -Not -Throw

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-View'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemOne }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-View mock with the passed Server and MyDatacenterFolderTwo once' {
                # Act
                { $resource.GetClusterData() } | Should -Not -Throw

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-View'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemTwo }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-Inventory mock with the passed Server and MyDatacenterFolderTwo once' {
                # Act
                { $resource.GetClusterData() } | Should -Not -Throw

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
                { $resource.GetClusterData() } | Should -Not -Throw

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

            It 'Should call the Get-View mock with the passed Server and HostFolder of the Datacenter once' {
                # Act
                { $resource.GetClusterData() } | Should -Not -Throw

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
                { $resource.GetClusterData() } | Should -Not -Throw

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

            It 'Should call the Get-Inventory mock with the passed Server, MyClusterFolderTwo and HostFolder Location once' {
                # Act
                { $resource.GetClusterData() } | Should -Not -Throw

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-Inventory'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Name -eq $script:constants.InventoryPathItemTwo -and $Location -eq $script:hostFolderLocation }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-View mock with the passed Server and MyClusterFolderTwo once' {
                # Act
                { $resource.GetClusterData() } | Should -Not -Throw

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-View'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Id -eq $script:location }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call the Get-View mock with the passed Server and MyClusterFolderOne once' {
                # Act
                { $resource.GetClusterData() } | Should -Not -Throw

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

            It 'Should call the Get-Inventory mock with the passed Server, MyCluster and valid Location once' {
                # Act
                { $resource.GetClusterData() } | Should -Not -Throw

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-Inventory'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.Name -and $Location.Id -eq $script:clusterLocation.Id }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }
    }

    Describe 'HACluster\Set' -Tag 'Set' {
        BeforeEach {
            # Arrange
            $script:resourceProperties.Datacenter = "$($script:constants.DatacenterPathItemOne)/$($script:constants.DatacenterPathItemTwo)/$($script:constants.DatacenterName)"
            $script:resourceProperties.InventoryPath = "$($script:constants.InventoryPathItemOne)/$($script:constants.InventoryPathItemTwo)"

            $vCenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vCenterWithRootFolderScriptBlock))
            $rootFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:rootFolderViewBaseObjectScriptBlock))
            $datacenterPathItemOne = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemOneScriptBlock))
            $datacenterPathItemTwo = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemTwoScriptBlock))
            $datacenterFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterFolderScriptBlock))
            $datacenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterWithPathItemTwoAsParentScriptBlock))
            $hostFolderViewBaseObjectMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:hostFolderOfDatacenterViewBaseObjectScriptBlock))
            $hostFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:hostFolderScriptBlock))
            $locationsMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationsScriptBlock))
            $locationViewBaseObjectMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationViewBaseObjectScriptBlock))
            $locationParentMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationParentScriptBlock))

            Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $rootFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:rootFolder } -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $datacenterPathItemOne -ParameterFilter { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemOne } -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $datacenterPathItemTwo -ParameterFilter { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemTwo } -ModuleName $script:moduleName
            Mock -CommandName Get-Inventory -MockWith $datacenterFolderMock -ModuleName $script:moduleName
            Mock -CommandName Get-Datacenter -MockWith $datacenterMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $hostFolderViewBaseObjectMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder } -ModuleName $script:moduleName
            Mock -CommandName Get-Inventory -MockWith $hostFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder } -ModuleName $script:moduleName
            Mock -CommandName Get-Inventory -MockWith $locationsMock -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:constants.InventoryPathItemTwo -and $Location -eq $script:hostFolderLocation } -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $locationViewBaseObjectMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:location } -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $locationParentMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:locationParent } -ModuleName $script:moduleName

            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
        }

        AfterAll {
            $script:resourceProperties.Datacenter = [string]::Empty
            $script:resourceProperties.InventoryPath = [string]::Empty
        }

        Context 'Invoking with Ensure Present, non existing Cluster and no HA settings specified' {
            BeforeAll {
                # Arrange
                Mock -CommandName Get-Inventory -MockWith { return $null } -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.Name -and $Location.Id -eq $script:clusterLocation.Id } -ModuleName $script:moduleName
                Mock -CommandName New-Cluster -MockWith { return $null } -ModuleName $script:moduleName
            }

            It 'Should call the New-Cluster mock with the passed parameters once' {
                # Act
                { $resource.Set() } | Should -Not -Throw

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'New-Cluster'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.Name -and $Location.Id -eq $script:clusterLocation.Id -and !$Confirm }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Invoking with Ensure Present, non existing Cluster and HA settings specified' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.HAEnabled = $true
                $script:resourceProperties.HAAdmissionControlEnabled = $true
                $script:resourceProperties.HAFailoverLevel = 4
                $script:resourceProperties.HAIsolationResponse = 'DoNothing'
                $script:resourceProperties.HARestartPriority = 'High'

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

                Mock -CommandName Get-Inventory -MockWith { return $null } -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.Name -and $Location.Id -eq $script:clusterLocation.Id } -ModuleName $script:moduleName
                Mock -CommandName New-Cluster -MockWith { return $null } -ModuleName $script:moduleName
            }

            AfterAll {
                $script:resourceProperties.HAEnabled = $null
                $script:resourceProperties.HAAdmissionControlEnabled = $null
                $script:resourceProperties.HAFailoverLevel = $null
                $script:resourceProperties.HAIsolationResponse = 'Unset'
                $script:resourceProperties.HARestartPriority = 'Unset'
            }

            It 'Should call the New-Cluster mock with the passed parameters once' {
                # Act
                { $resource.Set() } | Should -Not -Throw

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'New-Cluster'
                    ParameterFilter = { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.Name -and $Location.Id -eq $script:clusterLocation.Id -and !$Confirm -and `
                    $HAEnabled -eq $true -and $HAAdmissionControlEnabled -eq $true -and $HAFailoverLevel -eq 4 -and $HAIsolationResponse -eq 'DoNothing' -and $HARestartPriority -eq 'High' }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Invoking with Ensure Present, existing Cluster and no HA settings specified' {
            BeforeAll {
                # Arrange
                $clusterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:clusterScriptBlock))

                Mock -CommandName Get-Inventory -MockWith $clusterMock -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.Name -and $Location.Id -eq $script:clusterLocation.Id } -ModuleName $script:moduleName
                Mock -CommandName Set-Cluster -MockWith { return $null } -ModuleName $script:moduleName
            }

            It 'Should call the Set-Cluster mock with the passed parameters once' {
                # Act
                { $resource.Set() } | Should -Not -Throw

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Set-Cluster'
                    ParameterFilter = { $Cluster.Id -eq $script:cluster.Id -and $Cluster.Name -eq $script:cluster.Name -and $Cluster.ParentId -eq $script:cluster.ParentId -and `
                                        $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.Name -and !$Confirm }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Invoking with Ensure Present, existing Cluster and HA settings specified' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.HAEnabled = $false
                $script:resourceProperties.HAAdmissionControlEnabled = $false
                $script:resourceProperties.HAFailoverLevel = 4
                $script:resourceProperties.HAIsolationResponse = 'DoNothing'
                $script:resourceProperties.HARestartPriority = 'High'

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

                $clusterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:clusterScriptBlock))

                Mock -CommandName Get-Inventory -MockWith $clusterMock -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.Name -and $Location.Id -eq $script:clusterLocation.Id } -ModuleName $script:moduleName
                Mock -CommandName Set-Cluster -MockWith { return $null } -ModuleName $script:moduleName
            }

            AfterAll {
                $script:resourceProperties.HAEnabled = $null
                $script:resourceProperties.HAAdmissionControlEnabled = $null
                $script:resourceProperties.HAFailoverLevel = $null
                $script:resourceProperties.HAIsolationResponse = 'Unset'
                $script:resourceProperties.HARestartPriority = 'Unset'
            }

            It 'Should call the Set-Cluster mock with the passed parameters once' {
                # Act
                { $resource.Set() } | Should -Not -Throw

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Set-Cluster'
                    ParameterFilter = { $Cluster.Id -eq $script:cluster.Id -and $Cluster.Name -eq $script:cluster.Name -and $Cluster.ParentId -eq $script:cluster.ParentId -and `
                                        $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.Name -and !$Confirm -and $HAEnabled -eq $false -and `
                                        $HAAdmissionControlEnabled -eq $false -and $HAFailoverLevel -eq 4 -and $HAIsolationResponse -eq 'DoNothing' -and $HARestartPriority -eq 'High' }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Invoking with Ensure Absent and existing Cluster' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Ensure = 'Absent'
                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

                $clusterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:clusterScriptBlock))

                Mock -CommandName Get-Inventory -MockWith $clusterMock -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.Name -and $Location.Id -eq $script:clusterLocation.Id } -ModuleName $script:moduleName
                Mock -CommandName Remove-Cluster -MockWith { return $null } -ModuleName $script:moduleName
            }

            AfterAll {
                $script:resourceProperties.Ensure = 'Present'
            }

            It 'Should call the Remove-Cluster mock with the passed parameters once' {
                # Act
                { $resource.Set() } | Should -Not -Throw

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Remove-Cluster'
                    ParameterFilter = { $Cluster.Id -eq $script:cluster.Id -and $Cluster.Name -eq $script:cluster.Name -and $Cluster.ParentId -eq $script:cluster.ParentId -and `
                                        $Server -eq $script:vCenter -and !$Confirm }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Invoking with Ensure Absent and non existing Cluster' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Ensure = 'Absent'
                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

                Mock -CommandName Get-Inventory -MockWith { return $null } -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.Name -and $Location.Id -eq $script:clusterLocation.Id } -ModuleName $script:moduleName
                Mock -CommandName Remove-Cluster -MockWith { return $null } -ModuleName $script:moduleName
            }

            AfterAll {
                $script:resourceProperties.Ensure = 'Present'
            }

            It 'Should not call the Remove-Cluster mock' {
                # Act
                { $resource.Set() } | Should -Not -Throw

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Remove-Cluster'
                    ParameterFilter = { $Cluster.Id -eq $script:cluster.Id -and $Cluster.Name -eq $script:cluster.Name -and $Cluster.ParentId -eq $script:cluster.ParentId -and `
                                        $Server -eq $script:vCenter -and !$Confirm }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 0
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }
    }

    Describe 'HACluster\Test' -Tag 'Test' {
        BeforeEach {
            # Arrange
            $script:resourceProperties.Datacenter = "$($script:constants.DatacenterPathItemOne)/$($script:constants.DatacenterPathItemTwo)/$($script:constants.DatacenterName)"
            $script:resourceProperties.InventoryPath = "$($script:constants.InventoryPathItemOne)/$($script:constants.InventoryPathItemTwo)"

            $vCenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vCenterWithRootFolderScriptBlock))
            $rootFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:rootFolderViewBaseObjectScriptBlock))
            $datacenterPathItemOne = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemOneScriptBlock))
            $datacenterPathItemTwo = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemTwoScriptBlock))
            $datacenterFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterFolderScriptBlock))
            $datacenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterWithPathItemTwoAsParentScriptBlock))
            $hostFolderViewBaseObjectMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:hostFolderOfDatacenterViewBaseObjectScriptBlock))
            $hostFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:hostFolderScriptBlock))
            $locationsMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationsScriptBlock))
            $locationViewBaseObjectMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationViewBaseObjectScriptBlock))
            $locationParentMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationParentScriptBlock))

            Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $rootFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:rootFolder } -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $datacenterPathItemOne -ParameterFilter { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemOne } -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $datacenterPathItemTwo -ParameterFilter { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemTwo } -ModuleName $script:moduleName
            Mock -CommandName Get-Inventory -MockWith $datacenterFolderMock -ModuleName $script:moduleName
            Mock -CommandName Get-Datacenter -MockWith $datacenterMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $hostFolderViewBaseObjectMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder } -ModuleName $script:moduleName
            Mock -CommandName Get-Inventory -MockWith $hostFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder } -ModuleName $script:moduleName
            Mock -CommandName Get-Inventory -MockWith $locationsMock -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:constants.InventoryPathItemTwo -and $Location -eq $script:hostFolderLocation } -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $locationViewBaseObjectMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:location } -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $locationParentMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:locationParent } -ModuleName $script:moduleName

            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
        }

        AfterAll {
            $script:resourceProperties.Datacenter = [string]::Empty
            $script:resourceProperties.InventoryPath = [string]::Empty
        }

        Context 'Invoking with Ensure Present and non existing Cluster' {
            BeforeAll {
                # Arrange
                Mock -CommandName Get-Inventory -MockWith { return $null } -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.Name -and $Location.Id -eq $script:clusterLocation.Id } -ModuleName $script:moduleName
            }

            It 'Should return $false' {
                # Act
                { $resource.Test() } | Should -Not -Throw

                # Assert
                $resource.Test() | Should -Be $false
            }
        }

        Context 'Invoking with Ensure Present, existing Cluster and matching settings' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.HAEnabled = $true
                $script:resourceProperties.HAAdmissionControlEnabled = $true
                $script:resourceProperties.HAFailoverLevel = 4
                $script:resourceProperties.HAIsolationResponse = 'DoNothing'
                $script:resourceProperties.HARestartPriority = 'High'

                $clusterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:clusterScriptBlock))
                Mock -CommandName Get-Inventory -MockWith $clusterMock -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.Name -and $Location.Id -eq $script:clusterLocation.Id } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.HAEnabled = $null
                $script:resourceProperties.HAAdmissionControlEnabled = $null
                $script:resourceProperties.HAFailoverLevel = $null
                $script:resourceProperties.HAIsolationResponse = 'Unset'
                $script:resourceProperties.HARestartPriority = 'Unset'
            }

            It 'Should return $true' {
                # Act
                { $resource.Test() } | Should -Not -Throw

                # Assert
                $resource.Test() | Should -Be $true
            }
        }

        Context 'Invoking with Ensure Present, existing Cluster and non matching settings' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.HAEnabled = $true
                $script:resourceProperties.HAAdmissionControlEnabled = $true
                $script:resourceProperties.HAFailoverLevel = 3
                $script:resourceProperties.HAIsolationResponse = 'DoNothing'
                $script:resourceProperties.HARestartPriority = 'High'

                $clusterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:clusterScriptBlock))
                Mock -CommandName Get-Inventory -MockWith $clusterMock -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.Name -and $Location.Id -eq $script:clusterLocation.Id } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.HAEnabled = $null
                $script:resourceProperties.HAAdmissionControlEnabled = $null
                $script:resourceProperties.HAFailoverLevel = $null
                $script:resourceProperties.HAIsolationResponse = 'Unset'
                $script:resourceProperties.HARestartPriority = 'Unset'
            }

            It 'Should return $false' {
                # Act
                { $resource.Test() } | Should -Not -Throw

                # Assert
                $resource.Test() | Should -Be $false
            }
        }

        Context 'Invoking with Ensure Absent and non existing Cluster' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Ensure = 'Absent'
                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

                Mock -CommandName Get-Inventory -MockWith { return $null } -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.Name -and $Location.Id -eq $script:clusterLocation.Id } -ModuleName $script:moduleName
            }

            AfterAll {
                $script:resourceProperties.Ensure = 'Present'
            }

            It 'Should return $true' {
                # Act
                { $resource.Test() } | Should -Not -Throw

                # Assert
                $resource.Test() | Should -Be $true
            }
        }

        Context 'Invoking with Ensure Absent and existing Cluster' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Ensure = 'Absent'
                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

                $clusterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:clusterScriptBlock))
                Mock -CommandName Get-Inventory -MockWith $clusterMock -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.Name -and $Location.Id -eq $script:clusterLocation.Id } -ModuleName $script:moduleName
            }

            AfterAll {
                $script:resourceProperties.Ensure = 'Present'
            }

            It 'Should return $false' {
                # Act
                { $resource.Test() } | Should -Not -Throw

                # Assert
                $resource.Test() | Should -Be $false
            }
        }
    }

    Describe 'HACluster\Get' -Tag 'Get' {
        BeforeEach {
            # Arrange
            $script:resourceProperties.Datacenter = "$($script:constants.DatacenterPathItemOne)/$($script:constants.DatacenterPathItemTwo)/$($script:constants.DatacenterName)"
            $script:resourceProperties.InventoryPath = "$($script:constants.InventoryPathItemOne)/$($script:constants.InventoryPathItemTwo)"
            $script:resourceProperties.HAEnabled = $true
            $script:resourceProperties.HAAdmissionControlEnabled = $true
            $script:resourceProperties.HAFailoverLevel = 4
            $script:resourceProperties.HAIsolationResponse = 'DoNothing'
            $script:resourceProperties.HARestartPriority = 'High'

            $vCenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vCenterWithRootFolderScriptBlock))
            $rootFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:rootFolderViewBaseObjectScriptBlock))
            $datacenterPathItemOne = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemOneScriptBlock))
            $datacenterPathItemTwo = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterPathItemTwoScriptBlock))
            $datacenterFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterFolderScriptBlock))
            $datacenterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:datacenterWithPathItemTwoAsParentScriptBlock))
            $hostFolderViewBaseObjectMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:hostFolderOfDatacenterViewBaseObjectScriptBlock))
            $hostFolderMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:hostFolderScriptBlock))
            $locationsMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationsScriptBlock))
            $locationViewBaseObjectMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationViewBaseObjectScriptBlock))
            $locationParentMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:locationParentScriptBlock))

            Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $rootFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:rootFolder } -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $datacenterPathItemOne -ParameterFilter { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemOne } -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $datacenterPathItemTwo -ParameterFilter { $Server -eq $script:vCenter -and $Id -Contains $script:datacenterPathItemTwo } -ModuleName $script:moduleName
            Mock -CommandName Get-Inventory -MockWith $datacenterFolderMock -ModuleName $script:moduleName
            Mock -CommandName Get-Datacenter -MockWith $datacenterMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $hostFolderViewBaseObjectMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder } -ModuleName $script:moduleName
            Mock -CommandName Get-Inventory -MockWith $hostFolderMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:hostFolder } -ModuleName $script:moduleName
            Mock -CommandName Get-Inventory -MockWith $locationsMock -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:constants.InventoryPathItemTwo -and $Location -eq $script:hostFolderLocation } -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $locationViewBaseObjectMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:location } -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $locationParentMock -ParameterFilter { $Server -eq $script:vCenter -and $Id -eq $script:locationParent } -ModuleName $script:moduleName

            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
        }

        AfterAll {
            $script:resourceProperties.Datacenter = [string]::Empty
            $script:resourceProperties.InventoryPath = [string]::Empty
            $script:resourceProperties.HAEnabled = $null
            $script:resourceProperties.HAAdmissionControlEnabled = $null
            $script:resourceProperties.HAFailoverLevel = $null
            $script:resourceProperties.HAIsolationResponse = 'Unset'
            $script:resourceProperties.HARestartPriority = 'Unset'
        }

        Context 'Invoking with Ensure Present and non existing Cluster' {
            BeforeAll {
                # Arrange
                Mock -CommandName Get-Inventory -MockWith { return $null } -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.Name -and $Location.Id -eq $script:clusterLocation.Id } -ModuleName $script:moduleName
            }

            It 'Should retrieve the correct settings from the server' {
                # Act
                { $resource.Get() } | Should -Not -Throw

                $result = $resource.Get()

                # Assert
                $result.Server | Should -Be $script:resourceProperties.Server
                $result.InventoryPath | Should -Be $script:resourceProperties.InventoryPath
                $result.Datacenter | Should -Be $script:resourceProperties.Datacenter
                $result.Name | Should -Be $script:resourceProperties.Name
                $result.Ensure | Should -Be 'Absent'
                $result.HAEnabled | Should -Be $script:resourceProperties.HAEnabled
                $result.HAAdmissionControlEnabled | Should -Be $script:resourceProperties.HAAdmissionControlEnabled
                $result.HAFailoverLevel | Should -Be $script:resourceProperties.HAFailoverLevel
                $result.HAIsolationResponse | Should -Be $script:resourceProperties.HAIsolationResponse
                $result.HARestartPriority | Should -Be $script:resourceProperties.HARestartPriority
            }
        }

        Context 'Invoking with Ensure Present and existing Cluster' {
            BeforeAll {
                # Arrange
                $clusterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:clusterScriptBlock))

                Mock -CommandName Get-Inventory -MockWith $clusterMock -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.Name -and $Location.Id -eq $script:clusterLocation.Id } -ModuleName $script:moduleName
            }

            It 'Should retrieve the correct settings from the server' {
                # Act
                { $resource.Get() } | Should -Not -Throw

                $result = $resource.Get()

                # Assert
                $result.Server | Should -Be $script:resourceProperties.Server
                $result.InventoryPath | Should -Be $script:resourceProperties.InventoryPath
                $result.Datacenter | Should -Be $script:resourceProperties.Datacenter
                $result.Name | Should -Be $script:cluster.Name
                $result.Ensure | Should -Be 'Present'
                $result.HAEnabled | Should -Be $script:cluster.HAEnabled
                $result.HAAdmissionControlEnabled | Should -Be $script:cluster.HAAdmissionControlEnabled
                $result.HAFailoverLevel | Should -Be $script:cluster.HAFailoverLevel
                $result.HAIsolationResponse | Should -Be $script:cluster.HAIsolationResponse
                $result.HARestartPriority | Should -Be $script:cluster.HARestartPriority
            }
        }

        Context 'Invoking with Ensure Absent and non existing Cluster' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Ensure = 'Absent'
                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

                Mock -CommandName Get-Inventory -MockWith { return $null } -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.Name -and $Location.Id -eq $script:clusterLocation.Id } -ModuleName $script:moduleName
            }

            AfterAll {
                $script:resourceProperties.Ensure = 'Present'
            }

            It 'Should retrieve the correct settings from the server' {
                # Act
                { $resource.Get() } | Should -Not -Throw

                $result = $resource.Get()

                # Assert
                $result.Server | Should -Be $script:resourceProperties.Server
                $result.InventoryPath | Should -Be $script:resourceProperties.InventoryPath
                $result.Datacenter | Should -Be $script:resourceProperties.Datacenter
                $result.Name | Should -Be $script:resourceProperties.Name
                $result.Ensure | Should -Be 'Absent'
                $result.HAEnabled | Should -Be $script:resourceProperties.HAEnabled
                $result.HAAdmissionControlEnabled | Should -Be $script:resourceProperties.HAAdmissionControlEnabled
                $result.HAFailoverLevel | Should -Be $script:resourceProperties.HAFailoverLevel
                $result.HAIsolationResponse | Should -Be $script:resourceProperties.HAIsolationResponse
                $result.HARestartPriority | Should -Be $script:resourceProperties.HARestartPriority
            }
        }

        Context 'Invoking with Ensure Absent and existing Cluster' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Ensure = 'Absent'
                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

                $clusterMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:clusterScriptBlock))
                Mock -CommandName Get-Inventory -MockWith $clusterMock -ParameterFilter { $Server -eq $script:vCenter -and $Name -eq $script:resourceProperties.Name -and $Location.Id -eq $script:clusterLocation.Id } -ModuleName $script:moduleName
            }

            AfterAll {
                $script:resourceProperties.Ensure = 'Present'
            }

            It 'Should retrieve the correct settings from the server' {
                # Act
                { $resource.Get() } | Should -Not -Throw

                $result = $resource.Get()

                # Assert
                $result.Server | Should -Be $script:resourceProperties.Server
                $result.InventoryPath | Should -Be $script:resourceProperties.InventoryPath
                $result.Datacenter | Should -Be $script:resourceProperties.Datacenter
                $result.Name | Should -Be $script:cluster.Name
                $result.Ensure | Should -Be 'Present'
                $result.HAEnabled | Should -Be $script:cluster.HAEnabled
                $result.HAAdmissionControlEnabled | Should -Be $script:cluster.HAAdmissionControlEnabled
                $result.HAFailoverLevel | Should -Be $script:cluster.HAFailoverLevel
                $result.HAIsolationResponse | Should -Be $script:cluster.HAIsolationResponse
                $result.HARestartPriority | Should -Be $script:cluster.HARestartPriority
            }
        }
    }
}
finally {
    # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
    Invoke-TestCleanup
}
