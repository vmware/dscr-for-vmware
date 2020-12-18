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

    Retrieves information about the VMHost storage for the specified VMHost.
    #>

    $defaultErrorActionPreference = $global:ErrorActionPreference
    $global:ErrorActionPreference = 'Stop'

    try {
        $script:VIServer = Connect-VIServer -Server $Server -Credential $Credential
        $script:VMHost = Get-VMHost -Server $script:VIServer -Name $Name
        $script:VMHostStorage = Get-VMHostStorage -Server $script:VIServer -VMHost $script:VMHost

        $script:InitialSoftwareIScsiEnabled = $script:VMHostStorage.SoftwareIScsiEnabled
    }
    finally {
        $global:ErrorActionPreference = $defaultErrorActionPreference
        Disconnect-VIServer -Server $Server -Confirm:$false
    }
}

function Test-CleanUp {
    <#
    .SYNOPSIS

    Restarts the specified VMHost after the Integration Tests.
    #>

    $defaultErrorActionPreference = $global:ErrorActionPreference
    $global:ErrorActionPreference = 'Stop'

    try {
        $script:VIServer = Connect-VIServer -Server $Server -Credential $Credential
        $script:VMHost = Get-VMHost -Server $script:VIServer -Name $Name

        $script:VMHost = Set-VMHost -Server $script:VIServer -VMHost $script:VMHost -State Maintenance -Confirm:$false
        Restart-VMHost -Server $script:VIServer -VMHost $script:VMHost -Confirm:$false

        if ($script:VIServer.Connection.ProductLine -eq 'embeddedEsx') {
            Assert-VMHostIsInDesiredState -VIServer $script:VIServer -DesiredState 'Maintenance' -RequiresVIServerConnection $true
        }
        else {
            Assert-VMHostIsInDesiredState -VIServer $script:VIServer -DesiredState 'NotResponding' -RequiresVIServerConnection $false
            Assert-VMHostIsInDesiredState -VIServer $script:VIServer -DesiredState 'Maintenance' -RequiresVIServerConnection $false
        }

        Get-VMHost -Server $script:VIServer -Name $Name | Set-VMHost -Server $script:VIServer -State Connected -Confirm:$false | Out-Null
    }
    finally {
        $global:ErrorActionPreference = $defaultErrorActionPreference
        Disconnect-VIServer -Server $Server -Confirm:$false
    }
}

function Assert-VMHostIsInDesiredState {
    <#
    .SYNOPSIS

    Asserts that the VMHost used in the Integration Tests is in the
    specified desired state.
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [PSObject] $VIServer,

        [Parameter(Mandatory = $true)]
        [string] $DesiredState,

        [Parameter(Mandatory = $true)]
        [bool] $RequiresVIServerConnection
    )

    $restartTimeoutMinutes = 5
    $sleepTimeInSeconds = 10
    $elapsedTimeInSeconds = 0

    while ($true) {
        $timeSpan = New-TimeSpan -Seconds $elapsedTimeInSeconds
        if ($timeSpan.Minutes -gt $restartTimeoutMinutes) {
            throw "VMHost $Name is not in Maintenance mode."
        }

        Start-Sleep -Seconds $sleepTimeInSeconds
        $elapsedTimeInSeconds += $sleepTimeInSeconds

        try {
            if ($RequiresVIServerConnection) {
                $VIServer = Connect-VIServer -Server $Server -Credential $Credential
            }

            $vmHost = Get-VMHost -Server $VIServer -Name $Name
            if ($vmHost.ConnectionState.ToString() -eq $DesiredState) {
                break
            }
        }
        catch {
            Write-Verbose -Message "VMHost $Name is still not in $DesiredState State."
        }

        $vmHost = Get-VMHost -Server $VIServer -Name $Name
        if ($vmHost.ConnectionState.ToString() -eq $DesiredState) {
            break
        }
    }
}
