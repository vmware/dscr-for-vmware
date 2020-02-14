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
class VMHostVssPortGroupSecurity : VMHostVssPortGroupBaseDSC {
    <#
    .DESCRIPTION

    Specifies whether promiscuous mode is enabled for the corresponding Virtual Port Group.
    #>
    [DscProperty()]
    [nullable[bool]] $AllowPromiscuous

    <#
    .DESCRIPTION

    Specifies whether the AllowPromiscuous setting is inherited from the parent Standard Virtual Switch.
    #>
    [DscProperty()]
    [nullable[bool]] $AllowPromiscuousInherited

    <#
    .DESCRIPTION

    Specifies whether forged transmits are enabled for the corresponding Virtual Port Group.
    #>
    [DscProperty()]
    [nullable[bool]] $ForgedTransmits

    <#
    .DESCRIPTION

    Specifies whether the ForgedTransmits setting is inherited from the parent Standard Virtual Switch.
    #>
    [DscProperty()]
    [nullable[bool]] $ForgedTransmitsInherited

    <#
    .DESCRIPTION

    Specifies whether MAC address changes are enabled for the corresponding Virtual Port Group.
    #>
    [DscProperty()]
    [nullable[bool]] $MacChanges

    <#
    .DESCRIPTION

    Specifies whether the MacChanges setting is inherited from the parent Standard Virtual Switch.
    #>
    [DscProperty()]
    [nullable[bool]] $MacChangesInherited

    hidden [string] $AllowPromiscuousSettingName = 'AllowPromiscuous'
    hidden [string] $AllowPromiscuousInheritedSettingName = 'AllowPromiscuousInherited'
    hidden [string] $ForgedTransmitsSettingName = 'ForgedTransmits'
    hidden [string] $ForgedTransmitsInheritedSettingName = 'ForgedTransmitsInherited'
    hidden [string] $MacChangesSettingName = 'MacChanges'
    hidden [string] $MacChangesInheritedSettingName = 'MacChangesInherited'

    [void] Set() {
        try {
            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $virtualPortGroup = $this.GetVirtualPortGroup()
            $virtualPortGroupSecurityPolicy = $this.GetVirtualPortGroupSecurityPolicy($virtualPortGroup)

            $this.UpdateVirtualPortGroupSecurityPolicy($virtualPortGroupSecurityPolicy)
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

            $virtualPortGroupSecurityPolicy = $this.GetVirtualPortGroupSecurityPolicy($virtualPortGroup)

            return !$this.ShouldUpdateVirtualPortGroupSecurityPolicy($virtualPortGroupSecurityPolicy)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostVssPortGroupSecurity] Get() {
        try {
            $result = [VMHostVssPortGroupSecurity]::new()
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

            $virtualPortGroupSecurityPolicy = $this.GetVirtualPortGroupSecurityPolicy($virtualPortGroup)
            $result.Name = $virtualPortGroup.Name

            $this.PopulateResult($virtualPortGroupSecurityPolicy, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Virtual Port Group Security Policy from the server.
    #>
    [PSObject] GetVirtualPortGroupSecurityPolicy($virtualPortGroup) {
        try {
            $virtualPortGroupSecurityPolicy = Get-SecurityPolicy -Server $this.Connection -VirtualPortGroup $virtualPortGroup -ErrorAction Stop
            return $virtualPortGroupSecurityPolicy
        }
        catch {
            throw "Could not retrieve Virtual Port Group $($this.PortGroup) Security Policy. For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Checks if the Security Policy of the specified Virtual Port Group should be updated.
    #>
    [bool] ShouldUpdateVirtualPortGroupSecurityPolicy($virtualPortGroupSecurityPolicy) {
        $shouldUpdateVirtualPortGroupSecurityPolicy = @()

        $shouldUpdateVirtualPortGroupSecurityPolicy += ($null -ne $this.AllowPromiscuous -and $this.AllowPromiscuous -ne $virtualPortGroupSecurityPolicy.AllowPromiscuous)
        $shouldUpdateVirtualPortGroupSecurityPolicy += ($null -ne $this.AllowPromiscuousInherited -and $this.AllowPromiscuousInherited -ne $virtualPortGroupSecurityPolicy.AllowPromiscuousInherited)
        $shouldUpdateVirtualPortGroupSecurityPolicy += ($null -ne $this.ForgedTransmits -and $this.ForgedTransmits -ne $virtualPortGroupSecurityPolicy.ForgedTransmits)
        $shouldUpdateVirtualPortGroupSecurityPolicy += ($null -ne $this.ForgedTransmitsInherited -and $this.ForgedTransmitsInherited -ne $virtualPortGroupSecurityPolicy.ForgedTransmitsInherited)
        $shouldUpdateVirtualPortGroupSecurityPolicy += ($null -ne $this.MacChanges -and $this.MacChanges -ne $virtualPortGroupSecurityPolicy.MacChanges)
        $shouldUpdateVirtualPortGroupSecurityPolicy += ($null -ne $this.MacChangesInherited -and $this.MacChangesInherited -ne $virtualPortGroupSecurityPolicy.MacChangesInherited)

        return ($shouldUpdateVirtualPortGroupSecurityPolicy -Contains $true)
    }

    <#
    .DESCRIPTION

    Performs an update on the Security Policy of the specified Virtual Port Group.
    #>
    [void] UpdateVirtualPortGroupSecurityPolicy($virtualPortGroupSecurityPolicy) {
        $securityPolicyParams = @{}
        $securityPolicyParams.VirtualPortGroupPolicy = $virtualPortGroupSecurityPolicy

        $this.PopulatePolicySetting($securityPolicyParams, $this.AllowPromiscuousSettingName, $this.AllowPromiscuous, $this.AllowPromiscuousInheritedSettingName, $this.AllowPromiscuousInherited)
        $this.PopulatePolicySetting($securityPolicyParams, $this.ForgedTransmitsSettingName, $this.ForgedTransmits, $this.ForgedTransmitsInheritedSettingName, $this.ForgedTransmitsInherited)
        $this.PopulatePolicySetting($securityPolicyParams, $this.MacChangesSettingName, $this.MacChanges, $this.MacChangesInheritedSettingName, $this.MacChangesInherited)

        try {
            Set-SecurityPolicy @securityPolicyParams
        }
        catch {
            throw "Cannot update Security Policy of Virtual Port Group $($this.PortGroup). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the Security Policy of the specified Virtual Port Group from the server.
    #>
    [void] PopulateResult($virtualPortGroupSecurityPolicy, $result) {
        $result.AllowPromiscuous = $virtualPortGroupSecurityPolicy.AllowPromiscuous
        $result.AllowPromiscuousInherited = $virtualPortGroupSecurityPolicy.AllowPromiscuousInherited
        $result.ForgedTransmits = $virtualPortGroupSecurityPolicy.ForgedTransmits
        $result.ForgedTransmitsInherited = $virtualPortGroupSecurityPolicy.ForgedTransmitsInherited
        $result.MacChanges = $virtualPortGroupSecurityPolicy.MacChanges
        $result.MacChangesInherited = $virtualPortGroupSecurityPolicy.MacChangesInherited
    }
}
