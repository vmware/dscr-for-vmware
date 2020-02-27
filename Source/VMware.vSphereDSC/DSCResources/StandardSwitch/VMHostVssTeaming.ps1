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

    [void] Set() {
        try {
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

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
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $this.GetNetworkSystem($vmHost)
            $vss = $this.GetVss()

            if ($this.Ensure -eq [Ensure]::Present) {
                return ($null -ne $vss -and $this.Equals($vss))
            }
            else {
                $this.CheckBeacon = $false
                $this.ActiveNic = @()
                $this.StandbyNic = @()
                $this.NotifySwitches = $true
                $this.Policy = [NicTeamingPolicy]::Loadbalance_srcid
                $this.RollingOrder = $false

                return ($null -eq $vss -or $this.Equals($vss))
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostVssTeaming] Get() {
        try {
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

            $result = [VMHostVssTeaming]::new()
            $result.Server = $this.Server

            $this.ConnectVIServer()
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
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

        $vssTeamingTest = @()
        $vssTeamingTest += ($null -eq $this.CheckBeacon -or $vss.Spec.Policy.NicTeaming.FailureCriteria.CheckBeacon -eq $this.CheckBeacon)
        $vssTeamingTest += !$this.ShouldUpdateArraySetting($vss.Spec.Policy.NicTeaming.NicOrder.ActiveNic, $this.ActiveNic)
        $vssTeamingTest += !$this.ShouldUpdateArraySetting($vss.Spec.Policy.NicTeaming.NicOrder.StandbyNic, $this.StandbyNic)
        $vssTeamingTest += ($null -eq $this.NotifySwitches -or $vss.Spec.Policy.NicTeaming.NotifySwitches -eq $this.NotifySwitches)
        $vssTeamingTest += ($null -eq $this.RollingOrder -or $vss.Spec.Policy.NicTeaming.RollingOrder -eq $this.RollingOrder)

        # The Network Adapter teaming policy should determine the Desired State only when it is specified.
        if ($this.Policy -ne [NicTeamingPolicy]::Unset) { $vssTeamingTest += ($vss.Spec.Policy.NicTeaming.Policy -eq $this.Policy.ToString().ToLower()) }

        return ($vssTeamingTest -notcontains $false)
    }

    <#
    .DESCRIPTION

    Updates the configuration of the virtual switch.
    #>
    [void] UpdateVssTeaming($vmHost) {
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

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
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

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
