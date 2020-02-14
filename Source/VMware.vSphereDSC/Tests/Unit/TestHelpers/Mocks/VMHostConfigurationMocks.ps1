<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-VMHostConfigurationProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostConfigurationProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        Name = $script:constants.VMHostName
        State = $script:constants.VMHostMaintenanceState
        Evacuate = $script:constants.EvacuateVMs
        VsanDataMigrationMode = $script:constants.VsanDataMigrationMode
        LicenseKey = $script:constants.VMHostLicenseKeyTwo
        TimeZoneName = $script:constants.VMHostUTCTimeZoneName
        VMSwapfileDatastoreName = $script:constants.VMSwapfileDatastoreTwoName
        VMSwapfilePolicy = $script:constants.WithVMDatastoreVMSwapfilePolicy
    }

    $vmHostConfigurationProperties
}

function New-MocksForVMHostConfiguration {
    [CmdletBinding()]

    $viServerMock = $script:viServer

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Disconnect-VIServer -MockWith { return $null }.GetNewClosure() -Verifiable
}

function New-MocksWhenTheVMHostConfigurationNeedsToBeModifiedAndErrorOccursWhileRetrievingTheTimeZone {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostConfigurationProperties = New-VMHostConfigurationProperties

    $vmHostMock = $script:vmHostWithClusterWithManualDrsAutomationLevelAsParentAndSettingsToModify

    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHostAvailableTimeZone -MockWith { throw }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMHostUTCTimeZoneName -and $VMHost -eq $script:vmHostWithClusterWithManualDrsAutomationLevelAsParentAndSettingsToModify } -Verifiable

    $vmHostConfigurationProperties
}

function New-MocksWhenTheVMHostConfigurationNeedsToBeModifiedAndErrorOccursWhileRetrievingTheVMSwapFileDatastore {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostConfigurationProperties = New-VMHostConfigurationProperties

    $vmHostMock = $script:vmHostWithClusterWithManualDrsAutomationLevelAsParentAndSettingsToModify
    $vmHostTimeZoneMock = $script:vmHostUTCTimeZone

    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHostAvailableTimeZone -MockWith { return $vmHostTimeZoneMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMHostUTCTimeZoneName -and $VMHost -eq $script:vmHostWithClusterWithManualDrsAutomationLevelAsParentAndSettingsToModify } -Verifiable
    Mock -CommandName Get-Datastore -MockWith { throw }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMSwapfileDatastoreTwoName -and $VMHost -eq $script:vmHostWithClusterWithManualDrsAutomationLevelAsParentAndSettingsToModify } -Verifiable

    $vmHostConfigurationProperties
}

function New-MocksWhenTheVMHostConfigurationNeedsToBeModifiedAndDrsRecommendationShouldBeGeneratedAndApplied {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostConfigurationProperties = New-VMHostConfigurationProperties

    $vmHostConfigurationProperties.HostProfileName = $script:constants.HostProfileName

    $vmHostMock = $script:vmHostWithClusterWithManualDrsAutomationLevelAsParentAndSettingsToModify
    $vmHostTimeZoneMock = $script:vmHostUTCTimeZone
    $datastoreMock = $script:vmSwapfileDatastoreTwo
    $hostProfileMock = $script:hostProfile
    $enterMaintenanceModeTaskMock = $script:enterMaintenanceModeSuccessTask
    $clusterDrsRecommendationMock = $script:clusterDrsRecommendation
    $applyDrsRecommendationTaskMock = $script:applyDrsRecommendationSuccessTask

    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHostAvailableTimeZone -MockWith { return $vmHostTimeZoneMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMHostUTCTimeZoneName -and $VMHost -eq $script:vmHostWithClusterWithManualDrsAutomationLevelAsParentAndSettingsToModify } -Verifiable
    Mock -CommandName Get-Datastore -MockWith { return $datastoreMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMSwapfileDatastoreTwoName -and $VMHost -eq $script:vmHostWithClusterWithManualDrsAutomationLevelAsParentAndSettingsToModify } -Verifiable
    Mock -CommandName Get-VMHostProfile -MockWith { return $hostProfileMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.HostProfileName } -Verifiable
    Mock -CommandName Set-VMHost -MockWith { return $enterMaintenanceModeTaskMock }.GetNewClosure() -Verifiable
    Mock -CommandName Start-Sleep -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Seconds -eq 5 } -Verifiable
    Mock -CommandName Get-DrsRecommendation -MockWith { return $clusterDrsRecommendationMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Cluster -eq $script:clusterWithManualDrsAutomationLevel -and $Refresh } -Verifiable
    Mock -CommandName Apply-DrsRecommendation -MockWith { return $applyDrsRecommendationTaskMock }.GetNewClosure() -ParameterFilter { $DrsRecommendation -eq $script:clusterDrsRecommendation -and $RunAsync -and !$Confirm } -Verifiable
    Mock -CommandName Wait-Task -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Task -eq $script:applyDrsRecommendationSuccessTask } -Verifiable
    Mock -CommandName Wait-Task -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Task -eq $script:enterMaintenanceModeSuccessTask } -Verifiable

    $vmHostConfigurationProperties
}

function New-MocksWhenTheVMHostConfigurationNeedsToBeModifiedWithoutGeneratingADrsRecommendation {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostConfigurationProperties = New-VMHostConfigurationProperties

    $vmHostConfigurationProperties.HostProfileName = $script:constants.HostProfileName

    $vmHostMock = $script:vmHostWithClusterWithFullyAutomatedDrsAutomationLevelAsParentAndSettingsToModify
    $vmHostTimeZoneMock = $script:vmHostUTCTimeZone
    $datastoreMock = $script:vmSwapfileDatastoreTwo
    $hostProfileMock = $script:hostProfile

    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHostAvailableTimeZone -MockWith { return $vmHostTimeZoneMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMHostUTCTimeZoneName -and $VMHost -eq $script:vmHostWithClusterWithFullyAutomatedDrsAutomationLevelAsParentAndSettingsToModify } -Verifiable
    Mock -CommandName Get-Datastore -MockWith { return $datastoreMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMSwapfileDatastoreTwoName -and $VMHost -eq $script:vmHostWithClusterWithFullyAutomatedDrsAutomationLevelAsParentAndSettingsToModify } -Verifiable
    Mock -CommandName Get-VMHostProfile -MockWith { return $hostProfileMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.HostProfileName } -Verifiable
    Mock -CommandName Set-VMHost -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostConfigurationProperties
}

function New-MocksWhenTheCryptoKeyOfTheVMHostNeedsToBeModified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostConfigurationProperties = New-VMHostConfigurationProperties

    $vmHostConfigurationProperties.HostProfileName = $script:constants.HostProfileName
    $vmHostConfigurationProperties.KmsClusterName = $script:constants.KmsClusterName

    $vmHostMock = $script:vmHostWithClusterWithFullyAutomatedDrsAutomationLevelAsParentAndSettingsToModify
    $vmHostTimeZoneMock = $script:vmHostUTCTimeZone
    $datastoreMock = $script:vmSwapfileDatastoreTwo
    $hostProfileMock = $script:hostProfile
    $kmsClusterMock = $script:kmsCluster

    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHostAvailableTimeZone -MockWith { return $vmHostTimeZoneMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMHostUTCTimeZoneName -and $VMHost -eq $script:vmHostWithClusterWithFullyAutomatedDrsAutomationLevelAsParentAndSettingsToModify } -Verifiable
    Mock -CommandName Get-Datastore -MockWith { return $datastoreMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VMSwapfileDatastoreTwoName -and $VMHost -eq $script:vmHostWithClusterWithFullyAutomatedDrsAutomationLevelAsParentAndSettingsToModify } -Verifiable
    Mock -CommandName Get-VMHostProfile -MockWith { return $hostProfileMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.HostProfileName } -Verifiable
    Mock -CommandName Get-KmsCluster -MockWith { return $kmsClusterMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.KmsClusterName } -Verifiable
    Mock -CommandName Set-VMHost -MockWith { return $null }.GetNewClosure() -ParameterFilter { $KmsCluster -eq $script:kmsCluster } -Verifiable

    $vmHostConfigurationProperties
}

function New-MocksWhenTheVMHostConfigurationDoesNotNeedToBeModified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostConfigurationProperties = New-VMHostConfigurationProperties

    $vmHostMock = $script:vmHostWithoutSettingsToModify

    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable

    $vmHostConfigurationProperties
}

function New-MocksWhenTheVMHostConfigurationNeedsToBeModified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostConfigurationProperties = New-VMHostConfigurationProperties

    $vmHostMock = $script:vmHostWithClusterWithManualDrsAutomationLevelAsParentAndSettingsToModify

    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable

    $vmHostConfigurationProperties
}

function New-MocksWhenTheHostProfileAndKmsClusterNamesAreNotSpecified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostConfigurationProperties = New-VMHostConfigurationProperties

    $vmHostMock = $script:vmHostWithoutSettingsToModify

    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHostProfile -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Entity -eq $script:vmHostWithoutSettingsToModify } -Verifiable

    $vmHostConfigurationProperties
}
