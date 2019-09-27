# VMHostPhysicalNetworkAdapter

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | Name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Credential** | Mandatory | PSCredential | Credentials needed for connection to the specified Server. ||
| **Name** | Key | string | Name of the VMHost to configure. ||
| **PhysicalNetworkAdapter** | Key | string | The Physical Network Adapter which is going to be configured. ||
| **Duplex** | Optional | Duplex | Indicates whether the link is capable of full-duplex. | Full, Half, Unset |
| **BitRatePerSecMb** | Optional | int | Specifies the bit rate of the link. ||
| **AutoNegotiate** | Optional | bool | Indicates that the host network adapter speed/duplex settings are configured automatically. If the property is passed, the Duplex and BitRatePerSecMb properties will be ignored. ||

## Description
The resource is used to update the speed and duplex settings of the specified Physical Network Adapter.

## Examples

### Example 1

Performs an Update operation on Physical Network Adapter **vmnic0** by setting the **BitRatePerSec** to **1000 Mb** and the **Duplex** to **Full**.

```powershell
Configuration VMHostPhysicalNetworkAdapter_Config {
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
        $Name
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostPhysicalNetworkAdapter VMHostPhysicalNetworkAdapter {
            Server = $Server
            Credential = $Credential
            Name = $Name
            PhysicalNetworkAdapter = 'vmnic0'
            Duplex = 'Full'
            BitRatePerSecMb = 1000
        }
    }
}
```

### Example 2

Performs an Update operation on Physical Network Adapter **vmnic0** by automatically configuring the **Duplex** and **Speed** settings.

```powershell
Configuration VMHostPhysicalNetworkAdapter_Config {
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
        $Name
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostPhysicalNetworkAdapter VMHostPhysicalNetworkAdapter {
            Server = $Server
            Credential = $Credential
            Name = $Name
            PhysicalNetworkAdapter = 'vmnic0'
            AutoNegotiate = $true
        }
    }
}
```
