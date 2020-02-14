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
class VMHostAccount : BaseDSC {
    <#
    .DESCRIPTION

    Specifies the ID for the host account.
    #>
    [DscProperty(Key)]
    [string] $Id

    <#
    .DESCRIPTION

    Value indicating if the Resource should be Present or Absent.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    <#
    .DESCRIPTION

    Permission on the VMHost entity is created for the specified User Id with the specified Role.
    #>
    [DscProperty(Mandatory)]
    [string] $Role

    <#
    .DESCRIPTION

    Specifies the Password for the host account.
    #>
    [DscProperty()]
    [string] $AccountPassword

    <#
    .DESCRIPTION

    Provides a description for the host account. The maximum length of the text is 255 symbols.
    #>
    [DscProperty()]
    [string] $Description

    hidden [string] $AccountPasswordParameterName = 'Password'
    hidden [string] $DescriptionParameterName = 'Description'

    [void] Set() {
        try {
            $this.ConnectVIServer()
            $this.EnsureConnectionIsESXi()
            $vmHostAccount = $this.GetVMHostAccount()

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $vmHostAccount) {
                    $this.AddVMHostAccount()
                }
                else {
                    $this.UpdateVMHostAccount($vmHostAccount)
                }
            }
            else {
                if ($null -ne $vmHostAccount) {
                    $this.RemoveVMHostAccount($vmHostAccount)
                }
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()
            $this.EnsureConnectionIsESXi()
            $vmHostAccount = $this.GetVMHostAccount()

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $vmHostAccount) {
                    return $false
                }

                return !$this.ShouldUpdateVMHostAccount($vmHostAccount) -or !$this.ShouldCreateAcountPermission($vmHostAccount)
            }
            else {
                return ($null -eq $vmHostAccount)
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostAccount] Get() {
        try {
            $result = [VMHostAccount]::new()
            $result.Server = $this.Server

            $this.ConnectVIServer()
            $this.EnsureConnectionIsESXi()
            $vmHostAccount = $this.GetVMHostAccount()

            $this.PopulateResult($vmHostAccount, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Returns the VMHost Account if it exists, otherwise returns $null.
    #>
    [PSObject] GetVMHostAccount() {
        return Get-VMHostAccount -Server $this.Connection -Id $this.Id -ErrorAction SilentlyContinue
    }

    <#
    .DESCRIPTION

    Checks if a new Permission with the passed Role needs to be created for the specified VMHost Account.
    #>
    [bool] ShouldCreateAcountPermission($vmHostAccount) {
        $existingPermission = Get-VIPermission -Server $this.Connection -Entity $this.Server -Principal $vmHostAccount -ErrorAction SilentlyContinue

        return ($null -eq $existingPermission)
    }

    <#
    .DESCRIPTION

    Checks if the VMHost Account should be updated.
    #>
    [bool] ShouldUpdateVMHostAccount($vmHostAccount) {
        <#
        If the Account Password is passed, we should check if we can connect to the ESXi host with the passed Id and Password.
        If we can connect to the host it means that the password is in the desired state so we should close the connection and
        continue checking the other passed properties. If we cannot connect to the host it means that
        the desired Password is not equal to the current Password of the Account.
        #>
        if ($null -ne $this.AccountPassword) {
            $hostConnection = Connect-VIServer -Server $this.Server -User $this.Id -Password $this.AccountPassword -ErrorAction SilentlyContinue

            if ($null -eq $hostConnection) {
                return $true
            }
            else {
                Disconnect-VIServer -Server $hostConnection -Confirm:$false
            }
        }

        return ($null -ne $this.Description -and $this.Description -ne $vmHostAccount.Description)
    }

    <#
    .DESCRIPTION

    Populates the parameters for the New-VMHostAccount and Set-VMHostAccount cmdlets.
    #>
    [void] PopulateVMHostAccountParams($vmHostAccountParams, $parameter, $desiredValue) {
        if ($null -ne $desiredValue) {
            $vmHostAccountParams.$parameter = $desiredValue
        }
    }

    <#
    .DESCRIPTION

    Returns the populated VMHost Account parameters.
    #>
    [hashtable] GetVMHostAccountParams() {
        $vmHostAccountParams = @{}

        $vmHostAccountParams.Server = $this.Connection
        $vmHostAccountParams.Confirm = $false
        $vmHostAccountParams.ErrorAction = 'Stop'

        $this.PopulateVMHostAccountParams($vmHostAccountParams, $this.AccountPasswordParameterName, $this.AccountPassword)
        $this.PopulateVMHostAccountParams($vmHostAccountParams, $this.DescriptionParameterName, $this.Description)

        return $vmHostAccountParams
    }

    <#
    .DESCRIPTION

    Creates a new Permission with the passed Role for the specified VMHost Account.
    #>
    [void] CreateAccountPermission($vmHostAccount) {
        $accountRole = Get-VIRole -Server $this.Connection -Name $this.Role -ErrorAction SilentlyContinue
        if ($null -eq $accountRole) {
            throw "The passed role $($this.Role) is not present on the server."
        }

        try {
            New-VIPermission -Server $this.Connection -Entity $this.Server -Principal $vmHostAccount -Role $accountRole -ErrorAction Stop
        }
        catch {
            throw "Cannot assign role $($this.Role) to account $($vmHostAccount.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Creates a new VMHost Account with the specified properties.
    #>
    [void] AddVMHostAccount() {
        $vmHostAccountParams = $this.GetVMHostAccountParams()
        $vmHostAccountParams.Id = $this.Id

        $vmHostAccount = $null

        try {
            $vmHostAccount = New-VMHostAccount @vmHostAccountParams
        }
        catch {
            throw "Cannot create VMHost Account $($this.Id). For more information: $($_.Exception.Message)"
        }

        $this.CreateAccountPermission($vmHostAccount)
    }

    <#
    .DESCRIPTION

    Updates the VMHost Account with the specified properties.
    #>
    [void] UpdateVMHostAccount($vmHostAccount) {
        $vmHostAccountParams = $this.GetVMHostAccountParams()

        try {
            $vmHostAccount | Set-VMHostAccount @vmHostAccountParams
        }
        catch {
            throw "Cannot update VMHost Account $($this.Id). For more information: $($_.Exception.Message)"
        }

        if ($this.ShouldCreateAcountPermission($vmHostAccount)) {
            $this.CreateAccountPermission($vmHostAccount)
        }
    }

    <#
    .DESCRIPTION

    Removes the VMHost Account.
    #>
    [void] RemoveVMHostAccount($vmHostAccount) {
        try {
            $vmHostAccount | Remove-VMHostAccount -Server $this.Connection -Confirm:$false -ErrorAction Stop
        }
        catch {
            throw "Cannot remove VMHost Account $($this.Id). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the VMHost Account from the server.
    #>
    [void] PopulateResult($vmHostAccount, $result) {
        if ($null -ne $vmHostAccount) {
            $permission = Get-VIPermission -Server $this.Connection -Entity $this.Server -Principal $vmHostAccount -ErrorAction SilentlyContinue

            $result.Id = $vmHostAccount.Id
            $result.Ensure = [Ensure]::Present
            $result.Role = $permission.Role
            $result.Description = $vmHostAccount.Description
        }
        else {
            $result.Id = $this.Id
            $result.Ensure = [Ensure]::Absent
            $result.Role = $this.Role
            $result.Description = $this.Description
        }
    }
}
