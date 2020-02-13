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

$script:dscResourceName = 'VMHostVssPortGroupShaping'
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
            StandardSwitchResourceName = 'StandardSwitch'
            StandardSwitchResourceId = '[VMHostVss]StandardSwitch'
            VirtualPortGroupResourceName = 'VirtualPortGroup'
            VirtualPortGroupResourceId = '[VMHostVssPortGroup]VirtualPortGroup'
            VirtualPortGroupShapingPolicyResourceName = 'VirtualPortGroupShapingPolicy'
            VirtualPortGroupShapingPolicyResourceId = '[VMHostVssPortGroupShaping]VirtualPortGroupShapingPolicy'
            StandardSwitchName = 'MyStandardSwitch'
            Mtu = 1500
            VirtualPortGroupName = 'MyVirtualPortGroup'
            VlanId = 0
            ShapingEnabled = $true
            AverageBandwidth = 104857600000
            PeakBandwidth = 104857600000
            BurstSize = 107374182400
        }
    )
}

$script:configWhenAddingVirtualPortGroupAndStandardSwitch = "$($script:dscResourceName)_WhenAddingVirtualPortGroupAndStandardSwitch_Config"
$script:configWhenUpdatingShapingPolicyWithEnabledSetToTrue = "$($script:dscResourceName)_WhenUpdatingShapingPolicyWithEnabledSetToTrue_Config"
$script:configWhenUpdatingShapingPolicyWithEnabledSetToFalse = "$($script:dscResourceName)_WhenUpdatingShapingPolicyWithEnabledSetToFalse_Config"
$script:configWhenRemovingVirtualPortGroupAndStandardSwitch = "$($script:dscResourceName)_WhenRemovingVirtualPortGroupAndStandardSwitch_Config"

. $script:configurationFile -ErrorAction Stop

$script:mofFileWhenAddingVirtualPortGroupAndStandardSwitchPath = "$script:integrationTestsFolderPath\$script:configWhenAddingVirtualPortGroupAndStandardSwitch\"
$script:mofFileWhenUpdatingShapingPolicyWithEnabledSetToTruePath = "$script:integrationTestsFolderPath\$script:configWhenUpdatingShapingPolicyWithEnabledSetToTrue\"
$script:mofFileWhenUpdatingShapingPolicyWithEnabledSetToFalsePath = "$script:integrationTestsFolderPath\$script:configWhenUpdatingShapingPolicyWithEnabledSetToFalse\"
$script:mofFileWhenRemovingVirtualPortGroupAndStandardSwitchPath = "$script:integrationTestsFolderPath\$script:configWhenRemovingVirtualPortGroupAndStandardSwitch\"

Describe "$($script:dscResourceName)_Integration" {
    Context "When using configuration $script:configWhenUpdatingShapingPolicyWithEnabledSetToTrue" {
        BeforeAll {
            # Arrange
            & $script:configWhenAddingVirtualPortGroupAndStandardSwitch `
                -OutputPath $script:mofFileWhenAddingVirtualPortGroupAndStandardSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configWhenUpdatingShapingPolicyWithEnabledSetToTrue `
                -OutputPath $script:mofFileWhenUpdatingShapingPolicyWithEnabledSetToTruePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersWhenAddingVirtualPortGroupAndStandardSwitch = @{
                Path = $script:mofFileWhenAddingVirtualPortGroupAndStandardSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersWhenUpdatingShapingPolicyWithEnabledSetToTrue = @{
                Path = $script:mofFileWhenUpdatingShapingPolicyWithEnabledSetToTruePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersWhenAddingVirtualPortGroupAndStandardSwitch
            Start-DscConfiguration @startDscConfigurationParametersWhenUpdatingShapingPolicyWithEnabledSetToTrue
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenUpdatingShapingPolicyWithEnabledSetToTruePath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configWhenUpdatingShapingPolicyWithEnabledSetToTrue }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.Name
            $configuration.Name | Should -Be $script:configurationData.AllNodes.VirtualPortGroupName
            $configuration.Ensure | Should -Be 'Present'
            $configuration.Enabled | Should -Be $script:configurationData.AllNodes.ShapingEnabled
            $configuration.AverageBandwidth | Should -Be $script:configurationData.AllNodes.AverageBandwidth
            $configuration.PeakBandwidth | Should -Be $script:configurationData.AllNodes.PeakBandwidth
            $configuration.BurstSize | Should -Be $script:configurationData.AllNodes.BurstSize
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileWhenUpdatingShapingPolicyWithEnabledSetToTruePath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configWhenRemovingVirtualPortGroupAndStandardSwitch `
                -OutputPath $script:mofFileWhenRemovingVirtualPortGroupAndStandardSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingVirtualPortGroupAndStandardSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileWhenAddingVirtualPortGroupAndStandardSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileWhenUpdatingShapingPolicyWithEnabledSetToTruePath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileWhenRemovingVirtualPortGroupAndStandardSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configWhenUpdatingShapingPolicyWithEnabledSetToFalse" {
        BeforeAll {
            # Arrange
            & $script:configWhenAddingVirtualPortGroupAndStandardSwitch `
                -OutputPath $script:mofFileWhenAddingVirtualPortGroupAndStandardSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configWhenUpdatingShapingPolicyWithEnabledSetToFalse `
                -OutputPath $script:mofFileWhenUpdatingShapingPolicyWithEnabledSetToFalsePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersWhenAddingVirtualPortGroupAndStandardSwitch = @{
                Path = $script:mofFileWhenAddingVirtualPortGroupAndStandardSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersWhenUpdatingShapingPolicyWithEnabledSetToFalse = @{
                Path = $script:mofFileWhenUpdatingShapingPolicyWithEnabledSetToFalsePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersWhenAddingVirtualPortGroupAndStandardSwitch
            Start-DscConfiguration @startDscConfigurationParametersWhenUpdatingShapingPolicyWithEnabledSetToFalse
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenUpdatingShapingPolicyWithEnabledSetToFalsePath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configWhenUpdatingShapingPolicyWithEnabledSetToFalse }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.Name
            $configuration.Name | Should -Be $script:configurationData.AllNodes.VirtualPortGroupName
            $configuration.Ensure | Should -Be 'Present'
            $configuration.Enabled | Should -Be $false
            $configuration.AverageBandwidth | Should -BeNullOrEmpty
            $configuration.PeakBandwidth | Should -BeNullOrEmpty
            $configuration.BurstSize | Should -Be $script:configurationData.AllNodes.BurstSize
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileWhenUpdatingShapingPolicyWithEnabledSetToFalsePath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configWhenRemovingVirtualPortGroupAndStandardSwitch `
                -OutputPath $script:mofFileWhenRemovingVirtualPortGroupAndStandardSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingVirtualPortGroupAndStandardSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileWhenAddingVirtualPortGroupAndStandardSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileWhenUpdatingShapingPolicyWithEnabledSetToFalsePath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileWhenRemovingVirtualPortGroupAndStandardSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }
}
