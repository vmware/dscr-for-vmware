<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-FolderProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $folderProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        Name = $script:constants.InventoryItemName
        Ensure = 'Present'
        Location = "$($script:constants.DatacenterLocationItemOne)/$($script:constants.DatacenterLocationItemTwo)"
    }

    $folderProperties
}

function New-MocksForFolder {
    [CmdletBinding()]

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
}

function New-MocksInSetWhenEnsurePresentAndNonExistingFolder {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $folderProperties = New-FolderProperties

    Mock -CommandName Get-Folder -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:locationDatacenterLocationItemTwo } -Verifiable
    Mock -CommandName New-Folder -MockWith { return $null }.GetNewClosure() -Verifiable

    $folderProperties
}

function New-MocksInSetWhenEnsurePresentAndExistingFolder {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $folderProperties = New-FolderProperties

    $folderMock = $script:datacenterFolder

    Mock -CommandName Get-Folder -MockWith { return $folderMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:locationDatacenterLocationItemTwo } -Verifiable
    Mock -CommandName New-Folder -MockWith { return $null }.GetNewClosure()

    $folderProperties
}

function New-MocksInSetWhenEnsureAbsentAndNonExistingFolder {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $folderProperties = New-FolderProperties
    $folderProperties.Ensure = 'Absent'

    Mock -CommandName Get-Folder -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:locationDatacenterLocationItemTwo } -Verifiable
    Mock -CommandName Remove-Folder -MockWith { return $null }.GetNewClosure()

    $folderProperties
}

function New-MocksInSetWhenEnsureAbsentAndExistingFolder {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $folderProperties = New-FolderProperties
    $folderProperties.Ensure = 'Absent'

    $folderMock = $script:datacenterFolder

    Mock -CommandName Get-Folder -MockWith { return $folderMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:locationDatacenterLocationItemTwo } -Verifiable
    Mock -CommandName Remove-Folder -MockWith { return $null }.GetNewClosure() -Verifiable

    $folderProperties
}

function New-MocksWhenEnsurePresentAndNonExistingFolder {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $folderProperties = New-FolderProperties

    Mock -CommandName Get-Folder -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:locationDatacenterLocationItemTwo } -Verifiable

    $folderProperties
}

function New-MocksWhenEnsurePresentAndExistingFolder {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $folderProperties = New-FolderProperties

    $folderMock = $script:datacenterFolder

    Mock -CommandName Get-Folder -MockWith { return $folderMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:locationDatacenterLocationItemTwo } -Verifiable

    $folderProperties
}

function New-MocksWhenEnsureAbsentAndNonExistingFolder {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $folderProperties = New-FolderProperties
    $folderProperties.Ensure = 'Absent'

    Mock -CommandName Get-Folder -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:locationDatacenterLocationItemTwo } -Verifiable

    $folderProperties
}

function New-MocksWhenEnsureAbsentAndExistingFolder {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $folderProperties = New-FolderProperties
    $folderProperties.Ensure = 'Absent'

    $folderMock = $script:datacenterFolder

    Mock -CommandName Get-Folder -MockWith { return $folderMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.InventoryItemName -and $Location -eq $script:locationDatacenterLocationItemTwo } -Verifiable

    $folderProperties
}
