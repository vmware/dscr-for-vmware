<#
Desired State Configuration Resources for VMware

Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

$root = Split-Path (Split-Path $PSScriptRoot)

$module = Join-Path $root 'VMware.PSDesiredStateConfiguration.psd1'

Import-Module $module -Force

InModuleScope -ModuleName 'VMware.PSDesiredStateConfiguration' {
    Describe 'Invoke-VmwDscConfiguration integration tests' {
        try {
            $root = $PSScriptRoot
            $serverConfigPath = Join-Path $root 'ServerConfig.ps1'
    
            # server data is retrieved from a ServerConfig.ps1 file
            $serverConfigs = . $serverConfigPath
    
            foreach ($serverConfig in $serverConfigs) {
                # establish connection to the vCenter
                $Script:Connection = Connect-ViServer -Server $serverConfig.Server -User $serverConfig.User -Password $serverConfig.Password
            }
    
            $Script:ConfigData = @{
                AllNodes = @(
                    foreach ($serverConfig in $serverConfigs) {
                        @{
                            NodeName = $serverConfig.Server
                        }
                    }
                )
                DatacenterFolder = @{
                    Name = 'MyDatacentersFolder'
                    Location = ''
                }
                Datacenter = @{
                    Name = 'MyDatacenter'
                    Location = 'MyDatacentersFolder'
                }
            }
    
            $root = $PSScriptRoot
    
            $configFolder = Join-Path $root 'Configurations'
    
            $Script:ConfigPath = Join-Path $configFolder 'vSphereNodeConfiguration.ps1'
    
            $Script:DscConfigurationObj = $null
    
            It 'Should compile correctly' {
                # Arrange
                $splatParams = @{
                    ConfigName = 'Config_Add'
                    ConfigurationData = $Script:ConfigData
                }
    
                . $Script:ConfigPath
    
                # Act
                $Script:DscConfigurationObj = New-VmwDscConfiguration @splatParams
    
                # Assert
                $Script:DscConfigurationObj | Should -Not -Be $null
            }
    
            It 'Should apply the Configuration without throwing' {
                # Assert
                { Start-VmwDscConfiguration $Script:DscConfigurationObj } | Should -Not -Throw
            }
    
            It 'Should be able to call Get-VmwDscConfiguration without throwing' {
                # Assert
                { Get-VmwDscConfiguration $Script:DscConfigurationObj } | Should -Not -Throw
            }
    
            It 'Should return $true when Test-VmwDscConfiguration is run' {
                # Assert
                Test-VmwDscConfiguration $Script:DscConfigurationObj | Should -Contain $true
            }
    
            It 'Should return correct object when Test-VmwDscConfiguration is run with -Detailed flag' {
                # Act
                $nodeResults = Test-VmwDscConfiguration $Script:DscConfigurationObj -Detailed
    
                foreach($res in $nodeResults) {
                    # Assert
                    $res.InDesiredState | Should -Be $true
                    $res.ResourcesInDesiredState.Count | Should -Be 2
                    $res.ResourcesNotInDesiredState.Count | Should -Be 0
                }
            }
    
            It 'Should be able to call Get-VmwDscConfiguration and all parameters should match' {
                # Act
                $nodeResults = Get-VmwDscConfiguration $Script:DscConfigurationObj
    
                foreach($res in $nodeResults) {
                    # Assert
                    $res.ResourcesStates[0].Name | Should -Be $Script:ConfigData.DatacenterFolder.Name
                    $res.ResourcesStates[0].Location | Should -Be $Script:ConfigData.DatacenterFolder.Location
    
                    $res.ResourcesStates[1].Name | Should -Be $Script:ConfigData.Datacenter.Name
                    $res.ResourcesStates[1].Location | Should -Be $Script:ConfigData.Datacenter.Location
                }
            }
    
            It 'Should execute current configuration with -ExecuteLastConfiguration flag on Test-VmwDscConfiguration' {
                # Assert
                Test-VmwDscConfiguration -ExecuteLastConfiguration | Should -Contain $true
            }
    
            It 'Should execute current configuration with -ExecuteLastConfiguration flag on Get-VmwDscConfiguration' {
                # Act
                $nodeResults = Get-VmwDscConfiguration -ExecuteLastConfiguration
    
                foreach($res in $nodeResults) {
                    # Assert
                    $res.ResourcesStates[0].Name | Should -Be $Script:ConfigData.DatacenterFolder.Name
                    $res.ResourcesStates[0].Location | Should -Be $Script:ConfigData.DatacenterFolder.Location
    
                    $res.ResourcesStates[1].Name | Should -Be $Script:ConfigData.Datacenter.Name
                    $res.ResourcesStates[1].Location | Should -Be $Script:ConfigData.Datacenter.Location
                }
            }

            It 'Should execute only on a single node with -ConnectionFilter param' {
                # Assert
                Test-VmwDscConfiguration $Script:DscConfigurationObj -ConnectionFilter $Script:DscConfigurationObj.Nodes[0].InstanceName | Should -Be $true
            }
        } finally {
            # cleanup changes

            $splatParams = @{
                ConfigName = 'Config_Remove'
                ConfigurationData = $Script:ConfigData
            }

            . $Script:ConfigPath

            $Script:DscConfigurationCleanObj = New-VmwDscConfiguration @splatParams

            $Script:DscConfigurationCleanObj | Start-VmwDscConfiguration
        }
    }
}
