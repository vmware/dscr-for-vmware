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
    $script:resourceName = 'VMHostAccount'

    $script:user = 'user'
    $password = 'password' | ConvertTo-SecureString -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential($script:user, $password)

    $script:resourceProperties = @{
        Server = '10.23.80.58'
        Credential = $credential
        Id = 'MyCustomVMHostAccount'
        Ensure = 'Present'
    }

    $script:constants = @{
        AccountPassword = 'MyCustomVMHostAccountPassword'
        Description = 'MyCustomVMHostAccountDescription'
        GrantShellAccess = $true
    }

    $script:viServerScriptBlock = @'
        return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{
            Name = '$($script:resourceProperties.Server)'
            User = '$($script:user)'
        }
'@

    $script:vmHostAccountScriptBlock = @'
        return [VMware.VimAutomation.ViCore.Impl.V1.Host.Account.HostUserAccountImpl] @{
            Id = '$($script:resourceProperties.Id)'
            Name = '$($script:resourceProperties.Name)'
            Description = '$($script:constants.Description)'
            ShellAccessEnabled = '$($script:constants.GrantShellAccess)'
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
        User = $script:user
    }

    $script:vmHostAccount = [VMware.VimAutomation.ViCore.Impl.V1.Host.Account.HostUserAccountImpl] @{
        Id = $script:resourceProperties.Id
        Name = $script:resourceProperties.Name
        Description = $script:constants.Description
        ShellAccessEnabled = $script:constants.GrantShellAccess
    }
}

function Invoke-TestCleanup {
    Remove-Module -Name VMware.VimAutomation.Core
    $env:PSModulePath = $script:modulePath
}

try {
    # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
    Invoke-TestSetup

    Describe 'VMHostAccount\Set' -Tag 'Set' {
        BeforeEach {
            # Arrange
            $viServerMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:viServerScriptBlock))

            Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
        }

        Context 'Invoking with Ensure Absent, non existing VMHostAccount and only Account Id specified' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Ensure = 'Absent'

                Mock -CommandName Get-VMHostAccount -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.Ensure = 'Present'
            }

            It 'Should call the Get-VMHostAccount mock with the VIServer and VMHost Account Id once' {
                # Act
                $resource.Set()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-VMHostAccount'
                    ParameterFilter = { $Server -eq $script:viServer -and $Id -eq $script:resourceProperties.Id }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Invoking with Ensure Present, non existing VMHost Account and only Account Password specified' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.AccountPassword = $script:constants.AccountPassword

                Mock -CommandName Get-VMHostAccount -MockWith { return $null } -ModuleName $script:moduleName
                Mock -CommandName New-VMHostAccount -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.Remove('AccountPassword')
            }

            It 'Should call the New-VMHostAccount mock with the VIServer, VMHost Account Id and Password once' {
                # Act
                $resource.Set()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'New-VMHostAccount'
                    ParameterFilter = { $Server -eq $script:viServer -and $Id -eq $script:resourceProperties.Id -and $Password -eq $script:resourceProperties.AccountPassword -and !$Confirm }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Invoking with Ensure Present, non existing VMHost Account and Account Password, Description and GrantShellAccess specified' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.AccountPassword = $script:constants.AccountPassword
                $script:resourceProperties.Description = $script:constants.Description
                $script:resourceProperties.GrantShellAccess = $script:constants.GrantShellAccess

                Mock -CommandName Get-VMHostAccount -MockWith { return $null } -ModuleName $script:moduleName
                Mock -CommandName New-VMHostAccount -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.Remove('AccountPassword')
                $script:resourceProperties.Remove('Description')
                $script:resourceProperties.Remove('GrantShellAccess')
            }

            It 'Should call the New-VMHostAccount mock with the VIServer, VMHost Account Id, Password, Description and GrantShellAccess once' {
                # Act
                $resource.Set()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'New-VMHostAccount'
                    ParameterFilter = { $Server -eq $script:viServer -and $Id -eq $script:resourceProperties.Id -and $Password -eq $script:resourceProperties.AccountPassword -and `
                                        $Description -eq $script:resourceProperties.Description -and $GrantShellAccess -eq $script:resourceProperties.GrantShellAccess -and !$Confirm }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Invoking with Ensure Present, existing VMHost Account and no Account settings specified' {
            BeforeAll {
                # Arrange
                $vmHostAccountMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vmHostAccountScriptBlock))

                Mock -CommandName Get-VMHostAccount -MockWith $vmHostAccountMock -ModuleName $script:moduleName
                Mock -CommandName Set-VMHostAccount -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            It 'Should call the Set-VMHostAccount mock with the VIServer and VMHost Account once' {
                # Act
                $resource.Set()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Set-VMHostAccount'
                    ParameterFilter = { $Server -eq $script:viServer -and $UserAccount -eq $script:vmHostAccount -and !$Confirm }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Invoking with Ensure Present, existing VMHost Account and Account Password, Description and GrantShellAccess specified' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.AccountPassword = $script:constants.AccountPassword + 'Modified Password'
                $script:resourceProperties.Description = $script:constants.Description + 'Modified Description'
                $script:resourceProperties.GrantShellAccess = !$script:constants.GrantShellAccess

                $vmHostAccountMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vmHostAccountScriptBlock))

                Mock -CommandName Get-VMHostAccount -MockWith $vmHostAccountMock -ModuleName $script:moduleName
                Mock -CommandName Set-VMHostAccount -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.Remove('AccountPassword')
                $script:resourceProperties.Remove('Description')
                $script:resourceProperties.Remove('GrantShellAccess')
            }

            It 'Should call the Set-VMHostAccount mock with the VIServer and VMHost Account, Account Password, Description and GrantShellAccess once' {
                # Act
                $resource.Set()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Set-VMHostAccount'
                    ParameterFilter = { $Server -eq $script:viServer -and $UserAccount -eq $script:vmHostAccount -and $Password -eq $script:resourceProperties.AccountPassword -and `
                                        $Description -eq $script:resourceProperties.Description -and $GrantShellAccess -eq $script:resourceProperties.GrantShellAccess -and !$Confirm }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Invoking with Ensure Absent and existing VMHost Account' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Ensure = 'Absent'

                $vmHostAccountMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vmHostAccountScriptBlock))

                Mock -CommandName Get-VMHostAccount -MockWith $vmHostAccountMock -ModuleName $script:moduleName
                Mock -CommandName Remove-VMHostAccount -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.Ensure = 'Present'
            }

            It 'Should call the Remove-VMHostAccount mock with the VIServer and VMHost Account once' {
                # Act
                $resource.Set()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Remove-VMHostAccount'
                    ParameterFilter = { $Server -eq $script:viServer -and $HostAccount -eq $script:vmHostAccount -and !$Confirm }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Invoking with Ensure Absent and non existing VMHost Account' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Ensure = 'Absent'

                Mock -CommandName Get-VMHostAccount -MockWith { return $null } -ModuleName $script:moduleName
                Mock -CommandName Remove-VMHostAccount -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.Ensure = 'Present'
            }

            It 'Should not call the Remove-VMHostAccount mock' {
                # Act
                $resource.Set()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Remove-VMHostAccount'
                    ParameterFilter = { $Server -eq $script:viServer -and $HostAccount -eq $script:vmHostAccount -and !$Confirm }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 0
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }
    }

    Describe 'VMHostAccount\Test' -Tag 'Test' {
        BeforeEach {
            # Arrange
            $viServerMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:viServerScriptBlock))

            Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
        }

        Context 'Invoking with Ensure Absent, non existing VMHostAccount and only Account Id specified' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Ensure = 'Absent'

                Mock -CommandName Get-VMHostAccount -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.Ensure = 'Present'
            }

            It 'Should call the Get-VMHostAccount mock with the VIServer and VMHost Account Id once' {
                # Act
                $resource.Test()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-VMHostAccount'
                    ParameterFilter = { $Server -eq $script:viServer -and $Id -eq $script:resourceProperties.Id }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Invoking with Ensure Present and non existing VMHost Account' {
            BeforeAll {
                # Arrange
                Mock -CommandName Get-VMHostAccount -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            It 'Should return $false' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $false
            }
        }

        Context 'Invoking with Ensure Present, existing VMHost Account and matching Account settings' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Description = $script:constants.Description
                $script:resourceProperties.GrantShellAccess = $script:constants.GrantShellAccess

                $vmHostAccountMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vmHostAccountScriptBlock))

                Mock -CommandName Get-VMHostAccount -MockWith $vmHostAccountMock -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.Remove('Description')
                $script:resourceProperties.Remove('GrantShellAccess')
            }

            It 'Should return $true' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $true
            }
        }

        Context 'Invoking with Ensure Present, existing VMHost Account and non matching Account settings' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Description = $script:constants.Description + 'Modified Description'
                $script:resourceProperties.GrantShellAccess = !$script:constants.GrantShellAccess

                $vmHostAccountMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vmHostAccountScriptBlock))

                Mock -CommandName Get-VMHostAccount -MockWith $vmHostAccountMock -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.Remove('Description')
                $script:resourceProperties.Remove('GrantShellAccess')
            }

            It 'Should return $false' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $false
            }
        }

        Context 'Invoking with Ensure Absent and non existing VMHost Account' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Ensure = 'Absent'

                Mock -CommandName Get-VMHostAccount -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.Ensure = 'Present'
            }

            It 'Should return $true' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $true
            }
        }

        Context 'Invoking with Ensure Absent and existing VMHost Account' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Ensure = 'Absent'

                $vmHostAccountMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vmHostAccountScriptBlock))

                Mock -CommandName Get-VMHostAccount -MockWith $vmHostAccountMock -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.Ensure = 'Present'
            }

            It 'Should return $false' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $false
            }
        }
    }

    Describe 'VMHostAccount\Get' -Tag 'Get' {
        BeforeAll {
            $script:resourceProperties.Description = $script:constants.Description
            $script:resourceProperties.GrantShellAccess = $script:constants.GrantShellAccess

            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
        }

        AfterAll {
            $script:resourceProperties.Remove('Description')
            $script:resourceProperties.Remove('GrantShellAccess')
        }

        BeforeEach {
            # Arrange
            $viServerMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:viServerScriptBlock))

            Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
        }

        Context 'Invoking with Ensure Absent, non existing VMHostAccount and only Account Id specified' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Ensure = 'Absent'

                Mock -CommandName Get-VMHostAccount -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.Ensure = 'Present'
            }

            It 'Should call the Get-VMHostAccount mock with the VIServer and VMHost Account Id once' {
                # Act
                $resource.Get()

                # Assert
                $assertMockCalledParams = @{
                    CommandName = 'Get-VMHostAccount'
                    ParameterFilter = { $Server -eq $script:viServer -and $Id -eq $script:resourceProperties.Id }
                    ModuleName = $script:moduleName
                    Exactly = $true
                    Times = 1
                    Scope = 'It'
                }

                Assert-MockCalled @assertMockCalledParams
            }
        }

        Context 'Invoking with Ensure Present and non existing VMHost Account' {
            BeforeAll {
                # Arrange
                Mock -CommandName Get-VMHostAccount -MockWith { return $null } -ModuleName $script:moduleName
            }

            It 'Should retrieve the correct settings from the server' {
                # Act
                $result = $resource.Get()

                # Assert
                $result.Server | Should -Be $script:resourceProperties.Server
                $result.Id | Should -Be $script:resourceProperties.Id
                $result.Ensure | Should -Be 'Absent'
                $result.Description | Should -Be $script:resourceProperties.Description
                $result.GrantShellAccess | Should -Be $script:resourceProperties.GrantShellAccess
            }
        }

        Context 'Invoking with Ensure Present and existing VMHost Account' {
            BeforeAll {
                # Arrange
                $vmHostAccountMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vmHostAccountScriptBlock))

                Mock -CommandName Get-VMHostAccount -MockWith $vmHostAccountMock -ModuleName $script:moduleName
            }

            It 'Should retrieve the correct settings from the server' {
                # Act
                $result = $resource.Get()

                # Assert
                $result.Server | Should -Be $script:resourceProperties.Server
                $result.Id | Should -Be $script:vmHostAccount.Id
                $result.Ensure | Should -Be 'Present'
                $result.Description | Should -Be $script:vmHostAccount.Description
                $result.GrantShellAccess | Should -Be $script:vmHostAccount.ShellAccessEnabled
            }
        }

        Context 'Invoking with Ensure Absent and non existing VMHost Account' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Ensure = 'Absent'

                Mock -CommandName Get-VMHostAccount -MockWith { return $null } -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.Ensure = 'Present'
            }

            It 'Should retrieve the correct settings from the server' {
                # Act
                $result = $resource.Get()

                # Assert
                $result.Server | Should -Be $script:resourceProperties.Server
                $result.Id | Should -Be $script:resourceProperties.Id
                $result.Ensure | Should -Be 'Absent'
                $result.Description | Should -Be $script:resourceProperties.Description
                $result.GrantShellAccess | Should -Be $script:resourceProperties.GrantShellAccess
            }
        }

        Context 'Invoking with Ensure Absent and existing VMHost Account' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Ensure = 'Absent'

                $vmHostAccountMock = [ScriptBlock]::Create($ExecutionContext.InvokeCommand.ExpandString($script:vmHostAccountScriptBlock))

                Mock -CommandName Get-VMHostAccount -MockWith $vmHostAccountMock -ModuleName $script:moduleName

                $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
            }

            AfterAll {
                $script:resourceProperties.Ensure = 'Present'
            }

            It 'Should retrieve the correct settings from the server' {
                # Act
                $result = $resource.Get()

                # Assert
                $result.Server | Should -Be $script:resourceProperties.Server
                $result.Id | Should -Be $script:vmHostAccount.Id
                $result.Ensure | Should -Be 'Present'
                $result.Description | Should -Be $script:vmHostAccount.Description
                $result.GrantShellAccess | Should -Be $script:vmHostAccount.ShellAccessEnabled
            }
        }
    }
}
finally {
    # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
    Invoke-TestCleanup
}
