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

$script:dscResourceName = 'VMHostTpsSettings'
$script:moduleFolderPath = (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase
$script:integrationTestsFolderPath = Join-Path (Join-Path $moduleFolderPath 'Tests') 'Integration'
$script:configurationFile = "$script:integrationTestsFolderPath\Configurations\$($script:dscResourceName)\$($script:dscResourceName)_Config.ps1"

$script:config = "$($script:dscResourceName)_Config"

$script:connection = Connect-VIServer -Server $Server -User $User -Password $Password
$script:vmHost = $null

$script:shareScanTime = $null
$script:shareScanGHz = $null
$script:shareRateMax = $null
$script:shareForceSalting = $null

$script:shareScanTimeTestValue = 50
$script:shareForceSaltingTestValue = 1

$script:resourceProperties = @{
    Name = $Name
    Server = $Server
    ShareScanTime = $script:shareScanTimeTestValue
    ShareForceSalting = $script:shareForceSaltingTestValue
}

. $script:configurationFile -Name $Name -Server $Server -User $User -Password $Password

$script:mofFilePath = "$script:integrationTestsFolderPath\$($script:config)\"

function Invoke-TestSetup {
    $script:vmHost = Get-VMHost -Server $script:connection -Name $script:resourceProperties.Name

    $script:shareScanTime = Get-AdvancedSetting -Server $script:connection -Entity $script:vmHost -Name "Mem.ShareScanTime"
    $script:shareScanGHz = Get-AdvancedSetting -Server $script:connection -Entity $script:vmHost -Name "Mem.ShareScanGHz"
    $script:shareRateMax = Get-AdvancedSetting -Server $script:connection -Entity $script:vmHost -Name "Mem.ShareRateMax"
    $script:shareForceSalting = Get-AdvancedSetting -Server $script:connection -Entity $script:vmHost -Name "Mem.ShareForceSalting"
}

function Invoke-TestCleanup {
    $script:vmHost = Get-VMHost -Server $script:connection -Name $script:resourceProperties.Name

    Set-AdvancedSetting -AdvancedSetting $script:shareScanTime -Value $script:shareScanTime.Value -Confirm:$false
    Set-AdvancedSetting -AdvancedSetting $script:shareForceSalting -Value $script:shareForceSalting.Value -Confirm:$false
}

try {
    Describe "$($script:dscResourceName)_Integration" {
        Context "When using configuration $($script:config)" {
            BeforeAll {
                Invoke-TestSetup
            }

            AfterAll {
                Invoke-TestCleanup
            }

            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFilePath
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
                    Path = $script:mofFilePath
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
                $configuration.Name | Should -Be $script:resourceProperties.Name
                $configuration.Server | Should -Be $script:resourceProperties.Server
                $configuration.ShareScanTime | Should -Be $script:shareScanTimeTestValue
                $configuration.ShareScanGHz | Should -Be $script:shareScanGHz.Value
                $configuration.ShareRateMax | Should -Be $script:shareRateMax.Value
                $configuration.ShareForceSalting | Should -Be $script:shareForceSaltingTestValue
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
