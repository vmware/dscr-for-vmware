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
class VMHostIScsiHba : VMHostIScsiHbaBaseDSC {
    <#
    .DESCRIPTION

    Specifies the name of the iSCSI Host Bus Adapter.
    #>
    [DscProperty(Key)]
    [string] $Name

    <#
    .DESCRIPTION

    Specifies the name for the VMHost Host Bus Adapter device.
    #>
    [DscProperty()]
    [string] $IScsiName

    hidden [string] $ConfigureIScsiHbaMessage = "Configuring iSCSI Host Bus Adapter {0} from VMHost {1}."

    hidden [string] $CouldNotConfigureIScsiHbaMessage = "Could not configure iSCSI Host Bus Adapter {0} from VMHost {1}. For more information: {2}"

    [void] Set() {
        try {
            $this.WriteLogUtil('Verbose', $this.SetMethodStartMessage, @($this.DscResourceName))

            $this.ConnectVIServer()

            $this.RetrieveVMHost()

            $iScsiHba = $this.GetIScsiHba($this.Name)

            $this.ConfigureIScsiHba($iScsiHba)
        }
        finally {
            $this.DisconnectVIServer()

            $this.WriteLogUtil('Verbose', $this.SetMethodEndMessage, @($this.DscResourceName))
        }
    }

    [bool] Test() {
        try {
            $this.WriteLogUtil('Verbose', $this.TestMethodStartMessage, @($this.DscResourceName))

            $this.ConnectVIServer()

            $this.RetrieveVMHost()

            $iScsiHba = $this.GetIScsiHba($this.Name)

            $shouldConfigureiScsiHba = @(
                $this.ShouldModifyCHAPSettings($iScsiHba.AuthenticationProperties),
                $this.ShouldUpdateDscResourceSetting('IScsiName', $iScsiHba.IScsiName, $this.IScsiName)
            )
            $result = !($shouldConfigureiScsiHba -Contains $true)

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()

            $this.WriteLogUtil('Verbose', $this.TestMethodEndMessage, @($this.DscResourceName))
        }
    }

    [VMHostIScsiHba] Get() {
        try {
            $this.WriteLogUtil('Verbose', $this.GetMethodStartMessage, @($this.DscResourceName))

            $this.ConnectVIServer()

            $result = [VMHostIScsiHba]::new()

            $this.RetrieveVMHost()

            $iScsiHba = $this.GetIScsiHba($this.Name)

            $this.PopulateResult($result, $iScsiHba)

            return $result
        }
        finally {
            $this.DisconnectVIServer()

            $this.WriteLogUtil('Verbose', $this.GetMethodEndMessage, @($this.DscResourceName))
        }
    }

    <#
    .DESCRIPTION

    Configures the CHAP properties and the iScsi name of the specified iSCSI Host Bus Adapter.
    #>
    [void] ConfigureIScsiHba($iScsiHba) {
        $setVMHostHbaParams = @{
            IScsiHba = $iScsiHba
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        $this.PopulateCmdletParametersWithCHAPSettings($setVMHostHbaParams)
        if (![string]::IsNullOrEmpty($this.IScsiName)) { $setVMHostHbaParams.IScsiName = $this.IScsiName }

        try {
            $this.WriteLogUtil('Verbose', $this.ConfigureIScsiHbaMessage, @($iScsiHba.Device, $this.VMHost.Name))

            Set-VMHostHba @setVMHostHbaParams
        }
        catch {
            throw ($this.CouldNotConfigureIScsiHbaMessage -f $iScsiHba.Device, $this.VMHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $iScsiHba) {
        $result.Server = $this.Connection.Name
        $result.VMHostName = $this.VMHost.Name
        $result.Name = $iScsiHba.Device
        $result.IScsiName = $iScsiHba.IScsiName
        $result.ChapType = $iScsiHba.AuthenticationProperties.ChapType.ToString()
        $result.ChapName = [string] $iScsiHba.AuthenticationProperties.ChapName
        $result.MutualChapEnabled = $iScsiHba.AuthenticationProperties.MutualChapEnabled
        $result.MutualChapName = [string] $iScsiHba.AuthenticationProperties.MutualChapName
        $result.Force = $this.Force
    }
}
