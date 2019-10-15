<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

<#
.SYNOPSIS
Retrieves the name and the location of the Datacenter where the specified VMHost is located.

.DESCRIPTION
Retrieves the name and the location of the Datacenter where the specified VMHost is located.
The prerequisite is that the VMHost should be added to a vCenter.

.PARAMETER Server
Specifies the vCenter Server we are going to use.

.PARAMETER Credential
Specifies the credentials needed for connection to the specified Server.

.PARAMETER VMHostName
Specifies the name of the VMHost that is going to be used.
#>
function Get-DatacenterInformation {
    [CmdletBinding()]
    [OutputType([hashtable])]
    Param(
        [Parameter(Mandatory = $true)]
        [string] $Server,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential] $Credential,

        [Parameter(Mandatory = $true)]
        [string] $VMHostName
    )

    $viServer = Connect-VIServer -Server $Server -Credential $Credential -ErrorAction Stop
    $vmHost = Get-VMHost -Server $viServer -Name $VMHostName -ErrorAction Stop
    $datacenter = Get-Datacenter -Server $viServer -VMHost $vmHost -ErrorAction Stop

    $datacenterInfo = @{}
    $datacenterInfo.Name = $datacenter.Name

    # If the Parent of the Parent Folder is $null, the Datacenter is located in the Root Folder of the Inventory.
    if ($null -eq $datacenter.ParentFolder.Parent) {
        $datacenterInfo.Location = [string]::Empty
    }
    else {
        $locationItems = @()
        $child = $datacenter.ParentFolder
        $parent = $datacenter.ParentFolder.Parent

        while ($true) {
            if ($null -eq $parent) {
                break
            }

            $locationItems += $child.Name
            $child = $parent
            $parent = $parent.Parent
        }

        # The Parent Folder of the Datacenter should be the last item in the array.
        [array]::Reverse($locationItems)

        # Folder names for Datacenter Location should be separated by '/'.
        $datacenterInfo.Location = [string]::Join('/', $locationItems)
    }

    $datacenterInfo
}
