namespace VMware.Vim
{
    public enum ServicePolicy
    {
        Unset = 0,
        On = 1,
        Off = 2,
        Automatic = 3
    }

    public enum BadCertificateAction
    {
        Ignore,
        Warn,
        Prompt,
        Fail,
        Unset
    }

    public enum DefaultVIServerMode
    {
        Single,
        Multiple,
        Unset
    }

    public enum ProxyPolicy
    {
        NoProxy,
        UseSystemProxy,
        Unset
    }

    public class ManagedObjectReference : System.IEquatable<ManagedObjectReference>
    {
        public string Type { get; set; }

        public string Value { get; set; }

        public bool Equals(ManagedObjectReference moRef)
        {
            return moRef != null && this.Type == moRef.Type && this.Value == moRef.Value;
        }

        public override bool Equals(object moRef)
        {
            return this.Equals(moRef as ManagedObjectReference);
        }

        public override int GetHashCode()
        {
            return (this.Type + "_" + this.Value).GetHashCode();
        }
    }

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

        public HostVirtualSwitch[] vSwitch { get; set; }
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

        public HostNetworkInfo NetworkInfo { get; set; }

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
        public ManagedObjectReference DateTimeSystem { get; set; }

        public ManagedObjectReference NetworkSystem { get; set; }

        public ManagedObjectReference ServiceSystem { get; set; }
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

        public string Name { get; set; }

        public HostExtensionData ExtensionData { get; set; }

        public bool Equals(VMHost vmhost)
        {
            return vmhost != null && this.Id == vmhost.Id && this.Name == vmhost.Name;
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

    public class Folder
    {
        public string Name { get; set; }

        public ManagedObjectReference[] ChildEntity { get; set; }
    }

    public class Datacenter
    {
        public string Name { get; set; }
    }

    public class ServiceContent
    {
        public ManagedObjectReference PerfManager { get; set; }

        public Folder RootFolder { get; set; }
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

    public class VMHostService : System.IEquatable<VMHostService>
    {
        public VMHostService()
        {
        }

        public string Key { get; set; }

        public string Label { get; set; }

        public ServicePolicy Policy { get; set; }

        public bool Required { get; set; }

        public string Ruleset { get; set; }

        public bool Running { get; set; }

        public bool Uninstallable { get; set; }

        public bool Equals(VMHostService vmHostService)
        {
            return vmHostService != null && this.Key == vmHostService.Key && this.Policy == vmHostService.Policy && this.Running == vmHostService.Running;
        }

        public override bool Equals(object vmHostService)
        {
            return this.Equals(vmHostService as VMHostService);
        }

        public override int GetHashCode()
        {
            return this.Key.GetHashCode();
        }
    }

    public class SyslogConfig : System.IEquatable<SyslogConfig>
    {
        public SyslogConfig()
        {
        }

        public string LogHost { get; set; }

        public string LogDir { get; set; }

        public bool LogDirUnique { get; set; }

        public bool CheckSslCerts { get; set; }

        public long DefaultRotate { get; set; }

        public long DefaultSize { get; set; }

        public long DefaultTimeout { get; set; }

        public long QueueDropMark { get; set; }

        public long DropLogRotate { get; set; }

        public long DropLogSize { get; set; }

        public bool Equals(SyslogConfig syslogConfig)
        {
            return syslogConfig != null && this.LogHost == syslogConfig.LogHost && this.CheckSslCerts == syslogConfig.CheckSslCerts &&
                this.DefaultRotate == syslogConfig.DefaultRotate && this.DefaultSize == syslogConfig.DefaultSize &&
                this.DefaultTimeout == syslogConfig.DefaultTimeout && this.DropLogRotate == syslogConfig.DropLogRotate &&
                this.DropLogSize == syslogConfig.DropLogSize && this.LogDir == syslogConfig.LogDir &&
                this.LogDirUnique == syslogConfig.LogDirUnique && this.QueueDropMark == syslogConfig.QueueDropMark;
        }

        public override bool Equals(object syslogConfig)
        {
            return this.Equals(syslogConfig as SyslogConfig);
        }

        public override int GetHashCode()
        {
            return (this.LogHost + "_" +
                    this.LogDir + "_" +
                    this.DefaultRotate + "_" +
                    this.DefaultSize + "_" +
                    this.DefaultTimeout + "_" +
                    this.QueueDropMark + "_" +
                    this.DropLogRotate + "_" +
                    this.DropLogSize).GetHashCode();
        }
    }

    public class PowerCLIConfiguration : System.IEquatable<PowerCLIConfiguration>
    {
        public PowerCLIConfiguration()
        {
        }

        public int Id { get; set; }

        public string Scope { get; set; }

        public ProxyPolicy CEIPDataTransferProxyPolicy { get; set; }

        public DefaultVIServerMode DefaultVIServerMode { get; set; }

        public bool DisplayDeprecationWarnings { get; set; }

        public BadCertificateAction InvalidCertificateAction { get; set; }

        public bool ParticipateInCeip { get; set; }

        public ProxyPolicy ProxyPolicy { get; set; }

        public int WebOperationTimeoutSeconds { get; set; }

        public bool Equals(PowerCLIConfiguration powerCLIConfiguration)
        {
            return (powerCLIConfiguration != null && this.Id == powerCLIConfiguration.Id && this.Scope == powerCLIConfiguration.Scope &&
                    this.CEIPDataTransferProxyPolicy == powerCLIConfiguration.CEIPDataTransferProxyPolicy && this.DefaultVIServerMode == powerCLIConfiguration.DefaultVIServerMode &&
                    this.DisplayDeprecationWarnings == powerCLIConfiguration.DisplayDeprecationWarnings && this.InvalidCertificateAction == powerCLIConfiguration.InvalidCertificateAction &&
                    this.ParticipateInCeip == powerCLIConfiguration.ParticipateInCeip && this.ProxyPolicy == powerCLIConfiguration.ProxyPolicy &&
                    this.WebOperationTimeoutSeconds == powerCLIConfiguration.WebOperationTimeoutSeconds);
        }

        public override bool Equals(object powerCLIConfiguration)
        {
            return this.Equals(powerCLIConfiguration as PowerCLIConfiguration);
        }

        public override int GetHashCode()
        {
            return (this.Id + "_" + this.Scope + "_" + this.CEIPDataTransferProxyPolicy.ToString() + "_" + this.DefaultVIServerMode.ToString() + "_" +
                    this.InvalidCertificateAction.ToString() + "_" + this.ProxyPolicy.ToString() + this.WebOperationTimeoutSeconds).GetHashCode();
        }
    }

    public class HostVirtualSwitch : System.IEquatable<HostVirtualSwitch>
    {
        public HostVirtualSwitch()
        {
        }

        public string Key { get; set; }

        public int Mtu { get; set; }

        public string Name { get; set; }

        public int NumPorts { get; set; }

        public int NumPortsAvailable { get; set; }

        public string[] Pnic { get; set; }

        public string[] Portgroup { get; set; }

        public bool Equals(HostVirtualSwitch hostVirtualSwitch)
        {
            return (hostVirtualSwitch != null && this.Name == hostVirtualSwitch.Name && this.NumPorts == hostVirtualSwitch.NumPorts &&
                    this.Mtu == hostVirtualSwitch.Mtu);
        }

        public override bool Equals(object hostVirtualSwitch)
        {
            return this.Equals(hostVirtualSwitch as HostVirtualSwitch);
        }

        public override int GetHashCode()
        {
            return (this.Key + "_" +
                    this.Mtu + "_" +
                    this.Name + "_" +
                    this.NumPorts + "_").GetHashCode();
        }
    }

    public class HostVirtualSwitchSpec
    {
        public int Mtu { get; set; }

        public int NumPorts { get; set; }
    }
    public class HostVirtualSwitchConfig
    {
        public string ChangeOperation { get; set; }

        public string Name { get; set; }

        public HostVirtualSwitchSpec Spec { get; set; }
    }

    public class HostNetworkConfigResult
    {
        public string[] ConsoleVnicDevice { get; set; }

        public string[] VnicDevice { get; set; }
    }
}
