## Getting Started

**VMware.PSDesiredStateConfiguration** provides a new way to compile and execute **DSC Configurations** on **Windows**, **Linux** and **MacOS** that does not require the use of **DSC LCM** or the typical MOF format and without altering the existing **Configuration** syntax.  Instead the cmdlets of this module create and work with regular powershell objects. This module is also designed to work with the existing **DSC Resources** in **VMware.vSphereDSC**.  

## Requirements

The following table describes the required dependencies for running VMware.vSphereDSC Resources.

 **Required dependency**   | **Minimum version**
-------------------------- | -------------------
`PowerShell`               | 5.1 (Core is supported)

1. Copy the VMware.PSDesiredStateConfiguration Module to one of the system PowerShell module directories. For more information on installing PowerShell Modules, please visit [Installing a PowerShell Module](https://docs.microsoft.com/en-us/powershell/module/powershellget/install-module?view=powershell-7).
2. In PowerShell import the VMware.PSDesiredStateConfiguration Module:
   ```
    Import-Module -Name 'VMware.PSDesiredStateConfiguration'
   ```

   To check if the module was successfully installed:
   ```
    Get-Module -Name 'VMware.PSDesiredStateConfiguration'
   ```
This module also has additional requirements depending on which version of powershell you wish to use it with.

#### Powershell core requirements
---
By using **Powershell Core** this module depends on the Invoke-DscResource cmdlet and it must be enabled with the following command.
```
Enable-ExperimentalFeature PSDesiredStateConfiguration.InvokeDscResource
```
 After executing the command you must restart your powershell session. The command needs to be run only once and the cmdlet will be usable.
 To check if the Invoke-DscResource cmdlet has been enabled correctly run the following command
```
Get-Module 'PSDesiredStateConfiguration' -ListAvailable | Select-Object -ExpandProperty ExportedCommands
```
##### Important!
When using **Powershell core** please keep in mind the list of [Known Limitations](https://github.com/vmware/dscr-for-vmware/blob/master/LIMITATIONS.md)

---
#### Powershell 5.1 requirements
For **Powershell 5.1** you need to enable Windows Remote Management
For information on how to enable it read here: [WinRM guide](https://docs.microsoft.com/en-us/windows/win32/winrm/installation-and-configuration-for-windows-remote-management)

# Guide
#### New-VmwDscConfiguration
This cmdlet creates a VmwDscConfiguration object which contains information about the configuration. This object is then used with the other cmdlets in order to perform the three main DSC operations(GET, SET, TEST).

##### Parameters
- **ConfigName** - Name of the Configuration to be compied as string
- **CustomParams** - Represents a hashtable of parameters that are used for the Configuration.
- **ConfigurationData** - Hashtable of values that are to be used as variables during the configuration execution
---
#### Start,Test,Get-VmwDscConfiguration
These cmdlets work with the powershell object created by **New-VmwDscConfiguration** and apply the Set, Test, Get **DSC methods** to the compiled configuration.

##### Parameters
- **Configuration** - A Dsc Configuration compiled by **New-VmwDscConfiguration**

---
### Examples

##### Example with [VMHostNtpSettings Resource](https://github.com/vmware/dscr-for-vmware/wiki/VMHostNtpSettings) from vSphereDsc module

1. Use the following vSphereDsc Configuration
    ```
    Configuration VMHostNtpSettings_Config {
        Import-DscResource -ModuleName VMware.vSphereDSC
    
        $Password = $Password | ConvertTo-SecureString -AsPlainText -Force
        $Credential = New-Object System.Management.Automation.PSCredential($User, $Password)
    
        VMHostNtpSettings vmHostNtpSettings {
            Name = $Name
            Server = $Server
            Credential = $Credential
            NtpServer = @("0.bg.pool.ntp.org", "1.bg.pool.ntp.org", "2.bg.pool.ntp.org")
            NtpServicePolicy = "automatic"
        }
    }
    ```

2. You need to compile the Configuration to a powershell object
    ```
    $compilationArgs = @{
        ConfigName = VMHostNtpSettings
        CustomParams = @{
            Name = '<VMHost Name>'
            Server 'Server Name>'
            Password '<Password for User>'
        }
    }

    $dscConfiguration = New-VmwDscConfiguration @compilationArgs
    ```
3. To Test if the NTP Settings are in the desired state:
    ```
    Test-VmwDscConfiguration -Configuration $dscConfiguration 
    ```
4. To Apply the NTP Configuration:
    ```
    Start-VmwDscConfiguration -Configuration $dscConfiguration
    ```
5. To get the latest applied configuration on your machine:
    ```
    Get-VmwDscConfiguration -Configuration $dscConfiguration
    ```