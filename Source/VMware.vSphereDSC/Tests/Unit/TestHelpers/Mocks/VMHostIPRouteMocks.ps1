<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-VMHostIPRouteProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIPRouteProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        Name = $script:constants.VMHostName
        Gateway = $script:constants.Gateway
        Destination = $script:constants.Destination
        PrefixLength = $script:constants.PrefixLength
    }

    $vmHostIPRouteProperties
}

function New-MocksForVMHostIPRoute {
    [CmdletBinding()]

    $viServerMock = $script:viServer
    $vmHostMock = $script:vmHost

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable
    Mock -CommandName Disconnect-VIServer -MockWith { return $null }.GetNewClosure() -Verifiable
}

function New-MocksWhenEnsureIsPresentTheIPRouteIsNotCreatedAndErrorOccursWhileCreatingTheIPRoute {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIPRouteProperties = New-VMHostIPRouteProperties

    $vmHostIPRouteProperties.Ensure = 'Present'

    Mock -CommandName Get-VMHostRoute -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VMHost -eq $script:vmHost } -Verifiable
    Mock -CommandName New-VMHostRoute -MockWith { throw }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VMHost -eq $script:vmHost -and $Gateway -eq $script:constants.Gateway -and $Destination -eq $script:constants.Destination -and $PrefixLength -eq $script:constants.PrefixLength -and !$Confirm } -Verifiable

    $vmHostIPRouteProperties
}

function New-MocksWhenEnsureIsPresentTheIPRouteIsNotCreatedAndNoErrorOccursWhileCreatingTheIPRoute {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIPRouteProperties = New-VMHostIPRouteProperties

    $vmHostIPRouteProperties.Ensure = 'Present'

    Mock -CommandName Get-VMHostRoute -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VMHost -eq $script:vmHost } -Verifiable
    Mock -CommandName New-VMHostRoute -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostIPRouteProperties
}

function New-MocksWhenEnsureIsAbsentAndTheIPRouteIsAlreadyRemoved {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIPRouteProperties = New-VMHostIPRouteProperties

    $vmHostIPRouteProperties.Ensure = 'Absent'

    Mock -CommandName Get-VMHostRoute -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VMHost -eq $script:vmHost } -Verifiable
    Mock -CommandName Remove-VMHostRoute -MockWith { return $null }.GetNewClosure()

    $vmHostIPRouteProperties
}

function New-MocksWhenEnsureIsAbsentTheIPRouteIsNotRemovedAndErrorOccursWhileRemovingTheIPRoute {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIPRouteProperties = New-VMHostIPRouteProperties

    $vmHostIPRouteProperties.Ensure = 'Absent'

    $vmHostIPRouteMock = $script:vmHostIPRouteOne

    Mock -CommandName Get-VMHostRoute -MockWith { return $vmHostIPRouteMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VMHost -eq $script:vmHost } -Verifiable
    Mock -CommandName Remove-VMHostRoute -MockWith { throw }.GetNewClosure() -ParameterFilter { $VMHostRoute -eq $script:vmHostIPRouteOne -and !$Confirm } -Verifiable

    $vmHostIPRouteProperties
}

function New-MocksWhenEnsureIsAbsentTheIPRouteIsNotRemovedAndNoErrorOccursWhileRemovingTheIPRoute {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIPRouteProperties = New-VMHostIPRouteProperties

    $vmHostIPRouteProperties.Ensure = 'Absent'

    $vmHostIPRouteMock = $script:vmHostIPRouteOne

    Mock -CommandName Get-VMHostRoute -MockWith { return $vmHostIPRouteMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VMHost -eq $script:vmHost } -Verifiable
    Mock -CommandName Remove-VMHostRoute -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostIPRouteProperties
}

function New-MocksWhenEnsureIsPresentAndTheIPRouteIsNotCreated {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIPRouteProperties = New-VMHostIPRouteProperties

    $vmHostIPRouteProperties.Ensure = 'Present'

    Mock -CommandName Get-VMHostRoute -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VMHost -eq $script:vmHost } -Verifiable

    $vmHostIPRouteProperties
}

function New-MocksWhenEnsureIsPresentAndTheIPRouteIsAlreadyCreated {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIPRouteProperties = New-VMHostIPRouteProperties

    $vmHostIPRouteProperties.Ensure = 'Present'

    $vmHostIPRouteMock = $script:vmHostIPRouteOne

    Mock -CommandName Get-VMHostRoute -MockWith { return $vmHostIPRouteMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VMHost -eq $script:vmHost } -Verifiable

    $vmHostIPRouteProperties
}

function New-MocksWhenEnsureIsAbsentAndTheIPRouteIsNotRemoved {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostIPRouteProperties = New-VMHostIPRouteProperties

    $vmHostIPRouteProperties.Ensure = 'Absent'

    $vmHostIPRouteMock = $script:vmHostIPRouteOne

    Mock -CommandName Get-VMHostRoute -MockWith { return $vmHostIPRouteMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VMHost -eq $script:vmHost } -Verifiable

    $vmHostIPRouteProperties
}
