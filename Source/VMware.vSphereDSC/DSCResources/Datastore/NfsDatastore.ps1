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
class NfsDatastore : DatastoreBaseDSC {
    <#
    .DESCRIPTION

    Specifies the Nfs Host for the Datastore.
    #>
    [DscProperty(Mandatory)]
    [string[]] $NfsHost

    <#
    .DESCRIPTION

    Specifies the access mode for the Nfs Datastore. Valid access modes are 'ReadWrite' and 'ReadOnly'.
    The default access mode is 'ReadWrite'.
    #>
    [DscProperty()]
    [AccessMode] $AccessMode = [AccessMode]::ReadWrite

    <#
    .DESCRIPTION

    Specifies the authentication method for the Nfs Datastore. Valid authentication methods are 'AUTH_SYS' and 'Kerberos'.
    The default authentication method is 'AUTH_SYS'.
    #>
    [DscProperty()]
    [AuthenticationMethod] $AuthenticationMethod = [AuthenticationMethod]::AUTH_SYS

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $datastore = $this.GetDatastore()

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $datastore) {
                    $datastore = $this.NewNfsDatastore()
                }

                if ($this.ShouldModifyDatastore($datastore)) {
                    $this.ModifyDatastore($datastore)
                }
            }
            else {
                if ($null -ne $datastore) {
                    $this.RemoveDatastore($datastore)
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

            $datastore = $this.GetDatastore()
            $result = $null

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $datastore) {
                    $result = $false
                }
                else {
                    $result = !$this.ShouldModifyDatastore($datastore)
                }
            }
            else {
                $result = ($null -eq $datastore)
            }

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [NfsDatastore] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [NfsDatastore]::new()

            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $datastore = $this.GetDatastore()
            $this.PopulateResultForNfsDatastore($result, $datastore)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Creates a new Nfs Datastore with the specified name on the VMHost.
    #>
    [PSObject] NewNfsDatastore() {
        $newDatastoreParams = @{
            Nfs = $true
            NfsHost = $this.NfsHost
        }

        if ($this.AccessMode -eq [AccessMode]::ReadOnly) { $newDatastoreParams.ReadOnly = $true }
        if ($this.AuthenticationMethod -eq [AuthenticationMethod]::Kerberos) { $newDatastoreParams.Kerberos = $true }

        return $this.NewDatastore($newDatastoreParams)
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResultForNfsDatastore($result, $datastore) {
        if ($null -ne $datastore) {
            $result.NfsHost = $datastore.RemoteHost
            $result.Path = $datastore.RemotePath
            $result.AccessMode = [AccessMode] $datastore.ExtensionData.Host.MountInfo.AccessMode
            $result.AuthenticationMethod = $datastore.AuthenticationMethod.ToString()
        }
        else {
            $result.NfsHost = $this.NfsHost
            $result.Path = $this.Path
            $result.AccessMode = $this.AccessMode
            $result.AuthenticationMethod = $this.AuthenticationMethod
        }

        $this.PopulateResult($result, $datastore)
    }
}
