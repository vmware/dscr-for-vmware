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
class VMHostPhysicalNetworkAdapter : VMHostNetworkBaseDSC {
    <#
    .DESCRIPTION

    Specifies the Physical Network Adapter which is going to be configured.
    #>
    [DscProperty(Key)]
    [string] $PhysicalNetworkAdapter

    <#
    .DESCRIPTION

    Indicates whether the link is capable of full-duplex. The valid values are Full, Half and Unset.
    #>
    [DscProperty()]
    [Duplex] $Duplex = [Duplex]::Unset

    <#
    .DESCRIPTION

    Specifies the bit rate of the link.
    #>
    [DscProperty()]
    [nullable[int]] $BitRatePerSecMb

    <#
    .DESCRIPTION

    Indicates that the host network adapter speed/duplex settings are configured automatically.
    If the property is passed, the Duplex and BitRatePerSecMb properties will be ignored.
    #>
    [DscProperty()]
    [nullable[bool]] $AutoNegotiate

    [void] Set() {
        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()
        $foundPhysicalNetworkAdapter = $this.GetPhysicalNetworkAdapter($vmHost, $this.PhysicalNetworkAdapter)

        $this.UpdatePhysicalNetworkAdapter($foundPhysicalNetworkAdapter)
    }

    [bool] Test() {
        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()
        $foundPhysicalNetworkAdapter = $this.GetPhysicalNetworkAdapter($vmHost, $this.PhysicalNetworkAdapter)

        return !$this.ShouldUpdatePhysicalNetworkAdapter($foundPhysicalNetworkAdapter)
    }

    [VMHostPhysicalNetworkAdapter] Get() {
        $result = [VMHostPhysicalNetworkAdapter]::new()
        $result.Server = $this.Server

        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()
        $foundPhysicalNetworkAdapter = $this.GetPhysicalNetworkAdapter($vmHost, $this.PhysicalNetworkAdapter)

        $result.Name = $vmHost.Name
        $result.PhysicalNetworkAdapter = $foundPhysicalNetworkAdapter.Name

        $this.PopulateResult($foundPhysicalNetworkAdapter, $result)

        return $result
    }

    <#
    .DESCRIPTION

    Checks if the Physical Network Adapter should be updated.
    #>
    [bool] ShouldUpdatePhysicalNetworkAdapter($foundPhysicalNetworkAdapter) {
        $shouldUpdatePhysicalNetworkAdapter = @()
        $shouldUpdatePhysicalNetworkAdapter += ($null -ne $this.BitRatePerSecMb -and $this.BitRatePerSecMb -ne $foundPhysicalNetworkAdapter.BitRatePerSec)

        <#
        The Duplex value on the server is stored as boolean indicating if the link is capable of full-duplex.
        So mapping between the enum and boolean values needs to be performed for comparison purposes.
        #>
        if ($this.Duplex -ne [Duplex]::Unset) {
            if ($foundPhysicalNetworkAdapter.FullDuplex) {
                $shouldUpdatePhysicalNetworkAdapter += ($this.Duplex -ne [Duplex]::Full)
            }
            else {
                $shouldUpdatePhysicalNetworkAdapter += ($this.Duplex -ne [Duplex]::Half)
            }
        }

        <#
        If the network adapter speed/duplex settings are configured automatically, the Link Speed
        property is $null on the server.
        #>
        if ($null -ne $this.AutoNegotiate) {
            if ($this.AutoNegotiate) {
                $shouldUpdatePhysicalNetworkAdapter += ($null -ne $foundPhysicalNetworkAdapter.ExtensionData.Spec.LinkSpeed)
            }
            else {
                $shouldUpdatePhysicalNetworkAdapter += ($null -eq $foundPhysicalNetworkAdapter.ExtensionData.Spec.LinkSpeed)
            }
        }

        return ($shouldUpdatePhysicalNetworkAdapter -Contains $true)
    }

    <#
    .DESCRIPTION

    Performs an update operation on the specified Physical Network Adapter.
    #>
    [void] UpdatePhysicalNetworkAdapter($foundPhysicalNetworkAdapter) {
        $physicalNetworkAdapterParams = @{}

        $physicalNetworkAdapterParams.PhysicalNic = $foundPhysicalNetworkAdapter
        $physicalNetworkAdapterParams.Confirm = $false
        $physicalNetworkAdapterParams.ErrorAction = 'Stop'

        if ($null -ne $this.AutoNegotiate -and $this.AutoNegotiate) {
            $physicalNetworkAdapterParams.AutoNegotiate = $this.AutoNegotiate
        }
        else {
            if ($this.Duplex -ne [Duplex]::Unset) { $physicalNetworkAdapterParams.Duplex = $this.Duplex.ToString() }
            if ($null -ne $this.BitRatePerSecMb) { $physicalNetworkAdapterParams.BitRatePerSecMb = $this.BitRatePerSecMb }
        }

        try {
            Set-VMHostNetworkAdapter @physicalNetworkAdapterParams
        }
        catch {
            throw "Cannot update Physical Network Adapter $($foundPhysicalNetworkAdapter.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the Physical Network Adapter from the server.
    #>
    [void] PopulateResult($foundPhysicalNetworkAdapter, $result) {
        <#
        AutoNegotiate property is not present on the server, so it should be populated
        with the value provided by user.
        #>
        $result.AutoNegotiate = $this.AutoNegotiate
        $result.BitRatePerSecMb = $foundPhysicalNetworkAdapter.BitRatePerSec

        if ($foundPhysicalNetworkAdapter.FullDuplex) {
            $result.Duplex = [Duplex]::Full
        }
        else {
            $result.Duplex = [Duplex]::Half
        }
    }
}
