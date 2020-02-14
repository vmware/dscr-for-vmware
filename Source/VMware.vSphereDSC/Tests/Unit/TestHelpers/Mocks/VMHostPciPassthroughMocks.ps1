<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-VMHostPciPassthroughProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostPciPassthroughProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        Name = $script:constants.VMHostName
    }

    $vmHostPciPassthroughProperties
}

function New-MocksForVMHostPciPassthrough {
    [CmdletBinding()]

    $viServerMock = $script:viServer
    $vmHostMock = $script:vmHost

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable
}

function New-MocksWhenPCIDeviceIsNotExisting {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostPciPassthroughProperties = New-VMHostPciPassthroughProperties
    $vmHostPciPassthroughProperties.Id = $script:constants.PciDeviceId + $script:constants.PciDeviceId
    $vmHostPciPassthroughProperties.Enabled = $script:constants.PciDeviceEnabled

    $vmHostPciPassthruSystemMock = $script:vmHostPciPassthruSystem

    Mock -CommandName Get-View -MockWith { return $vmHostPciPassthruSystemMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:vmHost.ExtensionData.ConfigManager.PciPassthruSystem } -Verifiable

    $vmHostPciPassthroughProperties
}

function New-MocksWhenPCIDeviceIsExistingButIsNotPassthroughCapable {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostPciPassthroughProperties = New-VMHostPciPassthroughProperties
    $vmHostPciPassthroughProperties.Id = $script:constants.PciDeviceId + '.0'
    $vmHostPciPassthroughProperties.Enabled = $script:constants.PciDeviceEnabled

    $vmHostPciPassthruSystemMock = $script:vmHostPciPassthruSystem

    Mock -CommandName Get-View -MockWith { return $vmHostPciPassthruSystemMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:vmHost.ExtensionData.ConfigManager.PciPassthruSystem } -Verifiable

    $vmHostPciPassthroughProperties
}

function New-MocksWhenPCIDeviceIsExisting {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostPciPassthroughProperties = New-VMHostPciPassthroughProperties
    $vmHostPciPassthroughProperties.Id = $script:constants.PciDeviceId
    $vmHostPciPassthroughProperties.Enabled = $script:constants.PciDeviceEnabled

    $vmHostPciPassthruSystemMock = $script:vmHostPciPassthruSystem

    Mock -CommandName Get-View -MockWith { return $vmHostPciPassthruSystemMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:vmHost.ExtensionData.ConfigManager.PciPassthruSystem } -Verifiable
    Mock -CommandName Update-PassthruConfig -MockWith { return $null }.GetNewClosure() -Verifiable
    Mock -CommandName Restart-VMHost -MockWith { return $null }.GetNewClosure() -Verifiable
    Mock -CommandName Start-Sleep -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostPciPassthroughProperties
}

function New-MocksWhenEnabledValueIsNotEqualToPCIDevicePassthroughEnabledValue {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostPciPassthroughProperties = New-VMHostPciPassthroughProperties
    $vmHostPciPassthroughProperties.Id = $script:constants.PciDeviceId
    $vmHostPciPassthroughProperties.Enabled = !$script:constants.PciDeviceEnabled

    $vmHostPciPassthruSystemMock = $script:vmHostPciPassthruSystem

    Mock -CommandName Get-View -MockWith { return $vmHostPciPassthruSystemMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:vmHost.ExtensionData.ConfigManager.PciPassthruSystem } -Verifiable

    $vmHostPciPassthroughProperties
}

function New-MocksWhenEnabledValueIsEqualToPCIDevicePassthroughEnabledValue {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostPciPassthroughProperties = New-VMHostPciPassthroughProperties
    $vmHostPciPassthroughProperties.Id = $script:constants.PciDeviceId
    $vmHostPciPassthroughProperties.Enabled = $script:constants.PciDeviceEnabled

    $vmHostPciPassthruSystemMock = $script:vmHostPciPassthruSystem

    Mock -CommandName Get-View -MockWith { return $vmHostPciPassthruSystemMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:vmHost.ExtensionData.ConfigManager.PciPassthruSystem } -Verifiable

    $vmHostPciPassthroughProperties
}

function New-MocksInGet {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostPciPassthroughProperties = New-VMHostPciPassthroughProperties
    $vmHostPciPassthroughProperties.Id = $script:constants.PciDeviceId
    $vmHostPciPassthroughProperties.Enabled = $script:constants.PciDeviceEnabled

    $vmHostPciPassthruSystemMock = $script:vmHostPciPassthruSystem

    Mock -CommandName Get-View -MockWith { return $vmHostPciPassthruSystemMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:vmHost.ExtensionData.ConfigManager.PciPassthruSystem } -Verifiable

    $vmHostPciPassthroughProperties
}
