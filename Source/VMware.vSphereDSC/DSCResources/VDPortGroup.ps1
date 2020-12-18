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

    Specifies the VLAN ID for the Distributed Port Group.
    Valid values are integers in the range of 1 to 4094.
    If 0 is specified, the VLAN type is 'None'.
    #>
    [DscProperty()]
    [nullable[int]] $VLanId

    <#
    .DESCRIPTION

    Specifies the name for the reference Distributed Port Group.
    The properties of the new Distributed Port Group will be cloned from the reference Distributed Port Group.
    #>
    [DscProperty()]
    [string] $ReferenceVDPortGroupName

    hidden [string] $RetrieveVDSwitchMessage = "Retrieving distributed switch {0}."
    hidden [string] $CreateVDPortGroupMessage = "Creating distributed port group {0} on distributed switch {1}."
    hidden [string] $ModifyVDPortGroupMessage = "Modifying distributed port group {0}."
    hidden [string] $ModifyVDPortGroupVlanConfigurationMessage = "Modifying the VLAN ID of distributed port group {0} to {1}."
    hidden [string] $RemoveVDPortGroupMessage = "Removing distributed port group {0} from distributed switch {1}."

    hidden [string] $CouldNotRetrieveVDSwitchMessage = "Could not retrieve distributed switch {0}. For more information: {1}"
    hidden [string] $CouldNotCreateVDPortGroupMessage = "Could not create distributed port group {0} on distributed switch {1}. For more information: {2}"
    hidden [string] $CouldNotModifyVDPortGroupMessage = "Could not modify distributed port group {0}. For more information: {1}"
    hidden [string] $CouldNotModifyVDPortGroupVlanConfigurationMessage = "Could not modify the VLAN ID of distributed port group {0} to {1}. For more information: {2}"
    hidden [string] $CouldNotRemoveVDPortGroupMessage = "Could not remove distributed port group {0} from distributed switch {1}. For more information: {2}"

    [void] Set() {
        try {
            $this.WriteLogUtil('Verbose', $this.SetMethodStartMessage, @($this.DscResourceName))
            $this.ConnectVIServer()
            $this.EnsureConnectionIsvCenter()

            $distributedSwitch = $this.GetDistributedSwitch()
            $distributedPortGroup = $this.GetDistributedPortGroup($distributedSwitch)

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $distributedPortGroup) {
                    $this.AddDistributedPortGroup($distributedSwitch)
                }
                else {
                    if ($this.ShouldUpdateVLanId($distributedPortGroup)) {
                        $this.UpdateDistributedPortGroupVlanConfiguration($distributedPortGroup)
                    }

                    if ($this.ShouldUpdateDistributedPortGroup($distributedPortGroup)) {
                        $this.UpdateDistributedPortGroup($distributedPortGroup)
                    }
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
            $this.WriteLogUtil('Verbose', $this.SetMethodEndMessage, @($this.DscResourceName))
        }
    }

    [bool] Test() {
        try {
            $this.WriteLogUtil('Verbose', $this.TestMethodStartMessage, @($this.DscResourceName))
            $this.ConnectVIServer()
            $this.EnsureConnectionIsvCenter()

            $distributedSwitch = $this.GetDistributedSwitch()
            $distributedPortGroup = $this.GetDistributedPortGroup($distributedSwitch)

            $result = $null
            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $distributedPortGroup) {
                    $result = $false
                }
                else {
                    $result = if ($this.ShouldUpdateDistributedPortGroup($distributedPortGroup) -or $this.ShouldUpdateVLanId($distributedPortGroup)) { $false } else { $true }
                }
            }
            else {
                $result = ($null -eq $distributedPortGroup)
            }

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            $this.WriteLogUtil('Verbose', $this.TestMethodEndMessage, @($this.DscResourceName))
        }
    }

    [VDPortGroup] Get() {
        try {
            $this.WriteLogUtil('Verbose', $this.GetMethodStartMessage, @($this.DscResourceName))
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
            $this.WriteLogUtil('Verbose', $this.GetMethodEndMessage, @($this.DscResourceName))
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
            The Verbose logic here is needed to suppress the Verbose output of the Import-Module cmdlet
            when importing the 'VMware.VimAutomation.Vds' Module.
        #>
        $savedVerbosePreference = $global:VerbosePreference
        $global:VerbosePreference = 'SilentlyContinue'

        try {
            $getVDSwitchParams = @{
                Server = $this.Connection
                Name = $this.VdsName
                Verbose = $false
            }
            if ($this.Ensure -eq [Ensure]::Absent) {
                $getVDSwitchParams.ErrorAction = 'SilentlyContinue'
                return Get-VDSwitch @getVDSwitchParams
            }
            else {
                try {
                    $this.WriteLogUtil('Verbose', $this.RetrieveVDSwitchMessage, @($this.VdsName))
                    $getVDSwitchParams.ErrorAction = 'Stop'
                    return Get-VDSwitch @getVDSwitchParams
                }
                catch {
                    throw ($this.CouldNotRetrieveVDSwitchMessage -f $this.VdsName, $_.Exception.Message)
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

        $getVDPortgroupParams = @{
            Server = $this.Connection
            Name = $this.Name
            VDSwitch = $distributedSwitch
            ErrorAction = 'SilentlyContinue'
            Verbose = $false
        }
        return Get-VDPortgroup @getVDPortgroupParams
    }

    <#
    .DESCRIPTION

    Checks if the passed Distributed Port Group needs be modified based on the passed properties.
    #>
    [bool] ShouldUpdateDistributedPortGroup($distributedPortGroup) {
        $shouldUpdateDistributedPortGroup = @(
            $this.ShouldUpdateDscResourceSetting('NumPorts', $distributedPortGroup.NumPorts, $this.NumPorts),
            $this.ShouldUpdateDscResourceSetting('PortBinding', [string] $distributedPortGroup.PortBinding, $this.PortBinding.ToString()),
            $this.ShouldUpdateDscResourceSetting('Notes', [string] $distributedPortGroup.Notes, $this.Notes)
        )

        return ($shouldUpdateDistributedPortGroup -Contains $true)
    }

    <#
    .DESCRIPTION

    Checks if the VLAN ID of the specified distributed port group should be modified.
    #>
    [bool] ShouldUpdateVLanId($distributedPortGroup) {
        $currentVLanId = if ($null -ne $distributedPortGroup.VlanConfiguration) { $distributedPortGroup.VlanConfiguration.VlanId } else { 0 }
        return $this.ShouldUpdateDscResourceSetting('VLanId', $currentVLanId, $this.VLanId)
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
        $distributedPortGroupParams.Verbose = $false

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
        ReferencePortGroup and VLanId are parameters only for the New-VDPortgroup cmdlet
        and are not used for the Set-VDPortgroup cmdlet.
        #>
        if (![string]::IsNullOrEmpty($this.ReferenceVDPortGroupName)) { $distributedPortGroupParams.ReferencePortgroup = $this.ReferenceVDPortGroupName }
        if ($null -ne $this.VLanId) { $distributedPortGroupParams.VlanId = $this.VLanId }

        try {
            $this.WriteLogUtil('Verbose', $this.CreateVDPortGroupMessage, @($this.Name, $distributedSwitch.Name))
            New-VDPortgroup @distributedPortGroupParams
        }
        catch {
            throw ($this.CouldNotCreateVDPortGroupMessage -f $this.Name, $distributedSwitch.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Modifies the configuration of the specified Distributed Port Group with the passed properties.
    #>
    [void] UpdateDistributedPortGroup($distributedPortGroup) {
        $distributedPortGroupParams = $this.GetDistributedPortGroupParams()

        try {
            $this.WriteLogUtil('Verbose', $this.ModifyVDPortGroupMessage, @($distributedPortGroup.Name))
            $distributedPortGroup | Set-VDPortgroup @distributedPortGroupParams
        }
        catch {
            throw ($this.CouldNotModifyVDPortGroupMessage -f $distributedPortGroup.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Modifies the VLAN configuration of the specified Distributed Port Group.
    #>
    [void] UpdateDistributedPortGroupVlanConfiguration($distributedPortGroup) {
        $setVDVlanConfigurationParams = @{
            VDPortgroup = $distributedPortGroup
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        if ($this.VLanId -eq 0) {
            $setVDVlanConfigurationParams.DisableVlan = $true
        }
        else {
            $setVDVlanConfigurationParams.VlanId = $this.VLanId
        }

        try {
            $this.WriteLogUtil('Verbose', $this.ModifyVDPortGroupVlanConfigurationMessage, @($distributedPortGroup.Name, $this.VLanId))
            Set-VDVlanConfiguration @setVDVlanConfigurationParams
        }
        catch {
            throw ($this.CouldNotModifyVDPortGroupVlanConfigurationMessage -f $distributedPortGroup.Name, $this.VLanId, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Removes the specified Distributed Port Group from the vSphere Distributed Switch that it belongs to.
    #>
    [void] RemoveDistributedPortGroup($distributedPortGroup) {
        try {
            $this.WriteLogUtil('Verbose', $this.RemoveVDPortGroupMessage, @($distributedPortGroup.Name, $distributedPortGroup.VDSwitch.Name))
            $removeVDPortGroupParams = @{
                Server = $this.Connection
                VDPortGroup = $distributedPortGroup
                Confirm = $false
                ErrorAction = 'Stop'
                Verbose = $false
            }
            Remove-VDPortGroup @removeVDPortGroupParams
        }
        catch {
            throw ($this.CouldNotRemoveVDPortGroupMessage -f $distributedPortGroup.Name, $distributedPortGroup.VDSwitch.Name, $_.Exception.Message)
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
            $result.VLanId = [int] $distributedPortGroup.VlanConfiguration.VlanId
        }
        else {
            $result.Name = $this.Name
            $result.VdsName = $this.VdsName
            $result.Ensure = [Ensure]::Absent
            $result.Notes = $this.Notes
            $result.NumPorts = $this.NumPorts
            $result.PortBinding = $this.PortBinding
            $result.VLanId = [int] $this.VLanId
        }
    }
}
