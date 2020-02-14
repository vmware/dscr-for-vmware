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

# Retrieves the needed LogHosts from the Server. If there are no LogHosts on the Server, it throws an error.
function Invoke-TestSetup {
    $viServer = Connect-VIServer -Server $Server -User $User -Password $Password
    $vmHost = Get-VMHost -Server $viServer -Name $Name
    $networkSystem = Get-View -Server $viServer -Id $vmHost.ExtensionData.ConfigManager.NetworkSystem
    $dnsAddress = $networkSystem.NetworkConfig.DnsConfig.Address
    if ($dnsAddress.Length -lt 2) {
        throw "The DNS should have at least two configured addresses because they will be used in the Integration Tests for specifying the Remote Hosts for the Syslog config."
    }

    $script:logHostOne = "udp://$($dnsAddress[0]):514"
    $script:logHostTwo = "udp://$($dnsAddress[1]):514"
}

Invoke-TestSetup

$script:dscResourceName = 'VMHostSyslog'
$script:moduleFolderPath = (Get-Module 'VMware.vSphereDSC' -ListAvailable).ModuleBase
$script:integrationTestsFolderPath = Join-Path (Join-Path $moduleFolderPath 'Tests') 'Integration'
$script:configurationFile = "$script:integrationTestsFolderPath\Configurations\$($script:dscResourceName)\$($script:dscResourceName)_Config.ps1"

$script:configWithDefaultSettings = "$($script:dscResourceName)_WithDefaultSettings_Config"
$script:configWithNotDefaultSettings = "$($script:dscResourceName)_WithNotDefaultSettings_Config"

. $script:configurationFile -Name $Name -Server $Server -User $User -Password $Password -LogHostOne $script:logHostOne -LogHostTwo $script:logHostTwo

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
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithDefaultSettings
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Assert
                { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                # Assert
                { Get-DscConfiguration } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration and all the parameters should match' {
                # Arrange && Act
                $configuration = Get-DscConfiguration

                # Assert
                $configuration.Name | Should -Be $Name
                $configuration.Server | Should -Be $Server
                $configuration.LogHost | Should -Be $script:logHostOne
                $configuration.CheckSslCerts = $script:checkSslCerts
                $configuration.DefaultRotate = $script:defaultRotate
                $configuration.DefaultSize = $script:defaultSize
                $configuration.DefaultTimeout = $script:defaultTimeout
                $configuration.Logdir = $script:logdirOne
                $configuration.LogdirUnique = $script:logdirUnique
                $configuration.DropLogRotate = $script:dropLogRotate
                $configuration.DropLogSize = $script:dropLogSize
                $configuration.QueueDropMark = $script:queueDropMark
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
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithNotDefaultSettings
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Assert
                { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                # Assert
                { Get-DscConfiguration } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration and all the parameters should match' {
                # Arrange && Act
                $configuration = Get-DscConfiguration

                # Assert
                $configuration.Name | Should -Be $Name
                $configuration.Server | Should -Be $Server
                $configuration.LogHost | Should -Be $script:logHostTwo
                $configuration.CheckSslCerts = !$script:checkSslCerts
                $configuration.DefaultRotate = $script:defaultRotate + 1
                $configuration.DefaultSize = $script:defaultSize + 1
                $configuration.DefaultTimeout = $script:defaultTimeout + 1
                $configuration.Logdir = $script:logdirTwo
                $configuration.LogdirUnique = !$script:logdirUnique
                $configuration.DropLogRotate = $script:dropLogRotate + 1
                $configuration.DropLogSize = $script:dropLogSize + 1
                $configuration.QueueDropMark = $script:queueDropMark + 1
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
