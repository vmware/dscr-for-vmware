<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

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
    ResourcePoolValue = 'my-resource-pool-id'
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
    DatacenterNetworkFolderId = 'group-h3'
    DatacenterNetworkFolderName = 'NetworkFolder'
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
    VMHostPort = 443
    DefaultVMHostRestartTimeoutMinutes = 5
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
    DatastoreId = 'datastore-1'
    DatastoreName = 'MyDatastore'
    DatastoreType = 'Datastore'
    DatastoreValue = 'datastore-1'
    ScsiLunCanonicalName = 'mpx.vmhba0:C0:T0:L0'
    FileSystemVersion = 3
    NfsHost = 'MyNfsHost'
    NfsPath = 'MyNfsPath'
    AuthenticationMethod = 'Kerberos'
    AccessMode = 'ReadOnly'
    BlockSizeMB = 1
    MaxCongestionThresholdMillisecond = 100
    CongestionThresholdMillisecond = 50
    StorageIOControlEnabled = $true
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
    VirtualSwitchName = 'vSwitch0'
    VirtualPortGroupName = 'MyVirtualPortGroup'
    VLanId = 4095
    AllowPromiscuous = $true
    AllowPromiscuousInherited = $false
    ForgedTransmits = $true
    ForgedTransmitsInherited = $false
    MacChanges = $true
    MacChangesInherited = $false
    FailbackEnabled = $true
    LoadBalancingPolicyIP = 'LoadBalanceIP'
    LoadBalancingPolicySrcMac = 'LoadBalanceSrcMac'
    NetworkFailoverDetectionPolicy = 'LinkStatus'
    NotifySwitches = $true
    ActiveNic = @('vmnic0', 'vmnic1')
    ActiveNicSubset = @('vmnic0')
    StandbyNic = @('vmnic2')
    UnusedNic = @('vmnic3')
    UnusedNicEmpty = @()
    InheritFailback = $false
    InheritFailoverOrder = $false
    InheritLoadBalancingPolicy = $false
    InheritNetworkFailoverDetectionPolicy = $false
    InheritNotifySwitches = $false
    NetworkSystemType = 'HostNetworkSystem'
    NetworkSystemValue = 'networkSystem-1'
    ShapingEnabled = $true
    AverageBandwidth = 104857600000
    PeakBandwidth = 104857600000
    BurstSize = 107374182400
    PhysicalNetworkAdapterName = 'vmnic1'
    FullDuplex = 'Full'
    HalfDuplex = 'Half'
    BitRatePerSecMb = 1000
    AutoNegotiate = $true
    VMKernelNetworkAdapterName = 'MyVMKernelNetworkAdapter'
    VMKernelNetworkAdapterIP = '192.168.0.1'
    VMKernelNetworkAdapterSubnetMask = '255.255.255.0'
    VMKernelNetworkAdapterMac = '00:50:56:63:5b:0e'
    VMKernelNetworkAdapterDhcp = $true
    VMKernelNetworkAdapterAutomaticIPv6 = $true
    VMKernelNetworkAdapterIPv6ThroughDhcp = $true
    VMKernelNetworkAdapterMtu = 4000
    VMKernelNetworkAdapterIPv6Enabled = $true
    VMKernelNetworkAdapterManagementTrafficEnabled = $true
    VMKernelNetworkAdapterFaultToleranceLoggingEnabled = $true
    VMKernelNetworkAdapterVMotionEnabled = $true
    VMKernelNetworkAdapterVsanTrafficEnabled = $true
    VMKernelNetworkAdapterPortId = '100'
    DistributedSwitchName = 'MyDistributedSwitch'
    DistributedSwitchContactDetails = 'Distributed Switch Contact Details'
    DistributedSwitchContactName = 'Distributed Switch Contact Name'
    DistributedSwitchLinkDiscoveryProtocol = 'CDP'
    DistributedSwitchLinkDiscoveryProtocolOperation = 'Advertise'
    DistributedSwitchMaxPorts = 100
    DistributedSwitchMtu = 2000
    DistributedSwitchNotes = 'Distributed Switch Description'
    DistributedSwitchNumUplinkPorts = 10
    DistributedSwitchVersion = '6.6.0'
    ReferenceDistributedSwitchName = 'MyReferenceDistributedSwitch'
    WithoutPortGroups = $true
    DistributedPortGroupName = 'MyDistributedPortGroup'
    DistributedPortGroupNotes = 'Distributed Port Group Description'
    DistributedPortGroupNumPorts = 128
    DistributedPortGroupStaticPortBinding = 'Static'
    DistributedPortGroupDynamicPortBinding = 'Dynamic'
    ReferenceDistributedPortGroupName = 'MyReferenceDistributedPortGroup'
    VMHostAddedToDistributedSwitchOneName = 'MyVMHostAddedToDistributedSwitchOne'
    VMHostAddedToDistributedSwitchTwoName = 'MyVMHostAddedToDistributedSwitchTwo'
    VMHostRemovedFromDistributedSwitchOneName = 'MyVMHostRemovedFromDistributedSwitchOne'
    VMHostRemovedFromDistributedSwitchTwoName = 'MyVMHostRemovedFromDistributedSwitchTwo'
    ConnectedPhysicalNetworkAdapterOneName = 'MyConnectedPhysicalNetworkAdapterOne'
    ConnectedPhysicalNetworkAdapterTwoName = 'MyConnectedPhysicalNetworkAdapterTwo'
    ConnectedPhysicalNetworkAdapterBitRatePerSecMb = 1000
    DisconnectedPhysicalNetworkAdapterOneName = 'MyDisconnectedPhysicalNetworkAdapterOne'
    DisconnectedPhysicalNetworkAdapterTwoName = 'MyDisconnectedPhysicalNetworkAdapterTwo'
    DisconnectedPhysicalNetworkAdapterBitRatePerSecMb = 0
    VMKernelNetworkAdapterOneName = 'MyVMKernelNetworkAdapterOne'
    VMKernelNetworkAdapterTwoName = 'MyVMKernelNetworkAdapterTwo'
    PortGroupOneName = 'MyPortGroupOneName'
    PortGroupTwoName = 'MyPortGroupTwoName'
    DistributedSwitchWithoutAddedPhysicalNetworkAdaptersName = 'MyDistributedSwitchWithoutAddedPhysicalNetworkAdapters'
    DomainName = 'MyDomain'
    DomainUsername = 'MyDomainUsername'
    DomainPassword = 'MyDomainPassword' | ConvertTo-SecureString -AsPlainText -Force
    DomainActionJoin = 'Join'
    DomainActionLeave = 'Leave'
    RoleName = 'MyRole'
    PrivilegeIds = @('System.Anonymous', 'System.View', 'System.Read')
    PrivilegeToAddIds = @('System.Anonymous', 'System.View', 'VirtualMachine.Inventory.Create')
    PrivilegeToRemoveIds = @('System.Read')
    RootResourcePoolId = 'rootResourcePool-1'
    RootResourcePoolName = 'MyRootResourcePool'
    RootResourcePoolType = 'Resource Pool'
    RootResourcePoolValue = 'rootResourcePool-1'
    VAppId = 'vapp-1'
    VAppName = 'MyVApp'
    VMId = 'virtualMachine-1'
    VMName = 'MyVirtualMachine'
    PrincipalName = 'MyPrincipalName'
    PropagatePermission = $true
    NfsUsername = 'MyNfsUsername'
    NfsUserPasswordOne = 'MyNfsUserPasswordOne'
    NfsUserPasswordTwo = 'MyNfsUserPasswordTwo'
    VMHostConnectedState = 'Connected'
    VMHostMaintenanceState = 'Maintenance'
    EvacuateVMs = $true
    VsanDataMigrationMode = 'Full'
    VMHostLicenseKeyOne = '00000-00000-00000-00000-00000'
    VMHostLicenseKeyTwo = '11111-11111-11111-11111-11111'
    InHostDatastoreVMSwapfilePolicy = 'InHostDatastore'
    WithVMDatastoreVMSwapfilePolicy = 'WithVM'
    VMHostUTCTimeZoneName = 'UTC'
    VMHostGMTTimeZoneName = 'GMT'
    VMSwapfileDatastoreOneName = 'MyDatastoreOne'
    VMSwapfileDatastoreTwoName = 'MyDatastoreTwo'
    HostProfileName = 'MyHostProfile'
    ClusterManualAutomationLevel = 'Manual'
    EnterMaintenanceModeTaskName = 'EnterMaintenanceMode_Task'
    ApplyDrsRecommendationTaskName = 'ApplyDrsRecommendation_Task'
    KmsClusterId = 'kmsCluster-1'
    KmsClusterName = 'MyKmsCluster'
    EsxCliCommandSetMethodName = 'set'
    EsxCliCommandGetMethodName = 'get'
    EsxCliDCUIKeyboardCommand = 'system.settings.keyboard.layout'
    EsxCliSetMethodCreateArgs = '$this.EsxCli.system.settings.keyboard.layout.set.CreateArgs()'
    EsxCliSetMethodArgs = @{
        layout = 'Unset'
        enable = 'Unset'
        size = 'Unset'
        parameterkeys = 'Unset'
    }
    EsxCliSetMethodPopulatedArgs = @{
        layout = 'United Kingdom'
        enable = $false
        size = 100000
        parameterkeys = [int[]] @(1, 2, 3, 4, 5)
    }
    EsxCliSetMethodInvoke = 'system.settings.keyboard.layout.set.Invoke({0})'
    EsxCliGetMethodInvoke = '$this.EsxCli.system.settings.keyboard.layout.get.Invoke()'
    DCUIKeyboardUSDefaultLayout = 'US Default'
    DCUIKeyboardUnitedKingdomLayout = 'United Kingdom'
    Gateway = '192.168.0.1'
    Destination = '192.168.100.0'
    PrefixLength = 32
    EnableVMKernelDumpPartition = $true
    UseSmartAlgorithmForVMKernelDumpPartition = $true
    DumpFileName = 'MyTestDumpFile'
    DumpFileSizeInMB = 1181
    DumpFileSizeInBytes = 1238368256
    EnableVMKernelDumpFile = $true
    UseSmartAlgorithmForVMKernelDumpFile = $true
    VMKernelModuleName = 's2io'
    VMKernelModuleEnabled = $true
    SNMPAgentAuthenticationProtocol = 'SHA1'
    SNMPAgentCommunities = 'community1'
    EnableSNMPAgent = $true
    SNMPAgentEngineId = '0x0-9a-f'
    SNMPAgentHwsrc = 'indications'
    SNMPAgentLargeStorage = $true
    SNMPAgentLogLevel = 'info'
    SNMPAgentNoTraps = 'reset'
    SNMPAgentPort = 161
    SNMPAgentPrivacyProtocol = 'AES128'
    SNMPAgentRemoteUsers = '0x0-9a-f/SHA1/AES128'
    SNMPAgentSysContact = 'System contact'
    SNMPAgentSystemLocation = 'System location'
    SNMPAgentTargets = 'MyTestVMHost udp/162'
    SNMPAgentUsers = 'localUser'
    SNMPAgentV3Targets = 'MyTestVMHost udp/162'
    ResetSNMPAgent = $true
    SoftwareDeviceId = 'com.vmware.iscsi_vmk'
    SoftwareDeviceDefaultInstanceAddress = 0
    SoftwareDeviceInstanceAddress = 1
    DatastoreEnabled = $true
    DatastoreOrder = 0
    HostCacheEnabled = $true
    HostCacheOrder = 1
    HostLocalSwapEnabled = $true
    HostLocalSwapOrder = 2
    NetworkCoreDumpEnabled = $true
    NetworkCoreDumpInterfaceName = 'vmk0'
    NetworkCoreDumpServerIP = '10.11.12.13'
    NetworkCoreDumpServerPort = 6500
    VMwareCertifiedAcceptanceLevel = 'VMwareCertified'
    VMwareAcceptedAcceptanceLevel = 'VMwareAccepted'
    VMHostvSanNetworkConfigurationInterfaceOneName = 'vmk0'
    VMHostvSanNetworkConfigurationInterfaceTwoName = 'vmk1'
    VMHostvSanNetworkConfigurationAgentGroupIPv6MulticastAddress = 'ff19::2:3:4'
    VMHostvSanNetworkConfigurationAgentGroupMulticastAddress = '224.2.3.4'
    VMHostvSanNetworkConfigurationAgentGroupMulticastPort = 23451
    VMHostvSanNetworkConfigurationHostUnicastChannelBoundPort = 12321
    VMHostvSanNetworkConfigurationMasterGroupIPv6MulticastAddress = 'ff19::1:2:3'
    VMHostvSanNetworkConfigurationMasterGroupMulticastAddress = '224.1.2.3'
    VMHostvSanNetworkConfigurationMasterGroupMulticastPort = 12345
    VMHostvSanNetworkConfigurationMulticastTTL = 5
    VMHostvSanNetworkConfigurationTrafficType = 'vsan'
    VMHostScsiLunCanonicalName = 'mpx.vmhba1:C0:T3:L1'
    VMHostScsiLunMultipathPolicy = 'Fixed'
    VMHostScsiLunBlocksToSwitchPath = 100
    VMHostScsiLunCommandsToSwitchPath = 10
    VMHostScsiLunDeletePartitions = $true
    VMHostScsiLunIsLocal = $true
    VMHostScsiLunIsSsd = $true
    VMHostScsiLunPathName = 'vmhba1:C0:T3:L1'
    VMHostScsiLunPathState = 'Active'
    VMHostActiveScsiLunPath = $true
    VMHostPreferredScsiLunPath = $true
    DiskPartition = 1
    FirewallSystemType = 'HostFirewallSystem'
    FirewallSystemValue = 'firewallSystem-1'
    FirewallRulesetKey = 'CIMHttpServer'
    FirewallRulesetName = 'CIM Server'
    FirewallRulesetEnabled = $true
    FirewallRulesetAllIP = $false
    FirewallRulesetIPAddressesOne = @('192.0.20.10', '192.0.20.11', '192.0.20.12')
    FirewallRulesetIPAddressesTwo = @('192.0.20.10', '192.0.20.11', '192.0.20.13')
    FirewallRulesetIPNetworksOne = @('10.20.120.12/22', '10.20.120.12/23', '10.20.120.12/24')
    FirewallRulesetIPNetworksTwo = @('10.20.120.12/22', '10.20.120.12/23', '10.20.120.12/25')
    IScsiHbaDeviceName = 'vmhba65'
    IScsiDeviceType = 'iSCSI'
    ChapTypeProhibited = 'Prohibited'
    ChapTypeRequired = 'Required'
    ChapInherited = $true
    ChapName = 'MyChapName'
    ChapPassword = 'MyChapPassword'
    MutualChapInherited = $true
    MutualChapEnabled = $true
    MutualChapName = 'MyMutualChapName'
    MutualChapPassword = 'MyMutualChapPassword'
    IScsiHbaTargetAddress = '10.23.84.73'
    IScsiHbaTargetPort = 3260
    IScsiIPEndPoint = '10.23.84.73:3260'
    IScsiHbaSendTargetType = 'Send'
    IScsiHbaStaticTargetType = 'Static'
    IScsiName = 'iqn.com.vmware:esx-server'
}

$script:credential = New-Object System.Management.Automation.PSCredential($script:constants.VIServerUser, $script:constants.VIServerPassword)
$script:domainCredential = New-Object System.Management.Automation.PSCredential($script:constants.DomainUsername, $script:constants.DomainPassword)

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

$script:esxiServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{
    Name = $script:constants.VIServerName
    User = $script:constants.VIServerUser
    ProductLine = $script:constants.ESXiProductId
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
        NetworkFolder = [VMware.Vim.ManagedObjectReference] @{
            Type = $script:constants.FolderType
            Value = $script:constants.DatacenterNetworkFolderId
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

$script:datacenterNetworkFolderViewBaseObject = [VMware.Vim.Folder] @{
    Name = $script:constants.DatacenterNetworkFolderName
    MoRef = [VMware.Vim.ManagedObjectReference] @{
        Type = $script:constants.FolderType
        Value = $script:constants.DatacenterNetworkFolderId
    }
}

$script:datacenterNetworkFolder = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] @{
    Id = $script:constants.DatacenterNetworkFolderId
    Name = $script:constants.DatacenterNetworkFolderName
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
            CacheConfigurationManager = [VMware.Vim.ManagedObjectReference] @{
                Type = $script:constants.CacheConfigurationManagerType
                Value = $script:constants.CacheConfigurationManagerValue
            }
            EsxAgentHostManager = [VMware.Vim.ManagedObjectReference] @{
                Type = $script:constants.EsxAgentHostManagerType
                Value = $script:constants.EsxAgentHostManagerValue
            }
            FirewallSystem = [VMware.Vim.ManagedObjectReference] @{
                Type = $script:constants.FirewallSystemType
                Value = $script:constants.FirewallSystemValue
            }
            GraphicsManager = [VMware.Vim.ManagedObjectReference] @{
                Type = $script:constants.GraphicsManagerType
                Value = $script:constants.GraphicsManagerValue
            }
            NetworkSystem = [VMware.Vim.ManagedObjectReference] @{
                Type = $script:constants.NetworkSystemType
                Value = $script:constants.NetworkSystemValue
            }
            PciPassthruSystem = [VMware.Vim.ManagedObjectReference] @{
                Type = $script:constants.PciPassthruSystemType
                Value = $script:constants.PciPassthruSystemValue
            }
            PowerSystem = [VMware.Vim.ManagedObjectReference] @{
                Type = $script:constants.PowerSystemType
                Value = $script:constants.PowerSystemValue
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
    FreeSpaceGB = $script:constants.SwapSizeGB * 8
    FileSystemVersion = $script:constants.FileSystemVersion
    StorageIOControlEnabled = $script:constants.StorageIOControlEnabled
    CongestionThresholdMillisecond = $script:constants.MaxCongestionThresholdMillisecond
    ExtensionData = [VMware.Vim.Datastore] @{
        Name = $script:constants.DatastoreName
        MoRef = [VMware.Vim.ManagedObjectReference] @{
            Type = $script:constants.DatastoreType
            Value = $script:constants.DatastoreValue
        }
        Info = [VMware.Vim.VmfsDatastoreInfo] @{
            Vmfs = [VMware.Vim.HostVmfsVolume] @{
                BlockSizeMB = $script:constants.BlockSizeMB
                Extent = @(
                    [VMware.Vim.HostScsiDiskPartition] @{
                        DiskName = $script:constants.ScsiLunCanonicalName
                    }
                )
            }
        }
    }
}

$script:nfsDatastore = [VMware.VimAutomation.ViCore.Impl.V1.DatastoreManagement.NasDatastoreImpl] @{
    Name = $script:constants.DatastoreName
    RemoteHost = $script:constants.NfsHost
    RemotePath = $script:constants.NfsPath
    AuthenticationMethod = $script:constants.AuthenticationMethod
    FileSystemVersion = $script:constants.FileSystemVersion
    StorageIOControlEnabled = $script:constants.StorageIOControlEnabled
    CongestionThresholdMillisecond = $script:constants.MaxCongestionThresholdMillisecond
    ExtensionData = [VMware.Vim.Datastore] @{
        Host = @(
            [VMware.Vim.DatastoreHostMount] @{
                MountInfo = [VMware.Vim.HostMountInfo] @{
                    AccessMode = $script:constants.AccessMode
                }
            }
        )
    }
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

$script:virtualSwitch = [VMware.VimAutomation.ViCore.Impl.V1.Host.Networking.VirtualSwitchImpl] @{
    Name = $script:constants.VirtualSwitchName
    VMHost = $script:vmHost
}

$script:virtualPortGroup = [VMware.VimAutomation.ViCore.Impl.V1.Host.Networking.VirtualPortGroupImpl] @{
    Name = $script:constants.VirtualPortGroupName
    VirtualSwitch = $script:virtualSwitch
    VirtualSwitchName = $script:constants.VirtualSwitchName
    VLanId = $script:constants.VLanId
    ExtensionData = [VMware.Vim.HostPortGroup] @{
        Spec = [VMware.Vim.HostPortGroupSpec] @{
            Policy = [VMware.Vim.HostNetworkPolicy] @{
                ShapingPolicy = [VMware.Vim.HostNetworkTrafficShapingPolicy] @{
                    Enabled = $script:constants.ShapingEnabled
                    AverageBandwidth = $script:constants.AverageBandwidth
                    PeakBandwidth = $script:constants.PeakBandwidth
                    BurstSize = $script:constants.BurstSize
                }
            }
        }
    }
}

$script:virtualPortGroupSecurityPolicy = [VMware.VimAutomation.ViCore.Impl.V1.Host.Networking.VirtualPortgroupSecurityPolicyImpl] @{
    VirtualPortGroup = $script:virtualPortGroup
    AllowPromiscuous = $script:constants.AllowPromiscuous
    AllowPromiscuousInherited = $script:constants.AllowPromiscuousInherited
    ForgedTransmits = $script:constants.ForgedTransmits
    ForgedTransmitsInherited = $script:constants.ForgedTransmitsInherited
    MacChanges = $script:constants.MacChanges
    MacChangesInherited = $script:constants.MacChangesInherited
}

$script:virtualPortGroupTeamingPolicy = [VMware.VimAutomation.ViCore.Impl.V1.Host.Networking.NicTeamingVirtualPortGroupPolicyImpl] @{
    VirtualPortGroup = $script:virtualPortGroup
    FailbackEnabled = $script:constants.FailbackEnabled
    LoadBalancingPolicy = $script:constants.LoadBalancingPolicyIP
    NetworkFailoverDetectionPolicy = $script:constants.NetworkFailoverDetectionPolicy
    NotifySwitches = $script:constants.NotifySwitches
    ActiveNic = $script:constants.ActiveNic
    StandbyNic = $script:constants.StandbyNic
    UnusedNic = $script:constants.UnusedNic
    IsFailbackInherited = $script:constants.InheritFailback
    IsFailoverOrderInherited = $script:constants.InheritFailoverOrder
    IsLoadBalancingInherited = $script:constants.InheritLoadBalancingPolicy
    IsNetworkFailoverDetectionInherited = $script:constants.InheritNetworkFailoverDetectionPolicy
    IsNotifySwitchesInherited = $script:constants.InheritNotifySwitches
}

$script:vmHostNetworkSystem = [VMware.Vim.HostNetworkSystem] @{
    MoRef = [VMware.Vim.ManagedObjectReference] @{
        Type = $script:constants.NetworkSystemType
        Value = $script:constants.NetworkSystemValue
    }
}

$script:virtualPortGroupSpec = [VMware.Vim.HostPortGroupSpec] @{
    Name = $script:virtualPortGroup.Name
    VswitchName = $script:virtualPortGroup.VirtualSwitchName
    VlanId = $script:virtualPortGroup.VLanId
    Policy = [VMware.Vim.HostNetworkPolicy] @{
        ShapingPolicy = [VMware.Vim.HostNetworkTrafficShapingPolicy] @{
            Enabled = $script:constants.ShapingEnabled
            AverageBandwidth = $script:constants.AverageBandwidth
            PeakBandwidth = $script:constants.PeakBandwidth
            BurstSize = $script:constants.BurstSize
        }
    }
}

$script:physicalNetworkAdapter = [VMware.VimAutomation.ViCore.Impl.V1.Host.Networking.Nic.PhysicalNicImpl] @{
    Name = $script:constants.PhysicalNetworkAdapterName
    FullDuplex = $true
    BitRatePerSec = $script:constants.BitRatePerSecMb
    ExtensionData = [VMware.Vim.PhysicalNic] @{
        Spec = [VMware.Vim.PhysicalNicSpec] @{
            LinkSpeed = [VMware.Vim.PhysicalNicLinkInfo] @{
                SpeedMb = $script:constants.BitRatePerSecMb
                Duplex = $true
            }
        }
    }
}

$script:vmHostNetworkAdapter = [VMware.VimAutomation.ViCore.Impl.V1.Host.Networking.Nic.HostVMKernelVirtualNicImpl] @{
    Name = $script:constants.VMKernelNetworkAdapterName
    VMHost = $script:vmHost
    PortGroupName = $script:constants.VirtualPortGroupName
    IP = $script:constants.VMKernelNetworkAdapterIP
    SubnetMask = $script:constants.VMKernelNetworkAdapterSubnetMask
    Mac = $script:constants.VMKernelNetworkAdapterMac
    DhcpEnabled = $script:constants.VMKernelNetworkAdapterDhcp
    AutomaticIPv6 = $script:constants.VMKernelNetworkAdapterAutomaticIPv6
    IPv6 = @()
    IPv6ThroughDhcp = $script:constants.VMKernelNetworkAdapterIPv6ThroughDhcp
    Mtu = $script:constants.VMKernelNetworkAdapterMtu
    IPv6Enabled = $script:constants.VMKernelNetworkAdapterIPv6Enabled
    ManagementTrafficEnabled = $script:constants.VMKernelNetworkAdapterManagementTrafficEnabled
    FaultToleranceLoggingEnabled = $script:constants.VMKernelNetworkAdapterFaultToleranceLoggingEnabled
    VMotionEnabled = $script:constants.VMKernelNetworkAdapterVMotionEnabled
    VsanTrafficEnabled = $script:constants.VMKernelNetworkAdapterVsanTrafficEnabled
}

$script:distributedSwitch = [VMware.VimAutomation.Vds.Impl.V1.VmwareVDSwitchImpl] @{
    Name = $script:constants.DistributedSwitchName
    ContactDetails = $script:constants.DistributedSwitchContactDetails
    ContactName = $script:constants.DistributedSwitchContactName
    LinkDiscoveryProtocol = $script:constants.DistributedSwitchLinkDiscoveryProtocol
    LinkDiscoveryProtocolOperation = $script:constants.DistributedSwitchLinkDiscoveryProtocolOperation
    MaxPorts = $script:constants.DistributedSwitchMaxPorts
    Mtu = $script:constants.DistributedSwitchMtu
    Notes = $script:constants.DistributedSwitchNotes
    NumUplinkPorts = $script:constants.DistributedSwitchNumUplinkPorts
    Version = $script:constants.DistributedSwitchVersion
}

$script:distributedPortGroup = [VMware.VimAutomation.Vds.Impl.V1.VmwareVDPortgroupImpl] @{
    Name = $script:constants.DistributedPortGroupName
    Notes = $script:constants.DistributedPortGroupNotes
    NumPorts = $script:constants.DistributedPortGroupNumPorts
    PortBinding = $script:constants.DistributedPortGroupStaticPortBinding
    VDSwitch = $script:distributedSwitch
}

$script:proxySwitch = [VMware.Vim.HostProxySwitch] @{
    DvsName = $script:constants.DistributedSwitchName
}

$script:vmHostAddedToDistributedSwitchOne = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{
    Name = $script:constants.VMHostAddedToDistributedSwitchOneName
    ExtensionData = [VMware.Vim.HostSystem] @{
        Config = [VMware.Vim.HostConfigInfo] @{
            Network = [VMware.Vim.HostNetworkInfo] @{
                ProxySwitch = @(
                    $script:proxySwitch
                )
            }
        }
    }
}

$script:vmHostAddedToDistributedSwitchTwo = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{
    Name = $script:constants.VMHostAddedToDistributedSwitchTwoName
    ExtensionData = [VMware.Vim.HostSystem] @{
        Config = [VMware.Vim.HostConfigInfo] @{
            Network = [VMware.Vim.HostNetworkInfo] @{
                ProxySwitch = @(
                    $script:proxySwitch
                )
            }
        }
    }
}

$script:vmHostRemovedFromDistributedSwitchOne = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{
    Name = $script:constants.VMHostRemovedFromDistributedSwitchOneName
    ExtensionData = [VMware.Vim.HostSystem] @{
        Config = [VMware.Vim.HostConfigInfo] @{
            Network = [VMware.Vim.HostNetworkInfo] @{
                ProxySwitch = @()
            }
        }
    }
}

$script:vmHostRemovedFromDistributedSwitchTwo = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{
    Name = $script:constants.VMHostRemovedFromDistributedSwitchTwoName
    ExtensionData = [VMware.Vim.HostSystem] @{
        Config = [VMware.Vim.HostConfigInfo] @{
            Network = [VMware.Vim.HostNetworkInfo] @{
                ProxySwitch = @()
            }
        }
    }
}

$script:connectedPhysicalNetworkAdapterOne = [VMware.VimAutomation.ViCore.Impl.V1.Host.Networking.Nic.PhysicalNicImpl] @{
    Name = $script:constants.ConnectedPhysicalNetworkAdapterOneName
    BitRatePerSec = $script:constants.ConnectedPhysicalNetworkAdapterBitRatePerSecMb
}

$script:connectedPhysicalNetworkAdapterTwo = [VMware.VimAutomation.ViCore.Impl.V1.Host.Networking.Nic.PhysicalNicImpl] @{
    Name = $script:constants.ConnectedPhysicalNetworkAdapterTwoName
    BitRatePerSec = $script:constants.ConnectedPhysicalNetworkAdapterBitRatePerSecMb
}

$script:disconnectedPhysicalNetworkAdapterOne = [VMware.VimAutomation.ViCore.Impl.V1.Host.Networking.Nic.PhysicalNicImpl] @{
    Name = $script:constants.DisconnectedPhysicalNetworkAdapterOneName
    BitRatePerSec = $script:constants.DisconnectedPhysicalNetworkAdapterBitRatePerSecMb
}

$script:disconnectedPhysicalNetworkAdapterTwo = [VMware.VimAutomation.ViCore.Impl.V1.Host.Networking.Nic.PhysicalNicImpl] @{
    Name = $script:constants.DisconnectedPhysicalNetworkAdapterTwoName
    BitRatePerSec = $script:constants.DisconnectedPhysicalNetworkAdapterBitRatePerSecMb
}

$script:vmKernelNetworkAdapterOne = [VMware.VimAutomation.ViCore.Impl.V1.Host.Networking.Nic.HostVMKernelVirtualNicImpl] @{
    Name = $script:constants.VMKernelNetworkAdapterOneName
    VMHost = $script:vmHostAddedToDistributedSwitchOne
    PortGroupName = $script:constants.PortGroupOneName
}

$script:vmKernelNetworkAdapterTwo = [VMware.VimAutomation.ViCore.Impl.V1.Host.Networking.Nic.HostVMKernelVirtualNicImpl] @{
    Name = $script:constants.VMKernelNetworkAdapterTwoName
    VMHost = $script:vmHostAddedToDistributedSwitchOne
    PortGroupName = $script:constants.PortGroupTwoName
}

$script:distributedSwitchWithoutAddedPhysicalNetworkAdapters = [VMware.VimAutomation.Vds.Impl.V1.VmwareVDSwitchImpl] @{
    Name = $script:constants.DistributedSwitchWithoutAddedPhysicalNetworkAdaptersName
    ExtensionData = [VMware.Vim.VmwareDistributedVirtualSwitch] @{
        Config = [VMware.Vim.VMwareDVSConfigInfo] @{
            Host = @(
                [VMware.Vim.DistributedVirtualSwitchHostMember] @{
                    Config = [VMware.Vim.DistributedVirtualSwitchHostMemberConfigInfo] @{
                        Backing = [VMware.Vim.DistributedVirtualSwitchHostMemberPnicBacking] @{
                            PnicSpec = @()
                        }
                    }
                }
            )
        }
    }
}

$script:distributedSwitchWithAddedPhysicalNetworkAdapters = [VMware.VimAutomation.Vds.Impl.V1.VmwareVDSwitchImpl] @{
    Name = $script:constants.DistributedSwitchName
    ExtensionData = [VMware.Vim.VmwareDistributedVirtualSwitch] @{
        Config = [VMware.Vim.VMwareDVSConfigInfo] @{
            Host = @(
                [VMware.Vim.DistributedVirtualSwitchHostMember] @{
                    Config = [VMware.Vim.DistributedVirtualSwitchHostMemberConfigInfo] @{
                        Backing = [VMware.Vim.DistributedVirtualSwitchHostMemberPnicBacking] @{
                            PnicSpec = @(
                                [VMware.Vim.DistributedVirtualSwitchHostMemberPnicSpec] @{
                                    PnicDevice = $script:constants.ConnectedPhysicalNetworkAdapterOneName
                                },
                                [VMware.Vim.DistributedVirtualSwitchHostMemberPnicSpec] @{
                                    PnicDevice = $script:constants.DisconnectedPhysicalNetworkAdapterOneName
                                }
                            )
                        }
                    }
                }
            )
        }
    }
}

$script:vmHostAuthenticationInfoWithoutDomain = [VMware.VimAutomation.ViCore.Impl.V1.Host.VMHostAuthenticationImpl] @{
    VMHost = $script:vmHost
}

$script:vmHostAuthenticationInfoWithDomain = [VMware.VimAutomation.ViCore.Impl.V1.Host.VMHostAuthenticationImpl] @{
    Domain = $script:constants.DomainName
    VMHost = $script:vmHost
}

$script:standardSwitchWithOnePhysicalNetworkAdapter = [VMware.VimAutomation.ViCore.Impl.V1.Host.Networking.VirtualSwitchImpl] @{
    Name = $script:constants.VirtualSwitchName
    VMHost = $script:vmHost
    Nic = @($script:constants.DisconnectedPhysicalNetworkAdapterOneName)
}

$script:vmKernelNetworkAdapterToMigrateToStandardSwitch = [VMware.VimAutomation.ViCore.Impl.V1.Host.Networking.Nic.HostVMKernelVirtualNicImpl] @{
    Name = $script:constants.VMKernelNetworkAdapterOneName
    VMHost = $script:vmHost
    PortGroupName = $script:constants.PortGroupOneName
}

$script:portGroupWithAttachedVMKernelNetworkAdapter = [VMware.VimAutomation.ViCore.Impl.V1.Host.Networking.VirtualPortGroupImpl] @{
    Name = $script:constants.PortGroupOneName
    VirtualSwitch = $script:standardSwitchWithOnePhysicalNetworkAdapter
    VirtualSwitchName = $script:constants.VirtualSwitchName
}

$script:anonymousPrivilege = [VMware.VimAutomation.ViCore.Impl.V1.PermissionManagement.PrivilegeImpl] @{
    Server = $script:esxiServer
    Id = $script:constants.PrivilegeIds[0]
    Name = 'Anonymous'
}

$script:viewPrivilege = [VMware.VimAutomation.ViCore.Impl.V1.PermissionManagement.PrivilegeImpl] @{
    Server = $script:esxiServer
    Id = $script:constants.PrivilegeIds[1]
    Name = 'View'
}

$script:readPrivilege = [VMware.VimAutomation.ViCore.Impl.V1.PermissionManagement.PrivilegeImpl] @{
    Server = $script:esxiServer
    Id = $script:constants.PrivilegeIds[2]
    Name = 'Read'
}

$script:createPrivilege = [VMware.VimAutomation.ViCore.Impl.V1.PermissionManagement.PrivilegeImpl] @{
    Server = $script:esxiServer
    Id = $script:constants.PrivilegeToAddIds[2]
    Name = 'Create'
}

$script:vmHostRole = [VMware.VimAutomation.ViCore.Impl.V1.PermissionManagement.RoleImpl] @{
    Server = $script:esxiServer
    Name = $script:constants.RoleName
    PrivilegeList = $script:constants.PrivilegeIds
}

$script:rootResourcePool = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.ResourcePoolImpl] @{
    Id = $script:constants.RootResourcePoolId
    Name = $script:constants.RootResourcePoolName
    ParentId = $script:vmHost.Id
    Parent = $script:vmHost
}

$script:datacenterEntity = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.DatacenterImpl] @{
    Id = $script:constants.DatacenterId
    Name = $script:constants.DatacenterName
}

$script:datastoreEntity = [VMware.VimAutomation.ViCore.Impl.V1.DatastoreManagement.VmfsDatastoreImpl] @{
    Id = $script:constants.DatastoreId
    Name = $script:constants.DatastoreName
    Datacenter = $script:datacenterEntity
}

$script:resourcePoolEntity = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.ResourcePoolImpl] @{
    Id = $script:constants.ResourcePoolId
    Name = $script:constants.ResourcePoolName
    ParentId = $script:rootResourcePool.Id
    Parent = $script:rootResourcePool
}

$script:vAppEntity = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.ResourcePoolImpl] @{
    Id = $script:constants.VAppId
    Name = $script:constants.VAppName
    ParentId = $script:resourcePoolEntity.Id
    Parent = $script:resourcePoolEntity
}

$script:vmEntity = [VMware.VimAutomation.ViCore.Impl.V1.VM.UniversalVirtualMachineImpl] @{
    Id = $script:constants.VMId
    Name = $script:constants.VMName
    VMHost = $script:vmHost
    ResourcePool = $script:rootResourcePool
}

$script:resourcePoolViewBaseObject = [VMware.Vim.ResourcePool] @{
    Name = $script:constants.ResourcePoolName
    Parent = [VMware.Vim.ManagedObjectReference] @{
        Type = $script:constants.RootResourcePoolType
        Value = $script:constants.RootResourcePoolValue
    }
}

$script:vAppViewBaseObject = [VMware.Vim.ResourcePool] @{
    Parent = [VMware.Vim.ManagedObjectReference] @{
        Type = $script:constants.ResourcePoolType
        Value = $script:constants.ResourcePoolValue
    }
}

$script:principal = [VMware.VimAutomation.ViCore.Impl.V1.Host.Account.HostUserAccountImpl] @{
    Server = $script:esxiServer
    Name = $script:constants.PrincipalName
}

$script:vmHostPermission = [VMware.VimAutomation.ViCore.Impl.V1.PermissionManagement.PermissionImpl] @{
    Entity = $script:datacenterEntity
    Principal = $script:constants.PrincipalName
    Role = $script:constants.RoleName
    Propagate = $script:constants.PropagatePermission
}

$script:nfsUser = [VMware.VimAutomation.Storage.Impl.V1.Nfs.NfsUserImpl] @{
    Username = $script:constants.NfsUsername
    VMHost = $script:vmHost
}

$script:vmHostWithDatacenterHostFolderAsParent = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{
    Id = $script:constants.VMHostId
    Name = $script:constants.VMHostName
    ParentId = $script:constants.DatacenterHostFolderId
    ExtensionData = [VMware.Vim.HostSystem] @{
        Summary = [VMware.Vim.HostListSummary] @{
            Config = [VMware.Vim.HostConfigSummary] @{
                Port = $script:constants.VMHostPort
            }
        }
    }
}

$script:vmHostWithInventoryItemLocationItemOneAsParent = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{
    Id = $script:constants.VMHostId
    Name = $script:constants.VMHostName
    ParentId = $script:constants.InventoryItemLocationItemOneId
}

$script:vmHostUTCTimeZone = [VMware.VimAutomation.ViCore.Impl.V1.Host.VMHostTimeZoneImpl] @{
    Name = $script:constants.VMHostUTCTimeZoneName
    Key = $script:constants.VMHostUTCTimeZoneName
    VMHost = $script:vmHostWithSettingsToModify
}

$script:vmHostGMTTimeZone = [VMware.VimAutomation.ViCore.Impl.V1.Host.VMHostTimeZoneImpl] @{
    Name = $script:constants.VMHostGMTTimeZoneName
    Key = $script:constants.VMHostGMTTimeZoneName
    VMHost = $script:vmHostWithSettingsToModify
}

$script:vmSwapfileDatastoreOne = [VMware.VimAutomation.ViCore.Impl.V1.DatastoreManagement.VmfsDatastoreImpl] @{
    Id = $script:constants.DatastoreId
    Name = $script:constants.VMSwapfileDatastoreOneName
}

$script:vmSwapfileDatastoreTwo = [VMware.VimAutomation.ViCore.Impl.V1.DatastoreManagement.VmfsDatastoreImpl] @{
    Id = $script:constants.DatastoreId
    Name = $script:constants.VMSwapfileDatastoreTwoName
}

$script:hostProfile = [VMware.VimAutomation.ViCore.Impl.V1.Host.Profile.VMHostProfileImpl] @{
    Name = $script:constants.HostProfileName
    Server = $script:viServer
    ReferenceHost = $script:vmHostWithSettingsToModify
}

$script:clusterWithManualDrsAutomationLevel = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.ClusterImpl] @{
    Id = $script:constants.ClusterId
    Name = $script:constants.ClusterName
    DrsEnabled = $script:constants.DrsEnabled
    DrsAutomationLevel = $script:constants.ClusterManualAutomationLevel
}

$script:clusterWithFullyAutomatedDrsAutomationLevel = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.ClusterImpl] @{
    Id = $script:constants.ClusterId
    Name = $script:constants.ClusterName
    DrsEnabled = $script:constants.DrsEnabled
    DrsAutomationLevel = $script:constants.DrsAutomationLevel
}

$script:kmsCluster = [VMware.VimAutomation.Storage.Impl.V1.Encryption.KmsClusterImpl] @{
    Id = $script:constants.KmsClusterId
    Name = $script:constants.KmsClusterName
}

$script:vmHostWithClusterWithManualDrsAutomationLevelAsParentAndSettingsToModify = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{
    Id = $script:constants.VMHostId
    Name = $script:constants.VMHostName
    Parent = $script:clusterWithManualDrsAutomationLevel
    ConnectionState = $script:constants.VMHostConnectedState
    LicenseKey = $script:constants.VMHostLicenseKeyOne
    TimeZone = $script:vmHostGMTTimeZone
    VMSwapfileDatastore = $script:vmSwapfileDatastoreOne
    VMSwapfilePolicy = $script:constants.InHostDatastoreVMSwapfilePolicy
}

$script:vmHostWithClusterWithFullyAutomatedDrsAutomationLevelAsParentAndSettingsToModify = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{
    Id = $script:constants.VMHostId
    Name = $script:constants.VMHostName
    Parent = $script:clusterWithFullyAutomatedDrsAutomationLevel
    ConnectionState = $script:constants.VMHostConnectedState
    LicenseKey = $script:constants.VMHostLicenseKeyOne
    TimeZone = $script:vmHostGMTTimeZone
    VMSwapfileDatastore = $script:vmSwapfileDatastoreOne
    VMSwapfilePolicy = $script:constants.InHostDatastoreVMSwapfilePolicy
    ExtensionData = [VMware.Vim.HostSystem] @{
        Runtime = [VMware.Vim.HostRuntimeInfo] @{
            CryptoKeyId = [VMware.Vim.CryptoKeyId] @{
                ProviderId = [VMware.Vim.KeyProviderId] @{
                    Id = $script:constants.KmsClusterId + $script:constants.KmsClusterName
                }
            }
        }
    }
}

$script:vmHostWithoutSettingsToModify = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{
    Id = $script:constants.VMHostId
    Name = $script:constants.VMHostName
    ConnectionState = $script:constants.VMHostMaintenanceState
    LicenseKey = $script:constants.VMHostLicenseKeyTwo
    TimeZone = $script:vmHostUTCTimeZone
    VMSwapfileDatastore = $script:vmSwapfileDatastoreTwo
    VMSwapfilePolicy = $script:constants.WithVMDatastoreVMSwapfilePolicy
}

$script:clusterDrsRecommendation = [VMware.VimAutomation.ViCore.Impl.V1.Cluster.DrsRecommendationImpl] @{
    ClusterId = $script:constants.ClusterId
    Cluster = $script:clusterWithManualDrsAutomationLevel
}

$script:enterMaintenanceModeSuccessTask = [VMware.VimAutomation.ViCore.Impl.V1.Task.TaskImpl] @{
    Name = $script:constants.EnterMaintenanceModeTaskName
    State = $script:constants.TaskSuccessState
}

$script:applyDrsRecommendationSuccessTask = [VMware.VimAutomation.ViCore.Impl.V1.Task.TaskImpl] @{
    Name = $script:constants.ApplyDrsRecommendationTaskName
    State = $script:constants.TaskSuccessState
}

$script:esxCli = [VMware.VimAutomation.ViCore.Impl.V1.EsxCli.EsxCliImpl] @{
    VMHost = $script:vmHost
}

$script:vmHostIPRouteOne = [VMware.VimAutomation.ViCore.Impl.V1.Host.VMHostRouteImpl] @{
    VMHost = $script:vmHost
    Gateway = $script:constants.Gateway
    Destination = $script:constants.Destination
    PrefixLength = $script:constants.PrefixLength
}

$script:vmKernelDumpPartition = @{
    Active = 'mpx.vmhba32:C0:T0:L0:7'
    Configured = 'mpx.vmhba32:C0:T0:L0:7'
}

$script:vmKernelDumpFile = @{
    Active = 'mpx.vmhba32:C0:T0:L0:7'
    Configured = 'mpx.vmhba32:C0:T0:L0:7'
    Path = '/vmfs/volumes/{0}/vmkdump/{1}.dumpfile' -f $script:constants.DatastoreName, $script:constants.DumpFileName
    Size = $script:constants.DumpFileSizeInBytes
}

$script:fileSystem = @{
    UUID = [Guid]::NewGuid()
    VolumeName = $script:constants.DatastoreName
}

$script:vmKernelModule = @{
    Name = $script:constants.VMKernelModuleName
    IsEnabled = $script:constants.VMKernelModuleEnabled
}

$script:vmHostSNMPAgent = @{
    authentication = $script:constants.SNMPAgentAuthenticationProtocol
    communities = $script:constants.SNMPAgentCommunities
    enable = $script:constants.EnableSNMPAgent
    engineid = $script:constants.SNMPAgentEngineId
    hwsrc = $script:constants.SNMPAgentHwsrc
    largestorage = $script:constants.SNMPAgentLargeStorage
    loglevel = $script:constants.SNMPAgentLogLevel
    notraps = $script:constants.SNMPAgentNoTraps
    port = $script:constants.SNMPAgentPort
    privacy = $script:constants.SNMPAgentPrivacyProtocol
    remoteusers = $script:constants.SNMPAgentRemoteUsers
    syscontact = $script:constants.SNMPAgentSysContact
    syslocation = $script:constants.SNMPAgentSystemLocation
    targets = $script:constants.SNMPAgentTargets
    users = $script:constants.SNMPAgentUsers
    v3targets = $script:constants.SNMPAgentV3Targets
}

$script:vmHostSoftwareDevices = @(
    @{
        DeviceID = $script:constants.SoftwareDeviceId
        Instance = $script:constants.SoftwareDeviceInstanceAddress
    }
)

$script:vmHostSharedSwapSpaceConfiguration = @{
    DatastoreEnabled = $script:constants.DatastoreEnabled
    DatastoreName = $script:constants.DatastoreName
    DatastoreOrder = $script:constants.DatastoreOrder
    HostcacheEnabled = $script:constants.HostCacheEnabled
    HostcacheOrder = $script:constants.HostCacheOrder
    HostlocalswapEnabled = $script:constants.HostLocalSwapEnabled
    HostlocalswapOrder = $script:constants.HostLocalSwapOrder
}

$script:vmHostNetworkCoreDumpConfiguration = @{
    Enabled = $script:constants.NetworkCoreDumpEnabled
    HostVNic = $script:constants.NetworkCoreDumpInterfaceName
    NetworkServerIP = $script:constants.NetworkCoreDumpServerIP
    NetworkServerPort = $script:constants.NetworkCoreDumpServerPort
}

$script:vmHostvSanNetworkConfigurationIPInterface = @{
    VmkNicName = $script:constants.VMHostvSanNetworkConfigurationInterfaceOneName
    AgentGroupIPv6MulticastAddress = $script:constants.VMHostvSanNetworkConfigurationAgentGroupIPv6MulticastAddress
    AgentGroupMulticastAddress = $script:constants.VMHostvSanNetworkConfigurationAgentGroupMulticastAddress
    AgentGroupMulticastPort = $script:constants.VMHostvSanNetworkConfigurationAgentGroupMulticastPort
    HostUnicastChannelBoundPort = $script:constants.VMHostvSanNetworkConfigurationHostUnicastChannelBoundPort
    MasterGroupIPv6MulticastAddress = $script:constants.VMHostvSanNetworkConfigurationMasterGroupIPv6MulticastAddress
    MasterGroupMulticastAddress = $script:constants.VMHostvSanNetworkConfigurationMasterGroupMulticastAddress
    MasterGroupMulticastPort = $script:constants.VMHostvSanNetworkConfigurationMasterGroupMulticastPort
    MulticastTTL = $script:constants.VMHostvSanNetworkConfigurationMulticastTTL
    TrafficType = $script:constants.VMHostvSanNetworkConfigurationTrafficType
}

$script:vmHostScsiLun = [VMware.VimAutomation.ViCore.Impl.V1.Host.Storage.Scsi.ScsiLunImpl] @{
    CanonicalName = $script:constants.VMHostScsiLunCanonicalName
    VMHost = $script:vmHost
    MultipathPolicy = $script:constants.VMHostScsiLunMultipathPolicy
    BlocksToSwitchPath = $script:constants.VMHostScsiLunBlocksToSwitchPath
    CommandsToSwitchPath = $script:constants.VMHostScsiLunCommandsToSwitchPath
    IsLocal = $script:constants.VMHostScsiLunIsLocal
    IsSsd = $script:constants.VMHostScsiLunIsSsd
}

$script:vmHostScsiLunPath = [VMware.VimAutomation.ViCore.Impl.V1.Host.Storage.Scsi.ScsiLunPathImpl] @{
    Name = $script:constants.VMHostScsiLunPathName
    ScsiLun = $script:vmHostScsiLun
    State = $script:constants.VMHostScsiLunPathState
    Preferred = $script:constants.VMHostPreferredScsiLunPath
}

$script:notPreferredVMHostScsiLunPath = [VMware.VimAutomation.ViCore.Impl.V1.Host.Storage.Scsi.ScsiLunPathImpl] @{
    Name = $script:constants.VMHostScsiLunPathName
    ScsiLun = $script:vmHostScsiLun
    State = $script:constants.VMHostScsiLunPathState
    Preferred = !$script:constants.VMHostPreferredScsiLunPath
}

$script:vmHostDisk = [VMware.VimAutomation.ViCore.Impl.V1.Host.Storage.VMHostDiskImpl] @{
    VMHost = $script:vmHost
    ScsiLun = $script:vmHostScsiLun
    ExtensionData = [VMware.Vim.HostDiskPartitionInfo] @{
        Spec = [VMware.Vim.HostDiskPartitionSpec] @{}
    }
}

$script:vmHostDiskWithPartitions = [VMware.VimAutomation.ViCore.Impl.V1.Host.Storage.VMHostDiskImpl] @{
    VMHost = $script:vmHost
    ScsiLun = $script:vmHostScsiLun
    ExtensionData = [VMware.Vim.HostDiskPartitionInfo] @{
        Spec = [VMware.Vim.HostDiskPartitionSpec] @{
            Partition = @(
                [VMware.Vim.HostDiskPartitionAttributes] @{
                    Partition = $script:constants.DiskPartition
                }
            )
        }
    }
}

$script:firewallRulesetIPNetworksOne = @(
        [VMware.Vim.HostFirewallRulesetIpNetwork] @{
            Network = '10.20.120.12'
            PrefixLength = '22'
        },
        [VMware.Vim.HostFirewallRulesetIpNetwork] @{
            Network = '10.20.120.12'
            PrefixLength = '23'
        },
        [VMware.Vim.HostFirewallRulesetIpNetwork] @{
            Network = '10.20.120.12'
            PrefixLength = '24'
        }
)

$script:firewallRulesetIPNetworksTwo = @(
    [VMware.Vim.HostFirewallRulesetIpNetwork] @{
        Network = '10.20.120.12'
        PrefixLength = '22'
    },
    [VMware.Vim.HostFirewallRulesetIpNetwork] @{
        Network = '10.20.120.12'
        PrefixLength = '23'
    },
    [VMware.Vim.HostFirewallRulesetIpNetwork] @{
        Network = '10.20.120.12'
        PrefixLength = '25'
    }
)

$script:vmHostFirewallSystem = [VMware.Vim.HostFirewallSystem] @{
    MoRef = [VMware.Vim.ManagedObjectReference] @{
        Type = $script:constants.FirewallSystemType
        Value = $script:constants.FirewallSystemValue
    }
}

$script:vmHostFirewallRulesetSpec = [VMware.Vim.HostFirewallRulesetRulesetSpec] @{
    AllowedHosts = [VMware.Vim.HostFirewallRulesetIpList] @{
        AllIp = !$script:constants.FirewallRulesetAllIP
        IpAddress = $script:constants.FirewallRulesetIPAddressesTwo
        IpNetwork = $script:firewallRulesetIPNetworksTwo
    }
}

$script:vmHostFirewallRuleset = [VMware.VimAutomation.ViCore.Impl.V1.Host.VMHostFirewallExceptionImpl] @{
    Name = $script:constants.FirewallRulesetName
    VMHost = $script:vmHost
    Enabled = $script:constants.FirewallRulesetEnabled
    ExtensionData = [VMware.Vim.HostFirewallRuleset] @{
        Key = $script:constants.FirewallRulesetKey
        AllowedHosts = [VMware.Vim.HostFirewallRulesetIpList] @{
            AllIp = $script:constants.FirewallRulesetAllIP
            IpAddress = $script:constants.FirewallRulesetIPAddressesOne
            IpNetwork = $script:firewallRulesetIPNetworksOne
        }
    }
}

$script:iScsiHba = [VMware.VimAutomation.ViCore.Impl.V1.Host.Storage.IScsiHbaImpl] @{
    Device = $script:constants.IScsiHbaDeviceName
    VMHost = $script:vmHost
    AuthenticationProperties = [VMware.VimAutomation.ViCore.Impl.V1.Host.Storage.IScsiHbaAuthenticationPropertiesImpl] @{
        ChapType = $script:constants.ChapTypeRequired
        ChapName = $script:constants.ChapName
        MutualChapEnabled = $script:constants.MutualChapEnabled
        MutualChapName = $script:constants.MutualChapName
    }
}

$script:iScsiHbaTarget = [VMware.VimAutomation.ViCore.Impl.V1.Host.Storage.IScsiHbaTargetImpl] @{
    Address = $script:constants.IScsiHbaTargetAddress
    Port = $script:constants.IScsiHbaTargetPort
    Type = $script:constants.IScsiHbaSendTargetType
    IScsiHbaName = $script:constants.IScsiHbaDeviceName
    AuthenticationProperties = [VMware.VimAutomation.ViCore.Impl.V1.Host.Storage.IScsiHbaAuthenticationPropertiesImpl] @{
        ChapType = $script:constants.ChapTypeRequired
        ChapInherited = $script:constants.ChapInherited
        ChapName = $script:constants.ChapName
        MutualChapInherited = $script:constants.MutualChapInherited
        MutualChapEnabled = $script:constants.MutualChapEnabled
        MutualChapName = $script:constants.MutualChapName
    }
}
