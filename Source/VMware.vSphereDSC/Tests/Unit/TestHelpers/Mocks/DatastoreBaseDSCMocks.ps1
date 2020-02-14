<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-DatastoreDSCProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $datastoreBaseDSCProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        VMHostName = $script:constants.VMHostName
        Name = $script:constants.DatastoreName
        Path = $script:constants.ScsiLunCanonicalName
    }

    $datastoreBaseDSCProperties
}

function New-MocksForDatastoreBaseDSC {
    [CmdletBinding()]

    $viServerMock = $script:viServer
    $vmHostMock = $script:vmHost

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable
}

function New-MocksWhenTheDatastoreDoesNotExist {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $datastoreBaseDSCProperties = New-DatastoreDSCProperties

    Mock -CommandName Get-Datastore -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $VMHost -eq $script:vmHost } -Verifiable

    $datastoreBaseDSCProperties
}

function New-MocksWhenTheDatastoreExists {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $datastoreBaseDSCProperties = New-DatastoreDSCProperties

    $datastoreMock = $script:datastore

    Mock -CommandName Get-Datastore -MockWith { return $datastoreMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $VMHost -eq $script:vmHost } -Verifiable

    $datastoreBaseDSCProperties
}

function New-MocksWhenDatastoreCongestionThresholdMillisecondAndStorageIOControlEnabledValuesDoNotNeedToBeModified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $datastoreBaseDSCProperties = New-DatastoreDSCProperties

    $datastoreBaseDSCProperties.StorageIOControlEnabled = $script:constants.StorageIOControlEnabled
    $datastoreBaseDSCProperties.CongestionThresholdMillisecond = $script:constants.MaxCongestionThresholdMillisecond

    $datastoreMock = $script:datastore

    Mock -CommandName Get-Datastore -MockWith { return $datastoreMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $VMHost -eq $script:vmHost } -Verifiable

    $datastoreBaseDSCProperties
}

function New-MocksWhenDatastoreCongestionThresholdMillisecondAndStorageIOControlEnabledValuesNeedToBeModified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $datastoreBaseDSCProperties = New-DatastoreDSCProperties

    $datastoreBaseDSCProperties.StorageIOControlEnabled = !$script:constants.StorageIOControlEnabled
    $datastoreBaseDSCProperties.CongestionThresholdMillisecond = $script:constants.CongestionThresholdMillisecond

    $datastoreMock = $script:datastore

    Mock -CommandName Get-Datastore -MockWith { return $datastoreMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $VMHost -eq $script:vmHost } -Verifiable

    $datastoreBaseDSCProperties
}

function New-MocksWhenErrorOccursWhileCreatingTheDatastore {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $datastoreBaseDSCProperties = New-DatastoreDSCProperties

    Mock -CommandName New-Datastore -MockWith { throw }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $VMHost -eq $script:vmHost -and $Path -eq $script:constants.ScsiLunCanonicalName -and !$Confirm } -Verifiable

    $datastoreBaseDSCProperties
}

function New-MocksWhenFileSystemVersionIsNotSpecified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $datastoreBaseDSCProperties = New-DatastoreDSCProperties

    $datastoreMock = $script:datastore

    Mock -CommandName New-Datastore -MockWith { return $datastoreMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $VMHost -eq $script:vmHost -and $Path -eq $script:constants.ScsiLunCanonicalName -and !$Confirm } -Verifiable

    $datastoreBaseDSCProperties
}

function New-MocksWhenFileSystemVersionIsSpecified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $datastoreBaseDSCProperties = New-DatastoreDSCProperties

    $datastoreBaseDSCProperties.FileSystemVersion = $script:constants.FileSystemVersion

    $datastoreMock = $script:datastore

    Mock -CommandName New-Datastore -MockWith { return $datastoreMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $VMHost -eq $script:vmHost -and $Path -eq $script:constants.ScsiLunCanonicalName -and $FileSystemVersion -eq $script:constants.FileSystemVersion -and !$Confirm } -Verifiable

    $datastoreBaseDSCProperties
}

function New-MocksWhenErrorOccursWhileModifyingTheDatastore {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $datastoreBaseDSCProperties = New-DatastoreDSCProperties

    $datastoreMock = $script:datastore

    Mock -CommandName Get-Datastore -MockWith { return $datastoreMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $VMHost -eq $script:vmHost } -Verifiable
    Mock -CommandName Set-Datastore -MockWith { throw }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Datastore -eq $script:datastore -and !$Confirm } -Verifiable

    $datastoreBaseDSCProperties
}

function New-MocksWhenStorageIOControlEnabledAndCongestionThresholdMillisecondAreNotSpecified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $datastoreBaseDSCProperties = New-DatastoreDSCProperties

    $datastoreMock = $script:datastore

    Mock -CommandName Get-Datastore -MockWith { return $datastoreMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $VMHost -eq $script:vmHost } -Verifiable
    Mock -CommandName Set-Datastore -MockWith { return $null }.GetNewClosure() -Verifiable

    $datastoreBaseDSCProperties
}

function New-MocksWhenStorageIOControlEnabledAndCongestionThresholdMillisecondAreSpecified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $datastoreBaseDSCProperties = New-DatastoreDSCProperties

    $datastoreBaseDSCProperties.StorageIOControlEnabled = $script:constants.StorageIOControlEnabled
    $datastoreBaseDSCProperties.CongestionThresholdMillisecond = $script:constants.MaxCongestionThresholdMillisecond

    $datastoreMock = $script:datastore

    Mock -CommandName Get-Datastore -MockWith { return $datastoreMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $VMHost -eq $script:vmHost } -Verifiable
    Mock -CommandName Set-Datastore -MockWith { return $null }.GetNewClosure() -Verifiable

    $datastoreBaseDSCProperties
}

function New-MocksWhenErrorOccursWhileRemovingTheDatastore {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $datastoreBaseDSCProperties = New-DatastoreDSCProperties

    $datastoreMock = $script:datastore

    Mock -CommandName Get-Datastore -MockWith { return $datastoreMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $VMHost -eq $script:vmHost } -Verifiable
    Mock -CommandName Remove-Datastore -MockWith { throw }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Datastore -eq $script:datastore -and $VMHost -eq $script:vmHost -and !$Confirm } -Verifiable

    $datastoreBaseDSCProperties
}

function New-MocksWhenNoErrorOccursWhileRemovingTheDatastore {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $datastoreBaseDSCProperties = New-DatastoreDSCProperties

    $datastoreMock = $script:datastore

    Mock -CommandName Get-Datastore -MockWith { return $datastoreMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $VMHost -eq $script:vmHost } -Verifiable
    Mock -CommandName Remove-Datastore -MockWith { return $null }.GetNewClosure() -Verifiable

    $datastoreBaseDSCProperties
}
