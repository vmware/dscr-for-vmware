<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-VDSwitchVMHostProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vdSwitchVMHostProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        VdsName = $script:constants.DistributedSwitchName
    }

    $vdSwitchVMHostProperties
}

function New-MocksForVDSwitchVMHost {
    [CmdletBinding()]

    $viServerMock = $script:viServer
    $distributedSwitchMock = $script:distributedSwitch

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VDSwitch -MockWith { return $distributedSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DistributedSwitchName } -Verifiable
}

function New-MocksWhenEnsurePresentTwoVMHostsAndOneOfThemIsAlreadyAddedToTheDistributedSwitch {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vdSwitchVMHostProperties = New-VDSwitchVMHostProperties

    $vdSwitchVMHostProperties.VMHostNames = @($script:constants.VMHostAddedToDistributedSwitchOneName, $script:constants.VMHostRemovedFromDistributedSwitchOneName)
    $vdSwitchVMHostProperties.Ensure = 'Present'

    $vmHostOneMock = $script:vmHostAddedToDistributedSwitchOne
    $vmHostTwoMock = $script:vmHostRemovedFromDistributedSwitchOne

    # Mock Write-WarningLog to avoid the warning output when executing the Unit Tests.
    Mock -CommandName Write-WarningLog -MockWith { return $null }.GetNewClosure() -Verifiable

    Mock -CommandName Get-VMHost -MockWith { return $vmHostOneMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMHostAddedToDistributedSwitchOneName } -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostTwoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMHostRemovedFromDistributedSwitchOneName } -Verifiable
    Mock -CommandName Add-VDSwitchVMHost -MockWith { return $null }.GetNewClosure() -Verifiable

    $vdSwitchVMHostProperties
}

function New-MocksWhenEnsurePresentAndTwoVMHostsThatAreNotAddedToTheDistributedSwitch {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vdSwitchVMHostProperties = New-VDSwitchVMHostProperties

    $vdSwitchVMHostProperties.VMHostNames = @($script:constants.VMHostRemovedFromDistributedSwitchOneName, $script:constants.VMHostRemovedFromDistributedSwitchTwoName)
    $vdSwitchVMHostProperties.Ensure = 'Present'

    $vmHostOneMock = $script:vmHostRemovedFromDistributedSwitchOne
    $vmHostTwoMock = $script:vmHostRemovedFromDistributedSwitchTwo

    Mock -CommandName Get-VMHost -MockWith { return $vmHostOneMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMHostRemovedFromDistributedSwitchOneName } -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostTwoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMHostRemovedFromDistributedSwitchTwoName } -Verifiable
    Mock -CommandName Add-VDSwitchVMHost -MockWith { return $null }.GetNewClosure() -Verifiable

    $vdSwitchVMHostProperties
}

function New-MocksWhenEnsureAbsentTwoVMHostsAndOneOfThemIsAlreadyRemovedFromTheDistributedSwitch {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vdSwitchVMHostProperties = New-VDSwitchVMHostProperties

    $vdSwitchVMHostProperties.VMHostNames = @($script:constants.VMHostAddedToDistributedSwitchOneName, $script:constants.VMHostRemovedFromDistributedSwitchOneName)
    $vdSwitchVMHostProperties.Ensure = 'Absent'

    $vmHostOneMock = $script:vmHostAddedToDistributedSwitchOne
    $vmHostTwoMock = $script:vmHostRemovedFromDistributedSwitchOne

    # Mock Write-WarningLog to avoid the warning output when executing the Unit Tests.
    Mock -CommandName Write-WarningLog -MockWith { return $null }.GetNewClosure() -Verifiable

    Mock -CommandName Get-VMHost -MockWith { return $vmHostOneMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMHostAddedToDistributedSwitchOneName } -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostTwoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMHostRemovedFromDistributedSwitchOneName } -Verifiable
    Mock -CommandName Remove-VDSwitchVMHost -MockWith { return $null }.GetNewClosure() -Verifiable

    $vdSwitchVMHostProperties
}

function New-MocksWhenEnsureAbsentAndTwoVMHostsThatAreNotRemovedFromTheDistributedSwitch {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vdSwitchVMHostProperties = New-VDSwitchVMHostProperties

    $vdSwitchVMHostProperties.VMHostNames = @($script:constants.VMHostAddedToDistributedSwitchOneName, $script:constants.VMHostAddedToDistributedSwitchTwoName)
    $vdSwitchVMHostProperties.Ensure = 'Absent'

    $vmHostOneMock = $script:vmHostAddedToDistributedSwitchOne
    $vmHostTwoMock = $script:vmHostAddedToDistributedSwitchTwo

    Mock -CommandName Get-VMHost -MockWith { return $vmHostOneMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMHostAddedToDistributedSwitchOneName } -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostTwoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMHostAddedToDistributedSwitchTwoName } -Verifiable
    Mock -CommandName Remove-VDSwitchVMHost -MockWith { return $null }.GetNewClosure() -Verifiable

    $vdSwitchVMHostProperties
}

function New-MocksWhenEnsurePresentAndVMHostThatIsNotAddedToTheDistributedSwitch {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vdSwitchVMHostProperties = New-VDSwitchVMHostProperties

    $vdSwitchVMHostProperties.VMHostNames = @($script:constants.VMHostRemovedFromDistributedSwitchOneName)
    $vdSwitchVMHostProperties.Ensure = 'Present'

    $vmHostMock = $script:vmHostRemovedFromDistributedSwitchOne

    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMHostRemovedFromDistributedSwitchOneName } -Verifiable

    $vdSwitchVMHostProperties
}

function New-MocksWhenEnsurePresentAndVMHostThatIsAddedToTheDistributedSwitch {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vdSwitchVMHostProperties = New-VDSwitchVMHostProperties

    $vdSwitchVMHostProperties.VMHostNames = @($script:constants.VMHostAddedToDistributedSwitchOneName)
    $vdSwitchVMHostProperties.Ensure = 'Present'

    $vmHostMock = $script:vmHostAddedToDistributedSwitchOne

    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMHostAddedToDistributedSwitchOneName } -Verifiable

    $vdSwitchVMHostProperties
}

function New-MocksWhenEnsureAbsentAndVMHostThatIsNotRemovedFromTheDistributedSwitch {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vdSwitchVMHostProperties = New-VDSwitchVMHostProperties

    $vdSwitchVMHostProperties.VMHostNames = @($script:constants.VMHostAddedToDistributedSwitchOneName)
    $vdSwitchVMHostProperties.Ensure = 'Absent'

    $vmHostMock = $script:vmHostAddedToDistributedSwitchOne

    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMHostAddedToDistributedSwitchOneName } -Verifiable

    $vdSwitchVMHostProperties
}

function New-MocksWhenEnsureAbsentAndVMHostThatIsRemovedFromTheDistributedSwitch {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vdSwitchVMHostProperties = New-VDSwitchVMHostProperties

    $vdSwitchVMHostProperties.VMHostNames = @($script:constants.VMHostRemovedFromDistributedSwitchOneName)
    $vdSwitchVMHostProperties.Ensure = 'Absent'

    $vmHostMock = $script:vmHostRemovedFromDistributedSwitchOne

    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMHostRemovedFromDistributedSwitchOneName } -Verifiable

    $vdSwitchVMHostProperties
}

function New-MocksInGet {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vdSwitchVMHostProperties = New-VDSwitchVMHostProperties

    $vdSwitchVMHostProperties.VMHostNames = @(
        $script:constants.VMHostAddedToDistributedSwitchOneName,
        $script:constants.VMHostAddedToDistributedSwitchTwoName,
        $script:constants.VMHostRemovedFromDistributedSwitchOneName,
        $script:constants.VMHostRemovedFromDistributedSwitchTwoName
    )
    $vdSwitchVMHostProperties.Ensure = 'Present'

    $vmHostOneMock = $script:vmHostAddedToDistributedSwitchOne
    $vmHostTwoMock = $script:vmHostAddedToDistributedSwitchTwo
    $vmHostThreeMock = $script:vmHostRemovedFromDistributedSwitchOne
    $vmHostFourMock = $script:vmHostRemovedFromDistributedSwitchTwo

    Mock -CommandName Get-VMHost -MockWith { return $vmHostOneMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMHostAddedToDistributedSwitchOneName } -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostTwoMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMHostAddedToDistributedSwitchTwoName } -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostThreeMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMHostRemovedFromDistributedSwitchOneName } -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostFourMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMHostRemovedFromDistributedSwitchTwoName } -Verifiable

    $vdSwitchVMHostProperties
}
