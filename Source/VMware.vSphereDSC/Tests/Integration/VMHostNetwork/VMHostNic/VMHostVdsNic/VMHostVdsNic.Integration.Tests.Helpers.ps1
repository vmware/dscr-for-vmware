<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

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

    Creates a new VDSwitch in the Datacenter of the retrieved VMHost.
    Creates a new VDPortGroup in the VDSwitch.
    Moves the VMHost to the VDSwitch.
    Creates a new VMKernel NIC connected to the VDPortGroup.
    #>

    $defaultErrorActionPreference = $global:ErrorActionPreference
    $global:ErrorActionPreference = 'Stop'

    try {
        $script:VIServer = Connect-VIServer -Server $Server -Credential $Credential

        $script:VMHost = Get-VMHost -Server $script:VIServer | Select-Object -First 1
        if ($null -eq $script:VMHost) {
            throw "Could not find a VMHost on vCenter Server $Server."
        }

        $script:Datacenter = Get-Datacenter -Server $script:VIServer -VMHost $script:VMHost

        $newVDSwitchParams = @{
            Server = $script:VIServer
            Name = 'DscVDSwitch'
            Location = $script:Datacenter
        }
        $script:VDSwitch = New-VDSwitch @newVDSwitchParams

        $newVDPortGroupParams = @{
            Server = $script:VIServer
            Name = 'DscVDPortGroup'
            VDSwitch = $script:VDSwitch
        }
        $script:VDPortGroup = New-VDPortgroup @newVDPortGroupParams

        $addVDSwitchVMHostParams = @{
            Server = $script:VIServer
            VDSwitch = $script:VDSwitch
            VMHost = $script:VMHost
        }
        Add-VDSwitchVMHost @addVDSwitchVMHostParams

        $newVMHostNetworkAdapterParams = @{
            Server = $script:VIServer
            VMHost = $script:VMHost
            VirtualSwitch = $script:VDSwitch
            PortGroup = $script:VDPortGroup
        }
        $script:VMKernelNic = New-VMHostNetworkAdapter @newVMHostNetworkAdapterParams
    }
    finally {
        $global:ErrorActionPreference = $defaultErrorActionPreference
        Disconnect-VIServer -Server $Server -Confirm:$false
    }
}

function Test-CleanUp {
    <#
    .SYNOPSIS

    Moves the retrieved VMHost to its' original location.
    Removes the VDSwitch from the Datacenter of the retrieved VMHost.
    #>

    $defaultErrorActionPreference = $global:ErrorActionPreference
    $global:ErrorActionPreference = 'Stop'

    try {
        $script:VIServer = Connect-VIServer -Server $Server -Credential $Credential

        $moveVMHostParams = @{
            Server = $script:VIServer
            VMHost = $script:VMHost
            Destination = $script:VMHost.Parent
            Confirm = $false
        }
        Move-VMHost @moveVMHostParams

        $removeVDSwitchParams = @{
            Server = $script:VIServer
            VDSwitch = $script:VDSwitch
            Confirm = $false
        }
        Remove-VDSwitch @removeVDSwitchParams
    }
    finally {
        $global:ErrorActionPreference = $defaultErrorActionPreference
        Disconnect-VIServer -Server $Server -Confirm:$false
    }
}
