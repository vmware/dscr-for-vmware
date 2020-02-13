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

Configuration StandardPortGroup {
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
        $VMHostName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $VssName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Present', 'Absent')]
        [string]
        $Ensure,

        [Parameter(Mandatory = $false)]
        [nullable[int]]
        $VLanId,

        [Parameter(Mandatory = $false)]
        [nullable[bool]]
        $AllowPromiscuous,

        [Parameter(Mandatory = $false)]
        [nullable[bool]]
        $AllowPromiscuousInherited,

        [Parameter(Mandatory = $false)]
        [nullable[bool]]
        $ForgedTransmits,

        [Parameter(Mandatory = $false)]
        [nullable[bool]]
        $ForgedTransmitsInherited,

        [Parameter(Mandatory = $false)]
        [nullable[bool]]
        $MacChanges,

        [Parameter(Mandatory = $false)]
        [nullable[bool]]
        $MacChangesInherited,

        [Parameter(Mandatory = $false)]
        [nullable[bool]]
        $Enabled,

        [Parameter(Mandatory = $false)]
        [nullable[long]]
        $AverageBandwidth,

        [Parameter(Mandatory = $false)]
        [nullable[long]]
        $PeakBandwidth,

        [Parameter(Mandatory = $false)]
        [nullable[long]]
        $BurstSize,

        [Parameter(Mandatory = $false)]
        [nullable[bool]]
        $FailbackEnabled,

        [Parameter(Mandatory = $false)]
        [ValidateSet('LoadBalanceIP', 'LoadBalanceSrcMac', 'LoadBalanceSrcId', 'ExplicitFailover', 'Unset')]
        [string]
        $LoadBalancingPolicy = 'Unset',

        [Parameter(Mandatory = $false)]
        [string[]]
        $ActiveNic,

        [Parameter(Mandatory = $false)]
        [string[]]
        $StandbyNic,

        [Parameter(Mandatory = $false)]
        [string[]]
        $UnusedNic,

        [Parameter(Mandatory = $false)]
        [ValidateSet('LinkStatus', 'BeaconProbing', 'Unset')]
        [string]
        $NetworkFailoverDetectionPolicy = 'Unset',

        [Parameter(Mandatory = $false)]
        [nullable[bool]]
        $NotifySwitches,

        [Parameter(Mandatory = $false)]
        [nullable[bool]]
        $InheritFailback,

        [Parameter(Mandatory = $false)]
        [nullable[bool]]
        $InheritFailoverOrder,

        [Parameter(Mandatory = $false)]
        [nullable[bool]]
        $InheritLoadBalancingPolicy,

        [Parameter(Mandatory = $false)]
        [nullable[bool]]
        $InheritNetworkFailoverDetectionPolicy,

        [Parameter(Mandatory = $false)]
        [nullable[bool]]
        $InheritNotifySwitches
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    # Constructs VMHostVssPortGroup Resource Block.
    $nullableVMHostVssPortGroupProperties = @{
        VLanId = $VLanId
    }
    $vmHostVssPortGroupProperties = @{
        Server = $Server
        Credential = $Credential
        VMHostName = $VMHostName
        Name = $Name
        VssName = $VssName
        Ensure = $Ensure
    }

    Push-NullablePropertiesToDscResourceBlock -ResourceBlockProperties $vmHostVssPortGroupProperties -NullableProperties $nullableVMHostVssPortGroupProperties
    New-DscResourceBlock -ResourceName 'VMHostVssPortGroup' -Properties $vmHostVssPortGroupProperties

    # Constructs VMHostVssPortGroupShaping Resource Block.
    $nullableVMHostVssPortGroupShapingProperties = @{
        Enabled = $Enabled
        AverageBandwidth = $AverageBandwidth
        PeakBandwidth = $PeakBandwidth
        BurstSize = $BurstSize
    }
    $vmHostVssPortGroupShapingProperties = @{
        Server = $Server
        Credential = $Credential
        VMHostName = $VMHostName
        Name = $Name
        Ensure = $Ensure
        DependsOn = "[VMHostVssPortGroup]VMHostVssPortGroup"
    }

    Push-NullablePropertiesToDscResourceBlock -ResourceBlockProperties $vmHostVssPortGroupShapingProperties -NullableProperties $nullableVMHostVssPortGroupShapingProperties
    New-DscResourceBlock -ResourceName 'VMHostVssPortGroupShaping' -Properties $vmHostVssPortGroupShapingProperties

    # Constructs VMHostVssPortGroupSecurity Resource Block.
    $nullableVMHostVssPortGroupSecurityProperties = @{
        AllowPromiscuous = $AllowPromiscuous
        AllowPromiscuousInherited = $AllowPromiscuousInherited
        ForgedTransmits = $ForgedTransmits
        ForgedTransmitsInherited = $ForgedTransmitsInherited
        MacChanges = $MacChanges
        MacChangesInherited = $MacChangesInherited
    }
    $vmHostVssPortGroupSecurityProperties = @{
        Server = $Server
        Credential = $Credential
        VMHostName = $VMHostName
        Name = $Name
        Ensure = $Ensure
        DependsOn = "[VMHostVssPortGroup]VMHostVssPortGroup"
    }

    Push-NullablePropertiesToDscResourceBlock -ResourceBlockProperties $vmHostVssPortGroupSecurityProperties -NullableProperties $nullableVMHostVssPortGroupSecurityProperties
    New-DscResourceBlock -ResourceName 'VMHostVssPortGroupSecurity' -Properties $vmHostVssPortGroupSecurityProperties

    # Constructs VMHostVssPortGroupTeaming Resource Block.
    $nullableVMHostVssPortGroupTeamingProperties = @{
        FailbackEnabled = $FailbackEnabled
        NotifySwitches = $NotifySwitches
        InheritFailback = $InheritFailback
        InheritFailoverOrder = $InheritFailoverOrder
        InheritLoadBalancingPolicy = $InheritLoadBalancingPolicy
        InheritNetworkFailoverDetectionPolicy = $InheritNetworkFailoverDetectionPolicy
        InheritNotifySwitches = $InheritNotifySwitches
    }
    $vmHostVssPortGroupTeamingProperties = @{
        Server = $Server
        Credential = $Credential
        VMHostName = $VMHostName
        Name = $Name
        Ensure = $Ensure
        LoadBalancingPolicy = $LoadBalancingPolicy
        ActiveNic = $ActiveNic
        StandbyNic = $StandbyNic
        UnusedNic = $UnusedNic
        NetworkFailoverDetectionPolicy = $NetworkFailoverDetectionPolicy
        DependsOn = "[VMHostVssPortGroup]VMHostVssPortGroup"
    }

    Push-NullablePropertiesToDscResourceBlock -ResourceBlockProperties $vmHostVssPortGroupTeamingProperties -NullableProperties $nullableVMHostVssPortGroupTeamingProperties
    New-DscResourceBlock -ResourceName 'VMHostVssPortGroupTeaming' -Properties $vmHostVssPortGroupTeamingProperties
}
