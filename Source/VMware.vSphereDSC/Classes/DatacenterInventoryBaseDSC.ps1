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
        $inventory = $this.Connection

        $rootFolderAsViewObject = Get-View -Server $this.Connection -Id $inventory.ExtensionData.Content.RootFolder
        $rootFolder = Get-Inventory -Server $this.Connection -Id $rootFolderAsViewObject.MoRef

        return [InventoryHelper]::GetDatacenterFromPath($this.Connection, $rootFolder, $this.Datacenter)
    }

    <#
    .DESCRIPTION

    Returns the Location of the Inventory Item we will use from the specified Datacenter.
    #>
    [PSObject] GetDatacenterInventoryItemLocationFromPath($foundDatacenter) {
        $datacenterFolderName = "$($this.DatacenterFolderType)Folder"
        $datacenterFolderAsViewObject = Get-View -Server $this.Connection -Id $foundDatacenter.ExtensionData.$datacenterFolderName
        $datacenterFolder = Get-Inventory -Server $this.Connection -Id $datacenterFolderAsViewObject.MoRef

        return [InventoryHelper]::GetInventoryItemLocationInDatacenter($this.Connection, $datacenterFolder, $this.DatacenterInventoryPath)
    }

    <#
    .DESCRIPTION

    Returns the Inventory Item from the specified Datacenter if it exists, otherwise returns $null.
    #>
    [PSObject] GetInventoryItem($datacenterInventoryItemLocation) {
        return Get-Inventory -Server $this.Connection -Name $this.Name -Location $datacenterInventoryItemLocation -ErrorAction SilentlyContinue | Where-Object { $_.ParentId -eq $datacenterInventoryItemLocation.Id }
    }
}
