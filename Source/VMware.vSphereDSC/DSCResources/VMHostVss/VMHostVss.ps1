<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

[DscResource()]
class VMHostVss : VMHostBaseDSC {
    <#
    .DESCRIPTION

    Value indicating if the VSS should be Present or Absent.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    <#
    .DESCRIPTION

    The name of the VSS.
    #>
    [DscProperty(Key)]
    [string] $VssName

    <#
    .DESCRIPTION

    The maximum transmission unit (MTU) associated with this virtual switch in bytes.
    #>
    [DscProperty()]
    [int] $Mtu

    <#
    .DESCRIPTION

    The number of ports that this virtual switch is configured to use.
    #>
    [DscProperty()]
    [int] $NumPorts

    <#
    .DESCRIPTION

    The virtual switch key.
    #>
    [DscProperty(NotConfigurable)]
    [string] $Key

    <#
    .DESCRIPTION

    The number of ports that are available on this virtual switch.
    #>
    [DscProperty(NotConfigurable)]
    [int] $NumPortsAvailable

    <#
    .DESCRIPTION

    The set of physical network adapters associated with this bridge.
    #>
    [DscProperty(NotConfigurable)]
    [string[]] $Pnic

    <#
    .DESCRIPTION

    The list of port groups configured for this virtual switch.
    #>
    [DscProperty(NotConfigurable)]
    [string[]] $PortGroup

    [void] Set() {
        Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()

        $this.UpdateVss($vmHost)
    }

    [bool] Test() {
        Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()
        $vss = $this.GetVss($vmHost)

        if ($this.Ensure -eq [Ensure]::Present) {
            return ($null -ne $vss -and $this.Equals($vss))
        }
        else {
            return ($null -eq $vss)
        }
    }

    [VMHostVss] Get() {
        Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

        $this.ConnectVIServer()
        $vmHost = $this.GetVMHost()

        $result = [VMHostVss]::new()
        $result.Server = $this.Server
        $result.Name = $vmHost.Name

        $this.PopulateResult($vmHost, $result)

        if ($null -ne $result.Key) {
            $result.Ensure = 'Present'
        }
        else {
            $result.Ensure = 'Absent'
        }

        return $result
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if the VMHostVss should be updated.
    #>
    [bool] Equals($vss) {
        Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

        $vssTest = @()
        $vssTest += ($vss.Name -eq $this.VssName)
        $vssTest += ($vss.MTU -eq $this.MTU)
        $vssTest += ($vss.NumPorts -eq $this.NumPorts)

        return ($vssTest -notcontains $false)
    }

    <#
    .DESCRIPTION

    Returns the desired virtual switch if it is present on the server otherwise returns $null.
    #>
    [PSObject] GetVss($vmHost) {
        Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

        $vmHostNetworkSystem = Get-View -Server $this.Connection -Id $vmHost.ExtensionData.ConfigManager.NetworkSystem

        return ($vmHostNetworkSystem.NetworkInfo.Vswitch | Where-Object { $_.Name -eq $this.VssName })
    }

    <#
    .DESCRIPTION

    Updates the configuration of the virtual switch.
    #>
    [void] UpdateVss($vmHost) {
        Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

        $vssConfigArgs = @{
            Name = $this.VssName
            Mtu = $this.Mtu
            NumPorts = $this.NumPorts
        }
        $vss = $this.GetVss($vmHost)

        if ($this.Ensure -eq 'Present') {
            if ($null -ne $vss) {
                if ($this.Equals($vss)) {
                    return
                }
                $vssConfigArgs.Add('Operation', 'edit')
            }
            else {
                $vssConfigArgs.Add('Operation', 'add')
            }
        }
        else {
            if ($null -eq $vss) {
                return
            }
            $vssConfigArgs.Add('Operation', 'remove')
        }

        $vssConfig = New-VssConfig @vssConfigArgs
        $vmHostNetworkSystem = Get-View -Server $this.Connection -Id $vmHost.ExtensionData.ConfigManager.NetworkSystem
        try {
            Update-Network -NetworkSystem $vmHostNetworkSystem -Type 'VSS' -VssConfig $vssConfig
        }
        catch {
            Write-Error "The virtual switch Config could not be updated: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the virtual switch.
    #>
    [void] PopulateResult($vmHost, $vmHostVSS) {
        Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

        $currentVss = $this.GetVss($vmHost)

        if ($null -ne $currentVss) {
            $vmHostVSS.Key = $currentVss.Key
            $vmHostVSS.Mtu = $currentVss.Mtu
            $vmHostVSS.VssName = $currentVss.Name
            $vmHostVSS.Numports = $currentVss.NumPorts
            $vmHostVSS.NumPortsAvailable = $currentVss.NumPortsAvailable
            $vmHostVSS.Pnic = $currentVss.Pnic
            $vmHostVSS.Portgroup = $currentVss.Portgroup
        }
    }
}
