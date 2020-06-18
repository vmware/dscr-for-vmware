<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

class InventoryUtil {
    InventoryUtil($viServer, $ensure) {
        $this.VIServer = $viServer
        $this.Ensure = $ensure
    }

    <#
    .DESCRIPTION

    Specifies the established connection to the vCenter Server system.
    #>
    [PSObject] $VIServer

    <#
    .DESCRIPTION

    Specifies whether the Inventory Item that is exposed through a DSC Resource that uses the 'InventoryUtil' class
    should be present or absent. It is used to determine the behaviour of the methods in the class
    that retrieve Inventory Items.
    #>
    [Ensure] $Ensure

    hidden [string] $InvalidLocationMessage = "Location {0} is not a valid location inside Folder {1}."

    hidden [string] $CouldNotRetrieveRootFolderMessage = "Could not retrieve Inventory Root Folder of vCenter Server {0}. For more information: {1}"
    hidden [string] $CouldNotRetrieveDatacenterRootFolderMessage = "Could not retrieve {0} of Datacenter {1}. For more information: {2}"
    hidden [string] $CouldNotRetrieveVDSwitchMessage = "Could not retrieve VDSwitch {0}. For more information: {1}"
    hidden [string] $CouldNotFindDatacenterMessage = "Could not find Datacenter {0} located in Folder {1}."
    hidden [string] $CouldNotFindFolderMessage = "Could not find Folder {0} located in Folder {1}."
    hidden [string] $CouldNotFindInventoryItemMessage = "Could not find Inventory Item {0} located in Inventory Item {1}."
    hidden [string] $CouldNotFindDatastoreClusterMessage = "Could not find Datastore Cluster {0} located in Folder {1}."

    <#
    .DESCRIPTION

    Retrieves the Datacenter with the specified name, located in the specified Folder.
    #>
    [PSObject] GetDatacenter($datacenterName, $datacenterLocation) {
        $datacenter = $null
        $inventoryRootFolder = $this.GetInventoryRootFolder()

        <#
            If empty Datacenter location is passed, the Datacenter should be located
                in the Root Folder of the Inventory.
            If Datacenter location without '/' is passed, the Datacenter should be located
                in the Folder specified in the Datacenter location.
            If Datacenter location with '/' is passed, the Datacenter should be located
                in the Folder that is lastly specified in the Datacenter location.
        #>
        if ($datacenterLocation -eq [string]::Empty) {
            $datacenter = $this.GetDatacenterInFolder($datacenterName, $inventoryRootFolder)
        }
        elseif ($datacenterLocation -NotMatch '/') {
            $folder = $this.GetFolder($datacenterLocation, $inventoryRootFolder)
            $datacenter = $this.GetDatacenterInFolder($datacenterName, $folder)
        }
        else {
            $folder = $null
            $datacenterLocationItems = $datacenterLocation -Split '/'

            # The array needs to be reversed so we can retrieve the Folder where the Datacenter is located.
            [array]::Reverse($datacenterLocationItems)

            $datacenterLocationName = $datacenterLocationItems[0]
            $foundDatacenterFolderLocations = $this.GetDatacenterFoldersByName($datacenterLocationName, $inventoryRootFolder)

            # The Folder where the Datacenter is located is already retrieved and it's not needed anymore.
            $datacenterLocationItems = $datacenterLocationItems[1..($datacenterLocationItems.Length - 1)]

            foreach ($foundDatacenterFolderLocation in $foundDatacenterFolderLocations) {
                $currentDatacenterLocationItem = $foundDatacenterFolderLocation
                $isDatacenterLocationValid = $true

                foreach ($datacenterLocationItem in $datacenterLocationItems) {
                    if ($currentDatacenterLocationItem.Parent.Name -ne $datacenterLocationItem) {
                        $isDatacenterLocationValid = $false
                        break
                    }

                    $currentDatacenterLocationItem = $currentDatacenterLocationItem.Parent
                }

                <#
                    If the Datacenter location is valid, the first Datacenter location item
                    should be located inside the Root Folder of the Inventory.
                #>
                if (
                    $isDatacenterLocationValid -and
                    $currentDatacenterLocationItem.ParentId -eq $inventoryRootFolder.Id
                ) {
                    $folder = $foundDatacenterFolderLocation
                    break
                }
            }

            if ($null -eq $folder -and $this.Ensure -eq [Ensure]::Present) {
                throw ($this.InvalidLocationMessage -f $datacenterLocation, $inventoryRootFolder.Name)
            }

            $datacenter = $this.GetDatacenterInFolder($datacenterName, $folder)
        }

        return $datacenter
    }

    <#
    .DESCRIPTION

    Retrieves the Parent of the Inventory Item located in the specified Datacenter.
    #>
    [PSObject] GetInventoryItemParent($inventoryItemLocation, $datacenter, $datacenterRootFolderName) {
        # If the Datacenter doesn't exist, the Inventory Item Parent doesn't exist as well.
        if ($null -eq $datacenter) {
            return $null
        }

        $inventoryItemParent = $null
        $datacenterRootFolder = $this.GetRootFolderOfDatacenter($datacenter, $datacenterRootFolderName)

        <#
            If empty Inventory Item location is passed, the Inventory Item Parent
                in the Root Folder of the Datacenter.
            If Inventory Item location without '/' is passed, the Inventory Item Parent
                is the Inventory Item specified in the Inventory Item location.
            If Inventory Item location with '/' is passed, the Inventory Item Parent
                is the Inventory Item that is lastly specified in the Inventory Item location.
        #>
        if ($inventoryItemLocation -eq [string]::Empty) {
            $inventoryItemParent = $datacenterRootFolder
        }
        elseif ($inventoryItemLocation -NotMatch '/') {
            $inventoryItemParent = $this.GetInventoryItem($inventoryItemLocation, $datacenterRootFolder)
        }
        else {
            $inventoryItemLocationItems = $inventoryItemLocation -Split '/'

            # The array needs to be reversed so we can retrieve the name of the Parent of the Inventory Item.
            [array]::Reverse($inventoryItemLocationItems)

            $inventoryItemParentName = $inventoryItemLocationItems[0]
            $foundInventoryItemLocations = $this.GetInventoryItemsByName($inventoryItemParentName, $datacenterRootFolder)

            # The Parent name where the Inventory Item is located is already retrieved and it's not needed anymore.
            $inventoryItemLocationItems = $inventoryItemLocationItems[1..($inventoryItemLocationItems.Length - 1)]

            foreach ($foundInventoryItemLocation in $foundInventoryItemLocations) {
                $currentInventoryItemLocationItem = $foundInventoryItemLocation
                $isInventoryItemLocationValid = $true

                foreach ($inventoryItemLocationItem in $inventoryItemLocationItems) {
                    if ($currentInventoryItemLocationItem.Parent.Name -ne $inventoryItemLocationItem) {
                        $isInventoryItemLocationValid = $false
                        break
                    }

                    $currentInventoryItemLocationItem = $currentInventoryItemLocationItem.Parent
                }

                <#
                    If the Inventory Item location is valid, the first Inventory Item location item
                    should be located inside the corresponding Root Folder of the Datacenter.
                #>
                if (
                    $isInventoryItemLocationValid -and
                    $currentInventoryItemLocationItem.ParentId -eq $datacenterRootFolder.Id
                ) {
                    $inventoryItemParent = $foundInventoryItemLocation
                    break
                }
            }

            if ($null -eq $inventoryItemParent -and $this.Ensure -eq [Ensure]::Present) {
                throw ($this.InvalidLocationMessage -f $inventoryItemLocation, $datacenterRootFolder.Name)
            }
        }

        return $inventoryItemParent
    }

    <#
    .DESCRIPTION

    Retrieves the Root Folder of the specified Inventory.
    #>
    [PSObject] GetInventoryRootFolder() {
        $getInventoryParams = @{
            Server = $this.VIServer
            Id = $this.VIServer.ExtensionData.Content.RootFolder
            ErrorAction = 'Stop'
            Verbose = $false
        }

        try {
            return Get-Inventory @getInventoryParams
        }
        catch {
            throw ($this.CouldNotRetrieveRootFolderMessage -f $this.VIServer.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the specified Root Folder of the Datacenter.
    #>
    [PSObject] GetRootFolderOfDatacenter($datacenter, $datacenterRootFolderName) {
        $getInventoryParams = @{
            Server = $this.VIServer
            Id = $datacenter.ExtensionData.$datacenterRootFolderName
            ErrorAction = 'Stop'
            Verbose = $false
        }

        try {
            return Get-Inventory @getInventoryParams
        }
        catch {
            throw ($this.CouldNotRetrieveDatacenterRootFolderMessage -f $datacenterRootFolderName, $datacenter.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Datacenter with the specified name, located in the specified Folder.
    #>
    [PSObject] GetDatacenterInFolder($datacenterName, $folder) {
        $getDatacenterParams = @{
            Server = $this.VIServer
            Name = $datacenterName
            Location = $folder
            ErrorAction = 'SilentlyContinue'
            Verbose = $false
        }

        $whereObjectParams = @{
            FilterScript = {
                $_.ParentFolderId -eq $folder.Id
            }
        }

        $datacenter = Get-Datacenter @getDatacenterParams | Where-Object @whereObjectParams
        if ($null -eq $datacenter -and $this.Ensure -eq [Ensure]::Present) {
            throw ($this.CouldNotFindDatacenterMessage -f $datacenterName, $folder.Name)
        }

        return $datacenter
    }

    <#
    .DESCRIPTION

    Retrieves the Folder with the specified name, located in the specified Folder.
    #>
    [PSObject] GetFolder($folderName, $parentFolder) {
        $getFolderParams = @{
            Server = $this.VIServer
            Name = $folderName
            Location = $parentFolder
            ErrorAction = 'SilentlyContinue'
            Verbose = $false
        }

        $whereObjectParams = @{
            FilterScript = {
                $_.ParentId -eq $parentFolder.Id
            }
        }

        $folder = Get-Folder @getFolderParams | Where-Object @whereObjectParams
        if ($null -eq $folder -and $this.Ensure -eq [Ensure]::Present) {
            throw ($this.CouldNotFindFolderMessage -f $folderName, $parentFolder.Name)
        }

        return $folder
    }

    <#
    .DESCRIPTION

    Retrieves all Folders with the specified name of type Datacenter,
    located inside the specified Folder.
    #>
    [PSObject] GetDatacenterFoldersByName($folderName, $folderLocation) {
        $getFolderParams = @{
            Server = $this.VIServer
            Name = $folderName
            Location = $folderLocation
            Type = 'Datacenter'
            ErrorAction = 'SilentlyContinue'
            Verbose = $false
        }

        return Get-Folder @getFolderParams
    }

    <#
    .DESCRIPTION

    Retrieves all Inventory Items with the specified name,
    located inside the specified Inventory Item.
    #>
    [array] GetInventoryItemsByName($inventoryItemName, $inventoryItemLocation) {
        $getInventoryParams = @{
            Server = $this.VIServer
            Name = $inventoryItemName
            Location = $inventoryItemLocation
            ErrorAction = 'SilentlyContinue'
            Verbose = $false
        }

        return Get-Inventory @getInventoryParams
    }

    <#
    .DESCRIPTION

    Retrieves the Inventory Item with the specified name, located in the specified Inventory Item.
    #>
    [PSObject] GetInventoryItem($inventoryItemName, $inventoryItemParent) {
        $getInventoryParams = @{
            Server = $this.VIServer
            Name = $inventoryItemName
            Location = $inventoryItemParent
            ErrorAction = 'SilentlyContinue'
            Verbose = $false
        }

        $whereObjectParams = @{
            FilterScript = {
                $_.ParentId -eq $inventoryItemParent.Id
            }
        }

        $inventoryItem = Get-Inventory @getInventoryParams | Where-Object @whereObjectParams
        if ($null -eq $inventoryItem -and $this.Ensure -eq [Ensure]::Present) {
            throw ($this.CouldNotFindInventoryItemMessage -f $inventoryItemName, $inventoryItemParent.Name)
        }

        return $inventoryItem
    }

    <#
    .DESCRIPTION

    Retrieves the Datastore Cluster with the specified name located in the specified Folder.
    #>
    [PSObject] GetDatastoreCluster($datastoreClusterName, $folder) {
        $getDatastoreClusterParams = @{
            Server = $this.VIServer
            Name = $datastoreClusterName
            Location = $folder
            ErrorAction = 'SilentlyContinue'
            Verbose = $false
        }

        $whereObjectParams = @{
            FilterScript = {
                $_.ExtensionData.Parent -eq $folder.ExtensionData.MoRef
            }
        }

        <#
            Multiple Datastore Clusters with the same name can be present in a Datacenter. So we need to filter
            by the direct Parent Folder of the Datastore Cluster to retrieve the desired one.
        #>
        $datastoreCluster = Get-DatastoreCluster @getDatastoreClusterParams | Where-Object @whereObjectParams
        if ($null -eq $datastoreCluster -and $this.Ensure -eq [Ensure]::Present) {
            throw ($this.CouldNotFindDatastoreClusterMessage -f $datastoreClusterName, $folder.Name)
        }

        return $datastoreCluster
    }

    <#
    .DESCRIPTION

    Retrieves the VDSwitch with the specified name from the server if it exists.
    If the VDSwitch does not exist and Ensure is set to 'Absent', $null is returned.
    Otherwise the method throws an exception.
    #>
    [PSObject] GetVDSwitch($vdSwitchName) {
        <#
            The Verbose logic here is needed to suppress the Verbose output of the Import-Module cmdlet
            when importing the 'VMware.VimAutomation.Vds' Module.
        #>
        $savedVerbosePreference = $global:VerbosePreference
        $global:VerbosePreference = 'SilentlyContinue'

        $getVDSwitchParams = @{
            Server = $this.VIServer
            Name = $vdSwitchName
            Verbose = $false
        }

        if ($this.Ensure -eq [Ensure]::Absent) {
            $getVDSwitchParams.ErrorAction = 'SilentlyContinue'
        }
        else {
            $getVDSwitchParams.ErrorAction = 'Stop'
        }

        try {
            return Get-VDSwitch @getVDSwitchParams
        }
        catch {
            throw ($this.CouldNotRetrieveVDSwitchMessage -f $vdSwitchName, $_.Exception.Message)
        }
        finally {
            $global:VerbosePreference = $savedVerbosePreference
        }
    }
}
