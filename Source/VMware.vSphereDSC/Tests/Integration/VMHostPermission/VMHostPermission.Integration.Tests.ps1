<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

Param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $VCenterServer,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $VCenterUser,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $VCenterPassword,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $ESXiServer,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $ESXiUser,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $ESXiPassword
)

. "$PSScriptRoot\VMHostPermission.Integration.Tests.Helpers.ps1"
Get-EntityInformation

$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ESXiUser, (ConvertTo-SecureString -String $ESXiPassword -AsPlainText -Force)

$script:dscResourceName = 'VMHostPermission'
$script:moduleFolderPath = (Get-Module -Name 'VMware.vSphereDSC' -ListAvailable).ModuleBase
$script:integrationTestsFolderPath = Join-Path -Path (Join-Path -Path $moduleFolderPath -ChildPath 'Tests') -ChildPath 'Integration'
$script:configurationFile = "$script:integrationTestsFolderPath\Configurations\$script:dscResourceName\$($script:dscResourceName)_Config.ps1"
$script:secondsToSleep = 20

$script:configurationData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
            Server = $ESXiServer
            Credential = $Credential
            VMHostRoleResourceName = 'VMHostRole'
            VMHostPermissionResourceName = 'VMHostPermission'
            VMHostUserAccountName = 'MyTestPrincipal'
            VMHostUserAccountPassword = 'MyAccountPass1!'
            DatacenterEntityName = $script:datacenterEntityName
            VMHostEntityName = $script:vmHostEntityName
            DatastoreEntityName = 'MyTestVmfsDatastore'
            ResourcePoolEntityName = 'MyTestResourcePool'
            VAppEntityName = 'MyTestvApp'
            VMEntityName = 'MyTestVM'
            RoleOneName = 'MyTestDscRoleOne'
            RoleTwoName = 'MyTestDscRoleTwo'
            EmptyEntityLocation = [string]::Empty
            OneResourcePoolEntityLocation = 'MyTestResourcePool'
            OneResourcePoolAndOneVAppEntityLocation = 'MyTestResourcePool/MyTestvApp'
            PropagatePermission = $true
        }
    )
}

$script:configCreateVMHostRoles = "$($script:dscResourceName)_CreateVMHostRoles_Config"
$script:configCreateVMHostPermissionForDatacenterEntity = "$($script:dscResourceName)_CreateVMHostPermissionForDatacenterEntity_Config"
$script:configCreateVMHostPermissionForVMHostEntity = "$($script:dscResourceName)_CreateVMHostPermissionForVMHostEntity_Config"
$script:configCreateVMHostPermissionForDatastoreEntity = "$($script:dscResourceName)_CreateVMHostPermissionForDatastoreEntity_Config"
$script:configCreateVMHostPermissionForResourcePoolEntity = "$($script:dscResourceName)_CreateVMHostPermissionForResourcePoolEntity_Config"
$script:configCreateVMHostPermissionForVMEntityWithEmptyEntityLocation = "$($script:dscResourceName)_CreateVMHostPermissionForVMEntityWithEmptyEntityLocation_Config"
$script:configCreateVMHostPermissionForVMEntityWithOneResourcePoolEntityLocation = "$($script:dscResourceName)_CreateVMHostPermissionForVMEntityWithOneResourcePoolEntityLocation_Config"
$script:configCreateVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocation = "$($script:dscResourceName)_CreateVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocation_Config"
$script:configModifyVMHostPermissionRoleAndPropagateBehaviour = "$($script:dscResourceName)_ModifyVMHostPermissionRoleAndPropagateBehaviour_Config"
$script:configRemoveVMHostPermissionForDatacenterEntity = "$($script:dscResourceName)_RemoveVMHostPermissionForDatacenterEntity_Config"
$script:configRemoveVMHostPermissionForVMHostEntity = "$($script:dscResourceName)_RemoveVMHostPermissionForVMHostEntity_Config"
$script:configRemoveVMHostPermissionForDatastoreEntity = "$($script:dscResourceName)_RemoveVMHostPermissionForDatastoreEntity_Config"
$script:configRemoveVMHostPermissionForResourcePoolEntity = "$($script:dscResourceName)_RemoveVMHostPermissionForResourcePoolEntity_Config"
$script:configRemoveVMHostPermissionForVMEntityWithEmptyEntityLocation = "$($script:dscResourceName)_RemoveVMHostPermissionForVMEntityWithEmptyEntityLocation_Config"
$script:configRemoveVMHostPermissionForVMEntityWithOneResourcePoolEntityLocation = "$($script:dscResourceName)_RemoveVMHostPermissionForVMEntityWithOneResourcePoolEntityLocation_Config"
$script:configRemoveVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocation = "$($script:dscResourceName)_RemoveVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocation_Config"
$script:configRemoveVMHostRoles = "$($script:dscResourceName)_RemoveVMHostRoles_Config"

. $script:configurationFile -ErrorAction Stop

$script:mofFileCreateVMHostRolesPath = "$script:integrationTestsFolderPath\$script:configCreateVMHostRoles\"
$script:mofFileCreateVMHostPermissionForDatacenterEntityPath = "$script:integrationTestsFolderPath\$script:configCreateVMHostPermissionForDatacenterEntity\"
$script:mofFileCreateVMHostPermissionForVMHostEntityPath = "$script:integrationTestsFolderPath\$script:configCreateVMHostPermissionForVMHostEntity\"
$script:mofFileCreateVMHostPermissionForDatastoreEntityPath = "$script:integrationTestsFolderPath\$script:configCreateVMHostPermissionForDatastoreEntity\"
$script:mofFileCreateVMHostPermissionForResourcePoolEntityPath = "$script:integrationTestsFolderPath\$script:configCreateVMHostPermissionForResourcePoolEntity\"
$script:mofFileCreateVMHostPermissionForVMEntityWithEmptyEntityLocationPath = "$script:integrationTestsFolderPath\$script:configCreateVMHostPermissionForVMEntityWithEmptyEntityLocation\"
$script:mofFileCreateVMHostPermissionForVMEntityWithOneResourcePoolEntityLocationPath = "$script:integrationTestsFolderPath\$script:configCreateVMHostPermissionForVMEntityWithOneResourcePoolEntityLocation\"
$script:mofFileCreateVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocationPath = "$script:integrationTestsFolderPath\$script:configCreateVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocation\"
$script:mofFileModifyVMHostPermissionRoleAndPropagateBehaviourPath = "$script:integrationTestsFolderPath\$script:configModifyVMHostPermissionRoleAndPropagateBehaviour\"
$script:mofFileRemoveVMHostPermissionForDatacenterEntityPath = "$script:integrationTestsFolderPath\$script:configRemoveVMHostPermissionForDatacenterEntity\"
$script:mofFileRemoveVMHostPermissionForVMHostEntityPath = "$script:integrationTestsFolderPath\$script:configRemoveVMHostPermissionForVMHostEntity\"
$script:mofFileRemoveVMHostPermissionForDatastoreEntityPath = "$script:integrationTestsFolderPath\$script:configRemoveVMHostPermissionForDatastoreEntity\"
$script:mofFileRemoveVMHostPermissionForResourcePoolEntityPath = "$script:integrationTestsFolderPath\$script:configRemoveVMHostPermissionForResourcePoolEntity\"
$script:mofFileRemoveVMHostPermissionForVMEntityWithEmptyEntityLocationPath = "$script:integrationTestsFolderPath\$script:configRemoveVMHostPermissionForVMEntityWithEmptyEntityLocation\"
$script:mofFileRemoveVMHostPermissionForVMEntityWithOneResourcePoolEntityLocationPath = "$script:integrationTestsFolderPath\$script:configRemoveVMHostPermissionForVMEntityWithOneResourcePoolEntityLocation\"
$script:mofFileRemoveVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocationPath = "$script:integrationTestsFolderPath\$script:configRemoveVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocation\"
$script:mofFileRemoveVMHostRolesPath = "$script:integrationTestsFolderPath\$script:configRemoveVMHostRoles\"

Describe "$($script:dscResourceName)_Integration" {
    Context "When using configuration $script:configCreateVMHostPermissionForDatacenterEntity" {
        BeforeAll {
            # Arrange
            & $script:configCreateVMHostRoles `
                -OutputPath $script:mofFileCreateVMHostRolesPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configCreateVMHostPermissionForDatacenterEntity `
                -OutputPath $script:mofFileCreateVMHostPermissionForDatacenterEntityPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersCreateVMHostRoles = @{
                Path = $script:mofFileCreateVMHostRolesPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersCreateVMHostPermissionForDatacenterEntity = @{
                Path = $script:mofFileCreateVMHostPermissionForDatacenterEntityPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            New-VMHostUserAccount

            Start-DscConfiguration @startDscConfigurationParametersCreateVMHostRoles
            Start-DscConfiguration @startDscConfigurationParametersCreateVMHostPermissionForDatacenterEntity
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileCreateVMHostPermissionForDatacenterEntityPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            # Arrange && Act && Assert
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration and all parameters should match' {
            # Arrange && Act
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configCreateVMHostPermissionForDatacenterEntity }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.EntityName | Should -Be $script:configurationData.AllNodes.DatacenterEntityName
            $configuration.EntityLocation | Should -Be $script:configurationData.AllNodes.EmptyEntityLocation
            $configuration.EntityType | Should -Be 'Datacenter'
            $configuration.PrincipalName | Should -Be $script:configurationData.AllNodes.VMHostUserAccountName
            $configuration.RoleName | Should -Be $script:configurationData.AllNodes.RoleOneName
            $configuration.Ensure | Should -Be 'Present'
            $configuration.Propagate | Should -Be $script:configurationData.AllNodes.PropagatePermission
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileCreateVMHostPermissionForDatacenterEntityPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configRemoveVMHostPermissionForDatacenterEntity `
                -OutputPath $script:mofFileRemoveVMHostPermissionForDatacenterEntityPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configRemoveVMHostRoles `
                -OutputPath $script:mofFileRemoveVMHostRolesPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersRemoveVMHostPermissionForDatacenterEntity = @{
                Path = $script:mofFileRemoveVMHostPermissionForDatacenterEntityPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersRemoveVMHostRoles = @{
                Path = $script:mofFileRemoveVMHostRolesPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersRemoveVMHostPermissionForDatacenterEntity
            Start-DscConfiguration @startDscConfigurationParametersRemoveVMHostRoles

            Remove-VMHostUserAccount

            Remove-Item -Path $script:mofFileCreateVMHostRolesPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileCreateVMHostPermissionForDatacenterEntityPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVMHostPermissionForDatacenterEntityPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVMHostRolesPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configCreateVMHostPermissionForVMHostEntity" {
        BeforeAll {
            # Arrange
            & $script:configCreateVMHostRoles `
                -OutputPath $script:mofFileCreateVMHostRolesPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configCreateVMHostPermissionForVMHostEntity `
                -OutputPath $script:mofFileCreateVMHostPermissionForVMHostEntityPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersCreateVMHostRoles = @{
                Path = $script:mofFileCreateVMHostRolesPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersCreateVMHostPermissionForVMHostEntity = @{
                Path = $script:mofFileCreateVMHostPermissionForVMHostEntityPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            New-VMHostUserAccount

            Start-DscConfiguration @startDscConfigurationParametersCreateVMHostRoles
            Start-DscConfiguration @startDscConfigurationParametersCreateVMHostPermissionForVMHostEntity
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileCreateVMHostPermissionForVMHostEntityPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            # Arrange && Act && Assert
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration and all parameters should match' {
            # Arrange && Act
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configCreateVMHostPermissionForVMHostEntity }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.EntityName | Should -Be $script:configurationData.AllNodes.VMHostEntityName
            $configuration.EntityLocation | Should -Be $script:configurationData.AllNodes.EmptyEntityLocation
            $configuration.EntityType | Should -Be 'VMHost'
            $configuration.PrincipalName | Should -Be $script:configurationData.AllNodes.VMHostUserAccountName
            $configuration.RoleName | Should -Be $script:configurationData.AllNodes.RoleOneName
            $configuration.Ensure | Should -Be 'Present'
            $configuration.Propagate | Should -Be $script:configurationData.AllNodes.PropagatePermission
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileCreateVMHostPermissionForVMHostEntityPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configRemoveVMHostPermissionForVMHostEntity `
                -OutputPath $script:mofFileRemoveVMHostPermissionForVMHostEntityPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configRemoveVMHostRoles `
                -OutputPath $script:mofFileRemoveVMHostRolesPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersRemoveVMHostPermissionForVMHostEntity = @{
                Path = $script:mofFileRemoveVMHostPermissionForVMHostEntityPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersRemoveVMHostRoles = @{
                Path = $script:mofFileRemoveVMHostRolesPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersRemoveVMHostPermissionForVMHostEntity
            Start-DscConfiguration @startDscConfigurationParametersRemoveVMHostRoles

            Remove-VMHostUserAccount

            Remove-Item -Path $script:mofFileCreateVMHostRolesPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileCreateVMHostPermissionForVMHostEntityPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVMHostPermissionForVMHostEntityPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVMHostRolesPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configCreateVMHostPermissionForDatastoreEntity" {
        BeforeAll {
            # Arrange
            & $script:configCreateVMHostRoles `
                -OutputPath $script:mofFileCreateVMHostRolesPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configCreateVMHostPermissionForDatastoreEntity `
                -OutputPath $script:mofFileCreateVMHostPermissionForDatastoreEntityPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersCreateVMHostRoles = @{
                Path = $script:mofFileCreateVMHostRolesPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersCreateVMHostPermissionForDatastoreEntity = @{
                Path = $script:mofFileCreateVMHostPermissionForDatastoreEntityPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            New-VMHostUserAccount
            New-VmfsDatastore

            Start-DscConfiguration @startDscConfigurationParametersCreateVMHostRoles
            Start-DscConfiguration @startDscConfigurationParametersCreateVMHostPermissionForDatastoreEntity
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileCreateVMHostPermissionForDatastoreEntityPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            # Arrange && Act && Assert
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration and all parameters should match' {
            # Arrange && Act
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configCreateVMHostPermissionForDatastoreEntity }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.EntityName | Should -Be $script:configurationData.AllNodes.DatastoreEntityName
            $configuration.EntityLocation | Should -Be $script:configurationData.AllNodes.EmptyEntityLocation
            $configuration.EntityType | Should -Be 'Datastore'
            $configuration.PrincipalName | Should -Be $script:configurationData.AllNodes.VMHostUserAccountName
            $configuration.RoleName | Should -Be $script:configurationData.AllNodes.RoleOneName
            $configuration.Ensure | Should -Be 'Present'
            $configuration.Propagate | Should -Be $script:configurationData.AllNodes.PropagatePermission
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileCreateVMHostPermissionForDatastoreEntityPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configRemoveVMHostPermissionForDatastoreEntity `
                -OutputPath $script:mofFileRemoveVMHostPermissionForDatastoreEntityPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configRemoveVMHostRoles `
                -OutputPath $script:mofFileRemoveVMHostRolesPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersRemoveVMHostPermissionForDatastoreEntity = @{
                Path = $script:mofFileRemoveVMHostPermissionForDatastoreEntityPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersRemoveVMHostRoles = @{
                Path = $script:mofFileRemoveVMHostRolesPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersRemoveVMHostPermissionForDatastoreEntity
            Start-DscConfiguration @startDscConfigurationParametersRemoveVMHostRoles

            Remove-VMHostUserAccount
            Remove-VmfsDatastore

            Remove-Item -Path $script:mofFileCreateVMHostRolesPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileCreateVMHostPermissionForDatastoreEntityPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVMHostPermissionForDatastoreEntityPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVMHostRolesPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configCreateVMHostPermissionForResourcePoolEntity" {
        BeforeAll {
            # Arrange
            & $script:configCreateVMHostRoles `
                -OutputPath $script:mofFileCreateVMHostRolesPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configCreateVMHostPermissionForResourcePoolEntity `
                -OutputPath $script:mofFileCreateVMHostPermissionForResourcePoolEntityPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersCreateVMHostRoles = @{
                Path = $script:mofFileCreateVMHostRolesPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersCreateVMHostPermissionForResourcePoolEntity = @{
                Path = $script:mofFileCreateVMHostPermissionForResourcePoolEntityPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            New-VMHostUserAccount

            New-VMHostResourcePool
            Start-Sleep -Seconds $script:secondsToSleep

            Start-DscConfiguration @startDscConfigurationParametersCreateVMHostRoles
            Start-DscConfiguration @startDscConfigurationParametersCreateVMHostPermissionForResourcePoolEntity
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileCreateVMHostPermissionForResourcePoolEntityPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            # Arrange && Act && Assert
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration and all parameters should match' {
            # Arrange && Act
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configCreateVMHostPermissionForResourcePoolEntity }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.EntityName | Should -Be $script:configurationData.AllNodes.ResourcePoolEntityName
            $configuration.EntityLocation | Should -Be $script:configurationData.AllNodes.EmptyEntityLocation
            $configuration.EntityType | Should -Be 'ResourcePool'
            $configuration.PrincipalName | Should -Be $script:configurationData.AllNodes.VMHostUserAccountName
            $configuration.RoleName | Should -Be $script:configurationData.AllNodes.RoleOneName
            $configuration.Ensure | Should -Be 'Present'
            $configuration.Propagate | Should -Be $script:configurationData.AllNodes.PropagatePermission
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileCreateVMHostPermissionForResourcePoolEntityPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configRemoveVMHostPermissionForResourcePoolEntity `
                -OutputPath $script:mofFileRemoveVMHostPermissionForResourcePoolEntityPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configRemoveVMHostRoles `
                -OutputPath $script:mofFileRemoveVMHostRolesPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersRemoveVMHostPermissionForResourcePoolEntity = @{
                Path = $script:mofFileRemoveVMHostPermissionForResourcePoolEntityPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersRemoveVMHostRoles = @{
                Path = $script:mofFileRemoveVMHostRolesPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersRemoveVMHostPermissionForResourcePoolEntity
            Start-DscConfiguration @startDscConfigurationParametersRemoveVMHostRoles

            Remove-VMHostUserAccount
            Remove-VMHostResourcePool

            Remove-Item -Path $script:mofFileCreateVMHostRolesPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileCreateVMHostPermissionForResourcePoolEntityPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVMHostPermissionForResourcePoolEntityPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVMHostRolesPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configCreateVMHostPermissionForVMEntityWithEmptyEntityLocation" {
        BeforeAll {
            # Arrange
            & $script:configCreateVMHostRoles `
                -OutputPath $script:mofFileCreateVMHostRolesPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configCreateVMHostPermissionForVMEntityWithEmptyEntityLocation `
                -OutputPath $script:mofFileCreateVMHostPermissionForVMEntityWithEmptyEntityLocationPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersCreateVMHostRoles = @{
                Path = $script:mofFileCreateVMHostRolesPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersCreateVMHostPermissionForVMEntityWithEmptyEntityLocation = @{
                Path = $script:mofFileCreateVMHostPermissionForVMEntityWithEmptyEntityLocationPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            New-VMHostUserAccount
            New-VirtualMachinePlacedInTheRootResourcePoolOfTheVMHost

            Start-DscConfiguration @startDscConfigurationParametersCreateVMHostRoles
            Start-DscConfiguration @startDscConfigurationParametersCreateVMHostPermissionForVMEntityWithEmptyEntityLocation
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileCreateVMHostPermissionForVMEntityWithEmptyEntityLocationPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            # Arrange && Act && Assert
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration and all parameters should match' {
            # Arrange && Act
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configCreateVMHostPermissionForVMEntityWithEmptyEntityLocation }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.EntityName | Should -Be $script:configurationData.AllNodes.VMEntityName
            $configuration.EntityLocation | Should -Be $script:configurationData.AllNodes.EmptyEntityLocation
            $configuration.EntityType | Should -Be 'VM'
            $configuration.PrincipalName | Should -Be $script:configurationData.AllNodes.VMHostUserAccountName
            $configuration.RoleName | Should -Be $script:configurationData.AllNodes.RoleOneName
            $configuration.Ensure | Should -Be 'Present'
            $configuration.Propagate | Should -Be $script:configurationData.AllNodes.PropagatePermission
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileCreateVMHostPermissionForVMEntityWithEmptyEntityLocationPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configRemoveVMHostPermissionForVMEntityWithEmptyEntityLocation `
                -OutputPath $script:mofFileRemoveVMHostPermissionForVMEntityWithEmptyEntityLocationPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configRemoveVMHostRoles `
                -OutputPath $script:mofFileRemoveVMHostRolesPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersRemoveVMHostPermissionForVMEntityWithEmptyEntityLocation = @{
                Path = $script:mofFileRemoveVMHostPermissionForVMEntityWithEmptyEntityLocationPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersRemoveVMHostRoles = @{
                Path = $script:mofFileRemoveVMHostRolesPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersRemoveVMHostPermissionForVMEntityWithEmptyEntityLocation
            Start-DscConfiguration @startDscConfigurationParametersRemoveVMHostRoles

            Remove-VMHostUserAccount
            Remove-VirtualMachinePlacedInTheRootResourcePoolOfTheVMHost

            Remove-Item -Path $script:mofFileCreateVMHostRolesPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileCreateVMHostPermissionForVMEntityWithEmptyEntityLocationPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVMHostPermissionForVMEntityWithEmptyEntityLocationPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVMHostRolesPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configCreateVMHostPermissionForVMEntityWithOneResourcePoolEntityLocation" {
        BeforeAll {
            # Arrange
            & $script:configCreateVMHostRoles `
                -OutputPath $script:mofFileCreateVMHostRolesPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configCreateVMHostPermissionForVMEntityWithOneResourcePoolEntityLocation `
                -OutputPath $script:mofFileCreateVMHostPermissionForVMEntityWithOneResourcePoolEntityLocationPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersCreateVMHostRoles = @{
                Path = $script:mofFileCreateVMHostRolesPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersCreateVMHostPermissionForVMEntityWithOneResourcePoolEntityLocation = @{
                Path = $script:mofFileCreateVMHostPermissionForVMEntityWithOneResourcePoolEntityLocationPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            New-VMHostUserAccount

            New-VMHostResourcePool
            Start-Sleep -Seconds $script:secondsToSleep

            New-VirtualMachinePlacedInResourcePool

            Start-DscConfiguration @startDscConfigurationParametersCreateVMHostRoles
            Start-DscConfiguration @startDscConfigurationParametersCreateVMHostPermissionForVMEntityWithOneResourcePoolEntityLocation
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileCreateVMHostPermissionForVMEntityWithOneResourcePoolEntityLocationPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            # Arrange && Act && Assert
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration and all parameters should match' {
            # Arrange && Act
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configCreateVMHostPermissionForVMEntityWithOneResourcePoolEntityLocation }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.EntityName | Should -Be $script:configurationData.AllNodes.VMEntityName
            $configuration.EntityLocation | Should -Be $script:configurationData.AllNodes.OneResourcePoolEntityLocation
            $configuration.EntityType | Should -Be 'VM'
            $configuration.PrincipalName | Should -Be $script:configurationData.AllNodes.VMHostUserAccountName
            $configuration.RoleName | Should -Be $script:configurationData.AllNodes.RoleOneName
            $configuration.Ensure | Should -Be 'Present'
            $configuration.Propagate | Should -Be $script:configurationData.AllNodes.PropagatePermission
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileCreateVMHostPermissionForVMEntityWithOneResourcePoolEntityLocationPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configRemoveVMHostPermissionForVMEntityWithOneResourcePoolEntityLocation `
                -OutputPath $script:mofFileRemoveVMHostPermissionForVMEntityWithOneResourcePoolEntityLocationPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configRemoveVMHostRoles `
                -OutputPath $script:mofFileRemoveVMHostRolesPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersRemoveVMHostPermissionForVMEntityWithOneResourcePoolEntityLocation = @{
                Path = $script:mofFileRemoveVMHostPermissionForVMEntityWithOneResourcePoolEntityLocationPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersRemoveVMHostRoles = @{
                Path = $script:mofFileRemoveVMHostRolesPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersRemoveVMHostPermissionForVMEntityWithOneResourcePoolEntityLocation
            Start-DscConfiguration @startDscConfigurationParametersRemoveVMHostRoles

            Remove-VMHostUserAccount
            Remove-VirtualMachinePlacedInResourcePool
            Remove-VMHostResourcePool

            Remove-Item -Path $script:mofFileCreateVMHostRolesPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileCreateVMHostPermissionForVMEntityWithOneResourcePoolEntityLocationPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVMHostPermissionForVMEntityWithOneResourcePoolEntityLocationPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVMHostRolesPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configCreateVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocation" {
        BeforeAll {
            # Arrange
            & $script:configCreateVMHostRoles `
                -OutputPath $script:mofFileCreateVMHostRolesPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configCreateVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocation `
                -OutputPath $script:mofFileCreateVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocationPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersCreateVMHostRoles = @{
                Path = $script:mofFileCreateVMHostRolesPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersCreateVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocation = @{
                Path = $script:mofFileCreateVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocationPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            New-VMHostUserAccount

            New-VMHostResourcePool
            Start-Sleep -Seconds $script:secondsToSleep

            New-VMHostVApp
            Start-Sleep -Seconds $script:secondsToSleep

            New-VirtualMachinePlacedInVApp

            Start-DscConfiguration @startDscConfigurationParametersCreateVMHostRoles
            Start-DscConfiguration @startDscConfigurationParametersCreateVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocation
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileCreateVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocationPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            # Arrange && Act && Assert
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration and all parameters should match' {
            # Arrange && Act
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configCreateVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocation }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.EntityName | Should -Be $script:configurationData.AllNodes.VMEntityName
            $configuration.EntityLocation | Should -Be $script:configurationData.AllNodes.OneResourcePoolAndOneVAppEntityLocation
            $configuration.EntityType | Should -Be 'VM'
            $configuration.PrincipalName | Should -Be $script:configurationData.AllNodes.VMHostUserAccountName
            $configuration.RoleName | Should -Be $script:configurationData.AllNodes.RoleOneName
            $configuration.Ensure | Should -Be 'Present'
            $configuration.Propagate | Should -Be $script:configurationData.AllNodes.PropagatePermission
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileCreateVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocationPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configRemoveVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocation `
                -OutputPath $script:mofFileRemoveVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocationPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configRemoveVMHostRoles `
                -OutputPath $script:mofFileRemoveVMHostRolesPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersRemoveVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocation = @{
                Path = $script:mofFileRemoveVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocationPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersRemoveVMHostRoles = @{
                Path = $script:mofFileRemoveVMHostRolesPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersRemoveVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocation
            Start-DscConfiguration @startDscConfigurationParametersRemoveVMHostRoles

            Remove-VMHostUserAccount
            Remove-VirtualMachinePlacedInVApp
            Remove-VMHostVApp
            Remove-VMHostResourcePool

            Remove-Item -Path $script:mofFileCreateVMHostRolesPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileCreateVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocationPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocationPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVMHostRolesPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configModifyVMHostPermissionRoleAndPropagateBehaviour" {
        BeforeAll {
            # Arrange
            & $script:configCreateVMHostRoles `
                -OutputPath $script:mofFileCreateVMHostRolesPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configCreateVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocation `
                -OutputPath $script:mofFileCreateVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocationPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configModifyVMHostPermissionRoleAndPropagateBehaviour `
                -OutputPath $script:mofFileModifyVMHostPermissionRoleAndPropagateBehaviourPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersCreateVMHostRoles = @{
                Path = $script:mofFileCreateVMHostRolesPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersCreateVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocation = @{
                Path = $script:mofFileCreateVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocationPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersModifyVMHostPermissionRoleAndPropagateBehaviour = @{
                Path = $script:mofFileModifyVMHostPermissionRoleAndPropagateBehaviourPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            New-VMHostUserAccount

            New-VMHostResourcePool
            Start-Sleep -Seconds $script:secondsToSleep

            New-VMHostVApp
            Start-Sleep -Seconds $script:secondsToSleep

            New-VirtualMachinePlacedInVApp

            Start-DscConfiguration @startDscConfigurationParametersCreateVMHostRoles
            Start-DscConfiguration @startDscConfigurationParametersCreateVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocation
            Start-DscConfiguration @startDscConfigurationParametersModifyVMHostPermissionRoleAndPropagateBehaviour
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileModifyVMHostPermissionRoleAndPropagateBehaviourPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            # Arrange && Act && Assert
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration and all parameters should match' {
            # Arrange && Act
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configModifyVMHostPermissionRoleAndPropagateBehaviour }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.EntityName | Should -Be $script:configurationData.AllNodes.VMEntityName
            $configuration.EntityLocation | Should -Be $script:configurationData.AllNodes.OneResourcePoolAndOneVAppEntityLocation
            $configuration.EntityType | Should -Be 'VM'
            $configuration.PrincipalName | Should -Be $script:configurationData.AllNodes.VMHostUserAccountName
            $configuration.RoleName | Should -Be $script:configurationData.AllNodes.RoleTwoName
            $configuration.Ensure | Should -Be 'Present'
            $configuration.Propagate | Should -BeFalse
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileModifyVMHostPermissionRoleAndPropagateBehaviourPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configRemoveVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocation `
                -OutputPath $script:mofFileRemoveVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocationPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configRemoveVMHostRoles `
                -OutputPath $script:mofFileRemoveVMHostRolesPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersRemoveVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocation = @{
                Path = $script:mofFileRemoveVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocationPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersRemoveVMHostRoles = @{
                Path = $script:mofFileRemoveVMHostRolesPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersRemoveVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocation
            Start-DscConfiguration @startDscConfigurationParametersRemoveVMHostRoles

            Remove-VMHostUserAccount
            Remove-VirtualMachinePlacedInVApp
            Remove-VMHostVApp
            Remove-VMHostResourcePool

            Remove-Item -Path $script:mofFileCreateVMHostRolesPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileCreateVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocationPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileModifyVMHostPermissionRoleAndPropagateBehaviourPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocationPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVMHostRolesPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configRemoveVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocation" {
        BeforeAll {
            # Arrange
            & $script:configCreateVMHostRoles `
                -OutputPath $script:mofFileCreateVMHostRolesPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configCreateVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocation `
                -OutputPath $script:mofFileCreateVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocationPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configRemoveVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocation `
                -OutputPath $script:mofFileRemoveVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocationPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersCreateVMHostRoles = @{
                Path = $script:mofFileCreateVMHostRolesPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersCreateVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocation = @{
                Path = $script:mofFileCreateVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocationPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersRemoveVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocation = @{
                Path = $script:mofFileRemoveVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocationPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            New-VMHostUserAccount

            New-VMHostResourcePool
            Start-Sleep -Seconds $script:secondsToSleep

            New-VMHostVApp
            Start-Sleep -Seconds $script:secondsToSleep

            New-VirtualMachinePlacedInVApp

            Start-DscConfiguration @startDscConfigurationParametersCreateVMHostRoles
            Start-DscConfiguration @startDscConfigurationParametersCreateVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocation
            Start-DscConfiguration @startDscConfigurationParametersRemoveVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocation
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileRemoveVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocationPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            # Arrange && Act && Assert
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration and all parameters should match' {
            # Arrange && Act
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configRemoveVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocation }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.EntityName | Should -Be $script:configurationData.AllNodes.VMEntityName
            $configuration.EntityLocation | Should -Be $script:configurationData.AllNodes.OneResourcePoolAndOneVAppEntityLocation
            $configuration.EntityType | Should -Be 'VM'
            $configuration.PrincipalName | Should -Be $script:configurationData.AllNodes.VMHostUserAccountName
            $configuration.RoleName | Should -Be $script:configurationData.AllNodes.RoleOneName
            $configuration.Ensure | Should -Be 'Absent'
            $configuration.Propagate | Should -BeNullOrEmpty
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileRemoveVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocationPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configRemoveVMHostRoles `
                -OutputPath $script:mofFileRemoveVMHostRolesPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileRemoveVMHostRolesPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-VMHostUserAccount
            Remove-VirtualMachinePlacedInVApp
            Remove-VMHostVApp
            Remove-VMHostResourcePool

            Remove-Item -Path $script:mofFileCreateVMHostRolesPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileCreateVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocationPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVMHostPermissionForVMEntityWithOneResourcePoolAndOneVAppEntityLocationPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVMHostRolesPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }
}
