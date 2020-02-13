<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-VMHostVssPortGroupShapingProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssPortGroupShapingProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        VMHostName = $script:constants.VMHostName
        Name = $script:constants.VirtualPortGroupName
        Ensure = 'Present'
    }

    $vmHostVssPortGroupShapingProperties
}

function New-MocksForVMHostVssPortGroupShaping {
    [CmdletBinding()]

    $viServerMock = $script:viServer
    $vmHostMock = $script:vmHost
    $virtualPortGroupMock = $script:virtualPortGroup

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VirtualPortGroup -MockWith { return $virtualPortGroupMock }.GetNewClosure() -Verifiable
}

function New-MocksInSet {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssPortGroupShapingProperties = New-VMHostVssPortGroupShapingProperties

    $vmHostVssPortGroupShapingProperties.Enabled = $script:constants.ShapingEnabled
    $vmHostVssPortGroupShapingProperties.AverageBandwidth = $script:constants.AverageBandwidth
    $vmHostVssPortGroupShapingProperties.PeakBandwidth = $script:constants.PeakBandwidth
    $vmHostVssPortGroupShapingProperties.BurstSize = $script:constants.BurstSize

    $networkSystemMock = $script:vmHostNetworkSystem

    Mock -CommandName Get-View -MockWith { return $networkSystemMock }.GetNewClosure() -Verifiable
    Mock -CommandName Update-VirtualPortGroup -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostVssPortGroupShapingProperties
}

function New-MocksWhenTheShapingPolicySettingsAreNonMatching {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssPortGroupShapingProperties = New-VMHostVssPortGroupShapingProperties

    $vmHostVssPortGroupShapingProperties.Enabled = !$script:constants.ShapingEnabled
    $vmHostVssPortGroupShapingProperties.BurstSize = $script:constants.BurstSize + $script:constants.BurstSize

    $vmHostVssPortGroupShapingProperties
}

function New-MocksWhenTheShapingPolicySettingsAreMatching {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssPortGroupShapingProperties = New-VMHostVssPortGroupShapingProperties

    $vmHostVssPortGroupShapingProperties.Enabled = $script:constants.ShapingEnabled
    $vmHostVssPortGroupShapingProperties.AverageBandwidth = $script:constants.AverageBandwidth
    $vmHostVssPortGroupShapingProperties.PeakBandwidth = $script:constants.PeakBandwidth
    $vmHostVssPortGroupShapingProperties.BurstSize = $script:constants.BurstSize

    $vmHostVssPortGroupShapingProperties
}
