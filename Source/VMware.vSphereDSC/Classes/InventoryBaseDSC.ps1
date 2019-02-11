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

    Name of the Inventory Item from the Datacenter we will use.
    #>
    [DscProperty(Key)]
    [string] $Name

    <#
    .DESCRIPTION

    The full path to the Inventory Item in the Datacenter we will use from the Inventory.
    The path consists of 0 or more folders.
    The Root folders of the Datacenter are not part of the path.
    The parts of the path are separated with "/".
    Example path: "<Folder Name>/<Folder Name>"
    #>
    [DscProperty(Key)]
    [string] $InventoryPath

    <#
    .DESCRIPTION

    The full path to the Datacenter we will use from the Inventory.
    The path consists of 0 or more folders and the Datacenter name.
    Root folder of the Inventory is not part of the path.
    The parts of the path are separated with "/" where the last part of the path is the Datacenter name.
    Example path: "<Folder Name>/<Folder Name>/<Datacenter Name>".
    #>
    [DscProperty(Key)]
    [string] $Datacenter

    <#
    .DESCRIPTION

    Value indicating if the Inventory Item should be Present or Absent.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    <#
    .DESCRIPTION

    The type of Datacenter Folder in which the Inventory Item is located.
    #>
    hidden [DatacenterFolderType] $DatacenterFolderType

    <#
    .DESCRIPTION

    Returns the Datacenter we will use from the Inventory.
    #>
    [PSObject] GetDatacenterFromPath() {
        if ($this.Datacenter -eq [string]::Empty) {
            throw "You have passed an empty path which is not a valid value."
        }

        $vCenter = $this.Connection
        $rootFolder = Get-View -Server $this.Connection -Id $vCenter.ExtensionData.Content.RootFolder

        <#
        This is a special case where only the Datacenter name is passed.
        So we check if there is a Datacenter with that name at root folder.
        #>
        if ($this.Datacenter -NotMatch '/') {
            $datacentersFolder = Get-Inventory -Server $this.Connection -Id $rootFolder.MoRef
            try {
                return Get-Datacenter -Server $this.Connection -Name $this.Datacenter -Location $datacentersFolder -ErrorAction Stop | Where-Object { $._ParentFolderId -eq $datacentersFolder.Id }
            }
            catch {
                throw "Datacenter with name $($this.Datacenter) was not found at $($datacentersFolder.Name). For more inforamtion: $($_.Exception.Message)"
            }
        }

        $pathItems = $this.Datacenter -Split '/'
        $datacenterName = $pathItems[$pathItems.Length - 1]

        # Removes the Datacenter name from the path items array as we already retrieved it.
        $pathItems = $pathItems[0..($pathItems.Length - 2)]

        $childEntities = Get-View -Server $this.Connection -Id $rootFolder.ChildEntity
        $foundPathItem = $null

        foreach ($pathItem in $pathItems) {
            $foundPathItem = $childEntities | Where-Object -Property Name -eq $pathItem

            if ($null -eq $foundPathItem) {
                throw "Datacenter with path $($this.Datacenter) was not found because $pathItem folder cannot be found under."
            }

            # If the found path item does not have 'ChildEntity' member, the item is a Datacenter.
            $childEntityMember = $foundPathItem | Get-Member -Name 'ChildEnity'
            if ($null -eq $childEntityMember) {
                throw "The path $($this.Datacenter) contains another Datacenter $pathItem."
            }

            # If the found path item is Folder and not Datacenter we start looking in the items of this Folder.
            $childEntities = Get-View -Server $this.Connection -Id $foundPathItem.ChildEntity
        }

        try {
            $datacenterLocation = Get-Inventory -Server $this.Connection -Id $foundPathItem.MoRef
            return Get-Datacenter -Server $this.Connection -Name $datacenterName -Location $datacenterLocation -ErrorAction Stop | Where-Object { $._ParentFolderId -eq $datacenterLocation.Id }
        }
        catch {
            throw "Datacenter with name $datacenterName was not found. For more inforamtion: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Returns the Location of the Inventory Item we will use from the specified Datacenter.
    #>
    [PSObject] GetInventoryItemLocationFromPath($foundDatacenter) {
        $validLocation = $null
        $datacenterFolderName = "$($this.DatacenterFolderType)Folder"
        $datacenterFolderAsViewObject = Get-View -Server $this.Connection -Id $foundDatacenter.ExtensionData.$datacenterFolderName
        $datacenterFolder = Get-Inventory -Server $this.Connection -Id $datacenterFolderAsViewObject.MoRef

        # Special case where the path does not contain any folders.
        if ($this.InventoryPath -eq [string]::Empty) {
            return $datacenterFolder
        }

        # Special case where the path is just one folder.
        if ($this.InventoryPath -NotMatch '/') {
            try {
                return Get-Inventory -Server $this.Connection -Name $this.InventoryPath -Location $datacenterFolder -ErrorAction Stop | Where-Object { $_.ParentId -eq $datacenterFolder.Id }
            }
            catch {
                throw "The provided path $($this.InventoryPath) is not a valid path in the Folder $($datacenterFolder.Name)."
            }
        }

        $pathItems = $this.InventoryPath -Split '/'

        # Reverses the path items so that we can start from the bottom and go to the top of the Inventory.
        [array]::Reverse($pathItems)

        $inventoryItemLocationName = $pathItems[0]
        $locations = Get-Inventory -Server $this.Connection -Name $inventoryItemLocationName -Location $datacenterFolder

        # Removes the Inventory Item Location from the path items array as we already retrieved it.
        $pathItems = $pathItems[1..($pathItems.Length - 1)]

        <#
        For every location in the Datacenter with the specified name we start to go up through the parents to check if the path is valid.
        If one of the Parents does not meet the criteria of the path, we continue with the next found location.
        If we find a valid path we stop iterating through the locations and return the location which is part of the path.
        #>
        foreach ($location in $locations) {
            $locationAsViewObject = Get-View -Server $this.Connection -Id $location.Id -Property Parent
            $validPath = $true

            foreach ($pathItem in $pathItems) {
                $locationAsViewObject = Get-View -Server $this.Connection -Id $locationAsViewObject.Parent -Property Name, Parent
                if ($locationAsViewObject.Name -ne $pathItem) {
                    $validPath = $false
                    break
                }
            }

            if ($validPath) {
                $validLocation = $location
                break
            }
        }

        return $validLocation
    }

    <#
    .DESCRIPTION

    Returns the Inventory Item from the specified Datacenter if it exists, otherwise returns $null.
    #>
    [PSObject] GetInventoryItem() {
        $foundDatacenter = $this.GetDatacenterFromPath()
        $inventoryItemLocation = $this.GetInventoryItemLocationFromPath($foundDatacenter)

        if ($null -eq $inventoryItemLocation) {
            throw "The provided path $($this.InventoryPath) is not a valid path in the Datacenter $($foundDatacenter.Name)."
        }

        return Get-Inventory -Server $this.Connection -Name $this.Name -Location $inventoryItemLocation | Where-Object { $_.ParentId -eq $inventoryItemLocation.Id }
    }
}
