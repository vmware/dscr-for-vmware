# Changelog
All notable changes to this project will be documented in this file.

## 2.0.0.29 - 2019-10-30
### Added
- Added VDPortGroup DSC Resource.
- Added Unit Tests for VDPortGroup DSC Resource.
- Added Integration Tests for VDPortGroup DSC Resource.
- Added Documentation and example Configurations for VDPortGroup DSC Resource.

### Changed
- Changed ReferenceVDSwitch property of VDSwitch DSC Resource to ReferenceVDSwitchName.

## 2.0.0.28 - 2019-10-21
### Changed
- Changed **DefaultRotateSize** to **DefaultSize** in VMHostSyslog DSC Resource Documentation.

## 2.0.0.27 - 2019-10-21
### Changed
- Fixed spacing around **Description** in all DSC Resources Documentation.

## 2.0.0.26 - 2019-10-18
### Added
- Added Tips & Tricks page from Wiki to Documentation.

### Changed
- Extend README.md with how to install VMware.vSphereDSC Module from PowerShell Gallery.

## 2.0.0.25 - 2019-10-09
### Added
- Added DisconnectVIServer logic in BaseDSC class.
- Added Unit Tests for DisconnectVIServer() in BaseDSC class.

### Changed
- Refactored all existing DSC Resources to use DisconnectVIServer() from BaseDSC.
-  Updated CODING_GUIDELINES section for creating new DSC Resources.

## 2.0.0.24 - 2019-10-02
### Added
- Added VDSwitch DSC Resource.
- Added Unit Tests for VDSwitch DSC Resource.
- Added Integration Tests for VDSwitch DSC Resource.
- Added Documentation and example Configuration for VDSwitch DSC Resource.

## 2.0.0.23 - 2019-10-01
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

## 2.0.0.22 - 2019-10-01
### Added
- Added VMHostPhysicalNic DSC Resource.
- Added Unit Tests for VMHostPhysicalNic DSC Resource.
- Added Integration Tests for VMHostPhysicalNic DSC Resource.
- Added Documentation and example Configuration for VMHostPhysicalNic DSC Resource.

## 2.0.0.21 - 2019-10-01
### Added
- Added VMHostVssPortGroupShaping DSC Resource.
- Added Unit Tests for VMHostVssPortGroupShaping DSC Resource.
- Added Integration Tests for VMHostVssPortGroupShaping DSC Resource.
- Added Documentation and example Configuration for VMHostVssPortGroupShaping DSC Resource.

## 2.0.0.20 - 2019-10-01
### Added
- Added VMHostVssPortGroupTeaming DSC Resource.
- Added Unit Tests for VMHostVssPortGroupTeaming DSC Resource.
- Added Integration Tests for VMHostVssPortGroupTeaming DSC Resource.
- Added Documentation and example Configuration for VMHostVssPortGroupTeaming DSC Resource.

## 2.0.0.19 - 2019-10-01
### Added
- Added VMHostVssPortGroupBaseDSC class.
- Added VMHostVssPortGroupSecurity DSC Resource.
- Added Unit Tests for VMHostVssPortGroupSecurity DSC Resource.
- Added Integration Tests for VMHostVssPortGroupSecurity DSC Resource.
- Added Documentation and example Configuration for VMHostVssPortGroupSecurity DSC Resource.

## 2.0.0.18 - 2019-09-30
### Added
- Added VMHostEntityBaseDSC class.
- Added VMHostVssPortGroup DSC Resource.
- Added Unit Tests for VMHostVssPortGroup DSC Resource.
- Added Integration Tests for VMHostVssPortGroup DSC Resource.
- Added Documentation and example Configuration for VMHostVssPortGroup DSC Resource.

## 2.0.0.17 - 2019-09-03
### Added
- VMware.vSphereDSC.Logging module is introduced.
- Added Write-VerboseLog and Write-WarningLog functions to Logging module.

### Changed
- Changed logging mechanism from Write-Verbose to Write-VerboseLog and Write-Warning to Write-WarningLog.
 
## 2.0.0.16 - 2019-09-03
### Added
- Added VMHostCache DSC Resource.
- Added Unit Tests for VMHostCache DSC Resource.
- Added Integration Tests for VMHostCache DSC Resource.
- Added Documentation and example Configuration for VMHostCache DSC Resource.
- Added missing TaskImpl type to PowerCLITypes.

## 2.0.0.15 - 2019-08-30
### Added
- Added VMHostPowerPolicy DSC Resource.
- Added Unit Tests for VMHostPowerPolicy DSC Resource.
- Added Integration Tests for VMHostPowerPolicy DSC Resource.
- Added Documentation and example Configuration for VMHostPowerPolicy DSC Resource.

## 2.0.0.14 - 2019-08-30
### Added
- Added VMHostGraphics DSC Resource.
- Added Unit Tests for VMHostGraphics DSC Resource.
- Added Integration Tests for VMHostGraphics DSC Resource.
- Added Documentation and example Configuration for VMHostGraphics DSC Resource.
- Added VMHostGraphicsDevice DSC Resource.
- Added Unit Tests for VMHostGraphicsDevice DSC Resource.
- Added Integration Tests for VMHostGraphicsDevice DSC Resource.
- Added Documentation and example Configuration for VMHostGraphicsDevice DSC Resource.

## 2.0.0.13 - 2019-08-30
### Added
- Added VMHostPciPassthrough DSC Resource.
- Added Unit Tests for VMHostPciPassthrough DSC Resource.
- Added Integration Tests for VMHostPciPassthrough DSC Resource.
- Added Documentation and example Configuration for VMHostPciPassthrough DSC Resource.

### Changed
- Extended VMHostBaseDSC with method for restarting the specified VMHost.
- Introduced RestartTimeoutMinutes optional parameter for VMHostBaseDSC.

## 2.0.0.12 - 2019-08-28
### Changed
- The Id property was changed from 'Mandatory' to 'Key' for VMHostAccount Resource.

## 2.0.0.11 - 2019-08-28
### Changed
- The RuleName property was changed from 'Mandatory' to 'Key' for VMHostSatpClaimRule Resource.

## 2.0.0.10 - 2019-08-28
### Changed
- The Key property was changed from 'Mandatory' to 'Key' for VMHostService Resource.

## 2.0.0.9 - 2019-08-28
### Changed
- The VssName property was changed from 'Mandatory' to 'Key' in the Standard Switch Resources Documentation.

## 2.0.0.8 - 2019-08-20
### Added
- Added VMHostAgentVM DSC Resource.
- Added Unit Tests for VMHostAgentVM DSC Resource.
- Added Integration Tests for VMHostAgentVM DSC Resource.
- Added Documentation and example Configuration for VMHostAgentVM DSC Resource.

### Changed
- Moved vCenterProductId Constant to BaseDSC class.

## 2.0.0.7 - 2019-08-02
### Changed
- Fix bug with '?' character in Build.ps1.

## 2.0.0.6 - 2019-08-02
### Added
- Added VMHostAdvancedSettings DSC Resource.
- Added Unit Tests for VMHostAdvancedSettings DSC Resource.
- Added Integration Tests for VMHostAdvancedSettings DSC Resource.
- Added Documentation and example Configuration for VMHostAdvancedSettings DSC Resource.

## 2.0.0.5 - 2019-08-02
### Added
- Added CHANGELOG.md document to the repository.
- Added CHANGELOG_TEMPLATE.md document to the repository.

### Changed
- Updated the Pull Request description section in CONTRIBUTING.md.
- Extended the build to update the content of the CHANGELOG.md with the Pull Request description.

### Removed
- Removed the 'dev' branch from .travis.yml.

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
