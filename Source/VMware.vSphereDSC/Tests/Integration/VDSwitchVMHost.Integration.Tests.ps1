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

    [Parameter(Mandatory = $true)]
    [string]
    $Name
)

# Mandatory Integration Tests parameter is not used so it is set to $null.
$Name = $null

<#
Retrieves the VMHosts on the specified server.
If there are no VMHosts or if there is only one VMHost on the specified server, it throws an exception.
#>
function Invoke-TestSetup {
    $viServer = Connect-VIServer -Server $Server -User $User -Password $Password -ErrorAction Stop
    $vmHosts = Get-VMHost -Server $viServer -ErrorAction SilentlyContinue

    if ($null -eq $vmHosts -or $vmHosts.Length -lt 2) {
        throw "The Integration Tests require at least 2 VMHosts to be available on the specified server."
    }

    $script:vmHost1 = $vmHosts[0].Name
    $script:vmHost2 = $vmHosts[1].Name
}

Invoke-TestSetup

$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (ConvertTo-SecureString -String $Password -AsPlainText -Force)

$script:dscResourceName = 'VDSwitchVMHost'
$script:moduleFolderPath = (Get-Module -Name 'VMware.vSphereDSC' -ListAvailable).ModuleBase
$script:integrationTestsFolderPath = Join-Path -Path (Join-Path -Path $moduleFolderPath -ChildPath 'Tests') -ChildPath 'Integration'
$script:configurationFile = "$script:integrationTestsFolderPath\Configurations\$script:dscResourceName\$($script:dscResourceName)_Config.ps1"

$script:configurationData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
            Server = $Server
            Credential = $Credential
            DistributedSwitchResourceName = 'DistributedSwitch'
            DistributedSwitchVMHostResourceName = 'DistributedSwitchVMHost'
            DatacenterName = 'Datacenter'
            DatacenterLocation = [string]::Empty
            DistributedSwitchName = 'MyTestDistributedSwitch'
            Location = [string]::Empty
            VMHostNames = @($script:vmHost1, $script:vmHost2, '0.0.0.0')
            ValidVMHostNames = @($script:vmHost1, $script:vmHost2)
        }
    )
}

$script:configWhenAddingDistributedSwitch = "$($script:dscResourceName)_WhenAddingDistributedSwitch_Config"
$script:configWhenAddingVMHostsToDistributedSwitch = "$($script:dscResourceName)_WhenAddingVMHostsToDistributedSwitch_Config"
$script:configWhenRemovingVMHostsFromDistributedSwitch = "$($script:dscResourceName)_WhenRemovingVMHostsFromDistributedSwitch_Config"
$script:configWhenRemovingDistributedSwitch = "$($script:dscResourceName)_WhenRemovingDistributedSwitch_Config"

. $script:configurationFile -ErrorAction Stop

$script:mofFileWhenAddingDistributedSwitchPath = "$script:integrationTestsFolderPath\$script:configWhenAddingDistributedSwitch\"
$script:mofFileWhenAddingVMHostsToDistributedSwitchPath = "$script:integrationTestsFolderPath\$script:configWhenAddingVMHostsToDistributedSwitch\"
$script:mofFileWhenRemovingVMHostsFromDistributedSwitchPath = "$script:integrationTestsFolderPath\$script:configWhenRemovingVMHostsFromDistributedSwitch\"
$script:mofFileWhenRemovingDistributedSwitchPath = "$script:integrationTestsFolderPath\$script:configWhenRemovingDistributedSwitch\"

try {
    Describe "$($script:dscResourceName)_Integration" {
        Context "When using configuration $script:configWhenAddingVMHostsToDistributedSwitch" {
            BeforeAll {
                # Arrange
                & $script:configWhenAddingDistributedSwitch `
                    -OutputPath $script:mofFileWhenAddingDistributedSwitchPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                & $script:configWhenAddingVMHostsToDistributedSwitch `
                    -OutputPath $script:mofFileWhenAddingVMHostsToDistributedSwitchPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                $startDscConfigurationParametersWhenAddingDistributedSwitch = @{
                    Path = $script:mofFileWhenAddingDistributedSwitchPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                $startDscConfigurationParametersWhenAddingVMHostsToDistributedSwitch = @{
                    Path = $script:mofFileWhenAddingVMHostsToDistributedSwitchPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParametersWhenAddingDistributedSwitch
                Start-DscConfiguration @startDscConfigurationParametersWhenAddingVMHostsToDistributedSwitch
            }

            It 'Should apply the MOF without throwing' {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenAddingVMHostsToDistributedSwitchPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
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
                $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configWhenAddingVMHostsToDistributedSwitch }

                # Assert
                $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
                $configuration.VdsName | Should -Be $script:configurationData.AllNodes.DistributedSwitchName
                $configuration.VMHostNames | Should -Be $script:configurationData.AllNodes.ValidVMHostNames
                $configuration.Ensure | Should -Be 'Present'
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange
                $testDscConfigurationParameters = @{
                    ReferenceConfiguration = "$script:mofFileWhenAddingVMHostsToDistributedSwitchPath\$($script:configurationData.AllNodes.NodeName).mof"
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act && Assert
                (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
            }

            AfterAll {
                # Arrange
                & $script:configWhenRemovingDistributedSwitch `
                    -OutputPath $script:mofFileWhenRemovingDistributedSwitchPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenRemovingDistributedSwitchPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters

                Remove-Item -Path $script:mofFileWhenAddingDistributedSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
                Remove-Item -Path $script:mofFileWhenAddingVMHostsToDistributedSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
                Remove-Item -Path $script:mofFileWhenRemovingDistributedSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            }
        }

        Context "When using configuration $script:configWhenRemovingVMHostsFromDistributedSwitch" {
            BeforeAll {
                # Arrange
                & $script:configWhenAddingDistributedSwitch `
                    -OutputPath $script:mofFileWhenAddingDistributedSwitchPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                & $script:configWhenAddingVMHostsToDistributedSwitch `
                    -OutputPath $script:mofFileWhenAddingVMHostsToDistributedSwitchPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                & $script:configWhenRemovingVMHostsFromDistributedSwitch `
                    -OutputPath $script:mofFileWhenRemovingVMHostsFromDistributedSwitchPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                $startDscConfigurationParametersWhenAddingDistributedSwitch = @{
                    Path = $script:mofFileWhenAddingDistributedSwitchPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                $startDscConfigurationParametersWhenAddingVMHostsToDistributedSwitch = @{
                    Path = $script:mofFileWhenAddingVMHostsToDistributedSwitchPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                $startDscConfigurationParametersWhenRemovingVMHostsFromDistributedSwitch = @{
                    Path = $script:mofFileWhenRemovingVMHostsFromDistributedSwitchPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParametersWhenAddingDistributedSwitch
                Start-DscConfiguration @startDscConfigurationParametersWhenAddingVMHostsToDistributedSwitch
                Start-DscConfiguration @startDscConfigurationParametersWhenRemovingVMHostsFromDistributedSwitch
            }

            It 'Should apply the MOF without throwing' {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenRemovingVMHostsFromDistributedSwitchPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
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
                $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configWhenRemovingVMHostsFromDistributedSwitch }

                # Assert
                $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
                $configuration.VdsName | Should -Be $script:configurationData.AllNodes.DistributedSwitchName
                $configuration.VMHostNames | Should -Be $script:configurationData.AllNodes.ValidVMHostNames
                $configuration.Ensure | Should -Be 'Absent'
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange
                $testDscConfigurationParameters = @{
                    ReferenceConfiguration = "$script:mofFileWhenRemovingVMHostsFromDistributedSwitchPath\$($script:configurationData.AllNodes.NodeName).mof"
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act && Assert
                (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
            }

            AfterAll {
                # Arrange
                & $script:configWhenRemovingDistributedSwitch `
                    -OutputPath $script:mofFileWhenRemovingDistributedSwitchPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenRemovingDistributedSwitchPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters

                Remove-Item -Path $script:mofFileWhenAddingDistributedSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
                Remove-Item -Path $script:mofFileWhenAddingVMHostsToDistributedSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
                Remove-Item -Path $script:mofFileWhenRemovingVMHostsFromDistributedSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
                Remove-Item -Path $script:mofFileWhenRemovingDistributedSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            }
        }
    }
}
finally {
    Disconnect-VIServer -Server $Server -Confirm:$false
}
