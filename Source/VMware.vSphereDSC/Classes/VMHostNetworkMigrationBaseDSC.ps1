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

    hidden [string] $RetrievePhysicalNicMessage = "Retrieving Physical Network Adapter {0} from VMHost {1}."
    hidden [string] $RetrieveVMKernelNicMessage = "Retrieving VMKernel Network Adapter {0} from VMHost {1}."

    hidden [string] $CouldNotFindPhysicalNicMessage = "Physical Network Adapter {0} was not found on VMHost {1} and will be ignored."
    hidden [string] $CouldNotFindVMKernelNicMessage = "VMKernel Network Adapter {0} was not found on VMHost {1}."

    <#
    .DESCRIPTION

    Retrieves the Physical Network Adapters with the specified names from the server if they exist.
    For every Physical Network Adapter that does not exist, a warning message is shown to the user without throwing an exception.
    #>
    [array] GetPhysicalNetworkAdapters() {
        $physicalNetworkAdapters = @()

        foreach ($physicalNetworkAdapterName in $this.PhysicalNicNames) {
            $this.WriteLogUtil('Verbose', $this.RetrievePhysicalNicMessage, @($physicalNetworkAdapterName, $this.VMHost.Name))

            $getVMHostNetworkAdapterParams = @{
                Server = $this.Connection
                Name = $physicalNetworkAdapterName
                VMHost = $this.VMHost
                Physical = $true
                ErrorAction = 'SilentlyContinue'
                Verbose = $false
            }

            $physicalNetworkAdapter = Get-VMHostNetworkAdapter @getVMHostNetworkAdapterParams
            if ($null -eq $physicalNetworkAdapter) {
                $this.WriteLogUtil('Warning', $this.CouldNotFindPhysicalNicMessage, @($physicalNetworkAdapterName, $this.VMHost.Name))
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
            $this.WriteLogUtil('Verbose', $this.RetrieveVMKernelNicMessage, @($vmKernelNetworkAdapterName, $this.VMHost.Name))

            $getVMHostNetworkAdapterParams = @{
                Server = $this.Connection
                Name = $vmKernelNetworkAdapterName
                VMHost = $this.VMHost
                VMKernel = $true
                ErrorAction = 'Stop'
                Verbose = $false
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
                throw ($this.CouldNotFindVMKernelNicMessage -f $vmKernelNetworkAdapterName, $this.VMHost.Name)
            }
        }

        return $vmKernelNetworkAdapters
    }
}
