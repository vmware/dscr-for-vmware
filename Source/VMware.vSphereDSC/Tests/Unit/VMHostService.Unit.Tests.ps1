<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

Using module '..\..\VMware.vSphereDSC.psm1'

$script:modulePath = $env:PSModulePath
$script:unitTestsFolder = Join-Path (Join-Path (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase 'Tests') 'Unit'
$script:mockModuleLocation = "$script:unitTestsFolder\TestHelpers"

$script:moduleName = 'VMware.vSphereDSC'
$script:resourceName = 'VMHostService'

$user = 'user'
$password = 'password' | ConvertTo-SecureString -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($user, $password)

$script:resourceProperties = @{
    Name = '10.23.82.112'
    Server = '10.23.82.112'
    Credential = $credential
    Key = 'TSM-SSH'
    Policy = 'Unset'
    Running = $false
    Label = 'SSH'
    Required = $false
    RuleSet = @('Rule1', 'Rule2')
}

function Invoke-TestSetup {
    $env:PSModulePath = $script:mockModuleLocation
    $vimAutomationModule = Get-Module -Name VMware.VimAutomation.Core
    if ($null -ne $vimAutomationModule -and $vimAutomationModule.Path -NotMatch 'TestHelpers') {
        throw 'The Original VMware.VimAutomation.Core Module is loaded in the current session. If you want to run the unit tests please open a new PowerShell session.'
    }

    Import-Module -Name VMware.VimAutomation.Core
}

function Invoke-TestCleanup {
    Remove-Module -Name VMware.VimAutomation.Core
    $env:PSModulePath = $script:modulePath
}

try {
    # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
    Invoke-TestSetup

    Describe 'VMHostService\Set' -Tag 'Set' {
        AfterEach {
            $script:resourceProperties.Key = [string]::Empty
            $script:resourceProperties.Policy = 'Unset'
            $script:resourceProperties.Running = $false
        }

        Context 'Invoking with empty settings' {
            BeforeAll {
                # Arrange
                $viServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                $retrievedVMHost = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId' }
                $vmHostService = [VMware.VimAutomation.ViCore.Impl.V1.Host.HostServiceImpl] @{ Key = 'TSM-SSH'}

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId' }
                }
                $vmHostService = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Host.HostServiceImpl] @{ Key = 'TSM-SSH'; Policy = 'Off'; Running = $false }
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHostService -MockWith $vmHostService -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call the Connect-VIServer mock with the passed server and credentials once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Connect-VIServer `
                    -ParameterFilter { $Server -eq $script:resourceProperties.Server -and $Credential -eq $script:resourceProperties.Credential } `
                    -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call Get-VMHost mock with the passed server and name once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Get-VMHost `
                    -ParameterFilter { $Server -eq $viServer -and $Name -eq $script:resourceProperties.Name } `
                    -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call Get-VMHostService mock with the passed server and vmhost once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Get-VMHostService `
                    -ParameterFilter { $Server -eq $viServer -and $VMHost -eq $retrievedVMHost } `
                    -ModuleName $script:moduleName -Exactly 1 -Scope It
            }
        }

        Context 'Invoking with VMHostService To Update Policy' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Key = 'TSM-SSH'
                $script:resourceProperties.Policy = 'On'
                $script:resourceProperties.Running = $true

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }

                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId' }
                }

                $getServiceSettingsMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Host.HostServiceImpl] @{Key = 'TSM-SSH'; Policy = 'Off'; Running = $false}
                }

                $setServiceSettingMock = {
                    return $null
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHostService -MockWith $getServiceSettingsMock -ModuleName $script:moduleName
                Mock -CommandName Set-VMHostService -MockWith $setServiceSettingMock -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call Set-VMHostService for service Policy that needs to be updated' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Set-VMHostService `
                    -ParameterFilter { $HostService.Key -eq $script:resourceProperties.Key -and $Policy -eq $script:resourceProperties.Policy } `
                    -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

        }

        Context 'Invoking with VMHostService To start service' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Key = 'TSM-SSH'
                $script:resourceProperties.Policy = 'On'
                $script:resourceProperties.Running = $true

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }

                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId' }
                }

                $getServiceSettingsMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Host.HostServiceImpl] @{Key = 'TSM-SSH'; Policy = 'On'; Running = $false}
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHostService -MockWith $getServiceSettingsMock -ModuleName $script:moduleName
                Mock -CommandName Start-VMHostService -MockWith { return $null} -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call Start-VMHostService once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Start-VMHostService `
                    -ParameterFilter { $HostService.Key -eq $script:resourceProperties.Key } `
                    -ModuleName $script:moduleName -Exactly 1 -Scope It
            }
        }

        Context 'Invoking with VMHostService To stop service' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Key = 'TSM-SSH'
                $script:resourceProperties.Policy = 'On'
                $script:resourceProperties.Running = $false

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }

                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId' }
                }

                $getServiceSettingsMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Host.HostServiceImpl] @{Key = 'TSM-SSH'; Policy = 'On'; Running = $true}
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHostService -MockWith $getServiceSettingsMock -ModuleName $script:moduleName
                Mock -CommandName Stop-VMHostService -MockWith { return $null} -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call Stop-VMHostService once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Stop-VMHostService `
                    -ParameterFilter { $HostService.Key -eq $script:resourceProperties.Key } `
                    -ModuleName $script:moduleName -Exactly 1 -Scope It
            }
        }

        Context 'Invoking without Advanced Settings To Update' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Key = 'TSM-SSH'
                $script:resourceProperties.Policy = 'On'
                $script:resourceProperties.Running = $false

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }

                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId' }
                }

                $serviceSettingsMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Host.HostServiceImpl] @{Key = 'TSM-SSH'; Policy = 'On'; Running = $false}
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHostService -MockWith $serviceSettingsMock -ModuleName $script:moduleName
                Mock -CommandName Set-VMHostService -MockWith { return $null } -ModuleName $script:moduleName
                Mock -CommandName Start-VMHostService -MockWith { return $null } -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should not call Set-VMHostService for each setting that does not need to be updated' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Set-VMHostService `
                    -ParameterFilter { $HostService.Key -eq $script:resourceProperties.Key -and !$Confirm } `
                    -ModuleName $script:moduleName -Exactly 0 -Scope It
            }
            It 'Should not call Start-VMHostService for each setting that does not need to be updated' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Start-VMHostService `
                    -ParameterFilter { $HostService.Key -eq $script:resourceProperties.Key -and !$Confirm } `
                    -ModuleName $script:moduleName -Exactly 0 -Scope It
            }
        }
    }

    Describe 'VMHostService\Test' -Tag 'Test' {
        AfterEach {
            $script:resourceProperties.Key = [string]::Empty
            $script:resourceProperties.Policy = 'Unset'
            $script:resourceProperties.Running = [bool]::FalseString
        }

        Context 'Invoking with default resource properties' {
            BeforeAll {
                # Arrange
                $viServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                $retrievedVMHost = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId' }
                $vmHostService = [VMware.VimAutomation.ViCore.Impl.V1.Host.HostServiceImpl] @{ Key = 'TSM-SSH'}

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user'}
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId'}
                }
                $serviceSettingsMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Host.HostServiceImpl] @{Key = 'TSM-SSH'; Policy = 'On'; Running = $false }
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHostService -MockWith $serviceSettingsMock -ModuleName $script:moduleName
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

            It 'Should call Get-VMHostService mock with the passed server and vmhost once' {
                # Act
                $resource.Test()

                # Assert
                Assert-MockCalled -CommandName Get-VMHostService `
                    -ParameterFilter { $Server -eq $viServer -and $VMHost -eq $retrievedVMHost } `
                    -ModuleName $script:moduleName -Exactly 1 -Scope It
            }
        }

        Context 'Invoking with equal VMHostService settings' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Key = 'TSM-SSH'
                $script:resourceProperties.Policy = 'Automatic'
                $script:resourceProperties.Running = [bool]::TrueString

                $viServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                $retrievedVMHost = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId' }

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId' }
                }

                $serviceSettingsMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Host.HostServiceImpl] @{
                        Key = 'TSM-SSH'
                        Policy = 'On'
                        Running = $true
                    }
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHostService -MockWith $serviceSettingsMock -ModuleName $script:moduleName
                Mock -CommandName Set-VMHostService -MockWith { return $null } -ModuleName $script:moduleName
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

            It 'Should call Get-VMHostService mock with the passed server and vCenter once' {
                # Act
                $resource.Test()

                # Assert
                Assert-MockCalled -CommandName Get-VMHostService `
                    -ParameterFilter { $Server -eq $viServer -and $VMHost -eq $retrievedVMHost } `
                    -ModuleName $script:moduleName -Exactly 1 -Scope It
            }
        }

        Context 'Invoking with Advanced Settings To Update' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Key = 'TSM-SSH'
                $script:resourceProperties.Policy = 'On'
                $script:resourceProperties.Running = $true

                $viServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                $retrievedVMHost = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId' }

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId' }
                }
                $vmhostServiceMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Host.HostServiceImpl] @{
                        Key = 'TSM-SSH'
                        Policy = 'Unset'
                        Running = $false
                    }
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHostService -MockWith $vmhostServiceMock -ModuleName $script:moduleName
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

            It 'Should call Get-VMHostService mock with the passed server and vCenter once' {
                # Act
                $resource.Test()

                # Assert
                Assert-MockCalled -CommandName Get-VMHostService `
                    -ParameterFilter { $Server -eq $viServer -and $VMHost -eq $retrievedVMHost } `
                    -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should return $false on Test' {
                $resource.Test() | Should be $false
            }
        }
    }

    Describe 'VMHostService\Get' -Tag 'Get' {
        AfterAll {
            $script:resourceProperties.Key = [string]::Empty
            $script:resourceProperties.Policy = 'Unset'
            $script:resourceProperties.Running = [bool]::FalseString
        }

        Context 'Invoking with default resource properties' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Key = 'TSM-SSH'

                $viServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                $retrievedVMHost = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Name = '10.23.82.112'; Id = 'VMHostId' }

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Name = '10.23.82.112'; Id = 'VMHostId' }
                }
                $vmhostServiceMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Host.HostServiceImpl] @{
                        Key = 'TSM-SSH'
                        Label = 'SSH'
                        Policy = 'Automatic'
                        Running = $script:resourceProperties.Running
                        Required = $script:resourceProperties.Required
                        Ruleset = @('Rule1', 'Rule2')
                    }
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHostService -MockWith $vmhostServiceMock -ModuleName $script:moduleName
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

            It 'Should call Get-VMHostService mock with the passed server and vCenter once' {
                # Act
                $resource.Get()

                # Assert
                Assert-MockCalled -CommandName Get-VMHostService `
                    -ParameterFilter { $Server -eq $viServer -and $VMHost -eq $retrievedVMHost } `
                    -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should match the properties retrieved from the server' {
                # Act
                $result = $resource.Get()

                # Assert
                $result.Name | Should -Be $retrievedVMHost.Name
                $result.Server | Should -Be $viServer.Name
                $result.Key | Should -Be $script:resourceProperties.Key
                $result.Policy | Should -Be 'Automatic'
                $result.Running | Should -Be $script:resourceProperties.Running.ToString()
                $result.Label | Should -Be $script:resourceProperties.Label
                $result.Required | Should -Be $script:resourceProperties.Required.ToString()
                ($result.Ruleset | ConvertTo-Json) | Should -Be ($script:resourceProperties.RuleSet | ConvertTo-Json)
            }
        }
    }
}
finally {
    # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
    Invoke-TestCleanup
}
