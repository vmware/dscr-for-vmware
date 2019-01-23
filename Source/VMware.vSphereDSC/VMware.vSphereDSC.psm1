<#
Copyright (c) 2018 VMware, Inc.  All rights reserved				

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License 

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

Using module '.\VMware.vSphereDSC.Helper.psm1'

enum Ensure {
    Absent
    Present
}

enum LoggingLevel {
    Unset
    None
    Error
    Warning
    Info
    Verbose
    Trivia
}

enum Period {
    Day = 86400
    Week = 604800
    Month = 2629800
    Year = 31556926
}

enum ServicePolicy {
    Unset
    On
    Off
    Automatic
}

enum BadCertificateAction {
    Ignore
    Warn
    Prompt
    Fail
    Unset
}

enum DefaultVIServerMode {
    Single
    Multiple
    Unset
}

enum PowerCLISettingsScope {
    LCM
}

enum ProxyPolicy {
    NoProxy
    UseSystemProxy
    Unset
}

class BaseDSC {
    <#
    .DESCRIPTION

    Name of the Server we are trying to connect to. The Server can be a vCenter or ESXi.
    #>
    [DscProperty(Key)]
    [string] $Server

    <#
    .DESCRIPTION

    Credentials needed for connection to the specified Server.
    #>
    [DscProperty(Mandatory)]
    [PSCredential] $Credential

    <#
    .DESCRIPTION

    Established connection to the specified vSphere Server.
    #>
    hidden [PSObject] $Connection

    <#
    .DESCRIPTION

    Imports the needed VMware Modules.
    #>
    [void] ImportRequiredModules() {
        $savedVerbosePreference = $global:VerbosePreference
        $global:VerbosePreference = 'SilentlyContinue'

        Import-Module -Name VMware.VimAutomation.Core

        $global:VerbosePreference = $savedVerbosePreference
    }

    <#
    .DESCRIPTION

    Connects to the specified Server with the passed Credentials.
    The method sets the Connection property to the established connection.
    If connection cannot be established, the method writes an error.
    #>
    [void] ConnectVIServer() {
        $this.ImportRequiredModules()

        if ($null -eq $this.Connection) {
            try {
                $this.Connection = Connect-VIServer -Server $this.Server -Credential $this.Credential -ErrorAction Stop
            }
            catch {
                throw "Cannot establish connection to server $($this.Server). For more information: $($_.Exception.Message)"
            }
        }
    }
}

class VMHostBaseDSC : BaseDSC {
    <#
    .DESCRIPTION

    Name of the VMHost to configure.
    #>
    [DscProperty(Key)]
    [string] $Name

    <#
    .DESCRIPTION

    Returns the VMHost with the specified Name on the specified Server.
    If the VMHost is not found, the method writes an error.
    #>
    [PSObject] GetVMHost() {
        try {
            $vmHost = Get-VMHost -Server $this.Connection -Name $this.Name -ErrorAction Stop
            return $vmHost
        }
        catch {
            throw "VMHost with name $($this.Name) was not found. For more information: $($_.Exception.Message)"
        }
    }
}

[DscResource()]
class PowerCLISettings {
    <#
    .DESCRIPTION

    Specifies the scope on which the PowerCLI Settings will be applied.
    LCM is the only possible value for the Settings Scope.
    #>
    [DscProperty(Key)]
    [PowerCLISettingsScope] $SettingsScope

    <#
    .DESCRIPTION

    Specifies the proxy policy for the connection through which Customer Experience Improvement Program (CEIP) data is sent to VMware.
    #>
    [DscProperty()]
    [ProxyPolicy] $CEIPDataTransferProxyPolicy = [ProxyPolicy]::Unset

    <#
    .DESCRIPTION

    Specifies the server connection mode.
    #>
    [DscProperty()]
    [DefaultVIServerMode] $DefaultVIServerMode = [DefaultVIServerMode]::Unset

    <#
    .DESCRIPTION

    Indicates whether you want to see warnings about deprecated elements.
    #>
    [DscProperty()]
    [nullable[bool]] $DisplayDeprecationWarnings

    <#
    .DESCRIPTION

    Define the action to take when an attempted connection to a server fails due to a certificate error.
    #>
    [DscProperty()]
    [BadCertificateAction] $InvalidCertificateAction = [BadCertificateAction]::Unset

    <#
    .DESCRIPTION

    Specifies if PowerCLI should send anonymous usage information to VMware.
    #>
    [DscProperty()]
    [nullable[bool]] $ParticipateInCeip

    <#
    .DESCRIPTION

    Specifies whether VMware PowerCLI uses a system proxy server to connect to the vCenter Server system.
    #>
    [DscProperty()]
    [ProxyPolicy] $ProxyPolicy = [ProxyPolicy]::Unset

    <#
    .DESCRIPTION

    Defines the timeout for Web operations. The default value is 300 sec.
    #>
    [DscProperty()]
    [nullable[int]] $WebOperationTimeoutSeconds

    hidden [string] $Scope = "User"

    [void] Set() {
        $this.ImportRequiredModules()
        $powerCLIConfigurationProperties = $this.GetPowerCLIConfigurationProperties()

        $commandName = 'Set-PowerCLIConfiguration'
        $namesOfPowerCLIConfigurationProperties = $powerCLIConfigurationProperties.Keys

        <#
        For testability we use this function to construct the Set-PowerCLIConfiguration cmdlet instead of using splatting and passing the cmdlet parameters as hashtable.
        At the moment Pester does not allow to pass hashtable in the ParameterFilter property of the Assert-MockCalled function.
        There is an open issue in GitHub: (https://github.com/pester/Pester/issues/862) describing the problem in details.
        #>
        $constructedCommand = $this.ConstructCommandWithParameters($commandName, $powerCLIConfigurationProperties, $namesOfPowerCLIConfigurationProperties)
        Invoke-Expression -Command $constructedCommand
    }

    [bool] Test() {
        $this.ImportRequiredModules()
        $powerCLICurrentConfiguration = Get-PowerCLIConfiguration -Scope $this.Scope
        $powerCLIDesiredConfiguration = $this.GetPowerCLIConfigurationProperties()

        return $this.Equals($powerCLICurrentConfiguration, $powerCLIDesiredConfiguration)
    }

    [PowerCLISettings] Get() {
        $this.ImportRequiredModules()
        $result = [PowerCLISettings]::new()
        $powerCLICurrentConfiguration = Get-PowerCLIConfiguration -Scope $this.Scope

        $this.PopulateResult($powerCLICurrentConfiguration, $result)

        return $result
    }

    <#
    .DESCRIPTION

    Imports the needed VMware Modules.
    #>
    [void] ImportRequiredModules() {
        $savedVerbosePreference = $global:VerbosePreference
        $global:VerbosePreference = 'SilentlyContinue'

        Import-Module -Name VMware.VimAutomation.Core

        $global:VerbosePreference = $savedVerbosePreference
    }

    <#
    .DESCRIPTION

    Returns all passed PowerCLI configuration properties as a hashtable.
    #>
    [hashtable] GetPowerCLIConfigurationProperties() {
        $powerCLIConfigurationProperties = @{}

        # Adds the Default Scope to the hashtable.
        $powerCLIConfigurationProperties.Add("Scope", $this.Scope)

        if ($this.CEIPDataTransferProxyPolicy -ne [ProxyPolicy]::Unset -and $this.ParticipateInCeip -eq $true) {
            $powerCLIConfigurationProperties.Add("CEIPDataTransferProxyPolicy", $this.CEIPDataTransferProxyPolicy)
        }

        if ($this.DefaultVIServerMode -ne [DefaultVIServerMode]::Unset) {
            $powerCLIConfigurationProperties.Add("DefaultVIServerMode", $this.DefaultVIServerMode)
        }

        if ($null -ne $this.DisplayDeprecationWarnings) {
            $powerCLIConfigurationProperties.Add("DisplayDeprecationWarnings", $this.DisplayDeprecationWarnings)
        }

        if ($this.InvalidCertificateAction -ne [BadCertificateAction]::Unset) {
            $powerCLIConfigurationProperties.Add("InvalidCertificateAction", $this.InvalidCertificateAction)
        }

        if ($null -ne $this.ParticipateInCeip) {
            $powerCLIConfigurationProperties.Add("ParticipateInCeip", $this.ParticipateInCeip)
        }

        if ($this.ProxyPolicy -ne [ProxyPolicy]::Unset) {
            $powerCLIConfigurationProperties.Add("ProxyPolicy", $this.ProxyPolicy)
        }

        if ($null -ne $this.WebOperationTimeoutSeconds) {
            $powerCLIConfigurationProperties.Add("WebOperationTimeoutSeconds", $this.WebOperationTimeoutSeconds)
        }

        return $powerCLIConfigurationProperties
    }

    <#
    .DESCRIPTION

    Constructs the Set-PowerCLIConfiguration cmdlet with the passed properties.
    This function is used instead of splatting because at the moment Pester does not allow to pass hashtable in the ParameterFilter property of the Assert-MockCalled function.
    There is an open issue in GitHub: (https://github.com/pester/Pester/issues/862) describing the problem in details.
    So with this function we can successfully test which properties are passed to the Set-PowerCLIConfiguration cmdlet.
    #>
    [string] ConstructCommandWithParameters($commandName, $properties, $namesOfProperties) {
        $constructedCommand = [System.Text.StringBuilder]::new()

        # Adds the command name to the constructed command.
        [void]$constructedCommand.Append("$commandName ")

        # For every property name we add the property value with the following syntax: '-Property Value'.
        foreach ($propertyName in $namesOfProperties) {
            $propertyValue = $properties.$propertyName

            <#
            For bool values we need to add another '$' sign so the value can be evaluated to bool.
            So we check the type of the value and if it is a boolean we add another '$' sign, because without it the value will
            not be evaluated to boolean and instead it will be evaluated to string which will cause an exception of mismatching types.
            #>
            if ($propertyValue.GetType().Name -eq 'Boolean') {
                [void]$constructedCommand.Append("-$propertyName $")
                [void]$constructedCommand.Append("$propertyValue ")
            }
            else {
                [void]$constructedCommand.Append("-$propertyName $propertyValue ")
            }
        }

        # Adds the confirm:$false to the command to ignore the confirmation.
        [void]$constructedCommand.Append("-Confirm:`$false")

        # Converts the StringBuilder to String and returns the result.
        return $constructedCommand.ToString()
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if the current PowerCLI Configuration is equal to the Desired Configuration.
    #>
    [bool] Equals($powerCLICurrentConfiguration, $powerCLIDesiredConfiguration) {
        foreach ($key in $powerCLIDesiredConfiguration.Keys) {
            <#
            Currently works only for properties which are numbers, strings and enums. For more complex types like
            Hashtable the logic needs to be modified to work correctly.
            #>
            if ($powerCLIDesiredConfiguration.$key.ToString() -ne $powerCLICurrentConfiguration.$key.ToString()) {
                return $false
            }
        }

        return $true
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the PowerCLI settings from the server.
    #>
    [void] PopulateResult($powerCLICurrentConfiguration, $result) {
        $result.SettingsScope = $this.SettingsScope
        $result.CEIPDataTransferProxyPolicy = if ($null -ne $powerCLICurrentConfiguration.CEIPDataTransferProxyPolicy) { $powerCLICurrentConfiguration.CEIPDataTransferProxyPolicy.ToString() } else { [ProxyPolicy]::Unset }
        $result.DefaultVIServerMode = if ($null -ne $powerCLICurrentConfiguration.DefaultVIServerMode) { $powerCLICurrentConfiguration.DefaultVIServerMode.ToString() } else { [DefaultVIServerMode]::Unset }
        $result.DisplayDeprecationWarnings = $powerCLICurrentConfiguration.DisplayDeprecationWarnings
        $result.InvalidCertificateAction = if ($null -ne $powerCLICurrentConfiguration.InvalidCertificateAction) { $powerCLICurrentConfiguration.InvalidCertificateAction.ToString() } else { [BadCertificateAction]::Unset }
        $result.ParticipateInCeip = $powerCLICurrentConfiguration.ParticipateInCEIP
        $result.ProxyPolicy = if ($null -ne $powerCLICurrentConfiguration.ProxyPolicy) { $powerCLICurrentConfiguration.ProxyPolicy.ToString() } else { [ProxyPolicy]::Unset }
        $result.WebOperationTimeoutSeconds = $powerCLICurrentConfiguration.WebOperationTimeoutSeconds
    }
}

[DscResource()]
class vCenterSettings : BaseDSC {
    <#
    .DESCRIPTION

    Logging Level Advanced Setting value.
    #>
    [DscProperty()]
    [LoggingLevel] $LoggingLevel

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
        $this.ConnectVIServer()
        $this.UpdatevCenterSettings($this.Connection)
    }

    [bool] Test() {
        $this.ConnectVIServer()
        return !$this.ShouldUpdatevCenterSettings($this.Connection)
    }

    [vCenterSettings] Get() {
        $result = [vCenterSettings]::new()
        $result.Server = $this.Server

        $this.ConnectVIServer()
        $this.PopulateResult($this.Connection, $result)

        return $result
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if the Advanced Setting value should be updated.
    #>
    [bool] ShouldUpdateSettingValue($desiredValue, $currentValue) {
        <#
            LoggingLevel type properties should be updated only when Desired value is different than Unset.
            Unset means that value was not specified for such type of property.
        #>
        if ($desiredValue -is [LoggingLevel] -and $desiredValue -eq [LoggingLevel]::Unset) {
            return $false
        }

        <#
            Desired value equal to $null means that the setting value was not specified.
            If it is specified we check if the setting value is not equal to the current value.
        #>
        return ($null -ne $desiredValue -and $desiredValue -ne $currentValue)
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if at least one Advanced Setting value should be updated.
    #>
    [bool] ShouldUpdatevCenterSettings($vCenter) {
        $vCenterCurrentAdvancedSettings = Get-AdvancedSetting -Server $this.Connection -Entity $vCenter

    	$currentLogLevel = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.LogLevelSettingName }
    	$currentEventMaxAgeEnabled = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.EventMaxAgeEnabledSettingName }
    	$currentEventMaxAge = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.EventMaxAgeSettingName }
    	$currentTaskMaxAgeEnabled = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.TaskMaxAgeEnabledSettingName }
    	$currentTaskMaxAge = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.TaskMaxAgeSettingName }
    	$currentMotd = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.MotdSettingName }
    	$currentIssue = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.IssueSettingName }

    	$shouldUpdatevCenterSettings = @()
    	$shouldUpdatevCenterSettings += $this.ShouldUpdateSettingValue($this.LoggingLevel, $currentLogLevel.Value)
    	$shouldUpdatevCenterSettings += $this.ShouldUpdateSettingValue($this.EventMaxAgeEnabled, $currentEventMaxAgeEnabled.Value)
    	$shouldUpdatevCenterSettings += $this.ShouldUpdateSettingValue($this.EventMaxAge, $currentEventMaxAge.Value)
    	$shouldUpdatevCenterSettings += $this.ShouldUpdateSettingValue($this.TaskMaxAgeEnabled, $currentTaskMaxAgeEnabled.Value)
    	$shouldUpdatevCenterSettings += $this.ShouldUpdateSettingValue($this.TaskMaxAge, $currentTaskMaxAge.Value)
    	$shouldUpdatevCenterSettings += ($this.MotdClear -and ($currentMotd.Value -ne [string]::Empty)) -or (-not $this.MotdClear -and ($this.Motd -ne $currentMotd.Value))
        $shouldUpdatevCenterSettings += ($this.IssueClear -and ($currentIssue.Value -ne [string]::Empty)) -or (-not $this.IssueClear -and ($this.Issue -ne $currentIssue.Value))

    	return ($shouldUpdatevCenterSettings -Contains $true)
    }

    <#
    .DESCRIPTION

    Sets the desired value for the Advanced Setting, if update of the Advanced Setting value is needed.
    #>
   [void] SetAdvancedSetting($advancedSetting, $advancedSettingDesiredValue, $advancedSettingCurrentValue) {
        if ($this.ShouldUpdateSettingValue($advancedSettingDesiredValue, $advancedSettingCurrentValue)) {
            Set-AdvancedSetting -AdvancedSetting $advancedSetting -Value $advancedSettingDesiredValue -Confirm:$false
        }
    }

    <#
    .DESCRIPTION

    Sets the desired value for the Advanced Setting, if update of the Advanced Setting value is needed.
    This handles Advanced Settings that have a "Clear" property.
    #>

    [void] SetAdvancedSetting($advancedSetting, $advancedSettingDesiredValue, $advancedSettingCurrentValue, $clearValue) {
        Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

    	if ($clearValue) {
      	    if ($this.ShouldUpdateSettingValue([string]::Empty, $advancedSettingCurrentValue)) {
                Set-AdvancedSetting -AdvancedSetting $advancedSetting -Value [string]::Empty -Confirm:$false
      	    }
    	}
    	else {
      	    if ($this.ShouldUpdateSettingValue($advancedSettingDesiredValue, $advancedSettingCurrentValue)) {
                Set-AdvancedSetting -AdvancedSetting $advancedSetting -Value $advancedSettingDesiredValue -Confirm:$false
      	    }
    	}
  	}

    <#
    .DESCRIPTION

    Performs update on those Advanced Settings values that needs to be updated.
    #>
    [void] UpdatevCenterSettings($vCenter) {
        $vCenterCurrentAdvancedSettings = Get-AdvancedSetting -Server $this.Connection -Entity $vCenter

        $currentLogLevel = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.LogLevelSettingName }
        $currentEventMaxAgeEnabled = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.EventMaxAgeEnabledSettingName }
        $currentEventMaxAge = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.EventMaxAgeSettingName }
        $currentTaskMaxAgeEnabled = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.TaskMaxAgeEnabledSettingName }
        $currentTaskMaxAge = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.TaskMaxAgeSettingName }
    	$currentMotd = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.MotdSettingName }
    	$currentIssue = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.IssueSettingName }

        $this.SetAdvancedSetting($currentLogLevel, $this.LoggingLevel, $currentLogLevel.Value)
        $this.SetAdvancedSetting($currentEventMaxAgeEnabled, $this.EventMaxAgeEnabled, $currentEventMaxAgeEnabled.Value)
        $this.SetAdvancedSetting($currentEventMaxAge, $this.EventMaxAge, $currentEventMaxAge.Value)
        $this.SetAdvancedSetting($currentTaskMaxAgeEnabled, $this.TaskMaxAgeEnabled, $currentTaskMaxAgeEnabled.Value)
        $this.SetAdvancedSetting($currentTaskMaxAge, $this.TaskMaxAge, $currentTaskMaxAge.Value)
    	$this.SetAdvancedSetting($currentMotd, $this.Motd, $currentMotd.Value, $this.MotdClear)
    	$this.SetAdvancedSetting($currentIssue, $this.Issue, $currentIssue.Value, $this.IssueClear)
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the advanced settings from the server.
    #>
    [void] PopulateResult($vCenter, $result) {
        $vCenterCurrentAdvancedSettings = Get-AdvancedSetting -Server $this.Connection -Entity $vCenter

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

[DscResource()]
class vCenterStatistics : BaseDSC {
    <#
    .DESCRIPTION

    The unit of period. Statistics can be stored separatelly for each of the {Day, Week, Month, Year} period units.
    #>
    [DscProperty(Key)]
    [Period] $Period

    <#
    .DESCRIPTION

    Period for which the statistics are saved.
    #>
    [DscProperty()]
    [nullable[long]] $PeriodLength

    <#
    .DESCRIPTION

    Specified Level value for the vCenter Statistics.
    #>
    [DscProperty()]
    [nullable[int]] $Level

    <#
    .DESCRIPTION

    If collecting statistics for the specified period unit is enabled.
    #>
    [DscProperty()]
    [nullable[bool]] $Enabled

    <#
    .DESCRIPTION

    Interval in Minutes, indicating the period for collecting statistics.
    #>
    [DscProperty()]
    [nullable[long]] $IntervalMinutes

    hidden [int] $SecondsInAMinute = 60

    [void] Set() {
        $this.ConnectVIServer()
        $performanceManager = $this.GetPerformanceManager()
        $currentPerformanceInterval = $this.GetPerformanceInterval($performanceManager)

        $this.UpdatePerformanceInterval($performanceManager, $currentPerformanceInterval)
    }

    [bool] Test() {
        $this.ConnectVIServer()
        $performanceManager = $this.GetPerformanceManager()
        $currentPerformanceInterval = $this.GetPerformanceInterval($performanceManager)

        return $this.Equals($currentPerformanceInterval)
    }

    [vCenterStatistics] Get() {
        $result = [vCenterStatistics]::new()
        $result.Server = $this.Server
        $result.Period = $this.Period

        $this.ConnectVIServer()
        $performanceManager = $this.GetPerformanceManager()
        $currentPerformanceInterval = $this.GetPerformanceInterval($performanceManager)

        $result.Level = $currentPerformanceInterval.Level
        $result.Enabled = $currentPerformanceInterval.Enabled

        # Converts the Sampling Period from seconds to minutes
        $result.IntervalMinutes = $currentPerformanceInterval.SamplingPeriod / $this.SecondsInAMinute

        # Converts the PeriodLength from seconds to the specified Period type
        $result.PeriodLength = $currentPerformanceInterval.Length / $this.Period

        return $result
    }

    <#
    .DESCRIPTION

    Returns the Performance Manager for the specified vCenter.
    #>
    [PSObject] GetPerformanceManager() {
        $vCenter = $this.Connection
        $performanceManager = Get-View -Server $this.Connection $vCenter.ExtensionData.Content.PerfManager

        return $performanceManager
    }

    <#
    .DESCRIPTION

    Returns the Performance Interval for which the new statistics settings should be applied.
    #>
    [PSObject] GetPerformanceInterval($performanceManager) {
        $currentPerformanceInterval = $performanceManager.HistoricalInterval | Where-Object { $_.Name -Match $this.Period }

        return $currentPerformanceInterval
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if the desired and current values are equal.
    #>
    [bool] AreEqual($desiredValue, $currentValue) {
        <#
            Desired value equal to $null means the value is not specified and should be ignored when we check for equality.
            So in this case we return $true. Otherwise we check if the Specified value is equal to the current value.
        #>
        return ($null -eq $desiredValue -or $desiredValue -eq $currentValue)
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if the Current Performance Interval is equal to the Desired Performance Interval.
    #>
    [bool] Equals($currentPerformanceInterval) {
        $equalLevels = $this.AreEqual($this.Level, $currentPerformanceInterval.Level)
        $equalEnabled = $this.AreEqual($this.Enabled, $currentPerformanceInterval.Enabled)
        $equalIntervalMinutes = $this.AreEqual($this.IntervalMinutes, $currentPerformanceInterval.SamplingPeriod / $this.SecondsInAMinute)
        $equalPeriodLength = $this.AreEqual($this.PeriodLength, $currentPerformanceInterval.Length / $this.Period)

        return ($equalLevels -and $equalEnabled -and $equalIntervalMinutes -and $equalPeriodLength)
    }

    <#
    .DESCRIPTION

    Returns the value to set for the Performance Interval Setting.
    #>
    [PSObject] SpecifiedOrCurrentValue($desiredValue, $currentValue) {
        if ($null -eq $desiredValue) {
            # Desired value is not specified
            return $currentValue
        }
        else {
            return $desiredValue
        }
    }

    <#
    .DESCRIPTION

    Updates the Performance Interval with the specified settings for vCenter Statistics.
    #>
    [void] UpdatePerformanceInterval($performanceManager, $currentPerformanceInterval) {
        $performanceIntervalArgs = @{
            Key = $currentPerformanceInterval.Key
            Name = $currentPerformanceInterval.Name
            Enabled = $this.SpecifiedOrCurrentValue($this.Enabled, $currentPerformanceInterval.Enabled)
            Level = $this.SpecifiedOrCurrentValue($this.Level, $currentPerformanceInterval.Level)
            SamplingPeriod = $this.SpecifiedOrCurrentValue($this.IntervalMinutes * $this.SecondsInAMinute, $currentPerformanceInterval.SamplingPeriod)
            Length = $this.SpecifiedOrCurrentValue($this.PeriodLength * $this.Period, $currentPerformanceInterval.Length)
        }

        $desiredPerformanceInterval = New-PerformanceInterval @performanceIntervalArgs

        try {
            Update-PerfInterval -PerformanceManager $performanceManager -PerformanceInterval $desiredPerformanceInterval
        }
        catch {
            throw "Server operation failed with the following error: $($_.Exception.Message)"
        }
    }
}

[DscResource()]
class VMHostDnsSettings : VMHostBaseDSC {
    <#
    .DESCRIPTION


    List of domain name or IP address of the DNS Servers.
    #>
    [DscProperty()]
    [string[]] $Address

    <#
    .DESCRIPTION

    Indicates whether DHCP is used to determine DNS configuration.
    #>
    [DscProperty(Mandatory)]
    [bool] $Dhcp

    <#
    .DESCRIPTION

    Domain Name portion of the DNS name. For example, "vmware.com".
    #>
    [DscProperty(Mandatory)]
    [string] $DomainName

    <#
    .DESCRIPTION

    Host Name portion of DNS name. For example, "esx01".
    #>
    [DscProperty(Mandatory)]
    [string] $HostName

    <#
    .DESCRIPTION

    Desired value for the VMHost DNS Ipv6VirtualNicDevice.
    #>
    [DscProperty()]
    [string] $Ipv6VirtualNicDevice

    <#
    .DESCRIPTION

    Domain in which to search for hosts, placed in order of preference.
    #>
    [DscProperty()]
    [string[]] $SearchDomain

    <#
    .DESCRIPTION

    Desired value for the VMHost DNS VirtualNicDevice.
    #>
    [DscProperty()]
    [string] $VirtualNicDevice

    [void] Set() {
        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()

        $this.UpdateDns($vmHost)
    }

    [bool] Test() {
        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()
        $vmHostDnsConfig = $vmHost.ExtensionData.Config.Network.DnsConfig

        return $this.Equals($vmHostDnsConfig)
    }

    [VMHostDnsSettings] Get() {
        $result = [VMHostDnsSettings]::new()

        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()
        $vmHostDnsConfig = $vmHost.ExtensionData.Config.Network.DnsConfig

        $result.Name = $vmHost.Name
        $result.Server = $this.Server
        $result.Address = $vmHostDnsConfig.Address
        $result.Dhcp = $vmHostDnsConfig.Dhcp
        $result.DomainName = $vmHostDnsConfig.DomainName
        $result.HostName = $vmHostDnsConfig.HostName
        $result.Ipv6VirtualNicDevice = $vmHostDnsConfig.Ipv6VirtualNicDevice
        $result.SearchDomain = $vmHostDnsConfig.SearchDomain
        $result.VirtualNicDevice = $vmHostDnsConfig.VirtualNicDevice

        return $result
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if the desired DNS array property is equal to the current DNS array property.
    #>
    [bool] AreDnsArrayPropertiesEqual($desiredArrayPropertyValue, $currentArrayPropertyValue) {
        $valuesToAdd = $desiredArrayPropertyValue | Where-Object { $currentArrayPropertyValue -NotContains $_ }
        $valuesToRemove = $currentArrayPropertyValue | Where-Object { $desiredArrayPropertyValue -NotContains $_ }

        return ($null -eq $valuesToAdd -and $null -eq $valuesToRemove)
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if the desired DNS optional value is equal to the current DNS value from the server.
    #>
    [bool] AreDnsOptionalPropertiesEqual($desiredPropertyValue, $currentPropertyValue) {
        if ([string]::IsNullOrEmpty($desiredPropertyValue) -and [string]::IsNullOrEmpty($currentPropertyValue)) {
            return $true
        }

        return $desiredPropertyValue -eq $currentPropertyValue
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if the current DNS Config is equal to the Desired DNS Config.
    #>
    [bool] Equals($vmHostDnsConfig) {
        # Checks if desired Mandatory values are equal to current values from server.
        if ($this.Dhcp -ne $vmHostDnsConfig.Dhcp -or $this.DomainName -ne $vmHostDnsConfig.DomainName -or $this.HostName -ne $vmHostDnsConfig.HostName) {
            return $false
        }

        if (!$this.AreDnsArrayPropertiesEqual($this.Address, $vmHostDnsConfig.Address) -or !$this.AreDnsArrayPropertiesEqual($this.SearchDomain, $vmHostDnsConfig.SearchDomain)) {
            return $false
        }

        if (!$this.AreDnsOptionalPropertiesEqual($this.Ipv6VirtualNicDevice, $vmHostDnsConfig.Ipv6VirtualNicDevice) -or !$this.AreDnsOptionalPropertiesEqual($this.VirtualNicDevice, $vmHostDnsConfig.VirtualNicDevice)) {
            return $false
        }

        return $true
    }

    <#
    .DESCRIPTION

    Updates the DNS Config of the VMHost with the Desired DNS Config.
    #>
    [void] UpdateDns($vmHost) {
        $dnsConfigArgs = @{
            Address = $this.Address
            Dhcp = $this.Dhcp
            DomainName = $this.DomainName
            HostName = $this.HostName
            Ipv6VirtualNicDevice = $this.Ipv6VirtualNicDevice
            SearchDomain = $this.SearchDomain
            VirtualNicDevice = $this.VirtualNicDevice
        }

        $dnsConfig = New-DNSConfig @dnsConfigArgs
        $networkSystem = Get-View -Server $this.Connection $vmHost.ExtensionData.ConfigManager.NetworkSystem

        try {
            Update-DNSConfig -NetworkSystem $networkSystem -DnsConfig $dnsConfig
        }
        catch {
            throw "The DNS Config could not be updated: $($_.Exception.Message)"
        }
    }
}

[DscResource()]
class VMHostNtpSettings : VMHostBaseDSC {
    <#
    .DESCRIPTION

    List of domain name or IP address of the desired NTP Servers.
    #>
    [DscProperty()]
    [string[]] $NtpServer

    <#
    .DESCRIPTION

    Desired Policy of the VMHost 'ntpd' service activation.
    #>
    [DscProperty()]
    [ServicePolicy] $NtpServicePolicy

    hidden [string] $ServiceId = "ntpd"

    [void] Set() {
        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()

        $this.UpdateVMHostNtpServer($vmHost)
        $this.UpdateVMHostNtpServicePolicy($vmHost)
    }

    [bool] Test() {
        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()
        $vmHostNtpConfig = $vmHost.ExtensionData.Config.DateTimeInfo.NtpConfig

        $shouldUpdateVMHostNtpServer = $this.ShouldUpdateVMHostNtpServer($vmHostNtpConfig)
        if ($shouldUpdateVMHostNtpServer) {
            return $false
        }

        $vmHostServices = $vmHost.ExtensionData.Config.Service
        $shouldUpdateVMHostNtpServicePolicy = $this.ShouldUpdateVMHostNtpServicePolicy($vmHostServices)
        if ($shouldUpdateVMHostNtpServicePolicy) {
            return $false
        }

        return $true
    }

    [VMHostNtpSettings] Get() {
        $result = [VMHostNtpSettings]::new()

        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()
        $vmHostNtpConfig = $vmHost.ExtensionData.Config.DateTimeInfo.NtpConfig
        $vmHostServices = $vmHost.ExtensionData.Config.Service
        $vmHostNtpService = $vmHostServices.Service | Where-Object { $_.Key -eq $this.ServiceId }

        $result.Name = $vmHost.Name
        $result.Server = $this.Server
        $result.NtpServer = $vmHostNtpConfig.Server
        $result.NtpServicePolicy = $vmHostNtpService.Policy

        return $result
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if the VMHost NTP Server should be updated.
    #>
    [bool] ShouldUpdateVMHostNtpServer($vmHostNtpConfig) {
        $desiredVMHostNtpServer = $this.NtpServer
        $currentVMHostNtpServer = $vmHostNtpConfig.Server

        if ($null -eq $desiredVMHostNtpServer) {
            # The property is not specified.
            return $false
        }
        elseif ($desiredVMHostNtpServer.Length -eq 0 -and $currentVMHostNtpServer.Length -ne 0) {
            # Empty array specified as desired, but current is not an empty array, so update VMHost NTP Server.
            return $true
        }
        else {
            $ntpServerToAdd = $desiredVMHostNtpServer | Where-Object { $currentVMHostNtpServer -NotContains $_ }
            $ntpServerToRemove = $currentVMHostNtpServer | Where-Object { $desiredVMHostNtpServer -NotContains $_ }

            if ($null -ne $ntpServerToAdd -or $null -ne $ntpServerToRemove) {
                <#
                The currentVMHostNtpServer does not contain at least one element from desiredVMHostNtpServer or
                the desiredVMHostNtpServer is a subset of the currentVMHostNtpServer. In both cases
                we should update VMHost NTP Server.
                #>
                return $true
            }

            # No need to update VMHost NTP Server.
            return $false
        }
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if the VMHost 'ntpd' Service Policy should be updated.
    #>
    [bool] ShouldUpdateVMHostNtpServicePolicy($vmHostServices) {
        if ($this.NtpServicePolicy -eq [ServicePolicy]::Unset) {
            # The property is not specified.
            return $false
        }

        $vmHostNtpService = $vmHostServices.Service | Where-Object { $_.Key -eq $this.ServiceId }

        return $this.NtpServicePolicy -ne $vmHostNtpService.Policy
    }

    <#
    .DESCRIPTION

    Updates the VMHost NTP Server with the desired NTP Server array.
    #>
    [void] UpdateVMHostNtpServer($vmHost) {
        $vmHostNtpConfig = $vmHost.ExtensionData.Config.DateTimeInfo.NtpConfig
        $shouldUpdateVMHostNtpServer = $this.ShouldUpdateVMHostNtpServer($vmHostNtpConfig)

        if (!$shouldUpdateVMHostNtpServer) {
            return
        }

        $dateTimeConfig = New-DateTimeConfig -NtpServer $this.NtpServer
        $dateTimeSystem = Get-View -Server $this.Connection $vmHost.ExtensionData.ConfigManager.DateTimeSystem

        Update-DateTimeConfig -DateTimeSystem $dateTimeSystem -DateTimeConfig $dateTimeConfig
    }

    <#
    .DESCRIPTION

    Updates the VMHost 'ntpd' Service Policy with the desired Service Policy.
    #>
    [void] UpdateVMHostNtpServicePolicy($vmHost) {
        $vmHostService = $vmHost.ExtensionData.Config.Service
        $shouldUpdateVMHostNtpServicePolicy = $this.ShouldUpdateVMHostNtpServicePolicy($vmHostService)
        if (!$shouldUpdateVMHostNtpServicePolicy) {
            return
        }

        $serviceSystem = Get-View -Server $this.Connection $vmHost.ExtensionData.ConfigManager.ServiceSystem
        Update-ServicePolicy -ServiceSystem $serviceSystem -ServiceId $this.ServiceId -ServicePolicyValue $this.NtpServicePolicy.ToString().ToLower()
    }
}

[DscResource()]
class VMHostSatpClaimRule : VMHostBaseDSC {
    <#
    .DESCRIPTION

    Value indicating if the SATP Claim Rule should be Present or Absent.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    <#
    .DESCRIPTION

    Name of the SATP Claim Rule.
    #>
    [DscProperty(Mandatory)]
    [string] $RuleName

    <#
    .DESCRIPTION

    PSP options for the SATP Claim Rule.
    #>
    [DscProperty()]
    [string] $PSPOptions

    <#
    .DESCRIPTION

    Transport Property of the Satp Claim Rule.
    #>
    [DscProperty()]
    [string] $Transport

    <#
    .DESCRIPTION

    Description string to set when adding the SATP Claim Rule.
    #>
    [DscProperty()]
    [string] $Description

    <#
    .DESCRIPTION

    Vendor string to set when adding the SATP Claim Rule.
    #>
    [DscProperty()]
    [string] $Vendor

    <#
    .DESCRIPTION

    System default rule added at boot time.
    #>
    [DscProperty()]
    [bool] $Boot

    <#
    .DESCRIPTION

    Claim type for the SATP Claim Rule.
    #>
    [DscProperty()]
    [string] $Type

    <#
    .DESCRIPTION

    Device of the SATP Claim Rule.
    #>
    [DscProperty()]
    [string] $Device

    <#
    .DESCRIPTION

    Driver string for the SATP Claim Rule.
    #>
    [DscProperty()]
    [string] $Driver

    <#
    .DESCRIPTION

    Claim option string for the SATP Claim Rule.
    #>
    [DscProperty()]
    [string] $ClaimOptions

    <#
    .DESCRIPTION

    Default PSP for the SATP Claim Rule.
    #>
    [DscProperty()]
    [string] $Psp

    <#
    .DESCRIPTION

    Option string for the SATP Claim Rule.
    #>
    [DscProperty()]
    [string] $Options

    <#
    .DESCRIPTION

    Model string for the SATP Claim Rule.
    #>
    [DscProperty()]
    [string] $Model

    <#
    .DESCRIPTION

    Value, which ignores validity checks and install the rule anyway.
    #>
    [DscProperty()]
    [bool] $Force

    [void] Set() {
        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()
        $esxCli = Get-EsxCli -Server $this.Connection -VMHost $vmHost -V2
        $satpClaimRule = $this.GetSatpClaimRule($esxCli)
        $satpClaimRulePresent = ($null -ne $satpClaimRule)

        if ($this.Ensure -eq [Ensure]::Present) {
            if (!$satpClaimRulePresent) {
                $this.AddSatpClaimRule($esxCli)
            }
        }
        else {
            if ($satpClaimRulePresent) {
                $this.RemoveSatpClaimRule($esxCli)
            }
        }
    }

    [bool] Test() {
        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()
        $esxCli = Get-EsxCli -Server $this.Connection -VMHost $vmHost -V2
        $satpClaimRule = $this.GetSatpClaimRule($esxCli)
        $satpClaimRulePresent = ($null -ne $satpClaimRule)

        if ($this.Ensure -eq [Ensure]::Present) {
            return $satpClaimRulePresent
        }
        else {
            return -not $satpClaimRulePresent
        }
    }

    [VMHostSatpClaimRule] Get() {
        $result = [VMHostSatpClaimRule]::new()

        $result.Server = $this.Server
        $result.RuleName = $this.RuleName
        $result.Boot = $this.Boot
        $result.Type = $this.Type
        $result.Force = $this.Force

        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()
        $result.Name = $vmHost.Name
        $esxCli = Get-EsxCli -Server $this.Connection -VMHost $vmHost -V2
        $satpClaimRule = $this.GetSatpClaimRule($esxCli)
        $satpClaimRulePresent = ($null -ne $satpClaimRule)

        if (!$satpClaimRulePresent) {
            $result.Ensure = "Absent"
            $result.Psp = $this.Psp
            $this.PopulateResult($result, $this)
        }
        else {
            $result.Ensure = "Present"
            $result.Psp = $satpClaimRule.DefaultPSP
            $this.PopulateResult($result, $satpClaimRule)
        }

        return $result
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if the desired SATP Claim Rule is equal to the passed SATP Claim Rule.
    #>
    [bool] Equals($satpClaimRule) {
        if ($this.RuleName -ne $satpClaimRule.Name) {
            return $false
        }

        <#
            For every optional property we check if it is not passed(if it is null), because
            all properties on the server, which are not set are returned as empty strings and
            if we compare null with empty string the equality will fail.
        #>

        if ($null -ne $this.PSPOptions -and $this.PSPOptions -ne $satpClaimRule.PSPOptions) {
            return $false
        }

        if ($null -ne $this.Transport -and $this.Transport -ne $satpClaimRule.Transport) {
            return $false
        }

        if ($null -ne $this.Description -and $this.Description -ne $satpClaimRule.Description) {
            return $false
        }

        if ($null -ne $this.Vendor -and $this.Vendor -ne $satpClaimRule.Vendor) {
            return $false
        }

        if ($null -ne $this.Device -and $this.Device -ne $satpClaimRule.Device) {
            return $false
        }

        if ($null -ne $this.Driver -and $this.Driver -ne $satpClaimRule.Driver) {
            return $false
        }

        if ($null -ne $this.ClaimOptions -and $this.ClaimOptions -ne $satpClaimRule.ClaimOptions) {
            return $false
        }

        if ($null -ne $this.Psp -and $this.Psp -ne $satpClaimRule.DefaultPSP) {
            return $false
        }

        if ($null -ne $this.Options -and $this.Options -ne $satpClaimRule.Options) {
            return $false
        }

        if ($null -ne $this.Model -and $this.Model -ne $satpClaimRule.Model) {
            return $false
        }

        return $true
    }

    <#
    .DESCRIPTION

    Returns the desired SatpClaimRule if the Rule is present on the server, otherwise returns $null.
    #>
    [PSObject] GetSatpClaimRule($esxCli) {
        $foundSatpClaimRule = $null
        $satpClaimRules = Get-SATPClaimRules -EsxCli $esxCli

        foreach ($satpClaimRule in $satpClaimRules) {
            if ($this.Equals($satpClaimRule)) {
                $foundSatpClaimRule = $satpClaimRule
                break
            }
        }

        return $foundSatpClaimRule
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the SATP Claim Rule properties from the server.
    #>
    [void] PopulateResult($result, $satpClaimRule) {
        $result.PSPoptions = $satpClaimRule.PSPOptions
        $result.Transport = $satpClaimRule.Transport
        $result.Description = $satpClaimRule.Description
        $result.Vendor = $satpClaimRule.Vendor
        $result.Device = $satpClaimRule.Device
        $result.Driver = $satpClaimRule.Driver
        $result.ClaimOptions = $satpClaimRule.ClaimOptions
        $result.Options = $satpClaimRule.Options
        $result.Model = $satpClaimRule.Model
    }

    <#
    .DESCRIPTION

    Populates the arguments for the Add and Remove operations of SATP Claim Rule with the specified properties from the user.
    #>
    [void] PopulateSatpArgs($satpArgs) {
        $satpArgs.satp = $this.RuleName
        $satpArgs.pspoption = $this.PSPoptions
        $satpArgs.transport = $this.Transport
        $satpArgs.description = $this.Description
        $satpArgs.vendor = $this.Vendor
        $satpArgs.boot = $this.Boot
        $satpArgs.type = $this.Type
        $satpArgs.device = $this.Device
        $satpArgs.driver = $this.Driver
        $satpArgs.claimoption = $this.ClaimOptions
        $satpArgs.psp = $this.Psp
        $satpArgs.option = $this.Options
        $satpArgs.model = $this.Model
    }

    <#
    .DESCRIPTION

    Installs the new SATP Claim Rule with the specified properties from the user.
    #>
    [void] AddSatpClaimRule($esxCli) {
        $satpArgs = Add-CreateArgs -EsxCli $esxCli
        $satpArgs.force = $this.Force

        $this.PopulateSatpArgs($satpArgs)

        try {
            Add-SATPClaimRule -EsxCli $esxCli -SatpArgs $satpArgs
        }
        catch {
            throw "EsxCLI command for adding satp rule failed with the following exception: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Uninstalls the SATP Claim Rule with the specified properties from the user.
    #>
    [void] RemoveSatpClaimRule($esxCli) {
        $satpArgs = Remove-CreateArgs -EsxCli $esxCli

        $this.PopulateSatpArgs($satpArgs)

        try {
            Remove-SATPClaimRule -EsxCli $esxCli -SatpArgs $satpArgs
        }
        catch {
            throw "EsxCLI command for removing satp rule failed with the following exception: $($_.Exception.Message)"
        }
    }
}

[DscResource()]
class VMHostService : VMHostBaseDSC {
    <#
    .DESCRIPTION

    The key value of the service.
    #>
    [DscProperty(Mandatory)]
    [string] $Key

    <#
    .DESCRIPTION

    The state of the service after a VMHost reboot.
    #>
    [DscProperty()]
    [ServicePolicy] $Policy

    <#
    .DESCRIPTION

    The current state of the service.
    #>
    [DscProperty()]
    [bool] $Running

    <#
    .DESCRIPTION

    Host Service Label.
    #>
    [DscProperty(NotConfigurable)]
    [string] $Label

    <#
    .DESCRIPTION

    Host Service Required flag.
    #>
    [DscProperty(NotConfigurable)]
    [bool] $Required

    <#
    .DESCRIPTION

    Firewall rules for the service.
    #>
    [DscProperty(NotConfigurable)]
    [string[]] $Ruleset

    [void] Set() {
        Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()

        $this.UpdateVMHostService($vmHost)
    }

    [bool] Test() {
        Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()

        return !$this.ShouldUpdateVMHostService($vmHost)
    }

    [VMHostService] Get() {
        Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

        $result = [VMHostService]::new()
        $result.Server = $this.Server

        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()
        $this.PopulateResult($vmHost, $result)

        return $result
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if the VMHostService should to be updated.
    #>
    [bool] ShouldUpdateVMHostService($vmHost) {
        Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

        $vmHostCurrentService = Get-VMHostService -Server $this.Connection -VMHost $vmHost | Where-Object {$_.Key -eq $this.Key}

        $shouldUpdateVMHostService = @()
        $shouldUpdateVMHostService += $this.Policy -ne $vmHostCurrentService.Policy
        $shouldUpdateVMHostService += $this.Running -ne $vmHostCurrentService.Running

        return ($shouldUpdateVMHostService -Contains $true)
    }

    <#
    .DESCRIPTION

    Updates the configuration of the VMHostService.
    #>
    [void] UpdateVMHostService($vmHost) {
        Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

        $vmHostCurrentService = Get-VMHostService -Server $this.Connection -VMHost $vmHost | Where-Object {$_.Key -eq $this.Key}

        if ($vmHostCurrentService.Policy -ne $this.Policy) {
            Set-VMHostService -HostService $vmHostCurrentService -Policy $this.Policy.ToString() -Confirm:$false
        }

        if ($vmHostCurrentService.Running -ne $this.Running) {
            if ($vmHostCurrentService.Running) {
                Stop-VMHostService -HostService $vmHostCurrentService -Confirm:$false
            }
            else {
                Start-VMHostService -HostService $vmHostCurrentService -Confirm:$false
            }
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the VMHostService from the server.
    #>
    [void] PopulateResult($vmHost, $vmHostService) {
        Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

        $vmHostCurrentService = Get-VMHostService -Server $this.Connection -VMHost $vmHost | Where-Object {$_.Key -eq $this.Key}
        $vmHostService.Name = $vmHost.Name
        $vmHostService.Server = $this.Server
        $vmHostService.Key = $vmHostCurrentService.Key
        $vmHostService.Policy = $vmHostCurrentService.Policy
        $vmHostService.Running = $vmHostCurrentService.Running
        $vmHostService.Label = $vmHostCurrentService.Label
        $vmHostService.Required = $vmHostCurrentService.Required
        $vmHostService.Ruleset = $vmHostCurrentService.Ruleset
    }
}

[DscResource()]
class VMHostSettings : VMHostBaseDSC {
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

    hidden [string] $IssueSettingName = "Config.Etc.issue"
    hidden [string] $MotdSettingName = "Config.Etc.motd"

    [void] Set() {
    	Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

    	$this.ConnectVIServer()
    	$vmHost = $this.GetVMHost()

        $this.UpdateVMHostSettings($vmHost)
    }

    [bool] Test() {
    	Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

    	$this.ConnectVIServer()
    	$vmHost = $this.GetVMHost()

        return !$this.ShouldUpdateVMHostSettings($vmHost)
    }

    [VMHostSettings] Get() {
    	Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

        $result = [VMHostSettings]::new()
        $result.Server = $this.Server

    	$this.ConnectVIServer()
    	$vmHost = $this.GetVMHost()
    	$this.PopulateResult($vmHost, $result)

        return $result
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if the Advanced Setting value should be updated.
    #>
    [bool] ShouldUpdateSettingValue($desiredValue, $currentValue) {
    	<#
        Desired value equal to $null means that the setting value was not specified.
        If it is specified we check if the setting value is not equal to the current value.
        #>
    	Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

        return ($null -ne $desiredValue -and $desiredValue -ne $currentValue)
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if at least one Advanced Setting value should be updated.
    #>
    [bool] ShouldUpdateVMHostSettings($vmHost) {
    	Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

    	$vmHostCurrentAdvancedSettings = Get-AdvancedSetting -Server $this.Connection -Entity $vmHost

    	$currentMotd = $vmHostCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.MotdSettingName }
    	$currentIssue = $vmHostCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.IssueSettingName }

    	$shouldUpdateVMHostSettings = @()
    	$shouldUpdateVMHostSettings += ($this.MotdClear -and ($currentMotd.Value -ne [string]::Empty)) -or (-not $this.MotdClear -and ($this.Motd -ne $currentMotd.Value))
    	$shouldUpdateVMHostSettings += ($this.IssueClear -and ($currentIssue.Value -ne [string]::Empty)) -or (-not $this.IssueClear -and ($this.Issue -ne $currentIssue.Value))

        return ($shouldUpdateVMHostSettings -Contains $true)
    }

  	<#
    .DESCRIPTION

    Sets the desired value for the Advanced Setting, if update of the Advanced Setting value is needed.
    #>
  	[void] SetAdvancedSetting($advancedSetting, $advancedSettingDesiredValue, $advancedSettingCurrentValue, $clearValue) {
    	Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

    	if ($clearValue) {
      	    if ($this.ShouldUpdateSettingValue([string]::Empty, $advancedSettingCurrentValue)) {
                  Set-AdvancedSetting -AdvancedSetting $advancedSetting -Value [string]::Empty -Confirm:$false
      	    }
    	}
    	else {
      	    if ($this.ShouldUpdateSettingValue($advancedSettingDesiredValue, $advancedSettingCurrentValue)) {
                  Set-AdvancedSetting -AdvancedSetting $advancedSetting -Value $advancedSettingDesiredValue -Confirm:$false
      	    }
    	}
    }

    <#
    .DESCRIPTION

    Performs update on those Advanced Settings values that needs to be updated.
    #>
    [void] UpdateVMHostSettings($vmHost) {
    	Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

    	$vmHostCurrentAdvancedSettings = Get-AdvancedSetting -Server $this.Connection -Entity $vmHost

    	$currentMotd = $vmHostCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.MotdSettingName }
    	$currentIssue = $vmHostCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.IssueSettingName }

    	$this.SetAdvancedSetting($currentMotd, $this.Motd, $currentMotd.Value, $this.MotdClear)
        $this.SetAdvancedSetting($currentIssue, $this.Issue, $currentIssue.Value, $this.IssueClear)
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the advanced settings from the server.
    #>
    [void] PopulateResult($vmHost, $result) {
    	Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

    	$vmHostCurrentAdvancedSettings = Get-AdvancedSetting -Server $this.Connection -Entity $vmHost

    	$currentMotd = $vmHostCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.MotdSettingName }
    	$currentIssue = $vmHostCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.IssueSettingName }

        $result.Name = $vmHost.Name
    	$result.Motd = $currentMotd.Value
        $result.Issue = $currentIssue.Value
    }
}

[DscResource()]
class VMHostSyslog : VMHostBaseDSC {
    <#
    .DESCRIPTION

    The remote host(s) to send logs to.
    #>
    [DscProperty()]
    [string] $Loghost

    <#
    .DESCRIPTION

    Verify remote SSL certificates against the local CA Store.
    #>
    [DscProperty()]
    [bool] $CheckSslCerts

    <#
    .DESCRIPTION

    Default network retry timeout in seconds if a remote server fails to respond.
    #>
    [DscProperty()]
    [long] $DefaultTimeout

    <#
    .DESCRIPTION

    Message queue capacity after which messages are dropped.
    #>
    [DscProperty()]
    [long] $QueueDropMark

    <#
    .DESCRIPTION

    The directory to output local logs to.
    #>
    [DscProperty()]
    [string] $Logdir

    <#
    .DESCRIPTION

    Place logs in a unique subdirectory of logdir, based on hostname.
    #>
    [DscProperty()]
    [bool] $LogdirUnique

    <#
    .DESCRIPTION

    Default number of rotated local logs to keep.
    #>
    [DscProperty()]
    [long] $DefaultRotate

    <#
    .DESCRIPTION

    Default size of local logs before rotation, in KiB.
    #>
    [DscProperty()]
    [long] $DefaultSize

    <#
    .DESCRIPTION

    Number of rotated dropped log files to keep.
    #>
    [DscProperty()]
    [long] $DropLogRotate

    <#
    .DESCRIPTION

    Size of dropped log file before rotation, in KiB.
    #>
    [DscProperty()]
    [long] $DropLogSize

    [void] Set() {
        Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()

        $this.UpdateVMHostSyslog($vmHost)
    }

    [bool] Test() {
        Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()

        return !$this.ShouldUpdateVMHostSyslog($vmHost)
    }

    [VMHostSyslog] Get() {
        Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

        $result = [VMHostSyslog]::new()

        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()
        $this.PopulateResult($vmHost, $result)

        return $result
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if VMHostSyslog needs to be updated.
    #>
    [bool] ShouldUpdateVMHostSyslog($VMHost) {
        Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

        $esxcli = Get-Esxcli -Server $this.Connection -VMHost $vmHost -V2
        $current = Get-VMHostSyslogConfig -EsxCLi $esxcli

        $shouldUpdateVMHostSyslog = @()

        $shouldUpdateVMHostSyslog += $this.LogHost -ne $current.LogHost
        $shouldUpdateVMHostSyslog += $this.CheckSslCerts -ne $current.EnforceSSLCertificates
        $shouldUpdateVMHostSyslog += $this.DefaultTimeout -ne $current.DefaultNetworkRetryTimeout
        $shouldUpdateVMHostSyslog += $this.QueueDropMark -ne $current.MessageQueueDropMark
        $shouldUpdateVMHostSyslog += $this.Logdir -ne $current.LocalLogOutput
        $shouldUpdateVMHostSyslog += $this.LogdirUnique -ne $current.LogToUniqueSubdirectory
        $shouldUpdateVMHostSyslog += $this.DefaultRotate -ne $current.LocalLoggingDefaultRotations
        $shouldUpdateVMHostSyslog += $this.DefaultSize -ne $current.LocalLoggingDefaultRotationSize
        $shouldUpdateVMHostSyslog += $this.DropLogRotate -ne $current.DroppedLogFileRotations
        $shouldUpdateVMHostSyslog += $this.DropLogSize -ne $current.DroppedLogFileRotationSize

        return ($shouldUpdateVMHostSyslog -contains $true)
    }

    <#
    .DESCRIPTION

    Updates the configuration of the VMHostSyslog.
    #>
    [void] UpdateVMHostSyslog($VMHost) {
        Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

        $esxcli = Get-Esxcli -Server $this.Connection -VMHost $vmHost -V2

        $VMHostSyslogConfig = @{
            loghost = $this.Loghost
            checksslcerts = $this.CheckSslCerts
            defaulttimeout = $this.DefaultTimeout
            queuedropmark = $this.QueueDropMark
            logdir = $this.Logdir
            logdirunique = $this.LogdirUnique
            defaultrotate = $this.DefaultRotate
            defaultsize = $this.DefaultSize
            droplogrotate = $this.DropLogRotate
            droplogsize = $this.DropLogSize
        }
        Set-VMHostSyslogConfig -EsxCli $esxcli -VMHostSyslogConfig $VMHostSyslogConfig
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the VMHostService from the server.
    #>
    [void] PopulateResult($VMHost, $syslog) {
        Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

        $esxcli = Get-Esxcli -Server $this.Connection -VMHost $vmHost -V2
        $currentVMHostSyslog = Get-VMHostSyslogConfig -EsxCLi $esxcli

        $syslog.Server = $this.Server
        $syslog.Name = $VMHost.Name
        $syslog.Loghost = $currentVMHostSyslog.LogHost
        $syslog.CheckSslCerts = $currentVMHostSyslog.CheckSslCerts
        $syslog.DefaultTimeout = $currentVMHostSyslog.DefaultTimeout
        $syslog.QueueDropMark = $currentVMHostSyslog.QueueDropMark
        $syslog.Logdir = $currentVMHostSyslog.Logdir
        $syslog.LogdirUnique = $currentVMHostSyslog.LogdirUnique
        $syslog.DefaultRotate = $currentVMHostSyslog.DefaultRotate
        $syslog.DefaultSize = $currentVMHostSyslog.DefaultSize
        $syslog.DropLogRotate = $currentVMHostSyslog.DropLogRotate
        $syslog.DropLogSize = $currentVMHostSyslog.DropLogSize
    }
}

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
        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()

        $this.UpdateTpsSettings($vmHost)
    }

    [bool] Test() {
        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()
        $shouldUpdateTpsSettings = $this.ShouldUpdateTpsSettings($vmHost)

        return !$shouldUpdateTpsSettings
    }

    [VMHostTpsSettings] Get() {
        $result = [VMHostTpsSettings]::new()
        $result.Server = $this.Server

        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()
        $result.Name = $vmHost.Name
        $tpsSettings = Get-AdvancedSetting -Server $this.Connection -Entity $vmHost -Name $this.TpsSettingsName

        foreach ($tpsSetting in $tpsSettings) {
            $tpsSettingName = $tpsSetting.Name.TrimStart($this.MemValue)

            $result.$tpsSettingName = $tpsSetting.Value
        }

        return $result
    }

    <#
    .DESCRIPTION

    Returns a boolean value, indicating if update operation should be performed on at least one of the TPS Settings.
    #>
    [bool] ShouldUpdateTpsSettings($vmHost) {
        $tpsSettings = Get-AdvancedSetting -Server $this.Connection -Entity $vmHost -Name $this.TpsSettingsName

        foreach ($tpsSetting in $tpsSettings) {
            $tpsSettingName = $tpsSetting.Name.TrimStart($this.MemValue)

            if ($null -ne $this.$tpsSettingName -and $this.$tpsSettingName -ne $tpsSetting.Value) {
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
        $tpsSettings = Get-AdvancedSetting -Server $this.Connection -Entity $vmHost -Name $this.TpsSettingsName

        foreach ($tpsSetting in $tpsSettings) {
            $tpsSettingName = $tpsSetting.Name.TrimStart($this.MemValue)

            if ($null -eq $this.$tpsSettingName -or $this.$tpsSettingName -eq $tpsSetting.Value) {
                continue
            }

            Set-AdvancedSetting -AdvancedSetting $tpsSetting -Value $this.$tpsSettingName -Confirm:$false
        }
    }
}
