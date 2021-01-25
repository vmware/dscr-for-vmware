<#
Copyright (c) 2018-2021 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function Test-Setup {
    <#
    .SYNOPSIS

    Retrieves the name of the iSCSI Host Bus Adapter that is used in the Integration Tests.
    Retrieves the name of the Physical Network Adapter that is used in the Integration Tests.
    #>

    $defaultErrorActionPreference = $global:ErrorActionPreference
    $global:ErrorActionPreference = 'Stop'

    try {
        $script:VIServer = Connect-VIServer -Server $Server -Credential $Credential
        $script:VMHost = Get-VMHost -Server $script:VIServer -Name $Name

        $script:VMHostStorage = Get-VMHostStorage -Server $script:VIServer -VMHost $script:VMHost
        if (!$script:VMHostStorage.SoftwareIScsiEnabled) {
            throw 'The software iSCSI adapter should be enabled.'
        }

        $script:IscsiHba = Get-VMHostHba -Server $script:VIServer -VMHost $script:VMHost -Type 'iSCSI' |
                           Select-Object -First 1

        $script:IscsiHbaName = $script:IscsiHba.Device

        $script:VMHostView = Get-View -Server $script:VIServer -Id $script:VMHost.Id -Property 'ConfigManager'
        $script:IscsiManager = Get-View -Server $script:VIServer -Id $script:VMHostView.ConfigManager.IscsiManager

        $script:PhysicalNicNames = $script:IscsiManager.QueryCandidateNics($script:IscsiHbaName) |
            Where-Object -FilterScript { $_.VnicDevice -eq [string]::Empty } |
            Select-Object -First 2 |
            Select-Object -ExpandProperty PnicDevice
        if ($script:PhysicalNicNames.Length -lt 2) {
            throw "At least two Physical Network Adapters should be available on VMHost $($script:VMHost.Name)."
        }
    }
    finally {
        $global:ErrorActionPreference = $defaultErrorActionPreference
        Disconnect-VIServer -Server $Server -Confirm:$false
    }
}

function Get-VMKernelNicNames {
    <#
    .SYNOPSIS

    Retrieves the names of the VMKernel Network Adapters that are used in the Integration Tests.
    #>

    $defaultErrorActionPreference = $global:ErrorActionPreference
    $global:ErrorActionPreference = 'Stop'

    try {
        $script:VIServer = Connect-VIServer -Server $Server -Credential $Credential
        $script:VMHost = Get-VMHost -Server $script:VIServer -Name $Name

        $standardSwitchName = $script:configurationData.AllNodes.StandardSwitchName

        $script:StandardSwitch = Get-VirtualSwitch -Server $script:VIServer -Name $standardSwitchName -VMHost $script:VMHost -Standard
        $script:vmKernelNicNames = Get-VMHostNetworkAdapter -Server $script:VIServer -VirtualSwitch $script:StandardSwitch -VMKernel |
            Select-Object -ExpandProperty Name

        # Here we need to modify the Configuration Data passed to each Configuration to include the retrieved VMKernel Network Adapter names.
        $script:configurationData.AllNodes[0].VMKernelNicNames = $script:vmKernelNicNames
    }
    finally {
        $global:ErrorActionPreference = $defaultErrorActionPreference
        Disconnect-VIServer -Server $Server -Confirm:$false
    }
}
