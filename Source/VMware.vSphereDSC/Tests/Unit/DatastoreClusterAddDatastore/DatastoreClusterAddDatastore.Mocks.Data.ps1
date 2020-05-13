<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

$script:Constants = @{
    VIServer = '10.23.112.235'
    VIServerUser = 'Admin1'
    VIServerPassword = 'Password1' | ConvertTo-SecureString -AsPlainText -Force
    FolderType = 'Folder'
    RootFolderValue = 'group-d1'
    InventoryRootFolderId = 'Folder-group-d1'
    InventoryRootFolderName = 'DscDatacenters'
    DatacenterId = 'dsc-datacenter-inventory-root-folder-parent-id'
    DatacenterName = 'DscDatacenter'
    DatacenterDatastoreFolderId = 'group-s5'
    DatacenterDatastoreFolderName = 'DscDatacenterDatastoreFolder'
    DatastoreClusterId = 'StoragePod-group-p23'
    DatastoreClusterName = 'DscDatastoreCluster'
    DatastoreOneId = 'Datastore-datastore-11'
    DatastoreOneName = 'DscDatastoreOne'
    DatastoreTwoId = 'Datastore-datastore-12'
    DatastoreTwoName = 'DscDatastoreTwo'
    DatastoreThreeId = 'Datastore-datastore-13'
    DatastoreThreeName = 'DscDatastoreThree'
    DatastoreNames = @('DscDatastoreOne', 'DscDatastoreTwo')
}

$script:Credential = New-Object System.Management.Automation.PSCredential($script:Constants.VIServerUser, $script:Constants.VIServerPassword)

$script:VIServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{
    Name = $script:Constants.VIServer
    User = $script:Constants.VIServerUser
    ExtensionData = [VMware.Vim.ServiceInstance] @{
        Content = [VMware.Vim.ServiceContent] @{
            RootFolder = [VMware.Vim.ManagedObjectReference] @{
                Type = $script:Constants.FolderType
                Value = $script:Constants.RootFolderValue
            }
        }
    }
}

$script:InventoryRootFolder = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
    Id = $script:Constants.InventoryRootFolderId
    Name = $script:Constants.InventoryRootFolderName
}

$script:Datacenter = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.DatacenterImpl] @{
    Id = $script:Constants.DatacenterId
    Name = $script:Constants.DatacenterName
    ParentFolderId = $script:Constants.InventoryRootFolderId
    ExtensionData = [VMware.Vim.Datacenter] @{
        DatastoreFolder = [VMware.Vim.ManagedObjectReference] @{
            Type = $script:Constants.FolderType
            Value = $script:Constants.DatacenterDatastoreFolderId
        }
    }
}

$script:DatacenterDatastoreFolder = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
    Id = $script:Constants.DatacenterDatastoreFolderId
    Name = $script:Constants.DatacenterDatastoreFolderName
    ExtensionData = [VMware.Vim.Folder] @{
        MoRef = [VMware.Vim.ManagedObjectReference] @{
            Type = $script:Constants.FolderType
            Value = $script:Constants.DatacenterDatastoreFolderId
        }
    }
}

$script:DatastoreCluster = [VMware.VimAutomation.ViCore.Impl.V1.DatastoreManagement.DatastoreClusterImpl] @{
    Id = $script:Constants.DatastoreClusterId
    Name = $script:Constants.DatastoreClusterName
    ExtensionData = [VMware.Vim.StoragePod] @{
        Parent = [VMware.Vim.ManagedObjectReference] @{
            Type = $script:Constants.FolderType
            Value = $script:Constants.DatacenterDatastoreFolderId
        }
    }
}

$script:DatastoreOne = [VMware.VimAutomation.ViCore.Impl.V1.DatastoreManagement.VmfsDatastoreImpl] @{
    Id = $script:Constants.DatastoreOneId
    Name = $script:Constants.DatastoreOneName
    ParentFolderId = $script:Constants.DatacenterDatastoreFolderId
}

$script:DatastoreTwo = [VMware.VimAutomation.ViCore.Impl.V1.DatastoreManagement.VmfsDatastoreImpl] @{
    Id = $script:Constants.DatastoreTwoId
    Name = $script:Constants.DatastoreTwoName
    ParentFolderId = $script:Constants.DatacenterDatastoreFolderId
}

$script:DatastoreThree = [VMware.VimAutomation.ViCore.Impl.V1.DatastoreManagement.VmfsDatastoreImpl] @{
    Id = $script:Constants.DatastoreThreeId
    Name = $script:Constants.DatastoreThreeName
    ParentFolderId = $script:Constants.DatastoreClusterId
}

$script:Datastores = [VMware.VimAutomation.ViCore.Impl.V1.DatastoreManagement.VmfsDatastoreImpl[]] @(
    $script:DatastoreOne,
    $script:DatastoreTwo
)
