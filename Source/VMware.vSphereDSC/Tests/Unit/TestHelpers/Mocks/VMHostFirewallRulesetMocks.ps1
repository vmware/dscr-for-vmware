<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-VMHostFirewallRulesetProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostFirewallRulesetProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        VMHostName = $script:constants.VMHostName
        Name = $script:constants.FirewallRulesetName
    }

    $vmHostFirewallRulesetProperties
}

function New-MocksForVMHostFirewallRuleset {
    [CmdletBinding()]

    $viServerMock = $script:viServer
    $vmHostMock = $script:vmHost
    $vmHostFirewallRulesetMock = $script:vmHostFirewallRuleset

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHostFirewallException -MockWith { return $vmHostFirewallRulesetMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.FirewallRulesetName -and $VMHost -eq $script:vmHost } -Verifiable
    Mock -CommandName Disconnect-VIServer -MockWith { return $null }.GetNewClosure() -Verifiable
}

function New-MocksWhenErrorOccursWhileModifyingTheStateOfTheVMHostFirewallRuleset {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostFirewallRulesetProperties = New-VMHostFirewallRulesetProperties

    $vmHostFirewallRulesetProperties.Enabled = !$script:constants.FirewallRulesetEnabled

    Mock -CommandName Set-VMHostFirewallException -MockWith { throw }.GetNewClosure() -ParameterFilter { $Exception -eq $script:vmHostFirewallRuleset -and $Enabled -eq !$script:constants.FirewallRulesetEnabled -and !$Confirm } -Verifiable

    $vmHostFirewallRulesetProperties
}

function New-MocksWhenNoErrorOccursWhileModifyingTheStateOfTheVMHostFirewallRuleset {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostFirewallRulesetProperties = New-VMHostFirewallRulesetProperties

    $vmHostFirewallRulesetProperties.Enabled = !$script:constants.FirewallRulesetEnabled

    Mock -CommandName Set-VMHostFirewallException -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostFirewallRulesetProperties
}

function New-MocksWhenErrorOccursWhileModifyingTheAllowedIPAddressesListOfTheVMHostFirewallRuleset {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostFirewallRulesetProperties = New-VMHostFirewallRulesetProperties

    $vmHostFirewallRulesetProperties.AllIP = !$script:constants.FirewallRulesetAllIP
    $vmHostFirewallRulesetProperties.IPAddresses = $script:constants.FirewallRulesetIPAddressesTwo + $script:constants.FirewallRulesetIPNetworksTwo

    $vmHostFirewallSystemMock = $script:vmHostFirewallSystem

    Mock -CommandName Get-View -MockWith { return $vmHostFirewallSystemMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:vmHost.ExtensionData.ConfigManager.FirewallSystem } -Verifiable
    Mock -CommandName Update-VMHostFirewallRuleset -MockWith { throw }.GetNewClosure() -ParameterFilter { $VMHostFirewallSystem -eq $script:vmHostFirewallSystem -and $VMHostFirewallRulesetId -eq $script:vmHostFirewallRuleset.ExtensionData.Key -and $VMHostFirewallRulesetSpec -eq $script:vmHostFirewallRulesetSpec } -Verifiable

    $vmHostFirewallRulesetProperties
}

function New-MocksWhenNoErrorOccursWhileModifyingTheAllowedIPAddressesListOfTheVMHostFirewallRuleset {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostFirewallRulesetProperties = New-VMHostFirewallRulesetProperties

    $vmHostFirewallRulesetProperties.AllIP = !$script:constants.FirewallRulesetAllIP
    $vmHostFirewallRulesetProperties.IPAddresses = $script:constants.FirewallRulesetIPAddressesTwo + $script:constants.FirewallRulesetIPNetworksTwo

    $vmHostFirewallSystemMock = $script:vmHostFirewallSystem

    Mock -CommandName Get-View -MockWith { return $vmHostFirewallSystemMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Id -eq $script:vmHost.ExtensionData.ConfigManager.FirewallSystem } -Verifiable
    Mock -CommandName Update-VMHostFirewallRuleset -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostFirewallRulesetProperties
}

function New-MocksWhenTheStateOfTheVMHostFirewallRulesetDoesNotNeedToBeModified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostFirewallRulesetProperties = New-VMHostFirewallRulesetProperties

    $vmHostFirewallRulesetProperties.Enabled = $script:constants.FirewallRulesetEnabled

    $vmHostFirewallRulesetProperties
}

function New-MocksWhenTheStateOfTheVMHostFirewallRulesetNeedsToBeModified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostFirewallRulesetProperties = New-VMHostFirewallRulesetProperties

    $vmHostFirewallRulesetProperties.Enabled = !$script:constants.FirewallRulesetEnabled

    $vmHostFirewallRulesetProperties
}

function New-MocksWhenTheAllowedIPAddressesListOfTheVMHostFirewallRulesetDoesNotNeedToBeModified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostFirewallRulesetProperties = New-VMHostFirewallRulesetProperties

    $vmHostFirewallRulesetProperties.AllIP = $script:constants.FirewallRulesetAllIP
    $vmHostFirewallRulesetProperties.IPAddresses = $script:constants.FirewallRulesetIPAddressesOne + $script:constants.FirewallRulesetIPNetworksOne

    $vmHostFirewallRulesetProperties
}

function New-MocksWhenTheAllowedIPAddressesListOfTheVMHostFirewallRulesetNeedsToBeModified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostFirewallRulesetProperties = New-VMHostFirewallRulesetProperties

    $vmHostFirewallRulesetProperties.AllIP = !$script:constants.FirewallRulesetAllIP
    $vmHostFirewallRulesetProperties.IPAddresses = $script:constants.FirewallRulesetIPAddressesTwo + $script:constants.FirewallRulesetIPNetworksTwo

    $vmHostFirewallRulesetProperties
}
