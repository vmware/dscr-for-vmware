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
    $Name,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string[]]
    $NfsHost,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $NfsPath
)

$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (ConvertTo-SecureString -String $Password -AsPlainText -Force)

$script:dscResourceName = 'NfsDatastore'
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
            NfsDatastoreResourceName = 'NfsDatastore'
            DatastoreName = 'MyTestNfsDatastore'
            NfsPath = $NfsPath
            FileSystemVersion = '3'
            NfsHost = $NfsHost
            ReadWriteAccessMode = 'ReadWrite'
            ReadOnlyAccessMode = 'ReadOnly'
            AuthenticationMethod = 'AUTH_SYS'
            StorageIOControlEnabled = $false
            DefaultCongestionThresholdMillisecond = 30
            MinCongestionThresholdMillisecond = 10
            MaxCongestionThresholdMillisecond = 100
        }
    )
}

$script:configCreateNfsDatastoreWithReadOnlyAccessMode = "$($script:dscResourceName)_CreateNfsDatastoreWithReadOnlyAccessMode_Config"
$script:configCreateNfsDatastoreWithReadWriteAccessModeAndModifyStorageIOControlEnabledAndCongestionThresholdMillisecond = "$($script:dscResourceName)_CreateNfsDatastoreWithReadWriteAccessModeAndModifyStorageIOControlEnabledAndCongestionThresholdMillisecond_Config"
$script:configModifyNfsDatastore = "$($script:dscResourceName)_ModifyNfsDatastore_Config"
$script:configRemoveNfsDatastore = "$($script:dscResourceName)_RemoveNfsDatastore_Config"

. $script:configurationFile -ErrorAction Stop

$script:mofFileCreateNfsDatastoreWithReadOnlyAccessModePath = "$script:integrationTestsFolderPath\$script:configCreateNfsDatastoreWithReadOnlyAccessMode\"
$script:mofFileCreateNfsDatastoreWithReadWriteAccessModeAndModifyStorageIOControlEnabledAndCongestionThresholdMillisecondPath = "$script:integrationTestsFolderPath\$script:configCreateNfsDatastoreWithReadWriteAccessModeAndModifyStorageIOControlEnabledAndCongestionThresholdMillisecond\"
$script:mofFileModifyNfsDatastorePath = "$script:integrationTestsFolderPath\$script:configModifyNfsDatastore\"
$script:mofFileRemoveNfsDatastorePath = "$script:integrationTestsFolderPath\$script:configRemoveNfsDatastore\"

Describe "$($script:dscResourceName)_Integration" {
    Context "When using configuration $script:configCreateNfsDatastoreWithReadOnlyAccessMode" {
        BeforeAll {
            # Arrange
            & $script:configCreateNfsDatastoreWithReadOnlyAccessMode `
                -OutputPath $script:mofFileCreateNfsDatastoreWithReadOnlyAccessModePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileCreateNfsDatastoreWithReadOnlyAccessModePath
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
                Path = $script:mofFileCreateNfsDatastoreWithReadOnlyAccessModePath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configCreateNfsDatastoreWithReadOnlyAccessMode }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.Name | Should -Be $script:configurationData.AllNodes.DatastoreName
            $configuration.Path | Should -Be $script:configurationData.AllNodes.NfsPath
            $configuration.Ensure | Should -Be 'Present'
            $configuration.FileSystemVersion | Should -BeLike "$($script:configurationData.AllNodes.FileSystemVersion)*"
            $configuration.NfsHost | Should -Be $script:configurationData.AllNodes.NfsHost
            $configuration.AccessMode | Should -Be $script:configurationData.AllNodes.ReadOnlyAccessMode
            $configuration.AuthenticationMethod | Should -Be $script:configurationData.AllNodes.AuthenticationMethod
            $configuration.StorageIOControlEnabled | Should -Be $script:configurationData.AllNodes.StorageIOControlEnabled
            $configuration.CongestionThresholdMillisecond | Should -Be $script:configurationData.AllNodes.DefaultCongestionThresholdMillisecond
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileCreateNfsDatastoreWithReadOnlyAccessModePath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configRemoveNfsDatastore `
                -OutputPath $script:mofFileRemoveNfsDatastorePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileRemoveNfsDatastorePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileCreateNfsDatastoreWithReadOnlyAccessModePath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveNfsDatastorePath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configCreateNfsDatastoreWithReadWriteAccessModeAndModifyStorageIOControlEnabledAndCongestionThresholdMillisecond" {
        BeforeAll {
            # Arrange
            & $script:configCreateNfsDatastoreWithReadWriteAccessModeAndModifyStorageIOControlEnabledAndCongestionThresholdMillisecond `
                -OutputPath $script:mofFileCreateNfsDatastoreWithReadWriteAccessModeAndModifyStorageIOControlEnabledAndCongestionThresholdMillisecondPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileCreateNfsDatastoreWithReadWriteAccessModeAndModifyStorageIOControlEnabledAndCongestionThresholdMillisecondPath
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
                Path = $script:mofFileCreateNfsDatastoreWithReadWriteAccessModeAndModifyStorageIOControlEnabledAndCongestionThresholdMillisecondPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configCreateNfsDatastoreWithReadWriteAccessModeAndModifyStorageIOControlEnabledAndCongestionThresholdMillisecond }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.Name | Should -Be $script:configurationData.AllNodes.DatastoreName
            $configuration.Path | Should -Be $script:configurationData.AllNodes.NfsPath
            $configuration.Ensure | Should -Be 'Present'
            $configuration.FileSystemVersion | Should -BeLike "$($script:configurationData.AllNodes.FileSystemVersion)*"
            $configuration.NfsHost | Should -Be $script:configurationData.AllNodes.NfsHost
            $configuration.AccessMode | Should -Be $script:configurationData.AllNodes.ReadWriteAccessMode
            $configuration.AuthenticationMethod | Should -Be $script:configurationData.AllNodes.AuthenticationMethod
            $configuration.StorageIOControlEnabled | Should -BeTrue
            $configuration.CongestionThresholdMillisecond | Should -Be $script:configurationData.AllNodes.MaxCongestionThresholdMillisecond
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileCreateNfsDatastoreWithReadWriteAccessModeAndModifyStorageIOControlEnabledAndCongestionThresholdMillisecondPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configRemoveNfsDatastore `
                -OutputPath $script:mofFileRemoveNfsDatastorePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileRemoveNfsDatastorePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileCreateNfsDatastoreWithReadWriteAccessModeAndModifyStorageIOControlEnabledAndCongestionThresholdMillisecondPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveNfsDatastorePath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configModifyNfsDatastore" {
        BeforeAll {
            # Arrange
            & $script:configCreateNfsDatastoreWithReadWriteAccessModeAndModifyStorageIOControlEnabledAndCongestionThresholdMillisecond `
                -OutputPath $script:mofFileCreateNfsDatastoreWithReadWriteAccessModeAndModifyStorageIOControlEnabledAndCongestionThresholdMillisecondPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configModifyNfsDatastore `
                -OutputPath $script:mofFileModifyNfsDatastorePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersCreateNfsDatastoreWithReadWriteAccessModeAndModifyStorageIOControlEnabledAndCongestionThresholdMillisecond = @{
                Path = $script:mofFileCreateNfsDatastoreWithReadWriteAccessModeAndModifyStorageIOControlEnabledAndCongestionThresholdMillisecondPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersModifyNfsDatastore = @{
                Path = $script:mofFileModifyNfsDatastorePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersCreateNfsDatastoreWithReadWriteAccessModeAndModifyStorageIOControlEnabledAndCongestionThresholdMillisecond
            Start-DscConfiguration @startDscConfigurationParametersModifyNfsDatastore
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileModifyNfsDatastorePath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configModifyNfsDatastore }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.Name | Should -Be $script:configurationData.AllNodes.DatastoreName
            $configuration.Path | Should -Be $script:configurationData.AllNodes.NfsPath
            $configuration.Ensure | Should -Be 'Present'
            $configuration.FileSystemVersion | Should -BeLike "$($script:configurationData.AllNodes.FileSystemVersion)*"
            $configuration.NfsHost | Should -Be $script:configurationData.AllNodes.NfsHost
            $configuration.AccessMode | Should -Be $script:configurationData.AllNodes.ReadWriteAccessMode
            $configuration.AuthenticationMethod | Should -Be $script:configurationData.AllNodes.AuthenticationMethod
            $configuration.StorageIOControlEnabled | Should -Be $script:configurationData.AllNodes.StorageIOControlEnabled
            $configuration.CongestionThresholdMillisecond | Should -Be $script:configurationData.AllNodes.MinCongestionThresholdMillisecond
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileModifyNfsDatastorePath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configRemoveNfsDatastore `
                -OutputPath $script:mofFileRemoveNfsDatastorePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileRemoveNfsDatastorePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileCreateNfsDatastoreWithReadWriteAccessModeAndModifyStorageIOControlEnabledAndCongestionThresholdMillisecondPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileModifyNfsDatastorePath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveNfsDatastorePath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configRemoveNfsDatastore" {
        BeforeAll {
            # Arrange
            & $script:configCreateNfsDatastoreWithReadWriteAccessModeAndModifyStorageIOControlEnabledAndCongestionThresholdMillisecond `
                -OutputPath $script:mofFileCreateNfsDatastoreWithReadWriteAccessModeAndModifyStorageIOControlEnabledAndCongestionThresholdMillisecondPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configRemoveNfsDatastore `
                -OutputPath $script:mofFileRemoveNfsDatastorePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersCreateNfsDatastoreWithReadWriteAccessModeAndModifyStorageIOControlEnabledAndCongestionThresholdMillisecond = @{
                Path = $script:mofFileCreateNfsDatastoreWithReadWriteAccessModeAndModifyStorageIOControlEnabledAndCongestionThresholdMillisecondPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersRemoveNfsDatastore = @{
                Path = $script:mofFileRemoveNfsDatastorePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersCreateNfsDatastoreWithReadWriteAccessModeAndModifyStorageIOControlEnabledAndCongestionThresholdMillisecond
            Start-DscConfiguration @startDscConfigurationParametersRemoveNfsDatastore
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileRemoveNfsDatastorePath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configRemoveNfsDatastore }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.Name | Should -Be $script:configurationData.AllNodes.DatastoreName
            $configuration.Path | Should -Be $script:configurationData.AllNodes.NfsPath
            $configuration.Ensure | Should -Be 'Absent'
            $configuration.FileSystemVersion | Should -Be $script:configurationData.AllNodes.FileSystemVersion
            $configuration.NfsHost | Should -Be $script:configurationData.AllNodes.NfsHost
            $configuration.AccessMode | Should -Be $script:configurationData.AllNodes.ReadWriteAccessMode
            $configuration.AuthenticationMethod | Should -Be $script:configurationData.AllNodes.AuthenticationMethod
            $configuration.StorageIOControlEnabled | Should -Be $script:configurationData.AllNodes.StorageIOControlEnabled
            $configuration.CongestionThresholdMillisecond | Should -Be $script:configurationData.AllNodes.DefaultCongestionThresholdMillisecond
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileRemoveNfsDatastorePath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Act
            Remove-Item -Path $script:mofFileCreateNfsDatastoreWithReadWriteAccessModeAndModifyStorageIOControlEnabledAndCongestionThresholdMillisecondPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveNfsDatastorePath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }
}
