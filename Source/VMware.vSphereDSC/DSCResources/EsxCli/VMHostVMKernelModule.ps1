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
class VMHostVMKernelModule : EsxCliBaseDSC {
    VMHostVMKernelModule() {
        $this.EsxCliCommand = 'system.module'
    }

    <#
    .DESCRIPTION

    Specifies the name of the VMKernel module.
    #>
    [DscProperty(Key)]
    [string] $Module

    <#
    .DESCRIPTION

    Specifies whether the module should be enabled or disabled.
    #>
    [DscProperty(Mandatory)]
    [bool] $Enabled

    <#
    .DESCRIPTION

    Specifies whether to skip the VMkernel module validity checks.
    #>
    [DscProperty()]
    [nullable[bool]] $Force

    [void] Set() {
        try {
            $this.ConnectVIServer()

            $this.WriteLogUtil('Verbose', $this.SetMethodStartMessage, @($this.DscResourceName))

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            $this.ExecuteEsxCliModifyMethod($this.EsxCliSetMethodName)
        }
        finally {
            $this.WriteLogUtil('Verbose', $this.SetMethodEndMessage, @($this.DscResourceName))

            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()

            $this.WriteLogUtil('Verbose', $this.TestMethodStartMessage, @($this.DscResourceName))

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)
            $esxCliListMethodResult = $this.ExecuteEsxCliRetrievalMethod($this.EsxCliListMethodName)

            $result = !$this.ShouldModifyVMKernelModule($esxCliListMethodResult)

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.WriteLogUtil('Verbose', $this.TestMethodEndMessage, @($this.DscResourceName))

            $this.DisconnectVIServer()
        }
    }

    [VMHostVMKernelModule] Get() {
        try {
            $this.ConnectVIServer()

            $this.WriteLogUtil('Verbose', $this.GetMethodStartMessage, @($this.DscResourceName))

            $result = [VMHostVMKernelModule]::new()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            $this.PopulateResult($result, $vmHost)

            return $result
        }
        finally {
            $this.WriteLogUtil('Verbose', $this.GetMethodEndMessage, @($this.DscResourceName))

            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Checks if the specified VMKernel module should be modified.
    #>
    [bool] ShouldModifyVMKernelModule($esxCliListMethodResult) {
        $vmKernelModule = $esxCliListMethodResult | Where-Object -FilterScript { $_.Name -eq $this.Module }
        return $this.ShouldUpdateDscResourceSetting('Enabled', [System.Convert]::ToBoolean($vmKernelModule.IsEnabled), $this.Enabled)
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $vmHost) {
        $result.Server = $this.Connection.Name
        $result.Name = $vmHost.Name
        $result.Force = $this.Force

        $esxCliListMethodResult = $this.ExecuteEsxCliRetrievalMethod($this.EsxCliListMethodName)
        $vmKernelModule = $esxCliListMethodResult | Where-Object -FilterScript { $_.Name -eq $this.Module }

        $result.Module = $vmKernelModule.Name
        $result.Enabled = [System.Convert]::ToBoolean($vmKernelModule.IsEnabled)
    }
}
