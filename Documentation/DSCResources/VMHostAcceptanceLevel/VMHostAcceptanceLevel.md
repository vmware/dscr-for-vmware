# VMHostAcceptanceLevel

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Credential** | Mandatory | PSCredential | The credentials needed for connection to the specified Server. ||
| **Name** | Key | string | The name of the VMHost. ||
| **Level** | Mandatory | AcceptanceLevel | The acceptance level of the VMHost. | VMwareCertified, VMwareAccepted, PartnerSupported, CommunitySupported |

## Description

The resource is used to modify the acceptance level of the specified VMHost.

## Examples

### Example 1

Modifies the VMHost acceptance level by setting it to **CommunitySupported**.

```powershell
Configuration VMHostAcceptanceLevel_ModifyVMHostAcceptanceLevel_Config {
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
        VMHostAcceptanceLevel VMHostAcceptanceLevel {
            Server = $Server
            Credential = $Credential
            Name = $Name
            Level = 'CommunitySupported'
        }
    }
}
```
