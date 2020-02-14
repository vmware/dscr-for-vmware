<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

class VMHostNicBaseDSC : VMHostEntityBaseDSC {
    <#
    .DESCRIPTION

    Specifies the name of the Port Group to which the VMKernel Network Adapter should be connected. If a Distributed Switch is passed, an existing Port Group name should be specified.
    For Standard Virtual Switches, if the Port Group is non-existent, a new Port Group with the specified name will be created and the VMKernel Network Adapter will be connected to it.
    #>
    [DscProperty(Key)]
    [string] $PortGroupName

    <#
    .DESCRIPTION

    Value indicating if the VMKernel Network Adapter should be Present or Absent.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    <#
    .DESCRIPTION

    Indicates whether the VMKernel Network Adapter uses a Dhcp server.
    #>
    [DscProperty()]
    [nullable[bool]] $Dhcp

    <#
    .DESCRIPTION

    Specifies an IP address for the VMKernel Network Adapter. All IP addresses are specified using IPv4 dot notation. If IP is not specified, DHCP mode is enabled.
    #>
    [DscProperty()]
    [string] $IP

    <#
    .DESCRIPTION

    Specifies a Subnet Mask for the VMKernel Network Adapter.
    #>
    [DscProperty()]
    [string] $SubnetMask

    <#
    .DESCRIPTION

    Specifies a media access control (MAC) address for the VMKernel Network Adapter.
    #>
    [DscProperty()]
    [string] $Mac

    <#
    .DESCRIPTION

    Indicates that the IPv6 address is obtained through a router advertisement.
    #>
    [DscProperty()]
    [nullable[bool]] $AutomaticIPv6

    <#
    .DESCRIPTION

    Specifies multiple static addresses using the following format: <IPv6>/<subnet_prefix_length> or <IPv6>. If you skip <subnet_prefix_length>, the default value of 64 is used.
    #>
    [DscProperty()]
    [string[]] $IPv6

    <#
    .DESCRIPTION

    Indicates that the IPv6 address is obtained through DHCP.
    #>
    [DscProperty()]
    [nullable[bool]] $IPv6ThroughDhcp

    <#
    .DESCRIPTION

    Specifies the MTU size.
    #>
    [DscProperty()]
    [nullable[int]] $Mtu

    <#
    .DESCRIPTION

    Indicates that IPv6 configuration is enabled. Setting this parameter to $false disables all IPv6-related parameters.
    If the value is $true, you need to provide values for at least one of the IPv6 parameters.
    #>
    [DscProperty()]
    [nullable[bool]] $IPv6Enabled

    <#
    .DESCRIPTION

    Indicates that you want to enable the VMKernel Network Adapter for management traffic.
    #>
    [DscProperty()]
    [nullable[bool]] $ManagementTrafficEnabled

    <#
    .DESCRIPTION

    Indicates that the VMKernel Network Adapter is enabled for Fault Tolerance (FT) logging.
    #>
    [DscProperty()]
    [nullable[bool]] $FaultToleranceLoggingEnabled

    <#
    .DESCRIPTION

    Indicates that you want to use the VMKernel Network Adapter for VMotion.
    #>
    [DscProperty()]
    [nullable[bool]] $VMotionEnabled

    <#
    .DESCRIPTION

    Indicates that Virtual SAN traffic is enabled on this VMKernel Network Adapter.
    #>
    [DscProperty()]
    [nullable[bool]] $VsanTrafficEnabled

    <#
    .DESCRIPTION

    Retrieves the VMKernel Network Adapter connected to the specified Port Group and Virtual Switch and available on the specified VMHost from the server
    if it exists, otherwise returns $null.
    #>
    [PSObject] GetVMHostNetworkAdapter($virtualSwitch) {
        if ($null -eq $virtualSwitch) {
            <#
            If the Virtual Switch is $null, it means that Ensure was set to 'Absent' and
            the VMKernel Network Adapter does not exist for the specified Virtual Switch.
            #>
            return $null
        }

        return Get-VMHostNetworkAdapter -Server $this.Connection -PortGroup $this.PortGroupName -VirtualSwitch $virtualSwitch -VMHost $this.VMHost -VMKernel -ErrorAction SilentlyContinue
    }

    <#
    .DESCRIPTION

    Checks if the passed VMKernel Network Adapter IPv6 array needs to be updated.
    #>
    [bool] ShouldUpdateIPv6($ipv6) {
        $currentIPv6 = @()
        foreach ($ip in $ipv6) {
            <#
            The IPs on the server are of type 'IPv6Address' so they need to be converted to
            string before being passed to ShouldUpdateArraySetting method.
            #>
            $currentIPv6 += $ip.ToString()
        }

        <#
        The default IPv6 array contains one element, so when empty array is passed no update
        should be performed.
        #>
        if ($null -ne $this.IPv6 -and ($this.IPv6.Length -eq 0 -and $currentIPv6.Length -eq 1)) {
            return $false
        }

        return $this.ShouldUpdateArraySetting($currentIPv6, $this.IPv6)
    }

    <#
    .DESCRIPTION

    Checks if the passed VMKernel Network Adapter needs be updated based on the specified properties.
    #>
    [bool] ShouldUpdateVMHostNetworkAdapter($vmHostNetworkAdapter) {
        $shouldUpdateVMHostNetworkAdapter = @()

        $shouldUpdateVMHostNetworkAdapter += (![string]::IsNullOrEmpty($this.IP) -and $this.IP -ne $vmHostNetworkAdapter.IP)
        $shouldUpdateVMHostNetworkAdapter += (![string]::IsNullOrEmpty($this.SubnetMask) -and $this.SubnetMask -ne $vmHostNetworkAdapter.SubnetMask)
        $shouldUpdateVMHostNetworkAdapter += (![string]::IsNullOrEmpty($this.Mac) -and $this.Mac -ne $vmHostNetworkAdapter.Mac)

        $shouldUpdateVMHostNetworkAdapter += ($null -ne $this.Dhcp -and $this.Dhcp -ne $vmHostNetworkAdapter.DhcpEnabled)
        $shouldUpdateVMHostNetworkAdapter += ($null -ne $this.AutomaticIPv6 -and $this.AutomaticIPv6 -ne $vmHostNetworkAdapter.AutomaticIPv6)
        $shouldUpdateVMHostNetworkAdapter += $this.ShouldUpdateIPv6($vmHostNetworkAdapter.IPv6)
        $shouldUpdateVMHostNetworkAdapter += ($null -ne $this.IPv6ThroughDhcp -and $this.IPv6ThroughDhcp -ne $vmHostNetworkAdapter.IPv6ThroughDhcp)
        $shouldUpdateVMHostNetworkAdapter += ($null -ne $this.Mtu -and $this.Mtu -ne $vmHostNetworkAdapter.Mtu)
        $shouldUpdateVMHostNetworkAdapter += ($null -ne $this.IPv6Enabled -and $this.IPv6Enabled -ne $vmHostNetworkAdapter.IPv6Enabled)
        $shouldUpdateVMHostNetworkAdapter += ($null -ne $this.ManagementTrafficEnabled -and $this.ManagementTrafficEnabled -ne $vmHostNetworkAdapter.ManagementTrafficEnabled)
        $shouldUpdateVMHostNetworkAdapter += ($null -ne $this.FaultToleranceLoggingEnabled -and $this.FaultToleranceLoggingEnabled -ne $vmHostNetworkAdapter.FaultToleranceLoggingEnabled)
        $shouldUpdateVMHostNetworkAdapter += ($null -ne $this.VMotionEnabled -and $this.VMotionEnabled -ne $vmHostNetworkAdapter.VMotionEnabled)
        $shouldUpdateVMHostNetworkAdapter += ($null -ne $this.VsanTrafficEnabled -and $this.VsanTrafficEnabled -ne $vmHostNetworkAdapter.VsanTrafficEnabled)

        return ($shouldUpdateVMHostNetworkAdapter -Contains $true)
    }

    <#
    .DESCRIPTION

    Returns the populated VMKernel Network Adapter parameters.
    #>
    [hashtable] GetVMHostNetworkAdapterParams() {
        $vmHostNetworkAdapterParams = @{}

        $vmHostNetworkAdapterParams.Confirm = $false
        $vmHostNetworkAdapterParams.ErrorAction = 'Stop'

        if (![string]::IsNullOrEmpty($this.IP)) { $vmHostNetworkAdapterParams.IP = $this.IP }
        if (![string]::IsNullOrEmpty($this.SubnetMask)) { $vmHostNetworkAdapterParams.SubnetMask = $this.SubnetMask }
        if (![string]::IsNullOrEmpty($this.Mac)) { $vmHostNetworkAdapterParams.Mac = $this.Mac }

        if ($null -ne $this.AutomaticIPv6) { $vmHostNetworkAdapterParams.AutomaticIPv6 = $this.AutomaticIPv6 }
        if ($null -ne $this.IPv6) { $vmHostNetworkAdapterParams.IPv6 = $this.IPv6 }
        if ($null -ne $this.IPv6ThroughDhcp) { $vmHostNetworkAdapterParams.IPv6ThroughDhcp = $this.IPv6ThroughDhcp }
        if ($null -ne $this.Mtu) { $vmHostNetworkAdapterParams.Mtu = $this.Mtu }
        if ($null -ne $this.ManagementTrafficEnabled) { $vmHostNetworkAdapterParams.ManagementTrafficEnabled = $this.ManagementTrafficEnabled }
        if ($null -ne $this.FaultToleranceLoggingEnabled) { $vmHostNetworkAdapterParams.FaultToleranceLoggingEnabled = $this.FaultToleranceLoggingEnabled }
        if ($null -ne $this.VMotionEnabled) { $vmHostNetworkAdapterParams.VMotionEnabled = $this.VMotionEnabled }
        if ($null -ne $this.VsanTrafficEnabled) { $vmHostNetworkAdapterParams.VsanTrafficEnabled = $this.VsanTrafficEnabled }

        return $vmHostNetworkAdapterParams
    }

    <#
    .DESCRIPTION

    Creates a new VMKernel Network Adapter connected to the specified Virtual Switch and Port Group for the specified VMHost.
    If the Port Id is specified, the Port Group is ignored and only the Port Id is passed to the cmdlet.
    #>
    [PSObject] AddVMHostNetworkAdapter($virtualSwitch, $portId) {
        $vmHostNetworkAdapterParams = $this.GetVMHostNetworkAdapterParams()

        $vmHostNetworkAdapterParams.Server = $this.Connection
        $vmHostNetworkAdapterParams.VMHost = $this.VMHost
        $vmHostNetworkAdapterParams.VirtualSwitch = $virtualSwitch

        if ($null -ne $portId) {
            $vmHostNetworkAdapterParams.PortId = $portId
        }
        else {
            $vmHostNetworkAdapterParams.PortGroup = $this.PortGroupName
        }

        try {
            return New-VMHostNetworkAdapter @vmHostNetworkAdapterParams
        }
        catch {
            throw "Cannot create VMKernel Network Adapter connected to Virtual Switch $($virtualSwitch.Name) and Port Group $($this.PortGroupName). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Updates the VMKernel Network Adapter with the specified properties.
    #>
    [void] UpdateVMHostNetworkAdapter($vmHostNetworkAdapter) {
        $vmHostNetworkAdapterParams = $this.GetVMHostNetworkAdapterParams()

        <#
        IPv6 should only be passed to the cmdlet if an update needs to be performed.
        Otherwise the following error occurs when passing the same array: 'Address already exists in the config.'
        #>
        if (!$this.ShouldUpdateIPv6($vmHostNetworkAdapter.IPv6)) {
            $vmHostNetworkAdapterParams.Remove('IPv6')
        }

        <#
        Both Dhcp and IPv6Enabled are applicable only for the Update operation, so they are not
        populated in the GetVMHostNetworkAdapterParams() which is used for Create and Update operations.
        #>
        if ($null -ne $this.Dhcp) {
            $vmHostNetworkAdapterParams.Dhcp = $this.Dhcp

            <#
            IP and SubnetMask parameters are mutually exclusive with Dhcp so they should be removed
            from the parameters hashtable before calling Set-VMHostNetworkAdapter cmdlet.
            #>
            $vmHostNetworkAdapterParams.Remove('IP')
            $vmHostNetworkAdapterParams.Remove('SubnetMask')
        }

        if ($null -ne $this.IPv6Enabled) {
            $vmHostNetworkAdapterParams.IPv6Enabled = $this.IPv6Enabled

            if (!$this.IPv6Enabled) {
                <#
                If the value of IPv6Enabled is $false, other IPv6 settings cannot be specified.
                #>
                $vmHostNetworkAdapterParams.Remove('AutomaticIPv6')
                $vmHostNetworkAdapterParams.Remove('IPv6ThroughDhcp')
                $vmHostNetworkAdapterParams.Remove('IPv6')
            }
        }

        try {
            $vmHostNetworkAdapter | Set-VMHostNetworkAdapter @vmHostNetworkAdapterParams
        }
        catch {
            throw "Cannot update VMKernel Network Adapter $($vmHostNetworkAdapter.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Removes the VMKernel Network Adapter connected to the specified Virtual Switch and Port Group for the specified VMHost.
    #>
    [void] RemoveVMHostNetworkAdapter($vmHostNetworkAdapter) {
        try {
            Remove-VMHostNetworkAdapter -Nic $vmHostNetworkAdapter -Confirm:$false -ErrorAction Stop
        }
        catch {
            throw "Cannot remove VMKernel Network Adapter $($vmHostNetworkAdapter.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the VMKernel Network Adapter from the server.
    #>
    [void] PopulateResult($vmHostNetworkAdapter, $result) {
        $result.Server = $this.Connection.Name
        $result.VMHostName = $this.VMHost.Name

        if ($null -ne $vmHostNetworkAdapter) {
            $result.PortGroupName = $vmHostNetworkAdapter.PortGroupName
            $result.Ensure = [Ensure]::Present
            $result.IP = $vmHostNetworkAdapter.IP
            $result.SubnetMask = $vmHostNetworkAdapter.SubnetMask
            $result.Mac = $vmHostNetworkAdapter.Mac
            $result.AutomaticIPv6 = $vmHostNetworkAdapter.AutomaticIPv6
            $result.IPv6 = $vmHostNetworkAdapter.IPv6
            $result.IPv6ThroughDhcp = $vmHostNetworkAdapter.IPv6ThroughDhcp
            $result.Mtu = $vmHostNetworkAdapter.Mtu
            $result.Dhcp = $vmHostNetworkAdapter.DhcpEnabled
            $result.IPv6Enabled = $vmHostNetworkAdapter.IPv6Enabled
            $result.ManagementTrafficEnabled = $vmHostNetworkAdapter.ManagementTrafficEnabled
            $result.FaultToleranceLoggingEnabled = $vmHostNetworkAdapter.FaultToleranceLoggingEnabled
            $result.VMotionEnabled = $vmHostNetworkAdapter.VMotionEnabled
            $result.VsanTrafficEnabled = $vmHostNetworkAdapter.VsanTrafficEnabled
        }
        else {
            $result.PortGroupName = $this.PortGroupName
            $result.Ensure = [Ensure]::Absent
            $result.IP = $this.IP
            $result.SubnetMask = $this.SubnetMask
            $result.Mac = $this.Mac
            $result.AutomaticIPv6 = $this.AutomaticIPv6
            $result.IPv6 = $this.IPv6
            $result.IPv6ThroughDhcp = $this.IPv6ThroughDhcp
            $result.Mtu = $this.Mtu
            $result.Dhcp = $this.Dhcp
            $result.IPv6Enabled = $this.IPv6Enabled
            $result.ManagementTrafficEnabled = $this.ManagementTrafficEnabled
            $result.FaultToleranceLoggingEnabled = $this.FaultToleranceLoggingEnabled
            $result.VMotionEnabled = $this.VMotionEnabled
            $result.VsanTrafficEnabled = $this.VsanTrafficEnabled
        }
    }
}
