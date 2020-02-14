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

$script:dscResourceName = 'VMHostVssNic'
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
            StandardSwitchNetworkAdapterResourceName = 'StandardSwitchNetworkAdapter'
            StandardSwitchNetworkAdapterResourceId = '[VMHostVssNic]StandardSwitchNetworkAdapter'
            StandardSwitchName = 'MyStandardSwitch'
            StandardSwitchMtu = 1500
            PortGroup = 'MyVirtualPortGroup'
            IP1 = '192.168.0.1'
            IP2 = '10.23.123.234'
            DefaultIP = '0.0.0.0'
            SubnetMask1 = '255.255.255.0'
            SubnetMask2 = '255.255.254.0'
            DefaultSubnetMask = '0.0.0.0'
            Mac = '00:50:56:63:5b:0e'
            AutomaticIPv6 = $true
            IPv6 = @('fe80::250:56ff:fe63:5b0e/64', '200:2342::1/32')
            DefaultIPv6 = @('fe80::250:56ff:fe63:5b0e/64')
            IPv6ThroughDhcp = $true
            VMKernelNetworkAdapterMtu = 4000
            VMKernelNetworkAdapterUpdatedMtu = 5000
            ManagementTrafficEnabled = $true
            FaultToleranceLoggingEnabled = $true
            VMotionEnabled = $true
            VsanTrafficEnabled = $true
            Dhcp = $true
            IPv6Enabled = $true
        }
    )
}

$script:configWhenAddingVMKernelNetworkAdapter = "$($script:dscResourceName)_WhenAddingVMKernelNetworkAdapter_Config"
$script:configWhenUpdatingVMKernelNetworkAdapterMtuAndAvailableServices = "$($script:dscResourceName)_WhenUpdatingVMKernelNetworkAdapterMtuAndAvailableServices_Config"
$script:configWhenUpdatingVMKernelNetworkAdapterIPAndSubnetMask = "$($script:dscResourceName)_WhenUpdatingVMKernelNetworkAdapterIPAndSubnetMask_Config"
$script:configWhenUpdatingVMKernelNetworkAdapterIPv6Settings = "$($script:dscResourceName)_WhenUpdatingVMKernelNetworkAdapterIPv6Settings_Config"
$script:configWhenUpdatingVMKernelNetworkAdapterDhcpAndIPv6 = "$($script:dscResourceName)_WhenUpdatingVMKernelNetworkAdapterDhcpAndIPv6_Config"
$script:configWhenRemovingVMKernelNetworkAdapter = "$($script:dscResourceName)_WhenRemovingVMKernelNetworkAdapter_Config"
$script:configWhenRemovingVMKernelNetworkAdapterAndStandardSwitch = "$($script:dscResourceName)_WhenRemovingVMKernelNetworkAdapterAndStandardSwitch_Config"

. $script:configurationFile -ErrorAction Stop

$script:mofFileWhenAddingVMKernelNetworkAdapterPath = "$script:integrationTestsFolderPath\$script:configWhenAddingVMKernelNetworkAdapter\"
$script:mofFileWhenUpdatingVMKernelNetworkAdapterMtuAndAvailableServicesPath = "$script:integrationTestsFolderPath\$script:configWhenUpdatingVMKernelNetworkAdapterMtuAndAvailableServices\"
$script:mofFileWhenUpdatingVMKernelNetworkAdapterIPAndSubnetMaskPath = "$script:integrationTestsFolderPath\$script:configWhenUpdatingVMKernelNetworkAdapterIPAndSubnetMask\"
$script:mofFileWhenUpdatingVMKernelNetworkAdapterIPv6SettingsPath = "$script:integrationTestsFolderPath\$script:configWhenUpdatingVMKernelNetworkAdapterIPv6Settings\"
$script:mofFileWhenUpdatingVMKernelNetworkAdapterDhcpAndIPv6Path = "$script:integrationTestsFolderPath\$script:configWhenUpdatingVMKernelNetworkAdapterDhcpAndIPv6\"
$script:mofFileWhenRemovingVMKernelNetworkAdapterPath = "$script:integrationTestsFolderPath\$script:configWhenRemovingVMKernelNetworkAdapter\"
$script:mofFileWhenRemovingVMKernelNetworkAdapterAndStandardSwitchPath = "$script:integrationTestsFolderPath\$script:configWhenRemovingVMKernelNetworkAdapterAndStandardSwitch\"

Describe "$($script:dscResourceName)_Integration" {
    Context "When using configuration $script:configWhenAddingVMKernelNetworkAdapter" {
        BeforeAll {
            # Arrange
            & $script:configWhenAddingVMKernelNetworkAdapter `
                -OutputPath $script:mofFileWhenAddingVMKernelNetworkAdapterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenAddingVMKernelNetworkAdapterPath
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
                Path = $script:mofFileWhenAddingVMKernelNetworkAdapterPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configWhenAddingVMKernelNetworkAdapter }

            $standardSwitchResource = $configuration | Where-Object { $_.ResourceId -eq $script:configurationData.AllNodes.StandardSwitchResourceId }
            $standardSwitchNetworkAdapterResource = $configuration | Where-Object { $_.ResourceId -eq $script:configurationData.AllNodes.StandardSwitchNetworkAdapterResourceId }

            # Assert
            $standardSwitchResource.Server | Should -Be $script:configurationData.AllNodes.Server
            $standardSwitchResource.Name | Should -Be $script:configurationData.AllNodes.Name
            $standardSwitchResource.VssName | Should -Be $script:configurationData.AllNodes.StandardSwitchName
            $standardSwitchResource.Ensure | Should -Be 'Present'
            $standardSwitchResource.Mtu | Should -Be $script:configurationData.AllNodes.StandardSwitchMtu

            $standardSwitchNetworkAdapterResource.Server | Should -Be $script:configurationData.AllNodes.Server
            $standardSwitchNetworkAdapterResource.VMHostName | Should -Be $script:configurationData.AllNodes.Name
            $standardSwitchNetworkAdapterResource.VssName | Should -Be $script:configurationData.AllNodes.StandardSwitchName
            $standardSwitchNetworkAdapterResource.PortGroupName | Should -Be $script:configurationData.AllNodes.PortGroup
            $standardSwitchNetworkAdapterResource.Ensure | Should -Be 'Present'
            $standardSwitchNetworkAdapterResource.IP | Should -Be $script:configurationData.AllNodes.IP1
            $standardSwitchNetworkAdapterResource.SubnetMask | Should -Be $script:configurationData.AllNodes.SubnetMask1
            $standardSwitchNetworkAdapterResource.Mac | Should -Be $script:configurationData.AllNodes.Mac
            $standardSwitchNetworkAdapterResource.AutomaticIPv6 | Should -Be $script:configurationData.AllNodes.AutomaticIPv6
            $standardSwitchNetworkAdapterResource.IPv6 | Should -Be $script:configurationData.AllNodes.IPv6
            $standardSwitchNetworkAdapterResource.IPv6ThroughDhcp | Should -Be $script:configurationData.AllNodes.IPv6ThroughDhcp
            $standardSwitchNetworkAdapterResource.Mtu | Should -Be $script:configurationData.AllNodes.VMKernelNetworkAdapterMtu
            $standardSwitchNetworkAdapterResource.ManagementTrafficEnabled | Should -Be $script:configurationData.AllNodes.ManagementTrafficEnabled
            $standardSwitchNetworkAdapterResource.FaultToleranceLoggingEnabled | Should -Be $script:configurationData.AllNodes.FaultToleranceLoggingEnabled
            $standardSwitchNetworkAdapterResource.VMotionEnabled | Should -Be $script:configurationData.AllNodes.VMotionEnabled
            $standardSwitchNetworkAdapterResource.VsanTrafficEnabled | Should -Be $script:configurationData.AllNodes.VsanTrafficEnabled
            $standardSwitchNetworkAdapterResource.Dhcp | Should -Be $false
            $standardSwitchNetworkAdapterResource.IPv6Enabled | Should -Be $script:configurationData.AllNodes.IPv6Enabled
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileWhenAddingVMKernelNetworkAdapterPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        It "Should have the following dependency: Resource $($script:configurationData.AllNodes.StandardSwitchNetworkAdapterResourceName) should depend on Resource $($script:configurationData.AllNodes.StandardSwitchResourceName)" {
            # Arrange && Act
            $standardSwitchNetworkAdapterResource = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript {
                $_.ConfigurationName -eq $script:configWhenAddingVMKernelNetworkAdapter -and `
                $_.ResourceId -eq $script:configurationData.AllNodes.StandardSwitchNetworkAdapterResourceId
            }

            # Assert
            $standardSwitchNetworkAdapterResource.DependsOn | Should -Be $script:configurationData.AllNodes.StandardSwitchResourceId
        }

        AfterAll {
            # Arrange
            & $script:configWhenRemovingVMKernelNetworkAdapterAndStandardSwitch `
                -OutputPath $script:mofFileWhenRemovingVMKernelNetworkAdapterAndStandardSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingVMKernelNetworkAdapterAndStandardSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileWhenAddingVMKernelNetworkAdapterPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileWhenRemovingVMKernelNetworkAdapterAndStandardSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configWhenUpdatingVMKernelNetworkAdapterMtuAndAvailableServices" {
        BeforeAll {
            # Arrange
            & $script:configWhenAddingVMKernelNetworkAdapter `
                -OutputPath $script:mofFileWhenAddingVMKernelNetworkAdapterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configWhenUpdatingVMKernelNetworkAdapterMtuAndAvailableServices `
                -OutputPath $script:mofFileWhenUpdatingVMKernelNetworkAdapterMtuAndAvailableServicesPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersWhenAddingVMKernelNetworkAdapter = @{
                Path = $script:mofFileWhenAddingVMKernelNetworkAdapterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersWhenUpdatingVMKernelNetworkAdapterMtuAndAvailableServices = @{
                Path = $script:mofFileWhenUpdatingVMKernelNetworkAdapterMtuAndAvailableServicesPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersWhenAddingVMKernelNetworkAdapter
            Start-DscConfiguration @startDscConfigurationParametersWhenUpdatingVMKernelNetworkAdapterMtuAndAvailableServices
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenUpdatingVMKernelNetworkAdapterMtuAndAvailableServicesPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configWhenUpdatingVMKernelNetworkAdapterMtuAndAvailableServices }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.Name
            $configuration.VssName | Should -Be $script:configurationData.AllNodes.StandardSwitchName
            $configuration.PortGroupName | Should -Be $script:configurationData.AllNodes.PortGroup
            $configuration.Ensure | Should -Be 'Present'
            $configuration.IP | Should -Be $script:configurationData.AllNodes.IP1
            $configuration.SubnetMask | Should -Be $script:configurationData.AllNodes.SubnetMask1
            $configuration.Mac | Should -Be $script:configurationData.AllNodes.Mac
            $configuration.AutomaticIPv6 | Should -Be $script:configurationData.AllNodes.AutomaticIPv6
            $configuration.IPv6 | Should -Be $script:configurationData.AllNodes.IPv6
            $configuration.IPv6ThroughDhcp | Should -Be $script:configurationData.AllNodes.IPv6ThroughDhcp
            $configuration.Mtu | Should -Be $script:configurationData.AllNodes.VMKernelNetworkAdapterUpdatedMtu
            $configuration.ManagementTrafficEnabled | Should -Be $false
            $configuration.FaultToleranceLoggingEnabled | Should -Be $false
            $configuration.VMotionEnabled | Should -Be $false
            $configuration.VsanTrafficEnabled | Should -Be $false
            $configuration.Dhcp | Should -Be $false
            $configuration.IPv6Enabled | Should -Be $script:configurationData.AllNodes.IPv6Enabled
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileWhenUpdatingVMKernelNetworkAdapterMtuAndAvailableServicesPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configWhenRemovingVMKernelNetworkAdapterAndStandardSwitch `
                -OutputPath $script:mofFileWhenRemovingVMKernelNetworkAdapterAndStandardSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingVMKernelNetworkAdapterAndStandardSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileWhenAddingVMKernelNetworkAdapterPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileWhenUpdatingVMKernelNetworkAdapterMtuAndAvailableServicesPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileWhenRemovingVMKernelNetworkAdapterAndStandardSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configWhenUpdatingVMKernelNetworkAdapterIPAndSubnetMask" {
        BeforeAll {
            # Arrange
            & $script:configWhenAddingVMKernelNetworkAdapter `
                -OutputPath $script:mofFileWhenAddingVMKernelNetworkAdapterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configWhenUpdatingVMKernelNetworkAdapterIPAndSubnetMask `
                -OutputPath $script:mofFileWhenUpdatingVMKernelNetworkAdapterIPAndSubnetMaskPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersWhenAddingVMKernelNetworkAdapter = @{
                Path = $script:mofFileWhenAddingVMKernelNetworkAdapterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersWhenUpdatingVMKernelNetworkAdapterIPAndSubnetMask = @{
                Path = $script:mofFileWhenUpdatingVMKernelNetworkAdapterIPAndSubnetMaskPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersWhenAddingVMKernelNetworkAdapter
            Start-DscConfiguration @startDscConfigurationParametersWhenUpdatingVMKernelNetworkAdapterIPAndSubnetMask
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenUpdatingVMKernelNetworkAdapterIPAndSubnetMaskPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configWhenUpdatingVMKernelNetworkAdapterIPAndSubnetMask }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.Name
            $configuration.VssName | Should -Be $script:configurationData.AllNodes.StandardSwitchName
            $configuration.PortGroupName | Should -Be $script:configurationData.AllNodes.PortGroup
            $configuration.Ensure | Should -Be 'Present'
            $configuration.IP | Should -Be $script:configurationData.AllNodes.IP2
            $configuration.SubnetMask | Should -Be $script:configurationData.AllNodes.SubnetMask2
            $configuration.Mac | Should -Be $script:configurationData.AllNodes.Mac
            $configuration.AutomaticIPv6 | Should -Be $script:configurationData.AllNodes.AutomaticIPv6
            $configuration.IPv6 | Should -Be $script:configurationData.AllNodes.IPv6
            $configuration.IPv6ThroughDhcp | Should -Be $script:configurationData.AllNodes.IPv6ThroughDhcp
            $configuration.Mtu | Should -Be $script:configurationData.AllNodes.VMKernelNetworkAdapterMtu
            $configuration.ManagementTrafficEnabled | Should -Be $script:configurationData.AllNodes.ManagementTrafficEnabled
            $configuration.FaultToleranceLoggingEnabled | Should -Be $script:configurationData.AllNodes.FaultToleranceLoggingEnabled
            $configuration.VMotionEnabled | Should -Be $script:configurationData.AllNodes.VMotionEnabled
            $configuration.VsanTrafficEnabled | Should -Be $script:configurationData.AllNodes.VsanTrafficEnabled
            $configuration.Dhcp | Should -Be $false
            $configuration.IPv6Enabled | Should -Be $script:configurationData.AllNodes.IPv6Enabled
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileWhenUpdatingVMKernelNetworkAdapterIPAndSubnetMaskPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configWhenRemovingVMKernelNetworkAdapterAndStandardSwitch `
                -OutputPath $script:mofFileWhenRemovingVMKernelNetworkAdapterAndStandardSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingVMKernelNetworkAdapterAndStandardSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileWhenAddingVMKernelNetworkAdapterPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileWhenUpdatingVMKernelNetworkAdapterIPAndSubnetMaskPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileWhenRemovingVMKernelNetworkAdapterAndStandardSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configWhenUpdatingVMKernelNetworkAdapterIPv6Settings" {
        BeforeAll {
            # Arrange
            & $script:configWhenAddingVMKernelNetworkAdapter `
                -OutputPath $script:mofFileWhenAddingVMKernelNetworkAdapterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configWhenUpdatingVMKernelNetworkAdapterIPv6Settings `
                -OutputPath $script:mofFileWhenUpdatingVMKernelNetworkAdapterIPv6SettingsPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersWhenAddingVMKernelNetworkAdapter = @{
                Path = $script:mofFileWhenAddingVMKernelNetworkAdapterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersWhenUpdatingVMKernelNetworkAdapterIPv6Settings = @{
                Path = $script:mofFileWhenUpdatingVMKernelNetworkAdapterIPv6SettingsPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersWhenAddingVMKernelNetworkAdapter
            Start-DscConfiguration @startDscConfigurationParametersWhenUpdatingVMKernelNetworkAdapterIPv6Settings
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenUpdatingVMKernelNetworkAdapterIPv6SettingsPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configWhenUpdatingVMKernelNetworkAdapterIPv6Settings }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.Name
            $configuration.VssName | Should -Be $script:configurationData.AllNodes.StandardSwitchName
            $configuration.PortGroupName | Should -Be $script:configurationData.AllNodes.PortGroup
            $configuration.Ensure | Should -Be 'Present'
            $configuration.IP | Should -Be $script:configurationData.AllNodes.IP1
            $configuration.SubnetMask | Should -Be $script:configurationData.AllNodes.SubnetMask1
            $configuration.Mac | Should -Be $script:configurationData.AllNodes.Mac
            $configuration.AutomaticIPv6 | Should -Be $false
            $configuration.IPv6 | Should -Be $script:configurationData.AllNodes.DefaultIPv6
            $configuration.IPv6ThroughDhcp | Should -Be $false
            $configuration.Mtu | Should -Be $script:configurationData.AllNodes.VMKernelNetworkAdapterMtu
            $configuration.ManagementTrafficEnabled | Should -Be $script:configurationData.AllNodes.ManagementTrafficEnabled
            $configuration.FaultToleranceLoggingEnabled | Should -Be $script:configurationData.AllNodes.FaultToleranceLoggingEnabled
            $configuration.VMotionEnabled | Should -Be $script:configurationData.AllNodes.VMotionEnabled
            $configuration.VsanTrafficEnabled | Should -Be $script:configurationData.AllNodes.VsanTrafficEnabled
            $configuration.Dhcp | Should -Be $false
            $configuration.IPv6Enabled | Should -Be $false
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileWhenUpdatingVMKernelNetworkAdapterIPv6SettingsPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configWhenRemovingVMKernelNetworkAdapterAndStandardSwitch `
                -OutputPath $script:mofFileWhenRemovingVMKernelNetworkAdapterAndStandardSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingVMKernelNetworkAdapterAndStandardSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileWhenAddingVMKernelNetworkAdapterPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileWhenUpdatingVMKernelNetworkAdapterIPv6SettingsPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileWhenRemovingVMKernelNetworkAdapterAndStandardSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configWhenUpdatingVMKernelNetworkAdapterDhcpAndIPv6" {
        BeforeAll {
            # Arrange
            & $script:configWhenAddingVMKernelNetworkAdapter `
                -OutputPath $script:mofFileWhenAddingVMKernelNetworkAdapterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configWhenUpdatingVMKernelNetworkAdapterDhcpAndIPv6 `
                -OutputPath $script:mofFileWhenUpdatingVMKernelNetworkAdapterDhcpAndIPv6Path `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersWhenAddingVMKernelNetworkAdapter = @{
                Path = $script:mofFileWhenAddingVMKernelNetworkAdapterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersWhenUpdatingVMKernelNetworkAdapterDhcpAndIPv6 = @{
                Path = $script:mofFileWhenUpdatingVMKernelNetworkAdapterDhcpAndIPv6Path
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersWhenAddingVMKernelNetworkAdapter
            Start-DscConfiguration @startDscConfigurationParametersWhenUpdatingVMKernelNetworkAdapterDhcpAndIPv6

            <#
            IP and SubnetMask values on the server are not updated instantly so we
            need to suspend the activity before the execution of the tests begins.
            #>
            Start-Sleep -Seconds 30
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenUpdatingVMKernelNetworkAdapterDhcpAndIPv6Path
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configWhenUpdatingVMKernelNetworkAdapterDhcpAndIPv6 }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.Name
            $configuration.VssName | Should -Be $script:configurationData.AllNodes.StandardSwitchName
            $configuration.PortGroupName | Should -Be $script:configurationData.AllNodes.PortGroup
            $configuration.Ensure | Should -Be 'Present'
            $configuration.IP | Should -Be $script:configurationData.AllNodes.DefaultIP
            $configuration.SubnetMask | Should -Be $script:configurationData.AllNodes.DefaultSubnetMask
            $configuration.Mac | Should -Be $script:configurationData.AllNodes.Mac
            $configuration.AutomaticIPv6 | Should -Be $false
            $configuration.IPv6 | Should -Be $script:configurationData.AllNodes.DefaultIPv6
            $configuration.IPv6ThroughDhcp | Should -Be $false
            $configuration.Mtu | Should -Be $script:configurationData.AllNodes.VMKernelNetworkAdapterMtu
            $configuration.ManagementTrafficEnabled | Should -Be $script:configurationData.AllNodes.ManagementTrafficEnabled
            $configuration.FaultToleranceLoggingEnabled | Should -Be $script:configurationData.AllNodes.FaultToleranceLoggingEnabled
            $configuration.VMotionEnabled | Should -Be $script:configurationData.AllNodes.VMotionEnabled
            $configuration.VsanTrafficEnabled | Should -Be $script:configurationData.AllNodes.VsanTrafficEnabled
            $configuration.Dhcp | Should -Be $script:configurationData.AllNodes.Dhcp
            $configuration.IPv6Enabled | Should -Be $false
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileWhenUpdatingVMKernelNetworkAdapterDhcpAndIPv6Path\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configWhenRemovingVMKernelNetworkAdapterAndStandardSwitch `
                -OutputPath $script:mofFileWhenRemovingVMKernelNetworkAdapterAndStandardSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingVMKernelNetworkAdapterAndStandardSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileWhenAddingVMKernelNetworkAdapterPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileWhenUpdatingVMKernelNetworkAdapterDhcpAndIPv6Path -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileWhenRemovingVMKernelNetworkAdapterAndStandardSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configWhenRemovingVMKernelNetworkAdapter" {
        BeforeAll {
            # Arrange
            & $script:configWhenAddingVMKernelNetworkAdapter `
                -OutputPath $script:mofFileWhenAddingVMKernelNetworkAdapterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configWhenRemovingVMKernelNetworkAdapter `
                -OutputPath $script:mofFileWhenRemovingVMKernelNetworkAdapterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersWhenAddingVMKernelNetworkAdapter = @{
                Path = $script:mofFileWhenAddingVMKernelNetworkAdapterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersWhenRemovingVMKernelNetworkAdapter = @{
                Path = $script:mofFileWhenRemovingVMKernelNetworkAdapterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersWhenAddingVMKernelNetworkAdapter
            Start-DscConfiguration @startDscConfigurationParametersWhenRemovingVMKernelNetworkAdapter
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingVMKernelNetworkAdapterPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configWhenRemovingVMKernelNetworkAdapter }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.Name
            $configuration.VssName | Should -Be $script:configurationData.AllNodes.StandardSwitchName
            $configuration.PortGroupName | Should -Be $script:configurationData.AllNodes.PortGroup
            $configuration.Ensure | Should -Be 'Absent'
            $configuration.IP | Should -BeNullOrEmpty
            $configuration.SubnetMask | Should -BeNullOrEmpty
            $configuration.Mac | Should -BeNullOrEmpty
            $configuration.AutomaticIPv6 | Should -BeNullOrEmpty
            $configuration.IPv6 | Should -BeNullOrEmpty
            $configuration.IPv6ThroughDhcp | Should -BeNullOrEmpty
            $configuration.Mtu | Should -BeNullOrEmpty
            $configuration.ManagementTrafficEnabled | Should -BeNullOrEmpty
            $configuration.FaultToleranceLoggingEnabled | Should -BeNullOrEmpty
            $configuration.VMotionEnabled | Should -BeNullOrEmpty
            $configuration.VsanTrafficEnabled | Should -BeNullOrEmpty
            $configuration.Dhcp | Should -BeNullOrEmpty
            $configuration.IPv6Enabled | Should -BeNullOrEmpty
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileWhenRemovingVMKernelNetworkAdapterPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configWhenRemovingVMKernelNetworkAdapterAndStandardSwitch `
                -OutputPath $script:mofFileWhenRemovingVMKernelNetworkAdapterAndStandardSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingVMKernelNetworkAdapterAndStandardSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileWhenAddingVMKernelNetworkAdapterPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileWhenRemovingVMKernelNetworkAdapterPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileWhenRemovingVMKernelNetworkAdapterAndStandardSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }
}
