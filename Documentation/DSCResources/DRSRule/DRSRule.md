# DRSRule

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | The name of the Server we are trying to connect to. The Server can only be a vCenter Server. ||
| **Credential** | Mandatory | PSCredential | The credentials needed for connection to the specified Server. ||
| **Name** | Key | string | The name of the DRS rule for Cluster specified in **ClusterName** key property. ||
| **DatacenterName** | Key | string | The name of the Datacenter where the Cluster, for which the DRS rule applies, is located. ||
| **DatacenterLocation** | Key | string | The location of the Datacenter where the Cluster, for which the DRS rule applies, is located. The Root Folder of the Inventory is not part of the location. Empty location means that the Datacenter is located in the Root Folder of the Inventory. The Folder names in the location are separated by '/'. Example Datacenter location: **MyDatacentersFolderOne/MyDatacentersFolderTwo**. ||
| **ClusterName** | Key | string | The name of the Cluster for which the DRS rule applies. ||
| **ClusterLocation** | Key | string | The location of the Cluster, for which the DRS rule applies, located in the Datacenter specified in **DatacenterName** key property. The Root Folders of the Datacenter are not part of the location. Empty location means that the Cluster is located in the Host Folder of the Datacenter. The Folder names in the location are separated by '/'. Example Cluster location: **MyClusterFolderOne/MyClusterFolderTwo**. ||
| **DRSRuleType** | Key | DRSRuleType | Specifies the type of the DRS rule - affinity or anti-affinity. | VMAffinity, VMAntiAffinity |
| **VMNames**| Mandatory | string[] | The names of the virtual machines that are referenced by the DRS rule. ||
| **Ensure** | Mandatory | Ensure | Specifies whether the DRS rule should be present or absent. | Present, Absent |
| **Enabled** | Optional | bool | Whether the DRS rule is enabled or disabled for the specified Cluster. ||

## Description

The resource is used to create, modify and remove DRS rules for the specified Cluster.

## Examples

### Example 1

Creates and enables **VMAffinity** DRS rule **DscDrsRule** for Cluster **DscCluster**. Virtual Machines **DscVM1** and **DscVM2** are referenced by the DRS rule **DscDrsRule**.

```powershell
Configuration DRSRule_CreateDRSRule_Config {
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
        DRSRule DRSRule {
            Server = $Server
            Credential = $Credential
            Name = 'DscDrsRule'
            DatacenterName = 'Datacenter'
            DatacenterLocation = ''
            ClusterName = 'DscCluster'
            ClusterLocation = ''
            DRSRuleType = 'VMAffinity'
            VMNames = @('DscVM1', 'DscVM2')
            Ensure = 'Present'
            Enabled = $true
        }
    }
}
```

### Example 2

Removes **VMAffinity** DRS rule **DscDrsRule** for Cluster **DscCluster**.

```powershell
Configuration DRSRule_RemoveDRSRule_Config {
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
        DRSRule DRSRule {
            Server = $Server
            Credential = $Credential
            Name = 'DscDrsRule'
            DatacenterName = 'Datacenter'
            DatacenterLocation = ''
            ClusterName = 'DscCluster'
            ClusterLocation = ''
            DRSRuleType = 'VMAffinity'
            VMNames = @('DscVM1', 'DscVM2')
            Ensure = 'Absent'
        }
    }
}
```
