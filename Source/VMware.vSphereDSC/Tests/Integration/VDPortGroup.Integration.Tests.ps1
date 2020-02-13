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
    [string]
    $Name
)

# Mandatory Integration Tests parameter is not used so it is set to $null.
$Name = $null

$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (ConvertTo-SecureString -String $Password -AsPlainText -Force)

$script:dscResourceName = 'VDPortGroup'
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
            DatacenterResourceName = 'Datacenter'
            DatacenterResourceId = '[Datacenter]Datacenter'
            VDSwitchResourceName = 'VDSwitch'
            VDSwitchResourceId = '[VDSwitch]VDSwitch'
            VDPortGroupResourceName = 'VDPortGroup'
            VDPortGroupResourceId = '[VDPortGroup]VDPortGroup'
            ReferenceVDPortGroupResourceName = 'VDPortGroupViaReferenceVDPortGroup'
            ReferenceVDPortGroupResourceId = '[VDPortGroup]VDPortGroupViaReferenceVDPortGroup'
            DatacenterName = 'MyTestDatacenter'
            DatacenterLocation = [string]::Empty
            VDSwitchName = 'MyTestVDSwitch'
            VDSwitchLocation = [string]::Empty
            VDPortGroupName = 'MyTestVDPortGroup'
            ReferenceVDPortGroupName = 'MyTestVDPortGroupViaReferenceVDPortGroup'
            VDPortGroupNotes = 'MyTestVDPortGroup Notes'
            VDPortGroupDefaultNotes = [string]::Empty
            VDPortGroupNumPorts = 256
            VDPortGroupDefaultNumPorts = 128
            VDPortGroupPortBinding = 'Static'
        }
    )
}

$script:configCreateDatacenterAndVDSwitch = "$($script:dscResourceName)_CreateDatacenterAndVDSwitch_Config"
$script:configCreateVDPortGroup = "$($script:dscResourceName)_CreateVDPortGroup_Config"
$script:configCreateVDPortGroupViaReferenceVDPortGroup = "$($script:dscResourceName)_CreateVDPortGroupViaReferenceVDPortGroup_Config"
$script:configModifyVDPortGroupNotesAndNumPorts = "$($script:dscResourceName)_ModifyVDPortGroupNotesAndNumPorts_Config"
$script:configRemoveVDPortGroup = "$($script:dscResourceName)_RemoveVDPortGroup_Config"
$script:configRemoveDatacenterVDSwitchAndVDPortGroup = "$($script:dscResourceName)_RemoveDatacenterVDSwitchAndVDPortGroup_Config"

. $script:configurationFile -ErrorAction Stop

$script:mofFileCreateDatacenterAndVDSwitchPath = "$script:integrationTestsFolderPath\$script:configCreateDatacenterAndVDSwitch\"
$script:mofFileCreateVDPortGroupPath = "$script:integrationTestsFolderPath\$script:configCreateVDPortGroup\"
$script:mofFileCreateVDPortGroupViaReferenceVDPortGroupPath = "$script:integrationTestsFolderPath\$script:configCreateVDPortGroupViaReferenceVDPortGroup\"
$script:mofFileModifyVDPortGroupNotesAndNumPortsPath = "$script:integrationTestsFolderPath\$script:configModifyVDPortGroupNotesAndNumPorts\"
$script:mofFileRemoveVDPortGroupPath = "$script:integrationTestsFolderPath\$script:configRemoveVDPortGroup\"
$script:mofFileRemoveDatacenterVDSwitchAndVDPortGroupPath = "$script:integrationTestsFolderPath\$script:configRemoveDatacenterVDSwitchAndVDPortGroup\"

Describe "$($script:dscResourceName)_Integration" {
    Context "When using configuration $script:configCreateVDPortGroup" {
        BeforeAll {
            # Arrange
            & $script:configCreateDatacenterAndVDSwitch `
                -OutputPath $script:mofFileCreateDatacenterAndVDSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configCreateVDPortGroup `
                -OutputPath $script:mofFileCreateVDPortGroupPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersCreateDatacenterAndVDSwitch = @{
                Path = $script:mofFileCreateDatacenterAndVDSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersCreateVDPortGroup = @{
                Path = $script:mofFileCreateVDPortGroupPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersCreateDatacenterAndVDSwitch
            Start-DscConfiguration @startDscConfigurationParametersCreateVDPortGroup
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileCreateVDPortGroupPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configCreateVDPortGroup }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.Name | Should -Be $script:configurationData.AllNodes.VDPortGroupName
            $configuration.VdsName | Should -Be $script:configurationData.AllNodes.VDSwitchName
            $configuration.Ensure | Should -Be 'Present'
            $configuration.Notes | Should -Be $script:configurationData.AllNodes.VDPortGroupNotes
            $configuration.NumPorts | Should -Be $script:configurationData.AllNodes.VDPortGroupNumPorts
            $configuration.PortBinding | Should -Be $script:configurationData.AllNodes.VDPortGroupPortBinding
            $configuration.ReferenceVDPortGroupName | Should -BeNullOrEmpty
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileCreateVDPortGroupPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configRemoveDatacenterVDSwitchAndVDPortGroup `
                -OutputPath $script:mofFileRemoveDatacenterVDSwitchAndVDPortGroupPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileRemoveDatacenterVDSwitchAndVDPortGroupPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileCreateDatacenterAndVDSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileCreateVDPortGroupPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveDatacenterVDSwitchAndVDPortGroupPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configCreateVDPortGroupViaReferenceVDPortGroup" {
        BeforeAll {
            # Arrange
            & $script:configCreateDatacenterAndVDSwitch `
                -OutputPath $script:mofFileCreateDatacenterAndVDSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configCreateVDPortGroup `
                -OutputPath $script:mofFileCreateVDPortGroupPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configCreateVDPortGroupViaReferenceVDPortGroup `
                -OutputPath $script:mofFileCreateVDPortGroupViaReferenceVDPortGroupPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersCreateDatacenterAndVDSwitch = @{
                Path = $script:mofFileCreateDatacenterAndVDSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersCreateVDPortGroup = @{
                Path = $script:mofFileCreateVDPortGroupPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersCreateVDPortGroupViaReferenceVDPortGroup = @{
                Path = $script:mofFileCreateVDPortGroupViaReferenceVDPortGroupPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersCreateDatacenterAndVDSwitch
            Start-DscConfiguration @startDscConfigurationParametersCreateVDPortGroup
            Start-DscConfiguration @startDscConfigurationParametersCreateVDPortGroupViaReferenceVDPortGroup
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileCreateVDPortGroupViaReferenceVDPortGroupPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configCreateVDPortGroupViaReferenceVDPortGroup }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.Name | Should -Be $script:configurationData.AllNodes.ReferenceVDPortGroupName
            $configuration.VdsName | Should -Be $script:configurationData.AllNodes.VDSwitchName
            $configuration.Ensure | Should -Be 'Present'
            $configuration.Notes | Should -Be $script:configurationData.AllNodes.VDPortGroupNotes
            $configuration.NumPorts | Should -Be $script:configurationData.AllNodes.VDPortGroupNumPorts
            $configuration.PortBinding | Should -Be $script:configurationData.AllNodes.VDPortGroupPortBinding
            $configuration.ReferenceVDPortGroupName | Should -Be $script:configurationData.AllNodes.VDPortGroupName
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileCreateVDPortGroupViaReferenceVDPortGroupPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configRemoveDatacenterVDSwitchAndVDPortGroup `
                -OutputPath $script:mofFileRemoveDatacenterVDSwitchAndVDPortGroupPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileRemoveDatacenterVDSwitchAndVDPortGroupPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileCreateDatacenterAndVDSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileCreateVDPortGroupPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileCreateVDPortGroupViaReferenceVDPortGroupPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveDatacenterVDSwitchAndVDPortGroupPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configModifyVDPortGroupNotesAndNumPorts" {
        BeforeAll {
            # Arrange
            & $script:configCreateDatacenterAndVDSwitch `
                -OutputPath $script:mofFileCreateDatacenterAndVDSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configCreateVDPortGroup `
                -OutputPath $script:mofFileCreateVDPortGroupPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configModifyVDPortGroupNotesAndNumPorts `
                -OutputPath $script:mofFileModifyVDPortGroupNotesAndNumPortsPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersCreateDatacenterAndVDSwitch = @{
                Path = $script:mofFileCreateDatacenterAndVDSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersCreateVDPortGroup = @{
                Path = $script:mofFileCreateVDPortGroupPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersModifyVDPortGroupNotesAndNumPorts = @{
                Path = $script:mofFileModifyVDPortGroupNotesAndNumPortsPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersCreateDatacenterAndVDSwitch
            Start-DscConfiguration @startDscConfigurationParametersCreateVDPortGroup
            Start-DscConfiguration @startDscConfigurationParametersModifyVDPortGroupNotesAndNumPorts
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileModifyVDPortGroupNotesAndNumPortsPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configModifyVDPortGroupNotesAndNumPorts }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.Name | Should -Be $script:configurationData.AllNodes.VDPortGroupName
            $configuration.VdsName | Should -Be $script:configurationData.AllNodes.VDSwitchName
            $configuration.Ensure | Should -Be 'Present'
            $configuration.Notes | Should -Be $script:configurationData.AllNodes.VDPortGroupDefaultNotes
            $configuration.NumPorts | Should -Be $script:configurationData.AllNodes.VDPortGroupDefaultNumPorts
            $configuration.PortBinding | Should -Be $script:configurationData.AllNodes.VDPortGroupPortBinding
            $configuration.ReferenceVDPortGroupName | Should -BeNullOrEmpty
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileModifyVDPortGroupNotesAndNumPortsPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configRemoveDatacenterVDSwitchAndVDPortGroup `
                -OutputPath $script:mofFileRemoveDatacenterVDSwitchAndVDPortGroupPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileRemoveDatacenterVDSwitchAndVDPortGroupPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileCreateDatacenterAndVDSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileCreateVDPortGroupPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileModifyVDPortGroupNotesAndNumPortsPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveDatacenterVDSwitchAndVDPortGroupPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configRemoveVDPortGroup" {
        BeforeAll {
            # Arrange
            & $script:configCreateDatacenterAndVDSwitch `
                -OutputPath $script:mofFileCreateDatacenterAndVDSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configCreateVDPortGroup `
                -OutputPath $script:mofFileCreateVDPortGroupPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configRemoveVDPortGroup `
                -OutputPath $script:mofFileRemoveVDPortGroupPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersCreateDatacenterAndVDSwitch = @{
                Path = $script:mofFileCreateDatacenterAndVDSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersCreateVDPortGroup = @{
                Path = $script:mofFileCreateVDPortGroupPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersRemoveVDPortGroup = @{
                Path = $script:mofFileRemoveVDPortGroupPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersCreateDatacenterAndVDSwitch
            Start-DscConfiguration @startDscConfigurationParametersCreateVDPortGroup
            Start-DscConfiguration @startDscConfigurationParametersRemoveVDPortGroup
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileRemoveVDPortGroupPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configRemoveVDPortGroup }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.Name | Should -Be $script:configurationData.AllNodes.VDPortGroupName
            $configuration.VdsName | Should -Be $script:configurationData.AllNodes.VDSwitchName
            $configuration.Ensure | Should -Be 'Absent'
            $configuration.Notes | Should -BeNullOrEmpty
            $configuration.NumPorts | Should -BeNullOrEmpty
            $configuration.PortBinding | Should -Be 'Unset'
            $configuration.ReferenceVDPortGroupName | Should -BeNullOrEmpty
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileRemoveVDPortGroupPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configRemoveDatacenterVDSwitchAndVDPortGroup `
                -OutputPath $script:mofFileRemoveDatacenterVDSwitchAndVDPortGroupPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileRemoveDatacenterVDSwitchAndVDPortGroupPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileCreateDatacenterAndVDSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileCreateVDPortGroupPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVDPortGroupPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveDatacenterVDSwitchAndVDPortGroupPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }
}
