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

$script:dscResourceName = 'VMHostVssPortGroupSecurity'
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
            Name = $Name
            StandardSwitchResourceName = 'StandardSwitch'
            StandardSwitchResourceId = '[VMHostVss]StandardSwitch'
            StandardSwitchSecurityPolicyResourceName = 'StandardSwitchSecurityPolicy'
            StandardSwitchSecurityPolicyResourceId = '[VMHostVssSecurity]StandardSwitchSecurityPolicy'
            VirtualPortGroupResourceName = 'VirtualPortGroup'
            VirtualPortGroupResourceId = '[VMHostVssPortGroup]VirtualPortGroup'
            VirtualPortGroupSecurityPolicyResourceName = 'VirtualPortGroupSecurityPolicy'
            VirtualPortGroupSecurityPolicyResourceId = '[VMHostVssPortGroupSecurity]VirtualPortGroupSecurityPolicy'
            StandardSwitchName = 'MyStandardSwitch'
            StandardSwitchMtu = 1500
            VirtualPortGroupName = 'MyVirtualPortGroup'
            VlanId = 0
            AllowPromiscuous = $true
            AllowPromiscuousInherited = $false
            ForgedTransmits = $true
            ForgedTransmitsInherited = $false
            MacChanges = $true
            MacChangesInherited = $false
        }
    )
}

$script:configWhenAddingVirtualPortGroupAndStandardSwitch = "$($script:dscResourceName)_WhenAddingVirtualPortGroupAndStandardSwitch_Config"
$script:configWhenUpdatingSecurityPolicyWithoutInheritSettings = "$($script:dscResourceName)_WhenUpdatingSecurityPolicyWithoutInheritSettings_Config"
$script:configWhenUpdatingSecurityPolicyWithInheritSettingsSetToFalse = "$($script:dscResourceName)_WhenUpdatingSecurityPolicyWithInheritSettingsSetToFalse_Config"
$script:configWhenUpdatingSecurityPolicyWithInheritSettingsSetToTrue = "$($script:dscResourceName)_WhenUpdatingSecurityPolicyWithInheritSettingsSetToTrue_Config"
$script:configWhenRemovingVirtualPortGroupAndStandardSwitch = "$($script:dscResourceName)_WhenRemovingVirtualPortGroupAndStandardSwitch_Config"

. $script:configurationFile -ErrorAction Stop

$script:mofFileWhenAddingVirtualPortGroupAndStandardSwitchPath = "$script:integrationTestsFolderPath\$script:configWhenAddingVirtualPortGroupAndStandardSwitch\"
$script:mofFileWhenUpdatingSecurityPolicyWithoutInheritSettingsPath = "$script:integrationTestsFolderPath\$script:configWhenUpdatingSecurityPolicyWithoutInheritSettings\"
$script:mofFileWhenUpdatingSecurityPolicyWithInheritSettingsSetToFalsePath = "$script:integrationTestsFolderPath\$script:configWhenUpdatingSecurityPolicyWithInheritSettingsSetToFalse\"
$script:mofFileWhenUpdatingSecurityPolicyWithInheritSettingsSetToTruePath = "$script:integrationTestsFolderPath\$script:configWhenUpdatingSecurityPolicyWithInheritSettingsSetToTrue\"
$script:mofFileWhenRemovingVirtualPortGroupAndStandardSwitchPath = "$script:integrationTestsFolderPath\$script:configWhenRemovingVirtualPortGroupAndStandardSwitch\"

Describe "$($script:dscResourceName)_Integration" {
    Context "When using configuration $script:configWhenUpdatingSecurityPolicyWithoutInheritSettings" {
        BeforeAll {
            # Arrange
            & $script:configWhenAddingVirtualPortGroupAndStandardSwitch `
                -OutputPath $script:mofFileWhenAddingVirtualPortGroupAndStandardSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configWhenUpdatingSecurityPolicyWithoutInheritSettings `
                -OutputPath $script:mofFileWhenUpdatingSecurityPolicyWithoutInheritSettingsPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersWhenAddingVirtualPortGroupAndStandardSwitch = @{
                Path = $script:mofFileWhenAddingVirtualPortGroupAndStandardSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersWhenUpdatingSecurityPolicyWithoutInheritSettings = @{
                Path = $script:mofFileWhenUpdatingSecurityPolicyWithoutInheritSettingsPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersWhenAddingVirtualPortGroupAndStandardSwitch
            Start-DscConfiguration @startDscConfigurationParametersWhenUpdatingSecurityPolicyWithoutInheritSettings
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenUpdatingSecurityPolicyWithoutInheritSettingsPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configWhenUpdatingSecurityPolicyWithoutInheritSettings }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.Name
            $configuration.Name | Should -Be $script:configurationData.AllNodes.VirtualPortGroupName
            $configuration.Ensure | Should -Be 'Present'
            $configuration.AllowPromiscuous | Should -Be $script:configurationData.AllNodes.AllowPromiscuous
            $configuration.AllowPromiscuousInherited | Should -Be $script:configurationData.AllNodes.AllowPromiscuousInherited
            $configuration.ForgedTransmits | Should -Be $script:configurationData.AllNodes.ForgedTransmits
            $configuration.ForgedTransmitsInherited | Should -Be $script:configurationData.AllNodes.ForgedTransmitsInherited
            $configuration.MacChanges | Should -Be $script:configurationData.AllNodes.MacChanges
            $configuration.MacChangesInherited | Should -Be $script:configurationData.AllNodes.MacChangesInherited
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileWhenUpdatingSecurityPolicyWithoutInheritSettingsPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configWhenRemovingVirtualPortGroupAndStandardSwitch `
                -OutputPath $script:mofFileWhenRemovingVirtualPortGroupAndStandardSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingVirtualPortGroupAndStandardSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileWhenAddingVirtualPortGroupAndStandardSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileWhenUpdatingSecurityPolicyWithoutInheritSettingsPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileWhenRemovingVirtualPortGroupAndStandardSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configWhenUpdatingSecurityPolicyWithInheritSettingsSetToFalse" {
        BeforeAll {
            # Arrange
            & $script:configWhenAddingVirtualPortGroupAndStandardSwitch `
                -OutputPath $script:mofFileWhenAddingVirtualPortGroupAndStandardSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configWhenUpdatingSecurityPolicyWithInheritSettingsSetToFalse `
                -OutputPath $script:mofFileWhenUpdatingSecurityPolicyWithInheritSettingsSetToFalsePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersWhenAddingVirtualPortGroupAndStandardSwitch = @{
                Path = $script:mofFileWhenAddingVirtualPortGroupAndStandardSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersWhenUpdatingSecurityPolicyWithInheritSettingsSetToFalse = @{
                Path = $script:mofFileWhenUpdatingSecurityPolicyWithInheritSettingsSetToFalsePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersWhenAddingVirtualPortGroupAndStandardSwitch
            Start-DscConfiguration @startDscConfigurationParametersWhenUpdatingSecurityPolicyWithInheritSettingsSetToFalse
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenUpdatingSecurityPolicyWithInheritSettingsSetToFalsePath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configWhenUpdatingSecurityPolicyWithInheritSettingsSetToFalse }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.Name
            $configuration.Name | Should -Be $script:configurationData.AllNodes.VirtualPortGroupName
            $configuration.Ensure | Should -Be 'Present'
            $configuration.AllowPromiscuous | Should -Be $script:configurationData.AllNodes.AllowPromiscuous
            $configuration.AllowPromiscuousInherited | Should -Be $script:configurationData.AllNodes.AllowPromiscuousInherited
            $configuration.ForgedTransmits | Should -Be $script:configurationData.AllNodes.ForgedTransmits
            $configuration.ForgedTransmitsInherited | Should -Be $script:configurationData.AllNodes.ForgedTransmitsInherited
            $configuration.MacChanges | Should -Be $script:configurationData.AllNodes.MacChanges
            $configuration.MacChangesInherited | Should -Be $script:configurationData.AllNodes.MacChangesInherited
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileWhenUpdatingSecurityPolicyWithInheritSettingsSetToFalsePath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configWhenRemovingVirtualPortGroupAndStandardSwitch `
                -OutputPath $script:mofFileWhenRemovingVirtualPortGroupAndStandardSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingVirtualPortGroupAndStandardSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileWhenAddingVirtualPortGroupAndStandardSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileWhenUpdatingSecurityPolicyWithInheritSettingsSetToFalsePath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileWhenRemovingVirtualPortGroupAndStandardSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configWhenUpdatingSecurityPolicyWithInheritSettingsSetToTrue" {
        BeforeAll {
            # Arrange
            & $script:configWhenAddingVirtualPortGroupAndStandardSwitch `
                -OutputPath $script:mofFileWhenAddingVirtualPortGroupAndStandardSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configWhenUpdatingSecurityPolicyWithInheritSettingsSetToTrue `
                -OutputPath $script:mofFileWhenUpdatingSecurityPolicyWithInheritSettingsSetToTruePath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersWhenAddingVirtualPortGroupAndStandardSwitch = @{
                Path = $script:mofFileWhenAddingVirtualPortGroupAndStandardSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersWhenUpdatingSecurityPolicyWithInheritSettingsSetToTrue = @{
                Path = $script:mofFileWhenUpdatingSecurityPolicyWithInheritSettingsSetToTruePath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersWhenAddingVirtualPortGroupAndStandardSwitch
            Start-DscConfiguration @startDscConfigurationParametersWhenUpdatingSecurityPolicyWithInheritSettingsSetToTrue
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenUpdatingSecurityPolicyWithInheritSettingsSetToTruePath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configWhenUpdatingSecurityPolicyWithInheritSettingsSetToTrue }

            $standardSwitchSecurityPolicyResource = $configuration | Where-Object { $_.ResourceId -eq $script:configurationData.AllNodes.StandardSwitchSecurityPolicyResourceId }
            $virtualPortGroupSecurityPolicyResource = $configuration | Where-Object { $_.ResourceId -eq $script:configurationData.AllNodes.VirtualPortGroupSecurityPolicyResourceId }

            $standardSwitchSecurityPolicyResource.Server | Should -Be $script:configurationData.AllNodes.Server
            $standardSwitchSecurityPolicyResource.Name | Should -Be $script:configurationData.AllNodes.Name
            $standardSwitchSecurityPolicyResource.VssName | Should -Be $script:configurationData.AllNodes.StandardSwitchName
            $standardSwitchSecurityPolicyResource.Ensure | Should -Be 'Present'
            $standardSwitchSecurityPolicyResource.AllowPromiscuous | Should -Be $script:configurationData.AllNodes.AllowPromiscuous
            $standardSwitchSecurityPolicyResource.ForgedTransmits | Should -Be $false
            $standardSwitchSecurityPolicyResource.MacChanges | Should -Be $false

            # Assert
            $virtualPortGroupSecurityPolicyResource.Server | Should -Be $script:configurationData.AllNodes.Server
            $virtualPortGroupSecurityPolicyResource.VMHostName | Should -Be $script:configurationData.AllNodes.Name
            $virtualPortGroupSecurityPolicyResource.Name | Should -Be $script:configurationData.AllNodes.VirtualPortGroupName
            $virtualPortGroupSecurityPolicyResource.Ensure | Should -Be 'Present'
            $virtualPortGroupSecurityPolicyResource.AllowPromiscuous | Should -Be $script:configurationData.AllNodes.AllowPromiscuous
            $virtualPortGroupSecurityPolicyResource.AllowPromiscuousInherited | Should -Be $true
            $virtualPortGroupSecurityPolicyResource.ForgedTransmits | Should -Be $false
            $virtualPortGroupSecurityPolicyResource.ForgedTransmitsInherited | Should -Be $true
            $virtualPortGroupSecurityPolicyResource.MacChanges | Should -Be $false
            $virtualPortGroupSecurityPolicyResource.MacChangesInherited | Should -Be $true
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileWhenUpdatingSecurityPolicyWithInheritSettingsSetToTruePath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        It "Should have the following dependency: Resource $($script:configurationData.AllNodes.VirtualPortGroupSecurityPolicyResourceName) should depend on Resource $($script:configurationData.AllNodes.StandardSwitchSecurityPolicyResourceName)" {
            # Arrange && Act
            $virtualPortGroupSecurityPolicyResource = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript {
                $_.ConfigurationName -eq $script:configWhenUpdatingSecurityPolicyWithInheritSettingsSetToTrue -and `
                $_.ResourceId -eq $script:configurationData.AllNodes.VirtualPortGroupSecurityPolicyResourceId
            }

            # Assert
            $virtualPortGroupSecurityPolicyResource.DependsOn | Should -Be $script:configurationData.AllNodes.StandardSwitchSecurityPolicyResourceId
        }

        AfterAll {
            # Arrange
            & $script:configWhenRemovingVirtualPortGroupAndStandardSwitch `
                -OutputPath $script:mofFileWhenRemovingVirtualPortGroupAndStandardSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingVirtualPortGroupAndStandardSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileWhenAddingVirtualPortGroupAndStandardSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileWhenUpdatingSecurityPolicyWithInheritSettingsSetToTruePath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileWhenRemovingVirtualPortGroupAndStandardSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }
}
