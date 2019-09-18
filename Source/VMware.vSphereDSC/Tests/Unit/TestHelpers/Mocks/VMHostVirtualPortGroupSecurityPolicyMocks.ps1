<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-VMHostVirtualPortGroupSecurityPolicyProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVirtualPortGroupSecurityPolicyProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        Name = $script:constants.VMHostName
        PortGroup = $script:constants.VirtualPortGroupName
    }

    $vmHostVirtualPortGroupSecurityPolicyProperties
}

function New-MocksForVMHostVirtualPortGroupSecurityPolicy {
    [CmdletBinding()]

    $viServerMock = $script:viServer
    $vmHostMock = $script:vmHost
    $virtualPortGroupMock = $script:virtualPortGroup

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VirtualPortGroup -MockWith { return $virtualPortGroupMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VirtualPortGroupName -and $VMHost -eq $script:vmHost -and $Standard } -Verifiable
}

function New-MocksWhenSecurityPolicySettingsArePassedAndSecurityPolicySettingsInheritedAreNotPassed {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVirtualPortGroupSecurityPolicyProperties = New-VMHostVirtualPortGroupSecurityPolicyProperties

    $vmHostVirtualPortGroupSecurityPolicyProperties.AllowPromiscuous = $script:constants.AllowPromiscuous
    $vmHostVirtualPortGroupSecurityPolicyProperties.ForgedTransmits = $script:constants.ForgedTransmits
    $vmHostVirtualPortGroupSecurityPolicyProperties.MacChanges = $script:constants.MacChanges

    $virtualPortGroupSecurityPolicyMock = $script:virtualPortGroupSecurityPolicy

    Mock -CommandName Get-SecurityPolicy -MockWith { return $virtualPortGroupSecurityPolicyMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VirtualPortGroup -eq $script:virtualPortGroup } -Verifiable
    Mock -CommandName Set-SecurityPolicy -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostVirtualPortGroupSecurityPolicyProperties
}

function New-MocksWhenSecurityPolicySettingsArePassedAndSecurityPolicySettingsInheritedAreSetToFalse {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVirtualPortGroupSecurityPolicyProperties = New-VMHostVirtualPortGroupSecurityPolicyProperties

    $vmHostVirtualPortGroupSecurityPolicyProperties.AllowPromiscuous = $script:constants.AllowPromiscuous
    $vmHostVirtualPortGroupSecurityPolicyProperties.AllowPromiscuousInherited = $script:constants.AllowPromiscuousInherited
    $vmHostVirtualPortGroupSecurityPolicyProperties.ForgedTransmits = $script:constants.ForgedTransmits
    $vmHostVirtualPortGroupSecurityPolicyProperties.ForgedTransmitsInherited = $script:constants.ForgedTransmitsInherited
    $vmHostVirtualPortGroupSecurityPolicyProperties.MacChanges = $script:constants.MacChanges
    $vmHostVirtualPortGroupSecurityPolicyProperties.MacChangesInherited = $script:constants.MacChangesInherited

    $virtualPortGroupSecurityPolicyMock = $script:virtualPortGroupSecurityPolicy

    Mock -CommandName Get-SecurityPolicy -MockWith { return $virtualPortGroupSecurityPolicyMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VirtualPortGroup -eq $script:virtualPortGroup } -Verifiable
    Mock -CommandName Set-SecurityPolicy -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostVirtualPortGroupSecurityPolicyProperties
}

function New-MocksWhenSecurityPolicySettingsArePassedAndSecurityPolicySettingsInheritedAreSetToTrue {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVirtualPortGroupSecurityPolicyProperties = New-VMHostVirtualPortGroupSecurityPolicyProperties

    $vmHostVirtualPortGroupSecurityPolicyProperties.AllowPromiscuous = $script:constants.AllowPromiscuous
    $vmHostVirtualPortGroupSecurityPolicyProperties.AllowPromiscuousInherited = !$script:constants.AllowPromiscuousInherited
    $vmHostVirtualPortGroupSecurityPolicyProperties.ForgedTransmits = $script:constants.ForgedTransmits
    $vmHostVirtualPortGroupSecurityPolicyProperties.ForgedTransmitsInherited = !$script:constants.ForgedTransmitsInherited
    $vmHostVirtualPortGroupSecurityPolicyProperties.MacChanges = $script:constants.MacChanges
    $vmHostVirtualPortGroupSecurityPolicyProperties.MacChangesInherited = !$script:constants.MacChangesInherited

    $virtualPortGroupSecurityPolicyMock = $script:virtualPortGroupSecurityPolicy

    Mock -CommandName Get-SecurityPolicy -MockWith { return $virtualPortGroupSecurityPolicyMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VirtualPortGroup -eq $script:virtualPortGroup } -Verifiable
    Mock -CommandName Set-SecurityPolicy -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostVirtualPortGroupSecurityPolicyProperties
}

function New-MocksWhenTheSecurityPolicySettingsAreNonMatching {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVirtualPortGroupSecurityPolicyProperties = New-VMHostVirtualPortGroupSecurityPolicyProperties

    $vmHostVirtualPortGroupSecurityPolicyProperties.AllowPromiscuous = !$script:constants.AllowPromiscuous
    $vmHostVirtualPortGroupSecurityPolicyProperties.ForgedTransmitsInherited = !$script:constants.ForgedTransmitsInherited

    $virtualPortGroupSecurityPolicyMock = $script:virtualPortGroupSecurityPolicy

    Mock -CommandName Get-SecurityPolicy -MockWith { return $virtualPortGroupSecurityPolicyMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VirtualPortGroup -eq $script:virtualPortGroup } -Verifiable

    $vmHostVirtualPortGroupSecurityPolicyProperties
}

function New-MocksWhenTheSecurityPolicySettingsAreMatching {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVirtualPortGroupSecurityPolicyProperties = New-VMHostVirtualPortGroupSecurityPolicyProperties

    $vmHostVirtualPortGroupSecurityPolicyProperties.AllowPromiscuous = $script:constants.AllowPromiscuous
    $vmHostVirtualPortGroupSecurityPolicyProperties.AllowPromiscuousInherited = $script:constants.AllowPromiscuousInherited
    $vmHostVirtualPortGroupSecurityPolicyProperties.ForgedTransmits = $script:constants.ForgedTransmits
    $vmHostVirtualPortGroupSecurityPolicyProperties.ForgedTransmitsInherited = $script:constants.ForgedTransmitsInherited
    $vmHostVirtualPortGroupSecurityPolicyProperties.MacChanges = $script:constants.MacChanges
    $vmHostVirtualPortGroupSecurityPolicyProperties.MacChangesInherited = $script:constants.MacChangesInherited

    $virtualPortGroupSecurityPolicyMock = $script:virtualPortGroupSecurityPolicy

    Mock -CommandName Get-SecurityPolicy -MockWith { return $virtualPortGroupSecurityPolicyMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VirtualPortGroup -eq $script:virtualPortGroup } -Verifiable

    $vmHostVirtualPortGroupSecurityPolicyProperties
}

function New-MocksInGet {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVirtualPortGroupSecurityPolicyProperties = New-VMHostVirtualPortGroupSecurityPolicyProperties

    $virtualPortGroupSecurityPolicyMock = $script:virtualPortGroupSecurityPolicy

    Mock -CommandName Get-SecurityPolicy -MockWith { return $virtualPortGroupSecurityPolicyMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VirtualPortGroup -eq $script:virtualPortGroup } -Verifiable

    $vmHostVirtualPortGroupSecurityPolicyProperties
}
