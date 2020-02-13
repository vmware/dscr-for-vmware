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
class VMHostPciPassthrough : VMHostRestartBaseDSC {
    <#
    .DESCRIPTION

    Specifies the Id of the PCI Device, composed of "bus:slot.function".
    #>
    [DscProperty(Key)]
    [string] $Id

    <#
    .DESCRIPTION

    Specifies whether passThru has been configured for this device.
    #>
    [DscProperty(Mandatory)]
    [bool] $Enabled

    [void] Set() {
    	try {
            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $vmHostPciPassthruSystem = $this.GetVMHostPciPassthruSystem($vmHost)
            $pciDevice = $this.GetPCIDevice($vmHostPciPassthruSystem)

            $this.EnsurePCIDeviceIsPassthruCapable($pciDevice)
            $this.EnsureVMHostIsInMaintenanceMode($vmHost)

            $this.UpdatePciPassthruConfiguration($vmHostPciPassthruSystem)
            $this.RestartVMHost($vmHost)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
    	try {
            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $vmHostPciPassthruSystem = $this.GetVMHostPciPassthruSystem($vmHost)

            $pciDevice = $this.GetPCIDevice($vmHostPciPassthruSystem)
            $this.EnsurePCIDeviceIsPassthruCapable($pciDevice)

            return ($this.Enabled -eq $pciDevice.PassthruEnabled)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostPciPassthrough] Get() {
        try {
            $result = [VMHostPciPassthrough]::new()
            $result.Server = $this.Server
            $result.RestartTimeoutMinutes = $this.RestartTimeoutMinutes

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $vmHostPciPassthruSystem = $this.GetVMHostPciPassthruSystem($vmHost)

            $pciDevice = $this.GetPCIDevice($vmHostPciPassthruSystem)
            $this.EnsurePCIDeviceIsPassthruCapable($pciDevice)

            $result.Name = $vmHost.Name
            $result.Id = $pciDevice.Id
            $result.Enabled = $pciDevice.PassthruEnabled

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Retrieves the PciPassthruSystem of the specified VMHost from the server.
    #>
    [PSObject] GetVMHostPciPassthruSystem($vmHost) {
        try {
            $vmHostPciPassthruSystem = Get-View -Server $this.Connection -Id $vmHost.ExtensionData.ConfigManager.PciPassthruSystem -ErrorAction Stop
            return $vmHostPciPassthruSystem
        }
        catch {
            throw "Could not retrieve the PciPassthruSystem of VMHost $($vmHost.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Retrieves the PCI Device with the specified Id from the server.
    #>
    [PSObject] GetPCIDevice($vmHostPciPassthruSystem) {
        $pciDevice = $vmHostPciPassthruSystem.PciPassthruInfo | Where-Object { $_.Id -eq $this.Id }
        if ($null -eq $pciDevice) {
            throw "The specified PCI Device $($this.Id) does not exist for VMHost $($this.Name)."
        }

        return $pciDevice
    }

    <#
    .DESCRIPTION

    Checks if the specified PCIDevice is Passthrough capable and if not, throws an exception.
    #>
    [void] EnsurePCIDeviceIsPassthruCapable($pciDevice) {
        if (!$pciDevice.PassthruCapable) {
            throw "Cannot configure PCI-Passthrough on incapable device $($pciDevice.Id)."
        }
    }

    <#
    .DESCRIPTION

    Performs an update on the specified PCI Device by changing its Passthru Enabled value.
    #>
    [void] UpdatePciPassthruConfiguration($vmHostPciPassthruSystem) {
        $vmHostPciPassthruConfig = New-Object VMware.Vim.HostPciPassthruConfig

        $vmHostPciPassthruConfig.Id = $this.Id
        $vmHostPciPassthruConfig.PassthruEnabled = $this.Enabled

        try {
            Update-PassthruConfig -VMHostPciPassthruSystem $vmHostPciPassthruSystem -VMHostPciPassthruConfig $vmHostPciPassthruConfig
        }
        catch {
            throw "The Update operation of PCI Device $($this.Id) failed with the following error: $($_.Exception.Message)"
        }
    }
}
