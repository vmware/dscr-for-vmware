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

. "$PSScriptRoot\VMHostIScsiHba.Integration.Tests.Helpers.ps1"
$script:vmHostIScsiHba = Get-VMHostIScsiHba

$script:dscResourceName = 'VMHostIScsiHba'
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
            VMHostIScsiHbaResourceName = 'VMHostIScsiHba'
            IScsiHbaName = $script:vmHostIScsiHba.Name
            InitialChapType = $script:vmHostIScsiHba.ChapType
            ChapTypeRequired = 'Required'
            ChapTypeProhibited = 'Prohibited'
            ChapName = 'Admin'
            ChapPassword = 'AdminPasswordOne'
            MutualChapEnabled = $true
            MutualChapName = 'Admin'
            MutualChapPassword = 'AdminPasswordTwo'
        }
    )
}

$script:configConfigureCHAPSettingsOfIScsiHostBusAdapterWithRequiredChapType = "$($script:dscResourceName)_ConfigureCHAPSettingsOfIScsiHostBusAdapterWithRequiredChapType_Config"
$script:configConfigureCHAPSettingsOfIScsiHostBusAdapterWithProhibitedChapTypeAndDisabledMutualChap = "$($script:dscResourceName)_ConfigureCHAPSettingsOfIScsiHostBusAdapterWithProhibitedChapTypeAndDisabledMutualChap_Config"
$script:configConfigureCHAPSettingsOfIScsiHostBusAdapterToInitialState = "$($script:dscResourceName)_ConfigureCHAPSettingsOfIScsiHostBusAdapterToInitialState_Config"

. $script:configurationFile -ErrorAction Stop

$script:mofFileConfigureCHAPSettingsOfIScsiHostBusAdapterWithRequiredChapTypePath = "$script:integrationTestsFolderPath\$script:configConfigureCHAPSettingsOfIScsiHostBusAdapterWithRequiredChapType\"
$script:mofFileConfigureCHAPSettingsOfIScsiHostBusAdapterWithProhibitedChapTypeAndDisabledMutualChapPath = "$script:integrationTestsFolderPath\$script:configConfigureCHAPSettingsOfIScsiHostBusAdapterWithProhibitedChapTypeAndDisabledMutualChap\"
$script:mofFileConfigureCHAPSettingsOfIScsiHostBusAdapterToInitialStatePath = "$script:integrationTestsFolderPath\$script:configConfigureCHAPSettingsOfIScsiHostBusAdapterToInitialState\"

Describe "$($script:dscResourceName)_Integration" {
    Context "When using configuration $script:configConfigureCHAPSettingsOfIScsiHostBusAdapterWithRequiredChapType" {
        BeforeAll {
            # Arrange
            & $script:configConfigureCHAPSettingsOfIScsiHostBusAdapterWithRequiredChapType `
                -OutputPath $script:mofFileConfigureCHAPSettingsOfIScsiHostBusAdapterWithRequiredChapTypePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileConfigureCHAPSettingsOfIScsiHostBusAdapterWithRequiredChapTypePath
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
                Path = $script:mofFileConfigureCHAPSettingsOfIScsiHostBusAdapterWithRequiredChapTypePath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configConfigureCHAPSettingsOfIScsiHostBusAdapterWithRequiredChapType }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.Name | Should -Be $script:configurationData.AllNodes.IScsiHbaName
            $configuration.ChapType | Should -Be $script:configurationData.AllNodes.ChapTypeRequired
            $configuration.ChapName | Should -Be $script:configurationData.AllNodes.ChapName
            $configuration.ChapPassword | Should -BeNullOrEmpty
            $configuration.MutualChapEnabled | Should -Be $script:configurationData.AllNodes.MutualChapEnabled
            $configuration.MutualChapName | Should -Be $script:configurationData.AllNodes.MutualChapName
            $configuration.MutualChapPassword | Should -BeNullOrEmpty
            $configuration.Force | Should -BeNull
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileConfigureCHAPSettingsOfIScsiHostBusAdapterWithRequiredChapTypePath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configConfigureCHAPSettingsOfIScsiHostBusAdapterToInitialState `
                -OutputPath $script:mofFileConfigureCHAPSettingsOfIScsiHostBusAdapterToInitialStatePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileConfigureCHAPSettingsOfIScsiHostBusAdapterToInitialStatePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileConfigureCHAPSettingsOfIScsiHostBusAdapterWithRequiredChapTypePath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileConfigureCHAPSettingsOfIScsiHostBusAdapterToInitialStatePath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configConfigureCHAPSettingsOfIScsiHostBusAdapterWithProhibitedChapTypeAndDisabledMutualChap" {
        BeforeAll {
            # Arrange
            & $script:configConfigureCHAPSettingsOfIScsiHostBusAdapterWithRequiredChapType `
                -OutputPath $script:mofFileConfigureCHAPSettingsOfIScsiHostBusAdapterWithRequiredChapTypePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configConfigureCHAPSettingsOfIScsiHostBusAdapterWithProhibitedChapTypeAndDisabledMutualChap `
                -OutputPath $script:mofFileConfigureCHAPSettingsOfIScsiHostBusAdapterWithProhibitedChapTypeAndDisabledMutualChapPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersConfigureCHAPSettingsOfIScsiHostBusAdapterWithRequiredChapType = @{
                Path = $script:mofFileConfigureCHAPSettingsOfIScsiHostBusAdapterWithRequiredChapTypePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersConfigureCHAPSettingsOfIScsiHostBusAdapterWithProhibitedChapTypeAndDisabledMutualChap = @{
                Path = $script:mofFileConfigureCHAPSettingsOfIScsiHostBusAdapterWithProhibitedChapTypeAndDisabledMutualChapPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersConfigureCHAPSettingsOfIScsiHostBusAdapterWithRequiredChapType
            Start-DscConfiguration @startDscConfigurationParametersConfigureCHAPSettingsOfIScsiHostBusAdapterWithProhibitedChapTypeAndDisabledMutualChap
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileConfigureCHAPSettingsOfIScsiHostBusAdapterWithProhibitedChapTypeAndDisabledMutualChapPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configConfigureCHAPSettingsOfIScsiHostBusAdapterWithProhibitedChapTypeAndDisabledMutualChap }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.Name | Should -Be $script:configurationData.AllNodes.IScsiHbaName
            $configuration.ChapType | Should -Be $script:configurationData.AllNodes.ChapTypeProhibited
            $configuration.ChapName | Should -BeNullOrEmpty
            $configuration.ChapPassword | Should -BeNullOrEmpty
            $configuration.MutualChapEnabled | Should -Be (!$script:configurationData.AllNodes.MutualChapEnabled)
            $configuration.MutualChapName | Should -BeNullOrEmpty
            $configuration.MutualChapPassword | Should -BeNullOrEmpty
            $configuration.Force | Should -BeNull
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileConfigureCHAPSettingsOfIScsiHostBusAdapterWithProhibitedChapTypeAndDisabledMutualChapPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange && Act
            Remove-Item -Path $script:mofFileConfigureCHAPSettingsOfIScsiHostBusAdapterWithRequiredChapTypePath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileConfigureCHAPSettingsOfIScsiHostBusAdapterWithProhibitedChapTypeAndDisabledMutualChapPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }
}
