<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-VmfsDatastoreDSCProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmfsDatastoreBaseDSCProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        VMHostName = $script:constants.VMHostName
        Name = $script:constants.DatastoreName
        Path = $script:constants.ScsiLunCanonicalName
    }

    $vmfsDatastoreBaseDSCProperties
}

function New-MocksForVmfsDatastore {
    [CmdletBinding()]

    $viServerMock = $script:viServer
    $vmHostMock = $script:vmHost

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable
}

function New-MocksWhenEnsureIsPresentTheVmfsDatastoreIsNotCreatedAndBlockSizeMBIsNotSpecified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmfsDatastoreBaseDSCProperties = New-VmfsDatastoreDSCProperties

    $vmfsDatastoreBaseDSCProperties.Ensure = 'Present'

    $datastoreMock = $script:datastore

    Mock -CommandName Get-Datastore -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $VMHost -eq $script:vmHost }
    Mock -CommandName New-Datastore -MockWith { return $datastoreMock }.GetNewClosure()

    $vmfsDatastoreBaseDSCProperties
}

function New-MocksWhenEnsureIsPresentTheVmfsDatastoreIsNotCreatedAndBlockSizeMBIsSpecified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmfsDatastoreBaseDSCProperties = New-VmfsDatastoreDSCProperties

    $vmfsDatastoreBaseDSCProperties.Ensure = 'Present'
    $vmfsDatastoreBaseDSCProperties.BlockSizeMB = $script:constants.BlockSizeMB

    $datastoreMock = $script:datastore

    Mock -CommandName Get-Datastore -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $VMHost -eq $script:vmHost }
    Mock -CommandName New-Datastore -MockWith { return $datastoreMock }.GetNewClosure()

    $vmfsDatastoreBaseDSCProperties
}

function New-MocksWhenEnsureIsPresentTheVmfsDatastoreIsNotCreatedAndStorageIOControlEnabledAndCongestionThresholdMillisecondAreSpecified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmfsDatastoreBaseDSCProperties = New-VmfsDatastoreDSCProperties

    $vmfsDatastoreBaseDSCProperties.Ensure = 'Present'
    $vmfsDatastoreBaseDSCProperties.BlockSizeMB = $script:constants.BlockSizeMB
    $vmfsDatastoreBaseDSCProperties.StorageIOControlEnabled = !$script:constants.StorageIOControlEnabled
    $vmfsDatastoreBaseDSCProperties.CongestionThresholdMillisecond = $script:constants.CongestionThresholdMillisecond

    $datastoreMock = $script:datastore

    Mock -CommandName Get-Datastore -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $VMHost -eq $script:vmHost }
    Mock -CommandName New-Datastore -MockWith { return $datastoreMock }.GetNewClosure()
    Mock -CommandName Set-Datastore -MockWith { return $null }.GetNewClosure()

    $vmfsDatastoreBaseDSCProperties
}

function New-MocksWhenEnsureIsAbsentAndTheVmfsDatastoreIsAlreadyRemoved {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmfsDatastoreBaseDSCProperties = New-VmfsDatastoreDSCProperties

    $vmfsDatastoreBaseDSCProperties.Ensure = 'Absent'

    Mock -CommandName Get-Datastore -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $VMHost -eq $script:vmHost }
    Mock -CommandName Remove-Datastore -MockWith { return $null }.GetNewClosure()

    $vmfsDatastoreBaseDSCProperties
}

function New-MocksWhenEnsureIsAbsentAndTheVmfsDatastoreIsNotRemoved {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmfsDatastoreBaseDSCProperties = New-VmfsDatastoreDSCProperties

    $vmfsDatastoreBaseDSCProperties.Ensure = 'Absent'

    $datastoreMock = $script:datastore

    Mock -CommandName Get-Datastore -MockWith { return $datastoreMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $VMHost -eq $script:vmHost }
    Mock -CommandName Remove-Datastore -MockWith { return $null }.GetNewClosure()

    $vmfsDatastoreBaseDSCProperties
}

function New-MocksWhenEnsureIsPresentAndTheVmfsDatastoreIsNotCreated {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmfsDatastoreBaseDSCProperties = New-VmfsDatastoreDSCProperties

    $vmfsDatastoreBaseDSCProperties.Ensure = 'Present'

    Mock -CommandName Get-Datastore -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $VMHost -eq $script:vmHost }

    $vmfsDatastoreBaseDSCProperties
}

function New-MocksWhenEnsureIsPresentTheVmfsDatastoreIsAlreadyCreatedAndDatastoreCongestionThresholdMillisecondAndStorageIOControlEnabledValuesDoNotNeedToBeModified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmfsDatastoreBaseDSCProperties = New-VmfsDatastoreDSCProperties

    $vmfsDatastoreBaseDSCProperties.Ensure = 'Present'
    $vmfsDatastoreBaseDSCProperties.StorageIOControlEnabled = $script:constants.StorageIOControlEnabled
    $vmfsDatastoreBaseDSCProperties.CongestionThresholdMillisecond = $script:constants.MaxCongestionThresholdMillisecond

    $datastoreMock = $script:datastore

    Mock -CommandName Get-Datastore -MockWith { return $datastoreMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $VMHost -eq $script:vmHost }

    $vmfsDatastoreBaseDSCProperties
}

function New-MocksWhenEnsureIsPresentTheVmfsDatastoreIsAlreadyCreatedAndDatastoreCongestionThresholdMillisecondAndStorageIOControlEnabledValuesNeedToBeModified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmfsDatastoreBaseDSCProperties = New-VmfsDatastoreDSCProperties

    $vmfsDatastoreBaseDSCProperties.Ensure = 'Present'
    $vmfsDatastoreBaseDSCProperties.StorageIOControlEnabled = !$script:constants.StorageIOControlEnabled
    $vmfsDatastoreBaseDSCProperties.CongestionThresholdMillisecond = $script:constants.CongestionThresholdMillisecond

    $datastoreMock = $script:datastore

    Mock -CommandName Get-Datastore -MockWith { return $datastoreMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $VMHost -eq $script:vmHost }

    $vmfsDatastoreBaseDSCProperties
}

function New-MocksWhenTheVmfsDatastoreDoesNotExist {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmfsDatastoreBaseDSCProperties = New-VmfsDatastoreDSCProperties

    $vmfsDatastoreBaseDSCProperties.BlockSizeMB = $script:constants.BlockSizeMB

    Mock -CommandName Get-Datastore -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $VMHost -eq $script:vmHost } -Verifiable

    $vmfsDatastoreBaseDSCProperties
}

function New-MocksWhenTheVmfsDatastoreExists {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmfsDatastoreBaseDSCProperties = New-VmfsDatastoreDSCProperties

    $datastoreMock = $script:datastore

    Mock -CommandName Get-Datastore -MockWith { return $datastoreMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $VMHost -eq $script:vmHost } -Verifiable

    $vmfsDatastoreBaseDSCProperties
}
