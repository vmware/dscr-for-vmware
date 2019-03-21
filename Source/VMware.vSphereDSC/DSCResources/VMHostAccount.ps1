<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

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
    [DscProperty(Mandatory)]
    [string] $Id

    <#
    .DESCRIPTION

    Value indicating if the Resource should be Present or Absent.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

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

    <#
    .DESCRIPTION

    Indicates that the account is allowed to access the ESX shell.
    #>
    [DscProperty()]
    [nullable[bool]] $GrantShellAccess

    hidden [string] $AccountPasswordParameterName = 'Password'
    hidden [string] $DescriptionParameterName = 'Description'
    hidden [string] $GrantShellAccessParameterName = 'GrantShellAccess'

    [void] Set() {
        $this.ConnectVIServer()
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

    [bool] Test() {
        $this.ConnectVIServer()
        $vmHostAccount = $this.GetVMHostAccount()

        if ($this.Ensure -eq [Ensure]::Present) {
            if ($null -eq $vmHostAccount) {
                return $false
            }

            return !$this.ShouldUpdateVMHostAccount($vmHostAccount)
        }
        else {
            return ($null -eq $vmHostAccount)
        }
    }

    [VMHostAccount] Get() {
        $result = [VMHostAccount]::new()
        $result.Server = $this.Server
        $result.AccountPassword = $this.AccountPassword

        $this.ConnectVIServer()
        $vmHostAccount = $this.GetVMHostAccount()

        $this.PopulateResult($vmHostAccount, $result)

        return $result
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

    Checks if the VMHost Account should be updated.
    #>
    [bool] ShouldUpdateVMHostAccount($vmHostAccount) {
        $shouldUpdateVMHostAccount = @()
        $shouldUpdateVMHostAccount += ($null -ne $this.Description -and $this.Description -ne $vmHostAccount.Description)
        $shouldUpdateVMHostAccount += ($null -ne $this.GrantShellAccess -and $this.GrantShellAccess -ne $vmHostAccount.ShellAccessEnabled)

        # If the Account Password is passed to the Configuration, it should be updated.
        $shouldUpdateVMHostAccount += ($null -ne $this.AccountPassword)

        return ($shouldUpdateVMHostAccount -Contains $true)
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
        $this.PopulateVMHostAccountParams($vmHostAccountParams, $this.DesriptionParameterName, $this.Description)
        $this.PopulateVMHostAccountParams($vmHostAccountParams, $this.GrantShellAccessParameterName, $this.GrantShellAccess)

        return $vmHostAccountParams
    }

    <#
    .DESCRIPTION

    Creates a new VMHost Account with the specified properties.
    #>
    [void] AddVMHostAccount() {
        $vmHostAccountParams = $this.GetVMHostAccountParams()
        $vmHostAccountParams.Id = $this.Id

        try {
            New-VMHostAccount @vmHostAccountParams
        }
        catch {
            throw "Cannot create VMHost Account $($this.Id). For more information: $($_.Exception.Message)"
        }
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
            $result.Id = $vmHostAccount.Id
            $result.Ensure = [Ensure]::Present
            $result.Description = $vmHostAccount.Description
            $result.GrantShellAccess = $vmHostAccount.ShellAccessEnabled
        }
        else {
            $result.Id = $this.Id
            $result.Ensure = [Ensure]::Absent
            $result.Description = $this.Description
            $result.GrantShellAccess = $this.GrantShellAccess
        }
    }
}
