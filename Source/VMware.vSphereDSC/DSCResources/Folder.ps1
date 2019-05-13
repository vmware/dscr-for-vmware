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
class Folder : InventoryBaseDSC {
    <#
    .DESCRIPTION

    The type of Folder in which the Folder is located.
    Possible values are Datacenter, Network, Datastore, Vm, Host.
    #>
    [DscProperty(Key)]
    [FolderType] $FolderType

    <#
    .DESCRIPTION

    The full path to the Datacenter in the Inventory in which the Folder is located.
    The property is used only when the Folder Type is different from 'Datacenter'.
    Root 'Datacenters' folder is not part of the path. Path can't be empty.
    Last item in the path is the Datacenter Name. If only the Datacenter Name is specified, Datacenter will be searched under the root 'Datacenters' folder.
    The parts of the path are separated with "/".
    Example paths: "MyDatacenter"; "MyDatacentersFolder/MyDatacenter".
    #>
    [DscProperty()]
    [string] $Datacenter

    [void] Set() {
        $this.ConnectVIServer()

        $folderLocation = $this.GetFolderLocation()
        $folder = $this.GetFolder($folderLocation)

        if ($this.Ensure -eq [Ensure]::Present) {
            if ($null -eq $folder) {
                $this.AddFolder($folderLocation)
            }
        }
        else {
            if ($null -ne $folder) {
                $this.RemoveFolder($folder)
            }
        }
    }

    [bool] Test() {
        $this.ConnectVIServer()

        $folderLocation = $this.GetFolderLocation()
        $folder = $this.GetFolder($folderLocation)

        if ($this.Ensure -eq [Ensure]::Present) {
            return ($null -ne $folder)
        }
        else {
            return ($null -eq $folder)
        }
    }

    [Folder] Get() {
        $result = [Folder]::new()

        $result.Server = $this.Server
        $result.FolderType = $this.FolderType
        $result.Path = $this.Path
        $result.Datacenter = $this.Datacenter

        $this.ConnectVIServer()

        $folderLocation = $this.GetFolderLocation()
        $folder = $this.GetFolder($folderLocation)

        $this.PopulateResult($folder, $result)

        return $result
    }

    <#
    .DESCRIPTION

    Returns the Location of the Folder based on the passed properties.
    If the Folder Type is 'Datacenter' the search begins below the Root 'Datacenters' folder.
    Otherwise we retrieve the Datacenter from the path specified in the 'Datacenter' property and based on the Folder Type, the search begins below the specified Root Datacenter Folder.
    #>
    [PSObject] GetFolderLocation() {
        $folderLocation = $null
        $rootFolder = $this.GetRootFolderOfInventory()

        if ($this.FolderType -eq [FolderType]::Datacenter) {
            $folderLocation = $this.GetInventoryItemLocationFromPath($rootFolder)
        }
        else {
            $foundDatacenter = [InventoryHelper]::GetDatacenterFromPath($this.Connection, $rootFolder, $this.Datacenter)
            $datacenterFolderName = "$($this.FolderType)Folder"
            $datacenterFolderAsViewObject = Get-View -Server $this.Connection -Id $foundDatacenter.ExtensionData.$datacenterFolderName
            $datacenterFolder = Get-Inventory -Server $this.Connection -Id $datacenterFolderAsViewObject.MoRef

            $folderLocation = [InventoryHelper]::GetInventoryItemLocationInDatacenter($this.Connection, $datacenterFolder, $this.Path)
        }

        return $folderLocation
    }

    <#
    .DESCRIPTION

    Returns the Folder from the specified Location if it exists, otherwise returns $null.
    #>
    [PSObject] GetFolder($folderLocation) {
        return Get-Folder -Server $this.Connection -Name $this.Name -Location $folderLocation -ErrorAction SilentlyContinue | Where-Object { $_.ParentId -eq $folderLocation.Id }
    }

    <#
    .DESCRIPTION

    Creates a new Folder with the specified properties at the specified Location.
    #>
    [void] AddFolder($folderLocation) {
        $folderParams = @{}

        $folderParams.Server = $this.Connection
        $folderParams.Name = $this.Name
        $folderParams.Location = $folderLocation
        $folderParams.Confirm = $false
        $folderParams.ErrorAction = 'Stop'

        try {
            New-Folder @folderParams
        }
        catch {
            throw "Cannot create Folder $($this.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Removes the Folder from the specified Location.
    #>
    [void] RemoveFolder($folder) {
        $folderParams = @{}

        $folderParams.Server = $this.Connection
        $folderParams.Confirm = $false
        $folderParams.ErrorAction = 'Stop'

        try {
            $folder | Remove-Folder @folderParams
        }
        catch {
            throw "Cannot remove Folder $($this.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the Folder from the server.
    #>
    [void] PopulateResult($folder, $result) {
        if ($null -ne $folder) {
            $result.Name = $folder.Name
            $result.Ensure = [Ensure]::Present
        }
        else {
            $result.Name = $this.Name
            $result.Ensure = [Ensure]::Absent
        }
    }
}
