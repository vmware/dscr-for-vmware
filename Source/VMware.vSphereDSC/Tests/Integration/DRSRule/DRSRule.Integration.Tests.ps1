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

<#
    The DRSRule DSC Resource Integration Tests require a vCenter Server with at
    least one Datacenter and at least one VMHost located in that Datacenter.
#>

# The 'Name' parameter is not used in the Integration Tests, so it is set to $null.
$Name = $null

$newObjectParamsForCredential = @{
    TypeName = 'System.Management.Automation.PSCredential'
    ArgumentList = @(
        $User,
        (ConvertTo-SecureString -String $Password -AsPlainText -Force)
    )
}
$script:Credential = New-Object @newObjectParamsForCredential

$script:DscResourceName = 'DRSRule'
$script:ConfigurationsPath = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DscResourceName)_Config.ps1"

. "$PSScriptRoot\$script:DscResourceName.Integration.Tests.Helpers.ps1"
Test-Setup

$script:ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
            Server = $Server
            Credential = $script:Credential
            DrsClusterDscResourceId = '[DrsCluster]DrsCluster'
            DrsClusterDscResourceName = 'DrsCluster'
            vCenterVMHostDscResourceId = '[vCenterVMHost]vCenterVMHost'
            vCenterVMHostDscResourceName = 'vCenterVMHost'
            DRSRuleDscResourceName = 'DRSRule'
            VMHostConfigurationDscResourceId = '[VMHostConfiguration]VMHostConfiguration'
            VMHostConfigurationDscResourceName = 'VMHostConfiguration'
            ClusterName = 'DscDrsCluster'
            ClusterLocation = [string]::Empty
            ClusterDrsEnabled = $true
            DatacenterName = $script:Datacenter.Name
            DatacenterLocation = $script:DatacenterLocation
            VMHostName = $script:VMHost.Name
            VMHostClusterLocation = 'DscDrsCluster'
            VMHostDatacenterLocation = $script:VMHostLocation
            VMHostDisconnectedState = 'Disconnected'
            VMHostOriginalState = [string] $script:VMHost.ConnectionState
            DRSRuleName = 'DscDrsRule'
            DRSRuleType = 'VMAffinity'
            DRSRuleEnabled = $true
            VirtualMachineNames = $script:VirtualMachineNames
        }
    )
}

. $script:ConfigurationsPath -Verbose:$true -ErrorAction Stop

$script:CreateDrsClusterConfigurationName = "$($script:DscResourceName)_CreateDrsClusterAndMoveVMHostInCluster_Config"
$script:CreateDRSRuleConfigurationName = "$($script:DscResourceName)_CreateDRSRule_Config"
$script:RemoveDRSRuleConfigurationName = "$($script:DscResourceName)_RemoveDRSRule_Config"
$script:ChangeVMHostStateConfigurationName = "$($script:DscResourceName)_ChangeVMHostStateToDisconnected_Config"
$script:RemoveDrsClusterConfigurationName = "$($script:DscResourceName)_MoveVMHostToDatacenterAndRemoveDrsCluster_Config"

$script:CreateDrsClusterMofFilePath = Join-Path -Path $PSScriptRoot -ChildPath $script:CreateDrsClusterConfigurationName
$script:CreateDRSRuleMofFilePath = Join-Path -Path $PSScriptRoot -ChildPath $script:CreateDRSRuleConfigurationName
$script:RemoveDRSRuleMofFilePath = Join-Path -Path $PSScriptRoot -ChildPath $script:RemoveDRSRuleConfigurationName
$script:ChangeVMHostStateMofFilePath = Join-Path -Path $PSScriptRoot -ChildPath $script:ChangeVMHostStateConfigurationName
$script:RemoveDrsClusterMofFilePath = Join-Path -Path $PSScriptRoot -ChildPath $script:RemoveDrsClusterConfigurationName

Describe "$($script:DscResourceName)_Integration" {
    AfterAll {
        # We need to remove the Virtual Machines to restore the initial state of the vCenter Server.
        Test-CleanUp
    }

    Context 'When creating DRS rule' {
        BeforeAll {
            # Arrange
            & $script:CreateDrsClusterConfigurationName `
                -OutputPath $script:CreateDrsClusterMofFilePath `
                -ConfigurationData $script:ConfigurationData `
                -ErrorAction Stop

            $startDscConfigurationParamsCreateDrsCluster = @{
                Path = $script:CreateDrsClusterMofFilePath
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParamsCreateDrsCluster } | Should -Not -Throw

            It 'Should compile and apply the MOF without throwing' {
                # Arrange
                & $script:CreateDRSRuleConfigurationName `
                    -OutputPath $script:CreateDRSRuleMofFilePath `
                    -ConfigurationData $script:ConfigurationData `
                    -ErrorAction Stop

                $startDscConfigurationParamsCreateDRSRule = @{
                    Path = $script:CreateDRSRuleMofFilePath
                    ComputerName = $script:ConfigurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act && Assert
                { Start-DscConfiguration @startDscConfigurationParamsCreateDRSRule } | Should -Not -Throw
            }
        }

        It 'Should be able to call Test-DscConfiguration without throwing' {
            # Arrange
            $testDscConfigurationParams = @{
                ReferenceConfiguration = Join-Path -Path $script:CreateDRSRuleMofFilePath -ChildPath "$($script:ConfigurationData.AllNodes.NodeName).mof"
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
                ReferenceConfiguration = Join-Path -Path $script:CreateDRSRuleMofFilePath -ChildPath "$($script:ConfigurationData.AllNodes.NodeName).mof"
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
                    $_.ConfigurationName -eq $script:CreateDRSRuleConfigurationName
                }
            }

            # Act
            $DRSRuleDscResource = Get-DscConfiguration -Verbose:$true -ErrorAction Stop | Where-Object @whereObjectParams

            # Assert
            $DRSRuleDscResource.Server | Should -Be $script:ConfigurationData.AllNodes.Server
            $DRSRuleDscResource.Name | Should -Be $script:ConfigurationData.AllNodes.DRSRuleName
            $DRSRuleDscResource.DatacenterName | Should -Be $script:ConfigurationData.AllNodes.DatacenterName
            $DRSRuleDscResource.DatacenterLocation | Should -Be $script:ConfigurationData.AllNodes.DatacenterLocation
            $DRSRuleDscResource.ClusterName | Should -Be $script:ConfigurationData.AllNodes.ClusterName
            $DRSRuleDscResource.ClusterLocation | Should -Be $script:ConfigurationData.AllNodes.ClusterLocation
            $DRSRuleDscResource.DRSRuleType | Should -Be $script:ConfigurationData.AllNodes.DRSRuleType
            $DRSRuleDscResource.VMNames | Should -Be $script:ConfigurationData.AllNodes.VirtualMachineNames
            $DRSRuleDscResource.Ensure | Should -Be 'Present'
            $DRSRuleDscResource.Enabled | Should -Be $script:ConfigurationData.AllNodes.DRSRuleEnabled
        }

        AfterAll {
            # Arrange
            & $script:RemoveDRSRuleConfigurationName `
                -OutputPath $script:RemoveDRSRuleMofFilePath `
                -ConfigurationData $script:ConfigurationData `
                -ErrorAction Stop

            & $script:ChangeVMHostStateConfigurationName `
                -OutputPath $script:ChangeVMHostStateMofFilePath `
                -ConfigurationData $script:ConfigurationData `
                -ErrorAction Stop

            & $script:RemoveDrsClusterConfigurationName `
                -OutputPath $script:RemoveDrsClusterMofFilePath `
                -ConfigurationData $script:ConfigurationData `
                -ErrorAction Stop

            $startDscConfigurationParamsRemoveDRSRule = @{
                Path = $script:RemoveDRSRuleMofFilePath
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParamsChangeVMHostState = @{
                Path = $script:ChangeVMHostStateMofFilePath
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParamsRemoveDrsCluster = @{
                Path = $script:RemoveDrsClusterMofFilePath
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParamsRemoveDRSRule } | Should -Not -Throw
            { Start-DscConfiguration @startDscConfigurationParamsChangeVMHostState } | Should -Not -Throw
            { Start-DscConfiguration @startDscConfigurationParamsRemoveDrsCluster } | Should -Not -Throw

            Remove-Item -Path $script:CreateDrsClusterMofFilePath -Recurse -Confirm:$false -Verbose:$true -ErrorAction Stop
            Remove-Item -Path $script:CreateDRSRuleMofFilePath -Recurse -Confirm:$false -Verbose:$true -ErrorAction Stop
            Remove-Item -Path $script:RemoveDRSRuleMofFilePath -Recurse -Confirm:$false -Verbose:$true -ErrorAction Stop
            Remove-Item -Path $script:ChangeVMHostStateMofFilePath -Recurse -Confirm:$false -Verbose:$true -ErrorAction Stop
            Remove-Item -Path $script:RemoveDrsClusterMofFilePath -Recurse -Confirm:$false -Verbose:$true -ErrorAction Stop
        }
    }

    Context 'When removing DRS rule' {
        BeforeAll {
            # Arrange
            & $script:CreateDrsClusterConfigurationName `
                -OutputPath $script:CreateDrsClusterMofFilePath `
                -ConfigurationData $script:ConfigurationData `
                -ErrorAction Stop

            & $script:CreateDRSRuleConfigurationName `
                -OutputPath $script:CreateDRSRuleMofFilePath `
                -ConfigurationData $script:ConfigurationData `
                -ErrorAction Stop

            $startDscConfigurationParamsCreateDrsCluster = @{
                Path = $script:CreateDrsClusterMofFilePath
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParamsCreateDRSRule = @{
                Path = $script:CreateDRSRuleMofFilePath
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParamsCreateDrsCluster } | Should -Not -Throw
            { Start-DscConfiguration @startDscConfigurationParamsCreateDRSRule } | Should -Not -Throw

            It 'Should compile and apply the MOF without throwing' {
                # Arrange
                & $script:RemoveDRSRuleConfigurationName `
                    -OutputPath $script:RemoveDRSRuleMofFilePath `
                    -ConfigurationData $script:ConfigurationData `
                    -ErrorAction Stop

                $startDscConfigurationParamsRemoveDRSRule = @{
                    Path = $script:RemoveDRSRuleMofFilePath
                    ComputerName = $script:ConfigurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act && Assert
                { Start-DscConfiguration @startDscConfigurationParamsRemoveDRSRule } | Should -Not -Throw
            }
        }

        It 'Should be able to call Test-DscConfiguration without throwing' {
            # Arrange
            $testDscConfigurationParams = @{
                ReferenceConfiguration = Join-Path -Path $script:RemoveDRSRuleMofFilePath -ChildPath "$($script:ConfigurationData.AllNodes.NodeName).mof"
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
                ReferenceConfiguration = Join-Path -Path $script:RemoveDRSRuleMofFilePath -ChildPath "$($script:ConfigurationData.AllNodes.NodeName).mof"
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
                    $_.ConfigurationName -eq $script:RemoveDRSRuleConfigurationName
                }
            }

            # Act
            $DRSRuleDscResource = Get-DscConfiguration -Verbose:$true -ErrorAction Stop | Where-Object @whereObjectParams

            # Assert
            $DRSRuleDscResource.Server | Should -Be $script:ConfigurationData.AllNodes.Server
            $DRSRuleDscResource.Name | Should -Be $script:ConfigurationData.AllNodes.DRSRuleName
            $DRSRuleDscResource.DatacenterName | Should -Be $script:ConfigurationData.AllNodes.DatacenterName
            $DRSRuleDscResource.DatacenterLocation | Should -Be $script:ConfigurationData.AllNodes.DatacenterLocation
            $DRSRuleDscResource.ClusterName | Should -Be $script:ConfigurationData.AllNodes.ClusterName
            $DRSRuleDscResource.ClusterLocation | Should -Be $script:ConfigurationData.AllNodes.ClusterLocation
            $DRSRuleDscResource.DRSRuleType | Should -Be $script:ConfigurationData.AllNodes.DRSRuleType
            $DRSRuleDscResource.VMNames | Should -Be $script:ConfigurationData.AllNodes.VirtualMachineNames
            $DRSRuleDscResource.Ensure | Should -Be 'Absent'
            $DRSRuleDscResource.Enabled | Should -BeNull
        }

        AfterAll {
            # Arrange
            & $script:ChangeVMHostStateConfigurationName `
                -OutputPath $script:ChangeVMHostStateMofFilePath `
                -ConfigurationData $script:ConfigurationData `
                -ErrorAction Stop

            & $script:RemoveDrsClusterConfigurationName `
                -OutputPath $script:RemoveDrsClusterMofFilePath `
                -ConfigurationData $script:ConfigurationData `
                -ErrorAction Stop

            $startDscConfigurationParamsChangeVMHostState = @{
                Path = $script:ChangeVMHostStateMofFilePath
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParamsRemoveDrsCluster = @{
                Path = $script:RemoveDrsClusterMofFilePath
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParamsChangeVMHostState } | Should -Not -Throw
            { Start-DscConfiguration @startDscConfigurationParamsRemoveDrsCluster } | Should -Not -Throw

            Remove-Item -Path $script:CreateDrsClusterMofFilePath -Recurse -Confirm:$false -Verbose:$true -ErrorAction Stop
            Remove-Item -Path $script:CreateDRSRuleMofFilePath -Recurse -Confirm:$false -Verbose:$true -ErrorAction Stop
            Remove-Item -Path $script:RemoveDRSRuleMofFilePath -Recurse -Confirm:$false -Verbose:$true -ErrorAction Stop
            Remove-Item -Path $script:ChangeVMHostStateMofFilePath -Recurse -Confirm:$false -Verbose:$true -ErrorAction Stop
            Remove-Item -Path $script:RemoveDrsClusterMofFilePath -Recurse -Confirm:$false -Verbose:$true -ErrorAction Stop
        }
    }
}
