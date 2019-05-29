<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

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

$script:datacenterName = 'MyTestDatacenter'
$script:folderName = 'MyTestDatacenterFolder'
$script:emptyLocation = [string]::Empty
$script:locationWithOneFolder = $script:folderName
$script:locationWithTwoFolders = "$script:folderName/$script:folderName"

$script:folderWithEmptyLocationResourceName = 'DatacenterFolder_With_EmptyLocation'
$script:folderWithLocationWithOneFolderResourceName = 'DatacenterFolder_With_LocationWithOneFolder'

$script:folderWithEmptyLocationResourceId = "[DatacenterFolder]$script:folderWithEmptyLocationResourceName"
$script:folderWithLocationWithOneFolderResourceId = "[DatacenterFolder]$script:folderWithLocationWithOneFolderResourceName"

$script:datacenterWithEmptyLocationResourceName = 'Datacenter_With_EmptyLocation'
$script:datacenterWithLocationWithOneFolderResourceName = 'Datacenter_With_LocationWithOneFolder'
$script:datacenterWithLocationWithTwoFoldersResourceName = 'Datacenter_With_LocationWithTwoFolders'

$script:datacenterWithLocationWithOneFolderResourceId = "[Datacenter]$script:datacenterWithLocationWithOneFolderResourceName"
$script:datacenterWithLocationWithTwoFoldersResourceId = "[Datacenter]$script:datacenterWithLocationWithTwoFoldersResourceName"

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
            $configuration.Location | Should -Be $script:emptyLocation
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
            $configurations = Get-DscConfiguration

            $folderWithEmptyLocation = $configurations | Where-Object { $_.ResourceId -eq $script:folderWithEmptyLocationResourceId }
            $datacenterWithLocationWithOneFolder = $configurations | Where-Object { $_.ResourceId -eq $script:datacenterWithLocationWithOneFolderResourceId }

            # Assert
            $folderWithEmptyLocation.Server | Should -Be $Server
            $folderWithEmptyLocation.Name | Should -Be $script:folderName
            $folderWithEmptyLocation.Location | Should -Be $script:emptyLocation
            $folderWithEmptyLocation.Ensure | Should -Be 'Present'

            $datacenterWithLocationWithOneFolder.Server | Should -Be $Server
            $datacenterWithLocationWithOneFolder.Name | Should -Be $script:datacenterName
            $datacenterWithLocationWithOneFolder.Location | Should -Be $script:locationWithOneFolder
            $datacenterWithLocationWithOneFolder.Ensure | Should -Be 'Present'
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange && Act && Assert
            Test-DscConfiguration | Should -Be $true
        }

        It "Should have the following dependency: Resource $($script:datacenterWithLocationWithOneFolderResourceName) should depend on Resource $($script:folderWithEmptyLocationResourceName)" {
            # Arrange && Act
            $datacenterWithLocationWithOneFolder = Get-DscConfiguration | Where-Object { $_.ResourceId -eq $script:datacenterWithLocationWithOneFolderResourceId }

            # Assert
            $datacenterWithLocationWithOneFolder.DependsOn | Should -Be $script:folderWithEmptyLocationResourceId
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
            $configurations = Get-DscConfiguration

            $folderWithEmptyLocation = $configurations | Where-Object { $_.ResourceId -eq $script:folderWithEmptyLocationResourceId }
            $folderWithLocationWithOneFolder = $configurations | Where-Object { $_.ResourceId -eq $script:folderWithLocationWithOneFolderResourceId }
            $datacenterWithLocationWithTwoFolders = $configurations | Where-Object { $_.ResourceId -eq $script:datacenterWithLocationWithTwoFoldersResourceId }

            # Assert
            $folderWithEmptyLocation.Server | Should -Be $Server
            $folderWithEmptyLocation.Name | Should -Be $script:folderName
            $folderWithEmptyLocation.Location | Should -Be $script:emptyLocation
            $folderWithEmptyLocation.Ensure | Should -Be 'Present'

            $folderWithLocationWithOneFolder.Server | Should -Be $Server
            $folderWithLocationWithOneFolder.Name | Should -Be $script:folderName
            $folderWithLocationWithOneFolder.Location | Should -Be $script:locationWithOneFolder
            $folderWithLocationWithOneFolder.Ensure | Should -Be 'Present'

            $datacenterWithLocationWithTwoFolders.Server | Should -Be $Server
            $datacenterWithLocationWithTwoFolders.Name | Should -Be $script:datacenterName
            $datacenterWithLocationWithTwoFolders.Location | Should -Be $script:locationWithTwoFolders
            $datacenterWithLocationWithTwoFolders.Ensure | Should -Be 'Present'
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange && Act && Assert
            Test-DscConfiguration | Should -Be $true
        }

        It "Should have the following dependency: Resource $($script:folderWithLocationWithOneFolderResourceName) should depend on Resource $($script:folderWithEmptyLocationResourceName)" {
            # Arrange && Act
            $folderWithLocationWithOneFolder = Get-DscConfiguration | Where-Object { $_.ResourceId -eq $script:folderWithLocationWithOneFolderResourceId }

            # Assert
            $folderWithLocationWithOneFolder.DependsOn | Should -Be $script:folderWithEmptyLocationResourceId
        }

        It "Should have the following dependency: Resource $($script:datacenterWithLocationWithTwoFoldersResourceName) should depend on Resource $($script:folderWithLocationWithOneFolderResourceName)" {
            # Arrange && Act
            $datacenterWithLocationWithTwoFolders = Get-DscConfiguration | Where-Object { $_.ResourceId -eq $script:datacenterWithLocationWithTwoFoldersResourceId }

            # Assert
            $datacenterWithLocationWithTwoFolders.DependsOn | Should -Be $script:folderWithLocationWithOneFolderResourceId
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
            $configuration.Location | Should -Be $script:emptyLocation
            $configuration.Ensure | Should -Be 'Absent'
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange && Act && Assert
            Test-DscConfiguration | Should -Be $true
        }
    }
}
