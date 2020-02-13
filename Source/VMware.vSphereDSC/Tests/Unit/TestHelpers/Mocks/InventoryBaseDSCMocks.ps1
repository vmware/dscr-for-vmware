<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-InventoryBaseDSCProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $inventoryBaseDSCProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        Name = $script:constants.InventoryItemName
        Ensure = 'Present'
    }

    $inventoryBaseDSCProperties
}

function New-MocksWhenEmptyLocationIsPassed {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $inventoryBaseDSCProperties = New-InventoryBaseDSCProperties
    $inventoryBaseDSCProperties.Location = [string]::Empty

    $viServerMock = $script:viServer
    $rootFolderViewBaseObjectMock = $script:rootFolderViewBaseObject
    $inventoryRootFolderMock = $script:inventoryRootFolder

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $rootFolderViewBaseObjectMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $inventoryRootFolderMock }.GetNewClosure() -Verifiable

    $inventoryBaseDSCProperties
}

function New-MocksWhenLocationConsistsOfOnlyOneFolderAndTheFolderDoesNotExist {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $inventoryBaseDSCProperties = New-InventoryBaseDSCProperties
    $inventoryBaseDSCProperties.Location = $script:constants.DatacenterLocationItemOne

    $viServerMock = $script:viServer
    $rootFolderViewBaseObjectMock = $script:rootFolderViewBaseObject
    $inventoryRootFolderMock = $script:inventoryRootFolder

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $rootFolderViewBaseObjectMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $inventoryRootFolderMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:rootFolderViewBaseObject.MoRef } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $inventoryBaseDSCProperties.Location -and $Location -eq $script:inventoryRootFolder } -Verifiable

    $inventoryBaseDSCProperties
}

function New-MocksWhenLocationConsistsOfOnlyOneFolderAndTheFolderExists {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $inventoryBaseDSCProperties = New-InventoryBaseDSCProperties
    $inventoryBaseDSCProperties.Location = $script:constants.DatacenterLocationItemOne

    $viServerMock = $script:viServer
    $rootFolderViewBaseObjectMock = $script:rootFolderViewBaseObject
    $inventoryRootFolderMock = $script:inventoryRootFolder
    $locationDatacenterLocationItemOneMock = $script:locationDatacenterLocationItemOne

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $rootFolderViewBaseObjectMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $inventoryRootFolderMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:rootFolderViewBaseObject.MoRef } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $locationDatacenterLocationItemOneMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $inventoryBaseDSCProperties.Location -and $Location -eq $script:inventoryRootFolder } -Verifiable

    $inventoryBaseDSCProperties
}

function New-MocksWhenLocationConsistsOfTwoInventoryItemsAndOneOfThemIsADatacenter {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $inventoryBaseDSCProperties = New-InventoryBaseDSCProperties
    $inventoryBaseDSCProperties.Location = "$($script:constants.DatacenterName)/$($script:constants.DatacenterLocationItemTwo)"

    $viServerMock = $script:viServer
    $rootFolderViewBaseObjectMock = $script:rootFolderViewBaseObject
    $inventoryRootFolderMock = $script:inventoryRootFolder
    $datacenterChildEntityMock = $script:datacenterChildEntity

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $rootFolderViewBaseObjectMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:viServer.ExtensionData.Content.RootFolder } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $inventoryRootFolderMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:rootFolderViewBaseObject.MoRef } -Verifiable
    Mock -CommandName Get-View -MockWith { return $datacenterChildEntityMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and (($Id | ConvertTo-Json) -eq ($script:inventoryRootFolder.ExtensionData.ChildEntity | ConvertTo-Json)) } -Verifiable

    $inventoryBaseDSCProperties
}

function New-MocksWhenLocationConsistsOfTwoFoldersAndTheLocationIsNotValid {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $inventoryBaseDSCProperties = New-InventoryBaseDSCProperties
    $inventoryBaseDSCProperties.Location = "$($script:constants.DatacenterLocationItemThree)/$($script:constants.DatacenterLocationItemTwo)"

    $viServerMock = $script:viServer
    $rootFolderViewBaseObjectMock = $script:rootFolderViewBaseObject
    $inventoryRootFolderMock = $script:inventoryRootFolder
    $datacenterLocationItemOneMock = $script:datacenterLocationItemOne

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $rootFolderViewBaseObjectMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:viServer.ExtensionData.Content.RootFolder } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $inventoryRootFolderMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:rootFolderViewBaseObject.MoRef } -Verifiable
    Mock -CommandName Get-View -MockWith { return $datacenterLocationItemOneMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and (($Id | ConvertTo-Json) -eq ($script:inventoryRootFolder.ExtensionData.ChildEntity | ConvertTo-Json)) } -Verifiable

    $inventoryBaseDSCProperties
}

function New-MocksWhenLocationConsistsOfTwoFoldersAndTheLocationIsValid {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $inventoryBaseDSCProperties = New-InventoryBaseDSCProperties
    $inventoryBaseDSCProperties.Location = "$($script:constants.DatacenterLocationItemOne)/$($script:constants.DatacenterLocationItemTwo)"

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

    $inventoryBaseDSCProperties
}
