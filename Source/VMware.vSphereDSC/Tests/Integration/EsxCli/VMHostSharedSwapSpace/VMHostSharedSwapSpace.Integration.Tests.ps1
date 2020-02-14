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

. "$PSScriptRoot\VMHostSharedSwapSpace.Integration.Tests.Helpers.ps1"
$script:scsiLunCanonicalName = Get-ScsiLunCanonicalName
$script:initialVMHostSharedSwapSpaceConfiguration = Get-InitialVMHostSharedSwapSpaceConfiguration

$script:dscResourceName = 'VMHostSharedSwapSpace'
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
            VMHostSharedSwapSpaceResourceName = 'VMHostSharedSwapSpace'
            DatastoreName = 'MyTestVmfsDatastore'
            ScsiLunCanonicalName = $script:scsiLunCanonicalName
            InitialDatastoreEnabled = $script:initialVMHostSharedSwapSpaceConfiguration.DatastoreEnabled
            InitialDatastoreName = $script:initialVMHostSharedSwapSpaceConfiguration.DatastoreName
            InitialDatastoreOrder = $script:initialVMHostSharedSwapSpaceConfiguration.DatastoreOrder
            InitialHostCacheEnabled = $script:initialVMHostSharedSwapSpaceConfiguration.HostCacheEnabled
            InitialHostCacheOrder = $script:initialVMHostSharedSwapSpaceConfiguration.HostCacheOrder
            InitialHostLocalSwapEnabled = $script:initialVMHostSharedSwapSpaceConfiguration.HostLocalSwapEnabled
            InitialHostLocalSwapOrder = $script:initialVMHostSharedSwapSpaceConfiguration.HostLocalSwapOrder
            DatastoreEnabled = $true
            DatastoreOrder = 1
            HostCacheEnabled = $false
            HostCacheOrder = 2
            HostLocalSwapEnabled = $false
            HostLocalSwapOrder = 0
        }
    )
}

$script:configCreateVmfsDatastore = "$($script:dscResourceName)_CreateVmfsDatastore_Config"
$script:configModifySharedSwapSpaceConfiguration = "$($script:dscResourceName)_ModifySharedSwapSpaceConfiguration_Config"
$script:configModifySharedSwapSpaceConfigurationToInitialState = "$($script:dscResourceName)_ModifySharedSwapSpaceConfigurationToInitialState_Config"
$script:configRemoveVmfsDatastore = "$($script:dscResourceName)_RemoveVmfsDatastore_Config"

. $script:configurationFile -ErrorAction Stop

$script:mofFileCreateVmfsDatastorePath = "$script:integrationTestsFolderPath\$script:configCreateVmfsDatastore\"
$script:mofFileModifySharedSwapSpaceConfigurationPath = "$script:integrationTestsFolderPath\$script:configModifySharedSwapSpaceConfiguration\"
$script:mofFileModifySharedSwapSpaceConfigurationToInitialStatePath = "$script:integrationTestsFolderPath\$script:configModifySharedSwapSpaceConfigurationToInitialState\"
$script:mofFileRemoveVmfsDatastorePath = "$script:integrationTestsFolderPath\$script:configRemoveVmfsDatastore\"

Describe "$($script:dscResourceName)_Integration" {
    Context "When using configuration $script:configModifySharedSwapSpaceConfiguration" {
        BeforeAll {
            # Arrange
            & $script:configCreateVmfsDatastore `
                -OutputPath $script:mofFileCreateVmfsDatastorePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configModifySharedSwapSpaceConfiguration `
                -OutputPath $script:mofFileModifySharedSwapSpaceConfigurationPath `
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

            $startDscConfigurationParametersModifySharedSwapSpaceConfiguration = @{
                Path = $script:mofFileModifySharedSwapSpaceConfigurationPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersCreateVmfsDatastore
            Start-DscConfiguration @startDscConfigurationParametersModifySharedSwapSpaceConfiguration
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileModifySharedSwapSpaceConfigurationPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configModifySharedSwapSpaceConfiguration }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.Name | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.DatastoreEnabled | Should -Be $script:configurationData.AllNodes.DatastoreEnabled
            $configuration.DatastoreName | Should -Be $script:configurationData.AllNodes.DatastoreName
            $configuration.DatastoreOrder | Should -Be $script:configurationData.AllNodes.DatastoreOrder
            $configuration.HostCacheEnabled | Should -Be $script:configurationData.AllNodes.HostCacheEnabled
            $configuration.HostCacheOrder | Should -Be $script:configurationData.AllNodes.HostCacheOrder
            $configuration.HostLocalSwapEnabled | Should -Be $script:configurationData.AllNodes.HostLocalSwapEnabled
            $configuration.HostLocalSwapOrder | Should -Be $script:configurationData.AllNodes.HostLocalSwapOrder
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileModifySharedSwapSpaceConfigurationPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configModifySharedSwapSpaceConfigurationToInitialState `
                -OutputPath $script:mofFileModifySharedSwapSpaceConfigurationToInitialStatePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configRemoveVmfsDatastore `
                -OutputPath $script:mofFileRemoveVmfsDatastorePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersModifySharedSwapSpaceConfigurationToInitialState = @{
                Path = $script:mofFileModifySharedSwapSpaceConfigurationToInitialStatePath
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
            Start-DscConfiguration @startDscConfigurationParametersModifySharedSwapSpaceConfigurationToInitialState
            Start-DscConfiguration @startDscConfigurationParametersRemoveVmfsDatastore

            Remove-Item -Path $script:mofFileCreateVmfsDatastorePath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileModifySharedSwapSpaceConfigurationPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileModifySharedSwapSpaceConfigurationToInitialStatePath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVmfsDatastorePath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }
}
