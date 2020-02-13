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

            $datacenterWithEmptyLocationResource = $configuration | Where-Object { $_.ResourceId -eq $script:datacenterWithEmptyLocationResourceId }
            $folderWithEmptyLocationResource = $configuration | Where-Object { $_.ResourceId -eq $script:folderWithEmptyLocationResourceId }

            # Assert
            $datacenterWithEmptyLocationResource.Server | Should -Be $Server
            $datacenterWithEmptyLocationResource.Name | Should -Be $script:datacenterName
            $datacenterWithEmptyLocationResource.Location | Should -Be $script:datacenterEmptyLocation
            $datacenterWithEmptyLocationResource.Ensure | Should -Be 'Present'

            $folderWithEmptyLocationResource.Server | Should -Be $Server
            $folderWithEmptyLocationResource.Name | Should -Be $script:folderName
            $folderWithEmptyLocationResource.Location | Should -Be $script:folderWithEmptyLocation
            $folderWithEmptyLocationResource.DatacenterName | Should -Be $script:datacenterName
            $folderWithEmptyLocationResource.DatacenterLocation | Should -Be $script:datacenterEmptyLocation
            $folderWithEmptyLocationResource.Ensure | Should -Be 'Present'
            $folderWithEmptyLocationResource.FolderType | Should -Be $script:folderType
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange && Act && Assert
            Test-DscConfiguration | Should -Be $true
        }

        It "Should have the following dependency: Resource $($script:folderWithEmptyLocationResourceName) should depend on Resource $($script:datacenterWithEmptyLocationResourceName)" {
            # Arrange && Act
            $folderWithEmptyLocationResource = Get-DscConfiguration | Where-Object { $_.ResourceId -eq $script:folderWithEmptyLocationResourceId }

            # Assert
            $folderWithEmptyLocationResource.DependsOn | Should -Be $script:datacenterWithEmptyLocationResourceId
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
            $datacenterWithLocationWithOneFolderResource = $configuration | Where-Object { $_.ResourceId -eq $script:datacenterWithLocationWithOneFolderResourceId }
            $folderWithEmptyLocationResource = $configuration | Where-Object { $_.ResourceId -eq $script:folderWithEmptyLocationResourceId }
            $folderWithLocationWithOneFolderResource = $configuration | Where-Object { $_.ResourceId -eq $script:folderWithLocationWithOneFolderResourceId }

            # Assert
            $datacenterFolderWithEmptyLocationResource.Server | Should -Be $Server
            $datacenterFolderWithEmptyLocationResource.Name | Should -Be $script:datacenterFolderName
            $datacenterFolderWithEmptyLocationResource.Location | Should -Be $script:datacenterFolderEmptyLocation
            $datacenterFolderWithEmptyLocationResource.Ensure | Should -Be 'Present'

            $datacenterWithLocationWithOneFolderResource.Server | Should -Be $Server
            $datacenterWithLocationWithOneFolderResource.Name | Should -Be $script:datacenterName
            $datacenterWithLocationWithOneFolderResource.Location | Should -Be $script:datacenterLocationWithOneFolder
            $datacenterWithLocationWithOneFolderResource.Ensure | Should -Be 'Present'

            $folderWithEmptyLocationResource.Server | Should -Be $Server
            $folderWithEmptyLocationResource.Name | Should -Be $script:folderName
            $folderWithEmptyLocationResource.Location | Should -Be $script:folderWithEmptyLocation
            $folderWithEmptyLocationResource.DatacenterName | Should -Be $script:datacenterName
            $folderWithEmptyLocationResource.DatacenterLocation | Should -Be $script:datacenterLocationWithOneFolder
            $folderWithEmptyLocationResource.Ensure | Should -Be 'Present'
            $folderWithEmptyLocationResource.FolderType | Should -Be $script:folderType

            $folderWithLocationWithOneFolderResource.Server | Should -Be $Server
            $folderWithLocationWithOneFolderResource.Name | Should -Be $script:folderName
            $folderWithLocationWithOneFolderResource.Location | Should -Be $script:folderWithLocationWithOneFolder
            $folderWithLocationWithOneFolderResource.DatacenterName | Should -Be $script:datacenterName
            $folderWithLocationWithOneFolderResource.DatacenterLocation | Should -Be $script:datacenterLocationWithOneFolder
            $folderWithLocationWithOneFolderResource.Ensure | Should -Be 'Present'
            $folderWithLocationWithOneFolderResource.FolderType | Should -Be $script:folderType
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

        It "Should have the following dependency: Resource $($script:folderWithEmptyLocationResourceName) should depend on Resource $($script:datacenterWithLocationWithOneFolderResourceName)" {
            # Arrange && Act
            $folderWithEmptyLocationResource = Get-DscConfiguration | Where-Object { $_.ResourceId -eq $script:folderWithEmptyLocationResourceId }

            # Assert
            $folderWithEmptyLocationResource.DependsOn | Should -Be $script:datacenterWithLocationWithOneFolderResourceId
        }

        It "Should have the following dependency: Resource $($script:folderWithLocationWithOneFolderResourceName) should depend on Resource $($script:folderWithEmptyLocationResourceName)" {
            # Arrange && Act
            $folderWithLocationWithOneFolderResource = Get-DscConfiguration | Where-Object { $_.ResourceId -eq $script:folderWithLocationWithOneFolderResourceId }

            # Assert
            $folderWithLocationWithOneFolderResource.DependsOn | Should -Be $script:folderWithEmptyLocationResourceId
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
            $datacenterWithLocationWithTwoFoldersResource = $configuration | Where-Object { $_.ResourceId -eq $script:datacenterWithLocationWithTwoFoldersResourceId }
            $folderWithEmptyLocationResource = $configuration | Where-Object { $_.ResourceId -eq $script:folderWithEmptyLocationResourceId }
            $folderWithLocationWithOneFolderResource = $configuration | Where-Object { $_.ResourceId -eq $script:folderWithLocationWithOneFolderResourceId }
            $folderWithLocationWithTwoFoldersResource = $configuration | Where-Object { $_.ResourceId -eq $script:folderWithLocationWithTwoFoldersResourceId }

            # Assert
            $datacenterFolderWithEmptyLocationResource.Server | Should -Be $Server
            $datacenterFolderWithEmptyLocationResource.Name | Should -Be $script:datacenterFolderName
            $datacenterFolderWithEmptyLocationResource.Location | Should -Be $script:datacenterFolderEmptyLocation
            $datacenterFolderWithEmptyLocationResource.Ensure | Should -Be 'Present'

            $datacenterFolderWithLocationWithOneFolderResource.Server | Should -Be $Server
            $datacenterFolderWithLocationWithOneFolderResource.Name | Should -Be $script:datacenterFolderName
            $datacenterFolderWithLocationWithOneFolderResource.Location | Should -Be $script:datacenterFolderLocationWithOneFolder
            $datacenterFolderWithLocationWithOneFolderResource.Ensure | Should -Be 'Present'

            $datacenterWithLocationWithTwoFoldersResource.Server | Should -Be $Server
            $datacenterWithLocationWithTwoFoldersResource.Name | Should -Be $script:datacenterName
            $datacenterWithLocationWithTwoFoldersResource.Location | Should -Be $script:datacenterLocationWithTwoFolders
            $datacenterWithLocationWithTwoFoldersResource.Ensure | Should -Be 'Present'

            $folderWithEmptyLocationResource.Server | Should -Be $Server
            $folderWithEmptyLocationResource.Name | Should -Be $script:folderName
            $folderWithEmptyLocationResource.Location | Should -Be $script:folderWithEmptyLocation
            $folderWithEmptyLocationResource.DatacenterName | Should -Be $script:datacenterName
            $folderWithEmptyLocationResource.DatacenterLocation | Should -Be $script:datacenterLocationWithTwoFolders
            $folderWithEmptyLocationResource.Ensure | Should -Be 'Present'
            $folderWithEmptyLocationResource.FolderType | Should -Be $script:folderType

            $folderWithLocationWithOneFolderResource.Server | Should -Be $Server
            $folderWithLocationWithOneFolderResource.Name | Should -Be $script:folderName
            $folderWithLocationWithOneFolderResource.Location | Should -Be $script:folderWithLocationWithOneFolder
            $folderWithLocationWithOneFolderResource.DatacenterName | Should -Be $script:datacenterName
            $folderWithLocationWithOneFolderResource.DatacenterLocation | Should -Be $script:datacenterLocationWithTwoFolders
            $folderWithLocationWithOneFolderResource.Ensure | Should -Be 'Present'
            $folderWithLocationWithOneFolderResource.FolderType | Should -Be $script:folderType

            $folderWithLocationWithTwoFoldersResource.Server | Should -Be $Server
            $folderWithLocationWithTwoFoldersResource.Name | Should -Be $script:folderName
            $folderWithLocationWithTwoFoldersResource.Location | Should -Be $script:folderWithLocationWithTwoFolders
            $folderWithLocationWithTwoFoldersResource.DatacenterName | Should -Be $script:datacenterName
            $folderWithLocationWithTwoFoldersResource.DatacenterLocation | Should -Be $script:datacenterLocationWithTwoFolders
            $folderWithLocationWithTwoFoldersResource.Ensure | Should -Be 'Present'
            $folderWithLocationWithTwoFoldersResource.FolderType | Should -Be $script:folderType
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

        It "Should have the following dependency: Resource $($script:folderWithEmptyLocationResourceName) should depend on Resource $($script:datacenterWithLocationWithTwoFoldersResourceName)" {
            # Arrange && Act
            $folderWithEmptyLocationResource = Get-DscConfiguration | Where-Object { $_.ResourceId -eq $script:folderWithEmptyLocationResourceId }

            # Assert
            $folderWithEmptyLocationResource.DependsOn | Should -Be $script:datacenterWithLocationWithTwoFoldersResourceId
        }

        It "Should have the following dependency: Resource $($script:folderWithLocationWithOneFolderResourceName) should depend on Resource $($script:folderWithEmptyLocationResourceName)" {
            # Arrange && Act
            $folderWithLocationWithOneFolderResource = Get-DscConfiguration | Where-Object { $_.ResourceId -eq $script:folderWithLocationWithOneFolderResourceId }

            # Assert
            $folderWithLocationWithOneFolderResource.DependsOn | Should -Be $script:folderWithEmptyLocationResourceId
        }

        It "Should have the following dependency: Resource $($script:folderWithLocationWithTwoFoldersResourceName) should depend on Resource $($script:folderWithLocationWithOneFolderResourceName)" {
            # Arrange && Act
            $folderWithLocationWithTwoFoldersResource = Get-DscConfiguration | Where-Object { $_.ResourceId -eq $script:folderWithLocationWithTwoFoldersResourceId }

            # Assert
            $folderWithLocationWithTwoFoldersResource.DependsOn | Should -Be $script:folderWithLocationWithOneFolderResourceId
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

            $datacenterWithEmptyLocationResource = $configuration | Where-Object { $_.ResourceId -eq $script:datacenterWithEmptyLocationResourceId }
            $folderWithEmptyLocationResource = $configuration | Where-Object { $_.ResourceId -eq $script:folderWithEmptyLocationResourceId }

            # Assert
            $datacenterWithEmptyLocationResource.Server | Should -Be $Server
            $datacenterWithEmptyLocationResource.Name | Should -Be $script:datacenterName
            $datacenterWithEmptyLocationResource.Location | Should -Be $script:datacenterEmptyLocation
            $datacenterWithEmptyLocationResource.Ensure | Should -Be 'Absent'

            $folderWithEmptyLocationResource.Server | Should -Be $Server
            $folderWithEmptyLocationResource.Name | Should -Be $script:folderName
            $folderWithEmptyLocationResource.Location | Should -Be $script:folderWithEmptyLocation
            $folderWithEmptyLocationResource.DatacenterName | Should -Be $script:datacenterName
            $folderWithEmptyLocationResource.DatacenterLocation | Should -Be $script:datacenterEmptyLocation
            $folderWithEmptyLocationResource.Ensure | Should -Be 'Absent'
            $folderWithEmptyLocationResource.FolderType | Should -Be $script:folderType
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange && Act && Assert
            Test-DscConfiguration | Should -Be $true
        }

        It "Should have the following dependency: Resource $($script:datacenterWithEmptyLocationResourceName) should depend on Resource $($script:folderWithEmptyLocationResourceName)" {
            # Arrange && Act
            $datacenterWithEmptyLocationResource = Get-DscConfiguration | Where-Object { $_.ResourceId -eq $script:datacenterWithEmptyLocationResourceId }

            # Assert
            $datacenterWithEmptyLocationResource.DependsOn | Should -Be $script:folderWithEmptyLocationResourceId
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
            $datacenterWithLocationWithOneFolderResource = $configuration | Where-Object { $_.ResourceId -eq $script:datacenterWithLocationWithOneFolderResourceId }
            $folderWithEmptyLocationResource = $configuration | Where-Object { $_.ResourceId -eq $script:folderWithEmptyLocationResourceId }
            $folderWithLocationWithOneFolderResource = $configuration | Where-Object { $_.ResourceId -eq $script:folderWithLocationWithOneFolderResourceId }

            # Assert
            $datacenterFolderWithEmptyLocationResource.Server | Should -Be $Server
            $datacenterFolderWithEmptyLocationResource.Name | Should -Be $script:datacenterFolderName
            $datacenterFolderWithEmptyLocationResource.Location | Should -Be $script:datacenterFolderEmptyLocation
            $datacenterFolderWithEmptyLocationResource.Ensure | Should -Be 'Absent'

            $datacenterWithLocationWithOneFolderResource.Server | Should -Be $Server
            $datacenterWithLocationWithOneFolderResource.Name | Should -Be $script:datacenterName
            $datacenterWithLocationWithOneFolderResource.Location | Should -Be $script:datacenterLocationWithOneFolder
            $datacenterWithLocationWithOneFolderResource.Ensure | Should -Be 'Absent'

            $folderWithEmptyLocationResource.Server | Should -Be $Server
            $folderWithEmptyLocationResource.Name | Should -Be $script:folderName
            $folderWithEmptyLocationResource.Location | Should -Be $script:folderWithEmptyLocation
            $folderWithEmptyLocationResource.DatacenterName | Should -Be $script:datacenterName
            $folderWithEmptyLocationResource.DatacenterLocation | Should -Be $script:datacenterLocationWithOneFolder
            $folderWithEmptyLocationResource.Ensure | Should -Be 'Absent'
            $folderWithEmptyLocationResource.FolderType | Should -Be $script:folderType

            $folderWithLocationWithOneFolderResource.Server | Should -Be $Server
            $folderWithLocationWithOneFolderResource.Name | Should -Be $script:folderName
            $folderWithLocationWithOneFolderResource.Location | Should -Be $script:folderWithLocationWithOneFolder
            $folderWithLocationWithOneFolderResource.DatacenterName | Should -Be $script:datacenterName
            $folderWithLocationWithOneFolderResource.DatacenterLocation | Should -Be $script:datacenterLocationWithOneFolder
            $folderWithLocationWithOneFolderResource.Ensure | Should -Be 'Absent'
            $folderWithLocationWithOneFolderResource.FolderType | Should -Be $script:folderType
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange && Act && Assert
            Test-DscConfiguration | Should -Be $true
        }

        It "Should have the following dependency: Resource $($script:folderWithEmptyLocationResourceName) should depend on Resource $($script:folderWithLocationWithOneFolderResourceName)" {
            # Arrange && Act
            $folderWithEmptyLocationResource = Get-DscConfiguration | Where-Object { $_.ResourceId -eq $script:folderWithEmptyLocationResourceId }

            # Assert
            $folderWithEmptyLocationResource.DependsOn | Should -Be $script:folderWithLocationWithOneFolderResourceId
        }

        It "Should have the following dependency: Resource $($script:datacenterWithLocationWithOneFolderResourceName) should depend on Resource $($script:folderWithEmptyLocationResourceName)" {
            # Arrange && Act
            $datacenterWithLocationWithOneFolderResource = Get-DscConfiguration | Where-Object { $_.ResourceId -eq $script:datacenterWithLocationWithOneFolderResourceId }

            # Assert
            $datacenterWithLocationWithOneFolderResource.DependsOn | Should -Be $script:folderWithEmptyLocationResourceId
        }

        It "Should have the following dependency: Resource $($script:datacenterFolderWithEmptyLocationResourceName) should depend on Resource $($script:datacenterWithLocationWithOneFolderResourceName)" {
            # Arrange && Act
            $datacenterFolderWithEmptyLocationResource = Get-DscConfiguration | Where-Object { $_.ResourceId -eq $script:datacenterFolderWithEmptyLocationResourceId }

            # Assert
            $datacenterFolderWithEmptyLocationResource.DependsOn | Should -Be $script:datacenterWithLocationWithOneFolderResourceId
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
            $datacenterWithLocationWithTwoFoldersResource = $configuration | Where-Object { $_.ResourceId -eq $script:datacenterWithLocationWithTwoFoldersResourceId }
            $folderWithEmptyLocationResource = $configuration | Where-Object { $_.ResourceId -eq $script:folderWithEmptyLocationResourceId }
            $folderWithLocationWithOneFolderResource = $configuration | Where-Object { $_.ResourceId -eq $script:folderWithLocationWithOneFolderResourceId }
            $folderWithLocationWithTwoFoldersResource = $configuration | Where-Object { $_.ResourceId -eq $script:folderWithLocationWithTwoFoldersResourceId }

            # Assert
            $datacenterFolderWithEmptyLocationResource.Server | Should -Be $Server
            $datacenterFolderWithEmptyLocationResource.Name | Should -Be $script:datacenterFolderName
            $datacenterFolderWithEmptyLocationResource.Location | Should -Be $script:datacenterFolderEmptyLocation
            $datacenterFolderWithEmptyLocationResource.Ensure | Should -Be 'Absent'

            $datacenterFolderWithLocationWithOneFolderResource.Server | Should -Be $Server
            $datacenterFolderWithLocationWithOneFolderResource.Name | Should -Be $script:datacenterFolderName
            $datacenterFolderWithLocationWithOneFolderResource.Location | Should -Be $script:datacenterFolderLocationWithOneFolder
            $datacenterFolderWithLocationWithOneFolderResource.Ensure | Should -Be 'Absent'

            $datacenterWithLocationWithTwoFoldersResource.Server | Should -Be $Server
            $datacenterWithLocationWithTwoFoldersResource.Name | Should -Be $script:datacenterName
            $datacenterWithLocationWithTwoFoldersResource.Location | Should -Be $script:datacenterLocationWithTwoFolders
            $datacenterWithLocationWithTwoFoldersResource.Ensure | Should -Be 'Absent'

            $folderWithEmptyLocationResource.Server | Should -Be $Server
            $folderWithEmptyLocationResource.Name | Should -Be $script:folderName
            $folderWithEmptyLocationResource.Location | Should -Be $script:folderWithEmptyLocation
            $folderWithEmptyLocationResource.DatacenterName | Should -Be $script:datacenterName
            $folderWithEmptyLocationResource.DatacenterLocation | Should -Be $script:datacenterLocationWithTwoFolders
            $folderWithEmptyLocationResource.Ensure | Should -Be 'Absent'
            $folderWithEmptyLocationResource.FolderType | Should -Be $script:folderType

            $folderWithLocationWithOneFolderResource.Server | Should -Be $Server
            $folderWithLocationWithOneFolderResource.Name | Should -Be $script:folderName
            $folderWithLocationWithOneFolderResource.Location | Should -Be $script:folderWithLocationWithOneFolder
            $folderWithLocationWithOneFolderResource.DatacenterName | Should -Be $script:datacenterName
            $folderWithLocationWithOneFolderResource.DatacenterLocation | Should -Be $script:datacenterLocationWithTwoFolders
            $folderWithLocationWithOneFolderResource.Ensure | Should -Be 'Absent'
            $folderWithLocationWithOneFolderResource.FolderType | Should -Be $script:folderType

            $folderWithLocationWithTwoFoldersResource.Server | Should -Be $Server
            $folderWithLocationWithTwoFoldersResource.Name | Should -Be $script:folderName
            $folderWithLocationWithTwoFoldersResource.Location | Should -Be $script:folderWithLocationWithTwoFolders
            $folderWithLocationWithTwoFoldersResource.DatacenterName | Should -Be $script:datacenterName
            $folderWithLocationWithTwoFoldersResource.DatacenterLocation | Should -Be $script:datacenterLocationWithTwoFolders
            $folderWithLocationWithTwoFoldersResource.Ensure | Should -Be 'Absent'
            $folderWithLocationWithTwoFoldersResource.FolderType | Should -Be $script:folderType
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange && Act && Assert
            Test-DscConfiguration | Should -Be $true
        }

        It "Should have the following dependency: Resource $($script:folderWithLocationWithOneFolderResourceName) should depend on Resource $($script:folderWithLocationWithTwoFoldersResourceName)" {
            # Arrange && Act
            $folderWithLocationWithOneFolderResource = Get-DscConfiguration | Where-Object { $_.ResourceId -eq $script:folderWithLocationWithOneFolderResourceId }

            # Assert
            $folderWithLocationWithOneFolderResource.DependsOn | Should -Be $script:folderWithLocationWithTwoFoldersResourceId
        }

        It "Should have the following dependency: Resource $($script:folderWithEmptyLocationResourceName) should depend on Resource $($script:folderWithLocationWithOneFolderResourceName)" {
            # Arrange && Act
            $folderWithEmptyLocationResource = Get-DscConfiguration | Where-Object { $_.ResourceId -eq $script:folderWithEmptyLocationResourceId }

            # Assert
            $folderWithEmptyLocationResource.DependsOn | Should -Be $script:folderWithLocationWithOneFolderResourceId
        }

        It "Should have the following dependency: Resource $($script:datacenterWithLocationWithTwoFoldersResourceName) should depend on Resource $($script:folderWithEmptyLocationResourceName)" {
            # Arrange && Act
            $datacenterWithLocationWithTwoFoldersResource = Get-DscConfiguration | Where-Object { $_.ResourceId -eq $script:datacenterWithLocationWithTwoFoldersResourceId }

            # Assert
            $datacenterWithLocationWithTwoFoldersResource.DependsOn | Should -Be $script:folderWithEmptyLocationResourceId
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
