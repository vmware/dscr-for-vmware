<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

class DatastoreBaseDSC : VMHostEntityBaseDSC {
    <#
    .DESCRIPTION

    Specifies the name of the Datastore.
    #>
    [DscProperty(Key)]
    [string] $Name

    <#
    .DESCRIPTION

    For Nfs Datastore, specifies the remote path of the Nfs mount point.
    For Vmfs Datastore, specifies the canonical name of the Scsi logical unit that contains the Vmfs Datastore.
    #>
    [DscProperty(Mandatory)]
    [string] $Path

    <#
    .DESCRIPTION

    Specifies whether the Datastore should be present or absent.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    <#
    .DESCRIPTION

    Specifies the file system that is used on the Datastore.
    #>
    [DscProperty()]
    [string] $FileSystemVersion

    <#
    .DESCRIPTION

    Specifies the latency period beyond which the storage array is considered congested. The range of this value is between 10 to 100 milliseconds.
    #>
    [DscProperty()]
    [nullable[int]] $CongestionThresholdMillisecond

    <#
    .DESCRIPTION

    Indicates whether the IO control is enabled.
    #>
    [DscProperty()]
    [nullable[bool]] $StorageIOControlEnabled

    hidden [string] $CreateDatastoreMessage = "Creating Datastore {0} on VMHost {1}."
    hidden [string] $ModifyDatastoreMessage = "Modifying Datastore {0} on VMHost {1}."
    hidden [string] $RemoveDatastoreMessage = "Removing Datastore {0} from VMHost {1}."

    hidden [string] $CouldNotCreateDatastoreWithTheSpecifiedNameMessage = "Could not create Datastore {0} on VMHost {1} because there is another Datastore with the same name on vCenter Server {2}."
    hidden [string] $CouldNotCreateDatastoreMessage = "Could not create Datastore {0} on VMHost {1}. For more information: {2}"
    hidden [string] $CouldNotModifyDatastoreMessage = "Could not modify Datastore {0} on VMHost {1}. For more information: {2}"
    hidden [string] $CouldNotRemoveDatastoreMessage = "Could not remove Datastore {0} from VMHost {1}. For more information: {2}"

    <#
    .DESCRIPTION

    Retrieves the Datastore with the specified name from the VMHost if it exists.
    #>
    [PSObject] GetDatastore() {
        $getDatastoreParams = @{
            Server = $this.Connection
            Name = $this.Name
            VMHost = $this.VMHost
            ErrorAction = 'SilentlyContinue'
            Verbose = $false
        }

        $datastore = Get-Datastore @getDatastoreParams

        <#
        If the established connection is to a vCenter Server, Ensure is 'Present' and the Datastore does not exist on the specified VMHost,
        we need to check if there is a Datastore with the same name on the vCenter Server.
        #>
        if ($this.Connection.ProductLine -eq $this.vCenterProductId -and $this.Ensure -eq [Ensure]::Present -and $null -eq $datastore) {
            # We need to remove the filter by VMHost from the hashtable to search for the Datastore in the whole vCenter Server.
            $getDatastoreParams.Remove('VMHost')

            <#
            If there is another Datastore with the same name on the vCenter Server but on a different VMHost, we need to inform the user that the Datastore cannot be created with the
            specified name. vCenter Server accepts multiple Datastore creations with the same name but changes the names internally to avoid name duplication.
            vCenter Server appends '(<index>)' to the Datastore name.
            #>
            $datastoreInvCenter = Get-Datastore @getDatastoreParams
            if ($null -ne $datastoreInvCenter) {
                throw ($this.CouldNotCreateDatastoreWithTheSpecifiedNameMessage -f $this.Name, $this.VMHost.Name, $this.Connection.Name)
            }
        }

        return $datastore
    }

    <#
    .DESCRIPTION

    Checks if the specified Datastore should be modified.
    #>
    [bool] ShouldModifyDatastore($datastore) {
        $shouldModifyDatastore = @()

        $shouldModifyDatastore += ($null -ne $this.CongestionThresholdMillisecond -and $this.CongestionThresholdMillisecond -ne $datastore.CongestionThresholdMillisecond)
        $shouldModifyDatastore += ($null -ne $this.StorageIOControlEnabled -and $this.StorageIOControlEnabled -ne $datastore.StorageIOControlEnabled)

        return ($shouldModifyDatastore -Contains $true)
    }

    <#
    .DESCRIPTION

    Creates a new Datastore with the specified name on the VMHost.
    #>
    [PSObject] NewDatastore($newDatastoreParams) {
        $newDatastoreParams.Server = $this.Connection
        $newDatastoreParams.Name = $this.Name
        $newDatastoreParams.VMHost = $this.VMHost
        $newDatastoreParams.Path = $this.Path
        $newDatastoreParams.Confirm = $false
        $newDatastoreParams.ErrorAction = 'Stop'
        $newDatastoreParams.Verbose = $false

        if (![string]::IsNullOrEmpty($this.FileSystemVersion)) { $newDatastoreParams.FileSystemVersion = $this.FileSystemVersion }

        try {
            Write-VerboseLog -Message $this.CreateDatastoreMessage -Arguments @($this.Name, $this.VMHost.Name)
            $datastore = New-Datastore @newDatastoreParams

            return $datastore
        }
        catch {
            throw ($this.CouldNotCreateDatastoreMessage -f $this.Name, $this.VMHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Modifies the properties of the specified Datastore.
    #>
    [void] ModifyDatastore($datastore) {
        $setDatastoreParams = @{
            Server = $this.Connection
            Datastore = $datastore
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        if ($null -ne $this.StorageIOControlEnabled) { $setDatastoreParams.StorageIOControlEnabled = $this.StorageIOControlEnabled }
        if ($null -ne $this.CongestionThresholdMillisecond) { $setDatastoreParams.CongestionThresholdMillisecond = $this.CongestionThresholdMillisecond }

        try {
            Write-VerboseLog -Message $this.ModifyDatastoreMessage -Arguments @($datastore.Name, $this.VMHost.Name)
            Set-Datastore @setDatastoreParams
        }
        catch {
            throw ($this.CouldNotModifyDatastoreMessage -f $datastore.Name, $this.VMHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Removes the specified Datastore from the VMHost.
    #>
    [void] RemoveDatastore($datastore) {
        $removeDatastoreParams = @{
            Server = $this.Connection
            Datastore = $datastore
            VMHost = $thiS.VMHost
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        try {
            Write-VerboseLog -Message $this.RemoveDatastoreMessage -Arguments @($datastore.Name, $this.VMHost.Name)
            Remove-Datastore @removeDatastoreParams
        }
        catch {
            throw ($this.CouldNotRemoveDatastoreMessage -f $datastore.Name, $this.VMHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $datastore) {
        $result.Server = $this.Connection.Name
        $result.VMHostName = $this.VMHost.Name

        if ($null -ne $datastore) {
            $result.Name = $datastore.Name
            $result.Ensure = [Ensure]::Present
            $result.FileSystemVersion = $datastore.FileSystemVersion
            $result.CongestionThresholdMillisecond = $datastore.CongestionThresholdMillisecond
            $result.StorageIOControlEnabled = $datastore.StorageIOControlEnabled
        }
        else {
            $result.Name = $this.Name
            $result.Ensure = [Ensure]::Absent
            $result.FileSystemVersion = $this.FileSystemVersion
            $result.CongestionThresholdMillisecond = $this.CongestionThresholdMillisecond
            $result.StorageIOControlEnabled = $this.StorageIOControlEnabled
        }
    }
}
