<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

<#
Mocked PowerCLI Types for the purpose of unit testing.
#>
Add-Type -Path "$($env:PSModulePath)/VMware.VimAutomation.Core/PowerCLITypes.cs"

function Add-VDSwitchPhysicalNetworkAdapter {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.Nic.PhysicalNic[]]
        $VMHostPhysicalNic,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        $DistributedSwitch,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        $VirtualNicPortgroup,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.Nic.HostVirtualNic[]]
        $VMHostVirtualNic,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Add-VDSwitchVMHost {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.Vds.Types.V1.VDSwitch]
        $VDSwitch,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Get-VDPortgroup {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.NetworkAdapter[]]
        $NetworkAdapter,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.Vds.Types.V1.VDSwitch[]]
        $VDSwitch,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.Nic.HostVirtualNic[]]
        $VMHostNetworkAdapter,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ById", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Tagging.Tag[]]
        $Tag,

        [Parameter(Mandatory = $false, ParameterSetName = "ById", ValueFromPipeline = $false)]
        [string[]]
        $Id,

        [Parameter(Mandatory = $true, ParameterSetName = "RelatedObject", ValueFromPipeline = $true)]
        $RelatedObject
    )

    return $null
}

function Get-VDSwitch {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.FolderContainer[]]
        $Location,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Tagging.Tag[]]
        $Tag,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ById", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "ById", ValueFromPipeline = $false)]
        [string[]]
        $Id,

        [Parameter(Mandatory = $true, ParameterSetName = "Related", ValueFromPipeline = $true)]
        $RelatedObject
    )

    return $null
}

function New-VDPortgroup {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "ReferencePortgroup", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "FromBackup", ValueFromPipeline = $true)]
        [VMware.VimAutomation.Vds.Types.V1.VDSwitch]
        $VDSwitch,

        [Parameter(Mandatory = $true, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ReferencePortgroup", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromBackup", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string]
        $Notes,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [int]
        $NumPorts,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [int]
        $VlanId,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        $VlanTrunkRange,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.DistributedPortGroupPortBinding]
        $PortBinding,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ReferencePortgroup", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromBackup", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ReferencePortgroup", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromBackup", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ReferencePortgroup", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromBackup", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ReferencePortgroup", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromBackup", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $true, ParameterSetName = "ReferencePortgroup", ValueFromPipeline = $true)]
        $ReferencePortgroup,

        [Parameter(Mandatory = $true, ParameterSetName = "FromBackup", ValueFromPipeline = $false)]
        [string]
        $BackupPath,

        [Parameter(Mandatory = $false, ParameterSetName = "FromBackup", ValueFromPipeline = $false)]
        [switch]
        $KeepIdentifiers
    )

    return $null
}

function New-VDSwitch {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string]
        $ContactDetails,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string]
        $ContactName,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [System.Nullable[VMware.VimAutomation.Vds.Types.V1.LinkDiscoveryProtocol]]
        $LinkDiscoveryProtocol,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [System.Nullable[VMware.VimAutomation.Vds.Types.V1.LinkDiscoveryOperation]]
        $LinkDiscoveryProtocolOperation,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [System.Nullable[int]]
        $MaxPorts,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [System.Nullable[int]]
        $Mtu,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string]
        $Notes,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [System.Nullable[int]]
        $NumUplinkPorts,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string]
        $Version,

        [Parameter(Mandatory = $true, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $true, ParameterSetName = "CopyFromReferenceSwitch", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromBackup", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "CopyFromReferenceSwitch", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromBackup", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VIContainer]
        $Location,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "CopyFromReferenceSwitch", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromBackup", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "CopyFromReferenceSwitch", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromBackup", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "CopyFromReferenceSwitch", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromBackup", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "CopyFromReferenceSwitch", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromBackup", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $true, ParameterSetName = "CopyFromReferenceSwitch", ValueFromPipeline = $true)]
        $ReferenceVDSwitch,

        [Parameter(Mandatory = $false, ParameterSetName = "CopyFromReferenceSwitch", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromBackup", ValueFromPipeline = $false)]
        [switch]
        $WithoutPortGroups,

        [Parameter(Mandatory = $true, ParameterSetName = "FromBackup", ValueFromPipeline = $false)]
        [string]
        $BackupPath,

        [Parameter(Mandatory = $false, ParameterSetName = "FromBackup", ValueFromPipeline = $false)]
        [switch]
        $KeepIdentifiers
    )

    return $null
}

function Remove-VDPortGroup {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.Vds.Types.V1.VDPortgroup[]]
        $VDPortGroup,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-VDSwitch {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.Vds.Types.V1.VDSwitch[]]
        $VDSwitch,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-VDSwitchVMHost {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.Vds.Types.V1.VDSwitch]
        $VDSwitch,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-VDPortgroup {
    [CmdletBinding(DefaultParameterSetName = "")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string]
        $Notes,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [int]
        $NumPorts,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [int]
        $VlanId,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        $VlanTrunkRange,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [int]
        $PrivateVlanId,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.DistributedPortGroupPortBinding]
        $PortBinding,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [switch]
        $DisableVlan,

        [Parameter(Mandatory = $true, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "Rollback", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "FromBackup", ValueFromPipeline = $true)]
        [VMware.VimAutomation.Vds.Types.V1.VDPortgroup[]]
        $VDPortgroup,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Rollback", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromBackup", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Rollback", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromBackup", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Rollback", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromBackup", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Rollback", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromBackup", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $true, ParameterSetName = "Rollback", ValueFromPipeline = $false)]
        [switch]
        $RollbackConfiguration,

        [Parameter(Mandatory = $true, ParameterSetName = "FromBackup", ValueFromPipeline = $false)]
        [string]
        $BackupPath
    )

    return $null
}

function Set-VDSwitch {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string]
        $ContactDetails,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string]
        $ContactName,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [System.Nullable[VMware.VimAutomation.Vds.Types.V1.LinkDiscoveryProtocol]]
        $LinkDiscoveryProtocol,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [System.Nullable[VMware.VimAutomation.Vds.Types.V1.LinkDiscoveryOperation]]
        $LinkDiscoveryProtocolOperation,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [System.Nullable[int]]
        $MaxPorts,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [System.Nullable[int]]
        $Mtu,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string]
        $Notes,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [System.Nullable[int]]
        $NumUplinkPorts,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string]
        $Version,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromBackup", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "RollBack", ValueFromPipeline = $true)]
        [VMware.VimAutomation.Vds.Types.V1.VDSwitch[]]
        $VDSwitch,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromBackup", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "RollBack", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromBackup", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "RollBack", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromBackup", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "RollBack", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromBackup", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "RollBack", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $true, ParameterSetName = "FromBackup", ValueFromPipeline = $false)]
        [string]
        $BackupPath,

        [Parameter(Mandatory = $false, ParameterSetName = "FromBackup", ValueFromPipeline = $false)]
        [switch]
        $WithoutPortGroups,

        [Parameter(Mandatory = $true, ParameterSetName = "RollBack", ValueFromPipeline = $false)]
        [switch]
        $RollBackConfiguration
    )

    return $null
}

function Add-PassthroughDevice {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.PassThroughDevice[]]
        $PassthroughDevice,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Add-VirtualSwitchPhysicalNetworkAdapter {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.Nic.PhysicalNic[]]
        $VMHostPhysicalNic,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.VirtualSwitch]
        $VirtualSwitch,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        $VirtualNicPortgroup,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.Nic.HostVirtualNic[]]
        $VMHostVirtualNic,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Add-VMHost {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $Port,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VIContainer]
        $Location,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $User,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Password,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Force,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Add-VMHostNtpServer {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string[]]
        $NtpServer,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Connect-VIServer {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $true, ParameterSetName = "SamlSecurityContext", ValueFromPipeline = $false)]
        [string[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "SamlSecurityContext", ValueFromPipeline = $false)]
        [int]
        $Port,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "SamlSecurityContext", ValueFromPipeline = $false)]
        [string]
        $Protocol,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [string]
        $User,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string]
        $Password,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string]
        $Session,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "SamlSecurityContext", ValueFromPipeline = $false)]
        [switch]
        $NotDefault,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [switch]
        $SaveCredentials,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "SamlSecurityContext", ValueFromPipeline = $false)]
        [switch]
        $AllLinked,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "SamlSecurityContext", ValueFromPipeline = $false)]
        [switch]
        $Force,

        #[Parameter(Mandatory = $true, ParameterSetName = "SamlSecurityContext", ValueFromPipeline = $true)]
        #[VMware.VimAutomation.Common.Types.V1.Authentication.SamlSecurityContext]
        #$SamlSecurityContext,

        [Parameter(Mandatory = $true, ParameterSetName = "Menu", ValueFromPipeline = $false)]
        [switch]
        $Menu
    )

    return $null
}

function Copy-DatastoreItem {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [System.Object[]]
        $Item,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [System.Object]
        $Destination,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Force,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $PassThru,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Recurse,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Copy-HardDisk {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.HardDisk[]]
        $HardDisk,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $DestinationPath,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.VirtualDiskStorageFormat]
        $DestinationStorageFormat,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Force,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Copy-VMGuestFile {
    [CmdletBinding(DefaultParameterSetName = "")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "GuestToLocal", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $true, ParameterSetName = "LocalToGuest", ValueFromPipeline = $false)]
        [string[]]
        $Source,

        [Parameter(Mandatory = $true, ParameterSetName = "GuestToLocal", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $true, ParameterSetName = "LocalToGuest", ValueFromPipeline = $false)]
        [string]
        $Destination,

        [Parameter(Mandatory = $true, ParameterSetName = "GuestToLocal", ValueFromPipeline = $false)]
        [switch]
        $GuestToLocal,

        [Parameter(Mandatory = $false, ParameterSetName = "GuestToLocal", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "LocalToGuest", ValueFromPipeline = $false)]
        [switch]
        $Force,

        [Parameter(Mandatory = $false, ParameterSetName = "GuestToLocal", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "LocalToGuest", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "GuestToLocal", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "LocalToGuest", ValueFromPipeline = $false)]
        [pscredential]
        $HostCredential,

        [Parameter(Mandatory = $false, ParameterSetName = "GuestToLocal", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "LocalToGuest", ValueFromPipeline = $false)]
        [string]
        $HostUser,

        [Parameter(Mandatory = $false, ParameterSetName = "GuestToLocal", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "LocalToGuest", ValueFromPipeline = $false)]
        [securestring]
        $HostPassword,

        [Parameter(Mandatory = $false, ParameterSetName = "GuestToLocal", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "LocalToGuest", ValueFromPipeline = $false)]
        [pscredential]
        $GuestCredential,

        [Parameter(Mandatory = $false, ParameterSetName = "GuestToLocal", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "LocalToGuest", ValueFromPipeline = $false)]
        [string]
        $GuestUser,

        [Parameter(Mandatory = $false, ParameterSetName = "GuestToLocal", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "LocalToGuest", ValueFromPipeline = $false)]
        [securestring]
        $GuestPassword,

        [Parameter(Mandatory = $false, ParameterSetName = "GuestToLocal", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "LocalToGuest", ValueFromPipeline = $false)]
        [int]
        $ToolsWaitSecs,

        [Parameter(Mandatory = $false, ParameterSetName = "GuestToLocal", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "LocalToGuest", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "GuestToLocal", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "LocalToGuest", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "GuestToLocal", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "LocalToGuest", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $true, ParameterSetName = "LocalToGuest", ValueFromPipeline = $false)]
        [switch]
        $LocalToGuest
    )

    return $null
}

function Disconnect-VIServer {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Force,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Dismount-Tools {
    [CmdletBinding(DefaultParameterSetName = "")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "VMGuest", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VM.Guest.VMGuest[]]
        $Guest,

        [Parameter(Mandatory = $false, ParameterSetName = "Vm", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "Vm", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Export-VApp {
    [CmdletBinding(DefaultParameterSetName = "ExportVApp")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "ExportVApp", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ExportVM", ValueFromPipeline = $false)]
        [string]
        $Destination,

        [Parameter(Mandatory = $false, ParameterSetName = "ExportVApp", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VApp[]]
        $VApp,

        [Parameter(Mandatory = $false, ParameterSetName = "ExportVApp", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ExportVM", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "ExportVApp", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ExportVM", ValueFromPipeline = $false)]
        [switch]
        $Force,

        [Parameter(Mandatory = $false, ParameterSetName = "ExportVApp", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ExportVM", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VAppStorageFormat]
        $Format,

        [Parameter(Mandatory = $false, ParameterSetName = "ExportVApp", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ExportVM", ValueFromPipeline = $false)]
        [switch]
        $CreateSeparateFolder,

        [Parameter(Mandatory = $false, ParameterSetName = "ExportVApp", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ExportVM", ValueFromPipeline = $false)]
        [string]
        $Description,

        [Parameter(Mandatory = $false, ParameterSetName = "ExportVApp", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ExportVM", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "ExportVApp", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ExportVM", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "ExportVApp", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ExportVM", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "ExportVApp", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ExportVM", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $false, ParameterSetName = "ExportVM", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM
    )

    return $null
}

function Export-VMHostProfile {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $FilePath,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Profile.VMHostProfile]
        $Profile,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Force,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer]
        $Server
    )

    return $null
}

function Format-VMHostDiskPartition {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $VolumeName,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Storage.VMHostDiskPartition[]]
        $VMHostDiskPartition,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Get-AdvancedSetting {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.Sdk.Types.V1.VIObject[]]
        $Entity,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-AlarmAction {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Alarm.AlarmDefinition[]]
        $AlarmDefinition,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Alarm.ActionType[]]
        $ActionType,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-AlarmActionTrigger {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Alarm.AlarmAction[]]
        $AlarmAction
    )

    return $null
}

function Get-AlarmDefinition {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string[]]
        $Id,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.Sdk.Types.V1.VIObject[]]
        $Entity,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $Enabled,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-Annotation {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.AnnotationManagement.CustomAttribute[]]
        $CustomAttribute,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "Name", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.InventoryItem]
        $Entity,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Name", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "Name", ValueFromPipeline = $false)]
        [string[]]
        $Name
    )

    return $null
}

function Get-CDDrive {
    [CmdletBinding(DefaultParameterSetName = "VirtualDeviceGetter")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "VirtualDeviceGetter", ValueFromPipeline = $false)]
        [string[]]
        $Id,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualDeviceGetter", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualDeviceGetter", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualDeviceGetter", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Template[]]
        $Template,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualDeviceGetter", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VM.Snapshot[]]
        $Snapshot,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualDeviceGetter", ValueFromPipeline = $false)]
        [string[]]
        $Name
    )

    return $null
}

function Get-Cluster {
    [CmdletBinding(DefaultParameterSetName = "Location")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Location", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "RelatedObject", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "Location", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VIContainer[]]
        $Location,

        [Parameter(Mandatory = $false, ParameterSetName = "Location", ValueFromPipeline = $false)]
        [switch]
        $NoRecursion,

        [Parameter(Mandatory = $false, ParameterSetName = "Location", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "RelatedObject", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Tagging.Tag[]]
        $Tag,

        [Parameter(Mandatory = $false, ParameterSetName = "Location", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "RelatedObject", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ById", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $true, ParameterSetName = "ExternalRelatedObject", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.RelatedObject.ClusterRelatedObjectBase[]]
        $RelatedObject,

        [Parameter(Mandatory = $false, ParameterSetName = "RelatedObject", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "RelatedObject", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "ById", ValueFromPipeline = $false)]
        [string[]]
        $Id
    )

    return $null
}

function Get-ContentLibraryItem {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string[]]
        $ItemType,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ById", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $true, ParameterSetName = "ById", ValueFromPipeline = $false)]
        [string[]]
        $Id
    )

    return $null
}

function Get-CustomAttribute {
    [CmdletBinding(DefaultParameterSetName = "GetByMoRef")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "GetByMoRef", ValueFromPipeline = $false)]
        [string[]]
        $Id,

        [Parameter(Mandatory = $false, ParameterSetName = "GetByMoRef", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "GetByMoRef", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.AnnotationManagement.CustomAttributeTargetType[]]
        $TargetType,

        [Parameter(Mandatory = $false, ParameterSetName = "GetByMoRef", ValueFromPipeline = $false)]
        [switch]
        $Global,

        [Parameter(Mandatory = $false, ParameterSetName = "GetByMoRef", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-Datacenter {
    [CmdletBinding(DefaultParameterSetName = "Location")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Location", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "RelatedObject", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "Location", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Folder[]]
        $Location,

        [Parameter(Mandatory = $false, ParameterSetName = "Location", ValueFromPipeline = $false)]
        [switch]
        $NoRecursion,

        [Parameter(Mandatory = $false, ParameterSetName = "Location", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "RelatedObject", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Tagging.Tag[]]
        $Tag,

        [Parameter(Mandatory = $false, ParameterSetName = "Location", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "RelatedObject", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ById", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "RelatedObject", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "RelatedObject", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Cluster[]]
        $Cluster,

        [Parameter(Mandatory = $false, ParameterSetName = "RelatedObject", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $true, ParameterSetName = "ExternalRelatedObject", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.RelatedObject.DatacenterRelatedObjectBase[]]
        $RelatedObject,

        [Parameter(Mandatory = $false, ParameterSetName = "ById", ValueFromPipeline = $false)]
        [string[]]
        $Id
    )

    return $null
}

function Get-Datastore {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ById", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [VMware.VimAutomation.Sdk.Types.V1.VIObject[]]
        $Location,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.RelatedObject.DatastoreRelatedObjectBase[]]
        [Alias('VMHost')]
        $RelatedObject,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ById", ValueFromPipeline = $false)]
        [switch]
        $Refresh,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Tagging.Tag[]]
        $Tag,

        [Parameter(Mandatory = $false, ParameterSetName = "ById", ValueFromPipeline = $false)]
        [string[]]
        $Id
    )

    return $null
}

function Get-DatastoreCluster {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string[]]
        $Id,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VIContainer[]]
        $Location,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Template[]]
        $Template,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.DatastoreManagement.Datastore[]]
        $Datastore,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Tagging.Tag[]]
        $Tag,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $true, ParameterSetName = "RelatedObject", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.RelatedObject.DatastoreClusterRelatedObjectBase[]]
        $RelatedObject
    )

    return $null
}

function Get-DrsClusterGroup {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "DrsClusterVMGroup", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "DrsClusterVMHostGroup", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Cluster[]]
        $Cluster,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Cluster.DrsClusterGroupType]
        $Type,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "DrsClusterVMGroup", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "DrsClusterVMHostGroup", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "DrsClusterVMGroup", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "DrsClusterVMHostGroup", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost
    )

    return $null
}

function Get-DrsRecommendation {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Cluster[]]
        $Cluster,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Refresh,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int[]]
        $Priority,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-DrsRule {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "VMHostRule", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "VMHostRule", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Cluster[]]
        $Cluster,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "VMHostRule", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Cluster.ResourceSchedulingRuleType[]]
        $Type,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "VMHostRule", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "VMHostRule", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost
    )

    return $null
}

function Get-DrsVMHostRule {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Cluster[]]
        $Cluster,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Cluster.DrsVMHostRuleType[]]
        $Type,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Cluster.DrsClusterVMGroup[]]
        $VMGroup,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Cluster.DrsClusterVMHostGroup[]]
        $VMHostGroup,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-EsxCli {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $V2,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-EsxTop {
    [CmdletBinding(DefaultParameterSetName = "CounterValues")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "CounterValues", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Counter", ValueFromPipeline = $false)]
        [string[]]
        $CounterName,

        [Parameter(Mandatory = $false, ParameterSetName = "CounterValues", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "Counter", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "TopologyInfo", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $true, ParameterSetName = "Counter", ValueFromPipeline = $false)]
        [switch]
        $Counter,

        [Parameter(Mandatory = $true, ParameterSetName = "TopologyInfo", ValueFromPipeline = $false)]
        [switch]
        $TopologyInfo,

        [Parameter(Mandatory = $false, ParameterSetName = "TopologyInfo", ValueFromPipeline = $false)]
        [string[]]
        $Topology
    )

    return $null
}

function Get-FloppyDrive {
    [CmdletBinding(DefaultParameterSetName = "VirtualDeviceGetter")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "VirtualDeviceGetter", ValueFromPipeline = $false)]
        [string[]]
        $Id,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualDeviceGetter", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualDeviceGetter", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualDeviceGetter", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Template[]]
        $Template,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualDeviceGetter", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VM.Snapshot[]]
        $Snapshot,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualDeviceGetter", ValueFromPipeline = $false)]
        [string[]]
        $Name
    )

    return $null
}

function Get-Folder {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VIContainer[]]
        $Location,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.FolderType[]]
        $Type,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Tagging.Tag[]]
        $Tag,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ById", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [switch]
        $NoRecursion,

        [Parameter(Mandatory = $true, ParameterSetName = "RelatedObject", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.RelatedObject.FolderRelatedObjectBase[]]
        $RelatedObject,

        [Parameter(Mandatory = $false, ParameterSetName = "ById", ValueFromPipeline = $false)]
        [string[]]
        $Id
    )

    return $null
}

function Get-HAPrimaryVMHost {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Cluster[]]
        $Cluster,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-HardDisk {
    [CmdletBinding(DefaultParameterSetName = "ProviderPath")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "ProviderPath", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "VirtualDeviceGetter", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "DatastorePath", ValueFromPipeline = $false)]
        [string[]]
        $Id,

        [Parameter(Mandatory = $false, ParameterSetName = "ProviderPath", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.DatastoreManagement.DatastoreItem[]]
        $Path,

        [Parameter(Mandatory = $false, ParameterSetName = "ProviderPath", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "VirtualDeviceGetter", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "DatastorePath", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.DiskType[]]
        $DiskType,

        [Parameter(Mandatory = $false, ParameterSetName = "ProviderPath", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "VirtualDeviceGetter", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "DatastorePath", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $true, ParameterSetName = "RelatedObject", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.RelatedObject.HardDiskRelatedObjectBase[]]
        $RelatedObject,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualDeviceGetter", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualDeviceGetter", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Template[]]
        $Template,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualDeviceGetter", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VM.Snapshot[]]
        $Snapshot,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualDeviceGetter", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "DatastorePath", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.DatastoreManagement.Datastore[]]
        $Datastore,

        [Parameter(Mandatory = $false, ParameterSetName = "DatastorePath", ValueFromPipeline = $false)]
        [string[]]
        $DatastorePath
    )

    return $null
}

function Get-Inventory {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VIContainer[]]
        $Location,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [switch]
        $NoRecursion,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ById", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "ById", ValueFromPipeline = $false)]
        [string[]]
        $Id
    )

    return $null
}

function Get-IScsiHbaTarget {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Storage.IScsiHba[]]
        $IScsiHba,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Storage.IScsiHbaTargetType[]]
        $Type,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string[]]
        $IPEndPoint,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-KmsCluster {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "GetById", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $true, ParameterSetName = "GetById", ValueFromPipeline = $false)]
        [string[]]
        $Id
    )

    return $null
}

function Get-Log {
    [CmdletBinding(DefaultParameterSetName = "")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "logSet", ValueFromPipeline = $true)]
        [string[]]
        $Key,

        [Parameter(Mandatory = $false, ParameterSetName = "logSet", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "logBundleSet", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "logSet", ValueFromPipeline = $false)]
        [int]
        $StartLineNum,

        [Parameter(Mandatory = $false, ParameterSetName = "logSet", ValueFromPipeline = $false)]
        [int]
        $NumLines,

        [Parameter(Mandatory = $false, ParameterSetName = "logSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "logBundleSet", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "logBundleSet", ValueFromPipeline = $false)]
        [switch]
        $Bundle,

        [Parameter(Mandatory = $true, ParameterSetName = "logBundleSet", ValueFromPipeline = $false)]
        [string]
        $DestinationPath,

        [Parameter(Mandatory = $false, ParameterSetName = "logBundleSet", ValueFromPipeline = $false)]
        [switch]
        $RunAsync
    )

    return $null
}

function Get-LogType {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-NetworkAdapter {
    [CmdletBinding(DefaultParameterSetName = "VirtualDeviceGetter")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "VirtualDeviceGetter", ValueFromPipeline = $false)]
        [string[]]
        $Id,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualDeviceGetter", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualDeviceGetter", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualDeviceGetter", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Template[]]
        $Template,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualDeviceGetter", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VM.Snapshot[]]
        $Snapshot,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualDeviceGetter", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = "RelatedObject", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.RelatedObject.NetworkAdapterRelatedObjectBase[]]
        $RelatedObject
    )

    return $null
}

function Get-NfsUser {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string[]]
        $Username,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-NicTeamingPolicy {
    [CmdletBinding(DefaultParameterSetName = "")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "switch", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.VirtualSwitch[]]
        $VirtualSwitch,

        [Parameter(Mandatory = $false, ParameterSetName = "switch", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "pg", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $true, ParameterSetName = "pg", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.VirtualPortGroup[]]
        $VirtualPortGroup
    )

    return $null
}

function Get-OSCustomizationNicMapping {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.OSCustomization.OSCustomizationSpec[]]
        $OSCustomizationSpec,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-OSCustomizationSpec {
    [CmdletBinding(DefaultParameterSetName = "DefaultSet")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "DefaultSet", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultSet", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultSet", ValueFromPipeline = $false)]
        [string[]]
        $Id,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultSet", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.OSCustomization.OSCustomizationSpecType]
        $Type
    )

    return $null
}

function Get-OvfConfiguration {
    [CmdletBinding(DefaultParameterSetName = "Ovf")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "Ovf", ValueFromPipeline = $false)]
        [string]
        $Ovf,

        [Parameter(Mandatory = $false, ParameterSetName = "Ovf", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-PassthroughDevice {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Template[]]
        $Template,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.PassthroughDeviceType]
        $Type,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string[]]
        $Id,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-PowerCLIConfiguration {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.ConfigurationScope]
        $Scope
    )

    return $null
}

function Get-PowerCLIVersion {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
    )

    return $null
}

function Get-ResourcePool {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ByChildVm", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VIContainer[]]
        $Location,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ByChildVm", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ById", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ByChildVm", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Tagging.Tag[]]
        $Tag,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [switch]
        $NoRecursion,

        [Parameter(Mandatory = $true, ParameterSetName = "ByChildVm", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $true, ParameterSetName = "ById", ValueFromPipeline = $false)]
        [string[]]
        $Id,

        [Parameter(Mandatory = $true, ParameterSetName = "RelatedObject", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.RelatedObject.ResourcePoolRelatedObjectBase[]]
        $RelatedObject
    )

    return $null
}

function Get-ScsiController {
    [CmdletBinding(DefaultParameterSetName = "VirtualDeviceGetter")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "VirtualDeviceGetter", ValueFromPipeline = $false)]
        [string[]]
        $Id,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualDeviceGetter", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.HardDisk[]]
        $HardDisk,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualDeviceGetter", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualDeviceGetter", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualDeviceGetter", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Template[]]
        $Template,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualDeviceGetter", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VM.Snapshot[]]
        $Snapshot,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualDeviceGetter", ValueFromPipeline = $false)]
        [string[]]
        $Name
    )

    return $null
}

function Get-ScsiLun {
    [CmdletBinding(DefaultParameterSetName = "HostParameterSet")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "HostParameterSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "HbaParameterSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "DatastoreParameterSet", ValueFromPipeline = $false)]
        [string[]]
        $CanonicalName,

        [Parameter(Mandatory = $false, ParameterSetName = "HostParameterSet", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VmHost,

        [Parameter(Mandatory = $false, ParameterSetName = "HostParameterSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "HbaParameterSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "DatastoreParameterSet", ValueFromPipeline = $false)]
        [string[]]
        $Key,

        [Parameter(Mandatory = $false, ParameterSetName = "HostParameterSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "HbaParameterSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "DatastoreParameterSet", ValueFromPipeline = $false)]
        [string[]]
        $LunType,

        [Parameter(Mandatory = $false, ParameterSetName = "HostParameterSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "IdParameterSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "HbaParameterSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "DatastoreParameterSet", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "IdParameterSet", ValueFromPipeline = $false)]
        [string[]]
        $Id,

        [Parameter(Mandatory = $false, ParameterSetName = "HbaParameterSet", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Storage.Hba[]]
        $Hba,

        [Parameter(Mandatory = $false, ParameterSetName = "DatastoreParameterSet", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.DatastoreManagement.Datastore[]]
        $Datastore
    )

    return $null
}

function Get-ScsiLunPath {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Storage.Scsi.ScsiLun[]]
        $ScsiLun
    )

    return $null
}

function Get-SecurityPolicy {
    [CmdletBinding(DefaultParameterSetName = "")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "switch", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.VirtualSwitch[]]
        $VirtualSwitch,

        [Parameter(Mandatory = $false, ParameterSetName = "switch", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "portgroup", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $true, ParameterSetName = "portgroup", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.VirtualPortGroup[]]
        $VirtualPortGroup
    )

    return $null
}

function Get-Snapshot {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string[]]
        $Id,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-Stat {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.Sdk.Types.V1.VIObject[]]
        $Entity,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Common,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Memory,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Cpu,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Disk,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Network,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string[]]
        $Stat,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [datetime]
        $Start,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [datetime]
        $Finish,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $MaxSamples,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int[]]
        $IntervalMins,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int[]]
        $IntervalSecs,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string[]]
        $Instance,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Realtime,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-StatInterval {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int[]]
        $SamplingPeriodSecs,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-StatType {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.Sdk.Types.V1.VIObject[]]
        $Entity,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [datetime]
        $Start,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [datetime]
        $Finish,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Stat.StatInterval[]]
        $Interval,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Realtime,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-Tag {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Tagging.TagCategory[]]
        $Category,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ById", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $true, ParameterSetName = "ById", ValueFromPipeline = $false)]
        [string[]]
        $Id
    )

    return $null
}

function Get-TagAssignment {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.Sdk.Types.V1.VIObjectCore[]]
        $Entity,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Tagging.TagCategory[]]
        $Category,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-TagCategory {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "ById", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $true, ParameterSetName = "ById", ValueFromPipeline = $false)]
        [string[]]
        $Id
    )

    return $null
}

function Get-Task {
    [CmdletBinding(DefaultParameterSetName = "default")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.Sdk.Types.V1.TaskState]
        $Status,

        [Parameter(Mandatory = $false, ParameterSetName = "default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "byId", ValueFromPipeline = $false)]
        [VMware.VimAutomation.Sdk.Types.V1.VIConnection[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "byId", ValueFromPipeline = $false)]
        [string[]]
        $Id
    )

    return $null
}

function Get-Template {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VIContainer[]]
        $Location,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.DatastoreManagement.StorageResource[]]
        $Datastore,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [switch]
        $NoRecursion,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ById", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "ById", ValueFromPipeline = $false)]
        [string[]]
        $Id
    )

    return $null
}

function Get-UsbDevice {
    [CmdletBinding(DefaultParameterSetName = "VirtualDeviceGetter")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "VirtualDeviceGetter", ValueFromPipeline = $false)]
        [string[]]
        $Id,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualDeviceGetter", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualDeviceGetter", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualDeviceGetter", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Template[]]
        $Template,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualDeviceGetter", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VM.Snapshot[]]
        $Snapshot,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualDeviceGetter", ValueFromPipeline = $false)]
        [string[]]
        $Name
    )

    return $null
}

function Get-VApp {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VIContainer[]]
        $Location,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Tagging.Tag[]]
        $Tag,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [switch]
        $NoRecursion,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ById", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "ById", ValueFromPipeline = $false)]
        [string[]]
        $Id
    )

    return $null
}

function Get-VIAccount {
    [CmdletBinding(DefaultParameterSetName = "Name")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Name", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Id", ValueFromPipeline = $false)]
        [switch]
        $Group,

        [Parameter(Mandatory = $false, ParameterSetName = "Name", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Id", ValueFromPipeline = $false)]
        [switch]
        $User,

        [Parameter(Mandatory = $false, ParameterSetName = "Name", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "Name", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "Id", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "Id", ValueFromPipeline = $false)]
        [string[]]
        $Id,

        [Parameter(Mandatory = $false, ParameterSetName = "Id", ValueFromPipeline = $false)]
        [string]
        $Domain
    )

    return $null
}

function Get-VICredentialStoreItem {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Host,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $User,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $File
    )

    return $null
}

function Get-VIEvent {
    [CmdletBinding(DefaultParameterSetName = "DefaultSet")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "DefaultSet", ValueFromPipeline = $true)]
        [VMware.VimAutomation.Sdk.Types.V1.VIObject[]]
        $Entity,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultSet", ValueFromPipeline = $false)]
        [System.Nullable[datetime]]
        $Start,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultSet", ValueFromPipeline = $false)]
        [System.Nullable[datetime]]
        $Finish,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultSet", ValueFromPipeline = $false)]
        [string]
        $Username,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultSet", ValueFromPipeline = $false)]
        [int]
        $MaxSamples,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultSet", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.EventCategory[]]
        $Types,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultSet", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-View {
    [CmdletBinding(DefaultParameterSetName = "GetViewByVIObject")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "GetViewByVIObject", ValueFromPipeline = $true)]
        [VMware.VimAutomation.Sdk.Types.V1.VIObject[]]
        $VIObject,

        [Parameter(Mandatory = $false, ParameterSetName = "GetViewByVIObject", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "GetView", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "GetEntity", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "GetViewByRelatedObject", ValueFromPipeline = $false)]
        [string[]]
        $Property,

        [Parameter(Mandatory = $false, ParameterSetName = "GetView", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "GetEntity", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $true, ParameterSetName = "GetView", ValueFromPipeline = $false)]
        $Id,

        [Parameter(Mandatory = $false, ParameterSetName = "GetEntity", ValueFromPipeline = $false)]
        [VMware.Vim.ManagedObjectReference]
        $SearchRoot,

        [Parameter(Mandatory = $true, ParameterSetName = "GetEntity", ValueFromPipeline = $false)]
        [type]
        $ViewType,

        [Parameter(Mandatory = $false, ParameterSetName = "GetEntity", ValueFromPipeline = $false)]
        [hashtable]
        $Filter,

        [Parameter(Mandatory = $true, ParameterSetName = "GetViewByRelatedObject", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.ViewBaseMirroredObject[]]
        $RelatedObject
    )

    return $null
}

function Get-VIObjectByVIView {
    [CmdletBinding(DefaultParameterSetName = "GetByVIVIew")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "GetByVIVIew", ValueFromPipeline = $true)]
        [VMware.Vim.ViewBase[]]
        $VIView,

        [Parameter(Mandatory = $false, ParameterSetName = "GetByMoRef", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $true, ParameterSetName = "GetByMoRef", ValueFromPipeline = $true)]
        [VMware.Vim.ManagedObjectReference[]]
        $MORef
    )

    return $null
}

function Get-VIPermission {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        $Entity,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.PermissionManagement.VIAccount[]]
        $Principal,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-VIPrivilege {
    [CmdletBinding(DefaultParameterSetName = "Server")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Server", ValueFromPipeline = $false)]
        [switch]
        $PrivilegeGroup,

        [Parameter(Mandatory = $false, ParameterSetName = "Server", ValueFromPipeline = $false)]
        [switch]
        $PrivilegeItem,

        [Parameter(Mandatory = $false, ParameterSetName = "Server", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Role", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Group", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "Server", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Role", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Group", ValueFromPipeline = $false)]
        [string[]]
        $Id,

        [Parameter(Mandatory = $false, ParameterSetName = "Server", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "Role", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.PermissionManagement.Role[]]
        $Role,

        [Parameter(Mandatory = $false, ParameterSetName = "Group", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.PermissionManagement.PrivilegeGroup[]]
        $Group
    )

    return $null
}

function Get-VIProperty {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string[]]
        $ObjectType,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $DeclaredOnly
    )

    return $null
}

function Get-VIRole {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string[]]
        $Id,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-VirtualPortGroup {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.VirtualSwitchBase[]]
        $VirtualSwitch,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Datacenter[]]
        $Datacenter,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [switch]
        $Standard,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [switch]
        $Distributed,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Tagging.Tag[]]
        $Tag,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ById", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "ById", ValueFromPipeline = $false)]
        [string[]]
        $Id,

        [Parameter(Mandatory = $true, ParameterSetName = "RelatedObjectParamSet", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.RelatedObject.VirtualPortGroupRelatedObjectBase[]]
        $RelatedObject
    )

    return $null
}

function Get-VirtualSwitch {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Datacenter[]]
        $Datacenter,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [switch]
        $Standard,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [switch]
        $Distributed,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ById", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "ById", ValueFromPipeline = $false)]
        [string[]]
        $Id,

        [Parameter(Mandatory = $true, ParameterSetName = "RelatedObjectParamSet", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.RelatedObject.VirtualSwitchRelatedObjectBase[]]
        $RelatedObject
    )

    return $null
}

function Get-VM {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "DistributedSwitch", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "DistributedSwitch", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ById", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.DatastoreManagement.StorageResource[]]
        $Datastore,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VIContainer[]]
        $Location,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "DistributedSwitch", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Tagging.Tag[]]
        $Tag,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [switch]
        $NoRecursion,

        [Parameter(Mandatory = $false, ParameterSetName = "DistributedSwitch", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.VirtualSwitchBase[]]
        $VirtualSwitch,

        [Parameter(Mandatory = $false, ParameterSetName = "ById", ValueFromPipeline = $false)]
        [string[]]
        $Id,

        [Parameter(Mandatory = $true, ParameterSetName = "RelatedObject", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.RelatedObject.VmRelatedObjectBase[]]
        $RelatedObject
    )

    return $null
}

function Get-VMGuest {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-VMHost {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "DistributedSwitch", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "SecondaryParameterSet", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "SecondaryParameterSet", ValueFromPipeline = $false)]
        [switch]
        $NoRecursion,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "SecondaryParameterSet", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.DatastoreManagement.StorageResource[]]
        $Datastore,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.VMHostState[]]
        $State,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "SecondaryParameterSet", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VIContainer[]]
        $Location,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "DistributedSwitch", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "SecondaryParameterSet", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Tagging.Tag[]]
        $Tag,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "DistributedSwitch", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "SecondaryParameterSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ById", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "DistributedSwitch", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.DistributedSwitch[]]
        $DistributedSwitch,

        [Parameter(Mandatory = $false, ParameterSetName = "SecondaryParameterSet", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "SecondaryParameterSet", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.ResourcePool[]]
        $ResourcePool,

        [Parameter(Mandatory = $false, ParameterSetName = "ById", ValueFromPipeline = $false)]
        [string[]]
        $Id,

        [Parameter(Mandatory = $true, ParameterSetName = "RelatedObject", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.RelatedObject.VMHostRelatedObjectBase[]]
        $RelatedObject
    )

    return $null
}

function Get-VMHostAccount {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Group,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $User,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string[]]
        $Id,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-VMHostAdvancedConfiguration {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-VMHostAuthentication {
    [CmdletBinding(DefaultParameterSetName = "default")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "byId", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "byId", ValueFromPipeline = $false)]
        [string[]]
        $Id
    )

    return $null
}

function Get-VMHostAvailableTimeZone {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-VMHostDiagnosticPartition {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $All,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-VMHostDisk {
    [CmdletBinding(DefaultParameterSetName = "vmhost")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "vmhost", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "vmhost", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "byId", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "byId", ValueFromPipeline = $false)]
        [string[]]
        $Id,

        [Parameter(Mandatory = $false, ParameterSetName = "scsilun", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Storage.Scsi.ScsiLun[]]
        $ScsiLun
    )

    return $null
}

function Get-VMHostDiskPartition {
    [CmdletBinding(DefaultParameterSetName = "byVMHostDisk")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "byVMHostDisk", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Storage.VMHostDisk[]]
        $VMHostDisk,

        [Parameter(Mandatory = $false, ParameterSetName = "byId", ValueFromPipeline = $false)]
        [string[]]
        $Id,

        [Parameter(Mandatory = $false, ParameterSetName = "byId", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-VMHostFirewallDefaultPolicy {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-VMHostFirewallException {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int[]]
        $Port,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $Enabled,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-VMHostFirmware {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "Backup", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Backup", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "Backup", ValueFromPipeline = $false)]
        [switch]
        $BackupConfiguration,

        [Parameter(Mandatory = $true, ParameterSetName = "Backup", ValueFromPipeline = $false)]
        [string]
        $DestinationPath
    )

    return $null
}

function Get-VMHostHardware {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "GetById", ValueFromPipeline = $false)]
        [switch]
        $WaitForAllData,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "GetById", ValueFromPipeline = $false)]
        [switch]
        $SkipCACheck,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "GetById", ValueFromPipeline = $false)]
        [switch]
        $SkipCNCheck,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "GetById", ValueFromPipeline = $false)]
        [switch]
        $SkipRevocationCheck,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "GetById", ValueFromPipeline = $false)]
        [switch]
        $SkipAllSslCertificateChecks,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "GetById", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "GetById", ValueFromPipeline = $false)]
        [string[]]
        $Id
    )

    return $null
}

function Get-VMHostHba {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string[]]
        $Device,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Storage.HbaType[]]
        $Type,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-VMHostModule {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-VMHostNetwork {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost
    )

    return $null
}

function Get-VMHostNetworkAdapter {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        $VirtualSwitch,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        $PortGroup,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Physical,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $VMKernel,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Console,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string[]]
        $Id,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-VMHostNtpServer {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-VMHostPatch {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-VMHostPciDevice {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.PciDeviceClass[]]
        $DeviceClass,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-VMHostProfile {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string[]]
        $Description,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.InventoryItem[]]
        $Entity,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $ReferenceHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string[]]
        $Id,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-VMHostProfileImageCacheConfiguration {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Profile.VMHostProfile[]]
        $HostProfile,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-VMHostProfileRequiredInput {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [hashtable]
        $Variable,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Profile.VMHostProfile]
        $Profile,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Inapplicable,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-VMHostProfileStorageDeviceConfiguration {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Profile.VMHostProfile[]]
        $HostProfile,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string[]]
        $DeviceName,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-VMHostProfileUserConfiguration {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Profile.VMHostProfile[]]
        $HostProfile,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string[]]
        $UserName,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-VMHostProfileVmPortGroupConfiguration {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Profile.VMHostProfile[]]
        $HostProfile,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string[]]
        $PortGroupName,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-VMHostRoute {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-VMHostService {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Refresh,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-VMHostSnmp {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-VMHostStartPolicy {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-VMHostStorage {
    [CmdletBinding(DefaultParameterSetName = "default")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "default", ValueFromPipeline = $false)]
        [switch]
        $Refresh,

        [Parameter(Mandatory = $false, ParameterSetName = "default", ValueFromPipeline = $false)]
        [switch]
        $RescanAllHba,

        [Parameter(Mandatory = $false, ParameterSetName = "default", ValueFromPipeline = $false)]
        [switch]
        $RescanVmfs,

        [Parameter(Mandatory = $false, ParameterSetName = "default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "byId", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "byId", ValueFromPipeline = $false)]
        [string[]]
        $Id
    )

    return $null
}

function Get-VMHostSysLogServer {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-VMQuestion {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $QuestionText,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $QuestionId,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Get-VMResourceConfiguration {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM
    )

    return $null
}

function Get-VMStartPolicy {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Import-VApp {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Source,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [hashtable]
        $OvfConfiguration,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VIContainer]
        $Location,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.FolderContainer]
        $InventoryLocation,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.DatastoreManagement.StorageResource]
        $Datastore,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Force,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.VirtualDiskStorageFormat]
        $DiskStorageFormat,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Import-VMHostProfile {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $FilePath,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]
        $ReferenceHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Description,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Install-VMHostPatch {
    [CmdletBinding(DefaultParameterSetName = "")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "HostPath", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "WebPath", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "LocalPath", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $true, ParameterSetName = "HostPath", ValueFromPipeline = $false)]
        [string[]]
        $HostPath,

        [Parameter(Mandatory = $false, ParameterSetName = "HostPath", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "WebPath", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "LocalPath", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "HostPath", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "WebPath", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "LocalPath", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "HostPath", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "WebPath", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "LocalPath", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "HostPath", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "WebPath", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "LocalPath", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $true, ParameterSetName = "WebPath", ValueFromPipeline = $false)]
        [string[]]
        $WebPath,

        [Parameter(Mandatory = $true, ParameterSetName = "LocalPath", ValueFromPipeline = $false)]
        [string[]]
        $LocalPath,

        [Parameter(Mandatory = $false, ParameterSetName = "LocalPath", ValueFromPipeline = $false)]
        [string]
        $HostUsername,

        [Parameter(Mandatory = $false, ParameterSetName = "LocalPath", ValueFromPipeline = $false)]
        [securestring]
        $HostPassword,

        [Parameter(Mandatory = $false, ParameterSetName = "LocalPath", ValueFromPipeline = $false)]
        [pscredential]
        $HostCredential
    )

    return $null
}

function Invoke-DrsRecommendation {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    [Alias('Apply-DrsRecommendation')]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Cluster.DrsRecommendation[]]
        $DrsRecommendation,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Invoke-VMHostProfile {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.InventoryItem[]]
        $Entity,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Profile.VMHostProfile]
        $Profile,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [hashtable]
        $Variable,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $AssociateOnly,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $ApplyOnly,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Invoke-VMScript {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $ScriptText,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [pscredential]
        $HostCredential,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $HostUser,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [securestring]
        $HostPassword,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [pscredential]
        $GuestCredential,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $GuestUser,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [securestring]
        $GuestPassword,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $ToolsWaitSecs,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.ScriptType]
        $ScriptType,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Mount-Tools {
    [CmdletBinding(DefaultParameterSetName = "")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "VMGuest", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VM.Guest.VMGuest[]]
        $Guest,

        [Parameter(Mandatory = $false, ParameterSetName = "Vm", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "Vm", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Move-Cluster {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Cluster[]]
        $Cluster,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VIContainer]
        $Destination,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Move-Datacenter {
    [CmdletBinding(DefaultParameterSetName = "MoveDatacenterSet")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "MoveDatacenterSet", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Datacenter[]]
        $Datacenter,

        [Parameter(Mandatory = $false, ParameterSetName = "MoveDatacenterSet", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VIContainer]
        $Destination,

        [Parameter(Mandatory = $false, ParameterSetName = "MoveDatacenterSet", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "MoveDatacenterSet", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "MoveDatacenterSet", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "MoveDatacenterSet", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Move-Datastore {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.DatastoreManagement.Datastore[]]
        $Datastore,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.Sdk.Types.V1.VIObject]
        $Destination,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Move-Folder {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Folder[]]
        $Folder,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VIContainer]
        $Destination,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Move-HardDisk {
    [CmdletBinding(DefaultParameterSetName = "UpdateHardDisk")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "UpdateHardDisk", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.HardDisk[]]
        $HardDisk,

        [Parameter(Mandatory = $false, ParameterSetName = "UpdateHardDisk", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.DatastoreManagement.Datastore]
        $Datastore,

        [Parameter(Mandatory = $false, ParameterSetName = "UpdateHardDisk", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.VirtualDiskStorageFormat]
        $StorageFormat,

        [Parameter(Mandatory = $false, ParameterSetName = "UpdateHardDisk", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "UpdateHardDisk", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "UpdateHardDisk", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "UpdateHardDisk", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Move-Inventory {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.InventoryItem[]]
        $Item,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VIContainer]
        $Destination,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Move-ResourcePool {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.ResourcePool[]]
        $ResourcePool,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VIContainer]
        $Destination,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Move-Template {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Template[]]
        $Template,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VIContainer]
        $Destination,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Move-VApp {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VIContainer]
        $Destination,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VApp[]]
        $VApp,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Move-VM {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.AdvancedOption[]]
        $AdvancedOption,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VIContainer]
        $Destination,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.DatastoreManagement.StorageResource]
        $Datastore,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.VirtualDiskStorageFormat]
        $DiskStorageFormat,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VMotionPriority]
        $VMotionPriority,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.NetworkAdapter[]]
        $NetworkAdapter,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.VirtualPortGroupBase[]]
        $PortGroup,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.FolderContainer]
        $InventoryLocation,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Move-VMHost {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VIContainer]
        $Destination,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function New-AdvancedSetting {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [System.Object]
        $Value,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.Sdk.Types.V1.VIObject]
        $Entity,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.AdvancedSettingType]
        $Type,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Force,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function New-AlarmAction {
    [CmdletBinding(DefaultParameterSetName = "")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "email", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "script", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "snmp", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Alarm.AlarmDefinition]
        $AlarmDefinition,

        [Parameter(Mandatory = $true, ParameterSetName = "email", ValueFromPipeline = $false)]
        [switch]
        $Email,

        [Parameter(Mandatory = $false, ParameterSetName = "email", ValueFromPipeline = $false)]
        [string]
        $Subject,

        [Parameter(Mandatory = $true, ParameterSetName = "email", ValueFromPipeline = $false)]
        [string[]]
        $To,

        [Parameter(Mandatory = $false, ParameterSetName = "email", ValueFromPipeline = $false)]
        [string[]]
        $Cc,

        [Parameter(Mandatory = $false, ParameterSetName = "email", ValueFromPipeline = $false)]
        [string]
        $Body,

        [Parameter(Mandatory = $false, ParameterSetName = "email", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "script", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "snmp", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "email", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "script", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "snmp", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "email", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "script", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "snmp", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $true, ParameterSetName = "script", ValueFromPipeline = $false)]
        [switch]
        $Script,

        [Parameter(Mandatory = $true, ParameterSetName = "script", ValueFromPipeline = $false)]
        [string]
        $ScriptPath,

        [Parameter(Mandatory = $true, ParameterSetName = "snmp", ValueFromPipeline = $false)]
        [switch]
        $Snmp
    )

    return $null
}

function New-AlarmActionTrigger {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.InventoryItemStatus]
        $StartStatus,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.InventoryItemStatus]
        $EndStatus,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Alarm.AlarmAction]
        $AlarmAction,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Repeat,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function New-CDDrive {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string]
        $IsoPath,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string]
        $HostDevice,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [switch]
        $StartConnected,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromContentLibraryIso", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromContentLibraryIso", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromContentLibraryIso", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromContentLibraryIso", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $false, ParameterSetName = "FromContentLibraryIso", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.ContentLibrary.ContentLibraryItem]
        $ContentLibraryIso
    )

    return $null
}

function New-Cluster {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Cluster.HARestartPriority]
        $HARestartPriority,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Cluster.HAIsolationResponse]
        $HAIsolationResponse,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VMSwapfilePolicy]
        $VMSwapfilePolicy,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VIContainer]
        $Location,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $HAEnabled,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $HAAdmissionControlEnabled,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $HAFailoverLevel,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $DrsEnabled,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Cluster.DrsMode]
        $DrsMode,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Cluster.DrsAutomationLevel]
        $DrsAutomationLevel,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Vsan.VsanDiskClaimMode]
        $VsanDiskClaimMode,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $VsanEnabled,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $EVCMode,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function New-CustomAttribute {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.AnnotationManagement.CustomAttributeTargetType[]]
        $TargetType,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function New-Datacenter {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VIContainer]
        $Location,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function New-Datastore {
    [CmdletBinding(DefaultParameterSetName = "")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "NFS", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "VMFS", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "NFS", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "VMFS", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]
        $VMHost,

        [Parameter(Mandatory = $true, ParameterSetName = "NFS", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $true, ParameterSetName = "VMFS", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = "NFS", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $true, ParameterSetName = "VMFS", ValueFromPipeline = $false)]
        [string]
        $Path,

        [Parameter(Mandatory = $false, ParameterSetName = "NFS", ValueFromPipeline = $false)]
        [switch]
        $Nfs,

        [Parameter(Mandatory = $true, ParameterSetName = "NFS", ValueFromPipeline = $false)]
        [string[]]
        $NfsHost,

        [Parameter(Mandatory = $false, ParameterSetName = "NFS", ValueFromPipeline = $false)]
        [switch]
        $ReadOnly,

        [Parameter(Mandatory = $false, ParameterSetName = "NFS", ValueFromPipeline = $false)]
        [switch]
        $Kerberos,

        [Parameter(Mandatory = $false, ParameterSetName = "NFS", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "VMFS", ValueFromPipeline = $false)]
        [string]
        $FileSystemVersion,

        [Parameter(Mandatory = $false, ParameterSetName = "NFS", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "VMFS", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "NFS", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "VMFS", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $false, ParameterSetName = "VMFS", ValueFromPipeline = $false)]
        [switch]
        $Vmfs,

        [Parameter(Mandatory = $false, ParameterSetName = "VMFS", ValueFromPipeline = $false)]
        [int]
        $BlockSizeMB
    )

    return $null
}

function New-DatastoreCluster {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VIContainer]
        $Location,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function New-DrsClusterGroup {
    [CmdletBinding(DefaultParameterSetName = "")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "DrsClusterVMGroup", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $true, ParameterSetName = "DrsClusterVMHostGroup", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "DrsClusterVMGroup", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "DrsClusterVMHostGroup", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Cluster]
        $Cluster,

        [Parameter(Mandatory = $false, ParameterSetName = "DrsClusterVMGroup", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "DrsClusterVMGroup", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "DrsClusterVMHostGroup", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "DrsClusterVMGroup", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "DrsClusterVMHostGroup", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "DrsClusterVMGroup", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "DrsClusterVMHostGroup", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "DrsClusterVMGroup", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "DrsClusterVMHostGroup", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $false, ParameterSetName = "DrsClusterVMHostGroup", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost
    )

    return $null
}

function New-DrsRule {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Cluster]
        $Cluster,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $Enabled,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $KeepTogether,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function New-DrsVMHostRule {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $Enabled,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Cluster]
        $Cluster,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Cluster.DrsClusterVMGroup]
        $VMGroup,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Cluster.DrsClusterVMHostGroup]
        $VMHostGroup,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Cluster.DrsVMHostRuleType]
        $Type,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function New-FloppyDrive {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $FloppyImagePath,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $NewFloppyImagePath,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $HostDevice,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $StartConnected,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function New-Folder {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VIContainer]
        $Location,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function New-HardDisk {
    [CmdletBinding(DefaultParameterSetName = "CreateNew")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "CreateNew", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.AdvancedOption[]]
        $AdvancedOption,

        [Parameter(Mandatory = $false, ParameterSetName = "CreateNew", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "UseExisting", ValueFromPipeline = $false)]
        [string]
        $Persistence,

        [Parameter(Mandatory = $false, ParameterSetName = "CreateNew", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "UseExisting", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "AttachVDisk", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.ScsiController]
        $Controller,

        [Parameter(Mandatory = $false, ParameterSetName = "CreateNew", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.DiskType]
        $DiskType,

        [Parameter(Mandatory = $false, ParameterSetName = "CreateNew", ValueFromPipeline = $false)]
        [long]
        $CapacityKB,

        [Parameter(Mandatory = $false, ParameterSetName = "CreateNew", ValueFromPipeline = $false)]
        [decimal]
        $CapacityGB,

        [Parameter(Mandatory = $false, ParameterSetName = "CreateNew", ValueFromPipeline = $false)]
        [switch]
        $Split,

        [Parameter(Mandatory = $false, ParameterSetName = "CreateNew", ValueFromPipeline = $false)]
        [switch]
        $ThinProvisioned,

        [Parameter(Mandatory = $false, ParameterSetName = "CreateNew", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.VirtualDiskStorageFormat]
        $StorageFormat,

        [Parameter(Mandatory = $false, ParameterSetName = "CreateNew", ValueFromPipeline = $false)]
        [string]
        $DeviceName,

        [Parameter(Mandatory = $false, ParameterSetName = "CreateNew", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.DatastoreManagement.StorageResource]
        $Datastore,

        [Parameter(Mandatory = $false, ParameterSetName = "CreateNew", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Security.KmsCluster]
        $KmsCluster,

        [Parameter(Mandatory = $false, ParameterSetName = "CreateNew", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Storage.StoragePolicy]
        $StoragePolicy,

        [Parameter(Mandatory = $false, ParameterSetName = "CreateNew", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "UseExisting", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "AttachVDisk", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "CreateNew", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "UseExisting", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "AttachVDisk", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "CreateNew", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "UseExisting", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "AttachVDisk", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "CreateNew", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "UseExisting", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "AttachVDisk", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $true, ParameterSetName = "UseExisting", ValueFromPipeline = $false)]
        [string]
        $DiskPath,

        [Parameter(Mandatory = $false, ParameterSetName = "AttachVDisk", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Storage.VDisk.VDisk]
        $VDisk
    )

    return $null
}

function New-IScsiHbaTarget {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Storage.IScsiHba]
        $IScsiHba,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Address,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $Port,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Storage.IScsiHbaTargetType]
        $Type,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $IScsiName,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Storage.ChapType]
        $ChapType,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $ChapName,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $ChapPassword,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $MutualChapEnabled,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $MutualChapName,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $MutualChapPassword,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $InheritChap,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $InheritMutualChap,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function New-NetworkAdapter {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Advanced", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ConnectToPortgroup", ValueFromPipeline = $false)]
        [string]
        $MacAddress,

        [Parameter(Mandatory = $true, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string]
        $NetworkName,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Advanced", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ConnectToPortgroup", ValueFromPipeline = $false)]
        [switch]
        $StartConnected,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Advanced", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ConnectToPortgroup", ValueFromPipeline = $false)]
        [switch]
        $WakeOnLan,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Advanced", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ConnectToPortgroup", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.VirtualNetworkAdapterType]
        $Type,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "Advanced", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "ConnectToPortgroup", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Advanced", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ConnectToPortgroup", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Advanced", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ConnectToPortgroup", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Advanced", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ConnectToPortgroup", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $true, ParameterSetName = "Advanced", ValueFromPipeline = $false)]
        [string]
        $PortId,

        [Parameter(Mandatory = $false, ParameterSetName = "Advanced", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.DistributedSwitch]
        $DistributedSwitch,

        [Parameter(Mandatory = $true, ParameterSetName = "ConnectToPortgroup", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.VirtualPortGroupBase]
        $Portgroup
    )

    return $null
}

function New-NfsUser {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string]
        $Username,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string]
        $Password,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [switch]
        $Force,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function New-OSCustomizationNicMapping {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "Nic", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "Positional", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.OSCustomization.OSCustomizationSpec]
        $OSCustomizationSpec,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Nic", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Positional", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Nic", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Positional", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.OSCustomization.OSCustomizationIPMode]
        $IpMode,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Nic", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Positional", ValueFromPipeline = $false)]
        [string]
        $VCApplicationArgument,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Nic", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Positional", ValueFromPipeline = $false)]
        [string]
        $IpAddress,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Nic", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Positional", ValueFromPipeline = $false)]
        [string]
        $SubnetMask,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Nic", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Positional", ValueFromPipeline = $false)]
        [string]
        $DefaultGateway,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Nic", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Positional", ValueFromPipeline = $false)]
        [string]
        $AlternateGateway,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Nic", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Positional", ValueFromPipeline = $false)]
        [string[]]
        $Dns,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Nic", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Positional", ValueFromPipeline = $false)]
        [string[]]
        $Wins,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Nic", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Positional", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Nic", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Positional", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $false, ParameterSetName = "Nic", ValueFromPipeline = $false)]
        [string[]]
        $NetworkAdapterMac,

        [Parameter(Mandatory = $false, ParameterSetName = "Positional", ValueFromPipeline = $false)]
        [int[]]
        $Position
    )

    return $null
}

function New-OSCustomizationSpec {
    [CmdletBinding(DefaultParameterSetName = "Linux")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Linux", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [string]
        $OSType,

        [Parameter(Mandatory = $false, ParameterSetName = "Linux", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "Cloning", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "Linux", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Cloning", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "Linux", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Cloning", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.OSCustomization.OSCustomizationSpecType]
        $Type,

        [Parameter(Mandatory = $false, ParameterSetName = "Linux", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [string[]]
        $DnsServer,

        [Parameter(Mandatory = $false, ParameterSetName = "Linux", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [string[]]
        $DnsSuffix,

        [Parameter(Mandatory = $false, ParameterSetName = "Linux", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [string]
        $Domain,

        [Parameter(Mandatory = $false, ParameterSetName = "Linux", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [string]
        $NamingScheme,

        [Parameter(Mandatory = $false, ParameterSetName = "Linux", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [string]
        $NamingPrefix,

        [Parameter(Mandatory = $false, ParameterSetName = "Linux", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [string]
        $Description,

        [Parameter(Mandatory = $false, ParameterSetName = "Linux", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Cloning", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "Linux", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Cloning", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $true, ParameterSetName = "Cloning", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.OSCustomization.OSCustomizationSpec]
        $OSCustomizationSpec,

        [Parameter(Mandatory = $true, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [string]
        $FullName,

        [Parameter(Mandatory = $true, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [string]
        $OrgName,

        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [switch]
        $ChangeSid,

        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [switch]
        $DeleteAccounts,

        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [string[]]
        $GuiRunOnce,

        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [string]
        $AdminPassword,

        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [string]
        $TimeZone,

        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [int]
        $AutoLogonCount,

        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [string]
        $Workgroup,

        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [pscredential]
        $DomainCredentials,

        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [string]
        $DomainUsername,

        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [string]
        $DomainPassword,

        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [string]
        $ProductKey,

        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.OSCustomization.LicenseMode]
        $LicenseMode,

        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [int]
        $LicenseMaxConnections
    )

    return $null
}

function New-ResourcePool {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VIContainer]
        $Location,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $CpuExpandableReservation,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [long]
        $CpuLimitMhz,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [long]
        $CpuReservationMhz,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.SharesLevel]
        $CpuSharesLevel,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $MemExpandableReservation,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [long]
        $MemLimitMB,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [decimal]
        $MemLimitGB,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [long]
        $MemReservationMB,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [decimal]
        $MemReservationGB,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.SharesLevel]
        $MemSharesLevel,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $NumCpuShares,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $NumMemShares,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function New-ScsiController {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.HardDisk]
        $HardDisk,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.ScsiControllerType]
        $Type,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.ScsiBusSharingMode]
        $BusSharingMode,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function New-Snapshot {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine]
        $VM,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Description,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Memory,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Quiesce,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function New-StatInterval {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $SamplingPeriodSecs,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $StorageTimeSecs,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function New-Tag {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Tagging.TagCategory]
        $Category,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Description,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function New-TagAssignment {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Tagging.Tag]
        $Tag,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.Sdk.Types.V1.VIObjectCore]
        $Entity,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function New-TagCategory {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Description,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Cardinality]
        $Cardinality,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string[]]
        $EntityType,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function New-Template {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine]
        $VM,

        [Parameter(Mandatory = $true, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "clone", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "register", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "clone", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "register", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VIContainer]
        $Location,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "clone", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.DatastoreManagement.StorageResource]
        $Datastore,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "clone", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "register", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "clone", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "register", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "clone", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "register", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "clone", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "register", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $false, ParameterSetName = "clone", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "register", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "clone", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.VirtualDiskStorageFormat]
        $DiskStorageFormat,

        [Parameter(Mandatory = $true, ParameterSetName = "clone", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Template]
        $Template,

        [Parameter(Mandatory = $true, ParameterSetName = "register", ValueFromPipeline = $false)]
        [string]
        $TemplateFilePath
    )

    return $null
}

function New-VApp {
    [CmdletBinding(DefaultParameterSetName = "new")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "new", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "clone", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromContentLibraryItem", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VIContainer]
        $Location,

        [Parameter(Mandatory = $false, ParameterSetName = "new", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "clone", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromContentLibraryItem", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.FolderContainer]
        $InventoryLocation,

        [Parameter(Mandatory = $true, ParameterSetName = "new", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "clone", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromContentLibraryItem", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "new", ValueFromPipeline = $false)]
        [bool]
        $CpuExpandableReservation,

        [Parameter(Mandatory = $false, ParameterSetName = "new", ValueFromPipeline = $false)]
        [long]
        $CpuLimitMhz,

        [Parameter(Mandatory = $false, ParameterSetName = "new", ValueFromPipeline = $false)]
        [long]
        $CpuReservationMhz,

        [Parameter(Mandatory = $false, ParameterSetName = "new", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.SharesLevel]
        $CpuSharesLevel,

        [Parameter(Mandatory = $false, ParameterSetName = "new", ValueFromPipeline = $false)]
        [bool]
        $MemExpandableReservation,

        [Parameter(Mandatory = $false, ParameterSetName = "new", ValueFromPipeline = $false)]
        [long]
        $MemLimitMB,

        [Parameter(Mandatory = $false, ParameterSetName = "new", ValueFromPipeline = $false)]
        [decimal]
        $MemLimitGB,

        [Parameter(Mandatory = $false, ParameterSetName = "new", ValueFromPipeline = $false)]
        [long]
        $MemReservationMB,

        [Parameter(Mandatory = $false, ParameterSetName = "new", ValueFromPipeline = $false)]
        [decimal]
        $MemReservationGB,

        [Parameter(Mandatory = $false, ParameterSetName = "new", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.SharesLevel]
        $MemSharesLevel,

        [Parameter(Mandatory = $false, ParameterSetName = "new", ValueFromPipeline = $false)]
        [int]
        $NumCpuShares,

        [Parameter(Mandatory = $false, ParameterSetName = "new", ValueFromPipeline = $false)]
        [int]
        $NumMemShares,

        [Parameter(Mandatory = $false, ParameterSetName = "new", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "clone", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromContentLibraryItem", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "new", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "clone", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromContentLibraryItem", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "new", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "clone", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromContentLibraryItem", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "new", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "clone", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromContentLibraryItem", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $false, ParameterSetName = "clone", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VApp]
        $VApp,

        [Parameter(Mandatory = $false, ParameterSetName = "clone", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "clone", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromContentLibraryItem", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.DatastoreManagement.Datastore]
        $Datastore,

        [Parameter(Mandatory = $false, ParameterSetName = "clone", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromContentLibraryItem", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.VirtualDiskStorageFormat]
        $DiskStorageFormat,

        [Parameter(Mandatory = $true, ParameterSetName = "FromContentLibraryItem", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.ContentLibrary.ContentLibraryItem]
        $ContentLibraryItem
    )

    return $null
}

function New-VICredentialStoreItem {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Host,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $User,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Password,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $File
    )

    return $null
}

function New-VIPermission {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        $Entity,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.PermissionManagement.VIAccount]
        $Principal,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.PermissionManagement.Role]
        $Role,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $Propagate,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function New-VIProperty {
    [CmdletBinding(DefaultParameterSetName = "")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "ValueFromScriptBlock", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $true, ParameterSetName = "ValueFromExtensionProperty", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = "ValueFromScriptBlock", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $true, ParameterSetName = "ValueFromExtensionProperty", ValueFromPipeline = $false)]
        [string[]]
        $ObjectType,

        [Parameter(Mandatory = $true, ParameterSetName = "ValueFromScriptBlock", ValueFromPipeline = $false)]
        [scriptblock]
        $Value,

        [Parameter(Mandatory = $false, ParameterSetName = "ValueFromScriptBlock", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ValueFromExtensionProperty", ValueFromPipeline = $false)]
        [switch]
        $Force,

        [Parameter(Mandatory = $false, ParameterSetName = "ValueFromScriptBlock", ValueFromPipeline = $false)]
        [string[]]
        $BasedOnExtensionProperty,

        [Parameter(Mandatory = $false, ParameterSetName = "ValueFromScriptBlock", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ValueFromExtensionProperty", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "ValueFromScriptBlock", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ValueFromExtensionProperty", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $true, ParameterSetName = "ValueFromExtensionProperty", ValueFromPipeline = $false)]
        [string]
        $ValueFromExtensionProperty
    )

    return $null
}

function New-VIRole {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.PermissionManagement.Privilege[]]
        $Privilege,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function New-VirtualPortGroup {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.VirtualSwitch]
        $VirtualSwitch,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $VLanId,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function New-VirtualSwitch {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]
        $VMHost,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $NumPorts,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.Nic.PhysicalNic[]]
        $Nic,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $Mtu,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function New-VISamlSecurityContext {
    [CmdletBinding(DefaultParameterSetName = "OAuth2SecurityContext")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "OAuth2SecurityContext", ValueFromPipeline = $true)]
        [string]
        $VCenterServer,

        [Parameter(Mandatory = $false, ParameterSetName = "OAuth2SecurityContext", ValueFromPipeline = $false)]
        [System.Nullable[int]]
        $Port,

        [Parameter(Mandatory = $false, ParameterSetName = "OAuth2SecurityContext", ValueFromPipeline = $false)]
        [switch]
        $IgnoreSslValidationErrors,

        [Parameter(Mandatory = $true, ParameterSetName = "OAuth2SecurityContext", ValueFromPipeline = $false)]
        [VMware.VimAutomation.Common.Types.V1.Authentication.OAuth2SecurityContext]
        $OAuthSecurityContext
    )

    return $null
}

function New-VM {
    [CmdletBinding(DefaultParameterSetName = "DefaultParameterSet")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "DefaultParameterSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "CloneVm", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Template", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.AdvancedOption[]]
        $AdvancedOption,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultParameterSet", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "CloneVm", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "Template", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "RegisterVm", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromContentLibraryItem", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultParameterSet", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VM.VMVersion]
        $Version,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultParameterSet", ValueFromPipeline = $false)]
        [string]
        $HardwareVersion,

        [Parameter(Mandatory = $true, ParameterSetName = "DefaultParameterSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "CloneVm", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $true, ParameterSetName = "Template", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "RegisterVm", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromContentLibraryItem", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultParameterSet", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "CloneVm", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "Template", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "RegisterVm", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromContentLibraryItem", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VIContainer]
        $ResourcePool,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultParameterSet", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "CloneVm", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "Template", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "RegisterVm", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VApp]
        $VApp,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultParameterSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "CloneVm", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Template", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "RegisterVm", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromContentLibraryItem", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Folder]
        $Location,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultParameterSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "CloneVm", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Template", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromContentLibraryItem", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.DatastoreManagement.StorageResource]
        $Datastore,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultParameterSet", ValueFromPipeline = $false)]
        [long[]]
        $DiskMB,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultParameterSet", ValueFromPipeline = $false)]
        [decimal[]]
        $DiskGB,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultParameterSet", ValueFromPipeline = $false)]
        [string[]]
        $DiskPath,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultParameterSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "CloneVm", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Template", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromContentLibraryItem", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.VirtualDiskStorageFormat]
        $DiskStorageFormat,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultParameterSet", ValueFromPipeline = $false)]
        [long]
        $MemoryMB,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultParameterSet", ValueFromPipeline = $false)]
        [decimal]
        $MemoryGB,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultParameterSet", ValueFromPipeline = $false)]
        [int]
        $NumCpu,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultParameterSet", ValueFromPipeline = $false)]
        [int]
        $CoresPerSocket,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultParameterSet", ValueFromPipeline = $false)]
        [switch]
        $Floppy,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultParameterSet", ValueFromPipeline = $false)]
        [switch]
        $CD,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultParameterSet", ValueFromPipeline = $false)]
        [string]
        $GuestId,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultParameterSet", ValueFromPipeline = $false)]
        [string]
        $AlternateGuestName,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultParameterSet", ValueFromPipeline = $false)]
        [string[]]
        $NetworkName,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultParameterSet", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.VirtualPortGroupBase[]]
        $Portgroup,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultParameterSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "CloneVm", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Template", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "RegisterVm", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromContentLibraryItem", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Cluster.HARestartPriority]
        $HARestartPriority,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultParameterSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "CloneVm", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Template", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "RegisterVm", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromContentLibraryItem", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Cluster.HAIsolationResponse]
        $HAIsolationResponse,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultParameterSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "CloneVm", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Template", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "RegisterVm", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromContentLibraryItem", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Cluster.DrsAutomationLevel]
        $DrsAutomationLevel,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultParameterSet", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VMSwapfilePolicy]
        $VMSwapfilePolicy,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultParameterSet", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Security.KmsCluster]
        $KmsCluster,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultParameterSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "CloneVm", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Template", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Storage.StoragePolicy]
        $StoragePolicy,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultParameterSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "CloneVm", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Template", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Storage.ReplicationGroup]
        $ReplicationGroup,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultParameterSet", ValueFromPipeline = $false)]
        [switch]
        $SkipHardDisks,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultParameterSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "CloneVm", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Template", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "RegisterVm", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromContentLibraryItem", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultParameterSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "CloneVm", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Template", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "RegisterVm", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromContentLibraryItem", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultParameterSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "CloneVm", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Template", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "RegisterVm", ValueFromPipeline = $false)]
        [string]
        $Notes,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultParameterSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "CloneVm", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Template", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "RegisterVm", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromContentLibraryItem", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultParameterSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "CloneVm", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Template", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "RegisterVm", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "FromContentLibraryItem", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $false, ParameterSetName = "CloneVm", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Template", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.OSCustomization.OSCustomizationSpec]
        $OSCustomizationSpec,

        [Parameter(Mandatory = $false, ParameterSetName = "CloneVm", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Template", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Storage.StoragePolicyTargetType]
        $StoragePolicyTarget,

        [Parameter(Mandatory = $false, ParameterSetName = "CloneVm", ValueFromPipeline = $false)]
        [switch]
        $LinkedClone,

        [Parameter(Mandatory = $false, ParameterSetName = "CloneVm", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VM.Snapshot]
        $ReferenceSnapshot,

        [Parameter(Mandatory = $true, ParameterSetName = "CloneVm", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $true, ParameterSetName = "Template", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Template]
        $Template,

        [Parameter(Mandatory = $true, ParameterSetName = "RegisterVm", ValueFromPipeline = $false)]
        [string]
        $VMFilePath,

        [Parameter(Mandatory = $true, ParameterSetName = "FromContentLibraryItem", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.ContentLibrary.ContentLibraryItem]
        $ContentLibraryItem
    )

    return $null
}

function New-VMHostAccount {
    [CmdletBinding(DefaultParameterSetName = "")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "User", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $true, ParameterSetName = "Group", ValueFromPipeline = $false)]
        [string]
        $Id,

        [Parameter(Mandatory = $true, ParameterSetName = "User", ValueFromPipeline = $false)]
        [string]
        $Password,

        [Parameter(Mandatory = $false, ParameterSetName = "User", ValueFromPipeline = $false)]
        [string]
        $Description,

        [Parameter(Mandatory = $false, ParameterSetName = "User", ValueFromPipeline = $false)]
        [switch]
        $UserAccount,

        [Parameter(Mandatory = $false, ParameterSetName = "User", ValueFromPipeline = $false)]
        [string[]]
        $AssignGroups,

        [Parameter(Mandatory = $false, ParameterSetName = "User", ValueFromPipeline = $false)]
        [switch]
        $GrantShellAccess,

        [Parameter(Mandatory = $false, ParameterSetName = "User", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "Group", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "User", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Group", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "User", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Group", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $false, ParameterSetName = "Group", ValueFromPipeline = $false)]
        [switch]
        $GroupAccount,

        [Parameter(Mandatory = $false, ParameterSetName = "Group", ValueFromPipeline = $false)]
        [string[]]
        $AssignUsers
    )

    return $null
}

function New-VMHostNetworkAdapter {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $PortGroup,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $PortId,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        $VirtualSwitch,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $IP,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $SubnetMask,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Mac,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $Mtu,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $ConsoleNic,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $VMotionEnabled,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $FaultToleranceLoggingEnabled,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $IPv6ThroughDhcp,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $AutomaticIPv6,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string[]]
        $IPv6,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $ManagementTrafficEnabled,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $VsanTrafficEnabled,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function New-VMHostProfile {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]
        $ReferenceHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Description,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $CompatibilityMode,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function New-VMHostProfileVmPortGroupConfiguration {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Profile.VMHostProfile]
        $HostProfile,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $PortGroupName,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $VSwitchName,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $VLanId,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function New-VMHostRoute {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]
        $VMHost,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [ipaddress]
        $Destination,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [ipaddress]
        $Gateway,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $PrefixLength,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Open-VMConsoleWindow {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VM.RemoteConsoleVM[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $FullScreen,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $UrlOnly,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.Sdk.Types.V1.VIConnection[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-AdvancedSetting {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.AdvancedSetting[]]
        $AdvancedSetting,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-AlarmAction {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Alarm.AlarmAction[]]
        $AlarmAction,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-AlarmActionTrigger {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Alarm.AlarmActionTrigger[]]
        $AlarmActionTrigger,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-CDDrive {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.CDDrive[]]
        $CD,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-Cluster {
    [CmdletBinding(DefaultParameterSetName = "DeleteFromDiskSet")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "DeleteFromDiskSet", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Cluster[]]
        $Cluster,

        [Parameter(Mandatory = $false, ParameterSetName = "DeleteFromDiskSet", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "DeleteFromDiskSet", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "DeleteFromDiskSet", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "DeleteFromDiskSet", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-CustomAttribute {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.AnnotationManagement.CustomAttribute[]]
        $CustomAttribute,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-Datacenter {
    [CmdletBinding(DefaultParameterSetName = "RemoveDatacenterSet")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "RemoveDatacenterSet", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Datacenter[]]
        $Datacenter,

        [Parameter(Mandatory = $false, ParameterSetName = "RemoveDatacenterSet", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "RemoveDatacenterSet", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "RemoveDatacenterSet", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "RemoveDatacenterSet", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-Datastore {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.DatastoreManagement.Datastore[]]
        $Datastore,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-DatastoreCluster {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.DatastoreManagement.DatastoreCluster[]]
        $DatastoreCluster,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-DrsClusterGroup {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Cluster.DrsClusterGroup[]]
        $DrsClusterGroup,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-DrsRule {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Cluster.DrsRule[]]
        $Rule,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-DrsVMHostRule {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Cluster.DrsVMHostRule[]]
        $Rule,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-FloppyDrive {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.FloppyDrive[]]
        $Floppy,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-Folder {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Folder[]]
        $Folder,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $DeletePermanently,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-HardDisk {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.HardDisk[]]
        $HardDisk,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $DeletePermanently,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-Inventory {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.InventoryItem[]]
        $Item,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-IScsiHbaTarget {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Storage.IScsiHbaTarget[]]
        $Target,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-NetworkAdapter {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.NetworkAdapter[]]
        $NetworkAdapter,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-NfsUser {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.Storage.Types.V1.Nfs.NfsUser[]]
        $NfsUser,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-OSCustomizationNicMapping {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.OSCustomization.OSCustomizationNicMapping[]]
        $OSCustomizationNicMapping,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-OSCustomizationSpec {
    [CmdletBinding(DefaultParameterSetName = "DefaultSet")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "DefaultSet", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.OSCustomization.OSCustomizationSpec[]]
        $OSCustomizationSpec,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultSet", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultSet", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultSet", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-PassthroughDevice {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.PassThroughDevice[]]
        $PassthroughDevice,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-ResourcePool {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.ResourcePool[]]
        $ResourcePool,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-Snapshot {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VM.Snapshot[]]
        $Snapshot,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RemoveChildren,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-StatInterval {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Stat.StatInterval[]]
        $Interval,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-Tag {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Tagging.Tag[]]
        $Tag,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-TagAssignment {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Tagging.TagAssignment[]]
        $TagAssignment,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-TagCategory {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Tagging.TagCategory[]]
        $Category,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-Template {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Template[]]
        $Template,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $DeletePermanently,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-UsbDevice {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.UsbDevice[]]
        $UsbDevice,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-VApp {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $DeletePermanently,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VApp[]]
        $VApp,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-VICredentialStoreItem {
    [CmdletBinding(DefaultParameterSetName = "")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "ByCredentialItemObject", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VICredentialStoreItem[]]
        $CredentialStoreItem,

        [Parameter(Mandatory = $false, ParameterSetName = "ByCredentialItemObject", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ByFilters", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "ByCredentialItemObject", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ByFilters", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $false, ParameterSetName = "ByFilters", ValueFromPipeline = $false)]
        [string]
        $Host,

        [Parameter(Mandatory = $false, ParameterSetName = "ByFilters", ValueFromPipeline = $false)]
        [string]
        $User,

        [Parameter(Mandatory = $false, ParameterSetName = "ByFilters", ValueFromPipeline = $false)]
        [string]
        $File
    )

    return $null
}

function Remove-VIPermission {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.PermissionManagement.Permission[]]
        $Permission,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-VIProperty {
    [CmdletBinding(DefaultParameterSetName = "VIProperty")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "VIProperty", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VIProperty[]]
        $VIProperty,

        [Parameter(Mandatory = $false, ParameterSetName = "VIProperty", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "VIProperty", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $true, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string[]]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string[]]
        $ObjectType
    )

    return $null
}

function Remove-VIRole {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.PermissionManagement.Role[]]
        $Role,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Force,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-VirtualPortGroup {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.VirtualPortGroup[]]
        $VirtualPortGroup,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-VirtualSwitch {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.VirtualSwitch[]]
        $VirtualSwitch,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-VirtualSwitchPhysicalNetworkAdapter {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.Nic.PhysicalNic[]]
        $VMHostNetworkAdapter,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-VM {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $DeletePermanently,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-VMHost {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-VMHostAccount {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Account.HostAccount[]]
        $HostAccount,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-VMHostNetworkAdapter {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.Nic.HostVirtualNic[]]
        $Nic,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-VMHostNtpServer {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string[]]
        $NtpServer,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Remove-VMHostProfile {
    [CmdletBinding(DefaultParameterSetName = "")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "ProfileParameterSet", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Profile.VMHostProfile[]]
        $Profile,

        [Parameter(Mandatory = $false, ParameterSetName = "ProfileParameterSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "EntityParameterSet", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "ProfileParameterSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "EntityParameterSet", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "ProfileParameterSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "EntityParameterSet", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $false, ParameterSetName = "EntityParameterSet", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.InventoryItem[]]
        $Entity
    )

    return $null
}

function Remove-VMHostProfileVmPortGroupConfiguration {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Profile.VMHostProfileVmPortGroupConfiguration[]]
        $VmPortGroupConfiguration,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Remove-VMHostRoute {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.VMHostRoute[]]
        $VMHostRoute,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Restart-VM {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Restart-VMGuest {
    [CmdletBinding(DefaultParameterSetName = "Vm")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Vm", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "Vm", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "Vm", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "VMGuest", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "Vm", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "VMGuest", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $false, ParameterSetName = "VMGuest", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VM.Guest.VMGuest[]]
        $Guest
    )

    return $null
}

function Restart-VMHost {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Force,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Evacuate,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Restart-VMHostService {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.HostService[]]
        $HostService,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-AdvancedSetting {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.AdvancedSetting[]]
        $AdvancedSetting,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [System.Object]
        $Value,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-AlarmDefinition {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Alarm.AlarmDefinition[]]
        $AlarmDefinition,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $ActionRepeatMinutes,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Description,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $Enabled,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-Annotation {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.InventoryItem[]]
        $Entity,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.AnnotationManagement.CustomAttribute]
        $CustomAttribute,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Value,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-CDDrive {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.CDDrive[]]
        $CD,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $IsoPath,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $HostDevice,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $NoMedia,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $StartConnected,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $Connected,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-Cluster {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Cluster.HARestartPriority]
        $HARestartPriority,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Cluster.HAIsolationResponse]
        $HAIsolationResponse,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VMSwapfilePolicy]
        $VMSwapfilePolicy,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Cluster[]]
        $Cluster,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $HAEnabled,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $HAAdmissionControlEnabled,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $HAFailoverLevel,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $DrsEnabled,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Cluster.DrsMode]
        $DrsMode,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Cluster.DrsAutomationLevel]
        $DrsAutomationLevel,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $VsanEnabled,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Vsan.VsanDiskClaimMode]
        $VsanDiskClaimMode,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Profile.VMHostProfile]
        $Profile,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $EVCMode,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-CustomAttribute {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.AnnotationManagement.CustomAttribute[]]
        $CustomAttribute,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-Datacenter {
    [CmdletBinding(DefaultParameterSetName = "SetDatacenterSet")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "SetDatacenterSet", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Datacenter[]]
        $Datacenter,

        [Parameter(Mandatory = $true, ParameterSetName = "SetDatacenterSet", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "SetDatacenterSet", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "SetDatacenterSet", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "SetDatacenterSet", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "SetDatacenterSet", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-Datastore {
    [CmdletBinding(DefaultParameterSetName = "Update")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Update", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "MaintenanceMode", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.DatastoreManagement.Datastore[]]
        $Datastore,

        [Parameter(Mandatory = $false, ParameterSetName = "Update", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "Update", ValueFromPipeline = $false)]
        [int]
        $CongestionThresholdMillisecond,

        [Parameter(Mandatory = $false, ParameterSetName = "Update", ValueFromPipeline = $false)]
        [bool]
        $StorageIOControlEnabled,

        [Parameter(Mandatory = $false, ParameterSetName = "Update", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "MaintenanceMode", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "Update", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "MaintenanceMode", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "Update", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "MaintenanceMode", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $true, ParameterSetName = "MaintenanceMode", ValueFromPipeline = $false)]
        [bool]
        $MaintenanceMode,

        [Parameter(Mandatory = $false, ParameterSetName = "MaintenanceMode", ValueFromPipeline = $false)]
        [switch]
        $EvacuateAutomatically,

        [Parameter(Mandatory = $false, ParameterSetName = "MaintenanceMode", ValueFromPipeline = $false)]
        [switch]
        $RunAsync
    )

    return $null
}

function Set-DatastoreCluster {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.DatastoreManagement.DatastoreCluster[]]
        $DatastoreCluster,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $IOLatencyThresholdMillisecond,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $IOLoadBalanceEnabled,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Cluster.DrsAutomationLevel]
        $SdrsAutomationLevel,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $SpaceUtilizationThresholdPercent,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-DrsClusterGroup {
    [CmdletBinding(DefaultParameterSetName = "")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "DrsClusterVMGroup", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "DrsClusterVMHostGroup", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Cluster.DrsClusterGroup]
        $DrsClusterGroup,

        [Parameter(Mandatory = $false, ParameterSetName = "DrsClusterVMGroup", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "DrsClusterVMGroup", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "DrsClusterVMHostGroup", ValueFromPipeline = $false)]
        [switch]
        $Add,

        [Parameter(Mandatory = $false, ParameterSetName = "DrsClusterVMGroup", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "DrsClusterVMHostGroup", ValueFromPipeline = $false)]
        [switch]
        $Remove,

        [Parameter(Mandatory = $false, ParameterSetName = "DrsClusterVMGroup", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "DrsClusterVMHostGroup", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "DrsClusterVMGroup", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "DrsClusterVMHostGroup", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "DrsClusterVMGroup", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "DrsClusterVMHostGroup", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "DrsClusterVMGroup", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "DrsClusterVMHostGroup", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $false, ParameterSetName = "DrsClusterVMHostGroup", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost
    )

    return $null
}

function Set-DrsRule {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $Enabled,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Cluster.DrsRule[]]
        $Rule,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-DrsVMHostRule {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $Enabled,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Cluster.DrsClusterVMGroup]
        $VMGroup,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Cluster.DrsClusterVMHostGroup]
        $VMHostGroup,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Cluster.DrsVMHostRule[]]
        $Rule,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Cluster.DrsVMHostRuleType]
        $Type,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-FloppyDrive {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.FloppyDrive[]]
        $Floppy,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $FloppyImagePath,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $HostDevice,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $NoMedia,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $StartConnected,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $Connected,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-Folder {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Folder[]]
        $Folder,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-HardDisk {
    [CmdletBinding(DefaultParameterSetName = "UpdateHardDisk")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "UpdateHardDisk", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "ResizeGuestPartition", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "InflateHardDisk", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "ZeroOutHardDisk", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "EncryptHardDisk", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "DecryptHardDisk", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.HardDisk[]]
        $HardDisk,

        [Parameter(Mandatory = $false, ParameterSetName = "UpdateHardDisk", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ResizeGuestPartition", ValueFromPipeline = $false)]
        [long]
        $CapacityKB,

        [Parameter(Mandatory = $false, ParameterSetName = "UpdateHardDisk", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ResizeGuestPartition", ValueFromPipeline = $false)]
        [decimal]
        $CapacityGB,

        [Parameter(Mandatory = $false, ParameterSetName = "UpdateHardDisk", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ResizeGuestPartition", ValueFromPipeline = $false)]
        [string]
        $Persistence,

        [Parameter(Mandatory = $false, ParameterSetName = "UpdateHardDisk", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ResizeGuestPartition", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.DatastoreManagement.Datastore]
        $Datastore,

        [Parameter(Mandatory = $false, ParameterSetName = "UpdateHardDisk", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ResizeGuestPartition", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.VirtualDiskStorageFormat]
        $StorageFormat,

        [Parameter(Mandatory = $false, ParameterSetName = "UpdateHardDisk", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ResizeGuestPartition", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.ScsiController]
        $Controller,

        [Parameter(Mandatory = $false, ParameterSetName = "UpdateHardDisk", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ResizeGuestPartition", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "UpdateHardDisk", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ResizeGuestPartition", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "InflateHardDisk", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ZeroOutHardDisk", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "EncryptHardDisk", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "DecryptHardDisk", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "UpdateHardDisk", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ResizeGuestPartition", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "InflateHardDisk", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ZeroOutHardDisk", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "EncryptHardDisk", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "DecryptHardDisk", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $false, ParameterSetName = "ResizeGuestPartition", ValueFromPipeline = $false)]
        [pscredential]
        $HostCredential,

        [Parameter(Mandatory = $false, ParameterSetName = "ResizeGuestPartition", ValueFromPipeline = $false)]
        [string]
        $HostUser,

        [Parameter(Mandatory = $false, ParameterSetName = "ResizeGuestPartition", ValueFromPipeline = $false)]
        [securestring]
        $HostPassword,

        [Parameter(Mandatory = $false, ParameterSetName = "ResizeGuestPartition", ValueFromPipeline = $false)]
        [pscredential]
        $GuestCredential,

        [Parameter(Mandatory = $false, ParameterSetName = "ResizeGuestPartition", ValueFromPipeline = $false)]
        [string]
        $GuestUser,

        [Parameter(Mandatory = $false, ParameterSetName = "ResizeGuestPartition", ValueFromPipeline = $false)]
        [securestring]
        $GuestPassword,

        [Parameter(Mandatory = $false, ParameterSetName = "ResizeGuestPartition", ValueFromPipeline = $false)]
        [int]
        $ToolsWaitSecs,

        [Parameter(Mandatory = $false, ParameterSetName = "ResizeGuestPartition", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine]
        $HelperVM,

        [Parameter(Mandatory = $false, ParameterSetName = "ResizeGuestPartition", ValueFromPipeline = $false)]
        [string]
        $Partition,

        [Parameter(Mandatory = $false, ParameterSetName = "ResizeGuestPartition", ValueFromPipeline = $false)]
        [switch]
        $ResizeGuestPartition,

        [Parameter(Mandatory = $false, ParameterSetName = "InflateHardDisk", ValueFromPipeline = $false)]
        [switch]
        $Inflate,

        [Parameter(Mandatory = $false, ParameterSetName = "ZeroOutHardDisk", ValueFromPipeline = $false)]
        [switch]
        $ZeroOut,

        [Parameter(Mandatory = $false, ParameterSetName = "EncryptHardDisk", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Security.KmsCluster]
        $KmsCluster,

        [Parameter(Mandatory = $false, ParameterSetName = "EncryptHardDisk", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Storage.StoragePolicy]
        $StoragePolicy,

        [Parameter(Mandatory = $false, ParameterSetName = "EncryptHardDisk", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "DecryptHardDisk", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $true, ParameterSetName = "DecryptHardDisk", ValueFromPipeline = $false)]
        [switch]
        $DisableEncryption
    )

    return $null
}

function Set-IScsiHbaTarget {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Storage.IScsiHbaTarget[]]
        $Target,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Storage.ChapType]
        $ChapType,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $ChapName,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $ChapPassword,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $MutualChapEnabled,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $MutualChapName,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $MutualChapPassword,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $InheritChap,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $InheritMutualChap,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-NetworkAdapter {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "ConnectToPortByKey", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "ConnectToPortgroup", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.NetworkAdapter[]]
        $NetworkAdapter,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ConnectToPortByKey", ValueFromPipeline = $false)]
        [string]
        $MacAddress,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string]
        $NetworkName,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ConnectToPortByKey", ValueFromPipeline = $false)]
        [bool]
        $StartConnected,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ConnectToPortByKey", ValueFromPipeline = $false)]
        [bool]
        $Connected,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ConnectToPortByKey", ValueFromPipeline = $false)]
        [bool]
        $WakeOnLan,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ConnectToPortByKey", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.VirtualNetworkAdapterType]
        $Type,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ConnectToPortByKey", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ConnectToPortgroup", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ConnectToPortByKey", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ConnectToPortgroup", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ConnectToPortByKey", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ConnectToPortgroup", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ConnectToPortByKey", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ConnectToPortgroup", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $true, ParameterSetName = "ConnectToPortByKey", ValueFromPipeline = $false)]
        [string]
        $PortId,

        [Parameter(Mandatory = $true, ParameterSetName = "ConnectToPortByKey", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.DistributedSwitch]
        $DistributedSwitch,

        [Parameter(Mandatory = $true, ParameterSetName = "ConnectToPortgroup", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.VirtualPortGroupBase]
        $Portgroup
    )

    return $null
}

function Set-NfsUser {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.Storage.Types.V1.Nfs.NfsUser[]]
        $NfsUser,

        [Parameter(Mandatory = $true, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string]
        $Password,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-NicTeamingPolicy {
    [CmdletBinding(DefaultParameterSetName = "")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "switch", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.NicTeamingVirtualSwitchPolicy[]]
        $VirtualSwitchPolicy,

        [Parameter(Mandatory = $false, ParameterSetName = "switch", ValueFromPipeline = $false)]
        [int]
        $BeaconInterval,

        [Parameter(Mandatory = $false, ParameterSetName = "switch", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "pg", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.LoadBalancingPolicy]
        $LoadBalancingPolicy,

        [Parameter(Mandatory = $false, ParameterSetName = "switch", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "pg", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.NetworkFailoverDetectionPolicy]
        $NetworkFailoverDetectionPolicy,

        [Parameter(Mandatory = $false, ParameterSetName = "switch", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "pg", ValueFromPipeline = $false)]
        [bool]
        $NotifySwitches,

        [Parameter(Mandatory = $false, ParameterSetName = "switch", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "pg", ValueFromPipeline = $false)]
        [bool]
        $FailbackEnabled,

        [Parameter(Mandatory = $false, ParameterSetName = "switch", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "pg", ValueFromPipeline = $false)]
        [string[]]
        $MakeNicActive,

        [Parameter(Mandatory = $false, ParameterSetName = "switch", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "pg", ValueFromPipeline = $false)]
        [string[]]
        $MakeNicStandby,

        [Parameter(Mandatory = $false, ParameterSetName = "switch", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "pg", ValueFromPipeline = $false)]
        [string[]]
        $MakeNicUnused,

        [Parameter(Mandatory = $false, ParameterSetName = "switch", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "pg", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "switch", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "pg", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $true, ParameterSetName = "pg", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.NicTeamingVirtualPortGroupPolicy[]]
        $VirtualPortGroupPolicy,

        [Parameter(Mandatory = $false, ParameterSetName = "pg", ValueFromPipeline = $false)]
        [bool]
        $InheritLoadBalancingPolicy,

        [Parameter(Mandatory = $false, ParameterSetName = "pg", ValueFromPipeline = $false)]
        [bool]
        $InheritNetworkFailoverDetectionPolicy,

        [Parameter(Mandatory = $false, ParameterSetName = "pg", ValueFromPipeline = $false)]
        [bool]
        $InheritNotifySwitches,

        [Parameter(Mandatory = $false, ParameterSetName = "pg", ValueFromPipeline = $false)]
        [bool]
        $InheritFailback,

        [Parameter(Mandatory = $false, ParameterSetName = "pg", ValueFromPipeline = $false)]
        [bool]
        $InheritFailoverOrder
    )

    return $null
}

function Set-OSCustomizationNicMapping {
    [CmdletBinding(DefaultParameterSetName = "Positional")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "Positional", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "Nic", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.OSCustomization.OSCustomizationNicMapping[]]
        $OSCustomizationNicMapping,

        [Parameter(Mandatory = $false, ParameterSetName = "Positional", ValueFromPipeline = $false)]
        [int]
        $Position,

        [Parameter(Mandatory = $false, ParameterSetName = "Positional", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Nic", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "Positional", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Nic", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.OSCustomization.OSCustomizationIPMode]
        $IpMode,

        [Parameter(Mandatory = $false, ParameterSetName = "Positional", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Nic", ValueFromPipeline = $false)]
        [string]
        $VCApplicationArgument,

        [Parameter(Mandatory = $false, ParameterSetName = "Positional", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Nic", ValueFromPipeline = $false)]
        [string]
        $IpAddress,

        [Parameter(Mandatory = $false, ParameterSetName = "Positional", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Nic", ValueFromPipeline = $false)]
        [string]
        $SubnetMask,

        [Parameter(Mandatory = $false, ParameterSetName = "Positional", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Nic", ValueFromPipeline = $false)]
        [string]
        $DefaultGateway,

        [Parameter(Mandatory = $false, ParameterSetName = "Positional", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Nic", ValueFromPipeline = $false)]
        [string]
        $AlternateGateway,

        [Parameter(Mandatory = $false, ParameterSetName = "Positional", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Nic", ValueFromPipeline = $false)]
        [string[]]
        $Dns,

        [Parameter(Mandatory = $false, ParameterSetName = "Positional", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Nic", ValueFromPipeline = $false)]
        [string[]]
        $Wins,

        [Parameter(Mandatory = $false, ParameterSetName = "Positional", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Nic", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "Positional", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Nic", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $false, ParameterSetName = "Nic", ValueFromPipeline = $false)]
        [string]
        $NetworkAdapterMac
    )

    return $null
}

function Set-OSCustomizationSpec {
    [CmdletBinding(DefaultParameterSetName = "Linux")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Linux", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.OSCustomization.OSCustomizationSpec[]]
        $OSCustomizationSpec,

        [Parameter(Mandatory = $false, ParameterSetName = "Linux", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.OSCustomization.OSCustomizationSpec]
        $NewSpec,

        [Parameter(Mandatory = $false, ParameterSetName = "Linux", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.OSCustomization.OSCustomizationSpecType]
        $Type,

        [Parameter(Mandatory = $false, ParameterSetName = "Linux", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "Linux", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "Linux", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [string[]]
        $DnsServer,

        [Parameter(Mandatory = $false, ParameterSetName = "Linux", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [string[]]
        $DnsSuffix,

        [Parameter(Mandatory = $false, ParameterSetName = "Linux", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [string]
        $Domain,

        [Parameter(Mandatory = $false, ParameterSetName = "Linux", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [string]
        $NamingScheme,

        [Parameter(Mandatory = $false, ParameterSetName = "Linux", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [string]
        $NamingPrefix,

        [Parameter(Mandatory = $false, ParameterSetName = "Linux", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [string]
        $Description,

        [Parameter(Mandatory = $false, ParameterSetName = "Linux", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "Linux", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [string]
        $FullName,

        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [string]
        $OrgName,

        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [bool]
        $ChangeSID,

        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [bool]
        $DeleteAccounts,

        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [string[]]
        $GuiRunOnce,

        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [string]
        $AdminPassword,

        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [string]
        $TimeZone,

        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [int]
        $AutoLogonCount,

        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [string]
        $Workgroup,

        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [pscredential]
        $DomainCredentials,

        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [string]
        $DomainUsername,

        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [string]
        $DomainPassword,

        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [string]
        $ProductKey,

        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.OSCustomization.LicenseMode]
        $LicenseMode,

        [Parameter(Mandatory = $false, ParameterSetName = "WindowsParameterSet", ValueFromPipeline = $false)]
        [int]
        $LicenseMaxConnections
    )

    return $null
}

function Set-PowerCLIConfiguration {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.ProxyPolicy]
        $ProxyPolicy,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.DefaultVIServerMode]
        $DefaultVIServerMode,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.BadCertificateAction]
        $InvalidCertificateAction,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $ParticipateInCeip,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.ProxyPolicy]
        $CEIPDataTransferProxyPolicy,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $DisplayDeprecationWarnings,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $WebOperationTimeoutSeconds,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $VMConsoleWindowBrowser,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.ConfigurationScope]
        $Scope,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-ResourcePool {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.ResourcePool[]]
        $ResourcePool,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $CpuExpandableReservation,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [long]
        $CpuLimitMhz,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [long]
        $CpuReservationMhz,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.SharesLevel]
        $CpuSharesLevel,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $MemExpandableReservation,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [long]
        $MemLimitMB,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [decimal]
        $MemLimitGB,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [long]
        $MemReservationMB,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [decimal]
        $MemReservationGB,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.SharesLevel]
        $MemSharesLevel,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $NumCpuShares,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $NumMemShares,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-ScsiController {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.ScsiController[]]
        $ScsiController,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.ScsiBusSharingMode]
        $BusSharingMode,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.ScsiControllerType]
        $Type,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-ScsiLun {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Storage.Scsi.ScsiLunMultipathPolicy]
        $MultipathPolicy,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Storage.Scsi.ScsiLunPath]
        $PreferredPath,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Storage.Scsi.ScsiLun[]]
        $ScsiLun,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $CommandsToSwitchPath,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $BlocksToSwitchPath,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $NoCommandsSwitch,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $NoBlocksSwitch,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $IsSsd,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $IsLocal,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $IsLocatorLedOn,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $DeletePartitions,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Force,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-ScsiLunPath {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $Active,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Storage.Scsi.ScsiLunPath[]]
        $ScsiLunPath,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Preferred,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-SecurityPolicy {
    [CmdletBinding(DefaultParameterSetName = "")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "switch", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.VirtualSwitchSecurityPolicy[]]
        $VirtualSwitchPolicy,

        [Parameter(Mandatory = $false, ParameterSetName = "switch", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "portgroup", ValueFromPipeline = $false)]
        [bool]
        $AllowPromiscuous,

        [Parameter(Mandatory = $false, ParameterSetName = "switch", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "portgroup", ValueFromPipeline = $false)]
        [bool]
        $ForgedTransmits,

        [Parameter(Mandatory = $false, ParameterSetName = "switch", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "portgroup", ValueFromPipeline = $false)]
        [bool]
        $MacChanges,

        [Parameter(Mandatory = $false, ParameterSetName = "switch", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "portgroup", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "switch", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "portgroup", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $true, ParameterSetName = "portgroup", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.VirtualPortgroupSecurityPolicy[]]
        $VirtualPortGroupPolicy,

        [Parameter(Mandatory = $false, ParameterSetName = "portgroup", ValueFromPipeline = $false)]
        [bool]
        $AllowPromiscuousInherited,

        [Parameter(Mandatory = $false, ParameterSetName = "portgroup", ValueFromPipeline = $false)]
        [bool]
        $ForgedTransmitsInherited,

        [Parameter(Mandatory = $false, ParameterSetName = "portgroup", ValueFromPipeline = $false)]
        [bool]
        $MacChangesInherited
    )

    return $null
}

function Set-Snapshot {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VM.Snapshot[]]
        $Snapshot,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Description,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-StatInterval {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $SamplingPeriodSecs,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $StorageTimeSecs,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Stat.StatInterval[]]
        $Interval,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-Tag {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Tagging.Tag[]]
        $Tag,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Description,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-TagCategory {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Tagging.TagCategory[]]
        $Category,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Description,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [System.Nullable[VMware.VimAutomation.ViCore.Types.V1.Cardinality]]
        $Cardinality,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string[]]
        $AddEntityType,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-Template {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.Template[]]
        $Template,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $ToVM,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-VApp {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VApp[]]
        $VApp,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $CpuExpandableReservation,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [long]
        $CpuLimitMhz,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [long]
        $CpuReservationMhz,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.SharesLevel]
        $CpuSharesLevel,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $MemExpandableReservation,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [long]
        $MemLimitMB,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [decimal]
        $MemLimitGB,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [long]
        $MemReservationMB,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [decimal]
        $MemReservationGB,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.SharesLevel]
        $MemSharesLevel,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $NumCpuShares,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $NumMemShares,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-VIPermission {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.PermissionManagement.Permission[]]
        $Permission,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.PermissionManagement.Role]
        $Role,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $Propagate,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-VIRole {
    [CmdletBinding(DefaultParameterSetName = "Add")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Add", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "Remove", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.PermissionManagement.Role[]]
        $Role,

        [Parameter(Mandatory = $false, ParameterSetName = "Add", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Remove", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "Add", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.PermissionManagement.Privilege[]]
        $AddPrivilege,

        [Parameter(Mandatory = $false, ParameterSetName = "Add", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Remove", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "Add", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Remove", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "Add", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Remove", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $false, ParameterSetName = "Remove", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.PermissionManagement.Privilege[]]
        $RemovePrivilege
    )

    return $null
}

function Set-VirtualPortGroup {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $VLanId,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.VirtualPortGroup[]]
        $VirtualPortGroup,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-VirtualSwitch {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.VirtualSwitch[]]
        $VirtualSwitch,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $NumPorts,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string[]]
        $Nic,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $Mtu,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-VM {
    [CmdletBinding(DefaultParameterSetName = "DefaultSet")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "DefaultSet", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "SnapshotSet", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "TemplateParameterSet", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "EncryptParameterSet", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "DecryptParameterSet", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "SnapshotSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "TemplateParameterSet", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultSet", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VM.VMVersion]
        $Version,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultSet", ValueFromPipeline = $false)]
        [string]
        $HardwareVersion,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultSet", ValueFromPipeline = $false)]
        [long]
        $MemoryMB,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultSet", ValueFromPipeline = $false)]
        [decimal]
        $MemoryGB,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultSet", ValueFromPipeline = $false)]
        [int]
        $NumCpu,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultSet", ValueFromPipeline = $false)]
        [int]
        $CoresPerSocket,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultSet", ValueFromPipeline = $false)]
        [string]
        $GuestId,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultSet", ValueFromPipeline = $false)]
        [string]
        $AlternateGuestName,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "SnapshotSet", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.OSCustomization.OSCustomizationSpec]
        $OSCustomizationSpec,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "SnapshotSet", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Cluster.HARestartPriority]
        $HARestartPriority,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "SnapshotSet", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Cluster.HAIsolationResponse]
        $HAIsolationResponse,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "SnapshotSet", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Cluster.DrsAutomationLevel]
        $DrsAutomationLevel,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "SnapshotSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "TemplateParameterSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "EncryptParameterSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "DecryptParameterSet", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "SnapshotSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "TemplateParameterSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "EncryptParameterSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "DecryptParameterSet", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "SnapshotSet", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VMSwapfilePolicy]
        $VMSwapFilePolicy,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultSet", ValueFromPipeline = $false)]
        [string]
        $Notes,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "SnapshotSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "TemplateParameterSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "EncryptParameterSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "DecryptParameterSet", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "DefaultSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "SnapshotSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "TemplateParameterSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "EncryptParameterSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "DecryptParameterSet", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $false, ParameterSetName = "SnapshotSet", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VM.Snapshot]
        $Snapshot,

        [Parameter(Mandatory = $false, ParameterSetName = "TemplateParameterSet", ValueFromPipeline = $false)]
        [switch]
        $ToTemplate,

        [Parameter(Mandatory = $false, ParameterSetName = "EncryptParameterSet", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Security.KmsCluster]
        $KmsCluster,

        [Parameter(Mandatory = $false, ParameterSetName = "EncryptParameterSet", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Storage.StoragePolicy]
        $StoragePolicy,

        [Parameter(Mandatory = $false, ParameterSetName = "EncryptParameterSet", ValueFromPipeline = $false)]
        [switch]
        $SkipHardDisks,

        [Parameter(Mandatory = $true, ParameterSetName = "DecryptParameterSet", ValueFromPipeline = $false)]
        [switch]
        $DisableEncryption
    )

    return $null
}

function Set-VMHost {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "SecurityParameterSet", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.VMHostState]
        $State,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VMSwapfilePolicy]
        $VMSwapfilePolicy,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.DatastoreManagement.Datastore]
        $VMSwapfileDatastore,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Profile.VMHostProfile]
        $Profile,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [switch]
        $Evacuate,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.VMHostTimeZone]
        $TimeZone,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [string]
        $LicenseKey,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Vsan.VsanDataMigrationMode]
        $VsanDataMigrationMode,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "SecurityParameterSet", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "SecurityParameterSet", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "SecurityParameterSet", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $true, ParameterSetName = "SecurityParameterSet", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Security.KmsCluster]
        $KmsCluster
    )

    return $null
}

function Set-VMHostAccount {
    [CmdletBinding(DefaultParameterSetName = "")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Group", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Account.HostGroupAccount[]]
        $GroupAccount,

        [Parameter(Mandatory = $false, ParameterSetName = "Group", ValueFromPipeline = $false)]
        [string[]]
        $AssignUsers,

        [Parameter(Mandatory = $false, ParameterSetName = "Group", ValueFromPipeline = $false)]
        [string[]]
        $UnassignUsers,

        [Parameter(Mandatory = $false, ParameterSetName = "Group", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "User", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "Group", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "User", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "Group", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "User", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $false, ParameterSetName = "User", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Account.HostUserAccount[]]
        $UserAccount,

        [Parameter(Mandatory = $false, ParameterSetName = "User", ValueFromPipeline = $false)]
        [string]
        $Password,

        [Parameter(Mandatory = $false, ParameterSetName = "User", ValueFromPipeline = $false)]
        [string]
        $Description,

        [Parameter(Mandatory = $false, ParameterSetName = "User", ValueFromPipeline = $false)]
        [string[]]
        $AssignGroups,

        [Parameter(Mandatory = $false, ParameterSetName = "User", ValueFromPipeline = $false)]
        [string[]]
        $UnassignGroups,

        [Parameter(Mandatory = $false, ParameterSetName = "User", ValueFromPipeline = $false)]
        [bool]
        $GrantShellAccess
    )

    return $null
}

function Set-VMHostAdvancedConfiguration {
    [CmdletBinding(DefaultParameterSetName = "NameValueParameterSet")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "NameValueParameterSet", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "NameValueParameterSet", ValueFromPipeline = $false)]
        [System.Object]
        $Value,

        [Parameter(Mandatory = $false, ParameterSetName = "NameValueParameterSet", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "HashtableParameterSet", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "NameValueParameterSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "HashtableParameterSet", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "NameValueParameterSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "HashtableParameterSet", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "NameValueParameterSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "HashtableParameterSet", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $false, ParameterSetName = "HashtableParameterSet", ValueFromPipeline = $true)]
        [hashtable]
        $NameValue
    )

    return $null
}

function Set-VMHostAuthentication {
    [CmdletBinding(DefaultParameterSetName = "")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "JoinDomain", ValueFromPipeline = $false)]
        [string]
        $Domain,

        [Parameter(Mandatory = $false, ParameterSetName = "JoinDomain", ValueFromPipeline = $false)]
        [string]
        $Username,

        [Parameter(Mandatory = $false, ParameterSetName = "JoinDomain", ValueFromPipeline = $false)]
        [securestring]
        $Password,

        [Parameter(Mandatory = $false, ParameterSetName = "JoinDomain", ValueFromPipeline = $false)]
        [pscredential]
        $Credential,

        [Parameter(Mandatory = $true, ParameterSetName = "JoinDomain", ValueFromPipeline = $false)]
        [switch]
        $JoinDomain,

        [Parameter(Mandatory = $true, ParameterSetName = "JoinDomain", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "LeaveDomain", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.VMHostAuthentication[]]
        $VMHostAuthentication,

        [Parameter(Mandatory = $false, ParameterSetName = "JoinDomain", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "LeaveDomain", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "JoinDomain", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "LeaveDomain", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $false, ParameterSetName = "LeaveDomain", ValueFromPipeline = $false)]
        [switch]
        $Force,

        [Parameter(Mandatory = $true, ParameterSetName = "LeaveDomain", ValueFromPipeline = $false)]
        [switch]
        $LeaveDomain
    )

    return $null
}

function Set-VMHostDiagnosticPartition {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $Active,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.VMHostDiagnosticPartition[]]
        $VMHostDiagnosticPartition,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-VMHostFirewallDefaultPolicy {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $AllowIncoming,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $AllowOutgoing,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.VMHostFirewallDefaultPolicy[]]
        $Policy,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-VMHostFirewallException {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $Enabled,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.VMHostFirewallException[]]
        $Exception,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-VMHostFirmware {
    [CmdletBinding(DefaultParameterSetName = "")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Backup", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "Reset", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $false, ParameterSetName = "Restore", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "Backup", ValueFromPipeline = $false)]
        [switch]
        $BackupConfiguration,

        [Parameter(Mandatory = $true, ParameterSetName = "Backup", ValueFromPipeline = $false)]
        [string]
        $DestinationPath,

        [Parameter(Mandatory = $false, ParameterSetName = "Backup", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Reset", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Restore", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "Backup", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Reset", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Restore", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "Backup", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Reset", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Restore", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $false, ParameterSetName = "Reset", ValueFromPipeline = $false)]
        [switch]
        $ResetToDefaults,

        [Parameter(Mandatory = $false, ParameterSetName = "Restore", ValueFromPipeline = $false)]
        [switch]
        $Restore,

        [Parameter(Mandatory = $false, ParameterSetName = "Restore", ValueFromPipeline = $false)]
        [string]
        $SourcePath,

        [Parameter(Mandatory = $false, ParameterSetName = "Restore", ValueFromPipeline = $false)]
        [switch]
        $Force,

        [Parameter(Mandatory = $false, ParameterSetName = "Restore", ValueFromPipeline = $false)]
        [pscredential]
        $HostCredential,

        [Parameter(Mandatory = $false, ParameterSetName = "Restore", ValueFromPipeline = $false)]
        [string]
        $HostUser,

        [Parameter(Mandatory = $false, ParameterSetName = "Restore", ValueFromPipeline = $false)]
        [securestring]
        $HostPassword
    )

    return $null
}

function Set-VMHostHba {
    [CmdletBinding(DefaultParameterSetName = "IScsi")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "IScsi", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Storage.IScsiHba[]]
        $IScsiHba,

        [Parameter(Mandatory = $false, ParameterSetName = "IScsi", ValueFromPipeline = $false)]
        [string]
        $IScsiName,

        [Parameter(Mandatory = $false, ParameterSetName = "IScsi", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Storage.ChapType]
        $ChapType,

        [Parameter(Mandatory = $false, ParameterSetName = "IScsi", ValueFromPipeline = $false)]
        [string]
        $ChapName,

        [Parameter(Mandatory = $false, ParameterSetName = "IScsi", ValueFromPipeline = $false)]
        [string]
        $ChapPassword,

        [Parameter(Mandatory = $false, ParameterSetName = "IScsi", ValueFromPipeline = $false)]
        [bool]
        $MutualChapEnabled,

        [Parameter(Mandatory = $false, ParameterSetName = "IScsi", ValueFromPipeline = $false)]
        [string]
        $MutualChapName,

        [Parameter(Mandatory = $false, ParameterSetName = "IScsi", ValueFromPipeline = $false)]
        [string]
        $MutualChapPassword,

        [Parameter(Mandatory = $false, ParameterSetName = "IScsi", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "IScsi", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "IScsi", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-VMHostModule {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.VmHostModule[]]
        $HostModule,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Options,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-VMHostNetwork {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.VMHostNetworkInfo[]]
        $Network,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $ConsoleGateway,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $VMKernelGateway,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $VMKernelGatewayDevice,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $ConsoleGatewayDevice,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $DomainName,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $HostName,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $DnsFromDhcp,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [System.Object]
        $DnsDhcpDevice,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string[]]
        $DnsAddress,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string[]]
        $SearchDomain,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $IPv6Enabled,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $ConsoleV6Gateway,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $ConsoleV6GatewayDevice,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $VMKernelV6Gateway,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $VMKernelV6GatewayDevice,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-VMHostNetworkAdapter {
    [CmdletBinding(DefaultParameterSetName = "")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "PhysicalSet", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.Nic.PhysicalNic[]]
        $PhysicalNic,

        [Parameter(Mandatory = $false, ParameterSetName = "PhysicalSet", ValueFromPipeline = $false)]
        [string]
        $Duplex,

        [Parameter(Mandatory = $false, ParameterSetName = "PhysicalSet", ValueFromPipeline = $false)]
        [int]
        $BitRatePerSecMb,

        [Parameter(Mandatory = $false, ParameterSetName = "PhysicalSet", ValueFromPipeline = $false)]
        [switch]
        $AutoNegotiate,

        [Parameter(Mandatory = $false, ParameterSetName = "PhysicalSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "VirtualSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Move", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "PhysicalSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "VirtualSet", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Move", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $true, ParameterSetName = "VirtualSet", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "Move", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.Nic.HostVirtualNic[]]
        $VirtualNic,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualSet", ValueFromPipeline = $false)]
        [switch]
        $Dhcp,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualSet", ValueFromPipeline = $false)]
        [string]
        $IP,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualSet", ValueFromPipeline = $false)]
        [string]
        $SubnetMask,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualSet", ValueFromPipeline = $false)]
        [string]
        $Mac,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualSet", ValueFromPipeline = $false)]
        [int]
        $Mtu,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualSet", ValueFromPipeline = $false)]
        [bool]
        $VMotionEnabled,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualSet", ValueFromPipeline = $false)]
        [bool]
        $FaultToleranceLoggingEnabled,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualSet", ValueFromPipeline = $false)]
        [bool]
        $ManagementTrafficEnabled,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualSet", ValueFromPipeline = $false)]
        [bool]
        $VsanTrafficEnabled,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualSet", ValueFromPipeline = $false)]
        [bool]
        $IPv6ThroughDhcp,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualSet", ValueFromPipeline = $false)]
        [bool]
        $AutomaticIPv6,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualSet", ValueFromPipeline = $false)]
        [string[]]
        $IPv6,

        [Parameter(Mandatory = $false, ParameterSetName = "VirtualSet", ValueFromPipeline = $false)]
        [bool]
        $IPv6Enabled,

        [Parameter(Mandatory = $false, ParameterSetName = "Move", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Networking.DistributedPortGroup]
        $PortGroup
    )

    return $null
}

function Set-VMHostProfile {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]
        $ReferenceHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Profile.VMHostProfile[]]
        $Profile,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Description,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-VMHostProfileImageCacheConfiguration {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Profile.VMHostProfileImageCacheConfiguration[]]
        $ImageCacheConfiguration,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Profile.VMHostProfileInstallationType]
        $InstallationType,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Profile.VMHostProfileInstallationDevice]
        $InstallationDevice,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $DiskArguments,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $IgnoreSsd,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $OverwriteVmfs,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Set-VMHostProfileStorageDeviceConfiguration {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Profile.VMHostProfileStorageDeviceConfiguration[]]
        $StorageDeviceConfiguration,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $DeviceStateOn,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $IsPerenniallyReserved,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $IsSharedClusterwide,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $NumReqOutstanding,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $QueueFullSampleSize,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $QueueFullThreshold,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $PspName,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $ConfigInfo,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Set-VMHostProfileUserConfiguration {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Profile.VMHostProfileUserConfiguration[]]
        $UserConfiguration,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Profile.VMHostProfilePasswordPolicy]
        $PasswordPolicy,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $Password,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Set-VMHostProfileVmPortGroupConfiguration {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Profile.VMHostProfileVmPortGroupConfiguration[]]
        $VmPortGroupConfiguration,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [string]
        $VSwitchName,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $VLanId,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Set-VMHostRoute {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.VMHostRoute[]]
        $VMHostRoute,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [ipaddress]
        $Destination,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [ipaddress]
        $Gateway,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [System.Nullable[int]]
        $PrefixLength,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-VMHostService {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.HostService[]]
        $HostService,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.HostServicePolicy]
        $Policy,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-VMHostSnmp {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "Default", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "Add Trap Target", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "Remove Trap Target", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "Remove Trap Target By Object", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.VmHostSnmp[]]
        $HostSnmp,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Add Trap Target", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Remove Trap Target", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Remove Trap Target By Object", ValueFromPipeline = $false)]
        [bool]
        $Enabled,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Add Trap Target", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Remove Trap Target", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Remove Trap Target By Object", ValueFromPipeline = $false)]
        [int]
        $Port,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Add Trap Target", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Remove Trap Target", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Remove Trap Target By Object", ValueFromPipeline = $false)]
        [string[]]
        $ReadOnlyCommunity,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Add Trap Target", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Remove Trap Target", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Remove Trap Target By Object", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "Default", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Add Trap Target", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Remove Trap Target", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Remove Trap Target By Object", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $true, ParameterSetName = "Add Trap Target", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Remove Trap Target", ValueFromPipeline = $false)]
        [string]
        $TargetCommunity,

        [Parameter(Mandatory = $false, ParameterSetName = "Add Trap Target", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Remove Trap Target", ValueFromPipeline = $false)]
        [int]
        $TargetPort,

        [Parameter(Mandatory = $true, ParameterSetName = "Add Trap Target", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Remove Trap Target", ValueFromPipeline = $false)]
        [string]
        $TargetHost,

        [Parameter(Mandatory = $true, ParameterSetName = "Add Trap Target", ValueFromPipeline = $false)]
        [switch]
        $AddTarget,

        [Parameter(Mandatory = $true, ParameterSetName = "Remove Trap Target", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Remove Trap Target By Object", ValueFromPipeline = $false)]
        [switch]
        $RemoveTarget,

        [Parameter(Mandatory = $true, ParameterSetName = "Remove Trap Target By Object", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.TrapTarget]
        $TrapTargetToRemove
    )

    return $null
}

function Set-VMHostStartPolicy {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.VMStartPolicy.VMHostStartPolicy[]]
        $VMHostStartPolicy,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $Enabled,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $StartDelay,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.VMStartPolicy.VmStopAction]
        $StopAction,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $StopDelay,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $WaitForHeartBeat,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-VMHostStorage {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Storage.VMHostStorageInfo[]]
        $VMHostStorage,

        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $SoftwareIScsiEnabled,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-VMHostSysLogServer {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.NamedIPEndPoint[]]
        $SysLogServer,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $SysLogServerPort,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-VMQuestion {
    [CmdletBinding(DefaultParameterSetName = "")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "option", ValueFromPipeline = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = "default", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VM.VMQuestion[]]
        $VMQuestion,

        [Parameter(Mandatory = $true, ParameterSetName = "option", ValueFromPipeline = $false)]
        [System.Object]
        $Option,

        [Parameter(Mandatory = $false, ParameterSetName = "option", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "default", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "option", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "default", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $true, ParameterSetName = "default", ValueFromPipeline = $false)]
        [switch]
        $DefaultOption
    )

    return $null
}

function Set-VMResourceConfiguration {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VM.VMResourceConfiguration[]]
        $Configuration,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VM.HTCoreSharing]
        $HtCoreSharing,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VM.CpuAffinity]
        $CpuAffinity,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int[]]
        $CpuAffinityList,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [long]
        $CpuReservationMhz,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [System.Nullable[long]]
        $CpuLimitMhz,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.SharesLevel]
        $CpuSharesLevel,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $NumCpuShares,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [long]
        $MemReservationMB,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [decimal]
        $MemReservationGB,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [System.Nullable[long]]
        $MemLimitMB,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [System.Nullable[decimal]]
        $MemLimitGB,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.SharesLevel]
        $MemSharesLevel,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $NumMemShares,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VirtualDevice.HardDisk[]]
        $Disk,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $NumDiskShares,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.SharesLevel]
        $DiskSharesLevel,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [long]
        $DiskLimitIOPerSecond,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Set-VMStartPolicy {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.VMStartPolicy.VMStartPolicy[]]
        $StartPolicy,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.VMStartPolicy.VmStartAction]
        $StartAction,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $StartOrder,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $InheritStopActionFromHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $InheritStopDelayFromHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $InheritWaitForHeartbeatFromHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $InheritStartDelayFromHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $UnspecifiedStartOrder,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $StartDelay,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.VMStartPolicy.VmStopAction]
        $StopAction,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $StopDelay,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [bool]
        $WaitForHeartBeat,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Start-VApp {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VApp[]]
        $VApp,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Start-VM {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Start-VMHost {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $TimeoutSeconds,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Start-VMHostService {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.HostService[]]
        $HostService,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Stop-Task {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.Sdk.Types.V1.Task[]]
        $Task,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Stop-VApp {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Force,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VApp[]]
        $VApp,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Stop-VM {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Kill,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Stop-VMGuest {
    [CmdletBinding(DefaultParameterSetName = "Vm")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Vm", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "Vm", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "Vm", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "VMGuest", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "Vm", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "VMGuest", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $false, ParameterSetName = "VMGuest", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VM.Guest.VMGuest[]]
        $Guest
    )

    return $null
}

function Stop-VMHost {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Force,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Stop-VMHostService {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.HostService[]]
        $HostService,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Suspend-VM {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Suspend-VMGuest {
    [CmdletBinding(DefaultParameterSetName = "Vm")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "Vm", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "Vm", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "Vm", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "VMGuest", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "Vm", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "VMGuest", ValueFromPipeline = $false)]
        [switch]
        $Confirm,

        [Parameter(Mandatory = $false, ParameterSetName = "VMGuest", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VM.Guest.VMGuest[]]
        $Guest
    )

    return $null
}

function Suspend-VMHost {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [int]
        $TimeoutSeconds,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Evacuate,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $WhatIf,

        [Parameter(Mandatory = $false, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $false)]
        [switch]
        $Confirm
    )

    return $null
}

function Test-VMHostProfileCompliance {
    [CmdletBinding(DefaultParameterSetName = "")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "VMHostCompliance", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMHost,

        [Parameter(Mandatory = $false, ParameterSetName = "VMHostCompliance", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ProfileCompliance", ValueFromPipeline = $false)]
        [switch]
        $UseCache,

        [Parameter(Mandatory = $false, ParameterSetName = "VMHostCompliance", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "ProfileCompliance", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $false, ParameterSetName = "ProfileCompliance", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.Profile.VMHostProfile[]]
        $Profile
    )

    return $null
}

function Test-VMHostSnmp {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Host.VmHostSnmp[]]
        $HostSnmp
    )

    return $null
}

function Update-Tools {
    [CmdletBinding(DefaultParameterSetName = "")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "VMGuest", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Vm", ValueFromPipeline = $false)]
        [switch]
        $NoReboot,

        [Parameter(Mandatory = $false, ParameterSetName = "VMGuest", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Vm", ValueFromPipeline = $false)]
        [switch]
        $RunAsync,

        [Parameter(Mandatory = $false, ParameterSetName = "VMGuest", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VM.Guest.VMGuest[]]
        $Guest,

        [Parameter(Mandatory = $false, ParameterSetName = "Vm", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "Vm", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server
    )

    return $null
}

function Wait-Task {
    [CmdletBinding(DefaultParameterSetName = "__AllParameterSets")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "__AllParameterSets", ValueFromPipeline = $true)]
        [VMware.VimAutomation.Sdk.Types.V1.Task[]]
        $Task
    )

    return $null
}

function Wait-Tools {
    [CmdletBinding(DefaultParameterSetName = "")]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = "VM", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
        $VM,

        [Parameter(Mandatory = $false, ParameterSetName = "VM", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Guest", ValueFromPipeline = $false)]
        [int]
        $TimeoutSeconds,

        [Parameter(Mandatory = $false, ParameterSetName = "VM", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Guest", ValueFromPipeline = $false)]
        [pscredential]
        $HostCredential,

        [Parameter(Mandatory = $false, ParameterSetName = "VM", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Guest", ValueFromPipeline = $false)]
        [string]
        $HostUser,

        [Parameter(Mandatory = $false, ParameterSetName = "VM", ValueFromPipeline = $false)]
        [Parameter(Mandatory = $false, ParameterSetName = "Guest", ValueFromPipeline = $false)]
        [securestring]
        $HostPassword,

        [Parameter(Mandatory = $false, ParameterSetName = "VM", ValueFromPipeline = $false)]
        [VMware.VimAutomation.ViCore.Types.V1.VIServer[]]
        $Server,

        [Parameter(Mandatory = $true, ParameterSetName = "Guest", ValueFromPipeline = $true)]
        [VMware.VimAutomation.ViCore.Types.V1.VM.Guest.VMGuest[]]
        $Guest
    )

    return $null
}
