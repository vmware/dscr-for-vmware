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
$script:resourceName = 'VMHostVss'

$user = 'user'
$password = 'password' | ConvertTo-SecureString -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($user, $password)

$script:VssName = 'DSCTest'
$script:VssKey = 'VSS'
$script:NumPortsAvailable = 1
$script:Pnic = @('vmnic1', 'vmnic2')
$script:Portgroup = @('Portgroup')

$script:resourceProperties = @{
    Name = '10.23.82.112'
    Server = '10.23.82.112'
    Credential = $credential
    Ensure = 'Present'
    VssName = $script:VssName
    NumPorts = 1
    Mtu = 1500
}

function BeforeAllTests {
    $env:PSModulePath = $script:mockModuleLocation
    $vimAutomationModule = Get-Module -Name VMware.VimAutomation.Core
    if ($null -ne $vimAutomationModule -and $vimAutomationModule.Path -NotMatch 'TestHelpers') {
        throw 'The Original VMware.VimAutomation.Core Module is loaded in the current session. If you want to run the unit tests please open a new PowerShell session.'
    }

    Import-Module -Name VMware.VimAutomation.Core
}

function AfterAllTests {
    Remove-Module -Name VMware.VimAutomation.Core
    $env:PSModulePath = $script:modulePath
}

# Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
BeforeAllTests

Describe 'VMHostVss\Set'  -Tag 'Set' {
    AfterEach {}

    Context 'VSS does not exist' {}

    Context 'VSS does exist with different properties' {}

    Context 'VSS does exist with the same properties' {}
}

Describe 'VMHostVss\Test' -Tag 'Test' {
    AfterEach {}

    Context 'Present + VSS does not exist' {}

    Context 'Present + VSS does exist with different properties' {}

    Context 'Present + VSS does exist with the same properties' {}

    Context 'Absent + VSS does not exist' {}

    Context 'Absent + VSS does exist with different properties' {}

    Context 'Absent + VSS does exist with the same properties' {}
}

Describe 'VMHostVss\Get' -Tag 'Get' {
    BeforeAll {
        $vCenter = [VMware.Vim.VCenter] @{ Name = '10.23.82.112'; User = 'user' }
        $networkSystemMoRef = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostNetworkSystem'; Value = 'NetworkId' }

        $vCenterMock = {
            return [VMware.Vim.VCenter] @{ Name = '10.23.82.112'; User = 'user'}
        }
        $vmHostMock = {
            return [VMware.Vim.VMHost] @{
                Name = '10.23.82.112'
                ExtensionData = [VMware.Vim.HostExtensionData] @{
                    ConfigManager = [VMware.Vim.HostConfigManager] @{
                        NetworkSystem = [VMware.Vim.ManagedObjectReference] @{ Type = 'HostNetworkSystem'; Value = 'NetworkId' }
                    }
                }
            }
        }
        $networkSystemMock = {
            write-host ">$($Id)<"
            return (
                [VMware.Vim.HostNetworkSystem] @{
                    NetworkInfo = [VMware.Vim.HostNetworkInfo] @{
                        vswitch = @(
                            [VMware.Vim.HostVirtualSwitch]@{
                                Key = $script:VssKey
                                Mtu = $script:resourceProperties.Mtu
                                Name = $script:resourceProperties.VssName
                                NumPorts = $script:resourceProperties.NumPorts
                                NumPortsAvailable = $script:NumPortsAvailable
                                Pnic = $script:Pnic
                                PortGroup = $script:Portgroup
                            }
                        )
                    }
                }
            )
        }
    }

    # Arrange
    Mock -CommandName Connect-VIServer -MockWith $vCenterMock -ModuleName $script:moduleName
    Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
    Mock -CommandName Get-View -MockWith $networkSystemMock -ModuleName $script:moduleName

    $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties
    $resource | fc -Depth 2 | Out-Default

    It 'Should call the Connect-VIServer mock with the passed server and credentials once' {
        # Act
        $resource.Get()

        # Assert
        Assert-MockCalled -CommandName Connect-VIServer `
            -ParameterFilter { $Server -eq $script:resourceProperties.Server -and $Credential -eq $script:resourceProperties.Credential } `
            -ModuleName $script:moduleName -Exactly 1 -Scope It
    }

    It 'Should call Get-VMHost with the passed server and name once' {
        # Act
        $resource.Get()

        # Assert
        Assert-MockCalled -CommandName Get-VMHost `
            -ParameterFilter { $Server -eq $vCenter -and $Name -eq $script:resourceProperties.Name } `
            -ModuleName $script:moduleName -Exactly 1 -Scope It
    }

    It 'Should call Get-View with the passed server and id once' {
        # Act
        $resource.Get()

        # Assert
        Assert-MockCalled -CommandName Get-View `
            -ParameterFilter { $Server -eq $vCenter -and $Id -eq $networkSystemMoRef } `
            -ModuleName $script:moduleName -Exactly 1 -Scope It
    }

    It 'Should match the properties retrieved from the server' {
        # Act
        $result = $resource.Get()

        # Assert
        $result.Ensure | Should -Be $script:resourceProperties.Ensure
        $result.Server | Should -Be $script:resourceProperties.Server
        $result.Credential | Should -Be $script:resourceProperties.Credential
        $result.Name | Should -Be $script:resourceProperties.Name
        $result.VssName | Should -Be $script:resourceProperties.VssName
        $result.NumPorts | Should -Be $script:resourceProperties.NumPorts
        $result.Mtu | Should -Be $script:resourceProperties.Mtu
    }
}

# Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
AfterAllTests