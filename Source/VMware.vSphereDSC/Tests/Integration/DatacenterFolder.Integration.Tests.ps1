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

$script:dscResourceName = 'DatacenterFolder'
$script:moduleFolderPath = (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase
$script:integrationTestsFolderPath = Join-Path (Join-Path $moduleFolderPath 'Tests') 'Integration'
$script:configurationFile = "$script:integrationTestsFolderPath\Configurations\$($script:dscResourceName)\$($script:dscResourceName)_Config.ps1"

$script:configWhenAddingFolderWithEmptyLocation = "$($script:dscResourceName)_WhenAddingFolderWithEmptyLocation_Config"
$script:configWhenAddingFolderWithLocationWithOneFolder = "$($script:dscResourceName)_WhenAddingFolderWithLocationWithOneFolder_Config"
$script:configWhenAddingFolderWithLocationWithTwoFolders = "$($script:dscResourceName)_WhenAddingFolderWithLocationWithTwoFolders_Config"
$script:configWhenRemovingFolderWithEmptyLocation = "$($script:dscResourceName)_WhenRemovingFolderWithEmptyLocation_Config"
$script:configWhenRemovingFolderWithLocationWithOneFolder = "$($script:dscResourceName)_WhenRemovingFolderWithLocationWithOneFolder_Config"
$script:configWhenRemovingFolderWithLocationWithTwoFolders = "$($script:dscResourceName)_WhenRemovingFolderWithLocationWithTwoFolders_Config"

. $script:configurationFile -Server $Server -User $User -Password $Password

$script:mofFileWhenAddingFolderWithEmptyLocationPath = "$script:integrationTestsFolderPath\$($script:configWhenAddingFolderWithEmptyLocation)\"
$script:mofFileWhenAddingFolderWithLocationWithOneFolderPath = "$script:integrationTestsFolderPath\$($script:configWhenAddingFolderWithLocationWithOneFolder)\"
$script:mofFileWhenAddingFolderWithLocationWithTwoFoldersPath = "$script:integrationTestsFolderPath\$($script:configWhenAddingFolderWithLocationWithTwoFolders)\"
$script:mofFileWhenRemovingFolderWithEmptyLocationPath = "$script:integrationTestsFolderPath\$($script:configWhenRemovingFolderWithEmptyLocation)\"
$script:mofFileWhenRemovingFolderWithLocationWithOneFolderPath = "$script:integrationTestsFolderPath\$($script:configWhenRemovingFolderWithLocationWithOneFolder)\"
$script:mofFileWhenRemovingFolderWithLocationWithTwoFoldersPath = "$script:integrationTestsFolderPath\$($script:configWhenRemovingFolderWithLocationWithTwoFolders)\"

Describe "$($script:dscResourceName)_Integration" {
    Context "When using configuration $($script:configWhenAddingFolderWithEmptyLocation)" {
        BeforeAll {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenAddingFolderWithEmptyLocationPath
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
                Path = $script:mofFileWhenAddingFolderWithEmptyLocationPath
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
            $configuration.Name | Should -Be $script:datacenterFolderName
            $configuration.Location | Should -Be $script:datacenterFolderEmptyLocation
            $configuration.Ensure | Should -Be 'Present'
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange && Act && Assert
            Test-DscConfiguration | Should -Be $true
        }

        AfterAll {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingFolderWithEmptyLocationPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters
        }
    }

    Context "When using configuration $($script:configWhenAddingFolderWithLocationWithOneFolder)" {
        BeforeAll {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenAddingFolderWithLocationWithOneFolderPath
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
                Path = $script:mofFileWhenAddingFolderWithLocationWithOneFolderPath
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

            # Assert
            $datacenterFolderWithEmptyLocationResource.Server | Should -Be $Server
            $datacenterFolderWithEmptyLocationResource.Name | Should -Be $script:datacenterFolderName
            $datacenterFolderWithEmptyLocationResource.Location | Should -Be $script:datacenterFolderEmptyLocation
            $datacenterFolderWithEmptyLocationResource.Ensure | Should -Be 'Present'

            $datacenterFolderWithLocationWithOneFolderResource.Server | Should -Be $Server
            $datacenterFolderWithLocationWithOneFolderResource.Name | Should -Be $script:datacenterFolderName
            $datacenterFolderWithLocationWithOneFolderResource.Location | Should -Be $script:datacenterFolderLocationWithOneFolder
            $datacenterFolderWithLocationWithOneFolderResource.Ensure | Should -Be 'Present'
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

        AfterAll {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingFolderWithLocationWithOneFolderPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters
        }
    }

    Context "When using configuration $($script:configWhenAddingFolderWithLocationWithTwoFolders)" {
        BeforeAll {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenAddingFolderWithLocationWithTwoFoldersPath
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
                Path = $script:mofFileWhenAddingFolderWithLocationWithTwoFoldersPath
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
            $datacenterFolderWithLocationWithTwoFoldersResource = $configuration | Where-Object { $_.ResourceId -eq $script:datacenterFolderWithLocationWithTwoFoldersResourceId }

            # Assert
            $datacenterFolderWithEmptyLocationResource.Server | Should -Be $Server
            $datacenterFolderWithEmptyLocationResource.Name | Should -Be $script:datacenterFolderName
            $datacenterFolderWithEmptyLocationResource.Location | Should -Be $script:datacenterFolderEmptyLocation
            $datacenterFolderWithEmptyLocationResource.Ensure | Should -Be 'Present'

            $datacenterFolderWithLocationWithOneFolderResource.Server | Should -Be $Server
            $datacenterFolderWithLocationWithOneFolderResource.Name | Should -Be $script:datacenterFolderName
            $datacenterFolderWithLocationWithOneFolderResource.Location | Should -Be $script:datacenterFolderLocationWithOneFolder
            $datacenterFolderWithLocationWithOneFolderResource.Ensure | Should -Be 'Present'

            $datacenterFolderWithLocationWithTwoFoldersResource.Server | Should -Be $Server
            $datacenterFolderWithLocationWithTwoFoldersResource.Name | Should -Be $script:datacenterFolderName
            $datacenterFolderWithLocationWithTwoFoldersResource.Location | Should -Be $script:datacenterFolderLocationWithTwoFolders
            $datacenterFolderWithLocationWithTwoFoldersResource.Ensure | Should -Be 'Present'
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

        It "Should have the following dependency: Resource $($script:datacenterFolderWithLocationWithTwoFoldersResourceName) should depend on Resource $($script:datacenterFolderWithLocationWithOneFolderResourceName)" {
            # Arrange && Act
            $datacenterFolderWithLocationWithTwoFoldersResource = Get-DscConfiguration | Where-Object { $_.ResourceId -eq $script:datacenterFolderWithLocationWithTwoFoldersResourceId }

            # Assert
            $datacenterFolderWithLocationWithTwoFoldersResource.DependsOn | Should -Be $script:datacenterFolderWithLocationWithOneFolderResourceId
        }

        AfterAll {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingFolderWithLocationWithTwoFoldersPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters
        }
    }

    Context "When using configuration $($script:configWhenRemovingFolderWithEmptyLocation)" {
        BeforeAll {
            # Arrange
            $startDscConfigurationParametersWhenAddingFolder = @{
                Path = $script:mofFileWhenAddingFolderWithEmptyLocationPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            $startDscConfigurationParametersWhenRemovingFolder = @{
                Path = $script:mofFileWhenRemovingFolderWithEmptyLocationPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersWhenAddingFolder
            Start-DscConfiguration @startDscConfigurationParametersWhenRemovingFolder
        }

        It 'Should compile and apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingFolderWithEmptyLocationPath
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
            $configuration.Name | Should -Be $script:datacenterFolderName
            $configuration.Location | Should -Be $script:datacenterFolderEmptyLocation
            $configuration.Ensure | Should -Be 'Absent'
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange && Act && Assert
            Test-DscConfiguration | Should -Be $true
        }
    }

    Context "When using configuration $($script:configWhenRemovingFolderWithLocationWithOneFolder)" {
        BeforeAll {
            # Arrange
            $startDscConfigurationParametersWhenAddingFolder = @{
                Path = $script:mofFileWhenAddingFolderWithLocationWithOneFolderPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            $startDscConfigurationParametersWhenRemovingFolder = @{
                Path = $script:mofFileWhenRemovingFolderWithLocationWithOneFolderPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersWhenAddingFolder
            Start-DscConfiguration @startDscConfigurationParametersWhenRemovingFolder
        }

        It 'Should compile and apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingFolderWithLocationWithOneFolderPath
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

            # Assert
            $datacenterFolderWithEmptyLocationResource.Server | Should -Be $Server
            $datacenterFolderWithEmptyLocationResource.Name | Should -Be $script:datacenterFolderName
            $datacenterFolderWithEmptyLocationResource.Location | Should -Be $script:datacenterFolderEmptyLocation
            $datacenterFolderWithEmptyLocationResource.Ensure | Should -Be 'Absent'

            $datacenterFolderWithLocationWithOneFolderResource.Server | Should -Be $Server
            $datacenterFolderWithLocationWithOneFolderResource.Name | Should -Be $script:datacenterFolderName
            $datacenterFolderWithLocationWithOneFolderResource.Location | Should -Be $script:datacenterFolderLocationWithOneFolder
            $datacenterFolderWithLocationWithOneFolderResource.Ensure | Should -Be 'Absent'
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange && Act && Assert
            Test-DscConfiguration | Should -Be $true
        }

        It "Should have the following dependency: Resource $($script:datacenterFolderWithEmptyLocationResourceName) should depend on Resource $($script:datacenterFolderWithLocationWithOneFolderResourceName)" {
            # Arrange && Act
            $datacenterFolderWithEmptyLocationResource = Get-DscConfiguration | Where-Object { $_.ResourceId -eq $script:datacenterFolderWithEmptyLocationResourceId }

            # Assert
            $datacenterFolderWithEmptyLocationResource.DependsOn | Should -Be $script:datacenterFolderWithLocationWithOneFolderResourceId
        }
    }

    Context "When using configuration $($script:configWhenRemovingFolderWithLocationWithTwoFolders)" {
        BeforeAll {
            # Arrange
            $startDscConfigurationParametersWhenAddingFolder = @{
                Path = $script:mofFileWhenAddingFolderWithLocationWithTwoFoldersPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            $startDscConfigurationParametersWhenRemovingFolder = @{
                Path = $script:mofFileWhenRemovingFolderWithLocationWithTwoFoldersPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersWhenAddingFolder
            Start-DscConfiguration @startDscConfigurationParametersWhenRemovingFolder
        }

        It 'Should compile and apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingFolderWithLocationWithTwoFoldersPath
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
            $datacenterFolderWithLocationWithTwoFoldersResource = $configuration | Where-Object { $_.ResourceId -eq $script:datacenterFolderWithLocationWithTwoFoldersResourceId }

            # Assert
            $datacenterFolderWithEmptyLocationResource.Server | Should -Be $Server
            $datacenterFolderWithEmptyLocationResource.Name | Should -Be $script:datacenterFolderName
            $datacenterFolderWithEmptyLocationResource.Location | Should -Be $script:datacenterFolderEmptyLocation
            $datacenterFolderWithEmptyLocationResource.Ensure | Should -Be 'Absent'

            $datacenterFolderWithLocationWithOneFolderResource.Server | Should -Be $Server
            $datacenterFolderWithLocationWithOneFolderResource.Name | Should -Be $script:datacenterFolderName
            $datacenterFolderWithLocationWithOneFolderResource.Location | Should -Be $script:datacenterFolderLocationWithOneFolder
            $datacenterFolderWithLocationWithOneFolderResource.Ensure | Should -Be 'Absent'

            $datacenterFolderWithLocationWithTwoFoldersResource.Server | Should -Be $Server
            $datacenterFolderWithLocationWithTwoFoldersResource.Name | Should -Be $script:datacenterFolderName
            $datacenterFolderWithLocationWithTwoFoldersResource.Location | Should -Be $script:datacenterFolderLocationWithTwoFolders
            $datacenterFolderWithLocationWithTwoFoldersResource.Ensure | Should -Be 'Absent'
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange && Act && Assert
            Test-DscConfiguration | Should -Be $true
        }

        It "Should have the following dependency: Resource $($script:datacenterFolderWithLocationWithOneFolderResourceName) should depend on Resource $($script:datacenterFolderWithLocationWithTwoFoldersResourceName)" {
            # Arrange && Act
            $datacenterFolderWithLocationWithOneFolderResource = Get-DscConfiguration | Where-Object { $_.ResourceId -eq $script:datacenterFolderWithLocationWithOneFolderResourceId }

            # Assert
            $datacenterFolderWithLocationWithOneFolderResource.DependsOn | Should -Be $script:datacenterFolderWithLocationWithTwoFoldersResourceId
        }

        It "Should have the following dependency: Resource $($script:datacenterFolderWithEmptyLocationResourceName) should depend on Resource $($script:datacenterFolderWithLocationWithOneFolderResourceName)" {
            # Arrange && Act
            $datacenterFolderWithEmptyLocationResource = Get-DscConfiguration | Where-Object { $_.ResourceId -eq $script:datacenterFolderWithEmptyLocationResourceId }

            # Assert
            $datacenterFolderWithEmptyLocationResource.DependsOn | Should -Be $script:datacenterFolderWithLocationWithOneFolderResourceId
        }
    }
}
