<#
Copyright (c) 2018-2021 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

[DscResource()]
class VMHostStorage : VMHostBaseDSC {
    <#
    .DESCRIPTION

    Specifies whether the software iSCSI is enabled on the VMHost storage.
    #>
    [DscProperty(Mandatory)]
    [bool] $Enabled

    hidden [string] $RetrieveVMHostStorageMessage = "Retrieving VMHost storage for VMHost {0}."
    hidden [string] $ConfigureVMHostStorageMessage = "Configuring VMHost storage for VMHost {0}."

    hidden [string] $CouldNotRetrieveVMHostStorageMessage = "Could not retrieve VMHost storage for VMHost {0}. For more information: {1}"
    hidden [string] $CouldNotConfigureVMHostStorageMessage = "Could not configure VMHost storage for VMHost {0}. For more information: {1}"

    [void] Set() {
        try {
            $this.WriteLogUtil('Verbose', $this.SetMethodStartMessage, @($this.DscResourceName))
            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $vmHostStorage = $this.GetVMHostStorage($vmHost)
            $this.ConfigureVMHostStorage($vmHostStorage)
        }
        finally {
            $this.DisconnectVIServer()
            $this.WriteLogUtil('Verbose', $this.SetMethodEndMessage, @($this.DscResourceName))
        }
    }

    [bool] Test() {
        try {
            $this.WriteLogUtil('Verbose', $this.TestMethodStartMessage, @($this.DscResourceName))
            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $vmHostStorage = $this.GetVMHostStorage($vmHost)

            $result = !$this.ShouldConfigureVMHostStorage($vmHostStorage)
            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            $this.WriteLogUtil('Verbose', $this.TestMethodEndMessage, @($this.DscResourceName))
        }
    }

    [VMHostStorage] Get() {
        try {
            $this.WriteLogUtil('Verbose', $this.GetMethodStartMessage, @($this.DscResourceName))
            $result = [VMHostStorage]::new()

            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $vmHostStorage = $this.GetVMHostStorage($vmHost)

            $this.PopulateResult($result, $vmHostStorage)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            $this.WriteLogUtil('Verbose', $this.GetMethodEndMessage, @($this.DscResourceName))
        }
    }

    <#
    .DESCRIPTION

    Retrieves the VMHost storage for the specified VMHost.
    #>
    [PSObject] GetVMHostStorage($vmHost) {
        $getVMHostStorageParams = @{
            Server = $this.Connection
            VMHost = $vmHost
            ErrorAction = 'Stop'
            Verbose = $false
        }

        try {
            $this.WriteLogUtil('Verbose', $this.RetrieveVMHostStorageMessage, @($vmHost.Name))
            return Get-VMHostStorage @getVMHostStorageParams
        }
        catch {
            throw ($this.CouldNotRetrieveVMHostStorageMessage -f $vmHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Checks if the specified VMHost storage should be configured - whether to
    enable or disable the software iSCSI support.
    #>
    [bool] ShouldConfigureVMHostStorage($vmHostStorage) {
        return $this.ShouldUpdateDscResourceSetting('Enabled', $vmHostStorage.SoftwareIScsiEnabled, $this.Enabled)
    }

    <#
    .DESCRIPTION

    Configures the VMHost storage - enables or disables the software iSCSI support.
    #>
    [void] ConfigureVMHostStorage($vmHostStorage) {
        $setVMHostStorageParams = @{
            VMHostStorage = $vmHostStorage
            SoftwareIScsiEnabled = $this.Enabled
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        try {
            $this.WriteLogUtil('Verbose', $this.ConfigureVMHostStorageMessage, @($vmHostStorage.VMHost.Name))
            Set-VMHostStorage @setVMHostStorageParams
        }
        catch {
            throw ($this.CouldNotConfigureVMHostStorageMessage -f $vmHostStorage.VMHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $vmHostStorage) {
        $result.Server = $this.Connection.Name
        $result.Name = $vmHostStorage.VMHost.Name
        $result.Enabled = $vmHostStorage.SoftwareIScsiEnabled
    }
}
