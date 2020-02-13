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
class VMHostVssPortGroup : VMHostVssPortGroupBaseDSC {
    <#
    .DESCRIPTION

    Specifies the Name of the Virtual Switch associated with the Port Group.
    The Virtual Switch must be a Standard Virtual Switch.
    #>
    [DscProperty(Mandatory)]
    [string] $VssName

    <#
    .DESCRIPTION

    Specifies the VLAN ID for ports using this Port Group. The following values are valid:
    0 - specifies that you do not want to associate the Port Group with a VLAN.
    1 to 4094 - specifies a VLAN ID for the Port Group.
    4095 - specifies that the Port Group should use trunk mode, which allows the guest operating system to manage its own VLAN tags.
    #>
    [DscProperty()]
    [nullable[int]] $VLanId

    hidden [int] $VLanIdMaxValue = 4095

    [void] Set() {
        try {
            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $virtualSwitch = $this.GetVirtualSwitch()
            $portGroup = $this.GetVirtualPortGroup($virtualSwitch)

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $portGroup) {
                    $this.AddVirtualPortGroup($virtualSwitch)
                }
                else {
                    $this.UpdateVirtualPortGroup($portGroup)
                }
            }
            else {
                if ($null -ne $portGroup) {
                    $this.RemoveVirtualPortGroup($portGroup)
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
            $this.RetrieveVMHost()

            $virtualSwitch = $this.GetVirtualSwitch()
            $portGroup = $this.GetVirtualPortGroup($virtualSwitch)

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $portGroup) {
                    return $false
                }

                return !$this.ShouldUpdateVirtualPortGroup($portGroup)
            }
            else {
                return ($null -eq $portGroup)
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostVssPortGroup] Get() {
        try {
            $result = [VMHostVssPortGroup]::new()
            $result.Server = $this.Server

            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $virtualSwitch = $this.GetVirtualSwitch()
            $portGroup = $this.GetVirtualPortGroup($virtualSwitch)

            $result.VMHostName = $this.VMHost.Name
            $this.PopulateResult($portGroup, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Virtual Switch with the specified name from the server if it exists.
    The Virtual Switch must be a Standard Virtual Switch. If the Virtual Switch does not exist and Ensure is set to 'Absent', $null is returned.
    Otherwise it throws an exception.
    #>
    [PSObject] GetVirtualSwitch() {
        if ($this.Ensure -eq [Ensure]::Absent) {
            return Get-VirtualSwitch -Server $this.Connection -Name $this.VssName -VMHost $this.VMHost -Standard -ErrorAction SilentlyContinue
        }
        else {
            try {
                $virtualSwitch = Get-VirtualSwitch -Server $this.Connection -Name $this.VssName -VMHost $this.VMHost -Standard -ErrorAction Stop
                return $virtualSwitch
            }
            catch {
                throw "Could not retrieve Virtual Switch $($this.VssName) of VMHost $($this.VMHost.Name). For more information: $($_.Exception.Message)"
            }
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Virtual Port Group with the specified Name, available on the specified Virtual Switch and VMHost from the server if it exists,
    otherwise returns $null.
    #>
    [PSObject] GetVirtualPortGroup($virtualSwitch) {
        if ($null -eq $virtualSwitch) {
            <#
            If the Virtual Switch is $null, it means that Ensure was set to 'Absent' and
            the Port Group does not exist for the specified Virtual Switch.
            #>
            return $null
        }

        return Get-VirtualPortGroup -Server $this.Connection -Name $this.Name -VirtualSwitch $virtualSwitch -VMHost $this.VMHost -ErrorAction SilentlyContinue
    }

    <#
    .DESCRIPTION

    Ensures that the passed VLanId value is in the range [0, 4095].
    #>
    [void] EnsureVLanIdValueIsValid() {
        if ($this.VLanId -lt 0 -or $this.VLanId -gt $this.VLanIdMaxValue) {
            throw "The passed VLanId value $($this.VLanId) is not valid. The valid values are in the following range: [0, $($this.VLanIdMaxValue)]."
        }
    }

    <#
    .DESCRIPTION

    Checks if the VLanId is specified and needs to be updated.
    #>
    [bool] ShouldUpdateVirtualPortGroup($portGroup) {
        if ($null -eq $this.VLanId) {
            return $false
        }

        return ($this.VLanId -ne $portGroup.VLanId)
    }

    <#
    .DESCRIPTION

    Returns the populated Port Group parameters.
    #>
    [hashtable] GetPortGroupParams() {
        $portGroupParams = @{}

        $portGroupParams.Confirm = $false
        $portGroupParams.ErrorAction = 'Stop'

        if ($null -ne $this.VLanId) {
            $this.EnsureVLanIdValueIsValid()
            $portGroupParams.VLanId = $this.VLanId
        }

        return $portGroupParams
    }

    <#
    .DESCRIPTION

    Creates a new Port Group available on the specified Virtual Switch.
    #>
    [void] AddVirtualPortGroup($virtualSwitch) {
        $portGroupParams = $this.GetPortGroupParams()

        $portGroupParams.Server = $this.Connection
        $portGroupParams.Name = $this.Name
        $portGroupParams.VirtualSwitch = $virtualSwitch

        try {
            New-VirtualPortGroup @portGroupParams
        }
        catch {
            throw "Cannot create Virtual Port Group $($this.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Updates the Port Group by changing its VLanId value.
    #>
    [void] UpdateVirtualPortGroup($portGroup) {
        $portGroupParams = $this.GetPortGroupParams()

        try {
            $portGroup | Set-VirtualPortGroup @portGroupParams
        }
        catch {
            throw "Cannot update Virtual Port Group $($this.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Removes the specified Port Group available on the Virtual Switch. All VMs connected to the Port Group must be PoweredOff to successfully remove the Port Group.
    If one or more of the VMs are PoweredOn, the removal would not be successful because the Port Group is used by the VMs.
    #>
    [void] RemoveVirtualPortGroup($portGroup) {
        try {
            $portGroup | Remove-VirtualPortGroup -Confirm:$false -ErrorAction Stop
        }
        catch {
            throw "Cannot remove Virtual Port Group $($this.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the Port Group from the server.
    #>
    [void] PopulateResult($portGroup, $result) {
        if ($null -ne $portGroup) {
            $result.Name = $portGroup.Name
            $result.VssName = $portGroup.VirtualSwitchName
            $result.Ensure = [Ensure]::Present
            $result.VLanId = $portGroup.VLanId
        }
        else {
            $result.Name = $this.Name
            $result.VssName = $this.VssName
            $result.Ensure = [Ensure]::Absent
            $result.VLanId = $this.VLanId
        }
    }
}
