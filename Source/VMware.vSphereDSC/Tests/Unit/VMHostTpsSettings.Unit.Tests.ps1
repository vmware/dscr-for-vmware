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
$script:resourceName = 'VMHostTpsSettings'

$user = 'user'
$password = 'password' | ConvertTo-SecureString -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($user, $password)

$script:resourceProperties = @{
    Name = '10.23.82.112'
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

    Describe 'VMHostTpsSettings\Set' -Tag 'Set' {
        AfterEach {
            $script:resourceProperties.ShareScanTime = $null
            $script:resourceProperties.ShareScanGHz = $null
            $script:resourceProperties.ShareRateMax = $null
            $script:resourceProperties.ShareForceSalting = $null
        }

        Context 'Invoking with default resource properties' {
            BeforeAll {
                # Arrange
                $viServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                $vmhost = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId' }

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId' }
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
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

            It 'Should call Get-VMHost mock with the passed server and name once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Get-VMHost `
                                  -ParameterFilter { $Server -eq $viServer -and $Name -eq $script:resourceProperties.Name } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call Get-AdvancedSetting mock with the passed server and vmhost once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Get-AdvancedSetting `
                                  -ParameterFilter { $Server -eq $viServer -and $Entity -eq $vmhost -and $Name -eq 'Mem.Sh*' } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }
        }

        Context 'Invoking with Advanced Settings To Update' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.ShareScanTime = 21
                $script:resourceProperties.ShareScanGHz = 31
                $script:resourceProperties.ShareRateMax = 41
                $script:resourceProperties.ShareForceSalting = 51

                $advancedSettings = @(
                    [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'Mem.ShareScanTime'; Value = 20 }
                    [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'Mem.ShareScanGHz'; Value = 30 }
                    [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'Mem.ShareRateMax'; Value = 40 }
                    [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'Mem.ShareForceSalting'; Value = 50 }
                )

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId' }
                }
                $advancedSettingsMock = {
                    return @(
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'Mem.ShareScanTime'; Value = 20 }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'Mem.ShareScanGHz'; Value = 30 }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'Mem.ShareRateMax'; Value = 40 }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'Mem.ShareForceSalting'; Value = 50 }
                    )
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
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
                                  -ParameterFilter { $AdvancedSetting -eq $advancedSettings[0] -and $Value -eq $script:resourceProperties.ShareScanTime -and !$Confirm } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
                Assert-MockCalled -CommandName Set-AdvancedSetting `
                                  -ParameterFilter { $AdvancedSetting -eq $advancedSettings[1] -and $Value -eq $script:resourceProperties.ShareScanGHz -and !$Confirm } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
                Assert-MockCalled -CommandName Set-AdvancedSetting `
                                  -ParameterFilter { $AdvancedSetting -eq $advancedSettings[2] -and $Value -eq $script:resourceProperties.ShareRateMax -and !$Confirm } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
                Assert-MockCalled -CommandName Set-AdvancedSetting `
                                  -ParameterFilter { $AdvancedSetting -eq $advancedSettings[3] -and $Value -eq $script:resourceProperties.ShareForceSalting -and !$Confirm } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }
        }

        Context 'Invoking without Advanced Settings To Update' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.ShareScanTime = 20
                $script:resourceProperties.ShareScanGHz = 30
                $script:resourceProperties.ShareRateMax = 40
                $script:resourceProperties.ShareForceSalting = 50

                $advancedSettings = @(
                    [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'Mem.ShareScanTime'; Value = 20 }
                    [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'Mem.ShareScanGHz'; Value = 30 }
                    [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'Mem.ShareRateMax'; Value = 40 }
                    [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'Mem.ShareForceSalting'; Value = 50 }
                )

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId' }
                }
                $advancedSettingsMock = {
                    return @(
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'Mem.ShareScanTime'; Value = 20 }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'Mem.ShareScanGHz'; Value = 30 }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'Mem.ShareRateMax'; Value = 40 }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'Mem.ShareForceSalting'; Value = 50 }
                    )
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
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
                                  -ParameterFilter { $AdvancedSetting -eq $advancedSettings[0] -and $Value -eq $script:resourceProperties.ShareScanTime -and !$Confirm } `
                                  -ModuleName $script:moduleName -Exactly 0 -Scope It
                Assert-MockCalled -CommandName Set-AdvancedSetting `
                                  -ParameterFilter { $AdvancedSetting -eq $advancedSettings[1] -and $Value -eq $script:resourceProperties.ShareScanGHz -and !$Confirm } `
                                  -ModuleName $script:moduleName -Exactly 0 -Scope It
                Assert-MockCalled -CommandName Set-AdvancedSetting `
                                  -ParameterFilter { $AdvancedSetting -eq $advancedSettings[2] -and $Value -eq $script:resourceProperties.ShareRateMax -and !$Confirm } `
                                  -ModuleName $script:moduleName -Exactly 0 -Scope It
                Assert-MockCalled -CommandName Set-AdvancedSetting `
                                  -ParameterFilter { $AdvancedSetting -eq $advancedSettings[3] -and $Value -eq $script:resourceProperties.ShareForceSalting -and !$Confirm } `
                                  -ModuleName $script:moduleName -Exactly 0 -Scope It
            }
        }
    }

    Describe 'VMHostTpsSettings\Test' -Tag 'Test' {
        AfterEach {
            $script:resourceProperties.ShareScanTime = $null
            $script:resourceProperties.ShareScanGHz = $null
            $script:resourceProperties.ShareRateMax = $null
            $script:resourceProperties.ShareForceSalting = $null
        }

        Context 'Invoking with default resource properties' {
            BeforeAll {
                # Arrange
                $viServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                $vmhost = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId' }

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId' }
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
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

            It 'Should call Get-VMHost mock with the passed server and name once' {
                # Act
                $resource.Test()

                # Assert
                Assert-MockCalled -CommandName Get-VMHost `
                                  -ParameterFilter { $Server -eq $viServer -and $Name -eq $script:resourceProperties.Name } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call Get-AdvancedSetting mock with the passed server and vmhost once' {
                # Act
                $resource.Test()

                # Assert
                Assert-MockCalled -CommandName Get-AdvancedSetting `
                                  -ParameterFilter { $Server -eq $viServer -and $Entity -eq $vmhost -and $Name -eq 'Mem.Sh*' } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }
        }

        Context 'Invoking with Advanced Settings To Update' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.ShareScanTime = 21
                $script:resourceProperties.ShareScanGHz = 31
                $script:resourceProperties.ShareRateMax = 41
                $script:resourceProperties.ShareForceSalting = 51

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId' }
                }
                $advancedSettingsMock = {
                    return @(
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'Mem.ShareScanTime'; Value = 20 }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'Mem.ShareScanGHz'; Value = 30 }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'Mem.ShareRateMax'; Value = 40 }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'Mem.ShareForceSalting'; Value = 50 }
                    )
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName Get-AdvancedSetting -MockWith $advancedSettingsMock -ModuleName $script:moduleName
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
                $script:resourceProperties.ShareScanTime = 20
                $script:resourceProperties.ShareScanGHz = 30
                $script:resourceProperties.ShareRateMax = 40
                $script:resourceProperties.ShareForceSalting = 50

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId' }
                }
                $advancedSettingsMock = {
                    return @(
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'Mem.ShareScanTime'; Value = 20 }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'Mem.ShareScanGHz'; Value = 30 }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'Mem.ShareRateMax'; Value = 40 }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'Mem.ShareForceSalting'; Value = 50 }
                    )
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName Get-AdvancedSetting -MockWith $advancedSettingsMock -ModuleName $script:moduleName
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

    Describe 'VMHostTpsSettings\Get' -Tag 'Get' {
        AfterEach {
            $script:resourceProperties.ShareScanTime = $null
            $script:resourceProperties.ShareScanGHz = $null
            $script:resourceProperties.ShareRateMax = $null
            $script:resourceProperties.ShareForceSalting = $null
        }

        Context 'Invoking with default resource properties' {
            BeforeAll {
                # Arrange
                $viServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                $vmhost = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId'; Name = '10.23.82.112' }
                $advancedSettings = @(
                    [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'Mem.ShareScanTime'; Value = 20 }
                    [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'Mem.ShareScanGHz'; Value = 30 }
                    [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'Mem.ShareRateMax'; Value = 40 }
                    [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'Mem.ShareForceSalting'; Value = 50 }
                )

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId'; Name = '10.23.82.112' }
                }
                $advancedSettingsMock = {
                    return @(
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'Mem.ShareScanTime'; Value = 20 }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'Mem.ShareScanGHz'; Value = 30 }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'Mem.ShareRateMax'; Value = 40 }
                        [VMware.VimAutomation.ViCore.Impl.V1.AdvancedSettingImpl] @{ Name = 'Mem.ShareForceSalting'; Value = 50 }
                    )
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName Get-AdvancedSetting -MockWith $advancedSettingsMock -ModuleName $script:moduleName
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

            It 'Should call Get-VMHost mock with the passed server and name once' {
                # Act
                $resource.Get()

                # Assert
                Assert-MockCalled -CommandName Get-VMHost `
                                  -ParameterFilter { $Server -eq $viServer -and $Name -eq $script:resourceProperties.Name } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call Get-AdvancedSetting mock with the passed server and vmhost once' {
                # Act
                $resource.Get()

                # Assert
                Assert-MockCalled -CommandName Get-AdvancedSetting `
                                  -ParameterFilter { $Server -eq $viServer -and $Entity -eq $vmhost -and $Name -eq 'Mem.Sh*' } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should return the resource with the properties passed from the server' {
                # Act
                $result = $resource.Get()

                # Assert
                $result.Name | Should -Be $vmhost.Name
                $result.Server | Should -Be $script:resourceProperties.Server
                $result.ShareScanTime | Should -Be $advancedSettings[0].Value
                $result.ShareScanGHz | Should -Be $advancedSettings[1].Value
                $result.ShareRateMax | Should -Be $advancedSettings[2].Value
                $result.ShareForceSalting | Should -Be $advancedSettings[3].Value
            }
        }
    }
}
finally {
    # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
    Invoke-TestCleanup
}
