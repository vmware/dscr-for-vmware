## Getting Started

**VMware.PSDesiredStateConfiguration** module provides a set of cmdlets to compile and execute a **DSC Configuration** without using the **DSC Local Configuration Manager**. Compiled **DSC Configurations** are stored in memory as **PowerShell** objects.

**Start-VmwDscConfiguration**, **Get-VmwDscConfiguration** and **Test-VmwDscConfiguration** cmdlets use the **Invoke-DSCResource** cmdlet from the **PSDesiredStateConfiguration** module to execute the compiled **DSC Configurations**.

The **VMware.PSDesiredStateConfiguration** module provides a cross platform support on **MacOS** and **Linux**. The module is also designed to work with the existing **DSC Resources** from the **VMware.vSphereDSC** module.

The module also exposes **vSphereNodes**, which represent connections to **vCenter Servers**.
For more information on **vSphereNodes**, please read here [vSphere Nodes](https://github.com/vmware/dscr-for-vmware/blob/master/Documentation/vSphereNodes.md).

## Requirements

The following table describes the required dependencies for running the **VMware.PSDesiredStateConfiguration** module.

 **Required dependency**   | **Minimum version**
-------------------------- | -------------------
`PowerShell`               | **5.1 or 7.0**

The module also has additional requirements, depending on the **PowerShell** version, on which it is used.

### PowerShell 7.0 requirements

---
**VMware.PSDesiredStateConfiguration** uses the **Invoke-DscResource** cmdlet from the **PSDesiredStateConfiguration** module to process individual **DSC Resources**. In **PowerShell 7.0** the **Invoke-DscResource** cmdlet is an experimental feature.
The **Invoke-DscResource** cmdlet can be enabled with the following command:

```powershell
Enable-ExperimentalFeature PSDesiredStateConfiguration.InvokeDscResource
```

After executing the command you must restart your **PowerShell** session. The command needs to be run only once and the cmdlet will be available.
To check if the **Invoke-DscResource** cmdlet has been enabled correctly run the following command:

```powershell
Get-Module 'PSDesiredStateConfiguration' -ListAvailable | Select-Object -ExpandProperty ExportedCommands
```
### Important

When using **PowerShell 7.0** please keep in mind the list of [Known Limitations](https://github.com/vmware/dscr-for-vmware/blob/master/LIMITATIONS.md).

---
### PowerShell 5.1 requirements

For **PowerShell 5.1** you need to enable Windows Remote Management.
For information on how to enable it read here: [WinRM guide](https://docs.microsoft.com/en-us/windows/win32/winrm/installation-and-configuration-for-windows-remote-management).

## Installing the VMware.PSDesiredStateConfiguration Module

There are two ways to install the **VMware.PSDesiredStateConfiguration** Module: Download it from the **PowerShell Gallery** or download it from the [Releases page](https://github.com/vmware/dscr-for-vmware/releases).

### PowerShell Gallery

```powershell
 Install-Module -Name VMware.PSDesiredStateConfiguration
```

### Download it from [Releases](https://github.com/vmware/dscr-for-vmware/releases)

1. Copy the **VMware.PSDesiredStateConfiguration** Module to one of the system **PowerShell** module directories. For more information on installing **PowerShell** Modules, please visit [Installing a PowerShell Module](https://docs.microsoft.com/en-us/powershell/scripting/developer/module/installing-a-powershell-module?view=powershell-7).
2. In **PowerShell** import the **VMware.PSDesiredStateConfiguration** module:
   ```powershell
    Import-Module -Name 'VMware.PSDesiredStateConfiguration'
   ```

   To check if the module was successfully installed:
   ```powershell
    Get-Module -Name 'VMware.PSDesiredStateConfiguration'
   ```

## Overview

The **VMware.PSDesiredStateConfiguration** module works with **PowerShell** script files that contain **DSC Configurations** and the general workflow for creating **VmwDscConfiguration** objects is:

- Compiles **DSC Configurations** defined in a **PowerShell** script file and transforms the given **DSC Configurations** into **VmwDscConfiguration** objects. The **VmwDscConfiguration** object contains the name of the **DSC Configuration** and an array of **DSC Nodes**.

- All **DSC Resources** which are not defined inside a **Node** will get bundled into a default **localhost** **Node**. Each **Node** contains the name of the **Node** and an array of **DSC Resources**.

- Each **DSC Resource** object contains an **InstanceName** for the name of the **DSC Resource** given in the **DSC Configuration**, a **ResourceType** which display the type of the **DSC Resource**, a **ModuleName** which displays the module of the **DSC Resource** and a **Property** which is a hashtable of properties which are unique for a given **DSC Resource**. Example **VmwDscConfiguration** object from a given **DSC Configuration**:

    ```powershell
    $Credential = Get-Credential

    Configuration Datacenter_Config {
        Import-DscResource -ModuleName VMware.vSphereDSC

        Node localhost {
            Datacenter MyDatacenter {
                Server = '10.23.112.235'
                Credential = $Credential
                Name = 'MyDatacenter'
                Location = ''
                Ensure = 'Present'
            }
        }
    }

    # The compiled Datacenter_Config DSC Configuration as VmwDscConfiguration object.
    [VmwDscConfiguration] @{
        InstanceName = 'Datacenter_Config'
        Nodes = @(
            [VmwDscNode] @{
                InstanceName = 'localhost'
                Resources = @(
                    [VmwDscResource] @{
                        InstanceName = 'MyDatacenter'
                        ResourceType = 'Datacenter'
                        ModuleName = 'VMware.vSphereDSC'
                        Property = @{
                            Server = '10.23.112.235'
                            Credential = System.Management.Automation.PSCredential
                            Name = 'MyDatacenter'
                            Location = ''
                            Ensure = 'Present'
                        }
                    }
                )
            }
        )
    }
    ```

    Note: This step does not require a configured **LCM** and does not generate a **MOF** file.

- The resulting **VmwDscConfiguration** objects generated by the **New-VmwDscConfiguration** cmdlet are used by the **Start, Get and Test-VmwDscConfiguration** cmdlets.

## Cmdlet Guide

### New-VmwDscConfiguration

Compiles a **DSC Configuration** into a **VmwDscConfiguration** object, which contains the name of the **DSC Configuration** and the **DSC Resources** defined in it.

#### Parameters

#### Mandatory

- **Path** - A file path of a file that contains **DSC Configurations**. The file can contain multiple **DSC Configurations** and for each one, a separate **VmwDscConfiguration** object is created. If **ConfigurationData** hashtable is defined in the provided file, it is passed to each **DSC Configuration** defined in the file.

#### Optional

- **ConfigurationName** - The name of the **DSC Configuration** which should be compiled into a **VmwDscConfiguration** object. This parameter is applicable only when multiple **DSC Configurations** are defined in the file and only one specific **DSC Configuration** should be compiled. If not specified, all **DSC Configurations** in the file are compiled and returned as **VmwDscConfiguration** objects.

- **Parameters** - The parameters of the file that contains the **DSC Configurations** as a hashtable where each key is the parameter name and each value is the parameter value.

#### Examples

#### **Parameters** example:

The following **DSC Configuration** depends on a **Server** and **Credential** parameters:

```powershell
Param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Server,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [System.Management.Automation.PSCredential]
    $Credential
)

Configuration Datacenter_Config {
    Param(
        [string]
        $Server,

        [System.Management.Automation.PSCredential]
        $Credential
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        Datacenter MyDatacenter {
            Server = $Server
            Credential = $Credential
            Name = 'MyDatacenter'
            Location = ''
            Ensure = 'Present'
        }
    }
}
```

In order to supply the required **Server** and **Credential** parameters of the **DSC Configuration** we use the **Parameters** parameter.

```powershell
$Credential = Get-Credential

$newVmwDscConfigParams = @{
    Path = '.\Datacenter_Config.ps1'
    Parameters = @{
        Server = '10.23.112.235'
        Credential = $Credential
    }
}

$dscConfiguration = New-VmwDscConfiguration @newVmwDscConfigParams
```

#### ConfigurationData example:

The following **DSC Configuration** depends on a **Server** and **Credential** parameters that are specified in the **ConfigurationData** hashtable:

```powershell
Param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Server,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [System.Management.Automation.PSCredential]
    $Credential
)

$script:configurationData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            Server = $Server
            Credential = $Credential
        }
    )
}

Configuration Datacenter_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        Datacenter MyDatacenter {
            Server = $AllNodes.Server
            Credential = $AllNodes.Credential
            Name = 'MyDatacenter'
            Location = ''
            Ensure = 'Present'
        }
    }
}
```

In order to supply the required **Server** and **Credential** parameters of the **ConfigurationData** hashtable we use the **Parameters** parameter.

```powershell
$Credential = Get-Credential

$newVmwDscConfigParams = @{
    Path = '.\Datacenter_Config.ps1'
    Parameters = @{
        Server = '10.23.112.235'
        Credential = $Credential
    }
}

$dscConfiguration = New-VmwDscConfiguration @newVmwDscConfigParams
```

---
### Start, Test and Get-VmwDscConfiguration

These cmdlets work with the **VmwDscConfiguration** object created by the **New-VmwDscConfiguration** cmdlet and apply the **Set, Test, Get methods** to the compiled **DSC Configuration**.

#### Parameters

#### Mandatory

- **Configuration** - A **VmwDscConfiguration** object compiled by the **New-VmwDscConfiguration** cmdlet.

#### Optional

- **ConnectionFilter** - An array of **Node** names on which the **DSC Configuration** should be executed. **Nodes** that are not in the list will be skipped. **Node** names can be strings or **VIServer** objects.

---
#### Examples

#### Example with the [VMHostNtpSettings Resource](https://github.com/vmware/dscr-for-vmware/wiki/VMHostNtpSettings) from the **VMware.vSphereDSC** module

1. Use the following **VNware.vSphereDSC DSC Configuration**:

    ```powershell
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

2. You need to compile the **DSC Configuration** to a **VmwDscConfiguration** object:

    ```powershell
    $newVmwDscConfigParams = @{
        Path = '.\VMHostNtpSettings_Config.ps1'
        ConfigurationName = 'VMHostNtpSettings_Config'
        Parameters = @{
            Server = '10.23.112.235'
            User = 'Admin'
            Password = 'AdminPass'
            Name = '10.23.112.236'
        }
    }

    $dscConfiguration = New-VmwDscConfiguration @newVmwDscConfigParams
    ```

3. To test if the **NTP Settings** are in the desired state:

    ```powershell
    Test-VmwDscConfiguration -Configuration $dscConfiguration
    ```

    This will return a boolean result that shows if the state is desired or not. If you want a detailed result in which every **DSC Resource** state is shown you can use the optional **-Detailed** switch of the **Test-VmwDscConfiguration** cmdlet:

    ```powershell
    Test-VmwDscConfiguration -Configuration $dscConfiguration -Detailed
    ```

    The resulting object will contain an **InDesiredState** flag which shows the overall state of the **DSC Configuration**, a **ResourcesInDesiredState** array of **DSC Resources** in desired state and a **ResourcesNotInDesiredState** array of **DSC Resources** not in desired state.

    **Test-VmwDscConfiguration** also remembers the last run **DSC Configuration** so you can use the **-ExecuteLastConfiguration** flag to invoke it:

    ```powershell
    Test-VmwDscConfiguration -ExecuteLastConfiguration
    ```

4. To Apply the **NTP Configuration**:

    ```powershell
    Start-VmwDscConfiguration -Configuration $dscConfiguration
    ```

5. To get the current sate of the **DSC Configuration**:

    ```powershell
    Get-VmwDscConfiguration -Configuration $dscConfiguration
    ```

    **Get-VmwDscConfiguration** also remembers the last run configuration so you can use the **-ExecuteLastConfiguration** flag to invoke it:

    ```powershell
    Get-VmwDscConfiguration -ExecuteLastConfiguration
    ```

#### Example with the ConnectionFilter parameter

The following configuration has multiple **Nodes**. Only the **Nodes** specified in the **ConnectionFilter** will be executed.

```powershell
Param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [System.Management.Automation.PSCredential]
    $Credential
)

Configuration Datacenter_Config {
    Param(
        [System.Management.Automation.PSCredential]
        $Credential
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node 10.23.112.235 {
        Datacenter MyDatacenter {
            Server = '10.23.112.235'
            Credential = $Credential
            Name = 'MyDatacenter'
            Location = ''
            Ensure = 'Present'
        }
    }

    Node 10.23.112.237 {
        Datacenter MyDatacenter {
            Server = '10.23.112.237'
            Credential = $Credential
            Name = 'MyDatacenter'
            Location = ''
            Ensure = 'Present'
        }
    }
}

$Credential = Get-Credential

$newVmwDscConfigParams = @{
    Path = '.\Datacenter_Config.ps1'
    Parameters = @{
        Credential = $Credential
    }
}

$dscConfiguration = New-VmwDscConfiguration @newVmwDscConfigParams

$startVmwDscConfigParams = @{
    Configuration = $dscConfiguration
    ConnectionFilter = '10.23.112.237'
}

$result = Start-VmwDscConfiguration @startVmwDscConfigParams
```
