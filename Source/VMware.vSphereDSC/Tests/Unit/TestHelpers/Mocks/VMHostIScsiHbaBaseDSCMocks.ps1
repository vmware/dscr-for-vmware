<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-VMHostIScsiHbaBaseDSCProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIScsiHbaBaseDSCProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        VMHostName = $script:constants.VMHostName
    }

    $vmHostIScsiHbaBaseDSCProperties
}

function New-MocksForVMHostIScsiHbaBaseDSC {
    [CmdletBinding()]

    $viServerMock = $script:viServer
    $vmHostMock = $script:vmHost

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable
}

function New-MocksWhenErrorOccursWhileRetrievingTheiSCSIHostBusAdapter {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIScsiHbaBaseDSCProperties = New-VMHostIScsiHbaBaseDSCProperties

    Mock -CommandName Get-VMHostHba -MockWith { throw }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VMHost -eq $script:vmHost -and $Device -eq $script:constants.IScsiHbaDeviceName -and $Type -eq $script:constants.IScsiDeviceType } -Verifiable

    $vmHostIScsiHbaBaseDSCProperties
}

function New-MocksWhenTheiSCSIHostBusAdapterIsRetrievedSuccessfully {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIScsiHbaBaseDSCProperties = New-VMHostIScsiHbaBaseDSCProperties

    $iScsiHbaMock = $script:iScsiHba

    Mock -CommandName Get-VMHostHba -MockWith { return $iScsiHbaMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VMHost -eq $script:vmHost -and $Device -eq $script:constants.IScsiHbaDeviceName -and $Type -eq $script:constants.IScsiDeviceType } -Verifiable

    $vmHostIScsiHbaBaseDSCProperties
}

function New-MocksWhenTheCHAPSettingsOfTheiSCSIHostBusAdapterDoNotNeedToBeModified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIScsiHbaBaseDSCProperties = New-VMHostIScsiHbaBaseDSCProperties

    $vmHostIScsiHbaBaseDSCProperties.ChapType = $script:constants.ChapTypeRequired
    $vmHostIScsiHbaBaseDSCProperties.ChapName = $script:constants.ChapName
    $vmHostIScsiHbaBaseDSCProperties.MutualChapEnabled = $script:constants.MutualChapEnabled
    $vmHostIScsiHbaBaseDSCProperties.MutualChapName = $script:constants.MutualChapName
    $vmHostIScsiHbaBaseDSCProperties.Force = $false

    $vmHostIScsiHbaBaseDSCProperties
}

function New-MocksWhenTheCHAPSettingsOfTheiSCSIHostBusAdapterNeedToBeModified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIScsiHbaBaseDSCProperties = New-VMHostIScsiHbaBaseDSCProperties

    $vmHostIScsiHbaBaseDSCProperties.ChapType = $script:constants.ChapTypeProhibited
    $vmHostIScsiHbaBaseDSCProperties.ChapName = $script:constants.ChapName
    $vmHostIScsiHbaBaseDSCProperties.MutualChapEnabled = $script:constants.MutualChapEnabled
    $vmHostIScsiHbaBaseDSCProperties.MutualChapName = $script:constants.MutualChapName
    $vmHostIScsiHbaBaseDSCProperties.Force = $false

    $vmHostIScsiHbaBaseDSCProperties
}

function New-MocksWhenInheritChapAndInheritMutualChapAreNotSpecifiedAndChapTypeIsRequired {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIScsiHbaBaseDSCProperties = New-VMHostIScsiHbaBaseDSCProperties

    $vmHostIScsiHbaBaseDSCProperties.ChapType = $script:constants.ChapTypeRequired
    $vmHostIScsiHbaBaseDSCProperties.ChapName = $script:constants.ChapName
    $vmHostIScsiHbaBaseDSCProperties.ChapPassword = $script:constants.ChapPassword
    $vmHostIScsiHbaBaseDSCProperties.MutualChapEnabled = $script:constants.MutualChapEnabled
    $vmHostIScsiHbaBaseDSCProperties.MutualChapName = $script:constants.MutualChapName
    $vmHostIScsiHbaBaseDSCProperties.MutualChapPassword = $script:constants.MutualChapPassword

    $vmHostIScsiHbaBaseDSCProperties
}

function New-MocksWhenInheritChapAndInheritMutualChapAreNotSpecifiedAndChapTypeIsProhibited {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIScsiHbaBaseDSCProperties = New-VMHostIScsiHbaBaseDSCProperties

    $vmHostIScsiHbaBaseDSCProperties.ChapType = $script:constants.ChapTypeProhibited
    $vmHostIScsiHbaBaseDSCProperties.ChapName = $script:constants.ChapName
    $vmHostIScsiHbaBaseDSCProperties.ChapPassword = $script:constants.ChapPassword
    $vmHostIScsiHbaBaseDSCProperties.MutualChapEnabled = $script:constants.MutualChapEnabled
    $vmHostIScsiHbaBaseDSCProperties.MutualChapName = $script:constants.MutualChapName
    $vmHostIScsiHbaBaseDSCProperties.MutualChapPassword = $script:constants.MutualChapPassword

    $vmHostIScsiHbaBaseDSCProperties
}

function New-MocksWhenInheritChapAndInheritMutualChapAreNotSpecifiedChapTypeIsRequiredAndMutualChapEnabledIsFalse {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIScsiHbaBaseDSCProperties = New-VMHostIScsiHbaBaseDSCProperties

    $vmHostIScsiHbaBaseDSCProperties.ChapType = $script:constants.ChapTypeRequired
    $vmHostIScsiHbaBaseDSCProperties.ChapName = $script:constants.ChapName
    $vmHostIScsiHbaBaseDSCProperties.ChapPassword = $script:constants.ChapPassword
    $vmHostIScsiHbaBaseDSCProperties.MutualChapEnabled = !$script:constants.MutualChapEnabled
    $vmHostIScsiHbaBaseDSCProperties.MutualChapName = $script:constants.MutualChapName
    $vmHostIScsiHbaBaseDSCProperties.MutualChapPassword = $script:constants.MutualChapPassword

    $vmHostIScsiHbaBaseDSCProperties
}

function New-MocksWhenInheritChapAndInheritMutualChapAreBothSpecifiedWithFalseValue {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIScsiHbaBaseDSCProperties = New-VMHostIScsiHbaBaseDSCProperties

    $vmHostIScsiHbaBaseDSCProperties.ChapType = $script:constants.ChapTypeRequired
    $vmHostIScsiHbaBaseDSCProperties.ChapName = $script:constants.ChapName
    $vmHostIScsiHbaBaseDSCProperties.ChapPassword = $script:constants.ChapPassword
    $vmHostIScsiHbaBaseDSCProperties.MutualChapEnabled = $script:constants.MutualChapEnabled
    $vmHostIScsiHbaBaseDSCProperties.MutualChapName = $script:constants.MutualChapName
    $vmHostIScsiHbaBaseDSCProperties.MutualChapPassword = $script:constants.MutualChapPassword

    $vmHostIScsiHbaBaseDSCProperties
}

function New-MocksWhenInheritChapAndInheritMutualChapAreBothSpecifiedWithTrueValue {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIScsiHbaBaseDSCProperties = New-VMHostIScsiHbaBaseDSCProperties

    $vmHostIScsiHbaBaseDSCProperties.ChapType = $script:constants.ChapTypeRequired
    $vmHostIScsiHbaBaseDSCProperties.ChapName = $script:constants.ChapName
    $vmHostIScsiHbaBaseDSCProperties.ChapPassword = $script:constants.ChapPassword
    $vmHostIScsiHbaBaseDSCProperties.MutualChapEnabled = $script:constants.MutualChapEnabled
    $vmHostIScsiHbaBaseDSCProperties.MutualChapName = $script:constants.MutualChapName
    $vmHostIScsiHbaBaseDSCProperties.MutualChapPassword = $script:constants.MutualChapPassword

    $vmHostIScsiHbaBaseDSCProperties
}
