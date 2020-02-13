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
class VDSwitchVMHost : BaseDSC {
    <#
    .DESCRIPTION

    Specifies the name of the vSphere Distributed Switch to/from which you want to add/remove the specified VMHosts.
    #>
    [DscProperty(Key)]
    [string] $VdsName

    <#
    .DESCRIPTION

    Specifies the names of the VMHosts that you want to add/remove to/from the specified vSphere Distributed Switch.
    #>
    [DscProperty(Mandatory)]
    [string[]] $VMHostNames

    <#
    .DESCRIPTION

    Value indicating if the VMHosts should be Present/Absent to/from the specified vSphere Distributed Switch.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    [void] Set() {
        try {
            $this.ConnectVIServer()
            $this.EnsureConnectionIsvCenter()

            $distributedSwitch = $this.GetDistributedSwitch()
            $vmHosts = $this.GetVMHosts()
            $filteredVMHosts = $this.GetFilteredVMHosts($vmHosts, $distributedSwitch)

            if ($this.Ensure -eq [Ensure]::Present) {
                $this.AddVMHostsToDistributedSwitch($filteredVMHosts, $distributedSwitch)
            }
            else {
                $this.RemoveVMHostsFromDistributedSwitch($filteredVMHosts, $distributedSwitch)
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
            $vmHosts = $this.GetVMHosts()

            if ($null -eq $distributedSwitch) {
                # If the Distributed Switch is $null, it means that Ensure is 'Absent' and the Distributed Switch does not exist.
                return $true
            }

            return !$this.ShouldUpdateVMHostsInDistributedSwitch($vmHosts, $distributedSwitch)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VDSwitchVMHost] Get() {
        try {
            $result = [VDSwitchVMHost]::new()

            $this.ConnectVIServer()
            $this.EnsureConnectionIsvCenter()

            $distributedSwitch = $this.GetDistributedSwitch()
            $vmHosts = $this.GetVMHosts()

            $result.Server = $this.Connection.Name
            $result.VMHostNames = $vmHosts | Select-Object -ExpandProperty Name
            $result.Ensure = $this.Ensure

            if ($null -eq $distributedSwitch) {
                # If the Distributed Switch is $null, it means that Ensure is 'Absent' and the Distributed Switch does not exist.
                $result.VdsName = $this.Name
            }
            else {
                $result.VdsName = $distributedSwitch.Name
            }

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
        if ($this.Ensure -eq [Ensure]::Absent) {
            $distributedSwitch = Get-VDSwitch -Server $this.Connection -Name $this.VdsName -ErrorAction SilentlyContinue
            return $distributedSwitch
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

    <#
    .DESCRIPTION

    Retrieves the VMHosts with the specified names from the server if they exist.
    For every VMHost that does not exist, a warning message is shown to the user without throwing an exception.
    #>
    [array] GetVMHosts() {
        $vmHosts = @()

        foreach ($vmHostName in $this.VMHostNames) {
            $vmHost = Get-VMHost -Server $this.Connection -Name $vmHostName -ErrorAction SilentlyContinue
            if ($null -eq $vmHost) {
                Write-WarningLog -Message "The passed VMHost {0} was not found and it will be ignored." -Arguments @($vmHostName)
            }
            else {
                $vmHosts += $vmHost
            }
        }

        return $vmHosts
    }

    <#
    .DESCRIPTION

    Checks if VMHosts should be added/removed from the Distributed Switch depending on the value of the Ensure property.
    If Ensure is set to 'Present', checks if all passed VMHosts are part of the Distributed Switch.
    If Ensure is set to 'Absent', checks if all passed VMHosts are not part of the Distributed Switch.
    #>
    [bool] ShouldUpdateVMHostsInDistributedSwitch($vmHosts, $distributedSwitch) {
        if ($this.Ensure -eq [Ensure]::Present) {
            foreach ($vmHost in $vmHosts) {
                $addedVMHost = $vmHost.ExtensionData.Config.Network.ProxySwitch | Where-Object -FilterScript { $_.DvsName -eq $distributedSwitch.Name }
                if ($null -eq $addedVMHost) {
                    return $true
                }
            }
        }
        else {
            foreach ($vmHost in $vmHosts) {
                $removedVMHost = $vmHost.ExtensionData.Config.Network.ProxySwitch | Where-Object -FilterScript { $_.DvsName -eq $distributedSwitch.Name }
                if ($null -ne $removedVMHost) {
                    return $true
                }
            }
        }

        return $false
    }

    <#
    .DESCRIPTION

    Returns the filtered VMHosts based on the value of the Ensure property. If Ensure is set to 'Present', it returns only
    these VMHosts that are currently not part of the Distributed Switch. The other VMHosts in the array are ignored because they are already part
    of the Distributed Switch. If Ensure is set to 'Absent', it returns only these VMHosts that are currently part of the Distributed Switch. The other VMHosts
    in the array are ignored because they are not part of the Distributed Switch. In both cases a warning message is shown to the user when a specific VMHost is
    ignored.
    #>
    [array] GetFilteredVMHosts($vmHosts, $distributedSwitch) {
        $filteredVMHosts = @()

        if ($this.Ensure -eq [Ensure]::Present) {
            foreach ($vmHost in $vmHosts) {
                $addedVMHost = $vmHost.ExtensionData.Config.Network.ProxySwitch | Where-Object -FilterScript { $_.DvsName -eq $distributedSwitch.Name }
                if ($null -ne $addedVMHost) {
                    Write-WarningLog -Message "VMHost {0} is already added to Distributed Switch {1} and it will be ignored." -Arguments @($vmHost.Name, $distributedSwitch.Name)
                    continue
                }

                $filteredVMHosts += $vmHost
            }
        }
        else {
            foreach ($vmHost in $vmHosts) {
                $removedVMHost = $vmHost.ExtensionData.Config.Network.ProxySwitch | Where-Object -FilterScript { $_.DvsName -eq $distributedSwitch.Name }
                if ($null -eq $removedVMHost) {
                    Write-WarningLog -Message "VMHost {0} is not added to Distributed Switch {1} and it will be ignored." -Arguments @($vmHost.Name, $distributedSwitch.Name)
                    continue
                }

                $filteredVMHosts += $vmHost
            }
        }

        return $filteredVMHosts
    }

    <#
    .DESCRIPTION

    Adds the VMHosts to the specified Distributed Switch.
    #>
    [void] AddVMHostsToDistributedSwitch($filteredVMHosts, $distributedSwitch) {
        try {
            Add-VDSwitchVMHost -Server $this.Connection -VDSwitch $distributedSwitch -VMHost $filteredVMHosts -ErrorAction Stop
        }
        catch {
            throw "Could not add VMHosts $filteredVMHosts to Distributed Switch $($distributedSwitch.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Removes the VMHosts from the specified Distributed Switch.
    #>
    [void] RemoveVMHostsFromDistributedSwitch($filteredVMHosts, $distributedSwitch) {
        try {
            Remove-VDSwitchVMHost -Server $this.Connection -VDSwitch $distributedSwitch -VMHost $filteredVMHosts -ErrorAction Stop
        }
        catch {
            throw "Could not remove VMHosts $filteredVMHosts from Distributed Switch $($distributedSwitch.Name). For more information: $($_.Exception.Message)"
        }
    }
}
