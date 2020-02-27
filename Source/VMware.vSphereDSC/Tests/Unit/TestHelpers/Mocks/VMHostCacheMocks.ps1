<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-VMHostCacheProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostCacheProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        Name = $script:constants.VMHostName
    }

    $vmHostCacheProperties
}

function New-MocksForVMHostCache {
    [CmdletBinding()]

    $viServerMock = $script:viServer
    $vmHostMock = $script:vmHost
    $vmHostCacheConfigurationManagerMock = $script:vmHostCacheConfigurationManager

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $vmHostCacheConfigurationManagerMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:vmHost.ExtensionData.ConfigManager.CacheConfigurationManager } -Verifiable
}

function New-MocksWhenPassedSwapSizeIsNegative {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostCacheProperties = New-VMHostCacheProperties
    $vmHostCacheProperties.DatastoreName = $script:constants.DatastoreName
    $vmHostCacheProperties.SwapSizeGB = $script:constants.NegativeSwapSize

    $datastoreMock = $script:datastore

    Mock -CommandName Get-Datastore -MockWith { return $datastoreMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $RelatedObject -eq $script:vmHost } -Verifiable

    $vmHostCacheProperties
}

function New-MocksWhenPassedSwapSizeIsBiggerThanDatastoreFreeSpace {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostCacheProperties = New-VMHostCacheProperties
    $vmHostCacheProperties.DatastoreName = $script:constants.DatastoreName
    $vmHostCacheProperties.SwapSizeGB = $script:constants.OverflowingSwapSize

    $datastoreMock = $script:datastore

    Mock -CommandName Get-Datastore -MockWith { return $datastoreMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $RelatedObject -eq $script:vmHost } -Verifiable

    $vmHostCacheProperties
}

function New-MocksWhenUpdateCacheConfigurationResultsInError {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostCacheProperties = New-VMHostCacheProperties
    $vmHostCacheProperties.DatastoreName = $script:constants.DatastoreName
    $vmHostCacheProperties.SwapSizeGB = $script:constants.SwapSizeGB

    $datastoreMock = $script:datastore
    $hostCacheConfigurationResultMock = $script:hostCacheConfigurationResult
    $hostCacheConfigurationTaskMock = $script:hostCacheConfigurationErrorTask

    Mock -CommandName Get-Datastore -MockWith { return $datastoreMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $RelatedObject -eq $script:vmHost } -Verifiable
    Mock -CommandName Update-HostCacheConfiguration -MockWith { return $hostCacheConfigurationResultMock }.GetNewClosure() -ParameterFilter { $VMHostCacheConfigurationManager -eq $script:vmHostCacheConfigurationManager -and $Spec -eq $script:hostCacheConfigurationSpec } -Verifiable
    Mock -CommandName Get-Task -MockWith { return $hostCacheConfigurationTaskMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:hostCacheConfigurationResult } -Verifiable
    Mock -CommandName Wait-Task -MockWith { throw }.GetNewClosure() -ParameterFilter { $Task -eq $script:hostCacheConfigurationErrorTask } -Verifiable

    $vmHostCacheProperties
}

function New-MocksWhenUpdateCacheConfigurationResultsInSuccess {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostCacheProperties = New-VMHostCacheProperties
    $vmHostCacheProperties.DatastoreName = $script:constants.DatastoreName
    $vmHostCacheProperties.SwapSizeGB = $script:constants.SwapSizeGB

    $datastoreMock = $script:datastore
    $hostCacheConfigurationResultMock = $script:hostCacheConfigurationResult
    $hostCacheConfigurationTaskMock = $script:hostCacheConfigurationSuccessTask

    Mock -CommandName Get-Datastore -MockWith { return $datastoreMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $RelatedObject -eq $script:vmHost } -Verifiable
    Mock -CommandName Update-HostCacheConfiguration -MockWith { return $hostCacheConfigurationResultMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-Task -MockWith { return $hostCacheConfigurationTaskMock }.GetNewClosure() -Verifiable
    Mock -CommandName Wait-Task -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostCacheProperties
}

function New-MocksWhenSwapSizeIsNotEqualToCurrentSwapSize {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostCacheProperties = New-VMHostCacheProperties
    $vmHostCacheProperties.DatastoreName = $script:constants.DatastoreName
    $vmHostCacheProperties.SwapSizeGB = $script:constants.SwapSizeGB * 2

    $datastoreMock = $script:datastore

    Mock -CommandName Get-Datastore -MockWith { return $datastoreMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $RelatedObject -eq $script:vmHost } -Verifiable

    $vmHostCacheProperties
}

function New-MocksWhenSwapSizeIsEqualToCurrentSwapSize {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostCacheProperties = New-VMHostCacheProperties
    $vmHostCacheProperties.DatastoreName = $script:constants.DatastoreName
    $vmHostCacheProperties.SwapSizeGB = $script:constants.SwapSizeGB

    $datastoreMock = $script:datastore

    Mock -CommandName Get-Datastore -MockWith { return $datastoreMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $RelatedObject -eq $script:vmHost } -Verifiable

    $vmHostCacheProperties
}

function New-MocksInGet {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostCacheProperties = New-VMHostCacheProperties
    $vmHostCacheProperties.DatastoreName = $script:constants.DatastoreName
    $vmHostCacheProperties.SwapSizeGB = $script:constants.SwapSizeGB

    $datastoreMock = $script:datastore

    Mock -CommandName Get-Datastore -MockWith { return $datastoreMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $RelatedObject -eq $script:vmHost } -Verifiable

    $vmHostCacheProperties
}
