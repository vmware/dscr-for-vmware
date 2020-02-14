<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

class VMHostNetworkMigrationBaseDSC : VMHostEntityBaseDSC {
    <#
    .DESCRIPTION

    Specifies the names of the Physical Network Adapters that should be part of the vSphere Distributed/Standard Switch.
    #>
    [DscProperty(Mandatory)]
    [string[]] $PhysicalNicNames

    <#
    .DESCRIPTION

    Specifies the names of the VMKernel Network Adapters that should be part of the vSphere Distributed/Standard Switch.
    #>
    [DscProperty()]
    [string[]] $VMKernelNicNames

    <#
    .DESCRIPTION

    Retrieves the Physical Network Adapters with the specified names from the server if they exist.
    For every Physical Network Adapter that does not exist, a warning message is shown to the user without throwing an exception.
    #>
    [array] GetPhysicalNetworkAdapters() {
        $physicalNetworkAdapters = @()

        foreach ($physicalNetworkAdapterName in $this.PhysicalNicNames) {
            $physicalNetworkAdapter = Get-VMHostNetworkAdapter -Server $this.Connection -Name $physicalNetworkAdapterName -VMHost $this.VMHost -Physical -ErrorAction SilentlyContinue
            if ($null -eq $physicalNetworkAdapter) {
                Write-WarningLog -Message "The passed Physical Network Adapter {0} was not found and it will be ignored." -Arguments @($physicalNetworkAdapterName)
            }
            else {
                $physicalNetworkAdapters += $physicalNetworkAdapter
            }
        }

        return $physicalNetworkAdapters
    }

    <#
    .DESCRIPTION

    Retrieves the VMKernel Network Adapters with the specified names from the server if they exist.
    If one of the passed VMKernel Network Adapters does not exist, an exception is thrown.
    #>
    [array] GetVMKernelNetworkAdapters() {
        $vmKernelNetworkAdapters = @()

        foreach ($vmKernelNetworkAdapterName in $this.VMKernelNicNames) {
            $getVMHostNetworkAdapterParams = @{
                Server = $this.Connection
                Name = $vmKernelNetworkAdapterName
                VMHost = $this.VMHost
                VMKernel = $true
                ErrorAction = 'Stop'
            }

            try {
                $vmKernelNetworkAdapter = Get-VMHostNetworkAdapter @getVMHostNetworkAdapterParams
                $vmKernelNetworkAdapters += $vmKernelNetworkAdapter
            }
            catch {
                <#
                Here 'throw' should be used instead of 'Write-WarningLog' because if we ignore one VMKernel Network Adapter that is invalid, the mapping between VMKernel
                Network Adapters and Port Groups will not work: The first Adapter should be attached to the first Port Group,
                the second Adapter should be attached to the second Port Group, and so on.
                #>
                throw "The passed VMKernel Network Adapter $($vmKernelNetworkAdapterName) was not found."
            }
        }

        return $vmKernelNetworkAdapters
    }
}
