<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

class VMHostVssPortGroupBaseDSC : VMHostEntityBaseDSC {
    <#
    .DESCRIPTION

    Name of the the Port Group.
    #>
    [DscProperty(Key)]
    [string] $Name

    <#
    .DESCRIPTION

    Value indicating if the Port Group should be Present or Absent.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    <#
    .DESCRIPTION

    The Network System of the specified VMHost.
    #>
    hidden [PSObject] $VMHostNetworkSystem

    <#
    .DESCRIPTION

    Retrieves the Virtual Port Group with the specified name from the server if it exists.
    The Virtual Port Group must be a Standard Virtual Port Group. If the Virtual Port Group does not exist and Ensure is set to 'Absent', $null is returned.
    Otherwise it throws an exception.
    #>
    [PSObject] GetVirtualPortGroup() {
        if ($this.Ensure -eq [Ensure]::Absent) {
            return $null
        }
        else {
            try {
                $virtualPortGroup = Get-VirtualPortGroup -Server $this.Connection -Name $this.Name -VMHost $this.VMHost -Standard -ErrorAction Stop
                return $virtualPortGroup
            }
            catch {
                throw "Could not retrieve Virtual Port Group $($this.Name) of VMHost $($this.VMHost.Name). For more information: $($_.Exception.Message)"
            }
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Network System of the specified VMHost.
    #>
    [void] GetVMHostNetworkSystem() {
        try {
            $this.VMHostNetworkSystem = Get-View -Server $this.Connection -Id $this.VMHost.ExtensionData.ConfigManager.NetworkSystem -ErrorAction Stop
        }
        catch {
            throw "Could not retrieve the Network System of VMHost $($this.VMHost.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the specified Policy Setting. If the Inherited Setting is passed and set to $true,
    the Policy Setting should not be populated because "Parameters of the form "XXX" and "InheritXXX" are mutually exclusive."
    If the Inherited Setting is set to $false, both parameters can be populated.
    #>
    [void] PopulatePolicySetting($policyParams, $policySettingName, $policySetting, $policySettingInheritedName, $policySettingInherited) {
        if ($null -ne $policySetting) {
            if ($null -eq $policySettingInherited -or !$policySettingInherited) {
                $policyParams.$policySettingName = $policySetting
            }
        }

        if ($null -ne $policySettingInherited) { $policyParams.$policySettingInheritedName = $policySettingInherited }
    }
}
