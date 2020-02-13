<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-DatacenterInventoryBaseDSCProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $datacenterInventoryBaseDSCProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        Name = $script:constants.InventoryItemName
        Ensure = 'Present'
        DatacenterName = $script:constants.DatacenterName
    }

    $datacenterInventoryBaseDSCProperties
}

function New-MocksWhenEmptyDatacenterLocationIsPassedAndTheDatacenterDoesNotExist {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $datacenterInventoryBaseDSCProperties = New-DatacenterInventoryBaseDSCProperties
    $datacenterInventoryBaseDSCProperties.DatacenterLocation = [string]::Empty

    $viServerMock = $script:viServer
    $rootFolderViewBaseObjectMock = $script:rootFolderViewBaseObject
    $inventoryRootFolderMock = $script:inventoryRootFolder

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $rootFolderViewBaseObjectMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $inventoryRootFolderMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-Datacenter -MockWith { return $null }.GetNewClosure() -Verifiable

    $datacenterInventoryBaseDSCProperties
}

function New-MocksWhenEmptyDatacenterLocationIsPassedAndTheDatacenterExists {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $datacenterInventoryBaseDSCProperties = New-DatacenterInventoryBaseDSCProperties
    $datacenterInventoryBaseDSCProperties.DatacenterLocation = [string]::Empty

    $viServerMock = $script:viServer
    $rootFolderViewBaseObjectMock = $script:rootFolderViewBaseObject
    $inventoryRootFolderMock = $script:inventoryRootFolder
    $datacenterWithInventoryRootFolderAsParentMock = $script:datacenterWithInventoryRootFolderAsParent

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $rootFolderViewBaseObjectMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $inventoryRootFolderMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-Datacenter -MockWith { return $datacenterWithInventoryRootFolderAsParentMock }.GetNewClosure() -Verifiable

    $datacenterInventoryBaseDSCProperties
}

function New-MocksWhenDatacenterLocationConsistsOfOnlyOneFolderAndTheFolderDoesNotExist {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $datacenterInventoryBaseDSCProperties = New-DatacenterInventoryBaseDSCProperties
    $datacenterInventoryBaseDSCProperties.DatacenterLocation = "$($script:constants.DatacenterLocationItemOne)"

    $viServerMock = $script:viServer
    $rootFolderViewBaseObjectMock = $script:rootFolderViewBaseObject
    $inventoryRootFolderMock = $script:inventoryRootFolder

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $rootFolderViewBaseObjectMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $inventoryRootFolderMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-Folder -MockWith { return $null }.GetNewClosure() -Verifiable

    $datacenterInventoryBaseDSCProperties
}

function New-MocksWhenDatacenterLocationConsistsOfOnlyOneFolderTheFolderExistsAndTheDatacenterDoesNotExist {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $datacenterInventoryBaseDSCProperties = New-DatacenterInventoryBaseDSCProperties
    $datacenterInventoryBaseDSCProperties.DatacenterLocation = "$($script:constants.DatacenterLocationItemOne)"

    $viServerMock = $script:viServer
    $rootFolderViewBaseObjectMock = $script:rootFolderViewBaseObject
    $inventoryRootFolderMock = $script:inventoryRootFolder
    $locationDatacenterLocationItemOneMock = $script:locationDatacenterLocationItemOne

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $rootFolderViewBaseObjectMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $inventoryRootFolderMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-Folder -MockWith { return $locationDatacenterLocationItemOneMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-Datacenter -MockWith { return $null }.GetNewClosure() -Verifiable

    $datacenterInventoryBaseDSCProperties
}

function New-MocksWhenDatacenterLocationConsistsOfOnlyOneFolderTheFolderExistsAndTheDatacenterExists {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $datacenterInventoryBaseDSCProperties = New-DatacenterInventoryBaseDSCProperties
    $datacenterInventoryBaseDSCProperties.DatacenterLocation = "$($script:constants.DatacenterLocationItemOne)"

    $viServerMock = $script:viServer
    $rootFolderViewBaseObjectMock = $script:rootFolderViewBaseObject
    $inventoryRootFolderMock = $script:inventoryRootFolder
    $locationDatacenterLocationItemOneMock = $script:locationDatacenterLocationItemOne
    $datacenterWithDatacenterLocationItemOneAsParentMock = $script:datacenterWithDatacenterLocationItemOneAsParent

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $rootFolderViewBaseObjectMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $inventoryRootFolderMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-Folder -MockWith { return $locationDatacenterLocationItemOneMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-Datacenter -MockWith { return $datacenterWithDatacenterLocationItemOneAsParentMock }.GetNewClosure() -Verifiable

    $datacenterInventoryBaseDSCProperties
}

function New-MocksWhenDatacenterLocationConsistsOfTwoInventoryItemsAndOneOfThemIsADatacenter {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $datacenterInventoryBaseDSCProperties = New-DatacenterInventoryBaseDSCProperties
    $datacenterInventoryBaseDSCProperties.DatacenterLocation = "$($script:constants.DatacenterName)/$($script:constants.DatacenterLocationItemTwo)"

    $viServerMock = $script:viServer
    $rootFolderViewBaseObjectMock = $script:rootFolderViewBaseObject
    $inventoryRootFolderMock = $script:inventoryRootFolder
    $datacenterChildEntityMock = $script:datacenterChildEntity

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $rootFolderViewBaseObjectMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $inventoryRootFolderMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $datacenterChildEntityMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and (($Id | ConvertTo-Json) -eq ($script:inventoryRootFolder.ExtensionData.ChildEntity | ConvertTo-Json)) } -Verifiable

    $datacenterInventoryBaseDSCProperties
}

function New-MocksWhenDatacenterLocationConsistsOfTwoFoldersAndTheLocationIsNotValid {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $datacenterInventoryBaseDSCProperties = New-DatacenterInventoryBaseDSCProperties
    $datacenterInventoryBaseDSCProperties.DatacenterLocation = "$($script:constants.DatacenterLocationItemThree)/$($script:constants.DatacenterLocationItemTwo)"

    $viServerMock = $script:viServer
    $rootFolderViewBaseObjectMock = $script:rootFolderViewBaseObject
    $inventoryRootFolderMock = $script:inventoryRootFolder
    $datacenterLocationItemOneMock = $script:datacenterLocationItemOne

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $rootFolderViewBaseObjectMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $inventoryRootFolderMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $datacenterLocationItemOneMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and (($Id | ConvertTo-Json) -eq ($script:inventoryRootFolder.ExtensionData.ChildEntity | ConvertTo-Json)) } -Verifiable

    $datacenterInventoryBaseDSCProperties
}

function New-MocksWhenDatacenterLocationConsistsOfTwoFoldersTheLocationIsValidAndTheDatacenterDoesNotExist {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $datacenterInventoryBaseDSCProperties = New-DatacenterInventoryBaseDSCProperties
    $datacenterInventoryBaseDSCProperties.DatacenterLocation = "$($script:constants.DatacenterLocationItemOne)/$($script:constants.DatacenterLocationItemTwo)"

    $viServerMock = $script:viServer
    $rootFolderViewBaseObjectMock = $script:rootFolderViewBaseObject
    $inventoryRootFolderMock = $script:inventoryRootFolder
    $datacenterLocationItemOneMock = $script:datacenterLocationItemOne
    $datacenterLocationItemTwoMock = $script:datacenterLocationItemTwo
    $datacenterLocationItemThreeMock = $script:datacenterLocationItemThree
    $locationDatacenterLocationItemTwoMock = $script:locationDatacenterLocationItemTwo

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $rootFolderViewBaseObjectMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:viServer.ExtensionData.Content.RootFolder } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $inventoryRootFolderMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:rootFolderViewBaseObject.MoRef } -Verifiable
    Mock -CommandName Get-View -MockWith { return $datacenterLocationItemOneMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and (($Id | ConvertTo-Json) -eq ($script:inventoryRootFolder.ExtensionData.ChildEntity | ConvertTo-Json)) } -Verifiable
    Mock -CommandName Get-View -MockWith { return $datacenterLocationItemTwoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and (($Id | ConvertTo-Json) -eq ($script:datacenterLocationItemOne.ChildEntity | ConvertTo-Json)) } -Verifiable
    Mock -CommandName Get-View -MockWith { return $datacenterLocationItemThreeMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and (($Id | ConvertTo-Json) -eq ($script:datacenterLocationItemTwo.ChildEntity | ConvertTo-Json)) } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $locationDatacenterLocationItemTwoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:datacenterLocationItemTwo.MoRef } -Verifiable
    Mock -CommandName Get-Datacenter -MockWith { return $null }.GetNewClosure() -Verifiable

    $datacenterInventoryBaseDSCProperties
}

function New-MocksWhenDatacenterLocationConsistsOfTwoFoldersTheLocationIsValidAndTheDatacenterExists {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $datacenterInventoryBaseDSCProperties = New-DatacenterInventoryBaseDSCProperties
    $datacenterInventoryBaseDSCProperties.DatacenterLocation = "$($script:constants.DatacenterLocationItemOne)/$($script:constants.DatacenterLocationItemTwo)"

    $viServerMock = $script:viServer
    $rootFolderViewBaseObjectMock = $script:rootFolderViewBaseObject
    $inventoryRootFolderMock = $script:inventoryRootFolder
    $datacenterLocationItemOneMock = $script:datacenterLocationItemOne
    $datacenterLocationItemTwoMock = $script:datacenterLocationItemTwo
    $datacenterLocationItemThreeMock = $script:datacenterLocationItemThree
    $locationDatacenterLocationItemTwoMock = $script:locationDatacenterLocationItemTwo
    $datacenterWithDatacenterLocationItemTwoAsParentMock = $script:datacenterWithDatacenterLocationItemTwoAsParent

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $rootFolderViewBaseObjectMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:viServer.ExtensionData.Content.RootFolder } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $inventoryRootFolderMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:rootFolderViewBaseObject.MoRef } -Verifiable
    Mock -CommandName Get-View -MockWith { return $datacenterLocationItemOneMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and (($Id | ConvertTo-Json) -eq ($script:inventoryRootFolder.ExtensionData.ChildEntity | ConvertTo-Json)) } -Verifiable
    Mock -CommandName Get-View -MockWith { return $datacenterLocationItemTwoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and (($Id | ConvertTo-Json) -eq ($script:datacenterLocationItemOne.ChildEntity | ConvertTo-Json)) } -Verifiable
    Mock -CommandName Get-View -MockWith { return $datacenterLocationItemThreeMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and (($Id | ConvertTo-Json) -eq ($script:datacenterLocationItemTwo.ChildEntity | ConvertTo-Json)) } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $locationDatacenterLocationItemTwoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:datacenterLocationItemTwo.MoRef } -Verifiable
    Mock -CommandName Get-Datacenter -MockWith { return $datacenterWithDatacenterLocationItemTwoAsParentMock }.GetNewClosure() -Verifiable

    $datacenterInventoryBaseDSCProperties
}

function New-MocksWhenEmptyLocationIsPassed {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $datacenterInventoryBaseDSCProperties = New-DatacenterInventoryBaseDSCProperties
    $datacenterInventoryBaseDSCProperties.DatacenterLocation = "$($script:constants.DatacenterLocationItemOne)"
    $datacenterInventoryBaseDSCProperties.Location = [string]::Empty

    $viServerMock = $script:viServer
    $rootFolderViewBaseObjectMock = $script:rootFolderViewBaseObject
    $inventoryRootFolderMock = $script:inventoryRootFolder
    $locationDatacenterLocationItemOneMock = $script:locationDatacenterLocationItemOne
    $datacenterWithDatacenterLocationItemOneAsParentMock = $script:datacenterWithDatacenterLocationItemOneAsParent
    $datacenterHostFolderViewBaseObjectMock = $script:datacenterHostFolderViewBaseObject
    $datacenterHostFolderMock = $script:datacenterHostFolder

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $rootFolderViewBaseObjectMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:viServer.ExtensionData.Content.RootFolder } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $inventoryRootFolderMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:rootFolderViewBaseObject.MoRef } -Verifiable
    Mock -CommandName Get-Folder -MockWith { return $locationDatacenterLocationItemOneMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-Datacenter -MockWith { return $datacenterWithDatacenterLocationItemOneAsParentMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $datacenterHostFolderViewBaseObjectMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:datacenterWithDatacenterLocationItemOneAsParent.ExtensionData.HostFolder } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $datacenterHostFolderMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:datacenterHostFolderViewBaseObject.MoRef } -Verifiable

    $datacenterInventoryBaseDSCProperties
}

function New-MocksWhenLocationConsistsOfOneInventoryItemAndTheInventoryItemDoesNotExist {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $datacenterInventoryBaseDSCProperties = New-DatacenterInventoryBaseDSCProperties
    $datacenterInventoryBaseDSCProperties.DatacenterLocation = "$($script:constants.DatacenterLocationItemOne)"
    $datacenterInventoryBaseDSCProperties.Location = "$($script:constants.InventoryItemLocationItemOne)"

    $viServerMock = $script:viServer
    $rootFolderViewBaseObjectMock = $script:rootFolderViewBaseObject
    $inventoryRootFolderMock = $script:inventoryRootFolder
    $locationDatacenterLocationItemOneMock = $script:locationDatacenterLocationItemOne
    $datacenterWithDatacenterLocationItemOneAsParentMock = $script:datacenterWithDatacenterLocationItemOneAsParent
    $datacenterHostFolderViewBaseObjectMock = $script:datacenterHostFolderViewBaseObject
    $datacenterHostFolderMock = $script:datacenterHostFolder

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $rootFolderViewBaseObjectMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:viServer.ExtensionData.Content.RootFolder } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $inventoryRootFolderMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:rootFolderViewBaseObject.MoRef } -Verifiable
    Mock -CommandName Get-Folder -MockWith { return $locationDatacenterLocationItemOneMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-Datacenter -MockWith { return $datacenterWithDatacenterLocationItemOneAsParentMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $datacenterHostFolderViewBaseObjectMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:datacenterWithDatacenterLocationItemOneAsParent.ExtensionData.HostFolder } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $datacenterHostFolderMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:datacenterHostFolderViewBaseObject.MoRef } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemLocationItemOne -and $Location -eq $script:datacenterHostFolder } -Verifiable

    $datacenterInventoryBaseDSCProperties
}

function New-MocksWhenLocationConsistsOfOneInventoryItemAndTheInventoryItemExists {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $datacenterInventoryBaseDSCProperties = New-DatacenterInventoryBaseDSCProperties
    $datacenterInventoryBaseDSCProperties.DatacenterLocation = "$($script:constants.DatacenterLocationItemOne)"
    $datacenterInventoryBaseDSCProperties.Location = "$($script:constants.InventoryItemLocationItemOne)"

    $viServerMock = $script:viServer
    $rootFolderViewBaseObjectMock = $script:rootFolderViewBaseObject
    $inventoryRootFolderMock = $script:inventoryRootFolder
    $locationDatacenterLocationItemOneMock = $script:locationDatacenterLocationItemOne
    $datacenterWithDatacenterLocationItemOneAsParentMock = $script:datacenterWithDatacenterLocationItemOneAsParent
    $datacenterHostFolderViewBaseObjectMock = $script:datacenterHostFolderViewBaseObject
    $datacenterHostFolderMock = $script:datacenterHostFolder
    $inventoryItemLocationItemOneMock = $script:inventoryItemLocationItemOne

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $rootFolderViewBaseObjectMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:viServer.ExtensionData.Content.RootFolder } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $inventoryRootFolderMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:rootFolderViewBaseObject.MoRef } -Verifiable
    Mock -CommandName Get-Folder -MockWith { return $locationDatacenterLocationItemOneMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-Datacenter -MockWith { return $datacenterWithDatacenterLocationItemOneAsParentMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $datacenterHostFolderViewBaseObjectMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:datacenterWithDatacenterLocationItemOneAsParent.ExtensionData.HostFolder } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $datacenterHostFolderMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:datacenterHostFolderViewBaseObject.MoRef } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $inventoryItemLocationItemOneMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemLocationItemOne -and $Location -eq $script:datacenterHostFolder } -Verifiable

    $datacenterInventoryBaseDSCProperties
}

function New-MocksWhenLocationConsistsOfTwoInventoryItemsAndTheLocationIsNotValid {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $datacenterInventoryBaseDSCProperties = New-DatacenterInventoryBaseDSCProperties
    $datacenterInventoryBaseDSCProperties.DatacenterLocation = "$($script:constants.DatacenterLocationItemOne)"
    $datacenterInventoryBaseDSCProperties.Location = "$($script:constants.InventoryItemLocationItemOne)/$($script:constants.InventoryItemLocationItemTwo)"

    $viServerMock = $script:viServer
    $rootFolderViewBaseObjectMock = $script:rootFolderViewBaseObject
    $inventoryRootFolderMock = $script:inventoryRootFolder
    $locationDatacenterLocationItemOneMock = $script:locationDatacenterLocationItemOne
    $datacenterWithDatacenterLocationItemOneAsParentMock = $script:datacenterWithDatacenterLocationItemOneAsParent
    $datacenterHostFolderViewBaseObjectMock = $script:datacenterHostFolderViewBaseObject
    $datacenterHostFolderMock = $script:datacenterHostFolder
    $foundLocationsMock = $script:foundLocations
    $inventoryItemLocationViewBaseObjectMock = $script:inventoryItemLocationViewBaseObject
    $inventoryItemLocationWithDatacenterHostFolderAsParentMock = $script:inventoryItemLocationWithDatacenterHostFolderAsParent

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $rootFolderViewBaseObjectMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:viServer.ExtensionData.Content.RootFolder } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $inventoryRootFolderMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:rootFolderViewBaseObject.MoRef } -Verifiable
    Mock -CommandName Get-Folder -MockWith { return $locationDatacenterLocationItemOneMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-Datacenter -MockWith { return $datacenterWithDatacenterLocationItemOneAsParentMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $datacenterHostFolderViewBaseObjectMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:datacenterWithDatacenterLocationItemOneAsParent.ExtensionData.HostFolder } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $datacenterHostFolderMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:datacenterHostFolderViewBaseObject.MoRef } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $foundLocationsMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemLocationItemTwo -and $Location -eq $script:datacenterHostFolder } -Verifiable
    Mock -CommandName Get-View -MockWith { return $inventoryItemLocationViewBaseObjectMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:constants.InventoryItemLocationItemTwoId } -Verifiable
    Mock -CommandName Get-View -MockWith { return $inventoryItemLocationWithDatacenterHostFolderAsParentMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:inventoryItemLocationViewBaseObject.Parent } -Verifiable

    $datacenterInventoryBaseDSCProperties
}

function New-MocksWhenLocationConsistsOfTwoInventoryItemsAndTheLocationIsValid {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $datacenterInventoryBaseDSCProperties = New-DatacenterInventoryBaseDSCProperties
    $datacenterInventoryBaseDSCProperties.DatacenterLocation = "$($script:constants.DatacenterLocationItemOne)"
    $datacenterInventoryBaseDSCProperties.Location = "$($script:constants.InventoryItemLocationItemOne)/$($script:constants.InventoryItemLocationItemTwo)"

    $viServerMock = $script:viServer
    $rootFolderViewBaseObjectMock = $script:rootFolderViewBaseObject
    $inventoryRootFolderMock = $script:inventoryRootFolder
    $locationDatacenterLocationItemOneMock = $script:locationDatacenterLocationItemOne
    $datacenterWithDatacenterLocationItemOneAsParentMock = $script:datacenterWithDatacenterLocationItemOneAsParent
    $datacenterHostFolderViewBaseObjectMock = $script:datacenterHostFolderViewBaseObject
    $datacenterHostFolderMock = $script:datacenterHostFolder
    $foundLocationsMock = $script:foundLocations
    $inventoryItemLocationViewBaseObjectMock = $script:inventoryItemLocationViewBaseObject
    $inventoryItemLocationWithInventoryItemLocationItemOneAsParentMock = $script:inventoryItemLocationWithInventoryItemLocationItemOneAsParent

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $rootFolderViewBaseObjectMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:viServer.ExtensionData.Content.RootFolder } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $inventoryRootFolderMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:rootFolderViewBaseObject.MoRef } -Verifiable
    Mock -CommandName Get-Folder -MockWith { return $locationDatacenterLocationItemOneMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-Datacenter -MockWith { return $datacenterWithDatacenterLocationItemOneAsParentMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $datacenterHostFolderViewBaseObjectMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:datacenterWithDatacenterLocationItemOneAsParent.ExtensionData.HostFolder } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $datacenterHostFolderMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:datacenterHostFolderViewBaseObject.MoRef } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $foundLocationsMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemLocationItemTwo -and $Location -eq $script:datacenterHostFolder } -Verifiable
    Mock -CommandName Get-View -MockWith { return $inventoryItemLocationViewBaseObjectMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:constants.InventoryItemLocationItemTwoId } -Verifiable
    Mock -CommandName Get-View -MockWith { return $inventoryItemLocationWithInventoryItemLocationItemOneAsParentMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:inventoryItemLocationViewBaseObject.Parent } -Verifiable

    $datacenterInventoryBaseDSCProperties
}

function New-MocksWhenTheInventoryItemDoesNotExistAtTheSpecifiedLocation {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $datacenterInventoryBaseDSCProperties = New-DatacenterInventoryBaseDSCProperties
    $datacenterInventoryBaseDSCProperties.DatacenterLocation = "$($script:constants.DatacenterLocationItemOne)"
    $datacenterInventoryBaseDSCProperties.Location = "$($script:constants.InventoryItemLocationItemOne)/$($script:constants.InventoryItemLocationItemTwo)"

    $viServerMock = $script:viServer
    $rootFolderViewBaseObjectMock = $script:rootFolderViewBaseObject
    $inventoryRootFolderMock = $script:inventoryRootFolder
    $locationDatacenterLocationItemOneMock = $script:locationDatacenterLocationItemOne
    $datacenterWithDatacenterLocationItemOneAsParentMock = $script:datacenterWithDatacenterLocationItemOneAsParent
    $datacenterHostFolderViewBaseObjectMock = $script:datacenterHostFolderViewBaseObject
    $datacenterHostFolderMock = $script:datacenterHostFolder
    $foundLocationsMock = $script:foundLocations
    $inventoryItemLocationViewBaseObjectMock = $script:inventoryItemLocationViewBaseObject
    $inventoryItemLocationWithInventoryItemLocationItemOneAsParentMock = $script:inventoryItemLocationWithInventoryItemLocationItemOneAsParent

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $rootFolderViewBaseObjectMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:viServer.ExtensionData.Content.RootFolder } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $inventoryRootFolderMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:rootFolderViewBaseObject.MoRef } -Verifiable
    Mock -CommandName Get-Folder -MockWith { return $locationDatacenterLocationItemOneMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-Datacenter -MockWith { return $datacenterWithDatacenterLocationItemOneAsParentMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $datacenterHostFolderViewBaseObjectMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:datacenterWithDatacenterLocationItemOneAsParent.ExtensionData.HostFolder } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $datacenterHostFolderMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:datacenterHostFolderViewBaseObject.MoRef } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $foundLocationsMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemLocationItemTwo -and $Location -eq $script:datacenterHostFolder } -Verifiable
    Mock -CommandName Get-View -MockWith { return $inventoryItemLocationViewBaseObjectMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:constants.InventoryItemLocationItemTwoId } -Verifiable
    Mock -CommandName Get-View -MockWith { return $inventoryItemLocationWithInventoryItemLocationItemOneAsParentMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:inventoryItemLocationViewBaseObject.Parent } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:foundLocations[0] } -Verifiable

    $datacenterInventoryBaseDSCProperties
}

function New-MocksWhenTheInventoryItemExistsAtTheSpecifiedLocation {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $datacenterInventoryBaseDSCProperties = New-DatacenterInventoryBaseDSCProperties
    $datacenterInventoryBaseDSCProperties.DatacenterLocation = "$($script:constants.DatacenterLocationItemOne)"
    $datacenterInventoryBaseDSCProperties.Location = "$($script:constants.InventoryItemLocationItemOne)/$($script:constants.InventoryItemLocationItemTwo)"

    $viServerMock = $script:viServer
    $rootFolderViewBaseObjectMock = $script:rootFolderViewBaseObject
    $inventoryRootFolderMock = $script:inventoryRootFolder
    $locationDatacenterLocationItemOneMock = $script:locationDatacenterLocationItemOne
    $datacenterWithDatacenterLocationItemOneAsParentMock = $script:datacenterWithDatacenterLocationItemOneAsParent
    $datacenterHostFolderViewBaseObjectMock = $script:datacenterHostFolderViewBaseObject
    $datacenterHostFolderMock = $script:datacenterHostFolder
    $foundLocationsMock = $script:foundLocations
    $inventoryItemLocationViewBaseObjectMock = $script:inventoryItemLocationViewBaseObject
    $inventoryItemLocationWithInventoryItemLocationItemOneAsParentMock = $script:inventoryItemLocationWithInventoryItemLocationItemOneAsParent
    $inventoryItemWithInventoryItemLocationItemTwoAsParentMock = $script:inventoryItemWithInventoryItemLocationItemTwoAsParent

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $rootFolderViewBaseObjectMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:viServer.ExtensionData.Content.RootFolder } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $inventoryRootFolderMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:rootFolderViewBaseObject.MoRef } -Verifiable
    Mock -CommandName Get-Folder -MockWith { return $locationDatacenterLocationItemOneMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-Datacenter -MockWith { return $datacenterWithDatacenterLocationItemOneAsParentMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $datacenterHostFolderViewBaseObjectMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:datacenterWithDatacenterLocationItemOneAsParent.ExtensionData.HostFolder } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $datacenterHostFolderMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:datacenterHostFolderViewBaseObject.MoRef } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $foundLocationsMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemLocationItemTwo -and $Location -eq $script:datacenterHostFolder } -Verifiable
    Mock -CommandName Get-View -MockWith { return $inventoryItemLocationViewBaseObjectMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:constants.InventoryItemLocationItemTwoId } -Verifiable
    Mock -CommandName Get-View -MockWith { return $inventoryItemLocationWithInventoryItemLocationItemOneAsParentMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:inventoryItemLocationViewBaseObject.Parent } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $inventoryItemWithInventoryItemLocationItemTwoAsParentMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:foundLocations[0] } -Verifiable

    $datacenterInventoryBaseDSCProperties
}
