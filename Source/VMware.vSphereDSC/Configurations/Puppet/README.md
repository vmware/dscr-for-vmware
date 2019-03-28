# Desired State Configuration Resources for VMware Examples with Puppet

## Getting Started
## Requirements
1. Install [Puppet Agent](https://downloads.puppetlabs.com)
2. Install [DSC Lite Module](https://forge.puppet.com/puppetlabs/dsc_lite/readme)
3. To apply your configuration run the following command in Powershell:
    ```powershell
    puppet apply <path to your config file>
    ```

## Examples
All shown examples are located [here](https://github.com/vmware/dscr-for-vmware/tree/master/Source/VMware.vSphereDSC/Configurations/Puppet).

### Example 1
Updates the EventMaxAge Settings, TaskMaxAge Settings, Motd Setting, Issue Setting and the Logging Level of the passed vCenter.

```
dsc {'vCenter-Settings':
  resource_name => 'vCenterSettings',
  module => 'VMware.vSphereDSC',
  properties => {
    'server' => '<server>',
    'credential' => {
      'dsc_type' => 'MSFT_Credential',
      'dsc_properties' => {
        'user' => '<user>',
        'password' => Sensitive('<password>')
      }
    },
    'logginglevel' => 'Warning',
    'eventmaxageenabled' => false,
    'eventmaxage' => 40,
    'taskmaxageenabled' => false,
    'taskmaxage' => 40,
    'motd' => 'Hello World from motd!',
    'issue' => 'Hello World from issue!'
  }
}
```

For more information on how to write your configurations with Puppet, you can refer to the documentation [here](https://forge.puppet.com/puppetlabs/dsc_lite/readme).
