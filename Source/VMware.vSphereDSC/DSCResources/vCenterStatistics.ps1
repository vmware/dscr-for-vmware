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

            $performanceManager = $this.GetPerformanceManager()
            $currentPerformanceInterval = $this.GetPerformanceInterval($performanceManager)

            $this.UpdatePerformanceInterval($performanceManager, $currentPerformanceInterval)
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

            $performanceManager = $this.GetPerformanceManager()
            $currentPerformanceInterval = $this.GetPerformanceInterval($performanceManager)

            $result = !((
                $this.ShouldUpdateDscResourceSetting('Level', $currentPerformanceInterval.Level, $this.Level),
                $this.ShouldUpdateDscResourceSetting('Enabled', $currentPerformanceInterval.Enabled, $this.Enabled),
                $this.ShouldUpdateDscResourceSetting('IntervalMinutes', $currentPerformanceInterval.SamplingPeriod / $this.SecondsInAMinute, $this.IntervalMinutes),
                $this.ShouldUpdateDscResourceSetting('PeriodLength', $currentPerformanceInterval.Length / $this.Period, $this.PeriodLength)
            ) -Contains $true)

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

    [vCenterStatistics] Get() {
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

    Returns the Performance Manager for the specified vCenter.
    #>
    [PSObject] GetPerformanceManager() {
        $getViewParams = @{
            Server = $this.Connection
            Id = $this.Connection.ExtensionData.Content.PerfManager
            ErrorAction = 'Stop'
            Verbose = $false
        }

        return Get-View @getViewParams
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
