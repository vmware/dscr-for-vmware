# Desired State Configuration Resources for VMware Examples with Ansible

## Getting Started
## Requirements
1. Install [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
2. Setup [Windows Host](https://docs.ansible.com/ansible/latest/user_guide/windows_setup.html)
3. Put your Remote Systems following the instructions [here](https://docs.ansible.com/ansible/latest/user_guide/intro_getting_started.html) in the file:

    ```/etc/ansible/hosts```
4. To apply your configuration run the following command in the Terminal:
    ```
    ansible-playbook <path to your config file>
    ```

## Examples
All shown examples are located [here](https://github.com/vmware/dscr-for-vmware/tree/master/Source/VMware.vSphereDSC/Configurations/Ansible).

### Example 1
Updates the Statistics settings of the passed vCenter by changing the level to 2 for the Day period and also setting the Period Length and Interval in Minutes to 3. Also the collecting of statistics is enabled.

```yaml
- hosts: <host>
  tasks:
  - name: Updates the Statistics settings of the passed vCenter.
    win_dsc:
        resource_name: vCenterStatistics
        Server: <server>
        Credential_username: <user>
        Credential_password: <password>
        Period: Day
        PeriodLength: 3
        Level: 2
        Enabled: True
        IntervalMinutes: 3
```

For more information on how to write your configurations with Ansible, you can refer to the documentation [here](https://docs.ansible.com/ansible/latest/user_guide/windows_dsc.html).
