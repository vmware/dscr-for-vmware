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
class VMHostVss : VMHostVssBaseDSC {
    <#
    .DESCRIPTION

    The maximum transmission unit (MTU) associated with this virtual switch in bytes.
    #>
    [DscProperty()]
    [nullable[int]] $Mtu

    <#
    .DESCRIPTION

    The virtual switch key.
    #>
    [DscProperty(NotConfigurable)]
    [string] $Key

    <#
    .DESCRIPTION

    The number of ports that this virtual switch currently has.
    #>
    [DscProperty(NotConfigurable)]
    [int] $NumPorts

    <#
    .DESCRIPTION

    The number of ports that are available on this virtual switch.
    #>
    [DscProperty(NotConfigurable)]
    [int] $NumPortsAvailable

    <#
    .DESCRIPTION

    The set of physical network adapters associated with this bridge.
    #>
    [DscProperty(NotConfigurable)]
    [string[]] $Pnic

    <#
    .DESCRIPTION

    The list of port groups configured for this virtual switch.
    #>
    [DscProperty(NotConfigurable)]
    [string[]] $PortGroup

    [void] Set() {
        try {
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $this.GetNetworkSystem($vmHost)

            $this.UpdateVss($vmHost)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $this.GetNetworkSystem($vmHost)
            $vss = $this.GetVss()

            if ($this.Ensure -eq [Ensure]::Present) {
                return ($null -ne $vss -and $this.Equals($vss))
            }
            else {
                return ($null -eq $vss)
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostVss] Get() {
        try {
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

            $result = [VMHostVss]::new()
            $result.Server = $this.Server

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $this.GetNetworkSystem($vmHost)

            $result.Name = $vmHost.Name
            $this.PopulateResult($vmHost, $result)

            $result.Ensure = if ([string]::Empty -ne $result.Key) { 'Present' } else { 'Absent' }

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if the VMHostVss should be updated.
    #>
    [bool] Equals($vss) {
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

        $vssTest = @()
        $vssTest += ($vss.Name -eq $this.VssName)
        $vssTest += ($null -eq $this.Mtu -or $vss.MTU -eq $this.MTU)

        return ($vssTest -notcontains $false)
    }

    <#
    .DESCRIPTION

    Updates the configuration of the virtual switch.
    #>
    [void] UpdateVss($vmHost) {
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

        $vssConfigArgs = @{
            Name = $this.VssName
            Mtu = $this.Mtu
        }
        $vss = $this.GetVss()

        if ($this.Ensure -eq 'Present') {
            if ($null -ne $vss) {
                if ($this.Equals($vss)) {
                    return
                }
                $vssConfigArgs.Add('Operation', 'edit')
            }
            else {
                $vssConfigArgs.Add('Operation', 'add')
            }
        }
        else {
            if ($null -eq $vss) {
                return
            }
            $vssConfigArgs.Add('Operation', 'remove')
        }

        try {
            Update-Network -NetworkSystem $this.vmHostNetworkSystem -VssConfig $vssConfigArgs -ErrorAction Stop
        }
        catch {
            throw "The Virtual Switch Config could not be updated: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the virtual switch.
    #>
    [void] PopulateResult($vmHost, $vmHostVSS) {
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

        $currentVss = $this.GetVss()

        if ($null -ne $currentVss) {
            $vmHostVSS.Key = $currentVss.Key
            $vmHostVSS.Mtu = $currentVss.Mtu
            $vmHostVSS.VssName = $currentVss.Name
            $vmHostVSS.NumPortsAvailable = $currentVss.NumPortsAvailable
            $vmHostVSS.Pnic = $currentVss.Pnic
            $vmHostVSS.PortGroup = $currentVss.PortGroup
        }
        else{
            $vmHostVSS.Key = [string]::Empty
            $vmHostVSS.Mtu = $this.Mtu
            $vmHostVSS.VssName = $this.VssName
        }
    }
}
