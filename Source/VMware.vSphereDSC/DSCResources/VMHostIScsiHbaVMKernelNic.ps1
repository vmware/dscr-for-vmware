<#
Copyright (c) 2018-2021 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

[DscResource()]
class VMHostIScsiHbaVMKernelNic : VMHostEntityBaseDSC {
    <#
    .DESCRIPTION

    Specifies the name of the iSCSI Host Bus Adapter.
    #>
    [DscProperty(Key)]
    [string] $IScsiHbaName

    <#
    .DESCRIPTION

    Specifies the names of the VMKernel Network Adapters that should be bound/unbound
    to/from the specified iSCSI Host Bus Adapter.
    #>
    [DscProperty(Mandatory)]
    [string[]] $VMKernelNicNames

    <#
    .DESCRIPTION

    Value indicating if the VMKernel Network Adapters should be bound/unbound
    to/from the specified iSCSI Host Bus Adapter.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    <#
    .DESCRIPTION

    Specifies whether to bind VMKernel Network Adapters to iSCSI Host Bus Adapter
    when VMKernel Network Adapters aren't compatible for iSCSI multipathing.
    Specifies whether to unbind VMKernel Network Adapters from iSCSI Host Bus Adapter
    when there're active sessions using the VMKernel Network Adapters.
    #>
    [DscProperty()]
    [nullable[bool]] $Force

    hidden [string] $IScsiDeviceType = 'iSCSI'

    hidden [string] $RetrieveIScsiHbaMessage = "Retrieving iSCSI Host Bus Adapter {0} from VMHost {1}."
    hidden [string] $RetrieveEsxCliInterfaceMessage = "Retrieving EsxCli interface for VMHost {0}."
    hidden [string] $RetrieveVMKernelNicsMessage = "Retrieving VMKernel Network Adapters {0} from VMHost {1}."

    hidden [string] $VMKernelNicAlreadyBoundMessage = "VMKernel Network Adapter {0} is already bound to iSCSI Host Bus Adapter {1} and will be ignored."
    hidden [string] $VMKernelNicAlreadyUnboundMessage = "VMKernel Network Adapter {0} is already unbound from iSCSI Host Bus Adapter {1} and will be ignored."

    hidden [string] $VMKernelNicBindMessage = "Binding VMKernel Network Adapter {0} to iSCSI Host Bus Adapter {1}."
    hidden [string] $VMKernelNicUnbindMessage = "Unbinding VMKernel Network Adapter {0} from iSCSI Host Bus Adapter {1}."

    hidden [string] $CouldNotRetrieveIScsiHbaMessage = "Could not retrieve iSCSI Host Bus Adapter {0} from VMHost {1}. For more information: {2}"
    hidden [string] $CouldNotRetrieveEsxCliInterfaceMessage = "Could not retrieve EsxCli interface for VMHost {0}. For more information: {1}"
    hidden [string] $CouldNotRetrieveVMKernelNicMessage = "VMKernel Network Adapter {0} could not be retrieved from VMHost {1} and will be ignored."

    hidden [string] $CouldNotBindVMKernelNicMessage = "Could not bind VMKernel Network Adapter {0} to iSCSI Host Bus Adapter {1}. For more information: {2}"
    hidden [string] $CouldNotUnbindVMKernelNicMessage = "Could not unbind VMKernel Network Adapter {0} from iSCSI Host Bus Adapter {1}. For more information: {2}"

    [void] Set() {
        try {
            $this.WriteLogUtil('Verbose', $this.SetMethodStartMessage, @($this.DscResourceName))

            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $esxCli = $this.GetEsxCli()
            $iScsiHba = $this.GetIScsiHba()

            $vmKernelNics = $this.GetVMKernelNetworkAdapters()
            $filteredVMKernelNics = $this.GetFilteredVMKernelNetworkAdapters($esxCli, $iScsiHba, $vmKernelNics)

            if ($this.Ensure -eq [Ensure]::Present) {
                $this.BindVMKernelNicsToIScsiHba($esxCli, $iScsiHba, $filteredVMKernelNics)
            }
            else {
                $this.UnbindVMKernelNicsToIScsiHba($esxCli, $iScsiHba, $filteredVMKernelNics)
            }
        }
        finally {
            $this.DisconnectVIServer()

            $this.WriteLogUtil('Verbose', $this.SetMethodEndMessage, @($this.DscResourceName))
        }
    }

    [bool] Test() {
        try {
            $this.WriteLogUtil('Verbose', $this.TestMethodStartMessage, @($this.DscResourceName))

            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $esxCli = $this.GetEsxCli()
            $iScsiHba = $this.GetIScsiHba()
            $vmKernelNics = $this.GetVMKernelNetworkAdapters()

            $result = !$this.ShouldUpdateIScsiHbaBoundNics($esxCli, $iScsiHba, $vmKernelNics)
            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()

            $this.WriteLogUtil('Verbose', $this.TestMethodEndMessage, @($this.DscResourceName))
        }
    }

    [VMHostIScsiHbaVMKernelNic] Get() {
        try {
            $this.WriteLogUtil('Verbose', $this.GetMethodStartMessage, @($this.DscResourceName))

            $result = [VMHostIScsiHbaVMKernelNic]::new()

            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $esxCli = $this.GetEsxCli()
            $iScsiHba = $this.GetIScsiHba()

            $this.PopulateResult($result, $esxCli, $iScsiHba)

            return $result
        }
        finally {
            $this.DisconnectVIServer()

            $this.WriteLogUtil('Verbose', $this.GetMethodEndMessage, @($this.DscResourceName))
        }
    }

    <#
    .DESCRIPTION

    Retrieves the EsxCli version 2 interface to ESXCLI for the specified VMHost.
    #>
    [PSObject] GetEsxCli() {
        try {
            $this.WriteLogUtil('Verbose', $this.RetrieveEsxCliInterfaceMessage, @($this.VMHost.Name))

            $getEsxCliParams = @{
                Server = $this.Connection
                VMHost = $this.VMHost
                V2 = $true
                ErrorAction = 'Stop'
                Verbose = $false
            }
            return Get-EsxCli @getEsxCliParams
        }
        catch {
            throw ($this.CouldNotRetrieveEsxCliInterfaceMessage -f $this.VMHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the iSCSI Host Bus Adapter with the specified name from the specified VMHost.
    If the iSCSI Host Bus Adapter is not found, it throws an exception.
    #>
    [PSObject] GetIScsiHba() {
        try {
            $this.WriteLogUtil('Verbose', $this.RetrieveIScsiHbaMessage, @($this.IScsiHbaName, $this.VMHost.Name))

            $getVMHostHbaParams = @{
                Server = $this.Connection
                VMHost = $this.VMHost
                Device = $this.IScsiHbaName
                Type = $this.IScsiDeviceType
                ErrorAction = 'Stop'
                Verbose = $false
            }

            return Get-VMHostHba @getVMHostHbaParams
        }
        catch {
            throw ($this.CouldNotRetrieveIScsiHbaMessage -f $this.IScsiHbaName, $this.VMHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the VMKernel Network Adapters with the specified names from the specified VMHost.
    For every VMKernel Network Adapter that doesn't exist, a warning message is shown to the user without throwing an exception.
    #>
    [array] GetVMKernelNetworkAdapters() {
        $vmKernelNics = @()

        $this.WriteLogUtil('Verbose', $this.RetrieveVMKernelNicsMessage, @(($this.VMKernelNicNames -Join ', '), $this.VMHost.Name))

        $getVMHostNetworkAdapterParams = @{
            Server = $this.Connection
            VMHost = $this.VMHost
            VMKernel = $true
            ErrorAction = 'SilentlyContinue'
            Verbose = $false
        }
        $retrievedVMKernelNics = Get-VMHostNetworkAdapter @getVMHostNetworkAdapterParams

        foreach ($vmKernelNicName in $this.VMKernelNicNames) {
            $vmKernelNic = $retrievedVMKernelNics | Where-Object -FilterScript { $_.Name -eq $vmKernelNicName }
            if ($null -eq $vmKernelNic) {
                $this.WriteLogUtil('Warning', $this.CouldNotRetrieveVMKernelNicMessage, @($vmKernelNicName, $this.VMHost.Name))
            }
            else {
                $vmKernelNics += $vmKernelNic
            }
        }

        return $vmKernelNics
    }

    <#
    .DESCRIPTION

    Returns the filtered VMKernel Network Adapters based on the value of the Ensure property.
    If Ensure is set to 'Present', it returns only those VMKernel Network Adapters that are currently not bound
    to the iSCSI Host Bus Adapter. The other VMKernel Network Adapters in the array are ignored because they're already bound
    to the iSCSI Host Bus Adapter. If Ensure is set to 'Absent', it returns only these VMKernel Network Adapters that are currently
    bound to the iSCSI Host Bus Adapter. The other VMKernel Network Adapters in the array are ignored because they're not bound to the
    iSCSI Host Bus Adapter. In both cases a warning message is shown to the user when a specific VMKernel Network Adapter is ignored.
    #>
    [array] GetFilteredVMKernelNetworkAdapters($esxCli, $iScsiHba, $vmKernelNics) {
        $filteredVMKernelNics = @()

        $boundVMKernelNics = Get-IScsiHbaBoundNics -EsxCli $esxCli -IScsiHbaName $iScsiHba.Device
        foreach ($vmKernelNic in $vmKernelNics) {
            $boundVMKernelNic = $boundVMKernelNics | Where-Object -FilterScript { $_.Vmknic -eq $vmKernelNic.Name }
            if ($this.Ensure -eq [Ensure]::Present -and $null -ne $boundVMKernelNic) {
                $this.WriteLogUtil('Warning', $this.VMKernelNicAlreadyBoundMessage, @($vmKernelNic.Name, $iScsiHba.Device))
                continue
            }
            elseif ($this.Ensure -eq [Ensure]::Absent -and $null -eq $boundVMKernelNic) {
                $this.WriteLogUtil('Warning', $this.VMKernelNicAlreadyUnboundMessage, @($vmKernelNic.Name, $iScsiHba.Device))
                continue
            }

            $filteredVMKernelNics += $vmKernelNic
        }

        return $filteredVMKernelNics
    }

    <#
    .DESCRIPTION

    Checks if VMKernel Network Adapters should be bound/unbound to/from the specified iSCSI Host Bus Adapter.
    If Ensure is set to 'Present', checks if all passed VMKernel Network Adapters are bound to the specified iSCSI Host Bus Adapter.
    If Ensure is set to 'Absent', checks if all passed VMKernel Network Adapters are unbound from the specified iSCSI Host Bus Adapter.
    #>
    [bool] ShouldUpdateIScsiHbaBoundNics($esxCli, $iScsiHba, $vmKernelNics) {
        $result = $false

        $boundVMKernelNics = Get-IScsiHbaBoundNics -EsxCli $esxCli -IScsiHbaName $iScsiHba.Device
        foreach ($vmKernelNic in $vmKernelNics) {
            $boundVMKernelNic = $boundVMKernelNics | Where-Object -FilterScript { $_.Vmknic -eq $vmKernelNic.Name }
            if ($this.Ensure -eq [Ensure]::Present -and $null -eq $boundVMKernelNic) {
                $result = $true
                break
            }
            elseif ($this.Ensure -eq [Ensure]::Absent -and $null -ne $boundVMKernelNic) {
                $result = $true
                break
            }
        }

        return $result
    }

    <#
    .DESCRIPTION

    Binds the specified VMKernel Network Adapters to the specified iSCSI Host Bus Adapter.
    #>
    [void] BindVMKernelNicsToIScsiHba($esxCli, $iScsiHba, $vmKernelNics) {
        foreach ($vmKernelNic in $vmKernelNics) {
            try {
                $this.WriteLogUtil('Verbose', $this.VMKernelNicBindMessage, @($vmKernelNic.Name, $iScsiHba.Device))
                Update-IScsiHbaBoundNics -EsxCli $esxCli -IScsiHbaName $iScsiHba.Device -VMKernelNicName $vmKernelNic.Name -Operation 'Add' -Force $this.Force
            }
            catch {
                throw ($this.CouldNotBindVMKernelNicMessage -f $vmKernelNic.Name, $iScsiHba.Device, $_.Exception.Message)
            }
        }
    }

    <#
    .DESCRIPTION

    Unbinds the specified VMKernel Network Adapters from the specified iSCSI Host Bus Adapter.
    #>
    [void] UnbindVMKernelNicsToIScsiHba($esxCli, $iScsiHba, $vmKernelNics) {
        foreach ($vmKernelNic in $vmKernelNics) {
            try {
                $this.WriteLogUtil('Verbose', $this.VMKernelNicUnbindMessage, @($vmKernelNic.Name, $iScsiHba.Device))
                Update-IScsiHbaBoundNics -EsxCli $esxCli -IScsiHbaName $iScsiHba.Device -VMKernelNicName $vmKernelNic.Name -Operation 'Remove' -Force $this.Force
            }
            catch {
                throw ($this.CouldNotUnbindVMKernelNicMessage -f $vmKernelNic.Name, $iScsiHba.Device, $_.Exception.Message)
            }
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $esxCli, $iScsiHba) {
        $result.Server = $this.Connection.Name
        $result.VMHostName = $this.VMHost.Name
        $result.IScsiHbaName = $iScsiHba.Device
        $result.Force = $this.Force

        $boundVMKernelNics = Get-IScsiHbaBoundNics -EsxCli $esxCli -IScsiHbaName $iScsiHba.Device
        if ($boundVMKernelNics.Length -gt 0) {
            $result.Ensure = [Ensure]::Present
            $result.VMKernelNicNames = $boundVMKernelNics.Vmknic
        }
        else {
            $result.Ensure = [Ensure]::Absent
            $result.VMKernelNicNames = $this.VMKernelNicNames
        }
    }
}
