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

    Retrieves information about the VMHost and the Datacenter where the VMHost is located.
    It also retrieves the names of two unused Scsi logical units.
    #>

    $defaultErrorActionPreference = $global:ErrorActionPreference
    $global:ErrorActionPreference = 'Stop'

    try {
        $script:VIServer = Connect-VIServer -Server $Server -Credential $Credential

        $script:VMHost = Get-VMHost -Server $script:VIServer | Select-Object -First 1
        if ($null -eq $script:VMHost) {
            throw "Could not find a VMHost on vCenter Server $Server."
        }

        Get-DatacenterInformation
        Get-ScsiLunInformation
    }
    finally {
        $global:ErrorActionPreference = $defaultErrorActionPreference
        Disconnect-VIServer -Server $Server -Confirm:$false
    }
}

function Get-DatacenterInformation {
    <#
    .SYNOPSIS

    Retrieves the name and the location of the Datacenter in which the VMHost is located.
    #>

    $script:Datacenter = Get-Datacenter -Server $script:VIServer -VMHost $script:VMHost | Select-Object -First 1
    if ($null -eq $script:Datacenter) {
        throw "Could not find a Datacenter on vCenter Server $Server."
    }

    $inventoryRootFolder = Get-Folder -Server $script:VIServer -NoRecursion

    $datacenterLocationItems = @()
    $datacenterFolder = $script:Datacenter.ParentFolder

    $script:DatacenterLocation = $null
    if ($datacenterFolder.Id -eq $inventoryRootFolder.Id) {
        $script:DatacenterLocation = [string]::Empty
    }
    else {
        $datacenterLocationItems += $datacenterFolder.Name
        $currentFolder = $datacenterFolder.Parent
        while ($true) {
            if ($currentFolder.Id -eq $inventoryRootFolder.Id) {
                break
            }

            $datacenterLocationItems += $currentFolder.Name
            $currentFolder = $currentFolder.Parent
        }

        [array]::Reverse($datacenterLocationItems)

        $script:DatacenterLocation = $datacenterLocationItems -Join '/'
    }
}

function Get-ScsiLunInformation {
    <#
    .SYNOPSIS

    Retrieves the names of two unused Scsi logical units.
    #>

    $datastoreSystem = Get-View -Server $script:VIServer -Id $script:VMHost.ExtensionData.ConfigManager.DatastoreSystem
    $scsiLuns = $datastoreSystem.QueryAvailableDisksForVmfs($null) | Select-Object -First 2

    if ($scsiLuns.Length -lt 2) {
        throw 'The Integration Tests require two unused Scsi logical units to be available.'
    }

    $script:ScsiLunCanonicalNames = $scsiLuns | Select-Object -ExpandProperty CanonicalName
}
