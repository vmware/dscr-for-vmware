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
class VMHostVdsNic : VMHostNicBaseDSC {
    <#
    .DESCRIPTION

    Specifies the name of the VMKernel NIC connected
    to the specified Distributed Port Group on the specified VDSwitch.
    #>
    [DscProperty(Key)]
    [string] $Name

    <#
    .DESCRIPTION

    Specifies the name of the VDSwitch to which the
    VMKernel NIC is added.
    #>
    [DscProperty(Key)]
    [string] $VdsName

    <#
    .DESCRIPTION

    Specifies the instance of the 'InventoryUtil' class that is used
    for Inventory operations.
    #>
    hidden [InventoryUtil] $InventoryUtil

    hidden [string] $VMHostIsNotAddedToVDSwitchMessage = "VMHost {0} should be added to VDSwitch {1} before configuring the VMKernel NIC."
    hidden [string] $CouldNotFindVMKernelNICMessage = "VMKernel NIC {0} connected to Distributed Port Group {1} on VDSwitch {2} could not be found."

    [void] Set() {
        try {
            $this.ConnectVIServer()

            $this.WriteLogUtil('Verbose', $this.SetMethodStartMessage, @($this.DscResourceName))

            $this.EnsureConnectionIsvCenter()

            $this.InitInventoryUtil()

            $this.RetrieveVMHost()
            $vdSwitch = $this.InventoryUtil.GetVDSwitch($this.VdsName)
            $this.EnsureVMHostIsAddedToTheVDSwitch($vdSwitch)

            $vmKernelNic = $this.GetVMKernelNic($vdSwitch)
            if ($this.Ensure -eq [Ensure]::Present) {
                $this.UpdateVMHostNetworkAdapter($vmKernelNic)
            }
            else {
                if ($null -ne $vmKernelNic) {
                    $this.RemoveVMHostNetworkAdapter($vmKernelNic)
                }
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

            $this.InitInventoryUtil()

            $this.RetrieveVMHost()
            $vdSwitch = $this.InventoryUtil.GetVDSwitch($this.VdsName)
            $this.EnsureVMHostIsAddedToTheVDSwitch($vdSwitch)

            $vmKernelNic = $this.GetVMKernelNic($vdSwitch)
            $result = $null

            if ($this.Ensure -eq [Ensure]::Present) {
                $result = !$this.ShouldUpdateVMHostNetworkAdapter($vmKernelNic)
            }
            else {
                $result = ($null -eq $vmKernelNic)
            }

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.WriteLogUtil('Verbose', $this.TestMethodEndMessage, @($this.DscResourceName))

            $this.DisconnectVIServer()
        }
    }

    [VMHostVdsNic] Get() {
        try {
            $this.ConnectVIServer()

            $this.WriteLogUtil('Verbose', $this.GetMethodStartMessage, @($this.DscResourceName))

            $result = [VMHostVdsNic]::new()

            $this.EnsureConnectionIsvCenter()

            $this.InitInventoryUtil()

            $this.RetrieveVMHost()
            $vdSwitch = $this.InventoryUtil.GetVDSwitch($this.VdsName)
            $this.EnsureVMHostIsAddedToTheVDSwitch($vdSwitch)

            $vmKernelNic = $this.GetVMKernelNic($vdSwitch)
            if ($null -eq $vmKernelNic) {
                $result.VdsName = $this.VdsName
                $result.Name = $this.Name
            }
            else {
                $result.VdsName = $vdSwitch.Name
                $result.Name = $vmKernelNic.Name
            }

            $this.PopulateResult($vmKernelNic, $result)

            return $result
        }
        finally {
            $this.WriteLogUtil('Verbose', $this.GetMethodEndMessage, @($this.DscResourceName))

            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Initializes an instance of the 'InventoryUtil' class.
    #>
    [void] InitInventoryUtil() {
        if ($null -eq $this.InventoryUtil) {
            $this.InventoryUtil = [InventoryUtil]::new($this.Connection, $this.Ensure)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the VMKernel NIC connected to the specified Distributed Port Group and added
    to the specified VDSwitch from the server if it exists,
    otherwise the method returns $null.
    #>
    [PSObject] GetVMKernelNic($vdSwitch) {
        if ($null -eq $vdSwitch) {
            <#
                If the VDSwitch is $null, it means that Ensure was set to 'Absent' and
                the VMKernel NIC is not added to the specified VDSwitch.
            #>
            return $null
        }

        $getVMHostNetworkAdapterParams = @{
            Server = $this.Connection
            VMHost = $this.VMHost
            Name = $this.Name
            VirtualSwitch = $vdSwitch
            PortGroup = $this.PortGroupName
            VMKernel = $true
            ErrorAction = 'SilentlyContinue'
            Verbose = $false
        }

        $vmKernelNic = Get-VMHostNetworkAdapter @getVMHostNetworkAdapterParams
        if ($this.Ensure -eq [Ensure]::Present -and $null -eq $vmKernelNic) {
            throw ($this.CouldNotFindVMKernelNICMessage -f $this.Name, $this.PortGroupName, $vdSwitch.Name)
        }

        return $vmKernelNic
    }

    <#
    .DESCRIPTION

    Checks if the specified VMHost is part of the specified VDSwitch
    and if not, throws an exception.
    #>
    [void] EnsureVMHostIsAddedToTheVDSwitch($vdSwitch) {
        if ($null -eq $vdSwitch) {
            <#
                If the VDSwitch is $null, it means that Ensure was set to 'Absent' and
                the VMKernel NIC does not exist for the specified VDSwitch.
                So there is no need to ensure that the VMHost is part of the VDSwitch.
            #>
            return
        }

        $whereObjectParams = @{
            FilterScript = {
                $_.DvsName -eq $vdSwitch.Name
            }
        }

        $addedVMHost = $this.VMHost.ExtensionData.Config.Network.ProxySwitch | Where-Object @whereObjectParams
        if ($null -eq $addedVMHost) {
            throw ($this.VMHostIsNotAddedToVDSwitchMessage -f $this.VMHost.Name, $vdSwitch.Name)
        }
    }
}
