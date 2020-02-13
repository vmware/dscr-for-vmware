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
class VMHostPowerPolicy : VMHostBaseDSC {
    <#
    .DESCRIPTION

    Specifies the Power Management Policy for the specified VMHost.
    #>
    [DscProperty(Mandatory)]
    [PowerPolicy] $PowerPolicy

    [void] Set() {
        try {
            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $vmHostPowerSystem = $this.GetVMHostPowerSystem($vmHost)

            $this.UpdatePowerPolicy($vmHostPowerSystem)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $currentPowerPolicy = $vmHost.ExtensionData.Config.PowerSystemInfo.CurrentPolicy

            return ($this.PowerPolicy -eq $currentPowerPolicy.Key)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostPowerPolicy] Get() {
        try {
            $result = [VMHostPowerPolicy]::new()
            $result.Server = $this.Server

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $currentPowerPolicy = $vmHost.ExtensionData.Config.PowerSystemInfo.CurrentPolicy

            $result.Name = $vmHost.Name
            $result.PowerPolicy = $currentPowerPolicy.Key

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Power System of the specified VMHost from the server.
    #>
    [PSObject] GetVMHostPowerSystem($vmHost) {
        try {
            $vmHostPowerSystem = Get-View -Server $this.Connection -Id $vmHost.ExtensionData.ConfigManager.PowerSystem -ErrorAction Stop
            return $vmHostPowerSystem
        }
        catch {
            throw "Could not retrieve the Power System of VMHost $($vmHost.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Performs an update on the Power Management Policy of the specified VMHost.
    #>
    [void] UpdatePowerPolicy($vmHostPowerSystem) {
        try {
            Update-PowerPolicy -VMHostPowerSystem $vmHostPowerSystem -PowerPolicy $this.PowerPolicy
        }
        catch {
            throw "The Power Policy of VMHost $($this.Name) could not be updated: $($_.Exception.Message)"
        }
    }
}
