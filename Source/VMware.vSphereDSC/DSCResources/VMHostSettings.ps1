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
    	try {
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

            $writeToLogFilesplat = @{
                Connection = $this.Connection.Name
                ResourceName = $this.GetType().ToString()
                LogType = 'Verbose'
                Message = "{0} Entering {1}"
                Arguments = @((Get-Date), (Get-PSCallStack)[0].FunctionName)
            }

            Write-LogToFile @writeToLogFilesplat


            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()

            $this.UpdateVMHostSettings($vmHost)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
    	try {
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

            $writeToLogFilesplat = @{
                Connection = $this.Connection.Name
                ResourceName = $this.GetType().ToString()
                LogType = 'Verbose'
                Message = "{0} Entering {1}"
                Arguments = @((Get-Date), (Get-PSCallStack)[0].FunctionName)
            }

            Write-LogToFile @writeToLogFilesplat


            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()

            $result = !$this.ShouldUpdateVMHostSettings($vmHost)

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostSettings] Get() {
    	try {
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

            $writeToLogFilesplat = @{
                Connection = $this.Connection.Name
                ResourceName = $this.GetType().ToString()
                LogType = 'Verbose'
                Message = "{0} Entering {1}"
                Arguments = @((Get-Date), (Get-PSCallStack)[0].FunctionName)
            }

            Write-LogToFile @writeToLogFilesplat


            $result = [VMHostSettings]::new()
            $result.Server = $this.Server

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $this.PopulateResult($vmHost, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if at least one Advanced Setting value should be updated.
    #>
    [bool] ShouldUpdateVMHostSettings($vmHost) {
    	Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

    $writeToLogFilesplat = @{
        Connection = $this.Connection.Name
        ResourceName = $this.GetType().ToString()
        LogType = 'Verbose'
        Message = "{0} Entering {1}"
        Arguments = @((Get-Date), (Get-PSCallStack)[0].FunctionName)
    }

    Write-LogToFile @writeToLogFilesplat


    	$vmHostCurrentAdvancedSettings = Get-AdvancedSetting -Server $this.Connection -Entity $vmHost

    	$currentMotd = $vmHostCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.MotdSettingName }
        $currentIssue = $vmHostCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.IssueSettingName }

        $motdDesiredValue = if ($this.MotdClear) { [string]::Empty } else { $this.Motd }
        $issueDesiredValue = if ($this.IssueClear) { [string]::Empty } else { $this.Issue }

    	$shouldUpdateVMHostSettings = @(
            $this.ShouldUpdateDscResourceSetting('Motd', $currentMotd.Value, $motdDesiredValue),
            $this.ShouldUpdateDscResourceSetting('Issue', $currentIssue.Value, $issueDesiredValue)
        )

        return ($shouldUpdateVMHostSettings -Contains $true)
    }

    <#
    .DESCRIPTION

    Sets the desired value for the Advanced Setting, if update of the Advanced Setting value is needed.
    #>
  	[void] SetAdvancedSetting($advancedSettingName, $advancedSetting, $advancedSettingDesiredValue, $advancedSettingCurrentValue, $clearValue) {
    	Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

    $writeToLogFilesplat = @{
        Connection = $this.Connection.Name
        ResourceName = $this.GetType().ToString()
        LogType = 'Verbose'
        Message = "{0} Entering {1}"
        Arguments = @((Get-Date), (Get-PSCallStack)[0].FunctionName)
    }

    Write-LogToFile @writeToLogFilesplat


    	if ($clearValue) {
      	    if ($this.ShouldUpdateDscResourceSetting($advancedSettingName, $advancedSettingCurrentValue, [string]::Empty)) {
                Set-AdvancedSetting -AdvancedSetting $advancedSetting -Value [string]::Empty -Confirm:$false
      	    }
    	}
    	else {
      	    if ($this.ShouldUpdateDscResourceSetting($advancedSettingName, $advancedSettingCurrentValue, $advancedSettingDesiredValue)) {
                Set-AdvancedSetting -AdvancedSetting $advancedSetting -Value $advancedSettingDesiredValue -Confirm:$false
      	    }
    	}
    }

    <#
    .DESCRIPTION

    Performs update on those Advanced Settings values that needs to be updated.
    #>
    [void] UpdateVMHostSettings($vmHost) {
    	Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

    $writeToLogFilesplat = @{
        Connection = $this.Connection.Name
        ResourceName = $this.GetType().ToString()
        LogType = 'Verbose'
        Message = "{0} Entering {1}"
        Arguments = @((Get-Date), (Get-PSCallStack)[0].FunctionName)
    }

    Write-LogToFile @writeToLogFilesplat


    	$vmHostCurrentAdvancedSettings = Get-AdvancedSetting -Server $this.Connection -Entity $vmHost

    	$currentMotd = $vmHostCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.MotdSettingName }
    	$currentIssue = $vmHostCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.IssueSettingName }

    	$this.SetAdvancedSetting('Motd', $currentMotd, $this.Motd, $currentMotd.Value, $this.MotdClear)
        $this.SetAdvancedSetting('Issue', $currentIssue, $this.Issue, $currentIssue.Value, $this.IssueClear)
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the advanced settings from the server.
    #>
    [void] PopulateResult($vmHost, $result) {
    	Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

    $writeToLogFilesplat = @{
        Connection = $this.Connection.Name
        ResourceName = $this.GetType().ToString()
        LogType = 'Verbose'
        Message = "{0} Entering {1}"
        Arguments = @((Get-Date), (Get-PSCallStack)[0].FunctionName)
    }

    Write-LogToFile @writeToLogFilesplat


    	$vmHostCurrentAdvancedSettings = Get-AdvancedSetting -Server $this.Connection -Entity $vmHost

    	$currentMotd = $vmHostCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.MotdSettingName }
    	$currentIssue = $vmHostCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.IssueSettingName }

        $result.Name = $vmHost.Name
    	$result.Motd = $currentMotd.Value
        $result.Issue = $currentIssue.Value
    }
}
