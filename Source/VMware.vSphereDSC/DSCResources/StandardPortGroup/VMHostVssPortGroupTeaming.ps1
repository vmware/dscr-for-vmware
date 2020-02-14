<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

[DscResource()]
class VMHostVssPortGroupTeaming : VMHostVssPortGroupBaseDSC {
    <#
    .DESCRIPTION

    Specifies how a physical adapter is returned to active duty after recovering from a failure.
    If the value is $true, the adapter is returned to active duty immediately on recovery, displacing the standby adapter that took over its slot, if any.
    If the value is $false, a failed adapter is left inactive even after recovery until another active adapter fails, requiring its replacement.
    #>
    [DscProperty()]
    [nullable[bool]] $FailbackEnabled

    <#
    .DESCRIPTION

    Determines how network traffic is distributed between the network adapters assigned to a switch. The following values are valid:
    LoadBalanceIP - Route based on IP hash. Choose an uplink based on a hash of the source and destination IP addresses of each packet.
    For non-IP packets, whatever is at those offsets is used to compute the hash.
    LoadBalanceSrcMac - Route based on source MAC hash. Choose an uplink based on a hash of the source Ethernet.
    LoadBalanceSrcId - Route based on the originating port ID. Choose an uplink based on the virtual port where the traffic entered the virtual switch.
    ExplicitFailover - Always use the highest order uplink from the list of Active adapters that passes failover detection criteria.
    #>
    [DscProperty()]
    [LoadBalancingPolicy] $LoadBalancingPolicy = [LoadBalancingPolicy]::Unset

    <#
    .DESCRIPTION

    Specifies the adapters you want to continue to use when the network adapter connectivity is available and active.
    #>
    [DscProperty()]
    [string[]] $ActiveNic

    <#
    .DESCRIPTION

    Specifies the adapters you want to use if one of the active adapter's connectivity is unavailable.
    #>
    [DscProperty()]
    [string[]] $StandbyNic

    <#
    .DESCRIPTION

    Specifies the adapters you do not want to use.
    #>
    [DscProperty()]
    [string[]] $UnusedNic

    <#
    .DESCRIPTION

    Specifies how to reroute traffic in the event of an adapter failure. The following values are valid:
    LinkStatus - Relies solely on the link status that the network adapter provides. This option detects failures, such as cable pulls and physical switch power failures,
    but not configuration errors, such as a physical switch port being blocked by spanning tree or misconfigured to the wrong VLAN or cable pulls on the other side of a physical switch.
    BeaconProbing - Sends out and listens for beacon probes on all NICs in the team and uses this information, in addition to link status, to determine link failure.
    This option detects many of the failures mentioned above that are not detected by link status alone.
    #>
    [DscProperty()]
    [NetworkFailoverDetectionPolicy] $NetworkFailoverDetectionPolicy = [NetworkFailoverDetectionPolicy]::Unset

    <#
    .DESCRIPTION

    Indicates that whenever a virtual NIC is connected to the virtual switch or whenever that virtual NIC's traffic is routed over a different physical NIC in the team because of a
    failover event, a notification is sent over the network to update the lookup tables on the physical switches.
    #>
    [DscProperty()]
    [nullable[bool]] $NotifySwitches

    <#
    .DESCRIPTION

    Indicates that the value of the FailbackEnabled parameter is inherited from the virtual switch.
    #>
    [DscProperty()]
    [nullable[bool]] $InheritFailback

    <#
    .DESCRIPTION

    Indicates that the values of the ActiveNic, StandbyNic, and UnusedNic parameters are inherited from the virtual switch.
    #>
    [DscProperty()]
    [nullable[bool]] $InheritFailoverOrder

    <#
    .DESCRIPTION

    Indicates that the value of the LoadBalancingPolicy parameter is inherited from the virtual switch.
    #>
    [DscProperty()]
    [nullable[bool]] $InheritLoadBalancingPolicy

    <#
    .DESCRIPTION

    Indicates that the value of the NetworkFailoverDetectionPolicy parameter is inherited from the virtual switch.
    #>
    [DscProperty()]
    [nullable[bool]] $InheritNetworkFailoverDetectionPolicy

    <#
    .DESCRIPTION

    Indicates that the value of the NotifySwitches parameter is inherited from the virtual switch.
    #>
    [DscProperty()]
    [nullable[bool]] $InheritNotifySwitches

    hidden [string] $FailbackEnabledSettingName = 'FailbackEnabled'
    hidden [string] $InheritFailbackSettingName = 'InheritFailback'
    hidden [string] $LoadBalancingPolicySettingName = 'LoadBalancingPolicy'
    hidden [string] $InheritLoadBalancingPolicySettingName = 'InheritLoadBalancingPolicy'
    hidden [string] $NetworkFailoverDetectionPolicySettingName = 'NetworkFailoverDetectionPolicy'
    hidden [string] $InheritNetworkFailoverDetectionPolicySettingName = 'InheritNetworkFailoverDetectionPolicy'
    hidden [string] $NotifySwitchesSettingName = 'NotifySwitches'
    hidden [string] $InheritNotifySwitchesSettingName = 'InheritNotifySwitches'
    hidden [string] $MakeNicActiveSettingName = 'MakeNicActive'
    hidden [string] $MakeNicStandbySettingName = 'MakeNicStandby'
    hidden [string] $MakeNicUnusedSettingName = 'MakeNicUnused'
    hidden [string] $InheritFailoverOrderSettingName = 'InheritFailoverOrder'

    [void] Set() {
        try {
            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $virtualPortGroup = $this.GetVirtualPortGroup()
            $virtualPortGroupTeamingPolicy = $this.GetVirtualPortGroupTeamingPolicy($virtualPortGroup)

            $this.UpdateVirtualPortGroupTeamingPolicy($virtualPortGroupTeamingPolicy)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $virtualPortGroup = $this.GetVirtualPortGroup()
            if ($null -eq $virtualPortGroup) {
                # If the Port Group is $null, it means that Ensure is 'Absent' and the Port Group does not exist.
                return $true
            }

            $virtualPortGroupTeamingPolicy = $this.GetVirtualPortGroupTeamingPolicy($virtualPortGroup)

            return !$this.ShouldUpdateVirtualPortGroupTeamingPolicy($virtualPortGroupTeamingPolicy)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostVssPortGroupTeaming] Get() {
        try {
            $result = [VMHostVssPortGroupTeaming]::new()
            $result.Server = $this.Server
            $result.Ensure = $this.Ensure

            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $result.VMHostName = $this.VMHost.Name

            $virtualPortGroup = $this.GetVirtualPortGroup()
            if ($null -eq $virtualPortGroup) {
                # If the Port Group is $null, it means that Ensure is 'Absent' and the Port Group does not exist.
                $result.Name = $this.Name
                return $result
            }

            $virtualPortGroupTeamingPolicy = $this.GetVirtualPortGroupTeamingPolicy($virtualPortGroup)
            $result.Name = $virtualPortGroup.Name

            $this.PopulateResult($virtualPortGroupTeamingPolicy, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Virtual Port Group Teaming Policy from the server.
    #>
    [PSObject] GetVirtualPortGroupTeamingPolicy($virtualPortGroup) {
        try {
            $virtualPortGroupTeamingPolicy = Get-NicTeamingPolicy -Server $this.Connection -VirtualPortGroup $virtualPortGroup -ErrorAction Stop
            return $virtualPortGroupTeamingPolicy
        }
        catch {
            throw "Could not retrieve Virtual Port Group $($this.Name) Teaming Policy. For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Checks if the passed Nic array is in the desired state and if an update should be performed.
    #>
    [bool] ShouldUpdateNicArray($currentNicArray, $desiredNicArray) {
        if ($null -eq $desiredNicArray -or $desiredNicArray.Length -eq 0) {
            # The property is not specified or an empty Nic array is passed.
            return $false
        }
        else {
            $nicsToAdd = $desiredNicArray | Where-Object { $currentNicArray -NotContains $_ }
            $nicsToRemove = $currentNicArray | Where-Object { $desiredNicArray -NotContains $_ }

            if ($null -ne $nicsToAdd -or $null -ne $nicsToRemove) {
                <#
                The current Nic array does not contain at least one Nic from desired Nic array or
                the desired Nic array is a subset of the current Nic array. In both cases
                we should perform an update operation.
                #>
                return $true
            }

            # No need to perform an update operation.
            return $false
        }
    }

    <#
    .DESCRIPTION

    Checks if the Teaming Policy of the specified Virtual Port Group should be updated.
    #>
    [bool] ShouldUpdateVirtualPortGroupTeamingPolicy($virtualPortGroupTeamingPolicy) {
        $shouldUpdateVirtualPortGroupTeamingPolicy = @()

        $shouldUpdateVirtualPortGroupTeamingPolicy += $this.ShouldUpdateNicArray($virtualPortGroupTeamingPolicy.ActiveNic, $this.ActiveNic)
        $shouldUpdateVirtualPortGroupTeamingPolicy += $this.ShouldUpdateNicArray($virtualPortGroupTeamingPolicy.StandbyNic, $this.StandbyNic)
        $shouldUpdateVirtualPortGroupTeamingPolicy += $this.ShouldUpdateNicArray($virtualPortGroupTeamingPolicy.UnusedNic, $this.UnusedNic)

        $shouldUpdateVirtualPortGroupTeamingPolicy += ($null -ne $this.FailbackEnabled -and $this.FailbackEnabled -ne $virtualPortGroupTeamingPolicy.FailbackEnabled)
        $shouldUpdateVirtualPortGroupTeamingPolicy += ($null -ne $this.NotifySwitches -and $this.NotifySwitches -ne $virtualPortGroupTeamingPolicy.NotifySwitches)
        $shouldUpdateVirtualPortGroupTeamingPolicy += ($null -ne $this.InheritFailback -and $this.InheritFailback -ne $virtualPortGroupTeamingPolicy.IsFailbackInherited)
        $shouldUpdateVirtualPortGroupTeamingPolicy += ($null -ne $this.InheritFailoverOrder -and $this.InheritFailoverOrder -ne $virtualPortGroupTeamingPolicy.IsFailoverOrderInherited)
        $shouldUpdateVirtualPortGroupTeamingPolicy += ($null -ne $this.InheritLoadBalancingPolicy -and $this.InheritLoadBalancingPolicy -ne $virtualPortGroupTeamingPolicy.IsLoadBalancingInherited)
        $shouldUpdateVirtualPortGroupTeamingPolicy += ($null -ne $this.InheritNetworkFailoverDetectionPolicy -and $this.InheritNetworkFailoverDetectionPolicy -ne $virtualPortGroupTeamingPolicy.IsNetworkFailoverDetectionInherited)
        $shouldUpdateVirtualPortGroupTeamingPolicy += ($null -ne $this.InheritNotifySwitches -and $this.InheritNotifySwitches -ne $virtualPortGroupTeamingPolicy.IsNotifySwitchesInherited)

        if ($this.LoadBalancingPolicy -ne [LoadBalancingPolicy]::Unset) {
            $shouldUpdateVirtualPortGroupTeamingPolicy += ($this.LoadBalancingPolicy.ToString() -ne $virtualPortGroupTeamingPolicy.LoadBalancingPolicy.ToString())
        }

        if ($this.NetworkFailoverDetectionPolicy -ne [NetworkFailoverDetectionPolicy]::Unset) {
            $shouldUpdateVirtualPortGroupTeamingPolicy += ($this.NetworkFailoverDetectionPolicy.ToString() -ne $virtualPortGroupTeamingPolicy.NetworkFailoverDetectionPolicy.ToString())
        }

        return ($shouldUpdateVirtualPortGroupTeamingPolicy -Contains $true)
    }

    <#
    .DESCRIPTION

    Populates the specified Enum Policy Setting. If the Inherited Setting is passed and set to $true,
    the Policy Setting should not be populated because "Parameters of the form "XXX" and "InheritXXX" are mutually exclusive."
    If the Inherited Setting is set to $false, both parameters can be populated.
    #>
    [void] PopulateEnumPolicySetting($policyParams, $policySettingName, $policySetting, $policySettingInheritedName, $policySettingInherited) {
        if ($policySetting -ne 'Unset') {
            if ($null -eq $policySettingInherited -or !$policySettingInherited) {
                $policyParams.$policySettingName = $policySetting
            }
        }

        if ($null -ne $policySettingInherited) { $policyParams.$policySettingInheritedName = $policySettingInherited }
    }

    <#
    .DESCRIPTION

    Populates the specified Array Policy Setting. If the Inherited Setting is passed and set to $true,
    the Policy Setting should not be populated because "Parameters of the form "XXX" and "InheritXXX" are mutually exclusive."
    If the Inherited Setting is set to $false, both parameters can be populated.
    #>
    [void] PopulateArrayPolicySetting($policyParams, $policySettingName, $policySetting, $policySettingInheritedName, $policySettingInherited) {
        if ($null -ne $policySetting -and $policySetting.Length -gt 0) {
            if ($null -eq $policySettingInherited -or !$policySettingInherited) {
                $policyParams.$policySettingName = $policySetting
            }
        }

        if ($null -ne $policySettingInherited) { $policyParams.$policySettingInheritedName = $policySettingInherited }
    }

    <#
    .DESCRIPTION

    Performs an update on the Teaming Policy of the specified Virtual Port Group.
    #>
    [void] UpdateVirtualPortGroupTeamingPolicy($virtualPortGroupTeamingPolicy) {
        $teamingPolicyParams = @{}
        $teamingPolicyParams.VirtualPortGroupPolicy = $virtualPortGroupTeamingPolicy

        $this.PopulatePolicySetting($teamingPolicyParams, $this.FailbackEnabledSettingName, $this.FailbackEnabled, $this.InheritFailbackSettingName, $this.InheritFailback)
        $this.PopulatePolicySetting($teamingPolicyParams, $this.NotifySwitchesSettingName, $this.NotifySwitches, $this.InheritNotifySwitchesSettingName, $this.InheritNotifySwitches)

        $this.PopulateEnumPolicySetting($teamingPolicyParams, $this.LoadBalancingPolicySettingName, $this.LoadBalancingPolicy.ToString(), $this.InheritLoadBalancingPolicySettingName, $this.InheritLoadBalancingPolicy)
        $this.PopulateEnumPolicySetting($teamingPolicyParams, $this.NetworkFailoverDetectionPolicySettingName, $this.NetworkFailoverDetectionPolicy.ToString(), $this.InheritNetworkFailoverDetectionPolicySettingName, $this.InheritNetworkFailoverDetectionPolicy)

        $this.PopulateArrayPolicySetting($teamingPolicyParams, $this.MakeNicActiveSettingName, $this.ActiveNic, $this.InheritFailoverOrderSettingName, $this.InheritFailoverOrder)
        $this.PopulateArrayPolicySetting($teamingPolicyParams, $this.MakeNicStandbySettingName, $this.StandbyNic, $this.InheritFailoverOrderSettingName, $this.InheritFailoverOrder)
        $this.PopulateArrayPolicySetting($teamingPolicyParams, $this.MakeNicUnusedSettingName, $this.UnusedNic, $this.InheritFailoverOrderSettingName, $this.InheritFailoverOrder)

        try {
            Set-NicTeamingPolicy @teamingPolicyParams
        }
        catch {
            throw "Cannot update Teaming Policy of Virtual Port Group $($this.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the Teaming Policy of the specified Virtual Port Group from the server.
    #>
    [void] PopulateResult($virtualPortGroupTeamingPolicy, $result) {
        $result.FailbackEnabled = $virtualPortGroupTeamingPolicy.FailbackEnabled
        $result.NotifySwitches = $virtualPortGroupTeamingPolicy.NotifySwitches
        $result.LoadBalancingPolicy = $virtualPortGroupTeamingPolicy.LoadBalancingPolicy.ToString()
        $result.NetworkFailoverDetectionPolicy = $virtualPortGroupTeamingPolicy.NetworkFailoverDetectionPolicy.ToString()
        $result.ActiveNic = $virtualPortGroupTeamingPolicy.ActiveNic
        $result.StandbyNic = $virtualPortGroupTeamingPolicy.StandbyNic
        $result.UnusedNic = $virtualPortGroupTeamingPolicy.UnusedNic
        $result.InheritFailback = $virtualPortGroupTeamingPolicy.IsFailbackInherited
        $result.InheritNotifySwitches = $virtualPortGroupTeamingPolicy.IsNotifySwitchesInherited
        $result.InheritLoadBalancingPolicy = $virtualPortGroupTeamingPolicy.IsLoadBalancingInherited
        $result.InheritNetworkFailoverDetectionPolicy = $virtualPortGroupTeamingPolicy.IsNetworkFailoverDetectionInherited
        $result.InheritFailoverOrder = $virtualPortGroupTeamingPolicy.IsFailoverOrderInherited
    }
}
