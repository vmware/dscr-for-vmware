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
Mock types of VMware.Vim assembly for the purpose of unit testing.
#>
Add-Type -Path "$($env:PSModulePath)/VMware.VimAutomation.Core/VMwareVimTypes.cs"

function Connect-VIServer {
    [CmdletBinding()]
    param(
        [string] $Server,
        [string] $User,
        [string] $Password,
        [PSCredential] $Credential
    )

    return $null
}

function Disconnect-VIServer {
    [CmdletBinding()]
    param(
        [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] $Server,
        [switch] $Confirm
    )

    return $null
}

function Get-VMHost {
    param(
        [PSObject] $Server,
        [string] $Name
    )

    return New-Object VMware.Vim.VMHost
}

function Get-View {
    [CmdletBinding()]
    param(
        [PSObject] $Server,
        [Parameter(ParameterSetName = 'GetViewByVIObject')]
        [PSObject] $VIObject,
        [Parameter(ParameterSetName = 'GetView')]
        [VMware.Vim.ManagedObjectReference[]] $Id,
        [Parameter(ParameterSetName = 'GetView')]
        [Parameter(ParameterSetName = 'GetEntity')]
        [Parameter(ParameterSetName = 'GetViewByRelatedObject')]
        [string[]] $Property,
        [Parameter(ParameterSetName = 'GetEntity')]
        [string[]] $ViewType,
        [Parameter(ParameterSetName = 'GetEntity')]
        [VMware.Vim.ManagedObjectReference[]] $SearchRoot,
        [Parameter(ParameterSetName = 'GetEntity')]
        [hashtable] $Filter,
        [Parameter(ParameterSetName = 'GetViewByRelatedObject')]
        [PSObject] $RelatedObject
    )

    return $null
}

function Get-EsxCli {
    param(
        [PSObject] $Server,
        [VMware.Vim.VMHost] $VMHost,
        [switch] $V2
    )

    return $null
}

function Get-AdvancedSetting {
    param(
        [PSObject] $Server,
        [PSObject] $Entity,
        [string] $Name
    )

    return @( [VMware.Vim.AdvancedSetting] @{} )
}

function Set-AdvancedSetting {
    param(
        [Vmware.Vim.AdvancedSetting] $AdvancedSetting,
        [string] $Value,
        [switch] $Confirm
    )

    return $null
}

function Get-VMHostService {
    param(
        [PSObject] $Server,
        [VMware.Vim.VMHost] $VMHost,
        [switch] $Refresh,
        [switch] $Confirm
    )

    return @( [VMware.Vim.VMHostService] @{} )
}

function Set-VMHostService {
    param(
        [VMware.Vim.VMHostService[]] $HostService,
        [ServicePolicy] $Policy,
        [switch] $Confirm
    )

    return $null
}

function Start-VMHostService {
    param(
        [VMware.Vim.VMHostService] $HostService,
        [switch] $Confirm
    )

    return @( [VMware.Vim.VMHostService] @{} )
}

function Stop-VMHostService {
    param(
        [VMware.Vim.VMHostService] $HostService,
        [switch] $Confirm
    )

    return @( [VMware.Vim.VMHostService] @{} )
}

function Get-PowerCLIConfiguration {
    param(
        [string] $Scope
    )

    return New-Object VMware.Vim.PowerCLIConfiguration
}

function Set-PowerCLIConfiguration {
    param(
        [string] $Scope,
        [VMware.Vim.ProxyPolicy] $CEIPDataTransferProxyPolicy,
        [VMware.Vim.DefaultVIServerMode] $DefaultVIServerMode,
        [bool] $DisplayDeprecationWarnings,
        [VMware.Vim.BadCertificateAction] $InvalidCertificateAction,
        [bool] $ParticipateInCeip,
        [VMware.Vim.ProxyPolicy] $ProxyPolicy,
        [int] $WebOperationTimeoutSeconds
    )

    return $null
}

function Get-Datacenter {
    param(
        [PSObject] $Server,
        [string] $Name,
        [VMware.VimAutomation.ViCore.Impl.V1.Inventory.FolderImpl] $Location
    )

    return $null
}

function Get-Inventory {
    param(
        [PSObject] $Server,
        [VMware.Vim.ManagedObjectReference] $Id,
        [string] $Name,
        [PSObject] $Location
    )

    return $null
}

function New-Cluster {
    param(
        [PSObject] $Server,
        [string] $Name,
        [PSObject] $Location,
        [bool] $HAEnabled,
        [bool] $HAAdmissionControlEnabled,
        [int] $HAFailoverLevel,
        [HAIsolationResponse] $HAIsolationResponse,
        [HARestartPriority] $HARestartPriority,
        [switch] $Confirm
    )
}

function Set-Cluster {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)] $Cluster,
        [PSObject] $Server,
        [string] $Name,
        [bool] $HAEnabled,
        [bool] $HAAdmissionControlEnabled,
        [int] $HAFailoverLevel,
        [HAIsolationResponse] $HAIsolationResponse,
        [HARestartPriority] $HARestartPriority,
        [switch] $Confirm
    )
}

function Remove-Cluster {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)] $Cluster,
        [PSObject] $Server,
        [switch] $Confirm
    )
}

function Get-VMHostAccount {
    [CmdletBinding()]
    param(
        [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] $Server,
        [string] $Id
    )

    return $null
}

function New-VMHostAccount {
    [CmdletBinding()]
    param(
        [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] $Server,
        [string] $Id,
        [string] $Password,
        [string] $Description,
        [switch] $Confirm
    )

    return $null
}

function Set-VMHostAccount {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)] $UserAccount,
        [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] $Server,
        [string] $Password,
        [string] $Description,
        [switch] $Confirm
    )

    return $null
}

function Remove-VMHostAccount {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)] $HostAccount,
        [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] $Server,
        [switch] $Confirm
    )

    return $null
}

function Get-VIRole {
    [CmdletBinding()]
    param(
        [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] $Server,
        [string] $Name
    )

    return $null
}

function Get-VIPermission {
    [CmdletBinding()]
    param(
        [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] $Server,
        [string] $Entity,
        [VMware.VimAutomation.ViCore.Impl.V1.Host.Account.HostUserAccountImpl] $Principal
    )

    return $null
}

function New-VIPermission {
    [CmdletBinding()]
    param(
        [VMware.VimAutomation.ViCore.Impl.V1.VIServerImpl] $Server,
        [string] $Entity,
        [VMware.VimAutomation.ViCore.Impl.V1.Host.Account.HostUserAccountImpl] $Principal,
        [VMware.VimAutomation.ViCore.Impl.V1.PermissionManagement.RoleImpl] $Role
    )

    return $null
}
