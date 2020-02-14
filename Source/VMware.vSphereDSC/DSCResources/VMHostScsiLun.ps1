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
class VMHostScsiLun : VMHostEntityBaseDSC {
    <#
    .DESCRIPTION

    Specifies the canonical name of the SCSI device. An example of a SCSI canonical name is 'vmhba0:0:0:0'.
    #>
    [DscProperty(Key)]
    [string] $CanonicalName

    <#
    .DESCRIPTION

    Specifies the policy that the Lun must use when choosing a path. The following values are valid:
    Fixed - uses the preferred SCSI Lun path whenever possible.
    RoundRobin - load balance.
    MostRecentlyUsed - uses the most recently used SCSI Lun path.
    Unknown
    #>
    [DscProperty()]
    [MultipathPolicy] $MultipathPolicy = [MultipathPolicy]::Unset

    <#
    .DESCRIPTION

    Specifies the name of the preferred SCSI Lun path to access the SCSI Lun.
    #>
    [DscProperty()]
    [string] $PreferredScsiLunPathName

    <#
    .DESCRIPTION

    Specifies the maximum number of I/O blocks to be issued on a given path before the system tries to select a different path. Modifying this setting affects all SCSI Lun devices that are connected to the same VMHost.
    The default value is 2048. Setting this parameter to zero (0) disables switching based on blocks.
    #>
    [DscProperty()]
    [nullable[int]] $BlocksToSwitchPath

    <#
    .DESCRIPTION

    Specifies the maximum number of I/O requests to be issued on a given path before the system tries to select a different path. Modifying this setting affects all SCSI Lun devices that are connected to the same VMHost.
    The default value is 50. Setting this parameter to zero (0) disables switching based on commands. This parameter is not supported on vCenter Server 4.x.
    #>
    [DscProperty()]
    [nullable[int]] $CommandsToSwitchPath

    <#
    .DESCRIPTION

    Specifies whether to remove all partitions from the SCSI disk.
    #>
    [DscProperty()]
    [nullable[bool]] $DeletePartitions

    <#
    .DESCRIPTION

    Marks the SCSI disk as local or remote. If the value is $true, the SCSI disk is local. If the value is $false, the SCSI disk is remote.
    #>
    [DscProperty()]
    [nullable[bool]] $IsLocal

    <#
    .DESCRIPTION

    Marks the SCSI disk as an SSD or HDD. If the value is $true, the SCSI disk is SSD type. If the value is $false, the SCSI disk is HDD type.
    #>
    [DscProperty()]
    [nullable[bool]] $IsSsd

    hidden [string] $ModifyScsiLunConfigurationMessage = "Modifying the configuration of SCSI device {0} from VMHost {1}."

    hidden [string] $CouldNotRetrieveScsiLunMessage = "Could not retrieve SCSI device {0} from VMHost {1}. For more information: {2}"
    hidden [string] $CouldNotRetrieveScsiLunPathMessage = "Could not retrieve SCSI Lun path {0} to SCSI device {1} from VMHost {2}. For more information: {3}"
    hidden [string] $CouldNotRetrievePreferredScsiLunPathMessage = "Could not retrieve the preferred SCSI Lun path to SCSI device {0} from VMHost {1}. For more information: {2}"
    hidden [string] $CouldNotRetrieveScsiLunDiskInformationMessage = "Could not retrieve SCSI Lun disk information for SCSI device {0} from VMHost {1}. For more information: {2}"
    hidden [string] $CouldNotModifyScsiLunConfigurationMessage = "Could not modify the configuration of SCSI device {0} from VMHost {1}. For more information: {2}"

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $scsiLun = $this.GetScsiLun()

            $this.ModifyScsiLunConfiguration($scsiLun)
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

            $result = !$this.ShouldModifyScsiLunConfiguration($scsiLun)

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [VMHostScsiLun] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [VMHostScsiLun]::new()

            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $scsiLun = $this.GetScsiLun()

            $this.PopulateResult($result, $scsiLun)

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
            $scsiLun = Get-ScsiLun -Server $this.Connection -VmHost $this.VMHost -CanonicalName $this.CanonicalName -ErrorAction Stop -Verbose:$false
            return $scsiLun
        }
        catch {
            throw ($this.CouldNotRetrieveScsiLunMessage -f $this.CanonicalName, $this.VMHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the SCSI Lun path with the specified name to the specified SCSI device if it exists.
    #>
    [PSObject] GetScsiLunPath($scsiLun) {
        try {
            $scsiLunPath = Get-ScsiLunPath -Name $this.PreferredScsiLunPathName -ScsiLun $scsiLun -ErrorAction Stop -Verbose:$false
            return $scsiLunPath
        }
        catch {
            throw ($this.CouldNotRetrieveScsiLunPathMessage -f $this.PreferredScsiLunPathName, $scsiLun.CanonicalName, $this.VMHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the preferred SCSI Lun path to the specified SCSI device.
    #>
    [PSObject] GetPreferredScsiLunPath($scsiLun) {
        try {
            # For each SCSI device there is only one SCSI Lun path which is preferred.
            $preferredScsiLunPath = Get-ScsiLunPath -ScsiLun $scsiLun -ErrorAction Stop -Verbose:$false |
                                    Where-Object -FilterScript { $_.Preferred }
            return $preferredScsiLunPath
        }
        catch {
            throw ($this.CouldNotRetrievePreferredScsiLunPathMessage -f $scsiLun.CanonicalName, $this.VMHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Retrieves SCSI Lun disk information for the specified SCSI device.
    #>
    [PSObject] GetVMHostDisk($scsiLun) {
        try {
            $vmHostDisk = Get-VMHostDisk -ScsiLun $scsiLun -ErrorAction Stop -Verbose:$false
            return $vmHostDisk
        }
        catch {
            throw ($this.CouldNotRetrieveScsiLunDiskInformationMessage -f $scsiLun.CanonicalName, $this.VMHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Checks if the SCSI device configuration should be modified.
    #>
    [bool] ShouldModifyScsiLunConfiguration($scsiLun) {
        $shouldModifyScsiLunConfiguration = @()

        $shouldModifyScsiLunConfiguration += ($this.MultipathPolicy -ne [MultipathPolicy]::Unset -and $this.MultipathPolicy.ToString() -ne $scsiLun.MultipathPolicy.ToString())
        $shouldModifyScsiLunConfiguration += ($null -ne $this.IsLocal -and $this.IsLocal -ne $scsiLun.IsLocal)
        $shouldModifyScsiLunConfiguration += ($null -ne $this.IsSsd -and $this.IsSsd -ne $scsiLun.IsSsd)

        # 'BlocksToSwitchPath' and 'CommandsToSwitchPath' properties should determine the Desired State only when the desired Multipath policy is 'Round Robin'.
        if ($this.MultipathPolicy -eq [MultipathPolicy]::RoundRobin) {
            $shouldModifyScsiLunConfiguration += ($null -ne $this.BlocksToSwitchPath -and $this.BlocksToSwitchPath -ne [int] $scsiLun.BlocksToSwitchPath)
            $shouldModifyScsiLunConfiguration += ($null -ne $this.CommandsToSwitchPath -and $this.CommandsToSwitchPath -ne [int] $scsiLun.CommandsToSwitchPath)
        }

        if (![string]::IsNullOrEmpty($this.PreferredScsiLunPathName) -and $this.MultipathPolicy -eq [MultipathPolicy]::Fixed) {
            $scsiLunPath = $this.GetScsiLunPath($scsiLun)

            # If the found SCSI Lun path is not preferred, the SCSI device is not in a desired state.
            $shouldModifyScsiLunConfiguration += !$scsiLunPath.Preferred
        }

        # If the VMHost disk has existing partitions and 'DeletePartitions' is specified, the SCSI device is not in a desired state.
        if ($null -ne $this.DeletePartitions -and $this.DeletePartitions) {
            $vmHostDisk = $this.GetVMHostDisk($scsiLun)
            $shouldModifyScsiLunConfiguration += ($null -ne $vmHostDisk.ExtensionData.Spec.Partition)
        }

        return ($shouldModifyScsiLunConfiguration -Contains $true)
    }

    <#
    .DESCRIPTION

    Modifies the configuration of the specified SCSI device.
    #>
    [void] ModifyScsiLunConfiguration($scsiLun) {
        $setScsiLunParams = @{
            ScsiLun = $scsiLun
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        if ($this.MultipathPolicy -ne [MultipathPolicy]::Unset) { $setScsiLunParams.MultipathPolicy = $this.MultipathPolicy.ToString() }
        if ($null -ne $this.IsLocal) { $setScsiLunParams.IsLocal = $this.IsLocal }
        if ($null -ne $this.IsSsd) { $setScsiLunParams.IsSsd = $this.IsSsd }

        # 'BlocksToSwitchPath' and 'CommandsToSwitchPath' parameters should be passed to the cmdlet only if the desired Multipath policy is 'Round Robin'.
        if ($this.MultipathPolicy -eq [MultipathPolicy]::RoundRobin) {
            if ($null -ne $this.BlocksToSwitchPath) { $setScsiLunParams.BlocksToSwitchPath = $this.BlocksToSwitchPath }
            if ($null -ne $this.CommandsToSwitchPath) { $setScsiLunParams.CommandsToSwitchPath = $this.CommandsToSwitchPath }
        }

        if ($null -ne $this.DeletePartitions) {
            # Force should be specified to avoid the user being asked for confirmation when deleting disk partitions.
            $setScsiLunParams.DeletePartitions = $this.DeletePartitions
            $setScsiLunParams.Force = $true
        }

        if (![string]::IsNullOrEmpty($this.PreferredScsiLunPathName) -and $this.MultipathPolicy -eq [MultipathPolicy]::Fixed) {
            $scsiLunPath = $this.GetScsiLunPath($scsiLun)
            $setScsiLunParams.PreferredPath = $scsiLunPath
        }

        try {
            Write-VerboseLog -Message $this.ModifyScsiLunConfigurationMessage -Arguments @($scsiLun.CanonicalName, $this.VMHost.Name)
            Set-ScsiLun @setScsiLunParams
        }
        catch {
            throw ($this.CouldNotModifyScsiLunConfigurationMessage -f $scsiLun.CanonicalName, $this.VMHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $scsiLun) {
        $result.Server = $this.Connection.Name
        $result.VMHostName = $this.VMHost.Name
        $result.CanonicalName = $scsiLun.CanonicalName
        $result.MultipathPolicy = $scsiLun.MultipathPolicy.ToString()
        $result.BlocksToSwitchPath = [int] $scsiLun.BlocksToSwitchPath
        $result.CommandsToSwitchPath = [int] $scsiLun.CommandsToSwitchPath
        $result.IsLocal = $scsiLun.IsLocal
        $result.IsSsd = $scsiLun.IsSsd

        $preferredScsiLunPath = $this.GetPreferredScsiLunPath($scsiLun)
        $result.PreferredScsiLunPathName = $preferredScsiLunPath.Name
        $result.DeletePartitions = $this.DeletePartitions
    }
}
