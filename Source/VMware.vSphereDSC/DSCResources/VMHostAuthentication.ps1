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
class VMHostAuthentication : VMHostBaseDSC {
    <#
    .DESCRIPTION

    Specifies the name of the domain to join/leave. The name should be the fully qualified domain name (FQDN).
    #>
    [DscProperty(Mandatory)]
    [string] $DomainName

    <#
    .DESCRIPTION

    Value indicating if the specified VMHost should join/leave the specified domain.
    #>
    [DscProperty(Mandatory)]
    [DomainAction] $DomainAction

    <#
    .DESCRIPTION

    The credentials needed for joining the specified domain.
    #>
    [DscProperty()]
    [PSCredential] $DomainCredential

    [void] Set() {
        try {
            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $vmHostAuthenticationInfo = $this.GetVMHostAuthenticationInfo($vmHost)

            if ($this.DomainAction -eq [DomainAction]::Join) {
                $this.JoinDomain($vmHostAuthenticationInfo, $vmHost)
            }
            else {
                $this.LeaveDomain($vmHostAuthenticationInfo, $vmHost)
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $vmHostAuthenticationInfo = $this.GetVMHostAuthenticationInfo($vmHost)

            if ($this.DomainAction -eq [DomainAction]::Join) {
                return ($this.DomainName -eq $vmHostAuthenticationInfo.Domain)
            }
            else {
                return ($null -eq $vmHostAuthenticationInfo.Domain)
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostAuthentication] Get() {
        try {
            $result = [VMHostAuthentication]::new()

            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $vmHostAuthenticationInfo = $this.GetVMHostAuthenticationInfo($vmHost)

            $this.PopulateResult($vmHostAuthenticationInfo, $vmHost, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Authentication information for the specified VMHost.
    #>
    [PSObject] GetVMHostAuthenticationInfo($vmHost) {
        try {
            $vmHostAuthenticationInfo = Get-VMHostAuthentication -Server $this.Connection -VMHost $vmHost -ErrorAction Stop
            return $vmHostAuthenticationInfo
        }
        catch {
            throw "Could not retrieve Authentication information for VMHost $($vmHost.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Includes the specified VMHost in the specified domain.
    #>
    [void] JoinDomain($vmHostAuthenticationInfo, $vmHost) {
        $setVMHostAuthenticationParams = @{
            VMHostAuthentication = $vmHostAuthenticationInfo
            Domain = $this.DomainName
            Credential = $this.DomainCredential
            JoinDomain = $true
            Confirm = $false
            ErrorAction = 'Stop'
        }

        try {
            Set-VMHostAuthentication @setVMHostAuthenticationParams
        }
        catch {
            throw "Could not include VMHost $($vmHost.Name) in domain $($this.DomainName). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Excludes the specified VMHost from the specified domain.
    #>
    [void] LeaveDomain($vmHostAuthenticationInfo, $vmHost) {
        $setVMHostAuthenticationParams = @{
            VMHostAuthentication = $vmHostAuthenticationInfo
            LeaveDomain = $true
            Force = $true
            Confirm = $false
            ErrorAction = 'Stop'
        }

        try {
            Set-VMHostAuthentication @setVMHostAuthenticationParams
        }
        catch {
            throw "Could not exclude VMHost $($vmHost.Name) from domain $($this.DomainName). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method.
    #>
    [void] PopulateResult($vmHostAuthenticationInfo, $vmHost, $result) {
        $result.Server = $this.Connection.Name
        $result.Name = $vmHost.Name

        if ($null -ne $vmHostAuthenticationInfo.Domain) {
            $result.DomainName = $vmHostAuthenticationInfo.Domain
            $result.DomainAction = [DomainAction]::Join
        }
        else {
            $result.DomainName = $this.DomainName
            $result.DomainAction = [DomainAction]::Leave
        }
    }
}
