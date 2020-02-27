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
class VMHostVssShaping : VMHostVssBaseDSC {
    <#
    .DESCRIPTION

    The average bandwidth in bits per second if shaping is enabled on the port.
    #>
    [DscProperty()]
    [nullable[long]] $AverageBandwidth

    <#
    .DESCRIPTION

    The maximum burst size allowed in bytes if shaping is enabled on the port.
    #>
    [DscProperty()]
    [nullable[long]] $BurstSize

    <#
    .DESCRIPTION

    The flag to indicate whether or not traffic shaper is enabled on the port.
    #>
    [DscProperty()]
    [nullable[bool]] $Enabled

    <#
    .DESCRIPTION

    The peak bandwidth during bursts in bits per second if traffic shaping is enabled on the port.
    #>
    [DscProperty()]
    [nullable[long]] $PeakBandwidth

    [void] Set() {
        try {
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $this.GetNetworkSystem($vmHost)

            $this.UpdateVssShaping($vmHost)
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
                $this.AverageBandwidth = 100000
                $this.BurstSize = 100000
                $this.Enabled = $false
                $this.PeakBandwidth = 100000

                return ($null -eq $vss -or $this.Equals($vss))
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostVssShaping] Get() {
        try {
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

            $result = [VMHostVssShaping]::new()
            $result.Server = $this.Server

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $this.GetNetworkSystem($vmHost)

            $result.Name = $vmHost.Name
            $this.PopulateResult($vmHost, $result)

            $result.Ensure = if ([string]::Empty -ne $result.VssName) { 'Present' } else { 'Absent' }

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if the VMHostVssShaping should to be updated.
    #>
    [bool] Equals($vss) {
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

        $vssShapingTest = @()
        $vssShapingTest += ($null -eq $this.AverageBandwidth -or $vss.Spec.Policy.ShapingPolicy.AverageBandwidth -eq $this.AverageBandwidth)
        $vssShapingTest += ($null -eq $this.BurstSize -or $vss.Spec.Policy.ShapingPolicy.BurstSize -eq $this.BurstSize)
        $vssShapingTest += ($null -eq $this.Enabled -or $vss.Spec.Policy.ShapingPolicy.Enabled -eq $this.Enabled)
        $vssShapingTest += ($null -eq $this.PeakBandwidth -or $vss.Spec.Policy.ShapingPolicy.PeakBandwidth -eq $this.PeakBandwidth)

        return ($vssShapingTest -notcontains $false)
    }

    <#
    .DESCRIPTION

    Updates the configuration of the virtual switch.
    #>
    [void] UpdateVssShaping($vmHost) {
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

        $vssShapingArgs = @{
            Name = $this.VssName
            AverageBandwidth = $this.AverageBandwidth
            BurstSize = $this.BurstSize
            Enabled = $this.Enabled
            PeakBandwidth = $this.PeakBandwidth
        }
        $vss = $this.GetVss()

        if ($this.Ensure -eq 'Present') {
            if ($this.Equals($vss)) {
                return
            }
            $vssShapingArgs.Add('Operation', 'edit')
        }
        else {
            $vssShapingArgs.AverageBandwidth = 100000
            $vssShapingArgs.BurstSize = 100000
            $vssShapingArgs.Enabled = $false
            $vssShapingArgs.PeakBandwidth = 100000
            $vssShapingArgs.Add('Operation', 'edit')
        }

        try {
            Update-Network -NetworkSystem $this.vmHostNetworkSystem -VssShapingConfig $vssShapingArgs -ErrorAction Stop
        }
        catch {
            throw "The Virtual Switch Shaping Policy Config could not be updated: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the Security settings of the Virtual Switch.
    #>
    [void] PopulateResult($vmHost, $vmHostVSSShaping) {
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

        $currentVss = $this.GetVss()

        if ($null -ne $currentVss) {
            $vmHostVSSShaping.VssName = $currentVss.Name
            $vmHostVSSShaping.AverageBandwidth = $currentVss.Spec.Policy.ShapingPolicy.AverageBandwidth
            $vmHostVSSShaping.BurstSize = $currentVss.Spec.Policy.ShapingPolicy.BurstSize
            $vmHostVSSShaping.Enabled = $currentVss.Spec.Policy.ShapingPolicy.Enabled
            $vmHostVSSShaping.PeakBandwidth = $currentVss.Spec.Policy.ShapingPolicy.PeakBandwidth
        }
        else {
            $vmHostVSSShaping.VssName = $this.Name
            $vmHostVSSShaping.AverageBandwidth = $this.AverageBandwidth
            $vmHostVSSShaping.BurstSize = $this.BurstSize
            $vmHostVSSShaping.Enabled = $this.Enabled
            $vmHostVSSShaping.PeakBandwidth = $this.PeakBandwidth
        }
    }
}
