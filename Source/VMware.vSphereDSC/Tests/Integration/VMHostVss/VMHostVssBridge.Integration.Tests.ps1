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

    $script:nicDevice = @($availableNetworkAdapters[0].Name, $availableNetworkAdapters[1].Name)
    $script:nicDeviceAlt = @($availableNetworkAdapters[0].Name)
}

Invoke-TestSetup

$script:moduleName = 'VMware.vSphereDSC'
$script:dscResourceName = 'VMHostVssBridge'
$script:dscDependResourceName = 'VMHostVss'
$script:moduleFolderPath = (Get-Module -Name $script:moduleName -ListAvailable).ModuleBase
$script:integrationTestsFolderPath = Join-Path (Join-Path $moduleFolderPath 'Tests') 'Integration'
$script:configurationFile = "$script:integrationTestsFolderPath\Configurations\$($script:dscResourceName)\$($script:dscResourceName)_Config.ps1"

$script:configWithCreateVssBridge = "$($script:dscResourceName)_Create_Config"
$script:configWithModifyVssBridge = "$($script:dscResourceName)_Modify_Config"
$script:configWithRemoveVssBridge = "$($script:dscResourceName)_Remove_Config"

$script:VssName = 'VSSDSC'
$script:BeaconInterval = 1
$script:BeaconIntervalAlt = 5
$script:LinkDiscoveryProtocolProtocol = 'CDP'
$script:LinkDiscoveryProtocolOperation = 'Listen'
$script:LinkDiscoveryProtocolProtocolAlt = 'CDP'
$script:LinkDiscoveryProtocolOperationAlt = 'Both'
$script:Present = 'Present'
$script:Absent = 'Absent'

$script:resourceWithCreateVssBridge = @{
    Name = $Name
    Server = $Server
    Ensure = $script:Present
    VssName = $script:VssName
    NicDevice = $script:nicDevice
    BeaconInterval = $script:BeaconInterval
    LinkDiscoveryProtocolProtocol = $script:LinkDiscoveryProtocolProtocol
    LinkDiscoveryProtocolOperation = $script:LinkDiscoveryProtocolOperation
    DependsOn = "[VMHostVss]vmHostVssSettings"
}
$script:resourceWithModifyVssBridge = @{
    Name = $Name
    Server = $Server
    Ensure = $script:Present
    VssName = $script:VssName
    NicDevice = $script:nicDeviceAlt
    BeaconInterval = $script:BeaconIntervalAlt
    LinkDiscoveryProtocolProtocol = $script:LinkDiscoveryProtocolProtocolAlt
    LinkDiscoveryProtocolOperation = $script:LinkDiscoveryProtocolOperationAlt
    DependsOn = "[VMHostVss]vmHostVssSettings"
}
$script:resourceWithRemoveVssBridge = @{
    Name = $Name
    Server = $Server
    Ensure = $script:Absent
    VssName = $script:VssName
    DependsOn = "[VMHostVss]vmHostVssSettings"
}

. $script:configurationFile -Name $Name -Server $Server -User $User -Password $Password -NicDevice $script:nicDevice -NicDeviceAlt $script:nicDeviceAlt

$script:mofFileWithCreateVssBridge = "$script:integrationTestsFolderPath\$($script:configWithCreateVssBridge)\"
$script:mofFileWithModifyVssBridge = "$script:integrationTestsFolderPath\$($script:configWithModifyVssBridge)\"
$script:mofFileWithRemoveVssBridge = "$script:integrationTestsFolderPath\$($script:configWithRemoveVssBridge)\"

try {
    Describe "$($script:dscResourceName)_Integration" {
        Context "When using configuration $($script:configWithCreateVssBridge)" {
            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithCreateVssBridge
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
                    Path = $script:mofFileWithCreateVssBridge
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
                $configuration = Get-DscConfiguration | Where-Object { $_.ResourceId -match $script:dscResourceName }

                # Assert
                $configuration.Server | Should -Be $script:resourceWithCreateVssBridge.Server
                $configuration.Name | Should -Be $script:resourceWithCreateVssBridge.Name
                $configuration.Ensure | Should -Be $script:Present
                $configuration.VssName | Should -Be $script:resourceWithCreateVssBridge.VssName
                $configuration.NicDevice | Should  -Be $script:resourceWithCreateVssBridge.NicDevice
                $configuration.BeaconInterval | Should  -Be $script:resourceWithCreateVssBridge.BeaconInterval
                $configuration.LinkDiscoveryProtocolProtocol | Should  -Be $script:resourceWithCreateVssBridge.LinkDiscoveryProtocolProtocol
                $configuration.LinkDiscoveryProtocolOperation | Should  -Be $script:resourceWithCreateVssBridge.LinkDiscoveryProtocolOperation
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

        Context "When using configuration $($script:configWithModifyVssBridge)" {
            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithModifyVssBridge
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
                    Path = $script:mofFileWithModifyVssBridge
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
                $configuration = Get-DscConfiguration | Where-Object { $_.ResourceId -match $script:dscResourceName }

                # Assert
                $configuration.Server | Should -Be $script:resourceWithModifyVssBridge.Server
                $configuration.Name | Should -Be $script:resourceWithModifyVssBridge.Name
                $configuration.Ensure | Should -Be $script:Present
                $configuration.VssName | Should -Be $script:resourceWithModifyVssBridge.VssName
                $configuration.NicDevice | Should  -Be $script:resourceWithModifyVssBridge.NicDevice
                $configuration.BeaconInterval | Should  -Be $script:resourceWithModifyVssBridge.BeaconInterval
                $configuration.LinkDiscoveryProtocolProtocol | Should  -Be $script:resourceWithModifyVssBridge.LinkDiscoveryProtocolProtocol
                $configuration.LinkDiscoveryProtocolOperation | Should  -Be $script:resourceWithModifyVssBridge.LinkDiscoveryProtocolOperation
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

        Context "When using configuration $($script:configWithRemoveVssBridge)" {
            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithRemoveVssBridge
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
                    Path = $script:mofFileWithRemoveVssBridge
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
                $configuration = Get-DscConfiguration | Where-Object { $_.ResourceId -match $script:dscResourceName }

                # Assert
                $configuration.Server | Should -Be $script:resourceWithRemoveVssBridge.Server
                $configuration.Name | Should -Be $script:resourceWithRemoveVssBridge.Name
                $configuration.Ensure | Should -Be $script:Present
                $configuration.VssName | Should -Be $script:resourceWithRemoveVssBridge.VssName
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
    }
}
finally {
    Disconnect-VIServer -Server $Server -Confirm:$false
}
