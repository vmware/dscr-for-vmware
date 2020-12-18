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

<#
    The VMHostStorage DSC Resource Integration Tests require a vCenter Server with at
    least one Datacenter and at least one VMHost located in that Datacenter.
#>

$newObjectParamsForCredential = @{
    TypeName = 'System.Management.Automation.PSCredential'
    ArgumentList = @(
        $User,
        (ConvertTo-SecureString -String $Password -AsPlainText -Force)
    )
}
$script:Credential = New-Object @newObjectParamsForCredential

$script:DscResourceName = 'VMHostStorage'
$script:ConfigurationsPath = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DscResourceName)_Config.ps1"

. "$PSScriptRoot\$script:DscResourceName.Integration.Tests.Helpers.ps1"
Test-Setup

$script:ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
            Server = $Server
            Credential = $script:Credential
            VMHostName = $Name
            VMHostStorageDscResourceName = 'VMHostStorage'
            InitialSoftwareIScsiEnabled = $script:InitialSoftwareIScsiEnabled
            SoftwareIScsiEnabled = $true
            SoftwareIScsiDisabled = $false
        }
    )
}

. $script:ConfigurationsPath -Verbose:$true -ErrorAction Stop

$script:EnableSoftwareIscsiConfigurationName = "$($script:DscResourceName)_EnableSoftwareIscsi_Config"
$script:DisableSoftwareIscsiConfigurationName = "$($script:DscResourceName)_DisableSoftwareIscsi_Config"
$script:SoftwareIscsiToInitialStateConfigurationName = "$($script:DscResourceName)_SoftwareIscsiToInitialState_Config"

$script:EnableSoftwareIscsiMofFilePath = Join-Path -Path $PSScriptRoot -ChildPath $script:EnableSoftwareIscsiConfigurationName
$script:DisableSoftwareIscsiMofFilePath = Join-Path -Path $PSScriptRoot -ChildPath $script:DisableSoftwareIscsiConfigurationName
$script:SoftwareIscsiToInitialStateMofFilePath = Join-Path -Path $PSScriptRoot -ChildPath $script:SoftwareIscsiToInitialStateConfigurationName

Describe "$($script:DscResourceName)_Integration" {
    Context 'When enabling software iSCSI' {
        BeforeAll {
            # Arrange
            & $script:DisableSoftwareIscsiConfigurationName `
                -OutputPath $script:DisableSoftwareIscsiMofFilePath `
                -ConfigurationData $script:ConfigurationData `
                -ErrorAction Stop

            $startDscConfigurationParamsDisableSoftwareIscsi = @{
                Path = $script:DisableSoftwareIscsiMofFilePath
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParamsDisableSoftwareIscsi } | Should -Not -Throw

            It 'Should compile and apply the MOF without throwing' {
                # Arrange
                & $script:EnableSoftwareIscsiConfigurationName `
                    -OutputPath $script:EnableSoftwareIscsiMofFilePath `
                    -ConfigurationData $script:ConfigurationData `
                    -ErrorAction Stop

                $startDscConfigurationParamsEnableSoftwareIscsi = @{
                    Path = $script:EnableSoftwareIscsiMofFilePath
                    ComputerName = $script:ConfigurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act && Assert
                { Start-DscConfiguration @startDscConfigurationParamsEnableSoftwareIscsi } | Should -Not -Throw
            }
        }

        It 'Should be able to call Test-DscConfiguration without throwing' {
            # Arrange
            $joinPathParams = @{
                Path = $script:EnableSoftwareIscsiMofFilePath
                ChildPath = "$($script:ConfigurationData.AllNodes.NodeName).mof"
            }

            $testDscConfigurationParams = @{
                ReferenceConfiguration = Join-Path @joinPathParams
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Test-DscConfiguration @testDscConfigurationParams } | Should -Not -Throw
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $joinPathParams = @{
                Path = $script:EnableSoftwareIscsiMofFilePath
                ChildPath = "$($script:ConfigurationData.AllNodes.NodeName).mof"
            }

            $testDscConfigurationParams = @{
                ReferenceConfiguration = Join-Path @joinPathParams
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParams).InDesiredState | Should -BeTrue
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            # Arrange && Act && Assert
            { Get-DscConfiguration -Verbose:$true -ErrorAction Stop } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration and all parameters should match' {
            # Arrange
            $whereObjectParams = @{
                FilterScript = {
                    $_.ConfigurationName -eq $script:EnableSoftwareIscsiConfigurationName
                }
            }

            # Act
            $VMHostStorageDscResource = Get-DscConfiguration -Verbose:$true -ErrorAction Stop | Where-Object @whereObjectParams

            # Assert
            $VMHostStorageDscResource.Server | Should -Be $script:ConfigurationData.AllNodes.Server
            $VMHostStorageDscResource.Name | Should -Be $script:ConfigurationData.AllNodes.VMHostName
            $VMHostStorageDscResource.Enabled | Should -Be $script:ConfigurationData.AllNodes.SoftwareIScsiEnabled
        }

        AfterAll {
            # Arrange
            & $script:SoftwareIscsiToInitialStateConfigurationName `
                -OutputPath $script:SoftwareIscsiToInitialStateMofFilePath `
                -ConfigurationData $script:ConfigurationData `
                -ErrorAction Stop

            $startDscConfigurationParamsSoftwareIscsiToInitialState = @{
                Path = $script:SoftwareIscsiToInitialStateMofFilePath
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParamsSoftwareIscsiToInitialState } | Should -Not -Throw

            Remove-Item -Path $script:DisableSoftwareIscsiMofFilePath -Recurse -Confirm:$false -Verbose:$true -ErrorAction Stop
            Remove-Item -Path $script:EnableSoftwareIscsiMofFilePath -Recurse -Confirm:$false -Verbose:$true -ErrorAction Stop
            Remove-Item -Path $script:SoftwareIscsiToInitialStateMofFilePath -Recurse -Confirm:$false -Verbose:$true -ErrorAction Stop
        }
    }

    Context 'When disabling software iSCSI' {
        BeforeAll {
            # Arrange
            & $script:EnableSoftwareIscsiConfigurationName `
                -OutputPath $script:EnableSoftwareIscsiMofFilePath `
                -ConfigurationData $script:ConfigurationData `
                -ErrorAction Stop

            $startDscConfigurationParamsEnableSoftwareIscsi = @{
                Path = $script:EnableSoftwareIscsiMofFilePath
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParamsEnableSoftwareIscsi } | Should -Not -Throw

            It 'Should compile and apply the MOF without throwing' {
                # Arrange
                & $script:DisableSoftwareIscsiConfigurationName `
                    -OutputPath $script:DisableSoftwareIscsiMofFilePath `
                    -ConfigurationData $script:ConfigurationData `
                    -ErrorAction Stop

                $startDscConfigurationParamsDisableSoftwareIscsi = @{
                    Path = $script:DisableSoftwareIscsiMofFilePath
                    ComputerName = $script:ConfigurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act && Assert
                { Start-DscConfiguration @startDscConfigurationParamsDisableSoftwareIscsi } | Should -Not -Throw
            }
        }

        It 'Should be able to call Test-DscConfiguration without throwing' {
            # Arrange
            $joinPathParams = @{
                Path = $script:DisableSoftwareIscsiMofFilePath
                ChildPath = "$($script:ConfigurationData.AllNodes.NodeName).mof"
            }

            $testDscConfigurationParams = @{
                ReferenceConfiguration = Join-Path @joinPathParams
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Test-DscConfiguration @testDscConfigurationParams } | Should -Not -Throw
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $joinPathParams = @{
                Path = $script:DisableSoftwareIscsiMofFilePath
                ChildPath = "$($script:ConfigurationData.AllNodes.NodeName).mof"
            }

            $testDscConfigurationParams = @{
                ReferenceConfiguration = Join-Path @joinPathParams
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParams).InDesiredState | Should -BeTrue
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            # Arrange && Act && Assert
            { Get-DscConfiguration -Verbose:$true -ErrorAction Stop } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration and all parameters should match' {
            # Arrange
            $whereObjectParams = @{
                FilterScript = {
                    $_.ConfigurationName -eq $script:DisableSoftwareIscsiConfigurationName
                }
            }

            # Act
            $VMHostStorageDscResource = Get-DscConfiguration -Verbose:$true -ErrorAction Stop | Where-Object @whereObjectParams

            # Assert
            $VMHostStorageDscResource.Server | Should -Be $script:ConfigurationData.AllNodes.Server
            $VMHostStorageDscResource.Name | Should -Be $script:ConfigurationData.AllNodes.VMHostName
            $VMHostStorageDscResource.Enabled | Should -Be $script:ConfigurationData.AllNodes.SoftwareIScsiDisabled
        }

        AfterAll {
            # Arrange
            & $script:SoftwareIscsiToInitialStateConfigurationName `
                -OutputPath $script:SoftwareIscsiToInitialStateMofFilePath `
                -ConfigurationData $script:ConfigurationData `
                -ErrorAction Stop

            $startDscConfigurationParamsSoftwareIscsiToInitialState = @{
                Path = $script:SoftwareIscsiToInitialStateMofFilePath
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParamsSoftwareIscsiToInitialState } | Should -Not -Throw

            Remove-Item -Path $script:EnableSoftwareIscsiMofFilePath -Recurse -Confirm:$false -Verbose:$true -ErrorAction Stop
            Remove-Item -Path $script:DisableSoftwareIscsiMofFilePath -Recurse -Confirm:$false -Verbose:$true -ErrorAction Stop
            Remove-Item -Path $script:SoftwareIscsiToInitialStateMofFilePath -Recurse -Confirm:$false -Verbose:$true -ErrorAction Stop
        }
    }
}
