<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

$script:configurationData = @{
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

Configuration vCenter_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {
        foreach ($vCenter in $AllNodes.VCenters) {
            $Server = $vCenter.Server
            $User = $vCenter.User
            $Password = $vCenter.Password | ConvertTo-SecureString -asPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential($User, $Password)

            HACluster "HACluster_$($Server)" {
                Server = $Server
                Credential = $Credential
                Name = 'MyHACluster'
                Location = ''
                DatacenterName = 'Datacenter'
                DatacenterLocation = ''
                Ensure = 'Present'
                HAEnabled = $true
                HAAdmissionControlEnabled = $true
                HAFailoverLevel = 3
                HAIsolationResponse = 'DoNothing'
                HARestartPriority = 'Low'
            }

            DrsCluster "DrsCluster_$($Server)" {
                Server = $Server
                Credential = $Credential
                Name = 'MyDrsCluster'
                Location = ''
                DatacenterName = 'Datacenter'
                DatacenterLocation = ''
                Ensure = 'Present'
                DrsEnabled = $true
                DrsAutomationLevel = 'FullyAutomated'
                DrsMigrationThreshold = 5
                DrsDistribution = 0
                MemoryLoadBalancing = 100
                CPUOverCommitment = 500
            }

            vCenterSettings "vCenterSettings_$($Server)" {
                Server = $Server
                Credential = $Credential
                LoggingLevel = 'Warning'
                EventMaxAgeEnabled = $false
                EventMaxAge = 40
                TaskMaxAgeEnabled = $false
                TaskMaxAge = 40
                Motd = 'Hello World from motd!'
                Issue = 'Hello World from issue!'
            }

            vCenterStatistics "vCenterStatistics_$($Server)" {
                Server = $Server
                Credential = $Credential
                Period = 'Day'
                PeriodLength = 3
                Level = 2
                Enabled = $true
                IntervalMinutes = 3
            }
        }
    }
}

vCenter_Config -ConfigurationData $script:configurationData
