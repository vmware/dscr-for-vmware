# vSphere Nodes
Inside a DSC Configuration vSphereNode is a special dynamic keyword that represents a connection to a VIServer. Each vSphereNode can contain DSC Resources from the module **VMware.vSphereDSC** . Currently vSphere Nodes only work on PowerShell 7.

With standard DSC we need to supply each resource with a Server and Credential parameter so that they can establish a connection the specified VIServer because the LCM runs the resources in different runspaces and a common connection cannot be reused.

The vSphere Nodes along with the new execution engine allow the user to bundle resources and specify a common VIServer connection which gets reused.

#### Regular DSC Configuration
```
Configuration Test {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        foreach ($vCenter in $AllNodes.VCenters) {
            $Server = $vCenter.Server
            $User = $vCenter.User
            $Password = $vCenter.Password | ConvertTo-SecureString -asPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential($User, $Password)

            DatacenterFolder "MyDatacentersFolder_$($Server)" {
                Server = $Server
                Credential = $Credential
                Name = 'MyDatacentersFolder'
                Location = ''
                Ensure = 'Present'
            }

            Datacenter "MyDatacenter_$($Server)" {
                Server = $Server
                Credential = $Credential
                Name = 'MyDatacenter'
                Location = 'MyDatacentersFolder'
                Ensure = 'Present'
                DependsOn = "[DatacenterFolder]MyDatacentersFolder_$($Server)"
            }

            Folder "MyFolder_$($Server)" {
                Server = $Server
                Credential = $Credential
                Name = 'MyFolder'
                Location = ''
                DatacenterName = 'MyDatacenter'
                DatacenterLocation = 'MyDatacentersFolder'
                Ensure = 'Present'
                FolderType = 'Host'
                DependsOn = "[Datacenter]MyDatacenter_$($Server)"
            }

            Folder "MyClustersFolder_$($Server)" {
                Server = $Server
                Credential = $Credential
                Name = 'MyClustersFolder'
                Location = 'MyFolder'
                DatacenterName = 'MyDatacenter'
                DatacenterLocation = 'MyDatacentersFolder'
                Ensure = 'Present'
                FolderType = 'Host'
                DependsOn = "[Folder]MyFolder_$($Server)"
            }

            Cluster "MyCluster_$($Server)" {
                Server = $Server
                Credential = $Credential
                Name = 'MyCluster'
                Location = 'MyFolder/MyClustersFolder'
                DatacenterName = 'MyDatacenter'
                DatacenterLocation = 'MyDatacentersFolder'
                Ensure = 'Present'
                HAEnabled = $true
                HAAdmissionControlEnabled = $true
                HAFailoverLevel = 3
                HAIsolationResponse = 'DoNothing'
                HARestartPriority = 'Low'
                DrsEnabled = $true
                DrsAutomationLevel = 'FullyAutomated'
                DrsMigrationThreshold = 5
                DrsDistribution = 0
                MemoryLoadBalancing = 100
                CPUOverCommitment = 500
                DependsOn = "[Folder]MyClustersFolder_$($Server)"
            }
        }
    }
}

configurationData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
            VCenters = @(
                @{
                    Server = '<server>'
                    User = '<user>'
                    Password = '<password>'
                },
                @{
                    Server = '<server>'
                    User = '<user>'
                    Password = '<password>'
                }
            )
        }
    )
}

Test -ConfigurationData $configurationData
```

#### DSC Configuration with vSphere Nodes
```
Configuration Test {
    Import-DscResource -ModuleName 'VMware.vSphereDSC'

    # $AllNodes gets supplied via ConfigurationData parameter
    foreach($node in $AllNodes) {
        vSphereNode $node.NodeName {
            DatacenterFolder "MyDatacentersFolder_$($node.NodeName)" {
                Name = 'MyDatacentersFolder'
                Location = ''
                Ensure = 'Present'
            }

            Datacenter "MyDatacenter_$($node.NodeName)" {
                Name = 'MyDatacenter'
                Location = 'MyDatacentersFolder'
                Ensure = 'Present'
                DependsOn = "[DatacenterFolder]MyDatacentersFolder_$($node.NodeName)"
            }

            Folder "MyFolder_$($node.NodeName)" {
                Name = 'MyFolder'
                Location = ''
                DatacenterName = 'MyDatacenter'
                DatacenterLocation = 'MyDatacentersFolder'
                Ensure = 'Present'
                FolderType = 'Host'
                DependsOn = "[Datacenter]MyDatacenter_$($node.NodeName)"
            }

            Folder "MyClustersFolder_$($node.NodeName)" {
                Name = 'MyClustersFolder'
                Location = 'MyFolder'
                DatacenterName = 'MyDatacenter'
                DatacenterLocation = 'MyDatacentersFolder'
                Ensure = 'Present'
                FolderType = 'Host'
                DependsOn = "[Folder]MyFolder_$($node.NodeName)"
            }

            Cluster "MyCluster_$($node.NodeName)" {
                Name = 'MyCluster'
                Location = 'MyFolder/MyClustersFolder'
                DatacenterName = 'MyDatacenter'
                DatacenterLocation = 'MyDatacentersFolder'
                Ensure = 'Present'
                HAEnabled = $true
                HAAdmissionControlEnabled = $true
                HAFailoverLevel = 3
                HAIsolationResponse = 'DoNothing'
                HARestartPriority = 'Low'
                DrsEnabled = $true
                DrsAutomationLevel = 'FullyAutomated'
                DrsMigrationThreshold = 5
                DrsDistribution = 0
                MemoryLoadBalancing = 100
                CPUOverCommitment = 500
                DependsOn = "[Folder]MyClustersFolder_$($node.NodeName)"
            }
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
Here each resource loses the previously mandatory Server and Credentials Parameter and instead the connection is retrieved from the vSphereNode Name. Note that the vSphereNode keyword opening bracket '{' must be placed on the same row as the keyword or else a parsing error is triggered.
After the configuration is compiled the user needs to establish a connection to the VIServers specified in the vSphereNodes. This can be done using the PowerCLI cmdlet **Connect-ViServer**. This gives more freedom in terms of ways to connect to a server instead of only supporting connectons via username and password.

#### Example connection before Invoke
```
$connection = Connect-ViServer -User '<Username here>' -Password '<Password here>' -Server '<vSphereNode server name here>'

$dscConfig | Start-VmwDscConfiguration
```

When invoking a dsc configuration object that contains vSphereNodes but connections to those nodes are not established then a warning is printed to the console and those nodes get skipped during execution.
