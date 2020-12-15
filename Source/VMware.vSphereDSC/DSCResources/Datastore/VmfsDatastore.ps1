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
class VmfsDatastore : DatastoreBaseDSC {
    <#f
    .DESCRIPTION

    Specifies the maximum file size of Vmfs in megabytes (MB). If no value is specified, the maximum file size for the current system platform is used.
    #>
    [DscProperty()]
    [nullable[int]] $BlockSizeMB

    hidden [string] $CouldNotCreateVmfsDatastoreWithTheSpecifiedNameMessage = "Could not create Vmfs Datastore {0} on VMHost {1} because there is another Vmfs Datastore with the same name on vCenter Server {2}."

    [void] Set() {
        try {
            $this.ConnectVIServer()

            $this.WriteLogUtil('Verbose', $this.SetMethodStartMessage, @($this.DscResourceName))

            $this.RetrieveVMHost()

            $datastore = $this.GetDatastore()
            $this.ValidateVmfsDatastoreCreation($datastore)

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $datastore) {
                    $datastore = $this.NewVmfsDatastore()
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
            $this.WriteLogUtil('Verbose', $this.SetMethodEndMessage, @($this.DscResourceName))

            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()

            $this.WriteLogUtil('Verbose', $this.TestMethodStartMessage, @($this.DscResourceName))

            $this.RetrieveVMHost()

            $datastore = $this.GetDatastore()
            $this.ValidateVmfsDatastoreCreation($datastore)

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
            $this.WriteLogUtil('Verbose', $this.TestMethodEndMessage, @($this.DscResourceName))

            $this.DisconnectVIServer()
        }
    }

    [VmfsDatastore] Get() {
        try {
            $this.ConnectVIServer()

            $this.WriteLogUtil('Verbose', $this.GetMethodStartMessage, @($this.DscResourceName))

            $result = [VmfsDatastore]::new()

            $this.RetrieveVMHost()

            $datastore = $this.GetDatastore()
            $this.ValidateVmfsDatastoreCreation($datastore)

            $this.PopulateResultForVmfsDatastore($result, $datastore)

            return $result
        }
        finally {
            $this.WriteLogUtil('Verbose', $this.GetMethodEndMessage, @($this.DscResourceName))
            
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Checks if a Vmfs Datastore with the specified name can be created on the vCenter Server.
    #>
    [void] ValidateVmfsDatastoreCreation($datastore) {
        <#
            If the established connection is to a vCenter Server, Ensure is 'Present' and the Vmfs Datastore does not exist on the specified VMHost,
            we need to check if there is a Vmfs Datastore with the same name on the vCenter Server.
        #>
        if ($this.Connection.ProductLine -eq $this.vCenterProductId -and $this.Ensure -eq [Ensure]::Present -and $null -eq $datastore) {
            $getDatastoreParams = @{
                Server = $this.Connection
                Name = $this.Name
                ErrorAction = 'SilentlyContinue'
                Verbose = $false
            }

            <#
                If there is another Vmfs Datastore with the same name on the vCenter Server but on a different VMHost, we need to inform the user that
                the Vmfs Datastore cannot be created with the specified name. vCenter Server accepts multiple Vmfs Datastore creations with the same name
                but changes the names internally to avoid name duplication. vCenter Server appends '(<index>)' to the Vmfs Datastore name.
            #>
            $datastoreInvCenter = Get-Datastore @getDatastoreParams
            if ($null -ne $datastoreInvCenter) {
                throw ($this.CouldNotCreateVmfsDatastoreWithTheSpecifiedNameMessage -f $this.Name, $this.VMHost.Name, $this.Connection.Name)
            }
        }
    }

    <#
    .DESCRIPTION

    Creates a new Vmfs Datastore with the specified name on the VMHost.
    #>
    [PSObject] NewVmfsDatastore() {
        $newDatastoreParams = @{
            Vmfs = $true
        }

        if ($null -ne $this.BlockSizeMB) { $newDatastoreParams.BlockSizeMB = $this.BlockSizeMB }

        return $this.NewDatastore($newDatastoreParams)
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResultForVmfsDatastore($result, $datastore) {
        if ($null -ne $datastore) {
            $result.BlockSizeMB = $datastore.ExtensionData.Info.Vmfs.BlockSizeMB
            $result.Path = $datastore.ExtensionData.Info.Vmfs.Extent | Where-Object -FilterScript { $_.DiskName -eq $this.Path } | Select-Object -ExpandProperty DiskName
        }
        else {
            $result.BlockSizeMB = $this.BlockSizeMB
            $result.Path = $this.Path
        }

        $this.PopulateResult($result, $datastore)
    }
}
