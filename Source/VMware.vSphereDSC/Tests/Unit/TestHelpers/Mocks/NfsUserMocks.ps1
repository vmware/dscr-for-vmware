<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-NfsUserProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $nfsUserProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        VMHostName = $script:constants.VMHostName
        Name = $script:constants.NfsUsername
    }

    $nfsUserProperties
}

function New-MocksForNfsUser {
    [CmdletBinding()]

    $viServerMock = $script:viServer
    $vmHostMock = $script:vmHost

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable
    Mock -CommandName Disconnect-VIServer -MockWith { return $null }.GetNewClosure() -Verifiable
}

function New-MocksWhenEnsureIsPresentTheNfsUserIsNotCreatedAndErrorOccursWhileCreatingTheNfsUser {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $nfsUserProperties = New-NfsUserProperties

    $nfsUserProperties.Password = $script:constants.NfsUserPasswordOne
    $nfsUserProperties.Ensure = 'Present'

    Mock -CommandName Get-NfsUser -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Username -eq $script:constants.NfsUsername -and $VMHost -eq $script:vmHost } -Verifiable
    Mock -CommandName New-NfsUser -MockWith { throw }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Username -eq $script:constants.NfsUsername -and $VMHost -eq $script:vmHost -and $Password -eq $script:constants.NfsUserPasswordOne -and !$Confirm } -Verifiable

    $nfsUserProperties
}

function New-MocksWhenEnsureIsPresentTheNfsUserIsNotCreatedAndNoErrorOccursWhileCreatingTheNfsUser {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $nfsUserProperties = New-NfsUserProperties

    $nfsUserProperties.Password = $script:constants.NfsUserPasswordOne
    $nfsUserProperties.Ensure = 'Present'

    Mock -CommandName Get-NfsUser -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Username -eq $script:constants.NfsUsername -and $VMHost -eq $script:vmHost } -Verifiable
    Mock -CommandName New-NfsUser -MockWith { return $null }.GetNewClosure() -Verifiable

    $nfsUserProperties
}

function New-MocksWhenEnsureIsPresentTheNfsUserIsAlreadyCreatedAndErrorOccursWhileChangingThePasswordOfTheNfsUser {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $nfsUserProperties = New-NfsUserProperties

    $nfsUserProperties.Password = $script:constants.NfsUserPasswordTwo
    $nfsUserProperties.Ensure = 'Present'
    $nfsUserProperties.Force = $true

    $nfsUserMock = $script:nfsUser

    Mock -CommandName Get-NfsUser -MockWith { return $nfsUserMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Username -eq $script:constants.NfsUsername -and $VMHost -eq $script:vmHost } -Verifiable
    Mock -CommandName Set-NfsUser -MockWith { throw }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $NfsUser -eq $script:nfsUser -and $Password -eq $script:constants.NfsUserPasswordTwo -and !$Confirm } -Verifiable

    $nfsUserProperties
}

function New-MocksWhenEnsureIsPresentTheNfsUserIsAlreadyCreatedAndThePasswordShouldBeChanged {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $nfsUserProperties = New-NfsUserProperties

    $nfsUserProperties.Password = $script:constants.NfsUserPasswordTwo
    $nfsUserProperties.Ensure = 'Present'
    $nfsUserProperties.Force = $true

    $nfsUserMock = $script:nfsUser

    Mock -CommandName Get-NfsUser -MockWith { return $nfsUserMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Username -eq $script:constants.NfsUsername -and $VMHost -eq $script:vmHost } -Verifiable
    Mock -CommandName Set-NfsUser -MockWith { return $null }.GetNewClosure() -Verifiable

    $nfsUserProperties
}

function New-MocksWhenEnsureIsAbsentAndTheNfsUserIsAlreadyRemoved {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $nfsUserProperties = New-NfsUserProperties

    $nfsUserProperties.Ensure = 'Absent'

    Mock -CommandName Get-NfsUser -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Username -eq $script:constants.NfsUsername -and $VMHost -eq $script:vmHost } -Verifiable
    Mock -CommandName Remove-NfsUser -MockWith { return $null }.GetNewClosure()

    $nfsUserProperties
}

function New-MocksWhenEnsureIsAbsentTheNfsUserIsNotRemovedAndErrorOccursWhileRemovingTheNfsUser {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $nfsUserProperties = New-NfsUserProperties

    $nfsUserProperties.Ensure = 'Absent'

    $nfsUserMock = $script:nfsUser

    Mock -CommandName Get-NfsUser -MockWith { return $nfsUserMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Username -eq $script:constants.NfsUsername -and $VMHost -eq $script:vmHost } -Verifiable
    Mock -CommandName Remove-NfsUser -MockWith { throw }.GetNewClosure() -ParameterFilter { $NfsUser -eq $script:nfsUser -and !$Confirm } -Verifiable

    $nfsUserProperties
}

function New-MocksWhenEnsureIsAbsentTheNfsUserIsNotRemovedAndNoErrorOccursWhileRemovingTheNfsUser {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $nfsUserProperties = New-NfsUserProperties

    $nfsUserProperties.Ensure = 'Absent'

    $nfsUserMock = $script:nfsUser

    Mock -CommandName Get-NfsUser -MockWith { return $nfsUserMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Username -eq $script:constants.NfsUsername -and $VMHost -eq $script:vmHost } -Verifiable
    Mock -CommandName Remove-NfsUser -MockWith { return $null }.GetNewClosure() -Verifiable

    $nfsUserProperties
}

function New-MocksWhenEnsureIsPresentAndTheNfsUserIsNotCreated {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $nfsUserProperties = New-NfsUserProperties

    $nfsUserProperties.Ensure = 'Present'

    Mock -CommandName Get-NfsUser -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Username -eq $script:constants.NfsUsername -and $VMHost -eq $script:vmHost } -Verifiable

    $nfsUserProperties
}

function New-MocksWhenEnsureIsPresentTheNfsUserIsAlreadyCreatedAndForcePropertyIsSpecified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $nfsUserProperties = New-NfsUserProperties

    $nfsUserProperties.Ensure = 'Present'
    $nfsUserProperties.Force = $true

    $nfsUserMock = $script:nfsUser

    Mock -CommandName Get-NfsUser -MockWith { return $nfsUserMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Username -eq $script:constants.NfsUsername -and $VMHost -eq $script:vmHost } -Verifiable

    $nfsUserProperties
}

function New-MocksWhenEnsureIsPresentTheNfsUserIsAlreadyCreatedAndForcePropertyIsNotSpecified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $nfsUserProperties = New-NfsUserProperties

    $nfsUserProperties.Ensure = 'Present'

    $nfsUserMock = $script:nfsUser

    Mock -CommandName Get-NfsUser -MockWith { return $nfsUserMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Username -eq $script:constants.NfsUsername -and $VMHost -eq $script:vmHost } -Verifiable

    $nfsUserProperties
}

function New-MocksWhenEnsureIsAbsentAndTheNfsUserIsNotRemoved {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $nfsUserProperties = New-NfsUserProperties

    $nfsUserProperties.Ensure = 'Absent'

    $nfsUserMock = $script:nfsUser

    Mock -CommandName Get-NfsUser -MockWith { return $nfsUserMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Username -eq $script:constants.NfsUsername -and $VMHost -eq $script:vmHost } -Verifiable

    $nfsUserProperties
}
