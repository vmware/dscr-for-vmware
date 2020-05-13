# DatastoreClusterAddDatastore

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The name of the Server we are trying to connect to. The Server can only be a vCenter Server. ||
| **Credential** | Mandatory | PSCredential | The credentials needed for connection to the specified Server. ||
| **DatacenterName** | Key | string | The name of the Datacenter where the specified Datastore Cluster and Datastores are located. ||
| **DatacenterLocation** | Key | string | The location of the Datacenter where the specified Datastore Cluster and Datastores are located. The Root Folder of the Inventory is not part of the location. Empty location means that the Datacenter is in the Root Folder of the Inventory. The Folder names in the location are separated by '/'. Example Datacenter location: **MyDatacentersFolderOne/MyDatacentersFolderTwo**. ||
| **DatastoreClusterName** | Key | string | The name of the Datastore Cluster located in the Datacenter specified in **DatacenterName** key property. ||
| **DatastoreClusterLocation** | Key | string | The location of the Datastore Cluster with name specified in **DatastoreClusterName** key property in the Datacenter specified in **DatacenterName** key property. Location consists of 0 or more Folders. Empty location means that the Datastore Cluster is located in the Datastore Folder of the Datacenter. The Root Folders of the Datacenter are not part of the location. Folder names in the location are separated by '/'. Example location for a Datastore Cluster: **MyDatastoreClusterFolderOne/MyDatastoreClusterFolderTwo**. ||
| **DatastoreNames**| Mandatory | string[] | The names of the Datastores that should be located in the specified Datastore Cluster. ||

## Description

The resource is used to add Datastores to the specified Datastore Cluster.

## Examples

### Example 1

Adds Datastores **DscDatastoreOne** and **DscDatastoreTwo** to Datastore Cluster **DscDatastoreCluster** located in Datacenter **Datacenter**.

```powershell
Configuration DatastoreClusterAddDatastore_AddDatastoresToDatastoreCluster_Config {
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

    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        DatastoreClusterAddDatastore DatastoreClusterAddDatastore {
            Server = $Server
            Credential = $Credential
            DatacenterName = 'Datacenter'
            DatacenterLocation = ''
            DatastoreClusterName = 'DscDatastoreCluster'
            DatastoreClusterLocation = ''
            DatastoreNames = @('DscDatastoreOne', 'DscDatastoreTwo')
        }
    }
}
```
