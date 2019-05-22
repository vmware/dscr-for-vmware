# HACluster

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | Name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Credential** | Mandatory | PSCredential | Credentials needed for connection to the specified Server. ||
| **Name** | Key | string | Name of the Cluster located in the Datacenter specified in 'DatacenterName' key property. ||
| **Location** | Key | string | Location of the Cluster with name specified in 'Name' key property in the Datacenter specified in the 'DatacenterName' key property. Location consists of 0 or more Inventory Items. Empty Location means that the Cluster is in the Host Folder of the Datacenter. The Root Folders of the Datacenter are not part of the Location. Inventory Item names in Location are separated by "/". Example Location for a Cluster Inventory Item: "MyClusters/DrsClusters". ||
| **DatacenterName** | Key | string | Name of the Datacenter we will use from the specified Inventory. ||
| **DatacenterLocation** | Key | string | Location of the Datacenter we will use from the Inventory. Root Folder of the Inventory is not part of the Location. Empty Location means that the Datacenter is in the Root Folder of the Inventory. Folder names in Location are separated by "/". Example Location: "MyDatacentersFolder". ||
| **Ensure** | Mandatory | Ensure | Value indicating if the Cluster should be Present or Absent. | Present, Absent |
| **HAEnabled** | Optional | bool | Indicates that VMware HA (High Availability) is enabled. ||
| **HAAdmissionControlEnabled** | Optional | bool | Indicates that virtual machines cannot be powered on if they violate availability constraints. ||
| **HAFailoverLevel** | Optional | int | Specifies a configured failover level. This is the number of physical host failures that can be tolerated without impacting the ability to meet minimum thresholds for all running virtual machines. The valid values range from 1 to 4. ||
| **HAIsolationResponse** | Optional | HAIsolationResponse | Indicates that the virtual machine should be powered off if a host determines that it is isolated from the rest of the compute resource. | PowerOff, DoNothing, Shutdown, Unset |
| **HARestartPriority** | Optional | HARestartPriority | Specifies the cluster HA restart priority. VMware HA is a feature that detects failed virtual machines and automatically restarts them on alternative ESX hosts. | Disabled, Low, Medium, High, Unset |

## Description

The resource is used to create, update and delete Clusters in a specified Datacenter. The resource also takes care to configure Cluster's High Availability (HA) settings.

## Examples

### Example 1

Creates a new Cluster in the specified Datacenter. The new Cluster has HAEnabled and HAAdmissionControlEnabled set to 'true', HAFailoverLevel is set to '3', HAIsolationResponse is 'DoNothing' and HARestartPriority is set to 'Low'.

```powershell
param(
    [Parameter(Mandatory = $true)]
    [string]
    $Server,

    [Parameter(Mandatory = $true)]
    [string]
    $User,

    [Parameter(Mandatory = $true)]
    [string]
    $Password
)

$script:configurationData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
        }
    )
}

Configuration HACluster_WithClusterToAdd_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        $Password = $Password | ConvertTo-SecureString -AsPlainText -Force
        $Credential = New-Object System.Management.Automation.PSCredential($User, $Password)

        HACluster haCluster {
            Server = $Server
            Credential = $Credential
            Ensure = 'Present'
            Location = [string]::Empty
            DatacenterName = 'Datacenter'
            DatacenterLocation = [string]::Empty
            Name = 'MyCluster'
            HAEnabled = $true
            HAAdmissionControlEnabled = $true
            HAFailoverLevel = 3
            HAIsolationResponse = 'DoNothing'
            HARestartPriority = 'Low'
        }
    }
}
```

### Example 2

Removes the Cluster from the specified Datacenter.

```powershell
param(
    [Parameter(Mandatory = $true)]
    [string]
    $Server,

    [Parameter(Mandatory = $true)]
    [string]
    $User,

    [Parameter(Mandatory = $true)]
    [string]
    $Password
)

$script:configurationData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
        }
    )
}

Configuration HACluster_WithClusterToAdd_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        $Password = $Password | ConvertTo-SecureString -AsPlainText -Force
        $Credential = New-Object System.Management.Automation.PSCredential($User, $Password)

        HACluster haCluster {
            Server = $Server
            Credential = $Credential
            Ensure = 'Absent'
            Location = [string]::Empty
            DatacenterName = 'Datacenter'
            DatacenterLocation = [string]::Empty
            Name = 'MyCluster'
        }
    }
}
```
