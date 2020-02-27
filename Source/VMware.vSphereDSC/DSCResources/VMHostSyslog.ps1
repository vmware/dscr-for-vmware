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
class VMHostSyslog : VMHostBaseDSC {
    <#
    .DESCRIPTION

    The remote host(s) to send logs to.
    #>
    [DscProperty()]
    [string] $Loghost

    <#
    .DESCRIPTION

    Verify remote SSL certificates against the local CA Store.
    #>
    [DscProperty()]
    [nullable[bool]] $CheckSslCerts

    <#
    .DESCRIPTION

    Default network retry timeout in seconds if a remote server fails to respond.
    #>
    [DscProperty()]
    [nullable[long]] $DefaultTimeout

    <#
    .DESCRIPTION

    Message queue capacity after which messages are dropped.
    #>
    [DscProperty()]
    [nullable[long]] $QueueDropMark

    <#
    .DESCRIPTION

    The directory to output local logs to.
    #>
    [DscProperty()]
    [string] $Logdir

    <#
    .DESCRIPTION

    Place logs in a unique subdirectory of logdir, based on hostname.
    #>
    [DscProperty()]
    [nullable[bool]] $LogdirUnique

    <#
    .DESCRIPTION

    Default number of rotated local logs to keep.
    #>
    [DscProperty()]
    [nullable[long]] $DefaultRotate

    <#
    .DESCRIPTION

    Default size of local logs before rotation, in KiB.
    #>
    [DscProperty()]
    [nullable[long]] $DefaultSize

    <#
    .DESCRIPTION

    Number of rotated dropped log files to keep.
    #>
    [DscProperty()]
    [nullable[long]] $DropLogRotate

    <#
    .DESCRIPTION

    Size of dropped log file before rotation, in KiB.
    #>
    [DscProperty()]
    [nullable[long]] $DropLogSize

    [void] Set() {
        try {
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()

            $this.UpdateVMHostSyslog($vmHost)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()

            return !$this.ShouldUpdateVMHostSyslog($vmHost)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostSyslog] Get() {
        try {
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

            $result = [VMHostSyslog]::new()

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $this.PopulateResult($vmHost, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if VMHostSyslog needs to be updated.
    #>
    [bool] ShouldUpdateVMHostSyslog($VMHost) {
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

        $esxcli = Get-Esxcli -Server $this.Connection -VMHost $vmHost -V2
        $current = Get-VMHostSyslogConfig -EsxCLi $esxcli

        $shouldUpdateVMHostSyslog = @()

        $shouldUpdateVMHostSyslog += (![string]::IsNullOrEmpty($this.LogHost) -and $this.LogHost -ne $current.RemoteHost)
        $shouldUpdateVMHostSyslog += ($null -ne $this.CheckSslCerts -and $this.CheckSslCerts -ne $current.EnforceSSLCertificates)
        $shouldUpdateVMHostSyslog += ($null -ne $this.DefaultTimeout -and $this.DefaultTimeout -ne $current.DefaultNetworkRetryTimeout)
        $shouldUpdateVMHostSyslog += ($null -ne $this.QueueDropMark -and $this.QueueDropMark -ne $current.MessageQueueDropMark)
        $shouldUpdateVMHostSyslog += (![string]::IsNullOrEmpty($this.Logdir) -and $this.Logdir -ne $current.LocalLogOutput)
        $shouldUpdateVMHostSyslog += ($null -ne $this.LogdirUnique -and $this.LogdirUnique -ne [System.Convert]::ToBoolean($current.LogToUniqueSubdirectory))
        $shouldUpdateVMHostSyslog += ($null -ne $this.DefaultRotate -and $this.DefaultRotate -ne $current.LocalLoggingDefaultRotations)
        $shouldUpdateVMHostSyslog += ($null -ne $this.DefaultSize -and $this.DefaultSize -ne $current.LocalLoggingDefaultRotationSize)
        $shouldUpdateVMHostSyslog += ($null -ne $this.DropLogRotate -and $this.DropLogRotate -ne $current.DroppedLogFileRotations)
        $shouldUpdateVMHostSyslog += ($null -ne $this.DropLogSize -and $this.DropLogSize -ne $current.DroppedLogFileRotationSize)

        return ($shouldUpdateVMHostSyslog -contains $true)
    }

    <#
    .DESCRIPTION

    Updates the configuration of the VMHostSyslog.
    #>
    [void] UpdateVMHostSyslog($VMHost) {
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

        $esxcli = Get-Esxcli -Server $this.Connection -VMHost $vmHost -V2

        $vmHostSyslogConfig = @{
            queuedropmark = $this.QueueDropMark
            defaultrotate = $this.DefaultRotate
            droplogrotate = $this.DropLogRotate
        }

        if ($null -ne $this.CheckSslCerts) { $vmHostSyslogConfig.checksslcerts = $this.CheckSslCerts }
        if ($null -ne $this.DefaultTimeout) { $vmHostSyslogConfig.defaulttimeout = $this.DefaultTimeout }
        if (![string]::IsNullOrEmpty($this.Logdir)) { $vmHostSyslogConfig.logdir = $this.Logdir }
        if ($null -ne $this.LogdirUnique) { $vmHostSyslogConfig.logdirunique = $this.LogdirUnique }
        if ($null -ne $this.DefaultSize) { $vmHostSyslogConfig.defaultsize = $this.DefaultSize }
        if ($null -ne $this.DropLogSize) { $vmHostSyslogConfig.droplogsize = $this.DropLogSize }
        if (![string]::IsNullOrEmpty($this.LogHost)) { $vmHostSyslogConfig.loghost = $this.Loghost }

        Set-VMHostSyslogConfig -EsxCli $esxcli -VMHostSyslogConfig $vmHostSyslogConfig
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the VMHostService from the server.
    #>
    [void] PopulateResult($VMHost, $syslog) {
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

        $esxcli = Get-Esxcli -Server $this.Connection -VMHost $vmHost -V2
        $currentVMHostSyslog = Get-VMHostSyslogConfig -EsxCLi $esxcli

        $syslog.Server = $this.Server
        $syslog.Name = $VMHost.Name
        $syslog.Loghost = $currentVMHostSyslog.RemoteHost
        $syslog.CheckSslCerts = [System.Convert]::ToBoolean($currentVMHostSyslog.EnforceSSLCertificates)
        $syslog.DefaultTimeout = [long] $currentVMHostSyslog.DefaultNetworkRetryTimeout
        $syslog.QueueDropMark = [long] $currentVMHostSyslog.MessageQueueDropMark
        $syslog.Logdir = $currentVMHostSyslog.LocalLogOutput
        $syslog.LogdirUnique = [System.Convert]::ToBoolean($currentVMHostSyslog.LogToUniqueSubdirectory)
        $syslog.DefaultRotate = [long] $currentVMHostSyslog.LocalLoggingDefaultRotations
        $syslog.DefaultSize = [long] $currentVMHostSyslog.LocalLoggingDefaultRotationSize
        $syslog.DropLogRotate = [long] $currentVMHostSyslog.DroppedLogFileRotations
        $syslog.DropLogSize = [long] $currentVMHostSyslog.DroppedLogFileRotationSize
    }
}
