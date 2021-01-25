# DatastoreCluster

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The name of the Server we are trying to connect to. The Server can only be a vCenter Server. ||
| **Credential** | Mandatory | PSCredential | The credentials needed for connection to the specified Server. ||
| **Name** | Key | string | The name of the Datastore Cluster located in the Datacenter specified in **DatacenterName** key property. ||
| **Location** | Key | string | The location of the Datastore Cluster with name specified in **Name** key property in the Datacenter specified in **DatacenterName** key property. Location consists of 0 or more Folders. Empty location means that the Datastore Cluster is located in the Datastore Folder of the Datacenter. The Root Folders of the Datacenter are not part of the location. Folder names in the location are separated by '/'. Example location for a Datastore Cluster: **MyDatastoreClusterFolderOne/MyDatastoreClusterFolderTwo**. ||
| **DatacenterName** | Key | string | The name of the Datacenter where the Datastore Cluster is located. ||
| **DatacenterLocation** | Key | string | The location of the Datacenter where the Datastore Cluster is located. The Root Folder of the Inventory is not part of the location. Empty location means that the Datacenter is in the Root Folder of the Inventory. The Folder names in the location are separated by '/'. Example Datacenter location: **MyDatacentersFolderOne/MyDatacentersFolderTwo**. ||
| **Ensure** | Mandatory | Ensure | Specifies whether the Datastore Cluster should be present or absent. | Present, Absent |
| **IOLatencyThresholdMillisecond** | Optional | int | The maximum I/O latency in milliseconds allowed before Storage DRS is triggered for the Datastore Cluster. Valid values are in the range of **5** to **100**. If the value of IOLoadBalancing is **$false**, the setting for the I/O latency threshold is not applied. ||
| **IOLoadBalanceEnabled** | Optional | bool | Whether I/O load balancing is enabled for the Datastore Cluster. If the value is **$false**, I/O load balancing is disabled and the settings for the I/O latency threshold and utilized space threshold are not applied. ||
| **SdrsAutomationLevel** | Optional | DrsAutomationLevel | The Storage DRS automation level for the Datastore Cluster. | FullyAutomated, Manual, Disabled |
| **SpaceUtilizationThresholdPercent** | Optional | int | The maximum percentage of consumed space allowed before Storage DRS is triggered for the Datastore Cluster. Valid values are in the range of **50** to **100**. If the value of IOLoadBalancing is **$false**, the setting for the utilized space threshold is not applied. ||

## Description

The resource is used to create, modify and remove Datastore Clusters in the specified Datacenter on the specified vCenter Server.

## Examples

### Example 1

Creates a Datastore Cluster **DscDatastoreCluster** in the **Datastore Folder** of Datacenter **Datacenter**. The IOLoadBalanceEnabled is set to **$true**, the SdrsAutomationLevel is set to **FullyAutomated** and the IOLatencyThresholdMillisecond and SpaceUtilizationThresholdPercent are set to **50**.

```powershell
Configuration DatastoreCluster_CreateDatastoreCluster_Config {
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
        DatastoreCluster DatastoreCluster {
            Server = $Server
            Credential = $Credential
            Name = 'DscDatastoreCluster'
            Location = ''
            DatacenterName = 'Datacenter'
            DatacenterLocation = ''
            Ensure = 'Present'
            IOLatencyThresholdMillisecond = 50
            IOLoadBalanceEnabled = $true
            SdrsAutomationLevel = 'FullyAutomated'
            SpaceUtilizationThresholdPercent = 50
        }
    }
}
```

### Example 2

Removes the Datastore Cluster **DscDatastoreCluster** located in the **Datastore Folder** of Datacenter **Datacenter**.

```powershell
Configuration DatastoreCluster_RemoveDatastoreCluster_Config {
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
        DatastoreCluster DatastoreCluster {
            Server = $Server
            Credential = $Credential
            Name = 'DscDatastoreCluster'
            Location = ''
            DatacenterName = 'Datacenter'
            DatacenterLocation = ''
            Ensure = 'Absent'
            IOLatencyThresholdMillisecond = 50
            IOLoadBalanceEnabled = $true
            SdrsAutomationLevel = 'FullyAutomated'
            SpaceUtilizationThresholdPercent = 50
        }
    }
}
```
