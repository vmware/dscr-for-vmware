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
class VMHostNtpSettings : VMHostBaseDSC {
    <#
    .DESCRIPTION

    List of domain name or IP address of the desired NTP Servers.
    #>
    [DscProperty()]
    [string[]] $NtpServer

    <#
    .DESCRIPTION

    Desired Policy of the VMHost 'ntpd' service activation.
    #>
    [DscProperty()]
    [ServicePolicy] $NtpServicePolicy = [ServicePolicy]::Unset

    hidden [string] $ServiceId = 'ntpd'

    [void] Set() {
        try {
            $this.ConnectVIServer()

            $this.WriteLogUtil('Verbose', $this.SetMethodStartMessage, @($this.DscResourceName))

            $vmHost = $this.GetVMHost()

            $this.UpdateVMHostNtpServer($vmHost)
            $this.UpdateVMHostNtpServicePolicy($vmHost)
        }
        finally {
            $this.WriteLogUtil('Verbose', $this.SetMethodEndMessage, @($this.DscResourceName))

            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()

            $this.WriteLogUtil('Verbose', $this.TestMethodStartMessage, @($this.DscResourceName))

            $vmHost = $this.GetVMHost()

            $vmHostNtpConfig = $vmHost.ExtensionData.Config.DateTimeInfo.NtpConfig
            $vmHostServices = $vmHost.ExtensionData.Config.Service
            $vmHostNtpService = $vmHostServices.Service | Where-Object -FilterScript { $_.Key -eq $this.ServiceId }

            $result = !((
                $this.ShouldUpdateArraySetting('NtpServer', $vmHostNtpConfig.Server, $this.NtpServer),
                $this.ShouldUpdateDscResourceSetting('NtpServicePolicy', $vmHostNtpService.Policy.ToString(), $this.NtpServicePolicy.ToString())
            ) -Contains $true)

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.WriteLogUtil('Verbose', $this.TestMethodEndMessage, @($this.DscResourceName))

            $this.DisconnectVIServer()
        }
    }

    [VMHostNtpSettings] Get() {
        try {
            $this.ConnectVIServer()

            $this.WriteLogUtil('Verbose', $this.GetMethodStartMessage, @($this.DscResourceName))

            $result = [VMHostNtpSettings]::new()

            $vmHost = $this.GetVMHost()

            $vmHostNtpConfig = $vmHost.ExtensionData.Config.DateTimeInfo.NtpConfig
            $vmHostServices = $vmHost.ExtensionData.Config.Service
            $vmHostNtpService = $vmHostServices.Service | Where-Object -FilterScript { $_.Key -eq $this.ServiceId }

            $result.Name = $vmHost.Name
            $result.Server = $this.Server
            $result.NtpServer = $vmHostNtpConfig.Server
            $result.NtpServicePolicy = $vmHostNtpService.Policy

            return $result
        }
        finally {
            $this.WriteLogUtil('Verbose', $this.GetMethodEndMessage, @($this.DscResourceName))

            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Updates the VMHost NTP Server with the desired NTP Server array.
    #>
    [void] UpdateVMHostNtpServer($vmHost) {
        $vmHostNtpConfig = $vmHost.ExtensionData.Config.DateTimeInfo.NtpConfig
        if (!$this.ShouldUpdateArraySetting('NtpServer', $vmHostNtpConfig.Server, $this.NtpServer)) {
            return
        }

        $dateTimeConfig = New-DateTimeConfig -NtpServer $this.NtpServer

        $getViewParams = @{
            Server = $this.Connection
            Id = $vmHost.ExtensionData.ConfigManager.DateTimeSystem
            ErrorAction = 'Stop'
            Verbose = $false
        }
        $dateTimeSystem = Get-View @getViewParams

        Update-DateTimeConfig -DateTimeSystem $dateTimeSystem -DateTimeConfig $dateTimeConfig
    }

    <#
    .DESCRIPTION

    Updates the VMHost 'ntpd' Service Policy with the desired Service Policy.
    #>
    [void] UpdateVMHostNtpServicePolicy($vmHost) {
        $vmHostServices = $vmHost.ExtensionData.Config.Service
        $vmHostNtpService = $vmHostServices.Service | Where-Object -FilterScript { $_.Key -eq $this.ServiceId }
        if (!$this.ShouldUpdateDscResourceSetting('NtpServicePolicy', $vmHostNtpService.Policy.ToString(), $this.NtpServicePolicy.ToString())) {
            return
        }

        $getViewParams = @{
            Server = $this.Connection
            Id = $vmHost.ExtensionData.ConfigManager.ServiceSystem
            ErrorAction = 'Stop'
            Verbose = $false
        }
        $serviceSystem = Get-View @getViewParams

        Update-ServicePolicy -ServiceSystem $serviceSystem -ServiceId $this.ServiceId -ServicePolicyValue $this.NtpServicePolicy.ToString().ToLower()
    }
}
