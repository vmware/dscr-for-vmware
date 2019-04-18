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
    $script:resourceName = 'VMHostVssTeaming'

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
        CheckBeacon = $false
        ActiveNic = @()
        StandbyNic = @()
        NotifySwitches = $true
        Policy = "LoadBalance_SrcId"
        RollingOrder = $false
    }
    $script:resourcePropertiesAbsent = $script:resourceProperties.Clone()
    $script:resourcePropertiesAbsent.Ensure = 'Absent'
    $script:ActiveNicAlt = "'vmnic2', 'vmnic3'"
    $script:StandbyNicAlt = "'vmnic6', 'vmnic7'"
    $script:PolicyAlt = "LoadBalance_IP"
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
    $script:networkSystemDiffVssTeamingCode = @'
        return (
            [VMware.Vim.HostNetworkSystem] @{
                NetworkInfo = [VMware.Vim.HostNetworkInfo] @{
                    vswitch = @(
                        [VMware.Vim.HostVirtualSwitch]@{
                            Name = '$($script:resourceProperties.VssName)'
                            Spec = [VMware.Vim.HostVirtualSwitchSpec] @{
                                Policy = [VMware.Vim.HostNetworkPolicy] @{
                                    NicTeaming = [VMware.Vim.HostNicTeamingPolicy] @{
                                        FailureCriteria = [VMware.Vim.HostNicFailureCriteria] @{
                                            CheckBeacon = `$$(-not $script:resourceProperties.CheckBeacon)
                                        }
                                        NicOrder = [VMware.Vim.HostNicOrderPolicy] @{
                                            ActiveNic = @($($script:ActiveNicAlt))
                                            StandbyNic = @($($script:StandbyNicAlt))
                                        }
                                        NotifySwitches = `$$(-not $script:resourceProperties.NotifySwitches)
                                        Policy = '$($script:PolicyAlt)'
                                        RollingOrder = `$$(-not $script:resourceProperties.RollingOrder)
                                    }
                                }
                            }
                        }
                    )
                }
            }
        )
'@
    $script:networkSystemSameVssTeamingCode = @'
        return (
            [VMware.Vim.HostNetworkSystem] @{
                NetworkInfo = [VMware.Vim.HostNetworkInfo] @{
                    vswitch = @(
                        [VMware.Vim.HostVirtualSwitch]@{
                            Name = '$($script:resourceProperties.VssName)'
                            Spec = [VMware.Vim.HostVirtualSwitchSpec] @{
                                Policy = [VMware.Vim.HostNetworkPolicy] @{
                                    NicTeaming = [VMware.Vim.HostNicTeamingPolicy] @{
                                        FailureCriteria = [VMware.Vim.HostNicFailureCriteria] @{
                                            CheckBeacon = `$$($script:resourceProperties.CheckBeacon)
                                        }
                                        NicOrder = [VMware.Vim.HostNicOrderPolicy] @{
                                            ActiveNic = @($($script:resourceProperties.ActiveNic))
                                            StandbyNic = @($($script:resourceProperties.StandbyNic))
                                        }
                                        NotifySwitches = `$$($script:resourceProperties.NotifySwitches)
                                        Policy = '$($script:resourceProperties.Policy)'
                                        RollingOrder = `$$($script:resourceProperties.RollingOrder)
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

    Describe 'VMHostVssTeaming\Set'  -Tag 'Set' {
        Context 'Present and default Teaming properties' {
            BeforeAll {
                $viserverMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:viServerCode))
                $vmHostMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vmHostCode))
                $networkSystemMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:networkSystemSameVssTeamingCode))
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
                    ParameterFilter = { $VssTeamingConfig -ne $null -and $VssTeamingConfig.Operation -eq $script:netObjectEdit.Operation }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 0
                    Scope = 'It'
                }
                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Present and different teaming properties' {
            BeforeAll {
                $viserverMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:viServerCode))
                $vmHostMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vmHostCode))
                $networkSystemMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:networkSystemDiffVssTeamingCode))
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
                    ParameterFilter = { $null -ne $VssTeamingConfig -and $VssTeamingConfig.Operation -eq $script:netObjectEdit  }
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
                $networkSystemMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:networkSystemDiffVssTeamingCode))
                $updateNetworkMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:updateNetworkCode))
            }

            # Arrange
            Mock -CommandName Connect-VIServer -MockWith $viserverMock -ModuleName $script:moduleName
            Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $networkSystemMock -ModuleName $script:moduleName
            Mock -CommandName Update-Network -MockWith $updateNetworkMock -ModuleName $script:moduleName

            $resource = New-Object -TypeName $script:resourceName -Property $script:resourcePropertiesAbsent

            It 'Should call Update-Network once with VssTeamingConfig and operation Edit' {
                # Act
                $result = $resource.Set()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Update-Network'
                    ParameterFilter = { $null -ne $VssTeamingConfig -and $VssTeamingConfig.Operation -eq $script:netObjectEdit  }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }
                Assert-MockCalled @assertMockCalledParams
            }
        }
    }

    Describe 'VMHostVssTeaming\Test' -Tag 'Test' {
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

        Context 'Present, VSS exists and teaming with different properties' {
            BeforeAll {
                $viserverMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:viServerCode))
                $vmHostMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vmHostCode))
                $networkSystemMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:networkSystemDiffVssTeamingCode))
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

        Context 'Present, VSS exists and teaming with the same properties' {
            BeforeAll {
                $viserverMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:viServerCode))
                $vmHostMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vmHostCode))
                $networkSystemMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:networkSystemSameVssTeamingCode))
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

        Context 'Absent, VSS exists and not default teaming properties' {
            BeforeAll {
                $viserverMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:viServerCode))
                $vmHostMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vmHostCode))
                $networkSystemMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:networkSystemDiffVssTeamingCode))
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

        Context 'Absent, VSS exists and default teaming properties' {
            BeforeAll {
                $viserverMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:viServerCode))
                $vmHostMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vmHostCode))
                $networkSystemMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:networkSystemSameVssTeamingCode))
            }

            # Arrange
            Mock -CommandName Connect-VIServer -MockWith $viserverMock -ModuleName $script:moduleName
            Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $networkSystemMock -ModuleName $script:moduleName

            $resource = New-Object -TypeName $script:resourceName -Property $script:resourcePropertiesAbsent

            It 'Should return $true (The VSS exists, but teaming settings are defaults)' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $true
            }
        }
    }

    Describe 'VMHostVssTeaming\Get' -Tag 'Get' {
        BeforeAll {
            $viserverMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:viServerCode))
            $vmHostMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vmHostCode))
            $networkSystemMock = [scriptblock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:networkSystemSameVssTeamingCode))
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
            $result.AverageBandwidth | Should -Be $script:resourceProperties.AverageBandwidth
            $result.BurstSize | Should -Be $script:resourceProperties.BurstSize
            $result.Enabled | Should -Be $script:resourceProperties.Enabled
            $result.PeakBandwidth | Should -Be $script:resourceProperties.PeakBandwidth
        }
    }
}
finally {
    # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
    Invoke-TestCleanup
}
