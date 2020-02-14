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
class VMHostSoftwareDevice : EsxCliBaseDSC {
    VMHostSoftwareDevice() {
        $this.EsxCliCommand = 'device.software'
    }

    <#
    .DESCRIPTION

    Specifies the device identifier from the device specification for the software device driver. Valid input is in reverse domain name format (e.g. com.company.device...).
    #>
    [DscProperty(Key)]
    [string] $DeviceIdentifier

    <#
    .DESCRIPTION

    Specifies whether the software device should be present or absent.
    #>
    [DscProperty(Mandatory = $true)]
    [Ensure] $Ensure

    <#
    .DESCRIPTION

    Specifies the unique number to address this instance of the device, if multiple instances of the same device identifier are added. Valid values are integer in the range 0-31. Default is 0.
    #>
    [DscProperty()]
    [nullable[long]] $InstanceAddress

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            $softwareDevice = $this.GetVMHostSoftwareDevice()
            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $softwareDevice) {
                    $this.ExecuteEsxCliModifyMethod($this.EsxCliAddMethodName)
                }
            }
            else {
                if ($null -ne $softwareDevice) {
                    $this.ExecuteEsxCliModifyMethod($this.EsxCliRemoveMethodName)
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
            $this.GetEsxCli($vmHost)

            $result = $this.IsVMHostSoftwareDeviceInDesiredState()

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [VMHostSoftwareDevice] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [VMHostSoftwareDevice]::new()

            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            $this.PopulateResult($result, $vmHost)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Software device with the specified id and instance address if it exists.
    #>
    [PSObject] GetVMHostSoftwareDevice() {
        $esxCliListMethodResult = $this.ExecuteEsxCliRetrievalMethod($this.EsxCliListMethodName)
        $softwareDeviceInstanceAddress = if ($null -ne $this.InstanceAddress) { $this.InstanceAddress } else { 0 }
        $softwareDevice = $esxCliListMethodResult | Where-Object -FilterScript { $_.DeviceID -eq $this.DeviceIdentifier -and [long] $_.Instance -eq $softwareDeviceInstanceAddress }

        return $softwareDevice
    }

    <#
    .DESCRIPTION

    Checks if the Software device is in a Desired State depending on the value of the 'Ensure' property.
    #>
    [bool] IsVMHostSoftwareDeviceInDesiredState() {
        $softwareDevice = $this.GetVMHostSoftwareDevice()

        $result = $false
        if ($this.Ensure -eq [Ensure]::Present) {
            $result = ($null -ne $softwareDevice)
        }
        else {
            $result = ($null -eq $softwareDevice)
        }

        return $result
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $vmHost) {
        $result.Server = $this.Connection.Name
        $result.Name = $vmHost.Name

        $softwareDevice = $this.GetVMHostSoftwareDevice()
        if ($null -ne $softwareDevice) {
            $result.DeviceIdentifier = $softwareDevice.DeviceID
            $result.InstanceAddress = [long] $softwareDevice.Instance
            $result.Ensure = [Ensure]::Present
        }
        else {
            $result.DeviceIdentifier = $this.DeviceIdentifier
            $result.InstanceAddress = $this.InstanceAddress
            $result.Ensure = [Ensure]::Absent
        }
    }
}
