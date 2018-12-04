<#
Copyright (c) 2018 VMware, Inc.  All rights reserved				

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License 

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-DateTimeConfig
{
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

function Update-DateTimeConfig
{
    [CmdletBinding()]
    param(
        [VMware.Vim.HostDateTimeSystem] $DateTimeSystem,
        [VMware.Vim.HostDateTimeConfig] $DateTimeConfig
    )

    $DateTimeSystem.UpdateDateTimeConfig($DateTimeConfig)
}

function Update-ServicePolicy
{
    [CmdletBinding()]
    param(
        [VMware.Vim.HostServiceSystem] $ServiceSystem,
        [string] $ServiceId,
        [string] $ServicePolicyValue
    )

    $ServiceSystem.UpdateServicePolicy($ServiceId, $ServicePolicyValue)
}

function New-DNSConfig
{
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

        if (!$Dhcp)
        {
            $dnsConfig.Address = $Address
            $dnsConfig.SearchDomain = $SearchDomain
        }
        else
        {
            $dnsConfig.Dhcp = $Dhcp
            $dnsConfig.VirtualNicDevice = $VirtualNicDevice
            
			if ($Ipv6VirtualNicDevice -ne [string]::Empty)
			{
			    $dnsConfig.Ipv6VirtualNicDevice = $Ipv6VirtualNicDevice
			}
        }

    return $dnsConfig
}

function Update-DNSConfig
{
    [CmdletBinding()]
    param(
        [VMware.Vim.HostNetworkSystem] $NetworkSystem,
        [VMware.Vim.HostDnsConfig] $DnsConfig
    )

    $NetworkSystem.UpdateDnsConfig($DnsConfig)
}

function Get-SATPClaimRules
{
    [CmdletBinding()]
    [OutputType([Object[]])]
    param(
        [PSObject] $EsxCli
    )

    $satpClaimRules = $EsxCli.storage.nmp.satp.rule.list.Invoke()
    return $satpClaimRules
}

function Add-CreateArgs
{
    [CmdletBinding()]
    [OutputType([Hashtable])]
    param(
        [PSOBject] $EsxCli
    )

    $satpArgs = $EsxCli.storage.nmp.satp.rule.add.CreateArgs()
    return $satpArgs
}

function Add-SATPClaimRule
{
    [CmdletBinding()]
    param(
        [PSObject] $EsxCli,
        [Hashtable] $SatpArgs
    )

    $EsxCli.storage.nmp.satp.rule.add.Invoke($SatpArgs)
}

function Remove-CreateArgs
{
    [CmdletBinding()]
    [OutputType([Hashtable])]
    param(
        [PSObject] $EsxCli
    )

    $satpArgs = $EsxCli.storage.nmp.satp.rule.remove.CreateArgs()
    return $satpArgs
}

function Remove-SATPClaimRule
{
    [CmdletBinding()]
    param(
        [PSObject] $EsxCli,
        [Hashtable] $SatpArgs
    )

    $EsxCli.storage.nmp.satp.rule.remove.Invoke($SatpArgs)
}

function New-PerformanceInterval
{
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

function Update-PerfInterval
{
    [CmdletBinding()]
    param(
        [VMware.Vim.PerformanceManager] $PerformanceManager,
        [VMware.Vim.PerfInterval] $PerformanceInterval
    )

    $PerformanceManager.UpdatePerfInterval($PerformanceInterval)
}