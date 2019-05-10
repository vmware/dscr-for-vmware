<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

class InventoryHelper {
    <#
    .DESCRIPTION

    Returns the Location of the Inventory Item from the specified Inventory.
    #>
    static [PSObject] GetLocationInInventory($viServer, $rootFolder, $path, $inventoryItemName) {
        # When empty path is specified, the Location is the root folder of the Inventory.
        if ($path -eq [string]::Empty) {
            return $rootFolder
        }

        <#
        This is a special case where only one Folder name is passed.
        So we check if there is a Folder with that name in the root folder of the Inventory.
        #>
        if ($path -NotMatch '/') {
            $foundLocation = Get-Folder -Server $viServer -Name $path -Location $rootFolder -ErrorAction SilentlyContinue | Where-Object { $_.ParentId -eq $rootFolder.Id }

            if ($null -eq $foundLocation) {
                throw "Folder with name $path was not found in $($rootFolder.Name)."
            }

            return $foundLocation
        }

        $pathItems = $path -Split '/'
        $locationName = $pathItems[$pathItems.Length - 1]

        # Removes the Location name from the path items array as we already retrieved it.
        $pathItems = $pathItems[0..($pathItems.Length - 2)]

        $childEntities = Get-View -Server $viServer -Id $rootFolder.ExtensionData.ChildEntity
        $foundPathItem = $null

        foreach ($pathItem in $pathItems) {
            $foundPathItem = $childEntities | Where-Object -Property Name -eq $pathItem

            if ($null -eq $foundPathItem) {
                throw "The Location of Inventory Item $inventoryItemName with path $path was not found because $pathItem Folder cannot be found in Folder $($rootFolder.Name)."
            }

            # If the found path item does not have 'ChildEntity' member, the item is a Datacenter.
            $childEntityMember = $foundPathItem | Get-Member -Name 'ChildEntity'
            if ($null -eq $childEntityMember) {
                throw "The path $path contains Datacenter $pathItem."
            }

            # If the found path item is a Folder and not a Datacenter we start looking in the items of this Folder.
            $childEntities = Get-View -Server $viServer -Id $foundPathItem.ChildEntity
        }

        $locationParent = Get-Inventory -Server $viServer -Id $foundPathItem.MoRef
        $foundLocation = Get-Folder -Server $viServer -Name $locationName -Location $locationParent -ErrorAction SilentlyContinue | Where-Object { $_.ParentId -eq $locationParent.Id }

        if ($null -eq $foundLocation) {
            throw "The Location of Inventory Item $inventoryItemName was not found in the specified Inventory."
        }

        return $foundLocation
    }

    <#
    .DESCRIPTION

    Returns the Datacenter we will use from the specified Inventory.
    #>
    static [PSObject] GetDatacenterFromPath($viServer, $rootFolder, $path) {
        if ($path -eq [string]::Empty) {
            throw 'You have passed an empty path which is not a valid value.'
        }

        <#
        This is a special case where only the Datacenter name is passed.
        So we check if there is a Datacenter with that name in the root folder of the Inventory.
        #>
        if ($path -NotMatch '/') {
            $foundDatacenter = Get-Datacenter -Server $viServer -Name $path -Location $rootFolder -ErrorAction SilentlyContinue | Where-Object { $_.ParentFolderId -eq $rootFolder.Id }

            if ($null -eq $foundDatacenter) {
                throw "Datacenter with name $path was not found at $($rootFolder.Name)."
            }

            return $foundDatacenter
        }

        $pathItems = $path -Split '/'
        $datacenterName = $pathItems[$pathItems.Length - 1]

        # Removes the Datacenter name from the path items array as we already retrieved it.
        $pathItems = $pathItems[0..($pathItems.Length - 2)]

        $childEntities = Get-View -Server $viServer -Id $rootFolder.ExtensionData.ChildEntity
        $foundPathItem = $null

        foreach ($pathItem in $pathItems) {
            $foundPathItem = $childEntities | Where-Object -Property Name -eq $pathItem

            if ($null -eq $foundPathItem) {
                throw "Datacenter with path $path was not found because $pathItem Folder cannot be found under Folder $($rootFolder.Name)."
            }

            # If the found path item does not have 'ChildEntity' member, the item is a Datacenter.
            $childEntityMember = $foundPathItem | Get-Member -Name 'ChildEntity'
            if ($null -eq $childEntityMember) {
                throw "The path $path contains Datacenter $pathItem."
            }

            # If the found path item is a Folder and not a Datacenter we start looking in the items of this Folder.
            $childEntities = Get-View -Server $viServer -Id $foundPathItem.ChildEntity
        }

        $datacenterLocation = Get-Inventory -Server $viServer -Id $foundPathItem.MoRef
        $foundDatacenter = Get-Datacenter -Server $viServer -Name $datacenterName -Location $datacenterLocation -ErrorAction SilentlyContinue | Where-Object { $_.ParentFolderId -eq $datacenterLocation.Id }

        if ($null -eq $foundDatacenter) {
            throw "Datacenter with name $datacenterName was not found."
        }

        return $foundDatacenter
    }

    <#
    .DESCRIPTION

    Returns the Inventory Item Location from the specified Datacenter.
    #>
    static [PSObject] GetInventoryItemLocationInDatacenter($viServer, $rootFolder, $path) {
        # When empty path is specified, the Location is the root folder of the Datacenter.
        if ($path -eq [string]::Empty) {
            return $rootFolder
        }

        <#
        This is a special case where only one Inventory Item name is passed.
        So we check if there is a Inventory Item with that name in the root folder of the Datacenter.
        #>
        if ($path -NotMatch '/') {
            $foundLocation = Get-Inventory -Server $viServer -Name $path -Location $rootFolder -ErrorAction SilentlyContinue | Where-Object { $_.ParentId -eq $rootFolder.Id }

            if ($null -eq $foundLocation) {
                throw "Inventory Item with name $path was not found at $($rootFolder.Name)."
            }

            return $foundLocation
        }

        $validLocation = $null
        $pathItems = $path -Split '/'

        # Reverses the path items so that we can start from the bottom and go to the top of the Datacenter Folder.
        [array]::Reverse($pathItems)

        $inventoryItemLocationName = $pathItems[0]
        $locations = Get-Inventory -Server $viServer -Name $inventoryItemLocationName -Location $rootFolder -ErrorAction SilentlyContinue

        # Removes the Inventory Item Location from the path items array as we already retrieved it.
        $pathItems = $pathItems[1..($pathItems.Length - 1)]

        <#
        For every location in the Datacenter Folder with the specified name we start to go up through the parents to check if the path is valid.
        If one of the Parents does not meet the criteria of the path, we continue with the next found location.
        If we find a valid path we stop iterating through the locations and return the location which is part of the path.
        #>
        foreach ($location in $locations) {
            $locationAsViewObject = Get-View -Server $viServer -Id $location.Id -Property Parent
            $validPath = $true

            foreach ($pathItem in $pathItems) {
                $locationAsViewObject = Get-View -Server $viServer -Id $locationAsViewObject.Parent -Property Name, Parent
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

        if ($null -eq $validLocation) {
            throw "The provided path $path is not a valid path in the Datacenter $($rootFolder.Parent.Name)."
        }

        return $validLocation
    }
}
