<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-VMHostIScsiHbaTargetProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIScsiHbaTargetProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        VMHostName = $script:constants.VMHostName
        Address = $script:constants.IScsiHbaTargetAddress
        Port = $script:constants.IScsiHbaTargetPort
        IScsiHbaName = $script:constants.IScsiHbaDeviceName
        TargetType = $script:constants.IScsiHbaSendTargetType
        IScsiName = $script:constants.IScsiName
    }

    $vmHostIScsiHbaTargetProperties
}

function New-MocksForVMHostIScsiHbaTarget {
    [CmdletBinding()]

    $viServerMock = $script:viServer
    $vmHostMock = $script:vmHost
    $iScsiHbaMock = $script:iScsiHba

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHostHba -MockWith { return $iScsiHbaMock }.GetNewClosure() -Verifiable
    Mock -CommandName Disconnect-VIServer -MockWith { return $null }.GetNewClosure() -Verifiable
}

function New-MocksWhenEnsureIsPresentTheiSCSIHostBusAdapterTargetIsNotCreatedAndErrorOccursWhileCreatingTheiSCSIHostBusAdapterTarget {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIScsiHbaTargetProperties = New-VMHostIScsiHbaTargetProperties

    $vmHostIScsiHbaTargetProperties.Ensure = 'Present'

    Mock -CommandName Get-IScsiHbaTarget -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $IScsiHba -eq $script:iScsiHba -and $IPEndPoint -eq $script:constants.IScsiIPEndPoint -and $Type -eq $script:constants.IScsiHbaSendTargetType } -Verifiable
    Mock -CommandName New-IScsiHbaTarget -MockWith { throw }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Address -eq $script:constants.IScsiHbaTargetAddress -and $Port -eq $script:constants.IScsiHbaTargetPort -and $IScsiHba -eq $script:iScsiHba -and $Type -eq $script:constants.IScsiHbaSendTargetType -and !$Confirm } -Verifiable

    $vmHostIScsiHbaTargetProperties
}

function New-MocksWhenEnsureIsPresentTheiSCSIHostBusAdapterTargetIsNotCreatedAndNoErrorOccursWhileCreatingTheiSCSIHostBusAdapterSendTarget {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIScsiHbaTargetProperties = New-VMHostIScsiHbaTargetProperties

    $vmHostIScsiHbaTargetProperties.Ensure = 'Present'

    Mock -CommandName Get-IScsiHbaTarget -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $IScsiHba -eq $script:iScsiHba -and $IPEndPoint -eq $script:constants.IScsiIPEndPoint -and $Type -eq $script:constants.IScsiHbaSendTargetType } -Verifiable
    Mock -CommandName New-IScsiHbaTarget -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostIScsiHbaTargetProperties
}

function New-MocksWhenEnsureIsPresentTheiSCSIHostBusAdapterTargetIsNotCreatedAndNoErrorOccursWhileCreatingTheiSCSIHostBusAdapterStaticTarget {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIScsiHbaTargetProperties = New-VMHostIScsiHbaTargetProperties

    $vmHostIScsiHbaTargetProperties.TargetType = $script:constants.IScsiHbaStaticTargetType
    $vmHostIScsiHbaTargetProperties.Ensure = 'Present'

    Mock -CommandName Get-IScsiHbaTarget -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $IScsiHba -eq $script:iScsiHba -and $IPEndPoint -eq $script:constants.IScsiIPEndPoint } -Verifiable
    Mock -CommandName New-IScsiHbaTarget -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostIScsiHbaTargetProperties
}

function New-MocksWhenEnsureIsPresentTheiSCSIHostBusAdapterTargetIsAlreadyCreatedAndErrorOccursWhileModifyingTheCHAPSettingsOfTheiSCSIHostBusAdapterTarget {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIScsiHbaTargetProperties = New-VMHostIScsiHbaTargetProperties

    $vmHostIScsiHbaTargetProperties.Ensure = 'Present'

    $iScsiHbaTargetMock = $script:iScsiHbaTarget

    Mock -CommandName Get-IScsiHbaTarget -MockWith { return $iScsiHbaTargetMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $IScsiHba -eq $script:iScsiHba -and $IPEndPoint -eq $script:constants.IScsiIPEndPoint -and $Type -eq $script:constants.IScsiHbaSendTargetType } -Verifiable
    Mock -CommandName Set-IScsiHbaTarget -MockWith { throw }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Target -eq $script:iScsiHbaTarget -and !$Confirm } -Verifiable

    $vmHostIScsiHbaTargetProperties
}

function New-MocksWhenEnsureIsPresentTheiSCSIHostBusAdapterTargetIsAlreadyCreatedAndNoErrorOccursWhileModifyingTheCHAPSettingsOfTheiSCSIHostBusAdapterTarget {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIScsiHbaTargetProperties = New-VMHostIScsiHbaTargetProperties

    $vmHostIScsiHbaTargetProperties.Ensure = 'Present'

    $iScsiHbaTargetMock = $script:iScsiHbaTarget

    Mock -CommandName Get-IScsiHbaTarget -MockWith { return $iScsiHbaTargetMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $IScsiHba -eq $script:iScsiHba -and $IPEndPoint -eq $script:constants.IScsiIPEndPoint -and $Type -eq $script:constants.IScsiHbaSendTargetType } -Verifiable
    Mock -CommandName Set-IScsiHbaTarget -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostIScsiHbaTargetProperties
}

function New-MocksWhenEnsureIsAbsentAndTheiSCSIHostBusAdapterTargetIsAlreadyRemoved {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIScsiHbaTargetProperties = New-VMHostIScsiHbaTargetProperties

    $vmHostIScsiHbaTargetProperties.Ensure = 'Absent'

    Mock -CommandName Get-IScsiHbaTarget -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $IScsiHba -eq $script:iScsiHba -and $IPEndPoint -eq $script:constants.IScsiIPEndPoint -and $Type -eq $script:constants.IScsiHbaSendTargetType } -Verifiable
    Mock -CommandName Remove-IScsiHbaTarget -MockWith { return $null }.GetNewClosure()

    $vmHostIScsiHbaTargetProperties
}

function New-MocksWhenEnsureIsAbsentTheiSCSIHostBusAdapterTargetIsNotRemovedAndErrorOccursWhileRemovingTheiSCSIHostBusAdapterTarget {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIScsiHbaTargetProperties = New-VMHostIScsiHbaTargetProperties

    $vmHostIScsiHbaTargetProperties.Ensure = 'Absent'

    $iScsiHbaTargetMock = $script:iScsiHbaTarget

    Mock -CommandName Get-IScsiHbaTarget -MockWith { return $iScsiHbaTargetMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $IScsiHba -eq $script:iScsiHba -and $IPEndPoint -eq $script:constants.IScsiIPEndPoint -and $Type -eq $script:constants.IScsiHbaSendTargetType } -Verifiable
    Mock -CommandName Remove-IScsiHbaTarget -MockWith { throw }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Target -eq $script:iScsiHbaTarget -and !$Confirm } -Verifiable

    $vmHostIScsiHbaTargetProperties
}

function New-MocksWhenEnsureIsAbsentTheiSCSIHostBusAdapterTargetIsNotRemovedAndNoErrorOccursWhileRemovingTheiSCSIHostBusAdapterTarget {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIScsiHbaTargetProperties = New-VMHostIScsiHbaTargetProperties

    $vmHostIScsiHbaTargetProperties.Ensure = 'Absent'

    $iScsiHbaTargetMock = $script:iScsiHbaTarget

    Mock -CommandName Get-IScsiHbaTarget -MockWith { return $iScsiHbaTargetMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $IScsiHba -eq $script:iScsiHba -and $IPEndPoint -eq $script:constants.IScsiIPEndPoint -and $Type -eq $script:constants.IScsiHbaSendTargetType } -Verifiable
    Mock -CommandName Remove-IScsiHbaTarget -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostIScsiHbaTargetProperties
}

function New-MocksWhenEnsureIsPresentAndTheiSCSIHostBusAdapterTargetIsNotCreated {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIScsiHbaTargetProperties = New-VMHostIScsiHbaTargetProperties

    $vmHostIScsiHbaTargetProperties.Ensure = 'Present'

    Mock -CommandName Get-IScsiHbaTarget -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $IScsiHba -eq $script:iScsiHba -and $IPEndPoint -eq $script:constants.IScsiIPEndPoint -and $Type -eq $script:constants.IScsiHbaSendTargetType } -Verifiable

    $vmHostIScsiHbaTargetProperties
}

function New-MocksWhenEnsureIsPresentTheiSCSIHostBusAdapterTargetIsAlreadyCreatedAndCHAPSettingsDoNotNeedToBeModified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIScsiHbaTargetProperties = New-VMHostIScsiHbaTargetProperties

    $vmHostIScsiHbaTargetProperties.Ensure = 'Present'

    $iScsiHbaTargetMock = $script:iScsiHbaTarget

    Mock -CommandName Get-IScsiHbaTarget -MockWith { return $iScsiHbaTargetMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $IScsiHba -eq $script:iScsiHba -and $IPEndPoint -eq $script:constants.IScsiIPEndPoint -and $Type -eq $script:constants.IScsiHbaSendTargetType } -Verifiable

    $vmHostIScsiHbaTargetProperties
}

function New-MocksWhenEnsureIsPresentTheiSCSIHostBusAdapterTargetIsAlreadyCreatedAndCHAPSettingsNeedToBeModified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIScsiHbaTargetProperties = New-VMHostIScsiHbaTargetProperties

    $vmHostIScsiHbaTargetProperties.Ensure = 'Present'
    $vmHostIScsiHbaTargetProperties.InheritChap = !$script:constants.ChapInherited

    $iScsiHbaTargetMock = $script:iScsiHbaTarget

    Mock -CommandName Get-IScsiHbaTarget -MockWith { return $iScsiHbaTargetMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $IScsiHba -eq $script:iScsiHba -and $IPEndPoint -eq $script:constants.IScsiIPEndPoint -and $Type -eq $script:constants.IScsiHbaSendTargetType } -Verifiable

    $vmHostIScsiHbaTargetProperties
}

function New-MocksWhenEnsureIsAbsentAndTheiSCSIHostBusAdapterTargetIsNotRemoved {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIScsiHbaTargetProperties = New-VMHostIScsiHbaTargetProperties

    $vmHostIScsiHbaTargetProperties.Ensure = 'Absent'

    $iScsiHbaTargetMock = $script:iScsiHbaTarget

    Mock -CommandName Get-IScsiHbaTarget -MockWith { return $iScsiHbaTargetMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $IScsiHba -eq $script:iScsiHba -and $IPEndPoint -eq $script:constants.IScsiIPEndPoint -and $Type -eq $script:constants.IScsiHbaSendTargetType } -Verifiable

    $vmHostIScsiHbaTargetProperties
}
