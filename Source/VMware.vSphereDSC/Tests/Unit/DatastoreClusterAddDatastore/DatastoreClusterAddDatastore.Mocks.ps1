<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-DatastoreClusterAddDatastoreDscResourceProperties {
    [OutputType([System.Collections.Hashtable])]

    $DatastoreClusterAddDatastoreDscResourceProperties = @{
        Server = $script:Constants.VIServer
        Credential = $script:Credential
        DatacenterName = $script:Constants.DatacenterName
        DatacenterLocation = [string]::Empty
        DatastoreClusterName = $script:Constants.DatastoreClusterName
        DatastoreClusterLocation = [string]::Empty
    }

    $DatastoreClusterAddDatastoreDscResourceProperties
}

function New-MocksForDatastoreClusterAddDatastoreDscResource {
    $viServerMock = $script:VIServer
    $inventoryRootFolderMock = $script:InventoryRootFolder
    $datacenterMock = $script:Datacenter
    $datacenterDatastoreFolderMock = $script:DatacenterDatastoreFolder
    $datastoreClusterMock = $script:DatastoreCluster

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Disconnect-VIServer -MockWith { return $null }.GetNewClosure() -Verifiable

    $getInventoryMockParamsForInventoryRootFolder = @{
        CommandName = 'Get-Inventory'
        MockWith = { return $inventoryRootFolderMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $Id -eq $script:VIServer.ExtensionData.Content.RootFolder
        }
        Verifiable = $true
    }
    Mock @getInventoryMockParamsForInventoryRootFolder

    $getDatacenterMockParams = @{
        CommandName = 'Get-Datacenter'
        MockWith = { return $datacenterMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $Name -eq $script:Constants.DatacenterName -and
            $Location -eq $script:InventoryRootFolder
        }
        Verifiable = $true
    }
    Mock @getDatacenterMockParams

    $getInventoryMockParamsForDatacenterDatastoreFolder = @{
        CommandName = 'Get-Inventory'
        MockWith = { return $datacenterDatastoreFolderMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $Id -eq $script:Datacenter.ExtensionData.DatastoreFolder
        }
        Verifiable = $true
    }
    Mock @getInventoryMockParamsForDatacenterDatastoreFolder

    $getDatastoreClusterMockParams = @{
        CommandName = 'Get-DatastoreCluster'
        MockWith = { return $datastoreClusterMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $Name -eq $script:Constants.DatastoreClusterName -and
            $Location -eq $script:DatacenterDatastoreFolder
        }
        Verifiable = $true
    }
    Mock @getDatastoreClusterMockParams
}

function New-MocksWhenErrorOccursWhileAddingDatastoresToDatastoreCluster {
    [OutputType([System.Collections.Hashtable])]

    $DatastoreClusterAddDatastoreDscResourceProperties = New-DatastoreClusterAddDatastoreDscResourceProperties
    $DatastoreClusterAddDatastoreDscResourceProperties.DatastoreNames = $script:Constants.DatastoreNames

    $datastoresMock = $script:Datastores

    $getDatastoreMockParams = @{
        CommandName = 'Get-Datastore'
        MockWith = { return $datastoresMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            [System.Linq.Enumerable]::SequenceEqual($Name, [string[]] $script:Constants.DatastoreNames) -and
            $Location -eq $script:Datacenter
        }
        Verifiable = $true
    }
    Mock @getDatastoreMockParams

    Mock -CommandName 'Move-Datastore' -MockWith { throw }.GetNewClosure() -Verifiable

    $DatastoreClusterAddDatastoreDscResourceProperties
}

function New-MocksWhenNoErrorOccursWhileAddingDatastoresToDatastoreCluster {
    [OutputType([System.Collections.Hashtable])]

    $DatastoreClusterAddDatastoreDscResourceProperties = New-DatastoreClusterAddDatastoreDscResourceProperties
    $DatastoreClusterAddDatastoreDscResourceProperties.DatastoreNames = $script:Constants.DatastoreNames

    $datastoresMock = $script:Datastores

    $getDatastoreMockParams = @{
        CommandName = 'Get-Datastore'
        MockWith = { return $datastoresMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            [System.Linq.Enumerable]::SequenceEqual($Name, [string[]] $script:Constants.DatastoreNames) -and
            $Location -eq $script:Datacenter
        }
        Verifiable = $true
    }
    Mock @getDatastoreMockParams

    Mock -CommandName 'Move-Datastore' -MockWith { return $null }.GetNewClosure() -Verifiable

    $DatastoreClusterAddDatastoreDscResourceProperties
}

function New-MocksWhenDatastoresShouldBeAddedToDatastoreCluster {
    [OutputType([System.Collections.Hashtable])]

    $DatastoreClusterAddDatastoreDscResourceProperties = New-DatastoreClusterAddDatastoreDscResourceProperties
    $DatastoreClusterAddDatastoreDscResourceProperties.DatastoreNames = $script:Constants.DatastoreNames

    $datastoresMock = $script:Datastores

    $getDatastoreMockParams = @{
        CommandName = 'Get-Datastore'
        MockWith = { return $datastoresMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            [System.Linq.Enumerable]::SequenceEqual($Name, [string[]] $script:Constants.DatastoreNames) -and
            $Location -eq $script:Datacenter
        }
        Verifiable = $true
    }
    Mock @getDatastoreMockParams

    $DatastoreClusterAddDatastoreDscResourceProperties
}

function New-MocksWhenDatastoresShouldNotBeAddedToDatastoreCluster {
    [OutputType([System.Collections.Hashtable])]

    $DatastoreClusterAddDatastoreDscResourceProperties = New-DatastoreClusterAddDatastoreDscResourceProperties
    $DatastoreClusterAddDatastoreDscResourceProperties.DatastoreNames = @($script:Constants.DatastoreThreeName)

    $datastoresMock = @($script:DatastoreThree)

    $getDatastoreMockParams = @{
        CommandName = 'Get-Datastore'
        MockWith = { return $datastoresMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            [System.Linq.Enumerable]::SequenceEqual($Name, [string[]] $script:Constants.DatastoreThreeName) -and
            $Location -eq $script:Datacenter
        }
        Verifiable = $true
    }
    Mock @getDatastoreMockParams

    $DatastoreClusterAddDatastoreDscResourceProperties
}

function New-MocksInGet {
    [OutputType([System.Collections.Hashtable])]

    $DatastoreClusterAddDatastoreDscResourceProperties = New-DatastoreClusterAddDatastoreDscResourceProperties

    $datastoresMock = $script:Datastores

    $getDatastoreMockParams = @{
        CommandName = 'Get-Datastore'
        MockWith = { return $datastoresMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $Location -eq $script:DatastoreCluster
        }
        Verifiable = $true
    }
    Mock @getDatastoreMockParams

    $DatastoreClusterAddDatastoreDscResourceProperties
}
