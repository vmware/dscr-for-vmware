<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]
    $Name,

    [Parameter(Mandatory = $true)]
    [string]
    $Server,

    [Parameter(Mandatory = $true)]
    [string]
    $User,

    [Parameter(Mandatory = $true)]
    [string]
    $Password
)

# Mandatory Integration Tests parameter unused so set to null.
$Name = $null

$script:dscResourceName = 'Datacenter'
$script:moduleFolderPath = (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase
$script:integrationTestsFolderPath = Join-Path (Join-Path $moduleFolderPath 'Tests') 'Integration'
$script:configurationFile = "$script:integrationTestsFolderPath\Configurations\$($script:dscResourceName)\$($script:dscResourceName)_Config.ps1"

$script:configWhenAddingDatacenterWithEmptyLocation = "$($script:dscResourceName)_WhenAddingDatacenterWithEmptyLocation_Config"
$script:configWhenAddingDatacenterWithLocationWithOneFolder = "$($script:dscResourceName)_WhenAddingDatacenterWithLocationWithOneFolder_Config"
$script:configWhenAddingDatacenterWithLocationWithTwoFolders = "$($script:dscResourceName)_WhenAddingDatacenterWithLocationWithTwoFolders_Config"
$script:configWhenRemovingDatacenterWithEmptyLocation = "$($script:dscResourceName)_WhenRemovingDatacenterWithEmptyLocation_Config"
$script:configWhenRemovingDatacenterWithLocationWithOneFolder = "$($script:dscResourceName)_WhenRemovingDatacenterWithLocationWithOneFolder_Config"
$script:configWhenRemovingDatacenterWithLocationWithTwoFolders = "$($script:dscResourceName)_WhenRemovingDatacenterWithLocationWithTwoFolders_Config"

. $script:configurationFile -Server $Server -User $User -Password $Password

$script:mofFileWhenAddingDatacenterWithEmptyLocationPath = "$script:integrationTestsFolderPath\$($script:configWhenAddingDatacenterWithEmptyLocation)\"
$script:mofFileWhenAddingDatacenterWithLocationWithOneFolderPath = "$script:integrationTestsFolderPath\$($script:configWhenAddingDatacenterWithLocationWithOneFolder)\"
$script:mofFileWhenAddingDatacenterWithLocationWithTwoFoldersPath = "$script:integrationTestsFolderPath\$($script:configWhenAddingDatacenterWithLocationWithTwoFolders)\"
$script:mofFileWhenRemovingDatacenterWithEmptyLocationPath = "$script:integrationTestsFolderPath\$($script:configWhenRemovingDatacenterWithEmptyLocation)\"
$script:mofFileWhenRemovingDatacenterWithLocationWithOneFolderPath = "$script:integrationTestsFolderPath\$($script:configWhenRemovingDatacenterWithLocationWithOneFolder)\"
$script:mofFileWhenRemovingDatacenterWithLocationWithTwoFoldersPath = "$script:integrationTestsFolderPath\$($script:configWhenRemovingDatacenterWithLocationWithTwoFolders)\"

Describe "$($script:dscResourceName)_Integration" {
    Context "When using configuration $($script:configWhenAddingDatacenterWithEmptyLocation)" {
        BeforeAll {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenAddingDatacenterWithEmptyLocationPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters
        }

        It 'Should compile and apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenAddingDatacenterWithEmptyLocationPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            # Arrange && Act && Assert
            { Get-DscConfiguration } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration and all parameters should match' {
            # Arrange && Act
            $configuration = Get-DscConfiguration

            # Assert
            $configuration.Server | Should -Be $Server
            $configuration.Name | Should -Be $script:datacenterName
            $configuration.Location | Should -Be $script:datacenterEmptyLocation
            $configuration.Ensure | Should -Be 'Present'
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange && Act && Assert
            Test-DscConfiguration | Should -Be $true
        }

        AfterAll {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingDatacenterWithEmptyLocationPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters
        }
    }

    Context "When using configuration $($script:configWhenAddingDatacenterWithLocationWithOneFolder)" {
        BeforeAll {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenAddingDatacenterWithLocationWithOneFolderPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters
        }

        It 'Should compile and apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenAddingDatacenterWithLocationWithOneFolderPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            # Arrange && Act && Assert
            { Get-DscConfiguration } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration and all parameters should match' {
            # Arrange && Act
            $configuration = Get-DscConfiguration

            $datacenterFolderWithEmptyLocationResource = $configuration | Where-Object { $_.ResourceId -eq $script:datacenterFolderWithEmptyLocationResourceId }
            $datacenterWithLocationWithOneFolderResource = $configuration | Where-Object { $_.ResourceId -eq $script:datacenterWithLocationWithOneFolderResourceId }

            # Assert
            $datacenterFolderWithEmptyLocationResource.Server | Should -Be $Server
            $datacenterFolderWithEmptyLocationResource.Name | Should -Be $script:datacenterFolderName
            $datacenterFolderWithEmptyLocationResource.Location | Should -Be $script:datacenterEmptyLocation
            $datacenterFolderWithEmptyLocationResource.Ensure | Should -Be 'Present'

            $datacenterWithLocationWithOneFolderResource.Server | Should -Be $Server
            $datacenterWithLocationWithOneFolderResource.Name | Should -Be $script:datacenterName
            $datacenterWithLocationWithOneFolderResource.Location | Should -Be $script:datacenterLocationWithOneFolder
            $datacenterWithLocationWithOneFolderResource.Ensure | Should -Be 'Present'
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange && Act && Assert
            Test-DscConfiguration | Should -Be $true
        }

        It "Should have the following dependency: Resource $($script:datacenterWithLocationWithOneFolderResourceName) should depend on Resource $($script:datacenterFolderWithEmptyLocationResourceName)" {
            # Arrange && Act
            $datacenterWithLocationWithOneFolderResource = Get-DscConfiguration | Where-Object { $_.ResourceId -eq $script:datacenterWithLocationWithOneFolderResourceId }

            # Assert
            $datacenterWithLocationWithOneFolderResource.DependsOn | Should -Be $script:datacenterFolderWithEmptyLocationResourceId
        }

        AfterAll {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingDatacenterWithLocationWithOneFolderPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters
        }
    }

    Context "When using configuration $($script:configWhenAddingDatacenterWithLocationWithTwoFolders)" {
        BeforeAll {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenAddingDatacenterWithLocationWithTwoFoldersPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters
        }

        It 'Should compile and apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenAddingDatacenterWithLocationWithTwoFoldersPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            # Arrange && Act && Assert
            { Get-DscConfiguration } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration and all parameters should match' {
            # Arrange && Act
            $configuration = Get-DscConfiguration

            $datacenterFolderWithEmptyLocationResource = $configuration | Where-Object { $_.ResourceId -eq $script:datacenterFolderWithEmptyLocationResourceId }
            $datacenterFolderWithLocationWithOneFolderResource = $configuration | Where-Object { $_.ResourceId -eq $script:datacenterFolderWithLocationWithOneFolderResourceId }
            $datacenterWithLocationWithTwoFoldersResource = $configuration | Where-Object { $_.ResourceId -eq $script:datacenterWithLocationWithTwoFoldersResourceId }

            # Assert
            $datacenterFolderWithEmptyLocationResource.Server | Should -Be $Server
            $datacenterFolderWithEmptyLocationResource.Name | Should -Be $script:datacenterFolderName
            $datacenterFolderWithEmptyLocationResource.Location | Should -Be $script:datacenterEmptyLocation
            $datacenterFolderWithEmptyLocationResource.Ensure | Should -Be 'Present'

            $datacenterFolderWithLocationWithOneFolderResource.Server | Should -Be $Server
            $datacenterFolderWithLocationWithOneFolderResource.Name | Should -Be $script:datacenterFolderName
            $datacenterFolderWithLocationWithOneFolderResource.Location | Should -Be $script:datacenterLocationWithOneFolder
            $datacenterFolderWithLocationWithOneFolderResource.Ensure | Should -Be 'Present'

            $datacenterWithLocationWithTwoFoldersResource.Server | Should -Be $Server
            $datacenterWithLocationWithTwoFoldersResource.Name | Should -Be $script:datacenterName
            $datacenterWithLocationWithTwoFoldersResource.Location | Should -Be $script:datacenterLocationWithTwoFolders
            $datacenterWithLocationWithTwoFoldersResource.Ensure | Should -Be 'Present'
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange && Act && Assert
            Test-DscConfiguration | Should -Be $true
        }

        It "Should have the following dependency: Resource $($script:datacenterFolderWithLocationWithOneFolderResourceName) should depend on Resource $($script:datacenterFolderWithEmptyLocationResourceName)" {
            # Arrange && Act
            $datacenterFolderWithLocationWithOneFolderResource = Get-DscConfiguration | Where-Object { $_.ResourceId -eq $script:datacenterFolderWithLocationWithOneFolderResourceId }

            # Assert
            $datacenterFolderWithLocationWithOneFolderResource.DependsOn | Should -Be $script:datacenterFolderWithEmptyLocationResourceId
        }

        It "Should have the following dependency: Resource $($script:datacenterWithLocationWithTwoFoldersResourceName) should depend on Resource $($script:datacenterFolderWithLocationWithOneFolderResourceName)" {
            # Arrange && Act
            $datacenterWithLocationWithTwoFoldersResource = Get-DscConfiguration | Where-Object { $_.ResourceId -eq $script:datacenterWithLocationWithTwoFoldersResourceId }

            # Assert
            $datacenterWithLocationWithTwoFoldersResource.DependsOn | Should -Be $script:datacenterFolderWithLocationWithOneFolderResourceId
        }

        AfterAll {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingDatacenterWithLocationWithTwoFoldersPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters
        }
    }

    Context "When using configuration $($script:configWhenRemovingDatacenterWithEmptyLocation)" {
        BeforeAll {
            # Arrange
            $startDscConfigurationParametersWhenAddingDatacenter = @{
                Path = $script:mofFileWhenAddingDatacenterWithEmptyLocationPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            $startDscConfigurationParametersWhenRemovingDatacenter = @{
                Path = $script:mofFileWhenRemovingDatacenterWithEmptyLocationPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersWhenAddingDatacenter
            Start-DscConfiguration @startDscConfigurationParametersWhenRemovingDatacenter
        }

        It 'Should compile and apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingDatacenterWithEmptyLocationPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            # Arrange && Act && Assert
            { Get-DscConfiguration } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration and all parameters should match' {
            # Arrange && Act
            $configuration = Get-DscConfiguration

            # Assert
            $configuration.Server | Should -Be $Server
            $configuration.Name | Should -Be $script:datacenterName
            $configuration.Location | Should -Be $script:datacenterEmptyLocation
            $configuration.Ensure | Should -Be 'Absent'
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange && Act && Assert
            Test-DscConfiguration | Should -Be $true
        }
    }

    Context "When using configuration $($script:configWhenRemovingDatacenterWithLocationWithOneFolder)" {
        BeforeAll {
            # Arrange
            $startDscConfigurationParametersWhenAddingDatacenter = @{
                Path = $script:mofFileWhenAddingDatacenterWithLocationWithOneFolderPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            $startDscConfigurationParametersWhenRemovingDatacenter = @{
                Path = $script:mofFileWhenRemovingDatacenterWithLocationWithOneFolderPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersWhenAddingDatacenter
            Start-DscConfiguration @startDscConfigurationParametersWhenRemovingDatacenter
        }

        It 'Should compile and apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingDatacenterWithLocationWithOneFolderPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            # Arrange && Act && Assert
            { Get-DscConfiguration } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration and all parameters should match' {
            # Arrange && Act
            $configuration = Get-DscConfiguration

            $datacenterFolderWithEmptyLocationResource = $configuration | Where-Object { $_.ResourceId -eq $script:datacenterFolderWithEmptyLocationResourceId }
            $datacenterWithLocationWithOneFolderResource = $configuration | Where-Object { $_.ResourceId -eq $script:datacenterWithLocationWithOneFolderResourceId }

            # Assert
            $datacenterFolderWithEmptyLocationResource.Server | Should -Be $Server
            $datacenterFolderWithEmptyLocationResource.Name | Should -Be $script:datacenterFolderName
            $datacenterFolderWithEmptyLocationResource.Location | Should -Be $script:datacenterEmptyLocation
            $datacenterFolderWithEmptyLocationResource.Ensure | Should -Be 'Absent'

            $datacenterWithLocationWithOneFolderResource.Server | Should -Be $Server
            $datacenterWithLocationWithOneFolderResource.Name | Should -Be $script:datacenterName
            $datacenterWithLocationWithOneFolderResource.Location | Should -Be $script:datacenterLocationWithOneFolder
            $datacenterWithLocationWithOneFolderResource.Ensure | Should -Be 'Absent'
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange && Act && Assert
            Test-DscConfiguration | Should -Be $true
        }

        It "Should have the following dependency: Resource $($script:datacenterFolderWithEmptyLocationResourceName) should depend on Resource $($script:datacenterWithLocationWithOneFolderResourceName)" {
            # Arrange && Act
            $datacenterFolderWithEmptyLocationResource = Get-DscConfiguration | Where-Object { $_.ResourceId -eq $script:datacenterFolderWithEmptyLocationResourceId }

            # Assert
            $datacenterFolderWithEmptyLocationResource.DependsOn | Should -Be $script:datacenterWithLocationWithOneFolderResourceId
        }
    }

    Context "When using configuration $($script:configWhenRemovingDatacenterWithLocationWithTwoFolders)" {
        BeforeAll {
            # Arrange
            $startDscConfigurationParametersWhenAddingDatacenter = @{
                Path = $script:mofFileWhenAddingDatacenterWithLocationWithTwoFoldersPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            $startDscConfigurationParametersWhenRemovingDatacenter = @{
                Path = $script:mofFileWhenRemovingDatacenterWithLocationWithTwoFoldersPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersWhenAddingDatacenter
            Start-DscConfiguration @startDscConfigurationParametersWhenRemovingDatacenter
        }

        It 'Should compile and apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingDatacenterWithLocationWithTwoFoldersPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            # Arrange && Act && Assert
            { Get-DscConfiguration } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration and all parameters should match' {
            # Arrange && Act
            $configuration = Get-DscConfiguration

            $datacenterFolderWithEmptyLocationResource = $configuration | Where-Object { $_.ResourceId -eq $script:datacenterFolderWithEmptyLocationResourceId }
            $datacenterFolderWithLocationWithOneFolderResource = $configuration | Where-Object { $_.ResourceId -eq $script:datacenterFolderWithLocationWithOneFolderResourceId }
            $datacenterWithLocationWithTwoFoldersResource = $configuration | Where-Object { $_.ResourceId -eq $script:datacenterWithLocationWithTwoFoldersResourceId }

            # Assert
            $datacenterFolderWithEmptyLocationResource.Server | Should -Be $Server
            $datacenterFolderWithEmptyLocationResource.Name | Should -Be $script:datacenterFolderName
            $datacenterFolderWithEmptyLocationResource.Location | Should -Be $script:datacenterEmptyLocation
            $datacenterFolderWithEmptyLocationResource.Ensure | Should -Be 'Absent'

            $datacenterFolderWithLocationWithOneFolderResource.Server | Should -Be $Server
            $datacenterFolderWithLocationWithOneFolderResource.Name | Should -Be $script:datacenterFolderName
            $datacenterFolderWithLocationWithOneFolderResource.Location | Should -Be $script:datacenterLocationWithOneFolder
            $datacenterFolderWithLocationWithOneFolderResource.Ensure | Should -Be 'Absent'

            $datacenterWithLocationWithTwoFoldersResource.Server | Should -Be $Server
            $datacenterWithLocationWithTwoFoldersResource.Name | Should -Be $script:datacenterName
            $datacenterWithLocationWithTwoFoldersResource.Location | Should -Be $script:datacenterLocationWithTwoFolders
            $datacenterWithLocationWithTwoFoldersResource.Ensure | Should -Be 'Absent'
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange && Act && Assert
            Test-DscConfiguration | Should -Be $true
        }

        It "Should have the following dependency: Resource $($script:datacenterFolderWithLocationWithOneFolderResourceName) should depend on Resource $($script:datacenterWithLocationWithTwoFoldersResourceName)" {
            # Arrange && Act
            $datacenterFolderWithLocationWithOneFolderResource = Get-DscConfiguration | Where-Object { $_.ResourceId -eq $script:datacenterFolderWithLocationWithOneFolderResourceId }

            # Assert
            $datacenterFolderWithLocationWithOneFolderResource.DependsOn | Should -Be $script:datacenterWithLocationWithTwoFoldersResourceId
        }

        It "Should have the following dependency: Resource $($script:datacenterFolderWithEmptyLocationResourceName) should depend on Resource $($script:datacenterFolderWithLocationWithOneFolderResourceName)" {
            # Arrange && Act
            $datacenterFolderWithEmptyLocationResource = Get-DscConfiguration | Where-Object { $_.ResourceId -eq $script:datacenterFolderWithEmptyLocationResourceId }

            # Assert
            $datacenterFolderWithEmptyLocationResource.DependsOn | Should -Be $script:datacenterFolderWithLocationWithOneFolderResourceId
        }
    }
}
