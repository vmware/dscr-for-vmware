namespace VMware.Vim
{
    using System.Linq;

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

    public enum HAIsolationResponse
    {
        PowerOff,
        DoNothing,
        Shutdown
    }

    public enum HARestartPriority
    {
        Disabled,
        Low,
        Medium,
        High
    }

    public enum DrsAutomationLevel
    {
        FullyAutomated,
        Manual,
        PartiallyAutomated,
        Disabled
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

    public class HostNetworkConfig
    {
        public HostDnsConfig DnsConfig { get; set; }

        public HostVirtualSwitchConfig[] vSwitch { get; set; }
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

        public HostNetworkConfig NetworkConfig { get; set; }

        public HostNetworkInfo NetworkInfo { get; set; }

        public void UpdateDnsConfig(HostDnsConfig dnsConfig)
        {
        }

        public void UpdateViewData(string[] properties)
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

    public class Datacenter
    {
        public ManagedObjectReference VmFolder { get; set; }

        public ManagedObjectReference HostFolder { get; set; }

        public ManagedObjectReference DatastoreFolder { get; set; }

        public ManagedObjectReference NetworkFolder { get; set; }
    }

    public class ServiceContent
    {
        public ManagedObjectReference PerfManager { get; set; }

        public ManagedObjectReference RootFolder { get; set; }
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

    public class SyslogConfigOut
    {
        public SyslogConfigOut()
        {
        }

        public string RemoteHost { get; set; }

        public string LogDir { get; set; }

        public bool LogDirUnique { get; set; }

        public bool CheckSslCerts { get; set; }

        public long DefaultRotate { get; set; }

        public long DefaultSize { get; set; }

        public long DefaultTimeout { get; set; }

        public long QueueDropMark { get; set; }

        public long DropLogRotate { get; set; }

        public long DropLogSize { get; set; }
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

        public HostVirtualSwitchSpec Spec { get; set; }

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

    public class HostVirtualSwitchBridge
    { }

    public class HostVirtualSwitchAutoBridge : HostVirtualSwitchBridge
    {
        public string[] ExcludedNicDevice { get; set; }
    }

    public class HostVirtualSwitchBeaconConfig
    {
        public int Interval { get; set; }
    }

    public class LinkDiscoveryProtocolConfig
    {
        public string Operation { get; set; }

        public string Protocol { get; set; }
    }

    public class HostVirtualSwitchBondBridge : HostVirtualSwitchBridge
    {
        public HostVirtualSwitchBeaconConfig Beacon { get; set; }

        public LinkDiscoveryProtocolConfig LinkDiscoveryProtocolConfig { get; set; }

        public string[] NicDevice { get; set; }
    }

    public class HostVirtualSwitchSimpleBridge : HostVirtualSwitchBridge
    {
        public string[] NicDevice { get; set; }
    }

    public class HostNicFailureCriteria
    {
        public bool CheckBeacon { get; set; }

        public bool CheckDuplex { get; set; }

        public bool CheckErrorPercent { get; set; }

        public string CheckSpeed { get; set; }

        public bool FullDuplex { get; set; }

        public int Percentage { get; set; }

        public int Speed { get; set; }
    }

    public class HostNicOrderPolicy
    {
        public string[] ActiveNic { get; set; }

        public string[] StandbyNic { get; set; }
    }

    public class HostNicTeamingPolicy
    {
        public HostNicFailureCriteria FailureCriteria { get; set; }

        public HostNicOrderPolicy NicOrder { get; set; }

        public bool NotifySwitches { get; set; }

        public string Policy { get; set; }

        public bool ReversePolicy { get; set; }

        public bool RollingOrder { get; set; }
    }

    public class HostNetOffloadCapabilities
    {
        public bool CsumOffload { get; set; }

        public bool TcpSegmentation { get; set; }

        public bool ZeroCopyXmit { get; set; }
    }

    public class HostNetworkSecurityPolicy
    {
        public bool AllowPromiscuous { get; set; }

        public bool ForgedTransmits { get; set; }

        public bool MacChanges { get; set; }
    }

    public class HostNetworkTrafficShapingPolicy
    {
        public long AverageBandwidth { get; set; }

        public long BurstSize { get; set; }

        public bool Enabled { get; set; }

        public long PeakBandwidth { get; set; }
    }

    public class HostNetworkPolicy
    {
        public HostNicTeamingPolicy NicTeaming { get; set; }

        public HostNetOffloadCapabilities OffloadPolicy { get; set; }

        public HostNetworkSecurityPolicy Security { get; set; }

        public HostNetworkTrafficShapingPolicy ShapingPolicy { get; set; }
    }

    public class HostVirtualSwitchSpec
    {
        public HostVirtualSwitchBridge Bridge { get; set; }

        public int Mtu { get; set; }

        public int NumPorts { get; set; }

        public HostNetworkPolicy Policy { get; set; }
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

    public class OptionValue : System.IEquatable<OptionValue>
    {
        public string Key { get; set; }

        public object Value { get; set; }

        public bool Equals(OptionValue optionValue)
        {
            if (optionValue == null)
            {
                return false;
            }

            if (this.Key != optionValue.Key)
            {
                return false;
            }

            // The Value property can be of type int or string. So we first check if it's an integer and if it's not we then check if it's a string.
            if (this.Value is int && optionValue.Value is int)
            {
                return (int)this.Value == (int)optionValue.Value;
            }
            else if (this.Value is string && optionValue.Value is string)
            {
                return (string)this.Value == (string)optionValue.Value;
            }
            else
            {
                return false;
            }
        }

        public override bool Equals(object optionValue)
        {
            return this.Equals(optionValue as OptionValue);
        }

        public override int GetHashCode()
        {
            return (this.Key + "_" + this.Value).GetHashCode();
        }
    }

    public class ClusterDrsConfigInfo : System.IEquatable<ClusterDrsConfigInfo>
    {
        public bool Enabled { get; set; }

        public DrsAutomationLevel DefaultVmBehavior { get; set; }

        public int VmotionRate { get; set; }

        public OptionValue[] Option { get; set; }

        public bool Equals(ClusterDrsConfigInfo clusterDrsConfigInfo)
        {
            if (clusterDrsConfigInfo == null)
            {
                return false;
            }

            // First we check all properties except the Option array for equality. If any of them are not equal we return false without comparing the Option arrays.
            var areEqual = (this.Enabled == clusterDrsConfigInfo.Enabled && this.DefaultVmBehavior == clusterDrsConfigInfo.DefaultVmBehavior && this.VmotionRate == clusterDrsConfigInfo.VmotionRate);
            if (!areEqual)
            {
                return false;
            }

            // If the Option arrays are both null, we return true because all other properties are equal.
            if (this.Option == null && clusterDrsConfigInfo.Option == null)
            {
                return true;
            }

            // If the Option arrays are not null and are of equal length, we check if every option from the first array is present in the second array.
            if (this.Option != null && clusterDrsConfigInfo.Option != null && this.Option.Length == clusterDrsConfigInfo.Option.Length)
            {
                foreach (var option in this.Option)
                {
                    var containsOption = clusterDrsConfigInfo.Option.Contains(option);
                    if (!containsOption)
                    {
                        return false;
                    }
                }

                return true;
            }

            return false;
        }

        public override bool Equals(object clusterDrsConfigInfo)
        {
            return this.Equals(clusterDrsConfigInfo as ClusterDrsConfigInfo);
        }

        public override int GetHashCode()
        {
            var result = new System.Text.StringBuilder();
            result.Append(this.Enabled + "_" + this.DefaultVmBehavior + "_" + this.VmotionRate);

            foreach (var option in this.Option)
            {
                result.Append(option.Key + "_" + option.Value);
            }

            return result.ToString().GetHashCode();
        }
    }

    public class ClusterConfigSpecEx : System.IEquatable<ClusterConfigSpecEx>
    {
        public ClusterDrsConfigInfo DrsConfig { get; set; }

        public bool Equals(ClusterConfigSpecEx clusterConfigSpecEx)
        {
            return (clusterConfigSpecEx != null && this.DrsConfig.Equals(clusterConfigSpecEx.DrsConfig));
        }

        public override bool Equals(object clusterConfigSpecEx)
        {
            return this.Equals(clusterConfigSpecEx as ClusterConfigSpecEx);
        }

        public override int GetHashCode()
        {
            return this.DrsConfig.GetHashCode();
        }
    }

    public class ClusterConfigInfoEx : System.IEquatable<ClusterConfigInfoEx>
    {
        public ClusterDrsConfigInfo DrsConfig { get; set; }

        public bool Equals(ClusterConfigInfoEx clusterConfigInfoEx)
        {
            return (clusterConfigInfoEx != null && this.DrsConfig.Equals(clusterConfigInfoEx.DrsConfig));
        }

        public override bool Equals(object clusterConfigInfoEx)
        {
            return this.Equals(clusterConfigInfoEx as ClusterConfigInfoEx);
        }

        public override int GetHashCode()
        {
            return this.DrsConfig.GetHashCode();
        }
    }

    public class ClusterComputeResource : System.IEquatable<ClusterComputeResource>
    {
        public ClusterConfigInfoEx ConfigurationEx { get; set; }

        public bool Equals(ClusterComputeResource clusterComputeResource)
        {
            return (clusterComputeResource != null && this.ConfigurationEx.Equals(clusterComputeResource.ConfigurationEx));
        }

        public override bool Equals(object clusterComputeResource)
        {
            return this.Equals(clusterComputeResource as ClusterComputeResource);
        }

        public override int GetHashCode()
        {
            return this.ConfigurationEx.GetHashCode();
        }
    }

    public class Folder : System.IEquatable<Folder>
    {
        public string Name { get; set; }

        public ManagedObjectReference[] ChildEntity { get; set; }

        public ManagedObjectReference MoRef { get; set; }

        public ManagedObjectReference Parent { get; set; }

        public void CreateClusterEx(string Name, ClusterConfigSpecEx Spec)
        {
        }

        public bool Equals(Folder folder)
        {
            return folder != null && this.Name == folder.Name && this.MoRef != null && this.MoRef.Equals(folder.MoRef);
        }

        public override bool Equals(object folder)
        {
            return this.Equals(folder as Folder);
        }

        public override int GetHashCode()
        {
            if (this.MoRef != null)
            {
                return (this.Name + "_" + this.MoRef.Type + "_" + this.MoRef.Value).GetHashCode();
            }

            return this.Name.GetHashCode();
        }
    }
}

namespace VMware.VimAutomation.ViCore.Impl.V1.Inventory
{
    public class FolderImpl : System.IEquatable<FolderImpl>
    {
        public string Id { get; set; }

        public string Name { get; set; }

        public string ParentId { get; set; }

        public bool Equals(FolderImpl folderImpl)
        {
            return (folderImpl != null && this.Id == folderImpl.Id && this.Name == folderImpl.Name && this.ParentId == folderImpl.ParentId);
        }

        public override bool Equals(object folderImpl)
        {
            return this.Equals(folderImpl as FolderImpl);
        }

        public override int GetHashCode()
        {
            return (this.Id + "_" + this.Name + "_" + this.ParentId).GetHashCode();
        }
    }

    public class DatacenterImpl : System.IEquatable<DatacenterImpl>
    {
        public string Id { get; set; }

        public string Name { get; set; }

        public string ParentFolderId { get; set; }

        public VMware.Vim.Datacenter ExtensionData { get; set; }

        public bool Equals(DatacenterImpl datacenterImpl)
        {
            return (datacenterImpl != null && this.Id == datacenterImpl.Id && this.Name == datacenterImpl.Name && this.ParentFolderId == datacenterImpl.ParentFolderId);
        }

        public override bool Equals(object datacenterImpl)
        {
            return this.Equals(datacenterImpl as DatacenterImpl);
        }

        public override int GetHashCode()
        {
            return (this.Id + "_" + this.Name + "_" + this.ParentFolderId).GetHashCode();
        }
    }

    public class ClusterImpl : System.IEquatable<ClusterImpl>
    {
        public string Id { get; set; }

        public string Name { get; set; }

        public string ParentId { get; set; }

        public bool HAEnabled { get; set; }

        public bool HAAdmissionControlEnabled { get; set; }

        public int HAFailoverLevel { get; set; }

        public VMware.Vim.HAIsolationResponse HAIsolationResponse { get; set; }

        public VMware.Vim.HARestartPriority HARestartPriority { get; set; }

        public VMware.Vim.ClusterComputeResource ExtensionData { get; set; }

        public void ReconfigureComputeResource_Task(VMware.Vim.ClusterConfigSpecEx Spec, bool modify)
        {
        }

        public void Destroy()
        {
        }

        public bool Equals(ClusterImpl clusterImpl)
        {
            return (clusterImpl != null && this.Id == clusterImpl.Id && this.Name == clusterImpl.Name && this.ParentId == clusterImpl.ParentId &&
                    this.HAEnabled == clusterImpl.HAEnabled && this.HAAdmissionControlEnabled == clusterImpl.HAAdmissionControlEnabled &&
                    this.HAFailoverLevel == clusterImpl.HAFailoverLevel && this.HAIsolationResponse == clusterImpl.HAIsolationResponse &&
                    this.HARestartPriority == clusterImpl.HARestartPriority && this.ExtensionData.Equals(clusterImpl.ExtensionData));
        }

        public override bool Equals(object clusterImpl)
        {
            return this.Equals(clusterImpl as ClusterImpl);
        }

        public override int GetHashCode()
        {
            return (this.Id + "_" + this.Name + "_" + this.ParentId + "_" + this.HAEnabled + "_" + this.HAAdmissionControlEnabled +
                    "_" + this.HAFailoverLevel + "_" + this.HAIsolationResponse + "_" + this.HARestartPriority).GetHashCode() + this.ExtensionData.GetHashCode();
        }
    }
}
