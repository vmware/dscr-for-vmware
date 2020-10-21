

# Desired State Configuration for VMware

## Overview
The **Desired State Configuration for VMware** project contains **VMware.vSphereDSC** and **VMware.PSDesiredStateConfiguration** PowerShell modules.

The **VMware.vSphereDSC** module is a collection of DSC Resources. This module includes DSC resources that simplify the management of vCenter and ESXi settings, with a simple declarative language.

The **VMware.vSphereDSC** module contains resources for:

- **Datacenters**, **Folders** and **Clusters**
- **Standard** and **distributed switches** and **portgroups** and **network migration** between them
- **Host network adapters**
- **Datastores** (**VMFS** and **NFS**) and **storage adapters**
- **Host accounts**, **roles** and **permissions**
- **vCenter** and **Host** settings

For more information about all available **Resources**, please visit the **wiki** page of the repository: [Wiki](https://github.com/vmware/dscr-for-vmware/wiki).
For more information about the **VMware.vSphereDSC** module ,please visit: [VMware.vSphereDSC info](https://github.com/vmware/dscr-for-vmware/blob/master/VMware.vSphereDSC.md).

The **VMware.PSDesiredStateConfiguration** module provides an alternative in-language way to compile and execute DSC Configurations. It does not require the use of LCM and supports PowerShell 7.0.

For more information about the **VMware.PSDesiredStateConfiguration** module, please visit: [VMware.PSDesiredStateConfiguration info](https://github.com/vmware/dscr-for-vmware/blob/master/VMware.PSDesiredStateConfiguration.md).

For a list of known limitations, please visit: [Known Limitations](https://github.com/vmware/dscr-for-vmware/blob/master/LIMITATIONS.md).

## Branches

### master

[![Build Status](https://travis-ci.org/vmware/dscr-for-vmware.svg?branch=master)](https://travis-ci.org/vmware/dscr-for-vmware)

**VMware.vSphereDSC** ![Coverage](https://img.shields.io/badge/coverage-91%25-brightgreen.svg?maxAge=60)

**VMware.PSDesiredStateConfiguration** ![Coverage](https://img.shields.io/badge/coverage-100%25-brightgreen.svg?maxAge=60)

This is the branch to which contributions should be proposed by contributors as pull requests. The content of the module releases will be from the master branch.

## Contributing

The Desired State Configuration Resources for VMware project team welcomes contributions from the community. For more detailed information, refer to [CONTRIBUTING.md](CONTRIBUTING.md).

## Join us on Slack

If you have any questions about the project you can join us on Slack:

1. Join [VMware Code](https://code.vmware.com/web/code/join)
2. Join the following channel:
    ```
    powercli-dsc-contrib
    ```

## License

The Desired State Configuration Resources for VMware is distributed under the [BSD-2](https://github.com/vmware/dscr-for-vmware/blob/master/LICENSE.txt).

For more details, please refer to the [BSD-2 License File](https://github.com/vmware/dscr-for-vmware/blob/master/LICENSE.txt).
