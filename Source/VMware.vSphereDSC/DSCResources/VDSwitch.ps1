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
class VDSwitch : DatacenterInventoryBaseDSC {
    DistributedSwitch() {
        $this.InventoryItemFolderType = [FolderType]::Network
    }

    <#
    .DESCRIPTION

    Specifies the contact details of the vSphere Distributed Switch administrator.
    #>
    [DscProperty()]
    [string] $ContactDetails

    <#
    .DESCRIPTION

    Specifies the name of the vSphere Distributed Switch administrator.
    #>
    [DscProperty()]
    [string] $ContactName

    <#
    .DESCRIPTION

    Specifies the discovery protocol type of the vSphere Distributed Switch that you want to create.
    The valid values are CDP, LLDP and Unset. If you do not set a value for this parameter, the default server setting is used.
    #>
    [DscProperty()]
    [LinkDiscoveryProtocolProtocol] $LinkDiscoveryProtocol = [LinkDiscoveryProtocolProtocol]::Unset

    <#
    .DESCRIPTION

    Specifies the link discovery protocol operation for the vSphere Distributed Switch that you want to create.
    The valid values are Advertise, Both, Listen, None and Unset. If you do not set a value for this parameter, the default server setting is used.
    #>
    [DscProperty()]
    [LinkDiscoveryProtocolOperation] $LinkDiscoveryProtocolOperation = [LinkDiscoveryProtocolOperation]::Unset

    <#
    .DESCRIPTION

    Specifies the maximum number of ports allowed on the vSphere Distributed Switch that you want to create.
    #>
    [DscProperty()]
    [nullable[int]] $MaxPorts

    <#
    .DESCRIPTION

    Specifies the maximum MTU size for the vSphere Distributed Switch that you want to create. Valid values are positive integers only.
    #>
    [DscProperty()]
    [nullable[int]] $Mtu

    <#
    .DESCRIPTION

    Specifies a description for the vSphere Distributed Switch that you want to create.
    #>
    [DscProperty()]
    [string] $Notes

    <#
    .DESCRIPTION

    Specifies the number of uplink ports on the vSphere Distributed Switch that you want to create.
    #>
    [DscProperty()]
    [nullable[int]] $NumUplinkPorts

    <#
    .DESCRIPTION

    Specifies the Name for the reference vSphere Distributed Switch.
    The properties of the new vSphere Distributed Switch will be cloned from the reference vSphere Distributed Switch.
    #>
    [DscProperty()]
    [string] $ReferenceVDSwitchName

    <#
    .DESCRIPTION

    Specifies the version of the vSphere Distributed Switch that you want to create.
    You cannot specify a version that is incompatible with the version of the vCenter Server system you are connected to.
    #>
    [DscProperty()]
    [string] $Version

    <#
    .DESCRIPTION

    Indicates whether the new vSphere Distributed Switch will be created without importing the port groups from the specified reference vSphere Distributed Switch.
    #>
    [DscProperty()]
    [nullable[bool]] $WithoutPortGroups

    [void] Set() {
        try {
            $this.ConnectVIServer()
            $this.EnsureConnectionIsvCenter()

            $datacenter = $this.GetDatacenter()
            $datacenterFolderName = "$($this.InventoryItemFolderType)Folder"
            $distributedSwitchLocation = $this.GetInventoryItemLocationInDatacenter($datacenter, $datacenterFolderName)
            $distributedSwitch = $this.GetDistributedSwitch($distributedSwitchLocation)

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $distributedSwitch) {
                    $this.AddDistributedSwitch($distributedSwitchLocation)
                }
                else {
                    $this.UpdateDistributedSwitch($distributedSwitch)
                }
            }
            else {
                if ($null -ne $distributedSwitch) {
                    $this.RemoveDistributedSwitch($distributedSwitch)
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

            $datacenter = $this.GetDatacenter()
            $datacenterFolderName = "$($this.InventoryItemFolderType)Folder"
            $distributedSwitchLocation = $this.GetInventoryItemLocationInDatacenter($datacenter, $datacenterFolderName)
            $distributedSwitch = $this.GetDistributedSwitch($distributedSwitchLocation)

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $distributedSwitch) {
                    return $false
                }

                return !$this.ShouldUpdateDistributedSwitch($distributedSwitch)
            }
            else {
                return ($null -eq $distributedSwitch)
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VDSwitch] Get() {
        try {
            $result = [VDSwitch]::new()
            $result.Server = $this.Server
            $result.Location = $this.Location
            $result.DatacenterName = $this.DatacenterName
            $result.DatacenterLocation = $this.DatacenterLocation
            $result.ReferenceVDSwitchName = $this.ReferenceVDSwitchName
            $result.WithoutPortGroups = $this.WithoutPortGroups

            $this.ConnectVIServer()
            $this.EnsureConnectionIsvCenter()

            $datacenter = $this.GetDatacenter()
            $datacenterFolderName = "$($this.InventoryItemFolderType)Folder"
            $distributedSwitchLocation = $this.GetInventoryItemLocationInDatacenter($datacenter, $datacenterFolderName)
            $distributedSwitch = $this.GetDistributedSwitch($distributedSwitchLocation)

            $this.PopulateResult($distributedSwitch, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Distributed Switch from the specified Location in the Datacenter if it exists, otherwise returns $null.
    #>
    [PSObject] GetDistributedSwitch($distributedSwitchLocation) {
        <#
        The Verbose logic here is needed to suppress the Exporting and Importing of the
        cmdlets from the VMware.VimAutomation.Vds Module.
        #>
        $savedVerbosePreference = $global:VerbosePreference
        $global:VerbosePreference = 'SilentlyContinue'

        $distributedSwitch = Get-VDSwitch -Server $this.Connection -Name $this.Name -Location $distributedSwitchLocation -ErrorAction SilentlyContinue

        $global:VerbosePreference = $savedVerbosePreference

        return $distributedSwitch
    }

    <#
    .DESCRIPTION

    Checks if the passed Distributed Switch needs be updated based on the specified properties.
    #>
    [bool] ShouldUpdateDistributedSwitch($distributedSwitch) {
        $shouldUpdateDistributedSwitch = @()

        <#
        The VDSwitch object does not contain information about ReferenceVDSwitchName and WithoutPortGroups so those properties are not
        part of the Desired State of the Resource.
        #>
        $shouldUpdateDistributedSwitch += (![string]::IsNullOrEmpty($this.ContactDetails) -and $this.ContactDetails -ne $distributedSwitch.ContactDetails)
        $shouldUpdateDistributedSwitch += (![string]::IsNullOrEmpty($this.ContactName) -and $this.ContactName -ne $distributedSwitch.ContactName)
        $shouldUpdateDistributedSwitch += (![string]::IsNullOrEmpty($this.Notes) -and $this.Notes -ne $distributedSwitch.Notes)
        $shouldUpdateDistributedSwitch += (![string]::IsNullOrEmpty($this.Version) -and $this.Version -ne $distributedSwitch.Version)

        $shouldUpdateDistributedSwitch += ($null -ne $this.MaxPorts -and $this.MaxPorts -ne $distributedSwitch.MaxPorts)
        $shouldUpdateDistributedSwitch += ($null -ne $this.Mtu -and $this.Mtu -ne $distributedSwitch.Mtu)
        $shouldUpdateDistributedSwitch += ($null -ne $this.NumUplinkPorts -and $this.NumUplinkPorts -ne $distributedSwitch.NumUplinkPorts)

        if ($this.LinkDiscoveryProtocol -ne [LinkDiscoveryProtocolProtocol]::Unset) {
            $shouldUpdateDistributedSwitch += ($this.LinkDiscoveryProtocol.ToString() -ne $distributedSwitch.LinkDiscoveryProtocol.ToString())
        }

        if ($this.LinkDiscoveryProtocolOperation -ne [LinkDiscoveryProtocolOperation]::Unset) {
            $shouldUpdateDistributedSwitch += ($this.LinkDiscoveryProtocolOperation.ToString() -ne $distributedSwitch.LinkDiscoveryProtocolOperation.ToString())
        }

        return ($shouldUpdateDistributedSwitch -Contains $true)
    }

    <#
    .DESCRIPTION

    Returns the populated Distributed Switch parameters.
    #>
    [hashtable] GetDistributedSwitchParams() {
        $distributedSwitchParams = @{}

        $distributedSwitchParams.Server = $this.Connection
        $distributedSwitchParams.Confirm = $false
        $distributedSwitchParams.ErrorAction = 'Stop'

        if (![string]::IsNullOrEmpty($this.ContactDetails)) { $distributedSwitchParams.ContactDetails = $this.ContactDetails }
        if (![string]::IsNullOrEmpty($this.ContactName)) { $distributedSwitchParams.ContactName = $this.ContactName }
        if (![string]::IsNullOrEmpty($this.Notes)) { $distributedSwitchParams.Notes = $this.Notes }
        if (![string]::IsNullOrEmpty($this.Version)) { $distributedSwitchParams.Version = $this.Version }

        if ($null -ne $this.MaxPorts) { $distributedSwitchParams.MaxPorts = $this.MaxPorts }
        if ($null -ne $this.Mtu) { $distributedSwitchParams.Mtu = $this.Mtu }
        if ($null -ne $this.NumUplinkPorts) { $distributedSwitchParams.NumUplinkPorts = $this.NumUplinkPorts }

        if ($this.LinkDiscoveryProtocol -ne [LinkDiscoveryProtocolProtocol]::Unset) {
            $distributedSwitchParams.LinkDiscoveryProtocol = $this.LinkDiscoveryProtocol.ToString()
        }

        if ($this.LinkDiscoveryProtocolOperation -ne [LinkDiscoveryProtocolOperation]::Unset) {
            $distributedSwitchParams.LinkDiscoveryProtocolOperation = $this.LinkDiscoveryProtocolOperation.ToString()
        }

        return $distributedSwitchParams
    }

    <#
    .DESCRIPTION

    Creates a new Distributed Switch with the specified properties at the specified location.
    #>
    [void] AddDistributedSwitch($distributedSwitchLocation) {
        $distributedSwitchParams = $this.GetDistributedSwitchParams()
        $distributedSwitchParams.Name = $this.Name
        $distributedSwitchParams.Location = $distributedSwitchLocation

        <#
        ReferenceVDSwitch and WithoutPortGroups are parameters only for the New-VDSwitch cmdlet
        and are not used for the Set-VDSwitch cmdlet.
        #>
        if (![string]::IsNullOrEmpty($this.ReferenceVDSwitchName)) { $distributedSwitchParams.ReferenceVDSwitch = $this.ReferenceVDSwitchName }
        if ($null -ne $this.WithoutPortGroups) { $distributedSwitchParams.WithoutPortGroups = $this.WithoutPortGroups }

        try {
            New-VDSwitch @distributedSwitchParams
        }
        catch {
            throw "Cannot create Distributed Switch $($this.Name) at Location $($distributedSwitchLocation.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Updates the Distributed Switch with the specified properties.
    #>
    [void] UpdateDistributedSwitch($distributedSwitch) {
        $distributedSwitchParams = $this.GetDistributedSwitchParams()

        try {
            $distributedSwitch | Set-VDSwitch @distributedSwitchParams
        }
        catch {
            throw "Cannot update Distributed Switch $($this.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Removes the Distributed Switch from the specified location.
    #>
    [void] RemoveDistributedSwitch($distributedSwitch) {
        try {
            $distributedSwitch | Remove-VDSwitch -Server $this.Connection -Confirm:$false -ErrorAction Stop
        }
        catch {
            throw "Cannot remove Distributed Switch $($this.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the Distributed Switch from the server.
    #>
    [void] PopulateResult($distributedSwitch, $result) {
        if ($null -ne $distributedSwitch) {
            $result.Name = $distributedSwitch.Name
            $result.Ensure = [Ensure]::Present
            $result.ContactDetails = $distributedSwitch.ContactDetails
            $result.ContactName = $distributedSwitch.ContactName
            $result.LinkDiscoveryProtocol = $distributedSwitch.LinkDiscoveryProtocol.ToString()
            $result.LinkDiscoveryProtocolOperation = $distributedSwitch.LinkDiscoveryProtocolOperation.ToString()
            $result.MaxPorts = $distributedSwitch.MaxPorts
            $result.Mtu = $distributedSwitch.Mtu
            $result.Notes = $distributedSwitch.Notes
            $result.NumUplinkPorts = $distributedSwitch.NumUplinkPorts
            $result.Version = $distributedSwitch.Version
        }
        else {
            $result.Name = $this.Name
            $result.Ensure = [Ensure]::Absent
            $result.ContactDetails = $this.ContactDetails
            $result.ContactName = $this.ContactName
            $result.LinkDiscoveryProtocol = $this.LinkDiscoveryProtocol
            $result.LinkDiscoveryProtocolOperation = $this.LinkDiscoveryProtocolOperation
            $result.MaxPorts = $this.MaxPorts
            $result.Mtu = $this.Mtu
            $result.Notes = $this.Notes
            $result.NumUplinkPorts = $this.NumUplinkPorts
            $result.Version = $this.Version
        }
    }
}
