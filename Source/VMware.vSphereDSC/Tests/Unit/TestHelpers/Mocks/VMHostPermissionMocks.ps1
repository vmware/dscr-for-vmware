<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-VMHostPermissionProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostPermissionProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
    }

    $vmHostPermissionProperties
}

function New-MocksForVMHostPermission {
    [CmdletBinding()]

    $viServerMock = $script:esxiServer

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Disconnect-VIServer -MockWith { return $null }.GetNewClosure() -Verifiable
}

function New-MocksWhenEnsureIsPresentThePermissionIsNotCreatedAndTheEntityIsADatacenter {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostPermissionProperties = New-VMHostPermissionProperties

    $vmHostPermissionProperties.EntityName = $script:constants.DatacenterName
    $vmHostPermissionProperties.EntityLocation = [string]::Empty
    $vmHostPermissionProperties.EntityType = 'Datacenter'
    $vmHostPermissionProperties.PrincipalName = $script:constants.PrincipalName
    $vmHostPermissionProperties.RoleName = $script:constants.RoleName
    $vmHostPermissionProperties.Ensure = 'Present'
    $vmHostPermissionProperties.Propagate = $script:constants.PropagatePermission

    $entityMock = $script:datacenterEntity
    $principalMock = $script:principal
    $roleMock = $script:vmHostRole

    Mock -CommandName Get-Datacenter -MockWith { return $entityMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer } -Verifiable
    Mock -CommandName Get-VIAccount -MockWith { return $principalMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Id -eq $script:constants.PrincipalName } -Verifiable
    Mock -CommandName Get-VIRole -MockWith { return $roleMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Name -eq $script:constants.RoleName } -Verifiable
    Mock -CommandName Get-VIPermission -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Entity -eq $script:datacenterEntity -and $Principal -eq $script:principal } -Verifiable
    Mock -CommandName New-VIPermission -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostPermissionProperties
}

function New-MocksWhenEnsureIsPresentThePermissionIsNotCreatedAndTheEntityIsAVMHost {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostPermissionProperties = New-VMHostPermissionProperties

    $vmHostPermissionProperties.EntityName = $script:constants.VMHostName
    $vmHostPermissionProperties.EntityLocation = [string]::Empty
    $vmHostPermissionProperties.EntityType = 'VMHost'
    $vmHostPermissionProperties.PrincipalName = $script:constants.PrincipalName
    $vmHostPermissionProperties.RoleName = $script:constants.RoleName
    $vmHostPermissionProperties.Ensure = 'Present'
    $vmHostPermissionProperties.Propagate = $script:constants.PropagatePermission

    $entityMock = $script:vmHost
    $principalMock = $script:principal
    $roleMock = $script:vmHostRole

    Mock -CommandName Get-VMHost -MockWith { return $entityMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer } -Verifiable
    Mock -CommandName Get-VIAccount -MockWith { return $principalMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Id -eq $script:constants.PrincipalName } -Verifiable
    Mock -CommandName Get-VIRole -MockWith { return $roleMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Name -eq $script:constants.RoleName } -Verifiable
    Mock -CommandName Get-VIPermission -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Entity -eq $script:vmHost -and $Principal -eq $script:principal } -Verifiable
    Mock -CommandName New-VIPermission -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostPermissionProperties
}

function New-MocksWhenEnsureIsPresentThePermissionIsNotCreatedAndTheEntityIsADatastore {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostPermissionProperties = New-VMHostPermissionProperties

    $vmHostPermissionProperties.EntityName = $script:constants.DatastoreName
    $vmHostPermissionProperties.EntityLocation = [string]::Empty
    $vmHostPermissionProperties.EntityType = 'Datastore'
    $vmHostPermissionProperties.PrincipalName = $script:constants.PrincipalName
    $vmHostPermissionProperties.RoleName = $script:constants.RoleName
    $vmHostPermissionProperties.Ensure = 'Present'
    $vmHostPermissionProperties.Propagate = $script:constants.PropagatePermission

    $entityMock = $script:datastoreEntity
    $principalMock = $script:principal
    $roleMock = $script:vmHostRole

    Mock -CommandName Get-Datastore -MockWith { return $entityMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Name -eq $script:constants.DatastoreName } -Verifiable
    Mock -CommandName Get-VIAccount -MockWith { return $principalMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Id -eq $script:constants.PrincipalName } -Verifiable
    Mock -CommandName Get-VIRole -MockWith { return $roleMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Name -eq $script:constants.RoleName } -Verifiable
    Mock -CommandName Get-VIPermission -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Entity -eq $script:datastoreEntity -and $Principal -eq $script:principal } -Verifiable
    Mock -CommandName New-VIPermission -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostPermissionProperties
}

function New-MocksWhenEnsureIsPresentThePermissionIsNotCreatedAndTheEntityIsAResourcePool {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostPermissionProperties = New-VMHostPermissionProperties

    $vmHostPermissionProperties.EntityName = $script:constants.ResourcePoolName
    $vmHostPermissionProperties.EntityLocation = [string]::Empty
    $vmHostPermissionProperties.EntityType = 'ResourcePool'
    $vmHostPermissionProperties.PrincipalName = $script:constants.PrincipalName
    $vmHostPermissionProperties.RoleName = $script:constants.RoleName
    $vmHostPermissionProperties.Ensure = 'Present'
    $vmHostPermissionProperties.Propagate = $script:constants.PropagatePermission

    $vmHostMock = $script:vmHost
    $rootResourcePoolMock = $script:rootResourcePool
    $entityMock = $script:resourcePoolEntity
    $principalMock = $script:principal
    $roleMock = $script:vmHostRole

    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer } -Verifiable
    Mock -CommandName Get-ResourcePool -MockWith { return $rootResourcePoolMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer } -Verifiable
    Mock -CommandName Get-ResourcePool -MockWith { return $entityMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Name -eq $script:constants.ResourcePoolName -and $Location -eq $script:rootResourcePool } -Verifiable
    Mock -CommandName Get-VIAccount -MockWith { return $principalMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Id -eq $script:constants.PrincipalName } -Verifiable
    Mock -CommandName Get-VIRole -MockWith { return $roleMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Name -eq $script:constants.RoleName } -Verifiable
    Mock -CommandName Get-VIPermission -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Entity -eq $script:resourcePoolEntity -and $Principal -eq $script:principal } -Verifiable
    Mock -CommandName New-VIPermission -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostPermissionProperties
}

function New-MocksWhenEnsureIsPresentThePermissionIsNotCreatedTheEntityIsAVMAndEmptyEntityLocationIsPassed {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostPermissionProperties = New-VMHostPermissionProperties

    $vmHostPermissionProperties.EntityName = $script:constants.VMName
    $vmHostPermissionProperties.EntityLocation = [string]::Empty
    $vmHostPermissionProperties.EntityType = 'VM'
    $vmHostPermissionProperties.PrincipalName = $script:constants.PrincipalName
    $vmHostPermissionProperties.RoleName = $script:constants.RoleName
    $vmHostPermissionProperties.Ensure = 'Present'
    $vmHostPermissionProperties.Propagate = $script:constants.PropagatePermission

    $vmHostMock = $script:vmHost
    $rootResourcePoolMock = $script:rootResourcePool
    $entityMock = $script:vmEntity
    $principalMock = $script:principal
    $roleMock = $script:vmHostRole

    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer } -Verifiable
    Mock -CommandName Get-ResourcePool -MockWith { return $rootResourcePoolMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer } -Verifiable
    Mock -CommandName Get-VM -MockWith { return $entityMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Name -eq $script:constants.VMName -and $Location -eq $script:rootResourcePool } -Verifiable
    Mock -CommandName Get-VIAccount -MockWith { return $principalMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Id -eq $script:constants.PrincipalName } -Verifiable
    Mock -CommandName Get-VIRole -MockWith { return $roleMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Name -eq $script:constants.RoleName } -Verifiable
    Mock -CommandName Get-VIPermission -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Entity -eq $script:vmEntity -and $Principal -eq $script:principal } -Verifiable
    Mock -CommandName New-VIPermission -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostPermissionProperties
}

function New-MocksWhenEnsureIsPresentThePermissionIsNotCreatedTheEntityIsAVMAndEntityLocationIsOneResourcePool {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostPermissionProperties = New-VMHostPermissionProperties

    $vmHostPermissionProperties.EntityName = $script:constants.VMName
    $vmHostPermissionProperties.EntityLocation = $script:constants.ResourcePoolName
    $vmHostPermissionProperties.EntityType = 'VM'
    $vmHostPermissionProperties.PrincipalName = $script:constants.PrincipalName
    $vmHostPermissionProperties.RoleName = $script:constants.RoleName
    $vmHostPermissionProperties.Ensure = 'Present'
    $vmHostPermissionProperties.Propagate = $script:constants.PropagatePermission

    $vmHostMock = $script:vmHost
    $rootResourcePoolMock = $script:rootResourcePool
    $resourcePoolMock = $script:resourcePoolEntity
    $entityMock = $script:vmEntity
    $principalMock = $script:principal
    $roleMock = $script:vmHostRole

    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer } -Verifiable
    Mock -CommandName Get-ResourcePool -MockWith { return $rootResourcePoolMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer } -Verifiable
    Mock -CommandName Get-ResourcePool -MockWith { return $resourcePoolMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Name -eq $script:constants.ResourcePoolName -and $Location -eq $script:rootResourcePool } -Verifiable
    Mock -CommandName Get-VM -MockWith { return $entityMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Name -eq $script:constants.VMName -and $Location -eq $script:resourcePoolEntity } -Verifiable
    Mock -CommandName Get-VIAccount -MockWith { return $principalMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Id -eq $script:constants.PrincipalName } -Verifiable
    Mock -CommandName Get-VIRole -MockWith { return $roleMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Name -eq $script:constants.RoleName } -Verifiable
    Mock -CommandName Get-VIPermission -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Entity -eq $script:vmEntity -and $Principal -eq $script:principal } -Verifiable
    Mock -CommandName New-VIPermission -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostPermissionProperties
}

function New-MocksWhenEnsureIsPresentThePermissionIsNotCreatedTheEntityIsAVMAndEntityLocationIsOneResourcePoolAndOneVApp {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostPermissionProperties = New-VMHostPermissionProperties

    $vmHostPermissionProperties.EntityName = $script:constants.VMName
    $vmHostPermissionProperties.EntityLocation = "$($script:constants.ResourcePoolName)/$($script:constants.VAppName)"
    $vmHostPermissionProperties.EntityType = 'VM'
    $vmHostPermissionProperties.PrincipalName = $script:constants.PrincipalName
    $vmHostPermissionProperties.RoleName = $script:constants.RoleName
    $vmHostPermissionProperties.Ensure = 'Present'
    $vmHostPermissionProperties.Propagate = $script:constants.PropagatePermission

    $vmHostMock = $script:vmHost
    $rootResourcePoolMock = $script:rootResourcePool
    $vAppMock = $script:vAppEntity
    $vAppViewBaseObjectMock = $script:vAppViewBaseObject
    $resourcePoolViewBaseObjectMock = $script:resourcePoolViewBaseObject
    $entityMock = $script:vmEntity
    $principalMock = $script:principal
    $roleMock = $script:vmHostRole

    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer } -Verifiable
    Mock -CommandName Get-ResourcePool -MockWith { return $rootResourcePoolMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $vAppMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Name -eq $script:constants.VAppName -and $Location -eq $script:rootResourcePool } -Verifiable
    Mock -CommandName Get-View -MockWith { return $vAppViewBaseObjectMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Id -eq $script:vAppEntity.Id } -Verifiable
    Mock -CommandName Get-View -MockWith { return $resourcePoolViewBaseObjectMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Id -eq $script:vAppViewBaseObject.Parent } -Verifiable
    Mock -CommandName Get-VM -MockWith { return $entityMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Name -eq $script:constants.VMName -and $Location -eq $script:vAppEntity } -Verifiable
    Mock -CommandName Get-VIAccount -MockWith { return $principalMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Id -eq $script:constants.PrincipalName } -Verifiable
    Mock -CommandName Get-VIRole -MockWith { return $roleMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Name -eq $script:constants.RoleName } -Verifiable
    Mock -CommandName Get-VIPermission -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Entity -eq $script:vmEntity -and $Principal -eq $script:principal } -Verifiable
    Mock -CommandName New-VIPermission -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostPermissionProperties
}

function New-MocksInSetWhenEnsureIsPresentAndThePermissionIsAlreadyCreated {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostPermissionProperties = New-VMHostPermissionProperties

    $vmHostPermissionProperties.EntityName = $script:constants.DatacenterName
    $vmHostPermissionProperties.EntityLocation = [string]::Empty
    $vmHostPermissionProperties.EntityType = 'Datacenter'
    $vmHostPermissionProperties.PrincipalName = $script:constants.PrincipalName
    $vmHostPermissionProperties.RoleName = $script:constants.RoleName + $script:constants.RoleName
    $vmHostPermissionProperties.Ensure = 'Present'
    $vmHostPermissionProperties.Propagate = $script:constants.PropagatePermission

    $entityMock = $script:datacenterEntity
    $principalMock = $script:principal
    $roleMock = $script:vmHostRole
    $permissionMock = $script:vmHostPermission

    Mock -CommandName Get-Datacenter -MockWith { return $entityMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer } -Verifiable
    Mock -CommandName Get-VIAccount -MockWith { return $principalMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Id -eq $script:constants.PrincipalName } -Verifiable
    Mock -CommandName Get-VIRole -MockWith { return $roleMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Name -eq ($script:constants.RoleName + $script:constants.RoleName) } -Verifiable
    Mock -CommandName Get-VIPermission -MockWith { return $permissionMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Entity -eq $script:datacenterEntity -and $Principal -eq $script:principal } -Verifiable
    Mock -CommandName Set-VIPermission -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostPermissionProperties
}

function New-MocksInSetWhenEnsureIsAbsentAndThePermissionIsAlreadyRemoved {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostPermissionProperties = New-VMHostPermissionProperties

    $vmHostPermissionProperties.EntityName = $script:constants.DatacenterName
    $vmHostPermissionProperties.EntityLocation = [string]::Empty
    $vmHostPermissionProperties.EntityType = 'Datacenter'
    $vmHostPermissionProperties.PrincipalName = $script:constants.PrincipalName
    $vmHostPermissionProperties.RoleName = $script:constants.RoleName
    $vmHostPermissionProperties.Ensure = 'Absent'

    $entityMock = $script:datacenterEntity
    $principalMock = $script:principal

    Mock -CommandName Get-Datacenter -MockWith { return $entityMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer } -Verifiable
    Mock -CommandName Get-VIAccount -MockWith { return $principalMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Id -eq $script:constants.PrincipalName } -Verifiable
    Mock -CommandName Get-VIPermission -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Entity -eq $script:datacenterEntity -and $Principal -eq $script:principal } -Verifiable
    Mock -CommandName Remove-VIPermission -MockWith { return $null }.GetNewClosure()

    $vmHostPermissionProperties
}

function New-MocksInSetWhenEnsureIsAbsentAndThePermissionIsNotRemoved {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostPermissionProperties = New-VMHostPermissionProperties

    $vmHostPermissionProperties.EntityName = $script:constants.DatacenterName
    $vmHostPermissionProperties.EntityLocation = [string]::Empty
    $vmHostPermissionProperties.EntityType = 'Datacenter'
    $vmHostPermissionProperties.PrincipalName = $script:constants.PrincipalName
    $vmHostPermissionProperties.RoleName = $script:constants.RoleName
    $vmHostPermissionProperties.Ensure = 'Absent'

    $entityMock = $script:datacenterEntity
    $principalMock = $script:principal
    $permissionMock = $script:vmHostPermission

    Mock -CommandName Get-Datacenter -MockWith { return $entityMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer } -Verifiable
    Mock -CommandName Get-VIAccount -MockWith { return $principalMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Id -eq $script:constants.PrincipalName } -Verifiable
    Mock -CommandName Get-VIPermission -MockWith { return $permissionMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Entity -eq $script:datacenterEntity -and $Principal -eq $script:principal } -Verifiable
    Mock -CommandName Remove-VIPermission -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostPermissionProperties
}

function New-MocksWhenThePrincipalIsPartOfADomain {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostPermissionProperties = New-VMHostPermissionProperties

    $vmHostPermissionProperties.EntityName = $script:constants.DatacenterName
    $vmHostPermissionProperties.EntityLocation = [string]::Empty
    $vmHostPermissionProperties.EntityType = 'Datacenter'
    $vmHostPermissionProperties.PrincipalName = $script:constants.DomainName + '\' + $script:constants.PrincipalName
    $vmHostPermissionProperties.RoleName = $script:constants.RoleName
    $vmHostPermissionProperties.Ensure = 'Present'

    $entityMock = $script:datacenterEntity
    $principalMock = $script:principal

    Mock -CommandName Get-Datacenter -MockWith { return $entityMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer } -Verifiable
    Mock -CommandName Get-VIAccount -MockWith { return $principalMock }.GetNewClosure() -Verifiable

    $vmHostPermissionProperties
}

function New-MocksWhenEnsureIsPresentAndThePermissionIsNotCreated {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostPermissionProperties = New-VMHostPermissionProperties

    $vmHostPermissionProperties.EntityName = $script:constants.DatacenterName
    $vmHostPermissionProperties.EntityLocation = [string]::Empty
    $vmHostPermissionProperties.EntityType = 'Datacenter'
    $vmHostPermissionProperties.PrincipalName = $script:constants.PrincipalName
    $vmHostPermissionProperties.RoleName = $script:constants.RoleName
    $vmHostPermissionProperties.Ensure = 'Present'

    $entityMock = $script:datacenterEntity
    $principalMock = $script:principal

    Mock -CommandName Get-Datacenter -MockWith { return $entityMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer } -Verifiable
    Mock -CommandName Get-VIAccount -MockWith { return $principalMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Id -eq $script:constants.PrincipalName } -Verifiable
    Mock -CommandName Get-VIPermission -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Entity -eq $script:datacenterEntity -and $Principal -eq $script:principal } -Verifiable

    $vmHostPermissionProperties
}

function New-MocksWhenEnsureIsPresentAndThePermissionIsAlreadyCreated {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostPermissionProperties = New-VMHostPermissionProperties

    $vmHostPermissionProperties.EntityName = $script:constants.DatacenterName
    $vmHostPermissionProperties.EntityLocation = [string]::Empty
    $vmHostPermissionProperties.EntityType = 'Datacenter'
    $vmHostPermissionProperties.PrincipalName = $script:constants.PrincipalName
    $vmHostPermissionProperties.RoleName = $script:constants.RoleName
    $vmHostPermissionProperties.Ensure = 'Present'

    $entityMock = $script:datacenterEntity
    $principalMock = $script:principal
    $permissionMock = $script:vmHostPermission

    Mock -CommandName Get-Datacenter -MockWith { return $entityMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer } -Verifiable
    Mock -CommandName Get-VIAccount -MockWith { return $principalMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Id -eq $script:constants.PrincipalName } -Verifiable
    Mock -CommandName Get-VIPermission -MockWith { return $permissionMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Entity -eq $script:datacenterEntity -and $Principal -eq $script:principal } -Verifiable

    $vmHostPermissionProperties
}

function New-MocksWhenEnsureIsPresentThePermissionIsAlreadyCreatedAndTheDesiredRoleAndPropagateBehaviourAreDifferentFromTheCurrentRoleAndPropagateBehaviour {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostPermissionProperties = New-VMHostPermissionProperties

    $vmHostPermissionProperties.EntityName = $script:constants.DatacenterName
    $vmHostPermissionProperties.EntityLocation = [string]::Empty
    $vmHostPermissionProperties.EntityType = 'Datacenter'
    $vmHostPermissionProperties.PrincipalName = $script:constants.PrincipalName
    $vmHostPermissionProperties.RoleName = $script:constants.RoleName + $script:constants.RoleName
    $vmHostPermissionProperties.Ensure = 'Present'
    $vmHostPermissionProperties.Propagate = !$script:constants.PropagatePermission

    $entityMock = $script:datacenterEntity
    $principalMock = $script:principal
    $permissionMock = $script:vmHostPermission

    Mock -CommandName Get-Datacenter -MockWith { return $entityMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer } -Verifiable
    Mock -CommandName Get-VIAccount -MockWith { return $principalMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Id -eq $script:constants.PrincipalName } -Verifiable
    Mock -CommandName Get-VIPermission -MockWith { return $permissionMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Entity -eq $script:datacenterEntity -and $Principal -eq $script:principal } -Verifiable

    $vmHostPermissionProperties
}

function New-MocksWhenEnsureIsPresentThePermissionIsAlreadyCreatedAndTheDesiredRoleAndPropagateBehaviourAreTheSameAsTheCurrentRoleAndPropagateBehaviour {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostPermissionProperties = New-VMHostPermissionProperties

    $vmHostPermissionProperties.EntityName = $script:constants.DatacenterName
    $vmHostPermissionProperties.EntityLocation = [string]::Empty
    $vmHostPermissionProperties.EntityType = 'Datacenter'
    $vmHostPermissionProperties.PrincipalName = $script:constants.PrincipalName
    $vmHostPermissionProperties.RoleName = $script:constants.RoleName
    $vmHostPermissionProperties.Ensure = 'Present'
    $vmHostPermissionProperties.Propagate = $script:constants.PropagatePermission

    $entityMock = $script:datacenterEntity
    $principalMock = $script:principal
    $permissionMock = $script:vmHostPermission

    Mock -CommandName Get-Datacenter -MockWith { return $entityMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer } -Verifiable
    Mock -CommandName Get-VIAccount -MockWith { return $principalMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Id -eq $script:constants.PrincipalName } -Verifiable
    Mock -CommandName Get-VIPermission -MockWith { return $permissionMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Entity -eq $script:datacenterEntity -and $Principal -eq $script:principal } -Verifiable

    $vmHostPermissionProperties
}

function New-MocksWhenEnsureIsAbsentAndThePermissionIsAlreadyRemoved {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostPermissionProperties = New-VMHostPermissionProperties

    $vmHostPermissionProperties.EntityName = $script:constants.DatacenterName
    $vmHostPermissionProperties.EntityLocation = [string]::Empty
    $vmHostPermissionProperties.EntityType = 'Datacenter'
    $vmHostPermissionProperties.PrincipalName = $script:constants.PrincipalName
    $vmHostPermissionProperties.RoleName = $script:constants.RoleName
    $vmHostPermissionProperties.Ensure = 'Absent'

    $entityMock = $script:datacenterEntity
    $principalMock = $script:principal

    Mock -CommandName Get-Datacenter -MockWith { return $entityMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer } -Verifiable
    Mock -CommandName Get-VIAccount -MockWith { return $principalMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Id -eq $script:constants.PrincipalName } -Verifiable
    Mock -CommandName Get-VIPermission -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Entity -eq $script:datacenterEntity -and $Principal -eq $script:principal } -Verifiable

    $vmHostPermissionProperties
}

function New-MocksWhenEnsureIsAbsentAndThePermissionIsNotRemoved {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostPermissionProperties = New-VMHostPermissionProperties

    $vmHostPermissionProperties.EntityName = $script:constants.DatacenterName
    $vmHostPermissionProperties.EntityLocation = [string]::Empty
    $vmHostPermissionProperties.EntityType = 'Datacenter'
    $vmHostPermissionProperties.PrincipalName = $script:constants.PrincipalName
    $vmHostPermissionProperties.RoleName = $script:constants.RoleName
    $vmHostPermissionProperties.Ensure = 'Absent'

    $entityMock = $script:datacenterEntity
    $principalMock = $script:principal
    $permissionMock = $script:vmHostPermission

    Mock -CommandName Get-Datacenter -MockWith { return $entityMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer } -Verifiable
    Mock -CommandName Get-VIAccount -MockWith { return $principalMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Id -eq $script:constants.PrincipalName } -Verifiable
    Mock -CommandName Get-VIPermission -MockWith { return $permissionMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:esxiServer -and $Entity -eq $script:datacenterEntity -and $Principal -eq $script:principal } -Verifiable

    $vmHostPermissionProperties
}
