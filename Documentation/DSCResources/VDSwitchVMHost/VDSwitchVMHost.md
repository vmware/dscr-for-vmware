# VDSwitchVMHost

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The Name of the Server we are trying to connect to. The Server can only be a vCenter. ||
| **Credential** | Mandatory | PSCredential | Credentials needed for connection to the specified Server. ||
| **VdsName** | Key | string | The Name of the vSphere Distributed Switch to/from which you want to add/remove the specified VMHosts. ||
| **VMHostNames** | Mandatory | string[] | The Names of the VMHosts that you want to add/remove to/from the specified vSphere Distributed Switch. ||
| **Ensure** | Mandatory | Ensure | Value indicating if the VMHosts should be Present/Absent to/from the specified vSphere Distributed Switch. | Present, Absent |

## Description

The resource is used to add/remove VMHosts to/from the specified vSphere Distributed Switch.

## Examples

### Example 1

The first Resource in the Configuration creates a new Distributed Switch **MyDistributedSwitch** in the **Network** folder of Datacenter **Datacenter**. The second Resource in the Configuration adds the specified VMHosts to Distributed Switch **MyDistributedSwitch**.

```powershell
Configuration VDSwitchVMHost_Config {
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Server,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $VMHostNames
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VDSwitch VDSwitch {
            Server = $Server
            Credential = $Credential
            Name = 'MyDistributedSwitch'
            Location = ''
            DatacenterName = 'Datacenter'
            DatacenterLocation = ''
            Ensure = 'Present'
        }

        VDSwitchVMHost VDSwitchVMHost {
            Server = $Server
            Credential = $Credential
            VdsName = 'MyDistributedSwitch'
            VMHostNames = $VMHostNames
            Ensure = 'Present'
            DependsOn = "[VDSwitch]VDSwitch"
        }
    }
}
```

### Example 2

The first Configuration creates a new Distributed Switch **MyDistributedSwitch** in the **Network** folder of Datacenter **Datacenter** and adds the specified VMHosts to Distributed Switch **MyDistributedSwitch**. The second Configuration removes the specified VMHosts from Distributed Switch **MyDistributedSwitch**.

```powershell
Configuration VDSwitchVMHost_WhenAddingVMHostsToDistributedSwitch_Config {
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Server,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $VMHostNames
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VDSwitch VDSwitch {
            Server = $Server
            Credential = $Credential
            Name = 'MyDistributedSwitch'
            Location = ''
            DatacenterName = 'Datacenter'
            DatacenterLocation = ''
            Ensure = 'Present'
        }

        VDSwitchVMHost VDSwitchVMHost {
            Server = $Server
            Credential = $Credential
            VdsName = 'MyDistributedSwitch'
            VMHostNames = $VMHostNames
            Ensure = 'Present'
            DependsOn = "[VDSwitch]VDSwitch"
        }
    }
}

Configuration VDSwitchVMHost_WhenRemovingVMHostsFromDistributedSwitch_Config {
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Server,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $VMHostNames
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VDSwitchVMHost VDSwitchVMHost {
            Server = $Server
            Credential = $Credential
            VdsName = 'MyDistributedSwitch'
            VMHostNames = $VMHostNames
            Ensure = 'Absent'
        }
    }
}
```
