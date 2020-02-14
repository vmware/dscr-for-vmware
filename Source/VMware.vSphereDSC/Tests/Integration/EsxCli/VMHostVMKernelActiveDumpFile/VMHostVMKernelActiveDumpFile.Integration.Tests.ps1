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

. "$PSScriptRoot\VMHostVMKernelActiveDumpFile.Integration.Tests.Helpers.ps1"
$script:scsiLunCanonicalName = Get-ScsiLunCanonicalName

$script:dscResourceName = 'VMHostVMKernelActiveDumpFile'
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
            VMHostVMKernelDumpFileResourceName = 'VMHostVMKernelDumpFile'
            VMHostVMKernelActiveDumpFileResourceName = 'VMHostVMKernelActiveDumpFile'
            DatastoreName = 'MyTestVmfsDatastore'
            ScsiLunCanonicalName = $script:scsiLunCanonicalName
            DumpFileName = 'MyTestDumpFile'
            DumpFileSize = 1181
            Force = $true
            EnableVMKernelDumpFile = $true
            DisableVMKernelDumpFile = $false
            UseSmartAlgorithmForVMKernelDumpFile = $true
        }
    )
}

$script:configCreateVmfsDatastore = "$($script:dscResourceName)_CreateVmfsDatastore_Config"
$script:configCreateVMKernelDumpFile = "$($script:dscResourceName)_CreateVMKernelDumpFile_Config"
$script:configEnableVMKernelDumpFile = "$($script:dscResourceName)_EnableVMKernelDumpFile_Config"
$script:configDisableVMKernelDumpFile = "$($script:dscResourceName)_DisableVMKernelDumpFile_Config"
$script:configRemoveVMKernelDumpFile = "$($script:dscResourceName)_RemoveVMKernelDumpFile_Config"
$script:configRemoveVmfsDatastore = "$($script:dscResourceName)_RemoveVmfsDatastore_Config"

. $script:configurationFile -ErrorAction Stop

$script:mofFileCreateVmfsDatastorePath = "$script:integrationTestsFolderPath\$script:configCreateVmfsDatastore\"
$script:mofFileCreateVMKernelDumpFilePath = "$script:integrationTestsFolderPath\$script:configCreateVMKernelDumpFile\"
$script:mofFileEnableVMKernelDumpFilePath = "$script:integrationTestsFolderPath\$script:configEnableVMKernelDumpFile\"
$script:mofFileDisableVMKernelDumpFilePath = "$script:integrationTestsFolderPath\$script:configDisableVMKernelDumpFile\"
$script:mofFileRemoveVMKernelDumpFilePath = "$script:integrationTestsFolderPath\$script:configRemoveVMKernelDumpFile\"
$script:mofFileRemoveVmfsDatastorePath = "$script:integrationTestsFolderPath\$script:configRemoveVmfsDatastore\"

Describe "$($script:dscResourceName)_Integration" {
    Context "When using configuration $script:configEnableVMKernelDumpFile" {
        BeforeAll {
            # Arrange
            & $script:configCreateVmfsDatastore `
                -OutputPath $script:mofFileCreateVmfsDatastorePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configCreateVMKernelDumpFile `
                -OutputPath $script:mofFileCreateVMKernelDumpFilePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configDisableVMKernelDumpFile `
                -OutputPath $script:mofFileDisableVMKernelDumpFilePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configEnableVMKernelDumpFile `
                -OutputPath $script:mofFileEnableVMKernelDumpFilePath `
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

            $startDscConfigurationParametersCreateVMKernelDumpFile = @{
                Path = $script:mofFileCreateVMKernelDumpFilePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersDisableVMKernelDumpFile = @{
                Path = $script:mofFileDisableVMKernelDumpFilePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersEnableVMKernelDumpFile = @{
                Path = $script:mofFileEnableVMKernelDumpFilePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersCreateVmfsDatastore
            Start-DscConfiguration @startDscConfigurationParametersCreateVMKernelDumpFile
            Start-DscConfiguration @startDscConfigurationParametersDisableVMKernelDumpFile
            Start-DscConfiguration @startDscConfigurationParametersEnableVMKernelDumpFile
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileEnableVMKernelDumpFilePath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configEnableVMKernelDumpFile }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.Name | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.Enable | Should -Be $script:configurationData.AllNodes.EnableVMKernelDumpFile
            $configuration.Smart | Should -Be $script:configurationData.AllNodes.UseSmartAlgorithmForVMKernelDumpFile
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileEnableVMKernelDumpFilePath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configRemoveVMKernelDumpFile `
                -OutputPath $script:mofFileRemoveVMKernelDumpFilePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configRemoveVmfsDatastore `
                -OutputPath $script:mofFileRemoveVmfsDatastorePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersRemoveVMKernelDumpFile = @{
                Path = $script:mofFileRemoveVMKernelDumpFilePath
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
            Start-DscConfiguration @startDscConfigurationParametersRemoveVMKernelDumpFile
            Start-DscConfiguration @startDscConfigurationParametersRemoveVmfsDatastore

            Remove-Item -Path $script:mofFileCreateVmfsDatastorePath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileCreateVMKernelDumpFilePath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileDisableVMKernelDumpFilePath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileEnableVMKernelDumpFilePath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVMKernelDumpFilePath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVmfsDatastorePath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }
}
