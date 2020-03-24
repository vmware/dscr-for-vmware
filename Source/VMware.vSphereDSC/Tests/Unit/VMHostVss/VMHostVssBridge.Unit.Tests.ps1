<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

Using module '..\..\..\VMware.vSphereDSC.psm1'

function Invoke-TestSetup {
    $script:modulePath = $env:PSModulePath
    $script:unitTestsFolder = Join-Path (Join-Path (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase 'Tests') 'Unit'
    $script:mockModuleLocation = "$script:unitTestsFolder\TestHelpers"

    $script:moduleName = 'VMware.vSphereDSC'
    $script:resourceName = 'VMHostVssBridge'

    $user = 'user'
    $password = ConvertTo-SecureString -String 'password' -AsPlainText -Force
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
        NicDevice = @()
        BeaconInterval = 0
        LinkDiscoveryProtocolProtocol = 'CDP'
        LinkDiscoveryProtocolOperation = 'Listen'
    }
    $script:resourcePropertiesAbsent = $script:resourceProperties.Clone()
    $script:resourcePropertiesAbsent.Ensure = 'Absent'
    $script:NicDeviceAlt = "'vmnic1', 'vmnic2'"
    $script:BeaconIntervalAlt = 1
    $script:LinkDiscoveryProtocolProtocolAlt = "CDP"
    $script:LinkDiscoveryProtocolOperationAlt = "Both"
    $script:LinkDiscoveryProtocolProtocolUnset = "Unset"
    $script:LinkDiscoveryProtocolOperationUnset = "Unset"
    $script:netObjectEdit = 'edit'
    $script:viServerCode = @'
        return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{
            Name = '$($script:resourceProperties.Server)'
            User = '$($script:Constants.VIServerUser)'
        }
'@
    $script:vmHostCode = @'
        return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{
            Name = '$($script:resourceProperties.Name)'
            ExtensionData = [VMware.Vim.HostSystem] @{
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
    $script:networkSystemNoVssBridgeCode = @'
        return (
            [VMware.Vim.HostNetworkSystem] @{
                NetworkInfo = [VMware.Vim.HostNetworkInfo] @{
                    vswitch = @(
                        [VMware.Vim.HostVirtualSwitch]@{
                            Name = '$($script:resourceProperties.VssName)'
                            Spec = [VMware.Vim.HostVirtualSwitchSpec] @{
                                Bridge = @{}
                            }
                        }
                    )
                }
            }
        )
'@
    $script:networkSystemSameVssBridgeCode = @'
        return (
            [VMware.Vim.HostNetworkSystem] @{
                NetworkInfo = [VMware.Vim.HostNetworkInfo] @{
                    vswitch = @(
                        [VMware.Vim.HostVirtualSwitch]@{
                            Name = '$($script:resourceProperties.VssName)'
                            Spec = [VMware.Vim.HostVirtualSwitchSpec] @{
                                Bridge = [VMware.Vim.HostVirtualSwitchBondBridge] @{
                                    NicDevice = @($($script:resourceProperties.NicDevice))
                                    Beacon = [VMware.Vim.HostVirtualSwitchBeaconConfig] @{
                                        Interval = '$($script:resourceProperties.BeaconInterval)'
                                    }
                                    LinkDiscoveryProtocolConfig = [VMware.Vim.LinkDiscoveryProtocolConfig] @{
                                        Operation = '$($script:resourceProperties.LinkDiscoveryProtocolOperation)'
                                        Protocol = '$($script:resourceProperties.LinkDiscoveryProtocolProtocol)'
                                    }
                                }
                            }
                        }
                    )
                }
            }
        )
'@
    $script:networkSystemUnsetVssBridgeCode = @'
        return (
            [VMware.Vim.HostNetworkSystem] @{
                NetworkInfo = [VMware.Vim.HostNetworkInfo] @{
                    vswitch = @(
                        [VMware.Vim.HostVirtualSwitch]@{
                            Name = '$($script:resourceProperties.VssName)'
                            Spec = [VMware.Vim.HostVirtualSwitchSpec] @{
                                Bridge = [VMware.Vim.HostVirtualSwitchBondBridge] @{
                                    NicDevice = @($($script:resourceProperties.NicDevice))
                                    Beacon = [VMware.Vim.HostVirtualSwitchBeaconConfig] @{
                                        Interval = '$($script:resourceProperties.BeaconInterval)'
                                    }
                                    LinkDiscoveryProtocolConfig = [VMware.Vim.LinkDiscoveryProtocolConfig] @{
                                        Operation = '$($script:resourceProperties.LinkDiscoveryProtocolOperationUnset)'
                                        Protocol = '$($script:resourceProperties.LinkDiscoveryProtocolProtocolUnset)'
                                    }
                                }
                            }
                        }
                    )
                }
            }
        )
'@
    $script:networkSystemDiffVssBridgeCode = @'
        return (
            [VMware.Vim.HostNetworkSystem] @{
                NetworkInfo = [VMware.Vim.HostNetworkInfo] @{
                    vswitch = @(
                        [VMware.Vim.HostVirtualSwitch]@{
                            Name = '$($script:resourceProperties.VssName)'
                            Spec = [VMware.Vim.HostVirtualSwitchSpec] @{
                                Bridge = [VMware.Vim.HostVirtualSwitchBondBridge] @{
                                    NicDevice = @($($script:NicDeviceAlt))
                                    Beacon = [VMware.Vim.HostVirtualSwitchBeaconConfig] @{
                                        Interval = '$($script:BeaconIntervalAlt)'
                                    }
                                    LinkDiscoveryProtocolConfig = [VMware.Vim.LinkDiscoveryProtocolConfig] @{
                                        Operation = '$($script:LinkDiscoveryProtocolOperationAlt)'
                                        Protocol = '$($script:LinkDiscoveryProtocolProtocolAlt)'
                                    }
                                }
                            }
                        }
                    )
                }
            }
        )
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

    $script:viServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{
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

    Describe 'VMHostVssBridge\Set'  -Tag 'Set' {
        Context 'Present and no Bridge settings' {
            BeforeAll {
                $viserverMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:viServerCode))
                $vmHostMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vmHostCode))
                $networkSystemMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:networkSystemNoVssBridgeCode))
                $updateNetworkMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:updateNetworkCode))
            }

            # Arrange
            Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
            Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $networkSystemMock -ModuleName $script:moduleName
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
                    Times = 1
                    Scope = 'It'
                }
                Assert-MockCalled @assertMockCalledParams
            }

            It 'Should not call Update-Network' {
                # Act
                $result = $resource.Set()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Update-Network'
                    ParameterFilter = { $VssBridgeConfig -ne $null -and $VssBridgeConfig.Operation -eq $script:netObjectEdit.Operation }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 0
                    Scope = 'It'
                }
                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Present and same Bridge settings' {
            BeforeAll {
                $viserverMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:viServerCode))
                $vmHostMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vmHostCode))
                $networkSystemMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:networkSystemSameVssBridgeCode))
                $updateNetworkMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:updateNetworkCode))
            }

            # Arrange
            Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
            Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $networkSystemMock -ModuleName $script:moduleName
            Mock -CommandName Update-Network -MockWith $updateNetworkMock -ModuleName $script:moduleName

            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should not call Update-Network' {
                # Act
                $result = $resource.Set()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Update-Network'
                    ParameterFilter = { $null -ne $VssBridgeConfig -and $VssBridgeConfig.Operation -eq $script:netObjectEdit }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 0
                    Scope = 'It'
                }
                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Present and different Bridge settings' {
            BeforeAll {
                $viserverMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:viServerCode))
                $vmHostMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vmHostCode))
                $networkSystemMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:networkSystemDiffVssBridgeCode))
                $updateNetworkMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:updateNetworkCode))
            }

            # Arrange
            Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
            Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $networkSystemMock -ModuleName $script:moduleName
            Mock -CommandName Update-Network -MockWith $updateNetworkMock -ModuleName $script:moduleName

            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call Update-Network once with VssConfig and operation Edit' {
                # Act
                $result = $resource.Set()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Update-Network'
                    ParameterFilter = { $null -ne $VssBridgeConfig -and $VssBridgeConfig.Operation -eq $script:netObjectEdit }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }
                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Absent and Bridge settings' {
            BeforeAll {
                $viserverMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:viServerCode))
                $vmHostMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vmHostCode))
                $networkSystemMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:networkSystemSameVssBridgeCode))
                $updateNetworkMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:updateNetworkCode))
            }

            # Arrange
            Mock -CommandName Connect-VIServer -MockWith $viserverMock -ModuleName $script:moduleName
            Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $networkSystemMock -ModuleName $script:moduleName
            Mock -CommandName Update-Network -MockWith $updateNetworkMock -ModuleName $script:moduleName

            $resource = New-Object -TypeName $script:resourceName -Property $script:resourcePropertiesAbsent

            It 'Should call Update-Network once with VssBridgeConfig and operation Edit' {
                # Act
                $result = $resource.Set()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Update-Network'
                    ParameterFilter = { $null -ne $VssBridgeConfig -and $VssBridgeConfig.Operation -eq $script:netObjectEdit }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }
                Assert-MockCalled @assertMockCalledParams
            }
        }
    }

    Describe 'VMHostVssBridge\Test' -Tag 'Test' {
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

        Context 'Present, VSS exists and Bridge with the same properties' {
            BeforeAll {
                $viserverMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:viServerCode))
                $vmHostMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vmHostCode))
                $networkSystemMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:networkSystemSameVssBridgeCode))
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

        Context 'Present, VSS exists and Bridge with different properties' {
            BeforeAll {
                $viserverMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:viServerCode))
                $vmHostMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vmHostCode))
                $networkSystemMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:networkSystemDiffVssBridgeCode))
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

            It 'Should return $true (The VSS does not exist)' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $true
            }
        }

        Context 'Absent, VSS exists and Bridge with the default properties' {
            BeforeAll {
                $viserverMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:viServerCode))
                $vmHostMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vmHostCode))
                $networkSystemMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:networkSystemUnsetVssBridgeCode))
            }

            # Arrange
            Mock -CommandName Connect-VIServer -MockWith $viserverMock -ModuleName $script:moduleName
            Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $networkSystemMock -ModuleName $script:moduleName

            $resource = New-Object -TypeName $script:resourceName -Property $script:resourcePropertiesAbsent

            It 'Should return $false (The VSS exists and Bridge has the default properties)' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $false
            }
        }

        Context 'Absent, VSS exists and Bridge with non-default properties' {
            BeforeAll {
                $viserverMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:viServerCode))
                $vmHostMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vmHostCode))
                $networkSystemMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:networkSystemDiffVssBridgeCode))
            }

            # Arrange
            Mock -CommandName Connect-VIServer -MockWith $viserverMock -ModuleName $script:moduleName
            Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $networkSystemMock -ModuleName $script:moduleName

            $resource = New-Object -TypeName $script:resourceName -Property $script:resourcePropertiesAbsent

            It 'Should return $false (The VSS exists, and Bridge does not have the default properties)' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $false
            }
        }
    }

    Describe 'VMHostVssBridge\Get' -Tag 'Get' {
        BeforeAll {
            $viserverMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:viServerCode))
            $vmHostMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vmHostCode))
            $networkSystemMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:networkSystemSameVssBridgeCode))
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
            $result.NicDevice | Should -Be $script:resourceProperties.NicDevice
            $result.BeaconInterval | Should -Be $script:resourceProperties.BeaconInterval
            $result.LinkDiscoveryProtocolProtocol | Should -Be $script:resourceProperties.LinkDiscoveryProtocolProtocol
            $result.LinkDiscoveryProtocolOperation | Should -Be $script:resourceProperties.LinkDiscoveryProtocolOperation
        }
    }
}
finally {
    # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
    Invoke-TestCleanup
}
