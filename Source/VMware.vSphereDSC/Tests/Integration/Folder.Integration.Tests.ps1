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

$script:dscResourceName = 'Folder'
$script:moduleFolderPath = (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase
$script:integrationTestsFolderPath = Join-Path (Join-Path $moduleFolderPath 'Tests') 'Integration'
$script:configurationFile = "$script:integrationTestsFolderPath\Configurations\$($script:dscResourceName)\$($script:dscResourceName)_Config.ps1"

$script:configWhenAddingFolderWithEmptyLocation = "$($script:dscResourceName)_WhenAddingFolderWithEmptyLocation_Config"
$script:configWhenAddingFolderWithLocationWithOneFolder = "$($script:dscResourceName)_WhenAddingFolderWithLocationWithOneFolder_Config"
$script:configWhenAddingFolderWithLocationWithTwoFolders = "$($script:dscResourceName)_WhenAddingFolderWithLocationWithTwoFolders_Config"
$script:configWhenRemovingFolderWithEmptyLocation = "$($script:dscResourceName)_WhenRemovingFolderWithEmptyLocation_Config"
$script:configWhenRemovingFolderWithLocationWithOneFolder = "$($script:dscResourceName)_WhenRemovingFolderWithLocationWithOneFolder_Config"
$script:configWhenRemovingFolderWithLocationWithTwoFolders = "$($script:dscResourceName)_WhenRemovingFolderWithLocationWithTwoFolders_Config"

$script:folderName = 'MyTestFolder'
$script:emptyLocation = [string]::Empty
$script:locationWithOneFolder = $script:folderName
$script:locationWithTwoFolders = "$script:folderName/$script:folderName"
$script:datacenterName = 'Datacenter'
$script:datacenterLocation = [string]::Empty
$script:folderType = 'Host'

$script:folderWithEmptyLocationResourceName = 'Folder_With_EmptyLocation'
$script:folderWithLocationWithOneFolderResourceName = 'Folder_With_LocationWithOneFolder'
$script:folderWithLocationWithTwoFoldersResourceName = 'Folder_With_LocationWithTwoFolders'

$script:folderWithEmptyLocationResourceId = "[Folder]$script:folderWithEmptyLocationResourceName"
$script:folderWithLocationWithOneFolderResourceId = "[Folder]$script:folderWithLocationWithOneFolderResourceName"
$script:folderWithLocationWithTwoFoldersResourceId = "[Folder]$script:folderWithLocationWithTwoFoldersResourceName"

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
            $configuration.Name | Should -Be $script:folderName
            $configuration.Location | Should -Be $script:emptyLocation
            $configuration.DatacenterName | Should -Be $script:datacenterName
            $configuration.DatacenterLocation | Should -Be $script:datacenterLocation
            $configuration.Ensure | Should -Be 'Present'
            $configuration.FolderType | Should -Be $script:folderType
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
            $configurations = Get-DscConfiguration

            $folderWithEmptyLocation = $configurations | Where-Object { $_.ResourceId -eq $script:folderWithEmptyLocationResourceId }
            $folderWithLocationWithOneFolder = $configurations | Where-Object { $_.ResourceId -eq $script:folderWithLocationWithOneFolderResourceId }

            # Assert
            $folderWithEmptyLocation.Server | Should -Be $Server
            $folderWithEmptyLocation.Name | Should -Be $script:folderName
            $folderWithEmptyLocation.Location | Should -Be $script:emptyLocation
            $folderWithEmptyLocation.DatacenterName | Should -Be $script:datacenterName
            $folderWithEmptyLocation.DatacenterLocation | Should -Be $script:datacenterLocation
            $folderWithEmptyLocation.Ensure | Should -Be 'Present'
            $folderWithEmptyLocation.FolderType | Should -Be $script:folderType

            $folderWithLocationWithOneFolder.Server | Should -Be $Server
            $folderWithLocationWithOneFolder.Name | Should -Be $script:folderName
            $folderWithLocationWithOneFolder.Location | Should -Be $script:locationWithOneFolder
            $folderWithLocationWithOneFolder.DatacenterName | Should -Be $script:datacenterName
            $folderWithLocationWithOneFolder.DatacenterLocation | Should -Be $script:datacenterLocation
            $folderWithLocationWithOneFolder.Ensure | Should -Be 'Present'
            $folderWithLocationWithOneFolder.FolderType | Should -Be $script:folderType
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
            $configurations = Get-DscConfiguration

            $folderWithEmptyLocation = $configurations | Where-Object { $_.ResourceId -eq $script:folderWithEmptyLocationResourceId }
            $folderWithLocationWithOneFolder = $configurations | Where-Object { $_.ResourceId -eq $script:folderWithLocationWithOneFolderResourceId }
            $folderWithLocationWithTwoFolders = $configurations | Where-Object { $_.ResourceId -eq $script:folderWithLocationWithTwoFoldersResourceId }

            # Assert
            $folderWithEmptyLocation.Server | Should -Be $Server
            $folderWithEmptyLocation.Name | Should -Be $script:folderName
            $folderWithEmptyLocation.Location | Should -Be $script:emptyLocation
            $folderWithEmptyLocation.DatacenterName | Should -Be $script:datacenterName
            $folderWithEmptyLocation.DatacenterLocation | Should -Be $script:datacenterLocation
            $folderWithEmptyLocation.Ensure | Should -Be 'Present'
            $folderWithEmptyLocation.FolderType | Should -Be $script:folderType

            $folderWithLocationWithOneFolder.Server | Should -Be $Server
            $folderWithLocationWithOneFolder.Name | Should -Be $script:folderName
            $folderWithLocationWithOneFolder.Location | Should -Be $script:locationWithOneFolder
            $folderWithLocationWithOneFolder.DatacenterName | Should -Be $script:datacenterName
            $folderWithLocationWithOneFolder.DatacenterLocation | Should -Be $script:datacenterLocation
            $folderWithLocationWithOneFolder.Ensure | Should -Be 'Present'
            $folderWithLocationWithOneFolder.FolderType | Should -Be $script:folderType

            $folderWithLocationWithTwoFolders.Server | Should -Be $Server
            $folderWithLocationWithTwoFolders.Name | Should -Be $script:folderName
            $folderWithLocationWithTwoFolders.Location | Should -Be $script:locationWithTwoFolders
            $folderWithLocationWithTwoFolders.DatacenterName | Should -Be $script:datacenterName
            $folderWithLocationWithTwoFolders.DatacenterLocation | Should -Be $script:datacenterLocation
            $folderWithLocationWithTwoFolders.Ensure | Should -Be 'Present'
            $folderWithLocationWithTwoFolders.FolderType | Should -Be $script:folderType
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

        It "Should have the following dependency: Resource $($script:folderWithLocationWithTwoFoldersResourceName) should depend on Resource $($script:folderWithLocationWithOneFolderResourceName)" {
            # Arrange && Act
            $folderWithLocationWithTwoFolders = Get-DscConfiguration | Where-Object { $_.ResourceId -eq $script:folderWithLocationWithTwoFoldersResourceId }

            # Assert
            $folderWithLocationWithTwoFolders.DependsOn | Should -Be $script:folderWithLocationWithOneFolderResourceId
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
            $configuration.Name | Should -Be $script:folderName
            $configuration.Location | Should -Be $script:emptyLocation
            $configuration.DatacenterName | Should -Be $script:datacenterName
            $configuration.DatacenterLocation | Should -Be $script:datacenterLocation
            $configuration.Ensure | Should -Be 'Absent'
            $configuration.FolderType | Should -Be $script:folderType
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange && Act && Assert
            Test-DscConfiguration | Should -Be $true
        }
    }
}
