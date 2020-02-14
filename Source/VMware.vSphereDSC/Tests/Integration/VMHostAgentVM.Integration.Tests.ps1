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

# Retrieves the needed Datastore and Network from the Server. If there is no Datastore on the Server or no Network is available for the VMHost, it throws an error.
function Invoke-TestSetup {
    $viServer = Connect-VIServer -Server $Server -User $User -Password $Password
    $vmHost = Get-VMHost -Server $viServer -Name $Name

    $datastore = Get-Datastore -Server $viServer -RelatedObject $vmHost -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($null -eq $datastore) {
        throw "Integration Tests need one Datastore but no Datastore is found on the server $Server."
    }

    $network = $vmHost.ExtensionData.Network | Select-Object -First 1
    if ($null -eq $network) {
        throw "Integration Tests require Network but no Network is available for the VMHost $($vmHost.Name)."
    }

    $script:datastoreName = $datastore.Name
    $script:networkName = (Get-View -Server $viServer -Id $network).Name
}

Invoke-TestSetup

$script:dscResourceName = 'VMHostAgentVM'
$script:moduleFolderPath = (Get-Module 'VMware.vSphereDSC' -ListAvailable).ModuleBase
$script:integrationTestsFolderPath = Join-Path (Join-Path $moduleFolderPath 'Tests') 'Integration'
$script:configurationFile = "$script:integrationTestsFolderPath\Configurations\$($script:dscResourceName)\$($script:dscResourceName)_Config.ps1"

$script:configWhenAgentVmSettingsAreNotPassed = "$($script:dscResourceName)_WhenAgentVmSettingsAreNotPassed_Config"
$script:configWhenBothAgentVmSettingsArePassedAsNull = "$($script:dscResourceName)_WhenBothAgentVmSettingsArePassedAsNull_Config"
$script:configWhenOnlyAgentVmDatastoreIsPassed = "$($script:dscResourceName)_WhenOnlyAgentVmDatastoreIsPassed_Config"
$script:configWhenOnlyAgentVmNetworkIsPassed = "$($script:dscResourceName)_WhenOnlyAgentVmNetworkIsPassed_Config"
$script:configWhenBothAgentVmSettingsArePassed = "$($script:dscResourceName)_WhenBothAgentVmSettingsArePassed_Config"

. $script:configurationFile -Name $Name -Server $Server -User $User -Password $Password -Datastore $script:datastoreName -Network $script:networkName

$script:mofFileWhenAgentVmSettingsAreNotPassedPath = "$script:integrationTestsFolderPath\$($script:configWhenAgentVmSettingsAreNotPassed)\"
$script:mofFileWhenBothAgentVmSettingsArePassedAsNullPath = "$script:integrationTestsFolderPath\$($script:configWhenBothAgentVmSettingsArePassedAsNull)\"
$script:mofFileWhenOnlyAgentVmDatastoreIsPassedPath = "$script:integrationTestsFolderPath\$($script:configWhenOnlyAgentVmDatastoreIsPassed)\"
$script:mofFileWhenOnlyAgentVmNetworkIsPassedPath = "$script:integrationTestsFolderPath\$($script:configWhenOnlyAgentVmNetworkIsPassed)\"
$script:mofFileWhenBothAgentVmSettingsArePassedPath = "$script:integrationTestsFolderPath\$($script:configWhenBothAgentVmSettingsArePassed)\"

try {
    Describe "$($script:dscResourceName)_Integration" {
        Context "When using configuration $($script:configWhenAgentVmSettingsAreNotPassed)" {
            BeforeAll {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenAgentVmSettingsAreNotPassedPath
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
                    Path = $script:mofFileWhenAgentVmSettingsAreNotPassedPath
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

                <#
                In the Resource Implementation when setting the property value to $null,
                PowerShell converts it to an empty string, so the comparison should be against
                empty string instead of $null.
                #>
                $agentVmSettingEmptyValue = [string]::Empty

                $configuration.AgentVmDatastore | Should -Be $agentVmSettingEmptyValue
                $configuration.AgentVmNetwork | Should -Be $agentVmSettingEmptyValue
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }
        }

        Context "When using configuration $($script:configWhenBothAgentVmSettingsArePassedAsNull)" {
            BeforeAll {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenBothAgentVmSettingsArePassedAsNullPath
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
                    Path = $script:mofFileWhenBothAgentVmSettingsArePassedAsNullPath
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

                <#
                In the Resource Implementation when setting the property value to $null,
                PowerShell converts it to an empty string, so the comparison should be against
                empty string instead of $null.
                #>
                $agentVmSettingEmptyValue = [string]::Empty

                $configuration.AgentVmDatastore | Should -Be $agentVmSettingEmptyValue
                $configuration.AgentVmNetwork | Should -Be $agentVmSettingEmptyValue
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }
        }

        Context "When using configuration $($script:configWhenOnlyAgentVmDatastoreIsPassed)" {
            BeforeAll {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenOnlyAgentVmDatastoreIsPassedPath
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
                    Path = $script:mofFileWhenOnlyAgentVmDatastoreIsPassedPath
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

                <#
                In the Resource Implementation when setting the property value to $null,
                PowerShell converts it to an empty string, so the comparison should be against
                empty string instead of $null.
                #>
                $agentVmSettingEmptyValue = [string]::Empty

                $configuration.AgentVmDatastore | Should -Be $script:datastoreName
                $configuration.AgentVmNetwork | Should -Be $agentVmSettingEmptyValue
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }

            AfterAll {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenBothAgentVmSettingsArePassedAsNullPath
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters
            }
        }

        Context "When using configuration $($script:configWhenOnlyAgentVmNetworkIsPassed)" {
            BeforeAll {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenOnlyAgentVmNetworkIsPassedPath
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
                    Path = $script:mofFileWhenOnlyAgentVmNetworkIsPassedPath
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

                <#
                In the Resource Implementation when setting the property value to $null,
                PowerShell converts it to an empty string, so the comparison should be against
                empty string instead of $null.
                #>
                $agentVmSettingEmptyValue = [string]::Empty

                $configuration.AgentVmDatastore | Should -Be $agentVmSettingEmptyValue
                $configuration.AgentVmNetwork | Should -Be $script:networkName
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }

            AfterAll {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenBothAgentVmSettingsArePassedAsNullPath
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters
            }
        }

        Context "When using configuration $($script:configWhenBothAgentVmSettingsArePassed)" {
            BeforeAll {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenBothAgentVmSettingsArePassedPath
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
                    Path = $script:mofFileWhenBothAgentVmSettingsArePassedPath
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
                $configuration.AgentVmDatastore | Should -Be $script:datastoreName
                $configuration.AgentVmNetwork | Should -Be $script:networkName
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }

            AfterAll {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenBothAgentVmSettingsArePassedAsNullPath
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
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
