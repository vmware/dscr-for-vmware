<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-VMHostScsiLunPathProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostScsiLunPathProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        VMHostName = $script:constants.VMHostName
        Name = $script:constants.VMHostScsiLunPathName
        ScsiLunCanonicalName = $script:constants.VMHostScsiLunCanonicalName
    }

    $vmHostScsiLunPathProperties
}

function New-MocksForVMHostScsiLunPath {
    [CmdletBinding()]

    $viServerMock = $script:viServer
    $vmHostMock = $script:vmHost

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable
    Mock -CommandName Disconnect-VIServer -MockWith { return $null }.GetNewClosure() -Verifiable
}

function New-MocksWhenErrorOccursWhileConfiguringTheScsiLunPath {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostScsiLunPathProperties = New-VMHostScsiLunPathProperties

    $vmHostScsiLunPathProperties.Active = $script:constants.VMHostActiveScsiLunPath
    $vmHostScsiLunPathProperties.Preferred = $script:constants.VMHostPreferredScsiLunPath

    $vmHostScsiLunMock = $script:vmHostScsiLun
    $vmHostScsiLunPathMock = $script:vmHostScsiLunPath

    Mock -CommandName Get-ScsiLun -MockWith { return $vmHostScsiLunMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VmHost -eq $script:vmHost -and $CanonicalName -eq $script:constants.VMHostScsiLunCanonicalName } -Verifiable
    Mock -CommandName Get-ScsiLunPath -MockWith { return $vmHostScsiLunPathMock }.GetNewClosure() -ParameterFilter { $Name -eq $script:constants.VMHostScsiLunPathName -and $ScsiLun -eq $script:vmHostScsiLun } -Verifiable
    Mock -CommandName Set-ScsiLunPath -MockWith { throw }.GetNewClosure() -ParameterFilter { $ScsiLunPath -eq $script:vmHostScsiLunPath -and $Active -eq $script:constants.VMHostActiveScsiLunPath -and $Preferred -eq $script:constants.VMHostPreferredScsiLunPath -and !$Confirm } -Verifiable

    $vmHostScsiLunPathProperties
}

function New-MocksWhenNoErrorOccursWhileConfiguringTheScsiLunPath {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostScsiLunPathProperties = New-VMHostScsiLunPathProperties

    $vmHostScsiLunPathProperties.Active = $script:constants.VMHostActiveScsiLunPath
    $vmHostScsiLunPathProperties.Preferred = $script:constants.VMHostPreferredScsiLunPath

    $vmHostScsiLunMock = $script:vmHostScsiLun
    $vmHostScsiLunPathMock = $script:vmHostScsiLunPath

    Mock -CommandName Get-ScsiLun -MockWith { return $vmHostScsiLunMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VmHost -eq $script:vmHost -and $CanonicalName -eq $script:constants.VMHostScsiLunCanonicalName } -Verifiable
    Mock -CommandName Get-ScsiLunPath -MockWith { return $vmHostScsiLunPathMock }.GetNewClosure() -ParameterFilter { $Name -eq $script:constants.VMHostScsiLunPathName -and $ScsiLun -eq $script:vmHostScsiLun } -Verifiable
    Mock -CommandName Set-ScsiLunPath -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostScsiLunPathProperties
}

function New-MocksWhenTheScsiLunIsNotFound {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostScsiLunPathProperties = New-VMHostScsiLunPathProperties

    Mock -CommandName Get-ScsiLun -MockWith { throw }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VmHost -eq $script:vmHost -and $CanonicalName -eq $script:constants.VMHostScsiLunCanonicalName } -Verifiable

    $vmHostScsiLunPathProperties
}

function New-MocksWhenTheScsiLunPathIsNotFound {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostScsiLunPathProperties = New-VMHostScsiLunPathProperties

    $vmHostScsiLunMock = $script:vmHostScsiLun

    Mock -CommandName Get-ScsiLun -MockWith { return $vmHostScsiLunMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VmHost -eq $script:vmHost -and $CanonicalName -eq $script:constants.VMHostScsiLunCanonicalName } -Verifiable
    Mock -CommandName Get-ScsiLunPath -MockWith { throw }.GetNewClosure() -ParameterFilter { $Name -eq $script:constants.VMHostScsiLunPathName -and $ScsiLun -eq $script:vmHostScsiLun } -Verifiable

    $vmHostScsiLunPathProperties
}

function New-MocksWhenTheScsiLunPathStateIsActiveAndTheActivePropertyIsTrue {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostScsiLunPathProperties = New-VMHostScsiLunPathProperties

    $vmHostScsiLunPathProperties.Active = $script:constants.VMHostActiveScsiLunPath

    $vmHostScsiLunMock = $script:vmHostScsiLun
    $vmHostScsiLunPathMock = $script:vmHostScsiLunPath

    Mock -CommandName Get-ScsiLun -MockWith { return $vmHostScsiLunMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VmHost -eq $script:vmHost -and $CanonicalName -eq $script:constants.VMHostScsiLunCanonicalName } -Verifiable
    Mock -CommandName Get-ScsiLunPath -MockWith { return $vmHostScsiLunPathMock }.GetNewClosure() -ParameterFilter { $Name -eq $script:constants.VMHostScsiLunPathName -and $ScsiLun -eq $script:vmHostScsiLun } -Verifiable

    $vmHostScsiLunPathProperties
}

function New-MocksWhenTheScsiLunPathStateIsActiveAndTheActivePropertyIsFalse {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostScsiLunPathProperties = New-VMHostScsiLunPathProperties

    $vmHostScsiLunPathProperties.Active = !$script:constants.VMHostActiveScsiLunPath

    $vmHostScsiLunMock = $script:vmHostScsiLun
    $vmHostScsiLunPathMock = $script:vmHostScsiLunPath

    Mock -CommandName Get-ScsiLun -MockWith { return $vmHostScsiLunMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VmHost -eq $script:vmHost -and $CanonicalName -eq $script:constants.VMHostScsiLunCanonicalName } -Verifiable
    Mock -CommandName Get-ScsiLunPath -MockWith { return $vmHostScsiLunPathMock }.GetNewClosure() -ParameterFilter { $Name -eq $script:constants.VMHostScsiLunPathName -and $ScsiLun -eq $script:vmHostScsiLun } -Verifiable

    $vmHostScsiLunPathProperties
}

function New-MocksWhenTheScsiLunPathIsPreferredAndThePreferredPropertyIsTrue {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostScsiLunPathProperties = New-VMHostScsiLunPathProperties

    $vmHostScsiLunPathProperties.Preferred = $script:constants.VMHostPreferredScsiLunPath

    $vmHostScsiLunMock = $script:vmHostScsiLun
    $vmHostScsiLunPathMock = $script:vmHostScsiLunPath

    Mock -CommandName Get-ScsiLun -MockWith { return $vmHostScsiLunMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VmHost -eq $script:vmHost -and $CanonicalName -eq $script:constants.VMHostScsiLunCanonicalName } -Verifiable
    Mock -CommandName Get-ScsiLunPath -MockWith { return $vmHostScsiLunPathMock }.GetNewClosure() -ParameterFilter { $Name -eq $script:constants.VMHostScsiLunPathName -and $ScsiLun -eq $script:vmHostScsiLun } -Verifiable

    $vmHostScsiLunPathProperties
}

function New-MocksWhenTheScsiLunPathIsPreferredAndThePreferredPropertyIsFalse {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostScsiLunPathProperties = New-VMHostScsiLunPathProperties

    $vmHostScsiLunPathProperties.Preferred = !$script:constants.VMHostPreferredScsiLunPath

    $vmHostScsiLunMock = $script:vmHostScsiLun
    $vmHostScsiLunPathMock = $script:vmHostScsiLunPath

    Mock -CommandName Get-ScsiLun -MockWith { return $vmHostScsiLunMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VmHost -eq $script:vmHost -and $CanonicalName -eq $script:constants.VMHostScsiLunCanonicalName } -Verifiable
    Mock -CommandName Get-ScsiLunPath -MockWith { return $vmHostScsiLunPathMock }.GetNewClosure() -ParameterFilter { $Name -eq $script:constants.VMHostScsiLunPathName -and $ScsiLun -eq $script:vmHostScsiLun } -Verifiable

    $vmHostScsiLunPathProperties
}

function New-MocksInGet {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostScsiLunPathProperties = New-VMHostScsiLunPathProperties

    $vmHostScsiLunMock = $script:vmHostScsiLun
    $vmHostScsiLunPathMock = $script:vmHostScsiLunPath

    Mock -CommandName Get-ScsiLun -MockWith { return $vmHostScsiLunMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VmHost -eq $script:vmHost -and $CanonicalName -eq $script:constants.VMHostScsiLunCanonicalName } -Verifiable
    Mock -CommandName Get-ScsiLunPath -MockWith { return $vmHostScsiLunPathMock }.GetNewClosure() -ParameterFilter { $Name -eq $script:constants.VMHostScsiLunPathName -and $ScsiLun -eq $script:vmHostScsiLun } -Verifiable

    $vmHostScsiLunPathProperties
}
