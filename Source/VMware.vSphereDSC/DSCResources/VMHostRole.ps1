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
class VMHostRole : BaseDSC {
    <#
    .DESCRIPTION

    Specifies the name of the Role on the VMHost.
    #>
    [DscProperty(Key)]
    [string] $Name

    <#
    .DESCRIPTION

    Specifies whether the Role on the VMHost should be present or absent.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    <#
    .DESCRIPTION

    Specifies the ids of the Privileges for the Role on the VMHost. The Privilege ids should be in the following format: '<Privilege Group id>.<Privilege Item id>'.
    Exampe Privilege id: 'VirtualMachine.Inventory.Create' where 'VirtualMachine.Inventory' is the Privilege Group id and 'Create' is the id of the Privilege item.
    #>
    [DscProperty()]
    [string[]] $PrivilegeIds

    hidden [string] $CreateRoleMessage = "Creating Role {0} on VMHost {1}."
    hidden [string] $CreateRoleWithPrivilegesMessage = "Creating Role {0} with Privileges {1} on VMHost {2}."
    hidden [string] $ModifyPrivilegesOfRoleMessage = "Modifying Privileges of Role {0} on VMHost {1}."
    hidden [string] $RemoveRoleMessage = "Removing Role {0} on VMHost {1}."

    hidden [string] $CouldNotFindPrivilegeMessage = "The passed Privilege {0} was not found and it will be ignored."
    hidden [string] $CouldNotRetrieveRolePrivilegesMessage = "Could not retrieve Privilege {0} of Role {1}. For more information: {2}"
    hidden [string] $CouldNotCreateRoleMessage = "Could not create Role {0} on VMHost {1}. For more information: {2}"
    hidden [string] $CouldNotCreateRoleWithPrivilegesMessage = "Could not create Role {0} with Privileges {1} on VMHost {2}. For more information: {3}"
    hidden [string] $CouldNotModifyPrivilegesOfRoleMessage = "Could not modify Privileges of Role {0} on VMHost {1}. For more information: {2}"
    hidden [string] $CouldNotRemoveRoleMessage = "Could not remove Role {0} on VMHost {1}. For more information: {2}"

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()
            $this.EnsureConnectionIsESXi()

            $vmHostRole = $this.GetVMHostRole()

            if ($this.Ensure -eq [Ensure]::Present) {
                $desiredPrivileges = $this.GetPrivileges()

                if ($null -eq $vmHostRole) {
                    if ($desiredPrivileges.Length -gt 0) {
                        $this.NewVMHostRole($desiredPrivileges)
                    }
                    else {
                        $this.NewVMHostRole()
                    }
                }
                else {
                    $currentPrivileges = $this.GetRolePrivileges($vmHostRole, $desiredPrivileges)
                    $this.ModifyPrivilegesOfVMHostRole($vmHostRole, $currentPrivileges, $desiredPrivileges)
                }
            }
            else {
                if ($null -ne $vmHostRole) {
                    $this.RemoveVMHostRole($vmHostRole)
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

            $vmHostRole = $this.GetVMHostRole()
            $result = $null

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $vmHostRole) {
                    $result = $false
                }
                else {
                    $desiredPrivileges = $this.GetPrivileges()
                    $desiredPrivilegeIds = if ($desiredPrivileges.Length -eq 0) { $null } else { $desiredPrivileges.Id }

                    $result = !$this.ShouldUpdateArraySetting($vmHostRole.PrivilegeList, $desiredPrivilegeIds)
                }
            }
            else {
                $result = ($null -eq $vmHostRole)
            }

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [VMHostRole] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [VMHostRole]::new()

            $this.ConnectVIServer()
            $this.EnsureConnectionIsESXi()

            $vmHostRole = $this.GetVMHostRole()
            $this.PopulateResult($result, $vmHostRole)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Role with the specified name on the VMHost if it exists, otherwise returns $null.
    #>
    [PSObject] GetVMHostRole() {
        return Get-VIRole -Server $this.Connection -Name $this.Name -ErrorAction SilentlyContinue -Verbose:$false
    }

    <#
    .DESCRIPTION

    Retrieves the Privileges with the specified ids on the VMHost if they exist.
    For every Privilege that does not exist, a warning message is shown to the user without throwing an exception.
    #>
    [array] GetPrivileges() {
        $privileges = @()

        foreach ($privilegeId in $this.PrivilegeIds) {
            $privilege = Get-VIPrivilege -Server $this.Connection -Id $privilegeId -ErrorAction SilentlyContinue -Verbose:$false
            if ($null -eq $privilege) {
                Write-WarningLog -Message $this.CouldNotFindPrivilegeMessage -Arguments @($privilegeId)
            }
            else {
                $privileges += $privilege
            }
        }

        return $privileges
    }

    <#
    .DESCRIPTION

    Retrieves the Privileges of the Role on the VMHost.
    #>
    [array] GetRolePrivileges($vmHostRole, $desiredPrivileges) {
        $rolePrivileges = @()

        foreach ($privilegeId in $vmHostRole.PrivilegeList) {
            <#
            Here we can check if the desired Privilege list already contains the Role Privilege and this way
            we can skip the server call because the Privilege object is already available in the array of Privileges.
            #>
            if ($desiredPrivileges.Length -gt 0 -and $desiredPrivileges.Id.Contains($privilegeId)) {
                $rolePrivileges += ($desiredPrivileges | Where-Object -FilterScript { $_.Id -eq $privilegeId })
            }
            else {
                try {
                    $rolePrivilige = Get-VIPrivilege -Server $this.Connection -Id $privilegeId -ErrorAction Stop -Verbose:$false
                    $rolePrivileges += $rolePrivilige
                }
                catch {
                    throw ($this.CouldNotRetrieveRolePrivilegesMessage -f $privilegeId, $vmHostRole.Name, $_.Exception.Message)
                }
            }
        }

        return $rolePrivileges
    }

    <#
    .DESCRIPTION

    Creates a new Role with the specified name on the VMHost.
    #>
    [void] NewVMHostRole() {
        try {
            Write-VerboseLog -Message $this.CreateRoleMessage -Arguments @($this.Name, $this.Connection.Name)
            New-VIRole -Server $this.Connection -Name $this.Name -Confirm:$false -ErrorAction Stop -Verbose:$false
        }
        catch {
            throw ($this.CouldNotCreateRoleMessage -f $this.Name, $this.Connection.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Creates a new Role with the specified name on the VMHost and applies the provided Privileges.
    #>
    [void] NewVMHostRole($desiredPrivileges) {
        $desiredPrivilegeIds = [string]::Join(', ', $desiredPrivileges.Id)

        try {
            Write-VerboseLog -Message $this.CreateRoleWithPrivilegesMessage -Arguments @($this.Name, $desiredPrivilegeIds, $this.Connection.Name)
            New-VIRole -Server $this.Connection -Name $this.Name -Privilege $desiredPrivileges -Confirm:$false -ErrorAction Stop -Verbose:$false
        }
        catch {
            throw ($this.CouldNotCreateRoleWithPrivilegesMessage -f $this.Name, $desiredPrivilegeIds, $this.Connection.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Modifies the Privileges of the Role on the VMHost. The 'Set-VIRole' cmdlet has two parameters for Privileges - 'AddPrivilege' and 'RemovePrivilege'.
    So based on the provided desired Privileges we need to add those of them that are not yet Privileges of the Role and also remove existing ones
    from the Privilege list of the Role because they are not specified as desired.
    #>
    [void] ModifyPrivilegesOfVMHostRole($vmHostRole, $currentPrivileges, $desiredPrivileges) {
        $setVIRoleParams = @{
            Server = $this.Connection
            Role = $vmHostRole
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }
        $privilegesToAdd = @()
        $privilegesToRemove = @()

        <#
        If the Role does not have Privileges, it means that all desired Privileges need to be marked as Privileges to add.
        Otherwise Privileges to add are those that are not present in the Privilege list of the Role and Privileges
        to remove are those that are not present in the desired Privilege list.
        #>
        if ($currentPrivileges.Length -eq 0) {
            $privilegesToAdd = $desiredPrivileges
        }
        else {
            $privilegesToAdd = $desiredPrivileges | Where-Object -FilterScript { $currentPrivileges -NotContains $_ }
            $privilegesToRemove = $currentPrivileges | Where-Object -FilterScript { $desiredPrivileges -NotContains $_ }
        }

        <#
        If the Privileges to add array is empty, it means that only removal of Privileges is needed. Otherwise, we first add
        all the specified Privileges that are not present in the list of Privileges of the Role and after that check if there are
        Privileges to remove from that list. The 'AddPrivilege' entry needs to be removed from the params hashtable because 'AddPrivilege'
        and 'RemovePrivilege' parameters of 'Set-VIRole' cmdlet are in different parameter sets, so two cmdlet invocations need to be made.
        #>
        try {
            Write-VerboseLog -Message $this.ModifyPrivilegesOfRoleMessage -Arguments @($vmHostRole.Name, $this.Connection.Name)

            if ($privilegesToAdd.Length -eq 0) {
                $setVIRoleParams.RemovePrivilege = $privilegesToRemove
                Set-VIRole @setVIRoleParams
            }
            else {
                $setVIRoleParams.AddPrivilege = $privilegesToAdd
                Set-VIRole @setVIRoleParams

                if ($privilegesToRemove.Length -gt 0) {
                    $setVIRoleParams.Remove('AddPrivilege')
                    $setVIRoleParams.RemovePrivilege = $privilegesToRemove

                    Set-VIRole @setVIRoleParams
                }
            }
        }
        catch {
            throw ($this.CouldNotModifyPrivilegesOfRoleMessage -f $vmHostRole.Name, $this.Connection.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Removes the Role on the VMHost. All Permissions associated with the Role will be removed as well.
    #>
    [void] RemoveVMHostRole($vmHostRole) {
        try {
            Write-VerboseLog -Message $this.RemoveRoleMessage -Arguments @($vmHostRole.Name, $this.Connection.Name)
            $vmHostRole | Remove-VIRole -Server $this.Connection -Force -Confirm:$false -ErrorAction Stop -Verbose:$false
        }
        catch {
            throw ($this.CouldNotRemoveRoleMessage -f $vmHostRole.Name, $this.Connection.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $vmHostRole) {
        $result.Server = $this.Connection.Name

        if ($null -ne $vmHostRole) {
            $result.Name = $vmHostRole.Name
            $result.Ensure = [Ensure]::Present
            $result.PrivilegeIds = $vmHostRole.PrivilegeList
        }
        else {
            $result.Name = $this.Name
            $result.Ensure = [Ensure]::Absent
            $result.PrivilegeIds = $this.PrivilegeIds
        }
    }
}
