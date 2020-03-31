<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

Using module '..\..\VMware.vSphereDSC.psm1'

$script:modulePath = $env:PSModulePath
$script:unitTestsFolder = Join-Path (Join-Path (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase 'Tests') 'Unit'
$script:mockModuleLocation = "$script:unitTestsFolder\TestHelpers"

$script:moduleName = 'VMware.vSphereDSC'
$script:resourceName = 'vCenterSettings'

$user = 'user'
$password = 'password' | ConvertTo-SecureString -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($user, $password)

$script:resourceProperties = @{
    Server = '10.23.82.112'
    Credential = $credential
}

function Invoke-TestSetup {
    $env:PSModulePath = $script:mockModuleLocation
    $vimAutomationModule = Get-Module -Name VMware.VimAutomation.Core
    if ($null -ne $vimAutomationModule -and $vimAutomationModule.Path -NotMatch 'TestHelpers') {
        throw 'The Original VMware.VimAutomation.Core Module is loaded in the current session. If you want to run the unit tests please open a new PowerShell session.'
    }

    Import-Module -Name VMware.VimAutomation.Core
}

function Invoke-TestCleanup {
    Remove-Module -Name VMware.VimAutomation.Core
    $env:PSModulePath = $script:modulePath
}

try {
    # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
    Invoke-TestSetup

    Describe 'vCenterSettings\Set' -Tag 'Set' {
        AfterEach {
            $script:resourceProperties.LoggingLevel = 'Unset'
            $script:resourceProperties.EventMaxAgeEnabled = $false
            $script:resourceProperties.EventMaxAge = 40
            $script:resourceProperties.TaskMaxAgeEnabled = $false
            $script:resourceProperties.TaskMaxAge = 40
            $script:resourceProperties.Motd = [string]::Empty
            $script:resourceProperties.Issue = [string]::Empty
        }

        Context 'Invoking with default resource properties' {
            BeforeAll {
                # Arrange
                $vCenter = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }

                $vCenterMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }

                Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-AdvancedSetting -MockWith { return $null } -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call the Connect-VIServer mock with the passed server and credentials once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Connect-VIServer `
                                  -ParameterFilter { $Server -eq $script:resourceProperties.Server -and $Credential -eq $script:resourceProperties.Credential } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call Get-AdvancedSetting mock with the passed server and vCenter once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Get-AdvancedSetting `
                                  -ParameterFilter { $Server -eq $vCenter -and $Entity -eq $vCenter } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }
        }

        Context 'Invoking with Advanced Settings To Update' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.LoggingLevel = 'Warning'
                $script:resourceProperties.EventMaxAgeEnabled = $true
                $script:resourceProperties.EventMaxAge = 41
                $script:resourceProperties.TaskMaxAgeEnabled = $true
                $script:resourceProperties.TaskMaxAge = 41
                $script:resourceProperties.Motd = 'Hello World from motd!'
                $script:resourceProperties.Issue = 'Hello World from isue!'

                $advancedSettings = @(
                    [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'log.level'; Value = 'Info' }
                    [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'event.maxAgeEnabled'; Value = $false }
                    [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'event.maxAge'; Value = 40 }
                    [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'task.maxAgeEnabled'; Value = $false }
                    [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'task.maxAge'; Value = 40 }
                    [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'etc.motd'; Value = [string]::Empty }
                    [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'etc.issue'; Value = [string]::Empty }
                )

                $vCenterMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $advancedSettingsMock = {
                    return @(
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'log.level'; Value = 'Info' }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'event.maxAgeEnabled'; Value = $false }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'event.maxAge'; Value = 40 }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'task.maxAgeEnabled'; Value = $false }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'task.maxAge'; Value = 40 }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'etc.motd'; Value = [string]::Empty }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'etc.issue'; Value = [string]::Empty }
                    )
                }

                Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-AdvancedSetting -MockWith $advancedSettingsMock -ModuleName $script:moduleName
                Mock -CommandName Set-AdvancedSetting -MockWith { return $null } -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call Set-AdvancedSetting for each setting that needs to be updated' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Set-AdvancedSetting `
                                  -ParameterFilter { $AdvancedSetting -eq $advancedSettings[0] -and $Value -eq $script:resourceProperties.LoggingLevel -and !$Confirm } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
                Assert-MockCalled -CommandName Set-AdvancedSetting `
                                  -ParameterFilter { $AdvancedSetting -eq $advancedSettings[1] -and $Value -eq $script:resourceProperties.EventMaxAgeEnabled -and !$Confirm } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
                Assert-MockCalled -CommandName Set-AdvancedSetting `
                                  -ParameterFilter { $AdvancedSetting -eq $advancedSettings[2] -and $Value -eq $script:resourceProperties.EventMaxAge -and !$Confirm } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
                Assert-MockCalled -CommandName Set-AdvancedSetting `
                                  -ParameterFilter { $AdvancedSetting -eq $advancedSettings[3] -and $Value -eq $script:resourceProperties.TaskMaxAgeEnabled -and !$Confirm } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
                Assert-MockCalled -CommandName Set-AdvancedSetting `
                                  -ParameterFilter { $AdvancedSetting -eq $advancedSettings[4] -and $Value -eq $script:resourceProperties.TaskMaxAge -and !$Confirm } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
                Assert-MockCalled -CommandName Set-AdvancedSetting `
                                  -ParameterFilter { $AdvancedSetting -eq $advancedSettings[5] -and $Value -eq $script:resourceProperties.Motd -and !$Confirm } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
                Assert-MockCalled -CommandName Set-AdvancedSetting `
                                  -ParameterFilter { $AdvancedSetting -eq $advancedSettings[6] -and $Value -eq $script:resourceProperties.Issue -and !$Confirm } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }
        }

        Context 'Invoking without Advanced Settings To Update' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.LoggingLevel = 'Warning'
                $script:resourceProperties.EventMaxAgeEnabled = $true
                $script:resourceProperties.EventMaxAge = 41
                $script:resourceProperties.TaskMaxAgeEnabled = $true
                $script:resourceProperties.TaskMaxAge = 41
                $script:resourceProperties.Motd = 'Hello World from motd!'
                $script:resourceProperties.Issue = 'Hello World from issue!'

                $advancedSettings = @(
                    [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'log.level'; Value = 'Warning' }
                    [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'event.maxAgeEnabled'; Value = $true }
                    [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'event.maxAge'; Value = 41 }
                    [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'task.maxAgeEnabled'; Value = $true }
                    [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'task.maxAge'; Value = 41 }
                    [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'etc.motd'; Value = 'Hello World from motd!' }
                    [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'etc.issue'; Value = 'Hello World from issue!' }
                )

                $vCenterMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $advancedSettingsMock = {
                    return @(
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'log.level'; Value = 'Warning' }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'event.maxAgeEnabled'; Value = $true }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'event.maxAge'; Value = 41 }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'task.maxAgeEnabled'; Value = $true }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'task.maxAge'; Value = 41 }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'etc.motd'; Value = 'Hello World from motd!' }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'etc.issue'; Value = 'Hello World from issue!' }
                    )
                }

                Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-AdvancedSetting -MockWith $advancedSettingsMock -ModuleName $script:moduleName
                Mock -CommandName Set-AdvancedSetting -MockWith { return $null } -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should not call Set-AdvancedSetting for each setting that does not need to be updated' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Set-AdvancedSetting `
                                  -ParameterFilter { $AdvancedSetting -eq $advancedSettings[0] -and $Value -eq $script:resourceProperties.LoggingLevel -and !$Confirm } `
                                  -ModuleName $script:moduleName -Exactly 0 -Scope It
                Assert-MockCalled -CommandName Set-AdvancedSetting `
                                  -ParameterFilter { $AdvancedSetting -eq $advancedSettings[1] -and $Value -eq $script:resourceProperties.EventMaxAgeEnabled -and !$Confirm } `
                                  -ModuleName $script:moduleName -Exactly 0 -Scope It
                Assert-MockCalled -CommandName Set-AdvancedSetting `
                                  -ParameterFilter { $AdvancedSetting -eq $advancedSettings[2] -and $Value -eq $script:resourceProperties.EventMaxAge -and !$Confirm } `
                                  -ModuleName $script:moduleName -Exactly 0 -Scope It
                Assert-MockCalled -CommandName Set-AdvancedSetting `
                                  -ParameterFilter { $AdvancedSetting -eq $advancedSettings[3] -and $Value -eq $script:resourceProperties.TaskMaxAgeEnabled -and !$Confirm } `
                                  -ModuleName $script:moduleName -Exactly 0 -Scope It
                Assert-MockCalled -CommandName Set-AdvancedSetting `
                                  -ParameterFilter { $AdvancedSetting -eq $advancedSettings[4] -and $Value -eq $script:resourceProperties.TaskMaxAge -and !$Confirm } `
                                  -ModuleName $script:moduleName -Exactly 0 -Scope It
                Assert-MockCalled -CommandName Set-AdvancedSetting `
                                  -ParameterFilter { $AdvancedSetting -eq $advancedSettings[5] -and $Value -eq $script:resourceProperties.Motd -and !$Confirm } `
                                  -ModuleName $script:moduleName -Exactly 0 -Scope It
                Assert-MockCalled -CommandName Set-AdvancedSetting `
                                  -ParameterFilter { $AdvancedSetting -eq $advancedSettings[6] -and $Value -eq $script:resourceProperties.Issue -and !$Confirm } `
                                  -ModuleName $script:moduleName -Exactly 0 -Scope It
            }
        }
    }

    Describe 'vCenterSettings\Test' -Tag 'Test' {
        AfterEach {
            $script:resourceProperties.LoggingLevel = 'Unset'
            $script:resourceProperties.EventMaxAgeEnabled = $false
            $script:resourceProperties.EventMaxAge = 40
            $script:resourceProperties.TaskMaxAgeEnabled = $false
            $script:resourceProperties.TaskMaxAge = 40
            $script:resourceProperties.Motd = [string]::Empty
            $script:resourceProperties.Issue = [string]::Empty
        }

        Context 'Invoking with default resource properties' {
            BeforeAll {
                # Arrange
                $vCenter = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }

                $vCenterMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }

                Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-AdvancedSetting -MockWith { return $null } -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call the Connect-VIServer mock with the passed server and credentials once' {
                # Act
                $resource.Test()

                # Assert
                Assert-MockCalled -CommandName Connect-VIServer `
                                  -ParameterFilter { $Server -eq $script:resourceProperties.Server -and $Credential -eq $script:resourceProperties.Credential } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call Get-AdvancedSetting mock with the passed server and vCenter once' {
                # Act
                $resource.Test()

                # Assert
                Assert-MockCalled -CommandName Get-AdvancedSetting `
                                  -ParameterFilter { $Server -eq $vCenter -and $Entity -eq $vCenter } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }
        }

        Context 'Invoking with Advanced Settings To Update' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.LoggingLevel = 'Warning'
                $script:resourceProperties.EventMaxAgeEnabled = $true
                $script:resourceProperties.EventMaxAge = 41
                $script:resourceProperties.TaskMaxAgeEnabled = $true
                $script:resourceProperties.TaskMaxAge = 41
                $script:resourceProperties.Motd = 'Hello World from motd!'
                $script:resourceProperties.Issue = 'Hello World from issue!'

                $vCenterMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $advancedSettingsMock = {
                    return @(
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'log.level'; Value = 'Info' }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'event.maxAgeEnabled'; Value = $false }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'event.maxAge'; Value = 40 }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'task.maxAgeEnabled'; Value = $false }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'task.maxAge'; Value = 40 }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'etc.motd'; Value = [string]::Empty }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'etc.issue'; Value = [string]::Empty }
                    )
                }

                Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-AdvancedSetting -MockWith $advancedSettingsMock -ModuleName $script:moduleName
                Mock -CommandName Set-AdvancedSetting -MockWith { return $null } -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should return $false (Advanced Settings need to be updated.)' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $false
            }
        }

        Context 'Invoking without Advanced Settings To Update' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.LoggingLevel = 'Warning'
                $script:resourceProperties.EventMaxAgeEnabled = $true
                $script:resourceProperties.EventMaxAge = 41
                $script:resourceProperties.TaskMaxAgeEnabled = $true
                $script:resourceProperties.TaskMaxAge = 41
                $script:resourceProperties.Motd = 'Hello World from motd!'
                $script:resourceProperties.Issue = 'Hello World from issue!'

                $vCenterMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $advancedSettingsMock = {
                    return @(
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'log.level'; Value = 'Warning' }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'event.maxAgeEnabled'; Value = $true }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'event.maxAge'; Value = 41 }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'task.maxAgeEnabled'; Value = $true }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'task.maxAge'; Value = 41 }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'etc.motd'; Value = 'Hello World from motd!' }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'etc.issue'; Value = 'Hello World from issue!' }
                    )
                }

                Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-AdvancedSetting -MockWith $advancedSettingsMock -ModuleName $script:moduleName
                Mock -CommandName Set-AdvancedSetting -MockWith { return $null } -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should return $true (Advanced Settings do not need to be updated.)' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $true
            }
        }
    }

    Describe 'vCenterSettings\Get' -Tag 'Get' {
        AfterEach {
            $script:resourceProperties.LoggingLevel = 'Unset'
            $script:resourceProperties.EventMaxAgeEnabled = $false
            $script:resourceProperties.EventMaxAge = 40
            $script:resourceProperties.TaskMaxAgeEnabled = $false
            $script:resourceProperties.TaskMaxAge = 40
            $script:resourceProperties.Motd = [string]::Empty
            $script:resourceProperties.Issue = [string]::Empty
        }

        Context 'Invoking with default resource properties' {
            BeforeEach {
                # Arrange
                $script:resourceProperties.LoggingLevel = 'Warning'
                $script:resourceProperties.EventMaxAgeEnabled = $true
                $script:resourceProperties.EventMaxAge = 41
                $script:resourceProperties.TaskMaxAgeEnabled = $true
                $script:resourceProperties.TaskMaxAge = 41
                $script:resourceProperties.Motd = 'Hello World from motd!'
                $script:resourceProperties.Issue = 'Hello World from issue!'

                $vCenter = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                $advancedSettings = @(
                    [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'log.level'; Value = 'Warning' }
                    [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'event.maxAgeEnabled'; Value = $true }
                    [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'event.maxAge'; Value = 41 }
                    [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'task.maxAgeEnabled'; Value = $true }
                    [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'task.maxAge'; Value = 41 }
                    [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'etc.motd'; Value = 'Hello World from motd!' }
                    [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'etc.issue'; Value = 'Hello World from issue!' }
                )

                $vCenterMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $advancedSettingsMock = {
                    return @(
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'log.level'; Value = 'Warning' }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'event.maxAgeEnabled'; Value = $true }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'event.maxAge'; Value = 41 }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'task.maxAgeEnabled'; Value = $true }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'task.maxAge'; Value = 41 }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'etc.motd'; Value = 'Hello World from motd!' }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'etc.issue'; Value = 'Hello World from issue!' }
                    )
                }

                Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-AdvancedSetting -MockWith $advancedSettingsMock -ModuleName $script:moduleName
                Mock -CommandName Set-AdvancedSetting -MockWith { return $null } -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call the Connect-VIServer mock with the passed server and credentials once' {
                # Act
                $resource.Get()

                # Assert
                Assert-MockCalled -CommandName Connect-VIServer `
                                  -ParameterFilter { $Server -eq $script:resourceProperties.Server -and $Credential -eq $script:resourceProperties.Credential } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call Get-AdvancedSetting mock with the passed server and vmhost once' {
                # Act
                $resource.Get()

                # Assert
                Assert-MockCalled -CommandName Get-AdvancedSetting `
                                  -ParameterFilter { $Server -eq $vCenter -and $Entity -eq $vCenter } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should return the resource with the properties passed from the server' {
                # Act
                $result = $resource.Get()

                # Assert
                $result.Server | Should -Be $script:resourceProperties.Server
                $result.LoggingLevel | Should -Be $script:resourceProperties.LoggingLevel
                $result.EventMaxAgeEnabled | Should -Be $script:resourceProperties.EventMaxAgeEnabled
                $result.EventMaxAge | Should -Be $script:resourceProperties.EventMaxAge
                $result.TaskMaxAgeEnabled | Should -Be $script:resourceProperties.TaskMaxAgeEnabled
                $result.TaskMaxAge | Should -Be $script:resourceProperties.TaskMaxAge
                $result.Motd | Should -Be $script:resourceProperties.Motd
                $result.Issue | Should -Be $script:resourceProperties.Issue
            }
        }
    }
}
finally {
    # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
    Invoke-TestCleanup
}
