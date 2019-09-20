<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-VMHostVirtualPortGroupTeamingPolicyProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVirtualPortGroupTeamingPolicyProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        Name = $script:constants.VMHostName
        PortGroup = $script:constants.VirtualPortGroupName
    }

    $vmHostVirtualPortGroupTeamingPolicyProperties
}

function New-MocksForVMHostVirtualPortGroupTeamingPolicy {
    [CmdletBinding()]

    $viServerMock = $script:viServer
    $vmHostMock = $script:vmHost
    $virtualPortGroupMock = $script:virtualPortGroup

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VirtualPortGroup -MockWith { return $virtualPortGroupMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VirtualPortGroupName -and $VMHost -eq $script:vmHost -and $Standard } -Verifiable
}

function New-MocksWhenTeamingPolicySettingsArePassedAndTeamingPolicySettingsInheritedAreNotPassed {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVirtualPortGroupTeamingPolicyProperties = New-VMHostVirtualPortGroupTeamingPolicyProperties

    $vmHostVirtualPortGroupTeamingPolicyProperties.FailbackEnabled = $script:constants.FailbackEnabled
    $vmHostVirtualPortGroupTeamingPolicyProperties.LoadBalancingPolicy = $script:constants.LoadBalancingPolicyIP
    $vmHostVirtualPortGroupTeamingPolicyProperties.NetworkFailoverDetectionPolicy = $script:constants.NetworkFailoverDetectionPolicy
    $vmHostVirtualPortGroupTeamingPolicyProperties.NotifySwitches = $script:constants.NotifySwitches
    $vmHostVirtualPortGroupTeamingPolicyProperties.MakeNicActive = $script:constants.MakeNicActive
    $vmHostVirtualPortGroupTeamingPolicyProperties.MakeNicStandby = $script:constants.MakeNicStandby
    $vmHostVirtualPortGroupTeamingPolicyProperties.MakeNicUnused = $script:constants.MakeNicUnused

    $virtualPortGroupTeamingPolicyMock = $script:virtualPortGroupTeamingPolicy

    Mock -CommandName Get-NicTeamingPolicy -MockWith { return $virtualPortGroupTeamingPolicyMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VirtualPortGroup -eq $script:virtualPortGroup } -Verifiable
    Mock -CommandName Set-NicTeamingPolicy -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostVirtualPortGroupTeamingPolicyProperties
}

function New-MocksWhenTeamingPolicySettingsArePassedAndTeamingPolicySettingsInheritedAreSetToFalse {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVirtualPortGroupTeamingPolicyProperties = New-VMHostVirtualPortGroupTeamingPolicyProperties

    $vmHostVirtualPortGroupTeamingPolicyProperties.FailbackEnabled = $script:constants.FailbackEnabled
    $vmHostVirtualPortGroupTeamingPolicyProperties.LoadBalancingPolicy = $script:constants.LoadBalancingPolicyIP
    $vmHostVirtualPortGroupTeamingPolicyProperties.NetworkFailoverDetectionPolicy = $script:constants.NetworkFailoverDetectionPolicy
    $vmHostVirtualPortGroupTeamingPolicyProperties.NotifySwitches = $script:constants.NotifySwitches
    $vmHostVirtualPortGroupTeamingPolicyProperties.MakeNicActive = $script:constants.MakeNicActive
    $vmHostVirtualPortGroupTeamingPolicyProperties.MakeNicStandby = $script:constants.MakeNicStandby
    $vmHostVirtualPortGroupTeamingPolicyProperties.MakeNicUnused = $script:constants.MakeNicUnused
    $vmHostVirtualPortGroupTeamingPolicyProperties.InheritFailback = $script:constants.InheritFailback
    $vmHostVirtualPortGroupTeamingPolicyProperties.InheritFailoverOrder = $script:constants.InheritFailoverOrder
    $vmHostVirtualPortGroupTeamingPolicyProperties.InheritLoadBalancingPolicy = $script:constants.InheritLoadBalancingPolicy
    $vmHostVirtualPortGroupTeamingPolicyProperties.InheritNetworkFailoverDetectionPolicy = $script:constants.InheritNetworkFailoverDetectionPolicy
    $vmHostVirtualPortGroupTeamingPolicyProperties.InheritNotifySwitches = $script:constants.InheritNotifySwitches

    $virtualPortGroupTeamingPolicyMock = $script:virtualPortGroupTeamingPolicy

    Mock -CommandName Get-NicTeamingPolicy -MockWith { return $virtualPortGroupTeamingPolicyMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VirtualPortGroup -eq $script:virtualPortGroup } -Verifiable
    Mock -CommandName Set-NicTeamingPolicy -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostVirtualPortGroupTeamingPolicyProperties
}

function New-MocksWhenTeamingPolicySettingsArePassedAndTeamingPolicySettingsInheritedAreSetToTrue {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVirtualPortGroupTeamingPolicyProperties = New-VMHostVirtualPortGroupTeamingPolicyProperties

    $vmHostVirtualPortGroupTeamingPolicyProperties.FailbackEnabled = $script:constants.FailbackEnabled
    $vmHostVirtualPortGroupTeamingPolicyProperties.LoadBalancingPolicy = $script:constants.LoadBalancingPolicyIP
    $vmHostVirtualPortGroupTeamingPolicyProperties.NetworkFailoverDetectionPolicy = $script:constants.NetworkFailoverDetectionPolicy
    $vmHostVirtualPortGroupTeamingPolicyProperties.NotifySwitches = $script:constants.NotifySwitches
    $vmHostVirtualPortGroupTeamingPolicyProperties.MakeNicActive = $script:constants.MakeNicActive
    $vmHostVirtualPortGroupTeamingPolicyProperties.MakeNicStandby = $script:constants.MakeNicStandby
    $vmHostVirtualPortGroupTeamingPolicyProperties.MakeNicUnused = $script:constants.MakeNicUnused
    $vmHostVirtualPortGroupTeamingPolicyProperties.InheritFailback = !$script:constants.InheritFailback
    $vmHostVirtualPortGroupTeamingPolicyProperties.InheritFailoverOrder = !$script:constants.InheritFailoverOrder
    $vmHostVirtualPortGroupTeamingPolicyProperties.InheritLoadBalancingPolicy = !$script:constants.InheritLoadBalancingPolicy
    $vmHostVirtualPortGroupTeamingPolicyProperties.InheritNetworkFailoverDetectionPolicy = !$script:constants.InheritNetworkFailoverDetectionPolicy
    $vmHostVirtualPortGroupTeamingPolicyProperties.InheritNotifySwitches = !$script:constants.InheritNotifySwitches

    $virtualPortGroupTeamingPolicyMock = $script:virtualPortGroupTeamingPolicy

    Mock -CommandName Get-NicTeamingPolicy -MockWith { return $virtualPortGroupTeamingPolicyMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VirtualPortGroup -eq $script:virtualPortGroup } -Verifiable
    Mock -CommandName Set-NicTeamingPolicy -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostVirtualPortGroupTeamingPolicyProperties
}

function New-MocksWhenTheTeamingPolicySettingsAreNonMatching {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVirtualPortGroupTeamingPolicyProperties = New-VMHostVirtualPortGroupTeamingPolicyProperties

    $vmHostVirtualPortGroupTeamingPolicyProperties.FailbackEnabled = !$script:constants.FailbackEnabled
    $vmHostVirtualPortGroupTeamingPolicyProperties.LoadBalancingPolicy = $script:constants.LoadBalancingPolicySrcMac
    $vmHostVirtualPortGroupTeamingPolicyProperties.MakeNicActive = $script:constants.MakeNicActiveSubset
    $vmHostVirtualPortGroupTeamingPolicyProperties.MakeNicUnused = $script:constants.MakeNicUnusedEmpty
    $vmHostVirtualPortGroupTeamingPolicyProperties.InheritNotifySwitches = !$script:constants.InheritNotifySwitches

    $virtualPortGroupTeamingPolicyMock = $script:virtualPortGroupTeamingPolicy

    Mock -CommandName Get-NicTeamingPolicy -MockWith { return $virtualPortGroupTeamingPolicyMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VirtualPortGroup -eq $script:virtualPortGroup } -Verifiable

    $vmHostVirtualPortGroupTeamingPolicyProperties
}

function New-MocksWhenTheTeamingPolicySettingsAreMatching {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVirtualPortGroupTeamingPolicyProperties = New-VMHostVirtualPortGroupTeamingPolicyProperties

    $vmHostVirtualPortGroupTeamingPolicyProperties.FailbackEnabled = $script:constants.FailbackEnabled
    $vmHostVirtualPortGroupTeamingPolicyProperties.LoadBalancingPolicy = $script:constants.LoadBalancingPolicyIP
    $vmHostVirtualPortGroupTeamingPolicyProperties.NetworkFailoverDetectionPolicy = $script:constants.NetworkFailoverDetectionPolicy
    $vmHostVirtualPortGroupTeamingPolicyProperties.NotifySwitches = $script:constants.NotifySwitches
    $vmHostVirtualPortGroupTeamingPolicyProperties.MakeNicActive = $script:constants.MakeNicActive
    $vmHostVirtualPortGroupTeamingPolicyProperties.MakeNicStandby = $script:constants.MakeNicStandby
    $vmHostVirtualPortGroupTeamingPolicyProperties.MakeNicUnused = $script:constants.MakeNicUnused
    $vmHostVirtualPortGroupTeamingPolicyProperties.InheritFailback = $script:constants.InheritFailback
    $vmHostVirtualPortGroupTeamingPolicyProperties.InheritFailoverOrder = $script:constants.InheritFailoverOrder
    $vmHostVirtualPortGroupTeamingPolicyProperties.InheritLoadBalancingPolicy = $script:constants.InheritLoadBalancingPolicy
    $vmHostVirtualPortGroupTeamingPolicyProperties.InheritNetworkFailoverDetectionPolicy = $script:constants.InheritNetworkFailoverDetectionPolicy
    $vmHostVirtualPortGroupTeamingPolicyProperties.InheritNotifySwitches = $script:constants.InheritNotifySwitches

    $virtualPortGroupTeamingPolicyMock = $script:virtualPortGroupTeamingPolicy

    Mock -CommandName Get-NicTeamingPolicy -MockWith { return $virtualPortGroupTeamingPolicyMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VirtualPortGroup -eq $script:virtualPortGroup } -Verifiable

    $vmHostVirtualPortGroupTeamingPolicyProperties
}

function New-MocksInGet {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVirtualPortGroupTeamingPolicyProperties = New-VMHostVirtualPortGroupTeamingPolicyProperties

    $virtualPortGroupTeamingPolicyMock = $script:virtualPortGroupTeamingPolicy

    Mock -CommandName Get-NicTeamingPolicy -MockWith { return $virtualPortGroupTeamingPolicyMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $VirtualPortGroup -eq $script:virtualPortGroup } -Verifiable

    $vmHostVirtualPortGroupTeamingPolicyProperties
}
