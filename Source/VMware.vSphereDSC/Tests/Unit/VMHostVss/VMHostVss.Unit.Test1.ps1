<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

using module VMware.vSphereDSC

function BeforeAllTests {
    $script:modulePath = $env:PSModulePath
    $script:unitTestsFolder = Join-Path (Join-Path (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase 'Tests') 'Unit'
    $script:mockModuleLocation = "$script:unitTestsFolder\TestHelpers"

    $script:moduleName = 'VMware.vSphereDSC'
    $script:resourceName = 'VMHostVss'

    $user = 'user'
    $password = 'password' | ConvertTo-SecureString -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential($user, $password)

    $global:resourceProperties = @{
        Name = '10.23.82.112'
        Server = '10.23.82.112'
        Credential = $credential
        Ensure = 'Present'
        VssName = 'DSCTest'
        NumPorts = 1
        Mtu = 1500
        Key = 'VSS'
        NumPortsAvailable = 1
        Pnic = @('vmnic1', 'vmnic2')
        Portgroup = @('Portgroup1', 'Portgroup2')
    }

    $env:PSModulePath = $script:mockModuleLocation
    $vimAutomationModule = Get-Module -Name VMware.VimAutomation.Core
    if ($null -ne $vimAutomationModule -and $vimAutomationModule.Path -NotMatch 'TestHelpers') {
        throw 'The Original VMware.VimAutomation.Core Module is loaded in the current session. If you want to run the unit tests please open a new PowerShell session.'
    }

    Import-Module -Name VMware.VimAutomation.Core
}

function AfterAllTests {
    Remove-Variable -Name resourceProperties -Scope Global -Confirm:$false
    Remove-Module -Name VMware.VimAutomation.Core
    $env:PSModulePath = $script:modulePath
}

# Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
Try {
    BeforeAllTests

    Describe 'VMHostVss\Set'  -Tag 'Set' {
        Context 'Present + VSS does not exist' {
            BeforeAll {
                $vCenter = [VMware.Vim.VCenter] @{ Name = '10.23.82.112'; User = 'user' }
                $networkSystemMoRef = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostNetworkSystem'; Value = 'NetworkId' }

                $vCenterMock = {
                    return [VMware.Vim.VCenter] @{ Name = '10.23.82.112'; User = 'user'}
                }
                $vmHostMock = {
                    return [VMware.Vim.VMHost] @{
                        Name = '10.23.82.112'
                        ExtensionData = [VMware.Vim.HostExtensionData] @{
                            ConfigManager = [VMware.Vim.HostConfigManager] @{
                                NetworkSystem = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostNetworkSystem'; Value = 'NetworkId' }
                            }
                        }
                    }
                }
                $networkSystemMock = {
                    return (
                        [VMware.Vim.HostNetworkSystem] @{
                            NetworkInfo = [VMware.Vim.HostNetworkInfo] @{
                                vswitch = $null
                            }
                        }
                    )
                }
                $vssConfigMock = {
                    return [VMware.Vim.HostVirtualSwitchConfig] @{
                        Name = $global:resourceProperties.VssName
                        ChangeOperation = 'add'
                        Spec = [VMware.Vim.HostVirtualSwitchSpec] @{
                            Mtu = $global:resourceProperties.Mtu
                            NumPorts = $global:resourceProperties.NumPorts
                        }
                    }
                }
                $updateNetworkMock = {
                    return [VMware.Vim.HostNetworkConfigResult] @{
                        ConsoleVnicDevice = $null
                        VnicDevice = $null
                    }
                }
            }

            # Arrange
            Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
            Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $networkSystemMock -ModuleName $script:moduleName
            Mock -CommandName New-VssConfig -MockWith $vssConfigMock -ModuleName $script:moduleName
            Mock -CommandName Update-Network -MockWith $updateNetworkMock -ModuleName $script:moduleName

            $resource = New-Object -TypeName $script:resourceName -Property $global:resourceProperties

            It 'Should call the Connect-VIServer mock with the passed server and credentials once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Connect-VIServer `
                    -ParameterFilter { $Server -eq $global:resourceProperties.Server -and $Credential -eq $global:resourceProperties.Credential } `
                    -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call Get-VMHost with the passed server and name once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Get-VMHost `
                    -ParameterFilter { $Server -eq $vCenter -and $Name -eq $global:resourceProperties.Name } `
                    -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call Get-View with the passed server and id twice' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Get-View `
                    -ParameterFilter { $Server -eq $vCenter -and $Id -eq $networkSystemMoRef } `
                    -ModuleName $script:moduleName -Exactly 2 -Scope It
            }

            It 'Should call New-VssConfig once with operation Add' {
                # Act
                $result = $resource.Set()

                # Assert
                Assert-MockCalled -CommandName New-VssConfig `
                    -ParameterFilter { $Name -eq $global:resourceProperties.VssName -and $Operation -eq 'add' } `
                    -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call Update-Network once with type Add' {
                # Act
                $result = $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Update-Network `
                    -ParameterFilter { $Type -eq 'VSS' -and $VssConfig.ChangeOperation -eq 'add' } `
                    -ModuleName $script:moduleName -Exactly 1 -Scope It
            }
        }

        Context 'Present + VSS does exist with different properties' {
            BeforeAll {
                $vCenter = [VMware.Vim.VCenter] @{ Name = '10.23.82.112'; User = 'user' }
                $networkSystemMoRef = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostNetworkSystem'; Value = 'NetworkId' }

                $vCenterMock = {
                    return [VMware.Vim.VCenter] @{ Name = '10.23.82.112'; User = 'user'}
                }
                $vmHostMock = {
                    return [VMware.Vim.VMHost] @{
                        Name = '10.23.82.112'
                        ExtensionData = [VMware.Vim.HostExtensionData] @{
                            ConfigManager = [VMware.Vim.HostConfigManager] @{
                                NetworkSystem = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostNetworkSystem'; Value = 'NetworkId' }
                            }
                        }
                    }
                }
                $networkSystemMock = {
                    return (
                        [VMware.Vim.HostNetworkSystem] @{
                            NetworkInfo = [VMware.Vim.HostNetworkInfo] @{
                                vswitch = @(
                                    [VMware.Vim.HostVirtualSwitch]@{
                                        Key = $global:resourceProperties.Key
                                        Mtu = $global:resourceProperties.Mtu + 1
                                        Name = $global:resourceProperties.VssName
                                        NumPorts = $global:resourceProperties.NumPorts + 1
                                        NumPortsAvailable = $global:resourceProperties.NumPortsAvailable
                                        Pnic = $global:resourceProperties.Pnic
                                        PortGroup = $global:resourceProperties.Portgroup
                                    }
                                )
                            }
                        }
                    )
                }
                $vssConfigMock = {
                    return [VMware.Vim.HostVirtualSwitchConfig] @{
                        Name = $global:resourceProperties.VssName
                        ChangeOperation = 'edit'
                        Spec = [VMware.Vim.HostVirtualSwitchSpec] @{
                            Mtu = $global:resourceProperties.Mtu
                            NumPorts = $global:resourceProperties.NumPorts
                        }
                    }
                }
                $updateNetworkMock = {
                    return [VMware.Vim.HostNetworkConfigResult] @{
                        ConsoleVnicDevice = $null
                        VnicDevice = $null
                    }
                }
            }

            # Arrange
            Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
            Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $networkSystemMock -ModuleName $script:moduleName
            Mock -CommandName New-VssConfig -MockWith $vssConfigMock -ModuleName $script:moduleName
            Mock -CommandName Update-Network -MockWith $updateNetworkMock -ModuleName $script:moduleName

            $resource = New-Object -TypeName $script:resourceName -Property $global:resourceProperties

            It 'Should call New-VssConfig once with operation Edit' {
                # Act
                $result = $resource.Set()

                # Assert
                Assert-MockCalled -CommandName New-VssConfig `
                    -ParameterFilter { $Name -eq $global:resourceProperties.VssName -and $Operation -eq 'edit' } `
                    -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call Update-Network once with type Edit' {
                # Act
                $result = $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Update-Network `
                    -ParameterFilter { $Type -eq 'VSS' -and $VssConfig.ChangeOperation -eq 'edit' } `
                    -ModuleName $script:moduleName -Exactly 1 -Scope It
            }
        }

        Context 'Absent + VSS exists' {
            BeforeAll {
                $global:resourceProperties.Ensure = 'Absent'

                $vCenter = [VMware.Vim.VCenter] @{ Name = '10.23.82.112'; User = 'user' }
                $networkSystemMoRef = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostNetworkSystem'; Value = 'NetworkId' }

                $vCenterMock = {
                    return [VMware.Vim.VCenter] @{ Name = '10.23.82.112'; User = 'user'}
                }
                $vmHostMock = {
                    return [VMware.Vim.VMHost] @{
                        Name = '10.23.82.112'
                        ExtensionData = [VMware.Vim.HostExtensionData] @{
                            ConfigManager = [VMware.Vim.HostConfigManager] @{
                                NetworkSystem = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostNetworkSystem'; Value = 'NetworkId' }
                            }
                        }
                    }
                }
                $networkSystemMock = {
                    return (
                        [VMware.Vim.HostNetworkSystem] @{
                            NetworkInfo = [VMware.Vim.HostNetworkInfo] @{
                                vswitch = @(
                                    [VMware.Vim.HostVirtualSwitch]@{
                                        Key = $global:resourceProperties.Key
                                        Mtu = $global:resourceProperties.Mtu
                                        Name = $global:resourceProperties.VssName
                                        NumPorts = $global:resourceProperties.NumPorts
                                        NumPortsAvailable = $global:resourceProperties.NumPortsAvailable
                                        Pnic = $global:resourceProperties.Pnic
                                        PortGroup = $global:resourceProperties.Portgroup
                                    }
                                )
                            }
                        }
                    )
                }
                $vssConfigMock = {
                    return [VMware.Vim.HostVirtualSwitchConfig] @{
                        Name = $global:resourceProperties.VssName
                        ChangeOperation = 'remove'
                        Spec = [VMware.Vim.HostVirtualSwitchSpec] @{
                            Mtu = $global:resourceProperties.Mtu
                            NumPorts = $global:resourceProperties.NumPorts
                        }
                    }
                }
                $updateNetworkMock = {
                    return [VMware.Vim.HostNetworkConfigResult] @{
                        ConsoleVnicDevice = $null
                        VnicDevice = $null
                    }
                }
            }

            AfterAll {
                $global:resourceProperties.Ensure = 'Present'
            }

            # Arrange
            Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
            Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $networkSystemMock -ModuleName $script:moduleName
            Mock -CommandName New-VssConfig -MockWith $vssConfigMock -ModuleName $script:moduleName
            Mock -CommandName Update-Network -MockWith $updateNetworkMock -ModuleName $script:moduleName

            $resource = New-Object -TypeName $script:resourceName -Property $global:resourceProperties

            It 'Should call New-VssConfig once with operation Remove' {
                # Act
                $result = $resource.Set()

                # Assert
                Assert-MockCalled -CommandName New-VssConfig `
                    -ParameterFilter { $Name -eq $global:resourceProperties.VssName -and $Operation -eq 'remove' } `
                    -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call Update-Network once with type Remove' {
                # Act
                $result = $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Update-Network `
                    -ParameterFilter { $Type -eq 'VSS' -and $VssConfig.ChangeOperation -eq 'remove' } `
                    -ModuleName $script:moduleName -Exactly 1 -Scope It
            }
        }
    }

    Describe 'VMHostVss\Test' -Tag 'Test' {
        Context 'Present + VSS does not exist' {
            BeforeAll {
                $vCenter = [VMware.Vim.VCenter] @{ Name = '10.23.82.112'; User = 'user' }
                $networkSystemMoRef = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostNetworkSystem'; Value = 'NetworkId' }

                $vCenterMock = {
                    return [VMware.Vim.VCenter] @{ Name = '10.23.82.112'; User = 'user'}
                }
                $vmHostMock = {
                    return [VMware.Vim.VMHost] @{
                        Name = '10.23.82.112'
                        ExtensionData = [VMware.Vim.HostExtensionData] @{
                            ConfigManager = [VMware.Vim.HostConfigManager] @{
                                NetworkSystem = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostNetworkSystem'; Value = 'NetworkId' }
                            }
                        }
                    }
                }
                $networkSystemMock = {
                    return (
                        [VMware.Vim.HostNetworkSystem] @{
                            NetworkInfo = [VMware.Vim.HostNetworkInfo] @{
                                vswitch = $null
                            }
                        }
                    )
                }
            }

            # Arrange
            Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
            Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $networkSystemMock -ModuleName $script:moduleName

            $resource = New-Object -TypeName $script:resourceName -Property $global:resourceProperties

            It 'Should call the Connect-VIServer mock with the passed server and credentials once' {
                # Act
                $resource.Test()

                # Assert
                Assert-MockCalled -CommandName Connect-VIServer `
                    -ParameterFilter { $Server -eq $global:resourceProperties.Server -and $Credential -eq $global:resourceProperties.Credential } `
                    -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call Get-VMHost with the passed server and name once' {
                # Act
                $resource.Test()

                # Assert
                Assert-MockCalled -CommandName Get-VMHost `
                    -ParameterFilter { $Server -eq $vCenter -and $Name -eq $global:resourceProperties.Name } `
                    -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call Get-View with the passed server and id once' {
                # Act
                $resource.Test()

                # Assert
                Assert-MockCalled -CommandName Get-View `
                    -ParameterFilter { $Server -eq $vCenter -and $Id -eq $networkSystemMoRef } `
                    -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should return $false (The desired VSS does not exist)' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $false
            }
        }

        Context 'Present + VSS does exist with different properties' {
            BeforeAll {
                $vCenter = [VMware.Vim.VCenter] @{ Name = '10.23.82.112'; User = 'user' }
                $networkSystemMoRef = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostNetworkSystem'; Value = 'NetworkId' }

                $vCenterMock = {
                    return [VMware.Vim.VCenter] @{ Name = '10.23.82.112'; User = 'user'}
                }
                $vmHostMock = {
                    return [VMware.Vim.VMHost] @{
                        Name = '10.23.82.112'
                        ExtensionData = [VMware.Vim.HostExtensionData] @{
                            ConfigManager = [VMware.Vim.HostConfigManager] @{
                                NetworkSystem = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostNetworkSystem'; Value = 'NetworkId' }
                            }
                        }
                    }
                }
                $networkSystemMock = {
                    return (
                        [VMware.Vim.HostNetworkSystem] @{
                            NetworkInfo = [VMware.Vim.HostNetworkInfo] @{
                                vswitch = @(
                                    [VMware.Vim.HostVirtualSwitch]@{
                                        Key = $global:resourceProperties.Key
                                        Mtu = $global:resourceProperties.Mtu + 1
                                        Name = $global:resourceProperties.VssName
                                        NumPorts = $global:resourceProperties.NumPorts + 1
                                        NumPortsAvailable = $global:resourceProperties.NumPortsAvailable
                                        Pnic = $global:resourceProperties.Pnic
                                        PortGroup = $global:resourceProperties.Portgroup
                                    }
                                )
                            }
                        }
                    )
                }
            }

            # Arrange
            Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
            Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $networkSystemMock -ModuleName $script:moduleName

            $resource = New-Object -TypeName $script:resourceName -Property $global:resourceProperties

            It 'Should return $false (The desired VSS is not configured correctly)' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $false
            }
        }

        Context 'Present + VSS does exist with the same properties' {
            BeforeAll {
                $vCenter = [VMware.Vim.VCenter] @{ Name = '10.23.82.112'; User = 'user' }
                $networkSystemMoRef = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostNetworkSystem'; Value = 'NetworkId' }

                $vCenterMock = {
                    return [VMware.Vim.VCenter] @{ Name = '10.23.82.112'; User = 'user'}
                }
                $vmHostMock = {
                    return [VMware.Vim.VMHost] @{
                        Name = '10.23.82.112'
                        ExtensionData = [VMware.Vim.HostExtensionData] @{
                            ConfigManager = [VMware.Vim.HostConfigManager] @{
                                NetworkSystem = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostNetworkSystem'; Value = 'NetworkId' }
                            }
                        }
                    }
                }
                $networkSystemMock = {
                    return (
                        [VMware.Vim.HostNetworkSystem] @{
                            NetworkInfo = [VMware.Vim.HostNetworkInfo] @{
                                vswitch = @(
                                    [VMware.Vim.HostVirtualSwitch]@{
                                        Key = $global:resourceProperties.Key
                                        Mtu = $global:resourceProperties.Mtu
                                        Name = $global:resourceProperties.VssName
                                        NumPorts = $global:resourceProperties.NumPorts
                                        NumPortsAvailable = $global:resourceProperties.NumPortsAvailable
                                        Pnic = $global:resourceProperties.Pnic
                                        PortGroup = $global:resourceProperties.Portgroup
                                    }
                                )
                            }
                        }
                    )
                }
            }

            # Arrange
            Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
            Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $networkSystemMock -ModuleName $script:moduleName

            $resource = New-Object -TypeName $script:resourceName -Property $global:resourceProperties

            It 'Should return $true (The desired VSS is configured correctly)' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $true
            }
        }

        Context 'Absent + VSS does not exist' {
            BeforeAll {
                $global:resourceProperties.Ensure = 'Absent'

                $vCenter = [VMware.Vim.VCenter] @{ Name = '10.23.82.112'; User = 'user' }
                $networkSystemMoRef = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostNetworkSystem'; Value = 'NetworkId' }

                $vCenterMock = {
                    return [VMware.Vim.VCenter] @{ Name = '10.23.82.112'; User = 'user'}
                }
                $vmHostMock = {
                    return [VMware.Vim.VMHost] @{
                        Name = '10.23.82.112'
                        ExtensionData = [VMware.Vim.HostExtensionData] @{
                            ConfigManager = [VMware.Vim.HostConfigManager] @{
                                NetworkSystem = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostNetworkSystem'; Value = 'NetworkId' }
                            }
                        }
                    }
                }
                $networkSystemMock = {
                    return (
                        [VMware.Vim.HostNetworkSystem] @{
                            NetworkInfo = [VMware.Vim.HostNetworkInfo] @{
                                vswitch = $null
                            }
                        }
                    )
                }
            }

            AfterAll {
                $global:resourceProperties.Ensure = 'Present'
            }

            # Arrange
            Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
            Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $networkSystemMock -ModuleName $script:moduleName

            $resource = New-Object -TypeName $script:resourceName -Property $global:resourceProperties

            It 'Should call the Connect-VIServer mock with the passed server and credentials once' {
                # Act
                $resource.Test()

                # Assert
                Assert-MockCalled -CommandName Connect-VIServer `
                    -ParameterFilter { $Server -eq $global:resourceProperties.Server -and $Credential -eq $global:resourceProperties.Credential } `
                    -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call Get-VMHost with the passed server and name once' {
                # Act
                $resource.Get()

                # Assert
                Assert-MockCalled -CommandName Get-VMHost `
                    -ParameterFilter { $Server -eq $vCenter -and $Name -eq $global:resourceProperties.Name } `
                    -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call Get-View with the passed server and id once' {
                # Act
                $resource.Get()

                # Assert
                Assert-MockCalled -CommandName Get-View `
                    -ParameterFilter { $Server -eq $vCenter -and $Id -eq $networkSystemMoRef } `
                    -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should return $true (The VSS does not exist)' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $true
            }
        }

        Context 'Absent + VSS does exist with different properties' {
            BeforeAll {
                $global:resourceProperties.Ensure = 'Absent'

                $vCenter = [VMware.Vim.VCenter] @{ Name = '10.23.82.112'; User = 'user' }
                $networkSystemMoRef = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostNetworkSystem'; Value = 'NetworkId' }

                $vCenterMock = {
                    return [VMware.Vim.VCenter] @{ Name = '10.23.82.112'; User = 'user'}
                }
                $vmHostMock = {
                    return [VMware.Vim.VMHost] @{
                        Name = '10.23.82.112'
                        ExtensionData = [VMware.Vim.HostExtensionData] @{
                            ConfigManager = [VMware.Vim.HostConfigManager] @{
                                NetworkSystem = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostNetworkSystem'; Value = 'NetworkId' }
                            }
                        }
                    }
                }
                $networkSystemMock = {
                    return (
                        [VMware.Vim.HostNetworkSystem] @{
                            NetworkInfo = [VMware.Vim.HostNetworkInfo] @{
                                vswitch = @(
                                    [VMware.Vim.HostVirtualSwitch]@{
                                        Key = $global:resourceProperties.Key
                                        Mtu = $global:resourceProperties.Mtu + 1
                                        Name = $global:resourceProperties.VssName
                                        NumPorts = $global:resourceProperties.NumPorts + 1
                                        NumPortsAvailable = $global:resourceProperties.NumPortsAvailable
                                        Pnic = $global:resourceProperties.Pnic
                                        PortGroup = $global:resourceProperties.Portgroup
                                    }
                                )
                            }
                        }
                    )
                }
            }

            AfterAll {
                $global:resourceProperties.Ensure = 'Present'
            }

            # Arrange
            Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
            Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $networkSystemMock -ModuleName $script:moduleName

            $resource = New-Object -TypeName $script:resourceName -Property $global:resourceProperties

            It 'Should return $false (The VSS exists)' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $false
            }
        }

        Context 'Absent + VSS does exist with the same properties' {
            BeforeAll {
                $global:resourceProperties.Ensure = 'Absent'

                $vCenter = [VMware.Vim.VCenter] @{ Name = '10.23.82.112'; User = 'user' }
                $networkSystemMoRef = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostNetworkSystem'; Value = 'NetworkId' }

                $vCenterMock = {
                    return [VMware.Vim.VCenter] @{ Name = '10.23.82.112'; User = 'user'}
                }
                $vmHostMock = {
                    return [VMware.Vim.VMHost] @{
                        Name = '10.23.82.112'
                        ExtensionData = [VMware.Vim.HostExtensionData] @{
                            ConfigManager = [VMware.Vim.HostConfigManager] @{
                                NetworkSystem = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostNetworkSystem'; Value = 'NetworkId' }
                            }
                        }
                    }
                }
                $networkSystemMock = {
                    return (
                        [VMware.Vim.HostNetworkSystem] @{
                            NetworkInfo = [VMware.Vim.HostNetworkInfo] @{
                                vswitch = @(
                                    [VMware.Vim.HostVirtualSwitch]@{
                                        Key = $global:resourceProperties.Key
                                        Mtu = $global:resourceProperties.Mtu
                                        Name = $global:resourceProperties.VssName
                                        NumPorts = $global:resourceProperties.NumPorts
                                        NumPortsAvailable = $global:resourceProperties.NumPortsAvailable
                                        Pnic = $global:resourceProperties.Pnic
                                        PortGroup = $global:resourceProperties.Portgroup
                                    }
                                )
                            }
                        }
                    )
                }
            }

            AfterAll {
                $global:resourceProperties.Ensure = 'Present'
            }

            # Arrange
            Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
            Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $networkSystemMock -ModuleName $script:moduleName

            $resource = New-Object -TypeName $script:resourceName -Property $global:resourceProperties

            It 'Should return $false (The VSS exists)' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $false
            }
        }
    }

    Describe 'VMHostVss\Get' -Tag 'Get' {
        BeforeAll {
            $vCenter = [VMware.Vim.VCenter] @{ Name = '10.23.82.112'; User = 'user' }
            $networkSystemMoRef = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostNetworkSystem'; Value = 'NetworkId' }

            $vCenterMock = {
                return [VMware.Vim.VCenter] @{ Name = '10.23.82.112'; User = 'user'}
            }
            $vmHostMock = {
                return [VMware.Vim.VMHost] @{
                    Name = '10.23.82.112'
                    ExtensionData = [VMware.Vim.HostExtensionData] @{
                        ConfigManager = [VMware.Vim.HostConfigManager] @{
                            NetworkSystem = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostNetworkSystem'; Value = 'NetworkId' }
                        }
                    }
                }
            }
            $networkSystemMock = {
                return (
                    [VMware.Vim.HostNetworkSystem] @{
                        NetworkInfo = [VMware.Vim.HostNetworkInfo] @{
                            vswitch = @(
                                [VMware.Vim.HostVirtualSwitch]@{
                                    Key = $global:resourceProperties.Key
                                    Mtu = $global:resourceProperties.Mtu
                                    Name = $global:resourceProperties.VssName
                                    NumPorts = $global:resourceProperties.NumPorts
                                    NumPortsAvailable = $global:resourceProperties.NumPortsAvailable
                                    Pnic = $global:resourceProperties.Pnic
                                    PortGroup = $global:resourceProperties.Portgroup
                                }
                            )
                        }
                    }
                )
            }
        }

        # Arrange
        Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
        Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
        Mock -CommandName Get-View -MockWith $networkSystemMock -ModuleName $script:moduleName

        $resource = New-Object -TypeName $script:resourceName -Property $global:resourceProperties

        It 'Should call the Connect-VIServer mock with the passed server and credentials once' {
            # Act
            $resource.Get()

            # Assert
            Assert-MockCalled -CommandName Connect-VIServer `
                -ParameterFilter { $Server -eq $global:resourceProperties.Server -and $Credential -eq $global:resourceProperties.Credential } `
                -ModuleName $script:moduleName -Exactly 1 -Scope It
        }

        It 'Should call Get-VMHost with the passed server and name once' {
            # Act
            $resource.Get()

            # Assert
            Assert-MockCalled -CommandName Get-VMHost `
                -ParameterFilter { $Server -eq $vCenter -and $Name -eq $global:resourceProperties.Name } `
                -ModuleName $script:moduleName -Exactly 1 -Scope It
        }

        It 'Should call Get-View with the passed server and id once' {
            # Act
            $resource.Get()

            # Assert
            Assert-MockCalled -CommandName Get-View `
                -ParameterFilter { $Server -eq $vCenter -and $Id -eq $networkSystemMoRef } `
                -ModuleName $script:moduleName -Exactly 1 -Scope It
        }

        It 'Should match the properties retrieved from the server' {
            # Act
            $result = $resource.Get()

            # Assert
            $result.Server | Should -Be $global:resourceProperties.Server
            $result.Credential | Should -Be $global:resourceProperties.Credential
            $result.Name | Should -Be $global:resourceProperties.Name
            $result.Ensure | Should -Be $global:resourceProperties.Ensure
            $result.VssName | Should -Be $global:resourceProperties.VssName
            $result.NumPorts | Should -Be $global:resourceProperties.NumPorts
            $result.Mtu | Should -Be $global:resourceProperties.Mtu
            $result.Key | Should -Be $global:resourceProperties.Key
            $result.NumPortsAvailable | Should -Be $global:resourceProperties.NumPortsAvailable
            $result.Pnic | Should -Be $global:resourceProperties.Pnic
            $result.PortGroup | Should -Be $global:resourceProperties.Portgroup
        }
    }
}
Finally {
    # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
    AfterAllTests
}