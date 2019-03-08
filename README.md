

# Desired State Configuration Resources for VMware

## Overview

The **VMware.vSphereDSC** module is a collection of DSC Resources. This module includes DSC resources that simplify the management of vCenter and ESXi settings, with a simple declarative language.

The **VMware.vSphereDSC** module contains resources which are configuring:

- **NTP**, **DNS**, **TPS** and **Syslog** settings of VMHosts.
- **Motd** and **Issue** Advanced Settings of VMHosts.
- **Host services** of VMHosts.
- **SATP Claim Rules** of VMHosts.
- **Statistics** and **Advanced Settings** of vCenters.

For more information about all available **Resources**, please visit the **wiki** page of the repository: [Wiki](https://github.com/vmware/dscr-for-vmware/wiki).

## Getting Started
## Requirements
**VMware.vSphereDSC** module contains Windows PowerShell Desired State Configuration Resources.
The following table describes the required dependencies for running VMware.vSphereDSC Resources.

 **Required dependency**   | **Minimum version**
-------------------------- | -------------------
`PowerShell`               | 5.1 (PS Core not supported)
`PowerCLI`                 | 10.1.1

For information on how to install PowerShell, please visit [Installing Windows PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/setup/installing-windows-powershell?view=powershell-5.1).

For information on how to install PowerCLI, please visit the [PowerCLI Blog](https://blogs.vmware.com/PowerCLI/2018/02/powercli-10.html).

You also need to configure the DSC LCM on a Windows machine where the resources will run. For more information on how to configure it, please visit [Desired State Configuration Quick Start](https://docs.microsoft.com/en-us/powershell/dsc/quickstart)

## Installing the VMware.vSphereDSC Resources

1. Copy the VMware.vSphereDSC Module to one of the system PowerShell module directories.For more information on installing PowerShell Modules, please visit [Installing a PowerShell Module](https://docs.microsoft.com/en-us/powershell/developer/module/installing-a-powershell-module#rules-for-installing-modules).
2. In PowerShell import the VMware.vSphereDSC Module:
   ```
    Import-Module -Name 'VMware.vSphereDSC'
   ```

   To check if the module was successfully installed:
   ```
    Get-DscResource -Module 'VMware.vSphereDSC'
   ```

## Applying VMware.vSphereDSC Resource Configuration
# Configuring PowerCLI
To configure PowerCLI you can use the **PowerCLISettings DSC Resource** and specify which settings you want to be configured. For more information on the available settings, please visit the wiki page of the [PowerCLISettings DSC Resource](https://github.com/vmware/dscr-for-vmware/wiki/PowerCLISettings).

# Example
The following example uses [VMHostNtpSettings Resource](https://github.com/vmware/dscr-for-vmware/wiki/VMHostNtpSettings) and configures the NTP Server and the 'ntpd' Service Policy.

1. You need to compile the [Configuration File](https://github.com/vmware/dscr-for-vmware/blob/master/Source/VMware.vSphereDSC/Configurations/ESXiConfigs/VMHostNtpSettings_Config.ps1) to [MOF](https://docs.microsoft.com/en-us/windows/desktop/wmisdk/managed-object-format--mof-):
   ```
    $ntpConfigPath = Join-Path (Join-Path (Join-Path (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase 'Configurations') 'ESXiConfigs')'VMHostNtpSettings_Config.ps1'
    . $ntpConfigPath -Name '<VMHost Name>' -Server 'Server Name>' -User '<User Name>' -Password '<Password for User>'
   ```
2. To Test if the NTP Settings are in the desired state:
   ```
    Test-DscConfiguration -ComputerName <The name of the machine on which you are applying your configuration> -Path .\VMHostNtpSettings_Config\
   ```
3. To Apply the NTP Configuration:
   ```
    Start-DscConfiguration -ComputerName <The name of the machine on which you are applying your configuration> -Path .\VMHostNtpSettings_Config\ -Wait -Force
   ```
4. To get the latest applied configuration on your machine:
   ```
    Get-DscConfiguration
   ```

If you want to apply other configurations, you just need to compile the configuration file and pass the path of the created MOF file to the DSC cmdlets.

For more information about the DSC cmdlets please visit the [PSDesiredStateConfiguration](https://docs.microsoft.com/en-us/powershell/module/psdesiredstateconfiguration/?view=powershell-5.1).

## Documentation and Examples

For a full list of resources in VMware.vSphereDSC and examples on their use, check out
the [Desired State Configuration Resources for VMware wiki](https://github.com/vmware/dscr-for-vmware/wiki).

## Branches

### master

[![Build Status](https://travis-ci.org/vmware/dscr-for-vmware.svg?branch=master)](https://travis-ci.org/vmware/dscr-for-vmware)
![Coverage](https://img.shields.io/badge/coverage-94%25-brightgreen.svg?maxAge=60)

This is the branch to which contributions should be proposed by contributors as pull requests. The content of the module releases will be from the master branch.

## Contributing

The Desired State Configuration Resources for VMware project team welcomes contributions from the community. For more detailed information, refer to [CONTRIBUTING.md](CONTRIBUTING.md).

## License
The Desired State Configuration Resources for VMware is distributed under the [BSD-2](https://github.com/vmware/dscr-for-vmware/blob/master/LICENSE.txt).

For more details, please refer to the [BSD-2 License File](https://github.com/vmware/dscr-for-vmware/blob/master/LICENSE.txt).
