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

$script:dscResourceName = 'DrsCluster'
$script:moduleFolderPath = (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase
$script:integrationTestsFolderPath = Join-Path (Join-Path $moduleFolderPath 'Tests') 'Integration'
$script:configurationFile = "$script:integrationTestsFolderPath\Configurations\$($script:dscResourceName)\$($script:dscResourceName)_Config.ps1"

$script:configWithClusterToAdd = "$($script:dscResourceName)_WithClusterToAdd_Config"
$script:configWithClusterToAddInCustomFolder = "$($script:dscResourceName)_WithClusterToAddInCustomFolder_Config"
$script:configWithClusterToUpdate = "$($script:dscResourceName)_WithClusterToUpdate_Config"
$script:configWithClusterToUpdateInCustomFolder = "$($script:dscResourceName)_WithClusterToUpdateInCustomFolder_Config"
$script:configWithClusterToRemove = "$($script:dscResourceName)_WithClusterToRemove_Config"
$script:configWithClusterToRemoveInCustomFolder = "$($script:dscResourceName)_WithClusterToRemoveInCustomFolder_Config"

$script:vCenter = Connect-VIServer -Server $Server -User $User -Password $Password
$script:datacenter = Get-Datacenter -Server $script:vCenter -Name 'Datacenter'
$script:clusterLocation = Get-Inventory -Server $script:vCenter -Name 'host' -Location $script:datacenter | Where-Object { $_.ParentId -eq $script:datacenter.Id }

$script:clusterName = 'MyCluster'
$script:inventoryPath = [string]::Empty
$script:inventoryPathWithCustomFolder = 'MyClusterFolder'
$script:datacenter = 'Datacenter'

$script:resourceWithClusterToAdd = @{
    Ensure = 'Present'
    DrsEnabled = $true
    DrsAutomationLevel = 'FullyAutomated'
    DrsMigrationThreshold = 5
    DrsDistribution = 0
    MemoryLoadBalancing = 100
    CPUOverCommitment = 500
}

$script:resourceWithClusterToAddInCustomFolder = @{
    Ensure = 'Present'
    DrsEnabled = $true
    DrsAutomationLevel = 'PartiallyAutomated'
    DrsMigrationThreshold = 3
    DrsDistribution = 1
    MemoryLoadBalancing = 200
    CPUOverCommitment = 400
}

$script:resourceWithClusterToUpdate = @{
    DrsAutomationLevel = 'Manual'
    DrsMigrationThreshold = 1
}

$script:resourceWithClusterToUpdateInCustomFolder = @{
    DrsDistribution = 2
    MemoryLoadBalancing = 50
    CPUOverCommitment = 300
}

$script:resourceWithClusterToRemove = @{
    Ensure = 'Absent'
}

. $script:configurationFile -Server $Server -User $User -Password $Password

$script:mofFileWithClusterToAddPath = "$script:integrationTestsFolderPath\$($script:configWithClusterToAdd)\"
$script:mofFileWithClusterToAddInCustomFolderPath = "$script:integrationTestsFolderPath\$($script:configWithClusterToAddInCustomFolder)\"
$script:mofFileWithClusterToUpdatePath = "$script:integrationTestsFolderPath\$($script:configWithClusterToUpdate)\"
$script:mofFileWithClusterToUpdateInCustomFolderPath = "$script:integrationTestsFolderPath\$($script:configWithClusterToUpdateInCustomFolder)\"
$script:mofFileWithClusterToRemovePath = "$script:integrationTestsFolderPath\$($script:configWithClusterToRemove)"
$script:mofFileWithClusterToRemoveInCustomFolderPath = "$script:integrationTestsFolderPath\$($script:configWithClusterToRemoveInCustomFolder)"

function New-CustomFolder {
    return New-Folder -Server $script:vCenter -Name $script:inventoryPathWithCustomFolder -Location $script:clusterLocation
}

function Invoke-TestSetup {
    # Cluster Location is the Host folder of the Datacenter.
    $clusterSpec = New-Object VMware.Vim.ClusterConfigSpecEx
    $clusterSpec.DrsConfig = New-Object VMware.Vim.ClusterDrsConfigInfo

    $clusterSpec.DrsConfig.Enabled = $script:resourceWithClusterToAdd.DrsEnabled
    $clusterSpec.DrsConfig.DefaultVmBehavior = $script:resourceWithClusterToAdd.DrsAutomationLevel
    $clusterSpec.DrsConfig.VmotionRate = $script:resourceWithClusterToAdd.DrsMigrationThreshold
    $clusterSpec.DrsConfig.Option = @(
        [VMware.Vim.OptionValue] @{
            Key = 'LimitVMsPerESXHostPercent'
            Value = $script:resourceWithClusterToAdd.DrsDistribution.ToString()
        },
        [VMware.Vim.OptionValue] @{
            Key = 'PercentIdleMBInMemDemand'
            Value = $script:resourceWithClusterToAdd.MemoryLoadBalancing.ToString()
        },
        [VMware.Vim.OptionValue] @{
            Key = 'MaxVcpusPerClusterPct'
            Value = $script:resourceWithClusterToAdd.CPUOverCommitment.ToString()
        }
    )

    $script:clusterLocation.ExtensionData.CreateClusterEx($script:clusterName, $clusterSpec)

    # Cluster Location is a Folder inside the Host Folder of the Datacenter.
    $clusterSpec = New-Object VMware.Vim.ClusterConfigSpecEx
    $clusterSpec.DrsConfig = New-Object VMware.Vim.ClusterDrsConfigInfo

    $clusterSpec.DrsConfig.Enabled = $script:resourceWithClusterToAddInCustomFolder.DrsEnabled
    $clusterSpec.DrsConfig.DefaultVmBehavior = $script:resourceWithClusterToAddInCustomFolder.DrsAutomationLevel
    $clusterSpec.DrsConfig.VmotionRate = $script:resourceWithClusterToAddInCustomFolder.DrsMigrationThreshold
    $clusterSpec.DrsConfig.Option = @(
        [VMware.Vim.OptionValue] @{
            Key = 'LimitVMsPerESXHostPercent'
            Value = $script:resourceWithClusterToAddInCustomFolder.DrsDistribution.ToString()
        },
        [VMware.Vim.OptionValue] @{
            Key = 'PercentIdleMBInMemDemand'
            Value = $script:resourceWithClusterToAddInCustomFolder.MemoryLoadBalancing.ToString()
        },
        [VMware.Vim.OptionValue] @{
            Key = 'MaxVcpusPerClusterPct'
            Value = $script:resourceWithClusterToAddInCustomFolder.CPUOverCommitment.ToString()
        }
    )

    $customFolderAsLocation = New-CustomFolder
    $customFolderAsLocation.ExtensionData.CreateClusterEx($script:clusterName, $clusterSpec)
}

function Invoke-TestCleanup {
    Get-Cluster -Server $script:vCenter -Name $script:clusterName -ErrorAction SilentlyContinue | Remove-Cluster -Server $script:vCenter -Confirm:$false
    Get-Folder -Server $script:vCenter -Name $script:inventoryPathWithCustomFolder -ErrorAction SilentlyContinue | Remove-Folder -Server $script:vCenter -Confirm:$false
}

try {
    Describe "$($script:dscResourceName)_Integration" {
        Context "When using configuration $($script:configWithClusterToAdd)" {
            AfterAll {
                Invoke-TestCleanup
            }

            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithClusterToAddPath
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
                    Path = $script:mofFileWithClusterToAddPath
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Assert
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
                $configuration.Ensure | Should -Be $script:resourceWithClusterToAdd.Ensure
                $configuration.InventoryPath | Should -Be $script:inventoryPath
                $configuration.Datacenter | Should -Be $script:datacenter
                $configuration.Name | Should -Be $script:clusterName
                $configuration.DrsEnabled | Should -Be $script:resourceWithClusterToAdd.DrsEnabled
                $configuration.DrsAutomationLevel | Should -Be $script:resourceWithClusterToAdd.DrsAutomationLevel
                $configuration.DrsMigrationThreshold | Should -Be $script:resourceWithClusterToAdd.DrsMigrationThreshold
                $configuration.DrsDistribution | Should -Be $script:resourceWithClusterToAdd.DrsDistribution
                $configuration.MemoryLoadBalancing | Should -Be $script:resourceWithClusterToAdd.MemoryLoadBalancing
                $configuration.CPUOverCommitment | Should -Be $script:resourceWithClusterToAdd.CPUOverCommitment
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }
        }

        Context "When using configuration $($script:configWithClusterToAddInCustomFolder)" {
            BeforeAll {
                New-CustomFolder
            }

            AfterAll {
                Invoke-TestCleanup
            }

            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithClusterToAddInCustomFolderPath
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
                    Path = $script:mofFileWithClusterToAddInCustomFolderPath
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Assert
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
                $configuration.Ensure | Should -Be $script:resourceWithClusterToAddInCustomFolder.Ensure
                $configuration.InventoryPath | Should -Be $script:inventoryPathWithCustomFolder
                $configuration.Datacenter | Should -Be $script:datacenter
                $configuration.Name | Should -Be $script:clusterName
                $configuration.DrsEnabled | Should -Be $script:resourceWithClusterToAddInCustomFolder.DrsEnabled
                $configuration.DrsAutomationLevel | Should -Be $script:resourceWithClusterToAddInCustomFolder.DrsAutomationLevel
                $configuration.DrsMigrationThreshold | Should -Be $script:resourceWithClusterToAddInCustomFolder.DrsMigrationThreshold
                $configuration.DrsDistribution | Should -Be $script:resourceWithClusterToAddInCustomFolder.DrsDistribution
                $configuration.MemoryLoadBalancing | Should -Be $script:resourceWithClusterToAddInCustomFolder.MemoryLoadBalancing
                $configuration.CPUOverCommitment | Should -Be $script:resourceWithClusterToAddInCustomFolder.CPUOverCommitment
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }
        }

        Context "When using configuration $($script:configWithClusterToUpdate)" {
            BeforeAll {
                Invoke-TestSetup
            }

            AfterAll {
                Invoke-TestCleanup
            }

            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithClusterToUpdatePath
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
                    Path = $script:mofFileWithClusterToUpdatePath
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Assert
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
                $configuration.Ensure | Should -Be $script:resourceWithClusterToAdd.Ensure
                $configuration.InventoryPath | Should -Be $script:inventoryPath
                $configuration.Datacenter | Should -Be $script:datacenter
                $configuration.Name | Should -Be $script:clusterName
                $configuration.DrsEnabled | Should -Be $script:resourceWithClusterToAdd.DrsEnabled
                $configuration.DrsAutomationLevel | Should -Be $script:resourceWithClusterToUpdate.DrsAutomationLevel
                $configuration.DrsMigrationThreshold | Should -Be $script:resourceWithClusterToUpdate.DrsMigrationThreshold
                $configuration.DrsDistribution | Should -Be $script:resourceWithClusterToAdd.DrsDistribution
                $configuration.MemoryLoadBalancing | Should -Be $script:resourceWithClusterToAdd.MemoryLoadBalancing
                $configuration.CPUOverCommitment | Should -Be $script:resourceWithClusterToAdd.CPUOverCommitment
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }
        }

        Context "When using configuration $($script:configWithClusterToUpdateInCustomFolder)" {
            BeforeAll {
                Invoke-TestSetup
            }

            AfterAll {
                Invoke-TestCleanup
            }

            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithClusterToUpdateInCustomFolderPath
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
                    Path = $script:mofFileWithClusterToUpdateInCustomFolderPath
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Assert
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
                $configuration.Ensure | Should -Be $script:resourceWithClusterToAddInCustomFolder.Ensure
                $configuration.InventoryPath | Should -Be $script:inventoryPathWithCustomFolder
                $configuration.Datacenter | Should -Be $script:datacenter
                $configuration.Name | Should -Be $script:clusterName
                $configuration.DrsEnabled | Should -Be $script:resourceWithClusterToAddInCustomFolder.DrsEnabled
                $configuration.DrsAutomationLevel | Should -Be $script:resourceWithClusterToAddInCustomFolder.DrsAutomationLevel
                $configuration.DrsMigrationThreshold | Should -Be $script:resourceWithClusterToAddInCustomFolder.DrsMigrationThreshold
                $configuration.DrsDistribution | Should -Be $script:resourceWithClusterToUpdateInCustomFolder.DrsDistribution
                $configuration.MemoryLoadBalancing | Should -Be $script:resourceWithClusterToUpdateInCustomFolder.MemoryLoadBalancing
                $configuration.CPUOverCommitment | Should -Be $script:resourceWithClusterToUpdateInCustomFolder.CPUOverCommitment
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }
        }

        Context "When using configuration $($script:configWithClusterToRemove)" {
            BeforeAll {
                Invoke-TestSetup
            }

            AfterAll {
                Invoke-TestCleanup
            }

            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithClusterToRemovePath
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
                    Path = $script:mofFileWithClusterToRemovePath
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Assert
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
                $configuration.Ensure | Should -Be $script:resourceWithClusterToRemove.Ensure
                $configuration.InventoryPath | Should -Be $script:inventoryPath
                $configuration.Datacenter | Should -Be $script:datacenter
                $configuration.Name | Should -Be $script:clusterName
                $configuration.DrsEnabled | Should -Be $null
                $configuration.DrsAutomationLevel | Should -Be 'Unset'
                $configuration.DrsMigrationThreshold | Should -Be $null
                $configuration.DrsDistribution | Should -Be $null
                $configuration.MemoryLoadBalancing | Should -Be $null
                $configuration.CPUOverCommitment | Should -Be $null
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }
        }

        Context "When using configuration $($script:configWithClusterToRemoveInCustomFolder)" {
            BeforeAll {
                Invoke-TestSetup
            }

            AfterAll {
                Invoke-TestCleanup
            }

            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithClusterToRemoveInCustomFolderPath
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
                    Path = $script:mofFileWithClusterToRemoveInCustomFolderPath
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Assert
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
                $configuration.Ensure | Should -Be $script:resourceWithClusterToRemove.Ensure
                $configuration.InventoryPath | Should -Be $script:inventoryPathWithCustomFolder
                $configuration.Datacenter | Should -Be $script:datacenter
                $configuration.Name | Should -Be $script:clusterName
                $configuration.DrsEnabled | Should -Be $null
                $configuration.DrsAutomationLevel | Should -Be 'Unset'
                $configuration.DrsMigrationThreshold | Should -Be $null
                $configuration.DrsDistribution | Should -Be $null
                $configuration.MemoryLoadBalancing | Should -Be $null
                $configuration.CPUOverCommitment | Should -Be $null
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }
        }
    }
}
finally {
    Disconnect-VIServer -Server $Server -Confirm:$false
}
