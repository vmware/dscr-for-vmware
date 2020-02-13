<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

Param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Server,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $User,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Password,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Name
)

<#
Retrieves one Physical Network Adapter from the specified VMHost.
If there are no Physical Network Adapters on the VMHost, it throws an exception.
#>
function Invoke-TestSetup {
    $viServer = Connect-VIServer -Server $Server -User $User -Password $Password -ErrorAction Stop
    $vmHost = Get-VMHost -Server $viServer -Name $Name -ErrorAction Stop
    $physicalNetworkAdapter = Get-VMHostNetworkAdapter -Server $viServer -VMHost $vmHost -Physical -ErrorAction Stop | Select-Object -First 1

    if ($null -eq $physicalNetworkAdapter) {
        throw "No Physical Network Adapters available on the VMHost and the Integration Tests require at least 1 Physical Network Adapter to be available on the ESXi node."
    }

    $script:physicalNic = $physicalNetworkAdapter.Name
}

Invoke-TestSetup

$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (ConvertTo-SecureString -String $Password -AsPlainText -Force)

$script:dscResourceName = 'VMHostPhysicalNic'
$script:moduleFolderPath = (Get-Module -Name 'VMware.vSphereDSC' -ListAvailable).ModuleBase
$script:integrationTestsFolderPath = Join-Path -Path (Join-Path -Path $moduleFolderPath -ChildPath 'Tests') -ChildPath 'Integration'
$script:configurationFile = "$script:integrationTestsFolderPath\Configurations\$script:dscResourceName\$($script:dscResourceName)_Config.ps1"

$script:configurationData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
            Server = $Server
            Credential = $Credential
            Name = $Name
            PhysicalNetworkAdapterResourceName = 'VMHostPhysicalNetworkAdapter'
            PhysicalNetworkAdapter = $script:physicalNic
            FullDuplex = 'Full'
            HalfDuplex = 'Half'
            FullDuplexBitRatePerSecMb = 100
            HalfDuplexBitRatePerSecMb = 10
            DefaultBitRatePerSecMb = 1000
            AutoNegotiate = $true
        }
    )
}

$script:configWhenSpeedAndDuplexSettingsAreConfiguredAutomatically = "$($script:dscResourceName)_WhenSpeedAndDuplexSettingsAreConfiguredAutomatically_Config"
$script:configWhenAutoNegotiateIsNotSpecified = "$($script:dscResourceName)_WhenAutoNegotiateIsNotSpecified_Config"
$script:configWhenAutoNegotiateIsSetToFalse = "$($script:dscResourceName)_WhenAutoNegotiateIsSetToFalse_Config"
$script:configWhenAutoNegotiateIsSetToTrue = "$($script:dscResourceName)_WhenAutoNegotiateIsSetToTrue_Config"

. $script:configurationFile -ErrorAction Stop

$script:mofFileWhenSpeedAndDuplexSettingsAreConfiguredAutomaticallyPath = "$script:integrationTestsFolderPath\$script:configWhenSpeedAndDuplexSettingsAreConfiguredAutomatically\"
$script:mofFileWhenAutoNegotiateIsNotSpecifiedPath = "$script:integrationTestsFolderPath\$script:configWhenAutoNegotiateIsNotSpecified\"
$script:mofFileWhenAutoNegotiateIsSetToFalsePath = "$script:integrationTestsFolderPath\$script:configWhenAutoNegotiateIsSetToFalse\"
$script:mofFileWhenAutoNegotiateIsSetToTruePath = "$script:integrationTestsFolderPath\$script:configWhenAutoNegotiateIsSetToTrue\"

try {
    Describe "$($script:dscResourceName)_Integration" {
        Context "When using configuration $script:configWhenAutoNegotiateIsNotSpecified" {
            BeforeAll {
                # Arrange
                & $script:configWhenAutoNegotiateIsNotSpecified `
                    -OutputPath $script:mofFileWhenAutoNegotiateIsNotSpecifiedPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenAutoNegotiateIsNotSpecifiedPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters
                Start-Sleep -Seconds 15
            }

            It 'Should apply the MOF without throwing' {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenAutoNegotiateIsNotSpecifiedPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act && Assert
                { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                # Arrange && Act && Assert
                { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration and all parameters should match' {
                # Arrange && Act
                $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configWhenAutoNegotiateIsNotSpecified }

                # Assert
                $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
                $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.Name
                $configuration.Name | Should -Be $script:configurationData.AllNodes.PhysicalNetworkAdapter
                $configuration.Duplex | Should -Be $script:configurationData.AllNodes.FullDuplex
                $configuration.BitRatePerSecMb | Should -Be $script:configurationData.AllNodes.FullDuplexBitRatePerSecMb
                $configuration.AutoNegotiate | Should -BeNullOrEmpty
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange
                $testDscConfigurationParameters = @{
                    ReferenceConfiguration = "$script:mofFileWhenAutoNegotiateIsNotSpecifiedPath\$($script:configurationData.AllNodes.NodeName).mof"
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act && Assert
                (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
            }

            AfterAll {
                # Arrange
                & $script:configWhenSpeedAndDuplexSettingsAreConfiguredAutomatically `
                    -OutputPath $script:mofFileWhenSpeedAndDuplexSettingsAreConfiguredAutomaticallyPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenSpeedAndDuplexSettingsAreConfiguredAutomaticallyPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters
                Start-Sleep -Seconds 15

                Remove-Item -Path $script:mofFileWhenAutoNegotiateIsNotSpecifiedPath -Recurse -Confirm:$false -ErrorAction Stop
                Remove-Item -Path $script:mofFileWhenSpeedAndDuplexSettingsAreConfiguredAutomaticallyPath -Recurse -Confirm:$false -ErrorAction Stop
            }
        }

        Context "When using configuration $script:configWhenAutoNegotiateIsSetToFalse" {
            BeforeAll {
                # Arrange
                & $script:configWhenAutoNegotiateIsSetToFalse `
                    -OutputPath $script:mofFileWhenAutoNegotiateIsSetToFalsePath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenAutoNegotiateIsSetToFalsePath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters
                Start-Sleep -Seconds 15
            }

            It 'Should apply the MOF without throwing' {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenAutoNegotiateIsSetToFalsePath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act && Assert
                { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                # Arrange && Act && Assert
                { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration and all parameters should match' {
                # Arrange && Act
                $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configWhenAutoNegotiateIsSetToFalse }

                # Assert
                $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
                $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.Name
                $configuration.Name | Should -Be $script:configurationData.AllNodes.PhysicalNetworkAdapter
                $configuration.Duplex | Should -Be $script:configurationData.AllNodes.HalfDuplex
                $configuration.BitRatePerSecMb | Should -Be $script:configurationData.AllNodes.HalfDuplexBitRatePerSecMb
                $configuration.AutoNegotiate | Should -Be $false
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange
                $testDscConfigurationParameters = @{
                    ReferenceConfiguration = "$script:mofFileWhenAutoNegotiateIsSetToFalsePath\$($script:configurationData.AllNodes.NodeName).mof"
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act && Assert
                (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
            }

            AfterAll {
                # Arrange
                & $script:configWhenSpeedAndDuplexSettingsAreConfiguredAutomatically `
                    -OutputPath $script:mofFileWhenSpeedAndDuplexSettingsAreConfiguredAutomaticallyPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenSpeedAndDuplexSettingsAreConfiguredAutomaticallyPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters
                Start-Sleep -Seconds 15

                Remove-Item -Path $script:mofFileWhenAutoNegotiateIsSetToFalsePath -Recurse -Confirm:$false -ErrorAction Stop
                Remove-Item -Path $script:mofFileWhenSpeedAndDuplexSettingsAreConfiguredAutomaticallyPath -Recurse -Confirm:$false -ErrorAction Stop
            }
        }

        Context "When using configuration $script:configWhenAutoNegotiateIsSetToTrue" {
            BeforeAll {
                # Arrange
                & $script:configWhenAutoNegotiateIsSetToTrue `
                    -OutputPath $script:mofFileWhenAutoNegotiateIsSetToTruePath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenAutoNegotiateIsSetToTruePath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters
                Start-Sleep -Seconds 15
            }

            It 'Should apply the MOF without throwing' {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenAutoNegotiateIsSetToTruePath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act && Assert
                { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                # Arrange && Act && Assert
                { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration and all parameters should match' {
                # Arrange && Act
                $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configWhenAutoNegotiateIsSetToTrue }

                # Assert
                $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
                $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.Name
                $configuration.Name | Should -Be $script:configurationData.AllNodes.PhysicalNetworkAdapter
                $configuration.Duplex | Should -Be $script:configurationData.AllNodes.FullDuplex
                $configuration.BitRatePerSecMb | Should -Be $script:configurationData.AllNodes.DefaultBitRatePerSecMb
                $configuration.AutoNegotiate | Should -Be $script:configurationData.AllNodes.AutoNegotiate
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange
                $testDscConfigurationParameters = @{
                    ReferenceConfiguration = "$script:mofFileWhenAutoNegotiateIsSetToTruePath\$($script:configurationData.AllNodes.NodeName).mof"
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act && Assert
                (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
            }

            AfterAll {
                # Arrange
                & $script:configWhenSpeedAndDuplexSettingsAreConfiguredAutomatically `
                    -OutputPath $script:mofFileWhenSpeedAndDuplexSettingsAreConfiguredAutomaticallyPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenSpeedAndDuplexSettingsAreConfiguredAutomaticallyPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters
                Start-Sleep -Seconds 15

                Remove-Item -Path $script:mofFileWhenAutoNegotiateIsSetToTruePath -Recurse -Confirm:$false -ErrorAction Stop
                Remove-Item -Path $script:mofFileWhenSpeedAndDuplexSettingsAreConfiguredAutomaticallyPath -Recurse -Confirm:$false -ErrorAction Stop
            }
        }
    }
}
finally {
    Disconnect-VIServer -Server $Server -Confirm:$false
}
