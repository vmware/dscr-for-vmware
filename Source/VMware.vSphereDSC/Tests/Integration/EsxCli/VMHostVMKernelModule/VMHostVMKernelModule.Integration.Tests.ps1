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

. "$PSScriptRoot\VMHostVMKernelModule.Integration.Tests.Helpers.ps1"
$script:initialVMHostVMKernelModuleState = Get-InitialVMHostVMKernelModuleState

$script:dscResourceName = 'VMHostVMKernelModule'
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
            VMHostVMKernelModuleResourceName = 'VMHostVMKernelModule'
            VMKernelModuleName = $script:initialVMHostVMKernelModuleState.Module
            InitialVMKernelModuleState = $script:initialVMHostVMKernelModuleState.Enabled
            EnableVMKernelModule = $true
            DisableVMKernelModule = $false
            Force = $true
        }
    )
}

$script:configEnableVMKernelModule = "$($script:dscResourceName)_EnableVMKernelModule_Config"
$script:configDisableVMKernelModule = "$($script:dscResourceName)_DisableVMKernelModule_Config"
$script:configModifyVMKernelModuleToInitialState = "$($script:dscResourceName)_ModifyVMKernelModuleToInitialState_Config"

. $script:configurationFile -ErrorAction Stop

$script:mofFileEnableVMKernelModulePath = "$script:integrationTestsFolderPath\$script:configEnableVMKernelModule\"
$script:mofFileDisableVMKernelModulePath = "$script:integrationTestsFolderPath\$script:configDisableVMKernelModule\"
$script:mofFileModifyVMKernelModuleToInitialStatePath = "$script:integrationTestsFolderPath\$script:configModifyVMKernelModuleToInitialState\"

Describe "$($script:dscResourceName)_Integration" {
    Context "When using configuration $script:configEnableVMKernelModule" {
        BeforeAll {
            # Arrange
            & $script:configDisableVMKernelModule `
                -OutputPath $script:mofFileDisableVMKernelModulePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configEnableVMKernelModule `
                -OutputPath $script:mofFileEnableVMKernelModulePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersDisableVMKernelModule = @{
                Path = $script:mofFileDisableVMKernelModulePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersEnableVMKernelModule = @{
                Path = $script:mofFileEnableVMKernelModulePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersDisableVMKernelModule
            Start-DscConfiguration @startDscConfigurationParametersEnableVMKernelModule
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileEnableVMKernelModulePath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configEnableVMKernelModule }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.Name | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.Module | Should -Be $script:configurationData.AllNodes.VMKernelModuleName
            $configuration.Enabled | Should -Be $script:configurationData.AllNodes.EnableVMKernelModule
            $configuration.Force | Should -Be $script:configurationData.AllNodes.Force
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileEnableVMKernelModulePath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configModifyVMKernelModuleToInitialState `
                -OutputPath $script:mofFileModifyVMKernelModuleToInitialStatePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileModifyVMKernelModuleToInitialStatePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileEnableVMKernelModulePath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileDisableVMKernelModulePath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileModifyVMKernelModuleToInitialStatePath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configDisableVMKernelModule" {
        BeforeAll {
            # Arrange
            & $script:configEnableVMKernelModule `
                -OutputPath $script:mofFileEnableVMKernelModulePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configDisableVMKernelModule `
                -OutputPath $script:mofFileDisableVMKernelModulePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersEnableVMKernelModule = @{
                Path = $script:mofFileEnableVMKernelModulePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersDisableVMKernelModule = @{
                Path = $script:mofFileDisableVMKernelModulePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersEnableVMKernelModule
            Start-DscConfiguration @startDscConfigurationParametersDisableVMKernelModule
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileDisableVMKernelModulePath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configDisableVMKernelModule }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.Name | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.Module | Should -Be $script:configurationData.AllNodes.VMKernelModuleName
            $configuration.Enabled | Should -Be $script:configurationData.AllNodes.DisableVMKernelModule
            $configuration.Force | Should -BeNullOrEmpty
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileDisableVMKernelModulePath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configModifyVMKernelModuleToInitialState `
                -OutputPath $script:mofFileModifyVMKernelModuleToInitialStatePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileModifyVMKernelModuleToInitialStatePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileEnableVMKernelModulePath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileDisableVMKernelModulePath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileModifyVMKernelModuleToInitialStatePath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }
}
