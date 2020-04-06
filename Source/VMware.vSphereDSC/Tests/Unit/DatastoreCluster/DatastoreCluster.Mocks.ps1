<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-DatastoreClusterDscResourceProperties {
    [OutputType([System.Collections.Hashtable])]

    $datastoreClusterDscResourceProperties = @{
        Server = $script:Constants.VIServer
        Credential = $script:Credential
        Name = $script:Constants.DatastoreClusterName
        Location = [string]::Empty
        DatacenterName = $script:Constants.DatacenterName
        DatacenterLocation = [string]::Empty
    }

    $datastoreClusterDscResourceProperties
}

function New-MocksForDatastoreClusterDscResource {
    $viServerMock = $script:VIServer
    $rootFolderViewBaseObjectMock = $script:RootFolderViewBaseObject
    $inventoryRootFolderMock = $script:InventoryRootFolder
    $datacenterMock = $script:Datacenter
    $datacenterDatastoreFolderViewBaseObjectMock = $script:DatacenterDatastoreFolderViewBaseObject
    $datacenterDatastoreFolderMock = $script:DatacenterDatastoreFolder

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-Datacenter -MockWith { return $datacenterMock }.GetNewClosure() -Verifiable
    Mock -CommandName Disconnect-VIServer -MockWith { return $null }.GetNewClosure() -Verifiable

    <#
        The Get-View and Get-Inventory cmdlets should be mocked with Parameter filter
        because they are executed twice in the DatacenterInventoryBaseDSC class.
    #>
    $getViewMockParamsForRootFolderViewBaseObject = @{
        CommandName = 'Get-View'
        MockWith = { return $rootFolderViewBaseObjectMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $Id -eq $script:VIServer.ExtensionData.Content.RootFolder
        }
        Verifiable = $true
    }
    Mock @getViewMockParamsForRootFolderViewBaseObject

    $getInventoryMockParamsForInventoryRootFolder = @{
        CommandName = 'Get-Inventory'
        MockWith = { return $inventoryRootFolderMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $Id -eq $script:RootFolderViewBaseObject.MoRef
        }
        Verifiable = $true
    }
    Mock @getInventoryMockParamsForInventoryRootFolder

    $getViewMockParamsForDatacenterDatastoreFolderViewBaseObject = @{
        CommandName = 'Get-View'
        MockWith = { return $datacenterDatastoreFolderViewBaseObjectMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $Id -eq $script:Datacenter.ExtensionData.DatastoreFolder
        }
        Verifiable = $true
    }
    Mock @getViewMockParamsForDatacenterDatastoreFolderViewBaseObject

    $getInventoryMockParamsForDatacenterDatastoreFolder = @{
        CommandName = 'Get-Inventory'
        MockWith = { return $datacenterDatastoreFolderMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $Id -eq $script:DatacenterDatastoreFolderViewBaseObject.MoRef
        }
        Verifiable = $true
    }
    Mock @getInventoryMockParamsForDatacenterDatastoreFolder
}

function New-MocksWhenEnsureIsPresentTheDatastoreClusterDoesNotExistAndErrorOccursWhileCreatingTheDatastoreCluster {
    [OutputType([System.Collections.Hashtable])]

    $datastoreClusterDscResourceProperties = New-DatastoreClusterDscResourceProperties
    $datastoreClusterDscResourceProperties.Ensure = 'Present'

    $getDatastoreClusterMockParams = @{
        CommandName = 'Get-DatastoreCluster'
        MockWith = { return $null }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $Name -eq $script:Constants.DatastoreClusterName -and
            $Location -eq $script:DatacenterDatastoreFolder
        }
        Verifiable = $true
    }
    Mock @getDatastoreClusterMockParams

    Mock -CommandName 'New-DatastoreCluster' -MockWith { throw }.GetNewClosure() -Verifiable

    $datastoreClusterDscResourceProperties
}

function New-MocksWhenEnsureIsPresentTheDatastoreClusterDoesNotExistAndNoErrorOccursWhileCreatingTheDatastoreCluster {
    [OutputType([System.Collections.Hashtable])]

    $datastoreClusterDscResourceProperties = New-DatastoreClusterDscResourceProperties
    $datastoreClusterDscResourceProperties.Ensure = 'Present'

    $getDatastoreClusterMockParams = @{
        CommandName = 'Get-DatastoreCluster'
        MockWith = { return $null }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $Name -eq $script:Constants.DatastoreClusterName -and
            $Location -eq $script:DatacenterDatastoreFolder
        }
        Verifiable = $true
    }
    Mock @getDatastoreClusterMockParams

    Mock -CommandName 'New-DatastoreCluster' -MockWith { return $null }.GetNewClosure() -Verifiable

    $datastoreClusterDscResourceProperties
}

function New-MocksWhenEnsureIsPresentTheDatastoreClusterExistsAndErrorOccursWhileModifyingTheDatastoreClusterConfiguration {
    [OutputType([System.Collections.Hashtable])]

    $datastoreClusterDscResourceProperties = New-DatastoreClusterDscResourceProperties

    $datastoreClusterDscResourceProperties.Ensure = 'Present'
    $datastoreClusterDscResourceProperties.IOLatencyThresholdMillisecond = $script:Constants.IOLatencyThresholdMillisecond
    $datastoreClusterDscResourceProperties.IOLoadBalanceEnabled = !$script:Constants.IOLoadBalanceEnabled
    $datastoreClusterDscResourceProperties.SdrsAutomationLevel = $script:Constants.SdrsAutomationLevel
    $datastoreClusterDscResourceProperties.SpaceUtilizationThresholdPercent = $script:Constants.SpaceUtilizationThresholdPercent

    $datastoreClusterMock = $script:DatastoreCluster

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

    Mock -CommandName 'Set-DatastoreCluster' -MockWith { throw }.GetNewClosure() -Verifiable

    $datastoreClusterDscResourceProperties
}

function New-MocksWhenEnsureIsPresentTheDatastoreClusterDoesNotExistAndDatastoreClusterSettingsAreSpecified {
    [OutputType([System.Collections.Hashtable])]

    $datastoreClusterDscResourceProperties = New-DatastoreClusterDscResourceProperties

    $datastoreClusterDscResourceProperties.Ensure = 'Present'
    $datastoreClusterDscResourceProperties.IOLatencyThresholdMillisecond = $script:Constants.IOLatencyThresholdMillisecond
    $datastoreClusterDscResourceProperties.IOLoadBalanceEnabled = !$script:Constants.IOLoadBalanceEnabled
    $datastoreClusterDscResourceProperties.SdrsAutomationLevel = $script:Constants.SdrsAutomationLevel
    $datastoreClusterDscResourceProperties.SpaceUtilizationThresholdPercent = $script:Constants.SpaceUtilizationThresholdPercent

    $datastoreClusterMock = $script:DatastoreCluster

    $getDatastoreClusterMockParams = @{
        CommandName = 'Get-DatastoreCluster'
        MockWith = { return $null }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $Name -eq $script:Constants.DatastoreClusterName -and
            $Location -eq $script:DatacenterDatastoreFolder
        }
        Verifiable = $true
    }
    Mock @getDatastoreClusterMockParams

    Mock -CommandName 'New-DatastoreCluster' -MockWith { return $datastoreClusterMock }.GetNewClosure() -Verifiable
    Mock -CommandName 'Set-DatastoreCluster' -MockWith { return $null }.GetNewClosure() -Verifiable

    $datastoreClusterDscResourceProperties
}

function New-MocksInSetWhenEnsureIsAbsentAndTheDatastoreClusterDoesNotExist {
    [OutputType([System.Collections.Hashtable])]

    $datastoreClusterDscResourceProperties = New-DatastoreClusterDscResourceProperties
    $datastoreClusterDscResourceProperties.Ensure = 'Absent'

    $getDatastoreClusterMockParams = @{
        CommandName = 'Get-DatastoreCluster'
        MockWith = { return $null }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $Name -eq $script:Constants.DatastoreClusterName -and
            $Location -eq $script:DatacenterDatastoreFolder
        }
        Verifiable = $true
    }
    Mock @getDatastoreClusterMockParams

    Mock -CommandName 'Remove-DatastoreCluster' -MockWith { return $null }.GetNewClosure()

    $datastoreClusterDscResourceProperties
}

function New-MocksWhenEnsureIsAbsentTheDatastoreClusterExistsAndErrorOccursWhileRemovingTheDatastoreCluster {
    [OutputType([System.Collections.Hashtable])]

    $datastoreClusterDscResourceProperties = New-DatastoreClusterDscResourceProperties
    $datastoreClusterDscResourceProperties.Ensure = 'Absent'

    $datastoreClusterMock = $script:DatastoreCluster

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

    Mock -CommandName 'Remove-DatastoreCluster' -MockWith { throw }.GetNewClosure() -Verifiable

    $datastoreClusterDscResourceProperties
}

function New-MocksInSetWhenEnsureIsAbsentAndTheDatastoreClusterExists {
    [OutputType([System.Collections.Hashtable])]

    $datastoreClusterDscResourceProperties = New-DatastoreClusterDscResourceProperties
    $datastoreClusterDscResourceProperties.Ensure = 'Absent'

    $datastoreClusterMock = $script:DatastoreCluster

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

    Mock -CommandName 'Remove-DatastoreCluster' -MockWith { return $null }.GetNewClosure() -Verifiable

    $datastoreClusterDscResourceProperties
}

function New-MocksWhenEnsureIsPresentTheDatastoreClusterExistsAndTheDatastoreClusterConfigurationShouldNotBeModified {
    [OutputType([System.Collections.Hashtable])]

    $datastoreClusterDscResourceProperties = New-DatastoreClusterDscResourceProperties

    $datastoreClusterDscResourceProperties.Ensure = 'Present'
    $datastoreClusterDscResourceProperties.IOLatencyThresholdMillisecond = $script:Constants.IOLatencyThresholdMillisecond
    $datastoreClusterDscResourceProperties.IOLoadBalanceEnabled = $script:Constants.IOLoadBalanceEnabled
    $datastoreClusterDscResourceProperties.SdrsAutomationLevel = $script:Constants.SdrsAutomationLevel
    $datastoreClusterDscResourceProperties.SpaceUtilizationThresholdPercent = $script:Constants.SpaceUtilizationThresholdPercent

    $datastoreClusterMock = $script:DatastoreCluster

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

    $datastoreClusterDscResourceProperties
}

function New-MocksWhenEnsureIsPresentTheDatastoreClusterExistsAndTheDatastoreClusterConfigurationShouldBeModified {
    [OutputType([System.Collections.Hashtable])]

    $datastoreClusterDscResourceProperties = New-DatastoreClusterDscResourceProperties

    $datastoreClusterDscResourceProperties.Ensure = 'Present'
    $datastoreClusterDscResourceProperties.IOLatencyThresholdMillisecond = $script:Constants.IOLatencyThresholdMillisecond
    $datastoreClusterDscResourceProperties.IOLoadBalanceEnabled = !$script:Constants.IOLoadBalanceEnabled
    $datastoreClusterDscResourceProperties.SdrsAutomationLevel = $script:Constants.SdrsAutomationLevel
    $datastoreClusterDscResourceProperties.SpaceUtilizationThresholdPercent = $script:Constants.SpaceUtilizationThresholdPercent

    $datastoreClusterMock = $script:DatastoreCluster

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

    $datastoreClusterDscResourceProperties
}

function New-MocksWhenEnsureIsPresentAndTheDatastoreClusterDoesNotExist {
    [OutputType([System.Collections.Hashtable])]

    $datastoreClusterDscResourceProperties = New-DatastoreClusterDscResourceProperties

    $datastoreClusterDscResourceProperties.Ensure = 'Present'
    $datastoreClusterDscResourceProperties.IOLatencyThresholdMillisecond = $script:Constants.IOLatencyThresholdMillisecond
    $datastoreClusterDscResourceProperties.IOLoadBalanceEnabled = $script:Constants.IOLoadBalanceEnabled
    $datastoreClusterDscResourceProperties.SdrsAutomationLevel = $script:Constants.SdrsAutomationLevel
    $datastoreClusterDscResourceProperties.SpaceUtilizationThresholdPercent = $script:Constants.SpaceUtilizationThresholdPercent

    $getDatastoreClusterMockParams = @{
        CommandName = 'Get-DatastoreCluster'
        MockWith = { return $null }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $Name -eq $script:Constants.DatastoreClusterName -and
            $Location -eq $script:DatacenterDatastoreFolder
        }
        Verifiable = $true
    }
    Mock @getDatastoreClusterMockParams

    $datastoreClusterDscResourceProperties
}

function New-MocksWhenEnsureIsPresentAndTheDatastoreClusterExists {
    [OutputType([System.Collections.Hashtable])]

    $datastoreClusterDscResourceProperties = New-DatastoreClusterDscResourceProperties
    $datastoreClusterDscResourceProperties.Ensure = 'Present'

    $datastoreClusterMock = $script:DatastoreCluster

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

    $datastoreClusterDscResourceProperties
}

function New-MocksWhenEnsureIsAbsentAndTheDatastoreClusterDoesNotExist {
    [OutputType([System.Collections.Hashtable])]

    $datastoreClusterDscResourceProperties = New-DatastoreClusterDscResourceProperties

    $datastoreClusterDscResourceProperties.Ensure = 'Absent'
    $datastoreClusterDscResourceProperties.IOLatencyThresholdMillisecond = $script:Constants.IOLatencyThresholdMillisecond
    $datastoreClusterDscResourceProperties.IOLoadBalanceEnabled = $script:Constants.IOLoadBalanceEnabled
    $datastoreClusterDscResourceProperties.SdrsAutomationLevel = $script:Constants.SdrsAutomationLevel
    $datastoreClusterDscResourceProperties.SpaceUtilizationThresholdPercent = $script:Constants.SpaceUtilizationThresholdPercent

    $getDatastoreClusterMockParams = @{
        CommandName = 'Get-DatastoreCluster'
        MockWith = { return $null }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $Name -eq $script:Constants.DatastoreClusterName -and
            $Location -eq $script:DatacenterDatastoreFolder
        }
        Verifiable = $true
    }
    Mock @getDatastoreClusterMockParams

    $datastoreClusterDscResourceProperties
}

function New-MocksWhenEnsureIsAbsentAndTheDatastoreClusterExists {
    [OutputType([System.Collections.Hashtable])]

    $datastoreClusterDscResourceProperties = New-DatastoreClusterDscResourceProperties
    $datastoreClusterDscResourceProperties.Ensure = 'Absent'

    $datastoreClusterMock = $script:DatastoreCluster

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

    $datastoreClusterDscResourceProperties
}
