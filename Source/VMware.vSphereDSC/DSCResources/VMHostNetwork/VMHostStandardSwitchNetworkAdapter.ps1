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
class VMHostStandardSwitchNetworkAdapter : VMHostNetworkAdapterBaseDSC {
    [void] Set() {
        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()

        $foundVirtualSwitch = $this.GetVirtualSwitch($vmHost, $this.VirtualSwitch)
        $vmHostNetworkAdapter = $this.GetVMHostNetworkAdapter($vmHost, $foundVirtualSwitch)

        if ($this.Ensure -eq [Ensure]::Present) {
            if ($null -eq $vmHostNetworkAdapter) {
                $this.AddVMHostNetworkAdapter($vmHost, $foundVirtualSwitch, $null)
            }
            else {
                $this.UpdateVMHostNetworkAdapter($vmHostNetworkAdapter)
            }
        }
        else {
            if ($null -ne $vmHostNetworkAdapter) {
                <#
                Here the retrieval of the VMKernel is done for the second time because retrieving it
                by Virtual Switch and Port Group produces the following error when trying to delete it:
                "The object 'vmodl.ManagedObject:' has already been deleted or has not been completely created".
                The error does not occur when the retrieval is done by Name.
                #>
                $vmHostNetworkAdapter = Get-VMHostNetworkAdapter -Server $this.Connection -Name $vmHostNetworkAdapter.Name

                $this.RemoveVMHostNetworkAdapter($vmHostNetworkAdapter)
            }
        }
    }

    [bool] Test() {
        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()

        $foundVirtualSwitch = $this.GetVirtualSwitch($vmHost, $this.VirtualSwitch)
        $vmHostNetworkAdapter = $this.GetVMHostNetworkAdapter($vmHost, $foundVirtualSwitch)

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

    [VMHostStandardSwitchNetworkAdapter] Get() {
        $result = [VMHostStandardSwitchNetworkAdapter]::new()
        $result.Server = $this.Server

        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()

        $foundVirtualSwitch = $this.GetVirtualSwitch($vmHost, $this.VirtualSwitch)
        $vmHostNetworkAdapter = $this.GetVMHostNetworkAdapter($vmHost, $foundVirtualSwitch)

        $result.Name = $vmHost.Name
        $result.VirtualSwitch = $foundVirtualSwitch.Name

        $this.PopulateResult($vmHostNetworkAdapter, $result)

        return $result
    }
}
