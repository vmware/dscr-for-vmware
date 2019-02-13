<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-DateTimeConfig {
    [CmdletBinding()]
    [OutputType([VMware.Vim.HostDateTimeConfig])]
    param(
        [string[]] $NtpServer
    )

    $dateTimeConfig = New-Object VMware.Vim.HostDateTimeConfig
    $dateTimeConfig.NtpConfig = New-Object VMware.Vim.HostNtpConfig
    $dateTimeConfig.NtpConfig.Server = $NtpServer

    return $dateTimeConfig
}

function Update-DateTimeConfig {
    [CmdletBinding()]
    param(
        [VMware.Vim.HostDateTimeSystem] $DateTimeSystem,
        [VMware.Vim.HostDateTimeConfig] $DateTimeConfig
    )

    $DateTimeSystem.UpdateDateTimeConfig($DateTimeConfig)
}

function Update-ServicePolicy {
    [CmdletBinding()]
    param(
        [VMware.Vim.HostServiceSystem] $ServiceSystem,
        [string] $ServiceId,
        [string] $ServicePolicyValue
    )

    $ServiceSystem.UpdateServicePolicy($ServiceId, $ServicePolicyValue)
}

function New-DNSConfig {
    [CmdletBinding()]
    [OutputType([VMware.Vim.HostDnsConfig])]
    param(
        [string[]] $Address,
        [bool] $Dhcp,
        [string] $DomainName,
        [string] $HostName,
        [string] $Ipv6VirtualNicDevice,
        [string[]] $SearchDomain,
        [string] $VirtualNicDevice
    )

    $dnsConfig = New-Object VMware.Vim.HostDnsConfig
    $dnsConfig.HostName = $HostName
    $dnsConfig.DomainName = $DomainName

    if (!$Dhcp) {
        $dnsConfig.Address = $Address
        $dnsConfig.SearchDomain = $SearchDomain
    }
    else {
        $dnsConfig.Dhcp = $Dhcp
        $dnsConfig.VirtualNicDevice = $VirtualNicDevice

        if ($Ipv6VirtualNicDevice -ne [string]::Empty) {
            $dnsConfig.Ipv6VirtualNicDevice = $Ipv6VirtualNicDevice
        }
    }

    return $dnsConfig
}

function Update-DNSConfig {
    [CmdletBinding()]
    param(
        [VMware.Vim.HostNetworkSystem] $NetworkSystem,
        [VMware.Vim.HostDnsConfig] $DnsConfig
    )

    $NetworkSystem.UpdateDnsConfig($DnsConfig)
}

function Get-SATPClaimRules {
    [CmdletBinding()]
    [OutputType([Object[]])]
    param(
        [PSObject] $EsxCli
    )

    $satpClaimRules = $EsxCli.storage.nmp.satp.rule.list.Invoke()
    return $satpClaimRules
}

function Add-CreateArgs {
    [CmdletBinding()]
    [OutputType([Hashtable])]
    param(
        [PSOBject] $EsxCli
    )

    $satpArgs = $EsxCli.storage.nmp.satp.rule.add.CreateArgs()
    return $satpArgs
}

function Add-SATPClaimRule {
    [CmdletBinding()]
    param(
        [PSObject] $EsxCli,
        [Hashtable] $SatpArgs
    )

    $EsxCli.storage.nmp.satp.rule.add.Invoke($SatpArgs)
}

function Remove-CreateArgs {
    [CmdletBinding()]
    [OutputType([Hashtable])]
    param(
        [PSObject] $EsxCli
    )

    $satpArgs = $EsxCli.storage.nmp.satp.rule.remove.CreateArgs()
    return $satpArgs
}

function Remove-SATPClaimRule {
    [CmdletBinding()]
    param(
        [PSObject] $EsxCli,
        [Hashtable] $SatpArgs
    )

    $EsxCli.storage.nmp.satp.rule.remove.Invoke($SatpArgs)
}

function New-PerformanceInterval {
    [CmdletBinding()]
    [OutputType([VMware.Vim.PerfInterval])]
    param(
        [int] $Key,
        [string] $Name,
        [bool] $Enabled,
        [int] $Level,
        [long] $SamplingPeriod,
        [long] $Length
    )

    $performanceInterval = New-Object VMware.Vim.PerfInterval

    $performanceInterval.Key = $Key
    $performanceInterval.Name = $Name
    $performanceInterval.Enabled = $Enabled
    $performanceInterval.Level = $Level
    $performanceInterval.SamplingPeriod = $SamplingPeriod
    $performanceInterval.Length = $Length

    return $performanceInterval
}

function Update-PerfInterval {
    [CmdletBinding()]
    param(
        [VMware.Vim.PerformanceManager] $PerformanceManager,
        [VMware.Vim.PerfInterval] $PerformanceInterval
    )

    $PerformanceManager.UpdatePerfInterval($PerformanceInterval)
}

function Compare-Settings {
    <#
    .SYNOPSIS
    Compare settings between current and desired states
    .DESCRIPTION
    This compares the current and desired states by comparing the configuration values specified in the desired state to the current state.
    If a value is not specified in the desired state it is not assessed against the current state.

    .PARAMETER DesiredState
    Desired state configuration object.

    .PARAMETER CurrentState
    Current state configuration object.
    #>
    [CmdletBinding()]
    param(
        $DesiredState,
        $CurrentState
    )

    foreach ($key in $DesiredState.Keys) {
        if ($CurrentState.$key -ne $DesiredState.$key ) {
            return $true
        }
    }
    return $false
}

function Get-VMHostSyslogConfig {
    [CmdletBinding()]
    [OutputType([Object])]
    param(
        [PSObject] $EsxCli
    )

    $syslogConfig = $EsxCli.system.syslog.config.get.Invoke()

    return $syslogConfig
}

function Set-VMHostSyslogConfig {
    [CmdletBinding()]
    [OutputType([Object[]])]
    param(
        [PSObject] $EsxCli,
        [Hashtable] $VMHostSyslogConfig
    )

    $esxcli.system.syslog.config.set.Invoke($VMHostSyslogConfig)
    $esxcli.system.syslog.reload.Invoke()
}

function Update-Network {
    [CmdletBinding()]
    param(
        [VMware.Vim.HostNetworkSystem] $NetworkSystem,
        [Parameter(ParameterSetName = 'VSS')]
        [Hashtable] $VssConfig,
        [Parameter(ParameterSetName = 'VSSSecurity')]
        [Hashtable] $VssSecurityConfig,
        [Parameter(ParameterSetName = 'VSSShaping')]
        [Hashtable] $VssShapingConfig
    )

    Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"
    Write-Verbose -Message "$(Get-Date) Parameterset $($PSCmdlet.ParameterSetName)"

    <#
    $configNet is the parameter object we pass to the UpdateNetworkConfig method.
    Since all network updates will be done via this UpdateNetworkConfig method,
    we start with an empty VMware.Vim.HostNetworkConfig object in $configNet.
    Depending on the Switch case, we add the required objects to $configNet.

    This allows the Update-Network function to be used for all ESXi network related changes.
    #>

    $configNet = New-Object VMware.Vim.HostNetworkConfig

    switch ($PSCmdlet.ParameterSetName) {
        'VSS' {
            $hostVirtualSwitchConfig = $NetworkSystem.NetworkConfig.Vswitch | Where-Object { $_.Name -eq $VssConfig.Name }

            if ($null -eq $hostVirtualSwitchConfig -and 'add' -ne $VssConfig.Operation) {
                throw "Standard Virtual Switch $($this.Name) was not found"
            }
            if ($null -eq $hostVirtualSwitchConfig) {
                $hostVirtualSwitchConfig = New-Object VMware.Vim.HostVirtualSwitchConfig
            }
            $hostVirtualSwitchConfig.ChangeOperation = $VssConfig.Operation
            $hostVirtualSwitchConfig.Name = $VssConfig.Name
            if ($null -eq $hostVirtualSwitchConfig.Spec) {
                $hostVirtualSwitchConfig.Spec = New-Object VMware.Vim.HostVirtualSwitchSpec
            }
            $hostVirtualSwitchConfig.Spec.Mtu = $VssConfig.Mtu
            $hostVirtualSwitchConfig.Spec.NumPorts = $VssConfig.NumPorts

            $configNet.Vswitch += $hostVirtualSwitchConfig
        }
        'VSSSecurity' {
            $hostVirtualSwitchConfig = $NetworkSystem.NetworkConfig.Vswitch | Where-Object { $_.Name -eq $VssSecurityConfig.Name }

            $hostVirtualSwitchConfig.ChangeOperation = $VssSecurityConfig.Operation
            $hostVirtualSwitchConfig.Spec.Policy.Security.AllowPromiscuous = $VssSecurityConfig.AllowPromiscuous
            $hostVirtualSwitchConfig.Spec.Policy.Security.ForgedTransmits = $VssSecurityConfig.ForgedTransmits
            $hostVirtualSwitchConfig.Spec.Policy.Security.MacChanges = $VssSecurityConfig.MacChanges

            $configNet.Vswitch += $hostVirtualSwitchConfig
        }
        'VSSShaping' {
            $hostVirtualSwitchConfig = $NetworkSystem.NetworkConfig.Vswitch | Where-Object { $_.Name -eq $VssSecurityConfig.Name }

            $hostVirtualSwitchConfig.ChangeOperation = $VssSecurityConfig.Operation
            $hostVirtualSwitchConfig.Spec.Policy.ShapingPolicy.AverageBandwidth = $VssShapingConfig.AverageBandwidth
            $hostVirtualSwitchConfig.Spec.Policy.ShapingPolicy.BurstSize = $VssShapingConfig.BurstSize
            $hostVirtualSwitchConfig.Spec.Policy.ShapingPolicy.Enabled = $VssShapingConfig.Enabled
            $hostVirtualSwitchConfig.Spec.Policy.ShapingPolicy.PeakBandwidth = $VssShapingConfig.PeakBandwidth

            $configNet.Vswitch += $hostVirtualSwitchConfig
        }
    }
    $NetworkSystem.UpdateNetworkConfig($configNet, [VMware.Vim.HostConfigChangeMode]::modify)
}
