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
$script:resourceName = 'VMHostSyslog'

$user = 'user'
$password = 'password' | ConvertTo-SecureString -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($user, $password)

$script:resourceProperties = @{
    Name = '10.23.82.112'
    Server = '10.23.82.112'
    Credential = $credential
    LogHost = 'udp://vli.local.lab:514'
    CheckSslCerts = $true
    DefaultRotate = 10
    DefaultSize = 100
    DefaultTimeout = 180
    DropLogRotate = 10
    DropLogSize = 100
    LogDir = '/scratch/log'
    LogDirUnique = $false
    QueueDropMark = 90
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

    Describe 'VMHostSyslog\Set' -Tag 'Set' {
        Context 'Invoking with syslog not configured' {
            BeforeAll {
                $viServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                $retrievedVMHost = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId' }

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId' }
                }
                $esxCliMock = {
                    $esxcli = New-Object PSObject
                    $esxcli | Add-Member -MemberType NoteProperty -Name 'VMHost' -Value (New-Object psobject)
                    $esxcli.VMHost | Add-Member -MemberType NoteProperty -Name 'Id' -Value 'VMHostId'
                    $esxcli | Add-Member -MemberType NoteProperty -Name 'system' -Value (New-Object PSObject)
                    $esxcli.system | Add-Member -MemberType NoteProperty -Name 'syslog' -Value (New-Object PSObject)
                    $esxcli.system.syslog | Add-Member -MemberType NoteProperty -Name 'config' -Value (New-Object PSObject)
                    $esxcli.system.syslog.config | Add-Member -MemberType NoteProperty -Name 'get' -Value (New-Object PSObject)
                    $esxcli.system.syslog.config | Add-Member -MemberType NoteProperty -Name 'set' -Value (New-Object PSObject)

                    $syslogConfig = [VMware.Vim.SyslogConfig]::new()

                    $esxcli.system.syslog.config.get | Add-Member -MemberType ScriptMethod -Name 'Invoke' -Value { $syslogConfig }
                    $esxcli.system.syslog.config.set | Add-Member -MemberType ScriptMethod -Name 'Invoke' -Value { $true }

                    return $esxcli
                }
                $getSyslogConfigMock = {
                    return $syslogConfig
                }
                $setSyslogConfigMock = {
                    return $true
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName Get-EsxCli -MockWith $esxCliMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHostSyslogConfig -MockWith $getSyslogConfigMock -ModuleName $script:moduleName
                Mock -CommandName Set-VMHostSyslogConfig -MockWith $setSyslogConfigMock -ModuleName $script:moduleName
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

            It 'Should call Get-EsxCli mock once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Get-EsxCli `
                    -ParameterFilter { $Server -eq $viServer -and $VMHost -eq $retrievedVMHost -and $V2 } `
                    -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should not call Get-VMHostSyslogConfig mock' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Get-VMHostSyslogConfig `
                    -ModuleName $script:moduleName -Exactly 0 -Scope It
            }

            It 'Should call Set-VMHostSyslogConfig mock once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Set-VMHostSyslogConfig `
                    -ParameterFilter { $VMHostSyslogConfig.LogHost -eq $script:resourceProperties.LogHost  } `
                    -ModuleName $script:moduleName -Exactly 1 -Scope It
            }
        }

        Context 'Invoking with default syslog settings' {
            BeforeAll {
                $viServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                $retrievedVMHost = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId' }
                $syslogConfig = [VMware.Vim.SyslogConfig] @{
                    LogHost = $script:resourceProperties.LogHost
                    CheckSslCerts = $script:resourceProperties.CheckSslCerts
                    DefaultRotate = $script:resourceProperties.DefaultRotate
                    DefaultSize = $script:resourceProperties.DefaultSize
                    DefaultTimeout = $script:resourceProperties.DefaultTimeout
                    DropLogRotate = $script:resourceProperties.DropLogRotate
                    DropLogSize = $script:resourceProperties.DropLogSize
                    LogDir = $script:resourceProperties.LogDir
                    LogDirUnique = $script:resourceProperties.LogDirUnique
                    QueueDropMark = $script:resourceProperties.QueueDropMark
                }
                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId' }
                }

                $esxCliMock = {
                    $esxcli = New-Object PSObject
                    $esxcli | Add-Member -MemberType NoteProperty -Name 'VMHost' -Value (New-Object psobject)
                    $esxcli.VMHost | Add-Member -MemberType NoteProperty -Name 'Id' -Value 'VMHostId'
                    $esxcli | Add-Member -MemberType NoteProperty -Name 'system' -Value (New-Object PSObject)
                    $esxcli.system | Add-Member -MemberType NoteProperty -Name 'syslog' -Value (New-Object PSObject)
                    $esxcli.system.syslog | Add-Member -MemberType NoteProperty -Name 'config' -Value (New-Object PSObject)
                    $esxcli.system.syslog.config | Add-Member -MemberType NoteProperty -Name 'get' -Value (New-Object PSObject)
                    $esxcli.system.syslog.config | Add-Member -MemberType NoteProperty -Name 'set' -Value (New-Object PSObject)
                    $esxcli.system.syslog.config.get | Add-Member -MemberType ScriptMethod -Name 'Invoke' -Value { $syslogConfig }
                    $esxcli.system.syslog.config.set | Add-Member -MemberType ScriptMethod -Name 'Invoke' -Value { $true }

                    return $esxcli
                }
                $getSyslogConfigMock = {
                    return $syslogConfig
                }
                $setSyslogConfigMock = {
                    return $true
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName Get-EsxCli -MockWith $esxCliMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHostSyslogConfig -MockWith $getSyslogConfigMock -ModuleName $script:moduleName
                Mock -CommandName Set-VMHostSyslogConfig -MockWith $setSyslogConfigMock -ModuleName $script:moduleName
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

            It 'Should call Get-EsxCli mock once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Get-EsxCli `
                    -ParameterFilter { $Server -eq $viServer -and $VMHost -eq $retrievedVMHost -and $V2 } `
                    -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should not call Get-VMHostSyslogConfig mock' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Get-VMHostSyslogConfig `
                    -ModuleName $script:moduleName -Exactly 0 -Scope It
            }

            It 'Should call Set-VMHostSyslogConfig mock once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Set-VMHostSyslogConfig `
                    -ParameterFilter { $EsxCli.VMHost.Id -eq $retrievedVMHost.Id -and $VMHostSyslogConfig.LogHost -eq $script:resourceProperties.LogHost  } `
                    -ModuleName $script:moduleName -Exactly 1 -Scope It
            }
        }

        Context 'Invoking with new syslog settings' {
            BeforeAll {
                $viServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                $retrievedVMHost = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId' }
                $syslogConfig = [VMware.Vim.SyslogConfig] @{
                    LogHost = $script:resourceProperties.LogHost
                    CheckSslCerts = -not $script:resourceProperties.CheckSslCerts
                    DefaultRotate = $script:resourceProperties.DefaultRotate + 1
                    DefaultSize = $script:resourceProperties.DefaultSize + 1
                    DefaultTimeout = $script:resourceProperties.DefaultTimeout + 1
                    DropLogRotate = $script:resourceProperties.DropLogRotate + 1
                    DropLogSize = $script:resourceProperties.DropLogSize + 1
                    LogDir = $script:resourceProperties.LogDir
                    LogDirUnique = -not $script:resourceProperties.LogDirUnique
                    QueueDropMark = $script:resourceProperties.QueueDropMark + 1
                }
                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId' }
                }

                $esxCliMock = {
                    $esxcli = New-Object PSObject
                    $esxcli | Add-Member -MemberType NoteProperty -Name 'VMHost' -Value (New-Object psobject)
                    $esxcli.VMHost | Add-Member -MemberType NoteProperty -Name 'Id' -Value 'VMHostId'
                    $esxcli | Add-Member -MemberType NoteProperty -Name 'system' -Value (New-Object PSObject)
                    $esxcli.system | Add-Member -MemberType NoteProperty -Name 'syslog' -Value (New-Object PSObject)
                    $esxcli.system.syslog | Add-Member -MemberType NoteProperty -Name 'config' -Value (New-Object PSObject)
                    $esxcli.system.syslog.config | Add-Member -MemberType NoteProperty -Name 'get' -Value (New-Object PSObject)
                    $esxcli.system.syslog.config | Add-Member -MemberType NoteProperty -Name 'set' -Value (New-Object PSObject)
                    $esxcli.system.syslog.config.get | Add-Member -MemberType ScriptMethod -Name 'Invoke' -Value { $syslogConfig }
                    $esxcli.system.syslog.config.set | Add-Member -MemberType ScriptMethod -Name 'Invoke' -Value { $true }

                    return $esxcli
                }
                $getSyslogConfigMock = {
                    return $syslogConfig
                }
                $setSyslogConfigMock = {
                    return $true
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName Get-EsxCli -MockWith $esxCliMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHostSyslogConfig -MockWith $getSyslogConfigMock -ModuleName $script:moduleName
                Mock -CommandName Set-VMHostSyslogConfig -MockWith $setSyslogConfigMock -ModuleName $script:moduleName
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

            It 'Should call Get-EsxCli mock once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Get-EsxCli `
                    -ParameterFilter { $Server -eq $viServer -and $VMHost -eq $retrievedVMHost -and $V2 } `
                    -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should not call Get-VMHostSyslogConfig mock' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Get-VMHostSyslogConfig `
                    -ModuleName $script:moduleName -Exactly 0 -Scope It
            }

            It 'Should call Set-VMHostSyslogConfig mock once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Set-VMHostSyslogConfig `
                    -ParameterFilter { $EsxCli.VMHost.Id -eq $retrievedVMHost.Id -and $VMHostSyslogConfig.LogHost -eq $script:resourceProperties.LogHost  } `
                    -ModuleName $script:moduleName -Exactly 1 -Scope It
            }
        }
    }

    Describe 'VMHostSyslog\Test' -Tag 'Test' {
        Context 'Invoking with syslog not configured' {
            BeforeAll {
                $viServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                $retrievedVMHost = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId' }

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId' }
                }
                $esxCliMock = {
                    $esxcli = New-Object PSObject
                    $esxcli | Add-Member -MemberType NoteProperty -Name 'VMHost' -Value (New-Object psobject)
                    $esxcli.VMHost | Add-Member -MemberType NoteProperty -Name 'Id' -Value 'VMHostId'
                    $esxcli | Add-Member -MemberType NoteProperty -Name 'system' -Value (New-Object PSObject)
                    $esxcli.system | Add-Member -MemberType NoteProperty -Name 'syslog' -Value (New-Object PSObject)
                    $esxcli.system.syslog | Add-Member -MemberType NoteProperty -Name 'config' -Value (New-Object PSObject)
                    $esxcli.system.syslog.config | Add-Member -MemberType NoteProperty -Name 'get' -Value (New-Object PSObject)
                    $esxcli.system.syslog.config | Add-Member -MemberType NoteProperty -Name 'set' -Value (New-Object PSObject)

                    $syslogConfig = [VMware.Vim.SyslogConfig]::new()

                    $esxcli.system.syslog.config.get | Add-Member -MemberType ScriptMethod -Name 'Invoke' -Value { $syslogConfig }
                    $esxcli.system.syslog.config.set | Add-Member -MemberType ScriptMethod -Name 'Invoke' -Value { $true }

                    return $esxcli
                }
                $getSyslogConfigMock = {
                    return $syslogConfig
                }
                $setSyslogConfigMock = {
                    return $true
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName Get-EsxCli -MockWith $esxCliMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHostSyslogConfig -MockWith $getSyslogConfigMock -ModuleName $script:moduleName
                Mock -CommandName Set-VMHostSyslogConfig -MockWith $setSyslogConfigMock -ModuleName $script:moduleName
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

            It 'Should call Get-EsxCli mock once' {
                # Act
                $resource.Test()

                # Assert
                Assert-MockCalled -CommandName Get-EsxCli `
                    -ParameterFilter { $Server -eq $viServer -and $VMHost -eq $retrievedVMHost -and $V2 } `
                    -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call Get-VMHostSyslogConfig mock once' {
                # Act
                $resource.Test()

                # Assert
                Assert-MockCalled -CommandName Get-VMHostSyslogConfig `
                    -ParameterFilter { $EsxCli.VMHost.Id -eq $retrievedVMHost.Id } `
                    -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should not call Set-VMHostSyslogConfig mock' {
                # Act
                $resource.Test()

                # Assert
                Assert-MockCalled -CommandName Set-VMHostSyslogConfig `
                    -ParameterFilter { $VMHostSyslogConfig.LogHost -eq $script:resourceProperties.LogHost  } `
                    -ModuleName $script:moduleName -Exactly 0 -Scope It
            }
        }

        Context 'Invoking with default syslog settings' {
            BeforeAll {
                $viServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                $retrievedVMHost = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId' }
                $syslogConfig = [VMware.Vim.SyslogConfig] @{
                    LogHost = $script:resourceProperties.LogHost
                    CheckSslCerts = $script:resourceProperties.CheckSslCerts
                    DefaultRotate = $script:resourceProperties.DefaultRotate
                    DefaultSize = $script:resourceProperties.DefaultSize
                    DefaultTimeout = $script:resourceProperties.DefaultTimeout
                    DropLogRotate = $script:resourceProperties.DropLogRotate
                    DropLogSize = $script:resourceProperties.DropLogSize
                    LogDir = $script:resourceProperties.LogDir
                    LogDirUnique = $script:resourceProperties.LogDirUnique
                    QueueDropMark = $script:resourceProperties.QueueDropMark
                }
                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId' }
                }

                $esxCliMock = {
                    $esxcli = New-Object PSObject
                    $esxcli | Add-Member -MemberType NoteProperty -Name 'VMHost' -Value (New-Object psobject)
                    $esxcli.VMHost | Add-Member -MemberType NoteProperty -Name 'Id' -Value 'VMHostId'
                    $esxcli | Add-Member -MemberType NoteProperty -Name 'system' -Value (New-Object PSObject)
                    $esxcli.system | Add-Member -MemberType NoteProperty -Name 'syslog' -Value (New-Object PSObject)
                    $esxcli.system.syslog | Add-Member -MemberType NoteProperty -Name 'config' -Value (New-Object PSObject)
                    $esxcli.system.syslog.config | Add-Member -MemberType NoteProperty -Name 'get' -Value (New-Object PSObject)
                    $esxcli.system.syslog.config | Add-Member -MemberType NoteProperty -Name 'set' -Value (New-Object PSObject)
                    $esxcli.system.syslog.config.get | Add-Member -MemberType ScriptMethod -Name 'Invoke' -Value { $syslogConfig }
                    $esxcli.system.syslog.config.set | Add-Member -MemberType ScriptMethod -Name 'Invoke' -Value { $true }

                    return $esxcli
                }
                $getSyslogConfigMock = {
                    return $syslogConfig
                }
                $setSyslogConfigMock = {
                    return $true
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName Get-EsxCli -MockWith $esxCliMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHostSyslogConfig -MockWith $getSyslogConfigMock -ModuleName $script:moduleName
                Mock -CommandName Set-VMHostSyslogConfig -MockWith $setSyslogConfigMock -ModuleName $script:moduleName
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

            It 'Should call Get-EsxCli mock once' {
                # Act
                $resource.Test()

                # Assert
                Assert-MockCalled -CommandName Get-EsxCli `
                    -ParameterFilter { $Server -eq $viServer -and $VMHost -eq $retrievedVMHost -and $V2 } `
                    -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call Get-VMHostSyslogConfig mock once' {
                # Act
                $resource.Test()

                # Assert
                Assert-MockCalled -CommandName Get-VMHostSyslogConfig `
                    -ParameterFilter { $EsxCli.VMHost.Id -eq $retrievedVMHost.Id } `
                    -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should not call Set-VMHostSyslogConfig mock' {
                # Act
                $resource.Test()

                # Assert
                Assert-MockCalled -CommandName Set-VMHostSyslogConfig `
                    -ParameterFilter { $EsxCli.VMHost.Id -eq $retrievedVMHost.Id -and $VMHostSyslogConfig.LogHost -eq $script:resourceProperties.LogHost  } `
                    -ModuleName $script:moduleName -Exactly 0 -Scope It
            }
        }

        Context 'Invoking with new syslog settings' {
            BeforeAll {
                $viServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                $retrievedVMHost = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId' }
                $syslogConfig = [VMware.Vim.SyslogConfig] @{
                    LogHost = $script:resourceProperties.LogHost
                    CheckSslCerts = -not $script:resourceProperties.CheckSslCerts
                    DefaultRotate = $script:resourceProperties.DefaultRotate + 1
                    DefaultSize = $script:resourceProperties.DefaultSize + 1
                    DefaultTimeout = $script:resourceProperties.DefaultTimeout + 1
                    DropLogRotate = $script:resourceProperties.DropLogRotate + 1
                    DropLogSize = $script:resourceProperties.DropLogSize + 1
                    LogDir = $script:resourceProperties.LogDir
                    LogDirUnique = -not $script:resourceProperties.LogDirUnique
                    QueueDropMark = $script:resourceProperties.QueueDropMark + 1
                }
                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId' }
                }

                $esxCliMock = {
                    $esxcli = New-Object PSObject
                    $esxcli | Add-Member -MemberType NoteProperty -Name 'VMHost' -Value (New-Object psobject)
                    $esxcli.VMHost | Add-Member -MemberType NoteProperty -Name 'Id' -Value 'VMHostId'
                    $esxcli | Add-Member -MemberType NoteProperty -Name 'system' -Value (New-Object PSObject)
                    $esxcli.system | Add-Member -MemberType NoteProperty -Name 'syslog' -Value (New-Object PSObject)
                    $esxcli.system.syslog | Add-Member -MemberType NoteProperty -Name 'config' -Value (New-Object PSObject)
                    $esxcli.system.syslog.config | Add-Member -MemberType NoteProperty -Name 'get' -Value (New-Object PSObject)
                    $esxcli.system.syslog.config | Add-Member -MemberType NoteProperty -Name 'set' -Value (New-Object PSObject)
                    $esxcli.system.syslog.config.get | Add-Member -MemberType ScriptMethod -Name 'Invoke' -Value { $syslogConfig }
                    $esxcli.system.syslog.config.set | Add-Member -MemberType ScriptMethod -Name 'Invoke' -Value { $true }

                    return $esxcli
                }
                $getSyslogConfigMock = {
                    return $syslogConfig
                }
                $setSyslogConfigMock = {
                    return $true
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName Get-EsxCli -MockWith $esxCliMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHostSyslogConfig -MockWith $getSyslogConfigMock -ModuleName $script:moduleName
                Mock -CommandName Set-VMHostSyslogConfig -MockWith $setSyslogConfigMock -ModuleName $script:moduleName
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

            It 'Should call Get-EsxCli mock once' {
                # Act
                $resource.Test()

                # Assert
                Assert-MockCalled -CommandName Get-EsxCli `
                    -ParameterFilter { $Server -eq $viServer -and $VMHost -eq $retrievedVMHost -and $V2 } `
                    -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call Get-VMHostSyslogConfig mock once' {
                # Act
                $resource.Test()

                # Assert
                Assert-MockCalled -CommandName Get-VMHostSyslogConfig `
                    -ParameterFilter { $EsxCli.VMHost.Id -eq $retrievedVMHost.Id } `
                    -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should not call Set-VMHostSyslogConfig mock' {
                # Act
                $resource.Test()

                # Assert
                Assert-MockCalled -CommandName Set-VMHostSyslogConfig `
                    -ParameterFilter { $EsxCli.VMHost.Id -eq $retrievedVMHost.Id -and $VMHostSyslogConfig.LogHost -eq $script:resourceProperties.LogHost  } `
                    -ModuleName $script:moduleName -Exactly 0 -Scope It
            }
        }
    }

    Describe 'VMHostSyslog\Get' -Tag 'Get' {
        Context 'Invoking with syslog not configured' {
            BeforeAll {
                $viServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                $retrievedVMHost = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Name = '10.23.82.112'; Id = 'VMHostId' }
                $syslogConfig = [VMware.Vim.SyslogConfig] @{
                    LogHost = $script:resourceProperties.LogHost
                    CheckSslCerts = $script:resourceProperties.CheckSslCerts
                    DefaultRotate = $script:resourceProperties.DefaultRotate
                    DefaultSize = $script:resourceProperties.DefaultSize
                    DefaultTimeout = $script:resourceProperties.DefaultTimeout
                    DropLogRotate = $script:resourceProperties.DropLogRotate
                    DropLogSize = $script:resourceProperties.DropLogSize
                    LogDir = $script:resourceProperties.LogDir
                    LogDirUnique = $script:resourceProperties.LogDirUnique
                    QueueDropMark = $script:resourceProperties.QueueDropMark
                }

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Name = '10.23.82.112'; Id = 'VMHostId' }
                }
                $esxCliMock = {
                    $esxcli = New-Object PSObject
                    $esxcli | Add-Member -MemberType NoteProperty -Name 'VMHost' -Value (New-Object psobject)
                    $esxcli.VMHost | Add-Member -MemberType NoteProperty -Name 'Id' -Value 'VMHostId'
                    $esxcli | Add-Member -MemberType NoteProperty -Name 'system' -Value (New-Object PSObject)
                    $esxcli.system | Add-Member -MemberType NoteProperty -Name 'syslog' -Value (New-Object PSObject)
                    $esxcli.system.syslog | Add-Member -MemberType NoteProperty -Name 'config' -Value (New-Object PSObject)
                    $esxcli.system.syslog.config | Add-Member -MemberType NoteProperty -Name 'get' -Value (New-Object PSObject)
                    $esxcli.system.syslog.config | Add-Member -MemberType NoteProperty -Name 'set' -Value (New-Object PSObject)

                    $esxcli.system.syslog.config.get | Add-Member -MemberType ScriptMethod -Name 'Invoke' -Value { $syslogConfig }
                    $esxcli.system.syslog.config.set | Add-Member -MemberType ScriptMethod -Name 'Invoke' -Value { $true }

                    return $esxcli
                }
                $getSyslogConfigMock = {
                    return $syslogConfig
                }
                $setSyslogConfigMock = {
                    return $true
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName Get-EsxCli -MockWith $esxCliMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHostSyslogConfig -MockWith $getSyslogConfigMock -ModuleName $script:moduleName
                Mock -CommandName Set-VMHostSyslogConfig -MockWith $setSyslogConfigMock -ModuleName $script:moduleName
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

            It 'Should call Get-EsxCli mock once' {
                # Act
                $resource.Get()

                # Assert
                Assert-MockCalled -CommandName Get-EsxCli `
                    -ParameterFilter { $Server -eq $viServer -and $VMHost -eq $retrievedVMHost -and $V2 } `
                    -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call Get-VMHostSyslogConfig mock once' {
                # Act
                $resource.Get()

                # Assert
                Assert-MockCalled -CommandName Get-VMHostSyslogConfig `
                    -ParameterFilter { $EsxCli.VMHost.Id -eq $retrievedVMHost.Id } `
                    -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should not call Set-VMHostSyslogConfig mock' {
                # Act
                $resource.Get()

                # Assert
                Assert-MockCalled -CommandName Set-VMHostSyslogConfig `
                    -ParameterFilter { $VMHostSyslogConfig.LogHost -eq $script:resourceProperties.LogHost  } `
                    -ModuleName $script:moduleName -Exactly 0 -Scope It
            }
        }

        Context 'Invoking with default syslog settings' {
            BeforeAll {
                $viServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                $retrievedVMHost = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Name = '10.23.82.112'; Id = 'VMHostId' }

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Name = '10.23.82.112'; Id = 'VMHostId' }
                }
                $esxCliMock = {
                    $esxcli = New-Object PSObject
                    $esxcli | Add-Member -MemberType NoteProperty -Name 'VMHost' -Value (New-Object psobject)
                    $esxcli.VMHost | Add-Member -MemberType NoteProperty -Name 'Id' -Value 'VMHostId'
                    $esxcli | Add-Member -MemberType NoteProperty -Name 'system' -Value (New-Object PSObject)
                    $esxcli.system | Add-Member -MemberType NoteProperty -Name 'syslog' -Value (New-Object PSObject)
                    $esxcli.system.syslog | Add-Member -MemberType NoteProperty -Name 'config' -Value (New-Object PSObject)
                    $esxcli.system.syslog.config | Add-Member -MemberType NoteProperty -Name 'get' -Value (New-Object PSObject)
                    $esxcli.system.syslog.config | Add-Member -MemberType NoteProperty -Name 'set' -Value (New-Object PSObject)
                    $syslogConfigOut = [VMware.Vim.SyslogConfigOut] @{
                        RemoteHost = 'udp://vli.local.lab:514'
                        CheckSslCerts = $true
                        DefaultRotate = 10
                        DefaultSize = 100
                        DefaultTimeout = 180
                        DropLogRotate = 10
                        DropLogSize = 100
                        LogDir = '/scratch/log'
                        LogDirUnique = $false
                        QueueDropMark = 90
                    }
                    $esxcli.system.syslog.config.get | Add-Member -MemberType ScriptMethod -Name 'Invoke' -Value { $syslogConfigOut }
                    $esxcli.system.syslog.config.set | Add-Member -MemberType ScriptMethod -Name 'Invoke' -Value { $true }

                    return $esxcli
                }
                $getSyslogConfigMock = {
                    return ([VMware.Vim.SyslogConfigOut] @{
                            RemoteHost = 'udp://vli.local.lab:514'
                            CheckSslCerts = $true
                            DefaultRotate = 10
                            DefaultSize = 100
                            DefaultTimeout = 180
                            DropLogRotate = 10
                            DropLogSize = 100
                            LogDir = '/scratch/log'
                            LogDirUnique = $false
                            QueueDropMark = 90
                        })
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName Get-EsxCli -MockWith $esxCliMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHostSyslogConfig -MockWith $getSyslogConfigMock -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should return the resource with the properties retrieved from the server' {
                # Act
                $result = $resource.Get()

                # Assert
                $result.Name | Should -Be $script:resourceProperties.Name
                $result.Server | Should -Be $script:resourceProperties.Server
                # The Syslog object for the Unit Tests should be modified to reflect the values retrieved from the Server.

                # $result.LogHost | Should -Be $script:resourceProperties.LogHost
                # $result.CheckSslCerts | Should -Be $script:resourceProperties.CheckSslCerts
                # $result.DefaultRotate | Should -Be $script:resourceProperties.DefaultRotate
                # $result.DefaultSize | Should -Be $script:resourceProperties.DefaultSize
                # $result.DefaultTimeout | Should -Be $script:resourceProperties.DefaultTimeout
                # $result.DropLogRotate | Should -Be $script:resourceProperties.DropLogRotate
                # $result.DropLogSize | Should -Be $script:resourceProperties.DropLogSize
                # $result.LogDir | Should -Be $script:resourceProperties.LogDir
                # $result.LogDirUnique | Should -Be $script:resourceProperties.LogDirUnique
                # $result.QueueDropMark | Should -Be $script:resourceProperties.QueueDropMark
            }
        }
    }
}
finally {
    # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
    Invoke-TestCleanup
}
