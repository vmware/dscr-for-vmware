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

Retrieves the names of the Datacenter and VMHost entities used in the Integration Tests.
#>
function Get-EntityInformation {
    [CmdletBinding()]

    # Data that is going to be passed as Configuration Data in the Integration Tests.
    $script:datacenterEntityName = $null
    $script:vmHostEntityName = $null

    $viServer = Connect-VIServer -Server $ESXiServer -User $ESXiUser -Password $ESXiPassword -ErrorAction Stop -Verbose:$false

    $datacenter = Get-Datacenter -Server $viServer -ErrorAction Stop -Verbose:$false
    $rootFolder = Get-Folder -Server $viServer -NoRecursion -ErrorAction Stop -Verbose:$false

    $script:datacenterEntityName = $datacenter.Name
    $script:vmHostEntityName = $rootFolder.Name

    Disconnect-VIServer -Server $ESXiServer -Confirm:$false -ErrorAction Stop -Verbose:$false
}

<#
.DESCRIPTION

Creates a new VMHost User account with the specified name and password.
#>
function New-VMHostUserAccount {
    [CmdletBinding()]

    $vmHostUserAccountName = $script:configurationData.AllNodes.VMHostUserAccountName
    $vmHostUserAccountPassword = $script:configurationData.AllNodes.VMHostUserAccountPassword

    $viServer = Connect-VIServer -Server $ESXiServer -User $ESXiUser -Password $ESXiPassword -ErrorAction Stop -Verbose:$false

    New-VMHostAccount -Server $viServer -Id $vmHostUserAccountName -Password $vmHostUserAccountPassword -Confirm:$false -ErrorAction Stop -Verbose:$false

    Disconnect-VIServer -Server $ESXiServer -Confirm:$false -ErrorAction Stop -Verbose:$false
}

<#
.DESCRIPTION

Creates a new Vmfs Datastore with the specified name on the specified VMHost.
#>
function New-VmfsDatastore {
    [CmdletBinding()]

    $datastoreName = $script:configurationData.AllNodes.DatastoreEntityName

    $viServer = Connect-VIServer -Server $VCenterServer -User $VCenterUser -Password $VCenterPassword -ErrorAction Stop -Verbose:$false
    $vmHost = Get-VMHost -Server $viServer -Name $ESXiServer -ErrorAction Stop -Verbose:$false
    $datastoreSystem = Get-View -Server $viServer -Id $vmHost.ExtensionData.ConfigManager.DatastoreSystem -ErrorAction Stop -Verbose:$false
    $scsiLun = $datastoreSystem.QueryAvailableDisksForVmfs($null) | Select-Object -First 1

    New-Datastore -Server $viServer -Name $datastoreName -VMHost $vmHost -Vmfs -Path $scsiLun.CanonicalName -Confirm:$false -ErrorAction Stop -Verbose:$false

    Disconnect-VIServer -Server $VCenterServer -Confirm:$false -ErrorAction Stop -Verbose:$false
}

<#
.DESCRIPTION

Creates a new Resource Pool with the specified name and places it in the Root Resource Pool on the specified VMHost.
#>
function New-VMHostResourcePool {
    [CmdletBinding()]

    $resourcePoolName = $script:configurationData.AllNodes.ResourcePoolEntityName

    $viServer = Connect-VIServer -Server $VCenterServer -User $VCenterUser -Password $VCenterPassword -ErrorAction Stop -Verbose:$false
    $vmHost = Get-VMHost -Server $viServer -Name $ESXiServer -ErrorAction Stop -Verbose:$false
    $resourcePoolsType = (Get-ResourcePool -Server $viServer -ErrorAction Stop -Verbose:$false | Select-Object -First 1).GetType()
    $rootResourcePool = Get-Inventory -Server $viServer -ErrorAction Stop -Verbose:$false |
                        Where-Object -FilterScript { $_.ParentId -eq $vmHost.Id -and $_.GetType() -eq $resourcePoolsType }

    New-ResourcePool -Server $viServer -Name $resourcePoolName -Location $rootResourcePool -Confirm:$false -ErrorAction Stop -Verbose:$false

    Disconnect-VIServer -Server $VCenterServer -Confirm:$false -ErrorAction Stop -Verbose:$false
}

<#
.DESCRIPTION

Creates a new vApp with the specified name and places it in the specified Resource Pool on the specified VMHost.
#>
function New-VMHostVApp {
    [CmdletBinding()]

    $resourcePoolName = $script:configurationData.AllNodes.ResourcePoolEntityName
    $vAppName = $script:configurationData.AllNodes.VAppEntityName

    $viServer = Connect-VIServer -Server $VCenterServer -User $VCenterUser -Password $VCenterPassword -ErrorAction Stop -Verbose:$false
    $vmHost = Get-VMHost -Server $viServer -Name $ESXiServer -ErrorAction Stop -Verbose:$false
    $resourcePoolsType = (Get-ResourcePool -Server $viServer -ErrorAction Stop -Verbose:$false | Select-Object -First 1).GetType()
    $rootResourcePool = Get-Inventory -Server $viServer -ErrorAction Stop -Verbose:$false |
                        Where-Object -FilterScript { $_.ParentId -eq $vmHost.Id -and $_.GetType() -eq $resourcePoolsType }
    $resourcePool = Get-ResourcePool -Server $viServer -Name $resourcePoolName -Location $rootResourcePool -ErrorAction Stop -Verbose:$false |
                    Where-Object -FilterScript { $_.ParentId -eq $rootResourcePool.Id }

    New-VApp -Server $viServer -Name $vAppName -Location $resourcePool -Confirm:$false -ErrorAction Stop -Verbose:$false

    Disconnect-VIServer -Server $VCenterServer -Confirm:$false -ErrorAction Stop -Verbose:$false
}

<#
.DESCRIPTION

Creates a new Virtual Machine with the specified name and places it in the Root Resource Pool on the specified VMHost.
#>
function New-VirtualMachinePlacedInTheRootResourcePoolOfTheVMHost {
    [CmdletBinding()]

    $vmName = $script:configurationData.AllNodes.VMEntityName

    $viServer = Connect-VIServer -Server $VCenterServer -User $VCenterUser -Password $VCenterPassword -ErrorAction Stop -Verbose:$false
    $vmHost = Get-VMHost -Server $viServer -Name $ESXiServer -ErrorAction Stop -Verbose:$false
    $resourcePoolsType = (Get-ResourcePool -Server $viServer -ErrorAction Stop -Verbose:$false | Select-Object -First 1).GetType()
    $rootResourcePool = Get-Inventory -Server $viServer -ErrorAction Stop -Verbose:$false |
                        Where-Object -FilterScript { $_.ParentId -eq $vmHost.Id -and $_.GetType() -eq $resourcePoolsType }

    New-VM -Server $viServer -Name $vmName -VMHost $vmHost -ResourcePool $rootResourcePool -Confirm:$false -ErrorAction Stop -Verbose:$false

    Disconnect-VIServer -Server $VCenterServer -Confirm:$false -ErrorAction Stop -Verbose:$false
}

<#
.DESCRIPTION

Creates a new Virtual Machine with the specified name and places it in the specified Resource Pool on the specified VMHost.
#>
function New-VirtualMachinePlacedInResourcePool {
    [CmdletBinding()]

    $resourcePoolName = $script:configurationData.AllNodes.ResourcePoolEntityName
    $vmName = $script:configurationData.AllNodes.VMEntityName

    $viServer = Connect-VIServer -Server $VCenterServer -User $VCenterUser -Password $VCenterPassword -ErrorAction Stop -Verbose:$false
    $vmHost = Get-VMHost -Server $viServer -Name $ESXiServer -ErrorAction Stop -Verbose:$false
    $resourcePoolsType = (Get-ResourcePool -Server $viServer -ErrorAction Stop -Verbose:$false | Select-Object -First 1).GetType()
    $rootResourcePool = Get-Inventory -Server $viServer -ErrorAction Stop -Verbose:$false |
                        Where-Object -FilterScript { $_.ParentId -eq $vmHost.Id -and $_.GetType() -eq $resourcePoolsType }
    $resourcePool = Get-ResourcePool -Server $viServer -Name $resourcePoolName -Location $rootResourcePool -ErrorAction Stop -Verbose:$false |
                    Where-Object -FilterScript { $_.ParentId -eq $rootResourcePool.Id }

    New-VM -Server $viServer -Name $vmName -VMHost $vmHost -ResourcePool $resourcePool -Confirm:$false -ErrorAction Stop -Verbose:$false

    Disconnect-VIServer -Server $VCenterServer -Confirm:$false -ErrorAction Stop -Verbose:$false
}

<#
.DESCRIPTION

Creates a new Virtual Machine with the specified name and places it in the specified vApp on the specified VMHost.
#>
function New-VirtualMachinePlacedInVApp {
    [CmdletBinding()]

    $resourcePoolName = $script:configurationData.AllNodes.ResourcePoolEntityName
    $vAppName = $script:configurationData.AllNodes.VAppEntityName
    $vmName = $script:configurationData.AllNodes.VMEntityName

    $viServer = Connect-VIServer -Server $VCenterServer -User $VCenterUser -Password $VCenterPassword -ErrorAction Stop -Verbose:$false
    $vmHost = Get-VMHost -Server $viServer -Name $ESXiServer -ErrorAction Stop -Verbose:$false
    $resourcePoolsType = (Get-ResourcePool -Server $viServer -ErrorAction Stop -Verbose:$false | Select-Object -First 1).GetType()
    $rootResourcePool = Get-Inventory -Server $viServer -ErrorAction Stop -Verbose:$false |
                        Where-Object -FilterScript { $_.ParentId -eq $vmHost.Id -and $_.GetType() -eq $resourcePoolsType }
    $resourcePool = Get-ResourcePool -Server $viServer -Name $resourcePoolName -Location $rootResourcePool -ErrorAction Stop -Verbose:$false |
                    Where-Object -FilterScript { $_.ParentId -eq $rootResourcePool.Id }
    $vApp = Get-VApp -Server $viServer -Name $vAppName -Location $resourcePool -ErrorAction Stop -Verbose:$false |
            Where-Object -FilterScript { $_.ParentId -eq $resourcePool.Id }

    New-VM -Server $viServer -Name $vmName -VMHost $vmHost -ResourcePool $vApp -Confirm:$false -ErrorAction Stop -Verbose:$false

    Disconnect-VIServer -Server $VCenterServer -Confirm:$false -ErrorAction Stop -Verbose:$false
}

<#
.DESCRIPTION

Removes the VMHost User account with the specified name.
#>
function Remove-VMHostUserAccount {
    [CmdletBinding()]

    $vmHostUserAccountName = $script:configurationData.AllNodes.VMHostUserAccountName

    $viServer = Connect-VIServer -Server $ESXiServer -User $ESXiUser -Password $ESXiPassword -ErrorAction Stop -Verbose:$false

    $vmHostUserAccount = Get-VMHostAccount -Server $viServer -Id $vmHostUserAccountName -ErrorAction Stop -Verbose:$false
    Remove-VMHostAccount -Server $viServer -HostAccount $vmHostUserAccount -Confirm:$false -ErrorAction Stop -Verbose:$false

    Disconnect-VIServer -Server $ESXiServer -Confirm:$false -ErrorAction Stop -Verbose:$false
}

<#
.DESCRIPTION

Removes the Vmfs Datastore with the specified name from the specified VMHost.
#>
function Remove-VmfsDatastore {
    [CmdletBinding()]

    $datastoreName = $script:configurationData.AllNodes.DatastoreEntityName

    $viServer = Connect-VIServer -Server $VCenterServer -User $VCenterUser -Password $VCenterPassword -ErrorAction Stop -Verbose:$false
    $vmHost = Get-VMHost -Server $viServer -Name $ESXiServer -ErrorAction Stop -Verbose:$false

    $vmfsDatastore = Get-Datastore -Server $viServer -Name $datastoreName -VMHost $vmHost -ErrorAction Stop -Verbose:$false
    Remove-Datastore -Server $viServer -Datastore $vmfsDatastore -VMHost $vmHost -Confirm:$false -ErrorAction Stop -Verbose:$false

    Disconnect-VIServer -Server $VCenterServer -Confirm:$false -ErrorAction Stop -Verbose:$false
}

<#
.DESCRIPTION

Removes the Resource Pool with the specified name from the specified VMHost.
#>
function Remove-VMHostResourcePool {
    [CmdletBinding()]

    $resourcePoolName = $script:configurationData.AllNodes.ResourcePoolEntityName

    $viServer = Connect-VIServer -Server $VCenterServer -User $VCenterUser -Password $VCenterPassword -ErrorAction Stop -Verbose:$false
    $vmHost = Get-VMHost -Server $viServer -Name $ESXiServer -ErrorAction Stop -Verbose:$false
    $resourcePoolsType = (Get-ResourcePool -Server $viServer -ErrorAction Stop -Verbose:$false | Select-Object -First 1).GetType()
    $rootResourcePool = Get-Inventory -Server $viServer -ErrorAction Stop -Verbose:$false |
                        Where-Object -FilterScript { $_.ParentId -eq $vmHost.Id -and $_.GetType() -eq $resourcePoolsType }

    $resourcePool = Get-ResourcePool -Server $viServer -Name $resourcePoolName -Location $rootResourcePool -ErrorAction Stop -Verbose:$false |
                    Where-Object -FilterScript { $_.ParentId -eq $rootResourcePool.Id }
    Remove-ResourcePool -Server $viServer -ResourcePool $resourcePool -Confirm:$false -ErrorAction Stop -Verbose:$false

    Disconnect-VIServer -Server $VCenterServer -Confirm:$false -ErrorAction Stop -Verbose:$false
}

<#
.DESCRIPTION

Removes the vApp with the specified name from the specified VMHost.
#>
function Remove-VMHostVApp {
    [CmdletBinding()]

    $resourcePoolName = $script:configurationData.AllNodes.ResourcePoolEntityName
    $vAppName = $script:configurationData.AllNodes.VAppEntityName

    $viServer = Connect-VIServer -Server $VCenterServer -User $VCenterUser -Password $VCenterPassword -ErrorAction Stop -Verbose:$false
    $vmHost = Get-VMHost -Server $viServer -Name $ESXiServer -ErrorAction Stop -Verbose:$false
    $resourcePoolsType = (Get-ResourcePool -Server $viServer -ErrorAction Stop -Verbose:$false | Select-Object -First 1).GetType()
    $rootResourcePool = Get-Inventory -Server $viServer -ErrorAction Stop -Verbose:$false |
                        Where-Object -FilterScript { $_.ParentId -eq $vmHost.Id -and $_.GetType() -eq $resourcePoolsType }
    $resourcePool = Get-ResourcePool -Server $viServer -Name $resourcePoolName -Location $rootResourcePool -ErrorAction Stop -Verbose:$false |
                    Where-Object -FilterScript { $_.ParentId -eq $rootResourcePool.Id }

    $vApp = Get-VApp -Server $viServer -Name $vAppName -Location $resourcePool -ErrorAction Stop -Verbose:$false |
            Where-Object -FilterScript { $_.ParentId -eq $resourcePool.Id }
    Remove-VApp -Server $viServer -VApp $vApp -Confirm:$false -ErrorAction Stop -Verbose:$false

    Disconnect-VIServer -Server $VCenterServer -Confirm:$false -ErrorAction Stop -Verbose:$false
}

<#
.DESCRIPTION

Removes the Virtual Machine with the specified name from the specified VMHost.
#>
function Remove-VirtualMachinePlacedInTheRootResourcePoolOfTheVMHost {
    [CmdletBinding()]

    $vmName = $script:configurationData.AllNodes.VMEntityName

    $viServer = Connect-VIServer -Server $VCenterServer -User $VCenterUser -Password $VCenterPassword -ErrorAction Stop -Verbose:$false
    $vmHost = Get-VMHost -Server $viServer -Name $ESXiServer -ErrorAction Stop -Verbose:$false
    $resourcePoolsType = (Get-ResourcePool -Server $viServer -ErrorAction Stop -Verbose:$false | Select-Object -First 1).GetType()
    $rootResourcePool = Get-Inventory -Server $viServer -ErrorAction Stop -Verbose:$false |
                        Where-Object -FilterScript { $_.ParentId -eq $vmHost.Id -and $_.GetType() -eq $resourcePoolsType }

    $vm = Get-VM -Server $viServer -Name $vmName -Location $rootResourcePool -ErrorAction Stop -Verbose:$false |
          Where-Object -FilterScript { $_.ResourcePoolId -eq $rootResourcePool.Id }
    Remove-VM -Server $viServer -VM $vm -DeletePermanently:$true -Confirm:$false -ErrorAction Stop -Verbose:$false

    Disconnect-VIServer -Server $VCenterServer -Confirm:$false -ErrorAction Stop -Verbose:$false
}

<#
.DESCRIPTION

Removes the Virtual Machine with the specified name from the specified VMHost.
#>
function Remove-VirtualMachinePlacedInResourcePool {
    [CmdletBinding()]

    $resourcePoolName = $script:configurationData.AllNodes.ResourcePoolEntityName
    $vmName = $script:configurationData.AllNodes.VMEntityName

    $viServer = Connect-VIServer -Server $VCenterServer -User $VCenterUser -Password $VCenterPassword -ErrorAction Stop -Verbose:$false
    $vmHost = Get-VMHost -Server $viServer -Name $ESXiServer -ErrorAction Stop -Verbose:$false
    $resourcePoolsType = (Get-ResourcePool -Server $viServer -ErrorAction Stop -Verbose:$false | Select-Object -First 1).GetType()
    $rootResourcePool = Get-Inventory -Server $viServer -ErrorAction Stop -Verbose:$false |
                        Where-Object -FilterScript { $_.ParentId -eq $vmHost.Id -and $_.GetType() -eq $resourcePoolsType }
    $resourcePool = Get-ResourcePool -Server $viServer -Name $resourcePoolName -Location $rootResourcePool -ErrorAction Stop -Verbose:$false |
                    Where-Object -FilterScript { $_.ParentId -eq $rootResourcePool.Id }

    $vm = Get-VM -Server $viServer -Name $vmName -Location $resourcePool -ErrorAction Stop -Verbose:$false |
          Where-Object -FilterScript { $_.ResourcePoolId -eq $resourcePool.Id }
    Remove-VM -Server $viServer -VM $vm -DeletePermanently:$true -Confirm:$false -ErrorAction Stop -Verbose:$false

    Disconnect-VIServer -Server $VCenterServer -Confirm:$false -ErrorAction Stop -Verbose:$false
}

<#
.DESCRIPTION

Removes the Virtual Machine with the specified name from the specified VMHost.
#>
function Remove-VirtualMachinePlacedInVApp {
    [CmdletBinding()]

    $resourcePoolName = $script:configurationData.AllNodes.ResourcePoolEntityName
    $vAppName = $script:configurationData.AllNodes.VAppEntityName
    $vmName = $script:configurationData.AllNodes.VMEntityName

    $viServer = Connect-VIServer -Server $VCenterServer -User $VCenterUser -Password $VCenterPassword -ErrorAction Stop -Verbose:$false
    $vmHost = Get-VMHost -Server $viServer -Name $ESXiServer -ErrorAction Stop -Verbose:$false
    $resourcePoolsType = (Get-ResourcePool -Server $viServer -ErrorAction Stop -Verbose:$false | Select-Object -First 1).GetType()
    $rootResourcePool = Get-Inventory -Server $viServer -ErrorAction Stop -Verbose:$false |
                        Where-Object -FilterScript { $_.ParentId -eq $vmHost.Id -and $_.GetType() -eq $resourcePoolsType }
    $resourcePool = Get-ResourcePool -Server $viServer -Name $resourcePoolName -Location $rootResourcePool -ErrorAction Stop -Verbose:$false |
                    Where-Object -FilterScript { $_.ParentId -eq $rootResourcePool.Id }
    $vApp = Get-VApp -Server $viServer -Name $vAppName -Location $resourcePool -ErrorAction Stop -Verbose:$false |
            Where-Object -FilterScript { $_.ParentId -eq $resourcePool.Id }

    $vm = Get-VM -Server $viServer -Name $vmName -Location $vApp -ErrorAction Stop -Verbose:$false |
          Where-Object -FilterScript { $_.ResourcePoolId -eq $vApp.Id }
    Remove-VM -Server $viServer -VM $vm -DeletePermanently:$true -Confirm:$false -ErrorAction Stop -Verbose:$false

    Disconnect-VIServer -Server $VCenterServer -Confirm:$false -ErrorAction Stop -Verbose:$false
}
