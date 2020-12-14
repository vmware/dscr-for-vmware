<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-VMHostIScsiHbaProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIScsiHbaProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        VMHostName = $script:constants.VMHostName
        Name = $script:constants.IScsiHbaDeviceName
        ChapType = $script:constants.ChapTypeProhibited
        ChapName = $script:constants.ChapName
        ChapPassword = $script:constants.ChapPassword
        MutualChapEnabled = $script:constants.MutualChapEnabled
        MutualChapName = $script:constants.MutualChapName
        MutualChapPassword = $script:constants.MutualChapPassword
    }

    $vmHostIScsiHbaProperties
}

function New-MocksForVMHostIScsiHba {
    [CmdletBinding()]

    $viServerMock = $script:viServer
    $vmHostMock = $script:vmHost
    $iScsiHbaMock = $script:iScsiHba

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHostHba -MockWith { return $iScsiHbaMock }.GetNewClosure() -Verifiable
    Mock -CommandName Disconnect-VIServer -MockWith { return $null }.GetNewClosure() -Verifiable
}

function New-MocksWhenErrorOccursWhileConfiguringTheiSCSIHostBusAdapterCHAPSettings {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIScsiHbaProperties = New-VMHostIScsiHbaProperties

    Mock -CommandName Set-VMHostHba -MockWith { throw }.GetNewClosure() -ParameterFilter { $IScsiHba -eq $script:iScsiHba -and $ChapType -eq $script:constants.ChapTypeProhibited -and !$Confirm } -Verifiable

    $vmHostIScsiHbaProperties
}

function New-MocksWhenNoErrorOccursWhileConfiguringTheiSCSIHostBusAdapterCHAPSettings {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIScsiHbaProperties = New-VMHostIScsiHbaProperties

    Mock -CommandName Set-VMHostHba -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostIScsiHbaProperties
}

function New-MocksWhenModifyingTheIScsiNameOfTheIScsiHostBusAdapter {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIScsiHbaProperties = New-VMHostIScsiHbaProperties

    $vmHostIScsiHbaProperties.IScsiName = $script:constants.IScsiName

    Mock -CommandName Set-VMHostHba -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostIScsiHbaProperties
}

function New-MocksWhenTheCHAPSettingsOfTheiSCSIHostBusAdapterDoNotNeedToBeModified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIScsiHbaProperties = New-VMHostIScsiHbaProperties

    $vmHostIScsiHbaProperties.ChapType = $script:constants.ChapTypeRequired

    $vmHostIScsiHbaProperties
}

function New-MocksWhenTheCHAPSettingsOfTheiSCSIHostBusAdapterNeedToBeModified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIScsiHbaProperties = New-VMHostIScsiHbaProperties

    $vmHostIScsiHbaProperties
}

function New-MocksWhenTheIScsiNameOfTheIScsiHostBusAdapterDoesNotNeedToBeModified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIScsiHbaProperties = New-VMHostIScsiHbaProperties

    $vmHostIScsiHbaProperties.IScsiName = $script:constants.IScsiName
    $vmHostIScsiHbaProperties.ChapType = $script:constants.ChapTypeRequired

    $vmHostIScsiHbaProperties
}

function New-MocksWhenTheIScsiNameOfTheIScsiHostBusAdapterNeedsToBeModified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIScsiHbaProperties = New-VMHostIScsiHbaProperties

    $vmHostIScsiHbaProperties.IScsiName = $script:constants.IScsiNameTwo

    $vmHostIScsiHbaProperties
}
