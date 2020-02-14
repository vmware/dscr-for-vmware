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

$script:dscResourceName = 'vCenterSettings'
$script:moduleFolderPath = (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase
$script:integrationTestsFolderPath = Join-Path (Join-Path $moduleFolderPath 'Tests') 'Integration'
$script:configurationFile = "$script:integrationTestsFolderPath\Configurations\$($script:dscResourceName)\$($script:dscResourceName)_Config.ps1"

$script:configWithLoggingLevel = "$($script:dscResourceName)_WithLoggingLevel_Config"
$script:configWithEventMaxAge = "$($script:dscResourceName)_WithEventMaxAge_Config"
$script:configWithTaskMaxAge = "$($script:dscResourceName)_WithTaskMaxAge_Config"
$script:configWithMotdAndIssue = "$($script:dscResourceName)_WithMotdAndIssue_Config"

$script:vCenter = Connect-VIServer -Server $Server -User $User -Password $Password
$script:vCenterCurrentAdvancedSettings = $null
$script:currentLoggingLevel = $null
$script:currentEventMaxAgeEnabled = $null
$script:currentEventMaxAge = $null
$script:currentTaskMaxAgeEnabled = $null
$script:currentTaskMaxAge = $null
$script:currentMotd = $null
$script:currentIssue = $null

$script:loggingLevel = 'Warning'
$script:eventMaxAgeEnabled = $false
$script:eventMaxAge = 40
$script:taskMaxAgeEnabled = $false
$script:taskMaxAge = 40
$script:motd = 'vCenterSettings motd test'
$script:issue = 'vCenterSettings issue test'

$script:resourceWithLoggingLevel = @{
    Server = $Server
    LoggingLevel = $script:loggingLevel
}

$script:resourceWithEventMaxAge = @{
    Server = $Server
    EventMaxAgeEnabled = $script:eventMaxAgeEnabled
    EventMaxAge = $script:eventMaxAge
}

$script:resourceWithTaskMaxAge = @{
    Server = $Server
    TaskMaxAgeEnabled = $script:taskMaxAgeEnabled
    TaskMaxAge = $script:taskMaxAge
}

$script:resourceWithMotdAndIssue = @{
    Server = $Server
    Motd = $script:motd
    Issue = $script:issue
}

. $script:configurationFile -Server $Server -User $User -Password $Password

$script:mofFileWithLoggingLevelPath = "$script:integrationTestsFolderPath\$($script:configWithLoggingLevel)\"
$script:mofFileWithEventMaxAgePath = "$script:integrationTestsFolderPath\$($script:configWithEventMaxAge)\"
$script:mofFileWithTaskMaxAgePath = "$script:integrationTestsFolderPath\$($script:configWithTaskMaxAge)"
$script:mofFileWithMotdAndIssuePath = "$script:integrationTestsFolderPath\$($script:configWithMotdAndIssue)\"

function Invoke-TestSetup {
    $script:vCenterCurrentAdvancedSettings = Get-AdvancedSetting -Server $script:vCenter -Entity $script:vCenter

    $script:currentLoggingLevel = $script:vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq "log.level" }
    $script:currentEventMaxAgeEnabled = $script:vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq "event.maxAgeEnabled" }
    $script:currentEventMaxAge = $script:vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq "event.maxAge" }
    $script:currentTaskMaxAgeEnabled = $script:vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq "task.maxAgeEnabled" }
    $script:currentTaskMaxAge = $script:vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq "task.maxAge" }
    $script:currentMotd = $script:vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq "etc.motd"}
    $script:currentIssue = $script:vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq "etc.issue"}
}

function Invoke-TestCleanup {
    Set-AdvancedSetting -AdvancedSetting $script:currentLoggingLevel -Value $script:currentLoggingLevel.Value -Confirm:$false
    Set-AdvancedSetting -AdvancedSetting $script:currentEventMaxAgeEnabled -Value $script:currentEventMaxAgeEnabled.Value -Confirm:$false
    Set-AdvancedSetting -AdvancedSetting $script:currentEventMaxAge -Value $script:currentEventMaxAge.Value -Confirm:$false
    Set-AdvancedSetting -AdvancedSetting $script:currentTaskMaxAgeEnabled -Value $script:currentTaskMaxAgeEnabled.Value -Confirm:$false
    Set-AdvancedSetting -AdvancedSetting $script:currentTaskMaxAge -Value $script:currentTaskMaxAge.Value -Confirm:$false
    Set-AdvancedSetting -AdvancedSetting $script:currentMotd -Value $script:currentMotd.Value -Confirm:$false
    Set-AdvancedSetting -AdvancedSetting $script:currentIssue -Value $script:currentIssue.Value -Confirm:$false
}

try {
    Describe "$($script:dscResourceName)_Integration" {
        Context "When using configuration $($script:configWithLoggingLevel)" {
            BeforeAll {
                Invoke-TestSetup
            }

            AfterAll {
                Invoke-TestCleanup
            }

            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithLoggingLevelPath
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
                    Path = $script:mofFileWithLoggingLevelPath
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
                $configuration.Server | Should -Be $script:resourceWithLoggingLevel.Server
                $configuration.LoggingLevel | Should -Be $script:resourceWithLoggingLevel.LoggingLevel
                $configuration.EventMaxAgeEnabled | Should -Be ($script:currentEventMaxAgeEnabled).Value
                $configuration.EventMaxAge | Should -Be ($script:currentEventMaxAge).Value
                $configuration.TaskMaxAgeEnabled | Should -Be ($script:currentTaskMaxAgeEnabled).Value
                $configuration.TaskMaxAge | Should -Be ($script:currentTaskMaxAge).Value
                $configuration.Motd | Should -Be ($script:currentMotd).Value
                $configuration.Issue | Should -Be ($script:currentIssue).Value
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }
        }

        Context "When using configuration $($script:configWithEventMaxAge)" {
            BeforeAll {
                Invoke-TestSetup
            }

            AfterAll {
                Invoke-TestCleanup
            }

            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithEventMaxAgePath
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
                    Path = $script:mofFileWithEventMaxAgePath
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
                $configuration.Server | Should -Be $script:resourceWithEventMaxAge.Server
                $configuration.LoggingLevel | Should -Be ($script:currentLoggingLevel).Value
                $configuration.EventMaxAgeEnabled | Should -Be $script:resourceWithEventMaxAge.EventMaxAgeEnabled
                $configuration.EventMaxAge | Should -Be $script:resourceWithEventMaxAge.EventMaxAge
                $configuration.TaskMaxAgeEnabled | Should -Be ($script:currentTaskMaxAgeEnabled).Value
                $configuration.TaskMaxAge | Should -Be ($script:currentTaskMaxAge).Value
                $configuration.Motd | Should -Be ($script:currentMotd).Value
                $configuration.Issue | Should -Be ($script:currentIssue).Value

            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }
        }

        Context "When using configuration $($script:configWithTaskMaxAge)" {
            BeforeAll {
                Invoke-TestSetup
            }

            AfterAll {
                Invoke-TestCleanup
            }

            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithTaskMaxAgePath
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
                    Path = $script:mofFileWithTaskMaxAgePath
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
                $configuration.Server | Should -Be $script:resourceWithTaskMaxAge.Server
                $configuration.LoggingLevel | Should -Be ($script:currentLoggingLevel).Value
                $configuration.EventMaxAgeEnabled | Should -Be ($script:currentEventMaxAgeEnabled).Value
                $configuration.EventMaxAge | Should -Be ($script:currentEventMaxAge).Value
                $configuration.TaskMaxAgeEnabled | Should -Be $script:resourceWithTaskMaxAge.TaskMaxAgeEnabled
                $configuration.TaskMaxAge | Should -Be $script:resourceWithTaskMaxAge.TaskMaxAge
                $configuration.Motd | Should -Be ($script:currentMotd).Value
                $configuration.Issue | Should -Be ($script:currentIssue).Value
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }
        }
        Context "When using configuration $($script:configWithMotdAndIssue)" {
            BeforeAll {
                Invoke-TestSetup
            }

            AfterAll {
                Invoke-TestCleanup
            }

            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithMotdAndIssuePath
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
                    Path = $script:mofFileWithMotdAndIssuePath
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
                $configuration.Server | Should -Be $script:resourceWithTaskMaxAge.Server
                $configuration.LoggingLevel | Should -Be ($script:currentLoggingLevel).Value
                $configuration.EventMaxAgeEnabled | Should -Be ($script:currentEventMaxAgeEnabled).Value
                $configuration.EventMaxAge | Should -Be ($script:currentEventMaxAge).Value
                $configuration.TaskMaxAgeEnabled | Should -Be ($script:currentTaskMaxAgeEnabled).Value
                $configuration.TaskMaxAge | Should -Be ($script:currentTaskMaxAge).Value
                $configuration.Motd | Should -Be $script:resourceWithMotdAndIssue.Motd
                $configuration.Issue | Should -Be $script:resourceWithMotdAndIssue.Issue
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
