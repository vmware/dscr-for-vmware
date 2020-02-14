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
class VMHostGraphicsDevice : VMHostGraphicsBaseDSC {
    <#
    .DESCRIPTION

    Specifies the Graphics device identifier (ex. PCI ID).
    #>
    [DscProperty(Key)]
    [string] $Id

    <#
    .DESCRIPTION

    Specifies the graphics type for the specified Device in 'Id' property.
    #>
    [DscProperty(Mandatory)]
    [GraphicsType] $GraphicsType

    [void] Set() {
    	try {
            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $vmHostGraphicsManager = $this.GetVMHostGraphicsManager($vmHost)

            $this.EnsureVMHostIsInMaintenanceMode($vmHost)
            $this.UpdateGraphicsConfiguration($vmHostGraphicsManager)
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
            $vmHostGraphicsManager = $this.GetVMHostGraphicsManager($vmHost)
            $foundDevice = $this.GetGraphicsDevice($vmHostGraphicsManager)

            return ($this.GraphicsType -eq $foundDevice.GraphicsType)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostGraphicsDevice] Get() {
        try {
            $result = [VMHostGraphicsDevice]::new()
            $result.Server = $this.Server
            $result.RestartTimeoutMinutes = $this.RestartTimeoutMinutes

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $vmHostGraphicsManager = $this.GetVMHostGraphicsManager($vmHost)
            $foundDevice = $this.GetGraphicsDevice($vmHostGraphicsManager)

            $result.Name = $vmHost.Name
            $result.Id = $foundDevice.DeviceId
            $result.GraphicsType = $foundDevice.GraphicsType

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Graphics Device with the specified Id from the server.
    #>
    [PSObject] GetGraphicsDevice($vmHostGraphicsManager) {
        $foundDevice = $vmHostGraphicsManager.GraphicsConfig.DeviceType | Where-Object { $_.DeviceId -eq $this.Id }
        if ($null -eq $foundDevice) {
            throw "Device $($this.Id) was not found in the available Graphics devices."
        }

        return $foundDevice
    }

    <#
    .DESCRIPTION

    Performs an update on the Graphics Configuration of the specified VMHost by changing the Graphics Type for the
    specified Device.
    #>
    [void] UpdateGraphicsConfiguration($vmHostGraphicsManager) {
        $vmHostGraphicsConfig = New-Object VMware.Vim.HostGraphicsConfig

        $vmHostGraphicsConfig.HostDefaultGraphicsType = $vmHostGraphicsManager.GraphicsConfig.HostDefaultGraphicsType
        $vmHostGraphicsConfig.SharedPassthruAssignmentPolicy = $vmHostGraphicsManager.GraphicsConfig.SharedPassthruAssignmentPolicy
        $vmHostGraphicsConfig.DeviceType = @()

        $vmHostGraphicsConfigDeviceType = New-Object VMware.Vim.HostGraphicsConfigDeviceType
        $vmHostGraphicsConfigDeviceType.DeviceId = $this.Id
        $vmHostGraphicsConfigDeviceType.GraphicsType = $this.ConvertEnumValueToServerValue($this.GraphicsType)

        $vmHostGraphicsConfig.DeviceType += $vmHostGraphicsConfigDeviceType

        try {
            Update-GraphicsConfig -VMHostGraphicsManager $vmHostGraphicsManager -VMHostGraphicsConfig $vmHostGraphicsConfig
        }
        catch {
            throw "The Graphics Configuration of VMHost $($this.Name) could not be updated: $($_.Exception.Message)"
        }
    }
}
