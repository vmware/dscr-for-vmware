# vSphere Nodes
Inside a DSC Configuration vSphereNode is a special dynamic keyword that represents a connection to a VIServer. Each vSphereNode can contain DSC Resources from the module **VMware.vSphereDSC**. Currently vSphere Nodes only work on PowerShell 7.

With standard DSC we need to supply each resource with a Server and Credential parameter so that they can establish a connection the specified VIServer because the LCM runs the resources in different runspaces and a common connection cannot be reused.

The vSphere Nodes along with the new execution engine allow the user to bundle resources and specify a common VIServer connection which gets reused.

## DSC Configurations with a Single Node Examples

#### Regular DSC Configuration
```powershell
Configuration Test {
    Import-DscResource -ModuleName 'VMware.vSphereDSC'

    Node 'localhost' {
        DatacenterFolder "MyDatacentersFolder" {
            Server = '<server here>'
            Credential = '<credentials object here>'
            Name = 'MyDatacentersFolder'
            Location = ''
            Ensure = 'Present'
        }

        Datacenter "MyDatacenter" {
            Server = '<server here>'
            Credential = '<credentials object here>'
            Name = 'MyDatacenter'
            Location = 'MyDatacentersFolder'
            Ensure = 'Present'
            DependsOn = "[DatacenterFolder]MyDatacentersFolder"
        }
    }
}

Test
```

#### DSC Configuration with vSphere Nodes
```powershell
Configuration Test {
    Import-DscResource -ModuleName 'VMware.vSphereDSC'

    vSphereNode '<server name goes here>' {
        DatacenterFolder "MyDatacentersFolder" {
            Name = 'MyDatacentersFolder'
            Location = ''
            Ensure = 'Present'
        }

        Datacenter "MyDatacenter" {
            Name = 'MyDatacenter'
            Location = 'MyDatacentersFolder'
            Ensure = 'Present'
            DependsOn = "[DatacenterFolder]MyDatacentersFolder"
        }
    }
}

$splat = @{
    ConfigName = 'Test'
}

$dscConfig = New-VmwDscConfiguration @splat
```

Here each **VMware.vSphere** DSC Resource loses the previously mandatory Server and Credentials Parameters and instead the connection is retrieved from the **vSphereNode** Name. Note that the **vSphereNode** keyword opening bracket '{' must be placed on the same row as the keyword or else a parsing error is triggered.

## DSC Configuration with multiple Nodes Example
```powershell
Configuration Test {
    Import-DscResource -ModuleName 'VMware.vSphereDSC'

    # $AllNodes gets supplied via ConfigurationData parameter
    vSphereNode $AllNodes.NodeName {
        DatacenterFolder "MyDatacentersFolder" {
            Name = 'MyDatacentersFolder'
            Location = ''
            Ensure = 'Present'
        }

        Datacenter "MyDatacenter" {
            Name = 'MyDatacenter'
            Location = 'MyDatacentersFolder'
            Ensure = 'Present'
            DependsOn = "[DatacenterFolder]MyDatacentersFolder"
        }
    }
}

$splat = @{
    ConfigName = 'Test'
    ConfigurationData = @{
        AllNodes = @(
            @{
                NodeName = '<Connection>' # Example: 10.10.10.10
            },
            @{
                NodeName = '<Connection>'
            }
        )
    }
}

$dscConfig = New-VmwDscConfiguration @splat
```
Here $AllNodes can contain multiple ViServer connections that can be specified via the **NodeName** property and a separate node object will be generated for each connection.

Common properties for all nodes can be specified with a **$AllNodes** entry that has a Nodename property that equals '*'. This value will be applied to all other Nodes. Nodes with duplicate **NodeName** properties will result in a exception.
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
                MyProp = 'common'
            }
        )
    }
```
---

After the configuration is compiled the user needs to establish a connection to the VIServers specified in the vSphereNodes before executing the configuration. This can be done using the PowerCLI cmdlet **Connect-VIServer**. This gives more freedom in terms of ways to connect to a server instead of only supporting connectons via username and password.

#### Example connection before Invoke
```powershell
$connection = Connect-ViServer -User '<Username here>' -Password '<Password here>' -Server '<vSphereNode server name here>'

$dscConfig | Start-VmwDscConfiguration
```

When invoking a DSC configuration object that contains vSphereNodes but connections to those nodes are not established then a warning is printed to the console and those nodes get skipped during execution.
