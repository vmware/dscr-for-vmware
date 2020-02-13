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
class NfsUser : VMHostEntityBaseDSC {
    <#
    .DESCRIPTION

    Specifies the Nfs User name used for Kerberos authentication.
    #>
    [DscProperty(Key)]
    [string] $Name

    <#
    .DESCRIPTION

    Specifies the Nfs User password used for Kerberos authentication.
    #>
    [DscProperty()]
    [string] $Password

    <#
    .DESCRIPTION

    Specifies whether the Nfs User should be present or absent.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    <#
    .DESCRIPTION

    Specifies whether to change the password of the Nfs User. When the property is not specified or is $false, it is ignored.
    If the property is $true and the Nfs User exists, the password of the Nfs User is changed.
    #>
    [DscProperty()]
    [nullable[bool]] $Force

    hidden [string] $CreateNfsUserMessage = "Creating Nfs User {0} on VMHost {1}."
    hidden [string] $ChangeNfsUserPasswordMessage = "Changing Nfs User {0} password on VMHost {1}."
    hidden [string] $RemoveNfsUserMessage = "Removing Nfs User {0} from VMHost {1}."

    hidden [string] $CouldNotCreateNfsUserMessage = "Could not create Nfs User {0} on VMHost {1}. For more information: {2}"
    hidden [string] $CouldNotChangeNfsUserPasswordMessage = "Could not change Nfs User {0} password on VMHost {1}. For more information: {2}"
    hidden [string] $CouldNotRemoveNfsUserMessage = "Could not remove Nfs User {0} from VMHost {1}. For more information: {2}"

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $nfsUser = $this.GetNfsUser()

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $nfsUser) {
                    $this.NewNfsUser()
                }
                else {
                    $this.ChangeNfsUserPassword($nfsUser)
                }
            }
            else {
                if ($null -ne $nfsUser) {
                    $this.RemoveNfsUser($nfsUser)
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
            $this.RetrieveVMHost()

            $nfsUser = $this.GetNfsUser()
            $result = $null

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $nfsUser) {
                    $result = $false
                }
                else {
                    $result = !($null -ne $this.Force -and $this.Force)
                }
            }
            else {
                $result = ($null -eq $nfsUser)
            }

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [NfsUser] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [NfsUser]::new()

            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $nfsUser = $this.GetNfsUser()
            $this.PopulateResult($result, $nfsUser)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Nfs User with the specified name from the VMHost if it exists.
    #>
    [PSObject] GetNfsUser() {
        <#
        The Verbose logic here is needed to suppress the Verbose output of the Import-Module cmdlet
        when importing the 'VMware.VimAutomation.Storage' Module.
        #>
        $savedVerbosePreference = $global:VerbosePreference
        $global:VerbosePreference = 'SilentlyContinue'

        $nfsUser = Get-NfsUser -Server $this.Connection -Username $this.Name -VMHost $this.VMHost -ErrorAction SilentlyContinue -Verbose:$false

        $global:VerbosePreference = $savedVerbosePreference

        return $nfsUser
    }

    <#
    .DESCRIPTION

    Creates a new Nfs User with the specified name and password on the VMHost.
    #>
    [void] NewNfsUser() {
        $newNfsUserParams = @{
            Server = $this.Connection
            Username = $this.Name
            VMHost = $this.VMHost
            Password = $this.Password
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        try {
            Write-VerboseLog -Message $this.CreateNfsUserMessage -Arguments @($this.Name, $this.VMHost.Name)
            New-NfsUser @newNfsUserParams
        }
        catch {
            throw ($this.CouldNotCreateNfsUserMessage -f $this.Name, $this.VMHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Changes the password of the specified Nfs User on the VMHost.
    #>
    [void] ChangeNfsUserPassword($nfsUser) {
        $setNfsUserParams = @{
            Server = $this.Connection
            NfsUser = $nfsUser
            Password = $this.Password
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        try {
            Write-VerboseLog -Message $this.ChangeNfsUserPasswordMessage -Arguments @($nfsUser.Username, $this.VMHost.Name)
            Set-NfsUser @setNfsUserParams
        }
        catch {
            throw ($this.CouldNotChangeNfsUserPasswordMessage -f $nfsUser.Username, $this.VMHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Removes the specified Nfs User from the VMHost.
    #>
    [void] RemoveNfsUser($nfsUser) {
        $removeNfsUserParams = @{
            NfsUser = $nfsUser
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        try {
            Write-VerboseLog -Message $this.RemoveNfsUserMessage -Arguments @($nfsUser.Username, $this.VMHost.Name)
            Remove-NfsUser @removeNfsUserParams
        }
        catch {
            throw ($this.CouldNotRemoveNfsUserMessage -f $nfsUser.Username, $this.VMHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $nfsUser) {
        $result.Server = $this.Connection.Name
        $result.VMHostName = $this.VMHost.Name
        $result.Force = $this.Force

        if ($null -ne $nfsUser) {
            $result.Name = $nfsUser.Username
            $result.Ensure = [Ensure]::Present
        }
        else {
            $result.Name = $this.Name
            $result.Ensure = [Ensure]::Absent
        }
    }
}
