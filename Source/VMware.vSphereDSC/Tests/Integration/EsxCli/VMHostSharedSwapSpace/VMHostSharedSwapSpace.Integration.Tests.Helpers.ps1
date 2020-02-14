<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

<#
.DESCRIPTION

Retrieves the canonical name of the Scsi logical unit that will contain the Vmfs Datastore used in the Integration Tests.
#>
function Get-ScsiLunCanonicalName {
    [CmdletBinding()]
    [OutputType([string])]

    $viServer = Connect-VIServer -Server $Server -Credential $Credential -ErrorAction Stop -Verbose:$false

    $vmHost = Get-VMHost -Server $viServer -Name $Name -ErrorAction Stop -Verbose:$false
    $datastoreSystem = Get-View -Server $viServer -Id $vmHost.ExtensionData.ConfigManager.DatastoreSystem -ErrorAction Stop -Verbose:$false
    $scsiLun = $datastoreSystem.QueryAvailableDisksForVmfs($null) | Select-Object -First 1

    if ($null -eq $scsiLun) {
        throw 'The Vmfs Datastore that is used in the Integration Tests requires one unused Scsi logical unit to be available.'
    }

    Disconnect-VIServer -Server $Server -Confirm:$false -ErrorAction Stop -Verbose:$false

    $scsiLun.CanonicalName
}

<#
.DESCRIPTION

Retrieves the initial shared swap space configuration of the VMHost before the execution of the Integration Tests.
#>
function Get-InitialVMHostSharedSwapSpaceConfiguration {
    [CmdletBinding()]
    [OutputType([hashtable])]

    $vmHostSharedSwapSpaceInitialConfiguration = @{}

    $viServer = Connect-VIServer -Server $Server -Credential $Credential -ErrorAction Stop -Verbose:$false

    $vmHost = Get-VMHost -Server $viServer -Name $Name -ErrorAction Stop -Verbose:$false
    $esxCli = Get-EsxCli -Server $viServer -VMHost $vmHost -V2 -ErrorAction Stop -Verbose:$false

    $vmHostSharedSwapSpaceConfiguration = $esxCli.sched.swap.system.get.Invoke()

    $vmHostSharedSwapSpaceInitialConfiguration.DatastoreEnabled = [System.Convert]::ToBoolean($vmHostSharedSwapSpaceConfiguration.DatastoreEnabled)
    $vmHostSharedSwapSpaceInitialConfiguration.DatastoreName = $vmHostSharedSwapSpaceConfiguration.DatastoreName
    $vmHostSharedSwapSpaceInitialConfiguration.DatastoreOrder = [long] $vmHostSharedSwapSpaceConfiguration.DatastoreOrder
    $vmHostSharedSwapSpaceInitialConfiguration.HostCacheEnabled = [System.Convert]::ToBoolean($vmHostSharedSwapSpaceConfiguration.HostcacheEnabled)
    $vmHostSharedSwapSpaceInitialConfiguration.HostCacheOrder = [long] $vmHostSharedSwapSpaceConfiguration.HostcacheOrder
    $vmHostSharedSwapSpaceInitialConfiguration.HostLocalSwapEnabled = [System.Convert]::ToBoolean($vmHostSharedSwapSpaceConfiguration.HostlocalswapEnabled)
    $vmHostSharedSwapSpaceInitialConfiguration.HostLocalSwapOrder = [long] $vmHostSharedSwapSpaceConfiguration.HostlocalswapOrder

    Disconnect-VIServer -Server $Server -Confirm:$false -ErrorAction Stop -Verbose:$false

    $vmHostSharedSwapSpaceInitialConfiguration
}
