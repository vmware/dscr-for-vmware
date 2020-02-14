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

# Retrieves the pNics that are unused from the Server. If there are not available unused pNics on the Server, it throws an error.
function Invoke-TestSetup {
    $viServer = Connect-VIServer -Server $Server -User $User -Password $Password
    $availableNetworkAdapters = Get-VMHostNetworkAdapter -Server $viServer | Where-Object { $_.Id -Match 'PhysicalNic' -and $_.BitRatePerSec -eq 0 }
    if ($availableNetworkAdapters.Length -lt 2) {
        throw "The VSS that is used in the Integration Tests requires 2 unused pNICs to be available on the ESXi node."
    }

    $script:activeNic = @($availableNetworkAdapters[0].Name, $availableNetworkAdapters[1].Name)
    $script:activeNicAlt = @($availableNetworkAdapters[0].Name)
    $script:standbyNic = @()
    $script:standbyNicAlt = @($availableNetworkAdapters[1].Name)
}

Invoke-TestSetup

$script:moduleName = 'VMware.vSphereDSC'
$script:dscResourceName = 'VMHostVssTeaming'
$script:dscDependResourceName = 'VMHostVssBridge'
$script:moduleFolderPath = (Get-Module -Name $script:moduleName -ListAvailable).ModuleBase
$script:integrationTestsFolderPath = Join-Path (Join-Path $moduleFolderPath 'Tests') 'Integration'
$script:configurationFile = "$script:integrationTestsFolderPath\Configurations\$($script:dscResourceName)\$($script:dscResourceName)_Config.ps1"

$script:configWithModifyVssTeaming = "$($script:dscResourceName)_Modify_Config"
$script:configWithRemoveVssTeaming = "$($script:dscResourceName)_Remove_Config"

$script:VssName = 'VSSDSC'
$script:AverageBandwidth = 100000
$script:CheckBeacon = $false
$script:NotifySwitches = $true
$script:Policy = 'loadbalance_srcid'
$script:PolicyAlt = 'loadbalance_ip'
$script:RollingOrder = $false
$script:Present = 'Present'
$script:Absent = 'Absent'

$script:resourceWithModifyVssTeaming = @{
    Name = $Name
    Server = $Server
    Ensure = $script:Present
    VssName = $script:VssName
    CheckBeacon = -not $script:CheckBeacon
    ActiveNic = $script:activeNic
    StandbyNic = $script:standbyNic
    NotifySwitches = -not $script:NotifySwitches
    Policy = $script:PolicyAlt
    RollingOrder = -not $script:RollingOrder
}
$script:resourceWithRemoveVssTeaming = @{
    Name = $Name
    Server = $Server
    Ensure = $script:Absent
    VssName = $script:VssName
    CheckBeacon = $script:CheckBeacon
    ActiveNic = @()
    StandbyNic = @()
    NotifySwitches = $script:NotifySwitches
    Policy = $script:Policy
    RollingOrder = $script:RollingOrder
}

. $script:configurationFile -Name $Name -Server $Server -User $User -Password $Password -ActiveNic $script:activeNic -ActiveNicAlt $script:activeNicAlt -StandbyNic $script:standbyNic -StandbyNicAlt $script:standbyNicAlt

$script:mofFileWithModifyVssTeaming = "$script:integrationTestsFolderPath\$($script:configWithModifyVssTeaming)\"
$script:mofFileWithRemoveVssTeaming = "$script:integrationTestsFolderPath\$($script:configWithRemoveVssTeaming)\"

try {
    Describe "$($script:dscResourceName)_Integration" {
        Context "When using configuration $($script:configWithModifyVssTeaming)" {
            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithModifyVssTeaming
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
                    Path = $script:mofFileWithModifyVssTeaming
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
                $configuration.Server | Should -Be $script:resourceWithModifyVssTeaming.Server
                $configuration.Name | Should -Be $script:resourceWithModifyVssTeaming.Name
                $configuration.Ensure | Should -Be $script:Present
                $configuration.VssName | Should -Be $script:resourceWithModifyVssTeaming.VssName
                $configuration.CheckBeacon | Should -Be $script:resourceWithModifyVssTeaming.CheckBeacon
                $configuration.ActiveNic | Should -Be $script:resourceWithModifyVssTeaming.ActiveNic
                $configuration.StandbyNic | Should -Be $script:resourceWithModifyVssTeaming.StandbyNic
                $configuration.NotifySwitches | Should -Be $script:resourceWithModifyVssTeaming.NotifySwitches
                $configuration.Policy | Should -Be $script:resourceWithModifyVssTeaming.Policy
                $configuration.RollingOrder | Should -Be $script:resourceWithModifyVssTeaming.RollingOrder
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }

            It 'Should depend on resource VMHostVssBridge' {
                # Act
                $currentResource = Get-DscConfiguration | Where-Object { $_.ResourceId -match $script:dscResourceName }

                # Assert
                $currentResource.DependsOn | Should -Match $script:dscDependResourceName
            }
        }

        Context "When using configuration $($script:configWithRemoveVssTeaming)" {
            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithRemoveVssTeaming
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
                    Path = $script:mofFileWithRemoveVssTeaming
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
                $configuration.Server | Should -Be $script:resourceWithRemoveVssTeaming.Server
                $configuration.Name | Should -Be $script:resourceWithRemoveVssTeaming.Name
                $configuration.Ensure | Should -Be $script:Present
                $configuration.VssName | Should -Be $script:resourceWithRemoveVssTeaming.VssName
                $configuration.CheckBeacon | Should -Be $script:resourceWithRemoveVssTeaming.CheckBeacon
                $configuration.ActiveNic | Should -Be $script:resourceWithRemoveVssTeaming.ActiveNic
                $configuration.StandbyNic | Should -Be $script:resourceWithRemoveVssTeaming.StandbyNic
                $configuration.NotifySwitches | Should -Be $script:resourceWithRemoveVssTeaming.NotifySwitches
                $configuration.Policy | Should -Be $script:resourceWithRemoveVssTeaming.Policy
                $configuration.RollingOrder | Should -Be $script:resourceWithRemoveVssTeaming.RollingOrder
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }

            It 'Should depend on resource VMHostVssBridge' {
                # Act
                $currentResource = Get-DscConfiguration | Where-Object { $_.ResourceId -match $script:dscResourceName }

                # Assert
                $currentResource.DependsOn | Should -Match $script:dscDependResourceName
            }
        }
    }
}
finally {
    Disconnect-VIServer -Server $Server -Confirm:$false
}
