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
class VMHostVdsNic : VMHostNicBaseDSC {
    <#
    .DESCRIPTION

    Specifies the name of the Distributed Switch to which the VMKernel Network Adapter should be connected.
    #>
    [DscProperty(Key)]
    [string] $VdsName

    <#
    .DESCRIPTION

    Specifies the port of the specified Distributed Switch to which the VMKernel Network Adapter should be connected.
    #>
    [DscProperty()]
    [string] $PortId

    [void] Set() {
        try {
            $this.ConnectVIServer()
            $this.EnsureConnectionIsvCenter()

            $this.RetrieveVMHost()
            $distributedSwitch = $this.GetDistributedSwitch()
            $this.EnsureVMHostIsAddedToDistributedSwitch($distributedSwitch)

            $vmHostNetworkAdapter = $this.GetVMHostNetworkAdapter($distributedSwitch)

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $vmHostNetworkAdapter) {
                    if ([string]::IsNullOrEmpty($this.PortId)) {
                        $this.AddVMHostNetworkAdapter($distributedSwitch, $null)
                    }
                    else {
                        $this.AddVMHostNetworkAdapter($distributedSwitch, $this.PortId)
                    }
                }
                else {
                    $this.UpdateVMHostNetworkAdapter($vmHostNetworkAdapter)
                }
            }
            else {
                if ($null -ne $vmHostNetworkAdapter) {
                    $this.RemoveVMHostNetworkAdapter($vmHostNetworkAdapter)
                }
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()
            $this.EnsureConnectionIsvCenter()

            $this.RetrieveVMHost()
            $distributedSwitch = $this.GetDistributedSwitch()
            $this.EnsureVMHostIsAddedToDistributedSwitch($distributedSwitch)

            $vmHostNetworkAdapter = $this.GetVMHostNetworkAdapter($distributedSwitch)

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $vmHostNetworkAdapter) {
                    return $false
                }

                return !$this.ShouldUpdateVMHostNetworkAdapter($vmHostNetworkAdapter)
            }
            else {
                return ($null -eq $vmHostNetworkAdapter)
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostVdsNic] Get() {
        try {
            $result = [VMHostVdsNic]::new()

            $this.ConnectVIServer()
            $this.EnsureConnectionIsvCenter()

            $this.RetrieveVMHost()
            $distributedSwitch = $this.GetDistributedSwitch()
            $this.EnsureVMHostIsAddedToDistributedSwitch($distributedSwitch)

            $vmHostNetworkAdapter = $this.GetVMHostNetworkAdapter($distributedSwitch)

            $result.VdsName = $distributedSwitch.Name
            if ($null -eq $vmHostNetworkAdapter) {
                $result.PortId = $this.PortId
            }
            else {
                $result.PortId = $vmHostNetworkAdapter.ExtensionData.Spec.DistributedVirtualPort.PortKey
            }

            $this.PopulateResult($vmHostNetworkAdapter, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Distributed Switch with the specified name from the server if it exists.
    If the Distributed Switch does not exist and Ensure is set to 'Absent', $null is returned.
    Otherwise it throws an exception.
    #>
    [PSObject] GetDistributedSwitch() {
        <#
        The Verbose logic here is needed to suppress the Exporting and Importing of the
        cmdlets from the VMware.VimAutomation.Vds Module.
        #>
        $savedVerbosePreference = $global:VerbosePreference
        $global:VerbosePreference = 'SilentlyContinue'

        try {
            if ($this.Ensure -eq [Ensure]::Absent) {
                return Get-VDSwitch -Server $this.Connection -Name $this.VdsName -ErrorAction SilentlyContinue
            }
            else {
                try {
                    $distributedSwitch = Get-VDSwitch -Server $this.Connection -Name $this.VdsName -ErrorAction Stop
                    return $distributedSwitch
                }
                catch {
                    throw "Could not retrieve Distributed Switch $($this.VdsName). For more information: $($_.Exception.Message)"
                }
            }
        }
        finally {
            $global:VerbosePreference = $savedVerbosePreference
        }
    }

    <#
    .DESCRIPTION

    Checks if the specified VMHost is part of the Distributed Switch and if not, throws an exception.
    #>
    [void] EnsureVMHostIsAddedToDistributedSwitch($distributedSwitch) {
        if ($null -eq $distributedSwitch) {
            <#
            If the Distributed Switch is $null, it means that Ensure was set to 'Absent' and
            the VMKernel Network Adapter does not exist for the specified Distributed Switch.
            So there is no need to ensure that the VMHost is part of the Distributed Switch.
            #>
            return
        }

        $addedVMHost = $this.VMHost.ExtensionData.Config.Network.ProxySwitch | Where-Object -FilterScript { $_.DvsName -eq $distributedSwitch.Name }
        if ($null -eq $addedVMHost) {
            throw "VMHost $($this.VMHost.Name) should be added to Distributed Switch $($distributedSwitch.Name) before configuring the VMKernel Network Adapter."
        }
    }
}
