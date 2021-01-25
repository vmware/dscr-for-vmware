# VMHostCache

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | Name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Name** | Key | string | Name of the VMHost to configure. ||
| **Credential** | Mandatory | PSCredential | Credentials needed for connection to the specified Server. ||
| **DatastoreName** | Key | string | The name of the Datastore used for swap performance enhancement. ||
| **SwapSizeGB** | Mandatory | double | The space to allocate on the specified Datastore to implement swap performance enhancements, in GB. This value should be less than or equal to the free space capacity of the Datastore. ||

## Description

The resource is used to Configure the host cache/swap performance enhancement by setting the Space to allocate on the specified SSD based Datastore.

## Examples

### Example 1

Performs an Update operation by setting the Space to allocate on the specified SSD based Datastore to **1 GB**.

```powershell
Configuration VMHostCache_Config {
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Server,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $Credential
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        VMHostCache VMHostCache {
            Name = $Name
            Server = $Server
            Credential = $Credential
            DatastoreName = 'MyDatastore'
            SwapSizeGB = 1
        }
    }
}
```
