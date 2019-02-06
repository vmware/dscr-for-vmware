<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

class HostInventoryBaseDSC : InventoryBaseDSC {
    <#
    .DESCRIPTION

    The full path to the Inventory object we will use from the Host folder in the specified Datacenter.
    The path consists of 0 or more folders and the Inventory object name.
    Host folder of the Datacenter is not part of the path.
    The parts of the path are separated with "/".
    Example path: "<Folder Name>/<Folder Name>/<Inventory object Name>".
    #>
    [DscProperty(Key)]
    [string] $Path

    <#
    .DESCRIPTION

    Returns the Inventory object we will use from the Host folder of the specified Datacenter if it exists, otherwise returns $null.
    #>
    [PSObject] GetInventoryObjectFromPath() {
        # This is a special case where no folders or inventory object name is passed.
        if ($this.Path -eq [string]::Empty) {
            throw "The passed path is empty and cannot be resolved to a specific Inventory object."
        }

        $datacenter = $this.GetDatacenterFromPath()
        $hostFolder = Get-View -Server $this.Connection -Id $datacenter.ExtensionData.HostFolder
        $childEntities = Get-View -Server $this.Connection -Id $hostFolder.ChildEnity
        $foundPathItem = $null
        $result = $null

        <#
        This is a special case where only the Inventory object name is passed.
        So if the Inventory object with that name at the Host folder of the specified Datacenter exists, we return it, otherwise we return $null.
        #>
        if ($this.Path -NotContains '/') {
            $foundPathItem = $childEntities | Where-Object { $_.Name -eq $this.Path }

            if ($null -ne $foundPathItem) {
                $result = Get-Inventory -Server $this.Connection -Id $foundPathItem.MoRef
            }

            return result
        }

        $pathItems = $this.Path -Split '/'
        $inventoryObjectName = $pathItems[$pathItems.Length - 1]

        # Removes the Inventory object name from the path items array as we already retrieved it.
        $pathItems = $pathItems[0..($pathItems.Length - 2)]

        foreach ($pathItem in $pathItems) {
            $foundPathItem = $childEntities | Where-Object { $_.Name -eq $this.Path }

            if ($null -eq $foundPathItem) {
                throw "$inventoryObjectName with path $($this.Path) was not found in Host folder because $pathItem folder cannot be found under."
            }

            # If the found path item does not have 'ChildEntity' member, the item is not a Folder.
            $childEntityMember = $foundPathItem | Get-Member -Name 'ChildEntity'
            if ($null -eq $childEntityMember) {
                throw "The path $($this.Path) contains $pathItem that is not a Folder."
            }

            # If the found path item is Folder we start looking in the items of this Folder.
            $childEntities = Get-View -Server $this.Connection -Id $foundPathItem.ChildEntity
        }

        $inventoryObject = $childEntities | Where-Object { $_.Name -eq $inventoryObjectName }

        if ($null -ne $inventoryObject) {
            $result = Get-Inventory -Server $this.Connection -Id $inventoryObject.MoRef
        }

        return result
    }
}
