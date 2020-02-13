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
class VMHostIPRoute : VMHostBaseDSC {
    <#
    .DESCRIPTION

    Specifies the gateway IPv4/IPv6 address of the route.
    #>
    [DscProperty(Key)]
    [string] $Gateway

    <#
    .DESCRIPTION

    Specifies the destination IPv4/IPv6 address of the route.
    #>
    [DscProperty(Key)]
    [string] $Destination

    <#
    .DESCRIPTION

    Specifies the prefix length of the destination IP address. For IPv4, the valid values are from 0 to 32, and for IPv6 - from 0 to 128.
    #>
    [DscProperty(Key)]
    [int] $PrefixLength

    <#
    .DESCRIPTION

    Specifies whether the IPv4/IPv6 route should be present or absent.
    #>
    [DscProperty(Mandatory = $true)]
    [Ensure] $Ensure

    hidden [string] $CreateVMHostIPRouteMessage = "Creating IP Route with Gateway address {0} and Destination address {1} on VMHost {2}."
    hidden [string] $RemoveVMHostIPRouteMessage = "Removing IP Route with Gateway address {0} and Destination address {1} on VMHost {2}."

    hidden [string] $CouldNotCreateVMHostIPRouteMessage = "Could not create IP Route with Gateway address {0} and Destination address {1} on VMHost {2}. For more information: {3}"
    hidden [string] $CouldNotRemoveVMHostIPRouteMessage = "Could not remove IP Route with Gateway address {0} and Destination address {1} on VMHost {2}. For more information: {3}"

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $vmHostIPRoute = $this.GetVMHostIPRoute($vmHost)

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $vmHostIPRoute) {
                    $this.NewVMHostIPRoute($vmHost)
                }
            }
            else {
                if ($null -ne $vmHostIPRoute) {
                    $this.RemoveVMHostIPRoute($vmHostIPRoute)
                }
            }
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.SetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [bool] Test() {
        try {
            Write-VerboseLog -Message $this.TestMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $vmHostIPRoute = $this.GetVMHostIPRoute($vmHost)

            $result = $null
            if ($this.Ensure -eq [Ensure]::Present) {
                $result = ($null -ne $vmHostIPRoute)
            }
            else {
                $result = ($null -eq $vmHostIPRoute)
            }

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [VMHostIPRoute] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [VMHostIPRoute]::new()

            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $vmHostIPRoute = $this.GetVMHostIPRoute($vmHost)

            $this.PopulateResult($result, $vmHostIPRoute)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the configured IPv4/IPv6 route with the specified Gateway and Destination addresses if it exists.
    #>
    [PSObject] GetVMHostIPRoute($vmHost) {
        return (Get-VMHostRoute -Server $this.Connection -VMHost $vmHost -ErrorAction SilentlyContinue -Verbose:$false |
                Where-Object -FilterScript { $_.Gateway -eq $this.Gateway -and $_.Destination -eq $this.Destination -and $_.PrefixLength -eq $this.PrefixLength })
    }

    <#
    .DESCRIPTION

    Creates a new IP route with the specified Gateway and Destination addresses.
    #>
    [void] NewVMHostIPRoute($vmHost) {
        $newVMHostRouteParams = @{
            Server = $this.Connection
            VMHost = $vmHost
            Gateway = $this.Gateway
            Destination = $this.Destination
            PrefixLength = $this.PrefixLength
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        try {
            Write-VerboseLog -Message $this.CreateVMHostIPRouteMessage -Arguments @($this.Gateway, $this.Destination, $vmHost.Name)
            New-VMHostRoute @newVMHostRouteParams
        }
        catch {
            throw ($this.CouldNotCreateVMHostIPRouteMessage -f $this.Gateway, $this.Destination, $vmHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Removes the IP route with the specified Gateway and Destination addresses.
    #>
    [void] RemoveVMHostIPRoute($vmHostIPRoute) {
        $removeVMHostRouteParams = @{
            VMHostRoute = $vmHostIPRoute
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        try {
            Write-VerboseLog -Message $this.RemoveVMHostIPRouteMessage -Arguments @($this.Gateway, $this.Destination, $this.Name)
            Remove-VMHostRoute @removeVMHostRouteParams
        }
        catch {
            throw ($this.CouldNotRemoveVMHostIPRouteMessage -f $this.Gateway, $this.Destination, $this.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $vmHostIPRoute) {
        $result.Server = $this.Connection.Name
        $result.Name = $this.Name

        if ($null -ne $vmHostIPRoute) {
            $result.Ensure = [Ensure]::Present
            $result.Gateway = $vmHostIPRoute.Gateway
            $result.Destination = $vmHostIPRoute.Destination
            $result.PrefixLength = $vmHostIPRoute.PrefixLength
        }
        else {
            $result.Ensure = [Ensure]::Absent
            $result.Gateway = $this.Gateway
            $result.Destination = $this.Destination
            $result.PrefixLength = $this.PrefixLength
        }
    }
}
