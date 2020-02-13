<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-VMHostRoleProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostRoleProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        Name = $script:constants.RoleName
    }

    $vmHostRoleProperties
}

function New-MocksForVMHostRole {
    [CmdletBinding()]

    $viServerMock = $script:esxiServer

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Disconnect-VIServer -MockWith { return $null }.GetNewClosure() -Verifiable
}

function New-MocksWhenEnsureIsPresentTheRoleIsNotCreatedAndThereAreNoPassedPrivileges {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostRoleProperties = New-VMHostRoleProperties

    $vmHostRoleProperties.Ensure = 'Present'

    Mock -CommandName Get-VIRole -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Name -eq $script:constants.RoleName } -Verifiable
    Mock -CommandName New-VIRole -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostRoleProperties
}

function New-MocksWhenEnsureIsPresentTheRoleIsNotCreatedAndThereArePassedPrivileges {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostRoleProperties = New-VMHostRoleProperties

    $vmHostRoleProperties.Ensure = 'Present'
    $vmHostRoleProperties.PrivilegeIds = $script:constants.PrivilegeIds

    $anonymousPrivilegeMock = $script:anonymousPrivilege
    $viewPrivilegeMock = $script:viewPrivilege
    $readPrivilegeMock = $script:readPrivilege

    Mock -CommandName Get-VIRole -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Name -eq $script:constants.RoleName } -Verifiable
    Mock -CommandName Get-VIPrivilege -MockWith { return $anonymousPrivilegeMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Id -eq $script:constants.PrivilegeIds[0] } -Verifiable
    Mock -CommandName Get-VIPrivilege -MockWith { return $viewPrivilegeMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Id -eq $script:constants.PrivilegeIds[1] } -Verifiable
    Mock -CommandName Get-VIPrivilege -MockWith { return $readPrivilegeMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Id -eq $script:constants.PrivilegeIds[2] } -Verifiable
    Mock -CommandName New-VIRole -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostRoleProperties
}

function New-MocksInSetWhenEnsureIsPresentTheRoleIsAlreadyCreatedAndTheDesiredPrivilegeListIsDifferentFromTheCurrentPrivilegeList {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostRoleProperties = New-VMHostRoleProperties

    $vmHostRoleProperties.Ensure = 'Present'
    $vmHostRoleProperties.PrivilegeIds = $script:constants.PrivilegeToAddIds

    $vmHostRoleMock = $script:vmHostRole
    $anonymousPrivilegeMock = $script:anonymousPrivilege
    $viewPrivilegeMock = $script:viewPrivilege
    $createPrivilegeMock = $script:createPrivilege
    $readPrivilegeMock = $script:readPrivilege

    Mock -CommandName Get-VIRole -MockWith { return $vmHostRoleMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Name -eq $script:constants.RoleName } -Verifiable
    Mock -CommandName Get-VIPrivilege -MockWith { return $anonymousPrivilegeMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Id -eq $script:constants.PrivilegeToAddIds[0] } -Verifiable
    Mock -CommandName Get-VIPrivilege -MockWith { return $viewPrivilegeMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Id -eq $script:constants.PrivilegeToAddIds[1] } -Verifiable
    Mock -CommandName Get-VIPrivilege -MockWith { return $createPrivilegeMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Id -eq $script:constants.PrivilegeToAddIds[2] } -Verifiable
    Mock -CommandName Get-VIPrivilege -MockWith { return $readPrivilegeMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Id -eq $script:vmHostRole.PrivilegeList[2] } -Verifiable
    Mock -CommandName Set-VIRole -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Role -eq $script:vmHostRole -and !$Confirm } -Verifiable

    $vmHostRoleProperties
}

function New-MocksInSetWhenEnsureIsAbsentAndTheRoleIsAlreadyRemoved {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostRoleProperties = New-VMHostRoleProperties

    $vmHostRoleProperties.Ensure = 'Absent'

    Mock -CommandName Get-VIRole -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Name -eq $script:constants.RoleName } -Verifiable
    Mock -CommandName Remove-VIRole -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Role -eq $script:vmHostRole -and $Force -and !$Confirm }

    $vmHostRoleProperties
}

function New-MocksInSetWhenEnsureIsAbsentAndTheRoleIsNotRemoved {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostRoleProperties = New-VMHostRoleProperties

    $vmHostRoleProperties.Ensure = 'Absent'

    $vmHostRoleMock = $script:vmHostRole

    Mock -CommandName Get-VIRole -MockWith { return $vmHostRoleMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Name -eq $script:constants.RoleName } -Verifiable
    Mock -CommandName Remove-VIRole -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Role -eq $script:vmHostRole -and $Force -and !$Confirm } -Verifiable

    $vmHostRoleProperties
}

function New-MocksWhenEnsureIsPresentTheRoleIsAlreadyCreatedAndTheDesiredPrivilegeListIsDifferentFromTheCurrentPrivilegeList {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostRoleProperties = New-VMHostRoleProperties

    $vmHostRoleProperties.Ensure = 'Present'
    $vmHostRoleProperties.PrivilegeIds = $script:constants.PrivilegeToAddIds

    $vmHostRoleMock = $script:vmHostRole
    $anonymousPrivilegeMock = $script:anonymousPrivilege
    $viewPrivilegeMock = $script:viewPrivilege
    $createPrivilegeMock = $script:createPrivilege

    Mock -CommandName Get-VIRole -MockWith { return $vmHostRoleMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Name -eq $script:constants.RoleName } -Verifiable
    Mock -CommandName Get-VIPrivilege -MockWith { return $anonymousPrivilegeMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Id -eq $script:constants.PrivilegeToAddIds[0] } -Verifiable
    Mock -CommandName Get-VIPrivilege -MockWith { return $viewPrivilegeMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Id -eq $script:constants.PrivilegeToAddIds[1] } -Verifiable
    Mock -CommandName Get-VIPrivilege -MockWith { return $createPrivilegeMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Id -eq $script:constants.PrivilegeToAddIds[2] } -Verifiable

    $vmHostRoleProperties
}

function New-MocksWhenEnsureIsPresentTheRoleIsAlreadyCreatedAndTheDesiredPrivilegeListIsTheSameAsTheCurrentPrivilegeList {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostRoleProperties = New-VMHostRoleProperties

    $vmHostRoleProperties.Ensure = 'Present'
    $vmHostRoleProperties.PrivilegeIds = $script:constants.PrivilegeIds

    $vmHostRoleMock = $script:vmHostRole
    $anonymousPrivilegeMock = $script:anonymousPrivilege
    $viewPrivilegeMock = $script:viewPrivilege
    $readPrivilegeMock = $script:readPrivilege

    Mock -CommandName Get-VIRole -MockWith { return $vmHostRoleMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Name -eq $script:constants.RoleName } -Verifiable
    Mock -CommandName Get-VIPrivilege -MockWith { return $anonymousPrivilegeMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Id -eq $script:constants.PrivilegeIds[0] } -Verifiable
    Mock -CommandName Get-VIPrivilege -MockWith { return $viewPrivilegeMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Id -eq $script:constants.PrivilegeIds[1] } -Verifiable
    Mock -CommandName Get-VIPrivilege -MockWith { return $readPrivilegeMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Id -eq $script:constants.PrivilegeIds[2] } -Verifiable

    $vmHostRoleProperties
}

function New-MocksWhenEnsureIsPresentAndTheRoleIsNotCreated {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostRoleProperties = New-VMHostRoleProperties

    $vmHostRoleProperties.Ensure = 'Present'
    $vmHostRoleProperties.PrivilegeIds = $script:constants.PrivilegeToAddIds

    Mock -CommandName Get-VIRole -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Name -eq $script:constants.RoleName } -Verifiable

    $vmHostRoleProperties
}

function New-MocksWhenEnsureIsPresentAndTheRoleIsAlreadyCreated {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostRoleProperties = New-VMHostRoleProperties

    $vmHostRoleProperties.Ensure = 'Present'

    $vmHostRoleMock = $script:vmHostRole

    Mock -CommandName Get-VIRole -MockWith { return $vmHostRoleMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Name -eq $script:constants.RoleName } -Verifiable

    $vmHostRoleProperties
}

function New-MocksWhenEnsureIsAbsentAndTheRoleIsAlreadyRemoved {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostRoleProperties = New-VMHostRoleProperties

    $vmHostRoleProperties.Ensure = 'Absent'
    $vmHostRoleProperties.PrivilegeIds = $script:constants.PrivilegeToAddIds

    Mock -CommandName Get-VIRole -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Name -eq $script:constants.RoleName } -Verifiable

    $vmHostRoleProperties
}

function New-MocksWhenEnsureIsAbsentAndTheRoleIsNotRemoved {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostRoleProperties = New-VMHostRoleProperties

    $vmHostRoleProperties.Ensure = 'Absent'

    $vmHostRoleMock = $script:vmHostRole

    Mock -CommandName Get-VIRole -MockWith { return $vmHostRoleMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Name -eq $script:constants.RoleName } -Verifiable

    $vmHostRoleProperties
}
