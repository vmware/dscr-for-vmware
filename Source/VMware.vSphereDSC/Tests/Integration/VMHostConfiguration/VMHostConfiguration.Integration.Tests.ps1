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

. "$PSScriptRoot\VMHostConfiguration.Integration.Tests.Helpers.ps1"
$script:scsiLunCanonicalName = Get-ScsiLunCanonicalName
$script:initialVMHostConfiguration = Get-InitialVMHostConfiguration

$script:dscResourceName = 'VMHostConfiguration'
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
            VmfsDatastoreResourceName = 'VmfsDatastore'
            VMHostConfigurationResourceName = 'VMHostConfiguration'
            DatastoreName = 'MyTestVmfsDatastore'
            ScsiLunCanonicalName = $script:scsiLunCanonicalName
            InitialVMHostState = $script:initialVMHostConfiguration.State
            InitialVMHostLicenseKey = $script:initialVMHostConfiguration.LicenseKey
            InitialVMHostTimeZoneName = $script:initialVMHostConfiguration.TimeZoneName
            InitialVMSwapfileDatastoreName = $script:initialVMHostConfiguration.VMSwapfileDatastoreName
            InitialVMSwapfilePolicy = $script:initialVMHostConfiguration.VMSwapfilePolicy
            InitialHostProfileName = $script:initialVMHostConfiguration.HostProfileName
            LicenseKey = '00000-00000-00000-00000-00000'
            TimeZoneName = 'UTC'
            VMSwapfilePolicy = 'InHostDatastore'
            HostProfileName = 'MyTestHostProfile'
        }
    )
}

$script:configCreateVmfsDatastore = "$($script:dscResourceName)_CreateVmfsDatastore_Config"
$script:configModifyVMHostHostProfileAssociation = "$($script:dscResourceName)_ModifyVMHostHostProfileAssociation_Config"
$script:configModifyVMHostLicenseKeyTimeZoneVMSwapfileDatastoreAndPolicy = "$($script:dscResourceName)_ModifyVMHostLicenseKeyTimeZoneVMSwapfileDatastoreAndPolicy_Config"
$script:configModifyVMHostConfigurationToInitialState = "$($script:dscResourceName)_ModifyVMHostConfigurationToInitialState_Config"
$script:configRemoveVmfsDatastore = "$($script:dscResourceName)_RemoveVmfsDatastore_Config"

. $script:configurationFile -ErrorAction Stop

$script:mofFileCreateVmfsDatastorePath = "$script:integrationTestsFolderPath\$script:configCreateVmfsDatastore\"
$script:mofFileModifyVMHostHostProfileAssociationPath = "$script:integrationTestsFolderPath\$script:configModifyVMHostHostProfileAssociation\"
$script:mofFileModifyVMHostLicenseKeyTimeZoneVMSwapfileDatastoreAndPolicyPath = "$script:integrationTestsFolderPath\$script:configModifyVMHostLicenseKeyTimeZoneVMSwapfileDatastoreAndPolicy\"
$script:mofFileModifyVMHostConfigurationToInitialStatePath = "$script:integrationTestsFolderPath\$script:configModifyVMHostConfigurationToInitialState\"
$script:mofFileRemoveVmfsDatastorePath = "$script:integrationTestsFolderPath\$script:configRemoveVmfsDatastore\"

Describe "$($script:dscResourceName)_Integration" {
    Context "When using configuration $script:configModifyVMHostLicenseKeyTimeZoneVMSwapfileDatastoreAndPolicy" {
        BeforeAll {
            # Arrange
            & $script:configCreateVmfsDatastore `
                -OutputPath $script:mofFileCreateVmfsDatastorePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configModifyVMHostLicenseKeyTimeZoneVMSwapfileDatastoreAndPolicy `
                -OutputPath $script:mofFileModifyVMHostLicenseKeyTimeZoneVMSwapfileDatastoreAndPolicyPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersCreateVmfsDatastore = @{
                Path = $script:mofFileCreateVmfsDatastorePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersModifyVMHostLicenseKeyTimeZoneVMSwapfileDatastoreAndPolicy = @{
                Path = $script:mofFileModifyVMHostLicenseKeyTimeZoneVMSwapfileDatastoreAndPolicyPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersCreateVmfsDatastore
            Start-DscConfiguration @startDscConfigurationParametersModifyVMHostLicenseKeyTimeZoneVMSwapfileDatastoreAndPolicy
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileModifyVMHostLicenseKeyTimeZoneVMSwapfileDatastoreAndPolicyPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configModifyVMHostLicenseKeyTimeZoneVMSwapfileDatastoreAndPolicy }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.Name | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.State | Should -Be $script:configurationData.AllNodes.InitialVMHostState
            $configuration.Evacuate | Should -BeNullOrEmpty
            $configuration.VsanDataMigrationMode | Should -Be 'Unset'
            $configuration.LicenseKey | Should -Be $script:configurationData.AllNodes.LicenseKey
            $configuration.TimeZoneName | Should -Be $script:configurationData.AllNodes.TimeZoneName
            $configuration.VMSwapfileDatastoreName | Should -Be $script:configurationData.AllNodes.DatastoreName
            $configuration.VMSwapfilePolicy | Should -Be $script:configurationData.AllNodes.VMSwapfilePolicy
            $configuration.HostProfileName | Should -Be $script:configurationData.AllNodes.InitialHostProfileName
            $configuration.KmsClusterName | Should -BeNullOrEmpty
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileModifyVMHostLicenseKeyTimeZoneVMSwapfileDatastoreAndPolicyPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configModifyVMHostConfigurationToInitialState `
                -OutputPath $script:mofFileModifyVMHostConfigurationToInitialStatePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configRemoveVmfsDatastore `
                -OutputPath $script:mofFileRemoveVmfsDatastorePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersModifyVMHostConfigurationToInitialState = @{
                Path = $script:mofFileModifyVMHostConfigurationToInitialStatePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersRemoveVmfsDatastore = @{
                Path = $script:mofFileRemoveVmfsDatastorePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Restore-VMHostVMSwapfileDatastoreToInitialState

            Start-DscConfiguration @startDscConfigurationParametersModifyVMHostConfigurationToInitialState
            Start-DscConfiguration @startDscConfigurationParametersRemoveVmfsDatastore

            Remove-Item -Path $script:mofFileCreateVmfsDatastorePath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileModifyVMHostLicenseKeyTimeZoneVMSwapfileDatastoreAndPolicyPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileModifyVMHostConfigurationToInitialStatePath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVmfsDatastorePath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configModifyVMHostHostProfileAssociation" {
        BeforeAll {
            # Arrange
            & $script:configModifyVMHostHostProfileAssociation `
                -OutputPath $script:mofFileModifyVMHostHostProfileAssociationPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileModifyVMHostHostProfileAssociationPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            New-HostProfile

            Start-DscConfiguration @startDscConfigurationParameters
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileModifyVMHostHostProfileAssociationPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configModifyVMHostHostProfileAssociation }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.Name | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.State | Should -Be $script:configurationData.AllNodes.InitialVMHostState
            $configuration.Evacuate | Should -BeNullOrEmpty
            $configuration.VsanDataMigrationMode | Should -Be 'Unset'
            $configuration.LicenseKey | Should -Be $script:configurationData.AllNodes.InitialVMHostLicenseKey
            $configuration.TimeZoneName | Should -Be $script:configurationData.AllNodes.InitialVMHostTimeZoneName
            $configuration.VMSwapfileDatastoreName | Should -Be $script:configurationData.AllNodes.InitialVMSwapfileDatastoreName
            $configuration.VMSwapfilePolicy | Should -Be $script:configurationData.AllNodes.InitialVMSwapfilePolicy
            $configuration.HostProfileName | Should -Be $script:configurationData.AllNodes.HostProfileName
            $configuration.KmsClusterName | Should -BeNullOrEmpty
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileModifyVMHostHostProfileAssociationPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configModifyVMHostConfigurationToInitialState `
                -OutputPath $script:mofFileModifyVMHostConfigurationToInitialStatePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileModifyVMHostConfigurationToInitialStatePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-HostProfile

            Remove-Item -Path $script:mofFileModifyVMHostHostProfileAssociationPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileModifyVMHostConfigurationToInitialStatePath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }
}
