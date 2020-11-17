## Getting Started

**VMware.PSDesiredStateConfiguration** provides a set of commands to compile and execute **DSC Configuration** without using the DSC Local Configuration Manager. Compiled DSC Configurations are stored in memory as PowerShell objects.
**Start-VmwDscConfiguration**, **Get-VmwDscConfiguration**, **Test-VmwDscConfiguration** cmdlets use **Invoke-DSCResource** cmdlet from the **PSDesiredStateConfiguration** module to execute the compiled configuration.
This solution allows cross platform support on MacOS and Linux. This module is also designed to work with the existing **DSC Resources** in the **VMware.vSphereDSC** module.
This module also features vSphereNodes which represent connections to VIServers.
For more information on vSphereNodes please read here [vSphere Nodes](https://github.com/vmware/dscr-for-vmware/blob/master/Documentation/vSphereNodes.md)

## Requirements

The following table describes the required dependencies for running VMware.PSDesiredStateConfiguration Resources.

 **Required dependency**   | **Minimum version**
-------------------------- | -------------------
`PowerShell`               | 5.1 or 7.0

This module also has additional requirements depending on which version of PowerShell you wish to use it with.

#### PowerShell 7.0 requirements
---
**VMware.PSDesiredStateConfiguration** uses the **Invoke-DscResource** cmdlet from the **PSDesiredStateConfiguration** module to process individual DSC Resources. In **PowerShell 7.0** the **Invoke-DscResource** cmdlet is an experimental feature.
The **Invoke-DscResource** cmdlet and it can be enabled with the following command:
```
Enable-ExperimentalFeature PSDesiredStateConfiguration.InvokeDscResource
```
 After executing the command you must restart your powershell session. The command needs to be run only once and the cmdlet will be usable.
 To check if the **Invoke-DscResource** cmdlet has been enabled correctly run the following command
```
Get-Module 'PSDesiredStateConfiguration' -ListAvailable | Select-Object -ExpandProperty ExportedCommands
```
##### Important!
When using **PowerShell 7.0** please keep in mind the list of [Known Limitations](https://github.com/vmware/dscr-for-vmware/blob/master/LIMITATIONS.md)

---
#### PowerShell 5.1 requirements
For **PowerShell 5.1** you need to enable Windows Remote Management
For information on how to enable it read here: [WinRM guide](https://docs.microsoft.com/en-us/windows/win32/winrm/installation-and-configuration-for-windows-remote-management)


## Installations

### Manual Installation

1. Copy the VMware.PSDesiredStateConfiguration Module to one of the system PowerShell module directories. For more information on installing PowerShell Modules, please visit [Installing a PowerShell Module](https://docs.microsoft.com/en-us/powershell/scripting/developer/module/installing-a-powershell-module?view=powershell-7).
2. In PowerShell import the VMware.PSDesiredStateConfiguration Module:
   ```
    Import-Module -Name 'VMware.PSDesiredStateConfiguration'
   ```

   To check if the module was successfully installed:
   ```
    Get-Module -Name 'VMware.PSDesiredStateConfiguration'
   ```

## Overview
VMware.PSDesiredStateConfiguration works with ps1 configuration files and the general flow is as follow:
- Compiles a DSC Configuration defined in a PowerShell script file (ps1) and transforms the given DSC Configuration to a configuration object. The object contains the name of the configuration and an array of DSC Nodes. All Dsc Resources which are not nested inside a node block will get bundled into a default 'localhost' node. Each Node contains the name of the Node and an array of DSC Resources. Each DSC Resource object contains an **InstanceName** for name of the DSC Resource given in the configuration, a **ResourceType** which display the type of the DSC Resource, a  **ModuleName** which displays the module of the DSC Resource and a **Property** which is a hashtable of properties which are unique for a given DSC Resource. Example Configuration object from a given configuration:
    ```
    Configuration Test
    {
        Import-DscResource -ModuleName MyDscResource

        CustomResource myResource
        {
            Field = "Test field"
            Ensure = "Present"
        }
    }

    # configuration object result
    [VmwDscConfiguration]@{
        InstanceName = 'Test'
        Resource = @(
            [VmwDscNode]@{
                InstanceName = 'localhost'
                Resources = @(
                    [VmwDscResource]@{
                        InstanceName = 'myResource'
                        ResourceType = 'CustomResource'
                        ModuleName = 'MyDscResource'
                        Property = @{
                            Field = "Test field"
                            Ensure = "Present"
                        }
                    }
                )
            }
        )
    }
    ```
    Note: this step does not require the use of **LCM** and does not generate a **MOF** file.
- The resulting configuration object generated by the **New-VmwDscConfiguration** cmdlet gets used with the Start, Get, Test cmdlets and the result is based on the cmdlet.

## Cmdlet Guide
#### New-VmwDscConfiguration
This cmdlet creates a VmwDscConfiguration object which contains information about the configuration. This object is then used with the other cmdlets in order to perform the three main DSC operations(GET, SET, TEST).

##### Parameters
##### Mandatory
- **ConfigName** - Name of the Configuration to be compiled as string
##### Optional
- **CustomParams** - Represents a hashtable of parameters that are used for the Configuration.
- **ConfigurationData** - Hashtable of values that are to be used as variables during the configuration execution

#### Examples with the optional parameters
##### CustomParams example:

The following DSC Configuration depends on a parameter:
```
Configuration ConfigurationDataRequired {
    Param(
        $SomeValue
    )
    Import-DscResource MyResource
    
    MyResource res {
        requredKey = $SomeValue
    }
}
```

In order to supply the required parameter of the DSC Configuration we use the **$CustomParams** parameter.

```
$newVmwDscConfigParams = @{
    ConfigName = 'ConfigurationDataRequired'
    CustomParams = @{
        someValue = 'sample value'
    }
}

$config = New-VmwDscConfiguration @vmwDscConfigParams
```

##### ConfigurationData example:
In the following DSC Configuration there is a variable **$someValue** that is used, but it does not have a value assigned to it.
```
Configuration ConfigurationDataRequired {
    Import-DscResource MyResource
    
    MyResource res {
        requredKey = $ConfigurationData.SomeValue
    }
}
```
In order to assign a value to it we must define it in the **ConfigurationData** parameter. This will supply the necessary value to the variable during the compilation of the DSC Configuration.
```
$newVmwDscConfigParams = @{
    ConfigName = 'ConfigurationDataRequired'
    ConfigurationData = @{
        SomeValue = 'sample value'
    }
}

$config = New-VmwDscConfiguration @vmwDscConfigParams
```

---
#### Start,Test,Get-VmwDscConfiguration
These cmdlets work with the PowerShell object created by **New-VmwDscConfiguration** and apply the Set, Test, Get **DSC methods** to the compiled configuration.

##### Parameters
- **Configuration** - A Dsc Configuration compiled by **New-VmwDscConfiguration**

---
### Examples

##### Example with [VMHostNtpSettings Resource](https://github.com/vmware/dscr-for-vmware/wiki/VMHostNtpSettings) from the vSphereDSC module

1. Use the following vSphereDSC Configuration
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

2. You need to compile the Configuration to a PowerShell object
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
    This will return a boolean result that shows if the state is desired or not. If you want a detailed result in which every resource state is shown you can use the optional **-Detailed** switch for the **Test-VmwDscConfiguration** cmdlet.
    ```
    Test-VmwDscConfiguration -Configuration $dscConfiguration -Detailed
    ```
    The resulting object will contain an **InDesiredState** flag which shows the overall state of the configuration, a **ResourcesInDesiredState** array of resources in desired state and a **ResourcesNotInDesiredState** array of resources not in desired state.
    
    Test-VmwDscConfiguration also remembers the last run configuration so you can use the -ExecuteLastConfiguration flag to invoke it.
    ```
    Test-VmwDscConfiguration -ExecuteLastConfiguration
    ```
4. To Apply the NTP Configuration:
    ```
    Start-VmwDscConfiguration -Configuration $dscConfiguration
    ```
5. To get the latest applied configuration on your machine:
    ```
    Get-VmwDscConfiguration -Configuration $dscConfiguration
    ```
    
    Get-VmwDscConfiguration also remembers the last run configuration so you can use the -ExecuteLastConfiguration flag to invoke it.
    ```
    Get-VmwDscConfiguration -ExecuteLastConfiguration
    ```
