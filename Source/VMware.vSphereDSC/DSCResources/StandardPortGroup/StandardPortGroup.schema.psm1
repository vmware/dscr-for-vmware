<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

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
        [int]
        $VLanId,

        [Parameter(Mandatory = $false)]
        [bool]
        $AllowPromiscuous,

        [Parameter(Mandatory = $false)]
        [bool]
        $AllowPromiscuousInherited,

        [Parameter(Mandatory = $false)]
        [bool]
        $ForgedTransmits,

        [Parameter(Mandatory = $false)]
        [bool]
        $ForgedTransmitsInherited,

        [Parameter(Mandatory = $false)]
        [bool]
        $MacChanges,

        [Parameter(Mandatory = $false)]
        [bool]
        $MacChangesInherited,

        [Parameter(Mandatory = $false)]
        [bool]
        $Enabled,

        [Parameter(Mandatory = $false)]
        [long]
        $AverageBandwidth,

        [Parameter(Mandatory = $false)]
        [long]
        $PeakBandwidth,

        [Parameter(Mandatory = $false)]
        [long]
        $BurstSize,

        [Parameter(Mandatory = $false)]
        [bool]
        $FailbackEnabled,

        [Parameter(Mandatory = $false)]
        [ValidateSet('LoadBalanceIP', 'LoadBalanceSrcMac', 'LoadBalanceSrcId', 'ExplicitFailover')]
        [string]
        $LoadBalancingPolicy,

        [Parameter(Mandatory = $false)]
        [string[]]
        $MakeNicActive,

        [Parameter(Mandatory = $false)]
        [string[]]
        $MakeNicStandby,

        [Parameter(Mandatory = $false)]
        [string[]]
        $MakeNicUnused,

        [Parameter(Mandatory = $false)]
        [ValidateSet('LinkStatus', 'BeaconProbing')]
        [string]
        $NetworkFailoverDetectionPolicy,

        [Parameter(Mandatory = $false)]
        [bool]
        $NotifySwitches,

        [Parameter(Mandatory = $false)]
        [bool]
        $InheritFailback,

        [Parameter(Mandatory = $false)]
        [bool]
        $InheritFailoverOrder,

        [Parameter(Mandatory = $false)]
        [bool]
        $InheritLoadBalancingPolicy,

        [Parameter(Mandatory = $false)]
        [bool]
        $InheritNetworkFailoverDetectionPolicy,

        [Parameter(Mandatory = $false)]
        [bool]
        $InheritNotifySwitches
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    VMHostVssPortGroup VMHostVssPortGroup {
        Server = $Server
        Credential = $Credential
        VMHostName = $VMHostName
        Name = $Name
        VssName = $VssName
        Ensure = $Ensure
        VLanId = $VLanId
    }

    VMHostVssPortGroupSecurity VMHostVssPortGroupSecurity {
        Server = $Server
        Credential = $Credential
        VMHostName = $VMHostName
        Name = $Name
        Ensure = $Ensure
        AllowPromiscuous = $AllowPromiscuous
        AllowPromiscuousInherited = $AllowPromiscuousInherited
        ForgedTransmits = $ForgedTransmits
        ForgedTransmitsInherited = $ForgedTransmitsInherited
        MacChanges = $MacChanges
        MacChangesInherited = $MacChangesInherited
        DependsOn = "[VMHostVssPortGroup]VMHostVssPortGroup"
    }

    VMHostVssPortGroupShaping VMHostVssPortGroupShaping {
        Server = $Server
        Credential = $Credential
        VMHostName = $VMHostName
        Name = $Name
        Ensure = $Ensure
        Enabled = $Enabled
        AverageBandwidth = $AverageBandwidth
        PeakBandwidth = $PeakBandwidth
        BurstSize = $BurstSize
        DependsOn = "[VMHostVssPortGroup]VMHostVssPortGroup"
    }

    VMHostVssPortGroupTeaming VMHostVssPortGroupTeaming {
        Server = $Server
        Credential = $Credential
        VMHostName = $VMHostName
        Name = $Name
        Ensure = $Ensure
        FailbackEnabled = $FailbackEnabled
        LoadBalancingPolicy = $LoadBalancingPolicy
        MakeNicActive = $MakeNicActive
        MakeNicStandby = $MakeNicStandby
        MakeNicUnused = $MakeNicUnused
        NetworkFailoverDetectionPolicy = $NetworkFailoverDetectionPolicy
        NotifySwitches = $NotifySwitches
        InheritFailback = $InheritFailback
        InheritFailoverOrder = $InheritFailoverOrder
        InheritLoadBalancingPolicy = $InheritLoadBalancingPolicy
        InheritNetworkFailoverDetectionPolicy = $InheritNetworkFailoverDetectionPolicy
        InheritNotifySwitches = $InheritNotifySwitches
        DependsOn = "[VMHostVssPortGroup]VMHostVssPortGroup"
    }
}
