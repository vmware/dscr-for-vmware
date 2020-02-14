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

$script:dscResourceName = 'VMHostService'
$script:dscConfig = $null
$script:moduleFolderPath = (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase
$script:integrationTestsFolderPath = Join-Path (Join-Path $moduleFolderPath 'Tests') 'Integration'
$script:configurationFile = "$script:integrationTestsFolderPath\Configurations\$($script:dscResourceName)\$($script:dscResourceName)_Config.ps1"

$script:configWithServicePolicyUnset = "$($script:dscResourceName)_WithServicePolicyUnset_Config"
$script:configWithServicePolicyOn = "$($script:dscResourceName)_WithServicePolicyOn_Config"
$script:configWithServicePolicyOff = "$($script:dscResourceName)_WithServicePolicyOff_Config"
$script:configWithServicePolicyOnAndRunning = "$($script:dscResourceName)_WithServicePolicyOnAndRunning_Config"

$script:connection = Connect-VIServer -Server $Server -User $User -Password $Password
$script:vmHost = $null
$script:vmHostService = $null
$script:vmHostServicePolicy = $null

$script:Key = 'TSM-SSH'
$script:PolicyUnset = 'Unset'
$script:PolicyOff = 'Off'
$script:PolicyOn = 'On'
$script:RunningFalse = $false
$script:RunningTrue = $true

$script:resourceWithServicePolicyUnset = @{
    Name = $Name
    Server = $Server
    Key = $script:Key
    Policy = $script:PolicyUnset
    Running = $script:RunningFalse
}
$script:resourceWithServicePolicyOn = @{
    Name = $Name
    Server = $Server
    Key = $script:Key
    Policy = $script:PolicyOn
    Running = $script:RunningFalse
}
$script:resourceWithServicePolicyOff = @{
    Name = $Name
    Server = $Server
    Key = $script:Key
    Policy = $script:PolicyOff
    Running = $script:RunningFalse
}
$script:resourceWithServicePolicyOnAndRunning = @{
    Name = $Name
    Server = $Server
    Key = $script:Key
    Policy = $script:PolicyOn
    Running = $script:RunningTrue
}

. $script:configurationFile -Name $Name -Server $Server -User $User -Password $Password

$script:mofFileWithServicePolicyUnset = "$script:integrationTestsFolderPath\$($script:configWithServicePolicyUnset)\"
$script:mofFileWithServicePolicyOn = "$script:integrationTestsFolderPath\$($script:configWithServicePolicyOn)\"
$script:mofFileWithServicePolicyOff = "$script:integrationTestsFolderPath\$($script:configWithServicePolicyOff)\"
$script:mofFileWithServicePolicyOnAndRunning = "$script:integrationTestsFolderPath\$($script:configWithServicePolicyOnAndRunning)\"

function Invoke-TestSetup {
    $script:vmHost = Get-VMHost -Server $script:connection -Name $script:resourceWithServicePolicyUnset.Name
    $script:vmHostService = Get-VMHostService -Server $script:connection -VMHost $script:vmHost | Where-Object { $_.Key -eq $script:resourceWithServicePolicyUnset.Key }
    $script:vmHostServicePolicy = $script:vmHostService.Policy
}

function Invoke-TestCleanup {
    $script:vmHost = Get-VMHost -Server $script:connection -Name $script:resourceWithServicePolicyUnset.Name
    $script:vmHostService = Get-VMHostService -Server $script:connection -VMHost $script:vmHost | Where-Object { $_.Key -eq $script:resourceWithServicePolicyUnset.Key }

    Set-VMHostService -HostService $script:vmHostService -Policy $script:vmHostServicePolicy -Confirm:$false
}

try {
    Describe "$($script:dscResourceName)_Integration" {
        Context "When using configuration $($script:configWithServicePolicyUnset)" {
            BeforeAll {
                Invoke-TestSetup
            }
            AfterAll {
                Invoke-TestCleanup
            }

            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithServicePolicyUnset
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters
            }

            It 'Should compile and apply the MOF without throwing' {
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithServicePolicyUnset
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Assert
                { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                # Assert
                { Get-DscConfiguration } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration and all the parameters should match' {
                # Act
                $configuration = Get-DscConfiguration

                # Assert
                $configuration.Name | Should -Be $script:resourceWithServicePolicyUnset.Name
                $configuration.Server | Should -Be $script:resourceWithServicePolicyUnset.Server
                $configuration.Key | Should -Be $script:resourceWithServicePolicyUnset.Key
                $configuration.Policy | Should -Be $script:vmHostServicePolicy
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }
        }

        Context "When using configuration $($script:configWithServicePolicyOn)" {
            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithServicePolicyOn
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters
            }

            It 'Should compile and apply the MOF without throwing' {
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithServicePolicyOn
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Assert
                { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                # Assert
                { Get-DscConfiguration} | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration and all the parameters should match' {
                # Act
                $configuration = Get-DscConfiguration

                # Assert
                $configuration.Name | Should -Be $script:resourceWithServicePolicyOn.Name
                $configuration.Server | Should -Be $script:resourceWithServicePolicyOn.Server
                $configuration.Key | Should -Be $script:resourceWithServicePolicyOn.Key
                $configuration.Policy | Should -Be $script:resourceWithServicePolicyOn.Policy
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }
        }

        Context "When using configuration $($script:configWithServicePolicyOff)" {
            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithServicePolicyOff
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters
            }

            It 'Should compile and apply the MOF without throwing' {
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithServicePolicyOff
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Assert
                { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                # Assert
                { Get-DscConfiguration } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration and all the parameters should match' {
                # Act
                $configuration = Get-DscConfiguration

                # Assert
                $configuration.Name | Should -Be $script:resourceWithServicePolicyOff.Name
                $configuration.Server | Should -Be $script:resourceWithServicePolicyOff.Server
                $configuration.Key | Should -Be $script:resourceWithServicePolicyOff.Key
                $configuration.Policy | Should -Be $script:resourceWithServicePolicyOff.Policy
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }
        }

        Context "When using configuration $($script:configWithServicePolicyOnAndRunning)" {
            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithServicePolicyOnAndRunning
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters
            }

            It 'Should compile and apply the MOF without throwing' {
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithServicePolicyOnAndRunning
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Assert
                { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                # Assert
                { Get-DscConfiguration } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration and all the parameters should match' {
                # Act
                $configuration = Get-DscConfiguration

                # Assert
                $configuration.Name | Should -Be $script:resourceWithServicePolicyOnAndRunning.Name
                $configuration.Server | Should -Be $script:resourceWithServicePolicyOnAndRunning.Server
                $configuration.Key | Should -Be $script:resourceWithServicePolicyOnAndRunning.Key
                $configuration.Policy | Should -Be $script:resourceWithServicePolicyOnAndRunning.Policy
                $configuration.Running | Should -Be $script:resourceWithServicePolicyOnAndRunning.Running
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
