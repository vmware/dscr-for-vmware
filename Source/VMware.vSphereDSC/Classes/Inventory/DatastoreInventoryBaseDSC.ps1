<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

class DatastoreInventoryBaseDSC : InventoryBaseDSC {
    <#
    .DESCRIPTION

    The full path in the Datastore folder from the Datacenter we will use from the Inventory.
    The parts of the path are separated with "/" where the last part of the path is the location of the inventory object in the Datastore folder.
    #>
    [DscProperty(Key)]
    [string] $DatastoreFolderPath

    <#
    .DESCRIPTION

    Returns the desired location in the Datastore folder from the Datacenter we will use from the Inventory.
    #>
    [PSObject] GetInventoryObjectLocationFromDatastoreFolderPath() {
        $datacenter = $this.GetDatacenterFromPath()
        $datastoreFolder = Get-View -Server $this.Connection $datacenter.ExtensionData.DatastoreFolder

        # Special case where the location is the root of the Datastore folder so we return the Datastore Folder.
        if ($this.DatastoreFolderPath -eq [string]::Empty -or $this.DatastoreFolderPath -NotContains '/') {
            $locationInDatastoreFolder = Get-Folder -Server $this.Connection -Name 'datastore' -Location $datacenter
            return $locationInDatastoreFolder
        }

        $pathItems = $this.DatastoreFolderPath -split '/'
        $locationName = $pathItems[$pathItems.Length - 1]

        # Removes the Location name from the path items array as we already retrieved it.
        $pathItems = $pathItems[0..($pathItems.Length - 2)]

        $childEntities = Get-View -Server $this.Connection $datastoreFolder.ChildEntity
        $foundPathItem = $null

        foreach ($pathItem in $pathItems) {
            $foundPathItem = $childEntities | Where-Object -Property Name -eq $pathItem

            if ($null -eq $foundPathItem) {
                throw "$pathItem could not be found in the Datastore Folder of Datacenter $($datacenter.Name). Please verify you have passed a valid path."
            }

            # If the found path item is Folder and not Datastore we start looking in the items of this Folder.
            if ($foundPathItem.GetType().Name -eq 'Folder') {
                $childEntities = Get-View -Server $this.Connection $foundPathItem.ChildEntity
            }
        }

        try {
            $locationInDatastoreFolder = Get-Folder -Server $this.Connection -Name $locationName -Location $foundPathItem -ErrorAction Stop
            return $locationInDatastoreFolder
        }
        catch {
            throw "Folder with name $locationName in Datastore Folder was not found. For more inforamtion: $($_.Exception.Message)"
        }
    }
}
