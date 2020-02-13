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

Retrieves the Root Resource Pool of the specified Cluster.
#>
function Get-RootResourcePoolOfCluster {
    [CmdletBinding()]
    [OutputType([PSObject])]

    $datacenterName = $script:configurationData.AllNodes.DatacenterName
    $clusterName = $script:configurationData.AllNodes.ClusterName

    $viServer = Connect-VIServer -Server $Server -Credential $Credential -ErrorAction Stop -Verbose:$false

    $datacenter = Get-Datacenter -Server $viServer -Name $datacenterName -ErrorAction Stop -Verbose:$false
    $cluster = Get-Cluster -Server $viServer -Name $clusterName -Location $datacenter -ErrorAction Stop -Verbose:$false
    $rootResourcePool = Get-ResourcePool -Server $viServer -ErrorAction Stop -Verbose:$false | Where-Object -FilterScript { $_.ParentId -eq $cluster.Id }

    Disconnect-VIServer -Server $Server -Confirm:$false -ErrorAction Stop -Verbose:$false

    $rootResourcePool
}

<#
.DESCRIPTION

Creates a new Resource Pool with the specified name and places it in the Root Resource Pool of the specified Cluster.
Creates a new VApp with the specified name and places it in the newly created Resource Pool in the specified Cluster.
Creates a second Resource Pool with the specified name and places it in the newly created VApp in the specified Cluster.
#>
function Invoke-ClusterSetup {
    [CmdletBinding()]

    $rootResourcePool = Get-RootResourcePoolOfCluster

    $resourcePoolName = $script:configurationData.AllNodes.ResourcePoolName
    $vAppName = $script:configurationData.AllNodes.VAppName

    $viServer = Connect-VIServer -Server $Server -Credential $Credential -ErrorAction Stop -Verbose:$false

    $resourcePool = New-ResourcePool -Server $viServer -Name $resourcePoolName -Location $rootResourcePool -Confirm:$false -ErrorAction Stop -Verbose:$false
    $vApp = New-VApp -Server $viServer -Name $vAppName -Location $resourcePool -Confirm:$false -ErrorAction Stop -Verbose:$false
    New-ResourcePool -Server $viServer -Name $resourcePoolName -Location $vApp -Confirm:$false -ErrorAction Stop -Verbose:$false

    Disconnect-VIServer -Server $Server -Confirm:$false -ErrorAction Stop -Verbose:$false
}

<#
.DESCRIPTION

Removes the Resource Pool with the specified name from the specified Cluster.
#>
function Invoke-ClusterCleanup {
    [CmdletBinding()]

    $resourcePoolName = $script:configurationData.AllNodes.ResourcePoolName

    $viServer = Connect-VIServer -Server $Server -Credential $Credential -ErrorAction Stop -Verbose:$false

    $rootResourcePool = Get-RootResourcePoolOfCluster
    $resourcePool = Get-ResourcePool -Server $viServer -Name $resourcePoolName -Location $rootResourcePool -ErrorAction Stop -Verbose:$false |
                    Where-Object -FilterScript { $_.ParentId -eq $rootResourcePool.Id }
    Remove-ResourcePool -Server $viServer -ResourcePool $resourcePool -Confirm:$false -ErrorAction Stop -Verbose:$false

    Disconnect-VIServer -Server $Server -Confirm:$false -ErrorAction Stop -Verbose:$false
}
