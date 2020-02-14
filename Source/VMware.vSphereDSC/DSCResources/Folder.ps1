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
class Folder : DatacenterInventoryBaseDSC {
    <#
    .DESCRIPTION

    The type of Root Folder in the Datacenter in which the Folder is located.
    Possible values are VM, Network, Datastore, Host.
    #>
    [DscProperty(Key)]
    [FolderType] $FolderType

    [void] Set() {
        try {
            $this.ConnectVIServer()

            $datacenter = $this.GetDatacenter()
            $datacenterFolderName = "$($this.FolderType)Folder"
            $folderLocation = $this.GetInventoryItemLocationInDatacenter($datacenter, $datacenterFolderName)
            $folder = $this.GetInventoryItem($folderLocation)

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
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()

            $datacenter = $this.GetDatacenter()
            $datacenterFolderName = "$($this.FolderType)Folder"
            $folderLocation = $this.GetInventoryItemLocationInDatacenter($datacenter, $datacenterFolderName)
            $folder = $this.GetInventoryItem($folderLocation)

            if ($this.Ensure -eq [Ensure]::Present) {
                return ($null -ne $folder)
            }
            else {
                return ($null -eq $folder)
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [Folder] Get() {
        try {
            $result = [Folder]::new()

            $result.Server = $this.Server
            $result.Location = $this.Location
            $result.DatacenterName = $this.DatacenterName
            $result.DatacenterLocation = $this.DatacenterLocation
            $result.FolderType = $this.FolderType

            $this.ConnectVIServer()

            $datacenter = $this.GetDatacenter()
            $datacenterFolderName = "$($this.FolderType)Folder"
            $folderLocation = $this.GetInventoryItemLocationInDatacenter($datacenter, $datacenterFolderName)
            $folder = $this.GetInventoryItem($folderLocation)

            $this.PopulateResult($folder, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
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
