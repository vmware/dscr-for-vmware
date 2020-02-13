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

$script:dscResourceName = 'HACluster'
$script:moduleFolderPath = (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase
$script:integrationTestsFolderPath = Join-Path (Join-Path $moduleFolderPath 'Tests') 'Integration'
$script:configurationFile = "$script:integrationTestsFolderPath\Configurations\$($script:dscResourceName)\$($script:dscResourceName)_Config.ps1"

$script:configWhenAddingClusterWithEmptyLocation = "$($script:dscResourceName)_WhenAddingClusterWithEmptyLocation_Config"
$script:configWhenAddingClusterWithLocationWithOneFolder = "$($script:dscResourceName)_WhenAddingClusterWithLocationWithOneFolder_Config"
$script:configWhenAddingClusterWithLocationWithTwoFolders = "$($script:dscResourceName)_WhenAddingClusterWithLocationWithTwoFolders_Config"
$script:configWhenUpdatingCluster = "$($script:dscResourceName)_WhenUpdatingCluster_Config"
$script:configWhenRemovingClusterWithEmptyLocation = "$($script:dscResourceName)_WhenRemovingClusterWithEmptyLocation_Config"
$script:configWhenRemovingClusterWithLocationWithOneFolder = "$($script:dscResourceName)_WhenRemovingClusterWithLocationWithOneFolder_Config"
$script:configWhenRemovingClusterWithLocationWithTwoFolders = "$($script:dscResourceName)_WhenRemovingClusterWithLocationWithTwoFolders_Config"

. $script:configurationFile -Server $Server -User $User -Password $Password

$script:mofFileWhenAddingClusterWithEmptyLocationPath = "$script:integrationTestsFolderPath\$($script:configWhenAddingClusterWithEmptyLocation)\"
$script:mofFileWhenAddingClusterWithLocationWithOneFolderPath = "$script:integrationTestsFolderPath\$($script:configWhenAddingClusterWithLocationWithOneFolder)\"
$script:mofFileWhenAddingClusterWithLocationWithTwoFoldersPath = "$script:integrationTestsFolderPath\$($script:configWhenAddingClusterWithLocationWithTwoFolders)\"
$script:mofFileWhenUpdatingClusterPath = "$script:integrationTestsFolderPath\$($script:configWhenUpdatingCluster)\"
$script:mofFileWhenRemovingClusterWithEmptyLocationPath = "$script:integrationTestsFolderPath\$($script:configWhenRemovingClusterWithEmptyLocation)\"
$script:mofFileWhenRemovingClusterWithLocationWithOneFolderPath = "$script:integrationTestsFolderPath\$($script:configWhenRemovingClusterWithLocationWithOneFolder)\"
$script:mofFileWhenRemovingClusterWithLocationWithTwoFoldersPath = "$script:integrationTestsFolderPath\$($script:configWhenRemovingClusterWithLocationWithTwoFolders)\"

Describe "$($script:dscResourceName)_Integration" {
    Context "When using configuration $($script:configWhenAddingClusterWithEmptyLocation)" {
        BeforeAll {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenAddingClusterWithEmptyLocationPath
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
                Path = $script:mofFileWhenAddingClusterWithEmptyLocationPath
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
            $clusterWithEmptyLocationResource = $configuration | Where-Object { $_.ResourceId -eq $script:haClusterWithEmptyLocationResourceId }

            # Assert
            $datacenterFolderWithEmptyLocationResource.Server | Should -Be $Server
            $datacenterFolderWithEmptyLocationResource.Name | Should -Be $script:datacenterFolderName
            $datacenterFolderWithEmptyLocationResource.Location | Should -Be $script:datacenterFolderEmptyLocation
            $datacenterFolderWithEmptyLocationResource.Ensure | Should -Be 'Present'

            $datacenterWithLocationWithOneFolderResource.Server | Should -Be $Server
            $datacenterWithLocationWithOneFolderResource.Name | Should -Be $script:datacenterName
            $datacenterWithLocationWithOneFolderResource.Location | Should -Be $script:datacenterLocationWithOneFolder
            $datacenterWithLocationWithOneFolderResource.Ensure | Should -Be 'Present'

            $clusterWithEmptyLocationResource.Server | Should -Be $Server
            $clusterWithEmptyLocationResource.Name | Should -Be $script:clusterName
            $clusterWithEmptyLocationResource.Location | Should -Be $script:clusterWithEmptyLocation
            $clusterWithEmptyLocationResource.DatacenterName | Should -Be $script:datacenterName
            $clusterWithEmptyLocationResource.DatacenterLocation | Should -Be $script:datacenterLocationWithOneFolder
            $clusterWithEmptyLocationResource.Ensure | Should -Be 'Present'
            $clusterWithEmptyLocationResource.HAEnabled | Should -Be $true
            $clusterWithEmptyLocationResource.HAAdmissionControlEnabled | Should -Be $true
            $clusterWithEmptyLocationResource.HAFailoverLevel | Should -Be 3
            $clusterWithEmptyLocationResource.HAIsolationResponse | Should -Be 'DoNothing'
            $clusterWithEmptyLocationResource.HARestartPriority | Should -Be 'Low'
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

        It "Should have the following dependency: Resource $($script:haClusterWithEmptyLocationResourceName) should depend on Resource $($script:datacenterWithLocationWithOneFolderResourceName)" {
            # Arrange && Act
            $clusterWithEmptyLocationResource = Get-DscConfiguration | Where-Object { $_.ResourceId -eq $script:haClusterWithEmptyLocationResourceId }

            # Assert
            $clusterWithEmptyLocationResource.DependsOn | Should -Be $script:datacenterWithLocationWithOneFolderResourceId
        }

        AfterAll {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingClusterWithEmptyLocationPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters
        }
    }

    Context "When using configuration $($script:configWhenAddingClusterWithLocationWithOneFolder)" {
        BeforeAll {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenAddingClusterWithLocationWithOneFolderPath
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
                Path = $script:mofFileWhenAddingClusterWithLocationWithOneFolderPath
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
            $clusterWithLocationWithOneFolderResource = $configuration | Where-Object { $_.ResourceId -eq $script:haClusterWithLocationWithOneFolderResourceId }

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

            $clusterWithLocationWithOneFolderResource.Server | Should -Be $Server
            $clusterWithLocationWithOneFolderResource.Name | Should -Be $script:clusterName
            $clusterWithLocationWithOneFolderResource.Location | Should -Be $script:clusterWithLocationWithOneFolder
            $clusterWithLocationWithOneFolderResource.DatacenterName | Should -Be $script:datacenterName
            $clusterWithLocationWithOneFolderResource.DatacenterLocation | Should -Be $script:datacenterLocationWithOneFolder
            $clusterWithLocationWithOneFolderResource.Ensure | Should -Be 'Present'
            $clusterWithLocationWithOneFolderResource.HAEnabled | Should -Be $true
            $clusterWithLocationWithOneFolderResource.HAAdmissionControlEnabled | Should -Be $true
            $clusterWithLocationWithOneFolderResource.HAFailoverLevel | Should -Be 2
            $clusterWithLocationWithOneFolderResource.HAIsolationResponse | Should -Be 'PowerOff'
            $clusterWithLocationWithOneFolderResource.HARestartPriority | Should -Be 'High'
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

        It "Should have the following dependency: Resource $($script:haClusterWithLocationWithOneFolderResourceName) should depend on Resource $($script:folderWithEmptyLocationResourceName)" {
            # Arrange && Act
            $clusterWithLocationWithOneFolderResource = Get-DscConfiguration | Where-Object { $_.ResourceId -eq $script:haClusterWithLocationWithOneFolderResourceId }

            # Assert
            $clusterWithLocationWithOneFolderResource.DependsOn | Should -Be $script:folderWithEmptyLocationResourceId
        }

        AfterAll {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingClusterWithLocationWithOneFolderPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters
        }
    }

    Context "When using configuration $($script:configWhenAddingClusterWithLocationWithTwoFolders)" {
        BeforeAll {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenAddingClusterWithLocationWithTwoFoldersPath
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
                Path = $script:mofFileWhenAddingClusterWithLocationWithTwoFoldersPath
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
            $clusterWithLocationWithTwoFoldersResource = $configuration | Where-Object { $_.ResourceId -eq $script:haClusterWithLocationWithTwoFoldersResourceId }

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

            $clusterWithLocationWithTwoFoldersResource.Server | Should -Be $Server
            $clusterWithLocationWithTwoFoldersResource.Name | Should -Be $script:clusterName
            $clusterWithLocationWithTwoFoldersResource.Location | Should -Be $script:clusterWithLocationWithTwoFolders
            $clusterWithLocationWithTwoFoldersResource.DatacenterName | Should -Be $script:datacenterName
            $clusterWithLocationWithTwoFoldersResource.DatacenterLocation | Should -Be $script:datacenterLocationWithOneFolder
            $clusterWithLocationWithTwoFoldersResource.Ensure | Should -Be 'Present'
            $clusterWithLocationWithTwoFoldersResource.HAEnabled | Should -Be $true
            $clusterWithLocationWithTwoFoldersResource.HAAdmissionControlEnabled | Should -Be $true
            $clusterWithLocationWithTwoFoldersResource.HAFailoverLevel | Should -Be 1
            $clusterWithLocationWithTwoFoldersResource.HAIsolationResponse | Should -Be 'Shutdown'
            $clusterWithLocationWithTwoFoldersResource.HARestartPriority | Should -Be 'Medium'
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

        It "Should have the following dependency: Resource $($script:haClusterWithLocationWithTwoFoldersResourceName) should depend on Resource $($script:folderWithLocationWithOneFolderResourceName)" {
            # Arrange && Act
            $clusterWithLocationWithTwoFoldersResource = Get-DscConfiguration | Where-Object { $_.ResourceId -eq $script:haClusterWithLocationWithTwoFoldersResourceId }

            # Assert
            $clusterWithLocationWithTwoFoldersResource.DependsOn | Should -Be $script:folderWithLocationWithOneFolderResourceId
        }

        AfterAll {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingClusterWithLocationWithTwoFoldersPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters
        }
    }

    Context "When using configuration $($script:configWhenUpdatingCluster)" {
        BeforeAll {
            # Arrange
            $startDscConfigurationParametersWhenAddingCluster = @{
                Path = $script:mofFileWhenAddingClusterWithEmptyLocationPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            $startDscConfigurationParametersWhenUpdatingCluster = @{
                Path = $script:mofFileWhenUpdatingClusterPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersWhenAddingCluster
            Start-DscConfiguration @startDscConfigurationParametersWhenUpdatingCluster
        }

        It 'Should compile and apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenUpdatingClusterPath
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
            $configuration.Name | Should -Be $script:clusterName
            $configuration.Location | Should -Be $script:clusterWithEmptyLocation
            $configuration.DatacenterName | Should -Be $script:datacenterName
            $configuration.DatacenterLocation | Should -Be $script:datacenterLocationWithOneFolder
            $configuration.Ensure | Should -Be 'Present'
            $configuration.HAEnabled | Should -Be $true
            $configuration.HAAdmissionControlEnabled | Should -Be $false
            $configuration.HAFailoverLevel | Should -Be 3
            $configuration.HAIsolationResponse | Should -Be 'PowerOff'
            $configuration.HARestartPriority | Should -Be 'Disabled'
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange && Act && Assert
            Test-DscConfiguration | Should -Be $true
        }

        AfterAll {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingClusterWithEmptyLocationPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters
        }
    }

    Context "When using configuration $($script:configWhenRemovingClusterWithEmptyLocation)" {
        BeforeAll {
            # Arrange
            $startDscConfigurationParametersWhenAddingCluster = @{
                Path = $script:mofFileWhenAddingClusterWithEmptyLocationPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            $startDscConfigurationParametersWhenRemovingCluster = @{
                Path = $script:mofFileWhenRemovingClusterWithEmptyLocationPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersWhenAddingCluster
            Start-DscConfiguration @startDscConfigurationParametersWhenRemovingCluster
        }

        It 'Should compile and apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingClusterWithEmptyLocationPath
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
            $clusterWithEmptyLocationResource = $configuration | Where-Object { $_.ResourceId -eq $script:haClusterWithEmptyLocationResourceId }

            # Assert
            $datacenterFolderWithEmptyLocationResource.Server | Should -Be $Server
            $datacenterFolderWithEmptyLocationResource.Name | Should -Be $script:datacenterFolderName
            $datacenterFolderWithEmptyLocationResource.Location | Should -Be $script:datacenterFolderEmptyLocation
            $datacenterFolderWithEmptyLocationResource.Ensure | Should -Be 'Absent'

            $datacenterWithLocationWithOneFolderResource.Server | Should -Be $Server
            $datacenterWithLocationWithOneFolderResource.Name | Should -Be $script:datacenterName
            $datacenterWithLocationWithOneFolderResource.Location | Should -Be $script:datacenterLocationWithOneFolder
            $datacenterWithLocationWithOneFolderResource.Ensure | Should -Be 'Absent'

            $clusterWithEmptyLocationResource.Server | Should -Be $Server
            $clusterWithEmptyLocationResource.Name | Should -Be $script:clusterName
            $clusterWithEmptyLocationResource.Location | Should -Be $script:clusterWithEmptyLocation
            $clusterWithEmptyLocationResource.DatacenterName | Should -Be $script:datacenterName
            $clusterWithEmptyLocationResource.DatacenterLocation | Should -Be $script:datacenterLocationWithOneFolder
            $clusterWithEmptyLocationResource.Ensure | Should -Be 'Absent'
            $clusterWithEmptyLocationResource.HAEnabled | Should -Be $null
            $clusterWithEmptyLocationResource.HAAdmissionControlEnabled | Should -Be $null
            $clusterWithEmptyLocationResource.HAFailoverLevel | Should -Be $null
            $clusterWithEmptyLocationResource.HAIsolationResponse | Should -Be 'Unset'
            $clusterWithEmptyLocationResource.HARestartPriority | Should -Be 'Unset'
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange && Act && Assert
            Test-DscConfiguration | Should -Be $true
        }

        It "Should have the following dependency: Resource $($script:datacenterWithLocationWithOneFolderResourceName) should depend on Resource $($script:haClusterWithEmptyLocationResourceName)" {
            # Arrange && Act
            $datacenterWithLocationWithOneFolderResource = Get-DscConfiguration | Where-Object { $_.ResourceId -eq $script:datacenterWithLocationWithOneFolderResourceId }

            # Assert
            $datacenterWithLocationWithOneFolderResource.DependsOn | Should -Be $script:haClusterWithEmptyLocationResourceId
        }

        It "Should have the following dependency: Resource $($script:datacenterFolderWithEmptyLocationResourceName) should depend on Resource $($script:datacenterWithLocationWithOneFolderResourceName)" {
            # Arrange && Act
            $datacenterFolderWithEmptyLocationResource = Get-DscConfiguration | Where-Object { $_.ResourceId -eq $script:datacenterFolderWithEmptyLocationResourceId }

            # Assert
            $datacenterFolderWithEmptyLocationResource.DependsOn | Should -Be $script:datacenterWithLocationWithOneFolderResourceId
        }
    }

    Context "When using configuration $($script:configWhenRemovingClusterWithLocationWithOneFolder)" {
        BeforeAll {
            # Arrange
            $startDscConfigurationParametersWhenAddingCluster = @{
                Path = $script:mofFileWhenAddingClusterWithLocationWithOneFolderPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            $startDscConfigurationParametersWhenRemovingCluster = @{
                Path = $script:mofFileWhenRemovingClusterWithLocationWithOneFolderPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersWhenAddingCluster
            Start-DscConfiguration @startDscConfigurationParametersWhenRemovingCluster
        }

        It 'Should compile and apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingClusterWithLocationWithOneFolderPath
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
            $clusterWithLocationWithOneFolderResource = $configuration | Where-Object { $_.ResourceId -eq $script:haClusterWithLocationWithOneFolderResourceId }

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

            $clusterWithLocationWithOneFolderResource.Server | Should -Be $Server
            $clusterWithLocationWithOneFolderResource.Name | Should -Be $script:clusterName
            $clusterWithLocationWithOneFolderResource.Location | Should -Be $script:clusterWithLocationWithOneFolder
            $clusterWithLocationWithOneFolderResource.DatacenterName | Should -Be $script:datacenterName
            $clusterWithLocationWithOneFolderResource.DatacenterLocation | Should -Be $script:datacenterLocationWithOneFolder
            $clusterWithLocationWithOneFolderResource.Ensure | Should -Be 'Absent'
            $clusterWithLocationWithOneFolderResource.HAEnabled | Should -Be $null
            $clusterWithLocationWithOneFolderResource.HAAdmissionControlEnabled | Should -Be $null
            $clusterWithLocationWithOneFolderResource.HAFailoverLevel | Should -Be $null
            $clusterWithLocationWithOneFolderResource.HAIsolationResponse | Should -Be 'Unset'
            $clusterWithLocationWithOneFolderResource.HARestartPriority | Should -Be 'Unset'
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange && Act && Assert
            Test-DscConfiguration | Should -Be $true
        }

        It "Should have the following dependency: Resource $($script:folderWithEmptyLocationResourceName) should depend on Resource $($script:haClusterWithLocationWithOneFolderResourceName)" {
            # Arrange && Act
            $folderWithEmptyLocationResource = Get-DscConfiguration | Where-Object { $_.ResourceId -eq $script:folderWithEmptyLocationResourceId }

            # Assert
            $folderWithEmptyLocationResource.DependsOn | Should -Be $script:haClusterWithLocationWithOneFolderResourceId
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

    Context "When using configuration $($script:configWhenRemovingClusterWithLocationWithTwoFolders)" {
        BeforeAll {
            # Arrange
            $startDscConfigurationParametersWhenAddingCluster = @{
                Path = $script:mofFileWhenAddingClusterWithLocationWithTwoFoldersPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            $startDscConfigurationParametersWhenRemovingCluster = @{
                Path = $script:mofFileWhenRemovingClusterWithLocationWithTwoFoldersPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersWhenAddingCluster
            Start-DscConfiguration @startDscConfigurationParametersWhenRemovingCluster
        }

        It 'Should compile and apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingClusterWithLocationWithTwoFoldersPath
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
            $clusterWithLocationWithTwoFoldersResource = $configuration | Where-Object { $_.ResourceId -eq $script:haClusterWithLocationWithTwoFoldersResourceId }

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

            $clusterWithLocationWithTwoFoldersResource.Server | Should -Be $Server
            $clusterWithLocationWithTwoFoldersResource.Name | Should -Be $script:clusterName
            $clusterWithLocationWithTwoFoldersResource.Location | Should -Be $script:clusterWithLocationWithTwoFolders
            $clusterWithLocationWithTwoFoldersResource.DatacenterName | Should -Be $script:datacenterName
            $clusterWithLocationWithTwoFoldersResource.DatacenterLocation | Should -Be $script:datacenterLocationWithOneFolder
            $clusterWithLocationWithTwoFoldersResource.Ensure | Should -Be 'Absent'
            $clusterWithLocationWithTwoFoldersResource.HAEnabled | Should -Be $null
            $clusterWithLocationWithTwoFoldersResource.HAAdmissionControlEnabled | Should -Be $null
            $clusterWithLocationWithTwoFoldersResource.HAFailoverLevel | Should -Be $null
            $clusterWithLocationWithTwoFoldersResource.HAIsolationResponse | Should -Be 'Unset'
            $clusterWithLocationWithTwoFoldersResource.HARestartPriority | Should -Be 'Unset'
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange && Act && Assert
            Test-DscConfiguration | Should -Be $true
        }

        It "Should have the following dependency: Resource $($script:folderWithLocationWithOneFolderResourceName) should depend on Resource $($script:haClusterWithLocationWithTwoFoldersResourceName)" {
            # Arrange && Act
            $folderWithLocationWithOneFolderResource = Get-DscConfiguration | Where-Object { $_.ResourceId -eq $script:folderWithLocationWithOneFolderResourceId }

            # Assert
            $folderWithLocationWithOneFolderResource.DependsOn | Should -Be $script:haClusterWithLocationWithTwoFoldersResourceId
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
}
