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

    [Parameter()]
    [string]
    $Name
)

# The 'Name' parameter is not used in the Integration Tests, so it is set to $null.
$Name = $null

$script:Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (ConvertTo-SecureString -String $Password -AsPlainText -Force)
$script:DscResourceName = 'DatastoreCluster'
$script:ConfigurationsPath = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DscResourceName)_Config.ps1"

$script:ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
            Server = $Server
            Credential = $script:Credential
            DatacenterDscResourceName = 'Datacenter'
            DatastoreClusterDscResourceName = 'DatastoreCluster'
            DatacenterName = 'DscDatacenter'
            DatacenterLocation = [string]::Empty
            DatastoreClusterName = 'DscDatastoreCluster'
            DatastoreClusterLocation = [string]::Empty
            IOLoadBalanceEnabled = $true
            DefaultIOLoadBalanceEnabled = $false
            SdrsAutomationLevel = 'FullyAutomated'
            DefaultSdrsAutomationLevel = 'Disabled'
            IOLatencyThresholdMillisecond = 50
            SpaceUtilizationThresholdPercent = 50
        }
    )
}

. $script:ConfigurationsPath -Verbose:$true -ErrorAction Stop

$script:CreateDatacenterConfigurationName = "$($script:DscResourceName)_CreateDatacenterInTheRootFolderOfTheInventory_Config"
$script:CreateDatastoreClusterConfigurationName = "$($script:DscResourceName)_CreateDatastoreClusterWithoutModifyingTheDatastoreClusterConfiguration_Config"
$script:CreateAndModifyDatastoreClusterConfigurationName = "$($script:DscResourceName)_CreateDatastoreClusterAndModifyTheDatastoreClusterConfiguration_Config"
$script:RemoveDatastoreClusterConfigurationName = "$($script:DscResourceName)_RemoveDatastoreCluster_Config"
$script:RemoveDatacenterConfigurationName = "$($script:DscResourceName)_RemoveDatacenter_Config"

$script:CreateDatacenterMofFilePath = Join-Path -Path $PSScriptRoot -ChildPath $script:CreateDatacenterConfigurationName
$script:CreateDatastoreClusterMofFilePath = Join-Path -Path $PSScriptRoot -ChildPath $script:CreateDatastoreClusterConfigurationName
$script:CreateAndModifyDatastoreClusterMofFilePath = Join-Path -Path $PSScriptRoot -ChildPath $script:CreateAndModifyDatastoreClusterConfigurationName
$script:RemoveDatastoreClusterMofFilePath = Join-Path -Path $PSScriptRoot -ChildPath $script:RemoveDatastoreClusterConfigurationName
$script:RemoveDatacenterMofFilePath = Join-Path -Path $PSScriptRoot -ChildPath $script:RemoveDatacenterConfigurationName

Describe "$($script:DscResourceName)_Integration" {
    Context 'When creating Datastore Cluster without modifying the Datastore Cluster configuration' {
        BeforeAll {
            # Arrange
            & $script:CreateDatacenterConfigurationName `
                -OutputPath $script:CreateDatacenterMofFilePath `
                -ConfigurationData $script:ConfigurationData `
                -ErrorAction Stop

            $startDscConfigurationParamsCreateDatacenter = @{
                Path = $script:CreateDatacenterMofFilePath
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParamsCreateDatacenter } | Should -Not -Throw

            It 'Should compile and apply the MOF without throwing' {
                # Arrange
                & $script:CreateDatastoreClusterConfigurationName `
                    -OutputPath $script:CreateDatastoreClusterMofFilePath `
                    -ConfigurationData $script:ConfigurationData `
                    -ErrorAction Stop

                $startDscConfigurationParamsCreateDatastoreCluster = @{
                    Path = $script:CreateDatastoreClusterMofFilePath
                    ComputerName = $script:ConfigurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act && Assert
                { Start-DscConfiguration @startDscConfigurationParamsCreateDatastoreCluster } | Should -Not -Throw
            }
        }

        It 'Should be able to call Test-DscConfiguration without throwing' {
            # Arrange
            $testDscConfigurationParams = @{
                ReferenceConfiguration = Join-Path -Path $script:CreateDatastoreClusterMofFilePath -ChildPath "$($script:ConfigurationData.AllNodes.NodeName).mof"
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Test-DscConfiguration @testDscConfigurationParams } | Should -Not -Throw
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParams = @{
                ReferenceConfiguration = Join-Path -Path $script:CreateDatastoreClusterMofFilePath -ChildPath "$($script:ConfigurationData.AllNodes.NodeName).mof"
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParams).InDesiredState | Should -BeTrue
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            # Arrange && Act && Assert
            { Get-DscConfiguration -Verbose:$true -ErrorAction Stop } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration and all parameters should match' {
            # Arrange
            $whereObjectParams = @{
                FilterScript = {
                    $_.ConfigurationName -eq $script:CreateDatastoreClusterConfigurationName
                }
            }

            # Act
            $datastoreClusterDscResource = Get-DscConfiguration -Verbose:$true -ErrorAction Stop | Where-Object @whereObjectParams

            # Assert
            $datastoreClusterDscResource.Server | Should -Be $script:ConfigurationData.AllNodes.Server
            $datastoreClusterDscResource.Name | Should -Be $script:ConfigurationData.AllNodes.DatastoreClusterName
            $datastoreClusterDscResource.Location | Should -Be $script:ConfigurationData.AllNodes.DatastoreClusterLocation
            $datastoreClusterDscResource.DatacenterName | Should -Be $script:ConfigurationData.AllNodes.DatacenterName
            $datastoreClusterDscResource.DatacenterLocation | Should -Be $script:ConfigurationData.AllNodes.DatacenterLocation
            $datastoreClusterDscResource.Ensure | Should -Be 'Present'
            $datastoreClusterDscResource.IOLatencyThresholdMillisecond | Should -BeNull
            $datastoreClusterDscResource.IOLoadBalanceEnabled | Should -Be $script:ConfigurationData.AllNodes.DefaultIOLoadBalanceEnabled
            $datastoreClusterDscResource.SdrsAutomationLevel | Should -Be $script:ConfigurationData.AllNodes.DefaultSdrsAutomationLevel
            $datastoreClusterDscResource.SpaceUtilizationThresholdPercent | Should -BeNull
        }

        AfterAll {
            # Arrange
            & $script:RemoveDatastoreClusterConfigurationName `
                -OutputPath $script:RemoveDatastoreClusterMofFilePath `
                -ConfigurationData $script:ConfigurationData `
                -ErrorAction Stop

            & $script:RemoveDatacenterConfigurationName `
                -OutputPath $script:RemoveDatacenterMofFilePath `
                -ConfigurationData $script:ConfigurationData `
                -ErrorAction Stop

            $startDscConfigurationParamsRemoveDatastoreCluster = @{
                Path = $script:RemoveDatastoreClusterMofFilePath
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParamsRemoveDatacenter = @{
                Path = $script:RemoveDatacenterMofFilePath
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParamsRemoveDatastoreCluster } | Should -Not -Throw
            { Start-DscConfiguration @startDscConfigurationParamsRemoveDatacenter } | Should -Not -Throw

            Remove-Item -Path $script:CreateDatacenterMofFilePath -Recurse -Confirm:$false -Verbose:$true -ErrorAction Stop
            Remove-Item -Path $script:CreateDatastoreClusterMofFilePath -Recurse -Confirm:$false -Verbose:$true -ErrorAction Stop
            Remove-Item -Path $script:RemoveDatastoreClusterMofFilePath -Recurse -Confirm:$false -Verbose:$true -ErrorAction Stop
            Remove-Item -Path $script:RemoveDatacenterMofFilePath -Recurse -Confirm:$false -Verbose:$true -ErrorAction Stop
        }
    }

    Context 'When creating Datastore Cluster and modifying the Datastore Cluster configuration' {
        BeforeAll {
            # Arrange
            & $script:CreateDatacenterConfigurationName `
                -OutputPath $script:CreateDatacenterMofFilePath `
                -ConfigurationData $script:ConfigurationData `
                -ErrorAction Stop

            $startDscConfigurationParamsCreateDatacenter = @{
                Path = $script:CreateDatacenterMofFilePath
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParamsCreateDatacenter } | Should -Not -Throw

            It 'Should compile and apply the MOF without throwing' {
                # Arrange
                & $script:CreateAndModifyDatastoreClusterConfigurationName `
                    -OutputPath $script:CreateAndModifyDatastoreClusterMofFilePath `
                    -ConfigurationData $script:ConfigurationData `
                    -ErrorAction Stop

                $startDscConfigurationParamsCreateAndModifyDatastoreCluster = @{
                    Path = $script:CreateAndModifyDatastoreClusterMofFilePath
                    ComputerName = $script:ConfigurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act && Assert
                { Start-DscConfiguration @startDscConfigurationParamsCreateAndModifyDatastoreCluster } | Should -Not -Throw
            }
        }

        It 'Should be able to call Test-DscConfiguration without throwing' {
            # Arrange
            $testDscConfigurationParams = @{
                ReferenceConfiguration = Join-Path -Path $script:CreateAndModifyDatastoreClusterMofFilePath -ChildPath "$($script:ConfigurationData.AllNodes.NodeName).mof"
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Test-DscConfiguration @testDscConfigurationParams } | Should -Not -Throw
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParams = @{
                ReferenceConfiguration = Join-Path -Path $script:CreateAndModifyDatastoreClusterMofFilePath -ChildPath "$($script:ConfigurationData.AllNodes.NodeName).mof"
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParams).InDesiredState | Should -BeTrue
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            # Arrange && Act && Assert
            { Get-DscConfiguration -Verbose:$true -ErrorAction Stop } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration and all parameters should match' {
            # Arrange
            $whereObjectParams = @{
                FilterScript = {
                    $_.ConfigurationName -eq $script:CreateAndModifyDatastoreClusterConfigurationName
                }
            }

            # Act
            $datastoreClusterDscResource = Get-DscConfiguration -Verbose:$true -ErrorAction Stop | Where-Object @whereObjectParams

            # Assert
            $datastoreClusterDscResource.Server | Should -Be $script:ConfigurationData.AllNodes.Server
            $datastoreClusterDscResource.Name | Should -Be $script:ConfigurationData.AllNodes.DatastoreClusterName
            $datastoreClusterDscResource.Location | Should -Be $script:ConfigurationData.AllNodes.DatastoreClusterLocation
            $datastoreClusterDscResource.DatacenterName | Should -Be $script:ConfigurationData.AllNodes.DatacenterName
            $datastoreClusterDscResource.DatacenterLocation | Should -Be $script:ConfigurationData.AllNodes.DatacenterLocation
            $datastoreClusterDscResource.Ensure | Should -Be 'Present'
            $datastoreClusterDscResource.IOLatencyThresholdMillisecond | Should -Be $script:ConfigurationData.AllNodes.IOLatencyThresholdMillisecond
            $datastoreClusterDscResource.IOLoadBalanceEnabled | Should -Be $script:ConfigurationData.AllNodes.IOLoadBalanceEnabled
            $datastoreClusterDscResource.SdrsAutomationLevel | Should -Be $script:ConfigurationData.AllNodes.SdrsAutomationLevel
            $datastoreClusterDscResource.SpaceUtilizationThresholdPercent | Should -Be $script:ConfigurationData.AllNodes.SpaceUtilizationThresholdPercent
        }

        AfterAll {
            # Arrange
            & $script:RemoveDatastoreClusterConfigurationName `
                -OutputPath $script:RemoveDatastoreClusterMofFilePath `
                -ConfigurationData $script:ConfigurationData `
                -ErrorAction Stop

            & $script:RemoveDatacenterConfigurationName `
                -OutputPath $script:RemoveDatacenterMofFilePath `
                -ConfigurationData $script:ConfigurationData `
                -ErrorAction Stop

            $startDscConfigurationParamsRemoveDatastoreCluster = @{
                Path = $script:RemoveDatastoreClusterMofFilePath
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParamsRemoveDatacenter = @{
                Path = $script:RemoveDatacenterMofFilePath
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParamsRemoveDatastoreCluster } | Should -Not -Throw
            { Start-DscConfiguration @startDscConfigurationParamsRemoveDatacenter } | Should -Not -Throw

            Remove-Item -Path $script:CreateDatacenterMofFilePath -Recurse -Confirm:$false -Verbose:$true -ErrorAction Stop
            Remove-Item -Path $script:CreateAndModifyDatastoreClusterMofFilePath -Recurse -Confirm:$false -Verbose:$true -ErrorAction Stop
            Remove-Item -Path $script:RemoveDatastoreClusterMofFilePath -Recurse -Confirm:$false -Verbose:$true -ErrorAction Stop
            Remove-Item -Path $script:RemoveDatacenterMofFilePath -Recurse -Confirm:$false -Verbose:$true -ErrorAction Stop
        }
    }

    Context 'When removing Datastore Cluster' {
        BeforeAll {
            # Arrange
            & $script:CreateDatacenterConfigurationName `
                -OutputPath $script:CreateDatacenterMofFilePath `
                -ConfigurationData $script:ConfigurationData `
                -ErrorAction Stop

            & $script:CreateAndModifyDatastoreClusterConfigurationName `
                -OutputPath $script:CreateAndModifyDatastoreClusterMofFilePath `
                -ConfigurationData $script:ConfigurationData `
                -ErrorAction Stop

            $startDscConfigurationParamsCreateDatacenter = @{
                Path = $script:CreateDatacenterMofFilePath
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParamsCreateAndModifyDatastoreCluster = @{
                Path = $script:CreateAndModifyDatastoreClusterMofFilePath
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParamsCreateDatacenter } | Should -Not -Throw
            { Start-DscConfiguration @startDscConfigurationParamsCreateAndModifyDatastoreCluster } | Should -Not -Throw

            It 'Should compile and apply the MOF without throwing' {
                # Arrange
                & $script:RemoveDatastoreClusterConfigurationName `
                    -OutputPath $script:RemoveDatastoreClusterMofFilePath `
                    -ConfigurationData $script:ConfigurationData `
                    -ErrorAction Stop

                $startDscConfigurationParamsRemoveDatastoreCluster = @{
                    Path = $script:RemoveDatastoreClusterMofFilePath
                    ComputerName = $script:ConfigurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act && Assert
                { Start-DscConfiguration @startDscConfigurationParamsRemoveDatastoreCluster } | Should -Not -Throw
            }
        }

        It 'Should be able to call Test-DscConfiguration without throwing' {
            # Arrange
            $testDscConfigurationParams = @{
                ReferenceConfiguration = Join-Path -Path $script:RemoveDatastoreClusterMofFilePath -ChildPath "$($script:ConfigurationData.AllNodes.NodeName).mof"
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Test-DscConfiguration @testDscConfigurationParams } | Should -Not -Throw
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParams = @{
                ReferenceConfiguration = Join-Path -Path $script:RemoveDatastoreClusterMofFilePath -ChildPath "$($script:ConfigurationData.AllNodes.NodeName).mof"
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParams).InDesiredState | Should -BeTrue
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            # Arrange && Act && Assert
            { Get-DscConfiguration -Verbose:$true -ErrorAction Stop } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration and all parameters should match' {
            # Arrange
            $whereObjectParams = @{
                FilterScript = {
                    $_.ConfigurationName -eq $script:RemoveDatastoreClusterConfigurationName
                }
            }

            # Act
            $datastoreClusterDscResource = Get-DscConfiguration -Verbose:$true -ErrorAction Stop | Where-Object @whereObjectParams

            # Assert
            $datastoreClusterDscResource.Server | Should -Be $script:ConfigurationData.AllNodes.Server
            $datastoreClusterDscResource.Name | Should -Be $script:ConfigurationData.AllNodes.DatastoreClusterName
            $datastoreClusterDscResource.Location | Should -Be $script:ConfigurationData.AllNodes.DatastoreClusterLocation
            $datastoreClusterDscResource.DatacenterName | Should -Be $script:ConfigurationData.AllNodes.DatacenterName
            $datastoreClusterDscResource.DatacenterLocation | Should -Be $script:ConfigurationData.AllNodes.DatacenterLocation
            $datastoreClusterDscResource.Ensure | Should -Be 'Absent'
            $datastoreClusterDscResource.IOLatencyThresholdMillisecond | Should -BeNull
            $datastoreClusterDscResource.IOLoadBalanceEnabled | Should -BeNull
            $datastoreClusterDscResource.SdrsAutomationLevel | Should -Be 'Unset'
            $datastoreClusterDscResource.SpaceUtilizationThresholdPercent | Should -BeNull
        }

        AfterAll {
            # Arrange
            & $script:RemoveDatacenterConfigurationName `
                -OutputPath $script:RemoveDatacenterMofFilePath `
                -ConfigurationData $script:ConfigurationData `
                -ErrorAction Stop

            $startDscConfigurationParamsRemoveDatacenter = @{
                Path = $script:RemoveDatacenterMofFilePath
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParamsRemoveDatacenter } | Should -Not -Throw

            Remove-Item -Path $script:CreateDatacenterMofFilePath -Recurse -Confirm:$false -Verbose:$true -ErrorAction Stop
            Remove-Item -Path $script:CreateAndModifyDatastoreClusterMofFilePath -Recurse -Confirm:$false -Verbose:$true -ErrorAction Stop
            Remove-Item -Path $script:RemoveDatastoreClusterMofFilePath -Recurse -Confirm:$false -Verbose:$true -ErrorAction Stop
            Remove-Item -Path $script:RemoveDatacenterMofFilePath -Recurse -Confirm:$false -Verbose:$true -ErrorAction Stop
        }
    }
}
