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
class VMHostVssMigration : VMHostNetworkMigrationBaseDSC {
    <#
    .DESCRIPTION

    Specifies the name of the Standard Switch to which the passed Physical Network Adapters, VMKernel Network Adapters and Port Groups should be part of.
    #>
    [DscProperty(Key)]
    [string] $VssName

    <#
    .DESCRIPTION

    Specifies the names of the Port Groups to which the specified VMKernel Network Adapters should be attached. Accepts the same number of
    Port Groups as the number of VMKernel Network Adapters specified. The first Adapter is attached to the first Port Group,
    the second Adapter to the second Port Group, and so on.
    #>
    [DscProperty()]
    [string[]] $PortGroupNames

    [void] Set() {
        try {
            $this.ConnectVIServer()
            $this.EnsureConnectionIsvCenter()

            $this.RetrieveVMHost()
            $standardSwitch = $this.GetStandardSwitch()

            $physicalNetworkAdapters = $this.GetPhysicalNetworkAdapters()
            if ($this.VMkernelNicNames.Length -eq 0) {
                $this.AddPhysicalNetworkAdaptersToStandardSwitch($physicalNetworkAdapters, $standardSwitch)
            }
            else {
                $vmKernelNetworkAdapters = $this.GetVMKernelNetworkAdapters()
                $this.EnsureVMKernelNetworkAdapterAndPortGroupNamesCountIsCorrect()

                $this.AddPhysicalNetworkAdaptersAndVMKernelNetworkAdaptersToStandardSwitch($physicalNetworkAdapters, $vmKernelNetworkAdapters, $standardSwitch)
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
            $standardSwitch = $this.GetStandardSwitch()

            if ($this.ShouldAddPhysicalNetworkAdaptersToStandardSwitch($standardSwitch)) {
                return $false
            }

            if ($this.VMkernelNicNames.Length -eq 0 -and $this.PortGroupNames.Length -eq 0) {
                return $true
            }
            else {
                return !$this.ShouldAddVMKernelNetworkAdaptersAndPortGroupsToStandardSwitch($standardSwitch)
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostVssMigration] Get() {
        try {
            $result = [VMHostVssMigration]::new()

            $this.ConnectVIServer()
            $this.EnsureConnectionIsvCenter()

            $this.RetrieveVMHost()
            $standardSwitch = $this.GetStandardSwitch()

            $this.PopulateResult($standardSwitch, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Standard Switch with the specified name from the specified VMHost if it exists.
    Otherwise it throws an exception.
    #>
    [PSObject] GetStandardSwitch() {
        try {
            $standardSwitch = Get-VirtualSwitch -Server $this.Connection -Name $this.VssName -VMHost $this.VMHost -Standard -ErrorAction Stop
            return $standardSwitch
        }
        catch {
            throw "Could not retrieve Standard Switch $($this.VssName). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Checks if all passed Physical Network Adapters are added to the Standard Switch.
    #>
    [bool] ShouldAddPhysicalNetworkAdaptersToStandardSwitch($standardSwitch) {
        $physicalNetworkAdapters = $this.GetPhysicalNetworkAdapters()
        if ($physicalNetworkAdapters.Length -eq 0) {
            throw 'At least one Physical Network Adapter needs to be specified.'
        }

        if ($null -eq $standardSwitch.Nic) {
            # No Physical Network Adapters are added to the Standard Switch.
            return $true
        }

        foreach ($physicalNetworkAdapter in $physicalNetworkAdapters) {
            $addedPhysicalNetworkAdapter = $standardSwitch.Nic | Where-Object -FilterScript { $_ -eq $physicalNetworkAdapter.Name }
            if ($null -eq $addedPhysicalNetworkAdapter) {
                return $true
            }
        }

        return $false
    }

    <#
    .DESCRIPTION

    Checks if all passed VMKernel Network Adapters and Port Groups are added to the Standard Switch.
    #>
    [bool] ShouldAddVMKernelNetworkAdaptersAndPortGroupsToStandardSwitch($standardSwitch) {
        $this.EnsureVMKernelNetworkAdapterAndPortGroupNamesCountIsCorrect()

        for ($i = 0; $i -lt $this.VMKernelNicNames.Length; $i++) {
            $vmKernelNetworkAdapterName = $this.VMKernelNicNames[$i]

            $getVMHostNetworkAdapterParams = @{
                Server = $this.Connection
                Name = $vmKernelNetworkAdapterName
                VMHost = $this.VMHost
                VirtualSwitch = $standardSwitch
                VMKernel = $true
                ErrorAction = 'SilentlyContinue'
            }

            if ($this.PortGroupNames.Length -gt 0) {
                $getVMHostNetworkAdapterParams.PortGroup = $this.PortGroupNames[$i]
            }

            $vmKernelNetworkAdapter = Get-VMHostNetworkAdapter @getVMHostNetworkAdapterParams
            if ($null -eq $vmKernelNetworkAdapter) {
                return $true
            }
        }

        return $false
    }

    <#
    .DESCRIPTION

    Ensures that the passed VMKernel Network Adapter names and Port Group names count meets the following criteria:
    If VMKernel Network Adapter names are passed, the following requirements should be met:
    No Port Group names are passed or the number of Port Group names is the same as the number of VMKernel Network Adapter names.
    If no VMKernel Network Adapter names are passed, no Port Group names should be passed as well.
    #>
    [void] EnsureVMKernelNetworkAdapterAndPortGroupNamesCountIsCorrect() {
        if ($this.VMKernelNicNames.Length -gt 0) {
            if ($this.PortGroupNames.Length -gt 0 -and $this.VMkernelNicNames.Length -ne $this.PortGroupNames.Length) {
                throw "$($this.VMKernelNicNames.Length) VMKernel Network Adapters specified and $($this.PortGroupNames.Length) Port Groups specified which is not valid."
            }
        }
        else {
            if ($this.PortGroupNames.Length -gt 0) {
                throw "$($this.VMKernelNicNames.Length) VMKernel Network Adapters specified and $($this.PortGroupNames.Length) Port Groups specified which is not valid."
            }
        }
    }

    <#
    .DESCRIPTION

    Ensures that the specified Standard Port Groups exist. If a Standard Port Group is specified and does not exist,
    it is created on the specified Standard Switch.
    #>
    [void] EnsureStandardPortGroupsExist($standardSwitch) {
        foreach ($standardPortGroupName in $this.PortGroupNames) {
            $standardPortGroup = Get-VirtualPortGroup -Server $this.Connection -Name $standardPortGroupName -VirtualSwitch $standardSwitch -Standard -ErrorAction SilentlyContinue
            if ($null -eq $standardPortGroup) {
                try {
                    New-VirtualPortGroup -Server $this.Connection -Name $standardPortGroupName -VirtualSwitch $standardSwitch -Confirm:$false -ErrorAction Stop
                }
                catch {
                    throw "Cannot create Standard Port Group $standardPortGroupName on Standard Switch $($standardSwitch.Name). For more information: $($_.Exception.Message)"
                }
            }
        }
    }

    <#
    .DESCRIPTION

    Adds the Physical Network Adapters to the specified Standard Switch.
    #>
    [void] AddPhysicalNetworkAdaptersToStandardSwitch($physicalNetworkAdapters, $standardSwitch) {
        try {
            $addVirtualSwitchPhysicalNetworkAdapterParams = @{
                Server = $this.Connection
                VirtualSwitch = $standardSwitch
                VMHostPhysicalNic = $physicalNetworkAdapters
                Confirm = $false
                ErrorAction = 'Stop'
            }

            Add-VirtualSwitchPhysicalNetworkAdapter @addVirtualSwitchPhysicalNetworkAdapterParams
        }
        catch {
            throw "Could not migrate Physical Network Adapters $($physicalNetworkAdapters) to Standard Switch $($standardSwitch.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Adds the Physical Network Adapters and VMKernel Network Adapters to the specified Standard Switch.
    #>
    [void] AddPhysicalNetworkAdaptersAndVMKernelNetworkAdaptersToStandardSwitch($physicalNetworkAdapters, $vmKernelNetworkAdapters, $standardSwitch) {
        $this.EnsureStandardPortGroupsExist($standardSwitch)

        try {
            $addVirtualSwitchPhysicalNetworkAdapterParams = @{
                Server = $this.Connection
                VirtualSwitch = $standardSwitch
                VMHostPhysicalNic = $physicalNetworkAdapters
                VMHostVirtualNic = $vmKernelNetworkAdapters
                Confirm = $false
                ErrorAction = 'Stop'
            }

            if ($this.PortGroupNames.Length -gt 0) {
                $addVirtualSwitchPhysicalNetworkAdapterParams.VirtualNicPortgroup = $this.PortGroupNames
            }

            Add-VirtualSwitchPhysicalNetworkAdapter @addVirtualSwitchPhysicalNetworkAdapterParams
        }
        catch {
            throw "Could not migrate Physical Network Adapters $($physicalNetworkAdapters) and VMKernel Network Adapters $($vmKernelNetworkAdapters) to Standard Switch $($standardSwitch.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method.
    #>
    [void] PopulateResult($standardSwitch, $result) {
        $result.Server = $this.Connection.Name
        $result.VMHostName = $this.VMHost.Name
        $result.VssName = $standardSwitch.Name
        $result.PhysicalNicNames = $standardSwitch.Nic
        $result.VMkernelNicNames = @()
        $result.PortGroupNames = @()

        if ($this.VMKernelNicNames.Length -eq 0) {
            return
        }

        $vmKernelNetworkAdapters = Get-VMHostNetworkAdapter -Server $this.Connection -VMHost $this.VMHost -VirtualSwitch $standardSwitch -VMKernel -ErrorAction SilentlyContinue |
                                   Where-Object -FilterScript { $this.VMKernelNicNames.Contains($_.Name) }

        foreach ($vmKernelNetworkAdapter in $vmKernelNetworkAdapters) {
            $result.VMkernelNicNames += $vmKernelNetworkAdapter.Name
            $result.PortGroupNames += $vmKernelNetworkAdapter.PortGroupName
        }
    }
}
