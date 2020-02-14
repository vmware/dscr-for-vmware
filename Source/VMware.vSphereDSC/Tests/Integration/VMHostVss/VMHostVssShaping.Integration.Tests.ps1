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

$script:moduleName = 'VMware.vSphereDSC'
$script:dscResourceName = 'VMHostVssShaping'
$script:dscDependResourceName = 'VMHostVss'
$script:moduleFolderPath = (Get-Module -Name $script:moduleName -ListAvailable).ModuleBase
$script:integrationTestsFolderPath = Join-Path (Join-Path $moduleFolderPath 'Tests') 'Integration'
$script:configurationFile = "$script:integrationTestsFolderPath\Configurations\$($script:dscResourceName)\$($script:dscResourceName)_Config.ps1"

$script:configWithModifyVssShaping = "$($script:dscResourceName)_Modify_Config"
$script:configWithRemoveVssShaping = "$($script:dscResourceName)_Remove_Config"

$script:VssName = 'VSSDSC'
$script:AverageBandwidth = 100000
$script:BurstSize = 100000
$script:Enabled = $false
$script:PeakBandwidth = 100000
$script:Present = 'Present'
$script:Absent = 'Absent'

$script:resourceWithModifyVssShaping = @{
    Name = $Name
    Server = $Server
    Ensure = $script:Present
    VssName = $script:VssName
    AverageBandwidth = $script:AverageBandwidth + 1
    BurstSize = $script:BurstSize + 1
    Enabled = -not $script:Enabled
    PeakBandwidth = $script:PeakBandwidth + 1
}
$script:resourceWithRemoveVssShaping = @{
    Name = $Name
    Server = $Server
    Ensure = $script:Absent
    VssName = $script:VssName
    AverageBandwidth = $script:AverageBandwidth
    BurstSize = $script:BurstSize
    Enabled = $script:Enabled
    PeakBandwidth = $script:PeakBandwidth
}

. $script:configurationFile -Name $Name -Server $Server -User $User -Password $Password

$script:mofFileWithModifyVssShaping = "$script:integrationTestsFolderPath\$($script:configWithModifyVssShaping)\"
$script:mofFileWithRemoveVssShaping = "$script:integrationTestsFolderPath\$($script:configWithRemoveVssShaping)\"

try {
    Describe "$($script:dscResourceName)_Integration" {
        Context "When using configuration $($script:configWithModifyVssShaping)" {
            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithModifyVssShaping
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
                    Path = $script:mofFileWithModifyVssShaping
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Act & Assert
                { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                # Act & Assert
                { Get-DscConfiguration } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration and all the parameters should match' {
                # Act
                $configuration = Get-DscConfiguration | where-object { $_.ResourceId -match $script:dscResourceName }

                # Assert
                $configuration.Server | Should -Be $script:resourceWithModifyVssShaping.Server
                $configuration.Name | Should -Be $script:resourceWithModifyVssShaping.Name
                $configuration.Ensure | Should -Be $script:Present
                $configuration.VssName | Should -Be $script:resourceWithModifyVssShaping.VssName
                $configuration.AverageBandwidth | Should -Be $script:resourceWithModifyVssShaping.AverageBandwidth
                $configuration.BurstSize | Should -Be $script:resourceWithModifyVssShaping.BurstSize
                $configuration.Enabled | Should -Be $script:resourceWithModifyVssShaping.Enabled
                $configuration.PeakBandwidth | Should -Be $script:resourceWithModifyVssShaping.PeakBandwidth
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }

            It 'Should depend on resource VMHostVss' {
                # Act
                $currentResource = Get-DscConfiguration | Where-Object { $_.ResourceId -match $script:dscResourceName }

                # Assert
                $currentResource.DependsOn | Should -Match $script:dscDependResourceName
            }
        }

        Context "When using configuration $($script:configWithRemoveVssShaping)" {
            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithRemoveVssShaping
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters
            }

            It 'Should compile and apply the MOF without throwing' {
                # Assert
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithRemoveVssShaping
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Act & Assert
                { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                # Act & Assert
                { Get-DscConfiguration } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration and all the parameters should match' {
                # Act
                $configuration = Get-DscConfiguration | where-object { $_.ResourceId -match $script:dscResourceName }

                # Assert
                $configuration.Server | Should -Be $script:resourceWithRemoveVssShaping.Server
                $configuration.Name | Should -Be $script:resourceWithRemoveVssShaping.Name
                $configuration.Ensure | Should -Be $script:Present
                $configuration.VssName | Should -Be $script:resourceWithRemoveVssShaping.VssName
                $configuration.AverageBandwidth | Should -Be $script:resourceWithRemoveVssShaping.AverageBandwidth
                $configuration.BurstSize | Should -Be $script:resourceWithRemoveVssShaping.BurstSize
                $configuration.Enabled | Should -Be $script:resourceWithRemoveVssShaping.Enabled
                $configuration.PeakBandwidth | Should -Be $script:resourceWithRemoveVssShaping.PeakBandwidth
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Act && Assert
                Test-DscConfiguration | Should -Be $true
            }

            It 'Should depend on resource VMHostVss' {
                # Act
                $currentResource = Get-DscConfiguration | Where-Object { $_.ResourceId -match $script:dscResourceName }

                # Assert
                $currentResource.DependsOn | Should -Match $script:dscDependResourceName
            }
        }
    }
}
finally {
}
