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

$script:dscResourceName = 'VMHostNtpSettings'
$script:moduleFolderPath = (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase
$script:integrationTestsFolderPath = Join-Path (Join-Path $moduleFolderPath 'Tests') 'Integration'
$script:configurationFile = "$script:integrationTestsFolderPath\Configurations\$($script:dscResourceName)\$($script:dscResourceName)_Config.ps1"

$script:configWithoutNtpProperties = "$($script:dscResourceName)_WithoutNtpServerAndNtpServicePolicy_Config"
$script:configWithEmptyArrayNtpServer = "$($script:dscResourceName)_WithEmptyArrayNtpServer_Config"
$script:configWithNtpServerAddUseCase = "$($script:dscResourceName)_WithNtpServerAddUseCase_Config"
$script:configWithNtpServerRemoveUseCase = "$($script:dscResourceName)_WithNtpServerRemoveUseCase_Config"
$script:configWithTheSameNtpServicePolicy = "$($script:dscResourceName)_WithTheSameNtpServicePolicy_Config"
$script:configWithNtpServicePolicy = "$($script:dscResourceName)_WithNtpServicePolicy_Config"

$script:connection = Connect-VIServer -Server $Server -User $User -Password $Password
$script:vmHost = $null

$script:ntpConfig = $null
$script:ntpServer = $null
$script:ntpServiceId = "ntpd"
$script:ntpServicePolicy = $null

$script:emptyArrayNtpServer = @()
$script:ntpServerAddUseCase = @("0.bg.pool.ntp.org", "1.bg.pool.ntp.org", "2.bg.pool.ntp.org")
$script:ntpServerRemoveUseCase = @("0.bg.pool.ntp.org", "1.bg.pool.ntp.org")
$script:configurationNtpServicePolicy = "Automatic"

$script:resourceWithoutNtpProperties = @{
    Name = $Name
    Server = $Server
}
$script:resourceWithEmptyArrayNtpServer = @{
    Name = $Name
    Server = $Server
    NtpServer = $script:emptyArrayNtpServer
}
$script:resourceWithNtpServerAddUseCase = @{
    Name = $Name
    Server = $Server
    NtpServer = $script:ntpServerAddUseCase
}
$script:resourceWithNtpServerRemoveUseCase = @{
    Name = $Name
    Server = $Server
    NtpServer = $script:ntpServerRemoveUseCase
}
$script:resourceWithNtpServicePolicy = @{
    Name = $Name
    Server = $Server
    NtpServicePolicy = $script:configurationNtpServicePolicy
}

. $script:configurationFile -Name $Name -Server $Server -User $User -Password $Password

$script:mofFileWithoutNtpServerAndNtpServicePolicyPath = "$script:integrationTestsFolderPath\$($script:configWithoutNtpProperties)\"
$script:mofFileWithEmptyArrayNtpServerPath = "$script:integrationTestsFolderPath\$($script:configWithEmptyArrayNtpServer)\"
$script:mofFileWithNtpServerAddUseCasePath = "$script:integrationTestsFolderPath\$($script:configWithNtpServerAddUseCase)\"
$script:mofFileWithNtpServerRemoveUseCasePath = "$script:integrationTestsFolderPath\$($script:configWithNtpServerRemoveUseCase)\"
$script:mofFileWithTheSameNtpServicePolicyPath = "$script:integrationTestsFolderPath\$($script:configWithTheSameNtpServicePolicy)\"
$script:mofFileWithNtpServicePolicyPath = "$script:integrationTestsFolderPath\$($script:configWithNtpServicePolicy)\"

function Invoke-TestSetup {
    $script:vmHost = Get-VMHost -Server $script:connection -Name $script:resourceWithoutNtpProperties.Name
    $script:ntpConfig = $script:vmHost.ExtensionData.Config.DateTimeInfo.NtpConfig
    $script:ntpServer = $script:ntpConfig.Server

    $vmHostService = $script:vmHost.ExtensionData.Config.Service
    $vmHostNtpService = $vmHostService.Service | Where-Object { $_.Key -eq $script:ntpServiceId }
    $script:ntpServicePolicy = $vmHostNtpService.Policy
}

function Invoke-TestCleanup {
    $script:vmHost = Get-VMHost -Server $script:connection -Name $script:resourceWithoutNtpProperties.Name

    $dateTimeConfig = New-Object VMware.Vim.HostDateTimeConfig
    $dateTimeConfig.NtpConfig = New-Object VMware.Vim.HostNtpConfig
    $dateTimeConfig.NtpConfig.Server = $script:ntpServer

    $dateTimeSystem = Get-View -Server $script:connection $script:vmHost.ExtensionData.ConfigManager.DateTimeSystem
    $dateTimeSystem.UpdateDateTimeConfig($dateTimeConfig)

    $serviceSystem = Get-View -Server $script:connection $script:vmHost.ExtensionData.ConfigManager.ServiceSystem
    $serviceSystem.UpdateServicePolicy($script:ntpServiceId, $script:ntpServicePolicy)
}

try {
    Describe "$($script:dscResourceName)_Integration" {
        Context "When using configuration $($script:configWithoutNtpProperties)" {
            BeforeAll {
                Invoke-TestSetup
            }

            AfterAll {
                Invoke-TestCleanup
            }

            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithoutNtpServerAndNtpServicePolicyPath
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
                    Path = $script:mofFileWithoutNtpServerAndNtpServicePolicyPath
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
                $configuration.Name | Should -Be $script:resourceWithoutNtpProperties.Name
                $configuration.Server | Should -Be $script:resourceWithoutNtpProperties.Server
                $configuration.NtpServer | Should -Be $script:ntpServer
                $configuration.NtpServicePolicy | Should -Be $script:ntpServicePolicy
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }
        }

        Context "When using configuration $($script:configWithEmptyArrayNtpServer)" {
            BeforeAll {
                Invoke-TestSetup
            }

            AfterAll {
                Invoke-TestCleanup
            }

            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithEmptyArrayNtpServerPath
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
                    Path = $script:mofFileWithEmptyArrayNtpServerPath
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
                $configuration.Name | Should -Be $script:resourceWithEmptyArrayNtpServer.Name
                $configuration.Server | Should -Be $script:resourceWithEmptyArrayNtpServer.Server
                $configuration.NtpServer | Should -Be $script:resourceWithEmptyArrayNtpServer.NtpServer
                $configuration.NtpServicePolicy | Should -Be $script:ntpServicePolicy
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }
        }

        Context "When using configuration $($script:configWithNtpServerAddUseCase)" {
            BeforeAll {
                Invoke-TestSetup
            }

            AfterAll {
                Invoke-TestCleanup
            }

            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithNtpServerAddUseCasePath
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
                    Path = $script:mofFileWithNtpServerAddUseCasePath
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
                $configuration.Name | Should -Be $script:resourceWithNtpServerAddUseCase.Name
                $configuration.Server | Should -Be $script:resourceWithNtpServerAddUseCase.Server
                $configuration.NtpServer | Should -Be $script:resourceWithNtpServerAddUseCase.NtpServer
                $configuration.NtpServicePolicy | Should -Be $script:ntpServicePolicy
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }
        }

        Context "When using configuration $($script:configWithNtpServerRemoveUseCase)" {
            BeforeAll {
                Invoke-TestSetup
            }

            AfterAll {
                Invoke-TestCleanup
            }

            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithNtpServerRemoveUseCasePath
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
                    Path = $script:mofFileWithNtpServerRemoveUseCasePath
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
                $configuration.Name | Should -Be $script:resourceWithNtpServerRemoveUseCase.Name
                $configuration.Server | Should -Be $script:resourceWithNtpServerRemoveUseCase.Server
                $configuration.NtpServer | Should -Be $script:resourceWithNtpServerRemoveUseCase.NtpServer
                $configuration.NtpServicePolicy | Should -Be $script:ntpServicePolicy
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }
        }

        Context "When using configuration $($script:configWithTheSameNtpServicePolicy)" {
            BeforeAll {
                Invoke-TestSetup
            }

            AfterAll {
                Invoke-TestCleanup
            }

            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithTheSameNtpServicePolicyPath
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
                    Path = $script:mofFileWithTheSameNtpServicePolicyPath
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
                $configuration.Name | Should -Be $Name
                $configuration.Server | Should -Be $Server
                $configuration.NtpServer | Should -Be $script:ntpServer
                $configuration.NtpServicePolicy | Should -Be $script:ntpServicePolicy
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }
        }

        Context "When using configuration $($script:configWithNtpServicePolicy)" {
            BeforeAll {
                Invoke-TestSetup
            }

            AfterAll {
                Invoke-TestCleanup
            }

            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithNtpServicePolicyPath
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
                    Path = $script:mofFileWithNtpServicePolicyPath
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
                $configuration.Name | Should -Be $script:resourceWithNtpServicePolicy.Name
                $configuration.Server | Should -Be $script:resourceWithNtpServicePolicy.Server
                $configuration.NtpServer | Should -Be $script:ntpServer
                $configuration.NtpServicePolicy | Should -Be $script:resourceWithNtpServicePolicy.NtpServicePolicy
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
