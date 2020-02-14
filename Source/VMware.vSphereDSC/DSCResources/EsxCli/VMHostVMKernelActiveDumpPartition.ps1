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
class VMHostVMKernelActiveDumpPartition : EsxCliBaseDSC {
    VMHostVMKernelActiveDumpPartition() {
        $this.EsxCliCommand = 'system.coredump.partition'
    }

    <#
    .DESCRIPTION

    Specifies whether the VMKernel dump partition should be enabled or disabled.
    #>
    [DscProperty()]
    [nullable[bool]] $Enable

    <#
    .DESCRIPTION

    Specifies whether to select the best available partition using the smart selection algorithm. Can only be used when 'Enabled' property is specified with '$true' value.
    #>
    [DscProperty()]
    [nullable[bool]] $Smart

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            $this.ExecuteEsxCliModifyMethod($this.EsxCliSetMethodName)
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.SetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [bool] Test() {
        try {
            Write-VerboseLog -Message $this.TestMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)
            $esxCliGetMethodResult = $this.ExecuteEsxCliRetrievalMethod($this.EsxCliGetMethodName)

            $result = !$this.ShouldModifyVMKernelDumpPartition($esxCliGetMethodResult)

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [VMHostVMKernelActiveDumpPartition] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [VMHostVMKernelActiveDumpPartition]::new()

            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            $this.PopulateResult($result, $vmHost)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Checks if the VMKernel dump partition should be modified.
    #>
    [bool] ShouldModifyVMKernelDumpPartition($esxCliGetMethodResult) {
        $result = $null

        if ($null -ne $this.Enable) {
            if ($this.Enable) { $result = [string]::IsNullOrEmpty($esxCliGetMethodResult.Active) }
            else { $result = ![string]::IsNullOrEmpty($esxCliGetMethodResult.Active) }
        }
        else {
            $result = $false
        }

        return $result
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $vmHost) {
        $result.Server = $this.Connection.Name
        $result.Name = $vmHost.Name
        $result.Smart = $this.Smart

        $esxCliGetMethodResult = $this.ExecuteEsxCliRetrievalMethod($this.EsxCliGetMethodName)
        $result.Enable = ![string]::IsNullOrEmpty($esxCliGetMethodResult.Active)
    }
}
