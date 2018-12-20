<#
Copyright (c) 2018 VMware, Inc.  All rights reserved				

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License 

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

using module VMware.vSphereDSC

$script:modulePath = $env:PSModulePath
$script:unitTestsFolder = Join-Path (Join-Path (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase 'Tests') 'Unit'
$script:mockModuleLocation = "$script:unitTestsFolder\TestHelpers"

$script:moduleName = 'VMware.vSphereDSC'
$script:resourceName = 'VMHostPowerPolicySettings'

$user = 'user'
$password = 'password' | ConvertTo-SecureString -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($user, $password)

$script:resourceProperties = @{
    Name = '10.23.82.112'
    Server = '10.23.82.112'
    Credential = $credential
    PowerPolicy = 2
}

Describe 'VMHostPowerPolicySettings' {
    BeforeAll {
        $env:PSModulePath = $script:mockModuleLocation
        $vimAutomationModule = Get-Module -Name VMware.VimAutomation.Core
        if ($null -ne $vimAutomationModule -and $vimAutomationModule.Path -NotMatch 'TestHelpers')
        {
            throw 'The Original VMware.VimAutomation.Core Module is loaded in the current session. If you want to run the unit tests please open a new PowerShell session.'
        }

        Import-Module -Name VMware.VimAutomation.Core
    }

    AfterAll {
        Remove-Module -Name VMware.VimAutomation.Core
        $env:PSModulePath = $script:modulePath
    }

    Describe 'VMHostPowerPolicySettings\Test' {
        AfterEach {
            $script:resourceProperties.PowerPolicy = 2
        }

        Context 'Invoking with default resource properties' {
            BeforeAll {
                # Arrange
                $viServer = [VMware.Vim.VIServer] @{ Name = '10.23.82.112'; User = 'user' }
                $vmhost = [VMware.Vim.VMHost] @{ Id = 'VMHostId' }
                
                $viServerMock = {
                    return [VMware.Vim.VIServer] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = { 
                    return [VMware.Vim.VMHost] @{ ExtensionData = [VMware.Vim.HostExtensionData] @{
                        Config = [VMware.Vim.HostConfig] @{
                            DateTimeInfo = [VMware.Vim.HostDateTimeConfig] @{
                                Id = 'HostDateTimeConfig'
                            };
                            Service = [VMware.Vim.HostServiceInfo] @{
                                Service = @(
                                    [VMware.Vim.HostService] @{
                                        Key = 'ntpd';
                                        Policy = 'automatic'
                                    }
                                )
                            };
                            PowerSystemInfo = [VMware.Vim.PowerSystemInfo] @{
                                CurrentPolicy = [VMware.Vim.HostPowerPolicy] @{
                                    Key = 2;
                                }
                            }
                        };
                        ConfigManager = [VMware.Vim.HostConfigManager] @{
                            ServiceSystem = [VMware.Vim.HostServiceSystem] @{
                                Id = 'HostServiceSystem'
                            }
                        }
                    } } 
                }
                
                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call the Connect-VIServer mock with the passed server and credentials once' {
                # Act
                $resource.Test()
    
                # Assert
                Assert-MockCalled -CommandName Connect-VIServer `
                                  -ParameterFilter { $Server -eq $script:resourceProperties.Server -and $Credential -eq $script:resourceProperties.Credential } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }
    
            It 'Should call Get-VMHost mock with the passed server and name once' {
                # Act
                $resource.Test()
    
                # Assert
                Assert-MockCalled -CommandName Get-VMHost `
                                  -ParameterFilter { $Server -eq $viServer -and $Name -eq $script:resourceProperties.Name } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should return $true as resource defaults to 2' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $true -Because ("[{0}] -eq [{1}]" -f $script:resourceProperties.PowerPolicy, $resource.PowerPolicy)
            }
        }

        Context 'Invoking with updated resource properties' {
            BeforeAll {
                # Arrange
                $viServer = [VMware.Vim.VIServer] @{ Name = '10.23.82.112'; User = 'user' }
                $vmhost = [VMware.Vim.VMHost] @{ Id = 'VMHostId' }
                
                $viServerMock = {
                    return [VMware.Vim.VIServer] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = { 
                    return [VMware.Vim.VMHost] @{ ExtensionData = [VMware.Vim.HostExtensionData] @{
                        Config = [VMware.Vim.HostConfig] @{
                            DateTimeInfo = [VMware.Vim.HostDateTimeConfig] @{
                                Id = 'HostDateTimeConfig'
                            };
                            Service = [VMware.Vim.HostServiceInfo] @{
                                Service = @(
                                    [VMware.Vim.HostService] @{
                                        Key = 'ntpd';
                                        Policy = 'automatic'
                                    }
                                )
                            };
                            PowerSystemInfo = [VMware.Vim.PowerSystemInfo] @{
                                CurrentPolicy = [VMware.Vim.HostPowerPolicy] @{
                                    Key = 1;
                                }
                            }
                        };
                        ConfigManager = [VMware.Vim.HostConfigManager] @{
                            ServiceSystem = [VMware.Vim.HostServiceSystem] @{
                                Id = 'HostServiceSystem'
                            }
                        }
                    } } 
                }
                
                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should return $false as mock policy is changed to 1' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $false -Because ("[{0}] -ne [{1}]" -f $script:resourceProperties.PowerPolicy, $resource.PowerPolicy)
            }
        }

        Context 'Invoking with updated resource but equal policy' {
            BeforeAll {
                # Arrange
                $viServer = [VMware.Vim.VIServer] @{ Name = '10.23.82.112'; User = 'user' }
                $vmhost = [VMware.Vim.VMHost] @{ Id = 'VMHostId' }
                
                $viServerMock = {
                    return [VMware.Vim.VIServer] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = { 
                    return [VMware.Vim.VMHost] @{ ExtensionData = [VMware.Vim.HostExtensionData] @{
                        Config = [VMware.Vim.HostConfig] @{
                            DateTimeInfo = [VMware.Vim.HostDateTimeConfig] @{
                                Id = 'HostDateTimeConfig'
                            };
                            Service = [VMware.Vim.HostServiceInfo] @{
                                Service = @(
                                    [VMware.Vim.HostService] @{
                                        Key = 'ntpd';
                                        Policy = 'automatic'
                                    }
                                )
                            };
                            PowerSystemInfo = [VMware.Vim.PowerSystemInfo] @{
                                CurrentPolicy = [VMware.Vim.HostPowerPolicy] @{
                                    Key = 2;
                                }
                            }
                        };
                        ConfigManager = [VMware.Vim.HostConfigManager] @{
                            ServiceSystem = [VMware.Vim.HostServiceSystem] @{
                                Id = 'HostServiceSystem'
                            }
                        }
                    } } 
                }
                
                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should return $true as mock policy is changed to 2' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $true -Because ("[{0}] -ne [{1}]" -f $script:resourceProperties.PowerPolicy, $resource.PowerPolicy)
            }
        }
    }

    Describe 'VMHostPowerPolicySettings\Get' {
        AfterEach {
            $script:resourceProperties.PowerPolicy = 2
        }

        Context 'Invoking with default resource properties' {
            BeforeAll {
                # Arrange
                $viServer = [VMware.Vim.VIServer] @{ Name = '10.23.82.112'; User = 'user' }
                $vmhost = [VMware.Vim.VMHost] @{ Id = 'VMHostId' }
                
                $viServerMock = {
                    return [VMware.Vim.VIServer] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = { 
                    return [VMware.Vim.VMHost] @{ ExtensionData = [VMware.Vim.HostExtensionData] @{
                        Config = [VMware.Vim.HostConfig] @{
                            DateTimeInfo = [VMware.Vim.HostDateTimeConfig] @{
                                Id = 'HostDateTimeConfig'
                            };
                            Service = [VMware.Vim.HostServiceInfo] @{
                                Service = @(
                                    [VMware.Vim.HostService] @{
                                        Key = 'ntpd';
                                        Policy = 'automatic'
                                    }
                                )
                            };
                            PowerSystemInfo = [VMware.Vim.PowerSystemInfo] @{
                                CurrentPolicy = [VMware.Vim.HostPowerPolicy] @{
                                    Key = 2;
                                }
                            }
                        };
                        ConfigManager = [VMware.Vim.HostConfigManager] @{
                            ServiceSystem = [VMware.Vim.HostServiceSystem] @{
                                Id = 'HostServiceSystem'
                            }
                        }
                    } } 
                }
                
                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call the Connect-VIServer mock with the passed server and credentials once' {
                # Act
                $resource.Get()
    
                # Assert
                Assert-MockCalled -CommandName Connect-VIServer `
                                  -ParameterFilter { $Server -eq $script:resourceProperties.Server -and $Credential -eq $script:resourceProperties.Credential } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }
    
            It 'Should call Get-VMHost mock with the passed server and name once' {
                # Act
                $resource.Get()
    
                # Assert
                Assert-MockCalled -CommandName Get-VMHost `
                                  -ParameterFilter { $Server -eq $viServer -and $Name -eq $script:resourceProperties.Name } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should return the resource with the properties passed from the server' {
                # Act
                $result = $resource.Get()

                # Assert
                $result.Name | Should -Be $script:resourceProperties.Name
                $result.Server | Should -Be $script:resourceProperties.Server

                $result.PowerPolicy | Should -Be 2
            }
        }
    }
}