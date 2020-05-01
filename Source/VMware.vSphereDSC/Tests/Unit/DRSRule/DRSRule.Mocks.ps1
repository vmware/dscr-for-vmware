<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-DRSRuleDscResourceProperties {
    [OutputType([System.Collections.Hashtable])]

    $DRSRuleDscResourceProperties = @{
        Server = $script:Constants.VIServer
        Credential = $script:Credential
        Name = $script:Constants.DrsRuleName
        DatacenterName = $script:Constants.DatacenterName
        DatacenterLocation = [string]::Empty
        ClusterName = $script:Constants.ClusterName
        ClusterLocation = [string]::Empty
        DRSRuleType = $script:Constants.DrsRuleType
    }

    $DRSRuleDscResourceProperties
}

function New-MocksForDRSRuleDscResource {
    $viServerMock = $script:VIServer
    $inventoryRootFolderMock = $script:InventoryRootFolder
    $datacenterMock = $script:Datacenter
    $datacenterHostFolderMock = $script:DatacenterHostFolder
    $clusterMock = $script:Cluster

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

    $getInventoryMockParamsForDatacenterHostFolder = @{
        CommandName = 'Get-Inventory'
        MockWith = { return $datacenterHostFolderMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $Id -eq $script:Datacenter.ExtensionData.HostFolder
        }
        Verifiable = $true
    }
    Mock @getInventoryMockParamsForDatacenterHostFolder

    $getClusterMockParams = @{
        CommandName = 'Get-Inventory'
        MockWith = { return $clusterMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $Name -eq $script:Constants.ClusterName -and
            $Location -eq $script:DatacenterHostFolder
        }
        Verifiable = $true
    }
    Mock @getClusterMockParams
}

function New-MocksWhenEnsureIsPresentTheDRSRuleDoesNotExistAndErrorOccursWhileCreatingTheDRSRule {
    [OutputType([System.Collections.Hashtable])]

    $DRSRuleDscResourceProperties = New-DRSRuleDscResourceProperties

    $DRSRuleDscResourceProperties.VMNames = $script:Constants.VirtualMachineNames
    $DRSRuleDscResourceProperties.Ensure = 'Present'

    $virtualMachinesMock = $script:VirtualMachines

    $getDRSRuleMockParams = @{
        CommandName = 'Get-DrsRule'
        MockWith = { return $null }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $Name -eq $script:Constants.DrsRuleName -and
            $Cluster -eq $script:Cluster
        }
        Verifiable = $true
    }
    Mock @getDRSRuleMockParams

    $getVMMockParams = @{
        CommandName = 'Get-VM'
        MockWith = { return $virtualMachinesMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            [System.Linq.Enumerable]::SequenceEqual($Name, [string[]] $script:Constants.VirtualMachineNames) -and
            $Location -eq $script:Cluster
        }
        Verifiable = $true
    }
    Mock @getVMMockParams

    Mock -CommandName 'New-DrsRule' -MockWith { throw }.GetNewClosure() -Verifiable

    $DRSRuleDscResourceProperties
}

function New-MocksWhenEnsureIsPresentTheDRSRuleDoesNotExistAndNoErrorOccursWhileCreatingTheDRSRule {
    [OutputType([System.Collections.Hashtable])]

    $DRSRuleDscResourceProperties = New-DRSRuleDscResourceProperties

    $DRSRuleDscResourceProperties.VMNames = $script:Constants.VirtualMachineNames
    $DRSRuleDscResourceProperties.Ensure = 'Present'
    $DRSRuleDscResourceProperties.Enabled = $script:Constants.DrsRuleEnabled

    $virtualMachinesMock = $script:VirtualMachines

    $getDRSRuleMockParams = @{
        CommandName = 'Get-DrsRule'
        MockWith = { return $null }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $Name -eq $script:Constants.DrsRuleName -and
            $Cluster -eq $script:Cluster
        }
        Verifiable = $true
    }
    Mock @getDRSRuleMockParams

    $getVMMockParams = @{
        CommandName = 'Get-VM'
        MockWith = { return $virtualMachinesMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            [System.Linq.Enumerable]::SequenceEqual($Name, [string[]] $script:Constants.VirtualMachineNames) -and
            $Location -eq $script:Cluster
        }
        Verifiable = $true
    }
    Mock @getVMMockParams

    Mock -CommandName 'New-DrsRule' -MockWith { return $null }.GetNewClosure() -Verifiable

    $DRSRuleDscResourceProperties
}

function New-MocksWhenEnsureIsPresentTheDRSRuleExistsAndErrorOccursWhileModifyingTheDRSRule {
    [OutputType([System.Collections.Hashtable])]

    $DRSRuleDscResourceProperties = New-DRSRuleDscResourceProperties

    $DRSRuleDscResourceProperties.VMNames = $script:Constants.VirtualMachineNames
    $DRSRuleDscResourceProperties.Ensure = 'Present'

    $drsRuleMock = $script:DrsRule
    $virtualMachinesMock = $script:VirtualMachines

    $getDRSRuleMockParams = @{
        CommandName = 'Get-DrsRule'
        MockWith = { return $drsRuleMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $Name -eq $script:Constants.DrsRuleName -and
            $Cluster -eq $script:Cluster
        }
        Verifiable = $true
    }
    Mock @getDRSRuleMockParams

    $getVMMockParams = @{
        CommandName = 'Get-VM'
        MockWith = { return $virtualMachinesMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            [System.Linq.Enumerable]::SequenceEqual($Name, [string[]] $script:Constants.VirtualMachineNames) -and
            $Location -eq $script:Cluster
        }
        Verifiable = $true
    }
    Mock @getVMMockParams

    Mock -CommandName 'Set-DrsRule' -MockWith { throw }.GetNewClosure() -Verifiable

    $DRSRuleDscResourceProperties
}

function New-MocksWhenEnsureIsPresentTheDRSRuleExistsAndVirtualMachinesAreSpecified {
    [OutputType([System.Collections.Hashtable])]

    $DRSRuleDscResourceProperties = New-DRSRuleDscResourceProperties

    $DRSRuleDscResourceProperties.VMNames = $script:Constants.VirtualMachineNames
    $DRSRuleDscResourceProperties.Ensure = 'Present'
    $DRSRuleDscResourceProperties.Enabled = !$script:Constants.DrsRuleEnabled

    $drsRuleMock = $script:DrsRule
    $virtualMachinesMock = $script:VirtualMachines

    $getDRSRuleMockParams = @{
        CommandName = 'Get-DrsRule'
        MockWith = { return $drsRuleMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $Name -eq $script:Constants.DrsRuleName -and
            $Cluster -eq $script:Cluster
        }
        Verifiable = $true
    }
    Mock @getDRSRuleMockParams

    $getVMMockParams = @{
        CommandName = 'Get-VM'
        MockWith = { return $virtualMachinesMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            [System.Linq.Enumerable]::SequenceEqual($Name, [string[]] $script:Constants.VirtualMachineNames) -and
            $Location -eq $script:Cluster
        }
        Verifiable = $true
    }
    Mock @getVMMockParams

    Mock -CommandName 'Set-DrsRule' -MockWith { return $null }.GetNewClosure() -Verifiable

    $DRSRuleDscResourceProperties
}

function New-MocksInSetWhenEnsureIsAbsentAndTheDRSRuleDoesNotExist {
    [OutputType([System.Collections.Hashtable])]

    $DRSRuleDscResourceProperties = New-DRSRuleDscResourceProperties
    $DRSRuleDscResourceProperties.Ensure = 'Absent'

    $getDRSRuleMockParams = @{
        CommandName = 'Get-DrsRule'
        MockWith = { return $null }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $Name -eq $script:Constants.DrsRuleName -and
            $Cluster -eq $script:Cluster
        }
        Verifiable = $true
    }
    Mock @getDRSRuleMockParams

    Mock -CommandName 'Remove-DrsRule' -MockWith { return $null }.GetNewClosure()

    $DRSRuleDscResourceProperties
}

function New-MocksWhenEnsureIsAbsentTheDRSRuleExistsAndErrorOccursWhileRemovingTheDRSRule {
    [OutputType([System.Collections.Hashtable])]

    $DRSRuleDscResourceProperties = New-DRSRuleDscResourceProperties
    $DRSRuleDscResourceProperties.Ensure = 'Absent'

    $drsRuleMock = $script:DrsRule

    $getDRSRuleMockParams = @{
        CommandName = 'Get-DrsRule'
        MockWith = { return $drsRuleMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $Name -eq $script:Constants.DrsRuleName -and
            $Cluster -eq $script:Cluster
        }
        Verifiable = $true
    }
    Mock @getDRSRuleMockParams

    Mock -CommandName 'Remove-DrsRule' -MockWith { throw }.GetNewClosure() -Verifiable

    $DRSRuleDscResourceProperties
}

function New-MocksInSetWhenEnsureIsAbsentAndTheDRSRuleExists {
    [OutputType([System.Collections.Hashtable])]

    $DRSRuleDscResourceProperties = New-DRSRuleDscResourceProperties
    $DRSRuleDscResourceProperties.Ensure = 'Absent'

    $drsRuleMock = $script:DrsRule

    $getDRSRuleMockParams = @{
        CommandName = 'Get-DrsRule'
        MockWith = { return $drsRuleMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $Name -eq $script:Constants.DrsRuleName -and
            $Cluster -eq $script:Cluster
        }
        Verifiable = $true
    }
    Mock @getDRSRuleMockParams

    Mock -CommandName 'Remove-DrsRule' -MockWith { return $null }.GetNewClosure() -Verifiable

    $DRSRuleDscResourceProperties
}

function New-MocksWhenEnsureIsPresentTheDRSRuleExistsAndTheVirtualMachinesReferencedByTheDRSRuleShouldNotBeModified {
    [OutputType([System.Collections.Hashtable])]

    $DRSRuleDscResourceProperties = New-DRSRuleDscResourceProperties

    $DRSRuleDscResourceProperties.VMNames = $script:Constants.VirtualMachineNames
    $DRSRuleDscResourceProperties.Ensure = 'Present'
    $DRSRuleDscResourceProperties.Enabled = $script:Constants.DrsRuleEnabled

    $drsRuleMock = $script:DrsRule
    $virtualMachinesMock = $script:VirtualMachines

    $getDRSRuleMockParams = @{
        CommandName = 'Get-DrsRule'
        MockWith = { return $drsRuleMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $Name -eq $script:Constants.DrsRuleName -and
            $Cluster -eq $script:Cluster
        }
        Verifiable = $true
    }
    Mock @getDRSRuleMockParams

    $getVMMockParams = @{
        CommandName = 'Get-VM'
        MockWith = { return $virtualMachinesMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            [System.Linq.Enumerable]::SequenceEqual($Id, [string[]] $script:Constants.VirtualMachineIds)
        }
        Verifiable = $true
    }
    Mock @getVMMockParams

    $DRSRuleDscResourceProperties
}

function New-MocksWhenEnsureIsPresentTheDRSRuleExistsAndTheVirtualMachinesReferencedByTheDRSRuleShouldBeModified {
    [OutputType([System.Collections.Hashtable])]

    $DRSRuleDscResourceProperties = New-DRSRuleDscResourceProperties

    $DRSRuleDscResourceProperties.VMNames = @($script:Constants.VirtualMachineOneName)
    $DRSRuleDscResourceProperties.Ensure = 'Present'
    $DRSRuleDscResourceProperties.Enabled = !$script:Constants.DrsRuleEnabled

    $drsRuleMock = $script:DrsRule
    $virtualMachinesMock = $script:VirtualMachines

    $getDRSRuleMockParams = @{
        CommandName = 'Get-DrsRule'
        MockWith = { return $drsRuleMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $Name -eq $script:Constants.DrsRuleName -and
            $Cluster -eq $script:Cluster
        }
        Verifiable = $true
    }
    Mock @getDRSRuleMockParams

    $getVMMockParams = @{
        CommandName = 'Get-VM'
        MockWith = { return $virtualMachinesMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            [System.Linq.Enumerable]::SequenceEqual($Id, [string[]] $script:Constants.VirtualMachineIds)
        }
        Verifiable = $true
    }
    Mock @getVMMockParams

    $DRSRuleDscResourceProperties
}

function New-MocksWhenEnsureIsPresentAndTheDRSRuleDoesNotExist {
    [OutputType([System.Collections.Hashtable])]

    $DRSRuleDscResourceProperties = New-DRSRuleDscResourceProperties
    $DRSRuleDscResourceProperties.Ensure = 'Present'

    $getDRSRuleMockParams = @{
        CommandName = 'Get-DrsRule'
        MockWith = { return $null }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $Name -eq $script:Constants.DrsRuleName -and
            $Cluster -eq $script:Cluster
        }
        Verifiable = $true
    }
    Mock @getDRSRuleMockParams

    $DRSRuleDscResourceProperties
}

function New-MocksWhenEnsureIsPresentAndTheDRSRuleExists {
    [OutputType([System.Collections.Hashtable])]

    $DRSRuleDscResourceProperties = New-DRSRuleDscResourceProperties
    $DRSRuleDscResourceProperties.Ensure = 'Present'

    $drsRuleMock = $script:DrsRule
    $virtualMachinesMock = $script:VirtualMachines

    $getDRSRuleMockParams = @{
        CommandName = 'Get-DrsRule'
        MockWith = { return $drsRuleMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $Name -eq $script:Constants.DrsRuleName -and
            $Cluster -eq $script:Cluster
        }
        Verifiable = $true
    }
    Mock @getDRSRuleMockParams

    $getVMMockParams = @{
        CommandName = 'Get-VM'
        MockWith = { return $virtualMachinesMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            [System.Linq.Enumerable]::SequenceEqual($Id, [string[]] $script:Constants.VirtualMachineIds)
        }
        Verifiable = $true
    }
    Mock @getVMMockParams

    $DRSRuleDscResourceProperties
}

function New-MocksWhenEnsureIsAbsentAndTheDRSRuleDoesNotExist {
    [OutputType([System.Collections.Hashtable])]

    $DRSRuleDscResourceProperties = New-DRSRuleDscResourceProperties
    $DRSRuleDscResourceProperties.Ensure = 'Absent'

    $getDRSRuleMockParams = @{
        CommandName = 'Get-DrsRule'
        MockWith = { return $null }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $Name -eq $script:Constants.DrsRuleName -and
            $Cluster -eq $script:Cluster
        }
        Verifiable = $true
    }
    Mock @getDRSRuleMockParams

    $DRSRuleDscResourceProperties
}

function New-MocksWhenEnsureIsAbsentAndTheDRSRuleExists {
    [OutputType([System.Collections.Hashtable])]

    $DRSRuleDscResourceProperties = New-DRSRuleDscResourceProperties
    $DRSRuleDscResourceProperties.Ensure = 'Absent'

    $drsRuleMock = $script:DrsRule
    $virtualMachinesMock = $script:VirtualMachines

    $getDRSRuleMockParams = @{
        CommandName = 'Get-DrsRule'
        MockWith = { return $drsRuleMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            $Name -eq $script:Constants.DrsRuleName -and
            $Cluster -eq $script:Cluster
        }
        Verifiable = $true
    }
    Mock @getDRSRuleMockParams

    $getVMMockParams = @{
        CommandName = 'Get-VM'
        MockWith = { return $virtualMachinesMock }.GetNewClosure()
        ParameterFilter = {
            $Server -eq $script:VIServer -and
            [System.Linq.Enumerable]::SequenceEqual($Id, [string[]] $script:Constants.VirtualMachineIds)
        }
    }
    Mock @getVMMockParams

    $DRSRuleDscResourceProperties
}
