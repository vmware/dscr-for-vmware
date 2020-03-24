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
$script:resourceName = 'VMHostDnsSettings'

$user = 'user'
$password = 'password' | ConvertTo-SecureString -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($user, $password)

$script:resourceProperties = @{
    Name = '10.23.82.112'
    Server = '10.23.82.112'
    Credential = $credential
    Dhcp = $false
    DomainName = 'Domain Name'
    HostName = 'Host Name'
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

    Describe 'VMHostDnsSettings\Set' -Tag 'Set' {
        AfterEach {
            $script:resourceProperties.Dhcp = $false
            $script:resourceProperties.VirtualNicDevice = [string]::Empty
        }

        Context 'Invoking with default resource properties' {
            BeforeAll {
                # Arrange
                $viServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ ExtensionData = [VMware.Vim.HostSystem] @{ ConfigManager = [VMware.Vim.HostConfigManager] @{ NetworkSystem `
                         = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostNetworkSystem'; Value = 'networkSystem' } } } }
                }
                $networkSystemMock = {
                    return [VMware.Vim.HostNetworkSystem] @{}
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $networkSystemMock -ModuleName $script:moduleName
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

        Context 'Invoking with Dhcp set to $false' {
            BeforeAll {
                # Arrange
                $viServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                $networkSystemMoRef = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostNetworkSystem'; Value = 'networkSystem' }
                $networkSystemObject = [VMware.Vim.HostNetworkSystem] @{}

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ ExtensionData = [VMware.Vim.HostSystem] @{ ConfigManager = [VMware.Vim.HostConfigManager] @{ NetworkSystem `
                         = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostNetworkSystem'; Value = 'networkSystem' } } } }
                }
                $dnsConfigMock = {
                    return [VMware.Vim.HostDnsConfig] @{ Dhcp = $false; DomainName = 'Domain Name'; HostName = 'Host Name' }
                }
                $networkSystemMock = {
                    return [VMware.Vim.HostNetworkSystem] @{}
                }

                $dnsConfigObject = [VMware.Vim.HostDnsConfig] @{ Dhcp = $false; DomainName = 'Domain Name'; HostName = 'Host Name' }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName New-DNSConfig -MockWith $dnsConfigMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $networkSystemMock -ModuleName $script:moduleName
                Mock -CommandName Update-DNSConfig -MockWith { return $null } -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call New-DNSConfig mock once with the passed parameters' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName New-DNSConfig `
                                  -ParameterFilter { $Dhcp -eq $script:resourceProperties.Dhcp -and $DomainName -eq $script:resourceProperties.DomainName -and `
                                                     $HostName -eq $script:resourceProperties.HostName } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call Get-View mock once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Get-View `
                                  -ParameterFilter { $Server -eq $viServer -and $Id -eq $networkSystemMoRef } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call Update-DNSConfig mock once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Update-DNSConfig `
                                  -ParameterFilter { $NetworkSystem -eq $networkSystemObject -and $DnsConfig -eq $dnsConfigObject } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }
        }

        Context 'Invoking with Dhcp set to $true' {
            BeforeAll {
                # Arrange
                $viServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                $networkSystemMoRef = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostNetworkSystem'; Value = 'networkSystem' }
                $networkSystemObject = [VMware.Vim.HostNetworkSystem] @{}

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ ExtensionData = [VMware.Vim.HostSystem] @{ ConfigManager = [VMware.Vim.HostConfigManager] @{ NetworkSystem `
                         = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostNetworkSystem'; Value = 'networkSystem' } } } }
                }
                $dnsConfigMock = {
                    return [VMware.Vim.HostDnsConfig] @{ Dhcp = $true; DomainName = 'Domain Name'; HostName = 'Host Name'; VirtualNicDevice = 'VirtualNicDevice' }
                }
                $networkSystemMock = {
                    return [VMware.Vim.HostNetworkSystem] @{}
                }

                $script:resourceProperties.Dhcp = $true
                $script:resourceProperties.VirtualNicDevice = 'VirtualNicDevice'

                $dnsConfigObject = [VMware.Vim.HostDnsConfig] @{ Dhcp = $true; DomainName = 'Domain Name'; HostName = 'Host Name'; VirtualNicDevice = 'VirtualNicDevice' }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName New-DNSConfig -MockWith $dnsConfigMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $networkSystemMock -ModuleName $script:moduleName
                Mock -CommandName Update-DNSConfig -MockWith { return $null } -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call New-DNSConfig mock once with the passed parameters' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName New-DNSConfig `
                                  -ParameterFilter { $Dhcp -eq $script:resourceProperties.Dhcp -and $DomainName -eq $script:resourceProperties.DomainName -and `
                                                     $HostName -eq $script:resourceProperties.HostName -and $VirtualNicDevice -eq $script:resourceProperties.VirtualNicDevice } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call Get-View mock once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Get-View `
                                  -ParameterFilter { $Server -eq $viServer -and $Id -eq $networkSystemMoRef } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call Update-DNSConfig mock once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Update-DNSConfig `
                                  -ParameterFilter { $NetworkSystem -eq $networkSystemObject -and $DnsConfig -eq $dnsConfigObject } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }
        }
    }

    Describe 'VMHostDnsSettings\Test' -Tag 'Test' {
        AfterEach {
            $script:resourceProperties.Dhcp = $false
            $script:resourceProperties.VirtualNicDevice = [string]::Empty
            $script:resourceProperties.Address = $null
            $script:resourceProperties.SearchDomain = $null
        }

        Context 'Invoking with default resource properties' {
            BeforeAll {
                # Arrange
                $viServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ ExtensionData = [VMware.Vim.HostSystem] @{ ConfigManager = [VMware.Vim.HostConfigManager] @{ NetworkSystem `
                         = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostNetworkSystem'; Value = 'networkSystem' } } } }
                }
                $networkSystemMock = {
                    return [VMware.Vim.HostNetworkSystem] @{}
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $networkSystemMock -ModuleName $script:moduleName
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

        Context 'Invoking with equal DNS Configs' {
            BeforeAll {
                # Arrange
                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ ExtensionData = [VMware.Vim.HostSystem] @{ Config = [VMware.Vim.HostConfigInfo] @{ Network = [VMware.Vim.HostNetworkInfo] @{ DnsConfig `
                         = [VMware.Vim.HostDnsConfig] @{ Dhcp = $false; DomainName = 'Domain Name'; HostName = 'Host Name'; Address = @('address 1', 'address 2'); SearchDomain = @('search domain 1') } } } } }
                }

                $script:resourceProperties.Address = @('address 2', 'address 1')
                $script:resourceProperties.SearchDomain = @('search domain 1')

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should return $true (The DNS Configs are equal)' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $true
            }
        }

        Context 'Invoking with different DNS Addresses' {
            BeforeAll {
                # Arrange
                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ ExtensionData = [VMware.Vim.HostSystem] @{ Config = [VMware.Vim.HostConfigInfo] @{ Network = [VMware.Vim.HostNetworkInfo] @{ DnsConfig `
                         = [VMware.Vim.HostDnsConfig] @{ Dhcp = $false; DomainName = 'Domain Name'; HostName = 'Host Name'; Address = @('address 1', 'address 2'); SearchDomain = @('search domain 1') } } } } }
                }

                $script:resourceProperties.Address = @('address 1')
                $script:resourceProperties.SearchDomain = @('search domain 1')

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should return $false (The DNS Configs are not equal)' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $false
            }
        }

        Context 'Invoking with different DNS VirtualNicDevice' {
            BeforeAll {
                # Arrange
                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ ExtensionData = [VMware.Vim.HostSystem] @{ Config = [VMware.Vim.HostConfigInfo] @{ Network = [VMware.Vim.HostNetworkInfo] @{ DnsConfig `
                         = [VMware.Vim.HostDnsConfig] @{ Dhcp = $false; DomainName = 'Domain Name'; HostName = 'Host Name'; VirtualNicDevice = 'Fake Virtual Nic Device' } } } } }
                }

                $script:resourceProperties.VirtualNicDevice = "Virtual Nic Device"

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should return $false (The DNS Configs are not equal)' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $false
            }
        }
    }

    Describe 'VMHostDnsSettings\Get' -Tag 'Get' {
        BeforeAll {
            # Arrange
            $viServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }

            $viServerMock = {
                return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
            }
            $vmHostMock = {
                return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Name = '10.23.82.112'; ExtensionData = [VMware.Vim.HostSystem] @{ Config = [VMware.Vim.HostConfigInfo] @{ Network = [VMware.Vim.HostNetworkInfo] @{ DnsConfig `
                     = [VMware.Vim.HostDnsConfig] @{ Dhcp = $false; DomainName = 'Domain Name'; HostName = 'Host Name'; Address = @('address 1', 'address 2'); SearchDomain = @('Search Domain 1'); VirtualNicDevice = 'Virtual Nic Device'; Ipv6VirtualNicDevice = 'Ipv6' } } } } }
            }

            Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
            Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
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
            $result.Dhcp | Should -Be $false
            $result.DomainName | Should -Be 'Domain Name'
            $result.HostName | Should -Be 'Host Name'
            $result.Address | Should -Be @('address 1', 'address 2')
            $result.SearchDomain | Should -Be @('Search Domain 1')
            $result.VirtualNicDevice | Should -Be 'Virtual Nic Device'
            $result.Ipv6VirtualNicDevice | Should -Be 'Ipv6'
        }
    }
}
finally {
    # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
    Invoke-TestCleanup
}
