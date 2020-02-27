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

# Retrieves the needed SSD based Datastore from the Server. If there is no SSD based Datastore on the Server for the VMHost, it throws an error.
function Invoke-TestSetup {
    $viServer = Connect-VIServer -Server $Server -User $User -Password $Password
    $vmHost = Get-VMHost -Server $viServer -Name $Name

    $datastore = Get-Datastore -Server $viServer -RelatedObject $vmHost -ErrorAction SilentlyContinue | Where-Object { $_.ExtensionData.Info.Vmfs.Ssd -eq $true } | Select-Object -First 1
    if ($null -eq $datastore) {
        throw "Integration Tests need one SSD based Datastore but no SSD based Datastore is found on the server $Server."
    }

    $script:datastoreName = $datastore.Name
}

Invoke-TestSetup

$script:dscResourceName = 'VMHostCache'
$script:moduleFolderPath = (Get-Module 'VMware.vSphereDSC' -ListAvailable).ModuleBase
$script:integrationTestsFolderPath = Join-Path (Join-Path $moduleFolderPath 'Tests') 'Integration'
$script:configurationFile = "$script:integrationTestsFolderPath\Configurations\$($script:dscResourceName)\$($script:dscResourceName)_Config.ps1"

$script:configWhenSwapSizeIsZeroGigabytes = "$($script:dscResourceName)_WhenSwapSizeIsZeroGigabytes_Config"
$script:configWhenSwapSizeIsOneGigabyte = "$($script:dscResourceName)_WhenSwapSizeIsOneGigabyte_Config"
$script:configWhenSwapSizeIsTwoGigabytes = "$($script:dscResourceName)_WhenSwapSizeIsTwoGigabytes_Config"

. $script:configurationFile -Name $Name -Server $Server -User $User -Password $Password -DatastoreName $script:datastoreName

$script:mofFileWhenSwapSizeIsZeroGigabytesPath = "$script:integrationTestsFolderPath\$($script:configWhenSwapSizeIsZeroGigabytes)\"
$script:mofFileWhenSwapSizeIsOneGigabytePath = "$script:integrationTestsFolderPath\$($script:configWhenSwapSizeIsOneGigabyte)\"
$script:mofFileWhenSwapSizeIsTwoGigabytesPath = "$script:integrationTestsFolderPath\$($script:configWhenSwapSizeIsTwoGigabytes)\"

try {
    Describe "$($script:dscResourceName)_Integration" {
        Context "When using configuration $($script:configWhenSwapSizeIsZeroGigabytes)" {
            BeforeAll {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenSwapSizeIsZeroGigabytesPath
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters
            }

            It 'Should compile and apply the MOF without throwing' {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenSwapSizeIsZeroGigabytesPath
                    ComputerName = 'localhost'
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
                $configuration = Get-DscConfiguration -Verbose

                # Assert
                $configuration.Server | Should -Be $Server
                $configuration.Name | Should -Be $Name
                $configuration.DatastoreName | Should -Be $script:datastoreName
                $configuration.SwapSizeGB | Should -Be $script:zeroGigabytesSwapSize
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration -Verbose | Should -Be $true
            }
        }

        Context "When using configuration $($script:configWhenSwapSizeIsOneGigabyte)" {
            BeforeAll {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenSwapSizeIsOneGigabytePath
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters
            }

            It 'Should compile and apply the MOF without throwing' {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenSwapSizeIsOneGigabytePath
                    ComputerName = 'localhost'
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
                $configuration = Get-DscConfiguration -Verbose

                # Assert
                $configuration.Server | Should -Be $Server
                $configuration.Name | Should -Be $Name
                $configuration.DatastoreName | Should -Be $script:datastoreName
                $configuration.SwapSizeGB | Should -Be $script:oneGigabyteSwapSize
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration -Verbose | Should -Be $true
            }

            AfterAll {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenSwapSizeIsZeroGigabytesPath
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters
            }
        }

        Context "When using configuration $($script:configWhenSwapSizeIsTwoGigabytes)" {
            BeforeAll {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenSwapSizeIsTwoGigabytesPath
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters
            }

            It 'Should compile and apply the MOF without throwing' {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenSwapSizeIsTwoGigabytesPath
                    ComputerName = 'localhost'
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
                $configuration = Get-DscConfiguration -Verbose

                # Assert
                $configuration.Server | Should -Be $Server
                $configuration.Name | Should -Be $Name
                $configuration.DatastoreName | Should -Be $script:datastoreName
                $configuration.SwapSizeGB | Should -Be $script:twoGigabytesSwapSize
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration -Verbose | Should -Be $true
            }

            AfterAll {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenSwapSizeIsZeroGigabytesPath
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters
            }
        }
    }
}
finally {
    Disconnect-VIServer -Server $Server -Confirm:$false
}
