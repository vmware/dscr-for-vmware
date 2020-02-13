<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-VMHostAgentVMProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostAgentVMProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        Name = $script:constants.VMHostName
    }

    $vmHostAgentVMProperties
}

function New-MocksForVMHostAgentVMWithEsxAgentHostManagerWithNullAgentVmSettings {
    [CmdletBinding()]

    $viServerMock = $script:viServer
    $vmHostMock = $script:vmHost
    $esxAgentHostManagerMock = $script:esxAgentHostManagerWithNullAgentVmSettings

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $esxAgentHostManagerMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:vmHost.ExtensionData.ConfigManager.EsxAgentHostManager } -Verifiable
    Mock -CommandName Update-AgentVMConfiguration -MockWith { return $null }.GetNewClosure() -Verifiable
}

function New-MocksForVMHostAgentVM {
    [CmdletBinding()]

    $viServerMock = $script:viServer
    $vmHostMock = $script:vmHost

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable
}

function New-MocksWhenAgentVmDatastoreIsAnExistingDatastoreAndAgentVmNetworkIsAnExistingNetwork {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostAgentVMProperties = New-VMHostAgentVMProperties
    $vmHostAgentVMProperties.AgentVmDatastore = $script:constants.DatastoreName
    $vmHostAgentVMProperties.AgentVmNetwork = $script:constants.NetworkName

    $datastoreMock = $script:datastore
    $networkMock = $script:network

    Mock -CommandName Get-Datastore -MockWith { return $datastoreMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $RelatedObject -eq $script:vmHost } -Verifiable
    Mock -CommandName Get-View -MockWith { return $networkMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:vmHost.ExtensionData.Network[0] } -Verifiable

    $vmHostAgentVMProperties
}

function New-MocksWhenAgentVmDatastoreIsNotAnExistingDatastore {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostAgentVMProperties = New-VMHostAgentVMProperties
    $vmHostAgentVMProperties.AgentVmDatastore = $script:constants.DatastoreName

    Mock -CommandName Get-Datastore -MockWith { throw }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.DatastoreName -and $RelatedObject -eq $script:vmHost } -Verifiable

    $vmHostAgentVMProperties
}

function New-MocksWhenAgentVmNetworkIsNotAnExistingNetwork {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostAgentVMProperties = New-VMHostAgentVMProperties
    $vmHostAgentVMProperties.AgentVmNetwork = $script:constants.NetworkName

    Mock -CommandName Get-View -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:vmHost.ExtensionData.Network[0] } -Verifiable

    $vmHostAgentVMProperties
}

function New-MocksWhenAgentVmSettingsAreSetToNullAndServerValuesAreNotEqualToNull {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostAgentVMProperties = New-VMHostAgentVMProperties

    $esxAgentHostManagerMock = $script:esxAgentHostManagerWithNotNullAgentVmSettings

    Mock -CommandName Get-View -MockWith { return $esxAgentHostManagerMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:vmHost.ExtensionData.ConfigManager.EsxAgentHostManager } -Verifiable

    $vmHostAgentVMProperties
}

function New-MocksWhenAgentVmSettingsAreSetToNullAndServerValuesAreEqualToNull {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostAgentVMProperties = New-VMHostAgentVMProperties

    $esxAgentHostManagerMock = $script:esxAgentHostManagerWithNullAgentVmSettings

    Mock -CommandName Get-View -MockWith { return $esxAgentHostManagerMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:vmHost.ExtensionData.ConfigManager.EsxAgentHostManager } -Verifiable

    $vmHostAgentVMProperties
}

function New-MocksWhenAgentVmSettingsAreNotSetToNullAndServerValuesAreEqualToNull {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostAgentVMProperties = New-VMHostAgentVMProperties
    $vmHostAgentVMProperties.AgentVmDatastore = $script:constants.DatastoreName
    $vmHostAgentVMProperties.AgentVmNetwork = $script:constants.NetworkName

    $esxAgentHostManagerMock = $script:esxAgentHostManagerWithNullAgentVmSettings

    Mock -CommandName Get-View -MockWith { return $esxAgentHostManagerMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:vmHost.ExtensionData.ConfigManager.EsxAgentHostManager } -Verifiable

    $vmHostAgentVMProperties
}

function New-MocksWhenAgentVmSettingsAreNotEqualToServerValues {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostAgentVMProperties = New-VMHostAgentVMProperties
    $vmHostAgentVMProperties.AgentVmDatastore = $script:constants.DatastoreName
    $vmHostAgentVMProperties.AgentVmNetwork = $script:constants.NetworkName + $script:constants.NetworkName

    $esxAgentHostManagerMock = $script:esxAgentHostManagerWithNotNullAgentVmSettings
    $datastoreMock = $script:datastore.ExtensionData
    $networkMock = $script:network

    Mock -CommandName Get-View -MockWith { return $esxAgentHostManagerMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:vmHost.ExtensionData.ConfigManager.EsxAgentHostManager } -Verifiable
    Mock -CommandName Get-View -MockWith { return $datastoreMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:esxAgentHostManagerWithNotNullAgentVmSettings.ConfigInfo.AgentVmDatastore } -Verifiable
    Mock -CommandName Get-View -MockWith { return $networkMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:esxAgentHostManagerWithNotNullAgentVmSettings.ConfigInfo.AgentVmNetwork } -Verifiable

    $vmHostAgentVMProperties
}

function New-MocksWhenAgentVmSettingsAreEqualToServerValues {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostAgentVMProperties = New-VMHostAgentVMProperties
    $vmHostAgentVMProperties.AgentVmDatastore = $script:constants.DatastoreName
    $vmHostAgentVMProperties.AgentVmNetwork = $script:constants.NetworkName

    $esxAgentHostManagerMock = $script:esxAgentHostManagerWithNotNullAgentVmSettings
    $datastoreMock = $script:datastore.ExtensionData
    $networkMock = $script:network

    Mock -CommandName Get-View -MockWith { return $esxAgentHostManagerMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:vmHost.ExtensionData.ConfigManager.EsxAgentHostManager } -Verifiable
    Mock -CommandName Get-View -MockWith { return $datastoreMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:esxAgentHostManagerWithNotNullAgentVmSettings.ConfigInfo.AgentVmDatastore } -Verifiable
    Mock -CommandName Get-View -MockWith { return $networkMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:esxAgentHostManagerWithNotNullAgentVmSettings.ConfigInfo.AgentVmNetwork } -Verifiable

    $vmHostAgentVMProperties
}

function New-MocksWhenAgentVmSettingsFromTheServerAreEqualToNull {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostAgentVMProperties = New-VMHostAgentVMProperties

    $esxAgentHostManagerMock = $script:esxAgentHostManagerWithNullAgentVmSettings

    Mock -CommandName Get-View -MockWith { return $esxAgentHostManagerMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:vmHost.ExtensionData.ConfigManager.EsxAgentHostManager } -Verifiable

    $vmHostAgentVMProperties
}

function New-MocksWhenAgentVmSettingsFromTheServerAreNotEqualToNull {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostAgentVMProperties = New-VMHostAgentVMProperties

    $esxAgentHostManagerMock = $script:esxAgentHostManagerWithNotNullAgentVmSettings
    $datastoreMock = $script:datastore.ExtensionData
    $networkMock = $script:network

    Mock -CommandName Get-View -MockWith { return $esxAgentHostManagerMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:vmHost.ExtensionData.ConfigManager.EsxAgentHostManager } -Verifiable
    Mock -CommandName Get-View -MockWith { return $datastoreMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:esxAgentHostManagerWithNotNullAgentVmSettings.ConfigInfo.AgentVmDatastore } -Verifiable
    Mock -CommandName Get-View -MockWith { return $networkMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:esxAgentHostManagerWithNotNullAgentVmSettings.ConfigInfo.AgentVmNetwork } -Verifiable

    $vmHostAgentVMProperties
}
