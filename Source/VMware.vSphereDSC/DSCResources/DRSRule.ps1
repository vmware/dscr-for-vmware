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
class DRSRule : BaseDSC {
    <#
    .DESCRIPTION

    Specifies the name of the DRS rule.
    #>
    [DscProperty(Key)]
    [string] $Name

    <#
    .DESCRIPTION

    Specifies the name of the Datacenter where the Cluster, for which the DRS rule applies, is located.
    #>
    [DscProperty(Key)]
    [string] $DatacenterName

    <#
    .DESCRIPTION

    Specifies the location of the Datacenter where the Cluster, for which the DRS rule applies, is located.
    The Root Folder of the Inventory is not part of the location.
    Empty location means that the Datacenter is located in the Root Folder of the Inventory.
    The Folder names in the location are separated by '/'.
    Example Datacenter location: 'MyDatacentersFolderOne/MyDatacentersFolderTwo'.
    #>
    [DscProperty(Key)]
    [string] $DatacenterLocation

    <#
    .DESCRIPTION

    Specifies the name of the Cluster for which the DRS rule applies.
    #>
    [DscProperty(Key)]
    [string] $ClusterName

    <#
    .DESCRIPTION

    Specifies the location of the Cluster, for which the DRS rule applies, located in the
    Datacenter specified in 'DatacenterName' key property.
    The Root Folders of the Datacenter are not part of the location.
    Empty location means that the Cluster is located in the Host Folder of the Datacenter.
    The Folder names in the location are separated by '/'.
    Example Cluster location: 'MyClusterFolderOne/MyClusterFolderTwo'.
    #>
    [DscProperty(Key)]
    [string] $ClusterLocation

    <#
    .DESCRIPTION

    Specifies the type of the DRS rule - affinity or anti-affinity.
    #>
    [DscProperty(Key)]
    [DRSRuleType] $DRSRuleType

    <#
    .DESCRIPTION

    Specifies the names of the virtual machines that are referenced by the DRS rule.
    #>
    [DscProperty(Mandatory)]
    [string[]] $VMNames

    <#
    .DESCRIPTION

    Specifies whether the DRS rule should be present or absent.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    <#
    .DESCRIPTION

    Specifies whether the DRS rule is enabled or disabled for the specified Cluster.
    #>
    [DscProperty()]
    [nullable[bool]] $Enabled

    <#
    .DESCRIPTION

    Specifies the instance of the 'InventoryUtil' class that is used
    for Inventory operations.
    #>
    hidden [InventoryUtil] $InventoryUtil

    hidden [string] $CreateDrsRuleMessage = "Creating DRS Rule {0} for Cluster {1}."
    hidden [string] $ModifyDrsRuleMessage = "Modifying DRS rule {0} for Cluster {1}."
    hidden [string] $RemoveDrsRuleMessage = "Removing DRS rule {0} for Cluster {1}."

    hidden [string] $InvalidVMCountMessage = "At least 2 Virtual Machines should be specified."

    hidden [string] $CouldNotFindVMMessage = "Could not find Virtual Machine {0} in Cluster {1}."
    hidden [string] $CouldNotCreateDrsRuleMessage = "Could not create DRS rule {0} for Cluster {1}. For more information: {2}"
    hidden [string] $CouldNotModifyDrsRuleMessage = "Could not modify DRS rule {0} for Cluster {1}. For more information: {2}"
    hidden [string] $CouldNotRemoveDrsRuleMessage = "Could not remove DRS rule {0} for Cluster {1}. For more information: {2}"

    [void] Set() {
        try {
            $this.ConnectVIServer()

            $this.WriteLogUtil('Verbose', $this.SetMethodStartMessage, @($this.DscResourceName))

            $this.InitInventoryUtil()
            $datacenter = $this.InventoryUtil.GetDatacenter($this.DatacenterName, $this.DatacenterLocation)
            $datacenterHostFolderName = [FolderType]::Host.ToString() + 'Folder'
            $cluster = $this.InventoryUtil.GetInventoryItem(
                $this.ClusterName,
                $this.InventoryUtil.GetInventoryItemParent(
                    $this.ClusterLocation,
                    $datacenter,
                    $datacenterHostFolderName
                )
            )

            $drsRule = $this.GetDrsRule($cluster)
            if ($this.Ensure -eq [Ensure]::Present) {
                $virtualMachines = $this.GetVirtualMachines($cluster)
                if ($null -eq $drsRule) {
                    $this.NewDrsRule($cluster, $virtualMachines)
                }
                else {
                    $this.ModifyDrsRule($drsRule, $virtualMachines)
                }
            }
            else {
                if ($null -ne $drsRule) {
                    $this.RemoveDrsRule($drsRule)
                }
            }
        }
        finally {
            $this.WriteLogUtil('Verbose', $this.SetMethodEndMessage, @($this.DscResourceName))

            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()

            $this.WriteLogUtil('Verbose', $this.TestMethodStartMessage, @($this.DscResourceName))

            $this.InitInventoryUtil()
            $datacenter = $this.InventoryUtil.GetDatacenter($this.DatacenterName, $this.DatacenterLocation)
            $datacenterHostFolderName = [FolderType]::Host.ToString() + 'Folder'
            $cluster = $this.InventoryUtil.GetInventoryItem(
                $this.ClusterName,
                $this.InventoryUtil.GetInventoryItemParent(
                    $this.ClusterLocation,
                    $datacenter,
                    $datacenterHostFolderName
                )
            )

            $drsRule = $this.GetDrsRule($cluster)
            $result = $null

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $drsRule) {
                    $result = $false
                }
                else {
                    $result = !$this.ShouldModifyDrsRule($drsRule)
                }
            }
            else {
                $result = ($null -eq $drsRule)
            }

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.WriteLogUtil('Verbose', $this.TestMethodEndMessage, @($this.DscResourceName))

            $this.DisconnectVIServer()
        }
    }

    [DRSRule] Get() {
        try {
            $this.ConnectVIServer()

            $this.WriteLogUtil('Verbose', $this.GetMethodStartMessage, @($this.DscResourceName))

            $result = [DRSRule]::new()

            $this.InitInventoryUtil()
            $datacenter = $this.InventoryUtil.GetDatacenter($this.DatacenterName, $this.DatacenterLocation)
            $datacenterHostFolderName = [FolderType]::Host.ToString() + 'Folder'
            $cluster = $this.InventoryUtil.GetInventoryItem(
                $this.ClusterName,
                $this.InventoryUtil.GetInventoryItemParent(
                    $this.ClusterLocation,
                    $datacenter,
                    $datacenterHostFolderName
                )
            )

            $drsRule = $this.GetDrsRule($cluster)

            $result.DatacenterName = $datacenter.Name
            $result.ClusterName = $cluster.Name
            $this.PopulateResult($result, $drsRule)

            return $result
        }
        finally {
            $this.WriteLogUtil('Verbose', $this.GetMethodEndMessage, @($this.DscResourceName))
            
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Initializes an instance of the 'InventoryUtil' class.
    #>
    [void] InitInventoryUtil() {
        if ($null -eq $this.InventoryUtil) {
            $this.InventoryUtil = [InventoryUtil]::new($this.Connection, $this.Ensure)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the DRS Rule with the speciifed name located in the specified Cluster.
    #>
    [PSObject] GetDrsRule($cluster) {
        $getDrsRuleParams = @{
            Server = $this.Connection
            Name = $this.Name
            Cluster = $cluster
            ErrorAction = 'SilentlyContinue'
            Verbose = $false
        }

        return Get-DrsRule @getDrsRuleParams
    }

    <#
    .DESCRIPTION

    Retrieves the Virtual Machines with the specified names located in the specified Cluster.
    #>
    [array] GetVirtualMachines($cluster) {
        $result = @()
        if ($this.VMNames.Length -gt 0) {
            $getVMParams = @{
                Server = $this.Connection
                Name = $this.VMNames
                Location = $cluster
                ErrorAction = 'SilentlyContinue'
                Verbose = $false
            }

            $result = Get-VM @getVMParams
        }

        if ($result.Length -lt 2) {
            throw $this.InvalidVMCountMessage
        }

        if ($this.VMNames.Length -gt $result.Length) {
            $notFoundVMNames = $this.VMNames | Where-Object -FilterScript { $result.Name -NotContains $_ }
            foreach ($notFoundVMName in $notFoundVMNames) {
                $this.WriteLogUtil('Warning', $this.CouldNotFindVMMessage, @($notFoundVMName, $cluster.Name))
            }
        }

        return $result
    }

    <#
    .DESCRIPTION

    Retrieves the names of the Virtual Machines with the specified Ids.
    #>
    [string[]] GetVirtualMachineNames($vmIds) {
        $getVMParams = @{
            Server = $this.Connection
            Id = $vmIds
            ErrorAction = 'SilentlyContinue'
            Verbose = $false
        }

        return Get-VM @getVMParams | Select-Object -ExpandProperty Name
    }

    <#
    .DESCRIPTION

    Checks if the specified DRS rule should be modified.
    #>
    [bool] ShouldModifyDrsRule($drsRule) {
        $shouldModifyDrsRule = @(
            $this.ShouldUpdateDscResourceSetting('Enabled', $drsRule.Enabled, $this.Enabled),
            $this.ShouldUpdateArraySetting('VMNames', $this.GetVirtualMachineNames($drsRule.VMIds), $this.VMNames)
        )

        return ($shouldModifyDrsRule -Contains $true)
    }

    <#
    .DESCRIPTION

    Creates a new DRS rule with the specified name for the specified Cluster.
    #>
    [void] NewDrsRule($cluster, $virtualMachines) {
        $newDrsRuleParams = @{
            Server = $this.Connection
            Name = $this.Name
            Cluster = $cluster
            KeepTogether = ($this.DRSRuleType -eq [DRSRuleType]::VMAffinity)
            VM = $virtualMachines
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        if ($null -ne $this.Enabled) { $newDrsRuleParams.Enabled = $this.Enabled }

        try {
            $this.WriteLogUtil('Verbose', $this.CreateDrsRuleMessage, @($this.Name, $cluster.Name))

            New-DrsRule @newDrsRuleParams
        }
        catch {
            throw ($this.CouldNotCreateDrsRuleMessage -f $this.Name, $cluster.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Modifies the specified DRS rule.
    #>
    [void] ModifyDrsRule($drsRule, $virtualMachines) {
        $setDrsRuleParams = @{
            Server = $this.Connection
            Rule = $drsRule
            VM = $virtualMachines
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        if ($null -ne $this.Enabled) { $setDrsRuleParams.Enabled = $this.Enabled }

        try {
            $this.WriteLogUtil('Verbose', $this.ModifyDrsRuleMessage, @($drsRule.Name, $drsRule.Cluster.Name))

            Set-DrsRule @setDrsRuleParams
        }
        catch {
            throw ($this.CouldNotModifyDrsRuleMessage -f $drsRule.Name, $drsRule.Cluster.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Removes the specified DRS rule.
    #>
    [void] RemoveDrsRule($drsRule) {
        $removeDrsRuleParams = @{
            Rule = $drsRule
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        try {
            $this.WriteLogUtil('Verbose', $this.RemoveDrsRuleMessage, @($drsRule.Name, $drsRule.Cluster.Name))

            Remove-DrsRule @removeDrsRuleParams
        }
        catch {
            throw ($this.CouldNotRemoveDrsRuleMessage -f $drsRule.Name, $drsRule.Cluster.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $drsRule) {
        $result.Server = $this.Server
        $result.DatacenterLocation = $this.DatacenterLocation
        $result.ClusterLocation = $this.ClusterLocation

        if ($null -ne $drsRule) {
            $result.Name = $drsRule.Name
            $result.DRSRuleType = [string] $drsRule.Type
            $result.VMNames = $this.GetVirtualMachineNames($drsRule.VMIds)
            $result.Ensure = [Ensure]::Present
            $result.Enabled = $drsRule.Enabled
        }
        else {
            $result.Name = $this.Name
            $result.DRSRuleType = $this.DRSRuleType
            $result.VMNames = $this.VMNames
            $result.Ensure = [Ensure]::Absent
            $result.Enabled = $this.Enabled
        }
    }
}
