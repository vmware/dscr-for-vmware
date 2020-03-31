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
$script:resourceName = 'VMHostSatpClaimRule'

$user = 'user'
$password = 'password' | ConvertTo-SecureString -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($user, $password)

$script:resourceProperties = @{
    Name = '10.23.82.112'
    Server = '10.23.82.112'
    Credential = $credential
    Ensure = 'Present'
    RuleName = 'VMW_SATP_LOCAL'
    Transport = 'VMW_SATP_LOCAL Transport'
    Description = 'Description of VMW_SATP_LOCAL Claim Rule.'
    Type = 'transport'
    Psp = 'VMW_PSP_MRU'
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

    Describe 'VMHostSatpClaimRule\Set' -Tag 'Set' {
        AfterEach {
            $script:resourceProperties.Ensure = 'Present'
        }

        Context 'Invoking with default resource properties' {
            BeforeAll {
                # Arrange
                $viServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                $vmhostObject = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId' }

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId' }
                }
                $esxCliMock = {
                    $esxcli = New-Object PSObject
                    $esxcli | Add-Member -MemberType NoteProperty -Name 'storage' -Value (New-Object PSObject)
                    $esxcli.storage | Add-Member -MemberType NoteProperty -Name 'nmp' -Value (New-Object PSObject)
                    $esxcli.storage.nmp | Add-Member -MemberType NoteProperty -Name 'satp' -Value (New-Object PSObject)
                    $esxcli.storage.nmp.satp | Add-Member -MemberType NoteProperty -Name 'rule' -Value (New-Object PSObject)
                    $esxcli.storage.nmp.satp.rule | Add-Member -MemberType NoteProperty -Name 'list' -Value (New-Object PSObject)
                    $esxcli.storage.nmp.satp.rule | Add-Member -MemberType NoteProperty -Name 'add' -Value (New-Object PSObject)

                    $satpClaimRules = @(
                       [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_LOCAL_2'; Transport = 'VMW_SATP_LOCAL_2 Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' };
                       [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_NOT_LOCAL'; Transport = 'VMW_SATP_NOT_LOCAL Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' }
                    )

                    $addSatpArgs = @{
                        satp = $null; pspoption = $null; transport = $null; description = $null; vendor = $null; boot = $false; type = $null; device = $null; driver = $null; claimoption = $null;
                        psp = $null; option = $null; model = $null; force = $false
                    }

                    $esxcli.storage.nmp.satp.rule.list | Add-Member -MemberType ScriptMethod -Name 'Invoke' -Value { $satpClaimRules }
                    $esxcli.storage.nmp.satp.rule.add | Add-Member -MemberType ScriptMethod -Name 'CreateArgs' -Value { return $addSatpArgs }
                    $esxcli.storage.nmp.satp.rule.add | Add-Member -MemberType ScriptMethod -Name 'Invoke' -Value { return $null }

                    return $esxcli
                }
                $satpClaimRulesMock = {
                    return @(
                        [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_LOCAL_2'; Transport = 'VMW_SATP_LOCAL_2 Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' };
                        [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_NOT_LOCAL'; Transport = 'VMW_SATP_NOT_LOCAL Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' }
                    )
                }
                $satpAddArgsMock = {
                    return @{
                        satp = $null; pspoption = $null; transport = $null; description = $null; vendor = $null; boot = $false; type = $null; device = $null; driver = $null; claimoption = $null;
                        psp = $null; option = $null; model = $null; force = $false
                    }
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName Get-EsxCli -MockWith $esxCliMock -ModuleName $script:moduleName
                Mock -CommandName Get-SATPClaimRules -MockWith $satpClaimRulesMock -ModuleName $script:moduleName
                Mock -CommandName Add-CreateArgs -MockWith $satpAddArgsMock -ModuleName $script:moduleName
                Mock -CommandName Add-SATPClaimRule -MockWith { return $null } -ModuleName $script:moduleName
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

            It 'Should call Get-EsxCli mock with the passed server and vmhost once' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Get-EsxCli `
                                  -ParameterFilter { $Server -eq $viServer -and $VMHost -eq $vmhostObject -and $V2 } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }
        }

        Context 'Invoking when ensure set to Present and the SATP Claim Rule is not installed' {
            BeforeAll {
                # Arrange
                $addSatpArgs = @{
                    satp = 'VMW_SATP_LOCAL'; pspoption = $null; transport = 'VMW_SATP_LOCAL Transport'; description = 'Description of VMW_SATP_LOCAL Claim Rule.'; vendor = $null; boot = $false;
                    type = 'transport'; device = $null; driver = $null; claimoption = $null; psp = 'VMW_PSP_MRU'; option = $null; model = $null; force = $false
                }

                $esxcliObject = New-Object PSObject
                $esxcliObject | Add-Member -MemberType NoteProperty -Name 'id' -Value 'esxCli Id'

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{}
                }
                $esxCliMock = {
                    $esxcli = New-Object PSObject
                    $esxcli | Add-Member -MemberType NoteProperty -Name 'id' -Value 'esxCli Id'
                    $esxcli | Add-Member -MemberType NoteProperty -Name 'storage' -Value (New-Object PSObject)
                    $esxcli.storage | Add-Member -MemberType NoteProperty -Name 'nmp' -Value (New-Object PSObject)
                    $esxcli.storage.nmp | Add-Member -MemberType NoteProperty -Name 'satp' -Value (New-Object PSObject)
                    $esxcli.storage.nmp.satp | Add-Member -MemberType NoteProperty -Name 'rule' -Value (New-Object PSObject)
                    $esxcli.storage.nmp.satp.rule | Add-Member -MemberType NoteProperty -Name 'list' -Value (New-Object PSObject)
                    $esxcli.storage.nmp.satp.rule | Add-Member -MemberType NoteProperty -Name 'add' -Value (New-Object PSObject)

                    $satpClaimRules = @(
                       [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_LOCAL_2'; Transport = 'VMW_SATP_LOCAL_2 Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' };
                       [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_NOT_LOCAL'; Transport = 'VMW_SATP_NOT_LOCAL Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' }
                    )

                    $addSatpArgs = @{
                        satp = $null; pspoption = $null; transport = $null; description = $null; vendor = $null; boot = $false; type = $null; device = $null; driver = $null; claimoption = $null;
                        psp = $null; option = $null; model = $null; force = $false
                    }

                    $esxcli.storage.nmp.satp.rule.list | Add-Member -MemberType ScriptMethod -Name 'Invoke' -Value { $satpClaimRules }
                    $esxcli.storage.nmp.satp.rule.add | Add-Member -MemberType ScriptMethod -Name 'CreateArgs' -Value { return $addSatpArgs }
                    $esxcli.storage.nmp.satp.rule.add | Add-Member -MemberType ScriptMethod -Name 'Invoke' -Value { return $null }

                    return $esxcli
                }
                $satpClaimRulesMock = {
                    return @(
                        [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_LOCAL_2'; Transport = 'VMW_SATP_LOCAL_2 Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' };
                        [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_NOT_LOCAL'; Transport = 'VMW_SATP_NOT_LOCAL Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' }
                    )
                }
                $satpAddArgsMock = {
                    return @{
                        satp = $null; pspoption = $null; transport = $null; description = $null; vendor = $null; boot = $false; type = $null; device = $null; driver = $null; claimoption = $null;
                        psp = $null; option = $null; model = $null; force = $false
                    }
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName Get-EsxCli -MockWith $esxCliMock -ModuleName $script:moduleName
                Mock -CommandName Get-SATPClaimRules -MockWith $satpClaimRulesMock -ModuleName $script:moduleName
                Mock -CommandName Add-CreateArgs -MockWith $satpAddArgsMock -ModuleName $script:moduleName
                Mock -CommandName Add-SATPClaimRule -MockWith { return $null } -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call Get-SATPClaimRules mock once with the passed EsxCli' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Get-SATPClaimRules `
                                  -ParameterFilter { $EsxCli.Id -eq $esxcliObject.Id } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call Add-CreateArgs mock once with the passed EsxCli' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Add-CreateArgs `
                                  -ParameterFilter { $EsxCli.Id -eq $esxcliObject.Id } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call Add-SATPClaimRule mock once with the passed EsxCli and SATP Args' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Add-SATPClaimRule `
                                  -ParameterFilter { $EsxCli.Id -eq $esxcliObject.Id -and ( Compare-Object -ReferenceObject $SatpArgs.Values -DifferenceObject $addSatpArgs.Values ) -eq $null } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }
        }

        Context 'Invoking when ensure set to Present and the SATP Claim Rule is installed' {
            BeforeAll {
                # Arrange
                $addSatpArgs = @{
                    satp = 'VMW_SATP_LOCAL'; pspoption = $null; transport = 'VMW_SATP_LOCAL Transport'; description = 'Description of VMW_SATP_LOCAL Claim Rule.'; vendor = $null; boot = $false;
                    type = 'transport'; device = $null; driver = $null; claimoption = $null; psp = 'VMW_PSP_MRU'; option = $null; model = $null; force = $false
                }

                $esxcliObject = New-Object PSObject
                $esxcliObject | Add-Member -MemberType NoteProperty -Name 'id' -Value 'esxCli Id'

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{}
                }
                $esxCliMock = {
                    $esxcli = New-Object PSObject
                    $esxcli | Add-Member -MemberType NoteProperty -Name 'id' -Value 'esxCli Id'
                    $esxcli | Add-Member -MemberType NoteProperty -Name 'storage' -Value (New-Object PSObject)
                    $esxcli.storage | Add-Member -MemberType NoteProperty -Name 'nmp' -Value (New-Object PSObject)
                    $esxcli.storage.nmp | Add-Member -MemberType NoteProperty -Name 'satp' -Value (New-Object PSObject)
                    $esxcli.storage.nmp.satp | Add-Member -MemberType NoteProperty -Name 'rule' -Value (New-Object PSObject)
                    $esxcli.storage.nmp.satp.rule | Add-Member -MemberType NoteProperty -Name 'list' -Value (New-Object PSObject)
                    $esxcli.storage.nmp.satp.rule | Add-Member -MemberType NoteProperty -Name 'add' -Value (New-Object PSObject)

                    $satpClaimRules = @(
                       [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_LOCAL_2'; Transport = 'VMW_SATP_LOCAL_2 Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' };
                       [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_NOT_LOCAL'; Transport = 'VMW_SATP_NOT_LOCAL Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' };
                       [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_LOCAL'; Transport = 'VMW_SATP_LOCAL Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' }
                    )

                    $addSatpArgs = @{
                        satp = $null; pspoption = $null; transport = $null; description = $null; vendor = $null; boot = $false; type = $null; device = $null; driver = $null; claimoption = $null;
                        psp = $null; option = $null; model = $null; force = $false
                    }

                    $esxcli.storage.nmp.satp.rule.list | Add-Member -MemberType ScriptMethod -Name 'Invoke' -Value { $satpClaimRules }
                    $esxcli.storage.nmp.satp.rule.add | Add-Member -MemberType ScriptMethod -Name 'CreateArgs' -Value { return $addSatpArgs }
                    $esxcli.storage.nmp.satp.rule.add | Add-Member -MemberType ScriptMethod -Name 'Invoke' -Value { return $null }

                    return $esxcli
                }
                $satpClaimRulesMock = {
                    return @(
                        [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_LOCAL_2'; Transport = 'VMW_SATP_LOCAL_2 Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' };
                        [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_NOT_LOCAL'; Transport = 'VMW_SATP_NOT_LOCAL Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' };
                        [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_LOCAL'; Transport = 'VMW_SATP_LOCAL Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' }
                    )
                }
                $satpAddArgsMock = {
                    return @{
                        satp = $null; pspoption = $null; transport = $null; description = $null; vendor = $null; boot = $false; type = $null; device = $null; driver = $null; claimoption = $null;
                        psp = $null; option = $null; model = $null; force = $false
                    }
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName Get-EsxCli -MockWith $esxCliMock -ModuleName $script:moduleName
                Mock -CommandName Get-SATPClaimRules -MockWith $satpClaimRulesMock -ModuleName $script:moduleName
                Mock -CommandName Add-CreateArgs -MockWith $satpAddArgsMock -ModuleName $script:moduleName
                Mock -CommandName Add-SATPClaimRule -MockWith { return $null } -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call Get-SATPClaimRules mock once with the passed EsxCli' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Get-SATPClaimRules `
                                  -ParameterFilter { $EsxCli.Id -eq $esxcliObject.Id } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should not call Add-CreateArgs mock with the passed EsxCli' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Add-CreateArgs `
                                  -ParameterFilter { $EsxCli.Id -eq $esxcliObject.Id } `
                                  -ModuleName $script:moduleName -Exactly 0 -Scope It
            }

            It 'Should not call Add-SATPClaimRule mock with the passed EsxCli and SATP Args' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Add-SATPClaimRule `
                                  -ParameterFilter { $EsxCli.Id -eq $esxcliObject.Id -and ( Compare-Object -ReferenceObject $SatpArgs.Values -DifferenceObject $addSatpArgs.Values ) -eq $null } `
                                  -ModuleName $script:moduleName -Exactly 0 -Scope It
            }
        }

        Context 'Invoking when ensure set to Absent and the SATP Claim Rule is installed' {
            BeforeAll {
                # Arrange
                $removeSatpArgs = @{
                    satp = 'VMW_SATP_LOCAL'; pspoption = $null; transport = 'VMW_SATP_LOCAL Transport'; description = 'Description of VMW_SATP_LOCAL Claim Rule.'; vendor = $null; boot = $false;
                    type = 'transport'; device = $null; driver = $null; claimoption = $null; psp = 'VMW_PSP_MRU'; option = $null; model = $null
                }

                $esxcliObject = New-Object PSObject
                $esxcliObject | Add-Member -MemberType NoteProperty -Name 'id' -Value 'esxCli Id'

                $script:resourceProperties.Ensure = 'Absent'

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{}
                }
                $esxCliMock = {
                    $esxcli = New-Object PSObject
                    $esxcli | Add-Member -MemberType NoteProperty -Name 'id' -Value 'esxCli Id'
                    $esxcli | Add-Member -MemberType NoteProperty -Name 'storage' -Value (New-Object PSObject)
                    $esxcli.storage | Add-Member -MemberType NoteProperty -Name 'nmp' -Value (New-Object PSObject)
                    $esxcli.storage.nmp | Add-Member -MemberType NoteProperty -Name 'satp' -Value (New-Object PSObject)
                    $esxcli.storage.nmp.satp | Add-Member -MemberType NoteProperty -Name 'rule' -Value (New-Object PSObject)
                    $esxcli.storage.nmp.satp.rule | Add-Member -MemberType NoteProperty -Name 'list' -Value (New-Object PSObject)
                    $esxcli.storage.nmp.satp.rule | Add-Member -MemberType NoteProperty -Name 'remove' -Value (New-Object PSObject)

                    $satpClaimRules = @(
                       [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_LOCAL_2'; Transport = 'VMW_SATP_LOCAL_2 Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' };
                       [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_NOT_LOCAL'; Transport = 'VMW_SATP_NOT_LOCAL Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' };
                       [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_LOCAL'; Transport = 'VMW_SATP_LOCAL Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' }
                    )

                    $removeSatpArgs = @{
                        satp = $null; pspoption = $null; transport = $null; description = $null; vendor = $null; boot = $false; type = $null; device = $null; driver = $null; claimoption = $null;
                        psp = $null; option = $null; model = $null
                    }

                    $esxcli.storage.nmp.satp.rule.list | Add-Member -MemberType ScriptMethod -Name 'Invoke' -Value { $satpClaimRules }
                    $esxcli.storage.nmp.satp.rule.remove | Add-Member -MemberType ScriptMethod -Name 'CreateArgs' -Value { return $removeSatpArgs }
                    $esxcli.storage.nmp.satp.rule.remove | Add-Member -MemberType ScriptMethod -Name 'Invoke' -Value { return $null }

                    return $esxcli
                }
                $satpClaimRulesMock = {
                    return @(
                        [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_LOCAL_2'; Transport = 'VMW_SATP_LOCAL_2 Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' };
                        [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_NOT_LOCAL'; Transport = 'VMW_SATP_NOT_LOCAL Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' };
                        [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_LOCAL'; Transport = 'VMW_SATP_LOCAL Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' }
                    )
                }
                $satpRemoveArgsMock = {
                    return @{
                        satp = $null; pspoption = $null; transport = $null; description = $null; vendor = $null; boot = $false; type = $null; device = $null; driver = $null; claimoption = $null;
                        psp = $null; option = $null; model = $null
                    }
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName Get-EsxCli -MockWith $esxCliMock -ModuleName $script:moduleName
                Mock -CommandName Get-SATPClaimRules -MockWith $satpClaimRulesMock -ModuleName $script:moduleName
                Mock -CommandName Remove-CreateArgs -MockWith $satpRemoveArgsMock -ModuleName $script:moduleName
                Mock -CommandName Remove-SATPClaimRule -MockWith { return $null } -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call Get-SATPClaimRules mock once with the passed EsxCli' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Get-SATPClaimRules `
                                  -ParameterFilter { $EsxCli.Id -eq $esxcliObject.Id } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call Remove-CreateArgs mock once with the passed EsxCli' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Remove-CreateArgs `
                                  -ParameterFilter { $EsxCli.Id -eq $esxcliObject.Id } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should call Remove-SATPClaimRule mock once with the passed EsxCli and SATP Args' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Remove-SATPClaimRule `
                                  -ParameterFilter { $EsxCli.Id -eq $esxcliObject.Id -and ( Compare-Object -ReferenceObject $SatpArgs.Values -DifferenceObject $removeSatpArgs.Values ) -eq $null } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }
        }

        Context 'Invoking when ensure set to Absent and the SATP Claim Rule is not installed' {
            BeforeAll {
                # Arrange
                $removeSatpArgs = @{
                    satp = 'VMW_SATP_LOCAL'; pspoption = $null; transport = 'VMW_SATP_LOCAL Transport'; description = 'Description of VMW_SATP_LOCAL Claim Rule.'; vendor = $null; boot = $false;
                    type = 'transport'; device = $null; driver = $null; claimoption = $null; psp = 'VMW_PSP_MRU'; option = $null; model = $null
                }

                $esxcliObject = New-Object PSObject
                $esxcliObject | Add-Member -MemberType NoteProperty -Name 'id' -Value 'esxCli Id'

                $script:resourceProperties.Ensure = 'Absent'

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{}
                }
                $esxCliMock = {
                    $esxcli = New-Object PSObject
                    $esxcli | Add-Member -MemberType NoteProperty -Name 'id' -Value 'esxCli Id'
                    $esxcli | Add-Member -MemberType NoteProperty -Name 'storage' -Value (New-Object PSObject)
                    $esxcli.storage | Add-Member -MemberType NoteProperty -Name 'nmp' -Value (New-Object PSObject)
                    $esxcli.storage.nmp | Add-Member -MemberType NoteProperty -Name 'satp' -Value (New-Object PSObject)
                    $esxcli.storage.nmp.satp | Add-Member -MemberType NoteProperty -Name 'rule' -Value (New-Object PSObject)
                    $esxcli.storage.nmp.satp.rule | Add-Member -MemberType NoteProperty -Name 'list' -Value (New-Object PSObject)
                    $esxcli.storage.nmp.satp.rule | Add-Member -MemberType NoteProperty -Name 'remove' -Value (New-Object PSObject)

                    $satpClaimRules = @(
                       [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_LOCAL_2'; Transport = 'VMW_SATP_LOCAL_2 Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' };
                       [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_NOT_LOCAL'; Transport = 'VMW_SATP_NOT_LOCAL Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' }
                    )

                    $removeSatpArgs = @{
                        satp = $null; pspoption = $null; transport = $null; description = $null; vendor = $null; boot = $false; type = $null; device = $null; driver = $null; claimoption = $null;
                        psp = $null; option = $null; model = $null
                    }

                    $esxcli.storage.nmp.satp.rule.list | Add-Member -MemberType ScriptMethod -Name 'Invoke' -Value { $satpClaimRules }
                    $esxcli.storage.nmp.satp.rule.remove | Add-Member -MemberType ScriptMethod -Name 'CreateArgs' -Value { return $removeSatpArgs }
                    $esxcli.storage.nmp.satp.rule.remove | Add-Member -MemberType ScriptMethod -Name 'Invoke' -Value { return $null }

                    return $esxcli
                }
                $satpClaimRulesMock = {
                    return @(
                        [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_LOCAL_2'; Transport = 'VMW_SATP_LOCAL_2 Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' };
                        [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_NOT_LOCAL'; Transport = 'VMW_SATP_NOT_LOCAL Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' }
                    )
                }
                $satpRemoveArgsMock = {
                    return @{
                        satp = $null; pspoption = $null; transport = $null; description = $null; vendor = $null; boot = $false; type = $null; device = $null; driver = $null; claimoption = $null;
                        psp = $null; option = $null; model = $null
                    }
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName Get-EsxCli -MockWith $esxCliMock -ModuleName $script:moduleName
                Mock -CommandName Get-SATPClaimRules -MockWith $satpClaimRulesMock -ModuleName $script:moduleName
                Mock -CommandName Remove-CreateArgs -MockWith $satpRemoveArgsMock -ModuleName $script:moduleName
                Mock -CommandName Remove-SATPClaimRule -MockWith { return $null } -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should call Get-SATPClaimRules mock once with the passed EsxCli' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Get-SATPClaimRules `
                                  -ParameterFilter { $EsxCli.Id -eq $esxcliObject.Id } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }

            It 'Should not call Remove-CreateArgs mock with the passed EsxCli' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Remove-CreateArgs `
                                  -ParameterFilter { $EsxCli.Id -eq $esxcliObject.Id } `
                                  -ModuleName $script:moduleName -Exactly 0 -Scope It
            }

            It 'Should not call Remove-SATPClaimRule mock with the passed EsxCli and SATP Args' {
                # Act
                $resource.Set()

                # Assert
                Assert-MockCalled -CommandName Remove-SATPClaimRule `
                                  -ParameterFilter { $EsxCli.Id -eq $esxcliObject.Id -and ( Compare-Object -ReferenceObject $SatpArgs.Values -DifferenceObject $removeSatpArgs.Values ) -eq $null } `
                                  -ModuleName $script:moduleName -Exactly 0 -Scope It
            }
        }
    }

    Describe 'VMHostSatpClaimRule\Test' -Tag 'Test' {
        AfterEach {
            $script:resourceProperties.Ensure = 'Present'
        }

        Context 'Invoking with default resource properties' {
            BeforeAll {
                # Arrange
                $viServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                $vmhostObject = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId' }

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId' }
                }
                $esxCliMock = {
                    $esxcli = New-Object PSObject
                    $esxcli | Add-Member -MemberType NoteProperty -Name 'storage' -Value (New-Object PSObject)
                    $esxcli.storage | Add-Member -MemberType NoteProperty -Name 'nmp' -Value (New-Object PSObject)
                    $esxcli.storage.nmp | Add-Member -MemberType NoteProperty -Name 'satp' -Value (New-Object PSObject)
                    $esxcli.storage.nmp.satp | Add-Member -MemberType NoteProperty -Name 'rule' -Value (New-Object PSObject)
                    $esxcli.storage.nmp.satp.rule | Add-Member -MemberType NoteProperty -Name 'list' -Value (New-Object PSObject)

                    $satpClaimRules = @(
                       [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_LOCAL_2'; Transport = 'VMW_SATP_LOCAL_2 Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' };
                       [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_NOT_LOCAL'; Transport = 'VMW_SATP_NOT_LOCAL Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' }
                    )

                    $esxcli.storage.nmp.satp.rule.list | Add-Member -MemberType ScriptMethod -Name 'Invoke' -Value { $satpClaimRules }

                    return $esxcli
                }
                $satpClaimRulesMock = {
                    return @(
                        [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_LOCAL_2'; Transport = 'VMW_SATP_LOCAL_2 Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' };
                        [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_NOT_LOCAL'; Transport = 'VMW_SATP_NOT_LOCAL Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' }
                    )
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName Get-EsxCli -MockWith $esxCliMock -ModuleName $script:moduleName
                Mock -CommandName Get-SATPClaimRules -MockWith $satpClaimRulesMock -ModuleName $script:moduleName
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

            It 'Should call Get-EsxCli mock with the passed server and vmhost once' {
                # Act
                $resource.Test()

                # Assert
                Assert-MockCalled -CommandName Get-EsxCli `
                                  -ParameterFilter { $Server -eq $viServer -and $VMHost -eq $vmhostObject -and $V2 } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }
        }

        Context 'Invoking with Ensure set to Present and the SATP Claim Rule is not installed' {
            BeforeAll {
                # Arrange
                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{}
                }
                $esxCliMock = {
                    $esxcli = New-Object PSObject
                    $esxcli | Add-Member -MemberType NoteProperty -Name 'storage' -Value (New-Object PSObject)
                    $esxcli.storage | Add-Member -MemberType NoteProperty -Name 'nmp' -Value (New-Object PSObject)
                    $esxcli.storage.nmp | Add-Member -MemberType NoteProperty -Name 'satp' -Value (New-Object PSObject)
                    $esxcli.storage.nmp.satp | Add-Member -MemberType NoteProperty -Name 'rule' -Value (New-Object PSObject)
                    $esxcli.storage.nmp.satp.rule | Add-Member -MemberType NoteProperty -Name 'list' -Value (New-Object PSObject)

                    $satpClaimRules = @(
                       [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_LOCAL_2'; Transport = 'VMW_SATP_LOCAL_2 Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' };
                       [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_NOT_LOCAL'; Transport = 'VMW_SATP_NOT_LOCAL Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' }
                    )

                    $esxcli.storage.nmp.satp.rule.list | Add-Member -MemberType ScriptMethod -Name 'Invoke' -Value { $satpClaimRules }

                    return $esxcli
                }
                $satpClaimRulesMock = {
                    return @(
                        [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_LOCAL_2'; Transport = 'VMW_SATP_LOCAL_2 Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' };
                        [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_NOT_LOCAL'; Transport = 'VMW_SATP_NOT_LOCAL Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' }
                    )
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName Get-EsxCli -MockWith $esxCliMock -ModuleName $script:moduleName
                Mock -CommandName Get-SATPClaimRules -MockWith $satpClaimRulesMock -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should return $false ( The rule is not installed )' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $false
            }
        }

        Context 'Invoking with Ensure set to Present and the SATP Claim Rule is installed' {
            BeforeAll {
                # Arrange
                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{}
                }
                $esxCliMock = {
                    $esxcli = New-Object PSObject
                    $esxcli | Add-Member -MemberType NoteProperty -Name 'storage' -Value (New-Object PSObject)
                    $esxcli.storage | Add-Member -MemberType NoteProperty -Name 'nmp' -Value (New-Object PSObject)
                    $esxcli.storage.nmp | Add-Member -MemberType NoteProperty -Name 'satp' -Value (New-Object PSObject)
                    $esxcli.storage.nmp.satp | Add-Member -MemberType NoteProperty -Name 'rule' -Value (New-Object PSObject)
                    $esxcli.storage.nmp.satp.rule | Add-Member -MemberType NoteProperty -Name 'list' -Value (New-Object PSObject)

                    $satpClaimRules = @(
                       [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_LOCAL_2'; Transport = 'VMW_SATP_LOCAL_2 Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' };
                       [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_NOT_LOCAL'; Transport = 'VMW_SATP_NOT_LOCAL Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' };
                       [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_LOCAL'; Transport = 'VMW_SATP_LOCAL Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' }
                    )

                    $esxcli.storage.nmp.satp.rule.list | Add-Member -MemberType ScriptMethod -Name 'Invoke' -Value { $satpClaimRules }

                    return $esxcli
                }
                $satpClaimRulesMock = {
                    return @(
                        [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_LOCAL_2'; Transport = 'VMW_SATP_LOCAL_2 Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' };
                        [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_NOT_LOCAL'; Transport = 'VMW_SATP_NOT_LOCAL Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' };
                        [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_LOCAL'; Transport = 'VMW_SATP_LOCAL Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' }
                    )
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName Get-EsxCli -MockWith $esxCliMock -ModuleName $script:moduleName
                Mock -CommandName Get-SATPClaimRules -MockWith $satpClaimRulesMock -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should return $true ( The rule is installed )' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $true
            }
        }

        Context 'Invoking with Ensure set to Absent and the SATP Claim Rule is installed' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Ensure = 'Absent'

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{}
                }
                $esxCliMock = {
                    $esxcli = New-Object PSObject
                    $esxcli | Add-Member -MemberType NoteProperty -Name 'storage' -Value (New-Object PSObject)
                    $esxcli.storage | Add-Member -MemberType NoteProperty -Name 'nmp' -Value (New-Object PSObject)
                    $esxcli.storage.nmp | Add-Member -MemberType NoteProperty -Name 'satp' -Value (New-Object PSObject)
                    $esxcli.storage.nmp.satp | Add-Member -MemberType NoteProperty -Name 'rule' -Value (New-Object PSObject)
                    $esxcli.storage.nmp.satp.rule | Add-Member -MemberType NoteProperty -Name 'list' -Value (New-Object PSObject)

                    $satpClaimRules = @(
                       [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_LOCAL_2'; Transport = 'VMW_SATP_LOCAL_2 Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' };
                       [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_NOT_LOCAL'; Transport = 'VMW_SATP_NOT_LOCAL Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' };
                       [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_LOCAL'; Transport = 'VMW_SATP_LOCAL Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' }
                    )

                    $esxcli.storage.nmp.satp.rule.list | Add-Member -MemberType ScriptMethod -Name 'Invoke' -Value { $satpClaimRules }

                    return $esxcli
                }
                $satpClaimRulesMock = {
                    return @(
                        [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_LOCAL_2'; Transport = 'VMW_SATP_LOCAL_2 Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' };
                        [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_NOT_LOCAL'; Transport = 'VMW_SATP_NOT_LOCAL Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' };
                        [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_LOCAL'; Transport = 'VMW_SATP_LOCAL Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' }
                    )
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName Get-EsxCli -MockWith $esxCliMock -ModuleName $script:moduleName
                Mock -CommandName Get-SATPClaimRules -MockWith $satpClaimRulesMock -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should return $false ( The rule is installed )' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $false
            }
        }

        Context 'Invoking with Ensure set to Absent and the SATP Claim Rule is not installed' {
            BeforeAll {
                # Arrange
                $script:resourceProperties.Ensure = 'Absent'

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{}
                }
                $esxCliMock = {
                    $esxcli = New-Object PSObject
                    $esxcli | Add-Member -MemberType NoteProperty -Name 'storage' -Value (New-Object PSObject)
                    $esxcli.storage | Add-Member -MemberType NoteProperty -Name 'nmp' -Value (New-Object PSObject)
                    $esxcli.storage.nmp | Add-Member -MemberType NoteProperty -Name 'satp' -Value (New-Object PSObject)
                    $esxcli.storage.nmp.satp | Add-Member -MemberType NoteProperty -Name 'rule' -Value (New-Object PSObject)
                    $esxcli.storage.nmp.satp.rule | Add-Member -MemberType NoteProperty -Name 'list' -Value (New-Object PSObject)

                    $satpClaimRules = @(
                       [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_LOCAL_2'; Transport = 'VMW_SATP_LOCAL_2 Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' };
                       [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_NOT_LOCAL'; Transport = 'VMW_SATP_NOT_LOCAL Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' }
                    )

                    $esxcli.storage.nmp.satp.rule.list | Add-Member -MemberType ScriptMethod -Name 'Invoke' -Value { $satpClaimRules }

                    return $esxcli
                }
                $satpClaimRulesMock = {
                    return @(
                        [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_LOCAL_2'; Transport = 'VMW_SATP_LOCAL_2 Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' };
                        [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_NOT_LOCAL'; Transport = 'VMW_SATP_NOT_LOCAL Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' }
                    )
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName Get-EsxCli -MockWith $esxCliMock -ModuleName $script:moduleName
                Mock -CommandName Get-SATPClaimRules -MockWith $satpClaimRulesMock -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should return $true ( The rule is not installed )' {
                # Act
                $result = $resource.Test()

                # Assert
                $result | Should -Be $true
            }
        }
    }

    Describe 'VMHostSatpClaimRule\Get' -Tag 'Get' {
        AfterEach {
            $script:resourceProperties.Ensure = 'Present'
        }

        Context 'Invoking with default resource properties' {
            BeforeAll {
                # Arrange
                $viServer = [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                $vmhostObject = [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId' }

                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Id = 'VMHostId' }
                }
                $esxCliMock = {
                    $esxcli = New-Object PSObject
                    $esxcli | Add-Member -MemberType NoteProperty -Name 'storage' -Value (New-Object PSObject)
                    $esxcli.storage | Add-Member -MemberType NoteProperty -Name 'nmp' -Value (New-Object PSObject)
                    $esxcli.storage.nmp | Add-Member -MemberType NoteProperty -Name 'satp' -Value (New-Object PSObject)
                    $esxcli.storage.nmp.satp | Add-Member -MemberType NoteProperty -Name 'rule' -Value (New-Object PSObject)
                    $esxcli.storage.nmp.satp.rule | Add-Member -MemberType NoteProperty -Name 'list' -Value (New-Object PSObject)

                    $satpClaimRules = @(
                       [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_LOCAL_2'; Transport = 'VMW_SATP_LOCAL_2 Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' };
                       [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_NOT_LOCAL'; Transport = 'VMW_SATP_NOT_LOCAL Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' }
                    )

                    $esxcli.storage.nmp.satp.rule.list | Add-Member -MemberType ScriptMethod -Name 'Invoke' -Value { $satpClaimRules }

                    return $esxcli
                }
                $satpClaimRulesMock = {
                    return @(
                        [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_LOCAL_2'; Transport = 'VMW_SATP_LOCAL_2 Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' };
                        [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_NOT_LOCAL'; Transport = 'VMW_SATP_NOT_LOCAL Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' }
                    )
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName Get-EsxCli -MockWith $esxCliMock -ModuleName $script:moduleName
                Mock -CommandName Get-SATPClaimRules -MockWith $satpClaimRulesMock -ModuleName $script:moduleName
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

            It 'Should call Get-EsxCli mock with the passed server and vmhost once' {
                # Act
                $resource.Get()

                # Assert
                Assert-MockCalled -CommandName Get-EsxCli `
                                  -ParameterFilter { $Server -eq $viServer -and $VMHost -eq $vmhostObject -and $V2 } `
                                  -ModuleName $script:moduleName -Exactly 1 -Scope It
            }
        }

        Context 'Invoking with Claim Rule Installed' {
            BeforeAll {
                # Arrange
                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Name = '10.23.82.112' }
                }
                $esxCliMock = {
                    $esxcli = New-Object PSObject
                    $esxcli | Add-Member -MemberType NoteProperty -Name 'storage' -Value (New-Object PSObject)
                    $esxcli.storage | Add-Member -MemberType NoteProperty -Name 'nmp' -Value (New-Object PSObject)
                    $esxcli.storage.nmp | Add-Member -MemberType NoteProperty -Name 'satp' -Value (New-Object PSObject)
                    $esxcli.storage.nmp.satp | Add-Member -MemberType NoteProperty -Name 'rule' -Value (New-Object PSObject)
                    $esxcli.storage.nmp.satp.rule | Add-Member -MemberType NoteProperty -Name 'list' -Value (New-Object PSObject)

                    $satpClaimRules = @(
                       [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_LOCAL_2'; Transport = 'VMW_SATP_LOCAL_2 Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' };
                       [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_NOT_LOCAL'; Transport = 'VMW_SATP_NOT_LOCAL Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' };
                       [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_LOCAL'; Transport = 'VMW_SATP_LOCAL Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' }
                    )

                    $esxcli.storage.nmp.satp.rule.list | Add-Member -MemberType ScriptMethod -Name 'Invoke' -Value { $satpClaimRules }

                    return $esxcli
                }
                $satpClaimRulesMock = {
                    return @(
                        [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_LOCAL_2'; Transport = 'VMW_SATP_LOCAL_2 Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' };
                        [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_NOT_LOCAL'; Transport = 'VMW_SATP_NOT_LOCAL Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' };
                        [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_LOCAL'; Transport = 'VMW_SATP_LOCAL Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' }
                    )
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName Get-EsxCli -MockWith $esxCliMock -ModuleName $script:moduleName
                Mock -CommandName Get-SATPClaimRules -MockWith $satpClaimRulesMock -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should return the resource with the properties retrieved from the server' {
                # Act
                $result = $resource.Get()

                # Assert
                $result.Name | Should -Be $script:resourceProperties.Name
                $result.Server | Should -Be $script:resourceProperties.Server
                $result.Ensure | Should -Be 'Present'
                $result.RuleName | Should -Be $script:resourceProperties.RuleName
                $result.Transport | Should -Be $script:resourceProperties.Transport
                $result.Description | Should -Be $script:resourceProperties.Description
                $result.Type | Should -Be $script:resourceProperties.Type
                $result.Psp | Should -Be $script:resourceProperties.Psp
                $result.PSPoptions | Should -Be ''
                $result.Vendor | Should -Be ''
                $result.Device | Should -Be ''
                $result.Driver | Should -Be ''
                $result.ClaimOptions | Should -Be ''
                $result.Options | Should -Be ''
                $result.Model | Should -Be ''
                $result.Boot | Should -Be $false
                $result.Force | Should -Be $false
            }
        }

        Context 'Invoking with Claim Rule Not Installed' {
            BeforeAll {
                # Arrange
                $viServerMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] @{ Name = '10.23.82.112'; User = 'user' }
                }
                $vmHostMock = {
                    return [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl] @{ Name = '10.23.82.112' }
                }
                $esxCliMock = {
                    $esxcli = New-Object PSObject
                    $esxcli | Add-Member -MemberType NoteProperty -Name 'storage' -Value (New-Object PSObject)
                    $esxcli.storage | Add-Member -MemberType NoteProperty -Name 'nmp' -Value (New-Object PSObject)
                    $esxcli.storage.nmp | Add-Member -MemberType NoteProperty -Name 'satp' -Value (New-Object PSObject)
                    $esxcli.storage.nmp.satp | Add-Member -MemberType NoteProperty -Name 'rule' -Value (New-Object PSObject)
                    $esxcli.storage.nmp.satp.rule | Add-Member -MemberType NoteProperty -Name 'list' -Value (New-Object PSObject)

                    $satpClaimRules = @(
                       [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_LOCAL_2'; Transport = 'VMW_SATP_LOCAL_2 Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' };
                       [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_NOT_LOCAL'; Transport = 'VMW_SATP_NOT_LOCAL Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' }
                    )

                    $esxcli.storage.nmp.satp.rule.list | Add-Member -MemberType ScriptMethod -Name 'Invoke' -Value { $satpClaimRules }

                    return $esxcli
                }
                $satpClaimRulesMock = {
                    return @(
                        [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_LOCAL_2'; Transport = 'VMW_SATP_LOCAL_2 Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' };
                        [VMware.Vim.SatpClaimRule] @{ Name = 'VMW_SATP_NOT_LOCAL'; Transport = 'VMW_SATP_NOT_LOCAL Transport'; Description = 'Description of VMW_SATP_LOCAL Claim Rule.'; DefaultPSP = 'VMW_PSP_MRU' }
                    )
                }

                Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
                Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
                Mock -CommandName Get-EsxCli -MockWith $esxCliMock -ModuleName $script:moduleName
                Mock -CommandName Get-SATPClaimRules -MockWith $satpClaimRulesMock -ModuleName $script:moduleName
            }

            # Arrange
            $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

            It 'Should return the resource with the properties retrieved from the server' {
                # Act
                $result = $resource.Get()

                # Assert
                $result.Name | Should -Be $script:resourceProperties.Name
                $result.Server | Should -Be $script:resourceProperties.Server
                $result.Ensure | Should -Be 'Absent'
                $result.RuleName | Should -Be $script:resourceProperties.RuleName
                $result.Transport | Should -Be $script:resourceProperties.Transport
                $result.Description | Should -Be $script:resourceProperties.Description
                $result.Type | Should -Be $script:resourceProperties.Type
                $result.Psp | Should -Be $script:resourceProperties.Psp
                $result.PSPoptions | Should -Be ''
                $result.Vendor | Should -Be ''
                $result.Device | Should -Be ''
                $result.Driver | Should -Be ''
                $result.ClaimOptions | Should -Be ''
                $result.Options | Should -Be ''
                $result.Model | Should -Be ''
                $result.Boot | Should -Be $false
                $result.Force | Should -Be $false
            }
        }
    }
}
finally {
    # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
    Invoke-TestCleanup
}
