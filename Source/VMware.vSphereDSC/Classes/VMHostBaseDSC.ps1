<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

class VMHostBaseDSC : BaseDSC {
    <#
    .DESCRIPTION

    Name of the VMHost to configure.
    #>
    [DscProperty(Key)]
    [string] $Name

    <#
    .DESCRIPTION

    Specifies the time in minutes to wait for the VMHost to restart before timing out
    and aborting the operation. The default value is 5 minutes.
    #>
    [DscProperty()]
    [int] $RestartTimeoutMinutes = 5

    hidden [string] $NotRespondingState = 'NotResponding'
    hidden [string] $MaintenanceState = 'Maintenance'

    <#
    .DESCRIPTION

    Returns the VMHost with the specified Name on the specified Server.
    If the VMHost is not found, the method writes an error.
    #>
    [PSObject] GetVMHost() {
        try {
            $vmHost = Get-VMHost -Server $this.Connection -Name $this.Name -ErrorAction Stop
            return $vmHost
        }
        catch {
            throw "VMHost with name $($this.Name) was not found. For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Checks if the specified VMHost is in Maintenance mode and if not, throws an exception.
    #>
    [void] EnsureVMHostIsInMaintenanceMode($vmHost) {
        if ($vmHost.ConnectionState.ToString() -ne $this.MaintenanceState) {
            throw "The Resource Update operation requires the VMHost $($vmHost.Name) to be in a Maintenance mode."
        }
    }

    <#
    .DESCRIPTION

    Ensures that the specified VMHost is restarted successfully in the specified period of time. If the elapsed time is
    longer than the desired time for restart, the method throws an exception.
    #>
    [void] EnsureRestartTimeoutIsNotReached($elapsedTimeInSeconds) {
        $timeSpan = New-TimeSpan -Seconds $elapsedTimeInSeconds
        if ($this.RestartTimeoutMinutes -le $timeSpan.Minutes) {
            throw "Aborting the operation. VMHost $($this.Name) could not be restarted successfully in $($this.RestartTimeoutMinutes) minutes."
        }
    }

    <#
    .DESCRIPTION

    Ensures that the specified VMHost is in the desired state after successful restart operation.
    #>
    [void] EnsureVMHostIsInDesiredState($requiresVIServerConnection, $desiredState) {
        $sleepTimeInSeconds = 10
        $elapsedTimeInSeconds = 0

        while ($true) {
            $this.EnsureRestartTimeoutIsNotReached($elapsedTimeInSeconds)

            Start-Sleep -Seconds $sleepTimeInSeconds
            $elapsedTimeInSeconds += $sleepTimeInSeconds

            try {
                if ($requiresVIServerConnection) {
                    $this.ConnectVIServer()
                }

                $vmHost = $this.GetVMHost()
                if ($vmHost.ConnectionState.ToString() -eq $desiredState) {
                    break
                }

                Write-Verbose -Message "VMHost $($this.Name) is still not in $desiredState State."
            }
            catch {
                <#
                Here the message used in the try block is written again in the case when an exception is thrown
                when retrieving the VMHost or establishing a Connection. This way the user still gets notified
                that the VMHost is not in the Desired State.
                #>
                Write-Verbose -Message "VMHost $($this.Name) is still not in $desiredState State."
            }
        }

        Write-Verbose -Message "VMHost $($this.Name) is successfully restarted and in $desiredState State."
    }

    <#
    .DESCRIPTION

    Restarts the specified VMHost so that the Update of the VMHost Configuration is successful.
    #>
    [void] RestartVMHost($vmHost) {
        try {
            Restart-VMHost -Server $this.Connection -VMHost $vmHost -Confirm:$false -ErrorAction Stop
        }
        catch {
            throw "Cannot restart VMHost $($vmHost.Name). For more information: $($_.Exception.Message)"
        }

        <#
        If the Connection is directly to a vCenter we do not need to establish a new connection so we pass $false
        to the method 'EnsureVMHostIsInCorrectState'. When the Connection is directly to an ESXi, after a successful
        restart the ESXi is down so new Connection needs to be established to check the ESXi state. So we pass $true
        to the method 'EnsureVMHostIsInCorrectState'.
        #>
        if ($this.Connection.ProductLine -eq $this.vCenterProductId) {
            $this.EnsureVMHostIsInDesiredState($false, $this.NotRespondingState)
            $this.EnsureVMHostIsInDesiredState($false, $this.MaintenanceState)
        }
        else {
            $this.EnsureVMHostIsInDesiredState($true, $this.MaintenanceState)
        }
    }
}
