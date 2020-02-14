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

$script:dscResourceName = 'VMHostDnsSettings'
$script:moduleFolderPath = (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase
$script:integrationTestsFolderPath = Join-Path (Join-Path $moduleFolderPath 'Tests') 'Integration'
$script:configurationFile = "$script:integrationTestsFolderPath\Configurations\$($script:dscResourceName)\$($script:dscResourceName)_Config.ps1"

$script:configWithDhcpDisabled = "$($script:dscResourceName)_WithDhcpDisabled_Config"
$script:configWithoutAddressAndSearchDomain = "$($script:dscResourceName)_WithoutAddressAndSearchDomain_Config"
$script:configWithDhcpEnabled = "$($script:dscResourceName)_WithDhcpEnabled_Config"

$script:connection = Connect-VIServer -Server $Server -User $User -Password $Password
$script:vmHost = $null

$script:dnsConfig = $null
$script:dnsHostName = $null
$script:dnsDomainName = $null
$script:dnsAddress = $null
$script:dnsSearchDomain = $null
$script:dnsDhcp = $null
$script:dnsVirtualNicDevice = $null

$script:hostName = "esx-server1"
$script:domainName = "eng.vmware.com"
$script:address = @("10.23.83.229", "10.23.108.1")
$script:searchDomain = @("eng.vmware.com")
$script:virtualNicDevice = "vmk0"

$script:resourceWithDhcpDisabled = @{
    Name = $Name
    Server = $Server
    HostName = $script:hostName
    DomainName = $script:domainName
    Dhcp = $false
    Address = $script:address
    SearchDomain = $script:searchDomain
}
$script:resourceWithoutAddressAndSearchDomain = @{
    Name = $Name
    Server = $Server
    HostName = $script:hostName
    DomainName = $script:domainName
    Dhcp = $false
}
$script:resourceWithDhcpEnabled = @{
    Name = $Name
    Server = $Server
    HostName = $script:hostName
    DomainName = $script:domainName
    Dhcp = $true
    VirtualNicDevice = $script:virtualNicDevice
}

. $script:configurationFile -Name $Name -Server $Server -User $User -Password $Password

$script:mofFileWithDhcpDisabledPath = "$script:integrationTestsFolderPath\$($script:configWithDhcpDisabled)\"
$script:mofFileWithoutAddressAndSearchDomainPath = "$script:integrationTestsFolderPath\$($script:configWithoutAddressAndSearchDomain)\"
$script:mofFileWithDhcpEnabledPath = "$script:integrationTestsFolderPath\$($script:configWithDhcpEnabled)\"

function Invoke-TestSetup {
    $script:vmHost = Get-VMHost -Server $Server -Name $Name
    $script:dnsConfig = $script:vmHost.ExtensionData.Config.Network.DnsConfig
}

try {
    Describe "$($script:dscResourceName)_Integration" {
        Context "When using configuration $($script:configWithDhcpDisabled)" {
            BeforeAll {
                Invoke-TestSetup

                $script:dnsHostName = $script:dnsConfig.HostName
                $script:dnsDomainName = $script:dnsConfig.DomainName
                $script:dnsAddress = $script:dnsConfig.Address
                $script:dnsSearchDomain = $script:dnsConfig.SearchDomain
            }

            AfterAll {
                $dnsConfig = New-Object VMware.Vim.HostDnsConfig

                $dnsConfig.HostName = $script:dnsHostName
                $dnsConfig.DomainName = $script:dnsDomainName
                $dnsConfig.Address = $script:dnsAddress
                $dnsConfig.SearchDomain = $script:dnsSearchDomain

                $networkSystem = Get-View -Server $Server $script:vmHost.ExtensionData.ConfigManager.NetworkSystem
                $networkSystem.UpdateDnsConfig($dnsConfig)
            }

            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithDhcpDisabledPath
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
                    Path = $script:mofFileWithDhcpDisabledPath
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Act && Assert
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
                $configuration.Name | Should -Be $script:resourceWithDhcpDisabled.Name
                $configuration.Server | Should -Be $script:resourceWithDhcpDisabled.Server
                $configuration.HostName | Should -Be $script:resourceWithDhcpDisabled.HostName
                $configuration.DomainName | Should -Be $script:resourceWithDhcpDisabled.DomainName
                $configuration.Dhcp | Should -Be $false
                $configuration.Address | Should -Be $script:resourceWithDhcpDisabled.Address
                $configuration.SearchDomain | Should -Be $script:resourceWithDhcpDisabled.SearchDomain
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }
        }

        Context "When using configuration $($script:configWithoutAddressAndSearchDomain)" {
            BeforeAll {
                Invoke-TestSetup

                $script:dnsHostName = $script:dnsConfig.HostName
                $script:dnsDomainName = $script:dnsConfig.DomainName
                $script:dnsAddress = $script:dnsConfig.Address
                $script:dnsSearchDomain = $script:dnsConfig.SearchDomain
            }

            AfterAll {
                $dnsConfig = New-Object VMware.Vim.HostDnsConfig

                $dnsConfig.HostName = $script:dnsHostName
                $dnsConfig.DomainName = $script:dnsDomainName
                $dnsConfig.Address = $script:dnsAddress
                $dnsConfig.SearchDomain = $script:dnsSearchDomain

                $networkSystem = Get-View -Server $Server $script:vmHost.ExtensionData.ConfigManager.NetworkSystem
                $networkSystem.UpdateDnsConfig($dnsConfig)
            }

            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithoutAddressAndSearchDomainPath
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
                    Path = $script:mofFileWithoutAddressAndSearchDomainPath
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Act && Assert
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
                $configuration.Name | Should -Be $script:resourceWithoutAddressAndSearchDomain.Name
                $configuration.Server | Should -Be $script:resourceWithoutAddressAndSearchDomain.Server
                $configuration.HostName | Should -Be $script:resourceWithoutAddressAndSearchDomain.HostName
                $configuration.DomainName | Should -Be $script:resourceWithoutAddressAndSearchDomain.DomainName
                $configuration.Dhcp | Should -Be $false
                $configuration.Address | Should -Be $null
                $configuration.SearchDomain | Should -Be $null
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }
        }

        Context "When using configuration $($script:configWithDhcpEnabled)" {
            BeforeAll {
                Invoke-TestSetup

                $script:dnsHostName = $script:dnsConfig.HostName
                $script:dnsDomainName = $script:dnsConfig.DomainName
                $script:dnsDhcp = $script:dnsConfig.Dhcp
                $script:dnsVirtualNicDevice = $script:dnsConfig.VirtualNicDevice
            }

            AfterAll {
                $dnsConfig = New-Object VMware.Vim.HostDnsConfig

                $dnsConfig.HostName = $script:dnsHostName
                $dnsConfig.DomainName = $script:dnsDomainName
                $dnsConfig.Dhcp = $script:dnsDhcp
                $dnsConfig.VirtualNicDevice = $script:dnsVirtualNicDevice

                $networkSystem = Get-View -Server $Server $script:vmHost.ExtensionData.ConfigManager.NetworkSystem
                $networkSystem.UpdateDnsConfig($dnsConfig)
            }

            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithDhcpEnabledPath
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
                    Path = $script:mofFileWithDhcpEnabledPath
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Act && Assert
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
                $configuration.Name | Should -Be $script:resourceWithDhcpEnabled.Name
                $configuration.Server | Should -Be $script:resourceWithDhcpEnabled.Server
                $configuration.HostName | Should -Be $script:resourceWithDhcpEnabled.HostName
                $configuration.DomainName | Should -Be $script:resourceWithDhcpEnabled.DomainName
                $configuration.Dhcp | Should -Be $true
                $configuration.VirtualNicDevice | Should -Be $script:resourceWithDhcpEnabled.VirtualNicDevice
                $configuration.Ipv6VirtualNicDevice | Should -Be ""
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
