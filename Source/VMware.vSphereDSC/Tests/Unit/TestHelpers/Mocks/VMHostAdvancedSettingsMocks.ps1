<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-VMHostAdvancedSettingsProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostAdvancedSettingsProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        Name = $script:constants.VMHostName
    }

    $vmHostAdvancedSettingsProperties
}

function New-MocksForVMHostAdvancedSettingsWithOptionManager {
    [CmdletBinding()]

    $viServerMock = $script:viServer
    $vmHostMock = $script:vmHost
    $optionManagerMock = $script:optionManager

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $optionManagerMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:vmHost.ExtensionData.ConfigManager.AdvancedOption } -Verifiable
}

function New-MocksForVMHostAdvancedSettings {
    [CmdletBinding()]

    $viServerMock = $script:viServer
    $vmHostMock = $script:vmHost

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable
}

function New-MocksInSetWhenHashtableContainsAdvancedSettingsAndAllOfThemNeedToBeUpdated {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $advancedSettingsHashtable = @{
        $script:constants.BufferCacheFlushIntervalAdvancedSettingName = $script:constants.BufferCacheFlushIntervalAdvancedSettingValue + 1
        $script:constants.BufferCacheHardMaxDirtyAdvancedSettingName = $script:constants.BufferCacheHardMaxDirtyAdvancedSettingValue + 1
        $script:constants.CBRCEnableAdvancedSettingName = $true
        $script:constants.VpxVpxaConfigWorkingDirAdvancedSettingName = $script:constants.VpxVpxaConfigWorkingDirAdvancedSettingValue + '/vpxa'
    }

    $vmHostAdvancedSettingsProperties = New-VMHostAdvancedSettingsProperties
    $vmHostAdvancedSettingsProperties.AdvancedSettings = $advancedSettingsHashtable

    $vmHostAdvancedSettingsMock = $script:vmHostAdvancedSettings

    Mock -CommandName Get-AdvancedSetting -MockWith { return $vmHostAdvancedSettingsMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Entity -eq $script:vmHost } -Verifiable
    Mock -CommandName Update-VMHostAdvancedSettings -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostAdvancedSettingsProperties
}

function New-MocksInSetWhenHashtableContainsAdvancedSettingsAndNotAllOfThemNeedToBeUpdated {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $advancedSettingsHashtable = @{
        $script:constants.BufferCacheFlushIntervalAdvancedSettingName = $script:constants.BufferCacheFlushIntervalAdvancedSettingValue + 1
        $script:constants.BufferCacheHardMaxDirtyAdvancedSettingName = $script:constants.BufferCacheHardMaxDirtyAdvancedSettingValue
        $script:constants.CBRCEnableAdvancedSettingName = $script:constants.CBRCEnableAdvancedSettingValue
        $script:constants.VpxVpxaConfigWorkingDirAdvancedSettingName = $script:constants.VpxVpxaConfigWorkingDirAdvancedSettingValue + '/vpxa'
    }

    $vmHostAdvancedSettingsProperties = New-VMHostAdvancedSettingsProperties
    $vmHostAdvancedSettingsProperties.AdvancedSettings = $advancedSettingsHashtable

    $vmHostAdvancedSettingsMock = $script:vmHostAdvancedSettings

    Mock -CommandName Get-AdvancedSetting -MockWith { return $vmHostAdvancedSettingsMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Entity -eq $script:vmHost } -Verifiable
    Mock -CommandName Update-VMHostAdvancedSettings -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostAdvancedSettingsProperties
}

function New-MocksInSetWhenHashtableContainsAdvancedSettingsAndNoneOfThemNeedToBeUpdated {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $advancedSettingsHashtable = @{
        $script:constants.BufferCacheFlushIntervalAdvancedSettingName = $script:constants.BufferCacheFlushIntervalAdvancedSettingValue
        $script:constants.BufferCacheHardMaxDirtyAdvancedSettingName = $script:constants.BufferCacheHardMaxDirtyAdvancedSettingValue
        $script:constants.CBRCEnableAdvancedSettingName = $script:constants.CBRCEnableAdvancedSettingValue
        $script:constants.VpxVpxaConfigWorkingDirAdvancedSettingName = $script:constants.VpxVpxaConfigWorkingDirAdvancedSettingValue
    }

    $vmHostAdvancedSettingsProperties = New-VMHostAdvancedSettingsProperties
    $vmHostAdvancedSettingsProperties.AdvancedSettings = $advancedSettingsHashtable

    $vmHostAdvancedSettingsMock = $script:vmHostAdvancedSettings

    Mock -CommandName Get-AdvancedSetting -MockWith { return $vmHostAdvancedSettingsMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Entity -eq $script:vmHost } -Verifiable
    Mock -CommandName Update-VMHostAdvancedSettings -MockWith { return $null }.GetNewClosure()

    $vmHostAdvancedSettingsProperties
}

function New-MocksWhenHashtableContainsAtLeastOneAdvancedSettingThatNeedsToBeUpdated {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $advancedSettingsHashtable = @{
        $script:constants.BufferCacheFlushIntervalAdvancedSettingName = $script:constants.BufferCacheFlushIntervalAdvancedSettingValue
        $script:constants.BufferCacheHardMaxDirtyAdvancedSettingName = $script:constants.BufferCacheHardMaxDirtyAdvancedSettingValue
        $script:constants.CBRCEnableAdvancedSettingName = $true
        $script:constants.VpxVpxaConfigWorkingDirAdvancedSettingName = $script:constants.VpxVpxaConfigWorkingDirAdvancedSettingValue
    }

    $vmHostAdvancedSettingsProperties = New-VMHostAdvancedSettingsProperties
    $vmHostAdvancedSettingsProperties.AdvancedSettings = $advancedSettingsHashtable

    $vmHostAdvancedSettingsMock = $script:vmHostAdvancedSettings

    Mock -CommandName Get-AdvancedSetting -MockWith { return $vmHostAdvancedSettingsMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Entity -eq $script:vmHost } -Verifiable

    $vmHostAdvancedSettingsProperties
}

function New-MocksWhenHashtableDoesNotContainAdvancedSettingsThatNeedToBeUpdated {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $advancedSettingsHashtable = @{
        $script:constants.BufferCacheFlushIntervalAdvancedSettingName = $script:constants.BufferCacheFlushIntervalAdvancedSettingValue
        $script:constants.BufferCacheHardMaxDirtyAdvancedSettingName = $script:constants.BufferCacheHardMaxDirtyAdvancedSettingValue
        $script:constants.CBRCEnableAdvancedSettingName = $false
        $script:constants.VpxVpxaConfigWorkingDirAdvancedSettingName = $script:constants.VpxVpxaConfigWorkingDirAdvancedSettingValue
    }

    $vmHostAdvancedSettingsProperties = New-VMHostAdvancedSettingsProperties
    $vmHostAdvancedSettingsProperties.AdvancedSettings = $advancedSettingsHashtable

    $vmHostAdvancedSettingsMock = $script:vmHostAdvancedSettings

    Mock -CommandName Get-AdvancedSetting -MockWith { return $vmHostAdvancedSettingsMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Entity -eq $script:vmHost } -Verifiable

    $vmHostAdvancedSettingsProperties
}

function New-MocksInGet {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $advancedSettingsHashtable = @{
        $script:constants.BufferCacheFlushIntervalAdvancedSettingName = $script:constants.BufferCacheFlushIntervalAdvancedSettingValue
        $script:constants.BufferCacheHardMaxDirtyAdvancedSettingName = $script:constants.BufferCacheHardMaxDirtyAdvancedSettingValue
        $script:constants.CBRCEnableAdvancedSettingName = $false
        $script:constants.VpxVpxaConfigWorkingDirAdvancedSettingName = $script:constants.VpxVpxaConfigWorkingDirAdvancedSettingValue
    }

    $vmHostAdvancedSettingsProperties = New-VMHostAdvancedSettingsProperties
    $vmHostAdvancedSettingsProperties.AdvancedSettings = $advancedSettingsHashtable

    $vmHostAdvancedSettingsMock = $script:vmHostAdvancedSettings

    Mock -CommandName Get-AdvancedSetting -MockWith { return $vmHostAdvancedSettingsMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Entity -eq $script:vmHost } -Verifiable

    $vmHostAdvancedSettingsProperties
}
