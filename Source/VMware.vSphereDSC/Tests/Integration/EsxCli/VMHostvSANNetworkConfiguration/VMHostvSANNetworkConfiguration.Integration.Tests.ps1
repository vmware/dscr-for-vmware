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

. "$PSScriptRoot\VMHostvSANNetworkConfiguration.Integration.Tests.Helpers.ps1"
$script:vmHostVMKernelNetworkAdapterName = Get-VMKernelNetworkAdapterName

$script:dscResourceName = 'VMHostvSANNetworkConfiguration'
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
            VMHostvSANNetworkConfigurationResourceName = 'VMHostvSANNetworkConfiguration'
            InterfaceName = $script:vmHostVMKernelNetworkAdapterName
            AgentGroupIPv6MulticastAddress = 'ff19::2:3:4'
            AgentGroupMulticastAddress = '224.2.3.4'
            AgentGroupMulticastPort = 23451
            HostUnicastChannelBoundPort = 12321
            MasterGroupIPv6MulticastAddress = 'ff19::1:2:3'
            MasterGroupMulticastAddress = '224.1.2.3'
            MasterGroupMulticastPort = 12345
            MulticastTTL = 5
            TrafficType = 'vsan'
            Force = $true
        }
    )
}

$script:configAddVMHostvSANNetworkConfigurationIPInterface = "$($script:dscResourceName)_AddVMHostvSANNetworkConfigurationIPInterface_Config"
$script:configRemoveVMHostvSANNetworkConfigurationIPInterface = "$($script:dscResourceName)_RemoveVMHostvSANNetworkConfigurationIPInterface_Config"

. $script:configurationFile -ErrorAction Stop

$script:mofFileAddVMHostvSANNetworkConfigurationIPInterfacePath = "$script:integrationTestsFolderPath\$script:configAddVMHostvSANNetworkConfigurationIPInterface\"
$script:mofFileRemoveVMHostvSANNetworkConfigurationIPInterfacePath = "$script:integrationTestsFolderPath\$script:configRemoveVMHostvSANNetworkConfigurationIPInterface\"

Describe "$($script:dscResourceName)_Integration" {
    Context "When using configuration $script:configAddVMHostvSANNetworkConfigurationIPInterface" {
        BeforeAll {
            # Arrange
            & $script:configAddVMHostvSANNetworkConfigurationIPInterface `
                -OutputPath $script:mofFileAddVMHostvSANNetworkConfigurationIPInterfacePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileAddVMHostvSANNetworkConfigurationIPInterfacePath
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
                Path = $script:mofFileAddVMHostvSANNetworkConfigurationIPInterfacePath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configAddVMHostvSANNetworkConfigurationIPInterface }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.Name | Should -Be $script:configurationData.AllNodes.Name
            $configuration.InterfaceName | Should -Be $script:configurationData.AllNodes.InterfaceName
            $configuration.Ensure | Should -Be 'Present'
            $configuration.AgentV6McAddr | Should -Be $script:configurationData.AllNodes.AgentGroupIPv6MulticastAddress
            $configuration.AgentMcAddr | Should -Be $script:configurationData.AllNodes.AgentGroupMulticastAddress
            $configuration.AgentMcPort | Should -Be $script:configurationData.AllNodes.AgentGroupMulticastPort
            $configuration.HostUcPort | Should -Be $script:configurationData.AllNodes.HostUnicastChannelBoundPort
            $configuration.MasterV6McAddr | Should -Be $script:configurationData.AllNodes.MasterGroupIPv6MulticastAddress
            $configuration.MasterMcAddr | Should -Be $script:configurationData.AllNodes.MasterGroupMulticastAddress
            $configuration.MasterMcPort | Should -Be $script:configurationData.AllNodes.MasterGroupMulticastPort
            $configuration.MulticastTtl | Should -Be $script:configurationData.AllNodes.MulticastTTL
            $configuration.TrafficType | Should -Be $script:configurationData.AllNodes.TrafficType
            $configuration.Force | Should -BeNullOrEmpty
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileAddVMHostvSANNetworkConfigurationIPInterfacePath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configRemoveVMHostvSANNetworkConfigurationIPInterface `
                -OutputPath $script:mofFileRemoveVMHostvSANNetworkConfigurationIPInterfacePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileRemoveVMHostvSANNetworkConfigurationIPInterfacePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileAddVMHostvSANNetworkConfigurationIPInterfacePath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVMHostvSANNetworkConfigurationIPInterfacePath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configRemoveVMHostvSANNetworkConfigurationIPInterface" {
        BeforeAll {
            # Arrange
            & $script:configAddVMHostvSANNetworkConfigurationIPInterface `
                -OutputPath $script:mofFileAddVMHostvSANNetworkConfigurationIPInterfacePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configRemoveVMHostvSANNetworkConfigurationIPInterface `
                -OutputPath $script:mofFileRemoveVMHostvSANNetworkConfigurationIPInterfacePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersAddVMHostvSANNetworkConfigurationIPInterface = @{
                Path = $script:mofFileAddVMHostvSANNetworkConfigurationIPInterfacePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersRemoveVMHostvSANNetworkConfigurationIPInterface = @{
                Path = $script:mofFileRemoveVMHostvSANNetworkConfigurationIPInterfacePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersAddVMHostvSANNetworkConfigurationIPInterface
            Start-DscConfiguration @startDscConfigurationParametersRemoveVMHostvSANNetworkConfigurationIPInterface
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileRemoveVMHostvSANNetworkConfigurationIPInterfacePath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configRemoveVMHostvSANNetworkConfigurationIPInterface }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.Name | Should -Be $script:configurationData.AllNodes.Name
            $configuration.InterfaceName | Should -Be $script:configurationData.AllNodes.InterfaceName
            $configuration.Ensure | Should -Be 'Absent'
            $configuration.AgentV6McAddr | Should -Be $script:configurationData.AllNodes.AgentGroupIPv6MulticastAddress
            $configuration.AgentMcAddr | Should -Be $script:configurationData.AllNodes.AgentGroupMulticastAddress
            $configuration.AgentMcPort | Should -Be $script:configurationData.AllNodes.AgentGroupMulticastPort
            $configuration.HostUcPort | Should -Be $script:configurationData.AllNodes.HostUnicastChannelBoundPort
            $configuration.MasterV6McAddr | Should -Be $script:configurationData.AllNodes.MasterGroupIPv6MulticastAddress
            $configuration.MasterMcAddr | Should -Be $script:configurationData.AllNodes.MasterGroupMulticastAddress
            $configuration.MasterMcPort | Should -Be $script:configurationData.AllNodes.MasterGroupMulticastPort
            $configuration.MulticastTtl | Should -Be $script:configurationData.AllNodes.MulticastTTL
            $configuration.TrafficType | Should -Be $script:configurationData.AllNodes.TrafficType
            $configuration.Force | Should -Be $script:configurationData.AllNodes.Force
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileRemoveVMHostvSANNetworkConfigurationIPInterfacePath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange && Act
            Remove-Item -Path $script:mofFileAddVMHostvSANNetworkConfigurationIPInterfacePath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVMHostvSANNetworkConfigurationIPInterfacePath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }
}
