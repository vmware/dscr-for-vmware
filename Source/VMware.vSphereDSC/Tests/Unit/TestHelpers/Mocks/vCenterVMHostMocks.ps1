<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-vCenterVMHostProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vCenterVMHostProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        Name = $script:constants.VMHostName
        Location = [string]::Empty
        DatacenterName = $script:constants.DatacenterName
        DatacenterLocation = $script:constants.DatacenterLocationItemOne
        VMHostCredential = $script:credential
    }

    $vCenterVMHostProperties
}

function New-MocksForvCenterVMHostInSet {
    [CmdletBinding()]

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
    Mock -CommandName Disconnect-VIServer -MockWith { return $null }.GetNewClosure() -Verifiable
}

function New-MocksForvCenterVMHost {
    [CmdletBinding()]

    $viServerMock = $script:viServer

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Disconnect-VIServer -MockWith { return $null }.GetNewClosure() -Verifiable
}

function New-MocksWhenEnsureIsPresentTheVMHostIsNotAddedToThevCenterAndErrorOccursWhileAddingTheVMHostToThevCenter {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vCenterVMHostProperties = New-vCenterVMHostProperties

    $vCenterVMHostProperties.Ensure = 'Present'

    Mock -CommandName Get-VMHost -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMHostName } -Verifiable
    Mock -CommandName Add-VMHost -MockWith { throw }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMHostName -and $Location -eq $script:datacenterHostFolder -and $Credential -eq $script:credential -and !$Confirm } -Verifiable

    $vCenterVMHostProperties
}

function New-MocksWhenEnsureIsPresentTheVMHostIsNotAddedToThevCenterAndNoErrorOccursWhileAddingTheVMHostToThevCenter {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vCenterVMHostProperties = New-vCenterVMHostProperties

    $vCenterVMHostProperties.Ensure = 'Present'
    $vCenterVMHostProperties.Port = $script:constants.VMHostPort
    $vCenterVMHostProperties.Force = $true

    Mock -CommandName Get-VMHost -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMHostName } -Verifiable
    Mock -CommandName Add-VMHost -MockWith { return $null }.GetNewClosure() -Verifiable

    $vCenterVMHostProperties
}

function New-MocksWhenEnsureIsPresentTheVMHostIsAlreadyAddedToThevCenterAndItIsOnTheDesiredLocation {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vCenterVMHostProperties = New-vCenterVMHostProperties

    $vCenterVMHostProperties.Ensure = 'Present'

    $vmHostMock = $script:vmHostWithDatacenterHostFolderAsParent

    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMHostName } -Verifiable
    Mock -CommandName Move-VMHost -MockWith { return $null }.GetNewClosure()

    $vCenterVMHostProperties
}

function New-MocksWhenEnsureIsPresentTheVMHostIsAlreadyAddedToThevCenterAndErrorOccursWhileMovingTheVMHostToTheDesiredLocation {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vCenterVMHostProperties = New-vCenterVMHostProperties

    $vCenterVMHostProperties.Ensure = 'Present'

    $vmHostMock = $script:vmHostWithInventoryItemLocationItemOneAsParent

    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMHostName } -Verifiable
    Mock -CommandName Move-VMHost -MockWith { throw }.GetNewClosure()

    $vCenterVMHostProperties
}

function New-MocksWhenEnsureIsPresentTheVMHostIsAlreadyAddedToThevCenterAndNoErrorOccursWhileMovingTheVMHostToTheDesiredLocation {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vCenterVMHostProperties = New-vCenterVMHostProperties

    $vCenterVMHostProperties.Ensure = 'Present'

    $vmHostMock = $script:vmHostWithInventoryItemLocationItemOneAsParent

    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMHostName } -Verifiable
    Mock -CommandName Move-VMHost -MockWith { return $null }.GetNewClosure()

    $vCenterVMHostProperties
}

function New-MocksWhenEnsureIsAbsentAndTheVMHostIsAlreadyRemovedFromThevCenter {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vCenterVMHostProperties = New-vCenterVMHostProperties

    $vCenterVMHostProperties.Ensure = 'Absent'

    Mock -CommandName Get-VMHost -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMHostName } -Verifiable
    Mock -CommandName Remove-VMHost -MockWith { return $null }.GetNewClosure()

    $vCenterVMHostProperties
}

function New-MocksWhenEnsureIsAbsentAndTheVMHostIsNotRemovedFromThevCenter {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vCenterVMHostProperties = New-vCenterVMHostProperties

    $vCenterVMHostProperties.Ensure = 'Absent'

    $vmHostMock = $script:vmHostWithDatacenterHostFolderAsParent

    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMHostName } -Verifiable

    $vCenterVMHostProperties
}

function New-MocksWhenEnsureIsAbsentTheVMHostIsNotRemovedFromThevCenterAndErrorOccursWhileRemovingTheVMHostFromThevCenter {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vCenterVMHostProperties = New-vCenterVMHostProperties

    $vCenterVMHostProperties.Ensure = 'Absent'

    $vmHostMock = $script:vmHostWithDatacenterHostFolderAsParent

    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMHostName } -Verifiable
    Mock -CommandName Remove-VMHost -MockWith { throw }.GetNewClosure()

    $vCenterVMHostProperties
}

function New-MocksWhenEnsureIsAbsentTheVMHostIsNotRemovedFromThevCenterAndNoErrorOccursWhileRemovingTheVMHostFromThevCenter {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vCenterVMHostProperties = New-vCenterVMHostProperties

    $vCenterVMHostProperties.Ensure = 'Absent'

    $vmHostMock = $script:vmHostWithDatacenterHostFolderAsParent

    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMHostName } -Verifiable
    Mock -CommandName Remove-VMHost -MockWith { return $null }.GetNewClosure()

    $vCenterVMHostProperties
}

function New-MocksWhenEnsureIsPresentAndTheVMHostIsNotAddedToThevCenter {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vCenterVMHostProperties = New-vCenterVMHostProperties

    $vCenterVMHostProperties.Ensure = 'Present'

    Mock -CommandName Get-VMHost -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMHostName } -Verifiable

    $vCenterVMHostProperties
}

function New-MocksWhenEnsureIsPresentAndTheVMHostIsAlreadyAddedToThevCenter {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vCenterVMHostProperties = New-vCenterVMHostProperties

    $vCenterVMHostProperties.Ensure = 'Present'

    $vmHostMock = $script:vmHostWithDatacenterHostFolderAsParent

    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMHostName } -Verifiable

    $vCenterVMHostProperties
}

function New-MocksWhenEnsureIsPresentTheVMHostIsAlreadyAddedToThevCenterButNotOnTheDesiredLocation {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vCenterVMHostProperties = New-vCenterVMHostProperties

    $vCenterVMHostProperties.Ensure = 'Present'

    $rootFolderViewBaseObjectMock = $script:rootFolderViewBaseObject
    $inventoryRootFolderMock = $script:inventoryRootFolder
    $locationDatacenterLocationItemOneMock = $script:locationDatacenterLocationItemOne
    $datacenterWithDatacenterLocationItemOneAsParentMock = $script:datacenterWithDatacenterLocationItemOneAsParent
    $datacenterHostFolderViewBaseObjectMock = $script:datacenterHostFolderViewBaseObject
    $datacenterHostFolderMock = $script:datacenterHostFolder
    $vmHostMock = $script:vmHostWithInventoryItemLocationItemOneAsParent

    Mock -CommandName Get-View -MockWith { return $rootFolderViewBaseObjectMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:viServer.ExtensionData.Content.RootFolder } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $inventoryRootFolderMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:rootFolderViewBaseObject.MoRef } -Verifiable
    Mock -CommandName Get-Folder -MockWith { return $locationDatacenterLocationItemOneMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-Datacenter -MockWith { return $datacenterWithDatacenterLocationItemOneAsParentMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $datacenterHostFolderViewBaseObjectMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:datacenterWithDatacenterLocationItemOneAsParent.ExtensionData.HostFolder } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $datacenterHostFolderMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:datacenterHostFolderViewBaseObject.MoRef } -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMHostName } -Verifiable

    $vCenterVMHostProperties
}

function New-MocksWhenEnsureIsPresentAndTheVMHostIsAlreadyAddedToTheDesiredLocationOnThevCenter {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vCenterVMHostProperties = New-vCenterVMHostProperties

    $vCenterVMHostProperties.Ensure = 'Present'

    $rootFolderViewBaseObjectMock = $script:rootFolderViewBaseObject
    $inventoryRootFolderMock = $script:inventoryRootFolder
    $locationDatacenterLocationItemOneMock = $script:locationDatacenterLocationItemOne
    $datacenterWithDatacenterLocationItemOneAsParentMock = $script:datacenterWithDatacenterLocationItemOneAsParent
    $datacenterHostFolderViewBaseObjectMock = $script:datacenterHostFolderViewBaseObject
    $datacenterHostFolderMock = $script:datacenterHostFolder
    $vmHostMock = $script:vmHostWithDatacenterHostFolderAsParent

    Mock -CommandName Get-View -MockWith { return $rootFolderViewBaseObjectMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:viServer.ExtensionData.Content.RootFolder } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $inventoryRootFolderMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:rootFolderViewBaseObject.MoRef } -Verifiable
    Mock -CommandName Get-Folder -MockWith { return $locationDatacenterLocationItemOneMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-Datacenter -MockWith { return $datacenterWithDatacenterLocationItemOneAsParentMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $datacenterHostFolderViewBaseObjectMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:datacenterWithDatacenterLocationItemOneAsParent.ExtensionData.HostFolder } -Verifiable
    Mock -CommandName Get-Inventory -MockWith { return $datacenterHostFolderMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:datacenterHostFolderViewBaseObject.MoRef } -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMHostName } -Verifiable

    $vCenterVMHostProperties
}
