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
class vCenterSettings : BaseDSC {
    <#
    .DESCRIPTION

    Logging Level Advanced Setting value.
    #>
    [DscProperty()]
    [LoggingLevel] $LoggingLevel = [LoggingLevel]::Unset

    <#
    .DESCRIPTION

    Event Max Age Enabled Advanced Setting value.
    #>
    [DscProperty()]
    [nullable[bool]] $EventMaxAgeEnabled

    <#
    .DESCRIPTION

    Event Max Age Advanced Setting value.
    #>
    [DscProperty()]
    [nullable[int]] $EventMaxAge

    <#
    .DESCRIPTION

    Task Max Age Enabled Advanced Setting value.
    #>
    [DscProperty()]
    [nullable[bool]] $TaskMaxAgeEnabled

    <#
    .DESCRIPTION

    Task Max Age Advanced Setting value.
    #>
    [DscProperty()]
    [nullable[int]] $TaskMaxAge

    <#
    .DESCRIPTION

    Motd Advanced Setting value.
    #>
    [DscProperty()]
    [string] $Motd

    <#
    .DESCRIPTION

    Indicates whether the Motd content should be cleared.
    #>
    [DscProperty()]
    [bool] $MotdClear

    <#
    .DESCRIPTION

    Issue Advanced Setting value.
    #>
    [DscProperty()]
    [string] $Issue

    <#
    .DESCRIPTION

    Indicates whether the Issue content should be cleared.
    #>
    [DscProperty()]
    [bool] $IssueClear

    hidden [string] $LogLevelSettingName = "log.level"
    hidden [string] $EventMaxAgeEnabledSettingName = "event.maxAgeEnabled"
    hidden [string] $EventMaxAgeSettingName = "event.maxAge"
    hidden [string] $TaskMaxAgeEnabledSettingName = "task.maxAgeEnabled"
    hidden [string] $TaskMaxAgeSettingName = "task.maxAge"
    hidden [string] $MotdSettingName = "etc.motd"
    hidden [string] $IssueSettingName = "etc.issue"

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()

            $this.UpdatevCenterSettings($this.Connection)
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

            $result = !$this.ShouldUpdatevCenterSettings()

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [vCenterSettings] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [vCenterSettings]::new()
            $result.Server = $this.Server

            $this.ConnectVIServer()
            $this.PopulateResult($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the advanced settings of the specified vCenter Server.
    #>
    [PSObject] GetvCenterAdvancedSettings() {
        $getAdvancedSettingParams = @{
            Server = $this.Connection
            Entity = $this.Connection
            ErrorAction = 'Stop'
            Verbose = $false
        }

        return Get-AdvancedSetting @getAdvancedSettingParams
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if at least one Advanced Setting value should be updated.
    #>
    [bool] ShouldUpdatevCenterSettings() {
        $vCenterCurrentAdvancedSettings = $this.GetvCenterAdvancedSettings()

    	$currentLogLevel = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.LogLevelSettingName }
    	$currentEventMaxAgeEnabled = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.EventMaxAgeEnabledSettingName }
    	$currentEventMaxAge = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.EventMaxAgeSettingName }
    	$currentTaskMaxAgeEnabled = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.TaskMaxAgeEnabledSettingName }
    	$currentTaskMaxAge = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.TaskMaxAgeSettingName }
    	$currentMotd = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.MotdSettingName }
        $currentIssue = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.IssueSettingName }

        $motdDesiredValue = if ($this.MotdClear) { [string]::Empty } else { $this.Motd }
        $issueDesiredValue = if ($this.IssueClear) { [string]::Empty } else { $this.Issue }

    	$shouldUpdatevCenterSettings = @(
            $this.ShouldUpdateDscResourceSetting('LoggingLevel', [string] $currentLogLevel.Value, $this.LoggingLevel.ToString()),
            $this.ShouldUpdateDscResourceSetting('EventMaxAgeEnabled', $currentEventMaxAgeEnabled.Value, $this.EventMaxAgeEnabled),
            $this.ShouldUpdateDscResourceSetting('EventMaxAge', $currentEventMaxAge.Value, $this.EventMaxAge),
            $this.ShouldUpdateDscResourceSetting('TaskMaxAgeEnabled', $currentTaskMaxAgeEnabled.Value, $this.TaskMaxAgeEnabled),
            $this.ShouldUpdateDscResourceSetting('TaskMaxAge', $currentTaskMaxAge.Value, $this.TaskMaxAge),
            $this.ShouldUpdateDscResourceSetting('Motd', $currentMotd.Value, $motdDesiredValue),
            $this.ShouldUpdateDscResourceSetting('Issue', $currentIssue.Value, $issueDesiredValue)
        )

    	return ($shouldUpdatevCenterSettings -Contains $true)
    }

    <#
    .DESCRIPTION

    Sets the desired value for the Advanced Setting, if update of the Advanced Setting value is needed.
    #>
   [void] SetAdvancedSetting($advancedSettingName, $advancedSetting, $advancedSettingDesiredValue, $advancedSettingCurrentValue) {
        if ($this.ShouldUpdateDscResourceSetting($advancedSettingName, $advancedSettingCurrentValue, $advancedSettingDesiredValue)) {
            $setAdvancedSettingParams = @{
                AdvancedSetting = $advancedSetting
                Value = $advancedSettingDesiredValue
                Confirm = $false
                ErrorAction = 'Stop'
                Verbose = $false
            }
            Set-AdvancedSetting @setAdvancedSettingParams
        }
    }

    <#
    .DESCRIPTION

    Sets the desired value for the Advanced Setting, if update of the Advanced Setting value is needed.
    This handles Advanced Settings that have a "Clear" property.
    #>

    [void] SetAdvancedSetting($advancedSettingName, $advancedSetting, $advancedSettingDesiredValue, $advancedSettingCurrentValue, $clearValue) {
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

    	if ($clearValue) {
      	    if ($this.ShouldUpdateDscResourceSetting($advancedSettingName, $advancedSettingCurrentValue, [string]::Empty)) {
                $setAdvancedSettingParams = @{
                    AdvancedSetting = $advancedSetting
                    Value = [string]::Empty
                    Confirm = $false
                    ErrorAction = 'Stop'
                    Verbose = $false
                }
                Set-AdvancedSetting @setAdvancedSettingParams
      	    }
    	}
    	else {
            $this.SetAdvancedSetting($advancedSettingName, $advancedSetting, $advancedSettingDesiredValue, $advancedSettingCurrentValue)
    	}
  	}

    <#
    .DESCRIPTION

    Performs update on those Advanced Settings values that needs to be updated.
    #>
    [void] UpdatevCenterSettings($vCenter) {
        $vCenterCurrentAdvancedSettings = $this.GetvCenterAdvancedSettings()

        $currentLogLevel = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.LogLevelSettingName }
        $currentEventMaxAgeEnabled = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.EventMaxAgeEnabledSettingName }
        $currentEventMaxAge = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.EventMaxAgeSettingName }
        $currentTaskMaxAgeEnabled = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.TaskMaxAgeEnabledSettingName }
        $currentTaskMaxAge = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.TaskMaxAgeSettingName }
    	$currentMotd = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.MotdSettingName }
    	$currentIssue = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.IssueSettingName }

        $this.SetAdvancedSetting('LoggingLevel', $currentLogLevel, $this.LoggingLevel.ToString(), $currentLogLevel.Value)
        $this.SetAdvancedSetting('EventMaxAgeEnabled', $currentEventMaxAgeEnabled, $this.EventMaxAgeEnabled, $currentEventMaxAgeEnabled.Value)
        $this.SetAdvancedSetting('EventMaxAge', $currentEventMaxAge, $this.EventMaxAge, $currentEventMaxAge.Value)
        $this.SetAdvancedSetting('TaskMaxAgeEnabled', $currentTaskMaxAgeEnabled, $this.TaskMaxAgeEnabled, $currentTaskMaxAgeEnabled.Value)
        $this.SetAdvancedSetting('TaskMaxAge', $currentTaskMaxAge, $this.TaskMaxAge, $currentTaskMaxAge.Value)
    	$this.SetAdvancedSetting('Motd', $currentMotd, $this.Motd, $currentMotd.Value, $this.MotdClear)
    	$this.SetAdvancedSetting('Issue', $currentIssue, $this.Issue, $currentIssue.Value, $this.IssueClear)
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the advanced settings from the server.
    #>
    [void] PopulateResult($result) {
        $vCenterCurrentAdvancedSettings = $this.GetvCenterAdvancedSettings()

        $currentLogLevel = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.LogLevelSettingName }
        $currentEventMaxAgeEnabled = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.EventMaxAgeEnabledSettingName }
        $currentEventMaxAge = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.EventMaxAgeSettingName }
        $currentTaskMaxAgeEnabled = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.TaskMaxAgeEnabledSettingName }
        $currentTaskMaxAge = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.TaskMaxAgeSettingName }
        $currentMotd = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.MotdSettingName }
        $currentIssue = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.IssueSettingName }

        $result.LoggingLevel = $currentLogLevel.Value
        $result.EventMaxAgeEnabled = $currentEventMaxAgeEnabled.Value
        $result.EventMaxAge = $currentEventMaxAge.Value
        $result.TaskMaxAgeEnabled = $currentTaskMaxAgeEnabled.Value
        $result.TaskMaxAge = $currentTaskMaxAge.Value
        $result.Motd = $currentMotd.Value
        $result.Issue = $currentIssue.Value
    }
}
