# vSphere Nodes

Inside a **DSC Configuration** a **vSphereNode** is a special dynamic keyword that represents a connection to a **VIServer**. Each **vSphereNode** can contain **DSC Resources** from the module **VMware.vSphereDSC**. Currently **vSphere Nodes** only work on **PowerShell 7**.

With standard DSC we need to supply each **DSC Resource** with a **Server** and **Credential** properties so that they can establish a connection to the specified **VIServer** because the **LCM** runs the **DSC Resources** in different runspaces and a common connection cannot be reused.

The **vSphere Nodes** along with the new execution engine allow the user to bundle **DSC Resources** and specify a common **VIServer** connection which gets reused.

## **DSC Configuration** with a standard **Node**

```powershell
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

Configuration Datacenter_Config {
    Param(
        [string]
        $Server,

        [System.Management.Automation.PSCredential]
        $Credential
    )

    Import-DscResource -ModuleName 'VMware.vSphereDSC'

    Node 'localhost' {
        Datacenter 'MyDatacenter' {
            Server = $Server
            Credential = $Credential
            Name = 'MyDatacenter'
            Location = ''
            Ensure = 'Present'
        }
    }
}
```

## **DSC Configuration** with a **vSphere Node**

```powershell
Configuration Datacenter_Config {
    Import-DscResource -ModuleName 'VMware.vSphereDSC'

    vSphereNode '10.23.112.235' {
        Datacenter 'MyDatacenter' {
            Name = 'MyDatacenter'
            Location = ''
            Ensure = 'Present'
        }
    }
}

$dscConfiguration = New-VmwDscConfiguration -Path '.\Datacenter_Config.ps1'
```

Here each **VMware.vSphere DSC Resource** loses the previously mandatory **Server** and **Credential** properties and instead the connection is retrieved from the **vSphereNode** name. Note that the **vSphereNode** keyword opening bracket **'{'** must be placed on the same row as the keyword or else a parsing error is triggered.

## **DSC Configuration** with multiple **vSphere Nodes**

```powershell
$script:configurationData = @{
    AllNodes = @(
        @{
            NodeName = '10.23.112.235'
        },
        @{
            NodeName = '10.23.112.236'
        }
    )
}

Configuration Datacenter_Config {
    Import-DscResource -ModuleName 'VMware.vSphereDSC'

    vSphereNode $AllNodes.NodeName {
        Datacenter 'MyDatacenter' {
            Name = 'MyDatacenter'
            Location = ''
            Ensure = 'Present'
        }
    }
}

$dscConfiguration = New-VmwDscConfiguration -Path '.\Datacenter_Config.ps1'
```

Here **AllNodes** can contain multiple **VIServer** connections that can be specified via the **NodeName** property and a separate **Node** object will be generated for each connection.

Common properties for all nodes can be specified with a **$AllNodes** entry that has a **NodeName** property that equals **'*'**. This value will be applied to all other **Nodes**. **Nodes** with duplicate **NodeName** properties will result in a exception.

```powershell
ConfigurationData = @{
        AllNodes = @(
            @{
                NodeName = '<Connection>' # Example: 10.10.10.10
            },
            @{
                NodeName = '<Connection>'
            },
            @{
                NodeName = '*'
                VMHostName = '10.23.112.237'
            }
        )
    }
```
---

After the **DSC Configuration** is compiled the user needs to establish a connection to the **VIServers** specified in the **vSphereNodes** before executing the **DSC Configuration**. This can be done using the PowerCLI cmdlet **Connect-VIServer**. This gives more freedom in terms of ways to connect to a server instead of only supporting connectons via username and password.

### Example **VIServer** connection before calling **Start-VmwDscConfiguration** cmdlet

```powershell
$connection = Connect-ViServer -User '<Username here>' -Password '<Password here>' -Server '<vSphereNode server name here>'

$dscConfiguration | Start-VmwDscConfiguration
```

When invoking a **VmwDscConfiguration** object that contains **vSphereNodes** but connections to those nodes are not established then a warning is printed to the console and those **Nodes** get skipped during execution.
