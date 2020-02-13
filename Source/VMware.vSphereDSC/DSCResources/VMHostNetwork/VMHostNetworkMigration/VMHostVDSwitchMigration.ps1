<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

[DscResource()]
class VMHostVDSwitchMigration : VMHostNetworkMigrationBaseDSC {
    <#
    .DESCRIPTION

    Specifies the name of the vSphere Distributed Switch to which the VMHost and its Network should be part of.
    VMHost Network consists of the passed Physical Network Adapters, VMKernel Network Adapters and Port Groups.
    #>
    [DscProperty(Key)]
    [string] $VdsName

    <#
    .DESCRIPTION

    Specifies the names of the Port Groups to which the specified VMKernel Network Adapters should be attached. Accepts either one Port Group
    or the same number of Port Groups as the number of VMKernel Network Adapters specified. If one Port Group is specified, all Adapters are attached to that Port Group.
    If the same number of Port Groups as the number of VMKernel Network Adapters are specified, the first Adapter is attached to the first Port Group,
    the second Adapter to the second Port Group, and so on.
    #>
    [DscProperty()]
    [string[]] $PortGroupNames

    [void] Set() {
        try {
            $this.ConnectVIServer()
            $this.EnsureConnectionIsvCenter()

            $this.RetrieveVMHost()
            $distributedSwitch = $this.GetDistributedSwitch()

            if (!$this.IsVMHostAddedToDistributedSwitch($distributedSwitch)) {
                $this.AddVMHostToDistributedSwitch($distributedSwitch)
            }

            $physicalNetworkAdapters = $this.GetPhysicalNetworkAdapters()
            if ($this.VMkernelNicNames.Length -eq 0) {
                $this.AddPhysicalNetworkAdaptersToDistributedSwitch($physicalNetworkAdapters, $distributedSwitch)
            }
            else {
                $vmKernelNetworkAdapters = $this.GetVMKernelNetworkAdapters()
                $this.EnsureVMKernelNetworkAdapterAndPortGroupNamesCountIsCorrect()

                $this.AddPhysicalNetworkAdaptersAndVMKernelNetworkAdaptersToDistributedSwitch($physicalNetworkAdapters, $vmKernelNetworkAdapters, $distributedSwitch)
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()
            $this.EnsureConnectionIsvCenter()

            $this.RetrieveVMHost()
            $distributedSwitch = $this.GetDistributedSwitch()

            if (!$this.IsVMHostAddedToDistributedSwitch($distributedSwitch)) {
                return $false
            }

            if ($this.ShouldAddPhysicalNetworkAdaptersToDistributedSwitch($distributedSwitch)) {
                return $false
            }

            if ($this.VMkernelNicNames.Length -eq 0 -and $this.PortGroupNames.Length -eq 0) {
                return $true
            }
            else {
                return !$this.ShouldAddVMKernelNetworkAdaptersAndPortGroupsToDistributedSwitch($distributedSwitch)
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostVDSwitchMigration] Get() {
        try {
            $result = [VMHostVDSwitchMigration]::new()

            $this.ConnectVIServer()
            $this.EnsureConnectionIsvCenter()

            $this.RetrieveVMHost()
            $distributedSwitch = $this.GetDistributedSwitch()

            $this.PopulateResult($distributedSwitch, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Distributed Switch with the specified name from the server if it exists.
    Otherwise it throws an exception.
    #>
    [PSObject] GetDistributedSwitch() {
        <#
        The Verbose logic here is needed to suppress the Exporting and Importing of the
        cmdlets from the VMware.VimAutomation.Vds Module.
        #>
        $savedVerbosePreference = $global:VerbosePreference
        $global:VerbosePreference = 'SilentlyContinue'

        try {
            $distributedSwitch = Get-VDSwitch -Server $this.Connection -Name $this.VdsName -ErrorAction Stop
            return $distributedSwitch
        }
        catch {
            throw "Could not retrieve Distributed Switch $($this.VdsName). For more information: $($_.Exception.Message)"
        }
        finally {
            $global:VerbosePreference = $savedVerbosePreference
        }
    }

    <#
    .DESCRIPTION

    Retrieves all connected Physical Network Adapters from the specified array of Physical Network Adapters.
    #>
    [array] GetConnectedPhysicalNetworkAdapters($physicalNetworkAdapters) {
        return ($physicalNetworkAdapters | Where-Object -FilterScript { $_.BitRatePerSec -ne 0 })
    }

    <#
    .DESCRIPTION

    Retrieves all disconnected Physical Network Adapters from the specified array of Physical Network Adapters.
    #>
    [array] GetDisconnectedPhysicalNetworkAdapters($physicalNetworkAdapters) {
        return ($physicalNetworkAdapters | Where-Object -FilterScript { $_.BitRatePerSec -eq 0 })
    }

    <#
    .DESCRIPTION

    Checks if the specified VMHost is part of the Distributed Switch.
    #>
    [bool] IsVMHostAddedToDistributedSwitch($distributedSwitch) {
        $addedVMHost = $this.VMHost.ExtensionData.Config.Network.ProxySwitch | Where-Object -FilterScript { $_.DvsName -eq $distributedSwitch.Name }
        return ($null -ne $addedVMHost)
    }

    <#
    .DESCRIPTION

    Checks if all passed Physical Network Adapters are added to the Distributed Switch.
    #>
    [bool] ShouldAddPhysicalNetworkAdaptersToDistributedSwitch($distributedSwitch) {
        $physicalNetworkAdapters = $this.GetPhysicalNetworkAdapters()
        if ($physicalNetworkAdapters.Length -eq 0) {
            throw 'At least one Physical Network Adapter needs to be specified.'
        }

        if ($null -eq $distributedSwitch.ExtensionData.Config.Host.Config.Backing.PnicSpec) {
            # No Physical Network Adapters are added to the Distributed Switch.
            return $true
        }

        foreach ($physicalNetworkAdapter in $physicalNetworkAdapters) {
            $addedPhysicalNetworkAdapter = $distributedSwitch.ExtensionData.Config.Host.Config.Backing.PnicSpec | Where-Object -FilterScript { $_.PNicDevice -eq $physicalNetworkAdapter.Name }
            if ($null -eq $addedPhysicalNetworkAdapter) {
                return $true
            }
        }

        return $false
    }

    <#
    .DESCRIPTION

    Checks if all passed VMKernel Network Adapters and Port Groups are added to the Distributed Switch.
    #>
    [bool] ShouldAddVMKernelNetworkAdaptersAndPortGroupsToDistributedSwitch($distributedSwitch) {
        $this.EnsureVMKernelNetworkAdapterAndPortGroupNamesCountIsCorrect()

        if ($this.PortGroupNames.Length -eq 1) {
            $portGroupName = $this.PortGroupNames[0]

            foreach ($vmKernelNetworkAdapterName in $this.VMKernelNicNames) {
                $getVMHostNetworkAdapterParams = @{
                    Server = $this.Connection
                    Name = $vmKernelNetworkAdapterName
                    VMHost = $this.VMHost
                    VirtualSwitch = $distributedSwitch
                    PortGroup = $portGroupName
                    VMKernel = $true
                    ErrorAction = 'SilentlyContinue'
                }

                $vmKernelNetworkAdapter = Get-VMHostNetworkAdapter @getVMHostNetworkAdapterParams
                if ($null -eq $vmKernelNetworkAdapter) {
                    return $true
                }
            }
        }
        else {
            for ($i = 0; $i -lt $this.VMKernelNicNames.Length; $i++) {
                $vmKernelNetworkAdapterName = $this.VMKernelNicNames[$i]
                $portGroupName = $this.PortGroupNames[$i]

                $getVMHostNetworkAdapterParams = @{
                    Server = $this.Connection
                    Name = $vmKernelNetworkAdapterName
                    VMHost = $this.VMHost
                    VirtualSwitch = $distributedSwitch
                    PortGroup = $portGroupName
                    VMKernel = $true
                    ErrorAction = 'SilentlyContinue'
                }

                $vmKernelNetworkAdapter = Get-VMHostNetworkAdapter @getVMHostNetworkAdapterParams
                if ($null -eq $vmKernelNetworkAdapter) {
                    return $true
                }
            }
        }

        return $false
    }

    <#
    .DESCRIPTION

    Ensures that the specified Distributed Port Groups exist. If a Distributed Port Group is specified and does not exist,
    it is created on the specified Distributed Switch.
    #>
    [void] EnsureDistributedPortGroupsExist($distributedSwitch) {
        foreach ($distributedPortGroupName in $this.PortGroupNames) {
            $distributedPortGroup = Get-VDPortgroup -Server $this.Connection -Name $distributedPortGroupName -VDSwitch $distributedSwitch -ErrorAction SilentlyContinue
            if ($null -eq $distributedPortGroup) {
                try {
                    New-VDPortgroup -Server $this.Connection -Name $distributedPortGroupName -VDSwitch $distributedSwitch -Confirm:$false -ErrorAction Stop
                }
                catch {
                    throw "Cannot create Distributed Port Group $distributedPortGroupName on Distributed Switch $($distributedSwitch.Name). For more information: $($_.Exception.Message)"
                }
            }
        }
    }

    <#
    .DESCRIPTION

    Ensures that the passed VMKernel Network Adapter names and Port Group names count meets the following criteria:
    If at least one VMKernel Network Adapter is specified, one of the following requirements should be met:
    1. The number of specified Port Groups should be equal to the number of specified VMKernel Network Adapters.
    2. Only one Port Group is passed.
    If no VMKernel Network Adapter names are passed, no Port Group names should be passed as well.
    #>
    [void] EnsureVMKernelNetworkAdapterAndPortGroupNamesCountIsCorrect() {
        if ($this.VMkernelNicNames.Length -gt 0) {
            if ($this.PortGroupNames.Length -eq 0 -or ($this.VMkernelNicNames.Length -ne $this.PortGroupNames.Length -and $this.PortGroupNames.Length -ne 1)) {
                throw "$($this.VMKernelNicNames.Length) VMKernel Network Adapters specified and $($this.PortGroupNames.Length) Port Groups specified which is not valid."
            }
        }
        else {
            if ($this.PortGroupNames.Length -ne 0) {
                throw "$($this.PortGroupNames.Length) Port Groups specified and no VMKernel Network Adapters specified which is not valid."
            }
        }
    }

    <#
    .DESCRIPTION

    Adds the VMHost to the specified Distributed Switch.
    #>
    [void] AddVMHostToDistributedSwitch($distributedSwitch) {
        try {
            Add-VDSwitchVMHost -Server $this.Connection -VDSwitch $distributedSwitch -VMHost $this.VMHost -Confirm:$false -ErrorAction Stop
        }
        catch {
            throw "Could not add VMHost $($this.VMHost.Name) to Distributed Switch $($distributedSwitch.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Adds the specified connected Physical Network Adapter to the specified Distributed Switch.
    #>
    [void] AddConnectedPhysicalNetworkAdapterToDistributedSwitch($connectedPhysicalNetworkAdapter, $distributedSwitch) {
        try {
            $addVDSwitchPhysicalNetworkAdapterParams = @{
                Server = $this.Connection
                DistributedSwitch = $distributedSwitch
                VMHostPhysicalNic = $connectedPhysicalNetworkAdapter
                Confirm = $false
                ErrorAction = 'Stop'
            }

            Add-VDSwitchPhysicalNetworkAdapter @addVDSwitchPhysicalNetworkAdapterParams
        }
        catch {
            throw "Could not migrate Physical Network Adapter $($connectedPhysicalNetworkAdapter.Name) to Distributed Switch $($distributedSwitch.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Adds the Physical Network Adapters to the specified Distributed Switch.
    #>
    [void] AddPhysicalNetworkAdaptersToDistributedSwitch($physicalNetworkAdapters, $distributedSwitch) {
        if ($physicalNetworkAdapters.Length -eq 1) {
            try {
                $addVDSwitchPhysicalNetworkAdapterParams = @{
                    Server = $this.Connection
                    DistributedSwitch = $distributedSwitch
                    VMHostPhysicalNic = $physicalNetworkAdapters
                    Confirm = $false
                    ErrorAction = 'Stop'
                }

                Add-VDSwitchPhysicalNetworkAdapter @addVDSwitchPhysicalNetworkAdapterParams
                return
            }
            catch {
                throw "Could not migrate Physical Network Adapter $($physicalNetworkAdapters) to Distributed Switch $($distributedSwitch.Name). For more information: $($_.Exception.Message)"
            }
        }

        $connectedPhysicalNetworkAdapters = $this.GetConnectedPhysicalNetworkAdapters($physicalNetworkAdapters)
        $disconnectedPhysicalNetworkAdapters = $this.GetDisconnectedPhysicalNetworkAdapters($physicalNetworkAdapters)

        if ($connectedPhysicalNetworkAdapters.Length -eq 0) {
            try {
                $addVDSwitchPhysicalNetworkAdapterParams = @{
                    Server = $this.Connection
                    DistributedSwitch = $distributedSwitch
                    VMHostPhysicalNic = $disconnectedPhysicalNetworkAdapters
                    Confirm = $false
                    ErrorAction = 'Stop'
                }

                Add-VDSwitchPhysicalNetworkAdapter @addVDSwitchPhysicalNetworkAdapterParams
            }
            catch {
                throw "Could not migrate Physical Network Adapters $($disconnectedPhysicalNetworkAdapters) to Distributed Switch $($distributedSwitch.Name). For more information: $($_.Exception.Message)"
            }
        }
        else {
            <#
            If they are connected Physical Network Adapters passed, we need to first move only one of them to the specified Distributed Switch and
            after that move the remaining ones. This is to ensure that the ESXi is not disconnected from the vCenter Server.
            #>
            $this.AddConnectedPhysicalNetworkAdapterToDistributedSwitch($connectedPhysicalNetworkAdapters[0], $distributedSwitch)

            # The first connected Physical Network Adapter is already migrated, so we only need the remaining connected Physical Network Adapters.
            $connectedPhysicalNetworkAdapters = $connectedPhysicalNetworkAdapters[1..($connectedPhysicalNetworkAdapters.Length - 1)]
            $physicalNetworkAdaptersToMigrate = $connectedPhysicalNetworkAdapters + $disconnectedPhysicalNetworkAdapters

            try {
                $addVDSwitchPhysicalNetworkAdapterParams = @{
                    Server = $this.Connection
                    DistributedSwitch = $distributedSwitch
                    VMHostPhysicalNic = $physicalNetworkAdaptersToMigrate
                    Confirm = $false
                    ErrorAction = 'Stop'
                }

                Add-VDSwitchPhysicalNetworkAdapter @addVDSwitchPhysicalNetworkAdapterParams
            }
            catch {
                throw "Could not migrate Physical Network Adapters $($physicalNetworkAdaptersToMigrate) to Distributed Switch $($distributedSwitch.Name). For more information: $($_.Exception.Message)"
            }
        }
    }

    <#
    .DESCRIPTION

    Adds the Physical Network Adapters and VMKernel Network Adapters to the specified Distributed Switch.
    #>
    [void] AddPhysicalNetworkAdaptersAndVMKernelNetworkAdaptersToDistributedSwitch($physicalNetworkAdapters, $vmKernelNetworkAdapters, $distributedSwitch) {
        $this.EnsureDistributedPortGroupsExist($distributedSwitch)

        if ($physicalNetworkAdapters.Length -eq 1) {
            try {
                $addVDSwitchPhysicalNetworkAdapterParams = @{
                    Server = $this.Connection
                    DistributedSwitch = $distributedSwitch
                    VMHostPhysicalNic = $physicalNetworkAdapters
                    VMHostVirtualNic = $vmKernelNetworkAdapters
                    VirtualNicPortgroup = $this.PortGroupNames
                    Confirm = $false
                    ErrorAction = 'Stop'
                }

                Add-VDSwitchPhysicalNetworkAdapter @addVDSwitchPhysicalNetworkAdapterParams
                return
            }
            catch {
                throw "Could not migrate Physical Network Adapter $($physicalNetworkAdapters) to Distributed Switch $($distributedSwitch.Name). For more information: $($_.Exception.Message)"
            }
        }

        $connectedPhysicalNetworkAdapters = $this.GetConnectedPhysicalNetworkAdapters($physicalNetworkAdapters)
        $disconnectedPhysicalNetworkAdapters = $this.GetDisconnectedPhysicalNetworkAdapters($physicalNetworkAdapters)

        if ($connectedPhysicalNetworkAdapters.Length -eq 0) {
            try {
                $addVDSwitchPhysicalNetworkAdapterParams = @{
                    Server = $this.Connection
                    DistributedSwitch = $distributedSwitch
                    VMHostPhysicalNic = $disconnectedPhysicalNetworkAdapters
                    VMHostVirtualNic = $vmKernelNetworkAdapters
                    VirtualNicPortgroup = $this.PortGroupNames
                    Confirm = $false
                    ErrorAction = 'Stop'
                }

                Add-VDSwitchPhysicalNetworkAdapter @addVDSwitchPhysicalNetworkAdapterParams
            }
            catch {
                throw "Could not migrate Physical Network Adapters $($disconnectedPhysicalNetworkAdapters) and $($vmKernelNetworkAdapters) to Distributed Switch $($distributedSwitch.Name). For more information: $($_.Exception.Message)"
            }
        }
        else {
            <#
            If they are connected Physical Network Adapters passed, we need to first move only one of them to the specified Distributed Switch and
            after that move the remaining ones. This is to ensure that the ESXi is not disconnected from the vCenter Server.
            #>
            $this.AddConnectedPhysicalNetworkAdapterToDistributedSwitch($connectedPhysicalNetworkAdapters[0], $distributedSwitch)

            # The first connected Physical Network Adapter is already migrated, so we only need the remaining connected Physical Network Adapters.
            $connectedPhysicalNetworkAdapters = $connectedPhysicalNetworkAdapters[1..($connectedPhysicalNetworkAdapters.Length - 1)]
            $physicalNetworkAdaptersToMigrate = $connectedPhysicalNetworkAdapters + $disconnectedPhysicalNetworkAdapters

            try {
                $addVDSwitchPhysicalNetworkAdapterParams = @{
                    Server = $this.Connection
                    DistributedSwitch = $distributedSwitch
                    VMHostPhysicalNic = $physicalNetworkAdaptersToMigrate
                    VMHostVirtualNic = $vmKernelNetworkAdapters
                    VirtualNicPortgroup = $this.PortGroupNames
                    Confirm = $false
                    ErrorAction = 'Stop'
                }

                Add-VDSwitchPhysicalNetworkAdapter @addVDSwitchPhysicalNetworkAdapterParams
            }
            catch {
                throw "Could not migrate Physical Network Adapters $($physicalNetworkAdaptersToMigrate) and VMKernel Network Adapters $($vmKernelNetworkAdapters) to Distributed Switch $($distributedSwitch.Name). For more information: $($_.Exception.Message)"
            }
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method.
    #>
    [void] PopulateResult($distributedSwitch, $result) {
        $result.Server = $this.Connection.Name
        $result.VMHostName = $this.VMHost.Name
        $result.VdsName = $distributedSwitch.Name

        if ($null -eq $distributedSwitch.ExtensionData.Config.Host.Config.Backing.PnicSpec) {
            $result.PhysicalNicNames = @()
        }
        else {
            $result.PhysicalNicNames = [string[]]($distributedSwitch.ExtensionData.Config.Host.Config.Backing.PnicSpec | Select-Object -ExpandProperty PNicDevice)
        }

        $result.VMkernelNicNames = @()
        $result.PortGroupNames = @()

        if ($this.VMKernelNicNames.Length -eq 0) {
            return
        }

        $vmKernelNetworkAdapters = Get-VMHostNetworkAdapter -Server $this.Connection -VMHost $this.VMHost -VirtualSwitch $distributedSwitch -VMKernel -ErrorAction SilentlyContinue |
                                   Where-Object -FilterScript { $this.VMKernelNicNames.Contains($_.Name) }

        foreach ($vmKernelNetworkAdapter in $vmKernelNetworkAdapters) {
            $result.VMkernelNicNames += $vmKernelNetworkAdapter.Name
            $result.PortGroupNames += $vmKernelNetworkAdapter.PortGroupName
        }
    }
}
