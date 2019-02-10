<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

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

$script:dscResourceName = 'VMHostSyslog'
$script:dscConfig = $null
$script:moduleFolderPath = (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase
$script:integrationTestsFolderPath = Join-Path (Join-Path $moduleFolderPath 'Tests') 'Integration'
$script:configurationFile = "$script:integrationTestsFolderPath\Configurations\$($script:dscResourceName)\$($script:dscResourceName)_Config.ps1"

$script:configWithDefaultSettings = "$($script:dscResourceName)_WithDefaultSettings_Config"
$script:configWithNotDefaultSettings = "$($script:dscResourceName)_WithNotDefaultSettings_Config"

$script:connection = Connect-VIServer -Server $Server -User $User -Password $Password
$script:vmHost = $null

$script:LogHost = 'udp://vli.eng.vmware.com:516'
$script:LogHost2 = 'udp://vli2.eng.vmware.com:516'
$script:CheckSslCerts = $true
$script:DefaultRotate = 10
$script:DefaultSize = 100
$script:DefaultTimeout = 180
$script:DropLogRotate = 10
$script:DropLogSize = 100
$script:Logdir = '/scratch/log'
$script:Logdir2 = '/scratch/log2'
$script:LogdirUnique = $false
$script:QueueDropMark = 90

$script:resource_WithDefaultSettings = @{
    Name = $Name
    Server = $Server
    LogHost = $script:LogHost
    CheckSslCerts = $script:CheckSslCerts
    DefaultRotate = $script:DefaultRotate
    DefaultSize = $script:DefaultSize
    DefaultTimeout = $script:DefaultTimeout
    DropLogRotate = $script:DropLogRotate
    DropLogSize = $script:DropLogSize
    Logdir = $script:Logdir
    LogdirUnique = $script:LogdirUnique
    QueueDropMark = $script:QueueDropMark
}
$script:resource_WithNotDefaultSettings = @{
    Name = $Name
    Server = $Server
    LogHost = $script:LogHost1
    CheckSslCerts = -not $script:CheckSslCerts
    DefaultRotate = $script:DefaultRotate + 1
    DefaultSize = $script:DefaultSize + 1
    DefaultTimeout = $script:DefaultTimeout + 1
    DropLogRotate = $script:DropLogRotate + 1
    DropLogSize = $script:DropLogSize + 1
    Logdir = $script:Logdir2
    LogdirUnique = -not $script:LogdirUnique
    QueueDropMark = $script:QueueDropMark + 1
}

. $script:configurationFile -Name $Name -Server $Server -User $User -Password $Password

$script:mofFileWithDefaultSettings = "$script:integrationTestsFolderPath\$($script:configWithDefaultSettings)\"
$script:mofFileWithNotDefaultSettings = "$script:integrationTestsFolderPath\$($script:configWithNotDefaultSettings)\"

try {
    Describe "$($script:dscResourceName)_Integration" {
        Context "When using configuration $($script:configWithDefaultSettings)" {
            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithDefaultSettings
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters
            }

            It 'Should compile and apply the MOF without throwing' {
                # Assert
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithDefaultSettings
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }
                Start-DscConfiguration @startDscConfigurationParameters | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                # Assert
                { Get-DscConfiguration } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration and all the parameters should match' {
                # Arrange && Act
                $configuration = Get-DscConfiguration

                # Assert
                $configuration.Name | Should -Be $script:resourceProperties.Name
                $configuration.Server | Should -Be $script:resourceProperties.Server
                $configuration.LogHost | Should -Be $script:resource_WithDefaultSettings.LogHost
                $configuration.CheckSslCerts = $script:resource_WithDefaultSettings.CheckSslCerts
                $configuration.DefaultRotate = $script:resource_WithDefaultSettings.DefaultRotate
                $configuration.DefaultSize = $script:resource_WithDefaultSettings.DefaultSize
                $configuration.DefaultTimeout = $script:resource_WithDefaultSettings.DefaultTimeout
                $configuration.DropLogRotate = $script:resource_WithDefaultSettings.DropLogRotate
                $configuration.DropLogSize = $script:resource_WithDefaultSettings.DropLogSize
                $configuration.Logdir = $script:resource_WithDefaultSettings.Logdir
                $configuration.LogdirUnique = $script:resource_WithDefaultSettings.LogdirUnique
                $configuration.QueueDropMark = $script:resource_WithDefaultSettings.QueueDropMark
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }
        }

        Context "When using configuration $($script:configWithNotDefaultSettings)" {
            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithNotDefaultSettings
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters
            }

            It 'Should compile and apply the MOF without throwing' {
                # Assert
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithNotDefaultSettings
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }
                Start-DscConfiguration @startDscConfigurationParameters | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                # Assert
                { Get-DscConfiguration } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration and all the parameters should match' {
                # Arrange && Act
                $configuration = Get-DscConfiguration

                # Assert
                $configuration.Name | Should -Be $script:resourceProperties.Name
                $configuration.Server | Should -Be $script:resourceProperties.Server
                $configuration.LogHost | Should -Be $script:resource_WithNotDefaultSettings.LogHost
                $configuration.CheckSslCerts = $script:resource_WithNotDefaultSettings.CheckSslCerts
                $configuration.DefaultRotate = $script:resource_WithNotDefaultSettings.DefaultRotate
                $configuration.DefaultSize = $script:resource_WithNotDefaultSettings.DefaultSize
                $configuration.DefaultTimeout = $script:resource_WithNotDefaultSettings.DefaultTimeout
                $configuration.DropLogRotate = $script:resource_WithNotDefaultSettings.DropLogRotate
                $configuration.DropLogSize = $script:resource_WithNotDefaultSettings.DropLogSize
                $configuration.Logdir = $script:resource_WithNotDefaultSettings.Logdir
                $configuration.LogdirUnique = $script:resource_WithNotDefaultSettings.LogdirUnique
                $configuration.QueueDropMark = $script:resource_WithNotDefaultSettings.QueueDropMark
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