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
class VMHostVssTeaming : VMHostVssBaseDSC {
    <#
    .DESCRIPTION

    The flag to indicate whether or not to enable beacon probing
    as a method to validate the link status of a physical network adapter.
    #>
    [DscProperty()]
    [nullable[bool]] $CheckBeacon

    <#
    .DESCRIPTION

    List of active network adapters used for load balancing.
    #>
    [DscProperty()]
    [string[]] $ActiveNic

    <#
    .DESCRIPTION

    Standby network adapters used for failover.
    #>
    [DscProperty()]
    [string[]] $StandbyNic

    <#
    .DESCRIPTION

    Flag to specify whether or not to notify the physical switch if a link fails.
    #>
    [DscProperty()]
    [nullable[bool]] $NotifySwitches

    <#
    .DESCRIPTION

    Network adapter teaming policy.
    #>
    [DscProperty()]
    [NicTeamingPolicy] $Policy = [NicTeamingPolicy]::Unset

    <#
    .DESCRIPTION

    The flag to indicate whether or not to use a rolling policy when restoring links.
    #>
    [DscProperty()]
    [nullable[bool]] $RollingOrder

    hidden [string] $PhysicalNicNotInBridgeMessage = "Physical network adapter {0} is not in the bridge with standard switch {1}."

    [void] Set() {
        try {
            $this.WriteLogUtil('Verbose', "{0} Entering {1}", @((Get-Date), (Get-PSCallStack)[0].FunctionName))

            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetNetworkSystem($vmHost)

            $this.UpdateVssTeaming($vmHost)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.WriteLogUtil('Verbose', "{0} Entering {1}", @((Get-Date), (Get-PSCallStack)[0].FunctionName))

            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetNetworkSystem($vmHost)
            $vss = $this.GetVss()

            $result = $null
            if ($this.Ensure -eq [Ensure]::Present) {
                $result = ($null -ne $vss -and $this.Equals($vss))
            }
            else {
                $this.CheckBeacon = $false
                $this.ActiveNic = @()
                $this.StandbyNic = @()
                $this.NotifySwitches = $true
                $this.Policy = [NicTeamingPolicy]::Loadbalance_srcid
                $this.RollingOrder = $false

                $result = ($null -eq $vss -or $this.Equals($vss))
            }

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostVssTeaming] Get() {
        try {
            $this.WriteLogUtil('Verbose', "{0} Entering {1}", @((Get-Date), (Get-PSCallStack)[0].FunctionName))

            $this.ConnectVIServer()

            $result = [VMHostVssTeaming]::new()
            $result.Server = $this.Server

            $vmHost = $this.GetVMHost()
            $this.GetNetworkSystem($vmHost)

            $result.Name = $vmHost.Name
            $this.PopulateResult($vmHost, $result)

            $result.Ensure = if ([string]::Empty -ne $result.VssName) { 'Present' } else { 'Absent' }

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if the VMHostVssTeaming should to be updated.
    #>
    [bool] Equals($vss) {
        $this.WriteLogUtil('Verbose', "{0} Entering {1}", @((Get-Date), (Get-PSCallStack)[0].FunctionName))

        $vssTeamingTest = @(
            $this.ShouldUpdateDscResourceSetting('CheckBeacon', $vss.Spec.Policy.NicTeaming.FailureCriteria.CheckBeacon, $this.CheckBeacon),
            $this.ShouldUpdateDscResourceSetting('NotifySwitches', $vss.Spec.Policy.NicTeaming.NotifySwitches, $this.NotifySwitches),
            $this.ShouldUpdateDscResourceSetting('RollingOrder', $vss.Spec.Policy.NicTeaming.RollingOrder, $this.RollingOrder),
            $this.ShouldUpdateDscResourceSetting('Policy', [string] $vss.Spec.Policy.NicTeaming.Policy, $this.Policy.ToString().ToLower()),
            $this.ShouldUpdateArraySetting('ActiveNic', $vss.Spec.Policy.NicTeaming.NicOrder.ActiveNic, $this.ActiveNic),
            $this.ShouldUpdateArraySetting('StandbyNic', $vss.Spec.Policy.NicTeaming.NicOrder.StandbyNic, $this.StandbyNic)
        )

        return ($vssTeamingTest -NotContains $true)
    }

    <#
    .DESCRIPTION

    Validates that all provided physical network adapters: (ActiveNic and StandbyNic) are in the bridge
    with the specified standard switch.
    #>
    [void] ValidatePhysicalNetworkAdapters() {
        $physicalNics = $this.ActiveNic + $this.StandbyNic

        if ($physicalNics.Length -gt 0) {
            $standardSwitch = $this.GetVss()
            foreach ($physicalNic in $physicalNics) {
                if (!($standardSwitch.Spec.Bridge.NicDevice -Contains $physicalNic)) {
                    throw ($this.PhysicalNicNotInBridgeMessage -f $physicalNic, $standardSwitch.Name)
                }
            }
        }
    }

    <#
    .DESCRIPTION

    Updates the configuration of the virtual switch.
    #>
    [void] UpdateVssTeaming($vmHost) {
        $this.WriteLogUtil('Verbose', "{0} Entering {1}", @((Get-Date), (Get-PSCallStack)[0].FunctionName))

        $this.ValidatePhysicalNetworkAdapters()

        $vssTeamingArgs = @{
            Name = $this.VssName
            ActiveNic = $this.ActiveNic
            StandbyNic = $this.StandbyNic
            NotifySwitches = $this.NotifySwitches
            RollingOrder = $this.RollingOrder
        }

        if ($null -ne $this.CheckBeacon) { $vssTeamingArgs.CheckBeacon = $this.CheckBeacon }
        if ($this.Policy -ne [NicTeamingPolicy]::Unset) { $vssTeamingArgs.Policy = $this.Policy.ToString().ToLower() }

        $vss = $this.GetVss()
        if ($this.Ensure -eq 'Present') {
            if ($this.Equals($vss)) {
                return
            }
            $vssTeamingArgs.Add('Operation', 'edit')
        }
        else {
            $vssTeamingArgs.CheckBeacon = $false
            $vssTeamingArgs.ActiveNic = @()
            $vssTeamingArgs.StandbyNic = @()
            $vssTeamingArgs.NotifySwitches = $true
            $vssTeamingArgs.Policy = ([NicTeamingPolicy]::Loadbalance_srcid).ToString().ToLower()
            $vssTeamingArgs.RollingOrder = $false
            $vssTeamingArgs.Add('Operation', 'edit')
        }

        try {
            Update-Network -NetworkSystem $this.vmHostNetworkSystem -VssTeamingConfig $vssTeamingArgs -ErrorAction Stop
        }
        catch {
            throw "The Virtual Switch Teaming Policy Config could not be updated: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the Security settings of the Virtual Switch.
    #>
    [void] PopulateResult($vmHost, $vmHostVSSTeaming) {
        $this.WriteLogUtil('Verbose', "{0} Entering {1}", @((Get-Date), (Get-PSCallStack)[0].FunctionName))

        $currentVss = $this.GetVss()

        if ($null -ne $currentVss) {
            $vmHostVSSTeaming.VssName = $currentVss.Name
            $vmHostVSSTeaming.CheckBeacon = $currentVss.Spec.Policy.NicTeaming.FailureCriteria.CheckBeacon
            $vmHostVSSTeaming.ActiveNic = $currentVss.Spec.Policy.NicTeaming.NicOrder.ActiveNic
            $vmHostVSSTeaming.StandbyNic = $currentVss.Spec.Policy.NicTeaming.NicOrder.StandbyNic
            $vmHostVSSTeaming.NotifySwitches = $currentVss.Spec.Policy.NicTeaming.NotifySwitches
            $vmHostVSSTeaming.Policy = [NicTeamingPolicy]$currentVss.Spec.Policy.NicTeaming.Policy
            $vmHostVSSTeaming.RollingOrder = $currentVss.Spec.Policy.NicTeaming.RollingOrder
        }
        else {
            $vmHostVSSTeaming.VssName = $this.Name
            $vmHostVSSTeaming.CheckBeacon = $this.CheckBeacon
            $vmHostVSSTeaming.ActiveNic = $this.ActiveNic
            $vmHostVSSTeaming.StandbyNic = $this.StandbyNic
            $vmHostVSSTeaming.NotifySwitches = $this.NotifySwitches
            $vmHostVSSTeaming.Policy = $this.Policy
            $vmHostVSSTeaming.RollingOrder = $this.RollingOrder
        }
    }
}
