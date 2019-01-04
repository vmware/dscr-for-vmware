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
class VMHostPowerPolicySettings : VMHostBaseDSC {
    <#
    .DESCRIPTION

    Host setting for power policy
    #>
    [DscProperty(Mandatory)]
    [System.Int32] $PowerPolicy = 2

    [void] Set()
    {
        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()

        $vmHostCurrentPowerPolicy = $vmHost.ExtensionData.Config.PowerSystemInfo.CurrentPolicy
        $shouldUpdateVMHostPowerPolicy = $this.ShouldUpdateVMHostPowerPolicy($vmHostCurrentPowerPolicy)

        if ($shouldUpdateVMHostPowerPolicy)
        {
            Set-HostPowerPolicy -vmHost $vmHost -PowerPolicy $this.PowerPolicy
        }
    }

    [bool] Test()
    {
        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()
        $vmHostPowerPolicy = $vmHost.ExtensionData.Config.PowerSystemInfo.CurrentPolicy

        return !$this.ShouldUpdateVMHostPowerPolicy($vmHostPowerPolicy)
    }

    [VMHostPowerPolicySettings] Get()
    {
        $result = [VMHostPowerPolicySettings]::new()

        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()

        $result.Name = $this.Name
        $result.Server = $this.Server
        $result.PowerPolicy = $vmHost.ExtensionData.Config.PowerSystemInfo.CurrentPolicy.Key

        return $result
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if the VMHost Power policy should be updated.
    #>
    [bool] ShouldUpdateVMHostPowerPolicy($vmHostCurrentPowerPolicy)
    {
        Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Host Power Policy - Should Update from/to [{0}/{1}]" -f $vmHostCurrentPowerPolicy.Key, $this.PowerPolicy)"

        return ($this.PowerPolicy -ne $vmHostCurrentPowerPolicy.Key)
    }
}
