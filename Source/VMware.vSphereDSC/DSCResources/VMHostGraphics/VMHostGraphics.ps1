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
class VMHostGraphics : VMHostGraphicsBaseDSC {
    <#
    .DESCRIPTION

    Specifies the default graphics type for the specified VMHost.
    #>
    [DscProperty(Mandatory)]
    [GraphicsType] $GraphicsType

    <#
    .DESCRIPTION

    Specifies the policy for assigning shared passthrough VMs to a host graphics device.
    #>
    [DscProperty(Mandatory)]
    [SharedPassthruAssignmentPolicy] $SharedPassthruAssignmentPolicy

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

            return !$this.ShouldUpdateGraphicsConfiguration($vmHostGraphicsManager)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostGraphics] Get() {
        try {
            $result = [VMHostGraphics]::new()
            $result.Server = $this.Server
            $result.RestartTimeoutMinutes = $this.RestartTimeoutMinutes

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $vmHostGraphicsManager = $this.GetVMHostGraphicsManager($vmHost)

            $result.Name = $vmHost.Name
            $result.GraphicsType = $vmHostGraphicsManager.GraphicsConfig.HostDefaultGraphicsType
            $result.SharedPassthruAssignmentPolicy = $vmHostGraphicsManager.GraphicsConfig.SharedPassthruAssignmentPolicy

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Checks if the Graphics Configuration needs to be updated with the desired values.
    #>
    [bool] ShouldUpdateGraphicsConfiguration($vmHostGraphicsManager) {
        if ($this.GraphicsType -ne $vmHostGraphicsManager.GraphicsConfig.HostDefaultGraphicsType) {
            return $true
        }
        elseif ($this.SharedPassthruAssignmentPolicy -ne $vmHostGraphicsManager.GraphicsConfig.SharedPassthruAssignmentPolicy) {
            return $true
        }
        else {
            return $false
        }
    }

    <#
    .DESCRIPTION

    Performs an update on the Graphics Configuration of the specified VMHost.
    #>
    [void] UpdateGraphicsConfiguration($vmHostGraphicsManager) {
        $vmHostGraphicsConfig = New-Object VMware.Vim.HostGraphicsConfig

        $vmHostGraphicsConfig.HostDefaultGraphicsType = $this.ConvertEnumValueToServerValue($this.GraphicsType)
        $vmHostGraphicsConfig.SharedPassthruAssignmentPolicy = $this.ConvertEnumValueToServerValue($this.SharedPassthruAssignmentPolicy)

        try {
            Update-GraphicsConfig -VMHostGraphicsManager $vmHostGraphicsManager -VMHostGraphicsConfig $vmHostGraphicsConfig
        }
        catch {
            throw "The Graphics Configuration of VMHost $($this.Name) could not be updated: $($_.Exception.Message)"
        }
    }
}
