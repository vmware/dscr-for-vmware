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
class VMHostService : VMHostBaseDSC {
    <#
    .DESCRIPTION

    Host Service key.
    #>
    [DscProperty(Mandatory)]
    [string]$Key

    <#
    .DESCRIPTION

    Host Service Policy.
    #>
    [DscProperty()]
    [ServicePolicy]$Policy

    <#
    .DESCRIPTION

    Host Service Running State.
    #>
    [DscProperty()]
    [bool]$Running

    <#
    .DESCRIPTION

    Host Service Label.
    #>
    [DscProperty(NotConfigurable)]
    [string]$Label

    <#
    .DESCRIPTION

    Host Service Required flag.
    #>
    [DscProperty(NotConfigurable)]
    [bool]$Required

    <#
    .DESCRIPTION

    Firewall rule set.
    #>
    [DscProperty(NotConfigurable)]
    [string[]]$Ruleset

    [void]Set() {
        Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()

        $this.UpdateVMHostService($vmHost)
    }

    [bool]Test() {
        Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()

        return !$this.ShouldUpdateVMHostService($vmHost)
    }

    [VMHostService]Get() {
        Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

        $vmHostService = [VMHostService]::new()
        $vmHostService.Server = $this.Server

        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()
        $this.PopulateResult($vmHost, $vmHostService)

        return $vmHostService
    }

    <#
    .DESCRIPTION

    Returns a boolean value if the VMHostService needs to be updated.
    #>
    [bool]ShouldUpdateVMHostService($vmHost) {
        Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

        $vmHostCurrentService = Get-VMHostService -Server $this.Connection -VMHost $vmHost | Where-Object {$_.Key -eq $this.Key}

        $shouldUpdateVMHostService = @()
        $shouldUpdateVMHostService += $this.Policy -ne $vmHostCurrentService.Policy
        $shouldUpdateVMHostService += $this.Running -ne $vmHostCurrentService.Running

        return ($shouldUpdateVMHostService -Contains $true)
    }

    <#
    .DESCRIPTION

    Updates the configuration of the VMHostService
    #>
    [void] UpdateVMHostService($vmHost) {
        Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

        $vmHostCurrentService = Get-VMHostService -Server $this.Connection -VMHost $vmHost | Where-Object {$_.Key -eq $this.Key}

        if ($vmHostCurrentService.Policy -ne $this.Policy) {
            Set-VMHostService -HostService $vmHostCurrentService -Policy $this.Policy.ToString() -Confirm:$false
        }

        if ($vmHostCurrentService.Running -ne $this.Running) {
            if ($vmHostCurrentService.Running) {
                Stop-VMHostService -HostService $vmHostCurrentService -Confirm:$false
            }
            else {
                Start-VMHostService -HostService $vmHostCurrentService -Confirm:$false
            }
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the VMHostService.
    #>
    [void] PopulateResult($vmHost, $vmHostService) {
        Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

        $vmHostCurrentService = Get-VMHostService -Server $this.Connection -VMHost $vmHost | Where-Object {$_.Key -eq $this.Key}
        $vmHostService.Key = $vmHostCurrentService.Key
        $vmHostService.Policy = $vmHostCurrentService.Policy
        $vmHostService.Running = $vmHostCurrentService.Running
        $vmHostService.Label = $vmHostCurrentService.Label
        $vmHostService.Required = $vmHostCurrentService.Required
        $vmHostService.Ruleset = $vmHostCurrentService.Ruleset
    }
}
