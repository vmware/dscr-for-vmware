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

    The name of the Inventory Item.
    #>
    [DscProperty(Key)]
    [string] $Name

    <#
    .DESCRIPTION

    Inventory folder path location of the Inventory Item with name specified in 'Name' key property.
    The path consists of 0 or more folders.
    The Root Inventory Folder is not part of the path.
    Empty path means the Folder is in the Root Inventory Folder.
    Folder names in path are separated by "/".
    Example paths: ""; "MyRootFolder/MyDatacentersFolder"
    #>
    [DscProperty(Key)]
    [string] $Path

    <#
    .DESCRIPTION

    Value indicating if the Inventory Item should be Present or Absent.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    <#
    .DESCRIPTION

    Returns the root folder of the specified Inventory.
    #>
    [PSObject] GetRootFolderOfInventory() {
        $inventory = $this.Connection

        $rootFolderAsViewObject = Get-View -Server $this.Connection -Id $inventory.ExtensionData.Content.RootFolder
        $rootFolder = Get-Inventory -Server $this.Connection -Id $rootFolderAsViewObject.MoRef

        return $rootFolder
    }

    <#
    .DESCRIPTION

    Returns the Location of the Inventory Item we will use from the specified Inventory.
    #>
    [PSObject] GetInventoryItemLocationFromPath($rootFolder) {
        return [InventoryHelper]::GetLocationInInventory($this.Connection, $rootFolder, $this.Path, $this.Name)
    }
}
