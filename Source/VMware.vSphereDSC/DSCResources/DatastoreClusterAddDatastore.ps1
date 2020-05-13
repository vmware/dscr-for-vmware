<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

[DscResource()]
class DatastoreClusterAddDatastore : BaseDSC {
    <#
    .DESCRIPTION

    Specifies the name of the Datacenter where the specified
    Datastore Cluster and Datastores are located.
    #>
    [DscProperty(Key)]
    [string] $DatacenterName

    <#
    .DESCRIPTION

    Specifies the location of the Datacenter where the specified Datastore Cluster and
    Datastores are located. The Root Folder of the Inventory is not part of the location.
    Empty location means that the Datacenter is in the Root Folder of the Inventory.
    The Folder names in the location are separated by '/'.
    Example Datacenter location: 'MyDatacentersFolderOne/MyDatacentersFolderTwo'.
    #>
    [DscProperty(Key)]
    [string] $DatacenterLocation

    <#
    .DESCRIPTION

    Specifies the name of the Datastore Cluster located in the Datacenter specified in 'DatacenterName' key property.
    #>
    [DscProperty(Key)]
    [string] $DatastoreClusterName

    <#
    .DESCRIPTION

    Specifies the location of the Datastore Cluster with name specified in 'DatastoreClusterName' key property in the Datacenter
    specified in 'DatacenterName' key property. Location consists of 0 or more Folders.
    Empty location means that the Datastore Cluster is located in the Datastore Folder of the Datacenter.
    The Root Folders of the Datacenter are not part of the location. Folder names in the location are separated by '/'.
    Example location for a Datastore Cluster: 'MyDatastoreClusterFolderOne/MyDatastoreClusterFolderTwo'.
    #>
    [DscProperty(Key)]
    [string] $DatastoreClusterLocation

    <#
    .DESCRIPTION

    Specifies the names of the Datastores that should be located in the specified Datastore Cluster.
    #>
    [DscProperty(Mandatory)]
    [string[]] $DatastoreNames

    <#
    .DESCRIPTION

    Specifies the instance of the 'InventoryUtil' class that is used
    for Inventory operations.
    #>
    hidden [InventoryUtil] $InventoryUtil

    hidden [string] $AddDatastoresToDatastoreClusterMessage = "Adding Datastores {0} to Datastore Cluster {1}."

    hidden [string] $CouldNotFindDatastoreMessage = "Could not find Datastore {0} in Datacenter {1}."
    hidden [string] $CouldNotAddDatastoresToDatastoreClusterMessage = "Could not add Datastores {0} to Datastore Cluster {1}. For more information: {2}"

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()

            $this.InitInventoryUtil()
            $datacenter = $this.InventoryUtil.GetDatacenter($this.DatacenterName, $this.DatacenterLocation)
            $datacenterDatastoreFolderName = [FolderType]::Datastore.ToString() + 'Folder'
            $datastoreCluster = $this.InventoryUtil.GetDatastoreCluster(
                $this.DatastoreClusterName,
                $this.InventoryUtil.GetInventoryItemParent(
                    $this.DatastoreClusterLocation,
                    $datacenter,
                    $datacenterDatastoreFolderName
                )
            )

            $datastores = $this.GetDatastores($datacenter)
            $datastoresToAddToDatastoreCluster = $this.GetDatastoresToAddToDatastoreCluster($datastoreCluster, $datastores)

            $this.AddDatastoresToDatastoreCluster($datastoreCluster, $datastoresToAddToDatastoreCluster)
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.SetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [bool] Test() {
        try {
            Write-VerboseLog -Message $this.TestMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()

            $this.InitInventoryUtil()
            $datacenter = $this.InventoryUtil.GetDatacenter($this.DatacenterName, $this.DatacenterLocation)
            $datacenterDatastoreFolderName = [FolderType]::Datastore.ToString() + 'Folder'
            $datastoreCluster = $this.InventoryUtil.GetDatastoreCluster(
                $this.DatastoreClusterName,
                $this.InventoryUtil.GetInventoryItemParent(
                    $this.DatastoreClusterLocation,
                    $datacenter,
                    $datacenterDatastoreFolderName
                )
            )

            $datastores = $this.GetDatastores($datacenter)
            $datastoresToAddToDatastoreCluster = $this.GetDatastoresToAddToDatastoreCluster($datastoreCluster, $datastores)
            $result = !($datastoresToAddToDatastoreCluster.Length -gt 0)

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [DatastoreClusterAddDatastore] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [DatastoreClusterAddDatastore]::new()

            $this.ConnectVIServer()

            $this.InitInventoryUtil()
            $datacenter = $this.InventoryUtil.GetDatacenter($this.DatacenterName, $this.DatacenterLocation)
            $datacenterDatastoreFolderName = [FolderType]::Datastore.ToString() + 'Folder'
            $datastoreCluster = $this.InventoryUtil.GetDatastoreCluster(
                $this.DatastoreClusterName,
                $this.InventoryUtil.GetInventoryItemParent(
                    $this.DatastoreClusterLocation,
                    $datacenter,
                    $datacenterDatastoreFolderName
                )
            )

            $datastores = $this.GetDatastoresInDatastoreCluster($datastoreCluster)

            $result.Server = $this.Server
            $result.DatacenterName = $datacenter.Name
            $result.DatacenterLocation = $this.DatacenterLocation
            $result.DatastoreClusterName = $datastoreCluster.Name
            $result.DatastoreClusterLocation = $this.DatastoreClusterLocation
            $result.DatastoreNames = $datastores | Select-Object -ExpandProperty Name

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Initializes an instance of the 'InventoryUtil' class.
    #>
    [void] InitInventoryUtil() {
        if ($null -eq $this.InventoryUtil) {
            $this.InventoryUtil = [InventoryUtil]::new($this.Connection, [Ensure]::Present)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Datastores with the specified names located in the specified Datacenter.
    #>
    [array] GetDatastores($datacenter) {
        $result = @()
        if ($this.DatastoreNames.Length -gt 0) {
            $getDatastoreParams = @{
                Server = $this.Connection
                Name = $this.DatastoreNames
                Location = $datacenter
                ErrorAction = 'SilentlyContinue'
                Verbose = $false
            }

            $result = Get-Datastore @getDatastoreParams
        }

        if ($this.DatastoreNames.Length -gt $result.Length) {
            $notFoundDatastoreNames = $this.DatastoreNames | Where-Object -FilterScript { $result.Name -NotContains $_ }
            foreach ($notFoundDatastoreName in $notFoundDatastoreNames) {
                Write-WarningLog -Message $this.CouldNotFindDatastoreMessage -Arguments @($notFoundDatastoreName, $datacenter.Name)
            }
        }

        return $result
    }

    <#
    .DESCRIPTION

    Retrieves the Datastores located in the specified Datastore Cluster.
    #>
    [array] GetDatastoresInDatastoreCluster($datastoreCluster) {
        $getDatastoreParams = @{
            Server = $this.Connection
            Location = $datastoreCluster
            ErrorAction = 'SilentlyContinue'
            Verbose = $false
        }

        return Get-Datastore @getDatastoreParams
    }

    <#
    .DESCRIPTION

    Retrieves only the Datastores that are still not added to the specified
    Datastore Cluster.
    #>
    [array] GetDatastoresToAddToDatastoreCluster($datastoreCluster, $datastores) {
        $whereObjectParams = @{
            FilterScript = {
                $_.ParentFolderId -ne $datastoreCluster.Id
            }
        }

        return $datastores | Where-Object @whereObjectParams
    }

    <#
    .DESCRIPTION

    Adds the specified Datastores to the Datastore Cluster.
    #>
    [void] AddDatastoresToDatastoreCluster($datastoreCluster, $datastoresToAddToDatastoreCluster) {
        $moveDatastoreParams = @{
            Server = $this.Connection
            Datastore = $datastoresToAddToDatastoreCluster
            Destination = $datastoreCluster
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        try {
            Write-VerboseLog -Message $this.AddDatastoresToDatastoreClusterMessage -Arguments @(
                ($datastoresToAddToDatastoreCluster.Name -Join ', '),
                $datastoreCluster.Name
            )
            Move-Datastore @moveDatastoreParams
        }
        catch {
            throw (
                $this.CouldNotAddDatastoresToDatastoreClusterMessage -f @(
                    ($datastoresToAddToDatastoreCluster.Name -Join ', '),
                    $datastoreCluster.Name,
                    $_.Exception.Message
                )
            )
        }
    }
}
