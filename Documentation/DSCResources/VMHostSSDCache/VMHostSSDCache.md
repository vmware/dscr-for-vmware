# VMHostSSDCache

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | Name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Name** | Key | string | Name of the VMHost to configure. ||
| **Credential** | Mandatory | PSCredential | Credentials needed for connection to the specified Server. ||
| **Datastore** | Key | string | The Datastore used for swap performance enhancement. ||
| **SwapSize** | Mandatory | long | The space to allocate on the specified Datastore to implement swap performance enhancements, in MB. This value should be less than or equal to the free space capacity of the Datastore. ||

## Description
The resource is used to Configure the host cache/swap performance enhancement by setting the Space to allocate on the specified SSD based Datastore.

## Examples

### Example 1

Performs an Update operation by setting the Space to allocate on the specified SSD based Datastore to **1 GB**.

```powershell
Configuration VMHostSSDCache_Config {
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
        VMHostSSDCache VMHostSSDCache {
            Name = $Name
            Server = $Server
            Credential = $Credential
            Datastore = 'MyDatastore'
            SwapSize = 1024
        }
    }
}
```
