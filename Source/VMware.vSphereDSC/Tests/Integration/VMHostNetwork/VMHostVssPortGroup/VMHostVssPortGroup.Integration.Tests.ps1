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

$script:dscResourceName = 'VMHostVssPortGroup'
$script:moduleFolderPath = (Get-Module 'VMware.vSphereDSC' -ListAvailable).ModuleBase
$script:integrationTestsFolderPath = Join-Path (Join-Path $moduleFolderPath 'Tests') 'Integration'
$script:configurationFile = "$script:integrationTestsFolderPath\Configurations\$($script:dscResourceName)\$($script:dscResourceName)_Config.ps1"

$script:configurationData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
            Server = $Server
            Credential = $Credential
            Name = $Name
            StandardSwitchResourceName = 'StandardSwitch'
            VirtualPortGroupResourceName = 'VirtualPortGroup'
            VirtualPortGroupResourceId = '[VMHostVssPortGroup]VirtualPortGroup'
            StandardSwitchName = 'MyStandardSwitch'
            Mtu = 1500
            VirtualPortGroupName = 'MyVirtualPortGroup'
            VLanId = 1
            DefaultVLanId = 0
        }
    )
}

$script:configWhenAddingVirtualStandardSwitch = "$($script:dscResourceName)_WhenAddingVirtualStandardSwitch_Config"
$script:configWhenAddingVirtualPortGroup = "$($script:dscResourceName)_WhenAddingVirtualPortGroup_Config"
$script:configWhenAddingVirtualPortGroupWithVLanId = "$($script:dscResourceName)_WhenAddingVirtualPortGroupWithVLanId_Config"
$script:configWhenUpdatingVirtualPortGroup = "$($script:dscResourceName)_WhenUpdatingVirtualPortGroup_Config"
$script:configWhenRemovingVirtualPortGroup = "$($script:dscResourceName)_WhenRemovingVirtualPortGroup_Config"
$script:configWhenRemovingVirtualPortGroupAndVirtualStandardSwitch = "$($script:dscResourceName)_WhenRemovingVirtualPortGroupAndVirtualStandardSwitch_Config"

. $script:configurationFile -ErrorAction Stop

$script:mofFileWhenAddingVirtualStandardSwitchPath = "$script:integrationTestsFolderPath\$($script:configWhenAddingVirtualStandardSwitch)\"
$script:mofFileWhenAddingVirtualPortGroupPath = "$script:integrationTestsFolderPath\$($script:configWhenAddingVirtualPortGroup)\"
$script:mofFileWhenAddingVirtualPortGroupWithVLanIdPath = "$script:integrationTestsFolderPath\$($script:configWhenAddingVirtualPortGroupWithVLanId)\"
$script:mofFileWhenUpdatingVirtualPortGroupPath = "$script:integrationTestsFolderPath\$($script:configWhenUpdatingVirtualPortGroup)\"
$script:mofFileWhenRemovingVirtualPortGroupPath = "$script:integrationTestsFolderPath\$($script:configWhenRemovingVirtualPortGroup)\"
$script:mofFileWhenRemovingVirtualPortGroupAndVirtualStandardSwitchPath = "$script:integrationTestsFolderPath\$($script:configWhenRemovingVirtualPortGroupAndVirtualStandardSwitch)\"

Describe "$($script:dscResourceName)_Integration" {
    Context "When using configuration $($script:configWhenAddingVirtualPortGroup)" {
        BeforeAll {
            # Arrange
            & $script:configWhenAddingVirtualStandardSwitch `
                -OutputPath $script:mofFileWhenAddingVirtualStandardSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configWhenAddingVirtualPortGroup `
                -OutputPath $script:mofFileWhenAddingVirtualPortGroupPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersWhenAddingVirtualStandardSwitch = @{
                Path = $script:mofFileWhenAddingVirtualStandardSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersWhenAddingVirtualPortGroup = @{
                Path = $script:mofFileWhenAddingVirtualPortGroupPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersWhenAddingVirtualStandardSwitch
            Start-DscConfiguration @startDscConfigurationParametersWhenAddingVirtualPortGroup
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenAddingVirtualPortGroupPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configWhenAddingVirtualPortGroup }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.Name
            $configuration.Name | Should -Be $script:configurationData.AllNodes.VirtualPortGroupName
            $configuration.VssName | Should -Be $script:configurationData.AllNodes.StandardSwitchName
            $configuration.Ensure | Should -Be 'Present'
            $configuration.VLanId | Should -Be $script:configurationData.AllNodes.DefaultVLanId
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileWhenAddingVirtualPortGroupPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configWhenRemovingVirtualPortGroupAndVirtualStandardSwitch `
                -OutputPath $script:mofFileWhenRemovingVirtualPortGroupAndVirtualStandardSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingVirtualPortGroupAndVirtualStandardSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileWhenAddingVirtualStandardSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileWhenAddingVirtualPortGroupPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileWhenRemovingVirtualPortGroupAndVirtualStandardSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $($script:configWhenAddingVirtualPortGroupWithVLanId)" {
        BeforeAll {
            # Arrange
            & $script:configWhenAddingVirtualStandardSwitch `
                -OutputPath $script:mofFileWhenAddingVirtualStandardSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configWhenAddingVirtualPortGroupWithVLanId `
                -OutputPath $script:mofFileWhenAddingVirtualPortGroupWithVLanIdPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersWhenAddingVirtualStandardSwitch = @{
                Path = $script:mofFileWhenAddingVirtualStandardSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersWhenAddingVirtualPortGroupWithVLanId = @{
                Path = $script:mofFileWhenAddingVirtualPortGroupWithVLanIdPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersWhenAddingVirtualStandardSwitch
            Start-DscConfiguration @startDscConfigurationParametersWhenAddingVirtualPortGroupWithVLanId
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenAddingVirtualPortGroupWithVLanIdPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configWhenAddingVirtualPortGroupWithVLanId }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.Name
            $configuration.Name | Should -Be $script:configurationData.AllNodes.VirtualPortGroupName
            $configuration.VssName | Should -Be $script:configurationData.AllNodes.StandardSwitchName
            $configuration.Ensure | Should -Be 'Present'
            $configuration.VLanId | Should -Be $script:configurationData.AllNodes.DefaultVLanId
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileWhenAddingVirtualPortGroupWithVLanIdPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configWhenRemovingVirtualPortGroupAndVirtualStandardSwitch `
                -OutputPath $script:mofFileWhenRemovingVirtualPortGroupAndVirtualStandardSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingVirtualPortGroupAndVirtualStandardSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileWhenAddingVirtualStandardSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileWhenAddingVirtualPortGroupWithVLanIdPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileWhenRemovingVirtualPortGroupAndVirtualStandardSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $($script:configWhenUpdatingVirtualPortGroup)" {
        BeforeAll {
            # Arrange
            & $script:configWhenAddingVirtualStandardSwitch `
                -OutputPath $script:mofFileWhenAddingVirtualStandardSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configWhenAddingVirtualPortGroup `
                -OutputPath $script:mofFileWhenAddingVirtualPortGroupPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configWhenUpdatingVirtualPortGroup `
                -OutputPath $script:mofFileWhenUpdatingVirtualPortGroupPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersWhenAddingVirtualStandardSwitch = @{
                Path = $script:mofFileWhenAddingVirtualStandardSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersWhenAddingVirtualPortGroup = @{
                Path = $script:mofFileWhenAddingVirtualPortGroupPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersWhenUpdatingVirtualPortGroup = @{
                Path = $script:mofFileWhenUpdatingVirtualPortGroupPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersWhenAddingVirtualStandardSwitch
            Start-DscConfiguration @startDscConfigurationParametersWhenAddingVirtualPortGroup
            Start-DscConfiguration @startDscConfigurationParametersWhenUpdatingVirtualPortGroup
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenUpdatingVirtualPortGroupPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configWhenUpdatingVirtualPortGroup }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.Name
            $configuration.Name | Should -Be $script:configurationData.AllNodes.VirtualPortGroupName
            $configuration.VssName | Should -Be $script:configurationData.AllNodes.StandardSwitchName
            $configuration.Ensure | Should -Be 'Present'
            $configuration.VLanId | Should -Be $script:configurationData.AllNodes.VLanId
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileWhenUpdatingVirtualPortGroupPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configWhenRemovingVirtualPortGroupAndVirtualStandardSwitch `
                -OutputPath $script:mofFileWhenRemovingVirtualPortGroupAndVirtualStandardSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingVirtualPortGroupAndVirtualStandardSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileWhenAddingVirtualStandardSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileWhenAddingVirtualPortGroupPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileWhenUpdatingVirtualPortGroupPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileWhenRemovingVirtualPortGroupAndVirtualStandardSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $($script:configWhenRemovingVirtualPortGroup)" {
        BeforeAll {
            # Arrange
            & $script:configWhenAddingVirtualStandardSwitch `
                -OutputPath $script:mofFileWhenAddingVirtualStandardSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configWhenAddingVirtualPortGroup `
                -OutputPath $script:mofFileWhenAddingVirtualPortGroupPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configWhenRemovingVirtualPortGroup `
                -OutputPath $script:mofFileWhenRemovingVirtualPortGroupPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersWhenAddingVirtualStandardSwitch = @{
                Path = $script:mofFileWhenAddingVirtualStandardSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersWhenAddingVirtualPortGroup = @{
                Path = $script:mofFileWhenAddingVirtualPortGroupPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersWhenRemovingVirtualPortGroup = @{
                Path = $script:mofFileWhenRemovingVirtualPortGroupPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersWhenAddingVirtualStandardSwitch
            Start-DscConfiguration @startDscConfigurationParametersWhenAddingVirtualPortGroup
            Start-DscConfiguration @startDscConfigurationParametersWhenRemovingVirtualPortGroup
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingVirtualPortGroupPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configWhenRemovingVirtualPortGroup }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.Name
            $configuration.Name | Should -Be $script:configurationData.AllNodes.VirtualPortGroupName
            $configuration.VssName | Should -Be $script:configurationData.AllNodes.StandardSwitchName
            $configuration.Ensure | Should -Be 'Absent'
            $configuration.VLanId | Should -BeNullOrEmpty
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileWhenRemovingVirtualPortGroupPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configWhenRemovingVirtualPortGroupAndVirtualStandardSwitch `
                -OutputPath $script:mofFileWhenRemovingVirtualPortGroupAndVirtualStandardSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingVirtualPortGroupAndVirtualStandardSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileWhenAddingVirtualStandardSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileWhenAddingVirtualPortGroupPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileWhenRemovingVirtualPortGroupPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileWhenRemovingVirtualPortGroupAndVirtualStandardSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }
}
