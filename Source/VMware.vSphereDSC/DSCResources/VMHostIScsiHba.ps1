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
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)

            $writeToLogFilesplat = @{
                Connection = $this.Connection.Name
                ResourceName = $this.GetType().ToString()
                LogType = 'Verbose'
                Message = $this.SetMethodStartMessage
                Arguments = @($this.DscResourceName)
            }

            Write-LogToFile @writeToLogFilesplat

            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $iScsiHba = $this.GetIScsiHba($this.Name)

            $this.ConfigureIScsiHba($iScsiHba)
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.SetMethodEndMessage -Arguments @($this.DscResourceName)

            $writeToLogFilesplat = @{
                Connection = $this.Connection.Name
                ResourceName = $this.GetType().ToString()
                LogType = 'Verbose'
                Message = $this.SetMethodEndMessage
                Arguments = @($this.DscResourceName)
            }

            Write-LogToFile @writeToLogFilesplat
        }
    }

    [bool] Test() {
        try {
            Write-VerboseLog -Message $this.TestMethodStartMessage -Arguments @($this.DscResourceName)

            $writeToLogFilesplat = @{
                Connection = $this.Connection.Name
                ResourceName = $this.GetType().ToString()
                LogType = 'Verbose'
                Message = $this.TestMethodStartMessage
                Arguments = @($this.DscResourceName)
            }

            Write-LogToFile @writeToLogFilesplat

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
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)

            $writeToLogFilesplat = @{
                Connection = $this.Connection.Name
                ResourceName = $this.GetType().ToString()
                LogType = 'Verbose'
                Message = $this.TestMethodEndMessage
                Arguments = @($this.DscResourceName)
            }

            Write-LogToFile @writeToLogFilesplat
        }
    }

    [VMHostIScsiHba] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)

            $writeToLogFilesplat = @{
                Connection = $this.Connection.Name
                ResourceName = $this.GetType().ToString()
                LogType = 'Verbose'
                Message = $this.GetMethodStartMessage
                Arguments = @($this.DscResourceName)
            }

            Write-LogToFile @writeToLogFilesplat

            $result = [VMHostIScsiHba]::new()

            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $iScsiHba = $this.GetIScsiHba($this.Name)

            $this.PopulateResult($result, $iScsiHba)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)

            $writeToLogFilesplat = @{
                Connection = $this.Connection.Name
                ResourceName = $this.GetType().ToString()
                LogType = 'Verbose'
                Message = $this.GetMethodEndMessage
                Arguments = @($this.DscResourceName)
            }

            Write-LogToFile @writeToLogFilesplat
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
            Write-VerboseLog -Message $this.ConfigureIScsiHbaMessage -Arguments @($iScsiHba.Device, $this.VMHost.Name)
            
            $writeToLogFilesplat = @{
                Connection = $this.Connection.Name
                ResourceName = $this.GetType().ToString()
                LogType = 'Verbose'
                Message = $this.ConfigureIScsiHbaMessage
                Arguments = @($iScsiHba.Device, $this.VMHost.Name)
            }

            Write-LogToFile @writeToLogFilesplat
            
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
