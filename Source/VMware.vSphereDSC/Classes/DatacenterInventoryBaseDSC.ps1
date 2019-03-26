<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

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

    Name of the resource under the Datacenter of 'Datacenter' key property.
    #>
    [DscProperty(Key)]
    [string] $Name

    <#
    .DESCRIPTION

    Inventory folder path location of the resource with name specified in 'Name' key property in
    the Datacenter specified in the 'Datacenter' key property.
    The path consists of 0 or more folders.
    Empty path means the resource is in the root inventory folder.
    The Root folders of the Datacenter are not part of the path.
    Folder names in path are separated by "/".
    Example path for a VM resource: "Discovered Virtual Machines/My Ubuntu VMs".
    #>
    [DscProperty(Key)]
    [string] $DatacenterInventoryPath

    <#
    .DESCRIPTION

    The full path to the Datacenter we will use from the Inventory.
    Root 'datacenters' folder is not part of the path. Path can't be empty.
    Last item in the path is the Datacenter Name. If only the Datacenter Name is specified, Datacenter will be searched under the root 'datacenters' folder.
    The parts of the path are separated with "/".
    Example path: "MyDatacentersFolder/MyDatacenter".
    #>
    [DscProperty(Key)]
    [string] $Datacenter

    <#
    .DESCRIPTION

    Value indicating if the Resource should be Present or Absent.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    <#
    .DESCRIPTION

    The type of Datacenter Folder in which the Resource is located.
    Possible values are VM, Network, Datastore, Host.
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
        $foundDatacenter = $null

        <#
        This is a special case where only the Datacenter name is passed.
        So we check if there is a Datacenter with that name at root folder.
        #>
        if ($this.Datacenter -NotMatch '/') {
            $datacentersFolder = Get-Inventory -Server $this.Connection -Id $rootFolder.MoRef
            $foundDatacenter = Get-Datacenter -Server $this.Connection -Name $this.Datacenter -Location $datacentersFolder -ErrorAction SilentlyContinue | Where-Object { $_.ParentFolderId -eq $datacentersFolder.Id }

            if ($null -eq $foundDatacenter) {
                throw "Datacenter with name $($this.Datacenter) was not found at $($datacentersFolder.Name)."
            }

            return $foundDatacenter
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
            $childEntityMember = $foundPathItem | Get-Member -Name 'ChildEntity'
            if ($null -eq $childEntityMember) {
                throw "The path $($this.Datacenter) contains another Datacenter $pathItem."
            }

            # If the found path item is Folder and not Datacenter we start looking in the items of this Folder.
            $childEntities = Get-View -Server $this.Connection -Id $foundPathItem.ChildEntity
        }

        $datacenterLocation = Get-Inventory -Server $this.Connection -Id $foundPathItem.MoRef
        $foundDatacenter = Get-Datacenter -Server $this.Connection -Name $datacenterName -Location $datacenterLocation -ErrorAction SilentlyContinue | Where-Object { $_.ParentFolderId -eq $datacenterLocation.Id }

        if ($null -eq $foundDatacenter) {
            throw "Datacenter with name $datacenterName was not found."
        }

        return $foundDatacenter
    }

    <#
    .DESCRIPTION

    Returns the Location of the Inventory Item we will use from the specified Datacenter.
    #>
    [PSObject] GetDatacenterInventoryItemLocationFromPath($foundDatacenter) {
        $validLocation = $null
        $datacenterFolderName = "$($this.DatacenterFolderType)Folder"
        $datacenterFolderAsViewObject = Get-View -Server $this.Connection -Id $foundDatacenter.ExtensionData.$datacenterFolderName
        $datacenterFolder = Get-Inventory -Server $this.Connection -Id $datacenterFolderAsViewObject.MoRef

        # Special case where the path does not contain any folders.
        if ($this.DatacenterInventoryPath -eq [string]::Empty) {
            return $datacenterFolder
        }

        # Special case where the path is just one folder.
        if ($this.DatacenterInventoryPath -NotMatch '/') {
            $validLocation = Get-Inventory -Server $this.Connection -Name $this.DatacenterInventoryPath -Location $datacenterFolder -ErrorAction SilentlyContinue | Where-Object { $_.ParentId -eq $datacenterFolder.Id }

            if ($null -eq $validLocation) {
                throw "The provided path $($this.DatacenterInventoryPath) is not a valid path in the Folder $($datacenterFolder.Name)."
            }

            return $validLocation
        }

        $pathItems = $this.DatacenterInventoryPath -Split '/'

        # Reverses the path items so that we can start from the bottom and go to the top of the Inventory.
        [array]::Reverse($pathItems)

        $datacenterInventoryItemLocationName = $pathItems[0]
        $locations = Get-Inventory -Server $this.Connection -Name $datacenterInventoryItemLocationName -Location $datacenterFolder -ErrorAction SilentlyContinue

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
    [PSObject] GetInventoryItem($foundDatacenter, $datacenterInventoryItemLocation) {
        if ($null -eq $datacenterInventoryItemLocation) {
            throw "The provided path $($this.DatacenterInventoryPath) is not a valid path in the Datacenter $($foundDatacenter.Name)."
        }

        return Get-Inventory -Server $this.Connection -Name $this.Name -Location $datacenterInventoryItemLocation -ErrorAction SilentlyContinue | Where-Object { $_.ParentId -eq $datacenterInventoryItemLocation.Id }
    }
}
