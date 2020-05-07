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
    DrsRuleName = 'DscDRSRule'
    DatacenterId = 'dsc-datacenter-inventory-root-folder-parent-id'
    DatacenterName = 'DscDatacenter'
    DatacenterHostFolderId = 'group-h4'
    DatacenterHostFolderName = 'DscDatacenterHostFolder'
    ClusterId = 'ClusterComputeResource-domain-c29'
    ClusterName = 'DscCluster'
    VirtualMachineOneId = 'VirtualMachine-vm-27'
    VirtualMachineOneName = 'DscVMOne'
    VirtualMachineTwoId = 'VirtualMachine-vm-28'
    VirtualMachineTwoName = 'DscVMTwo'
    VirtualMachineIds = @('VirtualMachine-vm-27', 'VirtualMachine-vm-28')
    VirtualMachineNames = @('DscVMOne', 'DscVMTwo')
    DrsRuleType = 'VMAffinity'
    DrsRuleEnabled = $true
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
        HostFolder = [VMware.Vim.ManagedObjectReference] @{
            Type = $script:Constants.FolderType
            Value = $script:Constants.DatacenterHostFolderId
        }
    }
}

$script:DatacenterHostFolder = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
    Id = $script:Constants.DatacenterHostFolderId
    Name = $script:Constants.DatacenterHostFolderName
    ExtensionData = [VMware.Vim.Folder] @{
        MoRef = [VMware.Vim.ManagedObjectReference] @{
            Type = $script:Constants.FolderType
            Value = $script:Constants.DatacenterHostFolderId
        }
    }
}

$script:Cluster = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.ClusterImpl] @{
    Id = $script:Constants.ClusterId
    Name = $script:Constants.ClusterName
    ParentId = $script:Constants.DatacenterHostFolderId
}

$script:VirtualMachineOne = [VMware.VimAutomation.ViCore.Impl.V1.VM.UniversalVirtualMachineImpl] @{
    Id = $script:Constants.VirtualMachineOneId
    Name = $script:Constants.VirtualMachineOneName
}

$script:VirtualMachineTwo = [VMware.VimAutomation.ViCore.Impl.V1.VM.UniversalVirtualMachineImpl] @{
    Id = $script:Constants.VirtualMachineTwoId
    Name = $script:Constants.VirtualMachineTwoName
}

$script:VirtualMachines = [VMware.VimAutomation.ViCore.Impl.V1.VM.UniversalVirtualMachineImpl[]] @(
    $script:VirtualMachineOne,
    $script:VirtualMachineTwo
)

$script:DrsRule = [VMware.VimAutomation.ViCore.Impl.V1.Cluster.DrsVMAffinityRuleImpl] @{
    Name = $script:Constants.DrsRuleName
    Type = $script:Constants.DrsRuleType
    Cluster = $script:Cluster
    VMIds = $script:Constants.VirtualMachineIds
    Enabled = $script:Constants.DrsRuleEnabled
}
