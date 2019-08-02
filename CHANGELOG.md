# Changelog
All notable changes to this project will be documented in this file.

## 2.0.0.5 - 2019-08-02
Fix bug with '?' character in Build.ps1
## 2.0.0.4 - 2019-07-19
### Added
- Added VMHostSyslog example in Configurations.
- Introduced TestSetup for VMHostSyslog Integration Tests.

## 2.0.0.3 - 2019-07-19
### Changed
- Updated documentation for Unit and Integration Tests.

## 2.0.0.2 - 2019-06-14
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

## 2.0.0.1 - 2019-06-07
### Changed
- Bump module version to 2.0.0.0.

## 2.0.0.0 - 2019-06-07
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
