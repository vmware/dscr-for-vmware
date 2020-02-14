<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

[DscResource()]
class VMHostScsiLunPath : VMHostEntityBaseDSC {
    <#
    .DESCRIPTION

    Specifies the name of the SCSI Lun path to the specified SCSI device in 'ScsiLunCanonicalName' key property.
    #>
    [DscProperty(Key)]
    [string] $Name

    <#
    .DESCRIPTION

    Specifies the canonical name of the SCSI device for the specified SCSI Lun path in 'Name' key property.
    #>
    [DscProperty(Key)]
    [string] $ScsiLunCanonicalName

    <#
    .DESCRIPTION

    Specifies whether the SCSI Lun path should be active.
    #>
    [DscProperty()]
    [nullable[bool]] $Active

    <#
    .DESCRIPTION

    Specifies whether the SCSI Lun path should be preferred. Only one SCSI Lun path can be preferred, so when a SCSI Lun path is made preferred, the preference is removed from the previously preferred SCSI Lun path.
    #>
    [DscProperty()]
    [nullable[bool]] $Preferred

    hidden [string] $ActiveScsiLunPathState = 'Active'

    hidden [string] $ConfigureScsiLunPathMessage = "Configuring SCSI Lun path {0} to SCSI device {1} from VMHost {2}."

    hidden [string] $CouldNotRetrieveScsiLunMessage = "Could not retrieve SCSI device {0} from VMHost {1}. For more information: {2}"
    hidden [string] $CouldNotRetrieveScsiLunPathMessage = "Could not retrieve SCSI Lun path {0} to SCSI device {1} from VMHost {2}. For more information: {3}"
    hidden [string] $CouldNotConfigureScsiLunPathMessage = "Could not configure SCSI Lun path {0} to SCSI device {1} from VMHost {2}. For more information: {3}"

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $scsiLun = $this.GetScsiLun()
            $scsiLunPath = $this.GetScsiLunPath($scsiLun)

            $this.ConfigureScsiLunPath($scsiLunPath)
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.SetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [bool] Test() {
        try {
            Write-VerboseLog -Message $this.TestMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $scsiLun = $this.GetScsiLun()
            $scsiLunPath = $this.GetScsiLunPath($scsiLun)

            $result = !$this.ShouldConfigureScsiLunPath($scsiLunPath)

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [VMHostScsiLunPath] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [VMHostScsiLunPath]::new()

            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $scsiLun = $this.GetScsiLun()
            $scsiLunPath = $this.GetScsiLunPath($scsiLun)

            $this.PopulateResult($result, $scsiLunPath)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the SCSI device with the specified canonical name from the specified VMHost if it exists.
    #>
    [PSObject] GetScsiLun() {
        try {
            $scsiLun = Get-ScsiLun -Server $this.Connection -VmHost $this.VMHost -CanonicalName $this.ScsiLunCanonicalName -ErrorAction Stop -Verbose:$false
            return $scsiLun
        }
        catch {
            throw ($this.CouldNotRetrieveScsiLunMessage -f $this.ScsiLunCanonicalName, $this.VMHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the SCSI Lun path with the specified name to the specified SCSI device if it exists.
    #>
    [PSObject] GetScsiLunPath($scsiLun) {
        try {
            $scsiLunPath = Get-ScsiLunPath -Name $this.Name -ScsiLun $scsiLun -ErrorAction Stop -Verbose:$false
            return $scsiLunPath
        }
        catch {
            throw ($this.CouldNotRetrieveScsiLunPathMessage -f $this.Name, $scsiLun.CanonicalName, $this.VMHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Checks if the SCSI Lun path should be configured depending on the desired 'Active' and 'Preferred' values.
    #>
    [bool] ShouldConfigureScsiLunPath($scsiLunPath) {
        $shouldConfigureScsiLunPath = @()

        if ($null -ne $this.Active) {
            $currentScsiLunPathState = $scsiLunPath.State.ToString()
            if ($this.Active) {
                $shouldConfigureScsiLunPath += ($currentScsiLunPathState -ne $this.ActiveScsiLunPathState)
            }
            else {
                $shouldConfigureScsiLunPath += ($currentScsiLunPathState -eq $this.ActiveScsiLunPathState)
            }
        }

        $shouldConfigureScsiLunPath += ($null -ne $this.Preferred -and $this.Preferred -ne $scsiLunPath.Preferred)

        return ($shouldConfigureScsiLunPath -Contains $true)
    }

    <#
    .DESCRIPTION

    Configures the SCSI Lun path with the specified name with the desired 'Active' and 'Preferred' values.
    #>
    [void] ConfigureScsiLunPath($scsiLunPath) {
        $setScsiLunPathParams = @{
            ScsiLunPath = $scsiLunPath
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        if ($null -ne $this.Active) { $setScsiLunPathParams.Active = $this.Active }
        if ($null -ne $this.Preferred) { $setScsiLunPathParams.Preferred = $this.Preferred }

        try {
            Write-VerboseLog -Message $this.ConfigureScsiLunPathMessage -Arguments @($scsiLunPath.Name, $scsiLunPath.ScsiLun.CanonicalName, $this.VMHost.Name)
            Set-ScsiLunPath @setScsiLunPathParams
        }
        catch {
            throw ($this.CouldNotConfigureScsiLunPathMessage -f $scsiLunPath.Name, $scsiLunPath.ScsiLun.CanonicalName, $this.VMHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $scsiLunPath) {
        $result.Server = $this.Connection.Name
        $result.VMHostName = $this.VMHost.Name
        $result.Name = $scsiLunPath.Name
        $result.ScsiLunCanonicalName = $scsiLunPath.ScsiLun.CanonicalName
        $result.Active = if ($scsiLunPath.State.ToString() -eq $this.ActiveScsiLunPathState) { $true } else { $false }
        $result.Preferred = $scsiLunPath.Preferred
    }
}
