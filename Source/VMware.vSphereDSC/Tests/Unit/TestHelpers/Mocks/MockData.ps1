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
    vCenterProductId = 'vpx'
    ESXiProductId = 'embeddedEsx'
    InventoryItemName = 'TestInventoryItem'
    FolderType = 'Folder'
    DatacenterType = 'Datacenter'
    ResourcePoolType = 'Resource Pool'
    RootFolderValue = 'group-d1'
    InventoryRootFolderId = 'Folder-group-d1'
    InventoryRootFolderName = 'Datacenters'
    DatacenterLocationItemOneId = 'my-datacenter-folder-one-id'
    DatacenterLocationItemOne = 'MyDatacenterFolderOne'
    DatacenterLocationItemTwoId = 'my-datacenter-folder-two-id'
    DatacenterLocationItemTwo = 'MyDatacenterFolderTwo'
    DatacenterLocationItemThree = 'MyDatacenterFolderThree'
    DatacenterId = 'my-datacenter-inventory-root-folder-parent-id'
    DatacenterName = 'MyDatacenter'
    DatacenterHostFolderId = 'group-h4'
    DatacenterHostFolderName = 'HostFolder'
    InventoryItemLocationItemOneId = 'my-inventory-item-location-item-one'
    InventoryItemLocationItemOne = 'MyInventoryItemOne'
    InventoryItemLocationItemTwoId = 'my-inventory-item-location-item-two'
    InventoryItemLocationItemTwo = 'MyInventoryItemTwo'
    ResourcePoolId = 'my-resource-pool-id'
    ResourcePoolName = 'MyResourcePool'
    ClusterId = 'my-cluster-id'
    ClusterName = 'MyCluster'
    HAEnabled = $true
    HAAdmissionControlEnabled = $true
    HAFailoverLevel = 4
    HAIsolationResponse = 'DoNothing'
    HARestartPriority = 'High'
    DrsEnabled = $true
    DrsAutomationLevel = 'FullyAutomated'
    DrsMigrationThreshold = 5
    DrsDistribution = 0
    MemoryLoadBalancing = 100
    CPUOverCommitment = 500
    FolderId = 'my-folder-id'
    FolderName = 'MyFolder'
    DatacenterFolderId = 'my-datacenter-folder-id'
    DatacenterFolderName = 'MyDatacenterFolder'
    VMHostId = 'HostSystem-host-1'
    VMHostName = 'MyVMHost'
    VMHostConnectionState = 'Maintenance'
    OptionManagerType = 'OptionManager'
    OptionManagerValue = 'EsxHostAdvSettings-1'
    BufferCacheFlushIntervalAdvancedSettingName = 'BufferCache.FlushInterval'
    BufferCacheFlushIntervalAdvancedSettingValue = 30000
    BufferCacheHardMaxDirtyAdvancedSettingName = 'BufferCache.HardMaxDirty'
    BufferCacheHardMaxDirtyAdvancedSettingValue = 95
    CBRCEnableAdvancedSettingName = 'CBRC.Enable'
    CBRCEnableAdvancedSettingValue = $false
    VpxVpxaConfigWorkingDirAdvancedSettingName = 'Vpx.Vpxa.config.workingDir'
    VpxVpxaConfigWorkingDirAdvancedSettingValue = '/var/log/vmware'
    EsxAgentHostManagerType = 'HostEsxAgentHostManager'
    EsxAgentHostManagerValue = 'esxAgentHostManager-1'
    DatastoreName = 'MyDatastore'
    DatastoreType = 'Datastore'
    DatastoreValue = 'datastore-1'
    NetworkName = 'MyNetwork'
    NetworkType = 'Network'
    NetworkValue = 'network-1'
    PciDeviceId = '0000:00:00.0'
    PciDeviceEnabled = $true
    PciPassthruSystemType = 'HostPciPassthruSystem'
    PciPassthruSystemValue = 'pciPassthruSystem-1'
    PciDeviceCapable = $false
    GraphicsManagerType = 'HostGraphicsManager'
    GraphicsManagerValue = 'graphicsManager-1'
    DefaultGraphicsType = 'Shared'
    SharedPassthruAssignmentPolicy = 'Performance'
    GraphicsDeviceId = '0000:00:00.0'
    PowerSystemType = 'HostPowerSystem'
    PowerSystemValue = 'powerSystem-1'
    PowerPolicy = @{
        HighPerformance = 1
        Balanced = 2
        LowPower = 3
        Custom = 4
    }
    CacheConfigurationManagerType = 'HostCacheConfigurationManager'
    CacheConfigurationManagerValue = 'cacheConfigManager-1'
    NegativeSwapSize = -1
    OverflowingSwapSize = 9
    SwapSizeMB = 1024
    SwapSizeGB = 1
    ConfigureHostCacheTaskName = 'ConfigureHostCache_Task'
    TaskType = 'Task'
    TaskValue = 'task-1'
    TaskSuccessState = 'Success'
    TaskErrorState = 'Error'
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
    ProductLine = $script:constants.vCenterProductId
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
            },
            [VMware.Vim.ManagedObjectReference] @{
                Type = $script:constants.DatacenterType
                Value = $script:constants.DatacenterName
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

$script:datacenterChildEntity = [VMware.Vim.Datacenter] @{
    Name = $script:constants.DatacenterName
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

$script:datacenterWithInventoryRootFolderAsParent = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.DatacenterImpl] @{
    Id = $script:constants.DatacenterId
    Name = $script:constants.DatacenterName
    ParentFolderId = $script:constants.InventoryRootFolderId
}

$script:datacenterWithDatacenterLocationItemOneAsParent = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.DatacenterImpl] @{
    Id = $script:constants.DatacenterId
    Name = $script:constants.DatacenterName
    ParentFolderId = $script:constants.DatacenterLocationItemOneId
    ExtensionData = [VMware.Vim.Datacenter] @{
        HostFolder = [VMware.Vim.ManagedObjectReference] @{
            Type = $script:constants.FolderType
            Value = $script:constants.DatacenterHostFolderId
        }
    }
}

$script:datacenterWithDatacenterLocationItemTwoAsParent = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.DatacenterImpl] @{
    Id = $script:constants.DatacenterId
    Name = $script:constants.DatacenterName
    ParentFolderId = $script:constants.DatacenterLocationItemTwoId
}

$script:datacenterHostFolderViewBaseObject = [VMware.Vim.Folder] @{
    Name = $script:constants.DatacenterHostFolderName
    MoRef = [VMware.Vim.ManagedObjectReference] @{
        Type = $script:constants.FolderType
        Value = $script:constants.DatacenterHostFolderId
    }
}

$script:datacenterHostFolder = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
    Id = $script:constants.DatacenterHostFolderId
    Name = $script:constants.DatacenterHostFolderName
    Parent = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.DatacenterImpl] @{
        Name = $script:constants.DatacenterName
    }
}

$script:inventoryItemLocationItemOne = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
    Id = $script:constants.InventoryItemLocationItemOneId
    Name = $script:constants.InventoryItemLocationItemOne
    ParentId = $script:constants.DatacenterHostFolderId
}

$script:foundLocations = @(
    [VMware.VimAutomation.ViCore.Impl.V1.Inventory.ResourcePoolImpl] @{
        Id = $script:constants.InventoryItemLocationItemTwoId
        Name = $script:constants.InventoryItemLocationItemTwo
        Parent = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
            Id = $script:constants.InventoryItemLocationItemOneId
            Name = $script:constants.InventoryItemLocationItemOne
        }
    }
)

$script:foundLocationsForCluster = @(
    [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
        Id = $script:constants.InventoryItemLocationItemTwoId
        Name = $script:constants.InventoryItemLocationItemTwo
        Parent = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
            Id = $script:constants.InventoryItemLocationItemOneId
            Name = $script:constants.InventoryItemLocationItemOne
        }
        ExtensionData = [VMware.Vim.Folder] @{
            Name = $script:constants.InventoryItemLocationItemTwo
            MoRef = [VMware.Vim.ManagedObjectReference] @{
                Type = $script:constants.FolderType
                Value = $script:constants.InventoryItemLocationItemTwoId
            }
        }
    }
)

$script:inventoryItemLocationViewBaseObject = [VMware.Vim.ResourcePool] @{
    Name = $script:constants.InventoryItemLocationItemTwo
    Parent = [VMware.Vim.ManagedObjectReference] @{
        Type = $script:constants.ResourcePoolType
        Value = $script:constants.InventoryItemLocationItemOneId
    }
}

$script:inventoryItemLocationWithDatacenterHostFolderAsParent = [VMware.Vim.Folder] @{
    Name = $script:constants.DatacenterHostFolderName
    Parent = [VMware.Vim.ManagedObjectReference] @{
        Type = $script:constants.FolderType
        Value = $script:constants.DatacenterHostFolderId
    }
}

$script:inventoryItemLocationWithInventoryItemLocationItemOneAsParent = [VMware.Vim.Folder] @{
    Name = $script:constants.InventoryItemLocationItemOne
    Parent = [VMware.Vim.ManagedObjectReference] @{
        Type = $script:constants.FolderType
        Value = $script:constants.InventoryItemLocationItemOneId
    }
}

$script:inventoryItemWithInventoryItemLocationItemTwoAsParent = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.ResourcePoolImpl] @{
    Id = $script:constants.ResourcePoolId
    Name = $script:constants.ResourcePoolName
    ParentId = $script:constants.InventoryItemLocationItemTwoId
}

$script:cluster = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.ClusterImpl] @{
    Id = $script:constants.ClusterId
    Name = $script:constants.ClusterName
    ParentId = $script:constants.InventoryItemLocationItemTwoId
    HAEnabled = $script:constants.HAEnabled
    HAAdmissionControlEnabled = $script:constants.HAAdmissionControlEnabled
    HAFailoverLevel = $script:constants.HAFailoverLevel
    HAIsolationResponse = $script:constants.HAIsolationResponse
    HARestartPriority = $script:constants.HARestartPriority
    ExtensionData = [VMware.Vim.ClusterComputeResource] @{
        ConfigurationEx = [VMware.Vim.ClusterConfigInfoEx] @{
            DrsConfig = [VMware.Vim.ClusterDrsConfigInfo] @{
                Enabled = $true
                DefaultVmBehavior = 'Manual'
                VmotionRate = 3
                Option = @(
                    [VMware.Vim.OptionValue] @{
                        Key = 'LimitVMsPerESXHostPercent'
                        Value = '10'
                    },
                    [VMware.Vim.OptionValue] @{
                        Key = 'PercentIdleMBInMemDemand'
                        Value = '200'
                    },
                    [VMware.Vim.OptionValue] @{
                        Key = 'MaxVcpusPerClusterPct'
                        Value = '400'
                    }
                )
            }
        }
    }
}

$script:clusterSpecWithoutDrsSettings = [VMware.Vim.ClusterConfigSpecEx] @{
    DrsConfig = [VMware.Vim.ClusterDrsConfigInfo] @{
        Option = @(
        )
    }
}

$script:clusterSpecWithDrsSettings = [VMware.Vim.ClusterConfigSpecEx] @{
    DrsConfig = [VMware.Vim.ClusterDrsConfigInfo] @{
        Enabled = $script:constants.DrsEnabled
        DefaultVmBehavior = $script:constants.DrsAutomationLevel
        VmotionRate = $script:constants.DrsMigrationThreshold
        Option = @(
            [VMware.Vim.OptionValue] @{
                Key = 'LimitVMsPerESXHostPercent'
                Value = ($script:constants.DrsDistribution).ToString()
            },
            [VMware.Vim.OptionValue] @{
                Key = 'PercentIdleMBInMemDemand'
                Value = ($script:constants.MemoryLoadBalancing).ToString()
            },
            [VMware.Vim.OptionValue] @{
                Key = 'MaxVcpusPerClusterPct'
                Value = ($script:constants.CPUOverCommitment).ToString()
            }
        )
    }
}

$script:clusterComputeResource = [VMware.Vim.ClusterComputeResource] @{
    ConfigurationEx = [VMware.Vim.ClusterConfigInfoEx] @{
        DrsConfig = [VMware.Vim.ClusterDrsConfigInfo] @{
            Enabled = $true
            DefaultVmBehavior = 'Manual'
            VmotionRate = 3
            Option = @(
                [VMware.Vim.OptionValue] @{
                    Key = 'LimitVMsPerESXHostPercent'
                    Value = '10'
                },
                [VMware.Vim.OptionValue] @{
                    Key = 'PercentIdleMBInMemDemand'
                    Value = '200'
                },
                [VMware.Vim.OptionValue] @{
                    Key = 'MaxVcpusPerClusterPct'
                    Value = '400'
                }
            )
        }
    }
}

$script:folder = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
    Id = $script:constants.FolderId
    Name = $script:constants.FolderName
    ParentId = $script:constants.InventoryItemLocationItemTwoId
}

$script:datacenterFolder = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
    Id = $script:constants.DatacenterFolderId
    Name = $script:constants.DatacenterFolderName
    ParentId = $script:constants.DatacenterLocationItemTwoId
}

$script:vmHost = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{
    Id = $script:constants.VMHostId
    Name = $script:constants.VMHostName
    ConnectionState = $script:constants.VMHostConnectionState
    ExtensionData = [VMware.Vim.HostSystem] @{
        Config = [VMware.Vim.HostConfigInfo] @{
            PowerSystemInfo = [VMware.Vim.PowerSystemInfo] @{
                CurrentPolicy = [VMware.Vim.HostPowerPolicy] @{
                    Key = $script:constants.PowerPolicy.Balanced
                }
            }
        }
        ConfigManager = [VMware.Vim.HostConfigManager] @{
            AdvancedOption = [VMware.Vim.ManagedObjectReference] @{
                Type = $script:constants.OptionManagerType
                Value = $script:constants.OptionManagerValue
            }
            EsxAgentHostManager = [VMware.Vim.ManagedObjectReference] @{
                Type = $script:constants.EsxAgentHostManagerType
                Value = $script:constants.EsxAgentHostManagerValue
            }
            PciPassthruSystem = [VMware.Vim.ManagedObjectReference] @{
                Type = $script:constants.PciPassthruSystemType
                Value = $script:constants.PciPassthruSystemValue
            }
            GraphicsManager = [VMware.Vim.ManagedObjectReference] @{
                Type = $script:constants.GraphicsManagerType
                Value = $script:constants.GraphicsManagerValue
            }
            PowerSystem = [VMware.Vim.ManagedObjectReference] @{
                Type = $script:constants.PowerSystemType
                Value = $script:constants.PowerSystemValue
            }
            CacheConfigurationManager = [VMware.Vim.ManagedObjectReference] @{
                Type = $script:constants.CacheConfigurationManagerType
                Value = $script:constants.CacheConfigurationManagerValue
            }
        }
        Network = @(
            [VMware.Vim.ManagedObjectReference] @{
                Type = $script:constants.NetworkType
                Value = $script:constants.NetworkValue
            }
        )
    }
}

$script:optionManager = [VMware.Vim.OptionManager] @{
    MoRef = [VMware.Vim.ManagedObjectReference] @{
        Type = $script:constants.OptionManagerType
        Value = $script:constants.OptionManagerValue
    }
}

$script:vmHostAdvancedSettings = @(
    [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{
        Name = $script:constants.BufferCacheFlushIntervalAdvancedSettingName
        Value = $script:constants.BufferCacheFlushIntervalAdvancedSettingValue
    },
    [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{
        Name = $script:constants.BufferCacheHardMaxDirtyAdvancedSettingName
        Value = $script:constants.BufferCacheHardMaxDirtyAdvancedSettingValue
    },
    [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{
        Name = $script:constants.CBRCEnableAdvancedSettingName
        Value = $script:constants.CBRCEnableAdvancedSettingValue
    },
    [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{
        Name = $script:constants.VpxVpxaConfigWorkingDirAdvancedSettingName
        Value = $script:constants.VpxVpxaConfigWorkingDirAdvancedSettingValue
    }
)

$script:allAdvancedOptionsToUpdate = @(
    [VMware.Vim.OptionValue] @{
        Key = $script:constants.BufferCacheFlushIntervalAdvancedSettingName
        Value = $script:constants.BufferCacheFlushIntervalAdvancedSettingValue + 1
    },
    [VMware.Vim.OptionValue] @{
        Key = $script:constants.BufferCacheHardMaxDirtyAdvancedSettingName
        Value = $script:constants.BufferCacheHardMaxDirtyAdvancedSettingValue + 1
    },
    [VMware.Vim.OptionValue] @{
        Key = $script:constants.CBRCEnableAdvancedSettingName
        Value = $true
    },
    [VMware.Vim.OptionValue] @{
        Key = $script:constants.VpxVpxaConfigWorkingDirAdvancedSettingName
        Value = $script:constants.VpxVpxaConfigWorkingDirAdvancedSettingValue + '/vpxa'
    }
)

$script:notAllAdvancedOptionsToUpdate = @(
    [VMware.Vim.OptionValue] @{
        Key = $script:constants.BufferCacheFlushIntervalAdvancedSettingName
        Value = $script:constants.BufferCacheFlushIntervalAdvancedSettingValue + 1
    },
    [VMware.Vim.OptionValue] @{
        Key = $script:constants.VpxVpxaConfigWorkingDirAdvancedSettingName
        Value = $script:constants.VpxVpxaConfigWorkingDirAdvancedSettingValue + '/vpxa'
    }
)

$script:esxAgentHostManagerConfigInfoWithNullAgentVmSettings = [VMware.Vim.HostEsxAgentHostManagerConfigInfo] @{
    AgentVmDatastore = $null
    AgentVmNetwork = $null
}

$script:esxAgentHostManagerWithNullAgentVmSettings = [VMware.Vim.HostEsxAgentHostManager] @{
    ConfigInfo = $script:esxAgentHostManagerConfigInfoWithNullAgentVmSettings
}

$script:datastore = [VMware.VimAutomation.ViCore.Impl.V1.DatastoreManagement.VmfsDatastoreImpl] @{
    Name = $script:constants.DatastoreName
    ExtensionData = [VMware.Vim.Datastore] @{
        Name = $script:constants.DatastoreName
        MoRef = [VMware.Vim.ManagedObjectReference] @{
            Type = $script:constants.DatastoreType
            Value = $script:constants.DatastoreValue
        }
    }
    FreeSpaceGB = $script:constants.SwapSizeGB * 8
}

$script:network = [VMware.Vim.Network] @{
    Name = $script:constants.NetworkName
}

$script:esxAgentHostManagerConfigWithNotNullAgentVmSettings = [VMware.Vim.HostEsxAgentHostManagerConfigInfo] @{
    AgentVmDatastore = [VMware.Vim.ManagedObjectReference] @{
        Type = $script:constants.DatastoreType
        Value = $script:constants.DatastoreValue
    }
    AgentVmNetwork = [VMware.Vim.ManagedObjectReference] @{
        Type = $script:constants.NetworkType
        Value = $script:constants.NetworkValue
    }
}

$script:esxAgentHostManagerWithNotNullAgentVmSettings = [VMware.Vim.HostEsxAgentHostManager] @{
    ConfigInfo = $script:esxAgentHostManagerConfigWithNotNullAgentVmSettings
}

$script:vmHostPciPassthruSystem = [VMware.Vim.HostPciPassthruSystem] @{
    PciPassthruInfo = @(
        [VMware.Vim.HostPciPassthruInfo] @{
            Id = $script:constants.PciDeviceId + '.0'
            PassthruEnabled = $script:constants.PciDeviceEnabled
            PassthruCapable = $script:constants.PciDeviceCapable
        },
        [VMware.Vim.HostPciPassthruInfo] @{
            Id = $script:constants.PciDeviceId
            PassthruEnabled = $script:constants.PciDeviceEnabled
            PassthruCapable = !$script:constants.PciDeviceCapable
        }
    )
}

$script:vmHostPciPassthruConfig = [VMware.Vim.HostPciPassthruConfig] @{
    Id = $script:constants.PciDeviceId
    PassthruEnabled = $script:constants.PciDeviceEnabled
}

$script:vmHostGraphicsConfigWithoutGraphicsDevice = [VMware.Vim.HostGraphicsConfig] @{
    HostDefaultGraphicsType = $script:constants.DefaultGraphicsType.ToLower()
    SharedPassthruAssignmentPolicy = $script:constants.SharedPassthruAssignmentPolicy.ToLower()
}

$script:vmHostGraphicsConfigWithGraphicsDevice = [VMware.Vim.HostGraphicsConfig] @{
    HostDefaultGraphicsType = $script:constants.DefaultGraphicsType.ToLower()
    SharedPassthruAssignmentPolicy = $script:constants.SharedPassthruAssignmentPolicy.ToLower()
    DeviceType = @(
        [VMware.Vim.HostGraphicsConfigDeviceType] @{
            DeviceId = $script:constants.GraphicsDeviceId
            GraphicsType = $script:constants.DefaultGraphicsType.ToLower()
        }
    )
}

$script:vmHostGraphicsManager = [VMware.Vim.HostGraphicsManager] @{
    GraphicsConfig = $script:vmHostGraphicsConfigWithGraphicsDevice
}

$script:vmHostPowerSystem = [VMware.Vim.HostPowerSystem] @{
    MoRef = [VMware.Vim.ManagedObjectReference] @{
        Type = $script:constants.PowerSystemType
        Value = $script:constants.PowerSystemValue
    }
}

$script:vmHostCacheConfigurationManager = [VMware.Vim.HostCacheConfigurationManager] @{
    CacheConfigurationInfo = @(
        [VMware.Vim.HostCacheConfigurationInfo] @{
            Key = [VMware.Vim.ManagedObjectReference] @{
                Type = $script:constants.DatastoreType
                Value = $script:constants.DatastoreValue
            }
            SwapSize = $script:constants.SwapSizeMB
        }
    )
}

$script:hostCacheConfigurationSpec = [VMware.Vim.HostCacheConfigurationSpec] @{
    Datastore = [VMware.Vim.ManagedObjectReference] @{
        Type = $script:constants.DatastoreType
        Value = $script:constants.DatastoreValue
    }
    SwapSize = $script:constants.SwapSizeMB
}

$script:hostCacheConfigurationResult = [VMware.Vim.ManagedObjectReference] @{
    Type = $script:constants.TaskType
    Value = $script:constants.TaskValue
}

$script:hostCacheConfigurationErrorTask = [VMware.VimAutomation.ViCore.Impl.V1.Task.TaskImpl] @{
    Name = $script:constants.ConfigureHostCacheTaskName
    State = $script:constants.TaskErrorState
}

$script:hostCacheConfigurationSuccessTask = [VMware.VimAutomation.ViCore.Impl.V1.Task.TaskImpl] @{
    Name = $script:constants.ConfigureHostCacheTaskName
    State = $script:constants.TaskSuccessState
}
