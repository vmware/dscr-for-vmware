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

$script:dscResourceName = 'VDSwitch'
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
            DistributedSwitchResourceName = 'DistributedSwitch'
            DistributedSwitchResourceId = '[VDSwitch]DistributedSwitch'
            ReferenceVDSwitchResourceName = 'DistributedSwitch_Via_ReferenceVDSwitch'
            ReferenceVDSwitchResourceId = '[VDSwitch]DistributedSwitch_Via_ReferenceVDSwitch'
            DatacenterName = 'MyTestDatacenter'
            DatacenterLocation = [string]::Empty
            DistributedSwitchName = 'MyTestDistributedSwitch'
            ReferenceVDSwitchName = 'MyTestDistributedSwitchViaReferenceVDSwitch'
            Location = [string]::Empty
            ContactDetails = 'MyTestContactDetails'
            ContactName = 'MyTestContactName'
            UpdatedContactName = 'Updated MyTestContactName'
            LinkDiscoveryProtocol = 'CDP'
            LinkDiscoveryProtocolOperationAdvertise = 'Advertise'
            LinkDiscoveryProtocolOperationListen = 'Listen'
            MaxPorts = 100
            Mtu = 2000
            UpdatedMtu = 2200
            Notes = 'MyTestNotesDescription'
            NumUplinkPorts = 10
            Version = '6.6.0'
            WithoutPortGroups = $true
        }
    )
}

$script:configWhenAddingDistributedSwitch = "$($script:dscResourceName)_WhenAddingDistributedSwitch_Config"
$script:configWhenAddingDistributedSwitchViaReferenceVDSwitch = "$($script:dscResourceName)_WhenAddingDistributedSwitchViaReferenceVDSwitch_Config"
$script:configWhenUpdatingDistributedSwitch = "$($script:dscResourceName)_WhenUpdatingDistributedSwitch_Config"
$script:configWhenRemovingDistributedSwitch = "$($script:dscResourceName)_WhenRemovingDistributedSwitch_Config"
$script:configWhenRemovingDistributedSwitchesAndDatacenter = "$($script:dscResourceName)_WhenRemovingDistributedSwitchesAndDatacenter_Config"

. $script:configurationFile -ErrorAction Stop

$script:mofFileWhenAddingDistributedSwitchPath = "$script:integrationTestsFolderPath\$script:configWhenAddingDistributedSwitch\"
$script:mofFileWhenAddingDistributedSwitchViaReferenceVDSwitchPath = "$script:integrationTestsFolderPath\$script:configWhenAddingDistributedSwitchViaReferenceVDSwitch\"
$script:mofFileWhenUpdatingDistributedSwitchPath = "$script:integrationTestsFolderPath\$script:configWhenUpdatingDistributedSwitch\"
$script:mofFileWhenRemovingDistributedSwitchPath = "$script:integrationTestsFolderPath\$script:configWhenRemovingDistributedSwitch\"
$script:mofFileWhenRemovingDistributedSwitchesAndDatacenterPath = "$script:integrationTestsFolderPath\$script:configWhenRemovingDistributedSwitchesAndDatacenter\"

Describe "$($script:dscResourceName)_Integration" {
    Context "When using configuration $script:configWhenAddingDistributedSwitch" {
        BeforeAll {
            # Arrange
            & $script:configWhenAddingDistributedSwitch `
                -OutputPath $script:mofFileWhenAddingDistributedSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenAddingDistributedSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenAddingDistributedSwitchPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configWhenAddingDistributedSwitch }

            $datacenterResource = $configuration | Where-Object { $_.ResourceId -eq $script:configurationData.AllNodes.DatacenterResourceId }
            $distributedSwitchResource = $configuration | Where-Object { $_.ResourceId -eq $script:configurationData.AllNodes.DistributedSwitchResourceId }

            # Assert
            $datacenterResource.Server | Should -Be $script:configurationData.AllNodes.Server
            $datacenterResource.Name | Should -Be $script:configurationData.AllNodes.DatacenterName
            $datacenterResource.Location | Should -Be $script:configurationData.AllNodes.DatacenterLocation
            $datacenterResource.Ensure | Should -Be 'Present'

            $distributedSwitchResource.Server | Should -Be $script:configurationData.AllNodes.Server
            $distributedSwitchResource.Name | Should -Be $script:configurationData.AllNodes.DistributedSwitchName
            $distributedSwitchResource.Location | Should -Be $script:configurationData.AllNodes.Location
            $distributedSwitchResource.DatacenterName | Should -Be $script:configurationData.AllNodes.DatacenterName
            $distributedSwitchResource.DatacenterLocation | Should -Be $script:configurationData.AllNodes.DatacenterLocation
            $distributedSwitchResource.Ensure | Should -Be 'Present'
            $distributedSwitchResource.ContactDetails | Should -Be $script:configurationData.AllNodes.ContactDetails
            $distributedSwitchResource.ContactName | Should -Be $script:configurationData.AllNodes.ContactName
            $distributedSwitchResource.LinkDiscoveryProtocol | Should -Be $script:configurationData.AllNodes.LinkDiscoveryProtocol
            $distributedSwitchResource.LinkDiscoveryProtocolOperation | Should -Be $script:configurationData.AllNodes.LinkDiscoveryProtocolOperationAdvertise
            $distributedSwitchResource.MaxPorts | Should -Be $script:configurationData.AllNodes.MaxPorts
            $distributedSwitchResource.Mtu | Should -Be $script:configurationData.AllNodes.Mtu
            $distributedSwitchResource.Notes | Should -Be $script:configurationData.AllNodes.Notes
            $distributedSwitchResource.NumUplinkPorts | Should -Be $script:configurationData.AllNodes.NumUplinkPorts
            $distributedSwitchResource.Version | Should -Be $script:configurationData.AllNodes.Version
            $distributedSwitchResource.ReferenceVDSwitchName | Should -BeNullOrEmpty
            $distributedSwitchResource.WithoutPortGroups | Should -BeNullOrEmpty
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileWhenAddingDistributedSwitchPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        It "Should have the following dependency: Resource $($script:configurationData.AllNodes.DistributedSwitchResourceName) should depend on Resource $($script:configurationData.AllNodes.DatacenterResourceName)" {
            # Arrange && Act
            $distributedSwitchResource = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript {
                $_.ConfigurationName -eq $script:configWhenAddingDistributedSwitch -and `
                $_.ResourceId -eq $script:configurationData.AllNodes.DistributedSwitchResourceId
            }

            # Assert
            $distributedSwitchResource.DependsOn | Should -Be $script:configurationData.AllNodes.DatacenterResourceId
        }

        AfterAll {
            # Arrange
            & $script:configWhenRemovingDistributedSwitchesAndDatacenter `
                -OutputPath $script:mofFileWhenRemovingDistributedSwitchesAndDatacenterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingDistributedSwitchesAndDatacenterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileWhenAddingDistributedSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileWhenRemovingDistributedSwitchesAndDatacenterPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configWhenAddingDistributedSwitchViaReferenceVDSwitch" {
        BeforeAll {
            # Arrange
            & $script:configWhenAddingDistributedSwitch `
                -OutputPath $script:mofFileWhenAddingDistributedSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configWhenAddingDistributedSwitchViaReferenceVDSwitch `
                -OutputPath $script:mofFileWhenAddingDistributedSwitchViaReferenceVDSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersWhenAddingDistributedSwitch = @{
                Path = $script:mofFileWhenAddingDistributedSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersWhenAddingDistributedSwitchViaReferenceVDSwitch = @{
                Path = $script:mofFileWhenAddingDistributedSwitchViaReferenceVDSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersWhenAddingDistributedSwitch
            Start-DscConfiguration @startDscConfigurationParametersWhenAddingDistributedSwitchViaReferenceVDSwitch
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenAddingDistributedSwitchViaReferenceVDSwitchPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configWhenAddingDistributedSwitchViaReferenceVDSwitch }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.Name | Should -Be $script:configurationData.AllNodes.ReferenceVDSwitchName
            $configuration.Location | Should -Be $script:configurationData.AllNodes.Location
            $configuration.DatacenterName | Should -Be $script:configurationData.AllNodes.DatacenterName
            $configuration.DatacenterLocation | Should -Be $script:configurationData.AllNodes.DatacenterLocation
            $configuration.Ensure | Should -Be 'Present'
            $configuration.ContactDetails | Should -Be $script:configurationData.AllNodes.ContactDetails
            $configuration.ContactName | Should -Be $script:configurationData.AllNodes.ContactName
            $configuration.LinkDiscoveryProtocol | Should -Be $script:configurationData.AllNodes.LinkDiscoveryProtocol
            $configuration.LinkDiscoveryProtocolOperation | Should -Be $script:configurationData.AllNodes.LinkDiscoveryProtocolOperationAdvertise
            $configuration.MaxPorts | Should -Be $script:configurationData.AllNodes.MaxPorts
            $configuration.Mtu | Should -Be $script:configurationData.AllNodes.Mtu
            $configuration.Notes | Should -Be $script:configurationData.AllNodes.Notes
            $configuration.NumUplinkPorts | Should -Be $script:configurationData.AllNodes.NumUplinkPorts
            $configuration.Version | Should -Be $script:configurationData.AllNodes.Version
            $configuration.ReferenceVDSwitchName | Should -Be $script:configurationData.AllNodes.DistributedSwitchName
            $configuration.WithoutPortGroups | Should -Be $script:configurationData.AllNodes.WithoutPortGroups
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileWhenAddingDistributedSwitchViaReferenceVDSwitchPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configWhenRemovingDistributedSwitchesAndDatacenter `
                -OutputPath $script:mofFileWhenRemovingDistributedSwitchesAndDatacenterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingDistributedSwitchesAndDatacenterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileWhenAddingDistributedSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileWhenAddingDistributedSwitchViaReferenceVDSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileWhenRemovingDistributedSwitchesAndDatacenterPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configWhenUpdatingDistributedSwitch" {
        BeforeAll {
            # Arrange
            & $script:configWhenAddingDistributedSwitch `
                -OutputPath $script:mofFileWhenAddingDistributedSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configWhenUpdatingDistributedSwitch `
                -OutputPath $script:mofFileWhenUpdatingDistributedSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersWhenAddingDistributedSwitch = @{
                Path = $script:mofFileWhenAddingDistributedSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersWhenUpdatingDistributedSwitch = @{
                Path = $script:mofFileWhenUpdatingDistributedSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersWhenAddingDistributedSwitch
            Start-DscConfiguration @startDscConfigurationParametersWhenUpdatingDistributedSwitch
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenUpdatingDistributedSwitchPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configWhenUpdatingDistributedSwitch }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.Name | Should -Be $script:configurationData.AllNodes.DistributedSwitchName
            $configuration.Location | Should -Be $script:configurationData.AllNodes.Location
            $configuration.DatacenterName | Should -Be $script:configurationData.AllNodes.DatacenterName
            $configuration.DatacenterLocation | Should -Be $script:configurationData.AllNodes.DatacenterLocation
            $configuration.Ensure | Should -Be 'Present'
            $configuration.ContactDetails | Should -Be $script:configurationData.AllNodes.ContactDetails
            $configuration.ContactName | Should -Be $script:configurationData.AllNodes.UpdatedContactName
            $configuration.LinkDiscoveryProtocol | Should -Be $script:configurationData.AllNodes.LinkDiscoveryProtocol
            $configuration.LinkDiscoveryProtocolOperation | Should -Be $script:configurationData.AllNodes.LinkDiscoveryProtocolOperationListen
            $configuration.MaxPorts | Should -Be $script:configurationData.AllNodes.MaxPorts
            $configuration.Mtu | Should -Be $script:configurationData.AllNodes.UpdatedMtu
            $configuration.Notes | Should -Be $script:configurationData.AllNodes.Notes
            $configuration.NumUplinkPorts | Should -Be $script:configurationData.AllNodes.NumUplinkPorts
            $configuration.Version | Should -Be $script:configurationData.AllNodes.Version
            $configuration.ReferenceVDSwitchName | Should -BeNullOrEmpty
            $configuration.WithoutPortGroups | Should -BeNullOrEmpty
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileWhenUpdatingDistributedSwitchPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configWhenRemovingDistributedSwitchesAndDatacenter `
                -OutputPath $script:mofFileWhenRemovingDistributedSwitchesAndDatacenterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingDistributedSwitchesAndDatacenterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileWhenAddingDistributedSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileWhenUpdatingDistributedSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileWhenRemovingDistributedSwitchesAndDatacenterPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configWhenRemovingDistributedSwitch" {
        BeforeAll {
            # Arrange
            & $script:configWhenAddingDistributedSwitch `
                -OutputPath $script:mofFileWhenAddingDistributedSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configWhenRemovingDistributedSwitch `
                -OutputPath $script:mofFileWhenRemovingDistributedSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersWhenAddingDistributedSwitch = @{
                Path = $script:mofFileWhenAddingDistributedSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersWhenRemovingDistributedSwitch = @{
                Path = $script:mofFileWhenRemovingDistributedSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersWhenAddingDistributedSwitch
            Start-DscConfiguration @startDscConfigurationParametersWhenRemovingDistributedSwitch
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingDistributedSwitchPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configWhenRemovingDistributedSwitch }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.Name | Should -Be $script:configurationData.AllNodes.DistributedSwitchName
            $configuration.Location | Should -Be $script:configurationData.AllNodes.Location
            $configuration.DatacenterName | Should -Be $script:configurationData.AllNodes.DatacenterName
            $configuration.DatacenterLocation | Should -Be $script:configurationData.AllNodes.DatacenterLocation
            $configuration.Ensure | Should -Be 'Absent'
            $configuration.ContactDetails | Should -BeNullOrEmpty
            $configuration.ContactName | Should -BeNullOrEmpty
            $configuration.LinkDiscoveryProtocol | Should -Be 'Unset'
            $configuration.LinkDiscoveryProtocolOperation | Should -Be 'Unset'
            $configuration.MaxPorts | Should -BeNullOrEmpty
            $configuration.Mtu | Should -BeNullOrEmpty
            $configuration.Notes | Should -BeNullOrEmpty
            $configuration.NumUplinkPorts | Should -BeNullOrEmpty
            $configuration.Version | Should -BeNullOrEmpty
            $configuration.ReferenceVDSwitchName | Should -BeNullOrEmpty
            $configuration.WithoutPortGroups | Should -BeNullOrEmpty
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileWhenRemovingDistributedSwitchPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configWhenRemovingDistributedSwitchesAndDatacenter `
                -OutputPath $script:mofFileWhenRemovingDistributedSwitchesAndDatacenterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileWhenRemovingDistributedSwitchesAndDatacenterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileWhenAddingDistributedSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileWhenRemovingDistributedSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileWhenRemovingDistributedSwitchesAndDatacenterPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }
}
