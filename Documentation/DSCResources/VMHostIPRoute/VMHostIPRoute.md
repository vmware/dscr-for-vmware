# VMHostIPRoute

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Credential** | Mandatory | PSCredential | The credentials needed for connection to the specified Server. ||
| **Name** | Key | string | The name of the VMHost. ||
| **Gateway** | Key | string | The gateway IPv4/IPv6 address of the route. ||
| **Destination** | Key | string | The destination IPv4/IPv6 address of the route. ||
| **PrefixLength** | Key | int | The prefix length of the destination IP address. For IPv4, the valid values are from 0 to 32, and for IPv6 - from 0 to 128. ||
| **Ensure** | Mandatory | Ensure | Specifies whether the IPv4/IPv6 route should be present or absent. | Present, Absent |

## Description

The resource is used to create and remove IPv4/IPv6 routes on the specified VMHost.

## Examples

### Example 1

Creates a new IPv4 route with the specified gateway address and destination address **192.168.100.0/24** on the specified VMHost.

```powershell
Configuration VMHostIPRoute_CreateVMHostIPRoute_Config {
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
        $DefaultGateway
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostIPRoute VMHostIPRoute {
            Server = $Server
            Credential = $Credential
            Name = $Name
            Gateway = $VMHostDefaultGateway
            Destination = '192.168.100.0'
            PrefixLength = 24
            Ensure = 'Present'
        }
    }
}
```

### Example 2

Removes the IPv4 route with the specified gateway address and destination address **192.168.100.0/24** from the specified VMHost.

```powershell
Configuration VMHostIPRoute_RemoveVMHostIPRoute_Config {
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
        $DefaultGateway
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostIPRoute VMHostIPRoute {
            Server = $Server
            Credential = $Credential
            Name = $Name
            Gateway = $VMHostDefaultGateway
            Destination = '192.168.100.0'
            PrefixLength = 24
            Ensure = 'Absent'
        }
    }
}
```
