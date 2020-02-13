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

Retrieves the name and the location of the Datacenter where the specified VMHost is located.
Retrieves one connected Physical Network Adapter and two disconnected Physical Network Adapters from the specified VMHost.
The connected Physical Network Adapter should not be part of a Standard Switch which has VMKernel Network Adapter that has
Management Traffic enabled.
If the criteria is not met, it throws an exception.
#>
function Invoke-TestSetup {
    # Data that is going to be passed as Configuration Data in the Integration Tests.
    $script:datacenterName = $null
    $script:datacenterLocation = $null
    $script:physicalNetworkAdapters = @()
    $script:virtualSwitchesWithPhysicalNics = @{}

    $viServer = Connect-VIServer -Server $Server -User $User -Password $Password -ErrorAction Stop
    $vmHost = Get-VMHost -Server $viServer -Name $Name -ErrorAction Stop
    $networkSystem = Get-View -Server $viServer -Id $vmHost.ExtensionData.ConfigManager.NetworkSystem -ErrorAction Stop
    $datacenter = Get-Datacenter -Server $viServer -VMHost $vmHost -ErrorAction Stop

    $script:datacenterName = $datacenter.Name

    # If the Parent of the Parent Folder is $null, the Datacenter is located in the Root Folder of the Inventory.
    if ($null -eq $datacenter.ParentFolder.Parent) {
        $script:datacenterLocation = [string]::Empty
    }
    else {
        $locationItems = @()
        $child = $datacenter.ParentFolder
        $parent = $datacenter.ParentFolder.Parent

        while ($true) {
            if ($null -eq $parent) {
                break
            }

            $locationItems += $child.Name
            $child = $parent
            $parent = $parent.Parent
        }

        # The Parent Folder of the Datacenter should be the last item in the array.
        [array]::Reverse($locationItems)

        # Folder names for Datacenter Location should be separated by '/'.
        $script:datacenterLocation = [string]::Join('/', $locationItems)
    }

    $disconnectedPhysicalNetworkAdapters = Get-VMHostNetworkAdapter -Server $viServer -VMHost $vmHost -Physical -ErrorAction Stop |
                                           Where-Object -FilterScript { $_.BitRatePerSec -eq 0 } |
                                           Select-Object -First 2
    if ($disconnectedPhysicalNetworkAdapters.Length -lt 2) {
        throw 'The Integration Tests require at least two disconnected Physical Network Adapters to be available on the ESXi node.'
    }

    $script:physicalNetworkAdapters += $disconnectedPhysicalNetworkAdapters[0].Name
    $script:physicalNetworkAdapters += $disconnectedPhysicalNetworkAdapters[1].Name

    <#
    Store the initial Standard Switches for every Physical Network Adapter in the Virtual Switches hashtable, so
    a migration can be performed after the Tests have executed. The Physical Network Adapter will be added again to
    their initial Standard Switches.
    #>
    foreach ($physicalNetworkAdapter in $disconnectedPhysicalNetworkAdapters) {
        $virtualSwitch = Get-VirtualSwitch -Server $viServer -VMHost $vmHost -ErrorAction Stop | Where-Object { $null -ne $_.Nic -and $_.Nic.Contains($physicalNetworkAdapter.Name) }
        if ($null -eq $virtualSwitch) {
            continue
        }

        $virtualSwitchName = $virtualSwitch.Name
        $virtualSwitchNicTeamingPolicy = $networkSystem.NetworkConfig.Vswitch |
                                         Where-Object { $_.Name -eq $virtualSwitch.Name } |
                                         Select-Object -ExpandProperty Spec |
                                         Select-Object -ExpandProperty Policy |
                                         Select-Object -ExpandProperty NicTeaming

        $script:virtualSwitchesWithPhysicalNics.$virtualSwitchName = @{
            Nic = $virtualSwitch.Nic
            ActiveNic = $virtualSwitchNicTeamingPolicy.NicOrder.ActiveNic
            StandbyNic = $virtualSwitchNicTeamingPolicy.NicOrder.StandbyNic
            CheckBeacon = $virtualSwitchNicTeamingPolicy.FailureCriteria.CheckBeacon
            NotifySwitches = $virtualSwitchNicTeamingPolicy.NotifySwitches
            Policy = $virtualSwitchNicTeamingPolicy.Policy
            RollingOrder = $virtualSwitchNicTeamingPolicy.RollingOrder
        }
    }

    $connectedPhysicalNetworkAdapters = Get-VMHostNetworkAdapter -Server $viServer -VMHost $vmHost -Physical -ErrorAction Stop |
                                        Where-Object -FilterScript { $_.BitRatePerSec -ne 0 }
    if ($connectedPhysicalNetworkAdapters.Length -lt 1) {
        throw 'The Integration Tests require at least one connected Physical Network Adapter to be available on the ESXi node.'
    }

    <#
    Here we retrieve the names of the Port Groups to which VMKernel Network Adapters with Management Traffic enabled are connected.
    #>
    $portGroupNamesOfVMKernelsWithManagementTrafficEnabled = Get-VMHostNetworkAdapter -Server $viServer -VMHost $vmHost -VMKernel -ErrorAction Stop |
                                                             Where-Object { $_.ManagementTrafficEnabled } |
                                                             Select-Object -ExpandProperty PortGroupName

    <#
    For connected Physical Network Adapters, we need to retrieve only one of them that meets the following criteria:
    The Physical Network Adapter should not be part of a Standard Switch or the Physical Network Adapter is part of a Standard Switch
    that does not have a VMKernel Network Adapter that has Management Traffic enabled.
    #>
    foreach ($physicalNetworkAdapter in $connectedPhysicalNetworkAdapters) {
        $virtualSwitch = Get-VirtualSwitch -Server $viServer -VMHost $vmHost -ErrorAction Stop | Where-Object { $null -ne $_.Nic -and $_.Nic.Contains($physicalNetworkAdapter.Name) }
        if ($null -eq $virtualSwitch) {
            $script:physicalNetworkAdapters += $physicalNetworkAdapter.Name
            break
        }

        $virtualPortGroups = Get-VirtualPortGroup -Server $viServer -VMHost $vmHost -VirtualSwitch $virtualSwitch -ErrorAction Stop |
                             Where-Object { $_.VirtualSwitchName -eq $virtualSwitch.Name -and $portGroupNamesOfVMKernelsWithManagementTrafficEnabled.Contains($_.Name) }
        if ($virtualPortGroups.Length -gt 0) {
            continue
        }
        else {
            $script:physicalNetworkAdapters += $physicalNetworkAdapter.Name
            $virtualSwitchName = $virtualSwitch.Name
            $virtualSwitchNicTeamingPolicy = $networkSystem.NetworkConfig.Vswitch |
                                         Where-Object { $_.Name -eq $virtualSwitch.Name } |
                                         Select-Object -ExpandProperty Spec |
                                         Select-Object -ExpandProperty Policy |
                                         Select-Object -ExpandProperty NicTeaming

            $script:virtualSwitchesWithPhysicalNics.$virtualSwitchName = @{
                Nic = $virtualSwitch.Nic
                ActiveNic = $virtualSwitchNicTeamingPolicy.NicOrder.ActiveNic
                StandbyNic = $virtualSwitchNicTeamingPolicy.NicOrder.StandbyNic
                CheckBeacon = $virtualSwitchNicTeamingPolicy.FailureCriteria.CheckBeacon
                NotifySwitches = $virtualSwitchNicTeamingPolicy.NotifySwitches
                Policy = $virtualSwitchNicTeamingPolicy.Policy
                RollingOrder = $virtualSwitchNicTeamingPolicy.RollingOrder
            }

            break
        }
    }

    Disconnect-VIServer -Server $Server -Confirm:$false -ErrorAction Stop
}

<#
.DESCRIPTION

Creates two VMKernel Network Adapters on different Distributed Port Groups and on the same Distributed Switch.
#>
function New-VMKernelNetworkAdaptersOnDistributedSwitch {
    [CmdletBinding()]

    $distributedSwitchName = $script:configurationData.AllNodes.VDSwitchName
    $managementPortGroupName = $script:configurationData.AllNodes.ManagementPortGroupName
    $vMotionPortGroupName = $script:configurationData.AllNodes.VMotionPortGroupName

    $viServer = Connect-VIServer -Server $Server -User $User -Password $Password -ErrorAction Stop
    $vmHost = Get-VMHost -Server $viServer -Name $Name -ErrorAction Stop
    $distributedSwitch = Get-VDSwitch -Server $viServer -Name $distributedSwitchName -ErrorAction Stop

    New-VMHostNetworkAdapter -Server $viServer -VMHost $vmHost -VirtualSwitch $distributedSwitch -PortGroup $managementPortGroupName -ManagementTrafficEnabled:$true -ErrorAction Stop
    New-VMHostNetworkAdapter -Server $viServer -VMHost $vmHost -VirtualSwitch $distributedSwitch -PortGroup $vMotionPortGroupName -VMotionEnabled:$true -ErrorAction Stop

    Disconnect-VIServer -Server $Server -Confirm:$false -ErrorAction Stop
}

<#
.DESCRIPTION

Retrieves the names of the VMKernel Network Adapters connected to Standard Switch used in the Integration Tests.
#>
function Get-VMKernelNetworkAdapterNamesConnectedToStandardSwitch {
    [CmdletBinding()]

    $standardSwitchName = $script:configurationData.AllNodes.StandardSwitchName
    $managementPortGroupName = $script:configurationData.AllNodes.ManagementPortGroupName
    $vMotionPortGroupName = $script:configurationData.AllNodes.VMotionPortGroupName

    $viServer = Connect-VIServer -Server $Server -User $User -Password $Password -ErrorAction Stop
    $vmHost = Get-VMHost -Server $viServer -Name $Name -ErrorAction Stop
    $standardSwitch = Get-VirtualSwitch -Server $viServer -VMHost $vmHost -Name $standardSwitchName -ErrorAction Stop
    $managementPortGroup = Get-VirtualPortGroup -Server $viServer -VMHost $vmHost -Name $managementPortGroupName -ErrorAction Stop
    $vMotionPortGroup = Get-VirtualPortGroup -Server $viServer -VMHost $vmHost -Name $vMotionPortGroupName -ErrorAction Stop

    $vmKernelNetworkAdapterWithManagementTrafficEnabled = Get-VMHostNetworkAdapter -Server $viServer -VMHost $vmHost -VirtualSwitch $standardSwitch -PortGroup $managementPortGroup -VMKernel -ErrorAction Stop
    $vmKernelNetworkAdapterWithvMotionEnabled = Get-VMHostNetworkAdapter -Server $viServer -VMHost $vmHost -VirtualSwitch $standardSwitch -PortGroup $vMotionPortGroup -VMKernel -ErrorAction Stop

    # Here we need to modify the Configuration Data passed to each Configuration to include the retrieved VMKernel Network Adapter names.
    $script:configurationData.AllNodes[0].VMKernelNetworkAdapterNames = @($vmKernelNetworkAdapterWithManagementTrafficEnabled.Name, $vmKernelNetworkAdapterWithvMotionEnabled.Name)

    Disconnect-VIServer -Server $Server -Confirm:$false -ErrorAction Stop
}

<#
.DESCRIPTION

Retrieves the names of the VMKernel Network Adapters connected to Distributed Switch used in the Integration Tests.
#>
function Get-VMKernelNetworkAdapterNamesConnectedToDistributedSwitch {
    [CmdletBinding()]

    $distributedSwitchName = $script:configurationData.AllNodes.VDSwitchName
    $managementPortGroupName = $script:configurationData.AllNodes.ManagementPortGroupName
    $vMotionPortGroupName = $script:configurationData.AllNodes.VMotionPortGroupName

    $viServer = Connect-VIServer -Server $Server -User $User -Password $Password -ErrorAction Stop
    $vmHost = Get-VMHost -Server $viServer -Name $Name -ErrorAction Stop
    $distributedSwitch = Get-VDSwitch -Server $viServer -Name $distributedSwitchName -ErrorAction Stop
    $managementPortGroup = Get-VDPortgroup -Server $viServer -Name $managementPortGroupName -VDSwitch $distributedSwitch -ErrorAction Stop
    $vMotionPortGroup = Get-VDPortgroup -Server $viServer -Name $vMotionPortGroupName -VDSwitch $distributedSwitch -ErrorAction Stop

    $vmKernelNetworkAdapterWithManagementTrafficEnabled = Get-VMHostNetworkAdapter -Server $viServer -VMHost $vmHost -VirtualSwitch $distributedSwitch -PortGroup $managementPortGroup -VMKernel -ErrorAction Stop
    $vmKernelNetworkAdapterWithvMotionEnabled = Get-VMHostNetworkAdapter -Server $viServer -VMHost $vmHost -VirtualSwitch $distributedSwitch -PortGroup $vMotionPortGroup -VMKernel -ErrorAction Stop

    # Here we need to modify the Configuration Data passed to each Configuration to include the retrieved VMKernel Network Adapter names.
    $script:configurationData.AllNodes[0].VMKernelNetworkAdapterNames = @($vmKernelNetworkAdapterWithManagementTrafficEnabled.Name, $vmKernelNetworkAdapterWithvMotionEnabled.Name)

    Disconnect-VIServer -Server $Server -Confirm:$false -ErrorAction Stop
}

<#
.DESCRIPTION

Retrieves the names of the Port Groups of the VMKernel Network Adapters used in the Integration Tests.
When no Port Group names are passed to the VMHostVssMigration DSC Resource, for every passed VMKernel Network Adapter
a new Port Group with VMKernel prefix is created and the VMKernel Network Adapter is connected to it.
#>
function Get-PortGroupNamesWithVMKernelPrefix {
    [CmdletBinding()]

    $standardSwitchName = $script:configurationData.AllNodes.StandardSwitchName
    $vmKernelNetworkAdapterWithManagementTrafficEnabledName = $script:configurationData.AllNodes.VMKernelNetworkAdapterNames[0]
    $vmKernelNetworkAdapterWithvMotionEnabledName = $script:configurationData.AllNodes.VMKernelNetworkAdapterNames[1]

    $viServer = Connect-VIServer -Server $Server -User $User -Password $Password -ErrorAction Stop
    $vmHost = Get-VMHost -Server $viServer -Name $Name -ErrorAction Stop
    $standardSwitch = Get-VirtualSwitch -Server $viServer -VMHost $vmHost -Name $standardSwitchName -ErrorAction Stop

    $vmKernelNetworkAdapterWithManagementTrafficEnabled = Get-VMHostNetworkAdapter -Server $viServer -Name $vmKernelNetworkAdapterWithManagementTrafficEnabledName -VMHost $vmHost -VirtualSwitch $standardSwitch -VMKernel -ErrorAction Stop
    $vmKernelNetworkAdapterWithvMotionEnabled = Get-VMHostNetworkAdapter -Server $viServer -Name $vmKernelNetworkAdapterWithvMotionEnabledName -VMHost $vmHost -VirtualSwitch $standardSwitch -VMKernel -ErrorAction Stop

    # Here we need to modify the Configuration Data passed to each Configuration to include the retrieved Port Group names with VMKernel prefix.
    $script:configurationData.AllNodes[0].PortGroupNamesWithVMKernelPrefix = @($vmKernelNetworkAdapterWithManagementTrafficEnabled.PortGroupName, $vmKernelNetworkAdapterWithvMotionEnabled.PortGroupName)

    Disconnect-VIServer -Server $Server -Confirm:$false -ErrorAction Stop
}

<#
.DESCRIPTION

Removes VMKernel Network Adapters connected to the same Distributed Port Group.
#>
function Remove-ManagementAndvMotionVMKernelNetworkAdaptersConnectedToTheSamePortGroup {
    [CmdletBinding()]

    $distributedSwitchName = $script:configurationData.AllNodes.VDSwitchName
    $portGroupName = $script:configurationData.AllNodes.PortGroupName

    $viServer = Connect-VIServer -Server $Server -User $User -Password $Password -ErrorAction Stop
    $vmHost = Get-VMHost -Server $viServer -Name $Name -ErrorAction Stop
    $distributedSwitch = Get-VDSwitch -Server $viServer -Name $distributedSwitchName -ErrorAction Stop
    $portGroup = Get-VDPortgroup -Server $viServer -Name $portGroupName -VDSwitch $distributedSwitch -ErrorAction Stop

    $vmKernelNetworkAdapters = Get-VMHostNetworkAdapter -Server $viServer -VMHost $vmHost -VirtualSwitch $distributedSwitch -PortGroup $portGroup -VMKernel -ErrorAction Stop
    $vmKernelNetworkAdapters | Remove-VMHostNetworkAdapter -Confirm:$false -ErrorAction Stop

    Disconnect-VIServer -Server $Server -Confirm:$false -ErrorAction Stop
}

<#
.DESCRIPTION

Removes VMKernel Network Adapters connected to different Distributed Port Groups on the same Distributed Switch.
#>
function Remove-ManagementAndvMotionVMKernelNetworkAdaptersConnectedToDifferentPortGroups {
    [CmdletBinding()]

    $distributedSwitchName = $script:configurationData.AllNodes.VDSwitchName
    $managementPortGroupName = $script:configurationData.AllNodes.ManagementPortGroupName
    $vMotionPortGroupName = $script:configurationData.AllNodes.VMotionPortGroupName

    $viServer = Connect-VIServer -Server $Server -User $User -Password $Password -ErrorAction Stop
    $vmHost = Get-VMHost -Server $viServer -Name $Name -ErrorAction Stop
    $distributedSwitch = Get-VDSwitch -Server $viServer -Name $distributedSwitchName -ErrorAction Stop
    $managementPortGroup = Get-VDPortgroup -Server $viServer -Name $managementPortGroupName -VDSwitch $distributedSwitch -ErrorAction Stop
    $vMotionPortGroup = Get-VDPortgroup -Server $viServer -Name $vMotionPortGroupName -VDSwitch $distributedSwitch -ErrorAction Stop

    $vmKernelNetworkAdapterWithManagementTrafficEnabled = Get-VMHostNetworkAdapter -Server $viServer -VMHost $vmHost -VirtualSwitch $distributedSwitch -PortGroup $managementPortGroup -VMKernel -ErrorAction Stop
    $vmKernelNetworkAdapterWithvMotionEnabled = Get-VMHostNetworkAdapter -Server $viServer -VMHost $vmHost -VirtualSwitch $distributedSwitch -PortGroup $vMotionPortGroup -VMKernel -ErrorAction Stop

    $vmKernelNetworkAdapterWithManagementTrafficEnabled | Remove-VMHostNetworkAdapter -Confirm:$false -ErrorAction Stop
    $vmKernelNetworkAdapterWithvMotionEnabled | Remove-VMHostNetworkAdapter -Confirm:$false -ErrorAction Stop

    Disconnect-VIServer -Server $Server -Confirm:$false -ErrorAction Stop
}
