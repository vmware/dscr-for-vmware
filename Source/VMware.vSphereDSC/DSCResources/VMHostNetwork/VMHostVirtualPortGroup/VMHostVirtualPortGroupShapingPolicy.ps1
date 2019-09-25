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
class VMHostVirtualPortGroupShapingPolicy : VMHostVirtualPortGroupBaseDSC {
    <#
    .DESCRIPTION

    The flag to indicate whether or not traffic shaper is enabled on the port.
    #>
    [DscProperty()]
    [nullable[bool]] $Enabled

    <#
    .DESCRIPTION

    The average bandwidth in bits per second if shaping is enabled on the port.
    #>
    [DscProperty()]
    [nullable[long]] $AverageBandwidth

    <#
    .DESCRIPTION

    The peak bandwidth during bursts in bits per second if traffic shaping is enabled on the port.
    #>
    [DscProperty()]
    [nullable[long]] $PeakBandwidth

    <#
    .DESCRIPTION

    The maximum burst size allowed in bytes if shaping is enabled on the port.
    #>
    [DscProperty()]
    [nullable[long]] $BurstSize

    [void] Set() {
        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()

        $this.GetNetworkSystem($vmHost)
        $virtualPortGroup = $this.GetVirtualPortGroup($vmHost)

        $this.UpdateVirtualPortGroupShapingPolicy($virtualPortGroup)
    }

    [bool] Test() {
        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()
        $virtualPortGroup = $this.GetVirtualPortGroup($vmHost)

        return !$this.ShouldUpdateVirtualPortGroupShapingPolicy($virtualPortGroup)
    }

    [VMHostVirtualPortGroupShapingPolicy] Get() {
        $result = [VMHostVirtualPortGroupShapingPolicy]::new()
        $result.Server = $this.Server

        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()
        $virtualPortGroup = $this.GetVirtualPortGroup($vmHost)

        $result.Name = $vmHost.Name
        $result.PortGroup = $virtualPortGroup.Name

        $this.PopulateResult($virtualPortGroup, $result)

        return $result
    }

    <#
    .DESCRIPTION

    Checks if the Shaping Policy of the specified Virtual Port Group should be updated.
    #>
    [bool] ShouldUpdateVirtualPortGroupShapingPolicy($virtualPortGroup) {
        $shouldUpdateVirtualPortGroupShapingPolicy = @()

        $shouldUpdateVirtualPortGroupShapingPolicy += ($null -ne $this.Enabled -and $this.Enabled -ne $virtualPortGroup.ExtensionData.Spec.Policy.ShapingPolicy.Enabled)
        $shouldUpdateVirtualPortGroupShapingPolicy += ($null -ne $this.AverageBandwidth -and $this.AverageBandwidth -ne $virtualPortGroup.ExtensionData.Spec.Policy.ShapingPolicy.AverageBandwidth)
        $shouldUpdateVirtualPortGroupShapingPolicy += ($null -ne $this.PeakBandwidth -and $this.PeakBandwidth -ne $virtualPortGroup.ExtensionData.Spec.Policy.ShapingPolicy.PeakBandwidth)
        $shouldUpdateVirtualPortGroupShapingPolicy += ($null -ne $this.BurstSize -and $this.BurstSize -ne $virtualPortGroup.ExtensionData.Spec.Policy.ShapingPolicy.BurstSize)

        return ($shouldUpdateVirtualPortGroupShapingPolicy -Contains $true)
    }

    <#
    .DESCRIPTION

    Performs an update on the Shaping Policy of the specified Virtual Port Group.
    #>
    [void] UpdateVirtualPortGroupShapingPolicy($virtualPortGroup) {
        $virtualPortGroupSpec = New-Object VMware.Vim.HostPortGroupSpec

        $virtualPortGroupSpec.Name = $virtualPortGroup.Name
        $virtualPortGroupSpec.VswitchName = $virtualPortGroup.VirtualSwitchName
        $virtualPortGroupSpec.VlanId = $virtualPortGroup.VLanId

        $virtualPortGroupSpec.Policy = New-Object VMware.Vim.HostNetworkPolicy
        $virtualPortGroupSpec.Policy.ShapingPolicy = New-Object VMware.Vim.HostNetworkTrafficShapingPolicy

        if ($null -ne $this.Enabled) { $virtualPortGroupSpec.Policy.ShapingPolicy.Enabled = $this.Enabled }
        if ($null -ne $this.AverageBandwidth) { $virtualPortGroupSpec.Policy.ShapingPolicy.AverageBandwidth = $this.AverageBandwidth }
        if ($null -ne $this.PeakBandwidth) { $virtualPortGroupSpec.Policy.ShapingPolicy.PeakBandwidth = $this.PeakBandwidth }
        if ($null -ne $this.BurstSize) { $virtualPortGroupSpec.Policy.ShapingPolicy.BurstSize = $this.BurstSize }

        try {
            Update-VirtualPortGroup -VMHostNetworkSystem $this.VMHostNetworkSystem -VirtualPortGroupName $virtualPortGroup.Name -Spec $virtualPortGroupSpec
        }
        catch {
            throw "Cannot update Shaping Policy of Virtual Port Group $($this.PortGroup). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the Shaping Policy of the specified Virtual Port Group from the server.
    #>
    [void] PopulateResult($virtualPortGroup, $result) {
        $result.Enabled = $virtualPortGroup.ExtensionData.Spec.Policy.ShapingPolicy.Enabled
        $result.AverageBandwidth = $virtualPortGroup.ExtensionData.Spec.Policy.ShapingPolicy.AverageBandwidth
        $result.PeakBandwidth = $virtualPortGroup.ExtensionData.Spec.Policy.ShapingPolicy.PeakBandwidth
        $result.BurstSize = $virtualPortGroup.ExtensionData.Spec.Policy.ShapingPolicy.BurstSize
    }
}
