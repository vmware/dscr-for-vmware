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
class VMHostAdvancedSettings : VMHostBaseDSC {
    <#
    .DESCRIPTION

    Hashtable containing the advanced settings of the specified VMHost, where
    each key-value pair represents one advanced setting - the key is the name of the
    setting and the value is the desired value for the setting.
    #>
    [DscProperty(Mandatory)]
    [hashtable] $AdvancedSettings

    [void] Set() {
    	try {
            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()

            $this.UpdateVMHostAdvancedSettings($vmHost)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
    	try {
            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()

            return !$this.ShouldUpdateVMHostAdvancedSettings($vmHost)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostAdvancedSettings] Get() {
        try {
            $result = [VMHostAdvancedSettings]::new()
            $result.Server = $this.Server

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()

            $result.Name = $vmHost.Name
            $result.AdvancedSettings = @{}

            $this.PopulateResult($vmHost, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Advanced Settings of the specified VMHost from the server.
    #>
    [array] GetAdvancedSettings($vmHost) {
        try {
            $retrievedAdvancedSettings = Get-AdvancedSetting -Server $this.Connection -Entity $vmHost -ErrorAction Stop
            return $retrievedAdvancedSettings
        }
        catch {
            throw "Could not retrieve the Advanced Settings of VMHost $($vmHost.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Returns the Advanced Setting if it is present in the retrieved Advanced Settings from the server.
    Otherwise returns $null.
    #>
    [PSObject] GetAdvancedSetting($retrievedAdvancedSettings, $advancedSettingName, $vmHostName) {
        $advancedSetting = $retrievedAdvancedSettings | Where-Object { $_.Name -eq $advancedSettingName }
        if ($null -eq $advancedSetting) {
            <#
            Here 'Write-Warning' is used instead of 'throw' to ensure that the execution will not stop
            if an invalid Advanced Setting is present in the passed hashtable and in the same time to
            provide an information to the user that invalid data is passed.
            #>
            Write-WarningLog -Message "Advanced Setting {0} does not exist for VMHost {1} and will be ignored." -Arguments @($advancedSettingName, $vmHostName)
        }

        return $advancedSetting
    }

    <#
    .DESCRIPTION

    Converts the desired value of the Advanced Setting from the hashtable to the correct type of the value
    from the server. Works only for primitive types.
    #>
    [object] ConvertAdvancedSettingDesiredValueToCorrectType($advancedSetting) {
        $advancedSettingDesiredValue = $null
        if ($advancedSetting.Value -is [bool]) {
            # For bool values the '-as' operator returns 'True' for both 'true' and 'false' strings so specific conversion is needed.
            $advancedSettingDesiredValue = [System.Convert]::ToBoolean($this.AdvancedSettings[$advancedSetting.Name])
        }
        else {
            $advancedSettingDesiredValue = $this.AdvancedSettings[$advancedSetting.Name] -as $advancedSetting.Value.GetType()
        }

        return $advancedSettingDesiredValue
    }

    <#
    .DESCRIPTION

    Checks if the Advanced Setting should be updated depending on the passed desired value.
    #>
    [bool] ShouldUpdateVMHostAdvancedSetting($advancedSetting) {
        <#
        Each element in the hashtable is of type MSFT_KeyValuePair where the value is a string.
        So before comparison the value needs to be converted to its original type which can be
        retrieved from its server value.
        #>
        $advancedSettingDesiredValue = $this.ConvertAdvancedSettingDesiredValueToCorrectType($advancedSetting)

        return ($advancedSettingDesiredValue -ne $advancedSetting.Value)
    }

    <#
    .DESCRIPTION

    Checks if any of the Advanced Settings present in the hashtable need to be updated.
    #>
    [bool] ShouldUpdateVMHostAdvancedSettings($vmHost) {
        $retrievedAdvancedSettings = $this.GetAdvancedSettings($vmHost)

        foreach ($advancedSettingName in $this.AdvancedSettings.Keys) {
            $advancedSetting = $this.GetAdvancedSetting($retrievedAdvancedSettings, $advancedSettingName, $vmHost.Name)

            if ($null -ne $advancedSetting -and $this.ShouldUpdateVMHostAdvancedSetting($advancedSetting)) {
                return $true
            }
        }

        return $false
    }

    <#
    .DESCRIPTION

    Returns the Advanced Option Manager of the specified VMHost.
    #>
    [PSObject] GetVMHostAdvancedOptionManager($vmHost) {
        try {
            $vmHostAdvancedOptionManager = Get-View -Server $this.Connection -Id $vmHost.ExtensionData.ConfigManager.AdvancedOption -ErrorAction Stop
            return $vmHostAdvancedOptionManager
        }
        catch {
            throw "VMHost Advanced Option Manager could not be retrieved. For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Performs an update on these Advanced Settings that are present in the hashtable and
    need to be updated.
    #>
    [void] UpdateVMHostAdvancedSettings($vmHost) {
        $retrievedAdvancedSettings = $this.GetAdvancedSettings($vmHost)
        $vmHostAdvancedOptionManager = $this.GetVMHostAdvancedOptionManager($vmHost)
        $options = @()

        foreach ($advancedSettingName in $this.AdvancedSettings.Keys) {
            $advancedSetting = $this.GetAdvancedSetting($retrievedAdvancedSettings, $advancedSettingName, $vmHost.Name)

            if ($null -ne $advancedSetting -and $this.ShouldUpdateVMHostAdvancedSetting($advancedSetting)) {
                <#
                Each element in the hashtable is of type MSFT_KeyValuePair where the value is a string.
                So before setting the value of the option, we need to convert it to its original type which can be
                retrieved from its server value.
                #>
                $option = New-Object VMware.Vim.OptionValue
                $option.Key = $advancedSettingName
                $option.Value = $this.ConvertAdvancedSettingDesiredValueToCorrectType($advancedSetting)

                $options += $option
            }
        }

        if ($options.Length -eq 0) {
            return
        }

        try {
            Update-VMHostAdvancedSettings -VMHostAdvancedOptionManager $vmHostAdvancedOptionManager -Options $options
        }
        catch {
            throw "The Advanced Settings Update operation failed with the following error: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the Advanced Settings from the server.
    #>
    [void] PopulateResult($vmHost, $result) {
        $retrievedAdvancedSettings = $this.GetAdvancedSettings($vmHost)

        foreach ($advancedSettingName in $this.AdvancedSettings.Keys) {
            $advancedSetting = $this.GetAdvancedSetting($retrievedAdvancedSettings, $advancedSettingName, $vmHost.Name)

            if ($null -ne $advancedSetting) {
                <#
                The LCM converts the hashtable to MSFT_KeyValuePair class which has the following properties:
                Key of type string and Value of type string. So the value of the Advanced Setting from the server
                should be converted to string to avoid an error to be thrown. This will only work for primitive types
                like bool, int, long and so on. If a non-primitive type is introduced for Advanced Setting, invalid result
                will be returned from the conversion.
                #>
                $result.AdvancedSettings[$advancedSettingName] = $advancedSetting.Value.ToString()
            }
        }
    }
}
