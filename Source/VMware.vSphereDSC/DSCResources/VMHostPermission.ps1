<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

[DscResource()]
class VMHostPermission : BaseDSC {
    <#
    .DESCRIPTION

    Specifies the name of the Entity to which the Permission applies.
    #>
    [DscProperty(Key)]
    [string] $EntityName

    <#
    .DESCRIPTION

    Specifies the location of the Entity with name specified in 'EntityName' key property. Location consists of 0 or more Inventory Items.
    When the Entity is a Datacenter, a VMHost or a Datastore, the property is ignored. If the Entity is a Virtual Machine, a Resource Pool or a vApp and empty location
    is passed, the Entity should be located in the Root Resource Pool of the VMHost. Inventory Item names in the location are separated by '/'.
    Example location for a Datastore Inventory Item: ''. Example location for a Virtual Machine Inventory Item: 'MyResourcePoolOne/MyResourcePoolTwo/MyvApp'.
    #>
    [DscProperty(Key)]
    [string] $EntityLocation

    <#
    .DESCRIPTION

    Specifies the type of the Entity of the Permission. Valid Entity types are: 'Datacenter', 'VMHost', 'Datastore', 'VM', 'ResourcePool' and 'VApp'.
    #>
    [DscProperty(Key)]
    [EntityType] $EntityType

    <#
    .DESCRIPTION

    Specifies the name of the User to which the Permission applies. If the User is a Domain User, the Principal name should be in one of the
    following formats: '<Domain Name>/<User name>' or '<User name>@<Domain Name>'. Example Principal name for Domain User: 'MyDomain/MyDomainUser' or 'MyDomainUser@MyDomain'.
    #>
    [DscProperty(Key)]
    [string] $PrincipalName

    <#
    .DESCRIPTION

    Specifies the name of the Role to which the Permission applies.
    #>
    [DscProperty(Key)]
    [string] $RoleName

    <#
    .DESCRIPTION

    Specifies whether the Permission should be present or absent.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    <#
    .DESCRIPTION

    Specifies whether to propagate the Permission to the child Inventory Items.
    #>
    [DscProperty()]
    [nullable[bool]] $Propagate

    hidden [string] $CreatePermissionMessage = "Creating Permission for Entity {0}, Principal {1} and Role {2} on VMHost {3}."
    hidden [string] $ModifyPermissionMessage = "Modifying Permission for Entity {0} and Principal {1} on VMHost {2}."
    hidden [string] $RemovePermissionMessage = "Removing Permission for Entity {0}, Principal {1} and Role {2} on VMHost {3}."

    hidden [string] $CouldNotRetrieveRootResourcePoolMessage = "Could not retrieve Root Resource Pool from VMHost {0}. For more information: {1}"
    hidden [string] $InvalidEntityLocationMessage = "Location {0} for Entity {1} on VMHost {2} is not valid."
    hidden [string] $CouldNotIdentifyVMMessage = "Could not uniquely identify VM with name {0} on VMHost {1}. {2} VMs with this name exist on the VMHost."
    hidden [string] $CouldNotFindEntityMessage = "Entity {0} of type {1} was not found on VMHost {2}."
    hidden [string] $CouldNotRetrievePrincipalMessage = "Could not retrieve Principal {0} from VMHost {1}. For more information: {2}"
    hidden [string] $CouldNotRetrieveRoleMessage = "Could not retrieve Role from VMHost {1}. For more information: {2}"
    hidden [string] $CouldNotCreatePermissionMessage = "Could not create Permission for Entity {0}, Principal {1} and Role {2} on VMHost {3}. For more information: {4}"
    hidden [string] $CouldNotModifyPermissionMessage = "Could not modify Permission for Entity {0} and Principal {1} on VMHost {2}. For more information: {3}"
    hidden [string] $CouldNotRemovePermissionMessage = "Could not remove Permission for Entity {0}, Principal {1} and Role {2} on VMHost {3}. For more information: {4}"

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()
            $this.EnsureConnectionIsESXi()

            $foundEntityLocation = $this.GetEntityLocation()
            $entity = $this.GetEntity($foundEntityLocation)
            $vmHostPrincipal = $this.GetVMHostPrincipal()

            $vmHostPermission = $this.GetVMHostPermission($entity, $vmHostPrincipal)

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $vmHostPermission) {
                    $this.NewVMHostPermission($entity, $vmHostPrincipal)
                }
                else {
                    $this.ModifyVMHostPermission($vmHostPermission)
                }
            }
            else {
                if ($null -ne $vmHostPermission) {
                    $this.RemoveVMHostPermission($vmHostPermission)
                }
            }
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.SetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [bool] Test() {
        try {
            Write-VerboseLog -Message $this.TestMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()
            $this.EnsureConnectionIsESXi()

            $foundEntityLocation = $this.GetEntityLocation()
            $entity = $this.GetEntity($foundEntityLocation)
            $vmHostPrincipal = $this.GetVMHostPrincipal()

            $vmHostPermission = $this.GetVMHostPermission($entity, $vmHostPrincipal)
            $result = $null

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $vmHostPermission) {
                    $result = $false
                }
                else {
                    $result = !$this.ShouldModifyVMHostPermission($vmHostPermission)
                }
            }
            else {
                $result = ($null -eq $vmHostPermission)
            }

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [VMHostPermission] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [VMHostPermission]::new()

            $this.ConnectVIServer()
            $this.EnsureConnectionIsESXi()

            $foundEntityLocation = $this.GetEntityLocation()
            $entity = $this.GetEntity($foundEntityLocation)
            $vmHostPrincipal = $this.GetVMHostPrincipal()

            $vmHostPermission = $this.GetVMHostPermission($entity, $vmHostPrincipal)
            $this.PopulateResult($result, $vmHostPermission)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Root Resource Pool from the VMHost.
    #>
    [PSObject] GetRootResourcePool() {
        try {
            $vmHost = Get-VMHost -Server $this.Connection -ErrorAction Stop -Verbose:$false
            $rootResourcePool = Get-ResourcePool -Server $this.Connection -ErrorAction Stop -Verbose:$false |
                                Where-Object -FilterScript { $_.ParentId -eq $vmHost.Id }

            return $rootResourcePool
        }
        catch {
            throw ($this.CouldNotRetrieveRootResourcePoolMessage -f $this.Connection.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the location of the Entity with the specified name on the VMHost if it exists. For VMs, Resource Pools and vApps
    if Ensure is 'Present' and the location is not found, an exception is thrown. If Ensure is 'Absent' and the location is not found, $null is returned.
    #>
    [PSObject] GetEntityLocation() {
        $foundEntityLocation = $null

        if (
            $this.EntityType -eq [EntityType]::Datacenter -or
            $this.EntityType -eq [EntityType]::VMHost -or
            $this.EntityType -eq [EntityType]::Datastore
        ) {
            # The location is not needed to identify the Entity when it is a Datacenter, VMHost or a Datastore.
            $foundEntityLocation = $null
        }
        else {
            $rootResourcePool = $this.GetRootResourcePool()

            if ([string]::IsNullOrEmpty($this.EntityLocation)) {
                # Special case where the Entity location does not contain any Inventory Items. So the Root Resource Pool is the location for the Entity.
                $foundEntityLocation = $rootResourcePool
            }
            elseif ($this.EntityLocation -NotMatch '/') {
                # Special case where the Entity location is just one Resource Pool or vApp. On VMHosts the vApps are also retrieved with the Get-ResourcePool cmdlet.
                $foundEntityLocation = Get-ResourcePool -Server $this.Connection -Name $this.EntityLocation -Location $rootResourcePool -ErrorAction SilentlyContinue -Verbose:$false |
                                       Where-Object -FilterScript { $_.ParentId -eq $rootResourcePool.Id }
            }
            else {
                $entityLocationItems = $this.EntityLocation -Split '/'

                # Reverses the Entity location items so that we can start from the bottom and go to the top of the Inventory.
                [array]::Reverse($entityLocationItems)

                $entityLocationName = $entityLocationItems[0]
                $foundEntityLocations = Get-Inventory -Server $this.Connection -Name $entityLocationName -Location $rootResourcePool -ErrorAction SilentlyContinue -Verbose:$false

                # Removes the name of the Entity location from the Entity location items array as we already retrieved it.
                $entityLocationItems = $entityLocationItems[1..($entityLocationItems.Length - 1)]

                <#
                For every found Entity Location with the specified name we start to go up through the parents to check if the Entity Location is valid.
                If one of the Parents does not meet the criteria of the Entity location, we continue with the next found Entity location.
                If we find a valid Entity location we stop iterating through the Entity locations and mark it as the found Entity location.
                #>
                foreach ($entityLocation in $foundEntityLocations) {
                    $foundEntityLocationAsViewObject = Get-View -Server $this.Connection -Id $entityLocation.Id -Verbose:$false -Property Parent
                    $validEntityLocation = $true

                    foreach ($entityLocationItem in $entityLocationItems) {
                        $foundEntityLocationAsViewObject = Get-View -Server $this.Connection -Id $foundEntityLocationAsViewObject.Parent -Verbose:$false -Property Name, Parent
                        if ($foundEntityLocationAsViewObject.Name -ne $entityLocationItem) {
                            $validEntityLocation = $false
                            break
                        }
                    }

                    if ($validEntityLocation) {
                        $foundEntityLocation = $entityLocation
                        break
                    }
                }
            }

            $exceptionMessage = $this.InvalidEntityLocationMessage -f $this.EntityLocation, $this.EntityName, $this.Connection.Name
            $this.EnsureCorrectBehaviourIfTheEntityIsNotFound($foundEntityLocation, $exceptionMessage)
        }

        return $foundEntityLocation
    }

    <#
    .DESCRIPTION

    Retrieves the Entity with the specified name from the specified location on the VMHost if it exists. For VMs, Resource Pools and vApps
    if Ensure is 'Present' and the Entity is not found, an exception is thrown. If Ensure is 'Absent' and the Entity is not found, $null is returned.
    #>
    [PSObject] GetEntity($entityLocation) {
        $entity = $null

        if ($this.EntityType -eq [EntityType]::Datacenter) {
            # Each VMHost has only one Datacenter, so the name is not needed to retrieve it.
            $entity = Get-Datacenter -Server $this.Connection -ErrorAction SilentlyContinue -Verbose:$false
        }
        elseif ($this.EntityType -eq [EntityType]::VMHost) {
            # If the Entity is a VMHost, the Entity name and location are ignored because the Connection is directly to an ESXi host.
            $entity = Get-VMHost -Server $this.Connection -ErrorAction SilentlyContinue -Verbose:$false
        }
        elseif ($this.EntityType -eq [EntityType]::Datastore) {
            # If the Entity is a Datastore, the Entity location is ignored because the name uniquely identifies the Datastore.
            $entity = Get-Datastore -Server $this.Connection -Name $this.EntityName -ErrorAction SilentlyContinue -Verbose:$false
        }
        elseif ($this.EntityType -eq [EntityType]::VM) {
            <#
            If the Entity is a VM, the Entity location is either a Resource Pool or a vApp where the VM is placed. If the VMHost is managed by a vCenter,
            there is a special case where two VMs could be created with the same name on the same VMHost but on different vCenter folders. And this way the
            VM could not be uniquely identified on the VMHost.
            #>
            $entity = Get-VM -Server $this.Connection -Name $this.EntityName -Location $entityLocation -ErrorAction SilentlyContinue -Verbose:$false

            # Only throw an exception if Ensure is 'Present', otherwise ignore that multiple VMs were found.
            if ($entity.Length -gt 1 -and $this.Ensure -eq [Ensure]::Present) {
                throw ($this.CouldNotIdentifyVMMessage -f $this.EntityName, $this.Connection.Name, $entity.Length)
            }
        }
        else {
            <#
            If the Entity is a Resource Pool or vApp, the Entity location is either a Resource Pool or a vApp where the Entity is placed. For a specific Resource Pool
            or vApp, the name does not uniquely identify the Entity because there can be other Resource Pools or vApps below in the hierarchy with the same name placed in the
            Entity location. So additional filtering is needed to verify that the Entity is directly placed in the specified Entity location.
            #>
            $entity = Get-ResourcePool -Server $this.Connection -Name $this.EntityName -Location $entityLocation -ErrorAction SilentlyContinue -Verbose:$false |
                      Where-Object -FilterScript { $_.ParentId -eq $entityLocation.Id }
        }

        $exceptionMessage = $this.CouldNotFindEntityMessage -f $this.EntityName, $this.EntityType.ToString(), $this.Connection.Name
        $this.EnsureCorrectBehaviourIfTheEntityIsNotFound($entity, $exceptionMessage)

        return $entity
    }

    <#
    .DESCRIPTION

    Retrieves the Principal with the specified name from the VMHost if it exists.
    If the name contains '\' or '@', it means that the Principal is part of a Domain, so the search for the Principal should be done by filtering by Domain.
    If Ensure is 'Present' and the Principal is not found, an exception is thrown. If Ensure is 'Absent' and the Principal is not found, $null is returned.
    #>
    [PSObject] GetVMHostPrincipal() {
        $getVIAccountParams = @{
            Server = $this.Connection
            Verbose = $false
        }

        # If the Principal is a Domain User, we should extact the Domain and User names from the Principal name.
        if ($this.PrincipalName -Match '\\') {
            $principalNameParts = $this.PrincipalName -Split '\\'
            $domainName = $principalNameParts[0]
            $username = $principalNameParts[1]

            $getVIAccountParams.Domain = $domainName
            $getVIAccountParams.User = $true
            $getVIAccountParams.Id = $username
        }
        elseif ($this.PrincipalName -Match '@') {
            $principalNameParts = $this.PrincipalName -Split '@'
            $username = $principalNameParts[0]
            $domainName = $principalNameParts[1]

            $getVIAccountParams.Domain = $domainName
            $getVIAccountParams.User = $true
            $getVIAccountParams.Id = $username
        }
        else {
            $getVIAccountParams.Id = $this.PrincipalName
        }

        if ($this.Ensure -eq [Ensure]::Absent) {
            $getVIAccountParams.ErrorAction = 'SilentlyContinue'
            return Get-VIAccount @getVIAccountParams
        }
        else {
            try {
                $getVIAccountParams.ErrorAction = 'Stop'
                $vmHostPrincipal = Get-VIAccount @getVIAccountParams

                return $vmHostPrincipal
            }
            catch {
                throw ($this.CouldNotRetrievePrincipalMessage -f $this.PrincipalName, $this.Connection.Name, $_.Exception.Message)
            }
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Permission applied to the specified Entity and Principal from the VMHost if it exists.
    If one of the Entity and Principal parameters is $null, $null is returned.
    #>
    [PSObject] GetVMHostPermission($entity, $vmHostPrincipal) {
        if ($null -eq $entity -or $null -eq $vmHostPrincipal) {
            return $null
        }

        return Get-VIPermission -Server $this.Connection -Entity $entity -Principal $vmHostPrincipal -ErrorAction SilentlyContinue -Verbose:$false
    }

    <#
    .DESCRIPTION

    Retrieves the Role with the specified name from the VMHost if it exists.
    Otherwise it throws an exception.
    #>
    [PSObject] GetVMHostRole() {
        try {
            $vmHostRole = Get-VIRole -Server $this.Connection -Name $this.RoleName -ErrorAction Stop -Verbose:$false
            return $vmHostRole
        }
        catch {
            throw ($this.CouldNotRetrieveRoleMessage -f $this.RoleName, $this.Connection.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Ensures the correct behaviour if the Entity is not found based on the passed Ensure value.
    If Ensure is 'Present' and the Entity is not found, the method should throw an exception.
    #>
    [void] EnsureCorrectBehaviourIfTheEntityIsNotFound($entity, $exceptionMessage) {
        if ($null -eq $entity) {
            if ($this.Ensure -eq [Ensure]::Present) {
                throw $exceptionMessage
            }
        }
    }

    <#
    .DESCRIPTION

    Checks if the specified Permission should be modified. The Permission should be modified if the desired Role is different
    from the current one or if the Propagate behaviour should be different.
    #>
    [bool] ShouldModifyVMHostPermission($vmHostPermission) {
        $shouldModifyVMHostPermission = @()

        $shouldModifyVMHostPermission += ($this.RoleName -ne $vmHostPermission.Role)
        $shouldModifyVMHostPermission += ($null -ne $this.Propagate -and $this.Propagate -ne $vmHostPermission.Propagate)

        return ($shouldModifyVMHostPermission -Contains $true)
    }

    <#
    .DESCRIPTION

    Creates a new Permission and applies it to the specified Entity, Principal and Role.
    #>
    [void] NewVMHostPermission($entity, $vmHostPrincipal) {
        $vmHostRole = $this.GetVMHostRole()
        $newVIPermissionParams = @{
            Server = $this.Connection
            Entity = $entity
            Principal = $vmHostPrincipal
            Role = $vmHostRole
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        if ($null -ne $this.Propagate) {
            $newVIPermissionParams.Propagate = $this.Propagate
        }

        try {
            Write-VerboseLog -Message $this.CreatePermissionMessage -Arguments @($entity.Name, $vmHostPrincipal.Name, $vmHostRole.Name, $this.Connection.Name)
            New-VIPermission @newVIPermissionParams
        }
        catch {
            throw ($this.CouldNotCreatePermissionMessage -f $entity.Name, $vmHostPrincipal.Name, $vmHostRole.Name, $this.Connection.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Modifies the properties of the specified Permission. Changes the Role if the desired one is not the same as the current one.
    It also changes the propagate behaviour of the Permission if the 'Propagate' property is specified.
    #>
    [void] ModifyVMHostPermission($vmHostPermission) {
        $setVIPermissionParams = @{
            Server = $this.Connection
            Permission = $vmHostPermission
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        if ($vmHostPermission.Role -ne $this.RoleName) {
            $vmHostRole = $this.GetVMHostRole()
            $setVIPermissionParams.Role = $vmHostRole
        }

        if ($null -ne $this.Propagate) {
            $setVIPermissionParams.Propagate = $this.Propagate
        }

        try {
            Write-VerboseLog -Message $this.ModifyPermissionMessage -Arguments @($vmHostPermission.Entity.Name, $vmHostPermission.Principal, $this.Connection.Name)
            Set-VIPermission @setVIPermissionParams
        }
        catch {
            throw ($this.CouldNotModifyPermissionMessage -f $vmHostPermission.Entity.Name, $vmHostPermission.Principal, $this.Connection.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Removes the specified Permission.
    #>
    [void] RemoveVMHostPermission($vmHostPermission) {
        try {
            Write-VerboseLog -Message $this.RemovePermissionMessage -Arguments @($vmHostPermission.Entity.Name, $vmHostPermission.Principal, $vmHostPermission.Role, $this.Connection.Name)
            $vmHostPermission | Remove-VIPermission -Confirm:$false -ErrorAction Stop -Verbose:$false
        }
        catch {
            throw ($this.CouldNotRemovePermissionMessage -f $vmHostPermission.Entity.Name, $vmHostPermission.Principal, $vmHostPermission.Role, $this.Connection.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $vmHostPermission) {
        $result.Server = $this.Connection.Name
        $result.EntityLocation = $this.EntityLocation
        $result.EntityType = $this.EntityType

        if ($null -ne $vmHostPermission) {
            $result.EntityName = $vmHostPermission.Entity.Name
            $result.PrincipalName = $vmHostPermission.Principal
            $result.RoleName = $vmHostPermission.Role
            $result.Ensure = [Ensure]::Present
            $result.Propagate = $vmHostPermission.Propagate
        }
        else {
            $result.EntityName = $this.EntityName
            $result.PrincipalName = $this.PrincipalName
            $result.RoleName = $this.RoleName
            $result.Ensure = [Ensure]::Absent
            $result.Propagate = $this.Propagate
        }
    }
}
