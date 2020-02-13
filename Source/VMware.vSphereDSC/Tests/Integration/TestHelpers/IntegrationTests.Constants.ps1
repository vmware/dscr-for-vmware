<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

# Datacenter Folder Constants
$script:datacenterFolderName = 'MyTestDatacenterFolder'

$script:datacenterFolderEmptyLocation = [string]::Empty
$script:datacenterFolderLocationWithOneFolder = $script:datacenterFolderName
$script:datacenterFolderLocationWithTwoFolders = "$script:datacenterFolderName/$script:datacenterFolderName"

$script:datacenterFolderWithEmptyLocationResourceName = 'DatacenterFolder_With_EmptyLocation'
$script:datacenterFolderWithLocationWithOneFolderResourceName = 'DatacenterFolder_With_LocationWithOneFolder'
$script:datacenterFolderWithLocationWithTwoFoldersResourceName = 'DatacenterFolder_With_LocationWithTwoFolders'

$script:datacenterFolderWithEmptyLocationResourceId = "[DatacenterFolder]$script:datacenterFolderWithEmptyLocationResourceName"
$script:datacenterFolderWithLocationWithOneFolderResourceId = "[DatacenterFolder]$script:datacenterFolderWithLocationWithOneFolderResourceName"
$script:datacenterFolderWithLocationWithTwoFoldersResourceId = "[DatacenterFolder]$script:datacenterFolderWithLocationWithTwoFoldersResourceName"

# Datacenter Constants
$script:datacenterName = 'MyTestDatacenter'

$script:datacenterEmptyLocation = [string]::Empty
$script:datacenterLocationWithOneFolder = $script:datacenterFolderName
$script:datacenterLocationWithTwoFolders = "$script:datacenterFolderName/$script:datacenterFolderName"

$script:datacenterWithEmptyLocationResourceName = 'Datacenter_With_EmptyLocation'
$script:datacenterWithLocationWithOneFolderResourceName = 'Datacenter_With_LocationWithOneFolder'
$script:datacenterWithLocationWithTwoFoldersResourceName = 'Datacenter_With_LocationWithTwoFolders'

$script:datacenterWithEmptyLocationResourceId = "[Datacenter]$script:datacenterWithEmptyLocationResourceName"
$script:datacenterWithLocationWithOneFolderResourceId = "[Datacenter]$script:datacenterWithLocationWithOneFolderResourceName"
$script:datacenterWithLocationWithTwoFoldersResourceId = "[Datacenter]$script:datacenterWithLocationWithTwoFoldersResourceName"

# Folder Constants
$script:folderName = 'MyTestFolder'

$script:folderWithEmptyLocation = [string]::Empty
$script:folderWithLocationWithOneFolder = $script:folderName
$script:folderWithLocationWithTwoFolders = "$script:folderName/$script:folderName"

$script:folderType = 'Host'

$script:folderWithEmptyLocationResourceName = 'Folder_With_EmptyLocation'
$script:folderWithLocationWithOneFolderResourceName = 'Folder_With_LocationWithOneFolder'
$script:folderWithLocationWithTwoFoldersResourceName = 'Folder_With_LocationWithTwoFolders'

$script:folderWithEmptyLocationResourceId = "[Folder]$script:folderWithEmptyLocationResourceName"
$script:folderWithLocationWithOneFolderResourceId = "[Folder]$script:folderWithLocationWithOneFolderResourceName"
$script:folderWithLocationWithTwoFoldersResourceId = "[Folder]$script:folderWithLocationWithTwoFoldersResourceName"

# Cluster Constants
$script:clusterName = 'MyTestCluster'

$script:clusterWithEmptyLocation = [string]::Empty
$script:clusterWithLocationWithOneFolder = $script:folderName
$script:clusterWithLocationWithTwoFolders = "$script:folderName/$script:folderName"

$script:haClusterWithEmptyLocationResourceName = 'HACluster_With_EmptyLocation'
$script:haClusterWithLocationWithOneFolderResourceName = 'HACluster_With_LocationWithOneFolder'
$script:haClusterWithLocationWithTwoFoldersResourceName = 'HACluster_With_LocationWithTwoFolders'

$script:haClusterWithEmptyLocationResourceId = "[HACluster]$script:haClusterWithEmptyLocationResourceName"
$script:haClusterWithLocationWithOneFolderResourceId = "[HACluster]$script:haClusterWithLocationWithOneFolderResourceName"
$script:haClusterWithLocationWithTwoFoldersResourceId = "[HACluster]$script:haClusterWithLocationWithTwoFoldersResourceName"

$script:drsClusterWithEmptyLocationResourceName = 'DrsCluster_With_EmptyLocation'
$script:drsClusterWithLocationWithOneFolderResourceName = 'DrsCluster_With_LocationWithOneFolder'
$script:drsClusterWithLocationWithTwoFoldersResourceName = 'DrsCluster_With_LocationWithTwoFolders'

$script:drsClusterWithEmptyLocationResourceId = "[DrsCluster]$script:drsClusterWithEmptyLocationResourceName"
$script:drsClusterWithLocationWithOneFolderResourceId = "[DrsCluster]$script:drsClusterWithLocationWithOneFolderResourceName"
$script:drsClusterWithLocationWithTwoFoldersResourceId = "[DrsCluster]$script:drsClusterWithLocationWithTwoFoldersResourceName"

# Syslog Constants
$script:checkSslCerts = $true
$script:defaultRotate = 10
$script:defaultSize = 100
$script:defaultTimeout = 180
$script:logdirOne = '/scratch/log'
$script:logdirTwo = '/scratch/log2'
$script:logdirUnique = $false
$script:dropLogRotate = 10
$script:dropLogSize = 100
$script:queueDropMark = 90

# VMHost Advanced Settings Constants
$script:advancedSettingsWithDefaultValues = @{
    'Annotations.WelcomeMessage' = [string]::Empty
    'BufferCache.FlushInterval' = [long] 30000
    'BufferCache.HardMaxDirty' = [long] 95
    'CBRC.Enable' = $false
    'Cpu.UseMwait' = [long] 2
    'Config.Etc.issue' = [string]::Empty
    'Config.HostAgent.plugins.solo.enableMob' = $false
    'DataMover.MaxHeapSize' = [long] 64
    'HBR.HbrBitmapVMMaxStorageGB' = [long] 65536
    'HBR.HbrMinExtentSizeKB' = [long] 8
    'Misc.WorldletLoadType' = 'medium'
    'VMkernel.Boot.useReliableMem' = $true
    'Vpx.Vpxa.config.workingDir' = '/var/log/vmware'
    'UserVars.ProductLockerLocation' = '/locker/packages/vmtoolsRepo/'
}

$script:advancedSettingsWithCustomValues = @{
    'Annotations.WelcomeMessage' = 'Hello from DSC'
    'BufferCache.FlushInterval' = [long] 20000
    'BufferCache.HardMaxDirty' = [long] 50
    'CBRC.Enable' = $true
    'Cpu.UseMwait' = [long] 1
    'Config.Etc.issue' = 'Contents of /etc/issue'
    'Config.HostAgent.plugins.solo.enableMob' = $true
    'DataMover.MaxHeapSize' = [long] 32
    'HBR.HbrBitmapVMMaxStorageGB' = [long] 65500
    'HBR.HbrMinExtentSizeKB' = [long] 4
    'Misc.WorldletLoadType' = 'low'
    'VMkernel.Boot.useReliableMem' = $false
    'Vpx.Vpxa.config.workingDir' = '/var/log/vmware/temp'
    'UserVars.ProductLockerLocation' = '/locker/packages/vmtoolsRepo/temp/'
}

# VMHost Graphics Configuration Constants
$script:sharedGraphicsType = 'Shared'
$script:performanceSharedPassthruAssignmentPolicy = 'Performance'

# VMHost Power Policy Constants
$script:balancedPowerPolicy = 'Balanced'
$script:highPerformancePowerPolicy = 'HighPerformance'
$script:lowPowerPowerPolicy = 'LowPower'
$script:customPowerPolicy = 'Custom'

# VMHost Cache Constants
$script:zeroGigabytesSwapSize = 0
$script:oneGigabyteSwapSize = 1
$script:twoGigabytesSwapSize = 2
