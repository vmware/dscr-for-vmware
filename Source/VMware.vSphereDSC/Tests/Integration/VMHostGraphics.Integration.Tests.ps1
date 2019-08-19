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

# Retrieves the Id of the first Graphics Device in the DeviceType array of the Graphics Configuration. If there are no Graphics Devices, it throws an error.
function Invoke-TestSetup {
    $viServer = Connect-VIServer -Server $Server -User $User -Password $Password
    $vmHost = Get-VMHost -Server $viServer -Name $Name
    $graphicsManager = Get-View -Server $viServer -Id $vmHost.ExtensionData.ConfigManager.GraphicsManager

    $graphicsDevice = $graphicsManager.GraphicsConfig.DeviceType | Select-Object -First 1
    if ($null -eq $graphicsDevice) {
        throw "No Graphics Device found on the server $Server."
    }

    $script:graphicsDeviceId = $graphicsDevice.DeviceId
}

Invoke-TestSetup

$script:dscResourceName = 'VMHostGraphics'
$script:moduleFolderPath = (Get-Module 'VMware.vSphereDSC' -ListAvailable).ModuleBase
$script:integrationTestsFolderPath = Join-Path (Join-Path $moduleFolderPath 'Tests') 'Integration'
$script:configurationFile = "$script:integrationTestsFolderPath\Configurations\$($script:dscResourceName)\$($script:dscResourceName)_Config.ps1"

$script:configWhenGraphicsDeviceIsNotPassed = "$($script:dscResourceName)_WhenGraphicsDeviceIsNotPassed_Config"
$script:configWhenGraphicsDeviceIsPassed = "$($script:dscResourceName)_WhenGraphicsDeviceIsPassed_Config"

. $script:configurationFile -Name $Name -Server $Server -User $User -Password $Password -GraphicsDeviceId $script:graphicsDeviceId

$script:mofFileWhenGraphicsDeviceIsNotPassedPath = "$script:integrationTestsFolderPath\$($script:configWhenGraphicsDeviceIsNotPassed)\"
$script:mofFileWhenGraphicsDeviceIsPassedPath = "$script:integrationTestsFolderPath\$($script:configWhenGraphicsDeviceIsPassed)\"

try {
    Describe "$($script:dscResourceName)_Integration" {
        Context "When using configuration $($script:configWhenGraphicsDeviceIsNotPassed)" {
            BeforeAll {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenGraphicsDeviceIsNotPassedPath
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
                    Path = $script:mofFileWhenGraphicsDeviceIsNotPassedPath
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
                $configuration.DefaultGraphicsType | Should -Be $script:sharedGraphicsType
                $configuration.SharedPassthruAssignmentPolicy | Should -Be $script:performanceSharedPassthruAssignmentPolicy

                <#
                In the Resource Implementation when setting the property value to $null,
                PowerShell converts it to an empty string, so the comparison should be against
                empty string instead of $null.
                #>
                $deviceIdEmptyValue = [string]::Empty

                $configuration.DeviceId | Should -Be $deviceIdEmptyValue
                $configuration.DeviceGraphicsType | Should -Be 'Unset'
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration -Verbose | Should -Be $true
            }
        }

        Context "When using configuration $($script:configWhenGraphicsDeviceIsPassed)" {
            BeforeAll {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenGraphicsDeviceIsPassedPath
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
                    Path = $script:mofFileWhenGraphicsDeviceIsPassedPath
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
                $configuration.DefaultGraphicsType | Should -Be $script:sharedDirectGraphicsType
                $configuration.SharedPassthruAssignmentPolicy | Should -Be $script:consolidationSharedPassthruAssignmentPolicy
                $configuration.DeviceId | Should -Be $script:graphicsDeviceId
                $configuration.DeviceGraphicsType | Should -Be $script:sharedGraphicsType
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration -Verbose | Should -Be $true
            }

            AfterAll {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenGraphicsDeviceIsNotPassedPath
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
