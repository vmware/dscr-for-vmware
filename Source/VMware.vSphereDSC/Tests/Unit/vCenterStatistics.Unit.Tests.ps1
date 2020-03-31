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
$script:resourceName = 'vCenterStatistics'

$user = 'user'
$password = 'password' | ConvertTo-SecureString -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($user, $password)

$script:resourceProperties = @{
    Server = '10.23.82.112'
    Credential = $credential
    Period = 'Month'
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

    Describe 'vCenterStatistics\Set' -Tag 'Set' {
        AfterEach {
            $script:resourceProperties.PeriodLength = $null
            $script:resourceProperties.Level = $null
            $script:resourceProperties.Enabled = $null
            $script:resourceProperties.IntervalMinutes = $null
        }

        Context 'Invoking with default resource properties' {
            BeforeAll {
                $vCenter = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user'; ExtensionData = `
                [VMware.Vim.ServiceInstance] @{ Content = [VMware.Vim.ServiceContent] @{ PerfManager = `
                [VMware.Vim.ManagedObjectReference] @{ Type = 'PerformanceManager'; Value = 'PerfMgr' } } } }
                $perfManagerMoRef = [VMware.Vim.ManagedObjectReference] @{ Type = 'PerformanceManager'; Value = 'PerfMgr' }
                $perfManager = [VMware.Vim.PerformanceManager] @{ HistoricalInterval = @([VMware.Vim.PerfInterval] @{ Key = 1; Name = 'Month'; Enabled = $false; `
                SamplingPeriod = 600; Length = 2629800; Level = 1 }) }
                $perfInterval = [VMware.Vim.PerfInterval] @{ Key = 1; Name = 'Month'; Enabled = $false; SamplingPeriod = 600; Length = 2629800; Level = 1 }

                # Arrange
                $vCenterMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user'; ExtensionData = `
                    [VMware.Vim.ServiceInstance] @{ Content = [VMware.Vim.ServiceContent] @{ PerfManager = `
                    [VMware.Vim.ManagedObjectReference] @{ Type = 'PerformanceManager'; Value = 'PerfMgr' } } } }
                }
                $performanceManagerMock = {
                    return [VMware.Vim.PerformanceManager] @{ HistoricalInterval = @([VMware.Vim.PerfInterval] @{ Key = 1; Name = 'Month'; Enabled = $false; `
                                                              SamplingPeriod = 600; Length = 2629800; Level = 1 }) }
                }
                $performanceIntervalMock = {
                    return [VMware.Vim.PerfInterval] @{ Key = 1; Name = 'Month'; Enabled = $false; SamplingPeriod = 600; Length = 2629800; Level = 1 }
                }

                Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $performanceManagerMock -ModuleName $script:moduleName
                Mock -CommandName New-PerformanceInterval -MockWith $performanceIntervalMock -ModuleName $script:moduleName
                Mock -CommandName Update-PerfInterval -MockWith { return $null } -ModuleName $script:moduleName
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

            It 'Should call the Get-View mock with the PerformanceManager once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Get-View `
                                  -ParameterFilter { $Server -eq $vCenter -and $Id -eq $perfManagerMoRef } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call the New-PerformanceInterval mock with the Performance Interval once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName New-PerformanceInterval `
                                  -ParameterFilter { $Key -eq $perfInterval.Key -and $Name -eq $perfInterval.Name -and $Enabled -eq $perfInterval.Enabled -and `
                                                     $SamplingPeriod -eq $perfInterval.SamplingPeriod -and $Length -eq $perfInterval.Length -and $Level -eq $perfInterval.Level } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call the Update-PerfInterval mock with the Performance Manager and Performance Interval once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Update-PerfInterval `
                                  -ParameterFilter { $PerformanceManager -eq $perfManager -and $PerformanceInterval -eq $perfInterval } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }
        }

        Context 'Invoking with specified resource properties' {
            BeforeAll {
                $script:resourceProperties.PeriodLength = 2
                $script:resourceProperties.Level = 2
                $script:resourceProperties.Enabled = $true
                $script:resourceProperties.IntervalMinutes = 30

                $perfInterval = [VMware.Vim.PerfInterval] @{ Key = 1; Name = 'Month'; Enabled = $true; `
                                                             SamplingPeriod = 30 * 60; Length = 2 * 2629800; `
                                                             Level = 2 }

                # Arrange
                $vCenterMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user'; ExtensionData = `
                    [VMware.Vim.ServiceInstance] @{ Content = [VMware.Vim.ServiceContent] @{ PerfManager = `
                    [VMware.Vim.ManagedObjectReference] @{ Type = 'PerformanceManager'; Value = 'PerfMgr' } } } }
                }
                $performanceManagerMock = {
                    return [VMware.Vim.PerformanceManager] @{ HistoricalInterval = @([VMware.Vim.PerfInterval] @{ Key = 1; Name = 'Month'; Enabled = $false; `
                                                              SamplingPeriod = 600; Length = 2629800; Level = 1 }) }
                }
                $performanceIntervalMock = {
                    return [VMware.Vim.PerfInterval] @{ Key = 1; Name = 'Month'; Enabled = $true; SamplingPeriod = 30 * 60; Length = 2 * 2629800; Level = 2 }
                }

                Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $performanceManagerMock -ModuleName $script:moduleName
                Mock -CommandName New-PerformanceInterval -MockWith $performanceIntervalMock -ModuleName $script:moduleName
                Mock -CommandName Update-PerfInterval -MockWith { return $null } -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call the New-PerformanceInterval mock with the Performance Interval once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName New-PerformanceInterval `
                                  -ParameterFilter { $Key -eq $perfInterval.Key -and $Name -eq $perfInterval.Name -and $Enabled -eq $perfInterval.Enabled -and `
                                                     $SamplingPeriod -eq $perfInterval.SamplingPeriod -and $Length -eq $perfInterval.Length -and $Level -eq $perfInterval.Level } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call the Update-PerfInterval mock with the Performance Manager and Performance Interval once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Update-PerfInterval `
                                  -ParameterFilter { $PerformanceManager -eq $perfManager -and $PerformanceInterval -eq $perfInterval } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }
        }
    }

    Describe 'vCenterStatistics\Test' -Tag 'Test' {
        AfterEach {
            $script:resourceProperties.PeriodLength = $null
            $script:resourceProperties.Level = $null
            $script:resourceProperties.Enabled = $null
            $script:resourceProperties.IntervalMinutes = $null
        }

        Context 'Invoking with default resource properties' {
            BeforeAll {
                $vCenter = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user'; ExtensionData = `
                [VMware.Vim.ServiceInstance] @{ Content = [VMware.Vim.ServiceContent] @{ PerfManager = `
                [VMware.Vim.ManagedObjectReference] @{ Type = 'PerformanceManager'; Value = 'PerfMgr' } } } }
                $perfManagerMoRef = [VMware.Vim.ManagedObjectReference] @{ Type = 'PerformanceManager'; Value = 'PerfMgr' }
                $perfManager = [VMware.Vim.PerformanceManager] @{}

                # Arrange
                $vCenterMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user'; ExtensionData = `
                    [VMware.Vim.ServiceInstance] @{ Content = [VMware.Vim.ServiceContent] @{ PerfManager = `
                    [VMware.Vim.ManagedObjectReference] @{ Type = 'PerformanceManager'; Value = 'PerfMgr' } } } }
                }
                $performanceManagerMock = {
                    return [VMware.Vim.PerformanceManager] @{ HistoricalInterval = @([VMware.Vim.PerfInterval] @{ Key = 1; Name = 'Month'; Enabled = $false; `
                                                              SamplingPeriod = 600; Length = 2629800; Level = 1 }) }
                }

                Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $performanceManagerMock -ModuleName $script:moduleName
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

            It 'Should call the Get-View mock with the PerformanceManager once' {
                # Act
                $resource.Test()

                # Assert
                Assert-MockCalled -CommandName Get-View `
                                  -ParameterFilter { $Server -eq $vCenter -and $Id -eq $perfManagerMoRef } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should return $true (The Statistics Settings are in the desired state)' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $true
            }
        }

        Context 'Invoking with different Level Setting' {
            BeforeAll {
                $script:resourceProperties.PeriodLength = 1
                $script:resourceProperties.Level = 2
                $script:resourceProperties.Enabled = $false
                $script:resourceProperties.IntervalMinutes = 10

                # Arrange
                $vCenterMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user'; ExtensionData = `
                    [VMware.Vim.ServiceInstance] @{ Content = [VMware.Vim.ServiceContent] @{ PerfManager = `
                    [VMware.Vim.ManagedObjectReference] @{ Type = 'PerformanceManager'; Value = 'PerfMgr' } } } }
                }
                $performanceManagerMock = {
                    return [VMware.Vim.PerformanceManager] @{ HistoricalInterval = @([VMware.Vim.PerfInterval] @{ Key = 1; Name = 'Month'; Enabled = $false; `
                                                              SamplingPeriod = 600; Length = 2629800; Level = 1 }) }
                }

                Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $performanceManagerMock -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should return $false (The Statistics Settings are not in the desired state)' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $false
            }
        }

        Context 'Invoking with different Enabled Setting' {
            BeforeAll {
                $script:resourceProperties.PeriodLength = 1
                $script:resourceProperties.Level = 1
                $script:resourceProperties.Enabled = $true
                $script:resourceProperties.IntervalMinutes = 10

                # Arrange
                $vCenterMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user'; ExtensionData = `
                    [VMware.Vim.ServiceInstance] @{ Content = [VMware.Vim.ServiceContent] @{ PerfManager = `
                    [VMware.Vim.ManagedObjectReference] @{ Type = 'PerformanceManager'; Value = 'PerfMgr' } } } }
                }
                $performanceManagerMock = {
                    return [VMware.Vim.PerformanceManager] @{ HistoricalInterval = @([VMware.Vim.PerfInterval] @{ Key = 1; Name = 'Month'; Enabled = $false; `
                                                              SamplingPeriod = 600; Length = 2629800; Level = 1 }) }
                }

                Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $performanceManagerMock -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should return $false (The Statistics Settings are not in the desired state)' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $false
            }
        }

        Context 'Invoking with different Period Length Setting' {
            BeforeAll {
                $script:resourceProperties.PeriodLength = 2
                $script:resourceProperties.Level = 1
                $script:resourceProperties.Enabled = $false
                $script:resourceProperties.IntervalMinutes = 10

                # Arrange
                $vCenterMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user'; ExtensionData = `
                    [VMware.Vim.ServiceInstance] @{ Content = [VMware.Vim.ServiceContent] @{ PerfManager = `
                    [VMware.Vim.ManagedObjectReference] @{ Type = 'PerformanceManager'; Value = 'PerfMgr' } } } }
                }
                $performanceManagerMock = {
                    return [VMware.Vim.PerformanceManager] @{ HistoricalInterval = @([VMware.Vim.PerfInterval] @{ Key = 1; Name = 'Month'; Enabled = $false; `
                                                              SamplingPeriod = 600; Length = 2629800; Level = 1 }) }
                }

                Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $performanceManagerMock -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should return $false (The Statistics Settings are not in the desired state)' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $false
            }
        }

        Context 'Invoking with different Interval Minutes Setting' {
            BeforeAll {
                $script:resourceProperties.PeriodLength = 1
                $script:resourceProperties.Level = 1
                $script:resourceProperties.Enabled = $false
                $script:resourceProperties.IntervalMinutes = 20

                # Arrange
                $vCenterMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user'; ExtensionData = `
                    [VMware.Vim.ServiceInstance] @{ Content = [VMware.Vim.ServiceContent] @{ PerfManager = `
                    [VMware.Vim.ManagedObjectReference] @{ Type = 'PerformanceManager'; Value = 'PerfMgr' } } } }
                }
                $performanceManagerMock = {
                    return [VMware.Vim.PerformanceManager] @{ HistoricalInterval = @([VMware.Vim.PerfInterval] @{ Key = 1; Name = 'Month'; Enabled = $false; `
                                                              SamplingPeriod = 600; Length = 2629800; Level = 1 }) }
                }

                Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $performanceManagerMock -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should return $false (The Statistics Settings are not in the desired state)' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $false
            }
        }

        Context 'Invoking with the same Statistics Settings' {
            BeforeAll {
                $script:resourceProperties.PeriodLength = 1
                $script:resourceProperties.Level = 1
                $script:resourceProperties.Enabled = $false
                $script:resourceProperties.IntervalMinutes = 10

                # Arrange
                $vCenterMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user'; ExtensionData = `
                    [VMware.Vim.ServiceInstance] @{ Content = [VMware.Vim.ServiceContent] @{ PerfManager = `
                    [VMware.Vim.ManagedObjectReference] @{ Type = 'PerformanceManager'; Value = 'PerfMgr' } } } }
                }
                $performanceManagerMock = {
                    return [VMware.Vim.PerformanceManager] @{ HistoricalInterval = @([VMware.Vim.PerfInterval] @{ Key = 1; Name = 'Month'; Enabled = $false; `
                                                              SamplingPeriod = 600; Length = 2629800; Level = 1 }) }
                }

                Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
                Mock -CommandName Get-View -MockWith $performanceManagerMock -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should return $true (The Statistics Settings are in the desired state)' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $true
            }
        }
    }

    Describe 'vCenterStatistics\Get' -Tag 'Get' {
        AfterEach {
            $script:resourceProperties.PeriodLength = $null
            $script:resourceProperties.Level = $null
            $script:resourceProperties.Enabled = $null
            $script:resourceProperties.IntervalMinutes = $null
        }

        BeforeAll {
            $vCenter = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user'; ExtensionData = `
            [VMware.Vim.ServiceInstance] @{ Content = [VMware.Vim.ServiceContent] @{ PerfManager = `
            [VMware.Vim.ManagedObjectReference] @{ Type = 'PerformanceManager'; Value = 'PerfMgr' } } } }
            $perfManagerMoRef = [VMware.Vim.ManagedObjectReference] @{ Type = 'PerformanceManager'; Value = 'PerfMgr' }
            $perfManager = [VMware.Vim.PerformanceManager] @{}
            $perfInterval = [VMware.Vim.PerfInterval] @{ Key = 1; Name = 'Month'; Enabled = $false; SamplingPeriod = 600; Length = 2629800; Level = 1 }

            # Arrange
            $vCenterMock = {
                return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user'; ExtensionData = `
                [VMware.Vim.ServiceInstance] @{ Content = [VMware.Vim.ServiceContent] @{ PerfManager = `
                [VMware.Vim.ManagedObjectReference] @{ Type = 'PerformanceManager'; Value = 'PerfMgr' } } } }
            }
            $performanceManagerMock = {
                return [VMware.Vim.PerformanceManager] @{ HistoricalInterval = @([VMware.Vim.PerfInterval] @{ Key = 1; Name = 'Month'; Enabled = $false; `
                                                          SamplingPeriod = 600; Length = 2629800; Level = 1 }) }
            }

            Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
            Mock -CommandName Get-View -MockWith $performanceManagerMock -ModuleName $script:moduleName
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

        It 'Should call the Get-View mock with the PerformanceManager once' {
            # Act
            $resource.Get()

            # Assert
            Assert-MockCalled -CommandName Get-View `
                              -ParameterFilter { $Server -eq $vCenter -and $Id -eq $perfManagerMoRef } `
                              -ModuleName $script:moduleName -Exactly 1 -Scope It
        }

        It 'Should return the Resource with the properties retrieved from the server' {
            # Act
            $result = $resource.Get()

            # Assert
            $result.Server | Should -Be $script:resourceProperties.Server
            $result.Period | Should -Be $script:resourceProperties.Period
            $result.Enabled | Should -Be $perfInterval.Enabled
            $result.Level | Should -Be $perfInterval.Level
            $result.IntervalMinutes | Should -Be ($perfInterval.SamplingPeriod / 60)
            $result.PeriodLength | Should -Be ($perfInterval.Length / 2629800)
        }
    }
}
finally {
    # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
    Invoke-TestCleanup
}
