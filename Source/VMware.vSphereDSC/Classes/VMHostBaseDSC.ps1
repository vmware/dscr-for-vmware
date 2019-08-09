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

    Restarts the specified VMHost so that the Update of the VMHost Configuration is successful.
    #>
    [void] RestartVMHost($vmHost) {
        try {
            Restart-VMHost -Server $this.Connection -VMHost $vmHost -Confirm:$false -ErrorAction Stop
        }
        catch {
            throw "Cannot restart VMHost $($vmHost.Name). For more information: $($_.Exception.Message)"
        }

        $sleepTimeInSeconds = 30

        $viServer = $null
        $restartedVMHost = $null

        while ($true) {
            Start-Sleep -Seconds $sleepTimeInSeconds

            try {
                $viServer = Connect-VIServer -Server $this.Server -Credential $this.Credential -ErrorAction Stop
                $restartedVMHost = Get-VMHost -Server $viServer -Name $this.Name -ErrorAction Stop

                if ($restartedVMHost.ConnectionState.ToString() -eq $this.MaintenanceState) {
                    break
                }
            }
            catch {
                Write-Verbose -Message "VMHost $($this.Name) is still not in $($this.MaintenanceState) State."
            }
        }

        Write-Verbose "VMHost $($this.Name) is successfully restarted and in $($this.MaintenanceState) State."
    }
}
