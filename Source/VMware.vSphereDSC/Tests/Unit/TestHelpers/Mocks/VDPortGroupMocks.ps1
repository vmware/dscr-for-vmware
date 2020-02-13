<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-VDPortGroupProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vdPortGroupProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        Name = $script:constants.DistributedPortGroupName
        VdsName = $script:constants.DistributedSwitchName
        Ensure = 'Present'
    }

    $vdPortGroupProperties
}

function New-MocksForVDPortGroup {
    [CmdletBinding()]

    $viServerMock = $script:viServer
    $distributedSwitchMock = $script:distributedSwitch

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VDSwitch -MockWith { return $distributedSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName } -Verifiable
    Mock -CommandName Disconnect-VIServer -MockWith { return $null }.GetNewClosure() -Verifiable
}

function New-MocksWhenDistributedPortGroupDoesNotExistDistributedPortGroupSettingsAreNotPassedAndEnsureIsPresent {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vdPortGroupProperties = New-VDPortGroupProperties

    Mock -CommandName Get-VDPortGroup -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedPortGroupName -and $VDSwitch -eq $script:distributedSwitch } -Verifiable
    Mock -CommandName New-VDPortGroup -MockWith { return $null }.GetNewClosure() -Verifiable

    $vdPortGroupProperties
}

function New-MocksWhenDistributedPortGroupDoesNotExistDistributedPortGroupSettingsArePassedAndEnsureIsPresent {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vdPortGroupProperties = New-VDPortGroupProperties

    $vdPortGroupProperties.Notes = $script:constants.DistributedPortGroupNotes
    $vdPortGroupProperties.NumPorts = $script:constants.DistributedPortGroupNumPorts
    $vdPortGroupProperties.PortBinding = $script:constants.DistributedPortGroupStaticPortBinding

    Mock -CommandName Get-VDPortGroup -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedPortGroupName -and $VDSwitch -eq $script:distributedSwitch } -Verifiable
    Mock -CommandName New-VDPortGroup -MockWith { return $null }.GetNewClosure() -Verifiable

    $vdPortGroupProperties
}

function New-MocksWhenDistributedPortGroupDoesNotExistReferenceDistributedPortGroupIsPassedAndEnsureIsPresent {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vdPortGroupProperties = New-VDPortGroupProperties

    $vdPortGroupProperties.ReferenceVDPortGroupName = $script:constants.ReferenceDistributedPortGroupName

    Mock -CommandName Get-VDPortGroup -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedPortGroupName -and $VDSwitch -eq $script:distributedSwitch } -Verifiable
    Mock -CommandName New-VDPortGroup -MockWith { return $null }.GetNewClosure() -Verifiable

    $vdPortGroupProperties
}

function New-MocksWhenDistributedPortGroupExistsDistributedPortGroupSettingsArePassedAndNeedToBeUpdatedAndEnsureIsPresent {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vdPortGroupProperties = New-VDPortGroupProperties

    $vdPortGroupProperties.NumPorts = $script:constants.DistributedPortGroupNumPorts + $script:constants.DistributedPortGroupNumPorts
    $vdPortGroupProperties.PortBinding = $script:constants.DistributedPortGroupDynamicPortBinding

    $distributedPortGroupMock = $script:distributedPortGroup

    Mock -CommandName Get-VDPortGroup -MockWith { return $distributedPortGroupMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedPortGroupName -and $VDSwitch -eq $script:distributedSwitch } -Verifiable
    Mock -CommandName Set-VDPortGroup -MockWith { return $null }.GetNewClosure() -Verifiable

    $vdPortGroupProperties
}

function New-MocksInSetWhenDistributedPortGroupDoesNotExistAndEnsureIsAbsent {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vdPortGroupProperties = New-VDPortGroupProperties

    $vdPortGroupProperties.Ensure = 'Absent'

    Mock -CommandName Get-VDPortGroup -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedPortGroupName -and $VDSwitch -eq $script:distributedSwitch } -Verifiable
    Mock -CommandName Remove-VDPortGroup -MockWith { return $null }.GetNewClosure()

    $vdPortGroupProperties
}

function New-MocksInSetWhenDistributedPortGroupExistsAndEnsureIsAbsent {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vdPortGroupProperties = New-VDPortGroupProperties

    $vdPortGroupProperties.Ensure = 'Absent'

    $distributedPortGroupMock = $script:distributedPortGroup

    Mock -CommandName Get-VDPortGroup -MockWith { return $distributedPortGroupMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedPortGroupName -and $VDSwitch -eq $script:distributedSwitch } -Verifiable
    Mock -CommandName Remove-VDPortGroup -MockWith { return $null }.GetNewClosure() -Verifiable

    $vdPortGroupProperties
}

function New-MocksWhenDistributedPortGroupDoesNotExistAndEnsureIsPresent {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vdPortGroupProperties = New-VDPortGroupProperties

    Mock -CommandName Get-VDPortGroup -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedPortGroupName -and $VDSwitch -eq $script:distributedSwitch } -Verifiable

    $vdPortGroupProperties
}

function New-MocksWhenDistributedPortGroupExistsAndEnsureIsPresent {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vdPortGroupProperties = New-VDPortGroupProperties

    $distributedPortGroupMock = $script:distributedPortGroup

    Mock -CommandName Get-VDPortGroup -MockWith { return $distributedPortGroupMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedPortGroupName -and $VDSwitch -eq $script:distributedSwitch } -Verifiable

    $vdPortGroupProperties
}

function New-MocksWhenDistributedPortGroupExistsPassedDistributedPortGroupSettingsAreEqualToTheServerSettingsAndEnsureIsPresent {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vdPortGroupProperties = New-VDPortGroupProperties

    $vdPortGroupProperties.Notes = $script:constants.DistributedPortGroupNotes
    $vdPortGroupProperties.NumPorts = $script:constants.DistributedPortGroupNumPorts
    $vdPortGroupProperties.PortBinding = $script:constants.DistributedPortGroupStaticPortBinding

    $distributedPortGroupMock = $script:distributedPortGroup

    Mock -CommandName Get-VDPortGroup -MockWith { return $distributedPortGroupMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedPortGroupName -and $VDSwitch -eq $script:distributedSwitch } -Verifiable

    $vdPortGroupProperties
}

function New-MocksWhenDistributedPortGroupExistsPassedDistributedPortGroupSettingsAreNotEqualToTheServerSettingsAndEnsureIsPresent {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vdPortGroupProperties = New-VDPortGroupProperties

    $vdPortGroupProperties.Notes = $script:constants.DistributedPortGroupNotes
    $vdPortGroupProperties.NumPorts = $script:constants.DistributedPortGroupNumPorts + $script:constants.DistributedPortGroupNumPorts
    $vdPortGroupProperties.PortBinding = $script:constants.DistributedPortGroupDynamicPortBinding

    $distributedPortGroupMock = $script:distributedPortGroup

    Mock -CommandName Get-VDPortGroup -MockWith { return $distributedPortGroupMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedPortGroupName -and $VDSwitch -eq $script:distributedSwitch } -Verifiable

    $vdPortGroupProperties
}

function New-MocksWhenDistributedPortGroupDoesNotExistAndEnsureIsAbsent {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vdPortGroupProperties = New-VDPortGroupProperties

    $vdPortGroupProperties.Ensure = 'Absent'

    Mock -CommandName Get-VDPortGroup -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedPortGroupName -and $VDSwitch -eq $script:distributedSwitch } -Verifiable

    $vdPortGroupProperties
}

function New-MocksWhenDistributedPortGroupExistsAndEnsureIsAbsent {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vdPortGroupProperties = New-VDPortGroupProperties

    $vdPortGroupProperties.Ensure = 'Absent'

    $distributedPortGroupMock = $script:distributedPortGroup

    Mock -CommandName Get-VDPortGroup -MockWith { return $distributedPortGroupMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedPortGroupName -and $VDSwitch -eq $script:distributedSwitch } -Verifiable

    $vdPortGroupProperties
}
