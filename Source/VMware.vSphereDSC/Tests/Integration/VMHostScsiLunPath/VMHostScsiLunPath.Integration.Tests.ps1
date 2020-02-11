<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

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

. "$PSScriptRoot\VMHostScsiLunPath.Integration.Tests.Helpers.ps1"
$script:vmHostScsiLunPathInitialConfiguration = Get-VMHostScsiLunPathInitialConfiguration

$script:dscResourceName = 'VMHostScsiLunPath'
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
            VMHostScsiLunPathResourceName = 'VMHostScsiLunPath'
            ScsiLunPathName = $script:vmHostScsiLunPathInitialConfiguration.ScsiLunPathName
            ScsiLunCanonicalName = $script:vmHostScsiLunPathInitialConfiguration.ScsiLunCanonicalName
            InitialScsiLunPathState = $script:vmHostScsiLunPathInitialConfiguration.State
            InitialScsiLunPathPreferred = $script:vmHostScsiLunPathInitialConfiguration.Preferred
            ScsiLunPathActive = $true
            ScsiLunPathPreferred = $true
        }
    )
}

$script:configConfigureScsiLunPathToBeActiveAndPreferred = "$($script:dscResourceName)_ConfigureScsiLunPathToBeActiveAndPreferred_Config"
$script:configConfigureScsiLunPathToInitialState = "$($script:dscResourceName)_ConfigureScsiLunPathToInitialState_Config"

. $script:configurationFile -ErrorAction Stop

$script:mofFileConfigureScsiLunPathToBeActiveAndPreferredPath = "$script:integrationTestsFolderPath\$script:configConfigureScsiLunPathToBeActiveAndPreferred\"
$script:mofFileConfigureScsiLunPathToInitialStatePath = "$script:integrationTestsFolderPath\$script:configConfigureScsiLunPathToInitialState\"

Describe "$($script:dscResourceName)_Integration" {
    Context "When using configuration $script:configConfigureScsiLunPathToBeActiveAndPreferred" {
        BeforeAll {
            # Arrange
            & $script:configConfigureScsiLunPathToBeActiveAndPreferred `
                -OutputPath $script:mofFileConfigureScsiLunPathToBeActiveAndPreferredPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileConfigureScsiLunPathToBeActiveAndPreferredPath
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
                Path = $script:mofFileConfigureScsiLunPathToBeActiveAndPreferredPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configConfigureScsiLunPathToBeActiveAndPreferred }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.Name | Should -Be $script:configurationData.AllNodes.ScsiLunPathName
            $configuration.ScsiLunCanonicalName | Should -Be $script:configurationData.AllNodes.ScsiLunCanonicalName
            $configuration.Active | Should -Be $script:configurationData.AllNodes.ScsiLunPathActive
            $configuration.Preferred | Should -Be $script:configurationData.AllNodes.ScsiLunPathPreferred
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileConfigureScsiLunPathToBeActiveAndPreferredPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configConfigureScsiLunPathToInitialState `
                -OutputPath $script:mofFileConfigureScsiLunPathToInitialStatePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileConfigureScsiLunPathToInitialStatePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileConfigureScsiLunPathToBeActiveAndPreferredPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileConfigureScsiLunPathToInitialStatePath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }
}
