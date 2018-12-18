<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

<#
Mock types of VMware.Vim assembly for the purpose of unit testing.
#>

Add-Type -TypeDefinition @"
 namespace VMware.Vim
 {
    public class VIServer : System.IEquatable<VIServer>
    {
        public string Name { get; set; }

        public string User { get; set; }

        public bool Equals(VIServer viServer)
        {
            return viServer != null && this.Name == viServer.Name && this.User == viServer.User;
        }

        public override bool Equals(object viServer)
        {
            return this.Equals(viServer as VIServer);
        }

        public override int GetHashCode()
        {
            return (this.Name + "_" + this.User).GetHashCode();
        }
    }

    public class HostNtpConfig : System.IEquatable<HostNtpConfig>
    {
        public string[] Server { get; set; }

        public string[] ConfigFile { get; set; }

        public bool Equals(HostNtpConfig ntpConfig)
        {
            if (ntpConfig == null)
            {
                return false;
            }

            if (this.Server == null && ntpConfig.Server == null)
            {
                return true;
            }

            if (this.Server != null && ntpConfig.Server != null && this.Server.Length == ntpConfig.Server.Length)
            {
                foreach (var ntpServer in this.Server)
                {
                    var position = System.Array.IndexOf(ntpConfig.Server, ntpServer);

                    if (position == -1)
                    {
                        return false;
                    }
                }

                return true;
            }

            return false;
        }

        public override bool Equals(object ntpConfig)
        {
            return this.Equals(ntpConfig as HostNtpConfig);
        }

        public override int GetHashCode()
        {
            int hash = 17;

            foreach (var server in this.Server)
            {
                hash = hash ^ server.GetHashCode();
            }

            return hash;
        }
    }

    public class HostDnsConfig : System.IEquatable<HostDnsConfig>
    {
        public string[] Address { get; set; }

        public bool Dhcp { get; set; }

        public string DomainName { get; set; }

        public string HostName { get; set; }

        public string Ipv6VirtualNicDevice { get; set; }

        public string[] SearchDomain { get; set; }

        public string VirtualNicDevice { get; set; }

        public bool Equals(HostDnsConfig dnsConfig)
        {
            return (dnsConfig != null && this.Dhcp == dnsConfig.Dhcp && this.DomainName == dnsConfig.DomainName && this.HostName == dnsConfig.HostName &&
                    this.VirtualNicDevice == dnsConfig.VirtualNicDevice && this.Ipv6VirtualNicDevice == dnsConfig.Ipv6VirtualNicDevice);
        }

        public override bool Equals(object dnsConfig)
        {
            return this.Equals(dnsConfig as HostDnsConfig);
        }

        public override int GetHashCode()
        {
            return (this.DomainName + "_" + this.HostName + "_" + this.VirtualNicDevice).GetHashCode();
        }
    }

    public class HostServiceSourcePackage
    {
    }

    public class HostService
    {
        public string Key { get; set; }

        public string Label { get; set; }

        public bool Required { get; set; }

        public bool Uninstallable { get; set; }

        public bool Running { get; set; }

        public string[] Ruleset { get; set; }

        public string Policy { get; set; }

        public HostServiceSourcePackage SourcePackage { get; set; }
    }

    public class HostDateTimeConfig : System.IEquatable<HostDateTimeConfig>
    {
        // Property used only for comparing HostDateTimeConfig objects without specified HostNtpConfigs.
        public string Id { get; set; }

        public HostNtpConfig NtpConfig { get; set; }

        public bool Equals(HostDateTimeConfig dateTimeConfig)
        {
            if (this.NtpConfig != null)
            {
                return dateTimeConfig != null && this.Id == dateTimeConfig.Id && this.NtpConfig.Equals(dateTimeConfig.NtpConfig);
            }

            return dateTimeConfig != null && this.Id == dateTimeConfig.Id;
        }

        public override bool Equals(object dateTimeConfig)
        {
            return this.Equals(dateTimeConfig as HostDateTimeConfig);
        }

        public override int GetHashCode()
        {
            if (this.NtpConfig == null)
            {
                return 0;
            }

            return this.NtpConfig.GetHashCode();
        }
    }

    public class HostServiceInfo
    {
        public HostService[] Service { get; set; }
    }

    public class HostNetworkInfo
    {
        public HostDnsConfig DnsConfig { get; set; }
    }

    public class HostConfig
    {
        public HostDateTimeConfig DateTimeInfo { get; set; }

        public HostServiceInfo Service { get; set; }

        public HostNetworkInfo Network { get; set; }
    }

    public class HostDateTimeSystem : System.IEquatable<HostDateTimeSystem>
    {
        // Property used only for comparing HostDateTimeSystem objects.
        public string Id { get; set; }

        public void UpdateDateTimeConfig(HostDateTimeConfig config)
        {
        }

        public bool Equals(HostDateTimeSystem dateTimeSystem)
        {
            return dateTimeSystem != null && this.Id == dateTimeSystem.Id;
        }

        public override bool Equals(object dateTimeSystem)
        {
            return this.Equals(dateTimeSystem as HostDateTimeSystem);
        }

        public override int GetHashCode()
        {
            return this.Id.GetHashCode();
        }
    }

    public class HostNetworkSystem : System.IEquatable<HostNetworkSystem>
    {
        // Property used only for comparing HostNetworkSystem objects.
        public string Id { get; set; }

        public void UpdateDnsConfig(HostDnsConfig dnsConfig)
        {
        }

        public bool Equals(HostNetworkSystem networkSystem)
        {
            return networkSystem != null && this.Id == networkSystem.Id;
        }

        public override bool Equals(object networkSystem)
        {
            return this.Equals(networkSystem as HostNetworkSystem);
        }

        public override int GetHashCode()
        {
            return this.Id.GetHashCode();
        }
    }

    public class HostServiceSystem : System.IEquatable<HostServiceSystem>
    {
        // Property used only for comparing HostServiceSystem objects.
        public string Id { get; set; }

        public void UpdateServicePolicy(string serviceId, string servicePolicyValue)
        {
        }

        public bool Equals(HostServiceSystem serviceSystem)
        {
            return serviceSystem != null && this.Id == serviceSystem.Id;
        }

        public override bool Equals(object serviceSystem)
        {
            return this.Equals(serviceSystem as HostServiceSystem);
        }

        public override int GetHashCode()
        {
            return this.Id.GetHashCode();
        }
    }

    public class HostConfigManager
    {
        public HostDateTimeSystem DateTimeSystem { get; set; }

        public HostNetworkSystem NetworkSystem { get; set; }

        public HostServiceSystem ServiceSystem { get; set; }
    }

    public class HostExtensionData
    {
        public HostConfig Config { get; set; }

        public HostConfigManager ConfigManager { get; set; }
    }

    public class VMHost : System.IEquatable<VMHost>
    {
        // Property used only for comparing VMHost objects.
        public string Id { get; set; }

        public HostExtensionData ExtensionData { get; set; }

        public bool Equals(VMHost vmhost)
        {
            return vmhost != null && this.Id == vmhost.Id;
        }

        public override bool Equals(object vmhost)
        {
            return this.Equals(vmhost as VMHost);
        }

        public override int GetHashCode()
        {
            return this.Id.GetHashCode();
        }
    }

    public class SatpClaimRule
    {
        public SatpClaimRule()
        {
        }

        public string Name { get; set; }

        public string PSPOptions { get; set; }

        public string Transport { get; set; }

        public string Description { get; set; }

        public string Vendor { get; set; }

        public string Device { get; set; }

        public string Driver { get; set; }

        public string ClaimOptions { get; set; }

        public string DefaultPSP { get; set; }

        public string Options { get; set; }

        public string Model { get; set; }
    }

    public class AdvancedSetting : System.IEquatable<AdvancedSetting>
    {
        public string Name { get; set; }

        public object Value { get; set; }

        public bool Equals(AdvancedSetting advancedSetting)
        {
            return advancedSetting != null && this.Name == advancedSetting.Name;
        }

        public override bool Equals(object advancedSetting)
        {
            return this.Equals(advancedSetting as AdvancedSetting);
        }

        public override int GetHashCode()
        {
            return (this.Name + "_" + this.Value).GetHashCode();
        }
    }

    public class PerfInterval : System.IEquatable<PerfInterval>
    {
        public int Key { get; set; }

        public string Name { get; set; }

        public bool Enabled { get; set; }

        public long SamplingPeriod { get; set; }

        public long Length { get; set; }

        public int Level { get; set; }

        public bool Equals(PerfInterval perfInterval)
        {
            return (perfInterval != null && this.Key == perfInterval.Key && this.Name == perfInterval.Name && this.Enabled == perfInterval.Enabled &&
                    this.SamplingPeriod == perfInterval.SamplingPeriod && this.Length == perfInterval.Length && this.Level == perfInterval.Level);
        }

        public override bool Equals(object perfInterval)
        {
            return this.Equals(perfInterval as PerfInterval);
        }

        public override int GetHashCode()
        {
            return (this.Key + "_" + this.Name + "_" + this.Enabled + "_" + this.SamplingPeriod + "_" + "this.Length" + "_" + this.Level).GetHashCode();
        }
    }

    public class PerformanceManager : System.IEquatable<PerformanceManager>
    {
        // Property used only for comparing PerformanceManager objects.
        public string Id { get; set; }

        public PerfInterval[] HistoricalInterval { get; set; }

        public void UpdatePerfInterval(PerfInterval performanceInterval)
        {
        }

        public bool Equals(PerformanceManager perfManager)
        {
            return perfManager != null && this.Id == perfManager.Id;
        }

        public override bool Equals(object perfManager)
        {
            return this.Equals(perfManager as PerformanceManager);
        }

        public override int GetHashCode()
        {
            return this.Id.GetHashCode();
        }
    }

    public class ServiceContent
    {
        public PerformanceManager PerfManager { get; set; }
    }

    public class VCenterExtensionData
    {
        public ServiceContent Content { get; set; }
    }

    public class VCenter : System.IEquatable<VCenter>
    {
        public string Name { get; set; }

        public string User { get; set; }

        public VCenterExtensionData ExtensionData { get; set; }

        public bool Equals(VCenter vCenter)
        {
            return vCenter != null && this.Name == vCenter.Name && this.User == vCenter.User;
        }

        public override bool Equals(object vCenter)
        {
            return this.Equals(vCenter as VCenter);
        }

        public override int GetHashCode()
        {
            return (this.Name + "_" + this.User).GetHashCode();
        }
    }
 }
"@

function Connect-VIServer {
    param(
        [string] $Server,
        [PSCredential] $Credential
    )

    return New-Object VMware.Vim.VIServer
}

function Get-VMHost {
    param(
        [PSObject] $Server,
        [string] $Name
    )

    return New-Object VMware.Vim.VMHost
}

function Get-View {
    param(
        [PSObject] $Server,
        [PSObject] $VIObject
    )

    return $null
}

function Get-EsxCli {
    param(
        [PSObject] $Server,
        [VMware.Vim.VMHost] $VMHost,
        [switch] $V2
    )

    return $null
}

function Get-AdvancedSetting {
    param(
        [PSObject] $Server,
        [PSObject] $Entity,
        [string] $Name
    )

    return @( [VMware.Vim.AdvancedSetting] @{} )
}

function Set-AdvancedSetting {
    param(
        [Vmware.Vim.AdvancedSetting] $AdvancedSetting,
        [string] $Value,
        [switch] $Confirm
    )

    return $null
}