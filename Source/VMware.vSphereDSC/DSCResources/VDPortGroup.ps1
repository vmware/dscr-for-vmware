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
class VDPortGroup : BaseDSC {
    <#
    .DESCRIPTION

    Specifies the name of the Distributed Port Group.
    #>
    [DscProperty(Key)]
    [string] $Name

    <#
    .DESCRIPTION

    Specifies the name of the vSphere Distributed Switch associated with the Distributed Port Group.
    #>
    [DscProperty(Mandatory)]
    [string] $VdsName

    <#
    .DESCRIPTION

    Value indicating if the Distributed Port Group should be Present or Absent.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    <#
    .DESCRIPTION

    Specifies a description for the Distributed Port Group.
    #>
    [DscProperty()]
    [string] $Notes

    <#
    .DESCRIPTION

    Specifies the number of ports that the Distributed Port Group will have.
    If the parameter is not specified, the number of ports for the Distributed Port Group is 128.
    #>
    [DscProperty()]
    [nullable[int]] $NumPorts

    <#
    .DESCRIPTION

    Specifies the port binding setting for the Distributed Port Group.
    Valid values are Static, Dynamic, and Ephemeral.
    #>
    [DscProperty()]
    [PortBinding] $PortBinding = [PortBinding]::Unset

    <#
    .DESCRIPTION

    Specifies the name for the reference Distributed Port Group.
    The properties of the new Distributed Port Group will be cloned from the reference Distributed Port Group.
    #>
    [DscProperty()]
    [string] $ReferenceVDPortGroupName

    [void] Set() {
        try {
            $this.ConnectVIServer()
            $this.EnsureConnectionIsvCenter()

            $distributedSwitch = $this.GetDistributedSwitch()
            $distributedPortGroup = $this.GetDistributedPortGroup($distributedSwitch)

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $distributedPortGroup) {
                    $this.AddDistributedPortGroup($distributedSwitch)
                }
                else {
                    $this.UpdateDistributedPortGroup($distributedPortGroup)
                }
            }
            else {
                if ($null -ne $distributedPortGroup) {
                    $this.RemoveDistributedPortGroup($distributedPortGroup)
                }
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()
            $this.EnsureConnectionIsvCenter()

            $distributedSwitch = $this.GetDistributedSwitch()
            $distributedPortGroup = $this.GetDistributedPortGroup($distributedSwitch)

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $distributedPortGroup) {
                    return $false
                }

                return !$this.ShouldUpdateDistributedPortGroup($distributedPortGroup)
            }
            else {
                return ($null -eq $distributedPortGroup)
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VDPortGroup] Get() {
        try {
            $result = [VDPortGroup]::new()

            $this.ConnectVIServer()
            $this.EnsureConnectionIsvCenter()

            $distributedSwitch = $this.GetDistributedSwitch()
            $distributedPortGroup = $this.GetDistributedPortGroup($distributedSwitch)

            $this.PopulateResult($distributedPortGroup, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Distributed Switch with the specified name from the server if it exists.
    If the Distributed Switch does not exist and Ensure is set to 'Absent', $null is returned.
    Otherwise it throws an exception.
    #>
    [PSObject] GetDistributedSwitch() {
        <#
        The Verbose logic here is needed to suppress the Exporting and Importing of the
        cmdlets from the VMware.VimAutomation.Vds Module.
        #>
        $savedVerbosePreference = $global:VerbosePreference
        $global:VerbosePreference = 'SilentlyContinue'

        try {
            if ($this.Ensure -eq [Ensure]::Absent) {
                return Get-VDSwitch -Server $this.Connection -Name $this.VdsName -ErrorAction SilentlyContinue
            }
            else {
                try {
                    $distributedSwitch = Get-VDSwitch -Server $this.Connection -Name $this.VdsName -ErrorAction Stop
                    return $distributedSwitch
                }
                catch {
                    throw "Could not retrieve Distributed Switch $($this.VdsName). For more information: $($_.Exception.Message)"
                }
            }
        }
        finally {
            $global:VerbosePreference = $savedVerbosePreference
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Distributed Port Group with the specified name, available on the specified Distributed Switch from the server if it exists.
    Otherwise returns $null.
    #>
    [PSObject] GetDistributedPortGroup($distributedSwitch) {
        if ($null -eq $distributedSwitch) {
            <#
            If the Distributed Switch is $null, it means that Ensure was set to 'Absent' and
            the Distributed Port Group does not exist for the specified Distributed Switch.
            #>
            return $null
        }

        return Get-VDPortgroup -Server $this.Connection -Name $this.Name -VDSwitch $distributedSwitch -ErrorAction SilentlyContinue
    }

    <#
    .DESCRIPTION

    Checks if the passed Distributed Port Group needs be modified based on the passed properties.
    #>
    [bool] ShouldUpdateDistributedPortGroup($distributedPortGroup) {
        $shouldUpdateDistributedPortGroup = @()

        <#
        The VDPortGroup object does not contain information about ReferenceVDPortGroupName so the property is not
        part of the Desired State of the Resource.
        #>
        if ($null -ne $this.Notes) {
            <#
            The server value for Notes property can be both $null and empty string. The DSC Resource will support only empty string value.
            Null value means that the property was not passed in the Configuration.
            #>
            if ($this.Notes -eq [string]::Empty) {
                $shouldUpdateDistributedPortGroup += ($null -ne $distributedPortGroup.Notes -and $distributedPortGroup.Notes -ne [string]::Empty)
            }
            else {
                $shouldUpdateDistributedPortGroup += ($this.Notes -ne $distributedPortGroup.Notes)
            }
        }

        $shouldUpdateDistributedPortGroup += ($null -ne $this.NumPorts -and $this.NumPorts -ne $distributedPortGroup.NumPorts)

        if ($this.PortBinding -ne [PortBinding]::Unset) {
            $shouldUpdateDistributedPortGroup += ($this.PortBinding.ToString() -ne $distributedPortGroup.PortBinding.ToString())
        }

        return ($shouldUpdateDistributedPortGroup -Contains $true)
    }

    <#
    .DESCRIPTION

    Returns the populated Distributed Port Group parameters.
    #>
    [hashtable] GetDistributedPortGroupParams() {
        $distributedPortGroupParams = @{}

        $distributedPortGroupParams.Server = $this.Connection
        $distributedPortGroupParams.Confirm = $false
        $distributedPortGroupParams.ErrorAction = 'Stop'

        if ($null -ne $this.Notes) { $distributedPortGroupParams.Notes = $this.Notes }
        if ($null -ne $this.NumPorts) { $distributedPortGroupParams.NumPorts = $this.NumPorts }

        if ($this.PortBinding -ne [PortBinding]::Unset) {
            $distributedPortGroupParams.PortBinding = $this.PortBinding.ToString()
        }

        return $distributedPortGroupParams
    }

    <#
    .DESCRIPTION

    Creates a new Distributed Port Group available on the specified Distributed Switch.
    #>
    [void] AddDistributedPortGroup($distributedSwitch) {
        $distributedPortGroupParams = $this.GetDistributedPortGroupParams()
        $distributedPortGroupParams.Name = $this.Name
        $distributedPortGroupParams.VDSwitch = $distributedSwitch

        <#
        ReferencePortGroup is parameter only for the New-VDPortgroup cmdlet
        and is not used for the Set-VDPortgroup cmdlet.
        #>
        if (![string]::IsNullOrEmpty($this.ReferenceVDPortGroupName)) { $distributedPortGroupParams.ReferencePortgroup = $this.ReferenceVDPortGroupName }

        try {
            New-VDPortgroup @distributedPortGroupParams
        }
        catch {
            throw "Cannot create Distributed Port Group $($this.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Modifies the configuration of the specified Distributed Port Group with the passed properties.
    #>
    [void] UpdateDistributedPortGroup($distributedPortGroup) {
        $distributedPortGroupParams = $this.GetDistributedPortGroupParams()

        try {
            $distributedPortGroup | Set-VDPortgroup @distributedPortGroupParams
        }
        catch {
            throw "Cannot update Distributed Port Group $($this.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Removes the specified Distributed Port Group from the vSphere Distributed Switch that it belongs to.
    #>
    [void] RemoveDistributedPortGroup($distributedPortGroup) {
        try {
            $distributedPortGroup | Remove-VDPortGroup -Server $this.Connection -Confirm:$false -ErrorAction Stop
        }
        catch {
            throw "Cannot remove Distributed Port Group $($this.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method.
    #>
    [void] PopulateResult($distributedPortGroup, $result) {
        $result.Server = $this.Connection.Name
        $result.ReferenceVDPortGroupName = $this.ReferenceVDPortGroupName

        if ($null -ne $distributedPortGroup) {
            $result.Name = $distributedPortGroup.Name
            $result.VdsName = $distributedPortGroup.VDSwitch.Name
            $result.Ensure = [Ensure]::Present
            $result.Notes = $distributedPortGroup.Notes
            $result.NumPorts = $distributedPortGroup.NumPorts
            $result.PortBinding = $distributedPortGroup.PortBinding.ToString()
        }
        else {
            $result.Name = $this.Name
            $result.VdsName = $this.VdsName
            $result.Ensure = [Ensure]::Absent
            $result.Notes = $this.Notes
            $result.NumPorts = $this.NumPorts
            $result.PortBinding = $this.PortBinding
        }
    }
}
