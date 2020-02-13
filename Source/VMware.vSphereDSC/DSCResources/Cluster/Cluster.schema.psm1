<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

$script:moduleRoot = (Get-Item -Path $PSScriptRoot).Parent.Parent.FullName
. "$script:moduleRoot/VMware.vSphereDSC.CompositeResourcesHelper.ps1"

Configuration Cluster {
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Server,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]
        $Location,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $DatacenterName,

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]
        $DatacenterLocation,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Present', 'Absent')]
        [string]
        $Ensure,

        [Parameter(Mandatory = $false)]
        [nullable[bool]]
        $HAEnabled,

        [Parameter(Mandatory = $false)]
        [nullable[bool]]
        $HAAdmissionControlEnabled,

        [Parameter(Mandatory = $false)]
        [nullable[int]]
        $HAFailoverLevel,

        [Parameter(Mandatory = $false)]
        [ValidateSet('PowerOff', 'DoNothing', 'Shutdown', 'Unset')]
        [string]
        $HAIsolationResponse = 'Unset',

        [Parameter(Mandatory = $false)]
        [ValidateSet('Disabled', 'Low', 'Medium', 'High', 'Unset')]
        [string]
        $HARestartPriority = 'Unset',

        [Parameter(Mandatory = $false)]
        [nullable[bool]]
        $DrsEnabled,

        [Parameter(Mandatory = $false)]
        [ValidateSet('FullyAutomated', 'Manual', 'PartiallyAutomated', 'Disabled', 'Unset')]
        [string]
        $DrsAutomationLevel = 'Unset',

        [Parameter(Mandatory = $false)]
        [nullable[int]]
        $DrsMigrationThreshold,

        [Parameter(Mandatory = $false)]
        [nullable[int]]
        $DrsDistribution,

        [Parameter(Mandatory = $false)]
        [nullable[int]]
        $MemoryLoadBalancing,

        [Parameter(Mandatory = $false)]
        [nullable[int]]
        $CPUOverCommitment
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    # Constructs HACluster Resource Block.
    $nullableHAClusterProperties = @{
        HAEnabled = $HAEnabled
        HAAdmissionControlEnabled = $HAAdmissionControlEnabled
        HAFailoverLevel = $HAFailoverLevel
    }
    $haClusterProperties = @{
        Server = $Server
        Credential = $Credential
        Ensure = $Ensure
        Location = $Location
        DatacenterName = $DatacenterName
        DatacenterLocation = $DatacenterLocation
        Name = $Name
        HAIsolationResponse = $HAIsolationResponse
        HARestartPriority = $HARestartPriority
    }

    Push-NullablePropertiesToDscResourceBlock -ResourceBlockProperties $haClusterProperties -NullableProperties $nullableHAClusterProperties
    New-DscResourceBlock -ResourceName 'HACluster' -Properties $haClusterProperties

    # Constructs DrsCluster Resource Block.
    $nullableDrsClusterProperties = @{
        DrsEnabled = $DrsEnabled
        DrsMigrationThreshold = $DrsMigrationThreshold
        DrsDistribution = $DrsDistribution
        MemoryLoadBalancing = $MemoryLoadBalancing
        CPUOverCommitment = $CPUOverCommitment
    }
    $drsClusterProperties = @{
        Server = $Server
        Credential = $Credential
        Ensure = $Ensure
        Location = $Location
        DatacenterName = $DatacenterName
        DatacenterLocation = $DatacenterLocation
        Name = $Name
        DrsAutomationLevel = $DrsAutomationLevel
    }

    Push-NullablePropertiesToDscResourceBlock -ResourceBlockProperties $drsClusterProperties -NullableProperties $nullableDrsClusterProperties
    New-DscResourceBlock -ResourceName 'DrsCluster' -Properties $drsClusterProperties
}
