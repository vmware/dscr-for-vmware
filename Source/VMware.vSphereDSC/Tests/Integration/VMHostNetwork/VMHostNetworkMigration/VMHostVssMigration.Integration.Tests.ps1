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

. "$PSScriptRoot\VMHostNetworkMigration.Integration.Tests.Helpers.ps1"
Invoke-TestSetup

$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (ConvertTo-SecureString -String $Password -AsPlainText -Force)

$script:dscResourceName = 'VMHostVssMigration'
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
            VDSwitchResourceName = 'VDSwitch'
            VDSwitchResourceId = '[VDSwitch]VDSwitch'
            ManagementVDPortGroupResourceName = 'ManagementVDPortGroup'
            ManagementStandardPortGroupResourceName = 'ManagementStandardPortGroup'
            ManagementStandardPortGroupResourceId = '[VMHostVssPortGroup]ManagementStandardPortGroup'
            VMotionVDPortGroupResourceName = 'VMotionVDPortGroup'
            VMotionStandardPortGroupResourceName = 'VMotionStandardPortGroup'
            VMotionStandardPortGroupResourceId = '[VMHostVssPortGroup]VMotionStandardPortGroup'
            VMHostVssResourceName = 'VMHostVss'
            VDSwitchVMHostResourceName = 'VDSwitchVMHost'
            VMHostVDSwitchMigrationResourceName = 'VMHostVDSwitchMigration'
            VMHostVssMigrationResourceName = 'VMHostVssMigration'
            VMHostVssManagementNicResourceName = 'VMHostVssManagementNic'
            VMHostVssvMotionNicResourceName = 'VMHostVssvMotionNic'
            VMHostVssBridgeResourceName = 'VMHostVssBridge'
            VMHostVssTeamingResourceName = 'VMHostVssTeaming'
            VDSwitchName = 'MyTestVDSwitch'
            VDSwitchLocation = [string]::Empty
            DatacenterName = $script:datacenterName
            DatacenterLocation = $script:datacenterLocation
            ManagementPortGroupName = 'MyManagementPortGroup'
            VMotionPortGroupName = 'MyvMotionPortGroup'
            StandardSwitchName = 'MyTestStandardSwitch'
            PhysicalNetworkAdapterNames = $script:physicalNetworkAdapters
            VirtualSwitches = $script:virtualSwitchesWithPhysicalNics
            LinkDiscoveryProtocolOperation = 'Listen'
            LinkDiscoveryProtocolProtocol = 'CDP'
        }
    )
}

$script:configCreateVDSwitchTwoVDPortGroupsStandardSwitchAndAddVMHostToVDSwitch = "$($script:dscResourceName)_CreateVDSwitchTwoVDPortGroupsStandardSwitchAndAddVMHostToVDSwitch_Config"
$script:configMigrateThreePhysicalNetworkAdaptersToDistributedSwitch = "$($script:dscResourceName)_MigrateThreePhysicalNetworkAdaptersToDistributedSwitch_Config"
$script:configMigrateThreePhysicalNetworkAdaptersToStandardSwitch = "$($script:dscResourceName)_MigrateThreePhysicalNetworkAdaptersToStandardSwitch_Config"
$script:configMigrateThreePhysicalNetworkAdaptersAndTwoVMKernelNetworkAdaptersToStandardSwitch = "$($script:dscResourceName)_MigrateThreePhysicalNetworkAdaptersAndTwoVMKernelNetworkAdaptersToStandardSwitch_Config"
$script:configMigrateThreePhysicalNetworkAdaptersAndTwoVMKernelNetworkAdaptersWithPortGroupsToStandardSwitch = "$($script:dscResourceName)_MigrateThreePhysicalNetworkAdaptersAndTwoVMKernelNetworkAdaptersWithPortGroupsToStandardSwitch_Config"
$script:configRemoveManagementAndvMotionVMKernelNetworkAdaptersWithPortGroupsWithVMKernelPrefixFromStandardSwitch = "$($script:dscResourceName)_RemoveManagementAndvMotionVMKernelNetworkAdaptersWithPortGroupsWithVMKernelPrefixFromStandardSwitch_Config"
$script:configRemoveManagementAndvMotionVMKernelNetworkAdaptersFromStandardSwitch = "$($script:dscResourceName)_RemoveManagementAndvMotionVMKernelNetworkAdaptersFromStandardSwitch_Config"
$script:configRemoveVDSwitchAndStandardSwitch = "$($script:dscResourceName)_RemoveVDSwitchAndStandardSwitch_Config"
$script:configMigratePhysicalNetworkAdaptersToInitialVirtualSwitches = "$($script:dscResourceName)_MigratePhysicalNetworkAdaptersToInitialVirtualSwitches_Config"

. $script:configurationFile -ErrorAction Stop

$script:mofFileCreateVDSwitchTwoVDPortGroupsStandardSwitchAndAddVMHostToVDSwitchPath = "$script:integrationTestsFolderPath\$script:configCreateVDSwitchTwoVDPortGroupsStandardSwitchAndAddVMHostToVDSwitch\"
$script:mofFileMigrateThreePhysicalNetworkAdaptersToDistributedSwitchPath = "$script:integrationTestsFolderPath\$script:configMigrateThreePhysicalNetworkAdaptersToDistributedSwitch\"
$script:mofFileMigrateThreePhysicalNetworkAdaptersToStandardSwitchPath = "$script:integrationTestsFolderPath\$script:configMigrateThreePhysicalNetworkAdaptersToStandardSwitch\"
$script:mofFileMigrateThreePhysicalNetworkAdaptersAndTwoVMKernelNetworkAdaptersToStandardSwitchPath = "$script:integrationTestsFolderPath\$script:configMigrateThreePhysicalNetworkAdaptersAndTwoVMKernelNetworkAdaptersToStandardSwitch\"
$script:mofFileMigrateThreePhysicalNetworkAdaptersAndTwoVMKernelNetworkAdaptersWithPortGroupsToStandardSwitchPath = "$script:integrationTestsFolderPath\$script:configMigrateThreePhysicalNetworkAdaptersAndTwoVMKernelNetworkAdaptersWithPortGroupsToStandardSwitch\"
$script:mofFileRemoveManagementAndvMotionVMKernelNetworkAdaptersWithPortGroupsWithVMKernelPrefixFromStandardSwitchPath = "$script:integrationTestsFolderPath\$script:configRemoveManagementAndvMotionVMKernelNetworkAdaptersWithPortGroupsWithVMKernelPrefixFromStandardSwitch\"
$script:mofFileRemoveManagementAndvMotionVMKernelNetworkAdaptersFromStandardSwitchPath = "$script:integrationTestsFolderPath\$script:configRemoveManagementAndvMotionVMKernelNetworkAdaptersFromStandardSwitch\"
$script:mofFileRemoveVDSwitchAndStandardSwitchPath = "$script:integrationTestsFolderPath\$script:configRemoveVDSwitchAndStandardSwitch\"
$script:mofFileMigratePhysicalNetworkAdaptersToInitialVirtualSwitchesPath = "$script:integrationTestsFolderPath\$script:configMigratePhysicalNetworkAdaptersToInitialVirtualSwitches\"

Describe "$($script:dscResourceName)_Integration" {
    Context "When using configuration $script:configMigrateThreePhysicalNetworkAdaptersToStandardSwitch" {
        BeforeAll {
            # Arrange
            & $script:configCreateVDSwitchTwoVDPortGroupsStandardSwitchAndAddVMHostToVDSwitch `
                -OutputPath $script:mofFileCreateVDSwitchTwoVDPortGroupsStandardSwitchAndAddVMHostToVDSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configMigrateThreePhysicalNetworkAdaptersToDistributedSwitch `
                -OutputPath $script:mofFileMigrateThreePhysicalNetworkAdaptersToDistributedSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configMigrateThreePhysicalNetworkAdaptersToStandardSwitch `
                -OutputPath $script:mofFileMigrateThreePhysicalNetworkAdaptersToStandardSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersCreateVDSwitchTwoVDPortGroupsStandardSwitchAndAddVMHostToVDSwitch = @{
                Path = $script:mofFileCreateVDSwitchTwoVDPortGroupsStandardSwitchAndAddVMHostToVDSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersMigrateThreePhysicalNetworkAdaptersToDistributedSwitch = @{
                Path = $script:mofFileMigrateThreePhysicalNetworkAdaptersToDistributedSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersMigrateThreePhysicalNetworkAdaptersToStandardSwitch = @{
                Path = $script:mofFileMigrateThreePhysicalNetworkAdaptersToStandardSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersCreateVDSwitchTwoVDPortGroupsStandardSwitchAndAddVMHostToVDSwitch
            Start-DscConfiguration @startDscConfigurationParametersMigrateThreePhysicalNetworkAdaptersToDistributedSwitch
            Start-DscConfiguration @startDscConfigurationParametersMigrateThreePhysicalNetworkAdaptersToStandardSwitch
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileMigrateThreePhysicalNetworkAdaptersToStandardSwitchPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configMigrateThreePhysicalNetworkAdaptersToStandardSwitch }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.VssName | Should -Be $script:configurationData.AllNodes.StandardSwitchName
            $configuration.PhysicalNicNames | Should -Be $script:configurationData.AllNodes.PhysicalNetworkAdapterNames
            $configuration.VMKernelNicNames | Should -Be @()
            $configuration.PortGroupNames | Should -Be @()
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileMigrateThreePhysicalNetworkAdaptersToStandardSwitchPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configRemoveVDSwitchAndStandardSwitch `
                -OutputPath $script:mofFileRemoveVDSwitchAndStandardSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configMigratePhysicalNetworkAdaptersToInitialVirtualSwitches `
                -OutputPath $script:mofFileMigratePhysicalNetworkAdaptersToInitialVirtualSwitchesPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersRemoveVDSwitchAndStandardSwitch = @{
                Path = $script:mofFileRemoveVDSwitchAndStandardSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersMigratePhysicalNetworkAdaptersToInitialVirtualSwitches = @{
                Path = $script:mofFileMigratePhysicalNetworkAdaptersToInitialVirtualSwitchesPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersRemoveVDSwitchAndStandardSwitch
            Start-DscConfiguration @startDscConfigurationParametersMigratePhysicalNetworkAdaptersToInitialVirtualSwitches

            Remove-Item -Path $script:mofFileCreateVDSwitchTwoVDPortGroupsStandardSwitchAndAddVMHostToVDSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileMigrateThreePhysicalNetworkAdaptersToDistributedSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileMigrateThreePhysicalNetworkAdaptersToStandardSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVDSwitchAndStandardSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileMigratePhysicalNetworkAdaptersToInitialVirtualSwitchesPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configMigrateThreePhysicalNetworkAdaptersAndTwoVMKernelNetworkAdaptersToStandardSwitch" {
        BeforeAll {
            # Arrange
            & $script:configCreateVDSwitchTwoVDPortGroupsStandardSwitchAndAddVMHostToVDSwitch `
                -OutputPath $script:mofFileCreateVDSwitchTwoVDPortGroupsStandardSwitchAndAddVMHostToVDSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configMigrateThreePhysicalNetworkAdaptersToDistributedSwitch `
                -OutputPath $script:mofFileMigrateThreePhysicalNetworkAdaptersToDistributedSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersCreateVDSwitchTwoVDPortGroupsStandardSwitchAndAddVMHostToVDSwitch = @{
                Path = $script:mofFileCreateVDSwitchTwoVDPortGroupsStandardSwitchAndAddVMHostToVDSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersMigrateThreePhysicalNetworkAdaptersToDistributedSwitch = @{
                Path = $script:mofFileMigrateThreePhysicalNetworkAdaptersToDistributedSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersCreateVDSwitchTwoVDPortGroupsStandardSwitchAndAddVMHostToVDSwitch

            New-VMKernelNetworkAdaptersOnDistributedSwitch

            Start-DscConfiguration @startDscConfigurationParametersMigrateThreePhysicalNetworkAdaptersToDistributedSwitch

            Get-VMKernelNetworkAdapterNamesConnectedToDistributedSwitch

            & $script:configMigrateThreePhysicalNetworkAdaptersAndTwoVMKernelNetworkAdaptersToStandardSwitch `
                -OutputPath $script:mofFileMigrateThreePhysicalNetworkAdaptersAndTwoVMKernelNetworkAdaptersToStandardSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersMigrateThreePhysicalNetworkAdaptersAndTwoVMKernelNetworkAdaptersToStandardSwitch = @{
                Path = $script:mofFileMigrateThreePhysicalNetworkAdaptersAndTwoVMKernelNetworkAdaptersToStandardSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            Start-DscConfiguration @startDscConfigurationParametersMigrateThreePhysicalNetworkAdaptersAndTwoVMKernelNetworkAdaptersToStandardSwitch

            Get-PortGroupNamesWithVMKernelPrefix
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileMigrateThreePhysicalNetworkAdaptersAndTwoVMKernelNetworkAdaptersToStandardSwitchPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configMigrateThreePhysicalNetworkAdaptersAndTwoVMKernelNetworkAdaptersToStandardSwitch }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.VssName | Should -Be $script:configurationData.AllNodes.StandardSwitchName
            $configuration.PhysicalNicNames | Should -Be $script:configurationData.AllNodes.PhysicalNetworkAdapterNames
            $configuration.VMKernelNicNames | Should -Be $script:configurationData.AllNodes.VMKernelNetworkAdapterNames
            $configuration.PortGroupNames | Should -Be $script:configurationData.AllNodes.PortGroupNamesWithVMKernelPrefix
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileMigrateThreePhysicalNetworkAdaptersAndTwoVMKernelNetworkAdaptersToStandardSwitchPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configRemoveManagementAndvMotionVMKernelNetworkAdaptersWithPortGroupsWithVMKernelPrefixFromStandardSwitch `
                -OutputPath $script:mofFileRemoveManagementAndvMotionVMKernelNetworkAdaptersWithPortGroupsWithVMKernelPrefixFromStandardSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configRemoveVDSwitchAndStandardSwitch `
                -OutputPath $script:mofFileRemoveVDSwitchAndStandardSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configMigratePhysicalNetworkAdaptersToInitialVirtualSwitches `
                -OutputPath $script:mofFileMigratePhysicalNetworkAdaptersToInitialVirtualSwitchesPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersRemoveManagementAndvMotionVMKernelNetworkAdaptersWithPortGroupsWithVMKernelPrefixFromStandardSwitch = @{
                Path = $script:mofFileRemoveManagementAndvMotionVMKernelNetworkAdaptersWithPortGroupsWithVMKernelPrefixFromStandardSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersRemoveVDSwitchAndStandardSwitch = @{
                Path = $script:mofFileRemoveVDSwitchAndStandardSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersMigratePhysicalNetworkAdaptersToInitialVirtualSwitches = @{
                Path = $script:mofFileMigratePhysicalNetworkAdaptersToInitialVirtualSwitchesPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersRemoveManagementAndvMotionVMKernelNetworkAdaptersWithPortGroupsWithVMKernelPrefixFromStandardSwitch
            Start-DscConfiguration @startDscConfigurationParametersRemoveVDSwitchAndStandardSwitch
            Start-DscConfiguration @startDscConfigurationParametersMigratePhysicalNetworkAdaptersToInitialVirtualSwitches

            Remove-Item -Path $script:mofFileCreateVDSwitchTwoVDPortGroupsStandardSwitchAndAddVMHostToVDSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileMigrateThreePhysicalNetworkAdaptersToDistributedSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileMigrateThreePhysicalNetworkAdaptersAndTwoVMKernelNetworkAdaptersToStandardSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveManagementAndvMotionVMKernelNetworkAdaptersWithPortGroupsWithVMKernelPrefixFromStandardSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVDSwitchAndStandardSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileMigratePhysicalNetworkAdaptersToInitialVirtualSwitchesPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configMigrateThreePhysicalNetworkAdaptersAndTwoVMKernelNetworkAdaptersWithPortGroupsToStandardSwitch" {
        BeforeAll {
            # Arrange
            & $script:configCreateVDSwitchTwoVDPortGroupsStandardSwitchAndAddVMHostToVDSwitch `
                -OutputPath $script:mofFileCreateVDSwitchTwoVDPortGroupsStandardSwitchAndAddVMHostToVDSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configMigrateThreePhysicalNetworkAdaptersToDistributedSwitch `
                -OutputPath $script:mofFileMigrateThreePhysicalNetworkAdaptersToDistributedSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersCreateVDSwitchTwoVDPortGroupsStandardSwitchAndAddVMHostToVDSwitch = @{
                Path = $script:mofFileCreateVDSwitchTwoVDPortGroupsStandardSwitchAndAddVMHostToVDSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersMigrateThreePhysicalNetworkAdaptersToDistributedSwitch = @{
                Path = $script:mofFileMigrateThreePhysicalNetworkAdaptersToDistributedSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersCreateVDSwitchTwoVDPortGroupsStandardSwitchAndAddVMHostToVDSwitch

            New-VMKernelNetworkAdaptersOnDistributedSwitch

            Start-DscConfiguration @startDscConfigurationParametersMigrateThreePhysicalNetworkAdaptersToDistributedSwitch

            Get-VMKernelNetworkAdapterNamesConnectedToDistributedSwitch

            & $script:configMigrateThreePhysicalNetworkAdaptersAndTwoVMKernelNetworkAdaptersWithPortGroupsToStandardSwitch `
                -OutputPath $script:mofFileMigrateThreePhysicalNetworkAdaptersAndTwoVMKernelNetworkAdaptersWithPortGroupsToStandardSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersMigrateThreePhysicalNetworkAdaptersAndTwoVMKernelNetworkAdaptersWithPortGroupsToStandardSwitch = @{
                Path = $script:mofFileMigrateThreePhysicalNetworkAdaptersAndTwoVMKernelNetworkAdaptersWithPortGroupsToStandardSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            Start-DscConfiguration @startDscConfigurationParametersMigrateThreePhysicalNetworkAdaptersAndTwoVMKernelNetworkAdaptersWithPortGroupsToStandardSwitch
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileMigrateThreePhysicalNetworkAdaptersAndTwoVMKernelNetworkAdaptersWithPortGroupsToStandardSwitchPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configMigrateThreePhysicalNetworkAdaptersAndTwoVMKernelNetworkAdaptersWithPortGroupsToStandardSwitch }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.VssName | Should -Be $script:configurationData.AllNodes.StandardSwitchName
            $configuration.PhysicalNicNames | Should -Be $script:configurationData.AllNodes.PhysicalNetworkAdapterNames
            $configuration.VMKernelNicNames | Should -Be $script:configurationData.AllNodes.VMKernelNetworkAdapterNames
            $configuration.PortGroupNames | Should -Be @($script:configurationData.AllNodes.ManagementPortGroupName, $script:configurationData.AllNodes.VMotionPortGroupName)
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileMigrateThreePhysicalNetworkAdaptersAndTwoVMKernelNetworkAdaptersWithPortGroupsToStandardSwitchPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configRemoveManagementAndvMotionVMKernelNetworkAdaptersFromStandardSwitch `
                -OutputPath $script:mofFileRemoveManagementAndvMotionVMKernelNetworkAdaptersFromStandardSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configRemoveVDSwitchAndStandardSwitch `
                -OutputPath $script:mofFileRemoveVDSwitchAndStandardSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configMigratePhysicalNetworkAdaptersToInitialVirtualSwitches `
                -OutputPath $script:mofFileMigratePhysicalNetworkAdaptersToInitialVirtualSwitchesPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersRemoveManagementAndvMotionVMKernelNetworkAdaptersFromStandardSwitch = @{
                Path = $script:mofFileRemoveManagementAndvMotionVMKernelNetworkAdaptersFromStandardSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersRemoveVDSwitchAndStandardSwitch = @{
                Path = $script:mofFileRemoveVDSwitchAndStandardSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersMigratePhysicalNetworkAdaptersToInitialVirtualSwitches = @{
                Path = $script:mofFileMigratePhysicalNetworkAdaptersToInitialVirtualSwitchesPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersRemoveManagementAndvMotionVMKernelNetworkAdaptersFromStandardSwitch
            Start-DscConfiguration @startDscConfigurationParametersRemoveVDSwitchAndStandardSwitch
            Start-DscConfiguration @startDscConfigurationParametersMigratePhysicalNetworkAdaptersToInitialVirtualSwitches

            Remove-Item -Path $script:mofFileCreateVDSwitchTwoVDPortGroupsStandardSwitchAndAddVMHostToVDSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileMigrateThreePhysicalNetworkAdaptersToDistributedSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileMigrateThreePhysicalNetworkAdaptersAndTwoVMKernelNetworkAdaptersWithPortGroupsToStandardSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveManagementAndvMotionVMKernelNetworkAdaptersFromStandardSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVDSwitchAndStandardSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileMigratePhysicalNetworkAdaptersToInitialVirtualSwitchesPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }
}
