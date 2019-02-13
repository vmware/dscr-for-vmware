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

function Invoke-TestSetup {
    $script:modulePath = $env:PSModulePath
    $script:unitTestsFolder = Join-Path (Join-Path (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase 'Tests') 'Unit'
    $script:mockModuleLocation = "$script:unitTestsFolder\TestHelpers"

    $script:moduleName = 'VMware.vSphereDSC'
    $script:resourceName = 'VMHostVss'

    $user = 'user'
    $password = 'password' | ConvertTo-SecureString -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential($user, $password)

    $script:Constants = @{
        VIServerUser = 'user'
        NetworkSystemMoRefType = 'HostNetworkSystem'
        NetworkSystemMoRefValue = 'networkSystem'
    }
    $script:resourceProperties = @{
        Name = '10.23.82.112'
        Server = '10.23.82.112'
        Credential = $credential
        Ensure = 'Present'
        VssName = 'DSCTest'
        NumPorts = 1
        Mtu = 1500
        Key = 'VSS'
        NumPortsAvailable = 1
        Pnic = @('vmnic1', 'vmnic2')
        Portgroup = @('Portgroup1', 'Portgroup2')
    }
    $script:resourcePropertiesAbsent = $script:resourceProperties.Clone()
    $script:resourcePropertiesAbsent.Ensure = 'Absent'
    $script:netObjectAdd = @{
        Type = 'VSS'
        Operation = 'add'
    }
    $script:netObjectEdit = @{
        Type = 'VSS'
        Operation = 'edit'
    }
    $script:netObjectRemove = @{
        Type = 'VSS'
        Operation = 'remove'
    }
    $script:viServerCode = @'
        return [VMware.Vim.VIServer] @{
            Name = '$($script:resourceProperties.Server)'
            User = '$($script:Constants.VIServerUser)'
    }
'@
    $script:vmHostCode = @'
        return [VMware.Vim.VMHost] @{
            Name = '$($script:resourceProperties.Name)'
            ExtensionData = [VMware.Vim.HostExtensionData] @{
                ConfigManager = [VMware.Vim.HostConfigManager] @{
                    NetworkSystem = [VMware.Vim.ManagedObjectReference] @{
                        Type = '$($script:Constants.NetworkSystemMoRefType)'
                        Value = '$($script:Constants.NetworkSystemMoRefValue)'
                    }
                }
            }
        }
'@
    $script:networkSystemNoVssCode = @'
        return (
            [VMware.Vim.HostNetworkSystem] @{
                NetworkInfo = [VMware.Vim.HostNetworkInfo] @{
                    vswitch = @()
                }
            }
        )
'@
    $script:networkSystemDiffVssCode = @'
        return (
            [VMware.Vim.HostNetworkSystem] @{
                NetworkInfo = [VMware.Vim.HostNetworkInfo] @{
                    vswitch = @(
                        [VMware.Vim.HostVirtualSwitch]@{
                            Key = '$($script:resourceProperties.Key)'
                            Mtu = $($script:resourceProperties.Mtu + 1)
                            Name = '$($script:resourceProperties.VssName)'
                            NumPorts = $($script:resourceProperties.NumPorts + 1)
                            NumPortsAvailable = $($script:resourceProperties.NumPortsAvailable)
                            Pnic = $(($script:resourceProperties.Pnic | %{"'$_'"}) -join ',')
                            PortGroup = $(($script:resourceProperties.Portgroup | %{"'$_'"}) -join ',')
                        }
                    )
                }
            }
        )
'@
    $script:networkSystemSameVssCode = @'
        return (
            [VMware.Vim.HostNetworkSystem] @{
                NetworkInfo = [VMware.Vim.HostNetworkInfo] @{
                    vswitch = @(
                        [VMware.Vim.HostVirtualSwitch]@{
                            Key = '$($script:resourceProperties.Key)'
                            Mtu = $($script:resourceProperties.Mtu)
                            Name = '$($script:resourceProperties.VssName)'
                            NumPorts = $($script:resourceProperties.NumPorts)
                            NumPortsAvailable = $($script:resourceProperties.NumPortsAvailable)
                            Pnic = $(($script:resourceProperties.Pnic | %{"'$_'"}) -join ',')
                            PortGroup = $(($script:resourceProperties.Portgroup | %{"'$_'"}) -join ',')
                        }
                    )
                }
            }
        )
'@
    $script:vssConfigAddVssCode = @'
        return [VMware.Vim.HostVirtualSwitchConfig] @{
            Name = '$($script:resourceProperties.VssName)'
            ChangeOperation = '$($script:netObjectAdd.Operation)'
            Spec = [VMware.Vim.HostVirtualSwitchSpec] @{
                Mtu = $($script:resourceProperties.Mtu)
                NumPorts = $($script:resourceProperties.NumPorts)
            }
        }
'@
    $script:vssConfigEditVssCode = @'
        return [VMware.Vim.HostVirtualSwitchConfig] @{
            Name = '$($script:resourceProperties.VssName)'
            ChangeOperation = '$($script:netObjectEdit.Operation)'
            Spec = [VMware.Vim.HostVirtualSwitchSpec] @{
                Mtu = $($script:resourceProperties.Mtu)
                NumPorts = $($script:resourceProperties.NumPorts)
            }
        }
'@
    $script:vssConfigRemoveVssCode = @'
        return [VMware.Vim.HostVirtualSwitchConfig] @{
            Name = '$($script:resourceProperties.VssName)'
            ChangeOperation = '$($script:netObjectRemove.Operation)'
            Spec = [VMware.Vim.HostVirtualSwitchSpec] @{
                Mtu = $($script:resourceProperties.Mtu)
                NumPorts = $($script:resourceProperties.NumPorts)
            }
        }
'@
    $script:updateNetworkCode = @'
        return [VMware.Vim.HostNetworkConfigResult] @{
            ConsoleVnicDevice = @()
            VnicDevice = @()
        }
'@

    $env:PSModulePath = $script:mockModuleLocation
    $vimAutomationModule = Get-Module -Name VMware.VimAutomation.Core
    if ($null -ne $vimAutomationModule -and $vimAutomationModule.Path -NotMatch 'TestHelpers') {
        throw 'The Original VMware.VimAutomation.Core Module is loaded in the current session. If you want to run the unit tests please open a new PowerShell session.'
    }

    Import-Module -Name VMware.VimAutomation.Core

    $script:viServer = [VMware.Vim.VIServer] @{
        Name = $script:resourceProperties.Server
        User = $script:Constants.VIServerUser
    }
    $script:networkSystemMoRef = [VMware.Vim.ManagedObjectReference] @{
        Type = $script:Constants.NetworkSystemMoRefType
        Value = $script:Constants.NetworkSystemMoRefValue
    }
}

function Invoke-TestCleanup {
    Remove-Module -Name VMware.VimAutomation.Core
    $env:PSModulePath = $script:modulePath
}

try {
    # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
    Invoke-TestSetup

    Describe 'VMHostVss\Set'  -Tag 'Set' {
        Context 'Present and VSS does not exist' {
            BeforeAll {
                $viserverMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:viServerCode))
                $vmHostMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vmHostCode))
                $networkSystemMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:networkSystemNoVssCode))
                $vssConfigMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vssConfigAddVssCode))
                $updateNetworkMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:updateNetworkCode))
            }

            # Arrange
            Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
            Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $networkSystemMock -ModuleName $script:moduleName
            Mock -CommandName New-VssConfig -MockWith $vssConfigMock -ModuleName $script:moduleName
            Mock -CommandName Update-Network -MockWith $updateNetworkMock -ModuleName $script:moduleName

            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call the Connect-VIServer mock with the passed server and credentials once' {
                # Act
                $resource.Set()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Connect-VIServer'
                    ParameterFilter = { $Server -eq $script:resourceProperties.Server -and $Credential -eq $script:resourceProperties.Credential }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }
                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call Get-VMHost with the passed server and name once' {
                # Act
                $resource.Set()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-VMHost'
                    ParameterFilter = { $Server -eq $script:viServer -and $Name -eq $script:resourceProperties.Name }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }
                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call Get-View with the passed server and id twice' {
                # Act
                $resource.Set()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-View'
                    ParameterFilter = { $Server -eq $script:viServer -and $Id -eq $script:networkSystemMoRef }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 2
                    Scope = 'It'
                }
                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call New-VssConfig once with operation Add' {
                # Act
                $result = $resource.Set()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'New-VssConfig'
                    ParameterFilter = { $Name -eq $script:resourceProperties.VssName -and $Operation -eq $script:netObjectAdd.Operation }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }
                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call Update-Network once with type Add' {
                # Act
                $result = $resource.Set()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Update-Network'
                    ParameterFilter = { $Type -eq $script:netObjectAdd.Type -and $VssConfig.ChangeOperation -eq $script:netObjectAdd.Operation }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }
                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Present and VSS does exist with different properties' {
            BeforeAll {
                $viserverMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:viServerCode))
                $vmHostMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vmHostCode))
                $networkSystemMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:networkSystemDiffVssCode))
                $vssConfigMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vssConfigEditVssCode))
                $updateNetworkMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:updateNetworkCode))
            }

            # Arrange
            Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
            Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $networkSystemMock -ModuleName $script:moduleName
            Mock -CommandName New-VssConfig -MockWith $vssConfigMock -ModuleName $script:moduleName
            Mock -CommandName Update-Network -MockWith $updateNetworkMock -ModuleName $script:moduleName

            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call New-VssConfig once with operation Edit' {
                # Act
                $result = $resource.Set()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'New-VssConfig'
                    ParameterFilter = { $Name -eq $script:resourceProperties.VssName -and $Operation -eq $script:netObjectEdit.Operation }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }
                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call Update-Network once with type Edit' {
                # Act
                $result = $resource.Set()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Update-Network'
                    ParameterFilter = { $Type -eq $script:netObjectEdit.Type -and $VssConfig.ChangeOperation -eq $script:netObjectEdit.Operation }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }
                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Absent and VSS exists' {
            BeforeAll {
                $viserverMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:viServerCode))
                $vmHostMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vmHostCode))
                $networkSystemMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:networkSystemSameVssCode))
                $vssConfigMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vssConfigRemoveVssCode))
                $updateNetworkMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:updateNetworkCode))
            }

            # Arrange
            Mock -CommandName Connect-VIServer -MockWith $viserverMock -ModuleName $script:moduleName
            Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $networkSystemMock -ModuleName $script:moduleName
            Mock -CommandName New-VssConfig -MockWith $vssConfigMock -ModuleName $script:moduleName
            Mock -CommandName Update-Network -MockWith $updateNetworkMock -ModuleName $script:moduleName

            $resource = New-Object -TypeName $script:resourceName -Property $script:resourcePropertiesAbsent

            It 'Should call New-VssConfig once with operation Remove' {
                # Act
                $result = $resource.Set()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'New-VssConfig'
                    ParameterFilter = { $Name -eq $script:resourceProperties.VssName -and $Operation -eq $script:netObjectRemove.Operation }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }
                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call Update-Network once with type Remove' {
                # Act
                $result = $resource.Set()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Update-Network'
                    ParameterFilter = { $Type -eq $script:netObjectRemove.Type -and $VssConfig.ChangeOperation -eq $script:netObjectRemove.Operation }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }
                Assert-MockCalled @assertMockCalledParams
            }
        }
    }

    Describe 'VMHostVss\Test' -Tag 'Test' {
        Context 'Present and VSS does not exist' {
            BeforeAll {
                $viserverMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:viServerCode))
                $vmHostMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vmHostCode))
                $networkSystemMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:networkSystemNoVssCode))
            }

            # Arrange
            Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
            Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $networkSystemMock -ModuleName $script:moduleName

            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call the Connect-VIServer mock with the passed server and credentials once' {
                # Act
                $resource.Test()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Connect-VIServer'
                    ParameterFilter = { $Server -eq $script:resourceProperties.Server -and $Credential -eq $script:resourceProperties.Credential }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }
                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call Get-VMHost with the passed server and name once' {
                # Act
                $resource.Test()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-VMHost'
                    ParameterFilter = { $Server -eq $script:viServer -and $Name -eq $script:resourceProperties.Name }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }
                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call Get-View with the passed server and id once' {
                # Act
                $resource.Test()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-View'
                    ParameterFilter = { $Server -eq $script:viServer -and $Id -eq $script:networkSystemMoRef }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }
                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should return $false (The desired VSS does not exist)' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $false
            }
        }

        Context 'Present and VSS does exist with different properties' {
            BeforeAll {
                $viserverMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:viServerCode))
                $vmHostMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vmHostCode))
                $networkSystemMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:networkSystemDiffVssCode))
            }

            # Arrange
            Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
            Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $networkSystemMock -ModuleName $script:moduleName

            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should return $false (The desired VSS is not configured correctly)' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $false
            }
        }

        Context 'Present and VSS does exist with the same properties' {
            BeforeAll {
                $viserverMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:viServerCode))
                $vmHostMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vmHostCode))
                $networkSystemMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:networkSystemSameVssCode))
            }

            # Arrange
            Mock -CommandName Connect-VIServer -MockWith $viserverMock -ModuleName $script:moduleName
            Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $networkSystemMock -ModuleName $script:moduleName

            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should return $true (The desired VSS is configured correctly)' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $true
            }
        }

        Context 'Absent and VSS does not exist' {
            BeforeAll {
                $viserverMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:viServerCode))
                $vmHostMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vmHostCode))
                $networkSystemMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:networkSystemNoVssCode))
            }

            # Arrange
            Mock -CommandName Connect-VIServer -MockWith $viserverMock -ModuleName $script:moduleName
            Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $networkSystemMock -ModuleName $script:moduleName

            $resource = New-Object -TypeName $script:resourceName -Property $script:resourcePropertiesAbsent

            It 'Should call the Connect-VIServer mock with the passed server and credentials once' {
                # Act
                $resource.Test()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Connect-VIServer'
                    ParameterFilter = { $Server -eq $script:resourceProperties.Server -and $Credential -eq $script:resourceProperties.Credential }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }
                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call Get-VMHost with the passed server and name once' {
                # Act
                $resource.Get()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-VMHost'
                    ParameterFilter = { $Server -eq $script:viServer -and $Name -eq $script:resourceProperties.Name }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }
                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should call Get-View with the passed server and id once' {
                # Act
                $resource.Get()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-View'
                    ParameterFilter = { $Server -eq $script:viServer -and $Id -eq $script:networkSystemMoRef }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }
                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should return $true (The VSS does not exist)' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $true
            }
        }

        Context 'Absent and VSS does exist with different properties' {
            BeforeAll {
                $viserverMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:viServerCode))
                $vmHostMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vmHostCode))
                $networkSystemMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:networkSystemDiffVssCode))
            }

            # Arrange
            Mock -CommandName Connect-VIServer -MockWith $viserverMock -ModuleName $script:moduleName
            Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $networkSystemMock -ModuleName $script:moduleName

            $resource = New-Object -TypeName $script:resourceName -Property $script:resourcePropertiesAbsent

            It 'Should return $false (The VSS exists)' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $false
            }
        }

        Context 'Absent and VSS does exist with the same properties' {
            BeforeAll {
                $viserverMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:viServerCode))
                $vmHostMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vmHostCode))
                $networkSystemMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:networkSystemSameVssCode))
            }

            # Arrange
            Mock -CommandName Connect-VIServer -MockWith $viserverMock -ModuleName $script:moduleName
            Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $networkSystemMock -ModuleName $script:moduleName

            $resource = New-Object -TypeName $script:resourceName -Property $script:resourcePropertiesAbsent

            It 'Should return $false (The VSS exists)' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $false
            }
        }
    }

    Describe 'VMHostVss\Get' -Tag 'Get' {
        BeforeAll {
            $viserverMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:viServerCode))
            $vmHostMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vmHostCode))
            $networkSystemMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:networkSystemSameVssCode))
        }

        # Arrange
        Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
        Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
        Mock -CommandName Get-View -MockWith $networkSystemMock -ModuleName $script:moduleName

        $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

        It 'Should call the Connect-VIServer mock with the passed server and credentials once' {
            # Act
            $resource.Get()

            # Assert
            $assertMockCalledParams = @{
                CommandName = 'Connect-VIServer'
                ParameterFilter = { $Server -eq $script:resourceProperties.Server -and $Credential -eq $script:resourceProperties.Credential }
                ModuleName = $script:moduleName
                Exactly = $true
                Times = 1
                Scope = 'It'
            }
            Assert-MockCalled @assertMockCalledParams
        }

        It 'Should call Get-VMHost with the passed server and name once' {
            # Act
            $resource.Get()

            # Assert
            $assertMockCalledParams = @{
                CommandName = 'Get-VMHost'
                ParameterFilter = { $Server -eq $script:viServer -and $Name -eq $script:resourceProperties.Name }
                ModuleName = $script:moduleName
                Exactly = $true
                Times = 1
                Scope = 'It'
            }
            Assert-MockCalled @assertMockCalledParams
        }

        It 'Should call Get-View with the passed server and id once' {
            # Act
            $resource.Get()

            # Assert
            $assertMockCalledParams = @{
                CommandName = 'Get-View'
                ParameterFilter = { $Server -eq $script:viServer -and $Id -eq $script:networkSystemMoRef }
                ModuleName = $script:moduleName
                Exactly = $true
                Times = 1
                Scope = 'It'
            }
            Assert-MockCalled @assertMockCalledParams
        }

        It 'Should match the properties retrieved from the server' {
            # Act
            $result = $resource.Get()

            # Assert
            $result.Server | Should -Be $script:resourceProperties.Server
            $result.Name | Should -Be $script:resourceProperties.Name
            $result.Ensure | Should -Be $script:resourceProperties.Ensure
            $result.VssName | Should -Be $script:resourceProperties.VssName
            $result.NumPorts | Should -Be $script:resourceProperties.NumPorts
            $result.Mtu | Should -Be $script:resourceProperties.Mtu
            $result.Key | Should -Be $script:resourceProperties.Key
            $result.NumPortsAvailable | Should -Be $script:resourceProperties.NumPortsAvailable
            Compare-Object -ReferenceObject ($result.Pnic | ConvertTo-Json) -DifferenceObject ($script:resourceProperties.Pnic | ConvertTo-Json) | Should -Be $null
            Compare-Object -ReferenceObject ($result.PortGroup | ConvertTo-Json) -DifferenceObject ($script:resourceProperties.Portgroup | ConvertTo-Json) | Should -Be $null
        }
    }
}
finally {
    # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
    Invoke-TestCleanup
}
