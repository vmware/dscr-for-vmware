<#
Copyright (c) 2018 VMware, Inc.  All rights reserved				

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License 

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

Using module '.\VMware.vSphereDSC.Helper.psm1'
Using module '.\VMware.vSphereDSC.Logging.psm1'

enum Duplex {
    Full
    Half
    Unset
}

enum Ensure {
    Absent
    Present
}

enum FolderType {
    Network
    Datastore
    Vm
    Host
}

enum GraphicsType {
    Shared
    SharedDirect
}

enum LinkDiscoveryProtocolOperation {
    Advertise
    Both
    Listen
    None
    Unset
}

enum LinkDiscoveryProtocolProtocol {
    CDP
    LLDP
    Unset
}

enum LoadBalancingPolicy {
    LoadBalanceIP
    LoadBalanceSrcMac
    LoadBalanceSrcId
    ExplicitFailover
    Unset
}

enum LoggingLevel {
    Unset
    None
    Error
    Warning
    Info
    Verbose
    Trivia
}

enum NetworkFailoverDetectionPolicy {
    LinkStatus
    BeaconProbing
    Unset
}

enum Period {
    Day = 86400
    Week = 604800
    Month = 2629800
    Year = 31556926
}

enum PortBinding {
    Static
    Dynamic
    Ephemeral
    Unset
}

enum PowerPolicy {
    HighPerformance = 1
    Balanced = 2
    LowPower = 3
    Custom = 4
}

enum ServicePolicy {
    Unset
    On
    Off
    Automatic
}

enum SharedPassthruAssignmentPolicy {
    Performance
    Consolidation
}

enum NicTeamingPolicy {
    Loadbalance_ip
    Loadbalance_srcmac
    Loadbalance_srcid
    Failover_explicit
}

enum DrsAutomationLevel {
    FullyAutomated
    Manual
    PartiallyAutomated
    Disabled
    Unset
}

enum HAIsolationResponse {
    PowerOff
    DoNothing
    Shutdown
    Unset
}

enum HARestartPriority {
    Disabled
    Low
    Medium
    High
    Unset
}

enum BadCertificateAction {
    Ignore
    Warn
    Prompt
    Fail
    Unset
}

enum DefaultVIServerMode {
    Single
    Multiple
    Unset
}

enum PowerCLISettingsScope {
    LCM
}

enum ProxyPolicy {
    NoProxy
    UseSystemProxy
    Unset
}

class BaseDSC {
    <#
    .DESCRIPTION

    Name of the Server we are trying to connect to. The Server can be a vCenter or ESXi.
    #>
    [DscProperty(Key)]
    [string] $Server

    <#
    .DESCRIPTION

    Credentials needed for connection to the specified Server.
    #>
    [DscProperty(Mandatory)]
    [PSCredential] $Credential

    <#
    .DESCRIPTION

    Established connection to the specified vSphere Server.
    #>
    hidden [PSObject] $Connection

    hidden [string] $vCenterProductId = 'vpx'

    <#
    .DESCRIPTION

    Imports the needed VMware Modules.
    #>
    [void] ImportRequiredModules() {
        $savedVerbosePreference = $global:VerbosePreference
        $global:VerbosePreference = 'SilentlyContinue'

        Import-Module -Name VMware.VimAutomation.Core

        $global:VerbosePreference = $savedVerbosePreference
    }

    <#
    .DESCRIPTION

    Connects to the specified Server with the passed Credentials.
    The method sets the Connection property to the established connection.
    If connection cannot be established, the method throws an exception.
    #>
    [void] ConnectVIServer() {
        $this.ImportRequiredModules()

        if ($null -eq $this.Connection) {
            try {
                $this.Connection = Connect-VIServer -Server $this.Server -Credential $this.Credential -ErrorAction Stop
            }
            catch {
                throw "Cannot establish connection to server $($this.Server). For more information: $($_.Exception.Message)"
            }
        }
    }

    <#
    .DESCRIPTION

    Checks if the passed array is in the desired state and if an update should be performed.
    #>
    [bool] ShouldUpdateArraySetting($currentArray, $desiredArray) {
        if ($null -eq $desiredArray) {
            # The property is not specified.
            return $false
        }
        elseif ($desiredArray.Length -eq 0 -and $currentArray.Length -ne 0) {
            # Empty array specified as desired, but current is not an empty array, so update should be performed.
            return $true
        }
        else {
            $elementsToAdd = $desiredArray | Where-Object { $currentArray -NotContains $_ }
            $elementsToRemove = $currentArray | Where-Object { $desiredArray -NotContains $_ }

            if ($null -ne $elementsToAdd -or $null -ne $elementsToRemove) {
                <#
                The current array does not contain at least one element from desired array or
                the desired array is a subset of the current array. In both cases
                we should perform an update operation.
                #>
                return $true
            }

            # No need to perform an update operation.
            return $false
        }
    }

    <#
    .DESCRIPTION

    Checks if the Connection is directly to a vCenter and if not, throws an exception.
    #>
    [void] EnsureConnectionIsvCenter() {
        if ($this.Connection.ProductLine -ne $this.vCenterProductId) {
            throw 'The Resource operations are only supported when connection is directly to a vCenter.'
        }
    }

    <#
    .DESCRIPTION

    Closes the last open connection to the specified Server.
    #>
    [void] DisconnectVIServer() {
        try {
            Disconnect-VIServer -Server $this.Connection -Confirm:$false -ErrorAction Stop
        }
        catch {
            throw "Cannot close Connection to Server $($this.Connection.Name). For more information: $($_.Exception.Message)"
        }
    }
}

class DatacenterInventoryBaseDSC : BaseDSC {
    <#
    .DESCRIPTION

    Name of the Inventory Item located in the Datacenter specified in 'DatacenterName' key property.
    #>
    [DscProperty(Key)]
    [string] $Name

    <#
    .DESCRIPTION

    Location of the Inventory Item with name specified in 'Name' key property in
    the Datacenter specified in the 'DatacenterName' key property.
    Location consists of 0 or more Inventory Items.
    Empty Location means that the Inventory Item is in the Root Folder of the Datacenter ('Vm', 'Host', 'Network' or 'Datastore' based on the Inventory Item).
    The Root Folders of the Datacenter are not part of the Location.
    Inventory Item names in Location are separated by "/".
    Example Location for a VM Inventory Item: "Discovered Virtual Machines/My Ubuntu VMs".
    #>
    [DscProperty(Key)]
    [string] $Location

    <#
    .DESCRIPTION

    Name of the Datacenter we will use from the specified Inventory.
    #>
    [DscProperty(Key)]
    [string] $DatacenterName

    <#
    .DESCRIPTION

    Location of the Datacenter we will use from the Inventory.
    Root Folder of the Inventory is not part of the Location.
    Empty Location means that the Datacenter is in the Root Folder of the Inventory.
    Folder names in Location are separated by "/".
    Example Location: "MyDatacentersFolder".
    #>
    [DscProperty(Key)]
    [string] $DatacenterLocation

    <#
    .DESCRIPTION

    Value indicating if the Inventory Item should be Present or Absent.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    <#
    .DESCRIPTION

    Type of Folder in which the Inventory Item is located.
    Possible values are VM, Network, Datastore, Host.
    #>
    hidden [FolderType] $InventoryItemFolderType

    <#
    .DESCRIPTION

    Ensures the correct behaviour when the Location is not valid based on the passed Ensure value.
    If Ensure is set to 'Present' and the Location is not valid, the method should throw with the passed error message.
    Otherwise Ensure is set to 'Absent' and $null result is returned because with invalid Location, the Inventory Item is 'Absent'
    from that Location and no error should be thrown.
    #>
    [PSObject] EnsureCorrectBehaviourForInvalidLocation($expression) {
        if ($this.Ensure -eq [Ensure]::Present) {
            throw $expression
        }

        return $null
    }

    <#
    .DESCRIPTION

    Returns the Datacenter we will use from the Inventory.
    #>
    [PSObject] GetDatacenter() {
        $rootFolderAsViewObject = Get-View -Server $this.Connection -Id $this.Connection.ExtensionData.Content.RootFolder
        $rootFolder = Get-Inventory -Server $this.Connection -Id $rootFolderAsViewObject.MoRef

        # Special case where the Location does not contain any folders.
        if ($this.DatacenterLocation -eq [string]::Empty) {
            $foundDatacenter = Get-Datacenter -Server $this.Connection -Name $this.DatacenterName -Location $rootFolder -ErrorAction SilentlyContinue | Where-Object { $_.ParentFolderId -eq $rootFolder.Id }
            if ($null -eq $foundDatacenter) {
                return $this.EnsureCorrectBehaviourForInvalidLocation("Datacenter $($this.DatacenterName) was not found at $($rootFolder.Name).")
            }

            return $foundDatacenter
        }

        # Special case where the Location is just one folder.
        if ($this.DatacenterLocation -NotMatch '/') {
            $foundLocation = Get-Folder -Server $this.Connection -Name $this.DatacenterLocation -Location $rootFolder -ErrorAction SilentlyContinue | Where-Object { $_.ParentId -eq $rootFolder.Id }
            if ($null -eq $foundLocation) {
                return $this.EnsureCorrectBehaviourForInvalidLocation("Folder $($this.DatacenterLocation) was not found at $($rootFolder.Name).")
            }

            $foundDatacenter = Get-Datacenter -Server $this.Connection -Name $this.DatacenterName -Location $foundLocation -ErrorAction SilentlyContinue | Where-Object { $_.ParentFolderId -eq $foundLocation.Id }
            if ($null -eq $foundDatacenter) {
                return $this.EnsureCorrectBehaviourForInvalidLocation("Datacenter $($this.DatacenterName) was not found at $($foundLocation.Name).")
            }

            return $foundDatacenter
        }

        $locationItems = $this.DatacenterLocation -Split '/'
        $childEntities = Get-View -Server $this.Connection -Id $rootFolder.ExtensionData.ChildEntity
        $foundLocationItem = $null

        for ($i = 0; $i -lt $locationItems.Length; $i++) {
            $locationItem = $locationItems[$i]
            $foundLocationItem = $childEntities | Where-Object -Property Name -eq $locationItem

            if ($null -eq $foundLocationItem) {
                return $this.EnsureCorrectBehaviourForInvalidLocation("Datacenter $($this.DatacenterName) with Location $($this.DatacenterLocation) was not found because $locationItem folder cannot be found below $($rootFolder.Name).")
            }

            # If the found location item does not have 'ChildEntity' member, the item is a Datacenter.
            $childEntityMember = $foundLocationItem | Get-Member -Name 'ChildEntity'
            if ($null -eq $childEntityMember) {
                return $this.EnsureCorrectBehaviourForInvalidLocation("The Location $($this.DatacenterLocation) contains another Datacenter $locationItem.")
            }

            <#
            If the found location item is a Folder we check how many Child Entities the folder has:
            If the Folder has zero Child Entities and the Folder is not the last location item, the Location is not valid.
            Otherwise we start looking in the items of this Folder.
            #>
            if ($foundLocationItem.ChildEntity.Length -eq 0) {
                if ($i -ne $locationItems.Length - 1) {
                    return $this.EnsureCorrectBehaviourForInvalidLocation("The Location $($this.DatacenterLocation) is not valid because Folder $locationItem does not have Child Entities and the Location $($this.DatacenterLocation) contains other Inventory Items.")
                }
            }
            else {
                $childEntities = Get-View -Server $this.Connection -Id $foundLocationItem.ChildEntity
            }
        }

        $foundLocation = Get-Inventory -Server $this.Connection -Id $foundLocationItem.MoRef
        $foundDatacenter = Get-Datacenter -Server $this.Connection -Name $this.DatacenterName -Location $foundLocation -ErrorAction SilentlyContinue | Where-Object { $_.ParentFolderId -eq $foundLocation.Id }

        if ($null -eq $foundDatacenter) {
            return $this.EnsureCorrectBehaviourForInvalidLocation("Datacenter $($this.DatacenterName) with Location $($this.DatacenterLocation) was not found.")
        }

        return $foundDatacenter
    }

    <#
    .DESCRIPTION

    Returns the Location of the Inventory Item from the specified Datacenter.
    #>
    [PSObject] GetInventoryItemLocationInDatacenter($datacenter, $datacenterFolderName) {
        <#
        Here if the Ensure property is set to 'Absent', we do not need to check if the Location is valid
        because the Datacenter does not exist and this means that the Inventory Item does not exist in the specified Datacenter.
        #>
        if ($null -eq $datacenter -and $this.Ensure -eq [Ensure]::Absent) {
            return $null
        }

        $validInventoryItemLocation = $null
        $datacenterFolderAsViewObject = Get-View -Server $this.Connection -Id $datacenter.ExtensionData.$datacenterFolderName
        $datacenterFolder = Get-Inventory -Server $this.Connection -Id $datacenterFolderAsViewObject.MoRef

        # Special case where the Location does not contain any Inventory Items.
        if ($this.Location -eq [string]::Empty) {
            return $datacenterFolder
        }

        # Special case where the Location is just one Inventory Item.
        if ($this.Location -NotMatch '/') {
            $validInventoryItemLocation = Get-Inventory -Server $this.Connection -Name $this.Location -Location $datacenterFolder -ErrorAction SilentlyContinue | Where-Object { $_.ParentId -eq $datacenterFolder.Id }

            if ($null -eq $validInventoryItemLocation) {
                return $this.EnsureCorrectBehaviourForInvalidLocation("Location $($this.Location) of Inventory Item $($this.Name) was not found in Folder $($datacenterFolder.Name).")
            }

            return $validInventoryItemLocation
        }

        $locationItems = $this.Location -Split '/'

        # Reverses the location items so that we can start from the bottom and go to the top of the Inventory.
        [array]::Reverse($locationItems)

        $datacenterInventoryItemLocationName = $locationItems[0]
        $foundLocations = Get-Inventory -Server $this.Connection -Name $datacenterInventoryItemLocationName -Location $datacenterFolder -ErrorAction SilentlyContinue

        # Removes the Name of the Inventory Item Location from the location items array as we already retrieved it.
        $locationItems = $locationItems[1..($locationItems.Length - 1)]

        <#
        For every found Inventory Item Location in the Datacenter with the specified name we start to go up through the parents to check if the Location is valid.
        If one of the Parents does not meet the criteria of the Location, we continue with the next found Location.
        If we find a valid Location we stop iterating through the Locations and return it.
        #>
        foreach ($foundLocation in $foundLocations) {
            $foundLocationAsViewObject = Get-View -Server $this.Connection -Id $foundLocation.Id -Property Parent
            $validLocation = $true

            foreach ($locationItem in $locationItems) {
                $foundLocationAsViewObject = Get-View -Server $this.Connection -Id $foundLocationAsViewObject.Parent -Property Name, Parent
                if ($foundLocationAsViewObject.Name -ne $locationItem) {
                    $validLocation = $false
                    break
                }
            }

            if ($validLocation) {
                $validInventoryItemLocation = $foundLocation
                break
            }
        }

        if ($null -eq $validInventoryItemLocation) {
            return $this.EnsureCorrectBehaviourForInvalidLocation("Location $($this.Location) of Inventory Item $($this.Name) was not found in Datacenter $($datacenter.Name).")
        }

        return $validInventoryItemLocation
    }

    <#
    .DESCRIPTION

    Returns the Inventory Item from the specified Location in the Datacenter if it exists, otherwise returns $null.
    #>
    [PSObject] GetInventoryItem($inventoryItemLocationInDatacenter) {
        return Get-Inventory -Server $this.Connection -Name $this.Name -Location $inventoryItemLocationInDatacenter -ErrorAction SilentlyContinue | Where-Object { $_.ParentId -eq $inventoryItemLocationInDatacenter.Id }
    }
}

class InventoryBaseDSC : BaseDSC {
    <#
    .DESCRIPTION

    Name of the Inventory Item (Folder or Datacenter) located in the Folder specified in 'Location' key property.
    #>
    [DscProperty(Key)]
    [string] $Name

    <#
    .DESCRIPTION

    Location of the Inventory Item (Folder or Datacenter) we will use from the Inventory.
    Root Folder of the Inventory is not part of the Location.
    Empty Location means that the Inventory Item (Folder or Datacenter) is in the Root Folder of the Inventory.
    Folder names in Location are separated by "/".
    Example Location: "MyDatacenters".
    #>
    [DscProperty(Key)]
    [string] $Location

    <#
    .DESCRIPTION

    Value indicating if the Inventory Item (Folder or Datacenter) should be Present or Absent.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    <#
    .DESCRIPTION

    Ensures the correct behaviour when the Location is not valid based on the passed Ensure value.
    If Ensure is set to 'Present' and the Location is not valid, the method should throw with the passed error message.
    Otherwise Ensure is set to 'Absent' and $null result is returned because with invalid Location, the Inventory Item is 'Absent'
    from that Location and no error should be thrown.
    #>
    [PSObject] EnsureCorrectBehaviourForInvalidLocation($expression) {
        if ($this.Ensure -eq [Ensure]::Present) {
            throw $expression
        }

        return $null
    }

    <#
    .DESCRIPTION

    Returns the Location of the Inventory Item (Folder or Datacenter) from the specified Inventory.
    #>
    [PSObject] GetInventoryItemLocation() {
        $rootFolderAsViewObject = Get-View -Server $this.Connection -Id $this.Connection.ExtensionData.Content.RootFolder
        $rootFolder = Get-Inventory -Server $this.Connection -Id $rootFolderAsViewObject.MoRef

        # Special case where the Location does not contain any folders.
        if ($this.Location -eq [string]::Empty) {
            return $rootFolder
        }

        # Special case where the Location is just one folder.
        if ($this.Location -NotMatch '/') {
            $foundLocation = Get-Inventory -Server $this.Connection -Name $this.Location -Location $rootFolder -ErrorAction SilentlyContinue | Where-Object { $_.ParentId -eq $rootFolder.Id }
            if ($null -eq $foundLocation) {
                return $this.EnsureCorrectBehaviourForInvalidLocation("Folder $($this.Location) was not found at $($rootFolder.Name).")
            }

            return $foundLocation
        }

        $locationItems = $this.Location -Split '/'
        $childEntities = Get-View -Server $this.Connection -Id $rootFolder.ExtensionData.ChildEntity
        $foundLocationItem = $null

        for ($i = 0; $i -lt $locationItems.Length; $i++) {
            $locationItem = $locationItems[$i]
            $foundLocationItem = $childEntities | Where-Object -Property Name -eq $locationItem

            if ($null -eq $foundLocationItem) {
                return $this.EnsureCorrectBehaviourForInvalidLocation("Inventory Item $($this.Name) with Location $($this.Location) was not found because $locationItem folder cannot be found below $($rootFolder.Name).")
            }

            # If the found location item does not have 'ChildEntity' member, the item is a Datacenter.
            $childEntityMember = $foundLocationItem | Get-Member -Name 'ChildEntity'
            if ($null -eq $childEntityMember) {
                return $this.EnsureCorrectBehaviourForInvalidLocation("The Location $($this.Location) contains Datacenter $locationItem which is not valid.")
            }

            <#
            If the found location item is a Folder we check how many Child Entities the folder has:
            If the Folder has zero Child Entities and the Folder is not the last location item, the Location is not valid.
            Otherwise we start looking in the items of this Folder.
            #>
            if ($foundLocationItem.ChildEntity.Length -eq 0) {
                if ($i -ne $locationItems.Length - 1) {
                    return $this.EnsureCorrectBehaviourForInvalidLocation("The Location $($this.Location) is not valid because Folder $locationItem does not have Child Entities and the Location $($this.Location) contains other Inventory Items.")
                }
            }
            else {
                $childEntities = Get-View -Server $this.Connection -Id $foundLocationItem.ChildEntity
            }
        }

        return Get-Inventory -Server $this.Connection -Id $foundLocationItem.MoRef
    }
}

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

                Write-VerboseLog -Message "VMHost {0} is still not in {1} State." -Arguments @($this.Name, $desiredState)
            }
            catch {
                <#
                Here the message used in the try block is written again in the case when an exception is thrown
                when retrieving the VMHost or establishing a Connection. This way the user still gets notified
                that the VMHost is not in the Desired State.
                #>
                Write-VerboseLog -Message "VMHost {0} is still not in {1} State." -Arguments @($this.Name, $desiredState)
            }
        }

        Write-VerboseLog -Message "VMHost {0} is successfully restarted and in {1} State." -Arguments @($this.Name, $desiredState)
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
        to the method 'EnsureVMHostIsInCorrectState'. We also need to set the variable holding the current Connection
        to $null, so a new Connection can be established via the ConnectVIServer().
        #>
        if ($this.Connection.ProductLine -eq $this.vCenterProductId) {
            $this.EnsureVMHostIsInDesiredState($false, $this.NotRespondingState)
            $this.EnsureVMHostIsInDesiredState($false, $this.MaintenanceState)
        }
        else {
            $this.Connection = $null
            $this.EnsureVMHostIsInDesiredState($true, $this.MaintenanceState)
        }
    }
}

class VMHostEntityBaseDSC : BaseDSC {
    <#
    .DESCRIPTION

    Name of the VMHost which is going to be used.
    #>
    [DscProperty(Key)]
    [string] $VMHostName

    <#
    .DESCRIPTION

    The VMHost which is going to be used.
    #>
    hidden [PSObject] $VMHost

    <#
    .DESCRIPTION

    Retrieves the VMHost with the specified name from the server.
    If the VMHost is not found, it throws an exception.
    #>
    [void] RetrieveVMHost() {
        try {
            $this.VMHost = Get-VMHost -Server $this.Connection -Name $this.VMHostName -ErrorAction Stop
        }
        catch {
            throw "VMHost with name $($this.VMHostName) was not found. For more information: $($_.Exception.Message)"
        }
    }
}

class VMHostGraphicsBaseDSC : VMHostBaseDSC {
    <#
    .DESCRIPTION

    Retrieves the Graphics Manager of the specified VMHost from the server.
    #>
    [PSObject] GetVMHostGraphicsManager($vmHost) {
        try {
            $vmHostGraphicsManager = Get-View -Server $this.Connection -Id $vmHost.ExtensionData.ConfigManager.GraphicsManager -ErrorAction Stop
            return $vmHostGraphicsManager
        }
        catch {
            throw "Could not retrieve the Graphics Manager of VMHost $($vmHost.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    The enum value passed in the Configuration should be converted to string value by the following criteria:
    Shared => shared; SharedDevice => sharedDevice
    #>
    [string] ConvertEnumValueToServerValue($enumValue) {
        return $enumValue.ToString().Substring(0, 1).ToLower() + $enumValue.ToString().Substring(1)
    }
}

class VMHostNetworkBaseDSC : VMHostBaseDSC {
    hidden [PSObject] $VMHostNetworkSystem

    <#
    .DESCRIPTION

    Retrieves the Network System from the specified VMHost.
    #>
    [void] GetNetworkSystem($vmHost) {
        try {
            $this.VMHostNetworkSystem = Get-View -Server $this.Connection -Id $vmHost.ExtensionData.ConfigManager.NetworkSystem -ErrorAction Stop
        }
        catch {
            throw "Could not retrieve NetworkSystem on VMHost with name $($this.Name). For more information: $($_.Exception.Message)"
        }
    }
}

class VMHostNicBaseDSC : VMHostEntityBaseDSC {
    <#
    .DESCRIPTION

    Specifies the Name of the Port Group to which you want to add the new Adapter. If a Distributed Switch is passed, an existing Port Group name should be specified.
    For Standard Virtual Switches, if the Port Group is non-existent, a new Port Group with the specified name will be created and the new Adapter will be added to the Port Group.
    #>
    [DscProperty(Key)]
    [string] $PortGroupName

    <#
    .DESCRIPTION

    Value indicating if the Network Adapter should be Present or Absent.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    <#
    .DESCRIPTION

    Indicates whether the host Network Adapter uses a Dhcp server.
    #>
    [DscProperty()]
    [nullable[bool]] $Dhcp

    <#
    .DESCRIPTION

    Specifies an IP address for the new Network Adapter. All IP addresses are specified using IPv4 dot notation. If IP is not specified, DHCP mode is enabled.
    #>
    [DscProperty()]
    [string] $IP

    <#
    .DESCRIPTION

    Specifies a Subnet Mask for the new Network Adapter.
    #>
    [DscProperty()]
    [string] $SubnetMask

    <#
    .DESCRIPTION

    Specifies a media access control (MAC) address for the new Virtual Network Adapter.
    #>
    [DscProperty()]
    [string] $Mac

    <#
    .DESCRIPTION

    Indicates that the IPv6 address is obtained through a router advertisement.
    #>
    [DscProperty()]
    [nullable[bool]] $AutomaticIPv6

    <#
    .DESCRIPTION

    Specifies multiple static addresses using the following format: <IPv6>/<subnet_prefix_length> or <IPv6>. If you skip <subnet_prefix_length>, the default value of 64 is used.
    #>
    [DscProperty()]
    [string[]] $IPv6

    <#
    .DESCRIPTION

    Indicates that the IPv6 address is obtained through DHCP.
    #>
    [DscProperty()]
    [nullable[bool]] $IPv6ThroughDhcp

    <#
    .DESCRIPTION

    Specifies the MTU size.
    #>
    [DscProperty()]
    [nullable[int]] $Mtu

    <#
    .DESCRIPTION

    Indicates that IPv6 configuration is enabled. Setting this parameter to $false disables all IPv6-related parameters.
    If the value is $true, you need to provide values for at least one of the IPv6 parameters.
    #>
    [DscProperty()]
    [nullable[bool]] $IPv6Enabled

    <#
    .DESCRIPTION

    Indicates that you want to enable the Network Adapter for management traffic.
    #>
    [DscProperty()]
    [nullable[bool]] $ManagementTrafficEnabled

    <#
    .DESCRIPTION

    Indicates that the Network Adapter is enabled for Fault Tolerance (FT) logging.
    #>
    [DscProperty()]
    [nullable[bool]] $FaultToleranceLoggingEnabled

    <#
    .DESCRIPTION

    Indicates that you want to use the new Virtual host/VMKernel Network Adapter for VMotion.
    #>
    [DscProperty()]
    [nullable[bool]] $VMotionEnabled

    <#
    .DESCRIPTION

    Indicates that Virtual SAN traffic is enabled on this network adapter.
    #>
    [DscProperty()]
    [nullable[bool]] $VsanTrafficEnabled

    <#
    .DESCRIPTION

    Retrieves the VMKernel Network Adapter connected to the specified Port Group and Virtual Switch and available on the specified VMHost from the server
    if it exists, otherwise returns $null.
    #>
    [PSObject] GetVMHostNetworkAdapter($virtualSwitch) {
        return Get-VMHostNetworkAdapter -Server $this.Connection -PortGroup $this.PortGroupName -VirtualSwitch $virtualSwitch -VMHost $this.VMHost -VMKernel -ErrorAction SilentlyContinue
    }

    <#
    .DESCRIPTION

    Checks if the passed VMKernel Network Adapter IPv6 array needs to be updated.
    #>
    [bool] ShouldUpdateIPv6($ipv6) {
        $currentIPv6 = @()
        foreach ($ip in $ipv6) {
            <#
            The IPs on the server are of type 'IPv6Address' so they need to be converted to
            string before being passed to ShouldUpdateArraySetting method.
            #>
            $currentIPv6 += $ip.ToString()
        }

        <#
        The default IPv6 array contains one element, so when empty array is passed no update
        should be performed.
        #>
        if ($null -ne $this.IPv6 -and ($this.IPv6.Length -eq 0 -and $currentIPv6.Length -eq 1)) {
            return $false
        }

        return $this.ShouldUpdateArraySetting($currentIPv6, $this.IPv6)
    }

    <#
    .DESCRIPTION

    Checks if the passed VMKernel Network Adapter needs be updated based on the specified properties.
    #>
    [bool] ShouldUpdateVMHostNetworkAdapter($vmHostNetworkAdapter) {
        $shouldUpdateVMHostNetworkAdapter = @()

        $shouldUpdateVMHostNetworkAdapter += (![string]::IsNullOrEmpty($this.IP) -and $this.IP -ne $vmHostNetworkAdapter.IP)
        $shouldUpdateVMHostNetworkAdapter += (![string]::IsNullOrEmpty($this.SubnetMask) -and $this.SubnetMask -ne $vmHostNetworkAdapter.SubnetMask)
        $shouldUpdateVMHostNetworkAdapter += (![string]::IsNullOrEmpty($this.Mac) -and $this.Mac -ne $vmHostNetworkAdapter.Mac)

        $shouldUpdateVMHostNetworkAdapter += ($null -ne $this.Dhcp -and $this.Dhcp -ne $vmHostNetworkAdapter.DhcpEnabled)
        $shouldUpdateVMHostNetworkAdapter += ($null -ne $this.AutomaticIPv6 -and $this.AutomaticIPv6 -ne $vmHostNetworkAdapter.AutomaticIPv6)
        $shouldUpdateVMHostNetworkAdapter += $this.ShouldUpdateIPv6($vmHostNetworkAdapter.IPv6)
        $shouldUpdateVMHostNetworkAdapter += ($null -ne $this.IPv6ThroughDhcp -and $this.IPv6ThroughDhcp -ne $vmHostNetworkAdapter.IPv6ThroughDhcp)
        $shouldUpdateVMHostNetworkAdapter += ($null -ne $this.Mtu -and $this.Mtu -ne $vmHostNetworkAdapter.Mtu)
        $shouldUpdateVMHostNetworkAdapter += ($null -ne $this.IPv6Enabled -and $this.IPv6Enabled -ne $vmHostNetworkAdapter.IPv6Enabled)
        $shouldUpdateVMHostNetworkAdapter += ($null -ne $this.ManagementTrafficEnabled -and $this.ManagementTrafficEnabled -ne $vmHostNetworkAdapter.ManagementTrafficEnabled)
        $shouldUpdateVMHostNetworkAdapter += ($null -ne $this.FaultToleranceLoggingEnabled -and $this.FaultToleranceLoggingEnabled -ne $vmHostNetworkAdapter.FaultToleranceLoggingEnabled)
        $shouldUpdateVMHostNetworkAdapter += ($null -ne $this.VMotionEnabled -and $this.VMotionEnabled -ne $vmHostNetworkAdapter.VMotionEnabled)
        $shouldUpdateVMHostNetworkAdapter += ($null -ne $this.VsanTrafficEnabled -and $this.VsanTrafficEnabled -ne $vmHostNetworkAdapter.VsanTrafficEnabled)

        return ($shouldUpdateVMHostNetworkAdapter -Contains $true)
    }

    <#
    .DESCRIPTION

    Returns the populated VMKernel Network Adapter parameters.
    #>
    [hashtable] GetVMHostNetworkAdapterParams() {
        $vmHostNetworkAdapterParams = @{}

        $vmHostNetworkAdapterParams.Confirm = $false
        $vmHostNetworkAdapterParams.ErrorAction = 'Stop'

        if (![string]::IsNullOrEmpty($this.IP)) { $vmHostNetworkAdapterParams.IP = $this.IP }
        if (![string]::IsNullOrEmpty($this.SubnetMask)) { $vmHostNetworkAdapterParams.SubnetMask = $this.SubnetMask }
        if (![string]::IsNullOrEmpty($this.Mac)) { $vmHostNetworkAdapterParams.Mac = $this.Mac }

        if ($null -ne $this.AutomaticIPv6) { $vmHostNetworkAdapterParams.AutomaticIPv6 = $this.AutomaticIPv6 }
        if ($null -ne $this.IPv6) { $vmHostNetworkAdapterParams.IPv6 = $this.IPv6 }
        if ($null -ne $this.IPv6ThroughDhcp) { $vmHostNetworkAdapterParams.IPv6ThroughDhcp = $this.IPv6ThroughDhcp }
        if ($null -ne $this.Mtu) { $vmHostNetworkAdapterParams.Mtu = $this.Mtu }
        if ($null -ne $this.ManagementTrafficEnabled) { $vmHostNetworkAdapterParams.ManagementTrafficEnabled = $this.ManagementTrafficEnabled }
        if ($null -ne $this.FaultToleranceLoggingEnabled) { $vmHostNetworkAdapterParams.FaultToleranceLoggingEnabled = $this.FaultToleranceLoggingEnabled }
        if ($null -ne $this.VMotionEnabled) { $vmHostNetworkAdapterParams.VMotionEnabled = $this.VMotionEnabled }
        if ($null -ne $this.VsanTrafficEnabled) { $vmHostNetworkAdapterParams.VsanTrafficEnabled = $this.VsanTrafficEnabled }

        return $vmHostNetworkAdapterParams
    }

    <#
    .DESCRIPTION

    Creates a new VMKernel Network Adapter connected to the specified Virtual Switch and Port Group for the specified VMHost.
    If the Port Id is specified, the Port Group is ignored and only the Port Id is passed to the cmdlet.
    #>
    [void] AddVMHostNetworkAdapter($virtualSwitch, $portId) {
        $vmHostNetworkAdapterParams = $this.GetVMHostNetworkAdapterParams()

        $vmHostNetworkAdapterParams.Server = $this.Connection
        $vmHostNetworkAdapterParams.VMHost = $this.VMHost
        $vmHostNetworkAdapterParams.VirtualSwitch = $virtualSwitch

        if ($null -ne $portId) {
            $vmHostNetworkAdapterParams.PortId = $portId
        }
        else {
            $vmHostNetworkAdapterParams.PortGroup = $this.PortGroupName
        }

        try {
            New-VMHostNetworkAdapter @vmHostNetworkAdapterParams
        }
        catch {
            throw "Cannot create VMKernel Network Adapter connected to Virtual Switch $($virtualSwitch.Name) and Port Group $($this.PortGroupName). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Updates the VMKernel Network Adapter with the specified properties.
    #>
    [void] UpdateVMHostNetworkAdapter($vmHostNetworkAdapter) {
        $vmHostNetworkAdapterParams = $this.GetVMHostNetworkAdapterParams()

        <#
        IPv6 should only be passed to the cmdlet if an update needs to be performed.
        Otherwise the following error occurs when passing the same array: 'Address already exists in the config.'
        #>
        if (!$this.ShouldUpdateIPv6($vmHostNetworkAdapter.IPv6)) {
            $vmHostNetworkAdapterParams.Remove('IPv6')
        }

        <#
        Both Dhcp and IPv6Enabled are applicable only for the Update operation, so they are not
        populated in the GetVMHostNetworkAdapterParams() which is used for Create and Update operations.
        #>
        if ($null -ne $this.Dhcp) {
            $vmHostNetworkAdapterParams.Dhcp = $this.Dhcp

            <#
            IP and SubnetMask parameters are mutually exclusive with Dhcp so they should be removed
            from the parameters hashtable before calling Set-VMHostNetworkAdapter cmdlet.
            #>
            $vmHostNetworkAdapterParams.Remove('IP')
            $vmHostNetworkAdapterParams.Remove('SubnetMask')
        }

        if ($null -ne $this.IPv6Enabled) {
            $vmHostNetworkAdapterParams.IPv6Enabled = $this.IPv6Enabled

            if (!$this.IPv6Enabled) {
                <#
                If the value of IPv6Enabled is $false, other IPv6 settings cannot be specified.
                #>
                $vmHostNetworkAdapterParams.Remove('AutomaticIPv6')
                $vmHostNetworkAdapterParams.Remove('IPv6ThroughDhcp')
                $vmHostNetworkAdapterParams.Remove('IPv6')
            }
        }

        try {
            $vmHostNetworkAdapter | Set-VMHostNetworkAdapter @vmHostNetworkAdapterParams
        }
        catch {
            throw "Cannot update VMKernel Network Adapter $($vmHostNetworkAdapter.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Removes the VMKernel Network Adapter connected to the specified Virtual Switch and Port Group for the specified VMHost.
    #>
    [void] RemoveVMHostNetworkAdapter($vmHostNetworkAdapter) {
        try {
            Remove-VMHostNetworkAdapter -Nic $vmHostNetworkAdapter -Confirm:$false -ErrorAction Stop
        }
        catch {
            throw "Cannot remove VMKernel Network Adapter $($vmHostNetworkAdapter.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the VMKernel Network Adapter from the server.
    #>
    [void] PopulateResult($vmHostNetworkAdapter, $result) {
        if ($null -ne $vmHostNetworkAdapter) {
            $result.PortGroupName = $vmHostNetworkAdapter.PortGroupName
            $result.Ensure = [Ensure]::Present
            $result.IP = $vmHostNetworkAdapter.IP
            $result.SubnetMask = $vmHostNetworkAdapter.SubnetMask
            $result.Mac = $vmHostNetworkAdapter.Mac
            $result.AutomaticIPv6 = $vmHostNetworkAdapter.AutomaticIPv6
            $result.IPv6 = $vmHostNetworkAdapter.IPv6
            $result.IPv6ThroughDhcp = $vmHostNetworkAdapter.IPv6ThroughDhcp
            $result.Mtu = $vmHostNetworkAdapter.Mtu
            $result.Dhcp = $vmHostNetworkAdapter.DhcpEnabled
            $result.IPv6Enabled = $vmHostNetworkAdapter.IPv6Enabled
            $result.ManagementTrafficEnabled = $vmHostNetworkAdapter.ManagementTrafficEnabled
            $result.FaultToleranceLoggingEnabled = $vmHostNetworkAdapter.FaultToleranceLoggingEnabled
            $result.VMotionEnabled = $vmHostNetworkAdapter.VMotionEnabled
            $result.VsanTrafficEnabled = $vmHostNetworkAdapter.VsanTrafficEnabled
        }
        else {
            $result.PortGroupName = $this.PortGroupName
            $result.Ensure = [Ensure]::Absent
            $result.IP = $this.IP
            $result.SubnetMask = $this.SubnetMask
            $result.Mac = $this.Mac
            $result.AutomaticIPv6 = $this.AutomaticIPv6
            $result.IPv6 = $this.IPv6
            $result.IPv6ThroughDhcp = $this.IPv6ThroughDhcp
            $result.Mtu = $this.Mtu
            $result.Dhcp = $this.Dhcp
            $result.IPv6Enabled = $this.IPv6Enabled
            $result.ManagementTrafficEnabled = $this.ManagementTrafficEnabled
            $result.FaultToleranceLoggingEnabled = $this.FaultToleranceLoggingEnabled
            $result.VMotionEnabled = $this.VMotionEnabled
            $result.VsanTrafficEnabled = $this.VsanTrafficEnabled
        }
    }
}

class VMHostVssBaseDSC : VMHostNetworkBaseDSC {
    <#
    .DESCRIPTION

    Value indicating if the VSS should be Present or Absent.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    <#
    .DESCRIPTION

    The name of the VSS.
    #>
    [DscProperty(Key)]
    [string] $VssName

    <#
    .DESCRIPTION

    Returns the desired virtual switch if it is present on the server otherwise returns $null.
    #>
    [PSObject] GetVss() {
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

        $this.vmHostNetworkSystem.UpdateViewData('NetworkInfo.Vswitch')
        return ($this.vmHostNetworkSystem.NetworkInfo.Vswitch | Where-Object { $_.Name -eq $this.VssName })
    }
}

class VMHostVssPortGroupBaseDSC : VMHostEntityBaseDSC {
    <#
    .DESCRIPTION

    Name of the the Port Group.
    #>
    [DscProperty(Key)]
    [string] $Name

    <#
    .DESCRIPTION

    Value indicating if the Port Group should be Present or Absent.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    <#
    .DESCRIPTION

    The Network System of the specified VMHost.
    #>
    hidden [PSObject] $VMHostNetworkSystem

    <#
    .DESCRIPTION

    Retrieves the Virtual Port Group with the specified name from the server if it exists.
    The Virtual Port Group must be a Standard Virtual Port Group. If the Virtual Port Group does not exist and Ensure is set to 'Absent', $null is returned.
    Otherwise it throws an exception.
    #>
    [PSObject] GetVirtualPortGroup() {
        if ($this.Ensure -eq [Ensure]::Absent) {
            return $null
        }
        else {
            try {
                $virtualPortGroup = Get-VirtualPortGroup -Server $this.Connection -Name $this.Name -VMHost $this.VMHost -Standard -ErrorAction Stop
                return $virtualPortGroup
            }
            catch {
                throw "Could not retrieve Virtual Port Group $($this.Name) of VMHost $($this.VMHost.Name). For more information: $($_.Exception.Message)"
            }
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Network System of the specified VMHost.
    #>
    [void] GetVMHostNetworkSystem() {
        try {
            $this.VMHostNetworkSystem = Get-View -Server $this.Connection -Id $this.VMHost.ExtensionData.ConfigManager.NetworkSystem -ErrorAction Stop
        }
        catch {
            throw "Could not retrieve the Network System of VMHost $($this.VMHost.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the specified Policy Setting. If the Inherited Setting is passed and set to $true,
    the Policy Setting should not be populated because "Parameters of the form "XXX" and "InheritXXX" are mutually exclusive."
    If the Inherited Setting is set to $false, both parameters can be populated.
    #>
    [void] PopulatePolicySetting($policyParams, $policySettingName, $policySetting, $policySettingInheritedName, $policySettingInherited) {
        if ($null -ne $policySetting) {
            if ($null -eq $policySettingInherited -or !$policySettingInherited) {
                $policyParams.$policySettingName = $policySetting
            }
        }

        if ($null -ne $policySettingInherited) { $policyParams.$policySettingInheritedName = $policySettingInherited }
    }
}

[DscResource()]
class Datacenter : InventoryBaseDSC {
    [void] Set() {
        try {
            $this.ConnectVIServer()

            $datacenterLocation = $this.GetInventoryItemLocation()
            $datacenter = $this.GetDatacenter($datacenterLocation)

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $datacenter) {
                    $this.AddDatacenter($datacenterLocation)
                }
            }
            else {
                if ($null -ne $datacenter) {
                    $this.RemoveDatacenter($datacenter)
                }
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()

            $datacenterLocation = $this.GetInventoryItemLocation()
            $datacenter = $this.GetDatacenter($datacenterLocation)

            if ($this.Ensure -eq [Ensure]::Present) {
                return ($null -ne $datacenter)
            }
            else {
                return ($null -eq $datacenter)
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [Datacenter] Get() {
        try {
            $result = [Datacenter]::new()

            $result.Server = $this.Server
            $result.Location = $this.Location

            $this.ConnectVIServer()

            $datacenterLocation = $this.GetInventoryItemLocation()
            $datacenter = $this.GetDatacenter($datacenterLocation)

            $this.PopulateResult($datacenter, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Returns the Datacenter from the specified Location if it exists, otherwise returns $null.
    #>
    [PSObject] GetDatacenter($datacenterLocation) {
        <#
        The client side filtering here is used so we can retrieve only the Datacenter which is located directly below the found Folder Location
        because Get-Datacenter searches recursively and can return more than one Datacenter located below the found Folder Location.
        #>
        return Get-Datacenter -Server $this.Connection -Name $this.Name -Location $datacenterLocation -ErrorAction SilentlyContinue | Where-Object { $_.ParentFolderId -eq $datacenterLocation.Id }
    }

    <#
    .DESCRIPTION

    Creates a new Datacenter with the specified properties at the specified Location.
    #>
    [void] AddDatacenter($datacenterLocation) {
        $datacenterParams = @{}

        $datacenterParams.Server = $this.Connection
        $datacenterParams.Name = $this.Name
        $datacenterParams.Location = $datacenterLocation
        $datacenterParams.Confirm = $false
        $datacenterParams.ErrorAction = 'Stop'

        try {
            New-Datacenter @datacenterParams
        }
        catch {
            throw "Cannot create Datacenter $($this.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Removes the Datacenter from the specified Location.
    #>
    [void] RemoveDatacenter($datacenter) {
        $datacenterParams = @{}

        $datacenterParams.Server = $this.Connection
        $datacenterParams.Confirm = $false
        $datacenterParams.ErrorAction = 'Stop'

        try {
            $datacenter | Remove-Datacenter @datacenterParams
        }
        catch {
            throw "Cannot remove Datacenter $($this.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the Datacenter from the server.
    #>
    [void] PopulateResult($datacenter, $result) {
        if ($null -ne $datacenter) {
            $result.Name = $datacenter.Name
            $result.Ensure = [Ensure]::Present
        }
        else {
            $result.Name = $this.Name
            $result.Ensure = [Ensure]::Absent
        }
    }
}

[DscResource()]
class DatacenterFolder : InventoryBaseDSC {
    [void] Set() {
        try {
            $this.ConnectVIServer()

            $datacenterFolderLocation = $this.GetInventoryItemLocation()
            $datacenterFolder = $this.GetDatacenterFolder($datacenterFolderLocation)

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $datacenterFolder) {
                    $this.AddDatacenterFolder($datacenterFolderLocation)
                }
            }
            else {
                if ($null -ne $datacenterFolder) {
                    $this.RemoveDatacenterFolder($datacenterFolder)
                }
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()

            $datacenterFolderLocation = $this.GetInventoryItemLocation()
            $datacenterFolder = $this.GetDatacenterFolder($datacenterFolderLocation)

            if ($this.Ensure -eq [Ensure]::Present) {
                return ($null -ne $datacenterFolder)
            }
            else {
                return ($null -eq $datacenterFolder)
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [DatacenterFolder] Get() {
        try {
            $result = [DatacenterFolder]::new()

            $result.Server = $this.Server
            $result.Location = $this.Location

            $this.ConnectVIServer()

            $datacenterFolderLocation = $this.GetInventoryItemLocation()
            $datacenterFolder = $this.GetDatacenterFolder($datacenterFolderLocation)

            $this.PopulateResult($datacenterFolder, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Returns the Datacenter Folder from the specified Location if it exists, otherwise returns $null.
    #>
    [PSObject] GetDatacenterFolder($datacenterFolderLocation) {
        <#
        The client side filtering here is used so we can retrieve only the Folder which is located directly below the found Folder Location
        because Get-Folder searches recursively and can return more than one Folder located below the found Folder Location.
        #>
        return Get-Folder -Server $this.Connection -Name $this.Name -Location $datacenterFolderLocation -ErrorAction SilentlyContinue | Where-Object { $_.ParentId -eq $datacenterFolderLocation.Id }
    }

    <#
    .DESCRIPTION

    Creates a new Datacenter Folder with the specified properties at the specified Location.
    #>
    [void] AddDatacenterFolder($datacenterFolderLocation) {
        $datacenterFolderParams = @{}

        $datacenterFolderParams.Server = $this.Connection
        $datacenterFolderParams.Name = $this.Name
        $datacenterFolderParams.Location = $datacenterFolderLocation
        $datacenterFolderParams.Confirm = $false
        $datacenterFolderParams.ErrorAction = 'Stop'

        try {
            New-Folder @datacenterFolderParams
        }
        catch {
            throw "Cannot create Datacenter Folder $($this.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Removes the Datacenter Folder from the specified Location.
    #>
    [void] RemoveDatacenterFolder($datacenterFolder) {
        $datacenterFolderParams = @{}

        $datacenterFolderParams.Server = $this.Connection
        $datacenterFolderParams.Confirm = $false
        $datacenterFolderParams.ErrorAction = 'Stop'

        try {
            $datacenterFolder | Remove-Folder @datacenterFolderParams
        }
        catch {
            throw "Cannot remove Datacenter Folder $($this.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the Datacenter Folder from the server.
    #>
    [void] PopulateResult($datacenterFolder, $result) {
        if ($null -ne $datacenterFolder) {
            $result.Name = $datacenterFolder.Name
            $result.Ensure = [Ensure]::Present
        }
        else {
            $result.Name = $this.Name
            $result.Ensure = [Ensure]::Absent
        }
    }
}

[DscResource()]
class Folder : DatacenterInventoryBaseDSC {
    <#
    .DESCRIPTION

    The type of Root Folder in the Datacenter in which the Folder is located.
    Possible values are VM, Network, Datastore, Host.
    #>
    [DscProperty(Key)]
    [FolderType] $FolderType

    [void] Set() {
        try {
            $this.ConnectVIServer()

            $datacenter = $this.GetDatacenter()
            $datacenterFolderName = "$($this.FolderType)Folder"
            $folderLocation = $this.GetInventoryItemLocationInDatacenter($datacenter, $datacenterFolderName)
            $folder = $this.GetInventoryItem($folderLocation)

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $folder) {
                    $this.AddFolder($folderLocation)
                }
            }
            else {
                if ($null -ne $folder) {
                    $this.RemoveFolder($folder)
                }
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()

            $datacenter = $this.GetDatacenter()
            $datacenterFolderName = "$($this.FolderType)Folder"
            $folderLocation = $this.GetInventoryItemLocationInDatacenter($datacenter, $datacenterFolderName)
            $folder = $this.GetInventoryItem($folderLocation)

            if ($this.Ensure -eq [Ensure]::Present) {
                return ($null -ne $folder)
            }
            else {
                return ($null -eq $folder)
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [Folder] Get() {
        try {
            $result = [Folder]::new()

            $result.Server = $this.Server
            $result.Location = $this.Location
            $result.DatacenterName = $this.DatacenterName
            $result.DatacenterLocation = $this.DatacenterLocation
            $result.FolderType = $this.FolderType

            $this.ConnectVIServer()

            $datacenter = $this.GetDatacenter()
            $datacenterFolderName = "$($this.FolderType)Folder"
            $folderLocation = $this.GetInventoryItemLocationInDatacenter($datacenter, $datacenterFolderName)
            $folder = $this.GetInventoryItem($folderLocation)

            $this.PopulateResult($folder, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Creates a new Folder with the specified properties at the specified Location.
    #>
    [void] AddFolder($folderLocation) {
        $folderParams = @{}

        $folderParams.Server = $this.Connection
        $folderParams.Name = $this.Name
        $folderParams.Location = $folderLocation
        $folderParams.Confirm = $false
        $folderParams.ErrorAction = 'Stop'

        try {
            New-Folder @folderParams
        }
        catch {
            throw "Cannot create Folder $($this.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Removes the Folder from the specified Location.
    #>
    [void] RemoveFolder($folder) {
        $folderParams = @{}

        $folderParams.Server = $this.Connection
        $folderParams.Confirm = $false
        $folderParams.ErrorAction = 'Stop'

        try {
            $folder | Remove-Folder @folderParams
        }
        catch {
            throw "Cannot remove Folder $($this.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the Folder from the server.
    #>
    [void] PopulateResult($folder, $result) {
        if ($null -ne $folder) {
            $result.Name = $folder.Name
            $result.Ensure = [Ensure]::Present
        }
        else {
            $result.Name = $this.Name
            $result.Ensure = [Ensure]::Absent
        }
    }
}

[DscResource()]
class PowerCLISettings {
    <#
    .DESCRIPTION

    Specifies the scope on which the PowerCLI Settings will be applied.
    LCM is the only possible value for the Settings Scope.
    #>
    [DscProperty(Key)]
    [PowerCLISettingsScope] $SettingsScope

    <#
    .DESCRIPTION

    Specifies the proxy policy for the connection through which Customer Experience Improvement Program (CEIP) data is sent to VMware.
    #>
    [DscProperty()]
    [ProxyPolicy] $CEIPDataTransferProxyPolicy = [ProxyPolicy]::Unset

    <#
    .DESCRIPTION

    Specifies the server connection mode.
    #>
    [DscProperty()]
    [DefaultVIServerMode] $DefaultVIServerMode = [DefaultVIServerMode]::Unset

    <#
    .DESCRIPTION

    Indicates whether you want to see warnings about deprecated elements.
    #>
    [DscProperty()]
    [nullable[bool]] $DisplayDeprecationWarnings

    <#
    .DESCRIPTION

    Define the action to take when an attempted connection to a server fails due to a certificate error.
    #>
    [DscProperty()]
    [BadCertificateAction] $InvalidCertificateAction = [BadCertificateAction]::Unset

    <#
    .DESCRIPTION

    Specifies if PowerCLI should send anonymous usage information to VMware.
    #>
    [DscProperty()]
    [nullable[bool]] $ParticipateInCeip

    <#
    .DESCRIPTION

    Specifies whether VMware PowerCLI uses a system proxy server to connect to the vCenter Server system.
    #>
    [DscProperty()]
    [ProxyPolicy] $ProxyPolicy = [ProxyPolicy]::Unset

    <#
    .DESCRIPTION

    Defines the timeout for Web operations. The default value is 300 sec.
    #>
    [DscProperty()]
    [nullable[int]] $WebOperationTimeoutSeconds

    hidden [string] $Scope = "User"

    [void] Set() {
        $this.ImportRequiredModules()
        $powerCLIConfigurationProperties = $this.GetPowerCLIConfigurationProperties()

        $commandName = 'Set-PowerCLIConfiguration'
        $namesOfPowerCLIConfigurationProperties = $powerCLIConfigurationProperties.Keys

        <#
        For testability we use this function to construct the Set-PowerCLIConfiguration cmdlet instead of using splatting and passing the cmdlet parameters as hashtable.
        At the moment Pester does not allow to pass hashtable in the ParameterFilter property of the Assert-MockCalled function.
        There is an open issue in GitHub: (https://github.com/pester/Pester/issues/862) describing the problem in details.
        #>
        $constructedCommand = $this.ConstructCommandWithParameters($commandName, $powerCLIConfigurationProperties, $namesOfPowerCLIConfigurationProperties)
        Invoke-Expression -Command $constructedCommand
    }

    [bool] Test() {
        $this.ImportRequiredModules()
        $powerCLICurrentConfiguration = Get-PowerCLIConfiguration -Scope $this.Scope
        $powerCLIDesiredConfiguration = $this.GetPowerCLIConfigurationProperties()

        return $this.Equals($powerCLICurrentConfiguration, $powerCLIDesiredConfiguration)
    }

    [PowerCLISettings] Get() {
        $this.ImportRequiredModules()
        $result = [PowerCLISettings]::new()
        $powerCLICurrentConfiguration = Get-PowerCLIConfiguration -Scope $this.Scope

        $this.PopulateResult($powerCLICurrentConfiguration, $result)

        return $result
    }

    <#
    .DESCRIPTION

    Imports the needed VMware Modules.
    #>
    [void] ImportRequiredModules() {
        $savedVerbosePreference = $global:VerbosePreference
        $global:VerbosePreference = 'SilentlyContinue'

        Import-Module -Name VMware.VimAutomation.Core

        $global:VerbosePreference = $savedVerbosePreference
    }

    <#
    .DESCRIPTION

    Returns all passed PowerCLI configuration properties as a hashtable.
    #>
    [hashtable] GetPowerCLIConfigurationProperties() {
        $powerCLIConfigurationProperties = @{}

        # Adds the Default Scope to the hashtable.
        $powerCLIConfigurationProperties.Add("Scope", $this.Scope)

        if ($this.CEIPDataTransferProxyPolicy -ne [ProxyPolicy]::Unset -and $this.ParticipateInCeip -eq $true) {
            $powerCLIConfigurationProperties.Add("CEIPDataTransferProxyPolicy", $this.CEIPDataTransferProxyPolicy)
        }

        if ($this.DefaultVIServerMode -ne [DefaultVIServerMode]::Unset) {
            $powerCLIConfigurationProperties.Add("DefaultVIServerMode", $this.DefaultVIServerMode)
        }

        if ($null -ne $this.DisplayDeprecationWarnings) {
            $powerCLIConfigurationProperties.Add("DisplayDeprecationWarnings", $this.DisplayDeprecationWarnings)
        }

        if ($this.InvalidCertificateAction -ne [BadCertificateAction]::Unset) {
            $powerCLIConfigurationProperties.Add("InvalidCertificateAction", $this.InvalidCertificateAction)
        }

        if ($null -ne $this.ParticipateInCeip) {
            $powerCLIConfigurationProperties.Add("ParticipateInCeip", $this.ParticipateInCeip)
        }

        if ($this.ProxyPolicy -ne [ProxyPolicy]::Unset) {
            $powerCLIConfigurationProperties.Add("ProxyPolicy", $this.ProxyPolicy)
        }

        if ($null -ne $this.WebOperationTimeoutSeconds) {
            $powerCLIConfigurationProperties.Add("WebOperationTimeoutSeconds", $this.WebOperationTimeoutSeconds)
        }

        return $powerCLIConfigurationProperties
    }

    <#
    .DESCRIPTION

    Constructs the Set-PowerCLIConfiguration cmdlet with the passed properties.
    This function is used instead of splatting because at the moment Pester does not allow to pass hashtable in the ParameterFilter property of the Assert-MockCalled function.
    There is an open issue in GitHub: (https://github.com/pester/Pester/issues/862) describing the problem in details.
    So with this function we can successfully test which properties are passed to the Set-PowerCLIConfiguration cmdlet.
    #>
    [string] ConstructCommandWithParameters($commandName, $properties, $namesOfProperties) {
        $constructedCommand = [System.Text.StringBuilder]::new()

        # Adds the command name to the constructed command.
        [void]$constructedCommand.Append("$commandName ")

        # For every property name we add the property value with the following syntax: '-Property Value'.
        foreach ($propertyName in $namesOfProperties) {
            $propertyValue = $properties.$propertyName

            <#
            For bool values we need to add another '$' sign so the value can be evaluated to bool.
            So we check the type of the value and if it is a boolean we add another '$' sign, because without it the value will
            not be evaluated to boolean and instead it will be evaluated to string which will cause an exception of mismatching types.
            #>
            if ($propertyValue.GetType().Name -eq 'Boolean') {
                [void]$constructedCommand.Append("-$propertyName $")
                [void]$constructedCommand.Append("$propertyValue ")
            }
            else {
                [void]$constructedCommand.Append("-$propertyName $propertyValue ")
            }
        }

        # Adds the confirm:$false to the command to ignore the confirmation.
        [void]$constructedCommand.Append("-Confirm:`$false")

        # Converts the StringBuilder to String and returns the result.
        return $constructedCommand.ToString()
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if the current PowerCLI Configuration is equal to the Desired Configuration.
    #>
    [bool] Equals($powerCLICurrentConfiguration, $powerCLIDesiredConfiguration) {
        foreach ($key in $powerCLIDesiredConfiguration.Keys) {
            <#
            Currently works only for properties which are numbers, strings and enums. For more complex types like
            Hashtable the logic needs to be modified to work correctly.
            #>
            if ($powerCLIDesiredConfiguration.$key.ToString() -ne $powerCLICurrentConfiguration.$key.ToString()) {
                return $false
            }
        }

        return $true
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the PowerCLI settings from the server.
    #>
    [void] PopulateResult($powerCLICurrentConfiguration, $result) {
        $result.SettingsScope = $this.SettingsScope
        $result.CEIPDataTransferProxyPolicy = if ($null -ne $powerCLICurrentConfiguration.CEIPDataTransferProxyPolicy) { $powerCLICurrentConfiguration.CEIPDataTransferProxyPolicy.ToString() } else { [ProxyPolicy]::Unset }
        $result.DefaultVIServerMode = if ($null -ne $powerCLICurrentConfiguration.DefaultVIServerMode) { $powerCLICurrentConfiguration.DefaultVIServerMode.ToString() } else { [DefaultVIServerMode]::Unset }
        $result.DisplayDeprecationWarnings = $powerCLICurrentConfiguration.DisplayDeprecationWarnings
        $result.InvalidCertificateAction = if ($null -ne $powerCLICurrentConfiguration.InvalidCertificateAction) { $powerCLICurrentConfiguration.InvalidCertificateAction.ToString() } else { [BadCertificateAction]::Unset }
        $result.ParticipateInCeip = $powerCLICurrentConfiguration.ParticipateInCEIP
        $result.ProxyPolicy = if ($null -ne $powerCLICurrentConfiguration.ProxyPolicy) { $powerCLICurrentConfiguration.ProxyPolicy.ToString() } else { [ProxyPolicy]::Unset }
        $result.WebOperationTimeoutSeconds = $powerCLICurrentConfiguration.WebOperationTimeoutSeconds
    }
}

[DscResource()]
class vCenterSettings : BaseDSC {
    <#
    .DESCRIPTION

    Logging Level Advanced Setting value.
    #>
    [DscProperty()]
    [LoggingLevel] $LoggingLevel

    <#
    .DESCRIPTION

    Event Max Age Enabled Advanced Setting value.
    #>
    [DscProperty()]
    [nullable[bool]] $EventMaxAgeEnabled

    <#
    .DESCRIPTION

    Event Max Age Advanced Setting value.
    #>
    [DscProperty()]
    [nullable[int]] $EventMaxAge

    <#
    .DESCRIPTION

    Task Max Age Enabled Advanced Setting value.
    #>
    [DscProperty()]
    [nullable[bool]] $TaskMaxAgeEnabled

    <#
    .DESCRIPTION

    Task Max Age Advanced Setting value.
    #>
    [DscProperty()]
    [nullable[int]] $TaskMaxAge

    <#
    .DESCRIPTION

    Motd Advanced Setting value.
    #>
    [DscProperty()]
    [string] $Motd

    <#
    .DESCRIPTION

    Indicates whether the Motd content should be cleared.
    #>
    [DscProperty()]
    [bool] $MotdClear

    <#
    .DESCRIPTION

    Issue Advanced Setting value.
    #>
    [DscProperty()]
    [string] $Issue

    <#
    .DESCRIPTION

    Indicates whether the Issue content should be cleared.
    #>
    [DscProperty()]
    [bool] $IssueClear

    hidden [string] $LogLevelSettingName = "log.level"
    hidden [string] $EventMaxAgeEnabledSettingName = "event.maxAgeEnabled"
    hidden [string] $EventMaxAgeSettingName = "event.maxAge"
    hidden [string] $TaskMaxAgeEnabledSettingName = "task.maxAgeEnabled"
    hidden [string] $TaskMaxAgeSettingName = "task.maxAge"
    hidden [string] $MotdSettingName = "etc.motd"
    hidden [string] $IssueSettingName = "etc.issue"

    [void] Set() {
        try {
            $this.ConnectVIServer()
            $this.UpdatevCenterSettings($this.Connection)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()
            return !$this.ShouldUpdatevCenterSettings($this.Connection)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [vCenterSettings] Get() {
        try {
            $result = [vCenterSettings]::new()
            $result.Server = $this.Server

            $this.ConnectVIServer()
            $this.PopulateResult($this.Connection, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if the Advanced Setting value should be updated.
    #>
    [bool] ShouldUpdateSettingValue($desiredValue, $currentValue) {
        <#
            LoggingLevel type properties should be updated only when Desired value is different than Unset.
            Unset means that value was not specified for such type of property.
        #>
        if ($desiredValue -is [LoggingLevel] -and $desiredValue -eq [LoggingLevel]::Unset) {
            return $false
        }

        <#
            Desired value equal to $null means that the setting value was not specified.
            If it is specified we check if the setting value is not equal to the current value.
        #>
        return ($null -ne $desiredValue -and $desiredValue -ne $currentValue)
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if at least one Advanced Setting value should be updated.
    #>
    [bool] ShouldUpdatevCenterSettings($vCenter) {
        $vCenterCurrentAdvancedSettings = Get-AdvancedSetting -Server $this.Connection -Entity $vCenter

    	$currentLogLevel = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.LogLevelSettingName }
    	$currentEventMaxAgeEnabled = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.EventMaxAgeEnabledSettingName }
    	$currentEventMaxAge = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.EventMaxAgeSettingName }
    	$currentTaskMaxAgeEnabled = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.TaskMaxAgeEnabledSettingName }
    	$currentTaskMaxAge = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.TaskMaxAgeSettingName }
    	$currentMotd = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.MotdSettingName }
    	$currentIssue = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.IssueSettingName }

    	$shouldUpdatevCenterSettings = @()
    	$shouldUpdatevCenterSettings += $this.ShouldUpdateSettingValue($this.LoggingLevel, $currentLogLevel.Value)
    	$shouldUpdatevCenterSettings += $this.ShouldUpdateSettingValue($this.EventMaxAgeEnabled, $currentEventMaxAgeEnabled.Value)
    	$shouldUpdatevCenterSettings += $this.ShouldUpdateSettingValue($this.EventMaxAge, $currentEventMaxAge.Value)
    	$shouldUpdatevCenterSettings += $this.ShouldUpdateSettingValue($this.TaskMaxAgeEnabled, $currentTaskMaxAgeEnabled.Value)
    	$shouldUpdatevCenterSettings += $this.ShouldUpdateSettingValue($this.TaskMaxAge, $currentTaskMaxAge.Value)
    	$shouldUpdatevCenterSettings += ($this.MotdClear -and ($currentMotd.Value -ne [string]::Empty)) -or (-not $this.MotdClear -and ($this.Motd -ne $currentMotd.Value))
        $shouldUpdatevCenterSettings += ($this.IssueClear -and ($currentIssue.Value -ne [string]::Empty)) -or (-not $this.IssueClear -and ($this.Issue -ne $currentIssue.Value))

    	return ($shouldUpdatevCenterSettings -Contains $true)
    }

    <#
    .DESCRIPTION

    Sets the desired value for the Advanced Setting, if update of the Advanced Setting value is needed.
    #>
   [void] SetAdvancedSetting($advancedSetting, $advancedSettingDesiredValue, $advancedSettingCurrentValue) {
        if ($this.ShouldUpdateSettingValue($advancedSettingDesiredValue, $advancedSettingCurrentValue)) {
            Set-AdvancedSetting -AdvancedSetting $advancedSetting -Value $advancedSettingDesiredValue -Confirm:$false
        }
    }

    <#
    .DESCRIPTION

    Sets the desired value for the Advanced Setting, if update of the Advanced Setting value is needed.
    This handles Advanced Settings that have a "Clear" property.
    #>

    [void] SetAdvancedSetting($advancedSetting, $advancedSettingDesiredValue, $advancedSettingCurrentValue, $clearValue) {
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

    	if ($clearValue) {
      	    if ($this.ShouldUpdateSettingValue([string]::Empty, $advancedSettingCurrentValue)) {
                Set-AdvancedSetting -AdvancedSetting $advancedSetting -Value [string]::Empty -Confirm:$false
      	    }
    	}
    	else {
      	    if ($this.ShouldUpdateSettingValue($advancedSettingDesiredValue, $advancedSettingCurrentValue)) {
                Set-AdvancedSetting -AdvancedSetting $advancedSetting -Value $advancedSettingDesiredValue -Confirm:$false
      	    }
    	}
  	}

    <#
    .DESCRIPTION

    Performs update on those Advanced Settings values that needs to be updated.
    #>
    [void] UpdatevCenterSettings($vCenter) {
        $vCenterCurrentAdvancedSettings = Get-AdvancedSetting -Server $this.Connection -Entity $vCenter

        $currentLogLevel = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.LogLevelSettingName }
        $currentEventMaxAgeEnabled = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.EventMaxAgeEnabledSettingName }
        $currentEventMaxAge = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.EventMaxAgeSettingName }
        $currentTaskMaxAgeEnabled = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.TaskMaxAgeEnabledSettingName }
        $currentTaskMaxAge = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.TaskMaxAgeSettingName }
    	$currentMotd = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.MotdSettingName }
    	$currentIssue = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.IssueSettingName }

        $this.SetAdvancedSetting($currentLogLevel, $this.LoggingLevel, $currentLogLevel.Value)
        $this.SetAdvancedSetting($currentEventMaxAgeEnabled, $this.EventMaxAgeEnabled, $currentEventMaxAgeEnabled.Value)
        $this.SetAdvancedSetting($currentEventMaxAge, $this.EventMaxAge, $currentEventMaxAge.Value)
        $this.SetAdvancedSetting($currentTaskMaxAgeEnabled, $this.TaskMaxAgeEnabled, $currentTaskMaxAgeEnabled.Value)
        $this.SetAdvancedSetting($currentTaskMaxAge, $this.TaskMaxAge, $currentTaskMaxAge.Value)
    	$this.SetAdvancedSetting($currentMotd, $this.Motd, $currentMotd.Value, $this.MotdClear)
    	$this.SetAdvancedSetting($currentIssue, $this.Issue, $currentIssue.Value, $this.IssueClear)
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the advanced settings from the server.
    #>
    [void] PopulateResult($vCenter, $result) {
        $vCenterCurrentAdvancedSettings = Get-AdvancedSetting -Server $this.Connection -Entity $vCenter

        $currentLogLevel = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.LogLevelSettingName }
        $currentEventMaxAgeEnabled = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.EventMaxAgeEnabledSettingName }
        $currentEventMaxAge = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.EventMaxAgeSettingName }
        $currentTaskMaxAgeEnabled = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.TaskMaxAgeEnabledSettingName }
        $currentTaskMaxAge = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.TaskMaxAgeSettingName }
        $currentMotd = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.MotdSettingName }
        $currentIssue = $vCenterCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.IssueSettingName }

        $result.LoggingLevel = $currentLogLevel.Value
        $result.EventMaxAgeEnabled = $currentEventMaxAgeEnabled.Value
        $result.EventMaxAge = $currentEventMaxAge.Value
        $result.TaskMaxAgeEnabled = $currentTaskMaxAgeEnabled.Value
        $result.TaskMaxAge = $currentTaskMaxAge.Value
        $result.Motd = $currentMotd.Value
        $result.Issue = $currentIssue.Value
    }
}

[DscResource()]
class vCenterStatistics : BaseDSC {
    <#
    .DESCRIPTION

    The unit of period. Statistics can be stored separatelly for each of the {Day, Week, Month, Year} period units.
    #>
    [DscProperty(Key)]
    [Period] $Period

    <#
    .DESCRIPTION

    Period for which the statistics are saved.
    #>
    [DscProperty()]
    [nullable[long]] $PeriodLength

    <#
    .DESCRIPTION

    Specified Level value for the vCenter Statistics.
    #>
    [DscProperty()]
    [nullable[int]] $Level

    <#
    .DESCRIPTION

    If collecting statistics for the specified period unit is enabled.
    #>
    [DscProperty()]
    [nullable[bool]] $Enabled

    <#
    .DESCRIPTION

    Interval in Minutes, indicating the period for collecting statistics.
    #>
    [DscProperty()]
    [nullable[long]] $IntervalMinutes

    hidden [int] $SecondsInAMinute = 60

    [void] Set() {
        try {
            $this.ConnectVIServer()
            $performanceManager = $this.GetPerformanceManager()
            $currentPerformanceInterval = $this.GetPerformanceInterval($performanceManager)

            $this.UpdatePerformanceInterval($performanceManager, $currentPerformanceInterval)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()
            $performanceManager = $this.GetPerformanceManager()
            $currentPerformanceInterval = $this.GetPerformanceInterval($performanceManager)

            return $this.Equals($currentPerformanceInterval)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [vCenterStatistics] Get() {
        try {
            $result = [vCenterStatistics]::new()
            $result.Server = $this.Server
            $result.Period = $this.Period

            $this.ConnectVIServer()
            $performanceManager = $this.GetPerformanceManager()
            $currentPerformanceInterval = $this.GetPerformanceInterval($performanceManager)

            $result.Level = $currentPerformanceInterval.Level
            $result.Enabled = $currentPerformanceInterval.Enabled

            # Converts the Sampling Period from seconds to minutes
            $result.IntervalMinutes = $currentPerformanceInterval.SamplingPeriod / $this.SecondsInAMinute

            # Converts the PeriodLength from seconds to the specified Period type
            $result.PeriodLength = $currentPerformanceInterval.Length / $this.Period

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Returns the Performance Manager for the specified vCenter.
    #>
    [PSObject] GetPerformanceManager() {
        $vCenter = $this.Connection
        $performanceManager = Get-View -Server $this.Connection -Id $vCenter.ExtensionData.Content.PerfManager

        return $performanceManager
    }

    <#
    .DESCRIPTION

    Returns the Performance Interval for which the new statistics settings should be applied.
    #>
    [PSObject] GetPerformanceInterval($performanceManager) {
        $currentPerformanceInterval = $performanceManager.HistoricalInterval | Where-Object { $_.Name -Match $this.Period }

        return $currentPerformanceInterval
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if the desired and current values are equal.
    #>
    [bool] AreEqual($desiredValue, $currentValue) {
        <#
            Desired value equal to $null means the value is not specified and should be ignored when we check for equality.
            So in this case we return $true. Otherwise we check if the Specified value is equal to the current value.
        #>
        return ($null -eq $desiredValue -or $desiredValue -eq $currentValue)
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if the Current Performance Interval is equal to the Desired Performance Interval.
    #>
    [bool] Equals($currentPerformanceInterval) {
        $equalLevels = $this.AreEqual($this.Level, $currentPerformanceInterval.Level)
        $equalEnabled = $this.AreEqual($this.Enabled, $currentPerformanceInterval.Enabled)
        $equalIntervalMinutes = $this.AreEqual($this.IntervalMinutes, $currentPerformanceInterval.SamplingPeriod / $this.SecondsInAMinute)
        $equalPeriodLength = $this.AreEqual($this.PeriodLength, $currentPerformanceInterval.Length / $this.Period)

        return ($equalLevels -and $equalEnabled -and $equalIntervalMinutes -and $equalPeriodLength)
    }

    <#
    .DESCRIPTION

    Returns the value to set for the Performance Interval Setting.
    #>
    [PSObject] SpecifiedOrCurrentValue($desiredValue, $currentValue) {
        if ($null -eq $desiredValue) {
            # Desired value is not specified
            return $currentValue
        }
        else {
            return $desiredValue
        }
    }

    <#
    .DESCRIPTION

    Updates the Performance Interval with the specified settings for vCenter Statistics.
    #>
    [void] UpdatePerformanceInterval($performanceManager, $currentPerformanceInterval) {
        $performanceIntervalArgs = @{
            Key = $currentPerformanceInterval.Key
            Name = $currentPerformanceInterval.Name
            Enabled = $this.SpecifiedOrCurrentValue($this.Enabled, $currentPerformanceInterval.Enabled)
            Level = $this.SpecifiedOrCurrentValue($this.Level, $currentPerformanceInterval.Level)
            SamplingPeriod = $this.SpecifiedOrCurrentValue($this.IntervalMinutes * $this.SecondsInAMinute, $currentPerformanceInterval.SamplingPeriod)
            Length = $this.SpecifiedOrCurrentValue($this.PeriodLength * $this.Period, $currentPerformanceInterval.Length)
        }

        $desiredPerformanceInterval = New-PerformanceInterval @performanceIntervalArgs

        try {
            Update-PerfInterval -PerformanceManager $performanceManager -PerformanceInterval $desiredPerformanceInterval
        }
        catch {
            throw "Server operation failed with the following error: $($_.Exception.Message)"
        }
    }
}

[DscResource()]
class VDPortGroup : BaseDSC {
    <#
    .DESCRIPTION

    Specifies the name of the Distributed Port Group.
    #>
    [DscProperty(Key)]
    [string] $Name

    <#
    .DESCRIPTION

    Specifies the name of the vSphere Distributed Switch associated with the Distributed Port Group.
    #>
    [DscProperty(Mandatory)]
    [string] $VdsName

    <#
    .DESCRIPTION

    Value indicating if the Distributed Port Group should be Present or Absent.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    <#
    .DESCRIPTION

    Specifies a description for the Distributed Port Group.
    #>
    [DscProperty()]
    [string] $Notes

    <#
    .DESCRIPTION

    Specifies the number of ports that the Distributed Port Group will have.
    If the parameter is not specified, the number of ports for the Distributed Port Group is 128.
    #>
    [DscProperty()]
    [nullable[int]] $NumPorts

    <#
    .DESCRIPTION

    Specifies the port binding setting for the Distributed Port Group.
    Valid values are Static, Dynamic, and Ephemeral.
    #>
    [DscProperty()]
    [PortBinding] $PortBinding = [PortBinding]::Unset

    <#
    .DESCRIPTION

    Specifies the name for the reference Distributed Port Group.
    The properties of the new Distributed Port Group will be cloned from the reference Distributed Port Group.
    #>
    [DscProperty()]
    [string] $ReferenceVDPortGroupName

    [void] Set() {
        try {
            $this.ConnectVIServer()
            $this.EnsureConnectionIsvCenter()

            $distributedSwitch = $this.GetDistributedSwitch()
            $distributedPortGroup = $this.GetDistributedPortGroup($distributedSwitch)

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $distributedPortGroup) {
                    $this.AddDistributedPortGroup($distributedSwitch)
                }
                else {
                    $this.UpdateDistributedPortGroup($distributedPortGroup)
                }
            }
            else {
                if ($null -ne $distributedPortGroup) {
                    $this.RemoveDistributedPortGroup($distributedPortGroup)
                }
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()
            $this.EnsureConnectionIsvCenter()

            $distributedSwitch = $this.GetDistributedSwitch()
            $distributedPortGroup = $this.GetDistributedPortGroup($distributedSwitch)

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $distributedPortGroup) {
                    return $false
                }

                return !$this.ShouldUpdateDistributedPortGroup($distributedPortGroup)
            }
            else {
                return ($null -eq $distributedPortGroup)
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VDPortGroup] Get() {
        try {
            $result = [VDPortGroup]::new()

            $this.ConnectVIServer()
            $this.EnsureConnectionIsvCenter()

            $distributedSwitch = $this.GetDistributedSwitch()
            $distributedPortGroup = $this.GetDistributedPortGroup($distributedSwitch)

            $this.PopulateResult($distributedPortGroup, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Distributed Switch with the specified name from the server if it exists.
    If the Distributed Switch does not exist and Ensure is set to 'Absent', $null is returned.
    Otherwise it throws an exception.
    #>
    [PSObject] GetDistributedSwitch() {
        <#
        The Verbose logic here is needed to suppress the Exporting and Importing of the
        cmdlets from the VMware.VimAutomation.Vds Module.
        #>
        $savedVerbosePreference = $global:VerbosePreference
        $global:VerbosePreference = 'SilentlyContinue'

        try {
            if ($this.Ensure -eq [Ensure]::Absent) {
                return Get-VDSwitch -Server $this.Connection -Name $this.VdsName -ErrorAction SilentlyContinue
            }
            else {
                try {
                    $distributedSwitch = Get-VDSwitch -Server $this.Connection -Name $this.VdsName -ErrorAction Stop
                    return $distributedSwitch
                }
                catch {
                    throw "Could not retrieve Distributed Switch $($this.VdsName). For more information: $($_.Exception.Message)"
                }
            }
        }
        finally {
            $global:VerbosePreference = $savedVerbosePreference
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Distributed Port Group with the specified name, available on the specified Distributed Switch from the server if it exists.
    Otherwise returns $null.
    #>
    [PSObject] GetDistributedPortGroup($distributedSwitch) {
        if ($null -eq $distributedSwitch) {
            <#
            If the Distributed Switch is $null, it means that Ensure was set to 'Absent' and
            the Distributed Port Group does not exist for the specified Distributed Switch.
            #>
            return $null
        }

        return Get-VDPortgroup -Server $this.Connection -Name $this.Name -VDSwitch $distributedSwitch -ErrorAction SilentlyContinue
    }

    <#
    .DESCRIPTION

    Checks if the passed Distributed Port Group needs be modified based on the passed properties.
    #>
    [bool] ShouldUpdateDistributedPortGroup($distributedPortGroup) {
        $shouldUpdateDistributedPortGroup = @()

        <#
        The VDPortGroup object does not contain information about ReferenceVDPortGroupName so the property is not
        part of the Desired State of the Resource.
        #>
        if ($null -ne $this.Notes) {
            <#
            The server value for Notes property can be both $null and empty string. The DSC Resource will support only empty string value.
            Null value means that the property was not passed in the Configuration.
            #>
            if ($this.Notes -eq [string]::Empty) {
                $shouldUpdateDistributedPortGroup += ($null -ne $distributedPortGroup.Notes -and $distributedPortGroup.Notes -ne [string]::Empty)
            }
            else {
                $shouldUpdateDistributedPortGroup += ($this.Notes -ne $distributedPortGroup.Notes)
            }
        }

        $shouldUpdateDistributedPortGroup += ($null -ne $this.NumPorts -and $this.NumPorts -ne $distributedPortGroup.NumPorts)

        if ($this.PortBinding -ne [PortBinding]::Unset) {
            $shouldUpdateDistributedPortGroup += ($this.PortBinding.ToString() -ne $distributedPortGroup.PortBinding.ToString())
        }

        return ($shouldUpdateDistributedPortGroup -Contains $true)
    }

    <#
    .DESCRIPTION

    Returns the populated Distributed Port Group parameters.
    #>
    [hashtable] GetDistributedPortGroupParams() {
        $distributedPortGroupParams = @{}

        $distributedPortGroupParams.Server = $this.Connection
        $distributedPortGroupParams.Confirm = $false
        $distributedPortGroupParams.ErrorAction = 'Stop'

        if ($null -ne $this.Notes) { $distributedPortGroupParams.Notes = $this.Notes }
        if ($null -ne $this.NumPorts) { $distributedPortGroupParams.NumPorts = $this.NumPorts }

        if ($this.PortBinding -ne [PortBinding]::Unset) {
            $distributedPortGroupParams.PortBinding = $this.PortBinding.ToString()
        }

        return $distributedPortGroupParams
    }

    <#
    .DESCRIPTION

    Creates a new Distributed Port Group available on the specified Distributed Switch.
    #>
    [void] AddDistributedPortGroup($distributedSwitch) {
        $distributedPortGroupParams = $this.GetDistributedPortGroupParams()
        $distributedPortGroupParams.Name = $this.Name
        $distributedPortGroupParams.VDSwitch = $distributedSwitch

        <#
        ReferencePortGroup is parameter only for the New-VDPortgroup cmdlet
        and is not used for the Set-VDPortgroup cmdlet.
        #>
        if (![string]::IsNullOrEmpty($this.ReferenceVDPortGroupName)) { $distributedPortGroupParams.ReferencePortgroup = $this.ReferenceVDPortGroupName }

        try {
            New-VDPortgroup @distributedPortGroupParams
        }
        catch {
            throw "Cannot create Distributed Port Group $($this.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Modifies the configuration of the specified Distributed Port Group with the passed properties.
    #>
    [void] UpdateDistributedPortGroup($distributedPortGroup) {
        $distributedPortGroupParams = $this.GetDistributedPortGroupParams()

        try {
            $distributedPortGroup | Set-VDPortgroup @distributedPortGroupParams
        }
        catch {
            throw "Cannot update Distributed Port Group $($this.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Removes the specified Distributed Port Group from the vSphere Distributed Switch that it belongs to.
    #>
    [void] RemoveDistributedPortGroup($distributedPortGroup) {
        try {
            $distributedPortGroup | Remove-VDPortGroup -Server $this.Connection -Confirm:$false -ErrorAction Stop
        }
        catch {
            throw "Cannot remove Distributed Port Group $($this.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method.
    #>
    [void] PopulateResult($distributedPortGroup, $result) {
        $result.Server = $this.Connection.Name
        $result.ReferenceVDPortGroupName = $this.ReferenceVDPortGroupName

        if ($null -ne $distributedPortGroup) {
            $result.Name = $distributedPortGroup.Name
            $result.VdsName = $distributedPortGroup.VDSwitch.Name
            $result.Ensure = [Ensure]::Present
            $result.Notes = $distributedPortGroup.Notes
            $result.NumPorts = $distributedPortGroup.NumPorts
            $result.PortBinding = $distributedPortGroup.PortBinding.ToString()
        }
        else {
            $result.Name = $this.Name
            $result.VdsName = $this.VdsName
            $result.Ensure = [Ensure]::Absent
            $result.Notes = $this.Notes
            $result.NumPorts = $this.NumPorts
            $result.PortBinding = $this.PortBinding
        }
    }
}

[DscResource()]
class VDSwitch : DatacenterInventoryBaseDSC {
    DistributedSwitch() {
        $this.InventoryItemFolderType = [FolderType]::Network
    }

    <#
    .DESCRIPTION

    Specifies the contact details of the vSphere Distributed Switch administrator.
    #>
    [DscProperty()]
    [string] $ContactDetails

    <#
    .DESCRIPTION

    Specifies the name of the vSphere Distributed Switch administrator.
    #>
    [DscProperty()]
    [string] $ContactName

    <#
    .DESCRIPTION

    Specifies the discovery protocol type of the vSphere Distributed Switch that you want to create.
    The valid values are CDP, LLDP and Unset. If you do not set a value for this parameter, the default server setting is used.
    #>
    [DscProperty()]
    [LinkDiscoveryProtocolProtocol] $LinkDiscoveryProtocol = [LinkDiscoveryProtocolProtocol]::Unset

    <#
    .DESCRIPTION

    Specifies the link discovery protocol operation for the vSphere Distributed Switch that you want to create.
    The valid values are Advertise, Both, Listen, None and Unset. If you do not set a value for this parameter, the default server setting is used.
    #>
    [DscProperty()]
    [LinkDiscoveryProtocolOperation] $LinkDiscoveryProtocolOperation = [LinkDiscoveryProtocolOperation]::Unset

    <#
    .DESCRIPTION

    Specifies the maximum number of ports allowed on the vSphere Distributed Switch that you want to create.
    #>
    [DscProperty()]
    [nullable[int]] $MaxPorts

    <#
    .DESCRIPTION

    Specifies the maximum MTU size for the vSphere Distributed Switch that you want to create. Valid values are positive integers only.
    #>
    [DscProperty()]
    [nullable[int]] $Mtu

    <#
    .DESCRIPTION

    Specifies a description for the vSphere Distributed Switch that you want to create.
    #>
    [DscProperty()]
    [string] $Notes

    <#
    .DESCRIPTION

    Specifies the number of uplink ports on the vSphere Distributed Switch that you want to create.
    #>
    [DscProperty()]
    [nullable[int]] $NumUplinkPorts

    <#
    .DESCRIPTION

    Specifies the Name for the reference vSphere Distributed Switch.
    The properties of the new vSphere Distributed Switch will be cloned from the reference vSphere Distributed Switch.
    #>
    [DscProperty()]
    [string] $ReferenceVDSwitchName

    <#
    .DESCRIPTION

    Specifies the version of the vSphere Distributed Switch that you want to create.
    You cannot specify a version that is incompatible with the version of the vCenter Server system you are connected to.
    #>
    [DscProperty()]
    [string] $Version

    <#
    .DESCRIPTION

    Indicates whether the new vSphere Distributed Switch will be created without importing the port groups from the specified reference vSphere Distributed Switch.
    #>
    [DscProperty()]
    [nullable[bool]] $WithoutPortGroups

    [void] Set() {
        try {
            $this.ConnectVIServer()
            $this.EnsureConnectionIsvCenter()

            $datacenter = $this.GetDatacenter()
            $datacenterFolderName = "$($this.InventoryItemFolderType)Folder"
            $distributedSwitchLocation = $this.GetInventoryItemLocationInDatacenter($datacenter, $datacenterFolderName)
            $distributedSwitch = $this.GetDistributedSwitch($distributedSwitchLocation)

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $distributedSwitch) {
                    $this.AddDistributedSwitch($distributedSwitchLocation)
                }
                else {
                    $this.UpdateDistributedSwitch($distributedSwitch)
                }
            }
            else {
                if ($null -ne $distributedSwitch) {
                    $this.RemoveDistributedSwitch($distributedSwitch)
                }
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()
            $this.EnsureConnectionIsvCenter()

            $datacenter = $this.GetDatacenter()
            $datacenterFolderName = "$($this.InventoryItemFolderType)Folder"
            $distributedSwitchLocation = $this.GetInventoryItemLocationInDatacenter($datacenter, $datacenterFolderName)
            $distributedSwitch = $this.GetDistributedSwitch($distributedSwitchLocation)

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $distributedSwitch) {
                    return $false
                }

                return !$this.ShouldUpdateDistributedSwitch($distributedSwitch)
            }
            else {
                return ($null -eq $distributedSwitch)
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VDSwitch] Get() {
        try {
            $result = [VDSwitch]::new()
            $result.Server = $this.Server
            $result.Location = $this.Location
            $result.DatacenterName = $this.DatacenterName
            $result.DatacenterLocation = $this.DatacenterLocation
            $result.ReferenceVDSwitchName = $this.ReferenceVDSwitchName
            $result.WithoutPortGroups = $this.WithoutPortGroups

            $this.ConnectVIServer()
            $this.EnsureConnectionIsvCenter()

            $datacenter = $this.GetDatacenter()
            $datacenterFolderName = "$($this.InventoryItemFolderType)Folder"
            $distributedSwitchLocation = $this.GetInventoryItemLocationInDatacenter($datacenter, $datacenterFolderName)
            $distributedSwitch = $this.GetDistributedSwitch($distributedSwitchLocation)

            $this.PopulateResult($distributedSwitch, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Distributed Switch from the specified Location in the Datacenter if it exists, otherwise returns $null.
    #>
    [PSObject] GetDistributedSwitch($distributedSwitchLocation) {
        <#
        The Verbose logic here is needed to suppress the Exporting and Importing of the
        cmdlets from the VMware.VimAutomation.Vds Module.
        #>
        $savedVerbosePreference = $global:VerbosePreference
        $global:VerbosePreference = 'SilentlyContinue'

        $distributedSwitch = Get-VDSwitch -Server $this.Connection -Name $this.Name -Location $distributedSwitchLocation -ErrorAction SilentlyContinue

        $global:VerbosePreference = $savedVerbosePreference

        return $distributedSwitch
    }

    <#
    .DESCRIPTION

    Checks if the passed Distributed Switch needs be updated based on the specified properties.
    #>
    [bool] ShouldUpdateDistributedSwitch($distributedSwitch) {
        $shouldUpdateDistributedSwitch = @()

        <#
        The VDSwitch object does not contain information about ReferenceVDSwitchName and WithoutPortGroups so those properties are not
        part of the Desired State of the Resource.
        #>
        $shouldUpdateDistributedSwitch += (![string]::IsNullOrEmpty($this.ContactDetails) -and $this.ContactDetails -ne $distributedSwitch.ContactDetails)
        $shouldUpdateDistributedSwitch += (![string]::IsNullOrEmpty($this.ContactName) -and $this.ContactName -ne $distributedSwitch.ContactName)
        $shouldUpdateDistributedSwitch += (![string]::IsNullOrEmpty($this.Notes) -and $this.Notes -ne $distributedSwitch.Notes)
        $shouldUpdateDistributedSwitch += (![string]::IsNullOrEmpty($this.Version) -and $this.Version -ne $distributedSwitch.Version)

        $shouldUpdateDistributedSwitch += ($null -ne $this.MaxPorts -and $this.MaxPorts -ne $distributedSwitch.MaxPorts)
        $shouldUpdateDistributedSwitch += ($null -ne $this.Mtu -and $this.Mtu -ne $distributedSwitch.Mtu)
        $shouldUpdateDistributedSwitch += ($null -ne $this.NumUplinkPorts -and $this.NumUplinkPorts -ne $distributedSwitch.NumUplinkPorts)

        if ($this.LinkDiscoveryProtocol -ne [LinkDiscoveryProtocolProtocol]::Unset) {
            $shouldUpdateDistributedSwitch += ($this.LinkDiscoveryProtocol.ToString() -ne $distributedSwitch.LinkDiscoveryProtocol.ToString())
        }

        if ($this.LinkDiscoveryProtocolOperation -ne [LinkDiscoveryProtocolOperation]::Unset) {
            $shouldUpdateDistributedSwitch += ($this.LinkDiscoveryProtocolOperation.ToString() -ne $distributedSwitch.LinkDiscoveryProtocolOperation.ToString())
        }

        return ($shouldUpdateDistributedSwitch -Contains $true)
    }

    <#
    .DESCRIPTION

    Returns the populated Distributed Switch parameters.
    #>
    [hashtable] GetDistributedSwitchParams() {
        $distributedSwitchParams = @{}

        $distributedSwitchParams.Server = $this.Connection
        $distributedSwitchParams.Confirm = $false
        $distributedSwitchParams.ErrorAction = 'Stop'

        if (![string]::IsNullOrEmpty($this.ContactDetails)) { $distributedSwitchParams.ContactDetails = $this.ContactDetails }
        if (![string]::IsNullOrEmpty($this.ContactName)) { $distributedSwitchParams.ContactName = $this.ContactName }
        if (![string]::IsNullOrEmpty($this.Notes)) { $distributedSwitchParams.Notes = $this.Notes }
        if (![string]::IsNullOrEmpty($this.Version)) { $distributedSwitchParams.Version = $this.Version }

        if ($null -ne $this.MaxPorts) { $distributedSwitchParams.MaxPorts = $this.MaxPorts }
        if ($null -ne $this.Mtu) { $distributedSwitchParams.Mtu = $this.Mtu }
        if ($null -ne $this.NumUplinkPorts) { $distributedSwitchParams.NumUplinkPorts = $this.NumUplinkPorts }

        if ($this.LinkDiscoveryProtocol -ne [LinkDiscoveryProtocolProtocol]::Unset) {
            $distributedSwitchParams.LinkDiscoveryProtocol = $this.LinkDiscoveryProtocol.ToString()
        }

        if ($this.LinkDiscoveryProtocolOperation -ne [LinkDiscoveryProtocolOperation]::Unset) {
            $distributedSwitchParams.LinkDiscoveryProtocolOperation = $this.LinkDiscoveryProtocolOperation.ToString()
        }

        return $distributedSwitchParams
    }

    <#
    .DESCRIPTION

    Creates a new Distributed Switch with the specified properties at the specified location.
    #>
    [void] AddDistributedSwitch($distributedSwitchLocation) {
        $distributedSwitchParams = $this.GetDistributedSwitchParams()
        $distributedSwitchParams.Name = $this.Name
        $distributedSwitchParams.Location = $distributedSwitchLocation

        <#
        ReferenceVDSwitch and WithoutPortGroups are parameters only for the New-VDSwitch cmdlet
        and are not used for the Set-VDSwitch cmdlet.
        #>
        if (![string]::IsNullOrEmpty($this.ReferenceVDSwitchName)) { $distributedSwitchParams.ReferenceVDSwitch = $this.ReferenceVDSwitchName }
        if ($null -ne $this.WithoutPortGroups) { $distributedSwitchParams.WithoutPortGroups = $this.WithoutPortGroups }

        try {
            New-VDSwitch @distributedSwitchParams
        }
        catch {
            throw "Cannot create Distributed Switch $($this.Name) at Location $($distributedSwitchLocation.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Updates the Distributed Switch with the specified properties.
    #>
    [void] UpdateDistributedSwitch($distributedSwitch) {
        $distributedSwitchParams = $this.GetDistributedSwitchParams()

        try {
            $distributedSwitch | Set-VDSwitch @distributedSwitchParams
        }
        catch {
            throw "Cannot update Distributed Switch $($this.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Removes the Distributed Switch from the specified location.
    #>
    [void] RemoveDistributedSwitch($distributedSwitch) {
        try {
            $distributedSwitch | Remove-VDSwitch -Server $this.Connection -Confirm:$false -ErrorAction Stop
        }
        catch {
            throw "Cannot remove Distributed Switch $($this.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the Distributed Switch from the server.
    #>
    [void] PopulateResult($distributedSwitch, $result) {
        if ($null -ne $distributedSwitch) {
            $result.Name = $distributedSwitch.Name
            $result.Ensure = [Ensure]::Present
            $result.ContactDetails = $distributedSwitch.ContactDetails
            $result.ContactName = $distributedSwitch.ContactName
            $result.LinkDiscoveryProtocol = $distributedSwitch.LinkDiscoveryProtocol.ToString()
            $result.LinkDiscoveryProtocolOperation = $distributedSwitch.LinkDiscoveryProtocolOperation.ToString()
            $result.MaxPorts = $distributedSwitch.MaxPorts
            $result.Mtu = $distributedSwitch.Mtu
            $result.Notes = $distributedSwitch.Notes
            $result.NumUplinkPorts = $distributedSwitch.NumUplinkPorts
            $result.Version = $distributedSwitch.Version
        }
        else {
            $result.Name = $this.Name
            $result.Ensure = [Ensure]::Absent
            $result.ContactDetails = $this.ContactDetails
            $result.ContactName = $this.ContactName
            $result.LinkDiscoveryProtocol = $this.LinkDiscoveryProtocol
            $result.LinkDiscoveryProtocolOperation = $this.LinkDiscoveryProtocolOperation
            $result.MaxPorts = $this.MaxPorts
            $result.Mtu = $this.Mtu
            $result.Notes = $this.Notes
            $result.NumUplinkPorts = $this.NumUplinkPorts
            $result.Version = $this.Version
        }
    }
}

[DscResource()]
class VMHostAccount : BaseDSC {
    <#
    .DESCRIPTION

    Specifies the ID for the host account.
    #>
    [DscProperty(Key)]
    [string] $Id

    <#
    .DESCRIPTION

    Value indicating if the Resource should be Present or Absent.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    <#
    .DESCRIPTION

    Permission on the VMHost entity is created for the specified User Id with the specified Role.
    #>
    [DscProperty(Mandatory)]
    [string] $Role

    <#
    .DESCRIPTION

    Specifies the Password for the host account.
    #>
    [DscProperty()]
    [string] $AccountPassword

    <#
    .DESCRIPTION

    Provides a description for the host account. The maximum length of the text is 255 symbols.
    #>
    [DscProperty()]
    [string] $Description

    hidden [string] $ESXiProductId = 'embeddedEsx'
    hidden [string] $AccountPasswordParameterName = 'Password'
    hidden [string] $DescriptionParameterName = 'Description'

    [void] Set() {
        try {
            $this.ConnectVIServer()
            $this.EnsureConnectionIsESXi()
            $vmHostAccount = $this.GetVMHostAccount()

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $vmHostAccount) {
                    $this.AddVMHostAccount()
                }
                else {
                    $this.UpdateVMHostAccount($vmHostAccount)
                }
            }
            else {
                if ($null -ne $vmHostAccount) {
                    $this.RemoveVMHostAccount($vmHostAccount)
                }
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()
            $this.EnsureConnectionIsESXi()
            $vmHostAccount = $this.GetVMHostAccount()

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $vmHostAccount) {
                    return $false
                }

                return !$this.ShouldUpdateVMHostAccount($vmHostAccount) -or !$this.ShouldCreateAcountPermission($vmHostAccount)
            }
            else {
                return ($null -eq $vmHostAccount)
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostAccount] Get() {
        try {
            $result = [VMHostAccount]::new()
            $result.Server = $this.Server

            $this.ConnectVIServer()
            $this.EnsureConnectionIsESXi()
            $vmHostAccount = $this.GetVMHostAccount()

            $this.PopulateResult($vmHostAccount, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Checks if the Connection is directly to an ESXi host and if not, throws an exception.
    #>
    [void] EnsureConnectionIsESXi() {
        if ($this.Connection.ProductLine -ne $this.ESXiProductId) {
            throw 'The Resource operations are only supported when connection is directly to an ESXi host.'
        }
    }

    <#
    .DESCRIPTION

    Returns the VMHost Account if it exists, otherwise returns $null.
    #>
    [PSObject] GetVMHostAccount() {
        return Get-VMHostAccount -Server $this.Connection -Id $this.Id -ErrorAction SilentlyContinue
    }

    <#
    .DESCRIPTION

    Checks if a new Permission with the passed Role needs to be created for the specified VMHost Account.
    #>
    [bool] ShouldCreateAcountPermission($vmHostAccount) {
        $existingPermission = Get-VIPermission -Server $this.Connection -Entity $this.Server -Principal $vmHostAccount -ErrorAction SilentlyContinue

        return ($null -eq $existingPermission)
    }

    <#
    .DESCRIPTION

    Checks if the VMHost Account should be updated.
    #>
    [bool] ShouldUpdateVMHostAccount($vmHostAccount) {
        <#
        If the Account Password is passed, we should check if we can connect to the ESXi host with the passed Id and Password.
        If we can connect to the host it means that the password is in the desired state so we should close the connection and
        continue checking the other passed properties. If we cannot connect to the host it means that
        the desired Password is not equal to the current Password of the Account.
        #>
        if ($null -ne $this.AccountPassword) {
            $hostConnection = Connect-VIServer -Server $this.Server -User $this.Id -Password $this.AccountPassword -ErrorAction SilentlyContinue

            if ($null -eq $hostConnection) {
                return $true
            }
            else {
                Disconnect-VIServer -Server $hostConnection -Confirm:$false
            }
        }

        return ($null -ne $this.Description -and $this.Description -ne $vmHostAccount.Description)
    }

    <#
    .DESCRIPTION

    Populates the parameters for the New-VMHostAccount and Set-VMHostAccount cmdlets.
    #>
    [void] PopulateVMHostAccountParams($vmHostAccountParams, $parameter, $desiredValue) {
        if ($null -ne $desiredValue) {
            $vmHostAccountParams.$parameter = $desiredValue
        }
    }

    <#
    .DESCRIPTION

    Returns the populated VMHost Account parameters.
    #>
    [hashtable] GetVMHostAccountParams() {
        $vmHostAccountParams = @{}

        $vmHostAccountParams.Server = $this.Connection
        $vmHostAccountParams.Confirm = $false
        $vmHostAccountParams.ErrorAction = 'Stop'

        $this.PopulateVMHostAccountParams($vmHostAccountParams, $this.AccountPasswordParameterName, $this.AccountPassword)
        $this.PopulateVMHostAccountParams($vmHostAccountParams, $this.DescriptionParameterName, $this.Description)

        return $vmHostAccountParams
    }

    <#
    .DESCRIPTION

    Creates a new Permission with the passed Role for the specified VMHost Account.
    #>
    [void] CreateAccountPermission($vmHostAccount) {
        $accountRole = Get-VIRole -Server $this.Connection -Name $this.Role -ErrorAction SilentlyContinue
        if ($null -eq $accountRole) {
            throw "The passed role $($this.Role) is not present on the server."
        }

        try {
            New-VIPermission -Server $this.Connection -Entity $this.Server -Principal $vmHostAccount -Role $accountRole -ErrorAction Stop
        }
        catch {
            throw "Cannot assign role $($this.Role) to account $($vmHostAccount.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Creates a new VMHost Account with the specified properties.
    #>
    [void] AddVMHostAccount() {
        $vmHostAccountParams = $this.GetVMHostAccountParams()
        $vmHostAccountParams.Id = $this.Id

        $vmHostAccount = $null

        try {
            $vmHostAccount = New-VMHostAccount @vmHostAccountParams
        }
        catch {
            throw "Cannot create VMHost Account $($this.Id). For more information: $($_.Exception.Message)"
        }

        $this.CreateAccountPermission($vmHostAccount)
    }

    <#
    .DESCRIPTION

    Updates the VMHost Account with the specified properties.
    #>
    [void] UpdateVMHostAccount($vmHostAccount) {
        $vmHostAccountParams = $this.GetVMHostAccountParams()

        try {
            $vmHostAccount | Set-VMHostAccount @vmHostAccountParams
        }
        catch {
            throw "Cannot update VMHost Account $($this.Id). For more information: $($_.Exception.Message)"
        }

        if ($this.ShouldCreateAcountPermission($vmHostAccount)) {
            $this.CreateAccountPermission($vmHostAccount)
        }
    }

    <#
    .DESCRIPTION

    Removes the VMHost Account.
    #>
    [void] RemoveVMHostAccount($vmHostAccount) {
        try {
            $vmHostAccount | Remove-VMHostAccount -Server $this.Connection -Confirm:$false -ErrorAction Stop
        }
        catch {
            throw "Cannot remove VMHost Account $($this.Id). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the VMHost Account from the server.
    #>
    [void] PopulateResult($vmHostAccount, $result) {
        if ($null -ne $vmHostAccount) {
            $permission = Get-VIPermission -Server $this.Connection -Entity $this.Server -Principal $vmHostAccount -ErrorAction SilentlyContinue

            $result.Id = $vmHostAccount.Id
            $result.Ensure = [Ensure]::Present
            $result.Role = $permission.Role
            $result.Description = $vmHostAccount.Description
        }
        else {
            $result.Id = $this.Id
            $result.Ensure = [Ensure]::Absent
            $result.Role = $this.Role
            $result.Description = $this.Description
        }
    }
}

[DscResource()]
class VMHostAdvancedSettings : VMHostBaseDSC {
    <#
    .DESCRIPTION

    Hashtable containing the advanced settings of the specified VMHost, where
    each key-value pair represents one advanced setting - the key is the name of the
    setting and the value is the desired value for the setting.
    #>
    [DscProperty(Mandatory)]
    [hashtable] $AdvancedSettings

    [void] Set() {
    	try {
            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()

            $this.UpdateVMHostAdvancedSettings($vmHost)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
    	try {
            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()

            return !$this.ShouldUpdateVMHostAdvancedSettings($vmHost)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostAdvancedSettings] Get() {
        try {
            $result = [VMHostAdvancedSettings]::new()
            $result.Server = $this.Server

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()

            $result.Name = $vmHost.Name
            $result.AdvancedSettings = @{}

            $this.PopulateResult($vmHost, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Advanced Settings of the specified VMHost from the server.
    #>
    [array] GetAdvancedSettings($vmHost) {
        try {
            $retrievedAdvancedSettings = Get-AdvancedSetting -Server $this.Connection -Entity $vmHost -ErrorAction Stop
            return $retrievedAdvancedSettings
        }
        catch {
            throw "Could not retrieve the Advanced Settings of VMHost $($vmHost.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Returns the Advanced Setting if it is present in the retrieved Advanced Settings from the server.
    Otherwise returns $null.
    #>
    [PSObject] GetAdvancedSetting($retrievedAdvancedSettings, $advancedSettingName, $vmHostName) {
        $advancedSetting = $retrievedAdvancedSettings | Where-Object { $_.Name -eq $advancedSettingName }
        if ($null -eq $advancedSetting) {
            <#
            Here 'Write-Warning' is used instead of 'throw' to ensure that the execution will not stop
            if an invalid Advanced Setting is present in the passed hashtable and in the same time to
            provide an information to the user that invalid data is passed.
            #>
            Write-WarningLog -Message "Advanced Setting {0} does not exist for VMHost {1} and will be ignored." -Arguments @($advancedSettingName, $vmHostName)
        }

        return $advancedSetting
    }

    <#
    .DESCRIPTION

    Converts the desired value of the Advanced Setting from the hashtable to the correct type of the value
    from the server. Works only for primitive types.
    #>
    [object] ConvertAdvancedSettingDesiredValueToCorrectType($advancedSetting) {
        $advancedSettingDesiredValue = $null
        if ($advancedSetting.Value -is [bool]) {
            # For bool values the '-as' operator returns 'True' for both 'true' and 'false' strings so specific conversion is needed.
            $advancedSettingDesiredValue = [System.Convert]::ToBoolean($this.AdvancedSettings[$advancedSetting.Name])
        }
        else {
            $advancedSettingDesiredValue = $this.AdvancedSettings[$advancedSetting.Name] -as $advancedSetting.Value.GetType()
        }

        return $advancedSettingDesiredValue
    }

    <#
    .DESCRIPTION

    Checks if the Advanced Setting should be updated depending on the passed desired value.
    #>
    [bool] ShouldUpdateVMHostAdvancedSetting($advancedSetting) {
        <#
        Each element in the hashtable is of type MSFT_KeyValuePair where the value is a string.
        So before comparison the value needs to be converted to its original type which can be
        retrieved from its server value.
        #>
        $advancedSettingDesiredValue = $this.ConvertAdvancedSettingDesiredValueToCorrectType($advancedSetting)

        return ($advancedSettingDesiredValue -ne $advancedSetting.Value)
    }

    <#
    .DESCRIPTION

    Checks if any of the Advanced Settings present in the hashtable need to be updated.
    #>
    [bool] ShouldUpdateVMHostAdvancedSettings($vmHost) {
        $retrievedAdvancedSettings = $this.GetAdvancedSettings($vmHost)

        foreach ($advancedSettingName in $this.AdvancedSettings.Keys) {
            $advancedSetting = $this.GetAdvancedSetting($retrievedAdvancedSettings, $advancedSettingName, $vmHost.Name)

            if ($null -ne $advancedSetting -and $this.ShouldUpdateVMHostAdvancedSetting($advancedSetting)) {
                return $true
            }
        }

        return $false
    }

    <#
    .DESCRIPTION

    Returns the Advanced Option Manager of the specified VMHost.
    #>
    [PSObject] GetVMHostAdvancedOptionManager($vmHost) {
        try {
            $vmHostAdvancedOptionManager = Get-View -Server $this.Connection -Id $vmHost.ExtensionData.ConfigManager.AdvancedOption -ErrorAction Stop
            return $vmHostAdvancedOptionManager
        }
        catch {
            throw "VMHost Advanced Option Manager could not be retrieved. For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Performs an update on these Advanced Settings that are present in the hashtable and
    need to be updated.
    #>
    [void] UpdateVMHostAdvancedSettings($vmHost) {
        $retrievedAdvancedSettings = $this.GetAdvancedSettings($vmHost)
        $vmHostAdvancedOptionManager = $this.GetVMHostAdvancedOptionManager($vmHost)
        $options = @()

        foreach ($advancedSettingName in $this.AdvancedSettings.Keys) {
            $advancedSetting = $this.GetAdvancedSetting($retrievedAdvancedSettings, $advancedSettingName, $vmHost.Name)

            if ($null -ne $advancedSetting -and $this.ShouldUpdateVMHostAdvancedSetting($advancedSetting)) {
                <#
                Each element in the hashtable is of type MSFT_KeyValuePair where the value is a string.
                So before setting the value of the option, we need to convert it to its original type which can be
                retrieved from its server value.
                #>
                $option = New-Object VMware.Vim.OptionValue
                $option.Key = $advancedSettingName
                $option.Value = $this.ConvertAdvancedSettingDesiredValueToCorrectType($advancedSetting)

                $options += $option
            }
        }

        if ($options.Length -eq 0) {
            return
        }

        try {
            Update-VMHostAdvancedSettings -VMHostAdvancedOptionManager $vmHostAdvancedOptionManager -Options $options
        }
        catch {
            throw "The Advanced Settings Update operation failed with the following error: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the Advanced Settings from the server.
    #>
    [void] PopulateResult($vmHost, $result) {
        $retrievedAdvancedSettings = $this.GetAdvancedSettings($vmHost)

        foreach ($advancedSettingName in $this.AdvancedSettings.Keys) {
            $advancedSetting = $this.GetAdvancedSetting($retrievedAdvancedSettings, $advancedSettingName, $vmHost.Name)

            if ($null -ne $advancedSetting) {
                <#
                The LCM converts the hashtable to MSFT_KeyValuePair class which has the following properties:
                Key of type string and Value of type string. So the value of the Advanced Setting from the server
                should be converted to string to avoid an error to be thrown. This will only work for primitive types
                like bool, int, long and so on. If a non-primitive type is introduced for Advanced Setting, invalid result
                will be returned from the conversion.
                #>
                $result.AdvancedSettings[$advancedSettingName] = $advancedSetting.Value.ToString()
            }
        }
    }
}

[DscResource()]
class VMHostAgentVM : VMHostBaseDSC {
    <#
    .DESCRIPTION

    Specifies the Datastore used for deploying Agent VMs on this host.
    #>
    [DscProperty()]
    [string] $AgentVmDatastore

    <#
    .DESCRIPTION

    Specifies the Management Network for Agent VMs on this host.
    #>
    [DscProperty()]
    [string] $AgentVmNetwork

    hidden [string] $AgentVmDatastoreName = 'AgentVmDatastore'
    hidden [string] $AgentVmNetworkName = 'AgentVmNetwork'
    hidden [string] $GetAgentVmDatastoreAsViewObjectMethodName = 'GetAgentVmDatastoreAsViewObject'
    hidden [string] $GetAgentVmNetworkAsViewObjectMethodName = 'GetAgentVmNetworkAsViewObject'

    [void] Set() {
        try {
            $this.ConnectVIServer()

            # vCenter Connection is needed to retrieve the EsxAgentHostManager.
            $this.EnsureConnectionIsvCenter()

            $vmHost = $this.GetVMHost()
            $esxAgentHostManager = $this.GetEsxAgentHostManager($vmHost)

            $this.UpdateAgentVMConfiguration($vmHost, $esxAgentHostManager)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()

            # vCenter Connection is needed to retrieve the EsxAgentHostManager.
            $this.EnsureConnectionIsvCenter()

            $vmHost = $this.GetVMHost()
            $esxAgentHostManager = $this.GetEsxAgentHostManager($vmHost)

            return !$this.ShouldUpdateAgentVMConfiguration($esxAgentHostManager)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostAgentVM] Get() {
        try {
            $result = [VMHostAgentVM]::new()
            $result.Server = $this.Server

            $this.ConnectVIServer()

            # vCenter Connection is needed to retrieve the EsxAgentHostManager.
            $this.EnsureConnectionIsvCenter()

            $vmHost = $this.GetVMHost()
            $esxAgentHostManager = $this.GetEsxAgentHostManager($vmHost)

            $result.Name = $vmHost.Name
            $this.PopulateResult($esxAgentHostManager, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Retrieves the EsxAgentHostManager of the specified VMHost from the server.
    #>
    [PSObject] GetEsxAgentHostManager($vmHost) {
        try {
            $esxAgentHostManager = Get-View -Server $this.Connection -Id $vmHost.ExtensionData.ConfigManager.EsxAgentHostManager -ErrorAction Stop
            return $esxAgentHostManager
        }
        catch {
            throw "Could not retrieve the EsxAgentHostManager of VMHost $($vmHost.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Retrieves the AgentVM Datastore of the EsxAgentHostManager of the specified VMHost from the server as a View Object.
    #>
    [PSObject] GetAgentVmDatastoreAsViewObject($esxAgentHostManager) {
        try {
            $datastoreAsViewObject = Get-View -Server $this.Connection -Id $esxAgentHostManager.ConfigInfo.AgentVmDatastore -ErrorAction Stop
            return $datastoreAsViewObject
        }
        catch {
            throw "Could not retrieve the AgentVM Datastore of the EsxAgentHostManager. For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Retrieves the AgentVM Network of the EsxAgentHostManager of the specified VMHost from the server as a View Object.
    #>
    [PSObject] GetAgentVmNetworkAsViewObject($esxAgentHostManager) {
        try {
            $networkAsViewObject = Get-View -Server $this.Connection -Id $esxAgentHostManager.ConfigInfo.AgentVmNetwork -ErrorAction Stop
            return $networkAsViewObject
        }
        catch {
            throw "Could not retrieve the AgentVM Network of the EsxAgentHostManager. For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Checks if the AgentVM Setting needs to be updated with the desired value.
    #>
    [bool] ShouldUpdateAgentVMSetting($esxAgentHostManager, $agentVmSetting, $agentVmSettingName, $getAgentVmSettingAsViewObjectMethodName) {
        if ($null -eq $agentVmSetting) {
            if ($null -ne $esxAgentHostManager.ConfigInfo.$agentVmSettingName) {
                return $true
            }
        }
        else {
            if ($null -eq $esxAgentHostManager.ConfigInfo.$agentVmSettingName) {
                return $true
            }
            else {
                $agentVmSettingAsViewObject = $this.$getAgentVmSettingAsViewObjectMethodName($esxAgentHostManager)
                if ($agentVmSetting -ne $agentVmSettingAsViewObject.Name) {
                    return $true
                }
            }
        }

        return $false
    }

    <#
    .DESCRIPTION

    Checks if the AgentVM Configuration needs to be updated with the desired values.
    #>
    [bool] ShouldUpdateAgentVMConfiguration($esxAgentHostManager) {
        if ($this.ShouldUpdateAgentVMSetting($esxAgentHostManager, $this.AgentVmDatastore, $this.AgentVmDatastoreName, $this.GetAgentVmDatastoreAsViewObjectMethodName)) {
            return $true
        }
        elseif ($this.ShouldUpdateAgentVMSetting($esxAgentHostManager, $this.AgentVmNetwork, $this.AgentVmNetworkName, $this.GetAgentVmNetworkAsViewObjectMethodName)) {
            return $true
        }
        else {
            return $false
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Datastore for AgentVM from the server if it exists.
    If the Datastore name is not passed it returns $null and if the Datastore does not exist
    it throws an exception.
    #>
    [PSObject] GetDatastoreForAgentVM($vmHost) {
        if ($null -eq $this.AgentVmDatastore) {
            return $null
        }

        try {
            $datastore = Get-Datastore -Server $this.Connection -Name $this.AgentVmDatastore -RelatedObject $vmHost -ErrorAction Stop
            return $datastore.ExtensionData.MoRef
        }
        catch {
            throw "Could not retrieve Datastore $($this.AgentVmDatastore) for VMHost $($vmHost.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Network for AgentVM from the specified VMHost if it exists.
    If the Network name is not passed it returns $null and if the Network does not exist
    it throws an exception.
    #>
    [PSObject] GetNetworkForAgentVM($vmHost) {
        if ($null -eq $this.AgentVmNetwork) {
            return $null
        }

        $foundNetwork = $null
        $networks = $vmHost.ExtensionData.Network

        foreach ($network in $networks) {
            $networkAsViewObject = Get-View -Server $this.Connection -Id $network
            if ($this.AgentVmNetwork -eq $networkAsViewObject.Name) {
                $foundNetwork = $network
                break
            }
        }

        if ($null -eq $foundNetwork) {
            throw "Could not find Network $($this.AgentVmNetwork) for VMHost $($vmHost.Name)."
        }

        return $foundNetwork
    }

    <#
    .DESCRIPTION

    Performs an update on the AgentVM Configuration of the specified VMHost by setting the Datastore and Network.
    #>
    [void] UpdateAgentVMConfiguration($vmHost, $esxAgentHostManager) {
        $datastore = $this.GetDatastoreForAgentVM($vmHost)
        $network = $this.GetNetworkForAgentVM($vmHost)

        $configInfo = New-Object VMware.Vim.HostEsxAgentHostManagerConfigInfo

        $configInfo.AgentVmDatastore = $datastore
        $configInfo.AgentVmNetwork = $network

        try {
            Update-AgentVMConfiguration -EsxAgentHostManager $esxAgentHostManager -EsxAgentHostManagerConfigInfo $configInfo
        }
        catch {
            throw "The AgentVM Configuration of VMHost $($vmHost.Name) could not be updated: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Returns the AgentVM Setting value from the Configuration on the server.
    #>
    [string] PopulateAgentVmSetting($esxAgentHostManager, $agentVmSettingName, $getAgentVmSettingAsViewObjectMethodName) {
        if ($null -eq $esxAgentHostManager.ConfigInfo.$agentVmSettingName) {
            return $null
        }
        else {
            $agentVmSettingAsViewObject = $this.$getAgentVmSettingAsViewObjectMethodName($esxAgentHostManager)
            return $agentVmSettingAsViewObject.Name
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the AgentVM Settings from the server.
    #>
    [void] PopulateResult($esxAgentHostManager, $result) {
        $result.AgentVmDatastore = $this.PopulateAgentVmSetting($esxAgentHostManager, $this.AgentVmDatastoreName, $this.GetAgentVmDatastoreAsViewObjectMethodName)
        $result.AgentVmNetwork = $this.PopulateAgentVmSetting($esxAgentHostManager, $this.AgentVmNetworkName, $this.GetAgentVmNetworkAsViewObjectMethodName)
    }
}

[DscResource()]
class VMHostCache : VMHostBaseDSC {
    <#
    .DESCRIPTION

    Specifies the Datastore used for swap performance enhancement.
    #>
    [DscProperty(Key)]
    [string] $Datastore

    <#
    .DESCRIPTION

    Specifies the space to allocate on the specified Datastore to implement swap performance enhancements, in GB.
    This value should be less than or equal to the free space capacity of the Datastore.
    #>
    [DscProperty(Mandatory)]
    [double] $SwapSizeGB

    [void] Set() {
        try {
            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()

            $this.UpdateHostCacheConfiguration($vmHost)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()

            return !$this.ShouldUpdateHostCacheConfiguration($vmHost)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostCache] Get() {
        try {
            $result = [VMHostCache]::new()
            $result.Server = $this.Server

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()

            $result.Name = $vmHost.Name
            $this.PopulateResult($vmHost, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    hidden [int] $NumberOfFractionalDigits = 3

    <#
    .DESCRIPTION

    Retrieves the Cache Configuration Manager of the specified VMHost from the server.
    #>
    [PSObject] GetVMHostCacheConfigurationManager($vmHost) {
        try {
            $vmHostCacheConfigurationManager = Get-View -Server $this.Connection -Id $vmHost.ExtensionData.ConfigManager.CacheConfigurationManager -ErrorAction Stop
            return $vmHostCacheConfigurationManager
        }
        catch {
            throw "Could not retrieve the Cache Configuration Manager of VMHost $($vmHost.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Datastore for Host Cache Configuration from the server if it exists.
    If the Datastore does not exist, it throws an exception.
    #>
    [PSObject] GetDatastore($vmHost) {
        try {
            $foundDatastore = Get-Datastore -Server $this.Connection -Name $this.Datastore -RelatedObject $vmHost -ErrorAction Stop
            return $foundDatastore
        }
        catch {
            throw "Could not retrieve Datastore $($this.Datastore) for VMHost $($this.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Cache Info for the specified Datastore from the Host Cache Configuration.
    If the Datastore is not enabled for swap performance, it throws an exception.
    #>
    [PSObject] GetDatastoreCacheInfo($vmHostCacheConfigurationManager, $foundDatastore) {
        $datastoreCacheInfo = $vmHostCacheConfigurationManager.CacheConfigurationInfo | Where-Object { $_.Key -eq $foundDatastore.ExtensionData.MoRef }
        if ($null -eq $datastoreCacheInfo) {
            throw "Datastore $($foundDatastore.Name) could not be found in enabled for swap performance Datastores."
        }

        return $datastoreCacheInfo
    }

    <#
    .DESCRIPTION

    Converts the passed MB value to GB value by rounding it down with 3 fractional digits in the return value.
    #>
    [double] ConvertMBValueToGBValue($mbValue) {
        return [Math]::Round($mbValue * 1MB / 1GB, $this.NumberOfFractionalDigits)
    }

    <#
    .DESCRIPTION

    Converts the passed GB value to MB value by rounding it down.
    #>
    [long] ConvertGBValueToMBValue($gbValue) {
        return [long] [Math]::Round($gbValue * 1GB / 1MB)
    }

    <#
    .DESCRIPTION

    Checks if the Host Cache Configuration should be updated for the specified VMHost by checking
    if the current Swap Size is equal to the desired one for the specified Datastore.
    #>
    [bool] ShouldUpdateHostCacheConfiguration($vmHost) {
        $vmHostCacheConfigurationManager = $this.GetVMHostCacheConfigurationManager($vmHost)
        $foundDatastore = $this.GetDatastore($vmHost)
        $datastoreCacheInfo = $this.GetDatastoreCacheInfo($vmHostCacheConfigurationManager, $foundDatastore)

        return ($this.SwapSizeGB -ne $this.ConvertMBValueToGBValue($datastoreCacheInfo.SwapSize))
    }

    <#
    .DESCRIPTION

    Performs an update on the Host Cache Configuration of the specified VMHost by changing the Swap Size for the
    specified Datastore.
    #>
    [void] UpdateHostCacheConfiguration($vmHost) {
        $vmHostCacheConfigurationManager = $this.GetVMHostCacheConfigurationManager($vmHost)
        $foundDatastore = $this.GetDatastore($vmHost)

        if ($this.SwapSizeGB -lt 0) {
            throw "The passed Swap Size $($this.SwapSizeGB) is less than zero."
        }

        if ($this.SwapSizeGB -gt $foundDatastore.FreeSpaceGB) {
            throw "The passed Swap Size $($this.SwapSizeGB) is larger than the free space of the Datastore $($foundDatastore.Name)."
        }

        $hostCacheConfigurationSpec = New-Object VMware.Vim.HostCacheConfigurationSpec
        $hostCacheConfigurationSpec.Datastore = $foundDatastore.ExtensionData.MoRef
        $hostCacheConfigurationSpec.SwapSize = $this.ConvertGBValueToMBValue($this.SwapSizeGB)

        $hostCacheConfigurationResult = Update-HostCacheConfiguration -VMHostCacheConfigurationManager $vmHostCacheConfigurationManager -Spec $hostCacheConfigurationSpec
        $hostCacheConfigurationTask = Get-Task -Server $this.Connection -Id $hostCacheConfigurationResult

        try {
            Wait-Task -Task $hostCacheConfigurationTask -ErrorAction Stop
        }
        catch {
            throw "An error occured while updating Cache Configuration for VMHost $($this.Name). For more information: $($_.Exception.Message)"
        }

        Write-VerboseLog -Message "Cache Configuration was successfully updated for VMHost {0}." -Arguments @($this.Name)
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the Host Cache Configuration from the server.
    #>
    [void] PopulateResult($vmHost, $result) {
        $vmHostCacheConfigurationManager = $this.GetVMHostCacheConfigurationManager($vmHost)
        $foundDatastore = $this.GetDatastore($vmHost)
        $datastoreCacheInfo = $this.GetDatastoreCacheInfo($vmHostCacheConfigurationManager, $foundDatastore)

        $result.Datastore = $foundDatastore.Name
        $result.SwapSizeGB = $this.ConvertMBValueToGBValue($datastoreCacheInfo.SwapSize)
    }
}

[DscResource()]
class VMHostDnsSettings : VMHostBaseDSC {
    <#
    .DESCRIPTION


    List of domain name or IP address of the DNS Servers.
    #>
    [DscProperty()]
    [string[]] $Address

    <#
    .DESCRIPTION

    Indicates whether DHCP is used to determine DNS configuration.
    #>
    [DscProperty(Mandatory)]
    [bool] $Dhcp

    <#
    .DESCRIPTION

    Domain Name portion of the DNS name. For example, "vmware.com".
    #>
    [DscProperty(Mandatory)]
    [string] $DomainName

    <#
    .DESCRIPTION

    Host Name portion of DNS name. For example, "esx01".
    #>
    [DscProperty(Mandatory)]
    [string] $HostName

    <#
    .DESCRIPTION

    Desired value for the VMHost DNS Ipv6VirtualNicDevice.
    #>
    [DscProperty()]
    [string] $Ipv6VirtualNicDevice

    <#
    .DESCRIPTION

    Domain in which to search for hosts, placed in order of preference.
    #>
    [DscProperty()]
    [string[]] $SearchDomain

    <#
    .DESCRIPTION

    Desired value for the VMHost DNS VirtualNicDevice.
    #>
    [DscProperty()]
    [string] $VirtualNicDevice

    [void] Set() {
        try {
            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()

            $this.UpdateDns($vmHost)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $vmHostDnsConfig = $vmHost.ExtensionData.Config.Network.DnsConfig

            return $this.Equals($vmHostDnsConfig)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostDnsSettings] Get() {
        try {
            $result = [VMHostDnsSettings]::new()

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $vmHostDnsConfig = $vmHost.ExtensionData.Config.Network.DnsConfig

            $result.Name = $vmHost.Name
            $result.Server = $this.Server
            $result.Address = $vmHostDnsConfig.Address
            $result.Dhcp = $vmHostDnsConfig.Dhcp
            $result.DomainName = $vmHostDnsConfig.DomainName
            $result.HostName = $vmHostDnsConfig.HostName
            $result.Ipv6VirtualNicDevice = $vmHostDnsConfig.Ipv6VirtualNicDevice
            $result.SearchDomain = $vmHostDnsConfig.SearchDomain
            $result.VirtualNicDevice = $vmHostDnsConfig.VirtualNicDevice

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if the desired DNS array property is equal to the current DNS array property.
    #>
    [bool] AreDnsArrayPropertiesEqual($desiredArrayPropertyValue, $currentArrayPropertyValue) {
        $valuesToAdd = $desiredArrayPropertyValue | Where-Object { $currentArrayPropertyValue -NotContains $_ }
        $valuesToRemove = $currentArrayPropertyValue | Where-Object { $desiredArrayPropertyValue -NotContains $_ }

        return ($null -eq $valuesToAdd -and $null -eq $valuesToRemove)
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if the desired DNS optional value is equal to the current DNS value from the server.
    #>
    [bool] AreDnsOptionalPropertiesEqual($desiredPropertyValue, $currentPropertyValue) {
        if ([string]::IsNullOrEmpty($desiredPropertyValue) -and [string]::IsNullOrEmpty($currentPropertyValue)) {
            return $true
        }

        return $desiredPropertyValue -eq $currentPropertyValue
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if the current DNS Config is equal to the Desired DNS Config.
    #>
    [bool] Equals($vmHostDnsConfig) {
        # Checks if desired Mandatory values are equal to current values from server.
        if ($this.Dhcp -ne $vmHostDnsConfig.Dhcp -or $this.DomainName -ne $vmHostDnsConfig.DomainName -or $this.HostName -ne $vmHostDnsConfig.HostName) {
            return $false
        }

        if (!$this.AreDnsArrayPropertiesEqual($this.Address, $vmHostDnsConfig.Address) -or !$this.AreDnsArrayPropertiesEqual($this.SearchDomain, $vmHostDnsConfig.SearchDomain)) {
            return $false
        }

        if (!$this.AreDnsOptionalPropertiesEqual($this.Ipv6VirtualNicDevice, $vmHostDnsConfig.Ipv6VirtualNicDevice) -or !$this.AreDnsOptionalPropertiesEqual($this.VirtualNicDevice, $vmHostDnsConfig.VirtualNicDevice)) {
            return $false
        }

        return $true
    }

    <#
    .DESCRIPTION

    Updates the DNS Config of the VMHost with the Desired DNS Config.
    #>
    [void] UpdateDns($vmHost) {
        $dnsConfigArgs = @{
            Address = $this.Address
            Dhcp = $this.Dhcp
            DomainName = $this.DomainName
            HostName = $this.HostName
            Ipv6VirtualNicDevice = $this.Ipv6VirtualNicDevice
            SearchDomain = $this.SearchDomain
            VirtualNicDevice = $this.VirtualNicDevice
        }

        $dnsConfig = New-DNSConfig @dnsConfigArgs
        $networkSystem = Get-View -Server $this.Connection -Id $vmHost.ExtensionData.ConfigManager.NetworkSystem

        try {
            Update-DNSConfig -NetworkSystem $networkSystem -DnsConfig $dnsConfig
        }
        catch {
            throw "The DNS Config could not be updated: $($_.Exception.Message)"
        }
    }
}

[DscResource()]
class VMHostNtpSettings : VMHostBaseDSC {
    <#
    .DESCRIPTION

    List of domain name or IP address of the desired NTP Servers.
    #>
    [DscProperty()]
    [string[]] $NtpServer

    <#
    .DESCRIPTION

    Desired Policy of the VMHost 'ntpd' service activation.
    #>
    [DscProperty()]
    [ServicePolicy] $NtpServicePolicy

    hidden [string] $ServiceId = "ntpd"

    [void] Set() {
        try {
            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()

            $this.UpdateVMHostNtpServer($vmHost)
            $this.UpdateVMHostNtpServicePolicy($vmHost)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $vmHostNtpConfig = $vmHost.ExtensionData.Config.DateTimeInfo.NtpConfig

            $shouldUpdateVMHostNtpServer = $this.ShouldUpdateVMHostNtpServer($vmHostNtpConfig)
            if ($shouldUpdateVMHostNtpServer) {
                return $false
            }

            $vmHostServices = $vmHost.ExtensionData.Config.Service
            $shouldUpdateVMHostNtpServicePolicy = $this.ShouldUpdateVMHostNtpServicePolicy($vmHostServices)
            if ($shouldUpdateVMHostNtpServicePolicy) {
                return $false
            }

            return $true
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostNtpSettings] Get() {
        try {
            $result = [VMHostNtpSettings]::new()

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $vmHostNtpConfig = $vmHost.ExtensionData.Config.DateTimeInfo.NtpConfig
            $vmHostServices = $vmHost.ExtensionData.Config.Service
            $vmHostNtpService = $vmHostServices.Service | Where-Object { $_.Key -eq $this.ServiceId }

            $result.Name = $vmHost.Name
            $result.Server = $this.Server
            $result.NtpServer = $vmHostNtpConfig.Server
            $result.NtpServicePolicy = $vmHostNtpService.Policy

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if the VMHost NTP Server should be updated.
    #>
    [bool] ShouldUpdateVMHostNtpServer($vmHostNtpConfig) {
        $desiredVMHostNtpServer = $this.NtpServer
        $currentVMHostNtpServer = $vmHostNtpConfig.Server

        if ($null -eq $desiredVMHostNtpServer) {
            # The property is not specified.
            return $false
        }
        elseif ($desiredVMHostNtpServer.Length -eq 0 -and $currentVMHostNtpServer.Length -ne 0) {
            # Empty array specified as desired, but current is not an empty array, so update VMHost NTP Server.
            return $true
        }
        else {
            $ntpServerToAdd = $desiredVMHostNtpServer | Where-Object { $currentVMHostNtpServer -NotContains $_ }
            $ntpServerToRemove = $currentVMHostNtpServer | Where-Object { $desiredVMHostNtpServer -NotContains $_ }

            if ($null -ne $ntpServerToAdd -or $null -ne $ntpServerToRemove) {
                <#
                The currentVMHostNtpServer does not contain at least one element from desiredVMHostNtpServer or
                the desiredVMHostNtpServer is a subset of the currentVMHostNtpServer. In both cases
                we should update VMHost NTP Server.
                #>
                return $true
            }

            # No need to update VMHost NTP Server.
            return $false
        }
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if the VMHost 'ntpd' Service Policy should be updated.
    #>
    [bool] ShouldUpdateVMHostNtpServicePolicy($vmHostServices) {
        if ($this.NtpServicePolicy -eq [ServicePolicy]::Unset) {
            # The property is not specified.
            return $false
        }

        $vmHostNtpService = $vmHostServices.Service | Where-Object { $_.Key -eq $this.ServiceId }

        return $this.NtpServicePolicy -ne $vmHostNtpService.Policy
    }

    <#
    .DESCRIPTION

    Updates the VMHost NTP Server with the desired NTP Server array.
    #>
    [void] UpdateVMHostNtpServer($vmHost) {
        $vmHostNtpConfig = $vmHost.ExtensionData.Config.DateTimeInfo.NtpConfig
        $shouldUpdateVMHostNtpServer = $this.ShouldUpdateVMHostNtpServer($vmHostNtpConfig)

        if (!$shouldUpdateVMHostNtpServer) {
            return
        }

        $dateTimeConfig = New-DateTimeConfig -NtpServer $this.NtpServer
        $dateTimeSystem = Get-View -Server $this.Connection -Id $vmHost.ExtensionData.ConfigManager.DateTimeSystem

        Update-DateTimeConfig -DateTimeSystem $dateTimeSystem -DateTimeConfig $dateTimeConfig
    }

    <#
    .DESCRIPTION

    Updates the VMHost 'ntpd' Service Policy with the desired Service Policy.
    #>
    [void] UpdateVMHostNtpServicePolicy($vmHost) {
        $vmHostService = $vmHost.ExtensionData.Config.Service
        $shouldUpdateVMHostNtpServicePolicy = $this.ShouldUpdateVMHostNtpServicePolicy($vmHostService)
        if (!$shouldUpdateVMHostNtpServicePolicy) {
            return
        }

        $serviceSystem = Get-View -Server $this.Connection -Id $vmHost.ExtensionData.ConfigManager.ServiceSystem
        Update-ServicePolicy -ServiceSystem $serviceSystem -ServiceId $this.ServiceId -ServicePolicyValue $this.NtpServicePolicy.ToString().ToLower()
    }
}

[DscResource()]
class VMHostPciPassthrough : VMHostBaseDSC {
    <#
    .DESCRIPTION

    Specifies the Id of the PCI Device, composed of "bus:slot.function".
    #>
    [DscProperty(Key)]
    [string] $Id

    <#
    .DESCRIPTION

    Specifies whether passThru has been configured for this device.
    #>
    [DscProperty(Mandatory)]
    [bool] $Enabled

    [void] Set() {
    	try {
            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $vmHostPciPassthruSystem = $this.GetVMHostPciPassthruSystem($vmHost)
            $pciDevice = $this.GetPCIDevice($vmHostPciPassthruSystem)

            $this.EnsurePCIDeviceIsPassthruCapable($pciDevice)
            $this.EnsureVMHostIsInMaintenanceMode($vmHost)

            $this.UpdatePciPassthruConfiguration($vmHostPciPassthruSystem)
            $this.RestartVMHost($vmHost)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
    	try {
            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $vmHostPciPassthruSystem = $this.GetVMHostPciPassthruSystem($vmHost)

            $pciDevice = $this.GetPCIDevice($vmHostPciPassthruSystem)
            $this.EnsurePCIDeviceIsPassthruCapable($pciDevice)

            return ($this.Enabled -eq $pciDevice.PassthruEnabled)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostPciPassthrough] Get() {
        try {
            $result = [VMHostPciPassthrough]::new()
            $result.Server = $this.Server

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $vmHostPciPassthruSystem = $this.GetVMHostPciPassthruSystem($vmHost)

            $pciDevice = $this.GetPCIDevice($vmHostPciPassthruSystem)
            $this.EnsurePCIDeviceIsPassthruCapable($pciDevice)

            $result.Name = $vmHost.Name
            $result.Id = $pciDevice.Id
            $result.Enabled = $pciDevice.PassthruEnabled

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Retrieves the PciPassthruSystem of the specified VMHost from the server.
    #>
    [PSObject] GetVMHostPciPassthruSystem($vmHost) {
        try {
            $vmHostPciPassthruSystem = Get-View -Server $this.Connection -Id $vmHost.ExtensionData.ConfigManager.PciPassthruSystem -ErrorAction Stop
            return $vmHostPciPassthruSystem
        }
        catch {
            throw "Could not retrieve the PciPassthruSystem of VMHost $($vmHost.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Retrieves the PCI Device with the specified Id from the server.
    #>
    [PSObject] GetPCIDevice($vmHostPciPassthruSystem) {
        $pciDevice = $vmHostPciPassthruSystem.PciPassthruInfo | Where-Object { $_.Id -eq $this.Id }
        if ($null -eq $pciDevice) {
            throw "The specified PCI Device $($this.Id) does not exist for VMHost $($this.Name)."
        }

        return $pciDevice
    }

    <#
    .DESCRIPTION

    Checks if the specified PCIDevice is Passthrough capable and if not, throws an exception.
    #>
    [void] EnsurePCIDeviceIsPassthruCapable($pciDevice) {
        if (!$pciDevice.PassthruCapable) {
            throw "Cannot configure PCI-Passthrough on incapable device $($pciDevice.Id)."
        }
    }

    <#
    .DESCRIPTION

    Performs an update on the specified PCI Device by changing its Passthru Enabled value.
    #>
    [void] UpdatePciPassthruConfiguration($vmHostPciPassthruSystem) {
        $vmHostPciPassthruConfig = New-Object VMware.Vim.HostPciPassthruConfig

        $vmHostPciPassthruConfig.Id = $this.Id
        $vmHostPciPassthruConfig.PassthruEnabled = $this.Enabled

        try {
            Update-PassthruConfig -VMHostPciPassthruSystem $vmHostPciPassthruSystem -VMHostPciPassthruConfig $vmHostPciPassthruConfig
        }
        catch {
            throw "The Update operation of PCI Device $($this.Id) failed with the following error: $($_.Exception.Message)"
        }
    }
}

[DscResource()]
class VMHostPowerPolicy : VMHostBaseDSC {
    <#
    .DESCRIPTION

    Specifies the Power Management Policy for the specified VMHost.
    #>
    [DscProperty(Mandatory)]
    [PowerPolicy] $PowerPolicy

    [void] Set() {
        try {
            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $vmHostPowerSystem = $this.GetVMHostPowerSystem($vmHost)

            $this.UpdatePowerPolicy($vmHostPowerSystem)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $currentPowerPolicy = $vmHost.ExtensionData.Config.PowerSystemInfo.CurrentPolicy

            return ($this.PowerPolicy -eq $currentPowerPolicy.Key)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostPowerPolicy] Get() {
        try {
            $result = [VMHostPowerPolicy]::new()
            $result.Server = $this.Server

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $currentPowerPolicy = $vmHost.ExtensionData.Config.PowerSystemInfo.CurrentPolicy

            $result.Name = $vmHost.Name
            $result.PowerPolicy = $currentPowerPolicy.Key

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Power System of the specified VMHost from the server.
    #>
    [PSObject] GetVMHostPowerSystem($vmHost) {
        try {
            $vmHostPowerSystem = Get-View -Server $this.Connection -Id $vmHost.ExtensionData.ConfigManager.PowerSystem -ErrorAction Stop
            return $vmHostPowerSystem
        }
        catch {
            throw "Could not retrieve the Power System of VMHost $($vmHost.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Performs an update on the Power Management Policy of the specified VMHost.
    #>
    [void] UpdatePowerPolicy($vmHostPowerSystem) {
        try {
            Update-PowerPolicy -VMHostPowerSystem $vmHostPowerSystem -PowerPolicy $this.PowerPolicy
        }
        catch {
            throw "The Power Policy of VMHost $($this.Name) could not be updated: $($_.Exception.Message)"
        }
    }
}

[DscResource()]
class VMHostSatpClaimRule : VMHostBaseDSC {
    <#
    .DESCRIPTION

    Value indicating if the SATP Claim Rule should be Present or Absent.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    <#
    .DESCRIPTION

    Name of the SATP Claim Rule.
    #>
    [DscProperty(Key)]
    [string] $RuleName

    <#
    .DESCRIPTION

    PSP options for the SATP Claim Rule.
    #>
    [DscProperty()]
    [string] $PSPOptions

    <#
    .DESCRIPTION

    Transport Property of the Satp Claim Rule.
    #>
    [DscProperty()]
    [string] $Transport

    <#
    .DESCRIPTION

    Description string to set when adding the SATP Claim Rule.
    #>
    [DscProperty()]
    [string] $Description

    <#
    .DESCRIPTION

    Vendor string to set when adding the SATP Claim Rule.
    #>
    [DscProperty()]
    [string] $Vendor

    <#
    .DESCRIPTION

    System default rule added at boot time.
    #>
    [DscProperty()]
    [bool] $Boot

    <#
    .DESCRIPTION

    Claim type for the SATP Claim Rule.
    #>
    [DscProperty()]
    [string] $Type

    <#
    .DESCRIPTION

    Device of the SATP Claim Rule.
    #>
    [DscProperty()]
    [string] $Device

    <#
    .DESCRIPTION

    Driver string for the SATP Claim Rule.
    #>
    [DscProperty()]
    [string] $Driver

    <#
    .DESCRIPTION

    Claim option string for the SATP Claim Rule.
    #>
    [DscProperty()]
    [string] $ClaimOptions

    <#
    .DESCRIPTION

    Default PSP for the SATP Claim Rule.
    #>
    [DscProperty()]
    [string] $Psp

    <#
    .DESCRIPTION

    Option string for the SATP Claim Rule.
    #>
    [DscProperty()]
    [string] $Options

    <#
    .DESCRIPTION

    Model string for the SATP Claim Rule.
    #>
    [DscProperty()]
    [string] $Model

    <#
    .DESCRIPTION

    Value, which ignores validity checks and install the rule anyway.
    #>
    [DscProperty()]
    [bool] $Force

    [void] Set() {
        try {
            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $esxCli = Get-EsxCli -Server $this.Connection -VMHost $vmHost -V2
            $satpClaimRule = $this.GetSatpClaimRule($esxCli)
            $satpClaimRulePresent = ($null -ne $satpClaimRule)

            if ($this.Ensure -eq [Ensure]::Present) {
                if (!$satpClaimRulePresent) {
                    $this.AddSatpClaimRule($esxCli)
                }
            }
            else {
                if ($satpClaimRulePresent) {
                    $this.RemoveSatpClaimRule($esxCli)
                }
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $esxCli = Get-EsxCli -Server $this.Connection -VMHost $vmHost -V2
            $satpClaimRule = $this.GetSatpClaimRule($esxCli)
            $satpClaimRulePresent = ($null -ne $satpClaimRule)

            if ($this.Ensure -eq [Ensure]::Present) {
                return $satpClaimRulePresent
            }
            else {
                return -not $satpClaimRulePresent
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostSatpClaimRule] Get() {
        try {
            $result = [VMHostSatpClaimRule]::new()

            $result.Server = $this.Server
            $result.RuleName = $this.RuleName
            $result.Boot = $this.Boot
            $result.Type = $this.Type
            $result.Force = $this.Force

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $result.Name = $vmHost.Name
            $esxCli = Get-EsxCli -Server $this.Connection -VMHost $vmHost -V2
            $satpClaimRule = $this.GetSatpClaimRule($esxCli)
            $satpClaimRulePresent = ($null -ne $satpClaimRule)

            if (!$satpClaimRulePresent) {
                $result.Ensure = "Absent"
                $result.Psp = $this.Psp
                $this.PopulateResult($result, $this)
            }
            else {
                $result.Ensure = "Present"
                $result.Psp = $satpClaimRule.DefaultPSP
                $this.PopulateResult($result, $satpClaimRule)
            }

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if the desired SATP Claim Rule is equal to the passed SATP Claim Rule.
    #>
    [bool] Equals($satpClaimRule) {
        if ($this.RuleName -ne $satpClaimRule.Name) {
            return $false
        }

        <#
            For every optional property we check if it is not passed(if it is null), because
            all properties on the server, which are not set are returned as empty strings and
            if we compare null with empty string the equality will fail.
        #>

        if ($null -ne $this.PSPOptions -and $this.PSPOptions -ne $satpClaimRule.PSPOptions) {
            return $false
        }

        if ($null -ne $this.Transport -and $this.Transport -ne $satpClaimRule.Transport) {
            return $false
        }

        if ($null -ne $this.Description -and $this.Description -ne $satpClaimRule.Description) {
            return $false
        }

        if ($null -ne $this.Vendor -and $this.Vendor -ne $satpClaimRule.Vendor) {
            return $false
        }

        if ($null -ne $this.Device -and $this.Device -ne $satpClaimRule.Device) {
            return $false
        }

        if ($null -ne $this.Driver -and $this.Driver -ne $satpClaimRule.Driver) {
            return $false
        }

        if ($null -ne $this.ClaimOptions -and $this.ClaimOptions -ne $satpClaimRule.ClaimOptions) {
            return $false
        }

        if ($null -ne $this.Psp -and $this.Psp -ne $satpClaimRule.DefaultPSP) {
            return $false
        }

        if ($null -ne $this.Options -and $this.Options -ne $satpClaimRule.Options) {
            return $false
        }

        if ($null -ne $this.Model -and $this.Model -ne $satpClaimRule.Model) {
            return $false
        }

        return $true
    }

    <#
    .DESCRIPTION

    Returns the desired SatpClaimRule if the Rule is present on the server, otherwise returns $null.
    #>
    [PSObject] GetSatpClaimRule($esxCli) {
        $foundSatpClaimRule = $null
        $satpClaimRules = Get-SATPClaimRules -EsxCli $esxCli

        foreach ($satpClaimRule in $satpClaimRules) {
            if ($this.Equals($satpClaimRule)) {
                $foundSatpClaimRule = $satpClaimRule
                break
            }
        }

        return $foundSatpClaimRule
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the SATP Claim Rule properties from the server.
    #>
    [void] PopulateResult($result, $satpClaimRule) {
        $result.PSPoptions = $satpClaimRule.PSPOptions
        $result.Transport = $satpClaimRule.Transport
        $result.Description = $satpClaimRule.Description
        $result.Vendor = $satpClaimRule.Vendor
        $result.Device = $satpClaimRule.Device
        $result.Driver = $satpClaimRule.Driver
        $result.ClaimOptions = $satpClaimRule.ClaimOptions
        $result.Options = $satpClaimRule.Options
        $result.Model = $satpClaimRule.Model
    }

    <#
    .DESCRIPTION

    Populates the arguments for the Add and Remove operations of SATP Claim Rule with the specified properties from the user.
    #>
    [void] PopulateSatpArgs($satpArgs) {
        $satpArgs.satp = $this.RuleName
        $satpArgs.pspoption = $this.PSPoptions
        $satpArgs.transport = $this.Transport
        $satpArgs.description = $this.Description
        $satpArgs.vendor = $this.Vendor
        $satpArgs.boot = $this.Boot
        $satpArgs.type = $this.Type
        $satpArgs.device = $this.Device
        $satpArgs.driver = $this.Driver
        $satpArgs.claimoption = $this.ClaimOptions
        $satpArgs.psp = $this.Psp
        $satpArgs.option = $this.Options
        $satpArgs.model = $this.Model
    }

    <#
    .DESCRIPTION

    Installs the new SATP Claim Rule with the specified properties from the user.
    #>
    [void] AddSatpClaimRule($esxCli) {
        $satpArgs = Add-CreateArgs -EsxCli $esxCli
        $satpArgs.force = $this.Force

        $this.PopulateSatpArgs($satpArgs)

        try {
            Add-SATPClaimRule -EsxCli $esxCli -SatpArgs $satpArgs
        }
        catch {
            throw "EsxCLI command for adding satp rule failed with the following exception: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Uninstalls the SATP Claim Rule with the specified properties from the user.
    #>
    [void] RemoveSatpClaimRule($esxCli) {
        $satpArgs = Remove-CreateArgs -EsxCli $esxCli

        $this.PopulateSatpArgs($satpArgs)

        try {
            Remove-SATPClaimRule -EsxCli $esxCli -SatpArgs $satpArgs
        }
        catch {
            throw "EsxCLI command for removing satp rule failed with the following exception: $($_.Exception.Message)"
        }
    }
}

[DscResource()]
class VMHostService : VMHostBaseDSC {
    <#
    .DESCRIPTION

    The key value of the service.
    #>
    [DscProperty(Key)]
    [string] $Key

    <#
    .DESCRIPTION

    The state of the service after a VMHost reboot.
    #>
    [DscProperty()]
    [ServicePolicy] $Policy

    <#
    .DESCRIPTION

    The current state of the service.
    #>
    [DscProperty()]
    [bool] $Running

    <#
    .DESCRIPTION

    Host Service Label.
    #>
    [DscProperty(NotConfigurable)]
    [string] $Label

    <#
    .DESCRIPTION

    Host Service Required flag.
    #>
    [DscProperty(NotConfigurable)]
    [bool] $Required

    <#
    .DESCRIPTION

    Firewall rules for the service.
    #>
    [DscProperty(NotConfigurable)]
    [string[]] $Ruleset

    [void] Set() {
        try {
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()

            $this.UpdateVMHostService($vmHost)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()

            return !$this.ShouldUpdateVMHostService($vmHost)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostService] Get() {
        try {
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

            $result = [VMHostService]::new()
            $result.Server = $this.Server

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $this.PopulateResult($vmHost, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if the VMHostService should to be updated.
    #>
    [bool] ShouldUpdateVMHostService($vmHost) {
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

        $vmHostCurrentService = Get-VMHostService -Server $this.Connection -VMHost $vmHost | Where-Object { $_.Key -eq $this.Key }

        $shouldUpdateVMHostService = @()
        $shouldUpdateVMHostService += ($this.Policy -ne [ServicePolicy]::Unset -and $this.Policy -ne $vmHostCurrentService.Policy)
        $shouldUpdateVMHostService += $this.Running -ne $vmHostCurrentService.Running

        return ($shouldUpdateVMHostService -Contains $true)
    }

    <#
    .DESCRIPTION

    Updates the configuration of the VMHostService.
    #>
    [void] UpdateVMHostService($vmHost) {
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

        $vmHostCurrentService = Get-VMHostService -Server $this.Connection -VMHost $vmHost | Where-Object { $_.Key -eq $this.Key }

        if ($this.Policy -ne [ServicePolicy]::Unset -and $this.Policy -ne $vmHostCurrentService.Policy) {
            Set-VMHostService -HostService $vmHostCurrentService -Policy $this.Policy.ToString() -Confirm:$false
        }

        if ($vmHostCurrentService.Running -ne $this.Running) {
            if ($vmHostCurrentService.Running) {
                Stop-VMHostService -HostService $vmHostCurrentService -Confirm:$false
            }
            else {
                Start-VMHostService -HostService $vmHostCurrentService -Confirm:$false
            }
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the VMHostService from the server.
    #>
    [void] PopulateResult($vmHost, $vmHostService) {
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

        $vmHostCurrentService = Get-VMHostService -Server $this.Connection -VMHost $vmHost | Where-Object { $_.Key -eq $this.Key }
        $vmHostService.Name = $vmHost.Name
        $vmHostService.Server = $this.Server
        $vmHostService.Key = $vmHostCurrentService.Key
        $vmHostService.Policy = $vmHostCurrentService.Policy
        $vmHostService.Running = $vmHostCurrentService.Running
        $vmHostService.Label = $vmHostCurrentService.Label
        $vmHostService.Required = $vmHostCurrentService.Required
        $vmHostService.Ruleset = $vmHostCurrentService.Ruleset
    }
}

[DscResource()]
class VMHostSettings : VMHostBaseDSC {
    <#
    .DESCRIPTION

    Motd Advanced Setting value.
    #>
    [DscProperty()]
    [string] $Motd

    <#
    .DESCRIPTION

    Indicates whether the Motd content should be cleared.
    #>
    [DscProperty()]
    [bool] $MotdClear

    <#
    .DESCRIPTION

    Issue Advanced Setting value.
    #>
    [DscProperty()]
    [string] $Issue

    <#
    .DESCRIPTION

    Indicates whether the Issue content should be cleared.
    #>
    [DscProperty()]
    [bool] $IssueClear

    hidden [string] $IssueSettingName = "Config.Etc.issue"
    hidden [string] $MotdSettingName = "Config.Etc.motd"

    [void] Set() {
    	try {
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()

            $this.UpdateVMHostSettings($vmHost)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
    	try {
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()

            return !$this.ShouldUpdateVMHostSettings($vmHost)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostSettings] Get() {
    	try {
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

            $result = [VMHostSettings]::new()
            $result.Server = $this.Server

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $this.PopulateResult($vmHost, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if the Advanced Setting value should be updated.
    #>
    [bool] ShouldUpdateSettingValue($desiredValue, $currentValue) {
    	<#
        Desired value equal to $null means that the setting value was not specified.
        If it is specified we check if the setting value is not equal to the current value.
        #>
    	Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

        return ($null -ne $desiredValue -and $desiredValue -ne $currentValue)
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if at least one Advanced Setting value should be updated.
    #>
    [bool] ShouldUpdateVMHostSettings($vmHost) {
    	Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

    	$vmHostCurrentAdvancedSettings = Get-AdvancedSetting -Server $this.Connection -Entity $vmHost

    	$currentMotd = $vmHostCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.MotdSettingName }
    	$currentIssue = $vmHostCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.IssueSettingName }

    	$shouldUpdateVMHostSettings = @()
    	$shouldUpdateVMHostSettings += ($this.MotdClear -and ($currentMotd.Value -ne [string]::Empty)) -or (-not $this.MotdClear -and ($this.Motd -ne $currentMotd.Value))
    	$shouldUpdateVMHostSettings += ($this.IssueClear -and ($currentIssue.Value -ne [string]::Empty)) -or (-not $this.IssueClear -and ($this.Issue -ne $currentIssue.Value))

        return ($shouldUpdateVMHostSettings -Contains $true)
    }

  	<#
    .DESCRIPTION

    Sets the desired value for the Advanced Setting, if update of the Advanced Setting value is needed.
    #>
  	[void] SetAdvancedSetting($advancedSetting, $advancedSettingDesiredValue, $advancedSettingCurrentValue, $clearValue) {
    	Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

    	if ($clearValue) {
      	    if ($this.ShouldUpdateSettingValue([string]::Empty, $advancedSettingCurrentValue)) {
                  Set-AdvancedSetting -AdvancedSetting $advancedSetting -Value [string]::Empty -Confirm:$false
      	    }
    	}
    	else {
      	    if ($this.ShouldUpdateSettingValue($advancedSettingDesiredValue, $advancedSettingCurrentValue)) {
                  Set-AdvancedSetting -AdvancedSetting $advancedSetting -Value $advancedSettingDesiredValue -Confirm:$false
      	    }
    	}
    }

    <#
    .DESCRIPTION

    Performs update on those Advanced Settings values that needs to be updated.
    #>
    [void] UpdateVMHostSettings($vmHost) {
    	Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

    	$vmHostCurrentAdvancedSettings = Get-AdvancedSetting -Server $this.Connection -Entity $vmHost

    	$currentMotd = $vmHostCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.MotdSettingName }
    	$currentIssue = $vmHostCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.IssueSettingName }

    	$this.SetAdvancedSetting($currentMotd, $this.Motd, $currentMotd.Value, $this.MotdClear)
        $this.SetAdvancedSetting($currentIssue, $this.Issue, $currentIssue.Value, $this.IssueClear)
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the advanced settings from the server.
    #>
    [void] PopulateResult($vmHost, $result) {
    	Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

    	$vmHostCurrentAdvancedSettings = Get-AdvancedSetting -Server $this.Connection -Entity $vmHost

    	$currentMotd = $vmHostCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.MotdSettingName }
    	$currentIssue = $vmHostCurrentAdvancedSettings | Where-Object { $_.Name -eq $this.IssueSettingName }

        $result.Name = $vmHost.Name
    	$result.Motd = $currentMotd.Value
        $result.Issue = $currentIssue.Value
    }
}

[DscResource()]
class VMHostSyslog : VMHostBaseDSC {
    <#
    .DESCRIPTION

    The remote host(s) to send logs to.
    #>
    [DscProperty()]
    [string] $Loghost

    <#
    .DESCRIPTION

    Verify remote SSL certificates against the local CA Store.
    #>
    [DscProperty()]
    [nullable[bool]] $CheckSslCerts

    <#
    .DESCRIPTION

    Default network retry timeout in seconds if a remote server fails to respond.
    #>
    [DscProperty()]
    [nullable[long]] $DefaultTimeout

    <#
    .DESCRIPTION

    Message queue capacity after which messages are dropped.
    #>
    [DscProperty()]
    [nullable[long]] $QueueDropMark

    <#
    .DESCRIPTION

    The directory to output local logs to.
    #>
    [DscProperty()]
    [string] $Logdir

    <#
    .DESCRIPTION

    Place logs in a unique subdirectory of logdir, based on hostname.
    #>
    [DscProperty()]
    [nullable[bool]] $LogdirUnique

    <#
    .DESCRIPTION

    Default number of rotated local logs to keep.
    #>
    [DscProperty()]
    [nullable[long]] $DefaultRotate

    <#
    .DESCRIPTION

    Default size of local logs before rotation, in KiB.
    #>
    [DscProperty()]
    [nullable[long]] $DefaultSize

    <#
    .DESCRIPTION

    Number of rotated dropped log files to keep.
    #>
    [DscProperty()]
    [nullable[long]] $DropLogRotate

    <#
    .DESCRIPTION

    Size of dropped log file before rotation, in KiB.
    #>
    [DscProperty()]
    [nullable[long]] $DropLogSize

    [void] Set() {
        try {
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()

            $this.UpdateVMHostSyslog($vmHost)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()

            return !$this.ShouldUpdateVMHostSyslog($vmHost)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostSyslog] Get() {
        try {
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

            $result = [VMHostSyslog]::new()

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $this.PopulateResult($vmHost, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if VMHostSyslog needs to be updated.
    #>
    [bool] ShouldUpdateVMHostSyslog($VMHost) {
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

        $esxcli = Get-Esxcli -Server $this.Connection -VMHost $vmHost -V2
        $current = Get-VMHostSyslogConfig -EsxCLi $esxcli

        $shouldUpdateVMHostSyslog = @()

        $shouldUpdateVMHostSyslog += ![string]::IsNullOrEmpty($this.LogHost) -or ($current.RemoteHost -ne '<none>' -and $this.LogHost -ne $current.RemoteHost)
        $shouldUpdateVMHostSyslog += $this.CheckSslCerts -ne $current.EnforceSSLCertificates
        $shouldUpdateVMHostSyslog += $this.DefaultTimeout -ne $current.DefaultNetworkRetryTimeout
        $shouldUpdateVMHostSyslog += $this.QueueDropMark -ne $current.MessageQueueDropMark
        $shouldUpdateVMHostSyslog += $this.Logdir -ne $current.LocalLogOutput
        $shouldUpdateVMHostSyslog += $this.LogdirUnique -ne [System.Convert]::ToBoolean($current.LogToUniqueSubdirectory)
        $shouldUpdateVMHostSyslog += $this.DefaultRotate -ne $current.LocalLoggingDefaultRotations
        $shouldUpdateVMHostSyslog += $this.DefaultSize -ne $current.LocalLoggingDefaultRotationSize
        $shouldUpdateVMHostSyslog += $this.DropLogRotate -ne $current.DroppedLogFileRotations
        $shouldUpdateVMHostSyslog += $this.DropLogSize -ne $current.DroppedLogFileRotationSize

        return ($shouldUpdateVMHostSyslog -contains $true)
    }

    <#
    .DESCRIPTION

    Updates the configuration of the VMHostSyslog.
    #>
    [void] UpdateVMHostSyslog($VMHost) {
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

        $esxcli = Get-Esxcli -Server $this.Connection -VMHost $vmHost -V2

        $VMHostSyslogConfig = @{
            checksslcerts = $this.CheckSslCerts
            defaulttimeout = $this.DefaultTimeout
            queuedropmark = $this.QueueDropMark
            logdir = $this.Logdir
            logdirunique = $this.LogdirUnique
            defaultrotate = $this.DefaultRotate
            defaultsize = $this.DefaultSize
            droplogrotate = $this.DropLogRotate
            droplogsize = $this.DropLogSize
        }

        if (![string]::IsNullOrEmpty($this.LogHost)) {
            $VMHostSyslogConfig.loghost = $this.Loghost
        }

        Set-VMHostSyslogConfig -EsxCli $esxcli -VMHostSyslogConfig $VMHostSyslogConfig
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the VMHostService from the server.
    #>
    [void] PopulateResult($VMHost, $syslog) {
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

        $esxcli = Get-Esxcli -Server $this.Connection -VMHost $vmHost -V2
        $currentVMHostSyslog = Get-VMHostSyslogConfig -EsxCLi $esxcli

        $syslog.Server = $this.Server
        $syslog.Name = $VMHost.Name
        $syslog.Loghost = $currentVMHostSyslog.RemoteHost
        $syslog.CheckSslCerts = $currentVMHostSyslog.EnforceSSLCertificates
        $syslog.DefaultTimeout = $currentVMHostSyslog.DefaultNetworkRetryTimeout
        $syslog.QueueDropMark = $currentVMHostSyslog.MessageQueueDropMark
        $syslog.Logdir = $currentVMHostSyslog.LocalLogOutput
        $syslog.LogdirUnique = [System.Convert]::ToBoolean($currentVMHostSyslog.LogToUniqueSubdirectory)
        $syslog.DefaultRotate = $currentVMHostSyslog.LocalLoggingDefaultRotations
        $syslog.DefaultSize = $currentVMHostSyslog.LocalLoggingDefaultRotationSize
        $syslog.DropLogRotate = $currentVMHostSyslog.DroppedLogFileRotations
        $syslog.DropLogSize = $currentVMHostSyslog.DroppedLogFileRotationSize
    }
}

[DscResource()]
class VMHostTpsSettings : VMHostBaseDSC {
    <#
    .DESCRIPTION

    Share Scan Time Advanced Setting value.
    #>
    [DscProperty()]
    [nullable[int]] $ShareScanTime

    <#
    .DESCRIPTION

    Share Scan GHz Advanced Setting value.
    #>
    [DscProperty()]
    [nullable[int]] $ShareScanGHz

    <#
    .DESCRIPTION

    Share Rate Max Advanced Setting value.
    #>
    [DscProperty()]
    [nullable[int]] $ShareRateMax

    <#
    .DESCRIPTION

    Share Force Salting Advanced Setting value.
    #>
    [DscProperty()]
    [nullable[int]] $ShareForceSalting

    hidden [string] $TpsSettingsName = "Mem.Sh*"
    hidden [string] $MemValue = "Mem."

    [void] Set() {
        try {
            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()

            $this.UpdateTpsSettings($vmHost)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $shouldUpdateTpsSettings = $this.ShouldUpdateTpsSettings($vmHost)

            return !$shouldUpdateTpsSettings
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostTpsSettings] Get() {
        try {
            $result = [VMHostTpsSettings]::new()
            $result.Server = $this.Server

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $result.Name = $vmHost.Name
            $tpsSettings = Get-AdvancedSetting -Server $this.Connection -Entity $vmHost -Name $this.TpsSettingsName

            foreach ($tpsSetting in $tpsSettings) {
                $tpsSettingName = $tpsSetting.Name.TrimStart($this.MemValue)

                $result.$tpsSettingName = $tpsSetting.Value
            }

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Returns a boolean value, indicating if update operation should be performed on at least one of the TPS Settings.
    #>
    [bool] ShouldUpdateTpsSettings($vmHost) {
        $tpsSettings = Get-AdvancedSetting -Server $this.Connection -Entity $vmHost -Name $this.TpsSettingsName

        foreach ($tpsSetting in $tpsSettings) {
            $tpsSettingName = $tpsSetting.Name.TrimStart($this.MemValue)

            if ($null -ne $this.$tpsSettingName -and $this.$tpsSettingName -ne $tpsSetting.Value) {
                return $true
            }
        }

        return $false
    }

    <#
    .DESCRIPTION

    Updates the needed TPS Settings with the specified values.
    #>
    [void] UpdateTpsSettings($vmHost) {
        $tpsSettings = Get-AdvancedSetting -Server $this.Connection -Entity $vmHost -Name $this.TpsSettingsName

        foreach ($tpsSetting in $tpsSettings) {
            $tpsSettingName = $tpsSetting.Name.TrimStart($this.MemValue)

            if ($null -eq $this.$tpsSettingName -or $this.$tpsSettingName -eq $tpsSetting.Value) {
                continue
            }

            Set-AdvancedSetting -AdvancedSetting $tpsSetting -Value $this.$tpsSettingName -Confirm:$false
        }
    }
}

[DscResource()]
class VMHostVssNic : VMHostNicBaseDSC {
    <#
    .DESCRIPTION

    Specifies the Name of the Virtual Switch to which you want to add the new Network Adapter.
    #>
    [DscProperty(Key)]
    [string] $VssName

    [void] Set() {
        try {
            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $virtualSwitch = $this.GetVirtualSwitch()
            $vmHostNetworkAdapter = $this.GetVMHostNetworkAdapter($virtualSwitch)

            if ($null -ne $vmHostNetworkAdapter) {
                <#
                Here the retrieval of the VMKernel is done for the second time because retrieving it
                by Virtual Switch and Port Group produces errors when trying to update or delete it.
                The errors do not occur when the retrieval is done by Name.
                #>
                $vmHostNetworkAdapter = Get-VMHostNetworkAdapter -Server $this.Connection -Name $vmHostNetworkAdapter.Name -VMHost $this.VMHost -VMKernel
            }

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $vmHostNetworkAdapter) {
                    $this.AddVMHostNetworkAdapter($virtualSwitch, $null)
                }
                else {
                    $this.UpdateVMHostNetworkAdapter($vmHostNetworkAdapter)
                }
            }
            else {
                if ($null -ne $vmHostNetworkAdapter) {
                    $this.RemoveVMHostNetworkAdapter($vmHostNetworkAdapter)
                }
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $virtualSwitch = $this.GetVirtualSwitch()
            $vmHostNetworkAdapter = $this.GetVMHostNetworkAdapter($virtualSwitch)

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $vmHostNetworkAdapter) {
                    return $false
                }

                return !$this.ShouldUpdateVMHostNetworkAdapter($vmHostNetworkAdapter)
            }
            else {
                return ($null -eq $vmHostNetworkAdapter)
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostVssNic] Get() {
        try {
            $result = [VMHostVssNic]::new()
            $result.Server = $this.Server

            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $virtualSwitch = $this.GetVirtualSwitch()
            $vmHostNetworkAdapter = $this.GetVMHostNetworkAdapter($virtualSwitch)

            $result.VMHostName = $this.VMHost.Name
            $result.VssName = $virtualSwitch.Name

            $this.PopulateResult($vmHostNetworkAdapter, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Virtual Switch with the specified name from the server if it exists.
    The Virtual Switch must be a Standard Virtual Switch. If the Virtual Switch does not exist, it throws an exception.
    #>
    [PSObject] GetVirtualSwitch() {
        try {
            $virtualSwitch = Get-VirtualSwitch -Server $this.Connection -Name $this.VssName -VMHost $this.VMHost -Standard -ErrorAction Stop
            return $virtualSwitch
        }
        catch {
            throw "Could not retrieve Virtual Switch $($this.VssName) of VMHost $($this.VMHost.Name). For more information: $($_.Exception.Message)"
        }
    }
}

[DscResource()]
class VMHostPhysicalNic : VMHostEntityBaseDSC {
    <#
    .DESCRIPTION

    Specifies the Name of the Physical Network Adapter which is going to be configured.
    #>
    [DscProperty(Key)]
    [string] $Name

    <#
    .DESCRIPTION

    Indicates whether the link is capable of full-duplex. The valid values are Full, Half and Unset.
    #>
    [DscProperty()]
    [Duplex] $Duplex = [Duplex]::Unset

    <#
    .DESCRIPTION

    Specifies the bit rate of the link.
    #>
    [DscProperty()]
    [nullable[int]] $BitRatePerSecMb

    <#
    .DESCRIPTION

    Indicates that the host network adapter speed/duplex settings are configured automatically.
    If the property is passed, the Duplex and BitRatePerSecMb properties will be ignored.
    #>
    [DscProperty()]
    [nullable[bool]] $AutoNegotiate

    [void] Set() {
        try {
            $this.ConnectVIServer()
            $this.RetrieveVMHost()
            $physicalNetworkAdapter = $this.GetPhysicalNetworkAdapter()

            $this.UpdatePhysicalNetworkAdapter($physicalNetworkAdapter)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()
            $this.RetrieveVMHost()
            $physicalNetworkAdapter = $this.GetPhysicalNetworkAdapter()

            return !$this.ShouldUpdatePhysicalNetworkAdapter($physicalNetworkAdapter)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostPhysicalNic] Get() {
        try {
            $result = [VMHostPhysicalNic]::new()
            $result.Server = $this.Server

            $this.ConnectVIServer()
            $this.RetrieveVMHost()
            $physicalNetworkAdapter = $this.GetPhysicalNetworkAdapter()

            $result.VMHostName = $this.VMHost.Name
            $result.Name = $physicalNetworkAdapter.Name

            $this.PopulateResult($physicalNetworkAdapter, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Physical Network Adapter with the specified name from the server if it exists.
    The Network Adapter must be a Physical Network Adapter. If the Physical Network Adapter does not exist, it throws an exception.
    #>
    [PSObject] GetPhysicalNetworkAdapter() {
        try {
            $physicalNetworkAdapter = Get-VMHostNetworkAdapter -Server $this.Connection -Name $this.Name -VMHost $this.VMHost -Physical -ErrorAction Stop
            return $physicalNetworkAdapter
        }
        catch {
            throw "Could not retrieve Physical Network Adapter $($this.Name) of VMHost $($this.VMHost.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Checks if the Physical Network Adapter should be updated.
    #>
    [bool] ShouldUpdatePhysicalNetworkAdapter($physicalNetworkAdapter) {
        $shouldUpdatePhysicalNetworkAdapter = @()
        $shouldUpdatePhysicalNetworkAdapter += ($null -ne $this.BitRatePerSecMb -and $this.BitRatePerSecMb -ne $physicalNetworkAdapter.BitRatePerSec)

        <#
        The Duplex value on the server is stored as boolean indicating if the link is capable of full-duplex.
        So mapping between the enum and boolean values needs to be performed for comparison purposes.
        #>
        if ($this.Duplex -ne [Duplex]::Unset) {
            if ($physicalNetworkAdapter.FullDuplex) {
                $shouldUpdatePhysicalNetworkAdapter += ($this.Duplex -ne [Duplex]::Full)
            }
            else {
                $shouldUpdatePhysicalNetworkAdapter += ($this.Duplex -ne [Duplex]::Half)
            }
        }

        <#
        If the network adapter speed/duplex settings are configured automatically, the Link Speed
        property is $null on the server.
        #>
        if ($null -ne $this.AutoNegotiate) {
            if ($this.AutoNegotiate) {
                $shouldUpdatePhysicalNetworkAdapter += ($null -ne $physicalNetworkAdapter.ExtensionData.Spec.LinkSpeed)
            }
            else {
                $shouldUpdatePhysicalNetworkAdapter += ($null -eq $physicalNetworkAdapter.ExtensionData.Spec.LinkSpeed)
            }
        }

        return ($shouldUpdatePhysicalNetworkAdapter -Contains $true)
    }

    <#
    .DESCRIPTION

    Performs an update operation on the specified Physical Network Adapter.
    #>
    [void] UpdatePhysicalNetworkAdapter($physicalNetworkAdapter) {
        $physicalNetworkAdapterParams = @{}

        $physicalNetworkAdapterParams.PhysicalNic = $physicalNetworkAdapter
        $physicalNetworkAdapterParams.Confirm = $false
        $physicalNetworkAdapterParams.ErrorAction = 'Stop'

        if ($null -ne $this.AutoNegotiate -and $this.AutoNegotiate) {
            $physicalNetworkAdapterParams.AutoNegotiate = $this.AutoNegotiate
        }
        else {
            if ($this.Duplex -ne [Duplex]::Unset) { $physicalNetworkAdapterParams.Duplex = $this.Duplex.ToString() }
            if ($null -ne $this.BitRatePerSecMb) { $physicalNetworkAdapterParams.BitRatePerSecMb = $this.BitRatePerSecMb }
        }

        try {
            Set-VMHostNetworkAdapter @physicalNetworkAdapterParams
        }
        catch {
            throw "Cannot update Physical Network Adapter $($physicalNetworkAdapter.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the Physical Network Adapter from the server.
    #>
    [void] PopulateResult($physicalNetworkAdapter, $result) {
        <#
        AutoNegotiate property is not present on the server, so it should be populated
        with the value provided by user.
        #>
        $result.AutoNegotiate = $this.AutoNegotiate
        $result.BitRatePerSecMb = $physicalNetworkAdapter.BitRatePerSec

        if ($physicalNetworkAdapter.FullDuplex) {
            $result.Duplex = [Duplex]::Full
        }
        else {
            $result.Duplex = [Duplex]::Half
        }
    }
}

[DscResource()]
class VMHostVssPortGroup : VMHostVssPortGroupBaseDSC {
    <#
    .DESCRIPTION

    Specifies the Name of the Virtual Switch associated with the Port Group.
    The Virtual Switch must be a Standard Virtual Switch.
    #>
    [DscProperty(Mandatory)]
    [string] $VssName

    <#
    .DESCRIPTION

    Specifies the VLAN ID for ports using this Port Group. The following values are valid:
    0 - specifies that you do not want to associate the Port Group with a VLAN.
    1 to 4094 - specifies a VLAN ID for the Port Group.
    4095 - specifies that the Port Group should use trunk mode, which allows the guest operating system to manage its own VLAN tags.
    #>
    [DscProperty()]
    [nullable[int]] $VLanId

    hidden [int] $VLanIdMaxValue = 4095

    [void] Set() {
        try {
            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $virtualSwitch = $this.GetVirtualSwitch()
            $portGroup = $this.GetVirtualPortGroup($virtualSwitch)

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $portGroup) {
                    $this.AddVirtualPortGroup($virtualSwitch)
                }
                else {
                    $this.UpdateVirtualPortGroup($portGroup)
                }
            }
            else {
                if ($null -ne $portGroup) {
                    $this.RemoveVirtualPortGroup($portGroup)
                }
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $virtualSwitch = $this.GetVirtualSwitch()
            $portGroup = $this.GetVirtualPortGroup($virtualSwitch)

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $portGroup) {
                    return $false
                }

                return !$this.ShouldUpdateVirtualPortGroup($portGroup)
            }
            else {
                return ($null -eq $portGroup)
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostVssPortGroup] Get() {
        try {
            $result = [VMHostVssPortGroup]::new()
            $result.Server = $this.Server

            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $virtualSwitch = $this.GetVirtualSwitch()
            $portGroup = $this.GetVirtualPortGroup($virtualSwitch)

            $result.VMHostName = $this.VMHost.Name
            $this.PopulateResult($portGroup, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Virtual Switch with the specified name from the server if it exists.
    The Virtual Switch must be a Standard Virtual Switch. If the Virtual Switch does not exist and Ensure is set to 'Absent', $null is returned.
    Otherwise it throws an exception.
    #>
    [PSObject] GetVirtualSwitch() {
        if ($this.Ensure -eq [Ensure]::Absent) {
            return Get-VirtualSwitch -Server $this.Connection -Name $this.VssName -VMHost $this.VMHost -Standard -ErrorAction SilentlyContinue
        }
        else {
            try {
                $virtualSwitch = Get-VirtualSwitch -Server $this.Connection -Name $this.VssName -VMHost $this.VMHost -Standard -ErrorAction Stop
                return $virtualSwitch
            }
            catch {
                throw "Could not retrieve Virtual Switch $($this.VssName) of VMHost $($this.VMHost.Name). For more information: $($_.Exception.Message)"
            }
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Virtual Port Group with the specified Name, available on the specified Virtual Switch and VMHost from the server if it exists,
    otherwise returns $null.
    #>
    [PSObject] GetVirtualPortGroup($virtualSwitch) {
        if ($null -eq $virtualSwitch) {
            <#
            If the Virtual Switch is $null, it means that Ensure was set to 'Absent' and
            the Port Group does not exist for the specified Virtual Switch.
            #>
            return $null
        }

        return Get-VirtualPortGroup -Server $this.Connection -Name $this.Name -VirtualSwitch $virtualSwitch -VMHost $this.VMHost -ErrorAction SilentlyContinue
    }

    <#
    .DESCRIPTION

    Ensures that the passed VLanId value is in the range [0, 4095].
    #>
    [void] EnsureVLanIdValueIsValid() {
        if ($this.VLanId -lt 0 -or $this.VLanId -gt $this.VLanIdMaxValue) {
            throw "The passed VLanId value $($this.VLanId) is not valid. The valid values are in the following range: [0, $($this.VLanIdMaxValue)]."
        }
    }

    <#
    .DESCRIPTION

    Checks if the VLanId is specified and needs to be updated.
    #>
    [bool] ShouldUpdateVirtualPortGroup($portGroup) {
        if ($null -eq $this.VLanId) {
            return $false
        }

        return ($this.VLanId -ne $portGroup.VLanId)
    }

    <#
    .DESCRIPTION

    Returns the populated Port Group parameters.
    #>
    [hashtable] GetPortGroupParams() {
        $portGroupParams = @{}

        $portGroupParams.Confirm = $false
        $portGroupParams.ErrorAction = 'Stop'

        if ($null -ne $this.VLanId) {
            $this.EnsureVLanIdValueIsValid()
            $portGroupParams.VLanId = $this.VLanId
        }

        return $portGroupParams
    }

    <#
    .DESCRIPTION

    Creates a new Port Group available on the specified Virtual Switch.
    #>
    [void] AddVirtualPortGroup($virtualSwitch) {
        $portGroupParams = $this.GetPortGroupParams()

        $portGroupParams.Server = $this.Connection
        $portGroupParams.Name = $this.Name
        $portGroupParams.VirtualSwitch = $virtualSwitch

        try {
            New-VirtualPortGroup @portGroupParams
        }
        catch {
            throw "Cannot create Virtual Port Group $($this.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Updates the Port Group by changing its VLanId value.
    #>
    [void] UpdateVirtualPortGroup($portGroup) {
        $portGroupParams = $this.GetPortGroupParams()

        try {
            $portGroup | Set-VirtualPortGroup @portGroupParams
        }
        catch {
            throw "Cannot update Virtual Port Group $($this.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Removes the specified Port Group available on the Virtual Switch. All VMs connected to the Port Group must be PoweredOff to successfully remove the Port Group.
    If one or more of the VMs are PoweredOn, the removal would not be successful because the Port Group is used by the VMs.
    #>
    [void] RemoveVirtualPortGroup($portGroup) {
        try {
            $portGroup | Remove-VirtualPortGroup -Confirm:$false -ErrorAction Stop
        }
        catch {
            throw "Cannot remove Virtual Port Group $($this.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the Port Group from the server.
    #>
    [void] PopulateResult($portGroup, $result) {
        if ($null -ne $portGroup) {
            $result.Name = $portGroup.Name
            $result.VssName = $portGroup.VirtualSwitchName
            $result.Ensure = [Ensure]::Present
            $result.VLanId = $portGroup.VLanId
        }
        else {
            $result.Name = $this.Name
            $result.VssName = $this.VssName
            $result.Ensure = [Ensure]::Absent
            $result.VLanId = $this.VLanId
        }
    }
}

[DscResource()]
class VMHostVssPortGroupSecurity : VMHostVssPortGroupBaseDSC {
    <#
    .DESCRIPTION

    Specifies whether promiscuous mode is enabled for the corresponding Virtual Port Group.
    #>
    [DscProperty()]
    [nullable[bool]] $AllowPromiscuous

    <#
    .DESCRIPTION

    Specifies whether the AllowPromiscuous setting is inherited from the parent Standard Virtual Switch.
    #>
    [DscProperty()]
    [nullable[bool]] $AllowPromiscuousInherited

    <#
    .DESCRIPTION

    Specifies whether forged transmits are enabled for the corresponding Virtual Port Group.
    #>
    [DscProperty()]
    [nullable[bool]] $ForgedTransmits

    <#
    .DESCRIPTION

    Specifies whether the ForgedTransmits setting is inherited from the parent Standard Virtual Switch.
    #>
    [DscProperty()]
    [nullable[bool]] $ForgedTransmitsInherited

    <#
    .DESCRIPTION

    Specifies whether MAC address changes are enabled for the corresponding Virtual Port Group.
    #>
    [DscProperty()]
    [nullable[bool]] $MacChanges

    <#
    .DESCRIPTION

    Specifies whether the MacChanges setting is inherited from the parent Standard Virtual Switch.
    #>
    [DscProperty()]
    [nullable[bool]] $MacChangesInherited

    hidden [string] $AllowPromiscuousSettingName = 'AllowPromiscuous'
    hidden [string] $AllowPromiscuousInheritedSettingName = 'AllowPromiscuousInherited'
    hidden [string] $ForgedTransmitsSettingName = 'ForgedTransmits'
    hidden [string] $ForgedTransmitsInheritedSettingName = 'ForgedTransmitsInherited'
    hidden [string] $MacChangesSettingName = 'MacChanges'
    hidden [string] $MacChangesInheritedSettingName = 'MacChangesInherited'

    [void] Set() {
        try {
            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $virtualPortGroup = $this.GetVirtualPortGroup()
            $virtualPortGroupSecurityPolicy = $this.GetVirtualPortGroupSecurityPolicy($virtualPortGroup)

            $this.UpdateVirtualPortGroupSecurityPolicy($virtualPortGroupSecurityPolicy)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $virtualPortGroup = $this.GetVirtualPortGroup()
            if ($null -eq $virtualPortGroup) {
                # If the Port Group is $null, it means that Ensure is 'Absent' and the Port Group does not exist.
                return $true
            }

            $virtualPortGroupSecurityPolicy = $this.GetVirtualPortGroupSecurityPolicy($virtualPortGroup)

            return !$this.ShouldUpdateVirtualPortGroupSecurityPolicy($virtualPortGroupSecurityPolicy)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostVssPortGroupSecurity] Get() {
        try {
            $result = [VMHostVssPortGroupSecurity]::new()
            $result.Server = $this.Server
            $result.Ensure = $this.Ensure

            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $result.VMHostName = $this.VMHost.Name

            $virtualPortGroup = $this.GetVirtualPortGroup()
            if ($null -eq $virtualPortGroup) {
                # If the Port Group is $null, it means that Ensure is 'Absent' and the Port Group does not exist.
                $result.Name = $this.Name
                return $result
            }

            $virtualPortGroupSecurityPolicy = $this.GetVirtualPortGroupSecurityPolicy($virtualPortGroup)
            $result.Name = $virtualPortGroup.Name

            $this.PopulateResult($virtualPortGroupSecurityPolicy, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Virtual Port Group Security Policy from the server.
    #>
    [PSObject] GetVirtualPortGroupSecurityPolicy($virtualPortGroup) {
        try {
            $virtualPortGroupSecurityPolicy = Get-SecurityPolicy -Server $this.Connection -VirtualPortGroup $virtualPortGroup -ErrorAction Stop
            return $virtualPortGroupSecurityPolicy
        }
        catch {
            throw "Could not retrieve Virtual Port Group $($this.PortGroup) Security Policy. For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Checks if the Security Policy of the specified Virtual Port Group should be updated.
    #>
    [bool] ShouldUpdateVirtualPortGroupSecurityPolicy($virtualPortGroupSecurityPolicy) {
        $shouldUpdateVirtualPortGroupSecurityPolicy = @()

        $shouldUpdateVirtualPortGroupSecurityPolicy += ($null -ne $this.AllowPromiscuous -and $this.AllowPromiscuous -ne $virtualPortGroupSecurityPolicy.AllowPromiscuous)
        $shouldUpdateVirtualPortGroupSecurityPolicy += ($null -ne $this.AllowPromiscuousInherited -and $this.AllowPromiscuousInherited -ne $virtualPortGroupSecurityPolicy.AllowPromiscuousInherited)
        $shouldUpdateVirtualPortGroupSecurityPolicy += ($null -ne $this.ForgedTransmits -and $this.ForgedTransmits -ne $virtualPortGroupSecurityPolicy.ForgedTransmits)
        $shouldUpdateVirtualPortGroupSecurityPolicy += ($null -ne $this.ForgedTransmitsInherited -and $this.ForgedTransmitsInherited -ne $virtualPortGroupSecurityPolicy.ForgedTransmitsInherited)
        $shouldUpdateVirtualPortGroupSecurityPolicy += ($null -ne $this.MacChanges -and $this.MacChanges -ne $virtualPortGroupSecurityPolicy.MacChanges)
        $shouldUpdateVirtualPortGroupSecurityPolicy += ($null -ne $this.MacChangesInherited -and $this.MacChangesInherited -ne $virtualPortGroupSecurityPolicy.MacChangesInherited)

        return ($shouldUpdateVirtualPortGroupSecurityPolicy -Contains $true)
    }

    <#
    .DESCRIPTION

    Performs an update on the Security Policy of the specified Virtual Port Group.
    #>
    [void] UpdateVirtualPortGroupSecurityPolicy($virtualPortGroupSecurityPolicy) {
        $securityPolicyParams = @{}
        $securityPolicyParams.VirtualPortGroupPolicy = $virtualPortGroupSecurityPolicy

        $this.PopulatePolicySetting($securityPolicyParams, $this.AllowPromiscuousSettingName, $this.AllowPromiscuous, $this.AllowPromiscuousInheritedSettingName, $this.AllowPromiscuousInherited)
        $this.PopulatePolicySetting($securityPolicyParams, $this.ForgedTransmitsSettingName, $this.ForgedTransmits, $this.ForgedTransmitsInheritedSettingName, $this.ForgedTransmitsInherited)
        $this.PopulatePolicySetting($securityPolicyParams, $this.MacChangesSettingName, $this.MacChanges, $this.MacChangesInheritedSettingName, $this.MacChangesInherited)

        try {
            Set-SecurityPolicy @securityPolicyParams
        }
        catch {
            throw "Cannot update Security Policy of Virtual Port Group $($this.PortGroup). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the Security Policy of the specified Virtual Port Group from the server.
    #>
    [void] PopulateResult($virtualPortGroupSecurityPolicy, $result) {
        $result.AllowPromiscuous = $virtualPortGroupSecurityPolicy.AllowPromiscuous
        $result.AllowPromiscuousInherited = $virtualPortGroupSecurityPolicy.AllowPromiscuousInherited
        $result.ForgedTransmits = $virtualPortGroupSecurityPolicy.ForgedTransmits
        $result.ForgedTransmitsInherited = $virtualPortGroupSecurityPolicy.ForgedTransmitsInherited
        $result.MacChanges = $virtualPortGroupSecurityPolicy.MacChanges
        $result.MacChangesInherited = $virtualPortGroupSecurityPolicy.MacChangesInherited
    }
}

[DscResource()]
class VMHostVssPortGroupShaping : VMHostVssPortGroupBaseDSC {
    <#
    .DESCRIPTION

    The flag to indicate whether or not traffic shaper is enabled on the port.
    #>
    [DscProperty()]
    [nullable[bool]] $Enabled

    <#
    .DESCRIPTION

    The average bandwidth in bits per second if shaping is enabled on the port.
    #>
    [DscProperty()]
    [nullable[long]] $AverageBandwidth

    <#
    .DESCRIPTION

    The peak bandwidth during bursts in bits per second if traffic shaping is enabled on the port.
    #>
    [DscProperty()]
    [nullable[long]] $PeakBandwidth

    <#
    .DESCRIPTION

    The maximum burst size allowed in bytes if shaping is enabled on the port.
    #>
    [DscProperty()]
    [nullable[long]] $BurstSize

    [void] Set() {
        try {
            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $this.GetVMHostNetworkSystem()
            $virtualPortGroup = $this.GetVirtualPortGroup()

            $this.UpdateVirtualPortGroupShapingPolicy($virtualPortGroup)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $virtualPortGroup = $this.GetVirtualPortGroup()
            if ($null -eq $virtualPortGroup) {
                # If the Port Group is $null, it means that Ensure is 'Absent' and the Port Group does not exist.
                return $true
            }

            return !$this.ShouldUpdateVirtualPortGroupShapingPolicy($virtualPortGroup)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostVssPortGroupShaping] Get() {
        try {
            $result = [VMHostVssPortGroupShaping]::new()
            $result.Server = $this.Server
            $result.Ensure = $this.Ensure

            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $result.VMHostName = $this.VMHost.Name

            $virtualPortGroup = $this.GetVirtualPortGroup()
            if ($null -eq $virtualPortGroup) {
                # If the Port Group is $null, it means that Ensure is 'Absent' and the Port Group does not exist.
                $result.Name = $this.Name
                return $result
            }

            $result.Name = $virtualPortGroup.Name
            $this.PopulateResult($virtualPortGroup, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Checks if the Shaping Policy of the specified Virtual Port Group should be updated.
    #>
    [bool] ShouldUpdateVirtualPortGroupShapingPolicy($virtualPortGroup) {
        $shouldUpdateVirtualPortGroupShapingPolicy = @()

        $shouldUpdateVirtualPortGroupShapingPolicy += ($null -ne $this.Enabled -and $this.Enabled -ne $virtualPortGroup.ExtensionData.Spec.Policy.ShapingPolicy.Enabled)
        $shouldUpdateVirtualPortGroupShapingPolicy += ($null -ne $this.AverageBandwidth -and $this.AverageBandwidth -ne $virtualPortGroup.ExtensionData.Spec.Policy.ShapingPolicy.AverageBandwidth)
        $shouldUpdateVirtualPortGroupShapingPolicy += ($null -ne $this.PeakBandwidth -and $this.PeakBandwidth -ne $virtualPortGroup.ExtensionData.Spec.Policy.ShapingPolicy.PeakBandwidth)
        $shouldUpdateVirtualPortGroupShapingPolicy += ($null -ne $this.BurstSize -and $this.BurstSize -ne $virtualPortGroup.ExtensionData.Spec.Policy.ShapingPolicy.BurstSize)

        return ($shouldUpdateVirtualPortGroupShapingPolicy -Contains $true)
    }

    <#
    .DESCRIPTION

    Performs an update on the Shaping Policy of the specified Virtual Port Group.
    #>
    [void] UpdateVirtualPortGroupShapingPolicy($virtualPortGroup) {
        $virtualPortGroupSpec = New-Object VMware.Vim.HostPortGroupSpec

        $virtualPortGroupSpec.Name = $virtualPortGroup.Name
        $virtualPortGroupSpec.VswitchName = $virtualPortGroup.VirtualSwitchName
        $virtualPortGroupSpec.VlanId = $virtualPortGroup.VLanId

        $virtualPortGroupSpec.Policy = New-Object VMware.Vim.HostNetworkPolicy
        $virtualPortGroupSpec.Policy.ShapingPolicy = New-Object VMware.Vim.HostNetworkTrafficShapingPolicy

        if ($null -ne $this.Enabled) { $virtualPortGroupSpec.Policy.ShapingPolicy.Enabled = $this.Enabled }
        if ($null -ne $this.AverageBandwidth) { $virtualPortGroupSpec.Policy.ShapingPolicy.AverageBandwidth = $this.AverageBandwidth }
        if ($null -ne $this.PeakBandwidth) { $virtualPortGroupSpec.Policy.ShapingPolicy.PeakBandwidth = $this.PeakBandwidth }
        if ($null -ne $this.BurstSize) { $virtualPortGroupSpec.Policy.ShapingPolicy.BurstSize = $this.BurstSize }

        try {
            Update-VirtualPortGroup -VMHostNetworkSystem $this.VMHostNetworkSystem -VirtualPortGroupName $virtualPortGroup.Name -Spec $virtualPortGroupSpec
        }
        catch {
            throw "Cannot update Shaping Policy of Virtual Port Group $($this.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the Shaping Policy of the specified Virtual Port Group from the server.
    #>
    [void] PopulateResult($virtualPortGroup, $result) {
        $result.Enabled = $virtualPortGroup.ExtensionData.Spec.Policy.ShapingPolicy.Enabled
        $result.AverageBandwidth = $virtualPortGroup.ExtensionData.Spec.Policy.ShapingPolicy.AverageBandwidth
        $result.PeakBandwidth = $virtualPortGroup.ExtensionData.Spec.Policy.ShapingPolicy.PeakBandwidth
        $result.BurstSize = $virtualPortGroup.ExtensionData.Spec.Policy.ShapingPolicy.BurstSize
    }
}

[DscResource()]
class VMHostVssPortGroupTeaming : VMHostVssPortGroupBaseDSC {
    <#
    .DESCRIPTION

    Specifies how a physical adapter is returned to active duty after recovering from a failure.
    If the value is $true, the adapter is returned to active duty immediately on recovery, displacing the standby adapter that took over its slot, if any.
    If the value is $false, a failed adapter is left inactive even after recovery until another active adapter fails, requiring its replacement.
    #>
    [DscProperty()]
    [nullable[bool]] $FailbackEnabled

    <#
    .DESCRIPTION

    Determines how network traffic is distributed between the network adapters assigned to a switch. The following values are valid:
    LoadBalanceIP - Route based on IP hash. Choose an uplink based on a hash of the source and destination IP addresses of each packet.
    For non-IP packets, whatever is at those offsets is used to compute the hash.
    LoadBalanceSrcMac - Route based on source MAC hash. Choose an uplink based on a hash of the source Ethernet.
    LoadBalanceSrcId - Route based on the originating port ID. Choose an uplink based on the virtual port where the traffic entered the virtual switch.
    ExplicitFailover - Always use the highest order uplink from the list of Active adapters that passes failover detection criteria.
    #>
    [DscProperty()]
    [LoadBalancingPolicy] $LoadBalancingPolicy = [LoadBalancingPolicy]::Unset

    <#
    .DESCRIPTION

    Specifies the adapters you want to continue to use when the network adapter connectivity is available and active.
    #>
    [DscProperty()]
    [string[]] $MakeNicActive

    <#
    .DESCRIPTION

    Specifies the adapters you want to use if one of the active adapter's connectivity is unavailable.
    #>
    [DscProperty()]
    [string[]] $MakeNicStandby

    <#
    .DESCRIPTION

    Specifies the adapters you do not want to use.
    #>
    [DscProperty()]
    [string[]] $MakeNicUnused

    <#
    .DESCRIPTION

    Specifies how to reroute traffic in the event of an adapter failure. The following values are valid:
    LinkStatus - Relies solely on the link status that the network adapter provides. This option detects failures, such as cable pulls and physical switch power failures,
    but not configuration errors, such as a physical switch port being blocked by spanning tree or misconfigured to the wrong VLAN or cable pulls on the other side of a physical switch.
    BeaconProbing - Sends out and listens for beacon probes on all NICs in the team and uses this information, in addition to link status, to determine link failure.
    This option detects many of the failures mentioned above that are not detected by link status alone.
    #>
    [DscProperty()]
    [NetworkFailoverDetectionPolicy] $NetworkFailoverDetectionPolicy = [NetworkFailoverDetectionPolicy]::Unset

    <#
    .DESCRIPTION

    Indicates that whenever a virtual NIC is connected to the virtual switch or whenever that virtual NIC's traffic is routed over a different physical NIC in the team because of a
    failover event, a notification is sent over the network to update the lookup tables on the physical switches.
    #>
    [DscProperty()]
    [nullable[bool]] $NotifySwitches

    <#
    .DESCRIPTION

    Indicates that the value of the FailbackEnabled parameter is inherited from the virtual switch.
    #>
    [DscProperty()]
    [nullable[bool]] $InheritFailback

    <#
    .DESCRIPTION

    Indicates that the value of the MakeNicActive, MakeNicStandBy, and MakeNicUnused parameters are inherited from the virtual switch.
    #>
    [DscProperty()]
    [nullable[bool]] $InheritFailoverOrder

    <#
    .DESCRIPTION

    Indicates that the value of the LoadBalancingPolicy parameter is inherited from the virtual switch.
    #>
    [DscProperty()]
    [nullable[bool]] $InheritLoadBalancingPolicy

    <#
    .DESCRIPTION

    Indicates that the value of the NetworkFailoverDetectionPolicy parameter is inherited from the virtual switch.
    #>
    [DscProperty()]
    [nullable[bool]] $InheritNetworkFailoverDetectionPolicy

    <#
    .DESCRIPTION

    Indicates that the value of the NotifySwitches parameter is inherited from the virtual switch.
    #>
    [DscProperty()]
    [nullable[bool]] $InheritNotifySwitches

    hidden [string] $FailbackEnabledSettingName = 'FailbackEnabled'
    hidden [string] $InheritFailbackSettingName = 'InheritFailback'
    hidden [string] $LoadBalancingPolicySettingName = 'LoadBalancingPolicy'
    hidden [string] $InheritLoadBalancingPolicySettingName = 'InheritLoadBalancingPolicy'
    hidden [string] $NetworkFailoverDetectionPolicySettingName = 'NetworkFailoverDetectionPolicy'
    hidden [string] $InheritNetworkFailoverDetectionPolicySettingName = 'InheritNetworkFailoverDetectionPolicy'
    hidden [string] $NotifySwitchesSettingName = 'NotifySwitches'
    hidden [string] $InheritNotifySwitchesSettingName = 'InheritNotifySwitches'
    hidden [string] $MakeNicActiveSettingName = 'MakeNicActive'
    hidden [string] $MakeNicStandbySettingName = 'MakeNicStandby'
    hidden [string] $MakeNicUnusedSettingName = 'MakeNicUnused'
    hidden [string] $InheritFailoverOrderSettingName = 'InheritFailoverOrder'

    [void] Set() {
        try {
            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $virtualPortGroup = $this.GetVirtualPortGroup()
            $virtualPortGroupTeamingPolicy = $this.GetVirtualPortGroupTeamingPolicy($virtualPortGroup)

            $this.UpdateVirtualPortGroupTeamingPolicy($virtualPortGroupTeamingPolicy)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $virtualPortGroup = $this.GetVirtualPortGroup()
            if ($null -eq $virtualPortGroup) {
                # If the Port Group is $null, it means that Ensure is 'Absent' and the Port Group does not exist.
                return $true
            }

            $virtualPortGroupTeamingPolicy = $this.GetVirtualPortGroupTeamingPolicy($virtualPortGroup)

            return !$this.ShouldUpdateVirtualPortGroupTeamingPolicy($virtualPortGroupTeamingPolicy)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostVssPortGroupTeaming] Get() {
        try {
            $result = [VMHostVssPortGroupTeaming]::new()
            $result.Server = $this.Server
            $result.Ensure = $this.Ensure

            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $result.VMHostName = $this.VMHost.Name

            $virtualPortGroup = $this.GetVirtualPortGroup()
            if ($null -eq $virtualPortGroup) {
                # If the Port Group is $null, it means that Ensure is 'Absent' and the Port Group does not exist.
                $result.Name = $this.Name
                return $result
            }

            $virtualPortGroupTeamingPolicy = $this.GetVirtualPortGroupTeamingPolicy($virtualPortGroup)
            $result.Name = $virtualPortGroup.Name

            $this.PopulateResult($virtualPortGroupTeamingPolicy, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Virtual Port Group Teaming Policy from the server.
    #>
    [PSObject] GetVirtualPortGroupTeamingPolicy($virtualPortGroup) {
        try {
            $virtualPortGroupTeamingPolicy = Get-NicTeamingPolicy -Server $this.Connection -VirtualPortGroup $virtualPortGroup -ErrorAction Stop
            return $virtualPortGroupTeamingPolicy
        }
        catch {
            throw "Could not retrieve Virtual Port Group $($this.Name) Teaming Policy. For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Checks if the passed Nic array is in the desired state and if an update should be performed.
    #>
    [bool] ShouldUpdateNicArray($currentNicArray, $desiredNicArray) {
        if ($null -eq $desiredNicArray -or $desiredNicArray.Length -eq 0) {
            # The property is not specified or an empty Nic array is passed.
            return $false
        }
        else {
            $nicsToAdd = $desiredNicArray | Where-Object { $currentNicArray -NotContains $_ }
            $nicsToRemove = $currentNicArray | Where-Object { $desiredNicArray -NotContains $_ }

            if ($null -ne $nicsToAdd -or $null -ne $nicsToRemove) {
                <#
                The current Nic array does not contain at least one Nic from desired Nic array or
                the desired Nic array is a subset of the current Nic array. In both cases
                we should perform an update operation.
                #>
                return $true
            }

            # No need to perform an update operation.
            return $false
        }
    }

    <#
    .DESCRIPTION

    Checks if the Teaming Policy of the specified Virtual Port Group should be updated.
    #>
    [bool] ShouldUpdateVirtualPortGroupTeamingPolicy($virtualPortGroupTeamingPolicy) {
        $shouldUpdateVirtualPortGroupTeamingPolicy = @()

        $shouldUpdateVirtualPortGroupTeamingPolicy += $this.ShouldUpdateNicArray($virtualPortGroupTeamingPolicy.ActiveNic, $this.MakeNicActive)
        $shouldUpdateVirtualPortGroupTeamingPolicy += $this.ShouldUpdateNicArray($virtualPortGroupTeamingPolicy.StandbyNic, $this.MakeNicStandBy)
        $shouldUpdateVirtualPortGroupTeamingPolicy += $this.ShouldUpdateNicArray($virtualPortGroupTeamingPolicy.UnusedNic, $this.MakeNicUnused)

        $shouldUpdateVirtualPortGroupTeamingPolicy += ($null -ne $this.FailbackEnabled -and $this.FailbackEnabled -ne $virtualPortGroupTeamingPolicy.FailbackEnabled)
        $shouldUpdateVirtualPortGroupTeamingPolicy += ($null -ne $this.NotifySwitches -and $this.NotifySwitches -ne $virtualPortGroupTeamingPolicy.NotifySwitches)
        $shouldUpdateVirtualPortGroupTeamingPolicy += ($null -ne $this.InheritFailback -and $this.InheritFailback -ne $virtualPortGroupTeamingPolicy.IsFailbackInherited)
        $shouldUpdateVirtualPortGroupTeamingPolicy += ($null -ne $this.InheritFailoverOrder -and $this.InheritFailoverOrder -ne $virtualPortGroupTeamingPolicy.IsFailoverOrderInherited)
        $shouldUpdateVirtualPortGroupTeamingPolicy += ($null -ne $this.InheritLoadBalancingPolicy -and $this.InheritLoadBalancingPolicy -ne $virtualPortGroupTeamingPolicy.IsLoadBalancingInherited)
        $shouldUpdateVirtualPortGroupTeamingPolicy += ($null -ne $this.InheritNetworkFailoverDetectionPolicy -and $this.InheritNetworkFailoverDetectionPolicy -ne $virtualPortGroupTeamingPolicy.IsNetworkFailoverDetectionInherited)
        $shouldUpdateVirtualPortGroupTeamingPolicy += ($null -ne $this.InheritNotifySwitches -and $this.InheritNotifySwitches -ne $virtualPortGroupTeamingPolicy.IsNotifySwitchesInherited)

        if ($this.LoadBalancingPolicy -ne [LoadBalancingPolicy]::Unset) {
            $shouldUpdateVirtualPortGroupTeamingPolicy += ($this.LoadBalancingPolicy.ToString() -ne $virtualPortGroupTeamingPolicy.LoadBalancingPolicy.ToString())
        }

        if ($this.NetworkFailoverDetectionPolicy -ne [NetworkFailoverDetectionPolicy]::Unset) {
            $shouldUpdateVirtualPortGroupTeamingPolicy += ($this.NetworkFailoverDetectionPolicy.ToString() -ne $virtualPortGroupTeamingPolicy.NetworkFailoverDetectionPolicy.ToString())
        }

        return ($shouldUpdateVirtualPortGroupTeamingPolicy -Contains $true)
    }

    <#
    .DESCRIPTION

    Populates the specified Enum Policy Setting. If the Inherited Setting is passed and set to $true,
    the Policy Setting should not be populated because "Parameters of the form "XXX" and "InheritXXX" are mutually exclusive."
    If the Inherited Setting is set to $false, both parameters can be populated.
    #>
    [void] PopulateEnumPolicySetting($policyParams, $policySettingName, $policySetting, $policySettingInheritedName, $policySettingInherited) {
        if ($policySetting -ne 'Unset') {
            if ($null -eq $policySettingInherited -or !$policySettingInherited) {
                $policyParams.$policySettingName = $policySetting
            }
        }

        if ($null -ne $policySettingInherited) { $policyParams.$policySettingInheritedName = $policySettingInherited }
    }

    <#
    .DESCRIPTION

    Populates the specified Array Policy Setting. If the Inherited Setting is passed and set to $true,
    the Policy Setting should not be populated because "Parameters of the form "XXX" and "InheritXXX" are mutually exclusive."
    If the Inherited Setting is set to $false, both parameters can be populated.
    #>
    [void] PopulateArrayPolicySetting($policyParams, $policySettingName, $policySetting, $policySettingInheritedName, $policySettingInherited) {
        if ($null -ne $policySetting -and $policySetting.Length -gt 0) {
            if ($null -eq $policySettingInherited -or !$policySettingInherited) {
                $policyParams.$policySettingName = $policySetting
            }
        }

        if ($null -ne $policySettingInherited) { $policyParams.$policySettingInheritedName = $policySettingInherited }
    }

    <#
    .DESCRIPTION

    Performs an update on the Teaming Policy of the specified Virtual Port Group.
    #>
    [void] UpdateVirtualPortGroupTeamingPolicy($virtualPortGroupTeamingPolicy) {
        $teamingPolicyParams = @{}
        $teamingPolicyParams.VirtualPortGroupPolicy = $virtualPortGroupTeamingPolicy

        $this.PopulatePolicySetting($teamingPolicyParams, $this.FailbackEnabledSettingName, $this.FailbackEnabled, $this.InheritFailbackSettingName, $this.InheritFailback)
        $this.PopulatePolicySetting($teamingPolicyParams, $this.NotifySwitchesSettingName, $this.NotifySwitches, $this.InheritNotifySwitchesSettingName, $this.InheritNotifySwitches)

        $this.PopulateEnumPolicySetting($teamingPolicyParams, $this.LoadBalancingPolicySettingName, $this.LoadBalancingPolicy.ToString(), $this.InheritLoadBalancingPolicySettingName, $this.InheritLoadBalancingPolicy)
        $this.PopulateEnumPolicySetting($teamingPolicyParams, $this.NetworkFailoverDetectionPolicySettingName, $this.NetworkFailoverDetectionPolicy.ToString(), $this.InheritNetworkFailoverDetectionPolicySettingName, $this.InheritNetworkFailoverDetectionPolicy)

        $this.PopulateArrayPolicySetting($teamingPolicyParams, $this.MakeNicActiveSettingName, $this.MakeNicActive, $this.InheritFailoverOrderSettingName, $this.InheritFailoverOrder)
        $this.PopulateArrayPolicySetting($teamingPolicyParams, $this.MakeNicStandbySettingName, $this.MakeNicStandBy, $this.InheritFailoverOrderSettingName, $this.InheritFailoverOrder)
        $this.PopulateArrayPolicySetting($teamingPolicyParams, $this.MakeNicUnusedSettingName, $this.MakeNicUnused, $this.InheritFailoverOrderSettingName, $this.InheritFailoverOrder)

        try {
            Set-NicTeamingPolicy @teamingPolicyParams
        }
        catch {
            throw "Cannot update Teaming Policy of Virtual Port Group $($this.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the Teaming Policy of the specified Virtual Port Group from the server.
    #>
    [void] PopulateResult($virtualPortGroupTeamingPolicy, $result) {
        $result.FailbackEnabled = $virtualPortGroupTeamingPolicy.FailbackEnabled
        $result.NotifySwitches = $virtualPortGroupTeamingPolicy.NotifySwitches
        $result.LoadBalancingPolicy = $virtualPortGroupTeamingPolicy.LoadBalancingPolicy.ToString()
        $result.NetworkFailoverDetectionPolicy = $virtualPortGroupTeamingPolicy.NetworkFailoverDetectionPolicy.ToString()
        $result.MakeNicActive = $virtualPortGroupTeamingPolicy.ActiveNic
        $result.MakeNicStandBy = $virtualPortGroupTeamingPolicy.StandbyNic
        $result.MakeNicUnused = $virtualPortGroupTeamingPolicy.UnusedNic
        $result.InheritFailback = $virtualPortGroupTeamingPolicy.IsFailbackInherited
        $result.InheritNotifySwitches = $virtualPortGroupTeamingPolicy.IsNotifySwitchesInherited
        $result.InheritLoadBalancingPolicy = $virtualPortGroupTeamingPolicy.IsLoadBalancingInherited
        $result.InheritNetworkFailoverDetectionPolicy = $virtualPortGroupTeamingPolicy.IsNetworkFailoverDetectionInherited
        $result.InheritFailoverOrder = $virtualPortGroupTeamingPolicy.IsFailoverOrderInherited
    }
}

[DscResource()]
class VMHostVss : VMHostVssBaseDSC {
    <#
    .DESCRIPTION

    The maximum transmission unit (MTU) associated with this virtual switch in bytes.
    #>
    [DscProperty()]
    [nullable[int]] $Mtu

    <#
    .DESCRIPTION

    The virtual switch key.
    #>
    [DscProperty(NotConfigurable)]
    [string] $Key

    <#
    .DESCRIPTION

    The number of ports that this virtual switch currently has.
    #>
    [DscProperty(NotConfigurable)]
    [int] $NumPorts

    <#
    .DESCRIPTION

    The number of ports that are available on this virtual switch.
    #>
    [DscProperty(NotConfigurable)]
    [int] $NumPortsAvailable

    <#
    .DESCRIPTION

    The set of physical network adapters associated with this bridge.
    #>
    [DscProperty(NotConfigurable)]
    [string[]] $Pnic

    <#
    .DESCRIPTION

    The list of port groups configured for this virtual switch.
    #>
    [DscProperty(NotConfigurable)]
    [string[]] $PortGroup

    [void] Set() {
        try {
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $this.GetNetworkSystem($vmHost)

            $this.UpdateVss($vmHost)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $this.GetNetworkSystem($vmHost)
            $vss = $this.GetVss()

            if ($this.Ensure -eq [Ensure]::Present) {
                return ($null -ne $vss -and $this.Equals($vss))
            }
            else {
                return ($null -eq $vss)
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostVss] Get() {
        try {
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

            $result = [VMHostVss]::new()
            $result.Server = $this.Server

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $this.GetNetworkSystem($vmHost)

            $result.Name = $vmHost.Name
            $this.PopulateResult($vmHost, $result)

            $result.Ensure = if ([string]::Empty -ne $result.Key) { 'Present' } else { 'Absent' }

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if the VMHostVss should be updated.
    #>
    [bool] Equals($vss) {
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

        $vssTest = @()
        $vssTest += ($vss.Name -eq $this.VssName)
        $vssTest += ($vss.MTU -eq $this.MTU)

        return ($vssTest -notcontains $false)
    }

    <#
    .DESCRIPTION

    Updates the configuration of the virtual switch.
    #>
    [void] UpdateVss($vmHost) {
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

        $vssConfigArgs = @{
            Name = $this.VssName
            Mtu = $this.Mtu
        }
        $vss = $this.GetVss()

        if ($this.Ensure -eq 'Present') {
            if ($null -ne $vss) {
                if ($this.Equals($vss)) {
                    return
                }
                $vssConfigArgs.Add('Operation', 'edit')
            }
            else {
                $vssConfigArgs.Add('Operation', 'add')
            }
        }
        else {
            if ($null -eq $vss) {
                return
            }
            $vssConfigArgs.Add('Operation', 'remove')
        }

        try {
            Update-Network -NetworkSystem $this.vmHostNetworkSystem -VssConfig $vssConfigArgs -ErrorAction Stop
        }
        catch {
            throw "The Virtual Switch Config could not be updated: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the virtual switch.
    #>
    [void] PopulateResult($vmHost, $vmHostVSS) {
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

        $currentVss = $this.GetVss()

        if ($null -ne $currentVss) {
            $vmHostVSS.Key = $currentVss.Key
            $vmHostVSS.Mtu = $currentVss.Mtu
            $vmHostVSS.VssName = $currentVss.Name
            $vmHostVSS.NumPortsAvailable = $currentVss.NumPortsAvailable
            $vmHostVSS.Pnic = $currentVss.Pnic
            $vmHostVSS.PortGroup = $currentVss.PortGroup
        }
        else{
            $vmHostVSS.Key = [string]::Empty
            $vmHostVSS.Mtu = $this.Mtu
            $vmHostVSS.VssName = $this.VssName
        }
    }
}

[DscResource()]
class VMHostVssBridge : VMHostVssBaseDSC {
    <#
    .DESCRIPTION

    The list of keys of the physical network adapters to be bridged.
    #>
    [DscProperty()]
    [string[]] $NicDevice

    <#
    .DESCRIPTION
    The beacon configuration to probe for the validity of a link.
    If this is set, beacon probing is configured and will be used.
    If this is not set, beacon probing is disabled.
    Determines how often, in seconds, a beacon should be sent.
    #>
    [DscProperty()]
    [nullable[int]] $BeaconInterval

    <#
    .DESCRIPTION

    The link discovery protocol, whether to advertise or listen.
    #>
    [DscProperty()]
    [LinkDiscoveryProtocolOperation] $LinkDiscoveryProtocolOperation = [LinkDiscoveryProtocolOperation]::Unset

    <#
    .DESCRIPTION

    The link discovery protocol type.
    #>
    [DscProperty()]
    [LinkDiscoveryProtocolProtocol] $LinkDiscoveryProtocolProtocol = [LinkDiscoveryProtocolProtocol]::Unset

    <#
    .DESCRIPTION

    Hidden property to have the name of the VSS Bridge type for later use.
    #>
    hidden [string] $bridgeType = 'HostVirtualSwitchBondBridge'

    [void] Set() {
        try {
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $this.GetNetworkSystem($vmHost)

            $this.UpdateVssBridge($vmHost)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $this.GetNetworkSystem($vmHost)
            $vss = $this.GetVss()

            if ($this.Ensure -eq [Ensure]::Present) {
                return ($null -ne $vss -and $this.Equals($vss))
            }
            else {
                $this.NicDevice = @()
                $this.BeaconInterval = 0
                $this.LinkDiscoveryProtocolProtocol = [LinkDiscoveryProtocolProtocol]::Unset

                return ($null -eq $vss -or $this.Equals($vss))
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostVssBridge] Get() {
        try {
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

            $result = [VMHostVssBridge]::new()
            $result.Server = $this.Server

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $this.GetNetworkSystem($vmHost)

            $result.Name = $vmHost.Name
            $this.PopulateResult($vmHost, $result)

            $result.Ensure = if ([string]::Empty -ne $result.VssName) { 'Present' } else { 'Absent' }

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if the VMHostVssBridge should to be updated.
    #>
    [bool] Equals($vss) {
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

        $vssBridgeTest = @()
        if ($null -eq $vss.Spec.Bridge) {
            $vssBridgeTest += $false
        }
        else {

            $correctType = $vss.Spec.Bridge.GetType().Name -eq $this.bridgeType
            $vssBridgeTest += $correctType
            if ($correctType) {
                $comparingResult = Compare-Object -ReferenceObject $vss.Spec.Bridge.NicDevice -DifferenceObject $this.NicDevice
                $vssBridgeTest += ($null -eq $comparingResult)
                $vssBrdigeTest += ($vss.Spec.Bridge.Beacon.Interval -eq $this.BeaconInterval)
                if ($this.LinkDiscoveryProtocolOperation -ne [LinkDiscoveryProtocolOperation]::Unset) {
                    $vssBridgeTest += ($vss.Spec.Bridge.LinkDiscoveryProtocolConfig.Operation.ToString() -eq $this.LinkDiscoveryProtocolOperation.ToString())
                }
                if ($this.LinkDiscoveryProtocolProtocol -ne [LinkDiscoveryProtocolProtocol]::Unset) {
                    $vssBridgeTest += ($vss.Spec.Bridge.LinkDiscoveryProtocolConfig.Protocol.ToString() -eq $this.LinkDiscoveryProtocolProtocol.ToString())
                }
            }
        }
        return ($vssBridgeTest -NotContains $false)
    }

    <#
    .DESCRIPTION

    Updates the Bridge configuration of the virtual switch.
    #>
    [void] UpdateVssBridge($vmHost) {
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

        $vssBridgeArgs = @{
            Name = $this.VssName
            NicDevice = $this.NicDevice
            BeaconInterval = $this.BeaconInterval
        }
        if ($this.LinkDiscoveryProtocolProtocol -ne [LinkDiscoveryProtocolProtocol]::Unset) {
            $vssBridgeArgs.Add('LinkDiscoveryProtocolProtocol', $this.LinkDiscoveryProtocolProtocol.ToString())
            $vssBridgeArgs.Add('LinkDiscoveryProtocolOperation', $this.LinkDiscoveryProtocolOperation.ToSTring())
        }
        $vss = $this.GetVss()

        if ($this.Ensure -eq 'Present') {
            if ($this.Equals($vss)) {
                return
            }
        }
        else {
            $vssBridgeArgs.NicDevice = @()
            $vssBridgeArgs.BeaconInterval = 0
        }
        $vssBridgeArgs.Add('Operation', 'edit')

        try {
            Update-Network -NetworkSystem $this.vmHostNetworkSystem -VssBridgeConfig $vssBridgeArgs -ErrorAction Stop
        }
        catch {
            throw "The Virtual Switch Bridge Config could not be updated: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the Bridge settings of the Virtual Switch.
    #>
    [void] PopulateResult($vmHost, $vmHostVSSBridge) {
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

        $currentVss = $this.GetVss()

        if ($null -ne $currentVss) {
            $vmHostVSSBridge.VssName = $currentVss.Name
            $vmHostVSSBridge.NicDevice = $currentVss.Spec.Bridge.NicDevice
            $vmHostVSSBridge.BeaconInterval = $currentVss.Spec.Bridge.Beacon.Interval

            if ($null -ne $currentVss.Spec.Bridge.linkDiscoveryProtocolConfig) {
                $vmHostVSSBridge.LinkDiscoveryProtocolOperation = $currentVss.Spec.Bridge.LinkDiscoveryProtocolConfig.Operation.ToString()
                $vmHostVSSBridge.LinkDiscoveryProtocolProtocol = $currentVss.Spec.Bridge.LinkDiscoveryProtocolConfig.Protocol.ToString()
            }
        }
        else {
            $vmHostVSSBridge.VssName = $this.VssName
            $vmHostVSSBridge.NicDevice = $this.NicDevice
            $vmHostVSSBridge.BeaconInterval = $this.BeaconInterval
            $vmHostVSSBridge.LinkDiscoveryProtocolOperation = $this.LinkDiscoveryProtocolOperation
            $vmHostVSSBridge.LinkDiscoveryProtocolProtocol = $this.LinkDiscoveryProtocolProtocol
        }
    }
}

[DscResource()]
class VMHostVssSecurity : VMHostVssBaseDSC {
    <#
    .DESCRIPTION

    The flag to indicate whether or not all traffic is seen on the port.
    #>
    [DscProperty()]
    [nullable[bool]] $AllowPromiscuous

    <#
    .DESCRIPTION

    The flag to indicate whether or not the virtual network adapter should be
    allowed to send network traffic with a different MAC address than that of
    the virtual network adapter.
    #>
    [DscProperty()]
    [nullable[bool]] $ForgedTransmits

    <#
    .DESCRIPTION

    The flag to indicate whether or not the Media Access Control (MAC) address
    can be changed.
    #>
    [DscProperty()]
    [nullable[bool]] $MacChanges

    [void] Set() {
        try {
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $this.GetNetworkSystem($vmHost)

            $this.UpdateVssSecurity($vmHost)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $this.GetNetworkSystem($vmHost)
            $vss = $this.GetVss()

            if ($this.Ensure -eq [Ensure]::Present) {
                return ($null -ne $vss -and $this.Equals($vss))
            }
            else {
                $this.AllowPromiscuous = $false
                $this.ForgedTransmits = $true
                $this.MacChanges = $true

                return ($null -eq $vss -or $this.Equals($vss))
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostVssSecurity] Get() {
        try {
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

            $result = [VMHostVssSecurity]::new()
            $result.Server = $this.Server

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $this.GetNetworkSystem($vmHost)

            $result.Name = $vmHost.Name
            $this.PopulateResult($vmHost, $result)

            $result.Ensure = if ([string]::Empty -ne $result.VssName) { 'Present' } else { 'Absent' }

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if the VMHostVssSecurity should to be updated.
    #>
    [bool] Equals($vss) {
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

        $vssSecurityTest = @()
        $vssSecurityTest += ($vss.Spec.Policy.Security.AllowPromiscuous -eq $this.AllowPromiscuous)
        $vssSecurityTest += ($vss.Spec.Policy.Security.ForgedTransmits -eq $this.ForgedTransmits)
        $vssSecurityTest += ($vss.Spec.Policy.Security.MacChanges -eq $this.MacChanges)

        return ($vssSecurityTest -notcontains $false)
    }

    <#
    .DESCRIPTION

    Updates the configuration of the virtual switch.
    #>
    [void] UpdateVssSecurity($vmHost) {
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

        $vssSecurityArgs = @{
            Name = $this.VssName
            AllowPromiscuous = $this.AllowPromiscuous
            ForgedTransmits = $this.ForgedTransmits
            MacChanges = $this.MacChanges
        }
        $vss = $this.GetVss()

        if ($this.Ensure -eq 'Present') {
            if ($this.Equals($vss)) {
                return
            }
            $vssSecurityArgs.Add('Operation', 'edit')
        }
        else {
            $vssSecurityArgs.AllowPromiscuous = $false
            $vssSecurityArgs.ForgedTransmits = $true
            $vssSecurityArgs.MacChanges = $true
            $vssSecurityArgs.Add('Operation', 'edit')
        }

        try {
            Update-Network -NetworkSystem $this.vmHostNetworkSystem -VssSecurityConfig $vssSecurityArgs -ErrorAction Stop
        }
        catch {
            throw "The Virtual Switch Security Config could not be updated: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the Security settings of the Virtual Switch.
    #>
    [void] PopulateResult($vmHost, $vmHostVSSSecurity) {
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

        $currentVss = $this.GetVss()

        if ($null -ne $currentVss) {
            $vmHostVSSSecurity.VssName = $currentVss.Name
            $vmHostVSSSecurity.AllowPromiscuous = $currentVss.Spec.Policy.Security.AllowPromiscuous
            $vmHostVSSSecurity.ForgedTransmits = $currentVss.Spec.Policy.Security.ForgedTransmits
            $vmHostVSSSecurity.MacChanges = $currentVss.Spec.Policy.Security.MacChanges
        }
        else {
            $vmHostVSSSecurity.VssName = $this.VssName
            $vmHostVSSSecurity.AllowPromiscuous = $this.AllowPromiscuous
            $vmHostVSSSecurity.ForgedTransmits = $this.ForgedTransmits
            $vmHostVSSSecurity.MacChanges = $this.MacChanges
        }
    }
}

[DscResource()]
class VMHostVssShaping : VMHostVssBaseDSC {
    <#
    .DESCRIPTION

    The average bandwidth in bits per second if shaping is enabled on the port.
    #>
    [DscProperty()]
    [nullable[long]] $AverageBandwidth

    <#
    .DESCRIPTION

    The maximum burst size allowed in bytes if shaping is enabled on the port.
    #>
    [DscProperty()]
    [nullable[long]] $BurstSize

    <#
    .DESCRIPTION

    The flag to indicate whether or not traffic shaper is enabled on the port.
    #>
    [DscProperty()]
    [nullable[bool]] $Enabled

    <#
    .DESCRIPTION

    The peak bandwidth during bursts in bits per second if traffic shaping is enabled on the port.
    #>
    [DscProperty()]
    [nullable[long]] $PeakBandwidth

    [void] Set() {
        try {
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $this.GetNetworkSystem($vmHost)

            $this.UpdateVssShaping($vmHost)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $this.GetNetworkSystem($vmHost)
            $vss = $this.GetVss()

            if ($this.Ensure -eq [Ensure]::Present) {
                return ($null -ne $vss -and $this.Equals($vss))
            }
            else {
                $this.AverageBandwidth = 100000
                $this.BurstSize = 100000
                $this.Enabled = $false
                $this.PeakBandwidth = 100000

                return ($null -eq $vss -or $this.Equals($vss))
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostVssShaping] Get() {
        try {
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

            $result = [VMHostVssShaping]::new()
            $result.Server = $this.Server

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $this.GetNetworkSystem($vmHost)

            $result.Name = $vmHost.Name
            $this.PopulateResult($vmHost, $result)

            $result.Ensure = if ([string]::Empty -ne $result.VssName) { 'Present' } else { 'Absent' }

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if the VMHostVssShaping should to be updated.
    #>
    [bool] Equals($vss) {
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

        $vssShapingTest = @()
        $vssShapingTest += ($vss.Spec.Policy.ShapingPolicy.AverageBandwidth -eq $this.AverageBandwidth)
        $vssShapingTest += ($vss.Spec.Policy.ShapingPolicy.BurstSize -eq $this.BurstSize)
        $vssShapingTest += ($vss.Spec.Policy.ShapingPolicy.Enabled -eq $this.Enabled)
        $vssShapingTest += ($vss.Spec.Policy.ShapingPolicy.PeakBandwidth -eq $this.PeakBandwidth)

        return ($vssShapingTest -notcontains $false)
    }

    <#
    .DESCRIPTION

    Updates the configuration of the virtual switch.
    #>
    [void] UpdateVssShaping($vmHost) {
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

        $vssShapingArgs = @{
            Name = $this.VssName
            AverageBandwidth = $this.AverageBandwidth
            BurstSize = $this.BurstSize
            Enabled = $this.Enabled
            PeakBandwidth = $this.PeakBandwidth
        }
        $vss = $this.GetVss()

        if ($this.Ensure -eq 'Present') {
            if ($this.Equals($vss)) {
                return
            }
            $vssShapingArgs.Add('Operation', 'edit')
        }
        else {
            $vssShapingArgs.AverageBandwidth = 100000
            $vssShapingArgs.BurstSize = 100000
            $vssShapingArgs.Enabled = $false
            $vssShapingArgs.PeakBandwidth = 100000
            $vssShapingArgs.Add('Operation', 'edit')
        }

        try {
            Update-Network -NetworkSystem $this.vmHostNetworkSystem -VssShapingConfig $vssShapingArgs -ErrorAction Stop
        }
        catch {
            throw "The Virtual Switch Shaping Policy Config could not be updated: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the Security settings of the Virtual Switch.
    #>
    [void] PopulateResult($vmHost, $vmHostVSSShaping) {
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

        $currentVss = $this.GetVss()

        if ($null -ne $currentVss) {
            $vmHostVSSShaping.VssName = $currentVss.Name
            $vmHostVSSShaping.AverageBandwidth = $currentVss.Spec.Policy.ShapingPolicy.AverageBandwidth
            $vmHostVSSShaping.BurstSize = $currentVss.Spec.Policy.ShapingPolicy.BurstSize
            $vmHostVSSShaping.Enabled = $currentVss.Spec.Policy.ShapingPolicy.Enabled
            $vmHostVSSShaping.PeakBandwidth = $currentVss.Spec.Policy.ShapingPolicy.PeakBandwidth
        }
        else {
            $vmHostVSSShaping.VssName = $this.Name
            $vmHostVSSShaping.AverageBandwidth = $this.AverageBandwidth
            $vmHostVSSShaping.BurstSize = $this.BurstSize
            $vmHostVSSShaping.Enabled = $this.Enabled
            $vmHostVSSShaping.PeakBandwidth = $this.PeakBandwidth
        }
    }
}

[DscResource()]
class VMHostVssTeaming : VMHostVssBaseDSC {
    <#
    .DESCRIPTION

    The flag to indicate whether or not to enable beacon probing
    as a method to validate the link status of a physical network adapter.
    #>
    [DscProperty()]
    [nullable[bool]] $CheckBeacon

    <#
    .DESCRIPTION

    List of active network adapters used for load balancing.
    #>
    [DscProperty()]
    [string[]] $ActiveNic

    <#
    .DESCRIPTION

    Standby network adapters used for failover.
    #>
    [DscProperty()]
    [string[]] $StandbyNic

    <#
    .DESCRIPTION

    Flag to specify whether or not to notify the physical switch if a link fails.
    #>
    [DscProperty()]
    [nullable[bool]] $NotifySwitches

    <#
    .DESCRIPTION

    Network adapter teaming policy.
    #>
    [DscProperty()]
    [NicTeamingPolicy] $Policy

    <#
    .DESCRIPTION

    The flag to indicate whether or not to use a rolling policy when restoring links.
    #>
    [DscProperty()]
    [nullable[bool]] $RollingOrder

    [void] Set() {
        try {
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $this.GetNetworkSystem($vmHost)

            $this.UpdateVssTeaming($vmHost)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $this.GetNetworkSystem($vmHost)
            $vss = $this.GetVss()

            if ($this.Ensure -eq [Ensure]::Present) {
                return ($null -ne $vss -and $this.Equals($vss))
            }
            else {
                $this.CheckBeacon = $false
                $this.ActiveNic = @()
                $this.StandbyNic = @()
                $this.NotifySwitches = $true
                $this.Policy = [NicTeamingPolicy]::Loadbalance_srcid
                $this.RollingOrder = $false

                return ($null -eq $vss -or $this.Equals($vss))
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostVssTeaming] Get() {
        try {
            Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

            $result = [VMHostVssTeaming]::new()
            $result.Server = $this.Server

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $this.GetNetworkSystem($vmHost)

            $result.Name = $vmHost.Name
            $this.PopulateResult($vmHost, $result)

            $result.Ensure = if ([string]::Empty -ne $result.VssName) { 'Present' } else { 'Absent' }

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Returns a boolean value indicating if the VMHostVssTeaming should to be updated.
    #>
    [bool] Equals($vss) {
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

        $vssTeamingTest = @()
        $vssTeamingTest += ($vss.Spec.Policy.NicTeaming.FailureCriteria.CheckBeacon -eq $this.CheckBeacon)

        if ($null -eq $vss.Spec.Policy.NicTeaming.NicOrder.ActiveNic) {
            if ($null -ne $this.ActiveNic -and $this.ActiveNic.Length -ne 0) {
                $vssTeamingTest += $false
            }
            else {
                $vssTeamingTest += $true
            }
        }
        else {
            $comparingResult = Compare-Object -ReferenceObject $vss.Spec.Policy.NicTeaming.NicOrder.ActiveNic -DifferenceObject $this.ActiveNic
            $areEqual = $null -eq $comparingResult
            $vssTeamingTest += $areEqual
        }

        if ($null -eq $vss.Spec.Policy.NicTeaming.NicOrder.StandbyNic) {
            if ($null -ne $this.StandbyNic -and $this.StandbyNic.Length -ne 0) {
                $vssTeamingTest += $false
            }
            else {
                $vssTeamingTest += $true
            }
        }
        else {
            $comparingResult = Compare-Object -ReferenceObject $vss.Spec.Policy.NicTeaming.NicOrder.StandbyNic -DifferenceObject $this.StandbyNic
            $areEqual = $null -eq $comparingResult
            $vssTeamingTest += $areEqual
        }

        $vssTeamingTest += ($vss.Spec.Policy.NicTeaming.NotifySwitches -eq $this.NotifySwitches)
        $vssTeamingTest += ($vss.Spec.Policy.NicTeaming.Policy -eq ($this.Policy).ToString().ToLower())
        $vssTeamingTest += ($vss.Spec.Policy.NicTeaming.RollingOrder -eq $this.RollingOrder)

        return ($vssTeamingTest -notcontains $false)
    }

    <#
    .DESCRIPTION

    Updates the configuration of the virtual switch.
    #>
    [void] UpdateVssTeaming($vmHost) {
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

        $vssTeamingArgs = @{
            Name = $this.VssName
            CheckBeacon = $this.CheckBeacon
            ActiveNic = $this.ActiveNic
            StandbyNic = $this.StandbyNic
            NotifySwitches = $this.NotifySwitches
            Policy = ($this.Policy).ToString().ToLower()
            RollingOrder = $this.RollingOrder
        }
        $vss = $this.GetVss()

        if ($this.Ensure -eq 'Present') {
            if ($this.Equals($vss)) {
                return
            }
            $vssTeamingArgs.Add('Operation', 'edit')
        }
        else {
            $vssTeamingArgs.CheckBeacon = $false
            $vssTeamingArgs.ActiveNic = @()
            $vssTeamingArgs.StandbyNic = @()
            $vssTeamingArgs.NotifySwitches = $true
            $vssTeamingArgs.Policy = ([NicTeamingPolicy]::Loadbalance_srcid).ToString().ToLower()
            $vssTeamingArgs.RollingOrder = $false
            $vssTeamingArgs.Add('Operation', 'edit')
        }

        try {
            Update-Network -NetworkSystem $this.vmHostNetworkSystem -VssTeamingConfig $vssTeamingArgs -ErrorAction Stop
        }
        catch {
            throw "The Virtual Switch Teaming Policy Config could not be updated: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the Security settings of the Virtual Switch.
    #>
    [void] PopulateResult($vmHost, $vmHostVSSTeaming) {
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

        $currentVss = $this.GetVss()

        if ($null -ne $currentVss) {
            $vmHostVSSTeaming.VssName = $currentVss.Name
            $vmHostVSSTeaming.CheckBeacon = $currentVss.Spec.Policy.NicTeaming.FailureCriteria.CheckBeacon
            $vmHostVSSTeaming.ActiveNic = $currentVss.Spec.Policy.NicTeaming.NicOrder.ActiveNic
            $vmHostVSSTeaming.StandbyNic = $currentVss.Spec.Policy.NicTeaming.NicOrder.StandbyNic
            $vmHostVSSTeaming.NotifySwitches = $currentVss.Spec.Policy.NicTeaming.NotifySwitches
            $vmHostVSSTeaming.Policy = [NicTeamingPolicy]$currentVss.Spec.Policy.NicTeaming.Policy
            $vmHostVSSTeaming.RollingOrder = $currentVss.Spec.Policy.NicTeaming.RollingOrder
        }
        else {
            $vmHostVSSTeaming.VssName = $this.Name
            $vmHostVSSTeaming.CheckBeacon = $this.CheckBeacon
            $vmHostVSSTeaming.ActiveNic = $this.ActiveNic
            $vmHostVSSTeaming.StandbyNic = $this.StandbyNic
            $vmHostVSSTeaming.NotifySwitches = $this.NotifySwitches
            $vmHostVSSTeaming.Policy = $this.Policy
            $vmHostVSSTeaming.RollingOrder = $this.RollingOrder
        }
    }
}

[DscResource()]
class VMHostGraphics : VMHostGraphicsBaseDSC {
    <#
    .DESCRIPTION

    Specifies the default graphics type for the specified VMHost.
    #>
    [DscProperty(Mandatory)]
    [GraphicsType] $GraphicsType

    <#
    .DESCRIPTION

    Specifies the policy for assigning shared passthrough VMs to a host graphics device.
    #>
    [DscProperty(Mandatory)]
    [SharedPassthruAssignmentPolicy] $SharedPassthruAssignmentPolicy

    [void] Set() {
    	try {
            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $vmHostGraphicsManager = $this.GetVMHostGraphicsManager($vmHost)

            $this.EnsureVMHostIsInMaintenanceMode($vmHost)
            $this.UpdateGraphicsConfiguration($vmHostGraphicsManager)
            $this.RestartVMHost($vmHost)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
    	try {
            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $vmHostGraphicsManager = $this.GetVMHostGraphicsManager($vmHost)

            return !$this.ShouldUpdateGraphicsConfiguration($vmHostGraphicsManager)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostGraphics] Get() {
        try {
            $result = [VMHostGraphics]::new()
            $result.Server = $this.Server

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $vmHostGraphicsManager = $this.GetVMHostGraphicsManager($vmHost)

            $result.Name = $vmHost.Name
            $result.GraphicsType = $vmHostGraphicsManager.GraphicsConfig.HostDefaultGraphicsType
            $result.SharedPassthruAssignmentPolicy = $vmHostGraphicsManager.GraphicsConfig.SharedPassthruAssignmentPolicy

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Checks if the Graphics Configuration needs to be updated with the desired values.
    #>
    [bool] ShouldUpdateGraphicsConfiguration($vmHostGraphicsManager) {
        if ($this.GraphicsType -ne $vmHostGraphicsManager.GraphicsConfig.HostDefaultGraphicsType) {
            return $true
        }
        elseif ($this.SharedPassthruAssignmentPolicy -ne $vmHostGraphicsManager.GraphicsConfig.SharedPassthruAssignmentPolicy) {
            return $true
        }
        else {
            return $false
        }
    }

    <#
    .DESCRIPTION

    Performs an update on the Graphics Configuration of the specified VMHost.
    #>
    [void] UpdateGraphicsConfiguration($vmHostGraphicsManager) {
        $vmHostGraphicsConfig = New-Object VMware.Vim.HostGraphicsConfig

        $vmHostGraphicsConfig.HostDefaultGraphicsType = $this.ConvertEnumValueToServerValue($this.GraphicsType)
        $vmHostGraphicsConfig.SharedPassthruAssignmentPolicy = $this.ConvertEnumValueToServerValue($this.SharedPassthruAssignmentPolicy)

        try {
            Update-GraphicsConfig -VMHostGraphicsManager $vmHostGraphicsManager -VMHostGraphicsConfig $vmHostGraphicsConfig
        }
        catch {
            throw "The Graphics Configuration of VMHost $($this.Name) could not be updated: $($_.Exception.Message)"
        }
    }
}

[DscResource()]
class VMHostGraphicsDevice : VMHostGraphicsBaseDSC {
    <#
    .DESCRIPTION

    Specifies the Graphics device identifier (ex. PCI ID).
    #>
    [DscProperty(Key)]
    [string] $Id

    <#
    .DESCRIPTION

    Specifies the graphics type for the specified Device in 'Id' property.
    #>
    [DscProperty(Mandatory)]
    [GraphicsType] $GraphicsType

    [void] Set() {
    	try {
            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $vmHostGraphicsManager = $this.GetVMHostGraphicsManager($vmHost)

            $this.EnsureVMHostIsInMaintenanceMode($vmHost)
            $this.UpdateGraphicsConfiguration($vmHostGraphicsManager)
            $this.RestartVMHost($vmHost)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
    	try {
            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $vmHostGraphicsManager = $this.GetVMHostGraphicsManager($vmHost)
            $foundDevice = $this.GetGraphicsDevice($vmHostGraphicsManager)

            return ($this.GraphicsType -eq $foundDevice.GraphicsType)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostGraphicsDevice] Get() {
        try {
            $result = [VMHostGraphicsDevice]::new()
            $result.Server = $this.Server

            $this.ConnectVIServer()
            $vmHost = $this.GetVMHost()
            $vmHostGraphicsManager = $this.GetVMHostGraphicsManager($vmHost)
            $foundDevice = $this.GetGraphicsDevice($vmHostGraphicsManager)

            $result.Name = $vmHost.Name
            $result.Id = $foundDevice.DeviceId
            $result.GraphicsType = $foundDevice.GraphicsType

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Graphics Device with the specified Id from the server.
    #>
    [PSObject] GetGraphicsDevice($vmHostGraphicsManager) {
        $foundDevice = $vmHostGraphicsManager.GraphicsConfig.DeviceType | Where-Object { $_.DeviceId -eq $this.Id }
        if ($null -eq $foundDevice) {
            throw "Device $($this.Id) was not found in the available Graphics devices."
        }

        return $foundDevice
    }

    <#
    .DESCRIPTION

    Performs an update on the Graphics Configuration of the specified VMHost by changing the Graphics Type for the
    specified Device.
    #>
    [void] UpdateGraphicsConfiguration($vmHostGraphicsManager) {
        $vmHostGraphicsConfig = New-Object VMware.Vim.HostGraphicsConfig

        $vmHostGraphicsConfig.HostDefaultGraphicsType = $vmHostGraphicsManager.GraphicsConfig.HostDefaultGraphicsType
        $vmHostGraphicsConfig.SharedPassthruAssignmentPolicy = $vmHostGraphicsManager.GraphicsConfig.SharedPassthruAssignmentPolicy
        $vmHostGraphicsConfig.DeviceType = @()

        $vmHostGraphicsConfigDeviceType = New-Object VMware.Vim.HostGraphicsConfigDeviceType
        $vmHostGraphicsConfigDeviceType.DeviceId = $this.Id
        $vmHostGraphicsConfigDeviceType.GraphicsType = $this.ConvertEnumValueToServerValue($this.GraphicsType)

        $vmHostGraphicsConfig.DeviceType += $vmHostGraphicsConfigDeviceType

        try {
            Update-GraphicsConfig -VMHostGraphicsManager $vmHostGraphicsManager -VMHostGraphicsConfig $vmHostGraphicsConfig
        }
        catch {
            throw "The Graphics Configuration of VMHost $($this.Name) could not be updated: $($_.Exception.Message)"
        }
    }
}

[DscResource()]
class DrsCluster : DatacenterInventoryBaseDSC {
    DrsCluster() {
        $this.InventoryItemFolderType = [FolderType]::Host
    }

    <#
    .DESCRIPTION

    Indicates that VMware DRS (Distributed Resource Scheduler) is enabled.
    #>
    [DscProperty()]
    [nullable[bool]] $DrsEnabled

    <#
    .DESCRIPTION

    Specifies a DRS (Distributed Resource Scheduler) automation level. The valid values are FullyAutomated, Manual, PartiallyAutomated, Disabled and Unset.
    #>
    [DscProperty()]
    [DrsAutomationLevel] $DrsAutomationLevel = [DrsAutomationLevel]::Unset

    <#
    .DESCRIPTION

    Threshold for generated ClusterRecommendations. DRS generates only those recommendations that are above the specified vmotionRate. Ratings vary from 1 to 5.
    This setting applies to Manual, PartiallyAutomated, and FullyAutomated DRS Clusters.
    #>
    [DscProperty()]
    [nullable[int]] $DrsMigrationThreshold

    <#
    .DESCRIPTION

    For availability, distributes a more even number of virtual machines across hosts.
    #>
    [DscProperty()]
    [nullable[int]] $DrsDistribution

    <#
    .DESCRIPTION

    Load balance based on consumed memory of virtual machines rather than active memory.
    This setting is recommended for clusters where host memory is not over-committed.
    #>
    [DscProperty()]
    [nullable[int]] $MemoryLoadBalancing

    <#
    .DESCRIPTION

    Controls CPU over-commitment in the cluster.
    Min value is 0 and Max value is 500.
    #>
    [DscProperty()]
    [nullable[int]] $CPUOverCommitment

    hidden [string] $DrsEnabledConfigPropertyName = 'Enabled'
    hidden [string] $DrsAutomationLevelConfigPropertyName = 'DefaultVmBehavior'
    hidden [string] $DrsMigrationThresholdConfigPropertyName = 'VmotionRate'
    hidden [string] $DrsDistributionSettingName = 'LimitVMsPerESXHostPercent'
    hidden [string] $MemoryLoadBalancingSettingName = 'PercentIdleMBInMemDemand'
    hidden [string] $CPUOverCommitmentSettingName = 'MaxVcpusPerClusterPct'

    [void] Set() {
        try {
            $this.ConnectVIServer()

            $datacenter = $this.GetDatacenter()
            $datacenterFolderName = "$($this.InventoryItemFolderType)Folder"
            $clusterLocation = $this.GetInventoryItemLocationInDatacenter($datacenter, $datacenterFolderName)
            $cluster = $this.GetInventoryItem($clusterLocation)

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $cluster) {
                    $this.AddCluster($clusterLocation)
                }
                else {
                    $this.UpdateCluster($cluster)
                }
            }
            else {
                if ($null -ne $cluster) {
                    $this.RemoveCluster($cluster)
                }
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()

            $datacenter = $this.GetDatacenter()
            $datacenterFolderName = "$($this.InventoryItemFolderType)Folder"
            $clusterLocation = $this.GetInventoryItemLocationInDatacenter($datacenter, $datacenterFolderName)
            $cluster = $this.GetInventoryItem($clusterLocation)

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $cluster) {
                    return $false
                }

                return !$this.ShouldUpdateCluster($cluster)
            }
            else {
                return ($null -eq $cluster)
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [DrsCluster] Get() {
        try {
            $result = [DrsCluster]::new()
            $result.Server = $this.Server
            $result.Location = $this.Location
            $result.DatacenterName = $this.DatacenterName
            $result.DatacenterLocation = $this.DatacenterLocation

            $this.ConnectVIServer()

            $datacenter = $this.GetDatacenter()
            $datacenterFolderName = "$($this.InventoryItemFolderType)Folder"
            $clusterLocation = $this.GetInventoryItemLocationInDatacenter($datacenter, $datacenterFolderName)
            $cluster = $this.GetInventoryItem($clusterLocation)

            $this.PopulateResult($cluster, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Checks if the Cluster option should be updated.
    #>
    [bool] ShouldUpdateOptionValue($options, $key, $desiredValue) {
        if ($null -ne $desiredValue) {
            $currentValue = ($options | Where-Object { $_.Key -eq $key }).Value

            if ($null -eq $currentValue) {
                return $true
            }
            else {
                return $desiredValue -ne $currentValue
            }
        }

        return $false
    }

    <#
    .DESCRIPTION

    Checks if the Cluster should be updated.
    #>
    [bool] ShouldUpdateCluster($cluster) {
        $drsConfig = $cluster.ExtensionData.ConfigurationEx.DrsConfig

        $shouldUpdateCluster = @()
        $shouldUpdateCluster += ($null -ne $this.DrsEnabled -and $this.DrsEnabled -ne $drsConfig.Enabled)
        $shouldUpdateCluster += ($this.DrsAutomationLevel -ne [DrsAutomationLevel]::Unset -and $this.DrsAutomationLevel.ToString() -ne $drsConfig.DefaultVmBehavior)
        $shouldUpdateCluster += ($null -ne $this.DrsMigrationThreshold -and $this.DrsMigrationThreshold -ne $drsConfig.VmotionRate)

        if ($null -ne $drsConfig.Option) {
            $shouldUpdateCluster += $this.ShouldUpdateOptionValue($drsConfig.Option, $this.DrsDistributionSettingName, $this.DrsDistribution)
            $shouldUpdateCluster += $this.ShouldUpdateOptionValue($drsConfig.Option, $this.MemoryLoadBalancingSettingName, $this.MemoryLoadBalancing)
            $shouldUpdateCluster += $this.ShouldUpdateOptionValue($drsConfig.Option, $this.CPUOverCommitmentSettingName, $this.CPUOverCommitment)
        }
        else {
            $shouldUpdateCluster += ($null -ne $this.DrsDistribution -or $null -ne $this.MemoryLoadBalancing -or $null -ne $this.CPUOverCommitment)
        }

        return ($shouldUpdateCluster -Contains $true)
    }

    <#
    .DESCRIPTION

    Populates the DrsConfig property with the desired value.
    #>
    [void] PopulateDrsConfigProperty($drsConfig, $propertyName, $propertyValue) {
        <#
            Special case where the passed property value is enum type. These type of properties
            should be populated only when their value is not equal to Unset.
            Unset means that the property was not specified in the Configuration.
        #>
        if ($propertyValue -is [DrsAutomationLevel]) {
            if ($propertyValue -ne [DrsAutomationLevel]::Unset) {
                $drsConfig.$propertyName = $propertyValue.ToString()
            }
        }
        elseif ($null -ne $propertyValue) {
            $drsConfig.$propertyName = $propertyValue
        }
    }

    <#
    .DESCRIPTION

    Returns the Option array for the DrsConfig with the specified options in the Configuration.
    #>
    [PSObject] GetOptionsForDrsConfig($allOptions) {
        $drsConfigOptions = @()

        foreach ($key in $allOptions.Keys) {
            if ($null -ne $allOptions.$key) {
                $option = New-Object VMware.Vim.OptionValue

                $option.Key = $key
                $option.Value = $allOptions.$key.ToString()

                $drsConfigOptions += $option
            }
        }

        return $drsConfigOptions
    }

    <#
    .DESCRIPTION

    Returns the populated Cluster Spec with the specified values in the Configuration.
    #>
    [PSObject] GetPopulatedClusterSpec() {
        $clusterSpec = New-Object VMware.Vim.ClusterConfigSpecEx
        $clusterSpec.DrsConfig = New-Object VMware.Vim.ClusterDrsConfigInfo

        $this.PopulateDrsConfigProperty($clusterSpec.DrsConfig, $this.DrsEnabledConfigPropertyName, $this.DrsEnabled)
        $this.PopulateDrsConfigProperty($clusterSpec.DrsConfig, $this.DrsAutomationLevelConfigPropertyName, $this.DrsAutomationLevel)
        $this.PopulateDrsConfigProperty($clusterSpec.DrsConfig, $this.DrsMigrationThresholdConfigPropertyName, $this.DrsMigrationThreshold)

        $allOptions = [ordered] @{
            $this.DrsDistributionSettingName = $this.DrsDistribution
            $this.MemoryLoadBalancingSettingName = $this.MemoryLoadBalancing
            $this.CPUOverCommitmentSettingName = $this.CPUOverCommitment
        }

        $clusterSpec.DrsConfig.Option = $this.GetOptionsForDrsConfig($allOptions)

        return $clusterSpec
    }

    <#
    .DESCRIPTION

    Creates a new Cluster with the specified properties at the specified location.
    #>
    [void] AddCluster($clusterLocation) {
        $clusterSpec = $this.GetPopulatedClusterSpec()

        try {
            Add-Cluster -Folder $clusterLocation.ExtensionData -Name $this.Name -Spec $clusterSpec
        }
        catch {
            throw "Server operation failed with the following error: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Updates the Cluster with the specified properties.
    #>
    [void] UpdateCluster($cluster) {
        $clusterSpec = $this.GetPopulatedClusterSpec()

        try {
            Update-ClusterComputeResource -ClusterComputeResource $cluster.ExtensionData -Spec $clusterSpec
        }
        catch {
            throw "Server operation failed with the following error: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Removes the Cluster from the specified Datacenter.
    #>
    [void] RemoveCluster($cluster) {
        try {
            Remove-ClusterComputeResource -ClusterComputeResource $cluster.ExtensionData
        }
        catch {
            throw "Server operation failed with the following error: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the Cluster from the server.
    #>
    [void] PopulateResult($cluster, $result) {
        if ($null -ne $cluster) {
            $drsConfig = $cluster.ExtensionData.ConfigurationEx.DrsConfig

            $result.Name = $cluster.Name
            $result.Ensure = [Ensure]::Present
            $result.DrsEnabled = $drsConfig.Enabled

            if ($null -eq $drsConfig.DefaultVmBehavior) {
                $result.DrsAutomationLevel = [DrsAutomationLevel]::Unset
            }
            else {
                $result.DrsAutomationLevel = $drsConfig.DefaultVmBehavior.ToString()
            }

            $result.DrsMigrationThreshold = $drsConfig.VmotionRate

            if ($null -ne $drsConfig.Option) {
                $options = $drsConfig.Option

                $result.DrsDistribution = ($options | Where-Object { $_.Key -eq $this.DrsDistributionSettingName }).Value
                $result.MemoryLoadBalancing = ($options | Where-Object { $_.Key -eq $this.MemoryLoadBalancingSettingName }).Value
                $result.CPUOverCommitment = ($options | Where-Object { $_.Key -eq $this.CPUOverCommitmentSettingName }).Value
            }
            else {
                $result.DrsDistribution = $null
                $result.MemoryLoadBalancing = $null
                $result.CPUOverCommitment = $null
            }
        }
        else {
            $result.Name = $this.Name
            $result.Ensure = [Ensure]::Absent
            $result.DrsEnabled = $this.DrsEnabled
            $result.DrsAutomationLevel = $this.DrsAutomationLevel
            $result.DrsMigrationThreshold = $this.DrsMigrationThreshold
            $result.DrsDistribution = $this.DrsDistribution
            $result.MemoryLoadBalancing = $this.MemoryLoadBalancing
            $result.CPUOverCommitment = $this.CPUOverCommitment
        }
    }
}

[DscResource()]
class HACluster : DatacenterInventoryBaseDSC {
    HACluster() {
        $this.InventoryItemFolderType = [FolderType]::Host
    }

    <#
    .DESCRIPTION

    Indicates that VMware HA (High Availability) is enabled.
    #>
    [DscProperty()]
    [nullable[bool]] $HAEnabled

    <#
    .DESCRIPTION

    Indicates that virtual machines cannot be powered on if they violate availability constraints.
    #>
    [DscProperty()]
    [nullable[bool]] $HAAdmissionControlEnabled

    <#
    .DESCRIPTION

    Specifies a configured failover level.
    This is the number of physical host failures that can be tolerated without impacting the ability to meet minimum thresholds for all running virtual machines.
    The valid values range from 1 to 4.
    #>
    [DscProperty()]
    [nullable[int]] $HAFailoverLevel

    <#
    .DESCRIPTION

    Indicates that the virtual machine should be powered off if a host determines that it is isolated from the rest of the compute resource.
    The valid values are PowerOff, DoNothing, Shutdown and Unset.
    #>
    [DscProperty()]
    [HAIsolationResponse] $HAIsolationResponse = [HAIsolationResponse]::Unset

    <#
    .DESCRIPTION

    Specifies the cluster HA restart priority. The valid values are Disabled, Low, Medium, High and Unset.
    VMware HA is a feature that detects failed virtual machines and automatically restarts them on alternative ESX hosts.
    #>
    [DscProperty()]
    [HARestartPriority] $HARestartPriority = [HARestartPriority]::Unset

    hidden [string] $HAEnabledParameterName = 'HAEnabled'
    hidden [string] $HAAdmissionControlEnabledParameterName = 'HAAdmissionControlEnabled'
    hidden [string] $HAFailoverLevelParameterName = 'HAFailoverLevel'
    hidden [string] $HAIsolationResponseParameterName = 'HAIsolationResponse'
    hidden [string] $HARestartPriorityParemeterName = 'HARestartPriority'

    [void] Set() {
        try {
            $this.ConnectVIServer()

            $datacenter = $this.GetDatacenter()
            $datacenterFolderName = "$($this.InventoryItemFolderType)Folder"
            $clusterLocation = $this.GetInventoryItemLocationInDatacenter($datacenter, $datacenterFolderName)
            $cluster = $this.GetInventoryItem($clusterLocation)

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $cluster) {
                    $this.AddCluster($clusterLocation)
                }
                else {
                    $this.UpdateCluster($cluster)
                }
            }
            else {
                if ($null -ne $cluster) {
                    $this.RemoveCluster($cluster)
                }
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [bool] Test() {
        try {
            $this.ConnectVIServer()

            $datacenter = $this.GetDatacenter()
            $datacenterFolderName = "$($this.InventoryItemFolderType)Folder"
            $clusterLocation = $this.GetInventoryItemLocationInDatacenter($datacenter, $datacenterFolderName)
            $cluster = $this.GetInventoryItem($clusterLocation)

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $cluster) {
                    return $false
                }

                return !$this.ShouldUpdateCluster($cluster)
            }
            else {
                return ($null -eq $cluster)
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [HACluster] Get() {
        try {
            $result = [HACluster]::new()
            $result.Server = $this.Server
            $result.Location = $this.Location
            $result.DatacenterName = $this.DatacenterName
            $result.DatacenterLocation = $this.DatacenterLocation

            $this.ConnectVIServer()

            $datacenter = $this.GetDatacenter()
            $datacenterFolderName = "$($this.InventoryItemFolderType)Folder"
            $clusterLocation = $this.GetInventoryItemLocationInDatacenter($datacenter, $datacenterFolderName)
            $cluster = $this.GetInventoryItem($clusterLocation)

            $this.PopulateResult($cluster, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Checks if the Cluster should be updated.
    #>
    [bool] ShouldUpdateCluster($cluster) {
        $shouldUpdateCluster = @()
        $shouldUpdateCluster += ($null -ne $this.HAEnabled -and $this.HAEnabled -ne $cluster.HAEnabled)
        $shouldUpdateCluster += ($null -ne $this.HAAdmissionControlEnabled -and $this.HAAdmissionControlEnabled -ne $cluster.HAAdmissionControlEnabled)
        $shouldUpdateCluster += ($null -ne $this.HAFailoverLevel -and $this.HAFailoverLevel -ne $cluster.HAFailoverLevel)

        if ($this.HAIsolationResponse -ne [HAIsolationResponse]::Unset) {
            if ($null -ne $cluster.HAIsolationResponse) {
                $shouldUpdateCluster += ($this.HAIsolationResponse.ToString() -ne $cluster.HAIsolationResponse.ToString())
            }
            else {
                $shouldUpdateCluster += $true
            }
        }

        if ($this.HARestartPriority -ne [HARestartPriority]::Unset) {
            if ($null -ne $cluster.HARestartPriority) {
                $shouldUpdateCluster += ($this.HARestartPriority.ToString() -ne $cluster.HARestartPriority.ToString())
            }
            else {
                $shouldUpdateCluster += $true
            }
        }

        return ($shouldUpdateCluster -Contains $true)
    }

    <#
    .DESCRIPTION

    Populates the parameters for the New-Cluster and Set-Cluster cmdlets.
    #>
    [void] PopulateClusterParams($clusterParams, $parameter, $desiredValue) {
        <#
            Special case where the desired value is enum type. These type of properties
            should be added as parameters to the cmdlet only when their value is not equal to Unset.
            Unset means that the property was not specified in the Configuration.
        #>
        if ($desiredValue -is [HAIsolationResponse] -or $desiredValue -is [HARestartPriority]) {
            if ($desiredValue -ne 'Unset') {
                $clusterParams.$parameter = $desiredValue.ToString()
            }

            return
        }

        if ($null -ne $desiredValue) {
            $clusterParams.$parameter = $desiredValue
        }
    }

    <#
    .DESCRIPTION

    Returns the populated Cluster parameters.
    #>
    [hashtable] GetClusterParams() {
        $clusterParams = @{}

        $clusterParams.Server = $this.Connection
        $clusterParams.Confirm = $false
        $clusterParams.ErrorAction = 'Stop'

        $this.PopulateClusterParams($clusterParams, $this.HAEnabledParameterName, $this.HAEnabled)
        $this.PopulateClusterParams($clusterParams, $this.HAAdmissionControlEnabledParameterName, $this.HAAdmissionControlEnabled)
        $this.PopulateClusterParams($clusterParams, $this.HAFailoverLevelParameterName, $this.HAFailoverLevel)
        $this.PopulateClusterParams($clusterParams, $this.HAIsolationResponseParameterName, $this.HAIsolationResponse)
        $this.PopulateClusterParams($clusterParams, $this.HARestartPriorityParemeterName, $this.HARestartPriority)

        return $clusterParams
    }

    <#
    .DESCRIPTION

    Creates a new Cluster with the specified properties at the specified location.
    #>
    [void] AddCluster($clusterLocation) {
        $clusterParams = $this.GetClusterParams()
        $clusterParams.Name = $this.Name
        $clusterParams.Location = $clusterLocation

        try {
            New-Cluster @clusterParams
        }
        catch {
            throw "Cannot create Cluster $($this.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Updates the Cluster with the specified properties.
    #>
    [void] UpdateCluster($cluster) {
        $clusterParams = $this.GetClusterParams()

        try {
            $cluster | Set-Cluster @clusterParams
        }
        catch {
            throw "Cannot update Cluster $($this.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Removes the Cluster from the specified Datacenter.
    #>
    [void] RemoveCluster($cluster) {
        try {
            $cluster | Remove-Cluster -Server $this.Connection -Confirm:$false -ErrorAction Stop
        }
        catch {
            throw "Cannot remove Cluster $($this.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method with the values of the Cluster from the server.
    #>
    [void] PopulateResult($cluster, $result) {
        if ($null -ne $cluster) {
            $result.Name = $cluster.Name
            $result.Ensure = [Ensure]::Present
            $result.HAEnabled = $cluster.HAEnabled
            $result.HAAdmissionControlEnabled = $cluster.HAAdmissionControlEnabled
            $result.HAFailoverLevel = $cluster.HAFailoverLevel
            $result.HAIsolationResponse = $cluster.HAIsolationResponse.ToString()
            $result.HARestartPriority = $cluster.HARestartPriority.ToString()
        }
        else {
            $result.Name = $this.Name
            $result.Ensure = [Ensure]::Absent
            $result.HAEnabled = $this.HAEnabled
            $result.HAAdmissionControlEnabled = $this.HAAdmissionControlEnabled
            $result.HAFailoverLevel = $this.HAFailoverLevel
            $result.HAIsolationResponse = $this.HAIsolationResponse
            $result.HARestartPriority = $this.HARestartPriority
        }
    }
}
