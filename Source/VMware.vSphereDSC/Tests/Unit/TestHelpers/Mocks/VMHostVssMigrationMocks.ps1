<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-VMHostVssMigrationProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssMigrationProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        VMHostName = $script:constants.VMHostName
        VssName = $script:constants.VirtualSwitchName
    }

    $vmHostVssMigrationProperties
}

function New-MocksForVMHostVssMigration {
    [CmdletBinding()]

    $viServerMock = $script:viServer
    $vmHostMock = $script:vmHost

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable
    Mock -CommandName Disconnect-VIServer -MockWith { return $null }.GetNewClosure() -Verifiable
}

function New-MocksWhenServerErrorOccursDuringStandardSwitchRetrieval {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssMigrationProperties = New-VMHostVssMigrationProperties

    $vmHostVssMigrationProperties.VssName = $script:constants.VirtualSwitchName

    Mock -CommandName Get-VirtualSwitch -MockWith { throw }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VirtualSwitchName -and $VMHost -eq $script:vmHost -and $Standard } -Verifiable

    $vmHostVssMigrationProperties
}

function New-MocksWhenTwoPhysicalNetworkAdaptersArePassedAndServerErrorOccursDuringMigration {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssMigrationProperties = New-VMHostVssMigrationProperties

    $vmHostVssMigrationProperties.VssName = $script:constants.VirtualSwitchName
    $vmHostVssMigrationProperties.PhysicalNicNames = @($script:constants.ConnectedPhysicalNetworkAdapterOneName, $script:constants.DisconnectedPhysicalNetworkAdapterOneName)

    $standardSwitchMock = $script:virtualSwitch
    $physicalNetworkAdapterOneMock = $script:connectedPhysicalNetworkAdapterOne
    $physicalNetworkAdapterTwoMock = $script:disconnectedPhysicalNetworkAdapterOne

    Mock -CommandName Get-VirtualSwitch -MockWith { return $standardSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VirtualSwitchName -and $VMHost -eq $script:vmHost -and $Standard } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterOneMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.ConnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHost -and $Physical } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterTwoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DisconnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHost -and $Physical } -Verifiable
    Mock -CommandName Add-VirtualSwitchPhysicalNetworkAdapter -MockWith { throw }.GetNewClosure() -Verifiable

    $vmHostVssMigrationProperties
}

function New-MocksWhenTwoPhysicalNetworkAdaptersArePassedAndBothAreNotAddedToThePassedStandardSwitch {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssMigrationProperties = New-VMHostVssMigrationProperties

    $vmHostVssMigrationProperties.VssName = $script:constants.VirtualSwitchName
    $vmHostVssMigrationProperties.PhysicalNicNames = @($script:constants.ConnectedPhysicalNetworkAdapterOneName, $script:constants.DisconnectedPhysicalNetworkAdapterOneName)

    $standardSwitchMock = $script:virtualSwitch
    $physicalNetworkAdapterOneMock = $script:connectedPhysicalNetworkAdapterOne
    $physicalNetworkAdapterTwoMock = $script:disconnectedPhysicalNetworkAdapterOne

    Mock -CommandName Get-VirtualSwitch -MockWith { return $standardSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VirtualSwitchName -and $VMHost -eq $script:vmHost -and $Standard } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterOneMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.ConnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHost -and $Physical } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterTwoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DisconnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHost -and $Physical } -Verifiable
    Mock -CommandName Add-VirtualSwitchPhysicalNetworkAdapter -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostVssMigrationProperties
}

function New-MocksWhenTwoPhysicalNetworkAdaptersOneVMKernelNetworkAdapterAndOnePortGroupArePassedAndServerErrorOccursDuringMigration {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssMigrationProperties = New-VMHostVssMigrationProperties

    $vmHostVssMigrationProperties.VssName = $script:constants.VirtualSwitchName
    $vmHostVssMigrationProperties.PhysicalNicNames = @($script:constants.ConnectedPhysicalNetworkAdapterOneName, $script:constants.DisconnectedPhysicalNetworkAdapterOneName)
    $vmHostVssMigrationProperties.VMKernelNicNames = @($script:constants.VMKernelNetworkAdapterOneName)
    $vmHostVssMigrationProperties.PortGroupNames = @($script:constants.PortGroupOneName)

    $standardSwitchMock = $script:standardSwitchWithOnePhysicalNetworkAdapter
    $physicalNetworkAdapterOneMock = $script:connectedPhysicalNetworkAdapterOne
    $physicalNetworkAdapterTwoMock = $script:disconnectedPhysicalNetworkAdapterOne
    $vmKernelNetworkAdapterMock = $script:vmKernelNetworkAdapterOne
    $standardPortGroupMock = $script:portGroupWithAttachedVMKernelNetworkAdapter

    Mock -CommandName Get-VirtualSwitch -MockWith { return $standardSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VirtualSwitchName -and $VMHost -eq $script:vmHost -and $Standard } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterOneMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.ConnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHost -and $Physical } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterTwoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DisconnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHost -and $Physical } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmKernelNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMKernelNetworkAdapterOneName -and $VMHost -eq $script:vmHost -and $VMKernel } -Verifiable
    Mock -CommandName Get-VirtualPortGroup -MockWith { return $standardPortGroupMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.PortGroupOneName -and $VirtualSwitch -eq $script:standardSwitchWithOnePhysicalNetworkAdapter -and $Standard } -Verifiable
    Mock -CommandName Add-VirtualSwitchPhysicalNetworkAdapter -MockWith { throw }.GetNewClosure() -Verifiable

    $vmHostVssMigrationProperties
}

function New-MocksWhenTwoPhysicalNetworkAdaptersOneVMKernelNetworkAdapterAndOnePortGroupArePassedThePortGroupDoesNotExistAndServerErrorOccursDuringPortGroupCreation {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssMigrationProperties = New-VMHostVssMigrationProperties

    $vmHostVssMigrationProperties.VssName = $script:constants.VirtualSwitchName
    $vmHostVssMigrationProperties.PhysicalNicNames = @($script:constants.ConnectedPhysicalNetworkAdapterOneName, $script:constants.DisconnectedPhysicalNetworkAdapterOneName)
    $vmHostVssMigrationProperties.VMKernelNicNames = @($script:constants.VMKernelNetworkAdapterOneName)
    $vmHostVssMigrationProperties.PortGroupNames = @($script:constants.PortGroupOneName)

    $standardSwitchMock = $script:standardSwitchWithOnePhysicalNetworkAdapter
    $physicalNetworkAdapterOneMock = $script:connectedPhysicalNetworkAdapterOne
    $physicalNetworkAdapterTwoMock = $script:disconnectedPhysicalNetworkAdapterOne
    $vmKernelNetworkAdapterMock = $script:vmKernelNetworkAdapterOne

    Mock -CommandName Get-VirtualSwitch -MockWith { return $standardSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VirtualSwitchName -and $VMHost -eq $script:vmHost -and $Standard } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterOneMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.ConnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHost -and $Physical } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterTwoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DisconnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHost -and $Physical } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmKernelNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMKernelNetworkAdapterOneName -and $VMHost -eq $script:vmHost -and $VMKernel } -Verifiable
    Mock -CommandName Get-VirtualPortGroup -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.PortGroupOneName -and $VirtualSwitch -eq $script:standardSwitchWithOnePhysicalNetworkAdapter -and $Standard } -Verifiable
    Mock -CommandName New-VirtualPortGroup -MockWith { throw }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.PortGroupOneName -and $VirtualSwitch -eq $script:standardSwitchWithOnePhysicalNetworkAdapter } -Verifiable

    $vmHostVssMigrationProperties
}

function New-MocksWhenTwoPhysicalNetworkAdaptersOneVMKernelNetworkAdapterAndOnePortGroupArePassedAndThePortGroupDoesNotExist {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssMigrationProperties = New-VMHostVssMigrationProperties

    $vmHostVssMigrationProperties.VssName = $script:constants.VirtualSwitchName
    $vmHostVssMigrationProperties.PhysicalNicNames = @($script:constants.ConnectedPhysicalNetworkAdapterOneName, $script:constants.DisconnectedPhysicalNetworkAdapterOneName)
    $vmHostVssMigrationProperties.VMKernelNicNames = @($script:constants.VMKernelNetworkAdapterOneName)
    $vmHostVssMigrationProperties.PortGroupNames = @($script:constants.PortGroupOneName)

    $standardSwitchMock = $script:standardSwitchWithOnePhysicalNetworkAdapter
    $physicalNetworkAdapterOneMock = $script:connectedPhysicalNetworkAdapterOne
    $physicalNetworkAdapterTwoMock = $script:disconnectedPhysicalNetworkAdapterOne
    $vmKernelNetworkAdapterMock = $script:vmKernelNetworkAdapterOne

    Mock -CommandName Get-VirtualSwitch -MockWith { return $standardSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VirtualSwitchName -and $VMHost -eq $script:vmHost -and $Standard } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterOneMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.ConnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHost -and $Physical } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterTwoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DisconnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHost -and $Physical } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmKernelNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMKernelNetworkAdapterOneName -and $VMHost -eq $script:vmHost -and $VMKernel } -Verifiable
    Mock -CommandName Get-VirtualPortGroup -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.PortGroupOneName -and $VirtualSwitch -eq $script:standardSwitchWithOnePhysicalNetworkAdapter -and $Standard } -Verifiable
    Mock -CommandName New-VirtualPortGroup -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.PortGroupOneName -and $VirtualSwitch -eq $script:standardSwitchWithOnePhysicalNetworkAdapter } -Verifiable
    Mock -CommandName Add-VirtualSwitchPhysicalNetworkAdapter -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostVssMigrationProperties
}

function New-MocksWhenOnePhysicalNetworkAdapterIsPassedAndIsNotPresentOnTheServer {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssMigrationProperties = New-VMHostVssMigrationProperties

    $vmHostVssMigrationProperties.VssName = $script:constants.VirtualSwitchName
    $vmHostVssMigrationProperties.PhysicalNicNames = @($script:constants.ConnectedPhysicalNetworkAdapterTwoName)

    $standardSwitchMock = $script:standardSwitchWithOnePhysicalNetworkAdapter

    # Mock Write-WarningLog to avoid the warning output when executing the Unit Tests.
    Mock -CommandName Write-WarningLog -MockWith { return $null }.GetNewClosure() -Verifiable

    Mock -CommandName Get-VirtualSwitch -MockWith { return $standardSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VirtualSwitchName -and $VMHost -eq $script:vmHost -and $Standard } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.ConnectedPhysicalNetworkAdapterTwoName -and $VMHost -eq $script:vmHost -and $Physical } -Verifiable

    $vmHostVssMigrationProperties
}

function New-MocksWhenOnePhysicalNetworkAdapterIsPassedAndTheStandardSwitchDoesNotHavePhysicalNetworkAdaptersAddedToIt {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssMigrationProperties = New-VMHostVssMigrationProperties

    $vmHostVssMigrationProperties.VssName = $script:constants.VirtualSwitchName
    $vmHostVssMigrationProperties.PhysicalNicNames = @($script:constants.ConnectedPhysicalNetworkAdapterOneName)

    $standardSwitchMock = $script:virtualSwitch
    $physicalNetworkAdapterMock = $script:connectedPhysicalNetworkAdapterOne

    Mock -CommandName Get-VirtualSwitch -MockWith { return $standardSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VirtualSwitchName -and $VMHost -eq $script:vmHost -and $Standard } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.ConnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHost -and $Physical } -Verifiable

    $vmHostVssMigrationProperties
}

function New-MocksWhenOnePhysicalNetworkAdapterIsPassedAndItIsNotAddedToTheStandardSwitch {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssMigrationProperties = New-VMHostVssMigrationProperties

    $vmHostVssMigrationProperties.VssName = $script:constants.VirtualSwitchName
    $vmHostVssMigrationProperties.PhysicalNicNames = @($script:constants.ConnectedPhysicalNetworkAdapterOneName)

    $standardSwitchMock = $script:standardSwitchWithOnePhysicalNetworkAdapter
    $physicalNetworkAdapterMock = $script:connectedPhysicalNetworkAdapterOne

    Mock -CommandName Get-VirtualSwitch -MockWith { return $standardSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VirtualSwitchName -and $VMHost -eq $script:vmHost -and $Standard } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.ConnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHost -and $Physical } -Verifiable

    $vmHostVssMigrationProperties
}

function New-MocksWhenOnePhysicalNetworkAdapterIsPassedAndItIsAddedToTheStandardSwitch {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssMigrationProperties = New-VMHostVssMigrationProperties

    $vmHostVssMigrationProperties.VssName = $script:constants.VirtualSwitchName
    $vmHostVssMigrationProperties.PhysicalNicNames = @($script:constants.DisconnectedPhysicalNetworkAdapterOneName)

    $standardSwitchMock = $script:standardSwitchWithOnePhysicalNetworkAdapter
    $physicalNetworkAdapterMock = $script:disconnectedPhysicalNetworkAdapterOne

    Mock -CommandName Get-VirtualSwitch -MockWith { return $standardSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VirtualSwitchName -and $VMHost -eq $script:vmHost -and $Standard } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.disconnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHost -and $Physical } -Verifiable

    $vmHostVssMigrationProperties
}

function New-MocksWhenTwoVMKernelNetworkAdaptersAndOnePortGroupArePassed {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssMigrationProperties = New-VMHostVssMigrationProperties

    $vmHostVssMigrationProperties.VssName = $script:constants.VirtualSwitchName
    $vmHostVssMigrationProperties.PhysicalNicNames = @($script:constants.DisconnectedPhysicalNetworkAdapterOneName)
    $vmHostVssMigrationProperties.VMKernelNicNames = @($script:constants.VMKernelNetworkAdapterOneName, $script:constants.VMKernelNetworkAdapterTwoName)
    $vmHostVssMigrationProperties.PortGroupNames = @($script:constants.PortGroupOneName)

    $standardSwitchMock = $script:standardSwitchWithOnePhysicalNetworkAdapter
    $physicalNetworkAdapterMock = $script:disconnectedPhysicalNetworkAdapterOne

    Mock -CommandName Get-VirtualSwitch -MockWith { return $standardSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VirtualSwitchName -and $VMHost -eq $script:vmHost -and $Standard } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.disconnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHost -and $Physical } -Verifiable

    $vmHostVssMigrationProperties
}

function New-MocksWhenZeroVMKernelNetworkAdaptersAndOnePortGroupArePassed {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssMigrationProperties = New-VMHostVssMigrationProperties

    $vmHostVssMigrationProperties.VssName = $script:constants.VirtualSwitchName
    $vmHostVssMigrationProperties.PhysicalNicNames = @($script:constants.DisconnectedPhysicalNetworkAdapterOneName)
    $vmHostVssMigrationProperties.VMKernelNicNames = @()
    $vmHostVssMigrationProperties.PortGroupNames = @($script:constants.PortGroupOneName)

    $standardSwitchMock = $script:standardSwitchWithOnePhysicalNetworkAdapter
    $physicalNetworkAdapterMock = $script:disconnectedPhysicalNetworkAdapterOne

    Mock -CommandName Get-VirtualSwitch -MockWith { return $standardSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VirtualSwitchName -and $VMHost -eq $script:vmHost -and $Standard } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.disconnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHost -and $Physical } -Verifiable

    $vmHostVssMigrationProperties
}

function New-MocksWhenOneVMKernelNetworkAdapterAndOnePortGroupArePassedAndTheVMKernelNetworkAdapterIsNotAddedToTheStandardSwitch {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssMigrationProperties = New-VMHostVssMigrationProperties

    $vmHostVssMigrationProperties.VssName = $script:constants.VirtualSwitchName
    $vmHostVssMigrationProperties.PhysicalNicNames = @($script:constants.DisconnectedPhysicalNetworkAdapterOneName)
    $vmHostVssMigrationProperties.VMKernelNicNames = @($script:constants.VMKernelNetworkAdapterOneName)
    $vmHostVssMigrationProperties.PortGroupNames = @($script:constants.PortGroupOneName)

    $standardSwitchMock = $script:standardSwitchWithOnePhysicalNetworkAdapter
    $physicalNetworkAdapterMock = $script:disconnectedPhysicalNetworkAdapterOne

    Mock -CommandName Get-VirtualSwitch -MockWith { return $standardSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VirtualSwitchName -and $VMHost -eq $script:vmHost -and $Standard } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.disconnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHost -and $Physical } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMKernelNetworkAdapterOneName -and $VMHost -eq $script:vmHost -and $VirtualSwitch -eq $script:standardSwitchWithOnePhysicalNetworkAdapter -and $PortGroup -eq $script:constants.PortGroupOneName -and $VMKernel } -Verifiable

    $vmHostVssMigrationProperties
}

function New-MocksWhenOneVMKernelNetworkAdapterAndOnePortGroupArePassedAndTheVMKernelNetworkAdapterIsAddedToTheStandardSwitch {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssMigrationProperties = New-VMHostVssMigrationProperties

    $vmHostVssMigrationProperties.VssName = $script:constants.VirtualSwitchName
    $vmHostVssMigrationProperties.PhysicalNicNames = @($script:constants.DisconnectedPhysicalNetworkAdapterOneName)
    $vmHostVssMigrationProperties.VMKernelNicNames = @($script:constants.VMKernelNetworkAdapterOneName)
    $vmHostVssMigrationProperties.PortGroupNames = @($script:constants.PortGroupOneName)

    $standardSwitchMock = $script:standardSwitchWithOnePhysicalNetworkAdapter
    $physicalNetworkAdapterMock = $script:disconnectedPhysicalNetworkAdapterOne
    $vmKernelNetworkAdapterMock = $script:vmKernelNetworkAdapterOne

    Mock -CommandName Get-VirtualSwitch -MockWith { return $standardSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VirtualSwitchName -and $VMHost -eq $script:vmHost -and $Standard } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $physicalNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.disconnectedPhysicalNetworkAdapterOneName -and $VMHost -eq $script:vmHost -and $Physical } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmKernelNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMKernelNetworkAdapterOneName -and $VMHost -eq $script:vmHost -and $VirtualSwitch -eq $script:standardSwitchWithOnePhysicalNetworkAdapter -and $PortGroup -eq $script:constants.PortGroupOneName -and $VMKernel } -Verifiable

    $vmHostVssMigrationProperties
}

function New-MocksInGet {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssMigrationProperties = New-VMHostVssMigrationProperties

    $vmHostVssMigrationProperties.VssName = $script:constants.VirtualSwitchName
    $vmHostVssMigrationProperties.PhysicalNicNames = @($script:constants.DisconnectedPhysicalNetworkAdapterOneName)
    $vmHostVssMigrationProperties.VMKernelNicNames = @($script:constants.VMKernelNetworkAdapterOneName)
    $vmHostVssMigrationProperties.PortGroupNames = @($script:constants.PortGroupOneName)

    $standardSwitchMock = $script:standardSwitchWithOnePhysicalNetworkAdapter
    $vmKernelNetworkAdapterMock = $script:vmKernelNetworkAdapterOne

    Mock -CommandName Get-VirtualSwitch -MockWith { return $standardSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VirtualSwitchName -and $VMHost -eq $script:vmHost -and $Standard } -Verifiable
    Mock -CommandName Get-VMHostNetworkAdapter -MockWith { return $vmKernelNetworkAdapterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VMHost -eq $script:vmHost -and $VirtualSwitch -eq $script:standardSwitchWithOnePhysicalNetworkAdapter -and $VMKernel } -Verifiable

    $vmHostVssMigrationProperties
}
