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
class DatacenterFolder : InventoryBaseDSC {
    [void] Set() {
        try {
            $this.ConnectVIServer()

            $datacenterFolderLocation = $this.GetInventoryItemLocation()
            $datacenterFolder = $this.GetDatacenterFolder($datacenterFolderLocation)

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $datacenterFolder) {
                    $this.AddDatacenterFolder($datacenterFolderLocation)
                }
            }
            else {
                if ($null -ne $datacenterFolder) {
                    $this.RemoveDatacenterFolder($datacenterFolder)
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

            $datacenterFolderLocation = $this.GetInventoryItemLocation()
            $datacenterFolder = $this.GetDatacenterFolder($datacenterFolderLocation)

            if ($this.Ensure -eq [Ensure]::Present) {
                return ($null -ne $datacenterFolder)
            }
            else {
                return ($null -eq $datacenterFolder)
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [DatacenterFolder] Get() {
        try {
            $result = [DatacenterFolder]::new()

            $result.Server = $this.Server
            $result.Location = $this.Location

            $this.ConnectVIServer()

            $datacenterFolderLocation = $this.GetInventoryItemLocation()
            $datacenterFolder = $this.GetDatacenterFolder($datacenterFolderLocation)

            $this.PopulateResult($datacenterFolder, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Returns the Datacenter Folder from the specified Location if it exists, otherwise returns $null.
    #>
    [PSObject] GetDatacenterFolder($datacenterFolderLocation) {
        <#
        The client side filtering here is used so we can retrieve only the Folder which is located directly below the found Folder Location
        because Get-Folder searches recursively and can return more than one Folder located below the found Folder Location.
        #>
        return Get-Folder -Server $this.Connection -Name $this.Name -Location $datacenterFolderLocation -ErrorAction SilentlyContinue | Where-Object { $_.ParentId -eq $datacenterFolderLocation.Id }
    }

    <#
    .DESCRIPTION

    Creates a new Datacenter Folder with the specified properties at the specified Location.
    #>
    [void] AddDatacenterFolder($datacenterFolderLocation) {
        $datacenterFolderParams = @{}

        $datacenterFolderParams.Server = $this.Connection
        $datacenterFolderParams.Name = $this.Name
        $datacenterFolderParams.Location = $datacenterFolderLocation
        $datacenterFolderParams.Confirm = $false
        $datacenterFolderParams.ErrorAction = 'Stop'

        try {
            New-Folder @datacenterFolderParams
        }
        catch {
            throw "Cannot create Datacenter Folder $($this.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Removes the Datacenter Folder from the specified Location.
    #>
    [void] RemoveDatacenterFolder($datacenterFolder) {
        $datacenterFolderParams = @{}

        $datacenterFolderParams.Server = $this.Connection
        $datacenterFolderParams.Confirm = $false
        $datacenterFolderParams.ErrorAction = 'Stop'

        try {
            $datacenterFolder | Remove-Folder @datacenterFolderParams
        }
        catch {
            throw "Cannot remove Datacenter Folder $($this.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the Datacenter Folder from the server.
    #>
    [void] PopulateResult($datacenterFolder, $result) {
        if ($null -ne $datacenterFolder) {
            $result.Name = $datacenterFolder.Name
            $result.Ensure = [Ensure]::Present
        }
        else {
            $result.Name = $this.Name
            $result.Ensure = [Ensure]::Absent
        }
    }
}
