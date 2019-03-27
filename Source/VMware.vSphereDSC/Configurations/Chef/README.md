# Desired State Configuration Resources for VMware Examples with Chef

## Getting Started
## Requirements
1. Install [Chef Development Kit](https://docs.chef.io/install_dk.html)
2. To apply your configuration run the following command in Powershell:
    ```powershell
    chef-client -z <path to your config file>
    ```

## Examples
All shown examples are located [here](https://github.com/vmware/dscr-for-vmware/tree/master/Source/VMware.vSphereDSC/Configurations/Chef).

### Example 1
Creates a new Cluster in the specified Datacenter. The new Cluster has HAEnabled and HAAdmissionControlEnabled set to 'true', HAFailoverLevel is set to '3', HAIsolationResponse is 'DoNothing' and HARestartPriority is set to 'Low'.

```ruby
dsc_resource 'ha-cluster' do
    resource :hacluster
    property :server, '<server>'
    property :credential, ps_credential('<user>', '<password>')
    property :name, 'MyChefCluster'
    property :datacenterinventorypath, ''
    property :datacenter, 'Datacenter'
    property :ensure, 'Present'
    property :haenabled, true
    property :haadmissioncontrolenabled, true
    property :hafailoverlevel, 3
    property :haisolationresponse, 'DoNothing'
    property :harestartpriority, 'Low'
end
```

### Example 2
Creates a new Cluster in the specified Datacenter. The new Cluster has HAEnabled and HAAdmissionControlEnabled set to 'true', HAFailoverLevel is set to '3', HAIsolationResponse is 'DoNothing' and HARestartPriority is set to 'Low'. The new Cluster also has DrsEnabled set to 'true', DrsAutomationLevel is 'FullyAutomated', DrsMigrationThreshold is set to '5'. It has the following options specified: DrsDistribution is set to '0', MemoryLoadBalancing is set to '100' and CPUOverCommitment is set to '500'.

```ruby
dsc_script 'cluster' do
    imports 'VMware.vSphereDSC'
    configuration_data <<-EOH
        @{
            AllNodes = @(
                @{
                    NodeName = "localhost";
                    PSDscAllowPlainTextPassword = $true
                })
        }
    EOH
    code <<-EOH
        $Server = '<server>'
        $User = '<user>'
        $Password = ConvertTo-SecureString -String '<password>' -AsPlainText -Force
        $Credential = New-Object System.Management.Automation.PSCredential($User, $Password)

        Cluster cluster
        {
            Server = $Server
            Credential = $Credential
            Ensure = 'Present'
            DatacenterInventoryPath = [string]::Empty
            Datacenter = 'Datacenter'
            Name = 'MyChefCluster'
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
        }
    EOH
end
```

For more information on how to write your configurations with Chef, you can refer to the documentation [here](https://docs.chef.io/resource_dsc_resource.html) and [here](https://docs.chef.io/resource_dsc_script.html).
