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

. "$PSScriptRoot\VMHostScsiLun.Integration.Tests.Helpers.ps1"
$script:vmHostScsiLunInitialConfiguration = Get-VMHostScsiLunInitialConfiguration

$script:dscResourceName = 'VMHostScsiLun'
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
            VMHostScsiLunResourceName = 'VMHostScsiLun'
            ScsiLunCanonicalName = $script:vmHostScsiLunInitialConfiguration.ScsiLunCanonicalName
            InitialScsiLunMultipathPolicy = $script:vmHostScsiLunInitialConfiguration.ScsiLunMultipathPolicy
            InitialScsiLunBlocksToSwitchPath = $script:vmHostScsiLunInitialConfiguration.ScsiLunBlocksToSwitchPath
            InitialScsiLunCommandsToSwitchPath = $script:vmHostScsiLunInitialConfiguration.ScsiLunCommandsToSwitchPath
            InitialScsiLunIsLocal = $script:vmHostScsiLunInitialConfiguration.ScsiLunIsLocal
            InitialScsiLunIsSsd = $script:vmHostScsiLunInitialConfiguration.ScsiLunIsSsd
            ScsiLunRoundRobinMultipathPolicy = 'RoundRobin'
            ScsiLunFixedMultipathPolicy = 'Fixed'
            ScsiLunBlocksToSwitchPath = 2048
            ScsiLunCommandsToSwitchPath = 50
            ScsiLunIsLocal = $script:vmHostScsiLunInitialConfiguration.ScsiLunIsLocal
            ScsiLunIsSsd = $script:vmHostScsiLunInitialConfiguration.ScsiLunIsSsd
            ScsiLunPathName = $script:vmHostScsiLunInitialConfiguration.ScsiLunPathName
            ScsiLunDisabledBlocksToSwitchPath = 0
            ScsiLunDisabledCommandsToSwitchPath = 0
        }
    )
}

$script:configModifyVMHostScsiLunConfigurationWithRoundRobinMultipathPolicy = "$($script:dscResourceName)_ModifyVMHostScsiLunConfigurationWithRoundRobinMultipathPolicy_Config"
$script:configModifyVMHostScsiLunConfigurationWithFixedMultipathPolicy = "$($script:dscResourceName)_ModifyVMHostScsiLunConfigurationWithFixedMultipathPolicy_Config"
$script:configModifyVMHostScsiLunConfigurationToInitialState = "$($script:dscResourceName)_ModifyVMHostScsiLunConfigurationToInitialState_Config"

. $script:configurationFile -ErrorAction Stop

$script:mofFileModifyVMHostScsiLunConfigurationWithRoundRobinMultipathPolicyPath = "$script:integrationTestsFolderPath\$script:configModifyVMHostScsiLunConfigurationWithRoundRobinMultipathPolicy\"
$script:mofFileModifyVMHostScsiLunConfigurationWithFixedMultipathPolicyPath = "$script:integrationTestsFolderPath\$script:configModifyVMHostScsiLunConfigurationWithFixedMultipathPolicy\"
$script:mofFileModifyVMHostScsiLunConfigurationToInitialStatePath = "$script:integrationTestsFolderPath\$script:configModifyVMHostScsiLunConfigurationToInitialState\"

Describe "$($script:dscResourceName)_Integration" {
    Context "When using configuration $script:configModifyVMHostScsiLunConfigurationWithRoundRobinMultipathPolicy" {
        BeforeAll {
            # Arrange
            & $script:configModifyVMHostScsiLunConfigurationWithRoundRobinMultipathPolicy `
                -OutputPath $script:mofFileModifyVMHostScsiLunConfigurationWithRoundRobinMultipathPolicyPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileModifyVMHostScsiLunConfigurationWithRoundRobinMultipathPolicyPath
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
                Path = $script:mofFileModifyVMHostScsiLunConfigurationWithRoundRobinMultipathPolicyPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configModifyVMHostScsiLunConfigurationWithRoundRobinMultipathPolicy }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.CanonicalName | Should -Be $script:configurationData.AllNodes.ScsiLunCanonicalName
            $configuration.MultipathPolicy | Should -Be $script:configurationData.AllNodes.ScsiLunRoundRobinMultipathPolicy
            $configuration.PreferredScsiLunPathName | Should -BeNullOrEmpty
            $configuration.BlocksToSwitchPath | Should -Be $script:configurationData.AllNodes.ScsiLunBlocksToSwitchPath
            $configuration.CommandsToSwitchPath | Should -Be $script:configurationData.AllNodes.ScsiLunCommandsToSwitchPath
            $configuration.IsLocal | Should -Be $script:configurationData.AllNodes.ScsiLunIsLocal
            $configuration.IsSsd | Should -Be $script:configurationData.AllNodes.ScsiLunIsSsd
            $configuration.DeletePartitions | Should -BeNull
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileModifyVMHostScsiLunConfigurationWithRoundRobinMultipathPolicyPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configModifyVMHostScsiLunConfigurationToInitialState `
                -OutputPath $script:mofFileModifyVMHostScsiLunConfigurationToInitialStatePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileModifyVMHostScsiLunConfigurationToInitialStatePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileModifyVMHostScsiLunConfigurationWithRoundRobinMultipathPolicyPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileModifyVMHostScsiLunConfigurationToInitialStatePath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configModifyVMHostScsiLunConfigurationWithFixedMultipathPolicy" {
        BeforeAll {
            # Arrange
            & $script:configModifyVMHostScsiLunConfigurationWithRoundRobinMultipathPolicy `
                -OutputPath $script:mofFileModifyVMHostScsiLunConfigurationWithRoundRobinMultipathPolicyPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configModifyVMHostScsiLunConfigurationWithFixedMultipathPolicy `
                -OutputPath $script:mofFileModifyVMHostScsiLunConfigurationWithFixedMultipathPolicyPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersWithRoundRobinMultipathPolicy = @{
                Path = $script:mofFileModifyVMHostScsiLunConfigurationWithRoundRobinMultipathPolicyPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersWithFixedMultipathPolicy = @{
                Path = $script:mofFileModifyVMHostScsiLunConfigurationWithFixedMultipathPolicyPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersWithRoundRobinMultipathPolicy
            Start-DscConfiguration @startDscConfigurationParametersWithFixedMultipathPolicy
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileModifyVMHostScsiLunConfigurationWithFixedMultipathPolicyPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configModifyVMHostScsiLunConfigurationWithFixedMultipathPolicy }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.CanonicalName | Should -Be $script:configurationData.AllNodes.ScsiLunCanonicalName
            $configuration.MultipathPolicy | Should -Be $script:configurationData.AllNodes.ScsiLunFixedMultipathPolicy
            $configuration.PreferredScsiLunPathName | Should -Be $script:configurationData.AllNodes.ScsiLunPathName
            $configuration.BlocksToSwitchPath | Should -Be $script:configurationData.AllNodes.ScsiLunDisabledBlocksToSwitchPath
            $configuration.CommandsToSwitchPath | Should -Be $script:configurationData.AllNodes.ScsiLunDisabledCommandsToSwitchPath
            $configuration.IsLocal | Should -Be $script:configurationData.AllNodes.ScsiLunIsLocal
            $configuration.IsSsd | Should -Be $script:configurationData.AllNodes.ScsiLunIsSsd
            $configuration.DeletePartitions | Should -BeNull
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileModifyVMHostScsiLunConfigurationWithFixedMultipathPolicyPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configModifyVMHostScsiLunConfigurationToInitialState `
                -OutputPath $script:mofFileModifyVMHostScsiLunConfigurationToInitialStatePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileModifyVMHostScsiLunConfigurationToInitialStatePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileModifyVMHostScsiLunConfigurationWithRoundRobinMultipathPolicyPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileModifyVMHostScsiLunConfigurationWithFixedMultipathPolicyPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileModifyVMHostScsiLunConfigurationToInitialStatePath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }
}
