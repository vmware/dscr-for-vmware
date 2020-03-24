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
$script:resourceName = 'VMHostNtpSettings'

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

    Describe 'VMHostNtpSettings\Set' -Tag 'Set' {
        AfterEach {
            $script:resourceProperties.NtpServer = $null
            $script:resourceProperties.NtpServicePolicy = 'unset'
        }

        Context 'Invoking without NTPServer and NTP Service Policy' {
            BeforeAll {
                # Arrange
                $viServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ ExtensionData = [VMware.Vim.HostSystem] @{ Config = [VMware.Vim.HostConfigInfo] @{ DateTimeInfo `
                         = [VMware.Vim.HostDateTimeInfo] @{ NtpConfig = [VMware.Vim.HostNtpConfig] @{} } } } }
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
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
        }

        Context 'Invoking with not specified NTP Server' {
            BeforeAll {
                # Arrange
                $viServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                $dateTimeInfoObject = [VMware.Vim.HostDateTimeInfo] @{ NtpConfig = [VMware.Vim.HostNtpConfig] @{} }
                $dateTimeSystemObject = [VMware.Vim.HostDateTimeSystem] @{}

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ ExtensionData = [VMware.Vim.HostSystem] @{ Config = [VMware.Vim.HostConfigInfo] @{ DateTimeInfo `
                         = [VMware.Vim.HostDateTimeInfo] @{ NtpConfig = [VMware.Vim.HostNtpConfig] @{} } } } }
                }
                $dateTimeConfigMock = {
                    return [VMware.Vim.HostDateTimeInfo] @{}
                }
                $dateTimeSystemMock = {
                    return [VMware.Vim.HostDateTimeSystem] @{}
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName New-DateTimeConfig -MockWith $dateTimeConfigMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $dateTimeSystemMock `
                                           -ParameterFilter { $Server -eq $viServer -and $Id -eq $dateTimeSystemObject } `
                                           -ModuleName $script:moduleName
                Mock -CommandName Update-DateTimeConfig -MockWith { return $null } -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should not call New-DateTimeConfig mock' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName New-DateTimeConfig -ParameterFilter { $NtpServer -eq $null } -ModuleName $script:moduleName -Exactly 0 -Scope It
            }

            It 'Should not call Get-View mock' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Get-View `
                                  -ParameterFilter { $Server -eq $viServer -and $Id -eq $dateTimeSystemObject } `
                                  -ModuleName $script:moduleName -Exactly 0 -Scope It
            }

            It 'Should not call Update-DateTimeConfig mock' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Update-DateTimeConfig `
                                  -ParameterFilter { $DateTimeSystem -eq $dateTimeSystemObject -and `
                                                     $DateTimeConfig -eq $dateTimeInfoObject } `
                                  -ModuleName $script:moduleName -Exactly 0 -Scope It
            }
        }

        Context 'Invoking with empty array NTP Server' {
            BeforeAll {
                # Arrange
                $viServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                $dateTimeInfoObject = [VMware.Vim.HostDateTimeConfig] @{ NtpConfig = [VMware.Vim.HostNtpConfig] @{ Server = @('0.bg.pool.ntp.org') } }
                $dateTimeSystemMoRef = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostDateTimeSystem'; Value = 'DateTimeSystem' }
                $dateTimeSystemObject = [VMware.Vim.HostDateTimeSystem] @{}

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ ExtensionData `
                         = [VMware.Vim.HostSystem] @{ Config = [VMware.Vim.HostConfigInfo] @{ DateTimeInfo = [VMware.Vim.HostDateTimeInfo] @{ NtpConfig `
                         = [VMware.Vim.HostNtpConfig] @{ Server = @('0.bg.pool.ntp.org') } } }; ConfigManager = [VMware.Vim.HostConfigManager] @{ DateTimeSystem `
                         = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostDateTimeSystem'; Value = 'DateTimeSystem' } } } }
                }
                $dateTimeConfigMock = {
                    return [VMware.Vim.HostDateTimeConfig] @{ NtpConfig = [VMware.Vim.HostNtpConfig] @{ Server = @('0.bg.pool.ntp.org') } }
                }
                $dateTimeSystemMock = {
                    return [VMware.Vim.HostDateTimeSystem] @{}
                }

                $script:resourceProperties.NtpServer = @()

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName New-DateTimeConfig -MockWith $dateTimeConfigMock `
                                                     -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $dateTimeSystemMock `
                                           -ParameterFilter { $Server -eq $viServer -and $Id -eq $dateTimeSystemMoRef } `
                                           -ModuleName $script:moduleName
                Mock -CommandName Update-DateTimeConfig -MockWith { return $null } -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call New-DateTimeConfig mock once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName New-DateTimeConfig `
                                  -ParameterFilter { [System.Linq.Enumerable]::SequenceEqual($NtpServer, $script:resourceProperties.NtpServer) } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call Get-View mock once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Get-View `
                                  -ParameterFilter { $Server -eq $viServer -and $Id -eq $dateTimeSystemMoRef } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call Update-DateTimeConfig mock once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Update-DateTimeConfig `
                                  -ParameterFilter { $DateTimeSystem -eq $dateTimeSystemObject -and `
                                                     $DateTimeConfig -eq $dateTimeInfoObject } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }
        }

        Context 'Invoking with IP address contained in Desired NTP Server, but not in current NTP Server' {
            BeforeAll {
                # Arrange
                $viServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                $dateTimeInfoObject = [VMware.Vim.HostDateTimeConfig] @{ NtpConfig = [VMware.Vim.HostNtpConfig] @{ Server = @('1.bg.pool.ntp.org') } }
                $dateTimeSystemMoRef = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostDateTimeSystem'; Value = 'DateTimeSystem' }
                $dateTimeSystemObject = [VMware.Vim.HostDateTimeSystem] @{}

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ ExtensionData `
                         = [VMware.Vim.HostSystem] @{ Config = [VMware.Vim.HostConfigInfo] @{ DateTimeInfo =[VMware.Vim.HostDateTimeInfo]@{ NtpConfig `
                         = [VMware.Vim.HostNtpConfig] @{ Server = @('0.bg.pool.ntp.org') } } }; ConfigManager = [VMware.Vim.HostConfigManager] @{ DateTimeSystem `
                         = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostDateTimeSystem'; Value = 'DateTimeSystem' } } } }
                }
                $dateTimeConfigMock = {
                    return [VMware.Vim.HostDateTimeConfig] @{ NtpConfig = [VMware.Vim.HostNtpConfig] @{ Server = @('1.bg.pool.ntp.org') } }
                }
                $dateTimeSystemMock = {
                    return [VMware.Vim.HostDateTimeSystem] @{}
                }

                $script:resourceProperties.NtpServer = @("1.bg.pool.ntp.org")

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName New-DateTimeConfig -MockWith $dateTimeConfigMock `
                                                     -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $dateTimeSystemMock `
                                           -ParameterFilter { $Server -eq $viServer -and $Id -eq $dateTimeSystemMoRef } `
                                           -ModuleName $script:moduleName
                Mock -CommandName Update-DateTimeConfig -MockWith { return $null } -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call New-DateTimeConfig mock once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName New-DateTimeConfig `
                                  -ParameterFilter { [System.Linq.Enumerable]::SequenceEqual($NtpServer, [string[]] $script:resourceProperties.NtpServer) } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call Get-View mock once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Get-View `
                                  -ParameterFilter { $Server -eq $viServer -and $Id -eq $dateTimeSystemMoRef } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call Update-DateTimeConfig mock once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Update-DateTimeConfig `
                                  -ParameterFilter { $DateTimeSystem -eq $dateTimeSystemObject -and `
                                                     $DateTimeConfig -eq $dateTimeInfoObject } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }
        }

        Context 'Invoking with Desired NTP Server as a subset of current NTP Server' {
            BeforeAll {
                # Arrange
                $viServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                $dateTimeInfoObject = [VMware.Vim.HostDateTimeConfig] @{ NtpConfig = [VMware.Vim.HostNtpConfig] @{ Server = @('1.bg.pool.ntp.org') } }
                $dateTimeSystemMoRef = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostDateTimeSystem'; Value = 'DateTimeSystem' }
                $dateTimeSystemObject = [VMware.Vim.HostDateTimeSystem] @{}

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ ExtensionData `
                         = [VMware.Vim.HostSystem] @{ Config = [VMware.Vim.HostConfigInfo] @{ DateTimeInfo =[VMware.Vim.HostDateTimeInfo]@{ NtpConfig `
                         = [VMware.Vim.HostNtpConfig] @{ Server = @('0.bg.pool.ntp.org', '1.bg.pool.ntp.org') } } }; ConfigManager = [VMware.Vim.HostConfigManager] @{ DateTimeSystem `
                         = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostDateTimeSystem'; Value = 'DateTimeSystem' } } } }
                }
                $dateTimeConfigMock = {
                    return [VMware.Vim.HostDateTimeConfig] @{ NtpConfig = [VMware.Vim.HostNtpConfig] @{ Server = @('1.bg.pool.ntp.org') } }
                }
                $dateTimeSystemMock = {
                    return [VMware.Vim.HostDateTimeSystem] @{}
                }

                $script:resourceProperties.NtpServer = @('1.bg.pool.ntp.org')

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName New-DateTimeConfig -MockWith $dateTimeConfigMock `
                                                     -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $dateTimeSystemMock `
                                           -ParameterFilter { $Server -eq $viServer -and $Id -eq $dateTimeSystemMoRef } `
                                           -ModuleName $script:moduleName
                Mock -CommandName Update-DateTimeConfig -MockWith { return $null } -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call New-DateTimeConfig mock once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName New-DateTimeConfig `
                                  -ParameterFilter { [System.Linq.Enumerable]::SequenceEqual($NtpServer, [string[]] $script:resourceProperties.NtpServer) } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call Get-View mock once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Get-View `
                                  -ParameterFilter { $Server -eq $viServer -and $Id -eq $dateTimeSystemMoRef } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call Update-DateTimeConfig mock once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Update-DateTimeConfig `
                                  -ParameterFilter { $DateTimeSystem -eq $dateTimeSystemObject -and `
                                                     $DateTimeConfig -eq $dateTimeInfoObject } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }
        }

        Context 'Invoking with Desired NTP Server equal to current NTP Server' {
            BeforeAll {
                # Arrange
                $viServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                $dateTimeInfoObject = [VMware.Vim.HostDateTimeConfig] @{ NtpConfig = [VMware.Vim.HostNtpConfig] @{ Server = @('0.bg.pool.ntp.org', '1.bg.pool.ntp.org') } }
                $dateTimeSystemMoRef = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostDateTimeSystem'; Value = 'DateTimeSystem' }
                $dateTimeSystemObject = [VMware.Vim.HostDateTimeSystem] @{}

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ ExtensionData `
                         = [VMware.Vim.HostSystem] @{ Config = [VMware.Vim.HostConfigInfo] @{ DateTimeInfo = [VMware.Vim.HostDateTimeInfo] @{ NtpConfig `
                         = [VMware.Vim.HostNtpConfig] @{ Server = @('0.bg.pool.ntp.org', '1.bg.pool.ntp.org') } } }; ConfigManager = [VMware.Vim.HostConfigManager] @{ DateTimeSystem `
                         = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostDateTimeSystem'; Value = 'DateTimeSystem' } } } }
                }
                $dateTimeConfigMock = {
                    return [VMware.Vim.HostDateTimeInfo] @{ NtpConfig = [VMware.Vim.HostNtpConfig] @{ Server = @('0.bg.pool.ntp.org', '1.bg.pool.ntp.org') } }
                }
                $dateTimeSystemMock = {
                    return [VMware.Vim.HostDateTimeSystem] @{}
                }

                $script:resourceProperties.NtpServer = @('1.bg.pool.ntp.org', '0.bg.pool.ntp.org')

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName New-DateTimeConfig -MockWith $dateTimeConfigMock `
                                                     -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $dateTimeSystemMock `
                                           -ParameterFilter { $Server -eq $viServer -and $Id -eq $dateTimeSystemMoRef } `
                                           -ModuleName $script:moduleName
                Mock -CommandName Update-DateTimeConfig -MockWith { return $null } -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should not call New-DateTimeConfig mock' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName New-DateTimeConfig `
                                  -ParameterFilter { [System.Linq.Enumerable]::SequenceEqual($NtpServer, [string[]] $script:resourceProperties.NtpServer) } `
                                  -ModuleName $script:moduleName -Exactly 0 -Scope It
            }

            It 'Should not call Get-View mock' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Get-View `
                                  -ParameterFilter { $Server -eq $viServer -and $Id -eq $dateTimeSystemMoRef } `
                                  -ModuleName $script:moduleName -Exactly 0 -Scope It
            }

            It 'Should not call Update-DateTimeConfig mock' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Update-DateTimeConfig `
                                  -ParameterFilter { $DateTimeSystem -eq $dateTimeSystemObject -and `
                                                     $DateTimeConfig -eq $dateTimeInfoObject } `
                                  -ModuleName $script:moduleName -Exactly 0 -Scope It
            }
        }

        Context 'Invoking with not specified NTP Service Policy' {
            BeforeAll {
                # Arrange
                $viServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                $serviceSystemObject = [VMware.Vim.HostServiceSystem] @{}
                $serviceSystemMoRef = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostServiceSystem'; Value = 'ServiceSystem' }

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ ExtensionData `
                         = [VMware.Vim.HostSystem] @{ Config = [VMware.Vim.HostConfigInfo] @{ DateTimeInfo =[VMware.Vim.HostDateTimeInfo]@{}; Service `
                         = [VMware.Vim.HostServiceInfo] @{ Service = @([VMware.Vim.HostService] @{ Key = 'ntpd'; Policy = 'automatic' }) } }; ConfigManager `
                         = [VMware.Vim.HostConfigManager] @{ ServiceSystem = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostServiceSystem'; Value = 'ServiceSystem' } } } }
                }
                $serviceSystemMock = {
                    return [VMware.Vim.HostServiceSystem] @{}
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $serviceSystemMock `
                                           -ParameterFilter { $Server -eq $viServer -and $VIObject -eq $serviceSystemObject } `
                                           -ModuleName $script:moduleName
                Mock -CommandName Update-ServicePolicy -MockWith { return $null } -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should not call Get-View mock' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Get-View `
                                  -ParameterFilter { $Server -eq $viServer -and $Id -eq $serviceSystemMoRef } `
                                  -ModuleName $script:moduleName -Exactly 0 -Scope It
            }

            It 'Should not call Update-ServicePolicy mock' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Update-ServicePolicy `
                                  -ParameterFilter { $ServiceSystem -eq $serviceSystemObject -and `
                                                     $ServiceId -eq 'ntpd' -and `
                                                     $ServicePolicyValue -eq 'unset' } `
                                  -ModuleName $script:moduleName -Exactly 0 -Scope It
            }
        }

        Context 'Invoking with the same NTP Service Policy' {
            BeforeAll {
                # Arrange
                $viServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                $serviceSystemObject = [VMware.Vim.HostServiceSystem] @{}
                $serviceSystemMoRef = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostServiceSystem'; Value = 'ServiceSystem' }

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ ExtensionData `
                         = [VMware.Vim.HostSystem] @{ Config = [VMware.Vim.HostConfigInfo] @{ DateTimeInfo = [VMware.Vim.HostDateTimeInfo] @{}; Service `
                         = [VMware.Vim.HostServiceInfo] @{ Service = @([VMware.Vim.HostService] @{ Key = 'ntpd'; Policy = 'automatic' }) } }; ConfigManager `
                         = [VMware.Vim.HostConfigManager] @{ ServiceSystem = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostServiceSystem'; Value = 'ServiceSystem' } } } }
                }
                $serviceSystemMock = {
                    return [VMware.Vim.HostServiceSystem] @{}
                }

                $script:resourceProperties.NtpServicePolicy = 'automatic'

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $serviceSystemMock `
                                           -ParameterFilter { $Server -eq $viServer -and $VIObject -eq $serviceSystemObject } `
                                           -ModuleName $script:moduleName
                Mock -CommandName Update-ServicePolicy -MockWith { return $null } -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should not call Get-View mock' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Get-View `
                                  -ParameterFilter { $Server -eq $viServer -and $Id -eq $serviceSystemMoRef } `
                                  -ModuleName $script:moduleName -Exactly 0 -Scope It
            }

            It 'Should not call Update-ServicePolicy mock' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Update-ServicePolicy `
                                  -ParameterFilter { $ServiceSystem -eq $serviceSystemObject -and `
                                                     $ServiceId -eq 'ntpd' -and `
                                                     $ServicePolicyValue -eq 'automatic' } `
                                  -ModuleName $script:moduleName -Exactly 0 -Scope It
            }
        }

        Context 'Invoking with different NTP Service Policy' {
            BeforeAll {
                # Arrange
                $viServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                $serviceSystemObject = [VMware.Vim.HostServiceSystem] @{}
                $serviceSystemMoRef = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostServiceSystem'; Value = 'ServiceSystem' }

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ ExtensionData `
                         = [VMware.Vim.HostSystem] @{ Config = [VMware.Vim.HostConfigInfo] @{ DateTimeInfo = [VMware.Vim.HostDateTimeInfo] @{}; Service `
                         = [VMware.Vim.HostServiceInfo] @{ Service = @([VMware.Vim.HostService] @{ Key = 'ntpd'; Policy = 'automatic' }) } }; ConfigManager `
                         = [VMware.Vim.HostConfigManager] @{ ServiceSystem = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostServiceSystem'; Value = 'ServiceSystem' } } } }
                }
                $serviceSystemMock = {
                    return [VMware.Vim.HostServiceSystem] @{}
                }

                $script:resourceProperties.NtpServicePolicy = 'on'

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $serviceSystemMock `
                                           -ParameterFilter { $Server -eq $viServer -and $Id -eq $serviceSystemMoRef } `
                                           -ModuleName $script:moduleName
                Mock -CommandName Update-ServicePolicy -MockWith { return $null } -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call Get-View mock once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Get-View `
                                  -ParameterFilter { $Server -eq $viServer -and $Id -eq $serviceSystemMoRef } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call Update-ServicePolicy mock once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Update-ServicePolicy `
                                  -ParameterFilter { $ServiceSystem -eq $serviceSystemObject -and `
                                                     $ServiceId -eq 'ntpd' -and `
                                                     $ServicePolicyValue -eq 'on' } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }
        }
    }

    Describe 'VMHostNtpSettings\Test' -Tag 'Test' {
        AfterEach {
            $script:resourceProperties.NtpServer = $null
            $script:resourceProperties.NtpServicePolicy = 'unset'
        }

        Context 'Invoking without NTPServer and NTP Service Policy' {
            BeforeAll {
                # Arrange
                $viServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ ExtensionData = [VMware.Vim.HostSystem] @{ Config = [VMware.Vim.HostConfigInfo] @{ DateTimeInfo `
                         = [VMware.Vim.HostDateTimeInfo] @{ NtpConfig = [VMware.Vim.HostNtpConfig] @{} } } } }
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
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
        }

        Context 'Invoking with not specified NTP Server' {
            BeforeAll {
                # Arrange
                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ ExtensionData = [VMware.Vim.HostSystem] @{ Config = [VMware.Vim.HostConfigInfo] @{ DateTimeInfo `
                         = [VMware.Vim.HostDateTimeInfo] @{ NtpConfig = [VMware.Vim.HostNtpConfig] @{} } } } }
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should return $true (The NTP Server should not be updated)' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $true
            }
        }

        Context 'Invoking with empty array NTP Server' {
            BeforeAll {
                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ ExtensionData `
                         = [VMware.Vim.HostSystem] @{ Config = [VMware.Vim.HostConfigInfo] @{ DateTimeInfo = [VMware.Vim.HostDateTimeInfo] @{ NtpConfig `
                         = [VMware.Vim.HostNtpConfig] @{ Server = @('0.bg.pool.ntp.org') } } }; ConfigManager = [VMware.Vim.HostConfigManager] @{ DateTimeSystem `
                         = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostDateTimeSystem'; Value = 'DateTimeSystem' } } } }
                }

                $script:resourceProperties.NtpServer = @()

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should return $false (The desired NTP Server is empty array and current NTP Server should be updated)' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $false
            }
        }

        Context 'Invoking with IP address contained in Desired NTP Server, but not in current NTP Server' {
            BeforeAll {
                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ ExtensionData `
                         = [VMware.Vim.HostSystem] @{ Config = [VMware.Vim.HostConfigInfo] @{ DateTimeInfo = [VMware.Vim.HostDateTimeInfo] @{ NtpConfig `
                         = [VMware.Vim.HostNtpConfig] @{ Server = @('0.bg.pool.ntp.org') } } }; ConfigManager = [VMware.Vim.HostConfigManager] @{ DateTimeSystem `
                         = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostDateTimeSystem'; Value = 'DateTimeSystem' } } } }
                }

                $script:resourceProperties.NtpServer = @('1.bg.pool.ntp.org')

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should return $false (The desired NTP Server contains IP address that the current NTP Server does not)' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $false
            }
        }

        Context 'Invoking with Desired NTP Server as a subset of current NTP Server' {
            BeforeAll {
                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ ExtensionData `
                         = [VMware.Vim.HostSystem] @{ Config = [VMware.Vim.HostConfigInfo] @{ DateTimeInfo = [VMware.Vim.HostDateTimeInfo] @{ NtpConfig `
                         = [VMware.Vim.HostNtpConfig] @{ Server = @('0.bg.pool.ntp.org', '1.bg.pool.ntp.org') } } }; ConfigManager = [VMware.Vim.HostConfigManager] @{ DateTimeSystem `
                         = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostDateTimeSystem'; Value = 'DateTimeSystem' } } } }
                }

                $script:resourceProperties.NtpServer = @('1.bg.pool.ntp.org')

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should return $false (The desired NTP Server is a subset of the current NTP Server)' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $false
            }
        }

        Context 'Invoking with Desired NTP Server equal to current NTP Server' {
            BeforeAll {
                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ ExtensionData `
                         = [VMware.Vim.HostSystem] @{ Config = [VMware.Vim.HostConfigInfo] @{ DateTimeInfo = [VMware.Vim.HostDateTimeInfo] @{ NtpConfig `
                         = [VMware.Vim.HostNtpConfig] @{ Server = @('0.bg.pool.ntp.org', '1.bg.pool.ntp.org') } } }; ConfigManager = [VMware.Vim.HostConfigManager] @{ DateTimeSystem `
                         = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostDateTimeSystem'; Value = 'DateTimeSystem' } } } }
                }

                $script:resourceProperties.NtpServer = @('1.bg.pool.ntp.org', '0.bg.pool.ntp.org')

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should return $true (The desired NTP Server is equal to the current NTP Server)' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $true
            }
        }

        Context 'Invoking with not specified NTP Service Policy' {
            BeforeAll {
                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ ExtensionData `
                         = [VMware.Vim.HostSystem] @{ Config = [VMware.Vim.HostConfigInfo] @{ DateTimeInfo = [VMware.Vim.HostDateTimeInfo] @{}; Service `
                         = [VMware.Vim.HostServiceInfo] @{ Service = @([VMware.Vim.HostService] @{ Key = 'ntpd'; Policy = 'automatic' }) } }; ConfigManager = [VMware.Vim.HostConfigManager] @{ ServiceSystem `
                         = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostServiceSystem'; Value = 'ServiceSystem' } } } }
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should return $true (The NTP Service Policy is not specified and should not be updated)' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $true
            }
        }

        Context 'Invoking with the same NTP Service Policy' {
            BeforeAll {
                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ ExtensionData `
                         = [VMware.Vim.HostSystem] @{ Config = [VMware.Vim.HostConfigInfo] @{ DateTimeInfo = [VMware.Vim.HostDateTimeInfo] @{}; Service `
                         = [VMware.Vim.HostServiceInfo] @{ Service = @([VMware.Vim.HostService] @{ Key = 'ntpd'; Policy = 'automatic' }) } }; ConfigManager = [VMware.Vim.HostConfigManager] @{ ServiceSystem `
                         = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostServiceSystem'; Value = 'ServiceSystem' } } } }
                }

                $script:resourceProperties.NtpServicePolicy = 'automatic'

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should return $true (The desired NTP Service Policy is the same as the current NTP Service Policy)' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $true
            }
        }

        Context 'Invoking with different NTP Service Policy' {
            BeforeAll {
                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ ExtensionData `
                         = [VMware.Vim.HostSystem] @{ Config = [VMware.Vim.HostConfigInfo] @{ DateTimeInfo = [VMware.Vim.HostDateTimeInfo] @{}; Service `
                         = [VMware.Vim.HostServiceInfo] @{ Service = @([VMware.Vim.HostService] @{ Key = 'ntpd'; Policy = 'automatic' }) } }; ConfigManager = [VMware.Vim.HostConfigManager] @{ ServiceSystem `
                         = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostServiceSystem'; Value = 'ServiceSystem' } } } }
                }

                $script:resourceProperties.NtpServicePolicy = 'on'

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should return $false (The desired NTP Service Policy is different than the current NTP Service Policy)' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $false
            }
        }
    }

    Describe 'VMHostNtpSettings\Get' -Tag 'Get' {
        BeforeAll {
            # Arrange
            $viServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }

            $viServerMock = {
                return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
            }
            $vmHostMock = {
                return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Name = '10.23.82.112'; ExtensionData `
                     = [VMware.Vim.HostSystem] @{ Config = [VMware.Vim.HostConfigInfo] @{ DateTimeInfo = [VMware.Vim.HostDateTimeInfo] @{ NtpConfig `
                     = [VMware.Vim.HostNtpConfig] @{ Server = @('0.bg.pool.ntp.org', '1.bg.pool.ntp.org') } }; Service = [VMware.Vim.HostServiceInfo] @{ Service `
                     = @([VMware.Vim.HostService] @{ Key = 'ntpd'; Policy = 'automatic' }) } }; ConfigManager = [VMware.Vim.HostConfigManager] @{ DateTimeSystem `
                     = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostDateTimeSystem'; Value = 'DateTimeSystem' } } } }
            }

            Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
            Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
        }

        AfterEach {
            $script:resourceProperties.NtpServer = $null
            $script:resourceProperties.NtpServicePolicy = 'unset'
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

        It 'Should match the properties retrieved from the server' {
            # Act
            $result = $resource.Get()

            # Assert
            $result.Name | Should -Be $script:resourceProperties.Name
            $result.Server | Should -Be $script:resourceProperties.Server
            $result.NtpServer | Should -Be @('0.bg.pool.ntp.org', '1.bg.pool.ntp.org')
            $result.NtpServicePolicy | Should -Be 'automatic'
        }
    }
}
finally {
    # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
    Invoke-TestCleanup
}
