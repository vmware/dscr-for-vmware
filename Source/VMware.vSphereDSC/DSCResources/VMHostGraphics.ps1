<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

[DscResource()]
class VMHostGraphics : VMHostBaseDSC {
    <#
    .DESCRIPTION

    Specifies the default graphics type for the specified VMHost. This default value is overridden if an individual device graphics type is specified.
    If the specified VMHost supports a single graphics type, specifying an individual graphics device is optional.
    #>
    [DscProperty(Mandatory)]
    [GraphicsType] $DefaultGraphicsType

    <#
    .DESCRIPTION

    Specifies the policy for assigning shared passthrough VMs to a host graphics device.
    #>
    [DscProperty(Mandatory)]
    [SharedPassthruAssignmentPolicy] $SharedPassthruAssignmentPolicy

    <#
    .DESCRIPTION

    Specifies the Graphics device identifier (ex. PCI ID).
    #>
    [DscProperty()]
    [string] $DeviceId

    <#
    .DESCRIPTION

    Specifies the graphics type for the specified Device in 'DeviceId' property.
    #>
    [DscProperty()]
    [GraphicsType] $DeviceGraphicsType = [GraphicsType]::Unset

    [void] Set() {
    	$this.ConnectVIServer()
        $vmHost = $this.GetVMHost()
        $vmHostGraphicsManager = $this.GetVMHostGraphicsManager($vmHost)

        $this.EnsureVMHostIsInMaintenanceMode($vmHost)
        $this.UpdateGraphicsConfiguration($vmHostGraphicsManager)
        $this.RestartVMHost($vmHost)
    }

    [bool] Test() {
    	$this.ConnectVIServer()
        $vmHost = $this.GetVMHost()
        $vmHostGraphicsManager = $this.GetVMHostGraphicsManager($vmHost)

        return !$this.ShouldUpdateGraphicsConfiguration($vmHostGraphicsManager)
    }

    [VMHostGraphics] Get() {
        $result = [VMHostGraphics]::new()
        $result.Server = $this.Server

    	$this.ConnectVIServer()
        $vmHost = $this.GetVMHost()
        $vmHostGraphicsManager = $this.GetVMHostGraphicsManager($vmHost)

        $result.Name = $vmHost.Name
        $this.PopulateResult($vmHostGraphicsManager, $result)

        return $result
    }

    <#
    .DESCRIPTION

    Retrieves the Graphics Manager of the specified VMHost from the server.
    #>
    [PSObject] GetVMHostGraphicsManager($vmHost) {
        try {
            $vmHostGraphicsManager = Get-View -Server $this.Connection -Id $vmHost.ExtensionData.ConfigManager.GraphicsManager -ErrorAction Stop
            return $vmHostGraphicsManager
        }
        catch {
            throw "Could not retrieve the Graphics Manager of VMHost $($vmHost.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Graphics Device with the specified Id from the server.
    #>
    [PSObject] GetGraphicsDevice($vmHostGraphicsManager) {
        $foundDevice = $vmHostGraphicsManager.GraphicsConfig.DeviceType | Where-Object { $_.DeviceId -eq $this.DeviceId }
        if ($null -eq $foundDevice) {
            throw "Device $($this.DeviceId) was not found in the available Graphics devices."
        }

        return $foundDevice
    }

    <#
    .DESCRIPTION

    Checks if the Graphics Configuration needs to be updated with the desired values.
    #>
    [bool] ShouldUpdateGraphicsConfiguration($vmHostGraphicsManager) {
        if ($this.DefaultGraphicsType -ne $vmHostGraphicsManager.GraphicsConfig.HostDefaultGraphicsType) {
            return $true
        }
        elseif ($this.SharedPassthruAssignmentPolicy -ne $vmHostGraphicsManager.GraphicsConfig.SharedPassthruAssignmentPolicy) {
            return $true
        }

        if (![string]::IsNullOrEmpty($this.DeviceId)) {
            if ($this.DeviceGraphicsType -eq [GraphicsType]::Unset) {
                throw "Graphics Type for Device $($this.DeviceId) is not passed."
            }

            $foundDevice = $this.GetGraphicsDevice($vmHostGraphicsManager)
            if ($this.DeviceGraphicsType -ne $foundDevice.GraphicsType) {
                return $true
            }
        }

        return $false
    }

    <#
    .DESCRIPTION

    The enum value passed in the Configuration should be converted to string value by the following criteria:
    Shared => shared; SharedDevice => sharedDevice
    #>
    [string] ConvertEnumValueToServerValue($enumValue) {
        return $enumValue.ToString().Substring(0, 1).ToLower() + $enumValue.ToString().Substring(1)
    }

    <#
    .DESCRIPTION

    Performs an update on the Graphics Configuration of the specified VMHost.
    A Graphics Device will be included in the Graphics Configuration only if both Device Id and Device Graphics Type are passed.
    #>
    [void] UpdateGraphicsConfiguration($vmHostGraphicsManager) {
        $vmHostGraphicsConfig = New-Object VMware.Vim.HostGraphicsConfig

        $vmHostGraphicsConfig.HostDefaultGraphicsType = $this.ConvertEnumValueToServerValue($this.DefaultGraphicsType)
        $vmHostGraphicsConfig.SharedPassthruAssignmentPolicy = $this.ConvertEnumValueToServerValue($this.SharedPassthruAssignmentPolicy)

        if (![string]::IsNullOrEmpty($this.DeviceId)) {
            if ($this.DeviceGraphicsType -eq [GraphicsType]::Unset) {
                throw "Graphics Type for Device $($this.DeviceId) is not passed."
            }
            else {
                <#
                The method is called here to ensure that the passed Graphics Device Id points
                to an existing Graphics Device before populating the Config Object. This way an
                exception is thrown on the client before going to the Server. The output of the method
                is not needed here so it is piped to the 'Out-Null' cmdlet.
                #>
                $this.GetGraphicsDevice($vmHostGraphicsManager) | Out-Null

                $vmHostGraphicsConfig.DeviceType = @()

                $vmHostGraphicsConfigDeviceType = New-Object VMware.Vim.HostGraphicsConfigDeviceType
                $vmHostGraphicsConfigDeviceType.DeviceId = $this.DeviceId
                $vmHostGraphicsConfigDeviceType.GraphicsType = $this.ConvertEnumValueToServerValue($this.DeviceGraphicsType)

                $vmHostGraphicsConfig.DeviceType += $vmHostGraphicsConfigDeviceType
            }
        }

        try {
            Update-GraphicsConfig -VMHostGraphicsManager $vmHostGraphicsManager -VMHostGraphicsConfig $vmHostGraphicsConfig
        }
        catch {
            throw "The Graphics Configuration of VMHost $($this.Name) could not be updated: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the Graphics Configuration from the server.
    #>
    [void] PopulateResult($vmHostGraphicsManager, $result) {
        $result.DefaultGraphicsType = $vmHostGraphicsManager.GraphicsConfig.HostDefaultGraphicsType
        $result.SharedPassthruAssignmentPolicy = $vmHostGraphicsManager.GraphicsConfig.SharedPassthruAssignmentPolicy

        if (![string]::IsNullOrEmpty($this.DeviceId)) {
            $foundDevice = $this.GetGraphicsDevice($vmHostGraphicsManager)

            $result.DeviceId = $foundDevice.DeviceId
            $result.DeviceGraphicsType = $foundDevice.GraphicsType
        }
        else {
            $result.DeviceId = $null
            $result.DeviceGraphicsType = [GraphicsType]::Unset
        }
    }
}
