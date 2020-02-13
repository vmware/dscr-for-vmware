<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]
    $Name,

    [Parameter(Mandatory = $true)]
    [string]
    $Server,

    [Parameter(Mandatory = $true)]
    [string]
    $User,

    [Parameter(Mandatory = $true)]
    [string]
    $Password
)

# Mandatory Integration Tests parameter unused so set to null.
$Name = $null

$script:dscResourceName = 'vCenterStatistics'
$script:moduleFolderPath = (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase
$script:integrationTestsFolderPath = Join-Path (Join-Path $moduleFolderPath 'Tests') 'Integration'
$script:configurationFile = "$script:integrationTestsFolderPath\Configurations\$($script:dscResourceName)\$($script:dscResourceName)_Config.ps1"

$script:configWithPassedEnabledProperty = "$($script:dscResourceName)_WithPassedEnabledProperty_Config"
$script:configWithoutEnabledProperty = "$($script:dscResourceName)_WithoutEnabledProperty_Config"

$script:vCenter = Connect-VIServer -Server $Server -User $User -Password $Password
$script:performanceManager = $null
$script:currentPerformanceInterval = $null
$script:currentLevel = $null
$script:currentEnabled = $null
$script:currentSamplingPeriod = $null
$script:currentLength = $null

$script:period = "Day"
$script:level = 2
$script:intervalMinutes = 3
$script:periodLength = 3

$script:resourceWithPassedEnabledProperty = @{
    Server = $Server
    Period = $script:period
    Level = $script:level
    Enabled = $true
    IntervalMinutes = $script:intervalMinutes
    PeriodLength = $script:periodLength
}

$script:resourceWithoutEnabledProperty = @{
    Server = $Server
    Period = $script:period
    Level = $script:level
    IntervalMinutes = $script:intervalMinutes
    PeriodLength = $script:periodLength
}

. $script:configurationFile -Server $Server -User $User -Password $Password

$script:mofFileWithPassedEnabledPropertyPath = "$script:integrationTestsFolderPath\$($script:configWithPassedEnabledProperty)\"
$script:mofFileWithoutEnabledPropertyPath = "$script:integrationTestsFolderPath\$($script:configWithoutEnabledProperty)\"

function Invoke-TestSetup {
    $script:performanceManager = Get-View -Server $script:vCenter $script:vCenter.ExtensionData.Content.PerfManager
    $script:currentPerformanceInterval = $script:performanceManager.HistoricalInterval | Where-Object { $_.Name -Match $script:period }

    $script:currentLevel = $script:currentPerformanceInterval.Level
    $script:currentEnabled = $script:currentPerformanceInterval.Enabled
    $script:currentSamplingPeriod = $script:currentPerformanceInterval.SamplingPeriod
    $script:currentLength = $script:currentPerformanceInterval.Length
}

function Invoke-TestCleanup {
    $script:performanceManager = Get-View -Server $script:vCenter $script:vCenter.ExtensionData.Content.PerfManager

    $desiredPerformanceInterval = New-Object VMware.Vim.PerfInterval

    $desiredPerformanceInterval.Key = $script:currentPerformanceInterval.Key
    $desiredPerformanceInterval.Name = $script:currentPerformanceInterval.Name
    $desiredPerformanceInterval.Level = $script:currentLevel
    $desiredPerformanceInterval.Enabled = $script:currentEnabled
    $desiredPerformanceInterval.SamplingPeriod = $script:currentSamplingPeriod
    $desiredPerformanceInterval.Length = $script:currentLength

    $script:performanceManager.UpdatePerfInterval($desiredPerformanceInterval)
}

try {
    Describe "$($script:dscResourceName)_Integration" {
        Context "When using configuration $($script:configWithPassedEnabledProperty)" {
            BeforeAll {
                Invoke-TestSetup
            }

            AfterAll {
                Invoke-TestCleanup
            }

            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithPassedEnabledPropertyPath
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters
            }

            It 'Should compile and apply the MOF without throwing' {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithPassedEnabledPropertyPath
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Assert
                { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                # Arrange && Act && Assert
                { Get-DscConfiguration } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration and all parameters should match' {
                # Arrange && Act
                $configuration = Get-DscConfiguration

                # Assert
                $configuration.Server | Should -Be $script:resourceWithPassedEnabledProperty.Server
                $configuration.Period | Should -Be $script:resourceWithPassedEnabledProperty.Period
                $configuration.Level | Should -Be $script:resourceWithPassedEnabledProperty.Level
                $configuration.Enabled | Should -Be $script:resourceWithPassedEnabledProperty.Enabled
                $configuration.IntervalMinutes | Should -Be $script:resourceWithPassedEnabledProperty.IntervalMinutes
                $configuration.PeriodLength | Should -Be $script:resourceWithPassedEnabledProperty.PeriodLength
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }
        }

        Context "When using configuration $($script:configWithoutEnabledProperty)" {
            BeforeAll {
                Invoke-TestSetup
            }

            AfterAll {
                Invoke-TestCleanup
            }

            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithoutEnabledPropertyPath
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters
            }

            It 'Should compile and apply the MOF without throwing' {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithoutEnabledPropertyPath
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Assert
                { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                # Arrange && Act && Assert
                { Get-DscConfiguration } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration and all parameters should match' {
                # Arrange && Act
                $configuration = Get-DscConfiguration

                # Assert
                $configuration.Server | Should -Be $script:resourceWithoutEnabledProperty.Server
                $configuration.Period | Should -Be $script:resourceWithoutEnabledProperty.Period
                $configuration.Level | Should -Be $script:resourceWithoutEnabledProperty.Level
                $configuration.Enabled | Should -Be $script:currentEnabled
                $configuration.IntervalMinutes | Should -Be $script:resourceWithoutEnabledProperty.IntervalMinutes
                $configuration.PeriodLength | Should -Be $script:resourceWithoutEnabledProperty.PeriodLength
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }
        }
    }
}
finally {
    Disconnect-VIServer -Server $Server -Confirm:$false
}
