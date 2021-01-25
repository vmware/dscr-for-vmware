# VMHostSoftwareDevice

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Credential** | Mandatory | PSCredential | The credentials needed for connection to the specified Server. ||
| **Name** | Key | string | The name of the VMHost. ||
| **DeviceIdentifier** | Key | string | The device identifier from the device specification for the software device driver. Valid input is in reverse domain name format (e.g. com.company.device...). ||
| **Ensure** | Mandatory | Ensure | Specifies whether the software device should be present or absent. | Present, Absent |
| **InstanceAddress** | Optional | long | Specifies the unique number to address this instance of the device, if multiple instances of the same device identifier are added. Valid values are integer in the range 0-31. Default is 0. ||

## Description

The resource is used to add a device to enable a software device driver or to remove a software device on the specified VMHost.

## Examples

### Example 1

Adds the device with the specified id to enable the software device driver. **0** is used to address this instance of the device.

```powershell
Configuration VMHostSoftwareDevice_AddSoftwareDevice_Config {
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
        [string]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $DeviceId
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostSoftwareDevice VMHostSoftwareDevice {
            Server = $Server
            Credential = $Credential
            Name = $Name
            DeviceIdentifier = $DeviceId
            Ensure = 'Present'
            InstanceAddress = 0
        }
    }
}
```

### Example 2

Removes the software device with the specified id.

```powershell
Configuration VMHostSoftwareDevice_RemoveSoftwareDevice_Config {
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
        [string]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $DeviceId
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostSoftwareDevice VMHostSoftwareDevice {
            Server = $Server
            Credential = $Credential
            Name = $Name
            DeviceIdentifier = $DeviceId
            Ensure = 'Absent'
        }
    }
}
```
