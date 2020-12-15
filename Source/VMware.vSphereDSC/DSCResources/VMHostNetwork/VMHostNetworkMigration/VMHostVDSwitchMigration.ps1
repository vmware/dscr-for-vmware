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

    <#
    .DESCRIPTION

    Specifies whether the user wants to migrate only the Physical Network
    Adapters when no VMKernel Network Adapters are specified. Migrating a
    Physical Network Adapter that takes care of the Management traffic without a
    VMKernel Network Adapter could result in an ESXi network connectivity loss.
    #>
    [DscProperty()]
    [nullable[bool]] $MigratePhysicalNicsOnly

    hidden [string] $RetrieveVDSwitchMessage = "Retrieving VDSwitch {0} from vCenter {1}."
    hidden [string] $CreateVDPortGroupMessage = "Creating VDPortGroup {0} on VDSwitch {1}."
    hidden [string] $AddVDSwitchToVMHostMessage = "Adding VDSwitch {0} to VMHost {1}."
    hidden [string] $AddPhysicalNicsToVDSwitchMessage = "Migrating Physical Network Adapters {0} to VDSwitch {1}."
    hidden [string] $AddPhysicalNicsAndVMKernelNicsToVDSwitchMessage = "Migrating Physical Network Adapters {0} and VMKernel Network Adapters {1} to VDSwitch {2}."

    hidden [string] $MigratePhysicalNicsOnlyNotSpecified = "When migrating Physical Network Adapters without VMKernel Network Adapters, the MigratePhysicalNicsOnly parameter should be specified in order for the migration to occur."

    hidden [string] $CouldNotRetrieveVDSwitchMessage = "Could not retrieve VDSwitch {0}. For more information: {1}"
    hidden [string] $CouldNotCreateVDPortGroupMessage = "Could not create VDPortGroup {0} on VDSwitch {1}. For more information: {2}"
    hidden [string] $CouldNotAddVDSwitchToVMHostMessage = "Could not add VDSwitch {0} to VMHost {1}. For more information: {2}"
    hidden [string] $CouldNotAddPhysicalNicsToVDSwitchMessage = "Could not migrate Physical Network Adapters {0} to VDSwitch {1}. For more information: {2}"
    hidden [string] $CouldNotAddPhysicalNicsAndVMKernelNicsToVDSwitchMessage = "Could not migrate Physical Network Adapters {0} and VMKernel Network Adapters {1} to VDSwitch {2}. For more information: {3}"

    [void] Set() {
        try {
            $this.ConnectVIServer()

            $this.WriteLogUtil('Verbose', $this.SetMethodStartMessage, @($this.DscResourceName))

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
            $this.WriteLogUtil('Verbose', $this.SetMethodEndMessage, @($this.DscResourceName))

            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()

            $this.WriteLogUtil('Verbose', $this.TestMethodStartMessage, @($this.DscResourceName))

            $this.EnsureConnectionIsvCenter()

            $this.RetrieveVMHost()
            $distributedSwitch = $this.GetDistributedSwitch()

            $result = $null

            if (!$this.IsVMHostAddedToDistributedSwitch($distributedSwitch)) {
                $result = $false
            }

            # The $null checks ensure that the desired state has not been determined yet from the previous statements.
            if ($null -eq $result -and $this.ShouldAddPhysicalNetworkAdaptersToDistributedSwitch($distributedSwitch)) {
                $result = $false
            }

            if ($null -eq $result -and $this.VMkernelNicNames.Length -eq 0 -and $this.PortGroupNames.Length -eq 0) {
                $result = $true
            }
            elseif ($null -eq $result) {
                $result = !$this.ShouldAddVMKernelNetworkAdaptersAndPortGroupsToDistributedSwitch($distributedSwitch)
            }

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.WriteLogUtil('Verbose', $this.TestMethodEndMessage, @($this.DscResourceName))

            $this.DisconnectVIServer()
        }
    }

    [VMHostVDSwitchMigration] Get() {
        try {
            $this.ConnectVIServer()

            $this.WriteLogUtil('Verbose', $this.GetMethodStartMessage, @($this.DscResourceName))

            $result = [VMHostVDSwitchMigration]::new()

            $this.EnsureConnectionIsvCenter()

            $this.RetrieveVMHost()
            $distributedSwitch = $this.GetDistributedSwitch()

            $this.PopulateResult($distributedSwitch, $result)

            return $result
        }
        finally {
            $this.WriteLogUtil('Verbose', $this.GetMethodEndMessage, @($this.DscResourceName))

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
            $this.WriteLogUtil('Verbose', $this.RetrieveVDSwitchMessage, @($this.VdsName, $this.Connection.Name))

            $getVDSwitchParams = @{
                Server = $this.Connection
                Name = $this.VdsName
                ErrorAction = 'Stop'
                Verbose = $false
            }

            return Get-VDSwitch @getVDSwitchParams
        }
        catch {
            throw ($this.CouldNotRetrieveVDSwitchMessage -f $this.VdsName, $_.Exception.Message)
        }
        finally {
            $global:VerbosePreference = $savedVerbosePreference
        }
    }

    <#
    .DESCRIPTION

    Creates a hashtable containing the parameters for the Add-VDSwitchPhysicalNetworkAdapter cmdlet.
    #>
    [hashtable] GetAddVDSwitchPhysicalNetworkAdapterParams($distributedSwitch, $physicalNics) {
        return @{
            Server = $this.Connection
            DistributedSwitch = $distributedSwitch
            VMHostPhysicalNic = $physicalNics
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }
    }

    <#
    .DESCRIPTION

    Creates a hashtable containing the parameters for the Add-VDSwitchPhysicalNetworkAdapter cmdlet.
    #>
    [hashtable] GetAddVDSwitchPhysicalNetworkAdapterParams($distributedSwitch, $physicalNics, $vmKernelNics, $portGroups) {
        $addVDSwitchPhysicalNetworkAdapterParams = $this.GetAddVDSwitchPhysicalNetworkAdapterParams($distributedSwitch, $physicalNics)

        $addVDSwitchPhysicalNetworkAdapterParams.VMHostVirtualNic = $vmKernelNics
        $addVDSwitchPhysicalNetworkAdapterParams.VirtualNicPortgroup = $portGroups

        return $addVDSwitchPhysicalNetworkAdapterParams
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
                    Verbose = $false
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
                    Verbose = $false
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
    [array] EnsureDistributedPortGroupsExist($distributedSwitch) {
        $portGroups = @()
        foreach ($distributedPortGroupName in $this.PortGroupNames) {
            $getVDPortGroupParams = @{
                Server = $this.Connection
                Name = $distributedPortGroupName
                VDSwitch = $distributedSwitch
                ErrorAction = 'SilentlyContinue'
                Verbose = $false
            }
            $distributedPortGroup = Get-VDPortgroup @getVDPortGroupParams
            if ($null -eq $distributedPortGroup) {
                try {
                    $this.WriteLogUtil('Verbose', $this.CreateVDPortGroupMessage, @($distributedPortGroupName, $distributedSwitch.Name))

                    $newVDPortGroupParams = @{
                        Server = $this.Connection
                        Name = $distributedPortGroupName
                        VDSwitch = $distributedSwitch
                        Confirm = $false
                        ErrorAction = 'Stop'
                        Verbose = $false
                    }
                    $distributedPortGroup = New-VDPortgroup @newVDPortGroupParams
                }
                catch {
                    throw ($this.CouldNotCreateVDPortGroupMessage -f $distributedPortGroupName, $distributedSwitch.Name, $_.Exception.Message)
                }
            }

            $portGroups += $distributedPortGroup
        }

        return $portGroups
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
            $this.WriteLogUtil('Verbose', $this.AddVDSwitchToVMHostMessage, @($distributedSwitch.Name, $this.VMHost.Name))

            $addVDSwitchVMHostParams = @{
                Server = $this.Connection
                VDSwitch = $distributedSwitch
                VMHost = $this.VMHost
                Confirm = $false
                ErrorAction = 'Stop'
                Verbose = $false
            }
            Add-VDSwitchVMHost @addVDSwitchVMHostParams
        }
        catch {
            throw ($this.CouldNotAddVDSwitchToVMHostMessage -f $distributedSwitch.Name, $this.VMHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Adds the Physical Network Adapters to the specified Distributed Switch.
    #>
    [void] AddPhysicalNetworkAdaptersToDistributedSwitch($physicalNetworkAdapters, $distributedSwitch) {
        if ($null -eq $this.MigratePhysicalNicsOnly -or !$this.MigratePhysicalNicsOnly) {
            $this.WriteLogUtil('Warning', $this.MigratePhysicalNicsOnlyNotSpecified)

            return
        }

        try {
            $this.WriteLogUtil('Verbose', $this.AddPhysicalNicsToVDSwitchMessage, @(
                ($physicalNetworkAdapters.Name -Join ', '),
                $distributedSwitch.Name
            ))

            $addVDSwitchPhysicalNetworkAdapterParams = $this.GetAddVDSwitchPhysicalNetworkAdapterParams($distributedSwitch, $physicalNetworkAdapters)

            Add-VDSwitchPhysicalNetworkAdapter @addVDSwitchPhysicalNetworkAdapterParams
        }
        catch {
            throw (
                $this.CouldNotAddPhysicalNicsToVDSwitchMessage -f @(
                    ($physicalNetworkAdapters.Name -Join ', '),
                    $distributedSwitch.Name,
                    $_.Exception.Message
                )
            )
        }
    }

    <#
    .DESCRIPTION

    Adds the Physical Network Adapters and VMKernel Network Adapters to the specified Distributed Switch.
    #>
    [void] AddPhysicalNetworkAdaptersAndVMKernelNetworkAdaptersToDistributedSwitch($physicalNetworkAdapters, $vmKernelNetworkAdapters, $distributedSwitch) {
        $portGroups = $this.EnsureDistributedPortGroupsExist($distributedSwitch)

        try {
            $this.WriteLogUtil('Verbose', $this.AddPhysicalNicsAndVMKernelNicsToVDSwitchMessage, @(
                ($physicalNetworkAdapters.Name -Join ', '),
                ($vmKernelNetworkAdapters.Name -Join ', '),
                $distributedSwitch.Name
            ))

            $addVDSwitchPhysicalNetworkAdapterParams = $this.GetAddVDSwitchPhysicalNetworkAdapterParams(
                $distributedSwitch,
                $physicalNetworkAdapters,
                $vmKernelNetworkAdapters,
                $portGroups
            )

            Add-VDSwitchPhysicalNetworkAdapter @addVDSwitchPhysicalNetworkAdapterParams
        }
        catch {
            throw (
                $this.CouldNotAddPhysicalNicsAndVMKernelNicsToVDSwitchMessage -f @(
                    ($physicalNetworkAdapters.Name -Join ', '),
                    ($vmKernelNetworkAdapters.Name -Join ', '),
                    $distributedSwitch.Name,
                    $_.Exception.Message
                )
            )
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

        $getVMHostNetworkAdapterParams = @{
            Server = $this.Connection
            VMHost = $this.VMHost
            VirtualSwitch = $distributedSwitch
            VMKernel = $true
            ErrorAction = 'SilentlyContinue'
            Verbose = $false
        }
        $vmKernelNetworkAdapters = Get-VMHostNetworkAdapter @getVMHostNetworkAdapterParams | Where-Object -FilterScript { $this.VMKernelNicNames.Contains($_.Name) }

        foreach ($vmKernelNetworkAdapter in $vmKernelNetworkAdapters) {
            $result.VMkernelNicNames += $vmKernelNetworkAdapter.Name
            $result.PortGroupNames += $vmKernelNetworkAdapter.PortGroupName
        }
    }
}
