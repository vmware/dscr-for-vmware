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
class vCenterVMHost : DatacenterInventoryBaseDSC {
    vCenterVMHost() {
        $this.InventoryItemFolderType = [FolderType]::Host
    }

    <#
    .DESCRIPTION

    Credentials needed for authenticating with the VMHost.
    #>
    [DscProperty(Mandatory)]
    [PSCredential] $VMHostCredential

    <#
    .DESCRIPTION

    Specifies the port on the VMHost used for the connection.
    #>
    [DscProperty()]
    [nullable[int]] $Port

    <#
    .DESCRIPTION

    Indicates whether the VMHost is added to the vCenter if the authenticity of the VMHost SSL certificate cannot be verified.
    #>
    [DscProperty()]
    [nullable[bool]] $Force

    hidden [string] $AddVMHostTovCenterMessage = "Adding VMHost {0} to vCenter {1} and location {2}."
    hidden [string] $MoveVMHostToDestinationMessage = "Moving VMHost {0} to location {1} on vCenter {2}."
    hidden [string] $RemoveVMHostFromvCenterMessage = "Removing VMHost {0} from vCenter {1}."

    hidden [string] $CouldNotAddVMHostTovCenterMessage = "Could not add VMHost {0} to vCenter {1} and location {2}. For more information: {3}"
    hidden [string] $CouldNotMoveVMHostToDestinationMessage = "Could not move VMHost {0} to location {1} on vCenter {2}. For more information: {3}"
    hidden [string] $CouldNotRemoveVMHostFromvCenterMessage = "Could not remove VMHost {0} from vCenter {1}. For more information: {2}"

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()
            $this.EnsureConnectionIsvCenter()

            $vmHost = $this.GetVMHost()

            if ($this.Ensure -eq [Ensure]::Present) {
                $datacenter = $this.GetDatacenter()
                $datacenterFolderName = "$($this.InventoryItemFolderType)Folder"
                $vmHostLocation = $this.GetInventoryItemLocationInDatacenter($datacenter, $datacenterFolderName)

                if ($null -eq $vmHost) {
                    $this.AddVMHost($vmHostLocation)
                }
                else {
                    if ($vmHost.ParentId -ne $vmHostLocation.Id) {
                        $this.MoveVMHost($vmHost, $vmHostLocation)
                    }
                }
            }
            else {
                if ($null -ne $vmHost) {
                    $this.RemoveVMHost($vmHost)
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
            $this.EnsureConnectionIsvCenter()

            $vmHost = $this.GetVMHost()
            $result = $null

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $vmHost) {
                    $result = $false
                }
                else {
                    $datacenter = $this.GetDatacenter()
                    $datacenterFolderName = "$($this.InventoryItemFolderType)Folder"
                    $vmHostLocation = $this.GetInventoryItemLocationInDatacenter($datacenter, $datacenterFolderName)

                    $result = ($vmHost.ParentId -eq $vmHostLocation.Id)
                }
            }
            else {
                $result = ($null -eq $vmHost)
            }

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [vCenterVMHost] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [vCenterVMHost]::new()

            $this.ConnectVIServer()
            $this.EnsureConnectionIsvCenter()

            $vmHost = $this.GetVMHost()
            $this.PopulateResult($result, $vmHost)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the VMHost with the specified name if it is on the vCenter Server system.
    #>
    [PSObject] GetVMHost() {
        return Get-VMHost -Server $this.Connection -Name $this.Name -ErrorAction SilentlyContinue -Verbose:$false
    }

    <#
    .DESCRIPTION

    Adds the VMHost to the specified location and to be managed by the vCenter Server system.
    #>
    [void] AddVMHost($vmHostLocation) {
        $addVMHostParams = @{
            Server = $this.Connection
            Name = $this.Name
            Location = $vmHostLocation
            Credential = $this.VMHostCredential
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        if ($null -ne $this.Port) { $addVMHostParams.Port = $this.Port }
        if ($null -ne $this.Force) { $addVMHostParams.Force = $this.Force }

        try {
            Write-VerboseLog -Message $this.AddVMHostTovCenterMessage -Arguments @($this.Name, $this.Connection.Name, $vmHostLocation.Name)
            Add-VMHost @addVMHostParams
        }
        catch {
            throw ($this.CouldNotAddVMHostTovCenterMessage -f $this.Name, $this.Connection.Name, $vmHostLocation.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Moves the VMHost to the specified location on the vCenter Server system.
    #>
    [void] MoveVMHost($vmHost, $vmHostLocation) {
        $moveVMHostParams = @{
            Server = $this.Connection
            VMHost = $vmHost
            Destination = $vmHostLocation
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        try {
            Write-VerboseLog -Message $this.MoveVMHostToDestinationMessage -Arguments @($vmHost.Name, $vmHostLocation.Name, $this.Connection.Name)
            Move-VMHost @moveVMHostParams
        }
        catch {
            throw ($this.CouldNotMoveVMHostToDestinationMessage -f $vmHost.Name, $vmHostLocation.Name, $this.Connection.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Removes the VMHost from the vCenter Server system.
    #>
    [void] RemoveVMHost($vmHost) {
        $removeVMHostParams = @{
            Server = $this.Connection
            VMHost = $vmHost
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        try {
            Write-VerboseLog -Message $this.RemoveVMHostFromvCenterMessage -Arguments @($vmHost.Name, $this.Connection.Name)
            Remove-VMHost @removeVMHostParams
        }
        catch {
            throw ($this.CouldNotRemoveVMHostFromvCenterMessage -f $vmHost.Name, $this.Connection.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $vmHost) {
        $result.Server = $this.Connection.Name
        $result.Location = $this.Location
        $result.DatacenterName = $this.DatacenterName
        $result.DatacenterLocation = $this.DatacenterLocation
        $result.Force = $this.Force

        if ($null -ne $vmHost) {
            $result.Name = $vmHost.Name
            $result.Ensure = [Ensure]::Present
            $result.Port = $vmHost.ExtensionData.Summary.Config.Port
        }
        else {
            $result.Name = $this.Name
            $result.Ensure = [Ensure]::Absent
            $result.Port = $this.Port
        }
    }
}
