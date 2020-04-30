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
    Example Cluster location: 'Discovered Virtual Machines/My Ubuntu VMs'.
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

    hidden [string] $CreateDrsRuleMessage = "Creating DRS Rule {0} for Cluster {1}."
    hidden [string] $ModifyDrsRuleMessage = "Modifying DRS rule {0} for Cluster {1}."
    hidden [string] $RemoveDrsRuleMessage = "Removing DRS rule {0} for Cluster {1}."

    hidden [string] $InvalidVMCountMessage = "At least 2 Virtual Machines should be specified."
    hidden [string] $InvalidLocationMessage = "Location {0} is not a valid location inside Folder {1}."

    hidden [string] $CouldNotRetrieveRootFolderMessage = "Could not retrieve Inventory Root Folder of vCenter Server {0}. For more information: {1}"
    hidden [string] $CouldNotRetrieveHostFolderMessage = "Could not retrieve Host Folder of Datacenter {0}. For more information: {1}"
    hidden [string] $CouldNotFindFolderMessage = "Could not find Folder {0} located in Folder {1}. For more information: {2}"
    hidden [string] $CouldNotFindDatacenterMessage = "Could not find Datacenter {0} located in Folder {1}. For more information: {2}"
    hidden [string] $CouldNotFindClusterMessage = "Could not find Cluster {0} located in Folder {1}."
    hidden [string] $CouldNotFindVMMessage = "Could not find Virtual Machine {0} in Cluster {1}."
    hidden [string] $CouldNotCreateDrsRuleMessage = "Could not create DRS rule {0} for Cluster {1}. For more information: {2}"
    hidden [string] $CouldNotModifyDrsRuleMessage = "Could not modify DRS rule {0} for Cluster {1}. For more information: {2}"
    hidden [string] $CouldNotRemoveDrsRuleMessage = "Could not remove DRS rule {0} for Cluster {1}. For more information: {2}"

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()

            $datacenter = $this.GetDatacenter()
            $cluster = $this.GetClusterInDatacenter($datacenter)

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
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.SetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [bool] Test() {
        try {
            Write-VerboseLog -Message $this.TestMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()

            $datacenter = $this.GetDatacenter()
            $cluster = $this.GetClusterInDatacenter($datacenter)

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
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [DRSRule] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [DRSRule]::new()

            $this.ConnectVIServer()

            $datacenter = $this.GetDatacenter()
            $cluster = $this.GetClusterInDatacenter($datacenter)

            $drsRule = $this.GetDrsRule($cluster)

            $result.DatacenterName = $datacenter.Name
            $result.ClusterName = $cluster.Name
            $this.PopulateResult($result, $drsRule)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Root Folder of the specified Inventory.
    #>
    [PSObject] GetInventoryRootFolder() {
        $getInventoryParams = @{
            Server = $this.Connection
            Id = $this.Connection.ExtensionData.Content.RootFolder
            ErrorAction = 'Stop'
            Verbose = $false
        }

        try {
            return Get-Inventory @getInventoryParams
        }
        catch {
            throw ($this.CouldNotRetrieveRootFolderMessage -f $this.Connection.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Host Folder of the specified Datacenter.
    #>
    [PSObject] GetHostFolderOfDatacenter($datacenter) {
        $getInventoryParams = @{
            Server = $this.Connection
            Id = $datacenter.ExtensionData.HostFolder
            ErrorAction = 'Stop'
            Verbose = $false
        }

        try {
            return Get-Inventory @getInventoryParams
        }
        catch {
            throw ($this.CouldNotRetrieveHostFolderMessage -f $datacenter.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Retrieves all Folders with the specified name,
    located inside the specified Folder.
    #>
    [array] GetFoldersByName($folderName, $folderLocation) {
        $folders = $null
        $getFolderParams = @{
            Server = $this.Connection
            Name = $folderName
            Location = $folderLocation
            ErrorAction = 'Stop'
            Verbose = $false
        }

        try {
            $folders = Get-Folder @getFolderParams
        }
        catch {
            if ($this.Ensure -eq [Ensure]::Present) {
                throw ($this.CouldNotFindFolderMessage -f $folderName, $folderLocation.Name, $_.Exception.Message)
            }
        }

        return $folders
    }

    <#
    .DESCRIPTION

    Retrieves the Folder with the specified name, located in the specified Folder.
    #>
    [PSObject] GetFolder($folderName, $parentFolder) {
        $folder = $null
        $getFolderParams = @{
            Server = $this.Connection
            Name = $folderName
            Location = $parentFolder
            ErrorAction = 'Stop'
            Verbose = $false
        }

        $whereObjectParams = @{
            FilterScript = {
                $_.ParentId -eq $parentFolder.Id
            }
        }

        try {
            $folder = Get-Folder @getFolderParams | Where-Object @whereObjectParams
        }
        catch {
            if ($this.Ensure -eq [Ensure]::Present) {
                throw ($this.CouldNotFindFolderMessage -f $folderName, $parentFolder.Name, $_.Exception.Message)
            }
        }

        return $folder
    }

    <#
    .DESCRIPTION

    Retrieves the Datacenter with the specified name, located in the specified Folder.
    #>
    [PSObject] GetDatacenter($folder) {
        $datacenter = $null
        $getDatacenterParams = @{
            Server = $this.Connection
            Name = $this.DatacenterName
            Location = $folder
            ErrorAction = 'Stop'
            Verbose = $false
        }

        $whereObjectParams = @{
            FilterScript = {
                $_.ParentFolderId -eq $folder.Id
            }
        }

        try {
            $datacenter = Get-Datacenter @getDatacenterParams | Where-Object @whereObjectParams
        }
        catch {
            if ($this.Ensure -eq [Ensure]::Present) {
                throw ($this.CouldNotFindDatacenterMessage -f $this.DatacenterName, $folder.Name, $_.Exception.Message)
            }
        }

        return $datacenter
    }

    <#
    .DESCRIPTION

    Retrieves the Datacenter with the specified name, located in the specified Folder.
    #>
    [PSObject] GetDatacenter() {
        $datacenter = $null
        $inventoryRootFolder = $this.GetInventoryRootFolder()

        <#
            If empty Datacenter location is passed, the Datacenter should be located
                in the Root Folder of the Inventory.
            If Datacenter location without '/' is passed, the Datacenter should be located
                in the Folder specified in the Datacenter location.
            If Datacenter location with '/' is passed, the Datacenter should be located
                in the Folder that is lastly specified in the Datacenter location.
        #>
        if ($this.DatacenterLocation -eq [string]::Empty) {
            $datacenter = $this.GetDatacenter($inventoryRootFolder)
        }
        elseif ($this.DatacenterLocation -NotMatch '/') {
            $folder = $this.GetFolder($this.DatacenterLocation, $inventoryRootFolder)
            $datacenter = $this.GetDatacenter($folder)
        }
        else {
            $folder = $null
            $datacenterLocationItems = $this.DatacenterLocation -Split '/'

            # The array needs to be reversed so we can retrieve the Folder where the Datacenter is located.
            [array]::Reverse($datacenterLocationItems)

            $datacenterLocationName = $datacenterLocationItems[0]
            $foundDatacenterFolderLocations = $this.GetFoldersByName($datacenterLocationName, $inventoryRootFolder)

            # The Folder where the Datacenter is located is already retrieved and it's not needed anymore.
            $datacenterLocationItems = $datacenterLocationItems[1..($datacenterLocationItems.Length - 1)]

            foreach ($foundDatacenterFolderLocation in $foundDatacenterFolderLocations) {
                $currentDatacenterLocationItem = $foundDatacenterFolderLocation
                $isDatacenterLocationValid = $true

                foreach ($datacenterLocationItem in $datacenterLocationItems) {
                    if ($currentDatacenterLocationItem.Parent.Name -ne $datacenterLocationItem) {
                        $isDatacenterLocationValid = $false
                        break
                    }

                    $currentDatacenterLocationItem = $currentDatacenterLocationItem.Parent
                }

                <#
                    If the Datacenter location is valid, the first Datacenter location item
                    should be located inside the Root Folder of the Inventory.
                #>
                if (
                    $isDatacenterLocationValid -and
                    $currentDatacenterLocationItem.ParentId -eq $inventoryRootFolder.Id
                ) {
                    $folder = $foundDatacenterFolderLocation
                    break
                }
            }

            if ($null -eq $folder -and $this.Ensure -eq [Ensure]::Present) {
                throw ($this.InvalidLocationMessage -f $this.DatacenterLocation, $inventoryRootFolder.Name)
            }

            $datacenter = $this.GetDatacenter($folder)
        }

        return $datacenter
    }

    <#
    .DESCRIPTION

    Retrieves the Cluster with the specified name, located in the specified Folder.
    #>
    [PSObject] GetClusterInDatacenter($datacenter) {
        # If the Datacenter doesn't exist, the Cluster doesn't exist as well.
        if ($null -eq $datacenter) {
            return $null
        }

        $cluster = $null
        $datacenterHostFolder = $this.GetHostFolderOfDatacenter($datacenter)

        <#
            If empty Cluster location is passed, the Cluster should be located
                in the Host Folder of the Datacenter.
            If Cluster location without '/' is passed, the Cluster should be located
                in the Folder specified in the Cluster location.
            If Cluster location with '/' is passed, the Cluster should be located
                in the Folder that is lastly specified in the Cluster location.
        #>
        if ($this.ClusterLocation -eq [string]::Empty) {
            $cluster = $this.GetCluster($datacenterHostFolder)
        }
        elseif ($this.ClusterLocation -NotMatch '/') {
            $folder = $this.GetFolder($this.ClusterLocation, $datacenterHostFolder)
            $cluster = $this.GetCluster($folder)
        }
        else {
            $folder = $null
            $clusterLocationItems = $this.ClusterLocation -Split '/'

            # The array needs to be reversed so we can retrieve the Folder where the Cluster is located.
            [array]::Reverse($clusterLocationItems)

            $clusterLocationName = $clusterLocationItems[0]
            $foundClusterFolderLocations = $this.GetFoldersByName($clusterLocationName, $datacenterHostFolder)

            # The Folder where the Cluster is located is already retrieved and it's not needed anymore.
            $clusterLocationItems = $clusterLocationItems[1..($clusterLocationItems.Length - 1)]

            foreach ($foundClusterFolderLocation in $foundClusterFolderLocations) {
                $currentClusterLocationItem = $foundClusterFolderLocation
                $isClusterLocationValid = $true

                foreach ($clusterLocationItem in $clusterLocationItems) {
                    if ($currentClusterLocationItem.Parent.Name -ne $clusterLocationItem) {
                        $isClusterLocationValid = $false
                        break
                    }

                    $currentClusterLocationItem = $currentClusterLocationItem.Parent
                }

                <#
                    If the Cluster location is valid, the first Cluster location item
                    should be located inside the Host Folder of the Datacenter.
                #>
                if (
                    $isClusterLocationValid -and
                    $currentClusterLocationItem.ParentId -eq $datacenterHostFolder.Id
                ) {
                    $folder = $foundClusterFolderLocation
                    break
                }
            }

            if ($null -eq $folder -and $this.Ensure -eq [Ensure]::Present) {
                throw ($this.InvalidLocationMessage -f $this.ClusterLocation, $datacenterHostFolder.Name)
            }

            $cluster = $this.GetCluster($folder)
        }

        return $cluster
    }

    <#
    .DESCRIPTION

    Retrieves the Cluster with the specified name, located in the specified Folder.
    #>
    [PSObject] GetCluster($folder) {
        $cluster = $null
        $getClusterParams = @{
            Server = $this.Connection
            Name = $this.ClusterName
            Location = $folder
            ErrorAction = 'Stop'
            Verbose = $false
        }

        $whereObjectParams = @{
            FilterScript = {
                $_.ParentId -eq $folder.Id
            }
        }

        try {
            $cluster = Get-Cluster @getClusterParams | Where-Object @whereObjectParams
        }
        catch {
            if ($this.Ensure -eq [Ensure]::Present) {
                throw ($this.CouldNotFindClusterMessage -f $this.ClusterName, $folder.Name)
            }
        }

        return $cluster
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
                Write-WarningLog -Message $this.CouldNotFindVMMessage -Arguments @($notFoundVMName, $cluster.Name)
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
            ($null -ne $this.Enabled -and $this.Enabled -ne $drsRule.Enabled),
            $this.ShouldUpdateArraySetting(
                $this.GetVirtualMachineNames($drsRule.VMIds),
                $this.VMNames
            )
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
            Write-VerboseLog -Message $this.CreateDrsRuleMessage -Arguments @($this.Name, $cluster.Name)
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
            Write-VerboseLog -Message $this.ModifyDrsRuleMessage -Arguments @($drsRule.Name, $drsRule.Cluster.Name)
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
            Write-VerboseLog -Message $this.RemoveDrsRuleMessage -Arguments @($drsRule.Name, $drsRule.Cluster.Name)
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
