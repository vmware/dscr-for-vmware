<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

class DatacenterInventoryBaseDSC : BaseDSC {
    <#
    .DESCRIPTION

    Name of the Inventory Item located in the Datacenter specified in 'DatacenterName' key property.
    #>
    [DscProperty(Key)]
    [string] $Name

    <#
    .DESCRIPTION

    Location of the Inventory Item with name specified in 'Name' key property in
    the Datacenter specified in the 'DatacenterName' key property.
    Location consists of 0 or more Inventory Items.
    Empty Location means that the Inventory Item is in the Root Folder of the Datacenter ('Vm', 'Host', 'Network' or 'Datastore' based on the Inventory Item).
    The Root Folders of the Datacenter are not part of the Location.
    Inventory Item names in Location are separated by "/".
    Example Location for a VM Inventory Item: "Discovered Virtual Machines/My Ubuntu VMs".
    #>
    [DscProperty(Key)]
    [string] $Location

    <#
    .DESCRIPTION

    Name of the Datacenter we will use from the specified Inventory.
    #>
    [DscProperty(Key)]
    [string] $DatacenterName

    <#
    .DESCRIPTION

    Location of the Datacenter we will use from the Inventory.
    Root Folder of the Inventory is not part of the Location.
    Empty Location means that the Datacenter is in the Root Folder of the Inventory.
    Folder names in Location are separated by "/".
    Example Location: "MyDatacentersFolder".
    #>
    [DscProperty(Key)]
    [string] $DatacenterLocation

    <#
    .DESCRIPTION

    Value indicating if the Inventory Item should be Present or Absent.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    <#
    .DESCRIPTION

    Type of Folder in which the Inventory Item is located.
    Possible values are VM, Network, Datastore, Host.
    #>
    hidden [FolderType] $InventoryItemFolderType

    <#
    .DESCRIPTION

    Ensures the correct behaviour when the Location is not valid based on the passed Ensure value.
    If Ensure is set to 'Present' and the Location is not valid, the method should throw with the passed error message.
    Otherwise Ensure is set to 'Absent' and $null result is returned because with invalid Location, the Inventory Item is 'Absent'
    from that Location and no error should be thrown.
    #>
    [PSObject] EnsureCorrectBehaviourForInvalidLocation($expression) {
        if ($this.Ensure -eq [Ensure]::Present) {
            throw $expression
        }

        return $null
    }

    <#
    .DESCRIPTION

    Returns the Datacenter we will use from the Inventory.
    #>
    [PSObject] GetDatacenter() {
        $rootFolderAsViewObject = Get-View -Server $this.Connection -Id $this.Connection.ExtensionData.Content.RootFolder
        $rootFolder = Get-Inventory -Server $this.Connection -Id $rootFolderAsViewObject.MoRef

        # Special case where the Location does not contain any folders.
        if ($this.DatacenterLocation -eq [string]::Empty) {
            $foundDatacenter = Get-Datacenter -Server $this.Connection -Name $this.DatacenterName -Location $rootFolder -ErrorAction SilentlyContinue | Where-Object { $_.ParentFolderId -eq $rootFolder.Id }
            if ($null -eq $foundDatacenter) {
                return $this.EnsureCorrectBehaviourForInvalidLocation("Datacenter $($this.DatacenterName) was not found at $($rootFolder.Name).")
            }

            return $foundDatacenter
        }

        # Special case where the Location is just one folder.
        if ($this.DatacenterLocation -NotMatch '/') {
            $foundLocation = Get-Folder -Server $this.Connection -Name $this.DatacenterLocation -Location $rootFolder -ErrorAction SilentlyContinue | Where-Object { $_.ParentId -eq $rootFolder.Id }
            if ($null -eq $foundLocation) {
                return $this.EnsureCorrectBehaviourForInvalidLocation("Folder $($this.DatacenterLocation) was not found at $($rootFolder.Name).")
            }

            $foundDatacenter = Get-Datacenter -Server $this.Connection -Name $this.DatacenterName -Location $foundLocation -ErrorAction SilentlyContinue | Where-Object { $_.ParentFolderId -eq $foundLocation.Id }
            if ($null -eq $foundDatacenter) {
                return $this.EnsureCorrectBehaviourForInvalidLocation("Datacenter $($this.DatacenterName) was not found at $($foundLocation.Name).")
            }

            return $foundDatacenter
        }

        $locationItems = $this.DatacenterLocation -Split '/'
        $childEntities = Get-View -Server $this.Connection -Id $rootFolder.ExtensionData.ChildEntity
        $foundLocationItem = $null

        for ($i = 0; $i -lt $locationItems.Length; $i++) {
            $locationItem = $locationItems[$i]
            $foundLocationItem = $childEntities | Where-Object -Property Name -eq $locationItem

            if ($null -eq $foundLocationItem) {
                return $this.EnsureCorrectBehaviourForInvalidLocation("Datacenter $($this.DatacenterName) with Location $($this.DatacenterLocation) was not found because $locationItem folder cannot be found below $($rootFolder.Name).")
            }

            # If the found location item does not have 'ChildEntity' member, the item is a Datacenter.
            $childEntityMember = $foundLocationItem | Get-Member -Name 'ChildEntity'
            if ($null -eq $childEntityMember) {
                return $this.EnsureCorrectBehaviourForInvalidLocation("The Location $($this.DatacenterLocation) contains another Datacenter $locationItem.")
            }

            <#
            If the found location item is a Folder we check how many Child Entities the folder has:
            If the Folder has zero Child Entities and the Folder is not the last location item, the Location is not valid.
            Otherwise we start looking in the items of this Folder.
            #>
            if ($foundLocationItem.ChildEntity.Length -eq 0) {
                if ($i -ne $locationItems.Length - 1) {
                    return $this.EnsureCorrectBehaviourForInvalidLocation("The Location $($this.DatacenterLocation) is not valid because Folder $locationItem does not have Child Entities and the Location $($this.DatacenterLocation) contains other Inventory Items.")
                }
            }
            else {
                $childEntities = Get-View -Server $this.Connection -Id $foundLocationItem.ChildEntity
            }
        }

        $foundLocation = Get-Inventory -Server $this.Connection -Id $foundLocationItem.MoRef
        $foundDatacenter = Get-Datacenter -Server $this.Connection -Name $this.DatacenterName -Location $foundLocation -ErrorAction SilentlyContinue | Where-Object { $_.ParentFolderId -eq $foundLocation.Id }

        if ($null -eq $foundDatacenter) {
            return $this.EnsureCorrectBehaviourForInvalidLocation("Datacenter $($this.DatacenterName) with Location $($this.DatacenterLocation) was not found.")
        }

        return $foundDatacenter
    }

    <#
    .DESCRIPTION

    Returns the Location of the Inventory Item from the specified Datacenter.
    #>
    [PSObject] GetInventoryItemLocationInDatacenter($datacenter, $datacenterFolderName) {
        <#
        Here if the Ensure property is set to 'Absent', we do not need to check if the Location is valid
        because the Datacenter does not exist and this means that the Inventory Item does not exist in the specified Datacenter.
        #>
        if ($null -eq $datacenter -and $this.Ensure -eq [Ensure]::Absent) {
            return $null
        }

        $validInventoryItemLocation = $null
        $datacenterFolderAsViewObject = Get-View -Server $this.Connection -Id $datacenter.ExtensionData.$datacenterFolderName
        $datacenterFolder = Get-Inventory -Server $this.Connection -Id $datacenterFolderAsViewObject.MoRef

        # Special case where the Location does not contain any Inventory Items.
        if ($this.Location -eq [string]::Empty) {
            return $datacenterFolder
        }

        # Special case where the Location is just one Inventory Item.
        if ($this.Location -NotMatch '/') {
            $validInventoryItemLocation = Get-Inventory -Server $this.Connection -Name $this.Location -Location $datacenterFolder -ErrorAction SilentlyContinue | Where-Object { $_.ParentId -eq $datacenterFolder.Id }

            if ($null -eq $validInventoryItemLocation) {
                return $this.EnsureCorrectBehaviourForInvalidLocation("Location $($this.Location) of Inventory Item $($this.Name) was not found in Folder $($datacenterFolder.Name).")
            }

            return $validInventoryItemLocation
        }

        $locationItems = $this.Location -Split '/'

        # Reverses the location items so that we can start from the bottom and go to the top of the Inventory.
        [array]::Reverse($locationItems)

        $datacenterInventoryItemLocationName = $locationItems[0]
        $foundLocations = Get-Inventory -Server $this.Connection -Name $datacenterInventoryItemLocationName -Location $datacenterFolder -ErrorAction SilentlyContinue

        # Removes the Name of the Inventory Item Location from the location items array as we already retrieved it.
        $locationItems = $locationItems[1..($locationItems.Length - 1)]

        <#
        For every found Inventory Item Location in the Datacenter with the specified name we start to go up through the parents to check if the Location is valid.
        If one of the Parents does not meet the criteria of the Location, we continue with the next found Location.
        If we find a valid Location we stop iterating through the Locations and return it.
        #>
        foreach ($foundLocation in $foundLocations) {
            $foundLocationAsViewObject = Get-View -Server $this.Connection -Id $foundLocation.Id -Property Parent
            $validLocation = $true

            foreach ($locationItem in $locationItems) {
                $foundLocationAsViewObject = Get-View -Server $this.Connection -Id $foundLocationAsViewObject.Parent -Property Name, Parent
                if ($foundLocationAsViewObject.Name -ne $locationItem) {
                    $validLocation = $false
                    break
                }
            }

            if ($validLocation) {
                $validInventoryItemLocation = $foundLocation
                break
            }
        }

        if ($null -eq $validInventoryItemLocation) {
            return $this.EnsureCorrectBehaviourForInvalidLocation("Location $($this.Location) of Inventory Item $($this.Name) was not found in Datacenter $($datacenter.Name).")
        }

        return $validInventoryItemLocation
    }

    <#
    .DESCRIPTION

    Returns the Inventory Item from the specified Location in the Datacenter if it exists, otherwise returns $null.
    #>
    [PSObject] GetInventoryItem($inventoryItemLocationInDatacenter) {
        return Get-Inventory -Server $this.Connection -Name $this.Name -Location $inventoryItemLocationInDatacenter -ErrorAction SilentlyContinue | Where-Object { $_.ParentId -eq $inventoryItemLocationInDatacenter.Id }
    }
}
