<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-NfsDatastoreDSCProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $nfsDatastoreBaseDSCProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        VMHostName = $script:constants.VMHostName
        Name = $script:constants.DatastoreName
        Path = $script:constants.NfsPath
        NfsHost = $script:constants.NfsHost
    }

    $nfsDatastoreBaseDSCProperties
}

function New-MocksForNfsDatastore {
    [CmdletBinding()]

    $viServerMock = $script:viServer
    $vmHostMock = $script:vmHost

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable
}

function New-MocksWhenEnsureIsPresentTheNfsDatastoreIsNotCreatedAndAccessModeAndAuthenticationMethodAreNotSpecified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $nfsDatastoreBaseDSCProperties = New-NfsDatastoreDSCProperties

    $nfsDatastoreBaseDSCProperties.Ensure = 'Present'

    $datastoreMock = $script:nfsDatastore

    Mock -CommandName Get-Datastore -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $VMHost -eq $script:vmHost }
    Mock -CommandName New-Datastore -MockWith { return $datastoreMock }.GetNewClosure()

    $nfsDatastoreBaseDSCProperties
}

function New-MocksWhenEnsureIsPresentTheNfsDatastoreIsNotCreatedAndAccessModeAndAuthenticationMethodAreSpecified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $nfsDatastoreBaseDSCProperties = New-NfsDatastoreDSCProperties

    $nfsDatastoreBaseDSCProperties.Ensure = 'Present'
    $nfsDatastoreBaseDSCProperties.AccessMode = $script:constants.AccessMode
    $nfsDatastoreBaseDSCProperties.AuthenticationMethod = $script:constants.AuthenticationMethod

    $datastoreMock = $script:nfsDatastore

    Mock -CommandName Get-Datastore -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $VMHost -eq $script:vmHost }
    Mock -CommandName New-Datastore -MockWith { return $datastoreMock }.GetNewClosure()

    $nfsDatastoreBaseDSCProperties
}

function New-MocksWhenEnsureIsPresentTheNfsDatastoreIsNotCreatedAndStorageIOControlEnabledAndCongestionThresholdMillisecondAreSpecified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $nfsDatastoreBaseDSCProperties = New-NfsDatastoreDSCProperties

    $nfsDatastoreBaseDSCProperties.Ensure = 'Present'
    $nfsDatastoreBaseDSCProperties.AccessMode = $script:constants.AccessMode
    $nfsDatastoreBaseDSCProperties.AuthenticationMethod = $script:constants.AuthenticationMethod
    $nfsDatastoreBaseDSCProperties.StorageIOControlEnabled = !$script:constants.StorageIOControlEnabled
    $nfsDatastoreBaseDSCProperties.CongestionThresholdMillisecond = $script:constants.CongestionThresholdMillisecond

    $datastoreMock = $script:nfsDatastore

    Mock -CommandName Get-Datastore -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $VMHost -eq $script:vmHost }
    Mock -CommandName New-Datastore -MockWith { return $datastoreMock }.GetNewClosure()
    Mock -CommandName Set-Datastore -MockWith { return $null }.GetNewClosure()

    $nfsDatastoreBaseDSCProperties
}

function New-MocksWhenEnsureIsAbsentAndTheNfsDatastoreIsAlreadyRemoved {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $nfsDatastoreBaseDSCProperties = New-NfsDatastoreDSCProperties

    $nfsDatastoreBaseDSCProperties.Ensure = 'Absent'

    Mock -CommandName Get-Datastore -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $VMHost -eq $script:vmHost }
    Mock -CommandName Remove-Datastore -MockWith { return $null }.GetNewClosure()

    $nfsDatastoreBaseDSCProperties
}

function New-MocksWhenEnsureIsAbsentAndTheNfsDatastoreIsNotRemoved {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $nfsDatastoreBaseDSCProperties = New-NfsDatastoreDSCProperties

    $nfsDatastoreBaseDSCProperties.Ensure = 'Absent'

    $datastoreMock = $script:nfsDatastore

    Mock -CommandName Get-Datastore -MockWith { return $datastoreMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $VMHost -eq $script:vmHost }
    Mock -CommandName Remove-Datastore -MockWith { return $null }.GetNewClosure()

    $nfsDatastoreBaseDSCProperties
}

function New-MocksWhenEnsureIsPresentAndTheNfsDatastoreIsNotCreated {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $nfsDatastoreBaseDSCProperties = New-NfsDatastoreDSCProperties

    $nfsDatastoreBaseDSCProperties.Ensure = 'Present'

    Mock -CommandName Get-Datastore -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $VMHost -eq $script:vmHost }

    $nfsDatastoreBaseDSCProperties
}

function New-MocksWhenEnsureIsPresentTheNfsDatastoreIsAlreadyCreatedAndDatastoreCongestionThresholdMillisecondAndStorageIOControlEnabledValuesDoNotNeedToBeModified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $nfsDatastoreBaseDSCProperties = New-NfsDatastoreDSCProperties

    $nfsDatastoreBaseDSCProperties.Ensure = 'Present'
    $nfsDatastoreBaseDSCProperties.StorageIOControlEnabled = $script:constants.StorageIOControlEnabled
    $nfsDatastoreBaseDSCProperties.CongestionThresholdMillisecond = $script:constants.MaxCongestionThresholdMillisecond

    $datastoreMock = $script:nfsDatastore

    Mock -CommandName Get-Datastore -MockWith { return $datastoreMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $VMHost -eq $script:vmHost }

    $nfsDatastoreBaseDSCProperties
}

function New-MocksWhenEnsureIsPresentTheNfsDatastoreIsAlreadyCreatedAndDatastoreCongestionThresholdMillisecondAndStorageIOControlEnabledValuesNeedToBeModified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $nfsDatastoreBaseDSCProperties = New-NfsDatastoreDSCProperties

    $nfsDatastoreBaseDSCProperties.Ensure = 'Present'
    $nfsDatastoreBaseDSCProperties.StorageIOControlEnabled = !$script:constants.StorageIOControlEnabled
    $nfsDatastoreBaseDSCProperties.CongestionThresholdMillisecond = $script:constants.CongestionThresholdMillisecond

    $datastoreMock = $script:nfsDatastore

    Mock -CommandName Get-Datastore -MockWith { return $datastoreMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $VMHost -eq $script:vmHost }

    $nfsDatastoreBaseDSCProperties
}

function New-MocksWhenTheNfsDatastoreDoesNotExist {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $nfsDatastoreBaseDSCProperties = New-NfsDatastoreDSCProperties

    Mock -CommandName Get-Datastore -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $VMHost -eq $script:vmHost } -Verifiable

    $nfsDatastoreBaseDSCProperties
}

function New-MocksWhenTheNfsDatastoreExists {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $nfsDatastoreBaseDSCProperties = New-NfsDatastoreDSCProperties

    $datastoreMock = $script:nfsDatastore

    Mock -CommandName Get-Datastore -MockWith { return $datastoreMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $VMHost -eq $script:vmHost } -Verifiable

    $nfsDatastoreBaseDSCProperties
}
