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
class VMHostVssBridge : VMHostVssBaseDSC {
    <#
    .DESCRIPTION

    The list of keys of the physical network adapters to be bridged.
    #>
    [DscProperty()]
    [string[]] $NicDevice

    <#
    .DESCRIPTION

    The beacon configuration to probe for the validity of a link.
    If this is set, beacon probing is configured and will be used.
    If this is not set, beacon probing is disabled.
    Determines how often, in seconds, a beacon should be sent.
    #>
    [DscProperty()]
    [nullable[int]] $BeaconInterval

    <#
    .DESCRIPTION

    The link discovery protocol, whether to advertise or listen.
    #>
    [DscProperty()]
    [LinkDiscoveryProtocolOperation] $LinkDiscoveryProtocolOperation = [LinkDiscoveryProtocolOperation]::Unset

    <#
    .DESCRIPTION

    The link discovery protocol type.
    #>
    [DscProperty()]
    [LinkDiscoveryProtocolProtocol] $LinkDiscoveryProtocolProtocol = [LinkDiscoveryProtocolProtocol]::Unset

    [void] Set() {
        try {
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $this.GetNetworkSystem($vmHost)

            $this.UpdateVssBridge($vmHost)
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
                $this.NicDevice = @()
                $this.BeaconInterval = 0
                $this.LinkDiscoveryProtocolProtocol = [LinkDiscoveryProtocolProtocol]::Unset

                return ($null -eq $vss -or $this.Equals($vss))
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostVssBridge] Get() {
        try {
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

            $result = [VMHostVssBridge]::new()
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

    Returns a boolean value indicating if the VMHostVssBridge should to be updated.
    #>
    [bool] Equals($vss) {
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

        $vssBridgeTest = @()

        $vssBridgeTest += !$this.ShouldUpdateArraySetting($vss.Spec.Bridge.NicDevice, $this.NicDevice)
        $vssBrdigeTest += ($null -eq $this.BeaconInterval -or $vss.Spec.Bridge.Beacon.Interval -eq $this.BeaconInterval)

        if ($this.LinkDiscoveryProtocolOperation -ne [LinkDiscoveryProtocolOperation]::Unset) {
            if ($null -eq $vss.Spec.Bridge.LinkDiscoveryProtocolConfig.Operation) { $vssBridgeTest += $false }
            else { $vssBridgeTest += ($vss.Spec.Bridge.LinkDiscoveryProtocolConfig.Operation.ToString() -eq $this.LinkDiscoveryProtocolOperation.ToString()) }
        }

        if ($this.LinkDiscoveryProtocolProtocol -ne [LinkDiscoveryProtocolProtocol]::Unset) {
            if ($null -eq $vss.Spec.Bridge.LinkDiscoveryProtocolConfig.Protocol) { $vssBridgeTest += $false }
            else { $vssBridgeTest += ($vss.Spec.Bridge.LinkDiscoveryProtocolConfig.Protocol.ToString() -eq $this.LinkDiscoveryProtocolProtocol.ToString()) }
        }

        return ($vssBridgeTest -NotContains $false)
    }

    <#
    .DESCRIPTION

    Updates the Bridge configuration of the virtual switch.
    #>
    [void] UpdateVssBridge($vmHost) {
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

        $vssBridgeArgs = @{
            Name = $this.VssName
            NicDevice = $this.NicDevice
        }

        # The Bridge configuration of the Standard Switch should be populated only when the Nic devices are passed.
        if ($this.NicDevice.Count -gt 0) {
            if ($null -ne $this.BeaconInterval) { $vssBridgeArgs.BeaconInterval = $this.BeaconInterval }
            if ($this.LinkDiscoveryProtocolProtocol -ne [LinkDiscoveryProtocolProtocol]::Unset) {
                $vssBridgeArgs.Add('LinkDiscoveryProtocolProtocol', $this.LinkDiscoveryProtocolProtocol.ToString())
                $vssBridgeArgs.Add('LinkDiscoveryProtocolOperation', $this.LinkDiscoveryProtocolOperation.ToSTring())
            }
        }

        $vss = $this.GetVss()

        if ($this.Ensure -eq 'Present') {
            if ($this.Equals($vss)) {
                return
            }
        }
        else {
            $vssBridgeArgs.NicDevice = @()
        }
        $vssBridgeArgs.Add('Operation', 'edit')

        try {
            Update-Network -NetworkSystem $this.vmHostNetworkSystem -VssBridgeConfig $vssBridgeArgs -ErrorAction Stop
        }
        catch {
            throw "The Virtual Switch Bridge Config could not be updated: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the Bridge settings of the Virtual Switch.
    #>
    [void] PopulateResult($vmHost, $vmHostVSSBridge) {
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

        $currentVss = $this.GetVss()

        if ($null -ne $currentVss) {
            $vmHostVSSBridge.VssName = $currentVss.Name
            $vmHostVSSBridge.NicDevice = $currentVss.Spec.Bridge.NicDevice
            $vmHostVSSBridge.BeaconInterval = $currentVss.Spec.Bridge.Beacon.Interval

            if ($null -ne $currentVss.Spec.Bridge.linkDiscoveryProtocolConfig) {
                $vmHostVSSBridge.LinkDiscoveryProtocolOperation = $currentVss.Spec.Bridge.LinkDiscoveryProtocolConfig.Operation.ToString()
                $vmHostVSSBridge.LinkDiscoveryProtocolProtocol = $currentVss.Spec.Bridge.LinkDiscoveryProtocolConfig.Protocol.ToString()
            }
        }
        else {
            $vmHostVSSBridge.VssName = $this.VssName
            $vmHostVSSBridge.NicDevice = $this.NicDevice
            $vmHostVSSBridge.BeaconInterval = $this.BeaconInterval
            $vmHostVSSBridge.LinkDiscoveryProtocolOperation = $this.LinkDiscoveryProtocolOperation
            $vmHostVSSBridge.LinkDiscoveryProtocolProtocol = $this.LinkDiscoveryProtocolProtocol
        }
    }
}
