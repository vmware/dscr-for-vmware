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
class VMHostTpsSettings : VMHostBaseDSC {
    <#
    .DESCRIPTION

    Share Scan Time Advanced Setting value.
    #>
    [DscProperty()]
    [nullable[int]] $ShareScanTime

    <#
    .DESCRIPTION

    Share Scan GHz Advanced Setting value.
    #>
    [DscProperty()]
    [nullable[int]] $ShareScanGHz

    <#
    .DESCRIPTION

    Share Rate Max Advanced Setting value.
    #>
    [DscProperty()]
    [nullable[int]] $ShareRateMax

    <#
    .DESCRIPTION

    Share Force Salting Advanced Setting value.
    #>
    [DscProperty()]
    [nullable[int]] $ShareForceSalting

    hidden [string] $TpsSettingsName = "Mem.Sh*"
    hidden [string] $MemValue = "Mem."

    [void] Set() {
        try {
            $this.ConnectVIServer()

            $this.WriteLogUtil('Verbose', $this.SetMethodStartMessage, @($this.DscResourceName))

            $vmHost = $this.GetVMHost()

            $this.UpdateTpsSettings($vmHost)
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

            $result = !$this.ShouldUpdateTpsSettings($vmHost)

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.WriteLogUtil('Verbose', $this.TestMethodEndMessage, @($this.DscResourceName))

            $this.DisconnectVIServer()
        }
    }

    [VMHostTpsSettings] Get() {
        try {
            $this.ConnectVIServer()

            $this.WriteLogUtil('Verbose', $this.GetMethodStartMessage, @($this.DscResourceName))

            $result = [VMHostTpsSettings]::new()
            $result.Server = $this.Server

            $vmHost = $this.GetVMHost()
            $result.Name = $vmHost.Name

            $tpsSettings = $this.GetTpsAdvancedSettings($vmHost)

            $vmHostTpsSettingsDscResourcePropertyNames = $this.GetType().GetProperties().Name
            foreach ($tpsSetting in $tpsSettings) {
                $tpsSettingName = $tpsSetting.Name.TrimStart($this.MemValue)
                if ($vmHostTpsSettingsDscResourcePropertyNames -Contains $tpsSettingName) {
                    $result.$tpsSettingName = $tpsSetting.Value
                }
            }

            return $result
        }
        finally {
            $this.WriteLogUtil('Verbose', $this.GetMethodEndMessage, @($this.DscResourceName))

            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Tps advanced settings for the specified VMHost from the server.
    #>
    [PSObject] GetTpsAdvancedSettings($vmHost) {
        $getAdvancedSettingParams = @{
            Server = $this.Connection
            Entity = $vmHost
            Name = $this.TpsSettingsName
            ErrorAction = 'Stop'
            Verbose = $false
        }

        return Get-AdvancedSetting @getAdvancedSettingParams
    }

    <#
    .DESCRIPTION

    Returns a boolean value, indicating if update operation should be performed on at least one of the TPS Settings.
    #>
    [bool] ShouldUpdateTpsSettings($vmHost) {
        $tpsSettings = $this.GetTpsAdvancedSettings($vmHost)

        foreach ($tpsSetting in $tpsSettings) {
            $tpsSettingName = $tpsSetting.Name.TrimStart($this.MemValue)

            if ($null -ne $this.$tpsSettingName -and $this.$tpsSettingName -ne $tpsSetting.Value) {
                $this.WriteLogUtil('Verbose', $this.SettingIsNotInDesiredStateMessage, @($tpsSettingName, $tpsSetting.Value, $this.$tpsSettingName))

                return $true
            }
        }

        return $false
    }

    <#
    .DESCRIPTION

    Updates the needed TPS Settings with the specified values.
    #>
    [void] UpdateTpsSettings($vmHost) {
        $tpsSettings = $this.GetTpsAdvancedSettings($vmHost)

        foreach ($tpsSetting in $tpsSettings) {
            $tpsSettingName = $tpsSetting.Name.TrimStart($this.MemValue)

            if ($null -eq $this.$tpsSettingName -or $this.$tpsSettingName -eq $tpsSetting.Value) {
                continue
            }

            $setAdvancedSettingParams = @{
                AdvancedSetting = $tpsSetting
                Value = $this.$tpsSettingName
                Confirm = $false
                ErrorAction = 'Stop'
                Verbose = $false
            }
            Set-AdvancedSetting @setAdvancedSettingParams
        }
    }
}
