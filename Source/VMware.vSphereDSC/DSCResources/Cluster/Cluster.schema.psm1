<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

Configuration Cluster {
    Param(
        [Parameter(Mandatory = $true)]
        [string] $Server,

        [Parameter(Mandatory = $true)]
        [PSCredential] $Credential,

        [Parameter(Mandatory = $true)]
        [string] $Name,

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string] $Location,

        [Parameter(Mandatory = $true)]
        [string] $DatacenterName,

        [Parameter(Mandatory = $true)]
        [string] $DatacenterLocation,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Present', 'Absent')]
        [string] $Ensure,

        [Parameter(Mandatory = $false)]
        [bool] $HAEnabled,

        [Parameter(Mandatory = $false)]
        [bool] $HAAdmissionControlEnabled,

        [Parameter(Mandatory = $false)]
        [int] $HAFailoverLevel,

        [Parameter(Mandatory = $false)]
        [ValidateSet('PowerOff', 'DoNothing', 'Shutdown', 'Unset')]
        [string] $HAIsolationResponse,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Disabled', 'Low', 'Medium', 'High', 'Unset')]
        [string] $HARestartPriority,

        [Parameter(Mandatory = $false)]
        [bool] $DrsEnabled,

        [Parameter(Mandatory = $false)]
        [ValidateSet('FullyAutomated', 'Manual', 'PartiallyAutomated', 'Disabled', 'Unset')]
        [string] $DrsAutomationLevel,

        [Parameter(Mandatory = $false)]
        [int] $DrsMigrationThreshold,

        [Parameter(Mandatory = $false)]
        [int] $DrsDistribution,

        [Parameter(Mandatory = $false)]
        [int] $MemoryLoadBalancing,

        [Parameter(Mandatory = $false)]
        [int] $CPUOverCommitment
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    HACluster haCluster {
        Server = $Server
        Credential = $Credential
        Ensure = $Ensure
        Location = $Location
        DatacenterName = $DatacenterName
        DatacenterLocation = $DatacenterLocation
        Name = $Name
        HAEnabled = $HAEnabled
        HAAdmissionControlEnabled = $HAAdmissionControlEnabled
        HAFailoverLevel = $HAFailoverLevel
        HAIsolationResponse = $HAIsolationResponse
        HARestartPriority = $HARestartPriority
    }

    DrsCluster drsCluster {
        Server = $Server
        Credential = $Credential
        Ensure = $Ensure
        Location = $Location
        DatacenterName = $DatacenterName
        DatacenterLocation = $DatacenterLocation
        Name = $Name
        DrsEnabled = $DrsEnabled
        DrsAutomationLevel = $DrsAutomationLevel
        DrsMigrationThreshold = $DrsMigrationThreshold
        DrsDistribution = $DrsDistribution
        MemoryLoadBalancing = $MemoryLoadBalancing
        CPUOverCommitment = $CPUOverCommitment
    }
}
