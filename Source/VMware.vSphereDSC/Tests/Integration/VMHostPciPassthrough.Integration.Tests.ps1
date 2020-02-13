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

# Retrieves the PCI Device Id of the first PCI Device which is Passthrough capable. If there are no PCI Devices which are Passthrough capable, it throws an error.
function Invoke-TestSetup {
    $viServer = Connect-VIServer -Server $Server -User $User -Password $Password
    $vmHost = Get-VMHost -Server $viServer -Name $Name
    $pciPassthruSystem = Get-View -Server $viServer -Id $vmHost.ExtensionData.ConfigManager.PciPassthruSystem

    $pciDevice = $pciPassthruSystem.PciPassthruInfo | Where-Object { $_.PassthruCapable } | Select-Object -First 1
    if ($null -eq $pciDevice) {
        throw "No Passthrough capable PCI Device is found on the server $Server."
    }

    $script:pciDeviceId = $pciDevice.Id
}

Invoke-TestSetup

$script:dscResourceName = 'VMHostPciPassthrough'
$script:moduleFolderPath = (Get-Module 'VMware.vSphereDSC' -ListAvailable).ModuleBase
$script:integrationTestsFolderPath = Join-Path (Join-Path $moduleFolderPath 'Tests') 'Integration'
$script:configurationFile = "$script:integrationTestsFolderPath\Configurations\$($script:dscResourceName)\$($script:dscResourceName)_Config.ps1"

$script:configWhenEnablingPassthru = "$($script:dscResourceName)_WhenEnablingPassthru_Config"
$script:configWhenDisablingPassthru = "$($script:dscResourceName)_WhenDisablingPassthru_Config"

. $script:configurationFile -Name $Name -Server $Server -User $User -Password $Password -PciDeviceId $script:pciDeviceId

$script:mofFileWhenEnablingPassthruPath = "$script:integrationTestsFolderPath\$($script:configWhenEnablingPassthru)\"
$script:mofFileWhenDisablingPassthruPath = "$script:integrationTestsFolderPath\$($script:configWhenDisablingPassthru)\"

try {
    Describe "$($script:dscResourceName)_Integration" {
        Context "When using configuration $($script:configWhenEnablingPassthru)" {
            BeforeAll {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenEnablingPassthruPath
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
                    Path = $script:mofFileWhenEnablingPassthruPath
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Act && Assert
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
                $configuration.Name | Should -Be $Name
                $configuration.Id | Should -Be $script:pciDeviceId
                $configuration.Enabled | Should -Be $true
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }

            AfterAll {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenDisablingPassthruPath
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters
            }
        }

        Context "When using configuration $($script:configWhenDisablingPassthru)" {
            BeforeAll {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenDisablingPassthruPath
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
                    Path = $script:mofFileWhenDisablingPassthruPath
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Act && Assert
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
                $configuration.Name | Should -Be $Name
                $configuration.Id | Should -Be $script:pciDeviceId
                $configuration.Enabled | Should -Be $false
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
