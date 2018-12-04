

# dscr-for-vmware

## Overview

The project contains Windows PowerShell Desired State Configuration (DSC) Resources for managing VC and ESXi settings. DSC is a management platform in PowerShell that enables managing infrastructure configuration as code. It is a declarative platform used for configuration, deployment and management of systems. The purpose of the project is to allow users to configure VC and ESXi in a declarative fashion. Configuration management software like Chef and Puppet are able to run DSC resources. Applying a configuration makes vCenter or ESXi in the desired by the user state.

## Try it out

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

### Build & Run

1. Copy the VMware.vSphereDSC Module to one of the module directories.
2. Import the VMware.vSphereDSC Module
   ```
    Import-Module -Name 'VMware.vSphereDSC'
   ```

## Documentation

## Releases & Major Branches

## Contributing

The dscr-for-vmware project team welcomes contributions from the community. If you wish to contribute code and you have not
signed our contributor license agreement (CLA), our bot will update the issue when you open a Pull Request. For any
questions about the CLA process, please refer to our [FAQ](https://cla.vmware.com/faq). For more detailed information,
refer to [CONTRIBUTING.md](CONTRIBUTING.md).

## License
