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
class VMHostVssNic : VMHostNicBaseDSC {
    <#
    .DESCRIPTION

    Specifies the name of the Virtual Switch to which the VMKernel Network Adapter should be connected.
    #>
    [DscProperty(Key)]
    [string] $VssName

    [void] Set() {
        try {
            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $virtualSwitch = $this.GetVirtualSwitch()
            $vmHostNetworkAdapter = $this.GetVMHostNetworkAdapter($virtualSwitch)

            if ($null -ne $vmHostNetworkAdapter) {
                <#
                Here the retrieval of the VMKernel is done for the second time because retrieving it
                by Virtual Switch and Port Group produces errors when trying to update or delete it.
                The errors do not occur when the retrieval is done by Name.
                #>
                $vmHostNetworkAdapter = Get-VMHostNetworkAdapter -Server $this.Connection -Name $vmHostNetworkAdapter.Name -VMHost $this.VMHost -VMKernel
            }

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $vmHostNetworkAdapter) {
                    $vmHostNetworkAdapter = $this.AddVMHostNetworkAdapter($virtualSwitch, $null)
                }

                if ($this.ShouldUpdateVMHostNetworkAdapter($vmHostNetworkAdapter)) {
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
            $this.RetrieveVMHost()

            $virtualSwitch = $this.GetVirtualSwitch()
            $vmHostNetworkAdapter = $this.GetVMHostNetworkAdapter($virtualSwitch)

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

    [VMHostVssNic] Get() {
        try {
            $result = [VMHostVssNic]::new()

            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $virtualSwitch = $this.GetVirtualSwitch()
            $vmHostNetworkAdapter = $this.GetVMHostNetworkAdapter($virtualSwitch)

            $result.VssName = $virtualSwitch.Name
            $this.PopulateResult($vmHostNetworkAdapter, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Virtual Switch with the specified name from the server if it exists.
    The Virtual Switch must be a Standard Virtual Switch. If the Virtual Switch does not exist and Ensure is set to 'Absent', $null is returned.
    Otherwise it throws an exception.
    #>
    [PSObject] GetVirtualSwitch() {
        if ($this.Ensure -eq [Ensure]::Absent) {
            return Get-VirtualSwitch -Server $this.Connection -Name $this.VssName -VMHost $this.VMHost -Standard -ErrorAction SilentlyContinue
        }
        else {
            try {
                $virtualSwitch = Get-VirtualSwitch -Server $this.Connection -Name $this.VssName -VMHost $this.VMHost -Standard -ErrorAction Stop
                return $virtualSwitch
            }
            catch {
                throw "Could not retrieve Virtual Switch $($this.VssName) of VMHost $($this.VMHost.Name). For more information: $($_.Exception.Message)"
            }
        }
    }
}
