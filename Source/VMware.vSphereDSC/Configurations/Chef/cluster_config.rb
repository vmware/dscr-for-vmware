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
