<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

class InventoryBaseDSC : BaseDSC {
    <#
    .DESCRIPTION

    The full path to the Datacenter we will use from the Inventory.
    The parts of the path are separated with "/" where the last part of the path is the Datacenter name.
    #>
    [DscProperty(Key)]
    [string] $DatacenterPath

    <#
    .DESCRIPTION

    Value indicating if the Inventory object should be Present or Absent.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    <#
    .DESCRIPTION

    Returns the Datacenter we will use from the Inventory.
    #>
    [PSObject] GetDatacenterFromPath() {
        if ($this.DatacenterPath -eq [string]::Empty) {
            throw "You have passed an empty path which is not a valid value."
        }

        $vCenter = $this.Connection
        $rootFolder = Get-View -Server $this.Connection $vCenter.ExtensionData.Content.RootFolder

        <#
        This is a special case where only the Datacenter name is passed.
        So we check if there is a Datacenter with that name at root folder.
        #>
        if ($this.DatacenterPath -NotContains '/') {
            try {
                $datacenter = Get-Datacenter -Server $this.Connection -Name $this.DatacenterPath -Location $rootFolder -ErrorAction Stop
                return $datacenter
            }
            catch {
                throw "Datacenter with name $($this.DatacenterPath) was not found at $rootFolder. For more inforamtion: $($_.Exception.Message)"
            }
        }

        $pathItems = $this.DatacenterPath -Split '/'
        $datacenterName = $pathItems[$pathItems.Length - 1]

        # Removes the Datacenter name from the path items array as we already retrieved it.
        $pathItems = $pathItems[0..($pathItems.Length - 2)]

        $childEntities = Get-View -Server $this.Connection $rootFolder.ChildEntity
        $foundPathItem = $null

        foreach ($pathItem in $pathItems) {
            $foundPathItem = $childEntities | Where-Object -Property Name -eq $pathItem

            if ($null -eq $foundPathItem) {
                throw "$pathItem could not be found in the Inventory. Please verify you have passed a valid path."
            }

            # If the found path item is Folder and not Datacenter we start looking in the items of this Folder.
            if ($foundPathItem -is [VMware.Vim.Folder]) {
                $childEntities = Get-View -Server $this.Connection $foundPathItem.ChildEntity
            }
        }

        try {
            $datacenter = Get-Datacenter -Server $this.Connection -Name $datacenterName -Location $foundPathItem -ErrorAction Stop
            return $datacenter
        }
        catch {
            throw "Datacenter with name $datacenterName was not found. For more inforamtion: $($_.Exception.Message)"
        }
    }
}
