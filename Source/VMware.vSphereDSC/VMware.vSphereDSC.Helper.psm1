<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

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
        [Hashtable] $VssShapingConfig,
        [Parameter(ParameterSetName = 'VSSTeaming')]
        [Hashtable] $VssTeamingConfig,
        [Parameter(ParameterSetName = 'VSSBridge')]
        [Hashtable] $VssBridgeConfig
    )

    Write-Verbose -Message "$(Get-Date) $($s = Get-PSCallStack; "Entering {0}" -f $s[0].FunctionName)"

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

            if ($null -eq $hostVirtualSwitchConfig -and $VssConfig.Operation -ne 'add') {
                throw "Standard Virtual Switch $($VssConfig.Name) was not found."
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
            # Although ignored since ESXi 5.5, the NumPorts property is 'required'
            $hostVirtualSwitchConfig.Spec.NumPorts = 1
            $configNet.Vswitch += $hostVirtualSwitchConfig
        }

        'VSSSecurity' {
            $hostVirtualSwitchConfig = $NetworkSystem.NetworkConfig.Vswitch | Where-Object { $_.Name -eq $VssSecurityConfig.Name }

            $hostVirtualSwitchConfig.ChangeOperation = $VssSecurityConfig.Operation
            if ($null -ne $VssSecurityConfig.AllowPromiscuous) { $hostVirtualSwitchConfig.Spec.Policy.Security.AllowPromiscuous = $VssSecurityConfig.AllowPromiscuous }
            if ($null -ne $VssSecurityConfig.ForgedTransmits) { $hostVirtualSwitchConfig.Spec.Policy.Security.ForgedTransmits = $VssSecurityConfig.ForgedTransmits }
            if ($null -ne $VssSecurityConfig.MacChanges) { $hostVirtualSwitchConfig.Spec.Policy.Security.MacChanges = $VssSecurityConfig.MacChanges }

            $configNet.Vswitch += $hostVirtualSwitchConfig
        }

        'VSSShaping' {
            $hostVirtualSwitchConfig = $NetworkSystem.NetworkConfig.Vswitch | Where-Object { $_.Name -eq $VssShapingConfig.Name }

            $hostVirtualSwitchConfig.ChangeOperation = $VssShapingConfig.Operation
            if ($null -ne $VssShapingConfig.Enabled) { $hostVirtualSwitchConfig.Spec.Policy.ShapingPolicy.Enabled = $VssShapingConfig.Enabled }
            if ($null -ne $VssShapingConfig.AverageBandwidth) { $hostVirtualSwitchConfig.Spec.Policy.ShapingPolicy.AverageBandwidth = $VssShapingConfig.AverageBandwidth }
            if ($null -ne $VssShapingConfig.BurstSize) { $hostVirtualSwitchConfig.Spec.Policy.ShapingPolicy.BurstSize = $VssShapingConfig.BurstSize }
            if ($null -ne $VssShapingConfig.PeakBandwidth) { $hostVirtualSwitchConfig.Spec.Policy.ShapingPolicy.PeakBandwidth = $VssShapingConfig.PeakBandwidth }

            $configNet.Vswitch += $hostVirtualSwitchConfig
        }

        'VSSTeaming' {
            $hostVirtualSwitchConfig = $NetworkSystem.NetworkConfig.Vswitch | Where-Object { $_.Name -eq $VssTeamingConfig.Name }

            if ($null -ne $VssTeamingConfig.CheckBeacon -and
                $VssTeamingConfig.CheckBeacon -and
                ($hostVirtualSwitchConfig.Spec.Bridge -isNot [VMware.Vim.HostVirtualSwitchBridge] -or
                    $hostVirtualSwitchConfig.Spec.Bridge.Interval -eq 0)) {
                throw 'VMHostVssTeaming: Configuration error - CheckBeacon can only be enabled if the VirtualSwitch has been configured to use the beacon.'
            }

            if ($null -ne $VssTeamingConfig.CheckBeacon -and
                !$VssTeamingConfig.CheckBeacon -and
                $hostVirtualSwitchConfig.Spec.Bridge -is [VMware.Vim.HostVirtualSwitchBridge] -and
                $hostVirtualSwitchConfig.Spec.Bridge.Interval -eq 0) {
                throw 'VMHostVssTeaming: Configuration error - CheckBeacon can only be disabled if the VirtualSwitch has not been configured to use the beacon.'
            }

            if (($VssTeamingConfig.ActiveNic.Count -ne 0 -or
                $VssTeamingConfig.StandbyNic.Count -ne 0) -and
                $null -ne $hostVirtualSwitchConfig.Spec.Bridge -and
                $hostVirtualSwitchConfig.Spec.Bridge.NicDevice.Count -eq 0) {
                throw "VMHostVssTeaming: Configuration error - You cannot use Active or Standby NICs, when there are no NICs assigned to the Bridge."
            }

            $hostVirtualSwitchConfig.ChangeOperation = $VssTeamingConfig.Operation
            if ($null -ne $VssTeamingConfig.CheckBeacon) { $hostVirtualSwitchConfig.Spec.Policy.NicTeaming.FailureCriteria.CheckBeacon = $VssTeamingConfig.CheckBeacon }
            if (![string]::IsNullOrEmpty($VssTeamingConfig.ActiveNic)) { $hostVirtualSwitchConfig.Spec.Policy.NicTeaming.NicOrder.ActiveNic = $VssTeamingConfig.ActiveNic }
            if (![string]::IsNullOrEmpty($VssTeamingConfig.StandbyNic)) { $hostVirtualSwitchConfig.Spec.Policy.NicTeaming.NicOrder.StandbyNic = $VssTeamingConfig.StandbyNic }
            if ($null -ne $VssTeamingConfig.NotifySwitches) { $hostVirtualSwitchConfig.Spec.Policy.NicTeaming.NotifySwitches = $VssTeamingConfig.NotifySwitches }
            if ($null -ne $VssTeamingConfig.RollingOrder) { $hostVirtualSwitchConfig.Spec.Policy.NicTeaming.RollingOrder = $VssTeamingConfig.RollingOrder }

            # The Network Adapter teaming policy should be specified only when it is passed.
            if ($null -ne $VssTeamingConfig.Policy) { $hostVirtualSwitchConfig.Spec.Policy.NicTeaming.Policy = $VssTeamingConfig.Policy }

            $configNet.Vswitch += $hostVirtualSwitchConfig
        }

        'VssBridge' {
            $hostVirtualSwitchConfig = $NetworkSystem.NetworkConfig.Vswitch | Where-Object { $_.Name -eq $VssBridgeConfig.Name }

            if ($VssBridgeConfig.NicDevice.Count -eq 0) {
                if ($hostVirtualSwitchConfig.Spec.Policy.NicTeaming.NicOrder.ActiveNic.Count -ne 0 -or
                    $hostVirtualSwitchConfig.Spec.Policy.NicTeaming.NicOrder.StandbyNic.Count -ne 0) {
                    throw "VMHostVssBridge: Configuration error - When NICs are defined as Active or Standby, you must specify them under NicDevice as well."
                }
                elseif ($null -ne $VssBridgeConfig.BeaconInterval) {
                    throw "VMHostVssBridge: Configuration error - When you define a BeaconInterval, you must have one or more NICs defined under NicDevice."
                }
                elseif (![string]::IsNullOrEmpty($VssBridgeConfig.LinkDiscoveryProtocolOperation) -or ![string]::IsNullOrEmpty($VssBridgeConfig.LinkDiscoveryProtocolProtocol)) {
                    throw "VMHostVssBridge: Configuration error - When you use Link Discovery, you must have NICs defined under NicDevice."
                }
            }
            else {
                if ($VssBridgeConfig.BeaconInterval -eq 0 -and $hostVirtualSwitchConfig.Spec.Policy.NicTeaming.FailureCriteria.CheckBeacon) {
                    throw "VMHostVssBridge: Configuration error - You can not have a Beacon interval of zero, when Beacon Checking is enabled."
                }
            }

            $hostVirtualSwitchConfig.ChangeOperation = $VssBridgeConfig.Operation

            if ($VssBridgeConfig.NicDevice.Count -ne 0) {
                $hostVirtualSwitchConfig.Spec.Bridge = New-Object -TypeName 'VMware.Vim.HostVirtualSwitchBondBridge'
                $hostVirtualSwitchConfig.Spec.Bridge.NicDevice = $VssBridgeConfig.NicDevice

                if ($VssBridgeConfig.BeaconInterval -ne 0) {
                    $hostVirtualSwitchConfig.Spec.Bridge.Beacon = New-Object VMware.Vim.HostVirtualSwitchBeaconConfig
                    $hostVirtualSwitchConfig.Spec.Bridge.Beacon.Interval = $VssBridgeConfig.BeaconInterval
                }
                else {
                    if ($vss.Spec.Policy.NicTeaming.FailureCriteria.CheckBeacon) {
                        throw "VMHostVssBridge: Configuration error - When CheckBeacon is True, the BeaconInterval cannot be 0."
                    }
                }

                if (![string]::IsNullOrEmpty($VssBridgeConfig.LinkDiscoveryProtocolProtocol)) {
                    if ($VssBridgeConfig.LinkDiscoveryProtocolProtocol -eq ([LinkDiscoveryProtocolProtocol]::CDP).ToString()) {
                        $hostVirtualSwitchConfig.Spec.Bridge.linkDiscoveryProtocolConfig = New-Object -TypeName VMware.Vim.LinkDiscoveryProtocolConfig
                        $hostVirtualSwitchConfig.Spec.Bridge.linkDiscoveryProtocolConfig.Operation = $VssBridgeConfig.LinkDiscoveryProtocolOperation.ToLower()
                        $hostVirtualSwitchConfig.Spec.Bridge.linkDiscoveryProtocolConfig.Protocol = $VssBridgeConfig.LinkDiscoveryProtocolProtocol.ToLower()
                    }
                    else {
                        throw "VMHostVssBridge: Configuration error - A Virtual Switch (VSS) only supports CDP as the Link Discovery Protocol."
                    }
                }
            }
            else {
                $hostVirtualSwitchConfig.Spec.Bridge = $null
            }

            $configNet.Vswitch += $hostVirtualSwitchConfig
        }
    }

    $NetworkSystem.UpdateNetworkConfig($configNet, [VMware.Vim.HostConfigChangeMode]::modify)
}

function Add-Cluster {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [VMware.Vim.Folder] $Folder,

        [Parameter(Mandatory = $true)]
        [string] $Name,

        [Parameter(Mandatory = $true)]
        [VMware.Vim.ClusterConfigSpecEx] $Spec
    )

    $Folder.CreateClusterEx($Name, $Spec)
}

function Update-ClusterComputeResource {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [VMware.Vim.ClusterComputeResource] $ClusterComputeResource,

        [Parameter(Mandatory = $true)]
        [VMware.Vim.ClusterConfigSpecEx] $Spec
    )

    $ClusterComputeResource.ReconfigureComputeResource_Task($Spec, $true)
}

function Remove-ClusterComputeResource {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [VMware.Vim.ClusterComputeResource] $ClusterComputeResource
    )

    $ClusterComputeResource.Destroy()
}

function Update-VMHostAdvancedSettings {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [VMware.Vim.OptionManager] $VMHostAdvancedOptionManager,

        [Parameter(Mandatory = $true)]
        [VMware.Vim.OptionValue[]] $Options
    )

    $VMHostAdvancedOptionManager.UpdateOptions($Options)
}

function Update-AgentVMConfiguration {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [VMware.Vim.HostEsxAgentHostManager] $EsxAgentHostManager,

        [Parameter(Mandatory = $true)]
        [VMware.Vim.HostEsxAgentHostManagerConfigInfo] $EsxAgentHostManagerConfigInfo
    )

    $EsxAgentHostManager.EsxAgentHostManagerUpdateConfig($EsxAgentHostManagerConfigInfo)
}

function Update-PassthruConfig {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [VMware.Vim.HostPciPassthruSystem] $VMHostPciPassthruSystem,

        [Parameter(Mandatory = $true)]
        [VMware.Vim.HostPciPassthruConfig] $VMHostPciPassthruConfig
    )

    $VMHostPciPassthruSystem.UpdatePassthruConfig($VMHostPciPassthruConfig)
}

function Update-GraphicsConfig {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [VMware.Vim.HostGraphicsManager] $VMHostGraphicsManager,

        [Parameter(Mandatory = $true)]
        [VMware.Vim.HostGraphicsConfig] $VMHostGraphicsConfig
    )

    $VMHostGraphicsManager.UpdateGraphicsConfig($VMHostGraphicsConfig)
}

function Update-PowerPolicy {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [VMware.Vim.HostPowerSystem] $VMHostPowerSystem,

        [Parameter(Mandatory = $true)]
        [int] $PowerPolicy
    )

    $VMHostPowerSystem.ConfigurePowerPolicy($PowerPolicy)
}

function Update-HostCacheConfiguration {
    [CmdletBinding()]
    [OutputType([VMware.Vim.ManagedObjectReference])]
    Param(
        [Parameter(Mandatory = $true)]
        [VMware.Vim.HostCacheConfigurationManager] $VMHostCacheConfigurationManager,

        [Parameter(Mandatory = $true)]
        [VMware.Vim.HostCacheConfigurationSpec] $Spec
    )

    return $VMHostCacheConfigurationManager.ConfigureHostCache_Task($Spec)
}

function Update-VirtualPortGroup {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [VMware.Vim.HostNetworkSystem] $VMHostNetworkSystem,

        [Parameter(Mandatory = $true)]
        [string] $VirtualPortGroupName,

        [Parameter(Mandatory = $true)]
        [VMware.Vim.HostPortGroupSpec] $Spec
    )

    $VMHostNetworkSystem.UpdatePortGroup($VirtualPortGroupName, $Spec)
}

function Invoke-EsxCliCommandMethod {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [VMware.VimAutomation.ViCore.Impl.V1.EsxCli.EsxCliImpl]
        $EsxCli,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [string]
        $EsxCliCommandMethod,

        [Parameter(Mandatory = $true)]
        [hashtable]
        $EsxCliCommandMethodArguments
    )

    Invoke-Expression -Command ("`$EsxCli." + ($EsxCliCommandMethod -f "`$EsxCliCommandMethodArguments")) -ErrorAction Stop -Verbose:$false
}

function Update-VMHostFirewallRuleset {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [VMware.Vim.HostFirewallSystem]
        $VMHostFirewallSystem,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $VMHostFirewallRulesetId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [VMware.Vim.HostFirewallRulesetRulesetSpec]
        $VMHostFirewallRulesetSpec
    )

    $VMHostFirewallSystem.UpdateRuleset($VMHostFirewallRulesetId, $VMHostFirewallRulesetSpec)
}
