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

$script:dscResourceName = 'VMHostVirtualPortGroup'
$script:moduleFolderPath = (Get-Module 'VMware.vSphereDSC' -ListAvailable).ModuleBase
$script:integrationTestsFolderPath = Join-Path (Join-Path $moduleFolderPath 'Tests') 'Integration'
$script:configurationFile = "$script:integrationTestsFolderPath\Configurations\$($script:dscResourceName)\$($script:dscResourceName)_Config.ps1"

$script:configWhenAddingVirtualPortGroup = "$($script:dscResourceName)_WhenAddingVirtualPortGroup_Config"
$script:configWhenAddingVirtualPortGroupWithVLanId = "$($script:dscResourceName)_WhenAddingVirtualPortGroupWithVLanId_Config"
$script:configWhenUpdatingVirtualPortGroup = "$($script:dscResourceName)_WhenUpdatingVirtualPortGroup_Config"
$script:configWhenRemovingVirtualPortGroup = "$($script:dscResourceName)_WhenRemovingVirtualPortGroup_Config"
$script:configWhenRemovingVirtualPortGroupAndVirtualSwitch = "$($script:dscResourceName)_WhenRemovingVirtualPortGroupAndVirtualSwitch_Config"

. $script:configurationFile -Name $Name -Server $Server -User $User -Password $Password

$script:mofFileWhenAddingVirtualPortGroupPath = "$script:integrationTestsFolderPath\$($script:configWhenAddingVirtualPortGroup)\"
$script:mofFileWhenAddingVirtualPortGroupWithVLanIdPath = "$script:integrationTestsFolderPath\$($script:configWhenAddingVirtualPortGroupWithVLanId)\"
$script:mofFileWhenUpdatingVirtualPortGroupPath = "$script:integrationTestsFolderPath\$($script:configWhenUpdatingVirtualPortGroup)\"
$script:mofFileWhenRemovingVirtualPortGroupPath = "$script:integrationTestsFolderPath\$($script:configWhenRemovingVirtualPortGroup)\"
$script:mofFileWhenRemovingVirtualPortGroupAndVirtualSwitchPath = "$script:integrationTestsFolderPath\$($script:configWhenRemovingVirtualPortGroupAndVirtualSwitch)\"

Describe "$($script:dscResourceName)_Integration" {
    Context "When using configuration $($script:configWhenAddingVirtualPortGroup)" {
        BeforeAll {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenAddingVirtualPortGroupPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters
        }

        It 'Should compile and apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenAddingVirtualPortGroupPath
                ComputerName = 'localhost'
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
            $configuration = Get-DscConfiguration -Verbose

            $virtualSwitchForVirtualPortGroupResource = $configuration | Where-Object { $_.ResourceId -eq $script:virtualSwitchForVirtualPortGroupResourceId }
            $virtualPortGroupResource = $configuration | Where-Object { $_.ResourceId -eq $script:virtualPortGroupResourceId }

            # Assert
            $virtualSwitchForVirtualPortGroupResource.Server | Should -Be $Server
            $virtualSwitchForVirtualPortGroupResource.Name | Should -Be $Name
            $virtualSwitchForVirtualPortGroupResource.VssName | Should -Be $script:virtualSwitchName
            $virtualSwitchForVirtualPortGroupResource.Ensure | Should -Be 'Present'
            $virtualSwitchForVirtualPortGroupResource.Mtu | Should -Be $script:virtualSwitchMtu

            $virtualPortGroupResource.Server | Should -Be $Server
            $virtualPortGroupResource.Name | Should -Be $Name
            $virtualPortGroupResource.PortGroupName | Should -Be $script:virtualPortGroupName
            $virtualPortGroupResource.VirtualSwitch | Should -Be $script:virtualSwitchName
            $virtualPortGroupResource.Ensure | Should -Be 'Present'
            $virtualPortGroupResource.VLanId | Should -Be 0
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange && Act && Assert
            Test-DscConfiguration -Verbose | Should -Be $true
        }

        It "Should have the following dependency: Resource $($script:virtualPortGroupResourceName) should depend on Resource $($script:virtualSwitchForVirtualPortGroupResourceName)" {
            # Arrange && Act
            $virtualPortGroupResource = Get-DscConfiguration | Where-Object { $_.ResourceId -eq $script:virtualPortGroupResourceId }

            # Assert
            $virtualPortGroupResource.DependsOn | Should -Be $script:virtualSwitchForVirtualPortGroupResourceId
        }

        AfterAll {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingVirtualPortGroupAndVirtualSwitchPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters
        }
    }

    Context "When using configuration $($script:configWhenAddingVirtualPortGroupWithVLanId)" {
        BeforeAll {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenAddingVirtualPortGroupWithVLanIdPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters
        }

        It 'Should compile and apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenAddingVirtualPortGroupWithVLanIdPath
                ComputerName = 'localhost'
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
            $configuration = Get-DscConfiguration -Verbose

            $virtualSwitchForVirtualPortGroupResource = $configuration | Where-Object { $_.ResourceId -eq $script:virtualSwitchForVirtualPortGroupResourceId }
            $virtualPortGroupResource = $configuration | Where-Object { $_.ResourceId -eq $script:virtualPortGroupResourceId }

            # Assert
            $virtualSwitchForVirtualPortGroupResource.Server | Should -Be $Server
            $virtualSwitchForVirtualPortGroupResource.Name | Should -Be $Name
            $virtualSwitchForVirtualPortGroupResource.VssName | Should -Be $script:virtualSwitchName
            $virtualSwitchForVirtualPortGroupResource.Ensure | Should -Be 'Present'
            $virtualSwitchForVirtualPortGroupResource.Mtu | Should -Be $script:virtualSwitchMtu

            $virtualPortGroupResource.Server | Should -Be $Server
            $virtualPortGroupResource.Name | Should -Be $Name
            $virtualPortGroupResource.PortGroupName | Should -Be $script:virtualPortGroupName
            $virtualPortGroupResource.VirtualSwitch | Should -Be $script:virtualSwitchName
            $virtualPortGroupResource.Ensure | Should -Be 'Present'
            $virtualPortGroupResource.VLanId | Should -Be $script:vlanId
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange && Act && Assert
            Test-DscConfiguration -Verbose | Should -Be $true
        }

        It "Should have the following dependency: Resource $($script:virtualPortGroupResourceName) should depend on Resource $($script:virtualSwitchForVirtualPortGroupResourceName)" {
            # Arrange && Act
            $virtualPortGroupResource = Get-DscConfiguration | Where-Object { $_.ResourceId -eq $script:virtualPortGroupResourceId }

            # Assert
            $virtualPortGroupResource.DependsOn | Should -Be $script:virtualSwitchForVirtualPortGroupResourceId
        }

        AfterAll {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingVirtualPortGroupAndVirtualSwitchPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters
        }
    }

    Context "When using configuration $($script:configWhenUpdatingVirtualPortGroup)" {
        BeforeAll {
            # Arrange
            $startDscConfigurationParametersWhenAddingVirtualPortGroup = @{
                Path = $script:mofFileWhenAddingVirtualPortGroupPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersWhenUpdatingVirtualPortGroup = @{
                Path = $script:mofFileWhenUpdatingVirtualPortGroupPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersWhenAddingVirtualPortGroup
            Start-DscConfiguration @startDscConfigurationParametersWhenUpdatingVirtualPortGroup
        }

        It 'Should compile and apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenUpdatingVirtualPortGroupPath
                ComputerName = 'localhost'
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
            $configuration = Get-DscConfiguration -Verbose

            $virtualSwitchForVirtualPortGroupResource = $configuration | Where-Object { $_.ResourceId -eq $script:virtualSwitchForVirtualPortGroupResourceId }
            $virtualPortGroupResource = $configuration | Where-Object { $_.ResourceId -eq $script:virtualPortGroupResourceId }

            # Assert
            $virtualSwitchForVirtualPortGroupResource.Server | Should -Be $Server
            $virtualSwitchForVirtualPortGroupResource.Name | Should -Be $Name
            $virtualSwitchForVirtualPortGroupResource.VssName | Should -Be $script:virtualSwitchName
            $virtualSwitchForVirtualPortGroupResource.Ensure | Should -Be 'Present'
            $virtualSwitchForVirtualPortGroupResource.Mtu | Should -Be $script:virtualSwitchMtu

            $virtualPortGroupResource.Server | Should -Be $Server
            $virtualPortGroupResource.Name | Should -Be $Name
            $virtualPortGroupResource.PortGroupName | Should -Be $script:virtualPortGroupName
            $virtualPortGroupResource.VirtualSwitch | Should -Be $script:virtualSwitchName
            $virtualPortGroupResource.Ensure | Should -Be 'Present'
            $virtualPortGroupResource.VLanId | Should -Be ($script:vlanId + 1)
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange && Act && Assert
            Test-DscConfiguration -Verbose | Should -Be $true
        }

        It "Should have the following dependency: Resource $($script:virtualPortGroupResourceName) should depend on Resource $($script:virtualSwitchForVirtualPortGroupResourceName)" {
            # Arrange && Act
            $virtualPortGroupResource = Get-DscConfiguration | Where-Object { $_.ResourceId -eq $script:virtualPortGroupResourceId }

            # Assert
            $virtualPortGroupResource.DependsOn | Should -Be $script:virtualSwitchForVirtualPortGroupResourceId
        }

        AfterAll {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingVirtualPortGroupAndVirtualSwitchPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters
        }
    }

    Context "When using configuration $($script:configWhenRemovingVirtualPortGroup)" {
        BeforeAll {
            # Arrange
            $startDscConfigurationParametersWhenAddingVirtualPortGroup = @{
                Path = $script:mofFileWhenAddingVirtualPortGroupPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersWhenRemovingVirtualPortGroup = @{
                Path = $script:mofFileWhenRemovingVirtualPortGroupPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersWhenAddingVirtualPortGroup
            Start-DscConfiguration @startDscConfigurationParametersWhenRemovingVirtualPortGroup
        }

        It 'Should compile and apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingVirtualPortGroupPath
                ComputerName = 'localhost'
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
            $configuration = Get-DscConfiguration -Verbose

            $virtualSwitchForVirtualPortGroupResource = $configuration | Where-Object { $_.ResourceId -eq $script:virtualSwitchForVirtualPortGroupResourceId }
            $virtualPortGroupResource = $configuration | Where-Object { $_.ResourceId -eq $script:virtualPortGroupResourceId }

            # Assert
            $virtualSwitchForVirtualPortGroupResource.Server | Should -Be $Server
            $virtualSwitchForVirtualPortGroupResource.Name | Should -Be $Name
            $virtualSwitchForVirtualPortGroupResource.VssName | Should -Be $script:virtualSwitchName
            $virtualSwitchForVirtualPortGroupResource.Ensure | Should -Be 'Present'
            $virtualSwitchForVirtualPortGroupResource.Mtu | Should -Be $script:virtualSwitchMtu

            $virtualPortGroupResource.Server | Should -Be $Server
            $virtualPortGroupResource.Name | Should -Be $Name
            $virtualPortGroupResource.PortGroupName | Should -Be $script:virtualPortGroupName
            $virtualPortGroupResource.VirtualSwitch | Should -Be $script:virtualSwitchName
            $virtualPortGroupResource.Ensure | Should -Be 'Absent'
            $virtualPortGroupResource.VLanId | Should -Be $null
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange && Act && Assert
            Test-DscConfiguration -Verbose | Should -Be $true
        }

        It "Should have the following dependency: Resource $($script:virtualPortGroupResourceName) should depend on Resource $($script:virtualSwitchForVirtualPortGroupResourceName)" {
            # Arrange && Act
            $virtualPortGroupResource = Get-DscConfiguration | Where-Object { $_.ResourceId -eq $script:virtualPortGroupResourceId }

            # Assert
            $virtualPortGroupResource.DependsOn | Should -Be $script:virtualSwitchForVirtualPortGroupResourceId
        }

        AfterAll {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingVirtualPortGroupAndVirtualSwitchPath
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters
        }
    }
}
