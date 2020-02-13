<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-VMHostScsiLunProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostScsiLunProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        VMHostName = $script:constants.VMHostName
        CanonicalName = $script:constants.VMHostScsiLunCanonicalName
    }

    $vmHostScsiLunProperties
}

function New-MocksForVMHostScsiLun {
    [CmdletBinding()]

    $viServerMock = $script:viServer
    $vmHostMock = $script:vmHost

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable
    Mock -CommandName Disconnect-VIServer -MockWith { return $null }.GetNewClosure() -Verifiable
}

function New-MocksWhenErrorOccursWhileModifyingTheScsiLunConfiguration {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostScsiLunProperties = New-VMHostScsiLunProperties

    $vmHostScsiLunProperties.MultipathPolicy = $script:constants.VMHostScsiLunMultipathPolicy
    $vmHostScsiLunProperties.PreferredScsiLunPathName = $script:constants.VMHostScsiLunPathName
    $vmHostScsiLunProperties.BlocksToSwitchPath = $script:constants.VMHostScsiLunBlocksToSwitchPath
    $vmHostScsiLunProperties.CommandsToSwitchPath = $script:constants.VMHostScsiLunCommandsToSwitchPath
    $vmHostScsiLunProperties.DeletePartitions = $script:constants.VMHostScsiLunDeletePartitions
    $vmHostScsiLunProperties.IsLocal = $script:constants.VMHostScsiLunIsLocal
    $vmHostScsiLunProperties.IsSsd = $script:constants.VMHostScsiLunIsSsd

    $vmHostScsiLunMock = $script:vmHostScsiLun
    $vmHostScsiLunPathMock = $script:vmHostScsiLunPath

    Mock -CommandName Get-ScsiLun -MockWith { return $vmHostScsiLunMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VmHost -eq $script:vmHost -and $CanonicalName -eq $script:constants.VMHostScsiLunCanonicalName } -Verifiable
    Mock -CommandName Get-ScsiLunPath -MockWith { return $vmHostScsiLunPathMock }.GetNewClosure() -ParameterFilter { $Name -eq $script:constants.VMHostScsiLunPathName -and $ScsiLun -eq $script:vmHostScsiLun } -Verifiable
    Mock -CommandName Set-ScsiLun -MockWith { throw }.GetNewClosure() -ParameterFilter { $ScsiLun -eq $script:vmHostScsiLun -and $MultipathPolicy -eq $script:constants.VMHostScsiLunMultipathPolicy -and $PreferredPath -eq $script:vmHostScsiLunPath -and $DeletePartitions -eq $script:constants.VMHostScsiLunDeletePartitions -and $IsLocal -eq $script:constants.VMHostScsiLunIsLocal -and $IsSsd -eq $script:constants.VMHostScsiLunIsSsd -and !$Confirm } -Verifiable

    $vmHostScsiLunProperties
}

function New-MocksWhenNoErrorOccursWhileModifyingTheScsiLunConfiguration {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostScsiLunProperties = New-VMHostScsiLunProperties

    $vmHostScsiLunProperties.MultipathPolicy = $script:constants.VMHostScsiLunMultipathPolicy
    $vmHostScsiLunProperties.PreferredScsiLunPathName = $script:constants.VMHostScsiLunPathName
    $vmHostScsiLunProperties.BlocksToSwitchPath = $script:constants.VMHostScsiLunBlocksToSwitchPath
    $vmHostScsiLunProperties.CommandsToSwitchPath = $script:constants.VMHostScsiLunCommandsToSwitchPath
    $vmHostScsiLunProperties.DeletePartitions = $script:constants.VMHostScsiLunDeletePartitions
    $vmHostScsiLunProperties.IsLocal = $script:constants.VMHostScsiLunIsLocal
    $vmHostScsiLunProperties.IsSsd = $script:constants.VMHostScsiLunIsSsd

    $vmHostScsiLunMock = $script:vmHostScsiLun
    $vmHostScsiLunPathMock = $script:vmHostScsiLunPath

    Mock -CommandName Get-ScsiLun -MockWith { return $vmHostScsiLunMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VmHost -eq $script:vmHost -and $CanonicalName -eq $script:constants.VMHostScsiLunCanonicalName } -Verifiable
    Mock -CommandName Get-ScsiLunPath -MockWith { return $vmHostScsiLunPathMock }.GetNewClosure() -ParameterFilter { $Name -eq $script:constants.VMHostScsiLunPathName -and $ScsiLun -eq $script:vmHostScsiLun } -Verifiable
    Mock -CommandName Set-ScsiLun -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostScsiLunProperties
}

function New-MocksWhenTheScsiLunIsNotFound {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostScsiLunProperties = New-VMHostScsiLunProperties

    Mock -CommandName Get-ScsiLun -MockWith { throw }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VmHost -eq $script:vmHost -and $CanonicalName -eq $script:constants.VMHostScsiLunCanonicalName } -Verifiable

    $vmHostScsiLunProperties
}

function New-MocksWhenTheScsiLunPathIsNotFound {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostScsiLunProperties = New-VMHostScsiLunProperties

    $vmHostScsiLunProperties.MultipathPolicy = $script:constants.VMHostScsiLunMultipathPolicy
    $vmHostScsiLunProperties.PreferredScsiLunPathName = $script:constants.VMHostScsiLunPathName

    $vmHostScsiLunMock = $script:vmHostScsiLun

    Mock -CommandName Get-ScsiLun -MockWith { return $vmHostScsiLunMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VmHost -eq $script:vmHost -and $CanonicalName -eq $script:constants.VMHostScsiLunCanonicalName } -Verifiable
    Mock -CommandName Get-ScsiLunPath -MockWith { throw }.GetNewClosure() -ParameterFilter { $Name -eq $script:constants.VMHostScsiLunPathName -and $ScsiLun -eq $script:vmHostScsiLun } -Verifiable

    $vmHostScsiLunProperties
}

function New-MocksWhenTheScsiLunConfigurationDoesNotNeedToBeModified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostScsiLunProperties = New-VMHostScsiLunProperties

    $vmHostScsiLunProperties.MultipathPolicy = $script:constants.VMHostScsiLunMultipathPolicy
    $vmHostScsiLunProperties.PreferredScsiLunPathName = $script:constants.VMHostScsiLunPathName
    $vmHostScsiLunProperties.BlocksToSwitchPath = $script:constants.VMHostScsiLunBlocksToSwitchPath
    $vmHostScsiLunProperties.CommandsToSwitchPath = $script:constants.VMHostScsiLunCommandsToSwitchPath
    $vmHostScsiLunProperties.DeletePartitions = $script:constants.VMHostScsiLunDeletePartitions
    $vmHostScsiLunProperties.IsLocal = $script:constants.VMHostScsiLunIsLocal
    $vmHostScsiLunProperties.IsSsd = $script:constants.VMHostScsiLunIsSsd

    $vmHostScsiLunMock = $script:vmHostScsiLun
    $vmHostScsiLunPathMock = $script:vmHostScsiLunPath
    $vmHostDiskMock = $script:vmHostDisk

    Mock -CommandName Get-ScsiLun -MockWith { return $vmHostScsiLunMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VmHost -eq $script:vmHost -and $CanonicalName -eq $script:constants.VMHostScsiLunCanonicalName } -Verifiable
    Mock -CommandName Get-ScsiLunPath -MockWith { return $vmHostScsiLunPathMock }.GetNewClosure() -ParameterFilter { $Name -eq $script:constants.VMHostScsiLunPathName -and $ScsiLun -eq $script:vmHostScsiLun } -Verifiable
    Mock -CommandName Get-VMHostDisk -MockWith { return $vmHostDiskMock }.GetNewClosure() -ParameterFilter { $ScsiLun -eq $script:vmHostScsiLun } -Verifiable

    $vmHostScsiLunProperties
}

function New-MocksWhenTheScsiLunPathIsNotPreferred {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostScsiLunProperties = New-VMHostScsiLunProperties

    $vmHostScsiLunProperties.MultipathPolicy = $script:constants.VMHostScsiLunMultipathPolicy
    $vmHostScsiLunProperties.PreferredScsiLunPathName = $script:constants.VMHostScsiLunPathName
    $vmHostScsiLunProperties.BlocksToSwitchPath = $script:constants.VMHostScsiLunBlocksToSwitchPath
    $vmHostScsiLunProperties.CommandsToSwitchPath = $script:constants.VMHostScsiLunCommandsToSwitchPath
    $vmHostScsiLunProperties.DeletePartitions = $script:constants.VMHostScsiLunDeletePartitions
    $vmHostScsiLunProperties.IsLocal = $script:constants.VMHostScsiLunIsLocal
    $vmHostScsiLunProperties.IsSsd = $script:constants.VMHostScsiLunIsSsd

    $vmHostScsiLunMock = $script:vmHostScsiLun
    $vmHostScsiLunPathMock = $script:notPreferredVMHostScsiLunPath
    $vmHostDiskMock = $script:vmHostDisk

    Mock -CommandName Get-ScsiLun -MockWith { return $vmHostScsiLunMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VmHost -eq $script:vmHost -and $CanonicalName -eq $script:constants.VMHostScsiLunCanonicalName } -Verifiable
    Mock -CommandName Get-ScsiLunPath -MockWith { return $vmHostScsiLunPathMock }.GetNewClosure() -ParameterFilter { $Name -eq $script:constants.VMHostScsiLunPathName -and $ScsiLun -eq $script:vmHostScsiLun } -Verifiable
    Mock -CommandName Get-VMHostDisk -MockWith { return $vmHostDiskMock }.GetNewClosure() -ParameterFilter { $ScsiLun -eq $script:vmHostScsiLun } -Verifiable

    $vmHostScsiLunProperties
}

function New-MocksWhenDiskPartitionsExistAndDeletePartitionsIsSpecified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostScsiLunProperties = New-VMHostScsiLunProperties

    $vmHostScsiLunProperties.MultipathPolicy = $script:constants.VMHostScsiLunMultipathPolicy
    $vmHostScsiLunProperties.PreferredScsiLunPathName = $script:constants.VMHostScsiLunPathName
    $vmHostScsiLunProperties.BlocksToSwitchPath = $script:constants.VMHostScsiLunBlocksToSwitchPath
    $vmHostScsiLunProperties.CommandsToSwitchPath = $script:constants.VMHostScsiLunCommandsToSwitchPath
    $vmHostScsiLunProperties.DeletePartitions = $script:constants.VMHostScsiLunDeletePartitions
    $vmHostScsiLunProperties.IsLocal = $script:constants.VMHostScsiLunIsLocal
    $vmHostScsiLunProperties.IsSsd = $script:constants.VMHostScsiLunIsSsd

    $vmHostScsiLunMock = $script:vmHostScsiLun
    $vmHostScsiLunPathMock = $script:vmHostScsiLunPath
    $vmHostDiskMock = $script:vmHostDiskWithPartitions

    Mock -CommandName Get-ScsiLun -MockWith { return $vmHostScsiLunMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VmHost -eq $script:vmHost -and $CanonicalName -eq $script:constants.VMHostScsiLunCanonicalName } -Verifiable
    Mock -CommandName Get-ScsiLunPath -MockWith { return $vmHostScsiLunPathMock }.GetNewClosure() -ParameterFilter { $Name -eq $script:constants.VMHostScsiLunPathName -and $ScsiLun -eq $script:vmHostScsiLun } -Verifiable
    Mock -CommandName Get-VMHostDisk -MockWith { return $vmHostDiskMock }.GetNewClosure() -ParameterFilter { $ScsiLun -eq $script:vmHostScsiLun } -Verifiable

    $vmHostScsiLunProperties
}

function New-MocksInGet {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostScsiLunProperties = New-VMHostScsiLunProperties

    $vmHostScsiLunProperties.MultipathPolicy = $script:constants.VMHostScsiLunMultipathPolicy
    $vmHostScsiLunProperties.PreferredScsiLunPathName = $script:constants.VMHostScsiLunPathName
    $vmHostScsiLunProperties.BlocksToSwitchPath = $script:constants.VMHostScsiLunBlocksToSwitchPath
    $vmHostScsiLunProperties.CommandsToSwitchPath = $script:constants.VMHostScsiLunCommandsToSwitchPath
    $vmHostScsiLunProperties.DeletePartitions = $script:constants.VMHostScsiLunDeletePartitions
    $vmHostScsiLunProperties.IsLocal = $script:constants.VMHostScsiLunIsLocal
    $vmHostScsiLunProperties.IsSsd = $script:constants.VMHostScsiLunIsSsd

    $vmHostScsiLunMock = $script:vmHostScsiLun
    $vmHostScsiLunPathMock = $script:vmHostScsiLunPath

    Mock -CommandName Get-ScsiLun -MockWith { return $vmHostScsiLunMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VmHost -eq $script:vmHost -and $CanonicalName -eq $script:constants.VMHostScsiLunCanonicalName } -Verifiable
    Mock -CommandName Get-ScsiLunPath -MockWith { return $vmHostScsiLunPathMock }.GetNewClosure() -ParameterFilter { $ScsiLun -eq $script:vmHostScsiLun } -Verifiable

    $vmHostScsiLunProperties
}
