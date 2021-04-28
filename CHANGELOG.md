# Changelog
All notable changes to this project will be documented in this file.

## VMware.PSDesiredStateConfiguration 1.0.0.17 - 2021-04-28
### Changed
- Fix bug with **`Test-VmwDscConfiguration`** cmdlet on **`PowerShell 5.1`** that occurred due to **`NodeResult`** being **`PSObject`** instead of **`PSCustomObject`**. **`Select-Object -ExpandProperty InvokeResult`** doesn't work on **`PSObject`** on **`PowerShell 5.1`**.

## 2021-03-08
### Added
- Added installation guide for **VMware.PSDesiredStateConfiguration** module.

### Changed
- Updated the **VMHostVssNic DSC Resource** documentation to be the same as the one in the [Wiki](https://github.com/vmware/dscr-for-vmware/wiki).

## VMware.vSphereDSC 2.2.0.84 - 2021-02-24
### Added
- Added **DatastoreCluster DSC Resource** that is used to create, modify and remove **Datastore Clusters** in the specified **Datacenter** on the specified **vCenter Server**.
- Added **DRSRule DSC Resource** that is used to create, modify and remove **DRS rules** for the specified **Cluster**.
- Added **DatastoreClusterAddDatastore DSC Resource** that is used to add **Datastores** to the specified **Datastore Cluster**.
- Added **VMHostVdsNic DSC Resource** that is used to modify the settings or remove **VMKernel NICs** connected to the specified **Distributed Port Group** on the specified **VDSwitch**.
- Added **VMHostStorage DSC Resource** that is used to enable or disable the **software iSCSI support** for the specified **VMHost**.
- Added **VMHostIScsiHbaVMKernelNic DSC Resource** that is used to **bind/unbind VMKernel Network Adapters** to/from the specified **iSCSI Host Bus Adapter**.

### Changed
- **VMHostVDSwitchMigration DSC Resource**: Added a new **MigratePhysicalNicsOnly** parameter to allow the user to choose to migrate only **Physical Network Adapters**. Extended the **DSC Resource** to create **distributed port groups** with **VLAN ID**.
- **VMHostIScsiHba DSC Resource**: Added **IScsiName** property to configure the **IScsiName** of the **IScsiHba**.
- **VDPortGroup DSC Resource**: Added **VLanId** property to configure the **VLanId** for a **Distributed Port Group**.
- **VMHostAccount DSC Resource**: Fixed the bug with determiting the desired state, when the **ESXi account password** should be changed.
- **VMHostVDSwitchMigration DSC Resource**: Fixed the bug with migrating **Physical Network Adapters** to **VDSwitch**. The **Physical Network Adapters** should be migrated with the **VMKernel Network Adapters** to avoid connectivity loss for the **ESXi** during the migration.
- **VMHostVssTeaming DSC Resource**: Fixed bugs with **physical network adapters** when updating the **teaming policy** of the **standard switch**.
- **NfsDatastore DSC Resource**: Moved name validation to **VmfsDatastore DSC Resource** due to not being applicable for **NfsDatastores**.

## VMware.PSDesiredStateConfiguration 1.0.0.16 - 2021-02-24
### Added
- Added **New-VmwDscConfiguration** cmdlet which compiles a **DSC Configuration** into a **VmwDscConfiguration** object, which contains the name of the **DSC Configuration** and the **DSC Resources** defined in it.
- Added **Start**, **Test** and **Get-VmwDscConfiguration** cmdlets which work with the **VmwDscConfiguration** object created by the **New-VmwDscConfiguration** cmdlet and apply the **Set**, **Test**, **Get** methods to the compiled **DSC Configuration**.
- Added **vSphereNode** which is a special dynamic keyword that represents a connection to a **VIServer**. Each **vSphereNode** can contain **DSC Resources** from the module **VMware.vSphereDSC**. The **vSphere Nodes** along with the new execution engine allow the user to bundle **DSC Resources** and specify a common **VIServer** connection which gets reused.

## VMware.PSDesiredStateConfiguration 0.0.0.16 - 2021-02-19
### Changed
- Modified the **VMware.PSDesiredStateConfiguration** module manifest to contain the **FunctionsToExport** to allow using the cmdlets without invoking **Import-Module** every time.

## VMware.vSphereDSC 2.1.0.84 - 2021-02-15
### Changed
- Modified the **VMware.vSphereDSC** and **VMware.PSDesiredStateConfiguration** module manifests to contain the **CompatiblePSEditions** module manifest key with both values: **Desktop** and **Core**.

## VMware.PSDesiredStateConfiguration 0.0.0.15 - 2021-02-15
### Changed
- Modified the **VMware.vSphereDSC** and **VMware.PSDesiredStateConfiguration** module manifests to contain the **CompatiblePSEditions** module manifest key with both values: **Desktop** and **Core**.

## 2021-02-15
### Changed
- Modified the documentation of the **VMware.PSDesiredStateConfiguration** module to reflect the changes made in the **New-VmwDscConfiguration** cmdlet.

## VMware.PSDesiredStateConfiguration 0.0.0.14 - 2021-02-14
### Added
- Added additional **DSC Configurations** with **ConfigurationData** for the **Unit Tests** in the **VMware.PSDesiredStateConfiguration** module.
- Added additional **Unit Tests** for the **ConfigurationName** parameter of the **New-VmwDscConfiguration** cmdlet.

### Changed
- Fixed bug with retrieving dynamic keywords from a **DSC Configuration Script Block**.
- Refactored the **New-VmwDscConfiguration Unit Tests** to work with the new cmdlet parameters.

## VMware.PSDesiredStateConfiguration 0.0.0.13 - 2021-02-14
### Added
- Implemented ordering of public classes when importing the **VMware.PSDesiredStateConfiguration** module.

### Changed
- Extracted all classes in the **VMware.PSDesiredStateConfiguration** module in separate files.
- Extracted all functions in the **VMware.PSDesiredStateConfiguration** module in separate files.

## VMware.PSDesiredStateConfiguration 0.0.0.12 - 2021-02-14
### Added
- Added a new **Path** parameter for the **New-VmwDscConfiguration** cmdlet which specifies a file path to file containing **DSC Configurations**.
- Added a new **ConfigurationName** parameter for the **New-VmwDscConfiguration** cmdlet which specifies the **DSC Configuration** to compile from the specified **DSC Configurations** file.

### Changed
- Renamed the **CustomParams** parameter of the **New-VmwDscConfiguration** cmdlet to **Parameters** which works with script parameters instead of configuration parameters only.

### Removed
- Removed the **ConfigName** parameter from the  **New-VmwDscConfiguration** cmdlet.
- Removed the **ConfigurationData** parameter from the  **New-VmwDscConfiguration** cmdlet.

## VMware.PSDesiredStateConfiguration 0.0.0.11 - 2021-01-25
### Changed
- Extended the validation of the key properties of a **DSC Resource** in the **VMware.PSDesiredStateConfiguration** module to throw an exception when a key property is **$null**.

## VMware.PSDesiredStateConfiguration 0.0.0.10 - 2021-01-25
### Changed
- Modified the **License** logic in the **VMware.PSDesiredStateConfiguration** build to cut the first two lines of the **License** in **License.txt**.
- Moved the **error constants** and the **Get-KeyPropertyResourceCheckDotNetHashCode** function to the **DscItems** file because on **PowerShell 5.1** they're not visible and are missing due to the **DscItems** being imported first.
-  Fixed the **error** and **verbose** output for all cmdlets in the **VMware.PSDesiredStateConfiguration** module.
- Fix **logs** property bug for **PowerShell 5.1** - the **logs** can't be serialized into a **CimInstance**.

### Removed
- Removed unused **ExperimentalEnabled** script.

## VMware.PSDesiredStateConfiguration 0.0.0.9 - 2021-01-23
### Changed
- Fix bug with exceptions not being thrown when an error occurs in a **DSC Resource** when invoking the **DSC Configuration** through the **VMware.PSDesiredStateConfiguration** module.
- Fix bug when connection is not established and the **DisconnectVIServer** method is called.
- Extract exceptions for base classes to constants in **VMware.vSphereDSC** module.

## VMware.vSphereDSC 2.1.0.83 - 2021-01-23
### Changed
- Fix bug with exceptions not being thrown when an error occurs in a **DSC Resource** when invoking the **DSC Configuration** through the **VMware.PSDesiredStateConfiguration** module.
- Fix bug when connection is not established and the **DisconnectVIServer** method is called.
- Extract exceptions for base classes to constants in **VMware.vSphereDSC** module.

## VMware.vSphereDSC 2.1.0.82 - 2021-01-18
### Changed
- Bumped **License.txt**.

## VMware.PSDesiredStateConfiguration 0.0.0.8 - 2021-01-18
### Changed
- Bumped **License.txt**.

## 2021-01-18
### Added
- Added **Getting Started** sections for **VMware.vSphereDSC** and **VMware.PSDesiredStateConfiguration** modules in **README.md**.

## VMware.vSphereDSC 2.1.0.81 - 2021-01-15
### Added
- Added **VMHostIScsiHbaVMKernelNic** DSC Resource.
- Added Unit Tests for **VMHostIScsiHbaVMKernelNic** DSC Resource.
- Added Integration Tests for **VMHostIScsiHbaVMKernelNic** DSC Resource.
- Added Documentation and example Configurations for **VMHostIScsiHbaVMKernelNic** DSC Resource.

## VMware.vSphereDSC 2.1.0.80 - 2021-01-15
### Added
- Added **VMHostStorage** DSC Resource.
- Added Unit Tests for **VMHostStorage** DSC Resource.
- Added Integration Tests for **VMHostStorage** DSC Resource.
- Added Documentation and example Configurations for **VMHostStorage** DSC Resource.

## VMware.vSphereDSC 2.1.0.79 - 2021-01-15
### Added
- Added **VLanId** property of **VDPortGroup DSC Resource**.
- Added Unit Tests for **VLanId** property of **VDPortGroup DSC Resource**.
- Added Integration Tests for **VLanId** property of **VDPortGroup DSC Resource**.
- Added Documentation and example Configuration for **VLanId** property of **VDPortGroup DSC Resource**.

## VMware.vSphereDSC 2.1.0.78 - 2021-01-15
### Changed
- Extended **VMHostVDSwitchMigration DSC Resource** to create distributed port groups with **VLAN ID**.

## VMware.PSDesiredStateConfiguration 0.0.0.7 - 2020-12-18
### Added
- Added integration tests for **VMware.PSDesiredStateConfiguration** module.

## VMware.PSDesiredStateConfiguration 0.0.0.6 - 2020-12-18
### Changed
- Fixed the bug with the same references for **DSC Resources** when multiple **vSphereNodes** are passed as array in a **DSC Configuration**.

## VMware.vSphereDSC 2.1.0.77 - 2020-12-17
### Added
- Added additional logic for **Verbose** and **Warning** outputs which enables printing the output when the **DSC Resource** is invoked via the **Invoke-DscResource** cmdlet.

### Changed
- Fixed the bug with redundant **Server**  DSC key property in the **BasevSphereConnection** class.

## VMware.PSDesiredStateConfiguration 0.0.0.5 - 2020-12-17
### Added
- Added additional logic for **Verbose** and **Warning** outputs which enables printing the output when the **DSC Resource** is invoked via the **Invoke-DscResource** cmdlet.

### Changed
- Fixed the bug with redundant **Server**  DSC key property in the **BasevSphereConnection** class.

## VMware.vSphereDSC 2.1.0.76 - 2020-12-14
### Added
- Added **IScsiName** property of **VMHostIScsiHba DSC Resource**.
- Added Unit Tests for **IScsiName** property of **VMHostIScsiHba DSC Resource**.
- Added Integration Tests for **IScsiName** property of **VMHostIScsiHba DSC Resource**.
- Added Documentation and example Configuration for **IScsiName** property of **VMHostIScsiHba DSC Resource**.

## VMware.vSphereDSC 2.1.0.75 - 2020-12-14
### Changed
- Moved name validation to **VmfsDatastore DSC Resource** due to not being applicable for **NfsDatastores**.

## VMware.vSphereDSC 2.1.0.74 - 2020-12-09
### Changed
- Fixed bugs with physical network adapters when updating the teaming policy of the standard switch.

## VMware.PSDesiredStateConfiguration 0.0.0.4 - 2020-12-07
### Added
- **ConnectionFilter** parameter was added to the **Start, Test and Get-VmwDscConfiguration** cmdlets, which gives the option to choose the **vSphere Nodes** on which the configuration will be executed.

### Changed
- Extend the **New-VmwDscConfiguration** cmdlet to have **Verbose** output.

## VMware.PSDesiredStateConfiguration 0.0.0.3 - 2020-11-30
### Changed
- Extend ***-VmwDscConfiguration** cmdlets vaildation to check for **DSC Resources** with duplicate key properties.

## VMware.PSDesiredStateConfiguration 0.0.0.2 - 2020-11-24
### Added
- Added a special **vSphereNode** dynamic keyword that represents a connection to a **VIServer** and allows reusing **vSphere** connections via the new execution engine.
- Added documentation for new **vSphere Node** feature.

### Changed
- The **DSC Resources** in the **VMware.vSphereDSC** module now have the **Server** and **Credential** properties set as optional as they're not mandatory when using **vSphereNodes**.
- **Test** and **Get-VmwDscConfiguration** cmdlets are extended with additional parameter sets to execute the latest applied configuration.

## VMware.vSphereDSC 2.1.0.73 - 2020-11-24
### Added
- Added a special **vSphereNode** dynamic keyword that represents a connection to a **VIServer** and allows reusing **vSphere** connections via the new execution engine.
- Added documentation for new **vSphere Node** feature.

### Changed
- The **DSC Resources** in the **VMware.vSphereDSC** module now have the **Server** and **Credential** properties set as optional as they're not mandatory when using **vSphereNodes**.
- **Test** and **Get-VmwDscConfiguration** cmdlets are extended with additional parameter sets to execute the latest applied configuration.

## 2020-11-03
### Added
- Added **BuildFlags** enumeration that tracks the steps which need to be performed during the build process.

### Changed
- The build now detects what changes have been made in order to run the tests and build functions only when a module code is changed.

## VMware.PSDesiredStateConfiguration 0.0.0.1 - 2020-10-21
### Added
- Introduced a new module **VMware.PSDesiredStateConfiguration** for compiling and executing DSC Configurations without the use of MOF or LCM.
- Added separate documentation files for both modules (**VMware.PSDesiredStateConfiguration.md** and **VMware.vSphereDSC.md**).
- Added **EnableExperimentalFeature.ps1** to enable **Invoke-DscResource** cmdlet on non-windows Operating Systems.
- Added a documentation file: **Limitations.md** for listing known issues and limitations.

### Changed
- Updated the build procedure in **build.ps1** to now work with both modules (**VMware.PSDesiredStateConfiguration** and **VMware.vSphereDSC**).
- Updated **README.md** with common information and links to the new documentation files for both modules (**VMware.PSDesiredStateConfiguration** and **VMware.vSphereDSC**) .
- **.travis.yml** now works with both **Ubuntu 14.04** and **Ubuntu 18.04** due to **Ubuntu 14.04** not supporting **Powershell Core 7.0.3**.

## VMware.vSphereDSC 2.1.0.72 - 2020-10-13
### Added
- Added new **MigratePhysicalNicsOnly** parameter to **VMHostVDSwitchMigration** DSC Resource.

### Changed
- Fixed the bug with migrating Physical Network Adapters to VDSwitch. The Physical Network Adapters should be migrated with the VMKernel Network Adapters to avoid connectivity loss for the ESXi during the migration.

## VMware.vSphereDSC 2.1.0.71 - 2020-09-24
### Changed
- Fixed the bug with determiting the desired state, when the **ESXi** account password should be changed.

## VMware.vSphereDSC 2.1.0.70 - 2020-09-23
### Changed
- Moved comment section, explaining the dependencies of the **VMware.vSphereDSC** module from **RequiredModules.ps1** to **VMware.vSphereDSC.psd1**.

## VMware.vSphereDSC 2.1.0.69 - 2020-09-18
### Changed
- Changed the implementation of the **New-DscResourceBlock()** in **VMware.vSphereDSC.CompositeResourcesHelper.ps1** to return the created **DscResourceBlock** instead of invoking it inside the function.

## VMware.vSphereDSC 2.1.0.68 - 2020-09-14
### Changed
- Updated **VMware.vSphereDSC** module manifest contents by removing **FunctionsToExport**, **CmdletsToExport** and **AliasesToExport**.

### Removed
- Removed the required **PowerCLI** modules that are dependencies of the **VMware.vSphereDSC** module from RequiredModules.ps1

## VMware.vSphereDSC 2.1.0.67 - 2020-06-19
### Added
- Added **VMHostVdsNic** DSC Resource.
- Added Unit Tests for **VMHostVdsNic** DSC Resource.
- Added Integration Tests for **VMHostVdsNic** DSC Resource.
- Added Documentation and example Configurations for **VMHostVdsNic** DSC Resource.

### Changed
- Extended **InventoryUtil** class with **GetVDSwitch()**.
- Updated the build procedure to install the latest **Pester v4** released version.

## VMware.vSphereDSC 2.1.0.66 - 2020-05-13
### Added
- Added **DatastoreClusterAddDatastore** DSC Resource.
- Added Unit Tests for **DatastoreClusterAddDatastore** DSC Resource.
- Added Integration Tests for **DatastoreClusterAddDatastore** DSC Resource.
- Added Documentation and example Configurations for **DatastoreClusterAddDatastore** DSC Resource.

### Changed
- Extended **InventoryUtil** class with **GetDatastoreCluster()**.

## VMware.vSphereDSC 2.1.0.65 - 2020-05-07
### Added
- Introduced **InventoryUtil** class.
- Added **DRSRule** DSC Resource.
- Added Unit Tests for **DRSRule** DSC Resource.
- Added Integration Tests for **DRSRule** DSC Resource.
- Added Documentation and example Configurations for **DRSRule** DSC Resource.

## VMware.vSphereDSC 2.1.0.64 - 2020-05-07
### Changed
- Extended **BaseDSC** class with helper methods that determine if a DSC Resource is in a _desired state_.
- Refactored the **Test()** method of each DSC Resource in the **VMware.vSphereDSC** module to use the helper methods from the **BaseDSC** class.

## VMware.vSphereDSC 2.1.0.63 - 2020-04-15
### Added
- Added **DatastoreCluster** DSC Resource.
- Added Unit Tests for **DatastoreCluster** DSC Resource.
- Added Integration Tests for **DatastoreCluster** DSC Resource.
- Added Documentation and example Configurations for **DatastoreCluster** DSC Resource.

### Changed
- Extended **TestUtils** with helper function for importing the **VMware.vSphereDSC** module.

## VMware.vSphereDSC 2.1.0.62 - 2020-03-31
### Changed
- Fixed bug with running Unit Tests locally.

## VMware.vSphereDSC 2.1.0.61 - 2020-03-19
### Added
- Added support for specifying which VMHost DSC Resources to export in ExportVMHostConfiguration script.

## VMware.vSphereDSC 2.1.0.60 - 2020-03-19
### Changed
- Fixed bugs with multiple dependencies for StandardSwitch, VMHostDnsSettings and VMHostPermission DSC Resources in ExportVMHostConfiguration script.

## VMware.vSphereDSC 2.1.0.59 - 2020-03-19
### Added
- Added example DSC Configurations for VMHost Authentication, Storage and Network.

## VMware.vSphereDSC 2.1.0.58 - 2020-03-06
### Added
- **NfsDatastore**: DSC Resource that is used to create, update and delete NFS Datastores on the VMHost.
- **NfsUser**: DSC Resource that is used to create, change the password and delete Nfs Users on the VMHost.
- **StandardPortGroup**: Composite DSC Resource that is used to create, update and delete Standard Port Groups which are associated with a Standard Switch. The resource also modifies the different policies of the Standard Port Group - Security, Shaping and Teaming policies.
- **StandardSwitch**: Composite DSC Resource that is used to create, update and delete Standard Switches on the VMHost. The resource also modifies the different policies of the Standard Switch - Security, Shaping and Teaming policies as well as creating a bridge to connect the Standard Switch to Physical Network Adapters.
- **VDPortGroup**: DSC Resource that is used to create, update and delete vSphere Distributed Port Groups.
- **VDSwitch**: DSC Resource that is used to create, update and delete vSphere Distributed Switches.
- **VDSwitchVMHost**: DSC Resource that is used to add/remove VMHosts to/from vSphere Distributed Switches.
- **VMHostAcceptanceLevel**: DSC Resource that is used to modify the acceptance level of the VMHost.
- **VMHostAdvancedSettings**: DSC Resource that is used to modify the Advanced Settings of the VMHost.
- **VMHostAgentVM**: DSC Resource that is used to modify the configuration of Agent Virtual Machine resources on the VMHost.
- **VMHostAuthentication**: DSC Resource that is used to include/exclude VMHosts in/from Domains.
- **VMHostCache**: DSC Resource that is used to configure the host cache/swap performance enhancement.
- **VMHostConfiguration**: DSC Resource that is used to modify the configuration of the VMHost.
- **VMHostDCUIKeyboard**: DSC Resource that is used to modify the Direct Console User Interface Keyboard Layout.
- **VMHostFirewallRuleset**: DSC Resource that is used to enable/disable firewall rulesets on the VMHost.
- **VMHostGraphics**: DSC Resource that is used to modify the Graphics configuration on the VMHost.
- **VMHostGraphicsDevice**: DSC Resource that is used to modify the Graphics Type of the Graphics Device.
- **VMHostIPRoute**: DSC Resource that is used to create and delete IPv4/IPv6 routes on the VMHost.
- **VMHostIScsiHba**: DSC Resource that is used to modify the CHAP settings of the iSCSI Host Bus Adapters on the VMHost.
- **VMHostIScsiHbaTarget**: DSC Resource that is used to create, modify the CHAP settings and delete iSCSI Host Bus Adapter targets from iSCSI Host Bus Adapters.
- **VMHostNetworkCoreDump**: DSC Resource that is used to modify the network coredump configuration of the VMHost.
- **VMHostPciPassthrough**: DSC Resource that is used to modify the PciPassthru configuration of the PCI Device on the VMHost.
- **VMHostPermission**: DSC Resource that is used to create, update and delete Permissions for Entity, Principal and Role on the VMHost.
- **VMHostPhysicalNic**: DSC Resource that is used to modify the speed and duplex settings of the Physical Network Adapter.
- **VMHostPowerPolicy**: DSC Resource that is used to modify the Power Management Policy of the VMHost.
- **VMHostRole**: DSC Resource that is used to create, update and delete Roles on the VMHost.
- **VMHostSNMPAgent**: DSC Resource that is used to modify the SNMP agent configuration on the VMHost.
- **VMHostScsiLun**: DSC Resource that is used to modify the configuration of SCSI Luns on the VMHost.
- **VMHostScsiLunPath**: DSC Resource that is used to configure SCSI Lun paths to SCSI devices on the VMHost.
- **VMHostSharedSwapSpace**: DSC Resource that is used to modify the configuration of system-wide shared swap space on the VMHost.
- **VMHostSoftwareDevice**: DSC Resource that is used to add a device to enable a software device driver or to remove a software device on the VMHost.
- **VMHostVDSwitchMigration**: DSC Resource that is used to migrate Physical Network Adapters and VMKernel Network Adapters attached to Standard Port Groups to vSphere Distributed Switches.
- **VMHostVMKernelActiveDumpFile**: DSC Resource that is used to enable/disable the VMKernel dump file on the VMHost.
- **VMHostVMKernelActiveDumpPartition**: DSC Resource that is used to enable/disable the VMKernel dump partition on the VMHost.
- **VMHostVMKernelDumpFile**: DSC Resource that is used to create and delete VMKernel dump files on a Datastore on the VMHost.
- **VMHostVMKernelModule**: DSC Resource that is used to enable/disable VMKernel modules on the VMHost.
- **VMHostVssMigration**: DSC Resource that is used to migrate Physical Network Adapters and VMKernel Network Adapters attached to Standard Port Groups to Standard Switches.
- **VMHostVssNic**: DSC Resource that is used to create, update and delete VMKernel Network Adapters added to Standard Switch and Standard Port Group.
- **VMHostVssPortGroup**: DSC Resource that is used to create, update and delete Standard Port Groups which are associated with a Standard Switch.
- **VMHostVssPortGroupSecurity**: DSC Resource that is used to modify the Security Policy of the Standard Port Group.
- **VMHostVssPortGroupShaping**: DSC Resource that is used to modify the Shaping Policy of the Standard Port Group.
- **VMHostVssPortGroupTeaming**: DSC Resource that is used to modify the Teaming Policy of the Standard Port Group.
- **VMHostvSANNetworkConfiguration**: DSC Resource that is used to add and remove vSAN network configuration IP Interfaces on the VMHost.
- **VmfsDatastore**: DSC Resource that is used to create, update and delete VMFS Datastores on the VMHost.
- **vCenterVMHost**: DSC Resource that is used to add, move to another location or remove VMHosts on the vCenter Server.

## VMware.vSphereDSC 2.0.0.58 - 2020-03-06
### Added
- Added VMware.VimAutomation.Storage as dependency of VMware.vSphereDSC.

## VMware.vSphereDSC 2.0.0.57 - 2020-03-05
### Added
- Added **VMware.VimAutomation.Vds** as dependency in module manifest.

### Changed
- Updated README.md section for available DSC Resources.
- Fixed bug with Tps setting not exposed in VMHostTpsSettings DSC Resource.

## VMware.vSphereDSC 2.0.0.56 - 2020-02-27
### Added
- Added a script that exports the VMHost state as a DSC Configuration.

### Changed
- Modified DatastoreName and FileName properties of VMHostVMKernelDumpFile to be **Key** instead of **Mandatory**.
- Renamed Datastore property of VMHostCache DSC Resource to DatastoreName.
- Fixed bug with nullable NoTraps property of VMHostSNMPAgent DSC Resource.
- Fixed bug with nullable properties for VMHostSyslog DSC Resource.

## VMware.vSphereDSC 2.0.0.55 - 2020-02-27
### Changed
- Fixed bugs with nullable properties for all Standard Switch DSC Resources.

## VMware.vSphereDSC 2.0.0.54 - 2020-02-14
### Added
- Introduced VMHostRestartBaseDSC class.

### Changed
- Extended VMHostVssNic DSC Resource to perform Update operation after the VMKernel Network Adapter is created, if needed.
- Extracted VMHost restart logic from VMHostBaseDSC class to VMHostRestartBaseDSC class.
- Fixed bug with HAEnabled set to $false when creating or modifying HA Cluster in HACluster DSC Resource.
- Fixed bug for creating Datastores when connected to vCenter Server when there is existing Datastore with the same name.
- Updated License.txt.

## VMware.vSphereDSC 2.0.0.53 - 2020-02-12
### Added
- Introduced VMHostIScsiHbaBaseDSC class.
- Added VMHostIScsiHba DSC Resource.
- Added VMHostIScsiHbaTarget DSC Resource.
- Added Unit Tests for VMHostIScsiHbaBaseDSC class.
- Added Unit Tests for VMHostIScsiHba DSC Resource.
- Added Unit Tests for VMHostIScsiHbaTarget DSC Resource.
- Added Integration Tests for VMHostIScsiHba DSC Resource.
- Added Integration Tests for VMHostIScsiHbaTarget DSC Resource.
- Added Documentation and example Configurations for VMHostIScsiHba DSC Resource.
- Added Documentation and example Configurations for VMHostIScsiHbaTarget DSC Resource.

## VMware.vSphereDSC 2.0.0.52 - 2020-02-12
### Added
- Added StandardSwitch Composite DSC Resource.
- Added Documentation and example Configuration for StandardSwitch Composite DSC Resource.

## VMware.vSphereDSC 2.0.0.51 - 2020-02-12
### Added
- Added VMHostFirewallRuleset DSC Resource.
- Added Unit Tests for VMHostFirewallRuleset DSC Resource.
- Added Integration Tests for VMHostFirewallRuleset DSC Resource.
- Added Documentation and example Configuration for VMHostFirewallRuleset DSC Resource.

## VMware.vSphereDSC 2.0.0.50 - 2020-02-12
### Added
- Added VMHostScsiLun DSC Resource.
- Added Unit Tests for VMHostScsiLun DSC Resource.
- Added Integration Tests for VMHostScsiLun DSC Resource.
- Added Documentation and example Configurations for VMHostScsiLun DSC Resource.

## VMware.vSphereDSC 2.0.0.49 - 2020-02-11
### Added
- Added VMHostScsiLunPath DSC Resource.
- Added Unit Tests for VMHostScsiLunPath DSC Resource.
- Added Integration Tests for VMHostScsiLunPath DSC Resource.
- Added Documentation and example Configuration for VMHostScsiLunPath DSC Resource.

## VMware.vSphereDSC 2.0.0.48 - 2020-02-11
### Added
- Added VMHostvSANNetworkConfiguration DSC Resource.
- Added Unit Tests for VMHostvSANNetworkConfiguration DSC Resource.
- Added Integration Tests for VMHostvSANNetworkConfiguration DSC Resource.
- Added Documentation and example Configurations for VMHostvSANNetworkConfiguration DSC Resource.

## VMware.vSphereDSC 2.0.0.47 - 2020-02-11
### Added
- Added VMHostAcceptanceLevel DSC Resource.
- Added Unit Tests for VMHostAcceptanceLevel DSC Resource.
- Added Integration Tests for VMHostAcceptanceLevel DSC Resource.
- Added Documentation and example Configuration for VMHostAcceptanceLevel DSC Resource.

## VMware.vSphereDSC 2.0.0.46 - 2020-02-11
### Added
- Added VMHostNetworkCoreDump DSC Resource.
- Added Unit Tests for VMHostNetworkCoreDump DSC Resource.
- Added Integration Tests for VMHostNetworkCoreDump DSC Resource.
- Added Documentation and example Configuration for VMHostNetworkCoreDump DSC Resource.

## VMware.vSphereDSC 2.0.0.45 - 2020-02-11
### Added
- Added VMHostVMKernelModule DSC Resource.
- Added VMHostSNMPAgent DSC Resource.
- Added VMHostSoftwareDevice DSC Resource.
- Added VMHostSharedSwapSpace DSC Resource.
- Added Unit Tests for VMHostVMKernelModule DSC Resource.
- Added Unit Tests for VMHostSNMPAgent DSC Resource.
- Added Unit Tests for VMHostSoftwareDevice DSC Resource.
- Added Unit Tests for VMHostSharedSwapSpace DSC Resource.
- Added Integration Tests for VMHostVMKernelModule DSC Resource.
- Added Integration Tests for VMHostSNMPAgent DSC Resource.
- Added Integration Tests for VMHostSoftwareDevice DSC Resource.
- Added Integration Tests for VMHostSharedSwapSpace DSC Resource.
- Added Documentation and example Configuration for VMHostVMKernelModule DSC Resource.
- Added Documentation and example Configurations for VMHostSNMPAgent DSC Resource.
- Added Documentation and example Configurations for VMHostSoftwareDevice DSC Resource.
- Added Documentation and example Configuration for VMHostSharedSwapSpace DSC Resource.

## VMware.vSphereDSC 2.0.0.44 - 2020-02-11
### Added
- Added VMHostVMKernelActiveDumpPartition DSC Resource.
- Added VMHostVMKernelDumpFile DSC Resource.
- Added VMHostVMKernelActiveDumpFile DSC Resource.
- Added Unit Tests for VMHostVMKernelActiveDumpPartition DSC Resource.
- Added Unit Tests for VMHostVMKernelDumpFile DSC Resource.
- Added Unit Tests for VMHostVMKernelActiveDumpFile DSC Resource.
- Added Integration Tests for VMHostVMKernelActiveDumpPartition DSC Resource.
- Added Integration Tests for VMHostVMKernelDumpFile DSC Resource.
- Added Integration Tests for VMHostVMKernelActiveDumpFile DSC Resource.
- Added Documentation and example Configuration for VMHostVMKernelActiveDumpPartition DSC Resource.
- Added Documentation and example Configurations for VMHostVMKernelDumpFile DSC Resource.
- Added Documentation and example Configuration for VMHostVMKernelActiveDumpFile DSC Resource.

### Changed
- Extended ExecuteEsxCliModifyMethod() with support for method arguments.

### Removed
- Removed NoPersist property from VMHostDCUIKeyboard DSC Resource.

## VMware.vSphereDSC 2.0.0.43 - 2020-02-11
### Added
- Added VMHostIPRoute DSC Resource.
- Added Unit Tests for VMHostIPRoute DSC Resource.
- Added Integration Tests for VMHostIPRoute DSC Resource.
- Added Documentation and example Configurations for VMHostIPRoute DSC Resource.

## VMware.vSphereDSC 2.0.0.42 - 2020-01-09
### Added
- Added VMHostDCUIKeyboard DSC Resource.
- Added Unit Tests for VMHostDCUIKeyboard DSC Resource.
- Added Integration Tests for VMHostDCUIKeyboard DSC Resource.
- Added Documentation and example Configuration for VMHostDCUIKeyboard DSC Resource.

## VMware.vSphereDSC 2.0.0.41 - 2020-01-08
### Added
- Introduced EsxCliBaseDSC class.
- Added Unit Tests for EsxCliBaseDSC class.

## VMware.vSphereDSC 2.0.0.40 - 2020-01-08
### Added
- Added VMHostConfiguration DSC Resource.
- Added Unit Tests for VMHostConfiguration DSC Resource.
- Added Integration Tests for VMHostConfiguration DSC Resource.
- Added Documentation and example Configurations for VMHostConfiguration DSC Resource.

## VMware.vSphereDSC 2.0.0.39 - 2020-01-08
### Added
- Added vCenterVMHost DSC Resource.
- Added Unit Tests for vCenterVMHost DSC Resource.
- Added Integration Tests for vCenterVMHost DSC Resource.
- Added Documentation and example Configurations for vCenterVMHost DSC Resource.

## VMware.vSphereDSC 2.0.0.38 - 2020-01-08
### Added
- Added NfsUser DSC Resource.
- Added Unit Tests for NfsUser DSC Resource.
- Added Integration Tests for NfsUser DSC Resource.
- Added Documentation and example Configurations for NfsUser DSC Resource.

## VMware.vSphereDSC 2.0.0.37 - 2019-12-05
### Added
- Introduced DatastoreBaseDSC class.
- Added VmfsDatastore and NfsDatastore DSC Resources.
- Added Unit Tests for DatastoreBaseDSC class, VmfsDatastore and NfsDatastore DSC Resources.
- Added Integration Tests for VmfsDatastore and NfsDatastore DSC Resources.
- Added Documentation and example Configurations for VmfsDatastore and NfsDatastore DSC Resources.

## VMware.vSphereDSC 2.0.0.36 - 2019-12-05
### Added
- Added VMHostPermission DSC Resource.
- Added Unit Tests for VMHostPermission DSC Resource.
- Added Integration Tests for VMHostPermission DSC Resource.
- Added Documentation and example Configurations for VMHostPermission DSC Resource.

## VMware.vSphereDSC 2.0.0.35 - 2019-12-04
### Added
- Added VMHostRole DSC Resource.
- Added Unit Tests for VMHostRole DSC Resource.
- Added Integration Tests for VMHostRole DSC Resource.
- Added Documentation and example Configurations for VMHostRole DSC Resource.

### Changed
- Moved EnsureConnectionIsESXi method from VMHostAccount DSC Resource to BaseDSC class and added WriteDscResourceState method to BaseDSC class.

## VMware.vSphereDSC 2.0.0.34 - 2019-11-15
### Added
- Introduced VMHostNetworkMigrationBaseDSC class.
- Added VMHostVssMigration DSC Resource.
- Added Unit Tests for VMHostVssMigration DSC Resource.
- Added Integration Tests for VMHostVssMigration DSC Resource.
- Added Documentation and example Configurations for VMHostVssMigration DSC Resource.

### Changed
- Modified Get() method of VMHostVDSwitchMigration DSC Resource to retrieve only the passed VMKernel Network Adapters connected to the VDSwitch.

### Removed
- Removed filtration of Physical Network Adapters in VMHostVDSwitchMigration DSC Resource.

## VMware.vSphereDSC 2.0.0.33 - 2019-11-15
### Added
- Added VMHostAuthentication DSC Resource.
- Added Unit Tests for VMHostAuthentication DSC Resource.
- Added Integration Tests for VMHostAuthentication DSC Resource.
- Added Documentation and example Configurations for VMHostAuthentication DSC Resource.

## VMware.vSphereDSC 2.0.0.32 - 2019-11-15
### Added
- Added VMware.vSphereDSC.CompositeResourcesHelper script with utility functions for Composite DSC Resources.
- Added StandardPortGroup Composite DSC Resource.
- Added Documentation and example Configuration for StandardPortGroup Composite DSC Resource.

### Changed
- Refactored Cluster Composite DSC Resource to use the utility functions from VMware.vSphereDSC.CompositeResourcesHelper script.
- Rename MakeNicActive, MakeNicStandby and MakeNicUnused properties of VMHostVssPortGroupTeaming DSC Resource to ActiveNic, StandbyNic and UnusedNic.

## VMware.vSphereDSC 2.0.0.31 - 2019-11-15
### Added
- Added VMHostVDSwitchMigration DSC Resource.
- Added Unit Tests for VMHostVDSwitchMigration DSC Resource.
- Added Integration Tests for VMHostVDSwitchMigration DSC Resource.
- Added Documentation and example Configurations for VMHostVDSwitchMigration DSC Resource.

### Changed
- Modified description of properties in VMHostVssNic DSC Resource Documentation.

## VMware.vSphereDSC 2.0.0.30 - 2019-10-30
### Added
- Added VDSwitchVMHost DSC Resource.
- Added Unit Tests for VDSwitchVMHost DSC Resource.
- Added Integration Tests for VDSwitchVMHost DSC Resource.
- Added Documentation and example Configuration for VDSwitchVMHost DSC Resource.

## VMware.vSphereDSC 2.0.0.29 - 2019-10-30
### Added
- Added VDPortGroup DSC Resource.
- Added Unit Tests for VDPortGroup DSC Resource.
- Added Integration Tests for VDPortGroup DSC Resource.
- Added Documentation and example Configurations for VDPortGroup DSC Resource.

### Changed
- Changed ReferenceVDSwitch property of VDSwitch DSC Resource to ReferenceVDSwitchName.

## VMware.vSphereDSC 2.0.0.28 - 2019-10-21
### Changed
- Changed **DefaultRotateSize** to **DefaultSize** in VMHostSyslog DSC Resource Documentation.

## VMware.vSphereDSC 2.0.0.27 - 2019-10-21
### Changed
- Fixed spacing around **Description** in all DSC Resources Documentation.

## VMware.vSphereDSC 2.0.0.26 - 2019-10-18
### Added
- Added Tips & Tricks page from Wiki to Documentation.

### Changed
- Extend README.md with how to install VMware.vSphereDSC Module from PowerShell Gallery.

## VMware.vSphereDSC 2.0.0.25 - 2019-10-09
### Added
- Added DisconnectVIServer logic in BaseDSC class.
- Added Unit Tests for DisconnectVIServer() in BaseDSC class.

### Changed
- Refactored all existing DSC Resources to use DisconnectVIServer() from BaseDSC.
- Updated CODING_GUIDELINES section for creating new DSC Resources.

## VMware.vSphereDSC 2.0.0.24 - 2019-10-02
### Added
- Added VDSwitch DSC Resource.
- Added Unit Tests for VDSwitch DSC Resource.
- Added Integration Tests for VDSwitch DSC Resource.
- Added Documentation and example Configuration for VDSwitch DSC Resource.

## VMware.vSphereDSC 2.0.0.23 - 2019-10-01
### Added
- Added Unit Tests for BaseDSC class.
- Added VMHostNicBaseDSC class.
- Added Unit Tests for VMHostNicBaseDSC class.
- Added VMHostVssNic DSC Resource.
- Added Unit Tests for VMHostVssNic DSC Resource.
- Added Integration Tests for VMHostVssNic DSC Resource.
- Added Documentation and example Configuration for VMHostVssNic DSC Resource.

### Changed
- Extended BaseDSC class with ShouldUpdateArrayProperty method.

## VMware.vSphereDSC 2.0.0.22 - 2019-10-01
### Added
- Added VMHostPhysicalNic DSC Resource.
- Added Unit Tests for VMHostPhysicalNic DSC Resource.
- Added Integration Tests for VMHostPhysicalNic DSC Resource.
- Added Documentation and example Configuration for VMHostPhysicalNic DSC Resource.

## VMware.vSphereDSC 2.0.0.21 - 2019-10-01
### Added
- Added VMHostVssPortGroupShaping DSC Resource.
- Added Unit Tests for VMHostVssPortGroupShaping DSC Resource.
- Added Integration Tests for VMHostVssPortGroupShaping DSC Resource.
- Added Documentation and example Configuration for VMHostVssPortGroupShaping DSC Resource.

## VMware.vSphereDSC 2.0.0.20 - 2019-10-01
### Added
- Added VMHostVssPortGroupTeaming DSC Resource.
- Added Unit Tests for VMHostVssPortGroupTeaming DSC Resource.
- Added Integration Tests for VMHostVssPortGroupTeaming DSC Resource.
- Added Documentation and example Configuration for VMHostVssPortGroupTeaming DSC Resource.

## VMware.vSphereDSC 2.0.0.19 - 2019-10-01
### Added
- Added VMHostVssPortGroupBaseDSC class.
- Added VMHostVssPortGroupSecurity DSC Resource.
- Added Unit Tests for VMHostVssPortGroupSecurity DSC Resource.
- Added Integration Tests for VMHostVssPortGroupSecurity DSC Resource.
- Added Documentation and example Configuration for VMHostVssPortGroupSecurity DSC Resource.

## VMware.vSphereDSC 2.0.0.18 - 2019-09-30
### Added
- Added VMHostEntityBaseDSC class.
- Added VMHostVssPortGroup DSC Resource.
- Added Unit Tests for VMHostVssPortGroup DSC Resource.
- Added Integration Tests for VMHostVssPortGroup DSC Resource.
- Added Documentation and example Configuration for VMHostVssPortGroup DSC Resource.

## VMware.vSphereDSC 2.0.0.17 - 2019-09-03
### Added
- VMware.vSphereDSC.Logging module is introduced.
- Added Write-VerboseLog and Write-WarningLog functions to Logging module.

### Changed
- Changed logging mechanism from Write-Verbose to Write-VerboseLog and Write-Warning to Write-WarningLog.

## VMware.vSphereDSC 2.0.0.16 - 2019-09-03
### Added
- Added VMHostCache DSC Resource.
- Added Unit Tests for VMHostCache DSC Resource.
- Added Integration Tests for VMHostCache DSC Resource.
- Added Documentation and example Configuration for VMHostCache DSC Resource.
- Added missing TaskImpl type to PowerCLITypes.

## VMware.vSphereDSC 2.0.0.15 - 2019-08-30
### Added
- Added VMHostPowerPolicy DSC Resource.
- Added Unit Tests for VMHostPowerPolicy DSC Resource.
- Added Integration Tests for VMHostPowerPolicy DSC Resource.
- Added Documentation and example Configuration for VMHostPowerPolicy DSC Resource.

## VMware.vSphereDSC 2.0.0.14 - 2019-08-30
### Added
- Added VMHostGraphics DSC Resource.
- Added Unit Tests for VMHostGraphics DSC Resource.
- Added Integration Tests for VMHostGraphics DSC Resource.
- Added Documentation and example Configuration for VMHostGraphics DSC Resource.
- Added VMHostGraphicsDevice DSC Resource.
- Added Unit Tests for VMHostGraphicsDevice DSC Resource.
- Added Integration Tests for VMHostGraphicsDevice DSC Resource.
- Added Documentation and example Configuration for VMHostGraphicsDevice DSC Resource.

## VMware.vSphereDSC 2.0.0.13 - 2019-08-30
### Added
- Added VMHostPciPassthrough DSC Resource.
- Added Unit Tests for VMHostPciPassthrough DSC Resource.
- Added Integration Tests for VMHostPciPassthrough DSC Resource.
- Added Documentation and example Configuration for VMHostPciPassthrough DSC Resource.

### Changed
- Extended VMHostBaseDSC with method for restarting the specified VMHost.
- Introduced RestartTimeoutMinutes optional parameter for VMHostBaseDSC.

## VMware.vSphereDSC 2.0.0.12 - 2019-08-28
### Changed
- The Id property was changed from 'Mandatory' to 'Key' for VMHostAccount Resource.

## VMware.vSphereDSC 2.0.0.11 - 2019-08-28
### Changed
- The RuleName property was changed from 'Mandatory' to 'Key' for VMHostSatpClaimRule Resource.

## VMware.vSphereDSC 2.0.0.10 - 2019-08-28
### Changed
- The Key property was changed from 'Mandatory' to 'Key' for VMHostService Resource.

## VMware.vSphereDSC 2.0.0.9 - 2019-08-28
### Changed
- The VssName property was changed from 'Mandatory' to 'Key' in the Standard Switch Resources Documentation.

## VMware.vSphereDSC 2.0.0.8 - 2019-08-20
### Added
- Added VMHostAgentVM DSC Resource.
- Added Unit Tests for VMHostAgentVM DSC Resource.
- Added Integration Tests for VMHostAgentVM DSC Resource.
- Added Documentation and example Configuration for VMHostAgentVM DSC Resource.

### Changed
- Moved vCenterProductId Constant to BaseDSC class.

## VMware.vSphereDSC 2.0.0.7 - 2019-08-02
### Changed
- Fix bug with '?' character in Build.ps1.

## VMware.vSphereDSC 2.0.0.6 - 2019-08-02
### Added
- Added VMHostAdvancedSettings DSC Resource.
- Added Unit Tests for VMHostAdvancedSettings DSC Resource.
- Added Integration Tests for VMHostAdvancedSettings DSC Resource.
- Added Documentation and example Configuration for VMHostAdvancedSettings DSC Resource.

## VMware.vSphereDSC 2.0.0.5 - 2019-08-02
### Added
- Added CHANGELOG.md document to the repository.
- Added CHANGELOG_TEMPLATE.md document to the repository.

### Changed
- Updated the Pull Request description section in CONTRIBUTING.md.
- Extended the build to update the content of the CHANGELOG.md with the Pull Request description.

### Removed
- Removed the 'dev' branch from .travis.yml.

## VMware.vSphereDSC 2.0.0.4 - 2019-07-19
### Added
- Added VMHostSyslog example in Configurations.
- Introduced TestSetup for VMHostSyslog Integration Tests.

## VMware.vSphereDSC 2.0.0.3 - 2019-07-19
### Changed
- Updated documentation for Unit and Integration Tests.

## VMware.vSphereDSC 2.0.0.2 - 2019-06-14
### Added
- Example Configuration File with the Inventory Resources: **DatacenterFolder**, **Datacenter**, **Folder**, **Cluster**.
- Example Configuration File with the VSS Resources: **VMHostVss**, **VMHostVssSecurity**, **VMHostVssShaping**, **VMHostVssBridge**, **VMHostVssTeaming**.
- Introduced Integration Tests Constants for Inventory Tests.
- Added more Integration Tests when removing DatacenterFolder.
- Introduced TestSetup for VMHostVssBridge Integration Tests.
- Introduced TestSetup for VMHostVssTeaming Integration Tests.

## Changed
- In the vCenter example Configuration File, **Cluster** Composite Resource was substituted with **HACluster** and **DrsCluster** Resources.
- Extended Configurations of Folder Integration Tests with DatacenterFolder and Datacenter Resources.
- Extended Configurations of Datacenter Integration Tests with DatacenterFolder Resource.
- Extended Configurations of HACluster Integration Tests with DatacenterFolder, Datacenter and Folder Resources.
- Extended Configurations of DrsCluster Integration Tests with DatacenterFolder, Datacenter and Folder Resources.
- Extended Configurations for VMHostVss Resources.

## VMware.vSphereDSC 2.0.0.1 - 2019-06-07
### Changed
- Bump module version to 2.0.0.0.

## VMware.vSphereDSC 2.0.0.0 - 2019-06-07
### Added
- **Cluster**: Composite Resource used to create, update and delete Clusters in a specified Datacenter. The resource also takes care to configure Cluster's High Availability (HA) and Drs settings.
- **HACluster**: Used to create, update and delete Clusters in a specified Datacenter. The resource also takes care to configure Cluster's High Availability (HA) settings.
- **DrsCluster**: Used to create, update and delete Clusters in a specified Datacenter. The resource also takes care to configure Cluster's Drs settings.
- **DatacenterFolder**: Used to create and delete Folders in a specified Inventory.
- **Datacenter**: Used to create and delete Datacenters in a specified Inventory.
- **Folder**: Used to create and delete Folders in a specified Datacenter.
- **PowerCLISettings**: Used to Update the PowerCLI Configuration settings of the LCM. User Scope PowerCLI Configuration settings are updated with this resource. The LCM runs with Windows System account, so the settings will be stored for the user that runs LCM PowerShell. If a user runs a Configuration with this resource, the settings will be preserved for all future Configurations that run on that LCM.
- **VMHostAccount**: Used to create, update and delete VMHost Accounts in the specified VMHost we are connected to.
- **VMHostService**: Used to configure the host services on an ESXi host.
- **VMHostSettings**: Used to Update Motd Setting and Issue Setting of the passed ESXi host.
- **VMHostSyslog**: Used to configure the syslog settings on an ESXi node.
- **VMHostVss**: Used to configure the basic properties of a Virtual Switch (VSS) on an ESXi node.
- **VMHostVssBridge**: A bridge connecting a virtual switch (VSS) to (a) physical network adapter(s).
- **VMHostVssSecurity**: Used to configure the security policy governing ports of a Virtual Switch (VSS).
- **VMHostVssShaping**: Used to configure the traffic shaping policy for ports of a Virtual Switch (VSS).
- **VMHostVssTeaming**: Used to configure the network adapter teaming policy of a Virtual Switch (VSS).

### Changed
- **vCenterSettings**: Extended to configure Motd and Issue Advanced Settings as well.
