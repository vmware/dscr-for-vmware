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

. "$PSScriptRoot\VMHostIScsiHbaTarget.Integration.Tests.Helpers.ps1"
$script:vmHostIScsiHba = Get-VMHostIScsiHba

$script:dscResourceName = 'VMHostIScsiHbaTarget'
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
            VMHostIScsiHbaTargetResourceName = 'VMHostIScsiHbaTarget'
            IScsiHbaName = $script:vmHostIScsiHba.Name
            InitialChapType = $script:vmHostIScsiHba.ChapType
            IScsiHbaTargetAddress = '10.23.84.73'
            IScsiHbaTargetPort = 3260
            IScsiHbaSendTargetType = 'Send'
            IScsiHbaStaticTargetType = 'Static'
            IScsiName = $script:vmHostIScsiHba.IScsiName
            InheritChap = $true
            ChapTypeRequired = 'Required'
            ChapTypeProhibited = 'Prohibited'
            ChapName = 'Admin'
            ChapPassword = 'AdminPasswordOne'
            InheritMutualChap = $true
            MutualChapEnabled = $true
            MutualChapName = 'Admin'
            MutualChapPassword = 'AdminPasswordTwo'
        }
    )
}

$script:configConfigureCHAPSettingsOfIScsiHostBusAdapterWithRequiredChapType = "$($script:dscResourceName)_ConfigureCHAPSettingsOfIScsiHostBusAdapterWithRequiredChapType_Config"
$script:configCreateIScsiHostBusAdapterSendTargetWithRequiredChapType = "$($script:dscResourceName)_CreateIScsiHostBusAdapterSendTargetWithRequiredChapType_Config"
$script:configCreateIScsiHostBusAdapterStaticTargetWithInheritedChapSettings = "$($script:dscResourceName)_CreateIScsiHostBusAdapterStaticTargetWithInheritedChapSettings_Config"
$script:configConfigureCHAPSettingsOfIScsiHostBusAdapterSendTargetWithProhibitedChapType = "$($script:dscResourceName)_ConfigureCHAPSettingsOfIScsiHostBusAdapterSendTargetWithProhibitedChapType_Config"
$script:configRemoveIScsiHostBusAdapterSendTarget = "$($script:dscResourceName)_RemoveIScsiHostBusAdapterSendTarget_Config"
$script:configRemoveIScsiHostBusAdapterStaticTarget = "$($script:dscResourceName)_RemoveIScsiHostBusAdapterStaticTarget_Config"
$script:configConfigureCHAPSettingsOfIScsiHostBusAdapterToInitialState = "$($script:dscResourceName)_ConfigureCHAPSettingsOfIScsiHostBusAdapterToInitialState_Config"

. $script:configurationFile -ErrorAction Stop

$script:mofFileConfigureCHAPSettingsOfIScsiHostBusAdapterWithRequiredChapTypePath = "$script:integrationTestsFolderPath\$script:configConfigureCHAPSettingsOfIScsiHostBusAdapterWithRequiredChapType\"
$script:mofFileCreateIScsiHostBusAdapterSendTargetWithRequiredChapTypePath = "$script:integrationTestsFolderPath\$script:configCreateIScsiHostBusAdapterSendTargetWithRequiredChapType\"
$script:mofFileCreateIScsiHostBusAdapterStaticTargetWithInheritedChapSettingsPath = "$script:integrationTestsFolderPath\$script:configCreateIScsiHostBusAdapterStaticTargetWithInheritedChapSettings\"
$script:mofFileConfigureCHAPSettingsOfIScsiHostBusAdapterSendTargetWithProhibitedChapTypePath = "$script:integrationTestsFolderPath\$script:configConfigureCHAPSettingsOfIScsiHostBusAdapterSendTargetWithProhibitedChapType\"
$script:mofFileRemoveIScsiHostBusAdapterSendTargetPath = "$script:integrationTestsFolderPath\$script:configRemoveIScsiHostBusAdapterSendTarget\"
$script:mofFileRemoveIScsiHostBusAdapterStaticTargetPath = "$script:integrationTestsFolderPath\$script:configRemoveIScsiHostBusAdapterStaticTarget\"
$script:mofFileConfigureCHAPSettingsOfIScsiHostBusAdapterToInitialStatePath = "$script:integrationTestsFolderPath\$script:configConfigureCHAPSettingsOfIScsiHostBusAdapterToInitialState\"

Describe "$($script:dscResourceName)_Integration" {
    Context "When using configuration $script:configCreateIScsiHostBusAdapterSendTargetWithRequiredChapType" {
        BeforeAll {
            # Arrange
            & $script:configCreateIScsiHostBusAdapterSendTargetWithRequiredChapType `
                -OutputPath $script:mofFileCreateIScsiHostBusAdapterSendTargetWithRequiredChapTypePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileCreateIScsiHostBusAdapterSendTargetWithRequiredChapTypePath
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
                Path = $script:mofFileCreateIScsiHostBusAdapterSendTargetWithRequiredChapTypePath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configCreateIScsiHostBusAdapterSendTargetWithRequiredChapType }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.Address | Should -Be $script:configurationData.AllNodes.IScsiHbaTargetAddress
            $configuration.Port | Should -Be $script:configurationData.AllNodes.IScsiHbaTargetPort
            $configuration.IScsiHbaName | Should -Be $script:configurationData.AllNodes.IScsiHbaName
            $configuration.TargetType | Should -Be $script:configurationData.AllNodes.IScsiHbaSendTargetType
            $configuration.Ensure | Should -Be 'Present'
            $configuration.IScsiName | Should -BeNullOrEmpty
            $configuration.InheritChap | Should -Be (!$script:configurationData.AllNodes.InheritChap)
            $configuration.ChapType | Should -Be $script:configurationData.AllNodes.ChapTypeRequired
            $configuration.ChapName | Should -Be $script:configurationData.AllNodes.ChapName
            $configuration.ChapPassword | Should -BeNullOrEmpty
            $configuration.InheritMutualChap | Should -Be (!$script:configurationData.AllNodes.InheritMutualChap)
            $configuration.MutualChapEnabled | Should -Be $script:configurationData.AllNodes.MutualChapEnabled
            $configuration.MutualChapName | Should -Be $script:configurationData.AllNodes.MutualChapName
            $configuration.MutualChapPassword | Should -BeNullOrEmpty
            $configuration.Force | Should -BeNull
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileCreateIScsiHostBusAdapterSendTargetWithRequiredChapTypePath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configRemoveIScsiHostBusAdapterSendTarget `
                -OutputPath $script:mofFileRemoveIScsiHostBusAdapterSendTargetPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileRemoveIScsiHostBusAdapterSendTargetPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileCreateIScsiHostBusAdapterSendTargetWithRequiredChapTypePath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveIScsiHostBusAdapterSendTargetPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configCreateIScsiHostBusAdapterStaticTargetWithInheritedChapSettings" {
        BeforeAll {
            # Arrange
            & $script:configConfigureCHAPSettingsOfIScsiHostBusAdapterWithRequiredChapType `
                -OutputPath $script:mofFileConfigureCHAPSettingsOfIScsiHostBusAdapterWithRequiredChapTypePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configCreateIScsiHostBusAdapterStaticTargetWithInheritedChapSettings `
                -OutputPath $script:mofFileCreateIScsiHostBusAdapterStaticTargetWithInheritedChapSettingsPath `
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

            $startDscConfigurationParametersCreateIScsiHostBusAdapterStaticTargetWithInheritedChapSettings = @{
                Path = $script:mofFileCreateIScsiHostBusAdapterStaticTargetWithInheritedChapSettingsPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersConfigureCHAPSettingsOfIScsiHostBusAdapterWithRequiredChapType
            Start-DscConfiguration @startDscConfigurationParametersCreateIScsiHostBusAdapterStaticTargetWithInheritedChapSettings
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileCreateIScsiHostBusAdapterStaticTargetWithInheritedChapSettingsPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configCreateIScsiHostBusAdapterStaticTargetWithInheritedChapSettings }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.Address | Should -Be $script:configurationData.AllNodes.IScsiHbaTargetAddress
            $configuration.Port | Should -Be $script:configurationData.AllNodes.IScsiHbaTargetPort
            $configuration.IScsiHbaName | Should -Be $script:configurationData.AllNodes.IScsiHbaName
            $configuration.TargetType | Should -Be $script:configurationData.AllNodes.IScsiHbaStaticTargetType
            $configuration.Ensure | Should -Be 'Present'
            $configuration.IScsiName | Should -Be $script:configurationData.AllNodes.IScsiName
            $configuration.InheritChap | Should -Be $script:configurationData.AllNodes.InheritChap
            $configuration.ChapType | Should -Be $script:configurationData.AllNodes.ChapTypeRequired
            $configuration.ChapName | Should -Be $script:configurationData.AllNodes.ChapName
            $configuration.ChapPassword | Should -BeNullOrEmpty
            $configuration.InheritMutualChap | Should -Be $script:configurationData.AllNodes.InheritMutualChap
            $configuration.MutualChapEnabled | Should -Be $script:configurationData.AllNodes.MutualChapEnabled
            $configuration.MutualChapName | Should -Be $script:configurationData.AllNodes.MutualChapName
            $configuration.MutualChapPassword | Should -BeNullOrEmpty
            $configuration.Force | Should -BeNull
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileCreateIScsiHostBusAdapterStaticTargetWithInheritedChapSettingsPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configRemoveIScsiHostBusAdapterStaticTarget `
                -OutputPath $script:mofFileRemoveIScsiHostBusAdapterStaticTargetPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configConfigureCHAPSettingsOfIScsiHostBusAdapterToInitialState `
                -OutputPath $script:mofFileConfigureCHAPSettingsOfIScsiHostBusAdapterToInitialStatePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersRemoveIScsiHostBusAdapterStaticTarget = @{
                Path = $script:mofFileRemoveIScsiHostBusAdapterStaticTargetPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersConfigureCHAPSettingsOfIScsiHostBusAdapterToInitialState = @{
                Path = $script:mofFileConfigureCHAPSettingsOfIScsiHostBusAdapterToInitialStatePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersRemoveIScsiHostBusAdapterStaticTarget
            Start-DscConfiguration @startDscConfigurationParametersConfigureCHAPSettingsOfIScsiHostBusAdapterToInitialState

            Remove-Item -Path $script:mofFileConfigureCHAPSettingsOfIScsiHostBusAdapterWithRequiredChapTypePath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileCreateIScsiHostBusAdapterStaticTargetWithInheritedChapSettingsPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveIScsiHostBusAdapterStaticTargetPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileConfigureCHAPSettingsOfIScsiHostBusAdapterToInitialStatePath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configConfigureCHAPSettingsOfIScsiHostBusAdapterSendTargetWithProhibitedChapType" {
        BeforeAll {
            # Arrange
            & $script:configCreateIScsiHostBusAdapterSendTargetWithRequiredChapType `
                -OutputPath $script:mofFileCreateIScsiHostBusAdapterSendTargetWithRequiredChapTypePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configConfigureCHAPSettingsOfIScsiHostBusAdapterSendTargetWithProhibitedChapType `
                -OutputPath $script:mofFileConfigureCHAPSettingsOfIScsiHostBusAdapterSendTargetWithProhibitedChapTypePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersCreateIScsiHostBusAdapterSendTargetWithRequiredChapType = @{
                Path = $script:mofFileCreateIScsiHostBusAdapterSendTargetWithRequiredChapTypePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersConfigureCHAPSettingsOfIScsiHostBusAdapterSendTargetWithProhibitedChapType = @{
                Path = $script:mofFileConfigureCHAPSettingsOfIScsiHostBusAdapterSendTargetWithProhibitedChapTypePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersCreateIScsiHostBusAdapterSendTargetWithRequiredChapType
            Start-DscConfiguration @startDscConfigurationParametersConfigureCHAPSettingsOfIScsiHostBusAdapterSendTargetWithProhibitedChapType
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileConfigureCHAPSettingsOfIScsiHostBusAdapterSendTargetWithProhibitedChapTypePath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configConfigureCHAPSettingsOfIScsiHostBusAdapterSendTargetWithProhibitedChapType }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.Address | Should -Be $script:configurationData.AllNodes.IScsiHbaTargetAddress
            $configuration.Port | Should -Be $script:configurationData.AllNodes.IScsiHbaTargetPort
            $configuration.IScsiHbaName | Should -Be $script:configurationData.AllNodes.IScsiHbaName
            $configuration.TargetType | Should -Be $script:configurationData.AllNodes.IScsiHbaSendTargetType
            $configuration.Ensure | Should -Be 'Present'
            $configuration.IScsiName | Should -BeNullOrEmpty
            $configuration.InheritChap | Should -Be (!$script:configurationData.AllNodes.InheritChap)
            $configuration.ChapType | Should -Be $script:configurationData.AllNodes.ChapTypeProhibited
            $configuration.ChapName | Should -BeNullOrEmpty
            $configuration.ChapPassword | Should -BeNullOrEmpty
            $configuration.InheritMutualChap | Should -Be (!$script:configurationData.AllNodes.InheritMutualChap)
            $configuration.MutualChapEnabled | Should -Be (!$script:configurationData.AllNodes.MutualChapEnabled)
            $configuration.MutualChapName | Should -BeNullOrEmpty
            $configuration.MutualChapPassword | Should -BeNullOrEmpty
            $configuration.Force | Should -BeNull
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileConfigureCHAPSettingsOfIScsiHostBusAdapterSendTargetWithProhibitedChapTypePath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configRemoveIScsiHostBusAdapterSendTarget `
                -OutputPath $script:mofFileRemoveIScsiHostBusAdapterSendTargetPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileRemoveIScsiHostBusAdapterSendTargetPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileCreateIScsiHostBusAdapterSendTargetWithRequiredChapTypePath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileConfigureCHAPSettingsOfIScsiHostBusAdapterSendTargetWithProhibitedChapTypePath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveIScsiHostBusAdapterSendTargetPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configRemoveIScsiHostBusAdapterSendTarget" {
        BeforeAll {
            # Arrange
            & $script:configCreateIScsiHostBusAdapterSendTargetWithRequiredChapType `
                -OutputPath $script:mofFileCreateIScsiHostBusAdapterSendTargetWithRequiredChapTypePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configRemoveIScsiHostBusAdapterSendTarget `
                -OutputPath $script:mofFileRemoveIScsiHostBusAdapterSendTargetPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersCreateIScsiHostBusAdapterSendTargetWithRequiredChapType = @{
                Path = $script:mofFileCreateIScsiHostBusAdapterSendTargetWithRequiredChapTypePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersRemoveIScsiHostBusAdapterSendTarget = @{
                Path = $script:mofFileRemoveIScsiHostBusAdapterSendTargetPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersCreateIScsiHostBusAdapterSendTargetWithRequiredChapType
            Start-DscConfiguration @startDscConfigurationParametersRemoveIScsiHostBusAdapterSendTarget
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileRemoveIScsiHostBusAdapterSendTargetPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configRemoveIScsiHostBusAdapterSendTarget }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.Address | Should -Be $script:configurationData.AllNodes.IScsiHbaTargetAddress
            $configuration.Port | Should -Be $script:configurationData.AllNodes.IScsiHbaTargetPort
            $configuration.IScsiHbaName | Should -Be $script:configurationData.AllNodes.IScsiHbaName
            $configuration.TargetType | Should -Be $script:configurationData.AllNodes.IScsiHbaSendTargetType
            $configuration.Ensure | Should -Be 'Absent'
            $configuration.IScsiName | Should -BeNullOrEmpty
            $configuration.InheritChap | Should -BeNull
            $configuration.ChapType | Should -Be 'Unset'
            $configuration.ChapName | Should -BeNullOrEmpty
            $configuration.ChapPassword | Should -BeNullOrEmpty
            $configuration.InheritMutualChap | Should -BeNull
            $configuration.MutualChapEnabled | Should -BeNull
            $configuration.MutualChapName | Should -BeNullOrEmpty
            $configuration.MutualChapPassword | Should -BeNullOrEmpty
            $configuration.Force | Should -BeNull
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileRemoveIScsiHostBusAdapterSendTargetPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange && Act
            Remove-Item -Path $script:mofFileCreateIScsiHostBusAdapterSendTargetWithRequiredChapTypePath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveIScsiHostBusAdapterSendTargetPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }
}
