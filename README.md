

# dscr-for-vmware

## Overview

The project contains Windows PowerShell Desired State Configuration (DSC) Resources for managing VC and ESXi settings. DSC is a management platform in PowerShell that enables managing infrastructure configuration as code. It is a declarative platform used for configuration, deployment and management of systems. The purpose of the project is to allow users to configure VC and ESXi in a declarative fashion. Configuration management software like Chef and Puppet are able to run DSC resources. Applying a configuration makes vCenter or ESXi in the desired by the user state.

## Getting Started

### Prerequisites

* Install PowerCLI
  ```
   Install-Module -Name VMware.PowerCLI -Scope CurrentUser
  ```
* Configure LCM
  ```
   winrm quickconfig
  ```
* Install Pester
  ```
   Install-Module -Name Pester
  ```

### Accessing the Repository
#### Downloading the Repository for Local Access
1. Load the GitHub repository page: <https://github.com/vmware/dscr-for-vmware>
2. Click on the green “Clone or Download” button and then click “Download ZIP”  
3. Once downloaded, extract the zip file to the location of your choosing  
4. At this point, you now have a local copy of the repository

#### Creating Your Own GitHub Based Access Point
1. Login (or signup) to GitHub
2. Load the GitHub repository page: <https://github.com/vmware/dscr-for-vmware>
3. Click on the Fork button, which will create a copy of the repository and place it in the GitHub based location of your choosing.

### Build & Run

1. Open new Powershell window to find your module directories by typing: 
   ``` 
   $env:PSModulePath 
   ```
2. Copy the VMware.vSphereDSC Module to one of the module directories.
3. Import the VMware.vSphereDSC Module by typing:
   ```
    Import-Module -Name 'VMware.vSphereDSC'
   ```
4. To see the available DSC Resources type:
   ```
    Get-DscResource -Module VMware.vSphereDSC
   ```
5. To apply one of the desired configurations:  
   Compile the ps1 configuration file (for example VMHostNtpSettings_Config.ps1 file)
   ```
    $ntpConfigPath = Join-Path (Join-Path (Join-Path (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase 'Configurations') 'ESXiConfigs')'VMHostNtpSettings_Config.ps1'
    . $ntpConfigPath -Name '<VMHost Name>' -Server 'Server Name>' -User '<User Name>' -Password '<Password for User>'
   ```

   To check if the NTP Settings are in the desired state:
   ```
    Test-DscConfiguration -ComputerName <your computer name> -Path .\VMHostNtpSettings_Config\
   ```

   To apply the configuration and configure the NTP Settings to be in the desired state:
   ```
    Start-DscConfiguration -ComputerName <your computer name> -Path .\VMHostNtpSettings_Config\
   ```

   To get the current state of the NTP Settings and also the last applied configuration:
   ```
    Get-DscConfiguration
   ```
  
6. To run all unit tests:
   ```
    cd (Join-Path (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase 'Tests')  
    .\TestRunner.ps1 -Unit
   ```

## Documentation

 DSC is a declarative platform used for configuration, deployment, and management of systems. It consists of three primary components:

 * Configurations are declarative PowerShell scripts which define and configure instances of resources.
 * Resources are the "make it so" part of DSC. They contain the code that puts and keeps the target of a configuration in the specified state.
 * The Local Configuration Manager (LCM) is the engine by which DSC facilitates the interaction between resources and configurations.

## Releases & Major Branches

## Contributing

The dscr-for-vmware project team welcomes contributions from the community. If you wish to contribute code and you have not
signed our contributor license agreement (CLA), our bot will update the issue when you open a Pull Request. For any
questions about the CLA process, please refer to our [FAQ](https://cla.vmware.com/faq). For more detailed information,
refer to [CONTRIBUTING.md](CONTRIBUTING.md).

## License
The dscr-for-vmware is distributed under the [BSD-2](https://github.com/vmware/dscr-for-vmware/blob/master/LICENSE.txt).

For more details, please refer to the [BSD-2 License File](https://github.com/vmware/dscr-for-vmware/blob/master/LICENSE.txt).