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
class Datacenter : InventoryBaseDSC {
    [void] Set() {
        try {
            $this.ConnectVIServer()

            $datacenterLocation = $this.GetInventoryItemLocation()
            $datacenter = $this.GetDatacenter($datacenterLocation)

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $datacenter) {
                    $this.AddDatacenter($datacenterLocation)
                }
            }
            else {
                if ($null -ne $datacenter) {
                    $this.RemoveDatacenter($datacenter)
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

            $datacenterLocation = $this.GetInventoryItemLocation()
            $datacenter = $this.GetDatacenter($datacenterLocation)

            if ($this.Ensure -eq [Ensure]::Present) {
                return ($null -ne $datacenter)
            }
            else {
                return ($null -eq $datacenter)
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [Datacenter] Get() {
        try {
            $result = [Datacenter]::new()

            $result.Server = $this.Server
            $result.Location = $this.Location

            $this.ConnectVIServer()

            $datacenterLocation = $this.GetInventoryItemLocation()
            $datacenter = $this.GetDatacenter($datacenterLocation)

            $this.PopulateResult($datacenter, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Returns the Datacenter from the specified Location if it exists, otherwise returns $null.
    #>
    [PSObject] GetDatacenter($datacenterLocation) {
        <#
        The client side filtering here is used so we can retrieve only the Datacenter which is located directly below the found Folder Location
        because Get-Datacenter searches recursively and can return more than one Datacenter located below the found Folder Location.
        #>
        return Get-Datacenter -Server $this.Connection -Name $this.Name -Location $datacenterLocation -ErrorAction SilentlyContinue | Where-Object { $_.ParentFolderId -eq $datacenterLocation.Id }
    }

    <#
    .DESCRIPTION

    Creates a new Datacenter with the specified properties at the specified Location.
    #>
    [void] AddDatacenter($datacenterLocation) {
        $datacenterParams = @{}

        $datacenterParams.Server = $this.Connection
        $datacenterParams.Name = $this.Name
        $datacenterParams.Location = $datacenterLocation
        $datacenterParams.Confirm = $false
        $datacenterParams.ErrorAction = 'Stop'

        try {
            New-Datacenter @datacenterParams
        }
        catch {
            throw "Cannot create Datacenter $($this.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Removes the Datacenter from the specified Location.
    #>
    [void] RemoveDatacenter($datacenter) {
        $datacenterParams = @{}

        $datacenterParams.Server = $this.Connection
        $datacenterParams.Confirm = $false
        $datacenterParams.ErrorAction = 'Stop'

        try {
            $datacenter | Remove-Datacenter @datacenterParams
        }
        catch {
            throw "Cannot remove Datacenter $($this.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the Datacenter from the server.
    #>
    [void] PopulateResult($datacenter, $result) {
        if ($null -ne $datacenter) {
            $result.Name = $datacenter.Name
            $result.Ensure = [Ensure]::Present
        }
        else {
            $result.Name = $this.Name
            $result.Ensure = [Ensure]::Absent
        }
    }
}
