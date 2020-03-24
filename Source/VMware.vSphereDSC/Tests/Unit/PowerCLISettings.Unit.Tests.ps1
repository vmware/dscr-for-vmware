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
$script:resourceName = 'PowerCLISettings'

$script:resourceProperties = @{
    SettingsScope = 'LCM'
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

    Describe 'PowerCLISettings\Set' -Tag 'Set' {
        Context 'Invoking without PowerCLIConfiguration properties passed' {
            BeforeAll {
                # Arrange
                Mock -CommandName Set-PowerCLIConfiguration -MockWith { return $null } -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call the Set-PowerCLIConfiguration mock with only the User Scope once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Set-PowerCLIConfiguration `
                                  -ParameterFilter { $Scope -eq 'User' } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }
        }

        Context 'Invoking with CEIPDataTransferProxyPolicy, DefaultVIServerMode, InvalidCertificateAction and ProxyPolicy PowerCLIConfiguration properties passed' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.CEIPDataTransferProxyPolicy = 'UseSystemProxy'
                $script:resourceProperties.DefaultVIServerMode = 'Multiple'
                $script:resourceProperties.InvalidCertificateAction = 'Fail'
                $script:resourceProperties.ProxyPolicy = 'UseSystemProxy'

                Mock -CommandName Set-PowerCLIConfiguration -MockWith { return $null } -ModuleName $script:moduleName
            }

            AfterAll {
                $script:resourceProperties.CEIPDataTransferProxyPolicy = 'Unset'
                $script:resourceProperties.DefaultVIServerMode = 'Unset'
                $script:resourceProperties.InvalidCertificateAction = 'Unset'
                $script:resourceProperties.ProxyPolicy = 'Unset'
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call the Set-PowerCLIConfiguration mock with User Scope, DefaultVIServerMode, InvalidCertificateAction and ProxyPolicy once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Set-PowerCLIConfiguration `
                                  -ParameterFilter { $Scope -eq 'User' -and $DefaultVIServerMode -eq 'Multiple' -and $InvalidCertificateAction -eq 'Fail' -and $ProxyPolicy -eq 'UseSystemProxy' } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }
        }

        Context 'Invoking with DisplayDeprecationWarnings, ParticipateInCeip and WebOperationTimeoutSeconds PowerCLIConfiguration properties passed' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.DisplayDeprecationWarnings = $true
                $script:resourceProperties.ParticipateInCeip = $false
                $script:resourceProperties.WebOperationTimeoutSeconds = 100

                Mock -CommandName Set-PowerCLIConfiguration -MockWith { return $null } -ModuleName $script:moduleName
            }

            AfterAll {
                $script:resourceProperties.DisplayDeprecationWarnings = $null
                $script:resourceProperties.ParticipateInCeip = $null
                $script:resourceProperties.WebOperationTimeoutSeconds = $null
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call the Set-PowerCLIConfiguration mock with User Scope, DisplayDeprecationWarnings, ParticipateInCeip and WebOperationTimeoutSeconds once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Set-PowerCLIConfiguration `
                                  -ParameterFilter { $Scope -eq 'User' -and $DisplayDeprecationWarnings -eq $true -and $ParticipateInCeip -eq $false -and $WebOperationTimeoutSeconds -eq 100 } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }
        }
    }

    Describe 'PowerCLISettings\Test' -Tag 'Test' {
        Context 'Invoking with equal PowerCLIConfiguration properties passed' {
            BeforeAll {
                # Arrange
                $powerCLIConfigurationMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.PowerCLIConfigurationImpl] @{ Scope = 'User'; CEIPDataTransferProxyPolicy = [VMware.VimAutomation.ViCore.Types.V1.ProxyPolicy]::UseSystemProxy; `
                                                                 DisplayDeprecationWarnings = $true; WebOperationTimeoutSeconds = 100 }
                }

                $script:resourceProperties.CEIPDataTransferProxyPolicy = 'UseSystemProxy'
                $script:resourceProperties.DisplayDeprecationWarnings = $true
                $script:resourceProperties.WebOperationTimeoutSeconds = 100

                Mock -CommandName Get-PowerCLIConfiguration -MockWith $powerCLIConfigurationMock -ModuleName $script:moduleName
            }

            AfterAll {
                $script:resourceProperties.CEIPDataTransferProxyPolicy = 'Unset'
                $script:resourceProperties.DisplayDeprecationWarnings = $null
                $script:resourceProperties.WebOperationTimeoutSeconds = $null
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call the Get-PowerCLIConfiguration mock with User Scope once' {
                # Act
                $resource.Test()

                # Assert
                Assert-MockCalled -CommandName Get-PowerCLIConfiguration `
                                  -ParameterFilter { $Scope -eq 'User' } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call return $true (The configuration properties are equal)' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $true
            }
        }

        Context 'Invoking with not equal PowerCLIConfiguration properties passed' {
            BeforeAll {
                # Arrange
                $powerCLIConfigurationMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.PowerCLIConfigurationImpl] @{ Scope = 'User'; CEIPDataTransferProxyPolicy = [VMware.VimAutomation.ViCore.Types.V1.ProxyPolicy]::UseSystemProxy; `
                                                                 DisplayDeprecationWarnings = $true; WebOperationTimeoutSeconds = 100 }
                }

                $script:resourceProperties.CEIPDataTransferProxyPolicy = 'UseSystemProxy'
                $script:resourceProperties.DisplayDeprecationWarnings = $true
                $script:resourceProperties.WebOperationTimeoutSeconds = 200

                Mock -CommandName Get-PowerCLIConfiguration -MockWith $powerCLIConfigurationMock -ModuleName $script:moduleName
            }

            AfterAll {
                $script:resourceProperties.CEIPDataTransferProxyPolicy = 'Unset'
                $script:resourceProperties.DisplayDeprecationWarnings = $null
                $script:resourceProperties.WebOperationTimeoutSeconds = $null
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call the Get-PowerCLIConfiguration mock with User Scope once' {
                # Act
                $resource.Test()

                # Assert
                Assert-MockCalled -CommandName Get-PowerCLIConfiguration `
                                  -ParameterFilter { $Scope -eq 'User' } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call return $false (The configuration properties are not equal)' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $false
            }
        }
    }

    Describe 'PowerCLISettings\Get' -Tag 'Get' {
        BeforeAll {
            # Arrange
            $powerCLIConfigurationMock = {
                return [VMware.VimAutomation.ViCore.Impl.V1.PowerCLIConfigurationImpl] @{ Scope = 'User'; CEIPDataTransferProxyPolicy = [VMware.VimAutomation.ViCore.Types.V1.ProxyPolicy]::UseSystemProxy; `
                                                             DefaultVIServerMode = [VMware.VimAutomation.ViCore.Types.V1.DefaultVIServerMode]::Multiple; InvalidCertificateAction = [VMware.VimAutomation.ViCore.Types.V1.BadCertificateAction]::Fail; `
                                                             ParticipateInCeip = $false; ProxyPolicy = [VMware.VimAutomation.ViCore.Types.V1.ProxyPolicy]::UseSystemProxy; DisplayDeprecationWarnings = $true; `
                                                             WebOperationTimeoutSeconds = 100 }
            }

            Mock -CommandName Get-PowerCLIConfiguration -MockWith $powerCLIConfigurationMock -ModuleName $script:moduleName
        }

        # Arrange
        $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

        It 'Should call the Get-PowerCLIConfiguration mock with User Scope once' {
            # Act
            $resource.Get()

            # Assert
            Assert-MockCalled -CommandName Get-PowerCLIConfiguration `
                              -ParameterFilter { $Scope -eq 'User' } `
                              -ModuleName $script:moduleName -Exactly 1 -Scope It
        }

        It 'Should match the properties retrieved from the server' {
            # Act
            $result = $resource.Get()

            # Assert
            $result.SettingsScope | Should -Be $script:resourceProperties.SettingsScope
            $result.CEIPDataTransferProxyPolicy | Should -Be 'UseSystemProxy'
            $result.DefaultVIServerMode | Should -Be 'Multiple'
            $result.DisplayDeprecationWarnings | Should -Be $true
            $result.InvalidCertificateAction | Should -Be 'Fail'
            $result.ParticipateInCeip | Should -Be $false
            $result.ProxyPolicy | Should -Be 'UseSystemProxy'
            $result.WebOperationTimeoutSeconds | Should -Be 100
        }
    }
}
finally {
    # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
    Invoke-TestCleanup
}
