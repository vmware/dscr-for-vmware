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

$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (ConvertTo-SecureString -String $Password -AsPlainText -Force)

. "$PSScriptRoot\VMHostFirewallRuleset.Integration.Tests.Helpers.ps1"
$script:vmHostFirewallRulesetInitialConfiguration = Get-VMHostFirewallRulesetInitialConfiguration

$script:dscResourceName = 'VMHostFirewallRuleset'
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
            VMHostName = $Name
            VMHostFirewallRulesetResourceName = 'VMHostFirewallRuleset'
            VMHostFirewallRulesetName = $script:vmHostFirewallRulesetInitialConfiguration.RulesetName
            InitialVMHostFirewallRulesetState = $script:vmHostFirewallRulesetInitialConfiguration.RulesetEnabled
            InitialVMHostFirewallRulesetForAllIPs = $script:vmHostFirewallRulesetInitialConfiguration.AllIP
            InitialVMHostFirewallRulesetIPAddressesAndIPNetworksList = $script:vmHostFirewallRulesetInitialConfiguration.IPAddresses
            VMHostFirewallRulesetEnabled = $true
            VMHostFirewallRulesetForAllIPs = $false
            VMHostFirewallRulesetEmptyIPAddressesList = @()
            VMHostFirewallRulesetIPAddressesList = @('192.0.20.10', '192.0.20.11', '192.0.20.12')
            VMHostFirewallRulesetIPNetworksList = @('10.20.120.12/22', '10.20.120.12/23', '10.20.120.12/24')
            VMHostFirewallRulesetIPAddressesAndIPNetworksList = @('192.0.20.10', '192.0.20.11', '192.0.20.12', '10.20.120.12/22', '10.20.120.12/23', '10.20.120.12/24')
        }
    )
}

$script:configEnableVMHostFirewallRuleset = "$($script:dscResourceName)_EnableVMHostFirewallRuleset_Config"
$script:configDisableVMHostFirewallRuleset = "$($script:dscResourceName)_DisableVMHostFirewallRuleset_Config"
$script:configModifyAllowedIPAddressesListOfVMHostFirewallRulesetToEmptyList = "$($script:dscResourceName)_ModifyAllowedIPAddressesListOfVMHostFirewallRulesetToEmptyList_Config"
$script:configModifyAllowedIPAddressesListOfVMHostFirewallRulesetToIPAddressesListOnly = "$($script:dscResourceName)_ModifyAllowedIPAddressesListOfVMHostFirewallRulesetToIPAddressesListOnly_Config"
$script:configModifyAllowedIPAddressesListOfVMHostFirewallRulesetToIPNetworksListOnly = "$($script:dscResourceName)_ModifyAllowedIPAddressesListOfVMHostFirewallRulesetToIPNetworksListOnly_Config"
$script:configModifyAllowedIPAddressesListOfVMHostFirewallRulesetToIPAddressesAndIPNetworksList = "$($script:dscResourceName)_ModifyAllowedIPAddressesListOfVMHostFirewallRulesetToIPAddressesAndIPNetworksList_Config"
$script:configModifyVMHostFirewallRulesetConfigurationToInitialState = "$($script:dscResourceName)_ModifyVMHostFirewallRulesetConfigurationToInitialState_Config"

. $script:configurationFile -ErrorAction Stop

$script:mofFileEnableVMHostFirewallRulesetPath = "$script:integrationTestsFolderPath\$script:configEnableVMHostFirewallRuleset\"
$script:mofFileDisableVMHostFirewallRulesetPath = "$script:integrationTestsFolderPath\$script:configDisableVMHostFirewallRuleset\"
$script:mofFileModifyAllowedIPAddressesListOfVMHostFirewallRulesetToEmptyListPath = "$script:integrationTestsFolderPath\$script:configModifyAllowedIPAddressesListOfVMHostFirewallRulesetToEmptyList\"
$script:mofFileModifyAllowedIPAddressesListOfVMHostFirewallRulesetToIPAddressesListOnlyPath = "$script:integrationTestsFolderPath\$script:configModifyAllowedIPAddressesListOfVMHostFirewallRulesetToIPAddressesListOnly\"
$script:mofFileModifyAllowedIPAddressesListOfVMHostFirewallRulesetToIPNetworksListOnlyPath = "$script:integrationTestsFolderPath\$script:configModifyAllowedIPAddressesListOfVMHostFirewallRulesetToIPNetworksListOnly\"
$script:mofFileModifyAllowedIPAddressesListOfVMHostFirewallRulesetToIPAddressesAndIPNetworksListPath = "$script:integrationTestsFolderPath\$script:configModifyAllowedIPAddressesListOfVMHostFirewallRulesetToIPAddressesAndIPNetworksList\"
$script:mofFileModifyVMHostFirewallRulesetConfigurationToInitialStatePath = "$script:integrationTestsFolderPath\$script:configModifyVMHostFirewallRulesetConfigurationToInitialState\"

Describe "$($script:dscResourceName)_Integration" {
    Context "When using configuration $script:configEnableVMHostFirewallRuleset" {
        BeforeAll {
            # Arrange
            & $script:configEnableVMHostFirewallRuleset `
                -OutputPath $script:mofFileEnableVMHostFirewallRulesetPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileEnableVMHostFirewallRulesetPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileEnableVMHostFirewallRulesetPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configEnableVMHostFirewallRuleset }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.Name | Should -Be $script:configurationData.AllNodes.VMHostFirewallRulesetName
            $configuration.Enabled | Should -Be $script:configurationData.AllNodes.VMHostFirewallRulesetEnabled
            $configuration.AllIP | Should -Be $script:configurationData.AllNodes.InitialVMHostFirewallRulesetForAllIPs
            $configuration.IPAddresses | Should -Be $script:configurationData.AllNodes.InitialVMHostFirewallRulesetIPAddressesAndIPNetworksList
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileEnableVMHostFirewallRulesetPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configModifyVMHostFirewallRulesetConfigurationToInitialState `
                -OutputPath $script:mofFileModifyVMHostFirewallRulesetConfigurationToInitialStatePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileModifyVMHostFirewallRulesetConfigurationToInitialStatePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileEnableVMHostFirewallRulesetPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileModifyVMHostFirewallRulesetConfigurationToInitialStatePath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configDisableVMHostFirewallRuleset" {
        BeforeAll {
            # Arrange
            & $script:configDisableVMHostFirewallRuleset `
                -OutputPath $script:mofFileDisableVMHostFirewallRulesetPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileDisableVMHostFirewallRulesetPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileDisableVMHostFirewallRulesetPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configDisableVMHostFirewallRuleset }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.Name | Should -Be $script:configurationData.AllNodes.VMHostFirewallRulesetName
            $configuration.Enabled | Should -Be (!$script:configurationData.AllNodes.VMHostFirewallRulesetEnabled)
            $configuration.AllIP | Should -Be $script:configurationData.AllNodes.InitialVMHostFirewallRulesetForAllIPs
            $configuration.IPAddresses | Should -Be $script:configurationData.AllNodes.InitialVMHostFirewallRulesetIPAddressesAndIPNetworksList
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileDisableVMHostFirewallRulesetPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configModifyVMHostFirewallRulesetConfigurationToInitialState `
                -OutputPath $script:mofFileModifyVMHostFirewallRulesetConfigurationToInitialStatePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileModifyVMHostFirewallRulesetConfigurationToInitialStatePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileDisableVMHostFirewallRulesetPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileModifyVMHostFirewallRulesetConfigurationToInitialStatePath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configModifyAllowedIPAddressesListOfVMHostFirewallRulesetToEmptyList" {
        BeforeAll {
            # Arrange
            & $script:configModifyAllowedIPAddressesListOfVMHostFirewallRulesetToEmptyList `
                -OutputPath $script:mofFileModifyAllowedIPAddressesListOfVMHostFirewallRulesetToEmptyListPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileModifyAllowedIPAddressesListOfVMHostFirewallRulesetToEmptyListPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileModifyAllowedIPAddressesListOfVMHostFirewallRulesetToEmptyListPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configModifyAllowedIPAddressesListOfVMHostFirewallRulesetToEmptyList }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.Name | Should -Be $script:configurationData.AllNodes.VMHostFirewallRulesetName
            $configuration.Enabled | Should -Be $script:configurationData.AllNodes.InitialVMHostFirewallRulesetState
            $configuration.AllIP | Should -Be $script:configurationData.AllNodes.VMHostFirewallRulesetForAllIPs
            $configuration.IPAddresses | Should -Be $script:configurationData.AllNodes.VMHostFirewallRulesetEmptyIPAddressesList
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileModifyAllowedIPAddressesListOfVMHostFirewallRulesetToEmptyListPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configModifyVMHostFirewallRulesetConfigurationToInitialState `
                -OutputPath $script:mofFileModifyVMHostFirewallRulesetConfigurationToInitialStatePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileModifyVMHostFirewallRulesetConfigurationToInitialStatePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileModifyAllowedIPAddressesListOfVMHostFirewallRulesetToEmptyListPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileModifyVMHostFirewallRulesetConfigurationToInitialStatePath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configModifyAllowedIPAddressesListOfVMHostFirewallRulesetToIPAddressesListOnly" {
        BeforeAll {
            # Arrange
            & $script:configModifyAllowedIPAddressesListOfVMHostFirewallRulesetToIPAddressesListOnly `
                -OutputPath $script:mofFileModifyAllowedIPAddressesListOfVMHostFirewallRulesetToIPAddressesListOnlyPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileModifyAllowedIPAddressesListOfVMHostFirewallRulesetToIPAddressesListOnlyPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileModifyAllowedIPAddressesListOfVMHostFirewallRulesetToIPAddressesListOnlyPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configModifyAllowedIPAddressesListOfVMHostFirewallRulesetToIPAddressesListOnly }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.Name | Should -Be $script:configurationData.AllNodes.VMHostFirewallRulesetName
            $configuration.Enabled | Should -Be $script:configurationData.AllNodes.InitialVMHostFirewallRulesetState
            $configuration.AllIP | Should -Be $script:configurationData.AllNodes.VMHostFirewallRulesetForAllIPs
            $configuration.IPAddresses | Should -Be $script:configurationData.AllNodes.VMHostFirewallRulesetIPAddressesList
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileModifyAllowedIPAddressesListOfVMHostFirewallRulesetToIPAddressesListOnlyPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configModifyVMHostFirewallRulesetConfigurationToInitialState `
                -OutputPath $script:mofFileModifyVMHostFirewallRulesetConfigurationToInitialStatePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileModifyVMHostFirewallRulesetConfigurationToInitialStatePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileModifyAllowedIPAddressesListOfVMHostFirewallRulesetToIPAddressesListOnlyPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileModifyVMHostFirewallRulesetConfigurationToInitialStatePath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configModifyAllowedIPAddressesListOfVMHostFirewallRulesetToIPNetworksListOnly" {
        BeforeAll {
            # Arrange
            & $script:configModifyAllowedIPAddressesListOfVMHostFirewallRulesetToIPNetworksListOnly `
                -OutputPath $script:mofFileModifyAllowedIPAddressesListOfVMHostFirewallRulesetToIPNetworksListOnlyPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileModifyAllowedIPAddressesListOfVMHostFirewallRulesetToIPNetworksListOnlyPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileModifyAllowedIPAddressesListOfVMHostFirewallRulesetToIPNetworksListOnlyPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configModifyAllowedIPAddressesListOfVMHostFirewallRulesetToIPNetworksListOnly }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.Name | Should -Be $script:configurationData.AllNodes.VMHostFirewallRulesetName
            $configuration.Enabled | Should -Be $script:configurationData.AllNodes.InitialVMHostFirewallRulesetState
            $configuration.AllIP | Should -Be $script:configurationData.AllNodes.VMHostFirewallRulesetForAllIPs
            $configuration.IPAddresses | Should -Be $script:configurationData.AllNodes.VMHostFirewallRulesetIPNetworksList
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileModifyAllowedIPAddressesListOfVMHostFirewallRulesetToIPNetworksListOnlyPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configModifyVMHostFirewallRulesetConfigurationToInitialState `
                -OutputPath $script:mofFileModifyVMHostFirewallRulesetConfigurationToInitialStatePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileModifyVMHostFirewallRulesetConfigurationToInitialStatePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileModifyAllowedIPAddressesListOfVMHostFirewallRulesetToIPNetworksListOnlyPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileModifyVMHostFirewallRulesetConfigurationToInitialStatePath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configModifyAllowedIPAddressesListOfVMHostFirewallRulesetToIPAddressesAndIPNetworksList" {
        BeforeAll {
            # Arrange
            & $script:configModifyAllowedIPAddressesListOfVMHostFirewallRulesetToIPAddressesAndIPNetworksList `
                -OutputPath $script:mofFileModifyAllowedIPAddressesListOfVMHostFirewallRulesetToIPAddressesAndIPNetworksListPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileModifyAllowedIPAddressesListOfVMHostFirewallRulesetToIPAddressesAndIPNetworksListPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileModifyAllowedIPAddressesListOfVMHostFirewallRulesetToIPAddressesAndIPNetworksListPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configModifyAllowedIPAddressesListOfVMHostFirewallRulesetToIPAddressesAndIPNetworksList }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.Name | Should -Be $script:configurationData.AllNodes.VMHostFirewallRulesetName
            $configuration.Enabled | Should -Be $script:configurationData.AllNodes.InitialVMHostFirewallRulesetState
            $configuration.AllIP | Should -Be (!$script:configurationData.AllNodes.VMHostFirewallRulesetForAllIPs)
            $configuration.IPAddresses | Should -Be $script:configurationData.AllNodes.VMHostFirewallRulesetIPAddressesAndIPNetworksList
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileModifyAllowedIPAddressesListOfVMHostFirewallRulesetToIPAddressesAndIPNetworksListPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configModifyVMHostFirewallRulesetConfigurationToInitialState `
                -OutputPath $script:mofFileModifyVMHostFirewallRulesetConfigurationToInitialStatePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileModifyVMHostFirewallRulesetConfigurationToInitialStatePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileModifyAllowedIPAddressesListOfVMHostFirewallRulesetToIPAddressesAndIPNetworksListPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileModifyVMHostFirewallRulesetConfigurationToInitialStatePath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }
}
