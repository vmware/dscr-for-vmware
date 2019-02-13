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
class VMHostVssSecurity : VMHostVssBaseDSC {
    <#
    .DESCRIPTION

    The flag to indicate whether or not all traffic is seen on the port.
    #>
    [DscProperty()]
    [boolean] $AllowPromiscuous

    <#
    .DESCRIPTION

    The flag to indicate whether or not the virtual network adapter should be
    allowed to send network traffic with a different MAC address than that of
    the virtual network adapter.
    #>
    [DscProperty()]
    [boolean] $ForgedTransmits

    <#
    .DESCRIPTION

    The flag to indicate whether or not the Media Access Control (MAC) address
    can be changed.
    #>
    [DscProperty()]
    [boolean] $MacChanges

    [void] Set() {
        Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()
        $this.GetNetworkSystem($vmHost)

        $this.UpdateVssSecurity($vmHost)
    }

    [bool] Test() {
        Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()
        $this.GetNetworkSystem($vmHost)
        $vss = $this.GetVss($vmHost)

        if ($this.Ensure -eq [Ensure]::Present) {
            return ($null -ne $vss -and $this.Equals($vss))
        }
        else {
            $this.AllowPromiscuous = $false
            $this.ForgedTransmits = $true
            $this.MacChanges = $true

            return ($null -eq $vss -or $this.Equals($vss))
        }
    }

    [VMHostVssSecurity] Get() {
        Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

        $result = [VMHostVssSecurity]::new()
        $result.Server = $this.Server

        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()
        $this.GetNetworkSystem($vmHost)

        $result.Name = $vmHost.Name
        $this.PopulateResult($vmHost, $result)

        if ($null -ne $result.VssName) {
            $result.Ensure = 'Present'
        }
        else {
            $result.Ensure = 'Absent'
        }

        return $result
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if the VMHostVssSecurity should to be updated.
    #>
    [bool] Equals($vss) {
        Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

        $vssSecurityTest = @()
        $vssSecurityTest += ($vss.Spec.Policy.Security.AllowPromiscuous -eq $this.AllowPromiscuous)
        $vssSecurityTest += ($vss.Spec.Policy.Security.ForgedTransmits -eq $this.ForgedTransmits)
        $vssSecurityTest += ($vss.Spec.Policy.Security.MacChanges -eq $this.MacChanges)

        return ($vssSecurityTest -notcontains $false)
    }

    <#
    .DESCRIPTION

    Updates the configuration of the virtual switch.
    #>
    [void] UpdateVssSecurity($vmHost) {
        Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

        $vssSecurityArgs = @{
            Name = $this.VssName
            AllowPromiscuous = $this.AllowPromiscuous
            ForgedTransmits = $this.ForgedTransmits
            MacChanges = $this.MacChanges
        }
        $vss = $this.GetVss($vmHost)

        if ($this.Ensure -eq 'Present') {
            if ($this.Equals($vss)) {
                return
            }
            $vssSecurityArgs.Add('Operation', 'edit')
        }
        else {
            $vssSecurityArgs.AllowPromiscuous = $false
            $vssSecurityArgs.ForgedTransmits = $true
            $vssSecurityArgs.MacChanges = $true
            $vssSecurityArgs.Add('Operation', 'edit')
        }

        try {
            Update-Network -NetworkSystem $this.vmHostNetworkSystem -VssSecurityConfig $vssSecurityArgs -ErrorAction Stop
        }
        catch {
            Write-Error "The Virtual Switch Security Config could not be updated: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the Security settings of the Virtual Switch.
    #>
    [void] PopulateResult($vmHost, $vmHostVSSSecurity) {
        Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

        $currentVss = $this.GetVss($vmHost)

        if ($null -ne $currentVss) {
            $vmHostVSSSecurity.VssName = $currentVss.Name
            $vmHostVSSSecurity.AllowPromiscuous = $currentVss.Spec.Policy.Security.AllowPromiscuous
            $vmHostVSSSecurity.ForgedTransmits = $currentVss.Spec.Policy.Security.ForgedTransmits
            $vmHostVSSSecurity.MacChanges = $currentVss.Spec.Policy.Security.MacChanges
        }
    }
}