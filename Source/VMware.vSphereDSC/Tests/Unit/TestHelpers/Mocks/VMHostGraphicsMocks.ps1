<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-VMHostGraphicsProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostGraphicsProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        Name = $script:constants.VMHostName
    }

    $vmHostGraphicsProperties
}

function New-MocksForVMHostGraphics {
    [CmdletBinding()]

    $viServerMock = $script:viServer
    $vmHostMock = $script:vmHost
    $vmHostGraphicsManagerMock = $script:vmHostGraphicsManager

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-View -MockWith { return $vmHostGraphicsManagerMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:vmHost.ExtensionData.ConfigManager.GraphicsManager } -Verifiable
}

function New-MocksInSetWhenGraphicsDeviceIsNotPassed {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostGraphicsProperties = New-VMHostGraphicsProperties
    $vmHostGraphicsProperties.DefaultGraphicsType = $script:constants.DefaultGraphicsType
    $vmHostGraphicsProperties.SharedPassthruAssignmentPolicy = $script:constants.SharedPassthruAssignmentPolicy

    Mock -CommandName Update-GraphicsConfig -MockWith { return $null }.GetNewClosure() -Verifiable
    Mock -CommandName Restart-VMHost -MockWith { return $null }.GetNewClosure() -Verifiable
    Mock -CommandName Start-Sleep -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostGraphicsProperties
}

function New-MocksWhenGraphicsDeviceIsPassedAndGraphicsDeviceTypeIsNotPassed {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostGraphicsProperties = New-VMHostGraphicsProperties
    $vmHostGraphicsProperties.DefaultGraphicsType = $script:constants.DefaultGraphicsType
    $vmHostGraphicsProperties.SharedPassthruAssignmentPolicy = $script:constants.SharedPassthruAssignmentPolicy
    $vmHostGraphicsProperties.DeviceId = $script:constants.GraphicsDeviceId

    $vmHostGraphicsProperties
}

function New-MocksWhenGraphicsDeviceAndGraphicsDeviceTypeArePassed {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostGraphicsProperties = New-VMHostGraphicsProperties
    $vmHostGraphicsProperties.DefaultGraphicsType = $script:constants.DefaultGraphicsType
    $vmHostGraphicsProperties.SharedPassthruAssignmentPolicy = $script:constants.SharedPassthruAssignmentPolicy
    $vmHostGraphicsProperties.DeviceId = $script:constants.GraphicsDeviceId
    $vmHostGraphicsProperties.DeviceGraphicsType = $script:constants.DefaultGraphicsType

    Mock -CommandName Update-GraphicsConfig -MockWith { return $null }.GetNewClosure() -Verifiable
    Mock -CommandName Restart-VMHost -MockWith { return $null }.GetNewClosure() -Verifiable
    Mock -CommandName Start-Sleep -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostGraphicsProperties
}

function New-MocksWhenDefaultGraphicsTypeValueIsNotEqualToGraphicsConfigurationDefaultGraphicsTypeValue {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostGraphicsProperties = New-VMHostGraphicsProperties
    $vmHostGraphicsProperties.DefaultGraphicsType = 'SharedDirect'

    $vmHostGraphicsProperties
}

function New-MocksWhenSharedPassthruAssignmentPolicyValueIsNotEqualToGraphicsConfigurationSharedPassthruAssignmentPolicyValue {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostGraphicsProperties = New-VMHostGraphicsProperties
    $vmHostGraphicsProperties.DefaultGraphicsType = $script:constants.DefaultGraphicsType
    $vmHostGraphicsProperties.SharedPassthruAssignmentPolicy = 'Consolidation'

    $vmHostGraphicsProperties
}

function New-MocksWhenGraphicsDeviceIsNotPassed {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostGraphicsProperties = New-VMHostGraphicsProperties
    $vmHostGraphicsProperties.DefaultGraphicsType = $script:constants.DefaultGraphicsType
    $vmHostGraphicsProperties.SharedPassthruAssignmentPolicy = $script:constants.SharedPassthruAssignmentPolicy

    $vmHostGraphicsProperties
}

function New-MocksWhenGraphicsDeviceIsNotExisting {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostGraphicsProperties = New-VMHostGraphicsProperties
    $vmHostGraphicsProperties.DefaultGraphicsType = $script:constants.DefaultGraphicsType
    $vmHostGraphicsProperties.SharedPassthruAssignmentPolicy = $script:constants.SharedPassthruAssignmentPolicy
    $vmHostGraphicsProperties.DeviceId = $script:constants.GraphicsDeviceId + $script:constants.GraphicsDeviceId

    $vmHostGraphicsProperties
}

function New-MocksWhenGraphicsDeviceIsExistingAndGraphicsDeviceTypeIsNotPassed {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostGraphicsProperties = New-VMHostGraphicsProperties
    $vmHostGraphicsProperties.DefaultGraphicsType = $script:constants.DefaultGraphicsType
    $vmHostGraphicsProperties.SharedPassthruAssignmentPolicy = $script:constants.SharedPassthruAssignmentPolicy
    $vmHostGraphicsProperties.DeviceId = $script:constants.GraphicsDeviceId

    $vmHostGraphicsProperties
}

function New-MocksWhenGraphicsDeviceTypeValueIsNotEqualToGraphicsConfigurationGraphicsDeviceTypeValue {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostGraphicsProperties = New-VMHostGraphicsProperties
    $vmHostGraphicsProperties.DefaultGraphicsType = $script:constants.DefaultGraphicsType
    $vmHostGraphicsProperties.SharedPassthruAssignmentPolicy = $script:constants.SharedPassthruAssignmentPolicy
    $vmHostGraphicsProperties.DeviceId = $script:constants.GraphicsDeviceId
    $vmHostGraphicsProperties.DeviceGraphicsType = 'SharedDirect'

    $vmHostGraphicsProperties
}

function New-MocksWhenPassedValuesAreEqualToGraphicsConfigurationValues {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostGraphicsProperties = New-VMHostGraphicsProperties
    $vmHostGraphicsProperties.DefaultGraphicsType = $script:constants.DefaultGraphicsType
    $vmHostGraphicsProperties.SharedPassthruAssignmentPolicy = $script:constants.SharedPassthruAssignmentPolicy
    $vmHostGraphicsProperties.DeviceId = $script:constants.GraphicsDeviceId
    $vmHostGraphicsProperties.DeviceGraphicsType = $script:constants.DefaultGraphicsType

    $vmHostGraphicsProperties
}

function New-MocksWhenGraphicsDeviceIsExisting {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostGraphicsProperties = New-VMHostGraphicsProperties
    $vmHostGraphicsProperties.DefaultGraphicsType = $script:constants.DefaultGraphicsType
    $vmHostGraphicsProperties.SharedPassthruAssignmentPolicy = $script:constants.SharedPassthruAssignmentPolicy
    $vmHostGraphicsProperties.DeviceId = $script:constants.GraphicsDeviceId

    $vmHostGraphicsProperties
}
