<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

$script:constants = @{
    VIServerName = 'TestServer'
    VIServerUser = 'TestUser'
    VIServerPassword = 'TestPassword' | ConvertTo-SecureString -AsPlainText -Force
    InventoryItemName = 'TestInventoryItem'
    FolderType = 'Folder'
    RootFolderValue = 'group-d1'
    InventoryRootFolderId = 'Folder-group-d1'
    InventoryRootFolderName = 'Datacenters'
    DatacenterLocationItemOneId = 'my-datacenter-folder-one-id'
    DatacenterLocationItemOne = 'MyDatacenterFolderOne'
    DatacenterLocationItemTwoId = 'my-datacenter-folder-two-id'
    DatacenterLocationItemTwo = 'MyDatacenterFolderTwo'
    DatacenterLocationItemThree = 'MyDatacenterFolderThree'
}

$script:credential = New-Object System.Management.Automation.PSCredential($script:constants.VIServerUser, $script:constants.VIServerPassword)

$script:viServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{
    Name = $script:constants.VIServerName
    User = $script:constants.VIServerUser
    ExtensionData = [VMware.Vim.ServiceInstance] @{
        Content = [VMware.Vim.ServiceContent] @{
            RootFolder = [VMware.Vim.ManagedObjectReference] @{
                Type = $script:constants.FolderType
                Value = $script:constants.RootFolderValue
            }
        }
    }
}

$script:rootFolderViewBaseObject = [VMware.Vim.Folder] @{
    Name = $script:constants.InventoryRootFolderName
    MoRef = [VMware.Vim.ManagedObjectReference] @{
        Type = $script:constants.FolderType
        Value = $script:constants.RootFolderValue
    }
    ChildEntity = @(
        [VMware.Vim.ManagedObjectReference] @{
            Type = $script:constants.FolderType
            Value = $script:constants.DatacenterLocationItemOne
        }
    )
}

$script:inventoryRootFolder = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
    Id = $script:constants.InventoryRootFolderId
    Name = $script:constants.InventoryRootFolderName
    ExtensionData = [VMware.Vim.Folder] @{
        ChildEntity = @(
            [VMware.Vim.ManagedObjectReference] @{
                Type = $script:constants.FolderType
                Value = $script:constants.DatacenterLocationItemOne
            }
        )
    }
}

$script:datacenterLocationItemOne = [VMware.Vim.Folder] @{
    Name = $script:constants.DatacenterLocationItemOne
    ChildEntity = @(
        [VMware.Vim.ManagedObjectReference] @{
            Type = $script:constants.FolderType
            Value = $script:constants.DatacenterLocationItemTwo
        }
    )
}

$script:datacenterLocationItemTwo = [VMware.Vim.Folder] @{
    Name = $script:constants.DatacenterLocationItemTwo
    ChildEntity = @(
        [VMware.Vim.ManagedObjectReference] @{
            Type = $script:constants.FolderType
            Value = $script:constants.DatacenterLocationItemThree
        }
    )
    MoRef = [VMware.Vim.ManagedObjectReference] @{
        Type = $script:constants.FolderType
        Value = $script:constants.DatacenterLocationItemTwoId
    }
}

$script:datacenterLocationItemThree = [VMware.Vim.Folder] @{
    Name = $script:constants.DatacenterLocationItemThree
}

$script:locationDatacenterLocationItemOne = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
    Id = $script:constants.DatacenterLocationItemOneId
    Name = $script:constants.DatacenterLocationItemOne
    ParentId = $script:constants.InventoryRootFolderId
}

$script:locationDatacenterLocationItemTwo = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
    Id = $script:constants.DatacenterLocationItemTwoId
    Name = $script:constants.DatacenterLocationItemTwo
    ParentId = $script:constants.DatacenterLocationItemOneId
}
