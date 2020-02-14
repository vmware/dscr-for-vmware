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

. "$PSScriptRoot\VMHostSNMPAgent.Integration.Tests.Helpers.ps1"
$script:vmHostSNMPAgentInitialConfiguration = Get-InitialVMHostSNMPAgentConfiguration

$script:dscResourceName = 'VMHostSNMPAgent'
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
            VMHostSNMPAgentResourceName = 'VMHostSNMPAgent'
            InitialVMHostSNMPAgentAuthentication = $script:vmHostSNMPAgentInitialConfiguration.Authentication
            InitialVMHostSNMPAgentCommunities = $script:vmHostSNMPAgentInitialConfiguration.Communities
            InitialVMHostSNMPAgentEnableState = $script:vmHostSNMPAgentInitialConfiguration.Enable
            InitialVMHostSNMPAgentEngineId = $script:vmHostSNMPAgentInitialConfiguration.EngineId
            InitialVMHostSNMPAgentHwsrc = $script:vmHostSNMPAgentInitialConfiguration.Hwsrc
            InitialVMHostSNMPAgentLargeStorage = $script:vmHostSNMPAgentInitialConfiguration.LargeStorage
            InitialVMHostSNMPAgentLogLevel = $script:vmHostSNMPAgentInitialConfiguration.LogLevel
            InitialVMHostSNMPAgentNoTraps = $script:vmHostSNMPAgentInitialConfiguration.NoTraps
            InitialVMHostSNMPAgentPort = $script:vmHostSNMPAgentInitialConfiguration.Port
            InitialVMHostSNMPAgentPrivacy = $script:vmHostSNMPAgentInitialConfiguration.Privacy
            InitialVMHostSNMPAgentRemoteUsers = $script:vmHostSNMPAgentInitialConfiguration.RemoteUsers
            InitialVMHostSNMPAgentSysContact = $script:vmHostSNMPAgentInitialConfiguration.SysContact
            InitialVMHostSNMPAgentSysLocation = $script:vmHostSNMPAgentInitialConfiguration.SysLocation
            InitialVMHostSNMPAgentTargets = $script:vmHostSNMPAgentInitialConfiguration.Targets
            InitialVMHostSNMPAgentUsers = $script:vmHostSNMPAgentInitialConfiguration.Users
            InitialVMHostSNMPAgentV3Targets = $script:vmHostSNMPAgentInitialConfiguration.V3Targets
            SNMPAgentAuthenticationProtocol = 'SHA1'
            EnableSNMPAgent = $true
            SNMPAgentHwsrc = 'indications'
            SNMPAgentLargeStorage = $true
            SNMPAgentLogLevel = 'info'
            SNMPAgentPort = 161
            SNMPAgentPrivacyProtocol = 'AES128'
            ResetSNMPAgent = $true
        }
    )
}

$script:configModifyVMHostSNMPAgentConfiguration = "$($script:dscResourceName)_ModifyVMHostSNMPAgentConfiguration_Config"
$script:configModifyVMHostSNMPAgentConfigurationToInitialState = "$($script:dscResourceName)_ModifyVMHostSNMPAgentConfigurationToInitialState_Config"
$script:configResetVMHostSNMPAgentConfiguration = "$($script:dscResourceName)_ResetVMHostSNMPAgentConfiguration_Config"

. $script:configurationFile -ErrorAction Stop

$script:mofFileModifyVMHostSNMPAgentConfigurationPath = "$script:integrationTestsFolderPath\$script:configModifyVMHostSNMPAgentConfiguration\"
$script:mofFileModifyVMHostSNMPAgentConfigurationToInitialStatePath = "$script:integrationTestsFolderPath\$script:configModifyVMHostSNMPAgentConfigurationToInitialState\"
$script:mofFileResetVMHostSNMPAgentConfigurationPath = "$script:integrationTestsFolderPath\$script:configResetVMHostSNMPAgentConfiguration\"

Describe "$($script:dscResourceName)_Integration" {
    Context "When using configuration $script:configModifyVMHostSNMPAgentConfiguration" {
        BeforeAll {
            # Arrange
            & $script:configModifyVMHostSNMPAgentConfiguration `
                -OutputPath $script:mofFileModifyVMHostSNMPAgentConfigurationPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileModifyVMHostSNMPAgentConfigurationPath
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
                Path = $script:mofFileModifyVMHostSNMPAgentConfigurationPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configModifyVMHostSNMPAgentConfiguration }

            # Assert

            # If the initial EngineId value was $null, we need to retrieve the new value to compare it with the output of the DSC Resource.
            $vmHostSNMPAgentEngineId = (Get-InitialVMHostSNMPAgentConfiguration).EngineId

            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.Name | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.Authentication | Should -Be ([string] $script:configurationData.AllNodes.SNMPAgentAuthenticationProtocol)
            $configuration.Communities | Should -Be ([string] $script:configurationData.AllNodes.InitialVMHostSNMPAgentCommunities)
            $configuration.Enable | Should -Be $script:configurationData.AllNodes.EnableSNMPAgent
            $configuration.EngineId | Should -Be ([string] $vmHostSNMPAgentEngineId)
            $configuration.Hwsrc | Should -Be ([string] $script:configurationData.AllNodes.SNMPAgentHwsrc)
            $configuration.LargeStorage | Should -Be $script:configurationData.AllNodes.SNMPAgentLargeStorage
            $configuration.LogLevel | Should -Be ([string] $script:configurationData.AllNodes.SNMPAgentLogLevel)
            $configuration.NoTraps | Should -Be ([string] $script:configurationData.AllNodes.InitialVMHostSNMPAgentNoTraps)
            $configuration.Port | Should -Be $script:configurationData.AllNodes.SNMPAgentPort
            $configuration.Privacy | Should -Be ([string] $script:configurationData.AllNodes.SNMPAgentPrivacyProtocol)
            $configuration.RemoteUsers | Should -Be ([string] $script:configurationData.AllNodes.InitialVMHostSNMPAgentRemoteUsers)
            $configuration.SysContact | Should -Be ([string] $script:configurationData.AllNodes.InitialVMHostSNMPAgentSysContact)
            $configuration.SysLocation | Should -Be ([string] $script:configurationData.AllNodes.InitialVMHostSNMPAgentSysLocation)
            $configuration.Targets | Should -Be ([string] $script:configurationData.AllNodes.InitialVMHostSNMPAgentTargets)
            $configuration.Users | Should -Be ([string] $script:configurationData.AllNodes.InitialVMHostSNMPAgentUsers)
            $configuration.V3Targets | Should -Be ([string] $script:configurationData.AllNodes.InitialVMHostSNMPAgentV3Targets)
            $configuration.Reset | Should -BeNullOrEmpty
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileModifyVMHostSNMPAgentConfigurationPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configResetVMHostSNMPAgentConfiguration `
                -OutputPath $script:mofFileResetVMHostSNMPAgentConfigurationPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configModifyVMHostSNMPAgentConfigurationToInitialState `
                -OutputPath $script:mofFileModifyVMHostSNMPAgentConfigurationToInitialStatePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersResetVMHostSNMPAgentConfiguration = @{
                Path = $script:mofFileResetVMHostSNMPAgentConfigurationPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersModifyVMHostSNMPAgentConfigurationToInitialState = @{
                Path = $script:mofFileModifyVMHostSNMPAgentConfigurationToInitialStatePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersResetVMHostSNMPAgentConfiguration
            Start-DscConfiguration @startDscConfigurationParametersModifyVMHostSNMPAgentConfigurationToInitialState

            Remove-Item -Path $script:mofFileModifyVMHostSNMPAgentConfigurationPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileModifyVMHostSNMPAgentConfigurationToInitialStatePath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileResetVMHostSNMPAgentConfigurationPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }
}
