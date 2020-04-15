<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

Using module '.\VMware.vSphereDSC.Helper.psm1'
Using module '.\VMware.vSphereDSC.Logging.psm1'

enum AcceptanceLevel {
    VMwareCertified
    VMwareAccepted
    PartnerSupported
    CommunitySupported
}

enum ChapType {
    Prohibited
    Discouraged
    Preferred
    Required
    Unset
}

enum DomainAction {
    Join
    Leave
}

enum Duplex {
    Full
    Half
    Unset
}

enum Ensure {
    Absent
    Present
}

enum EntityType {
    Folder
    Datacenter
    Cluster
    Datastore
    DatastoreCluster
    VMHost
    ResourcePool
    VApp
    VM
    Template
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

enum IScsiHbaTargetType {
    Static
    Send
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

enum MultipathPolicy {
    Fixed
    MostRecentlyUsed
    RoundRobin
    Unknown
    Unset
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

enum VMHostState {
    Connected
    Disconnected
    Maintenance
    Unset
}

enum VMSwapfilePolicy {
    InHostDatastore
    WithVM
    Unset
}

enum VsanDataMigrationMode {
    Full
    EnsureAccessibility
    NoDataMigration
    Unset
}

enum AccessMode {
    ReadWrite
    ReadOnly
}

enum AuthenticationMethod {
    AUTH_SYS
    Kerberos
}

enum NicTeamingPolicy {
    Loadbalance_ip
    Loadbalance_srcmac
    Loadbalance_srcid
    Failover_explicit
    Unset
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

    hidden [string] $DscResourceName = $this.GetType().Name
    hidden [string] $DscResourceIsInDesiredStateMessage = "{0} DSC Resource is in Desired State."
    hidden [string] $DscResourceIsNotInDesiredStateMessage = "{0} DSC Resource is not in Desired State."

    hidden [string] $TestMethodStartMessage = "Begin executing Test functionality for {0} DSC Resource."
    hidden [string] $TestMethodEndMessage = "End executing Test functionality for {0} DSC Resource."
    hidden [string] $SetMethodStartMessage = "Begin executing Set functionality for {0} DSC Resource."
    hidden [string] $SetMethodEndMessage = "End executing Set functionality for {0} DSC Resource."
    hidden [string] $GetMethodStartMessage = "Begin executing Get functionality for {0} DSC Resource."
    hidden [string] $GetMethodEndMessage = "End executing Get functionality for {0} DSC Resource."

    hidden [string] $vCenterProductId = 'vpx'
    hidden [string] $ESXiProductId = 'embeddedEsx'

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

    Checks if the Connection is directly to an ESXi host and if not, throws an exception.
    #>
    [void] EnsureConnectionIsESXi() {
        if ($this.Connection.ProductLine -ne $this.ESXiProductId) {
            throw 'The Resource operations are only supported when connection is directly to an ESXi host.'
        }
    }

    <#
    .DESCRIPTION

    Writes a Verbose message specifying if the DSC Resource is in the Desired State.
    #>
    [void] WriteDscResourceState($result) {
        if ($result) {
            Write-VerboseLog -Message $this.DscResourceIsInDesiredStateMessage -Arguments @($this.DscResourceName)
        }
        else {
            Write-VerboseLog -Message $this.DscResourceIsNotInDesiredStateMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Checks if the specified VIObject is of the specified type.
    #>
    [bool] IsVIObjectOfTheCorrectType($viObject, $typeAsString) {
        $result = $false
        $viObjectType = $viObject.GetType()

        if ($viObjectType.FullName -eq $typeAsString) {
            $result = $true
        }
        elseif (($viObjectType.GetInterfaces().FullName -eq $typeAsString).Length -gt 0) {
            $result = $true
        }
        else {
            $baseType = $viObjectType.BaseType

            while ($null -ne $baseType) {
                if ($baseType.FullName -eq $typeAsString) {
                    $result = $true
                    break
                }

                $baseType = $baseType.BaseType
            }
        }

        return $result
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

class DatastoreBaseDSC : VMHostEntityBaseDSC {
    <#
    .DESCRIPTION

    Specifies the name of the Datastore.
    #>
    [DscProperty(Key)]
    [string] $Name

    <#
    .DESCRIPTION

    For Nfs Datastore, specifies the remote path of the Nfs mount point.
    For Vmfs Datastore, specifies the canonical name of the Scsi logical unit that contains the Vmfs Datastore.
    #>
    [DscProperty(Mandatory)]
    [string] $Path

    <#
    .DESCRIPTION

    Specifies whether the Datastore should be present or absent.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    <#
    .DESCRIPTION

    Specifies the file system that is used on the Datastore.
    #>
    [DscProperty()]
    [string] $FileSystemVersion

    <#
    .DESCRIPTION

    Specifies the latency period beyond which the storage array is considered congested. The range of this value is between 10 to 100 milliseconds.
    #>
    [DscProperty()]
    [nullable[int]] $CongestionThresholdMillisecond

    <#
    .DESCRIPTION

    Indicates whether the IO control is enabled.
    #>
    [DscProperty()]
    [nullable[bool]] $StorageIOControlEnabled

    hidden [string] $CreateDatastoreMessage = "Creating Datastore {0} on VMHost {1}."
    hidden [string] $ModifyDatastoreMessage = "Modifying Datastore {0} on VMHost {1}."
    hidden [string] $RemoveDatastoreMessage = "Removing Datastore {0} from VMHost {1}."

    hidden [string] $CouldNotCreateDatastoreWithTheSpecifiedNameMessage = "Could not create Datastore {0} on VMHost {1} because there is another Datastore with the same name on vCenter Server {2}."
    hidden [string] $CouldNotCreateDatastoreMessage = "Could not create Datastore {0} on VMHost {1}. For more information: {2}"
    hidden [string] $CouldNotModifyDatastoreMessage = "Could not modify Datastore {0} on VMHost {1}. For more information: {2}"
    hidden [string] $CouldNotRemoveDatastoreMessage = "Could not remove Datastore {0} from VMHost {1}. For more information: {2}"

    <#
    .DESCRIPTION

    Retrieves the Datastore with the specified name from the VMHost if it exists.
    #>
    [PSObject] GetDatastore() {
        $getDatastoreParams = @{
            Server = $this.Connection
            Name = $this.Name
            VMHost = $this.VMHost
            ErrorAction = 'SilentlyContinue'
            Verbose = $false
        }

        $datastore = Get-Datastore @getDatastoreParams

        <#
        If the established connection is to a vCenter Server, Ensure is 'Present' and the Datastore does not exist on the specified VMHost,
        we need to check if there is a Datastore with the same name on the vCenter Server.
        #>
        if ($this.Connection.ProductLine -eq $this.vCenterProductId -and $this.Ensure -eq [Ensure]::Present -and $null -eq $datastore) {
            # We need to remove the filter by VMHost from the hashtable to search for the Datastore in the whole vCenter Server.
            $getDatastoreParams.Remove('VMHost')

            <#
            If there is another Datastore with the same name on the vCenter Server but on a different VMHost, we need to inform the user that the Datastore cannot be created with the
            specified name. vCenter Server accepts multiple Datastore creations with the same name but changes the names internally to avoid name duplication.
            vCenter Server appends '(<index>)' to the Datastore name.
            #>
            $datastoreInvCenter = Get-Datastore @getDatastoreParams
            if ($null -ne $datastoreInvCenter) {
                throw ($this.CouldNotCreateDatastoreWithTheSpecifiedNameMessage -f $this.Name, $this.VMHost.Name, $this.Connection.Name)
            }
        }

        return $datastore
    }

    <#
    .DESCRIPTION

    Checks if the specified Datastore should be modified.
    #>
    [bool] ShouldModifyDatastore($datastore) {
        $shouldModifyDatastore = @()

        $shouldModifyDatastore += ($null -ne $this.CongestionThresholdMillisecond -and $this.CongestionThresholdMillisecond -ne $datastore.CongestionThresholdMillisecond)
        $shouldModifyDatastore += ($null -ne $this.StorageIOControlEnabled -and $this.StorageIOControlEnabled -ne $datastore.StorageIOControlEnabled)

        return ($shouldModifyDatastore -Contains $true)
    }

    <#
    .DESCRIPTION

    Creates a new Datastore with the specified name on the VMHost.
    #>
    [PSObject] NewDatastore($newDatastoreParams) {
        $newDatastoreParams.Server = $this.Connection
        $newDatastoreParams.Name = $this.Name
        $newDatastoreParams.VMHost = $this.VMHost
        $newDatastoreParams.Path = $this.Path
        $newDatastoreParams.Confirm = $false
        $newDatastoreParams.ErrorAction = 'Stop'
        $newDatastoreParams.Verbose = $false

        if (![string]::IsNullOrEmpty($this.FileSystemVersion)) { $newDatastoreParams.FileSystemVersion = $this.FileSystemVersion }

        try {
            Write-VerboseLog -Message $this.CreateDatastoreMessage -Arguments @($this.Name, $this.VMHost.Name)
            $datastore = New-Datastore @newDatastoreParams

            return $datastore
        }
        catch {
            throw ($this.CouldNotCreateDatastoreMessage -f $this.Name, $this.VMHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Modifies the properties of the specified Datastore.
    #>
    [void] ModifyDatastore($datastore) {
        $setDatastoreParams = @{
            Server = $this.Connection
            Datastore = $datastore
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        if ($null -ne $this.StorageIOControlEnabled) { $setDatastoreParams.StorageIOControlEnabled = $this.StorageIOControlEnabled }
        if ($null -ne $this.CongestionThresholdMillisecond) { $setDatastoreParams.CongestionThresholdMillisecond = $this.CongestionThresholdMillisecond }

        try {
            Write-VerboseLog -Message $this.ModifyDatastoreMessage -Arguments @($datastore.Name, $this.VMHost.Name)
            Set-Datastore @setDatastoreParams
        }
        catch {
            throw ($this.CouldNotModifyDatastoreMessage -f $datastore.Name, $this.VMHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Removes the specified Datastore from the VMHost.
    #>
    [void] RemoveDatastore($datastore) {
        $removeDatastoreParams = @{
            Server = $this.Connection
            Datastore = $datastore
            VMHost = $thiS.VMHost
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        try {
            Write-VerboseLog -Message $this.RemoveDatastoreMessage -Arguments @($datastore.Name, $this.VMHost.Name)
            Remove-Datastore @removeDatastoreParams
        }
        catch {
            throw ($this.CouldNotRemoveDatastoreMessage -f $datastore.Name, $this.VMHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $datastore) {
        $result.Server = $this.Connection.Name
        $result.VMHostName = $this.VMHost.Name

        if ($null -ne $datastore) {
            $result.Name = $datastore.Name
            $result.Ensure = [Ensure]::Present
            $result.FileSystemVersion = $datastore.FileSystemVersion
            $result.CongestionThresholdMillisecond = $datastore.CongestionThresholdMillisecond
            $result.StorageIOControlEnabled = $datastore.StorageIOControlEnabled
        }
        else {
            $result.Name = $this.Name
            $result.Ensure = [Ensure]::Absent
            $result.FileSystemVersion = $this.FileSystemVersion
            $result.CongestionThresholdMillisecond = $this.CongestionThresholdMillisecond
            $result.StorageIOControlEnabled = $this.StorageIOControlEnabled
        }
    }
}

class VMHostBaseDSC : BaseDSC {
    <#
    .DESCRIPTION

    Specifies the name of the VMHost to configure.
    #>
    [DscProperty(Key)]
    [string] $Name

    hidden [string] $CouldNotRetrieveVMHostMessage = "Could not retrieve VMHost {0} on Server {1}. For more information: {2}"

    <#
    .DESCRIPTION

    Retrieves the VMHost with the specified name from the specified Server.
    If the VMHost is not found, the method throws an exception.
    #>
    [PSObject] GetVMHost() {
        try {
            $getVMHostParams = @{
                Server = $this.Connection
                Name = $this.Name
                ErrorAction = 'Stop'
                Verbose = $false
            }

            return Get-VMHost @getVMHostParams
        }
        catch {
            throw ($this.CouldNotRetrieveVMHostMessage -f $this.Name, $this.Connection.Name, $_.Exception.Message)
        }
    }
}

class EsxCliBaseDSC : VMHostBaseDSC {
    <#
    .DESCRIPTION

    The PowerCLI EsxCli version 2 interface to ESXCLI.
    #>
    hidden [PSObject] $EsxCli

    <#
    .DESCRIPTION

    The EsxCli command for the DSC Resource that inherits the base class.
    For the DCUI Keyboard DSC Resource the command is the following: 'system.settings.keyboard.layout'.
    #>
    hidden [string] $EsxCliCommand

    <#
    .DESCRIPTION

    The name of the DSC Resource that inherits the base class.
    #>
    hidden [string] $DscResourceName = $this.GetType().Name

    hidden [string] $EsxCliAddMethodName = 'add'
    hidden [string] $EsxCliSetMethodName = 'set'
    hidden [string] $EsxCliRemoveMethodName = 'remove'
    hidden [string] $EsxCliGetMethodName = 'get'
    hidden [string] $EsxCliListMethodName = 'list'

    hidden [string] $CouldNotRetrieveEsxCliInterfaceMessage = "Could not retrieve EsxCli interface for VMHost {0}. For more information: {1}"
    hidden [string] $CouldNotCreateMethodArgumentsMessage = "Could not create arguments for {0} method. For more information: {1}"
    hidden [string] $EsxCliCommandFailedMessage = "EsxCli command {0} failed to execute successfully. For more information: {1}"

    <#
    .DESCRIPTION

    Retrieves the EsxCli version 2 interface to ESXCLI for the specified VMHost.
    #>
    [void] GetEsxCli($vmHost) {
        try {
            $this.EsxCli = Get-EsxCli -Server $this.Connection -VMHost $vmHost -V2 -ErrorAction Stop -Verbose:$false
        }
        catch {
            throw ($this.CouldNotRetrieveEsxCliInterfaceMessage -f $vmHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Executes the specified method for modification - 'set', 'add' or 'remove' of the specified EsxCli command.
    #>
    [void] ExecuteEsxCliModifyMethod($methodName, $methodArguments) {
        $esxCliCommandMethod = "$($this.EsxCliCommand).$methodName."
        $esxCliMethodArgs = $null

        try {
            $esxCliMethodArgs = Invoke-Expression -Command ("`$this.EsxCli." + $esxCliCommandMethod + 'CreateArgs()') -ErrorAction Stop -Verbose:$false
        }
        catch {
            throw ($this.CouldNotCreateMethodArgumentsMessage -f $methodName, $_.Exception.Message)
        }

        # Skips the properties that are defined in the base classes of the Dsc Resource because they are not arguments of the EsxCli command.
        $dscResourceNamesOfProperties = $this.GetType().GetProperties() |
                                        Where-Object -FilterScript { $_.DeclaringType.Name -eq $this.DscResourceName } |
                                        Select-Object -ExpandProperty Name

        # A separate array of keys is needed because collections cannot be modified while being enumerated.
        $commandArgs = @()
        $commandArgs = $commandArgs + $esxCliMethodArgs.Keys
        foreach ($key in $commandArgs) {
            # The argument of the method is present in the method arguments hashtable and should be used instead of the property of the Dsc Resource.
            if ($methodArguments.Count -gt 0 -and $null -ne $methodArguments.$key) {
                $esxCliMethodArgs.$key = $methodArguments.$key
            }
            else {
                # The name of the property of the Dsc Resource starts with a capital letter whereas the key of the argument contains only lower case letters.
                $dscResourcePropertyName = $dscResourceNamesOfProperties | Where-Object -FilterScript { $_.ToLower() -eq $key.ToLower() }

                # Not all properties of the Dsc Resource are part of the arguments hashtable.
                if ($null -ne $dscResourcePropertyName) {
                    if ($this.$dscResourcePropertyName -is [string]) {
                        if (![string]::IsNullOrEmpty($this.$dscResourcePropertyName)) { $esxCliMethodArgs.$key = $this.$dscResourcePropertyName }
                    }
                    elseif ($this.$dscResourcePropertyName -is [array]) {
                        if ($null -ne $this.$dscResourcePropertyName -and $this.$dscResourcePropertyName.Length -gt 0) { $esxCliMethodArgs.$key = $this.$dscResourcePropertyName }
                    }
                    else {
                        if ($null -ne $this.$dscResourcePropertyName) { $esxCliMethodArgs.$key = $this.$dscResourcePropertyName }
                    }
                }
            }
        }

        try {
            Invoke-EsxCliCommandMethod -EsxCli $this.EsxCli -EsxCliCommandMethod ($esxCliCommandMethod + 'Invoke({0})') -EsxCliCommandMethodArguments $esxCliMethodArgs
        }
        catch {
            throw ($this.EsxCliCommandFailedMessage -f ('esxcli.' + $this.EsxCliCommand), $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Executes the specified method for modification - 'set', 'add' or 'remove' of the specified EsxCli command.
    #>
    [void] ExecuteEsxCliModifyMethod($methodName) {
        $this.ExecuteEsxCliModifyMethod($methodName, @{})
    }

    <#
    .DESCRIPTION

    Executes the specified retrieval method - 'get' or 'list' of the specified EsxCli command.
    #>
    [PSObject] ExecuteEsxCliRetrievalMethod($methodName) {
        $esxCliCommandMethod = '$this.EsxCli.' + "$($this.EsxCliCommand).$methodName."

        try {
            $esxCliCommandMethodResult = Invoke-Expression -Command ($esxCliCommandMethod + 'Invoke()') -ErrorAction Stop -Verbose:$false
            return $esxCliCommandMethodResult
        }
        catch {
            throw ($this.EsxCliCommandFailedMessage -f ('esxcli.' + $this.EsxCliCommand), $_.Exception.Message)
        }
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

class VMHostRestartBaseDSC : VMHostBaseDSC {
    <#
    .DESCRIPTION

    Specifies the time in minutes to wait for the VMHost to restart before timing out
    and aborting the operation. The default value is 5 minutes.
    #>
    [DscProperty()]
    [int] $RestartTimeoutMinutes = 5

    hidden [string] $NotRespondingState = 'NotResponding'
    hidden [string] $MaintenanceState = 'Maintenance'

    hidden [string] $VMHostIsRestartedSuccessfullyMessage = "VMHost {0} is successfully restarted and in {1} State."
    hidden [string] $VMHostIsStillNotInDesiredStateMessage = "VMHost {0} is still not in {1} State."
    hidden [string] $RestartVMHostMessage = "Restarting VMHost {0}."

    hidden [string] $VMHostIsNotInMaintenanceModeMessage = "The Resource update operation requires the VMHost {0} to be in a Maintenance mode."
    hidden [string] $CouldNotRestartVMHostInTimeMessage = "VMHost {0} could not be restarted successfully in {1} minutes."
    hidden [string] $CouldNotRestartVMHostMessage = "Could not restart VMHost {0}. For more information: {1}"

    <#
    .DESCRIPTION

    Checks if the specified VMHost is in Maintenance mode and if not, throws an exception.
    #>
    [void] EnsureVMHostIsInMaintenanceMode($vmHost) {
        if ($vmHost.ConnectionState.ToString() -ne $this.MaintenanceState) {
            throw ($this.VMHostIsNotInMaintenanceModeMessage -f $vmHost.Name)
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
            throw ($this.CouldNotRestartVMHostInTimeMessage -f $this.Name, $this.RestartTimeoutMinutes)
        }
    }

    <#
    .DESCRIPTION

    Ensures that the specified VMHost is in a Desired State after successful restart operation.
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

                Write-VerboseLog -Message $this.VMHostIsStillNotInDesiredStateMessage -Arguments @($this.Name, $desiredState)
            }
            catch {
                <#
                Here the message used in the try block is written again in the case when an exception is thrown
                when retrieving the VMHost or establishing a Connection. This way the user still gets notified
                that the VMHost is not in the Desired State.
                #>
                Write-VerboseLog -Message $this.VMHostIsStillNotInDesiredStateMessage -Arguments @($this.Name, $desiredState)
            }
        }

        Write-VerboseLog -Message $this.VMHostIsRestartedSuccessfullyMessage -Arguments @($this.Name, $desiredState)
    }

    <#
    .DESCRIPTION

    Restarts the specified VMHost so that the update of the VMHost Configuration is successful.
    #>
    [void] RestartVMHost($vmHost) {
        try {
            $restartVMHostParams = @{
                Server = $this.Connection
                VMHost = $vmHost
                Confirm = $false
                ErrorAction = 'Stop'
                Verbose = $false
            }

            Write-VerboseLog -Message $this.RestartVMHostMessage -Arguments @($vmHost.Name)
            Restart-VMHost @restartVMHostParams
        }
        catch {
            throw ($this.CouldNotRestartVMHostMessage -f $vmHost.Name, $_.Exception.Message)
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

class VMHostGraphicsBaseDSC : VMHostRestartBaseDSC {
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

class VMHostIScsiHbaBaseDSC : VMHostEntityBaseDSC {
    <#
    .DESCRIPTION

    Specifies the type of the CHAP (Challenge Handshake Authentication Protocol).
    #>
    [DscProperty()]
    [ChapType] $ChapType = [ChapType]::Unset

    <#
    .DESCRIPTION

    Specifies the CHAP authentication name.
    #>
    [DscProperty()]
    [string] $ChapName

    <#
    .DESCRIPTION

    Specifies the CHAP authentication password.
    #>
    [DscProperty()]
    [string] $ChapPassword

    <#
    .DESCRIPTION

    Indicates that Mutual CHAP is enabled.
    #>
    [DscProperty()]
    [nullable[bool]] $MutualChapEnabled

    <#
    .DESCRIPTION

    Specifies the Mutual CHAP authentication name.
    #>
    [DscProperty()]
    [string] $MutualChapName

    <#
    .DESCRIPTION

    Specifies the Mutual CHAP authentication password.
    #>
    [DscProperty()]
    [string] $MutualChapPassword

    <#
    .DESCRIPTION

    Specifies whether to change the password for CHAP, Mutual CHAP or both. When the property is not specified or its value is $false, it is ignored.
    If the property is $true the passwords for CHAP and Mutual CHAP are changed to their desired values.
    #>
    [DscProperty()]
    [nullable[bool]] $Force

    hidden [string] $IScsiDeviceType = 'iSCSI'

    hidden [string] $CouldNotRetrieveIScsiHbaMessage = "Could not retrieve iSCSI Host Bus Adapter {0} from VMHost {1}. For more information: {2}"

    <#
    .DESCRIPTION

    Retrieves the iSCSI Host Bus Adapter with the specified name from the specified VMHost if it exists.
    #>
    [PSObject] GetIScsiHba($iScsiHbaName) {
        try {
            $iScsiHba = Get-VMHostHba -Server $this.Connection -VMHost $this.VMHost -Device $iScsiHbaName -Type $this.IScsiDeviceType -ErrorAction Stop -Verbose:$false
            return $iScsiHba
        }
        catch {
            throw ($this.CouldNotRetrieveIScsiHbaMessage -f $iScsiHbaName, $this.VMHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Checks if the CHAP settings should be modified based on the current authentication properties.
    #>
    [bool] ShouldModifyCHAPSettings($authenticationProperties, $inheritChap, $inheritMutualChap) {
        $shouldModifyCHAPSettings = @()

        $shouldModifyCHAPSettings += ($null -ne $inheritChap -and $inheritChap -ne $authenticationProperties.ChapInherited)
        $shouldModifyCHAPSettings += ($this.ChapType -ne [ChapType]::Unset -and $this.ChapType.ToString() -ne $authenticationProperties.ChapType.ToString())
        $shouldModifyCHAPSettings += ($null -ne $inheritMutualChap -and $inheritMutualChap -ne $authenticationProperties.MutualChapInherited)
        $shouldModifyCHAPSettings += ($null -ne $this.MutualChapEnabled -and $this.MutualChapEnabled -ne $authenticationProperties.MutualChapEnabled)

        # Force should determine the Desired State only when it is $true.
        $shouldModifyCHAPSettings += ($null -ne $this.Force -and $this.Force)

        # CHAP and Mutual CHAP names should be ignored when determining the Desired State when CHAP type is 'Prohibited'.
        if ($this.ChapType -ne [ChapType]::Prohibited) {
            $shouldModifyCHAPSettings += (![string]::IsNullOrEmpty($this.ChapName) -and $this.ChapName -ne [string] $authenticationProperties.ChapName)
            $shouldModifyCHAPSettings += (![string]::IsNullOrEmpty($this.MutualChapName) -and $this.MutualChapName -ne [string] $authenticationProperties.MutualChapName)
        }

        return ($shouldModifyCHAPSettings -Contains $true)
    }

    <#
    .DESCRIPTION

    Checks if the CHAP settings should be modified based on the current authentication properties.
    #>
    [bool] ShouldModifyCHAPSettings($authenticationProperties) {
        return $this.ShouldModifyCHAPSettings($authenticationProperties, $null, $null)
    }

    <#
    .DESCRIPTION

    Populates the cmdlet parameters with the CHAP settings based on the following criteria:
    1. CHAP settings can only be passed to the cmdlet if the 'InheritChap' option is not passed or it is passed with a '$false' value.
    2. Mutual CHAP settings can only be passed to the cmdlet if the 'InheritMutualChap' option is not passed or it is passed with a '$false' value.
    3. CHAP name and CHAP password can be passed to the cmdlet if the CHAP type is not 'Prohibited'.
    4. Mutual CHAP settings can only be passed to the cmdlet if the CHAP type is 'Required'.
    5. Mutual CHAP name and Mutual CHAP password can be passed to the cmdlet if Mutual CHAP enabled is not passed
       or if it is passed with a '$true' value.
    #>
    [void] PopulateCmdletParametersWithCHAPSettings($cmdletParams, $inheritChap, $inheritMutualChap) {
        if ($null -ne $inheritChap -and $inheritChap) {
            $cmdletParams.InheritChap = $inheritChap
        }
        else {
            # When 'InheritChap' is $false, it can be passed to the cmdlet only if CHAP type is not 'Prohibited'.
            if ($null -ne $inheritChap -and $this.ChapType -ne [ChapType]::Prohibited) { $cmdletParams.InheritChap = $inheritChap }
            if ($this.ChapType -ne [ChapType]::Unset) { $cmdletParams.ChapType = $this.ChapType.ToString() }

            if ($this.ChapType -ne [ChapType]::Prohibited) {
                if (![string]::IsNullOrEmpty($this.ChapName)) { $cmdletParams.ChapName = $this.ChapName }
                if (![string]::IsNullOrEmpty($this.ChapPassword)) { $cmdletParams.ChapPassword = $this.ChapPassword }
            }
        }

        if ($null -ne $inheritMutualChap -and $inheritMutualChap) {
            $cmdletParams.InheritMutualChap = $inheritMutualChap
        }
        else {
            # When 'InheritMutualChap' is $false, it can be passed to the cmdlet only if CHAP type is not 'Prohibited'.
            if ($null -ne $inheritMutualChap -and $this.ChapType -ne [ChapType]::Prohibited) { $cmdletParams.InheritMutualChap = $inheritMutualChap }

            if ($this.ChapType -eq [ChapType]::Required) {
                if ($null -ne $this.MutualChapEnabled) { $cmdletParams.MutualChapEnabled = $this.MutualChapEnabled }

                if ($null -eq $this.MutualChapEnabled -or $this.MutualChapEnabled) {
                    if (![string]::IsNullOrEmpty($this.MutualChapName)) { $cmdletParams.MutualChapName = $this.MutualChapName }
                    if (![string]::IsNullOrEmpty($this.MutualChapPassword)) { $cmdletParams.MutualChapPassword = $this.MutualChapPassword }
                }
            }
        }
    }

    <#
    .DESCRIPTION

    Populates the cmdlet parameters with the CHAP settings.
    #>
    [void] PopulateCmdletParametersWithCHAPSettings($cmdletParams) {
        $this.PopulateCmdletParametersWithCHAPSettings($cmdletParams, $null, $null)
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

class VMHostNetworkMigrationBaseDSC : VMHostEntityBaseDSC {
    <#
    .DESCRIPTION

    Specifies the names of the Physical Network Adapters that should be part of the vSphere Distributed/Standard Switch.
    #>
    [DscProperty(Mandatory)]
    [string[]] $PhysicalNicNames

    <#
    .DESCRIPTION

    Specifies the names of the VMKernel Network Adapters that should be part of the vSphere Distributed/Standard Switch.
    #>
    [DscProperty()]
    [string[]] $VMKernelNicNames

    <#
    .DESCRIPTION

    Retrieves the Physical Network Adapters with the specified names from the server if they exist.
    For every Physical Network Adapter that does not exist, a warning message is shown to the user without throwing an exception.
    #>
    [array] GetPhysicalNetworkAdapters() {
        $physicalNetworkAdapters = @()

        foreach ($physicalNetworkAdapterName in $this.PhysicalNicNames) {
            $physicalNetworkAdapter = Get-VMHostNetworkAdapter -Server $this.Connection -Name $physicalNetworkAdapterName -VMHost $this.VMHost -Physical -ErrorAction SilentlyContinue
            if ($null -eq $physicalNetworkAdapter) {
                Write-WarningLog -Message "The passed Physical Network Adapter {0} was not found and it will be ignored." -Arguments @($physicalNetworkAdapterName)
            }
            else {
                $physicalNetworkAdapters += $physicalNetworkAdapter
            }
        }

        return $physicalNetworkAdapters
    }

    <#
    .DESCRIPTION

    Retrieves the VMKernel Network Adapters with the specified names from the server if they exist.
    If one of the passed VMKernel Network Adapters does not exist, an exception is thrown.
    #>
    [array] GetVMKernelNetworkAdapters() {
        $vmKernelNetworkAdapters = @()

        foreach ($vmKernelNetworkAdapterName in $this.VMKernelNicNames) {
            $getVMHostNetworkAdapterParams = @{
                Server = $this.Connection
                Name = $vmKernelNetworkAdapterName
                VMHost = $this.VMHost
                VMKernel = $true
                ErrorAction = 'Stop'
            }

            try {
                $vmKernelNetworkAdapter = Get-VMHostNetworkAdapter @getVMHostNetworkAdapterParams
                $vmKernelNetworkAdapters += $vmKernelNetworkAdapter
            }
            catch {
                <#
                Here 'throw' should be used instead of 'Write-WarningLog' because if we ignore one VMKernel Network Adapter that is invalid, the mapping between VMKernel
                Network Adapters and Port Groups will not work: The first Adapter should be attached to the first Port Group,
                the second Adapter should be attached to the second Port Group, and so on.
                #>
                throw "The passed VMKernel Network Adapter $($vmKernelNetworkAdapterName) was not found."
            }
        }

        return $vmKernelNetworkAdapters
    }
}

class VMHostNicBaseDSC : VMHostEntityBaseDSC {
    <#
    .DESCRIPTION

    Specifies the name of the Port Group to which the VMKernel Network Adapter should be connected. If a Distributed Switch is passed, an existing Port Group name should be specified.
    For Standard Virtual Switches, if the Port Group is non-existent, a new Port Group with the specified name will be created and the VMKernel Network Adapter will be connected to it.
    #>
    [DscProperty(Key)]
    [string] $PortGroupName

    <#
    .DESCRIPTION

    Value indicating if the VMKernel Network Adapter should be Present or Absent.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    <#
    .DESCRIPTION

    Indicates whether the VMKernel Network Adapter uses a Dhcp server.
    #>
    [DscProperty()]
    [nullable[bool]] $Dhcp

    <#
    .DESCRIPTION

    Specifies an IP address for the VMKernel Network Adapter. All IP addresses are specified using IPv4 dot notation. If IP is not specified, DHCP mode is enabled.
    #>
    [DscProperty()]
    [string] $IP

    <#
    .DESCRIPTION

    Specifies a Subnet Mask for the VMKernel Network Adapter.
    #>
    [DscProperty()]
    [string] $SubnetMask

    <#
    .DESCRIPTION

    Specifies a media access control (MAC) address for the VMKernel Network Adapter.
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

    Indicates that you want to enable the VMKernel Network Adapter for management traffic.
    #>
    [DscProperty()]
    [nullable[bool]] $ManagementTrafficEnabled

    <#
    .DESCRIPTION

    Indicates that the VMKernel Network Adapter is enabled for Fault Tolerance (FT) logging.
    #>
    [DscProperty()]
    [nullable[bool]] $FaultToleranceLoggingEnabled

    <#
    .DESCRIPTION

    Indicates that you want to use the VMKernel Network Adapter for VMotion.
    #>
    [DscProperty()]
    [nullable[bool]] $VMotionEnabled

    <#
    .DESCRIPTION

    Indicates that Virtual SAN traffic is enabled on this VMKernel Network Adapter.
    #>
    [DscProperty()]
    [nullable[bool]] $VsanTrafficEnabled

    <#
    .DESCRIPTION

    Retrieves the VMKernel Network Adapter connected to the specified Port Group and Virtual Switch and available on the specified VMHost from the server
    if it exists, otherwise returns $null.
    #>
    [PSObject] GetVMHostNetworkAdapter($virtualSwitch) {
        if ($null -eq $virtualSwitch) {
            <#
            If the Virtual Switch is $null, it means that Ensure was set to 'Absent' and
            the VMKernel Network Adapter does not exist for the specified Virtual Switch.
            #>
            return $null
        }

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
    [PSObject] AddVMHostNetworkAdapter($virtualSwitch, $portId) {
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
            return New-VMHostNetworkAdapter @vmHostNetworkAdapterParams
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
        $result.Server = $this.Connection.Name
        $result.VMHostName = $this.VMHost.Name

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
class DatastoreCluster : DatacenterInventoryBaseDSC {
    DatastoreCluster() {
        $this.InventoryItemFolderType = [FolderType]::Datastore
    }

    <#
    .DESCRIPTION

    Specifies the maximum I/O latency in milliseconds allowed before Storage DRS is triggered for the Datastore Cluster.
    Valid values are in the range of 5 to 100. If the value of IOLoadBalancing is $false, the setting for the I/O latency threshold is not applied.
    #>
    [DscProperty()]
    [nullable[int]] $IOLatencyThresholdMillisecond

    <#
    .DESCRIPTION

    Specifies whether I/O load balancing is enabled for the Datastore Cluster. If the value is $false, I/O load balancing is disabled
    and the settings for the I/O latency threshold and utilized space threshold are not applied.
    #>
    [DscProperty()]
    [nullable[bool]] $IOLoadBalanceEnabled

    <#
    .DESCRIPTION

    Specifies the Storage DRS automation level for the Datastore Cluster. Valid values are Disabled, Manual and FullyAutomated.
    #>
    [DscProperty()]
    [DrsAutomationLevel] $SdrsAutomationLevel = [DrsAutomationLevel]::Unset

    <#
    .DESCRIPTION

    Specifies the maximum percentage of consumed space allowed before Storage DRS is triggered for the Datastore Cluster.
    Valid values are in the range of 50 to 100. If the value of IOLoadBalancing is $false, the setting for the utilized space threshold is not applied.
    #>
    [DscProperty()]
    [nullable[int]] $SpaceUtilizationThresholdPercent

    hidden [string] $CreateDatastoreClusterMessage = "Creating Datastore Cluster {0} in Folder {1}."
    hidden [string] $ModifyDatastoreClusterMessage = "Modifying Datastore Cluster {0} configuration."
    hidden [string] $RemoveDatastoreClusterMessage = "Removing Datastore Cluster {0}."

    hidden [string] $CouldNotCreateDatastoreClusterMessage = "Could not create Datastore Cluster {0} in Folder {1}. For more information: {2}"
    hidden [string] $CouldNotModifyDatastoreClusterMessage = "Could not modify Datastore Cluster {0} configuration. For more information: {1}"
    hidden [string] $CouldNotRemoveDatastoreClusterMessage = "Could not remove Datastore Cluster {0}. For more information: {1}"

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()

            $datacenter = $this.GetDatacenter()
            $datacenterFolderName = "$($this.InventoryItemFolderType)Folder"
            $datastoreClusterLocation = $this.GetInventoryItemLocationInDatacenter($datacenter, $datacenterFolderName)

            $datastoreCluster = $this.GetDatastoreCluster($datastoreClusterLocation)
            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $datastoreCluster) {
                    $datastoreCluster = $this.NewDatastoreCluster($datastoreClusterLocation)
                }

                if ($this.ShouldModifyDatastoreCluster($datastoreCluster)) {
                    $this.ModifyDatastoreCluster($datastoreCluster)
                }
            }
            else {
                if ($null -ne $datastoreCluster) {
                    $this.RemoveDatastoreCluster($datastoreCluster)
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
            $datacenterFolderName = "$($this.InventoryItemFolderType)Folder"
            $datastoreClusterLocation = $this.GetInventoryItemLocationInDatacenter($datacenter, $datacenterFolderName)

            $datastoreCluster = $this.GetDatastoreCluster($datastoreClusterLocation)
            $result = $null

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $datastoreCluster) {
                    $result = $false
                }
                else {
                    $result = !$this.ShouldModifyDatastoreCluster($datastoreCluster)
                }
            }
            else {
                $result = ($null -eq $datastoreCluster)
            }

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [DatastoreCluster] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [DatastoreCluster]::new()

            $this.ConnectVIServer()

            $datacenter = $this.GetDatacenter()
            $datacenterFolderName = "$($this.InventoryItemFolderType)Folder"
            $datastoreClusterLocation = $this.GetInventoryItemLocationInDatacenter($datacenter, $datacenterFolderName)

            $datastoreCluster = $this.GetDatastoreCluster($datastoreClusterLocation)
            $this.PopulateResult($result, $datastoreCluster)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Datastore Cluster with the specified name located in the specified Folder if it exists.
    #>
    [PSObject] GetDatastoreCluster($datastoreClusterLocation) {
        $getDatastoreClusterParams = @{
            Server = $this.Connection
            Name = $this.Name
            Location = $datastoreClusterLocation
            ErrorAction = 'SilentlyContinue'
            Verbose = $false
        }

        $whereObjectParams = @{
            FilterScript = {
                $_.ExtensionData.Parent -eq $datastoreClusterLocation.ExtensionData.MoRef
            }
        }

        <#
            Multiple Datastore Clusters with the same name can be present in a Datacenter. So we need to filter
            by the direct Parent Folder of the Datastore Cluster to retrieve the desired one.
        #>
        return Get-DatastoreCluster @getDatastoreClusterParams | Where-Object @whereObjectParams
    }

    <#
    .DESCRIPTION

    Checks if the specified Datastore Cluster configuration should be modified.
    #>
    [bool] ShouldModifyDatastoreCluster($datastoreCluster) {
        $shouldModifyDatastoreCluster = @()

        $shouldModifyDatastoreCluster += ($null -ne $this.IOLatencyThresholdMillisecond -and $this.IOLatencyThresholdMillisecond -ne $datastoreCluster.IOLatencyThresholdMillisecond)
        $shouldModifyDatastoreCluster += ($null -ne $this.IOLoadBalanceEnabled -and $this.IOLoadBalanceEnabled -ne $datastoreCluster.IOLoadBalanceEnabled)
        $shouldModifyDatastoreCluster += ($this.SdrsAutomationLevel -ne [DrsAutomationLevel]::Unset -and $this.SdrsAutomationLevel.ToString() -ne $datastoreCluster.SdrsAutomationLevel.ToString())
        $shouldModifyDatastoreCluster += ($null -ne $this.SpaceUtilizationThresholdPercent -and $this.SpaceUtilizationThresholdPercent -ne $datastoreCluster.SpaceUtilizationThresholdPercent)

        return ($shouldModifyDatastoreCluster -Contains $true)
    }

    <#
    .DESCRIPTION

    Creates a new Datastore Cluster with the specified name located in the specified Folder.
    #>
    [PSObject] NewDatastoreCluster($datastoreClusterLocation) {
        $newDatastoreClusterParams = @{
            Server = $this.Connection
            Name = $this.Name
            Location = $datastoreClusterLocation
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        try {
            Write-VerboseLog -Message $this.CreateDatastoreClusterMessage -Arguments @($this.Name, $datastoreClusterLocation.Name)
            return New-DatastoreCluster @newDatastoreClusterParams
        }
        catch {
            throw ($this.CouldNotCreateDatastoreClusterMessage -f $this.Name, $datastoreClusterLocation.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Modifies the configuration of the specified Datastore Cluster.
    #>
    [void] ModifyDatastoreCluster($datastoreCluster) {
        $setDatastoreClusterParams = @{
            Server = $this.Connection
            DatastoreCluster = $datastoreCluster
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        if ($null -ne $this.IOLatencyThresholdMillisecond) { $setDatastoreClusterParams.IOLatencyThresholdMillisecond = $this.IOLatencyThresholdMillisecond }
        if ($null -ne $this.IOLoadBalanceEnabled) { $setDatastoreClusterParams.IOLoadBalanceEnabled = $this.IOLoadBalanceEnabled }
        if ($this.SdrsAutomationLevel -ne [DrsAutomationLevel]::Unset) { $setDatastoreClusterParams.SdrsAutomationLevel = $this.SdrsAutomationLevel.ToString() }
        if ($null -ne $this.SpaceUtilizationThresholdPercent) { $setDatastoreClusterParams.SpaceUtilizationThresholdPercent = $this.SpaceUtilizationThresholdPercent }

        try {
            Write-VerboseLog -Message $this.ModifyDatastoreClusterMessage -Arguments @($datastoreCluster.Name)
            Set-DatastoreCluster @setDatastoreClusterParams
        }
        catch {
            throw ($this.CouldNotModifyDatastoreClusterMessage -f $datastoreCluster.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Removes the specified Datastore Cluster.
    #>
    [void] RemoveDatastoreCluster($datastoreCluster) {
        $removeDatastoreClusterParams = @{
            Server = $this.Connection
            DatastoreCluster = $datastoreCluster
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        try {
            Write-VerboseLog -Message $this.RemoveDatastoreClusterMessage -Arguments @($datastoreCluster.Name)
            Remove-DatastoreCluster @removeDatastoreClusterParams
        }
        catch {
            throw ($this.CouldNotRemoveDatastoreClusterMessage -f $datastoreCluster.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $datastoreCluster) {
        $result.Server = $this.Server
        $result.Location = $this.Location
        $result.DatacenterName = $this.DatacenterName
        $result.DatacenterLocation = $this.DatacenterLocation

        if ($null -ne $datastoreCluster) {
            $result.Name = $datastoreCluster.Name
            $result.Ensure = [Ensure]::Present
            $result.IOLatencyThresholdMillisecond = $datastoreCluster.IOLatencyThresholdMillisecond
            $result.IOLoadBalanceEnabled = $datastoreCluster.IOLoadBalanceEnabled
            $result.SdrsAutomationLevel = $datastoreCluster.SdrsAutomationLevel.ToString()
            $result.SpaceUtilizationThresholdPercent = $datastoreCluster.SpaceUtilizationThresholdPercent
        }
        else {
            $result.Name = $this.Name
            $result.Ensure = [Ensure]::Absent
            $result.IOLatencyThresholdMillisecond = $this.IOLatencyThresholdMillisecond
            $result.IOLoadBalanceEnabled = $this.IOLoadBalanceEnabled
            $result.SdrsAutomationLevel = $this.SdrsAutomationLevel
            $result.SpaceUtilizationThresholdPercent = $this.SpaceUtilizationThresholdPercent
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
class NfsUser : VMHostEntityBaseDSC {
    <#
    .DESCRIPTION

    Specifies the Nfs User name used for Kerberos authentication.
    #>
    [DscProperty(Key)]
    [string] $Name

    <#
    .DESCRIPTION

    Specifies the Nfs User password used for Kerberos authentication.
    #>
    [DscProperty()]
    [string] $Password

    <#
    .DESCRIPTION

    Specifies whether the Nfs User should be present or absent.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    <#
    .DESCRIPTION

    Specifies whether to change the password of the Nfs User. When the property is not specified or is $false, it is ignored.
    If the property is $true and the Nfs User exists, the password of the Nfs User is changed.
    #>
    [DscProperty()]
    [nullable[bool]] $Force

    hidden [string] $CreateNfsUserMessage = "Creating Nfs User {0} on VMHost {1}."
    hidden [string] $ChangeNfsUserPasswordMessage = "Changing Nfs User {0} password on VMHost {1}."
    hidden [string] $RemoveNfsUserMessage = "Removing Nfs User {0} from VMHost {1}."

    hidden [string] $CouldNotCreateNfsUserMessage = "Could not create Nfs User {0} on VMHost {1}. For more information: {2}"
    hidden [string] $CouldNotChangeNfsUserPasswordMessage = "Could not change Nfs User {0} password on VMHost {1}. For more information: {2}"
    hidden [string] $CouldNotRemoveNfsUserMessage = "Could not remove Nfs User {0} from VMHost {1}. For more information: {2}"

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $nfsUser = $this.GetNfsUser()

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $nfsUser) {
                    $this.NewNfsUser()
                }
                else {
                    $this.ChangeNfsUserPassword($nfsUser)
                }
            }
            else {
                if ($null -ne $nfsUser) {
                    $this.RemoveNfsUser($nfsUser)
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
            $this.RetrieveVMHost()

            $nfsUser = $this.GetNfsUser()
            $result = $null

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $nfsUser) {
                    $result = $false
                }
                else {
                    $result = !($null -ne $this.Force -and $this.Force)
                }
            }
            else {
                $result = ($null -eq $nfsUser)
            }

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [NfsUser] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [NfsUser]::new()

            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $nfsUser = $this.GetNfsUser()
            $this.PopulateResult($result, $nfsUser)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Nfs User with the specified name from the VMHost if it exists.
    #>
    [PSObject] GetNfsUser() {
        <#
        The Verbose logic here is needed to suppress the Verbose output of the Import-Module cmdlet
        when importing the 'VMware.VimAutomation.Storage' Module.
        #>
        $savedVerbosePreference = $global:VerbosePreference
        $global:VerbosePreference = 'SilentlyContinue'

        $nfsUser = Get-NfsUser -Server $this.Connection -Username $this.Name -VMHost $this.VMHost -ErrorAction SilentlyContinue -Verbose:$false

        $global:VerbosePreference = $savedVerbosePreference

        return $nfsUser
    }

    <#
    .DESCRIPTION

    Creates a new Nfs User with the specified name and password on the VMHost.
    #>
    [void] NewNfsUser() {
        $newNfsUserParams = @{
            Server = $this.Connection
            Username = $this.Name
            VMHost = $this.VMHost
            Password = $this.Password
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        try {
            Write-VerboseLog -Message $this.CreateNfsUserMessage -Arguments @($this.Name, $this.VMHost.Name)
            New-NfsUser @newNfsUserParams
        }
        catch {
            throw ($this.CouldNotCreateNfsUserMessage -f $this.Name, $this.VMHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Changes the password of the specified Nfs User on the VMHost.
    #>
    [void] ChangeNfsUserPassword($nfsUser) {
        $setNfsUserParams = @{
            Server = $this.Connection
            NfsUser = $nfsUser
            Password = $this.Password
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        try {
            Write-VerboseLog -Message $this.ChangeNfsUserPasswordMessage -Arguments @($nfsUser.Username, $this.VMHost.Name)
            Set-NfsUser @setNfsUserParams
        }
        catch {
            throw ($this.CouldNotChangeNfsUserPasswordMessage -f $nfsUser.Username, $this.VMHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Removes the specified Nfs User from the VMHost.
    #>
    [void] RemoveNfsUser($nfsUser) {
        $removeNfsUserParams = @{
            NfsUser = $nfsUser
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        try {
            Write-VerboseLog -Message $this.RemoveNfsUserMessage -Arguments @($nfsUser.Username, $this.VMHost.Name)
            Remove-NfsUser @removeNfsUserParams
        }
        catch {
            throw ($this.CouldNotRemoveNfsUserMessage -f $nfsUser.Username, $this.VMHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $nfsUser) {
        $result.Server = $this.Connection.Name
        $result.VMHostName = $this.VMHost.Name
        $result.Force = $this.Force

        if ($null -ne $nfsUser) {
            $result.Name = $nfsUser.Username
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
class vCenterVMHost : DatacenterInventoryBaseDSC {
    vCenterVMHost() {
        $this.InventoryItemFolderType = [FolderType]::Host
    }

    <#
    .DESCRIPTION

    Credentials needed for authenticating with the VMHost.
    #>
    [DscProperty(Mandatory)]
    [PSCredential] $VMHostCredential

    <#
    .DESCRIPTION

    Specifies the port on the VMHost used for the connection.
    #>
    [DscProperty()]
    [nullable[int]] $Port

    <#
    .DESCRIPTION

    Indicates whether the VMHost is added to the vCenter if the authenticity of the VMHost SSL certificate cannot be verified.
    #>
    [DscProperty()]
    [nullable[bool]] $Force

    <#
    .DESCRIPTION

    Specifies the location of the Resource Pool in the Cluster. Location consists of 0 or more Resource Pools. The Root Resource Pool of the Cluster is not part of the location.
    If '/' location is passed, the Resource Pool is the Root Resource Pool of the Cluster. Resource Pools names in the location are separated by '/'.
    The VMHost's Root Resource Pool becomes the last Resource Pool specified in the location and the VMHost Resource Pool hierarchy is imported into the new nested Resource Pool.
    Example location for a Resource Pool: 'MyResourcePoolOne/MyResourcePoolTwo'.
    #>
    [DscProperty()]
    [string] $ResourcePoolLocation

    hidden [string] $ClusterType = 'VMware.VimAutomation.ViCore.Types.V1.Inventory.Cluster'

    hidden [string] $AddVMHostTovCenterMessage = "Adding VMHost {0} to vCenter {1} and location {2}."
    hidden [string] $MoveVMHostToDestinationMessage = "Moving VMHost {0} to location {1} on vCenter {2}."
    hidden [string] $RemoveVMHostFromvCenterMessage = "Removing VMHost {0} from vCenter {1}."

    hidden [string] $FoundLocationIsNotAClusterMessage = "Resource Pool location {0} is specified but the found location {1} for VMHost {2} is not a Cluster."
    hidden [string] $CouldNotRetrieveRootResourcePoolOfClusterMessage = "Could not retrieve Root Resource Pool of Cluster {0}. For more information: {1}"
    hidden [string] $InvalidResourcePoolLocationInClusterMessage = "Resource Pool location {0} is not valid in Cluster {2}."
    hidden [string] $CouldNotAddVMHostTovCenterMessage = "Could not add VMHost {0} to vCenter {1} and location {2}. For more information: {3}"
    hidden [string] $CouldNotMoveVMHostToDestinationMessage = "Could not move VMHost {0} to location {1} on vCenter {2}. For more information: {3}"
    hidden [string] $CouldNotRemoveVMHostFromvCenterMessage = "Could not remove VMHost {0} from vCenter {1}. For more information: {2}"

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()
            $this.EnsureConnectionIsvCenter()

            $vmHost = $this.GetVMHost()

            if ($this.Ensure -eq [Ensure]::Present) {
                $datacenter = $this.GetDatacenter()
                $datacenterFolderName = "$($this.InventoryItemFolderType)Folder"
                $vmHostLocation = $this.GetInventoryItemLocationInDatacenter($datacenter, $datacenterFolderName)

                if (![string]::IsNullOrEmpty($this.ResourcePoolLocation)) {
                    <#
                    If the Resource Pool location is specified it means that the desired VMHost location should be a Cluster and the Resource Pool needs to be passed to the cmdlets
                    as VMHost location instead of the Cluster.
                    #>
                    if (!$this.IsVIObjectOfTheCorrectType($vmHostLocation, $this.ClusterType)) {
                        throw ($this.FoundLocationIsNotAClusterMessage -f $this.ResourcePoolLocation, $vmHostLocation.Name, $this.Name)
                    }
                    $rootResourcePool = $this.GetRootResourcePoolOfCluster($vmHostLocation)
                    $vmHostLocation = $this.GetClusterResourcePool($rootResourcePool, $vmHostLocation.Name)
                }

                if ($null -eq $vmHost) {
                    $this.AddVMHost($vmHostLocation)
                }
                else {
                    if ($vmHost.ParentId -ne $vmHostLocation.Id) {
                        $this.MoveVMHost($vmHost, $vmHostLocation)
                    }
                }
            }
            else {
                if ($null -ne $vmHost) {
                    $this.RemoveVMHost($vmHost)
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
            $this.EnsureConnectionIsvCenter()

            $vmHost = $this.GetVMHost()
            $result = $null

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $vmHost) {
                    $result = $false
                }
                else {
                    $datacenter = $this.GetDatacenter()
                    $datacenterFolderName = "$($this.InventoryItemFolderType)Folder"
                    $vmHostLocation = $this.GetInventoryItemLocationInDatacenter($datacenter, $datacenterFolderName)

                    $result = ($vmHost.ParentId -eq $vmHostLocation.Id)
                }
            }
            else {
                $result = ($null -eq $vmHost)
            }

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [vCenterVMHost] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [vCenterVMHost]::new()

            $this.ConnectVIServer()
            $this.EnsureConnectionIsvCenter()

            $vmHost = $this.GetVMHost()
            $this.PopulateResult($result, $vmHost)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the VMHost with the specified name if it is on the vCenter Server system.
    #>
    [PSObject] GetVMHost() {
        return Get-VMHost -Server $this.Connection -Name $this.Name -ErrorAction SilentlyContinue -Verbose:$false
    }

    <#
    .DESCRIPTION

    Retrieves the Root Resource Pool of the specified Cluster.
    #>
    [PSObject] GetRootResourcePoolOfCluster($cluster) {
        try {
            $rootResourcePool = Get-ResourcePool -Server $this.Connection -Location $cluster -ErrorAction Stop -Verbose:$false |
                                Where-Object -FilterScript { $_.ParentId -eq $cluster.Id }
            return $rootResourcePool
        }
        catch {
            throw ($this.CouldNotRetrieveRootResourcePoolOfClusterMessage -f $cluster.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Resource Pool with the specified name from the specified Cluster.
    #>
    [PSObject] GetClusterResourcePool($rootResourcePool, $clusterName) {
        $clusterResourcePool = $null

        if ($this.ResourcePoolLocation -eq '/') {
            # Special case where the Resource Pool location does not contain any Resource Pools. So the Root Resource Pool is the searched Resource Pool from the Cluster.
            $clusterResourcePool = $rootResourcePool
        }
        elseif ($this.ResourcePoolLocation -NotMatch '/') {
            # Special case where the Resource Pool location is just one Resource Pool.
            $clusterResourcePool = Get-Inventory -Server $this.Connection -Name $this.ResourcePoolLocation -Location $rootResourcePool -ErrorAction SilentlyContinue -Verbose:$false |
                                           Where-Object -FilterScript { $_.ParentId -eq $rootResourcePool.Id }
        }
        else {
            $resourcePoolLocationItems = $this.ResourcePoolLocation -Split '/'

            # Reverse the Resource Pool location items so that we can start from the bottom and go to the Root Resource Pool.
            [array]::Reverse($resourcePoolLocationItems)

            $resourcePoolName = $resourcePoolLocationItems[0]
            $foundResourcePools = Get-Inventory -Server $this.Connection -Name $resourcePoolName -Location $rootResourcePool -ErrorAction SilentlyContinue -Verbose:$false

            # Remove the name of the Resource Pool from the Resource Pool location items array as we already retrieved it.
            $resourcePoolLocationItems = $resourcePoolLocationItems[1..($resourcePoolLocationItems.Length - 1)]

            <#
            For every found Resource Pool in the Cluster with the specified name we start to go up through the parents to check if the Resource Pool location is valid.
            If one of the Parents does not meet the criteria of the Resource Pool location, we continue with the next found Resource Pool.
            If we find a valid Resource Pool location we stop iterating through the Resource Pools and mark it as the searched Resource Pool from the Cluster.
            #>
            foreach ($foundResourcePool in $foundResourcePools) {
                $foundResourcePoolAsViewObject = Get-View -Server $this.Connection -Id $foundResourcePool.Id -Property Parent -Verbose:$false
                $validResourcePoolLocation = $true

                foreach ($resourcePoolLocationItem in $resourcePoolLocationItems) {
                    $foundResourcePoolAsViewObject = Get-View -Server $this.Connection -Id $foundResourcePoolAsViewObject.Parent -Property Name, Parent -Verbose:$false
                    if ($foundResourcePoolAsViewObject.Name -ne $resourcePoolLocationItem) {
                        $validResourcePoolLocation = $false
                        break
                    }
                }

                if ($validResourcePoolLocation) {
                    $clusterResourcePool = $foundResourcePool
                    break
                }
            }
        }

        if ($null -eq $clusterResourcePool) {
            throw ($this.InvalidResourcePoolLocationInClusterMessage -f $this.ResourcePoolLocation, $clusterName)
        }

        return $clusterResourcePool
    }

    <#
    .DESCRIPTION

    Adds the VMHost to the specified location and to be managed by the vCenter Server system.
    #>
    [void] AddVMHost($vmHostLocation) {
        $addVMHostParams = @{
            Server = $this.Connection
            Name = $this.Name
            Location = $vmHostLocation
            Credential = $this.VMHostCredential
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        if ($null -ne $this.Port) { $addVMHostParams.Port = $this.Port }
        if ($null -ne $this.Force) { $addVMHostParams.Force = $this.Force }

        try {
            Write-VerboseLog -Message $this.AddVMHostTovCenterMessage -Arguments @($this.Name, $this.Connection.Name, $vmHostLocation.Name)
            Add-VMHost @addVMHostParams
        }
        catch {
            throw ($this.CouldNotAddVMHostTovCenterMessage -f $this.Name, $this.Connection.Name, $vmHostLocation.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Moves the VMHost to the specified location on the vCenter Server system.
    #>
    [void] MoveVMHost($vmHost, $vmHostLocation) {
        $moveVMHostParams = @{
            Server = $this.Connection
            VMHost = $vmHost
            Destination = $vmHostLocation
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        try {
            Write-VerboseLog -Message $this.MoveVMHostToDestinationMessage -Arguments @($vmHost.Name, $vmHostLocation.Name, $this.Connection.Name)
            Move-VMHost @moveVMHostParams
        }
        catch {
            throw ($this.CouldNotMoveVMHostToDestinationMessage -f $vmHost.Name, $vmHostLocation.Name, $this.Connection.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Removes the VMHost from the vCenter Server system.
    #>
    [void] RemoveVMHost($vmHost) {
        $removeVMHostParams = @{
            Server = $this.Connection
            VMHost = $vmHost
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        try {
            Write-VerboseLog -Message $this.RemoveVMHostFromvCenterMessage -Arguments @($vmHost.Name, $this.Connection.Name)
            Remove-VMHost @removeVMHostParams
        }
        catch {
            throw ($this.CouldNotRemoveVMHostFromvCenterMessage -f $vmHost.Name, $this.Connection.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $vmHost) {
        $result.Server = $this.Connection.Name
        $result.Location = $this.Location
        $result.DatacenterName = $this.DatacenterName
        $result.DatacenterLocation = $this.DatacenterLocation
        $result.Force = $this.Force
        $result.ResourcePoolLocation = $this.ResourcePoolLocation

        if ($null -ne $vmHost) {
            $result.Name = $vmHost.Name
            $result.Ensure = [Ensure]::Present
            $result.Port = $vmHost.ExtensionData.Summary.Config.Port
        }
        else {
            $result.Name = $this.Name
            $result.Ensure = [Ensure]::Absent
            $result.Port = $this.Port
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
class VDSwitchVMHost : BaseDSC {
    <#
    .DESCRIPTION

    Specifies the name of the vSphere Distributed Switch to/from which you want to add/remove the specified VMHosts.
    #>
    [DscProperty(Key)]
    [string] $VdsName

    <#
    .DESCRIPTION

    Specifies the names of the VMHosts that you want to add/remove to/from the specified vSphere Distributed Switch.
    #>
    [DscProperty(Mandatory)]
    [string[]] $VMHostNames

    <#
    .DESCRIPTION

    Value indicating if the VMHosts should be Present/Absent to/from the specified vSphere Distributed Switch.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    [void] Set() {
        try {
            $this.ConnectVIServer()
            $this.EnsureConnectionIsvCenter()

            $distributedSwitch = $this.GetDistributedSwitch()
            $vmHosts = $this.GetVMHosts()
            $filteredVMHosts = $this.GetFilteredVMHosts($vmHosts, $distributedSwitch)

            if ($this.Ensure -eq [Ensure]::Present) {
                $this.AddVMHostsToDistributedSwitch($filteredVMHosts, $distributedSwitch)
            }
            else {
                $this.RemoveVMHostsFromDistributedSwitch($filteredVMHosts, $distributedSwitch)
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
            $vmHosts = $this.GetVMHosts()

            if ($null -eq $distributedSwitch) {
                # If the Distributed Switch is $null, it means that Ensure is 'Absent' and the Distributed Switch does not exist.
                return $true
            }

            return !$this.ShouldUpdateVMHostsInDistributedSwitch($vmHosts, $distributedSwitch)
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VDSwitchVMHost] Get() {
        try {
            $result = [VDSwitchVMHost]::new()

            $this.ConnectVIServer()
            $this.EnsureConnectionIsvCenter()

            $distributedSwitch = $this.GetDistributedSwitch()
            $vmHosts = $this.GetVMHosts()

            $result.Server = $this.Connection.Name
            $result.VMHostNames = $vmHosts | Select-Object -ExpandProperty Name
            $result.Ensure = $this.Ensure

            if ($null -eq $distributedSwitch) {
                # If the Distributed Switch is $null, it means that Ensure is 'Absent' and the Distributed Switch does not exist.
                $result.VdsName = $this.Name
            }
            else {
                $result.VdsName = $distributedSwitch.Name
            }

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
        if ($this.Ensure -eq [Ensure]::Absent) {
            $distributedSwitch = Get-VDSwitch -Server $this.Connection -Name $this.VdsName -ErrorAction SilentlyContinue
            return $distributedSwitch
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

    <#
    .DESCRIPTION

    Retrieves the VMHosts with the specified names from the server if they exist.
    For every VMHost that does not exist, a warning message is shown to the user without throwing an exception.
    #>
    [array] GetVMHosts() {
        $vmHosts = @()

        foreach ($vmHostName in $this.VMHostNames) {
            $vmHost = Get-VMHost -Server $this.Connection -Name $vmHostName -ErrorAction SilentlyContinue
            if ($null -eq $vmHost) {
                Write-WarningLog -Message "The passed VMHost {0} was not found and it will be ignored." -Arguments @($vmHostName)
            }
            else {
                $vmHosts += $vmHost
            }
        }

        return $vmHosts
    }

    <#
    .DESCRIPTION

    Checks if VMHosts should be added/removed from the Distributed Switch depending on the value of the Ensure property.
    If Ensure is set to 'Present', checks if all passed VMHosts are part of the Distributed Switch.
    If Ensure is set to 'Absent', checks if all passed VMHosts are not part of the Distributed Switch.
    #>
    [bool] ShouldUpdateVMHostsInDistributedSwitch($vmHosts, $distributedSwitch) {
        if ($this.Ensure -eq [Ensure]::Present) {
            foreach ($vmHost in $vmHosts) {
                $addedVMHost = $vmHost.ExtensionData.Config.Network.ProxySwitch | Where-Object -FilterScript { $_.DvsName -eq $distributedSwitch.Name }
                if ($null -eq $addedVMHost) {
                    return $true
                }
            }
        }
        else {
            foreach ($vmHost in $vmHosts) {
                $removedVMHost = $vmHost.ExtensionData.Config.Network.ProxySwitch | Where-Object -FilterScript { $_.DvsName -eq $distributedSwitch.Name }
                if ($null -ne $removedVMHost) {
                    return $true
                }
            }
        }

        return $false
    }

    <#
    .DESCRIPTION

    Returns the filtered VMHosts based on the value of the Ensure property. If Ensure is set to 'Present', it returns only
    these VMHosts that are currently not part of the Distributed Switch. The other VMHosts in the array are ignored because they are already part
    of the Distributed Switch. If Ensure is set to 'Absent', it returns only these VMHosts that are currently part of the Distributed Switch. The other VMHosts
    in the array are ignored because they are not part of the Distributed Switch. In both cases a warning message is shown to the user when a specific VMHost is
    ignored.
    #>
    [array] GetFilteredVMHosts($vmHosts, $distributedSwitch) {
        $filteredVMHosts = @()

        if ($this.Ensure -eq [Ensure]::Present) {
            foreach ($vmHost in $vmHosts) {
                $addedVMHost = $vmHost.ExtensionData.Config.Network.ProxySwitch | Where-Object -FilterScript { $_.DvsName -eq $distributedSwitch.Name }
                if ($null -ne $addedVMHost) {
                    Write-WarningLog -Message "VMHost {0} is already added to Distributed Switch {1} and it will be ignored." -Arguments @($vmHost.Name, $distributedSwitch.Name)
                    continue
                }

                $filteredVMHosts += $vmHost
            }
        }
        else {
            foreach ($vmHost in $vmHosts) {
                $removedVMHost = $vmHost.ExtensionData.Config.Network.ProxySwitch | Where-Object -FilterScript { $_.DvsName -eq $distributedSwitch.Name }
                if ($null -eq $removedVMHost) {
                    Write-WarningLog -Message "VMHost {0} is not added to Distributed Switch {1} and it will be ignored." -Arguments @($vmHost.Name, $distributedSwitch.Name)
                    continue
                }

                $filteredVMHosts += $vmHost
            }
        }

        return $filteredVMHosts
    }

    <#
    .DESCRIPTION

    Adds the VMHosts to the specified Distributed Switch.
    #>
    [void] AddVMHostsToDistributedSwitch($filteredVMHosts, $distributedSwitch) {
        try {
            Add-VDSwitchVMHost -Server $this.Connection -VDSwitch $distributedSwitch -VMHost $filteredVMHosts -ErrorAction Stop
        }
        catch {
            throw "Could not add VMHosts $filteredVMHosts to Distributed Switch $($distributedSwitch.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Removes the VMHosts from the specified Distributed Switch.
    #>
    [void] RemoveVMHostsFromDistributedSwitch($filteredVMHosts, $distributedSwitch) {
        try {
            Remove-VDSwitchVMHost -Server $this.Connection -VDSwitch $distributedSwitch -VMHost $filteredVMHosts -ErrorAction Stop
        }
        catch {
            throw "Could not remove VMHosts $filteredVMHosts from Distributed Switch $($distributedSwitch.Name). For more information: $($_.Exception.Message)"
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
class VMHostAuthentication : VMHostBaseDSC {
    <#
    .DESCRIPTION

    Specifies the name of the domain to join/leave. The name should be the fully qualified domain name (FQDN).
    #>
    [DscProperty(Mandatory)]
    [string] $DomainName

    <#
    .DESCRIPTION

    Value indicating if the specified VMHost should join/leave the specified domain.
    #>
    [DscProperty(Mandatory)]
    [DomainAction] $DomainAction

    <#
    .DESCRIPTION

    The credentials needed for joining the specified domain.
    #>
    [DscProperty()]
    [PSCredential] $DomainCredential

    [void] Set() {
        try {
            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $vmHostAuthenticationInfo = $this.GetVMHostAuthenticationInfo($vmHost)

            if ($this.DomainAction -eq [DomainAction]::Join) {
                $this.JoinDomain($vmHostAuthenticationInfo, $vmHost)
            }
            else {
                $this.LeaveDomain($vmHostAuthenticationInfo, $vmHost)
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
            $vmHostAuthenticationInfo = $this.GetVMHostAuthenticationInfo($vmHost)

            if ($this.DomainAction -eq [DomainAction]::Join) {
                return ($this.DomainName -eq $vmHostAuthenticationInfo.Domain)
            }
            else {
                return ($null -eq $vmHostAuthenticationInfo.Domain)
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostAuthentication] Get() {
        try {
            $result = [VMHostAuthentication]::new()

            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $vmHostAuthenticationInfo = $this.GetVMHostAuthenticationInfo($vmHost)

            $this.PopulateResult($vmHostAuthenticationInfo, $vmHost, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Authentication information for the specified VMHost.
    #>
    [PSObject] GetVMHostAuthenticationInfo($vmHost) {
        try {
            $vmHostAuthenticationInfo = Get-VMHostAuthentication -Server $this.Connection -VMHost $vmHost -ErrorAction Stop
            return $vmHostAuthenticationInfo
        }
        catch {
            throw "Could not retrieve Authentication information for VMHost $($vmHost.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Includes the specified VMHost in the specified domain.
    #>
    [void] JoinDomain($vmHostAuthenticationInfo, $vmHost) {
        $setVMHostAuthenticationParams = @{
            VMHostAuthentication = $vmHostAuthenticationInfo
            Domain = $this.DomainName
            Credential = $this.DomainCredential
            JoinDomain = $true
            Confirm = $false
            ErrorAction = 'Stop'
        }

        try {
            Set-VMHostAuthentication @setVMHostAuthenticationParams
        }
        catch {
            throw "Could not include VMHost $($vmHost.Name) in domain $($this.DomainName). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Excludes the specified VMHost from the specified domain.
    #>
    [void] LeaveDomain($vmHostAuthenticationInfo, $vmHost) {
        $setVMHostAuthenticationParams = @{
            VMHostAuthentication = $vmHostAuthenticationInfo
            LeaveDomain = $true
            Force = $true
            Confirm = $false
            ErrorAction = 'Stop'
        }

        try {
            Set-VMHostAuthentication @setVMHostAuthenticationParams
        }
        catch {
            throw "Could not exclude VMHost $($vmHost.Name) from domain $($this.DomainName). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method.
    #>
    [void] PopulateResult($vmHostAuthenticationInfo, $vmHost, $result) {
        $result.Server = $this.Connection.Name
        $result.Name = $vmHost.Name

        if ($null -ne $vmHostAuthenticationInfo.Domain) {
            $result.DomainName = $vmHostAuthenticationInfo.Domain
            $result.DomainAction = [DomainAction]::Join
        }
        else {
            $result.DomainName = $this.DomainName
            $result.DomainAction = [DomainAction]::Leave
        }
    }
}

[DscResource()]
class VMHostCache : VMHostBaseDSC {
    <#
    .DESCRIPTION

    Specifies the name of the Datastore used for swap performance enhancement.
    #>
    [DscProperty(Key)]
    [string] $DatastoreName

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
            $foundDatastore = Get-Datastore -Server $this.Connection -Name $this.DatastoreName -RelatedObject $vmHost -ErrorAction Stop
            return $foundDatastore
        }
        catch {
            throw "Could not retrieve Datastore $($this.DatastoreName) for VMHost $($this.Name). For more information: $($_.Exception.Message)"
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

        $result.DatastoreName = $foundDatastore.Name
        $result.SwapSizeGB = $this.ConvertMBValueToGBValue($datastoreCacheInfo.SwapSize)
    }
}

[DscResource()]
class VMHostConfiguration : VMHostBaseDSC {
    <#
    .DESCRIPTION

    Specifies the state of the VMHost. If there are powered on VMs on the VMHost, the VMHost can be set into Maintenance mode, only if it is a part of a Drs-enabled Cluster.
    Before entering Maintenance mode, if the VMHost is fully automated, all powered on VMs are relocated. If the VMHost is not fully automated,
    a Drs recommendation is generated and all powered on VMs are relocated or powered off.
    Valid values are Connected, Disconnected and Maintenance.
    #>
    [DscProperty()]
    [VMHostState] $State = [VMHostState]::Unset

    <#
    .DESCRIPTION

    Specifies the license key to be used by the VMHost. You can set the VMHost to evaluation mode by passing the '00000-00000-00000-00000-00000' evaluation key.
    #>
    [DscProperty()]
    [string] $LicenseKey

    <#
    .DESCRIPTION

    Specifies the name of the Time Zone for the VMHost.
    #>
    [DscProperty()]
    [string] $TimeZoneName

    <#
    .DESCRIPTION

    Specifies the name of the Datastore that is visible to the VMHost and can be used for storing swapfiles for the VMs that run on the VMHost. Using a VMHost-specific
    swap location might degrade the VMotion performance.
    #>
    [DscProperty()]
    [string] $VMSwapfileDatastoreName

    <#
    .DESCRIPTION

    Specifies the swapfile placement policy.
    Valid values are InHostDatastore and WithVM.
    #>
    [DscProperty()]
    [VMSwapfilePolicy] $VMSwapfilePolicy = [VMSwapfilePolicy]::Unset

    <#
    .DESCRIPTION

    Specifies the name of the host profile associated with the VMHost. If the value is an empty string, the current profile association should not exist.
    #>
    [DscProperty()]
    [string] $HostProfileName

    <#
    .DESCRIPTION

    Specifies the name of the KmsCluster which is used to generate a key to set the VMHost. If the property is passed and the VMHost is not in CryptoSafe state,
    the DSC Resource makes the VMHost CryptoSafe. If the property is passed and the VMHost is already in CryptoSafe state, the DSC Resource resets the CryptoKey in the VMHost.
    #>
    [DscProperty()]
    [string] $KmsClusterName

    <#
    .DESCRIPTION

    If the value is $true, vCenter Server system automatically reregisters the VMs that are compatible for reregistration. If they are not compatible, they remain on the VMHost.
    The Evacuate property is valid only when the connection is to a vCenter Server system and the State property is 'Maintenance'. Also, the VMHost must be in a Drs-enabled Cluster.
    #>
    [DscProperty()]
    [nullable[bool]] $Evacuate

    <#
    .DESCRIPTION

    Specifies the special action to take regarding Virtual SAN data when moving in Maintenance mode. The VsanDataMigrationMode property is valid only when the connection is to a
    vCenter Server system and the State property is 'Maintenance'.
    #>
    [DscProperty()]
    [VsanDataMigrationMode] $VsanDataMigrationMode = [VsanDataMigrationMode]::Unset

    hidden [string] $ClusterType = 'VMware.VimAutomation.ViCore.Types.V1.Inventory.Cluster'
    hidden [int] $EnterMaintenanceModeTaskSecondsToSleep = 5

    hidden [string] $ModifyVMHostConfigurationMessage = "Modifying the configuration of VMHost {0}."
    hidden [string] $ApplyingDrsRecommendationsFromClusterMessage = "Applying Drs Recommendations from Cluster {0}."
    hidden [string] $VMHostStateWasChangedSuccessfullyMessage = "The state of the VMHost {0} was changed successfully to {1}."
    hidden [string] $ModifyVMHostCryptoKeyMessage = "Modifying the Crypto Key of VMHost {0} by using Kms Cluster {1}."

    hidden [string] $CouldNotRetrieveTimeZoneMessage = "Could not retrieve Time Zone {0} available on VMHost {1}. For more information: {2}"
    hidden [string] $CouldNotRetrieveDatastoreMessage = "Could not retrieve Datastore {0} from VMHost {1}. For more information: {2}"
    hidden [string] $CouldNotRetrieveHostProfileMessage = "Could not retrieve Host Profile {0} from Server {1}. For more information: {2}"
    hidden [string] $CouldNotRetrieveHostProfileAssociatedWithVMHostMessage = "Could not retrieve Host Profile associated with VMHost {0}. For more information: {1}"
    hidden [string] $CouldNotRetrieveKmsClusterMessage = "Could not retrieve Kms Cluster {0} from the Server. For more information: {1}"
    hidden [string] $CouldNotModifyVMHostConfigurationMessage = "Could not modify the configuration of VMHost {0}. For more information: {1}"
    hidden [string] $CouldNotModifyVMHostCryptoKeyMessage = "Could not modify the Crypto Key of VMHost {0} by using Kms Cluster {1}. For more information: {2}"

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()

            if ($this.ShouldModifyVMHostConfiguration($vmHost)) {
                $setVMHostParams = $this.GetVMHostParamsToModify($vmHost)

                if ($this.ShouldApplyDrsRecommendation($vmHost)) {
                    $this.ModifyVMHostConfigurationAndApplyDrsRecommendation($setVMHostParams)
                }
                else {
                    $this.ModifyVMHostConfiguration($setVMHostParams)
                }
            }

            if ($this.ShouldModifyCryptoKeyOfVMHost($vmHost)) {
                $this.ModifyVMHostCryptoKey($vmHost)
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

            $vmHost = $this.GetVMHost()
            $result = $true

            if ($this.ShouldModifyVMHostConfiguration($vmHost) -or $this.ShouldModifyCryptoKeyOfVMHost($vmHost)) {
                $result = $false
            }

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [VMHostConfiguration] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [VMHostConfiguration]::new()

            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.PopulateResult($result, $vmHost)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Time Zone with the specified name available on the specified VMHost.
    #>
    [PSObject] GetVMHostTimeZone($vmHost) {
        $getVMHostAvailableTimeZoneParams = @{
            Server = $this.Connection
            Name = $this.TimeZoneName
            VMHost = $vmHost
            ErrorAction = 'Stop'
            Verbose = $false
        }

        try {
            $vmHostTimeZone = Get-VMHostAvailableTimeZone @getVMHostAvailableTimeZoneParams
            return $vmHostTimeZone
        }
        catch {
            throw ($this.CouldNotRetrieveTimeZoneMessage -f $this.TimeZoneName, $vmHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Datastore with the specified name that is used for storing swapfiles for the VMs that run on the specified VMHost.
    #>
    [PSObject] GetVMSwapfileDatastore($vmHost) {
        $getDatastoreParams = @{
            Server = $this.Connection
            Name = $this.VMSwapfileDatastoreName
            VMHost = $vmHost
            ErrorAction = 'Stop'
            Verbose = $false
        }

        try {
            $vmSwapfileDatastore = Get-Datastore @getDatastoreParams
            return $vmSwapfileDatastore
        }
        catch {
            throw ($this.CouldNotRetrieveDatastoreMessage -f $this.VMSwapfileDatastoreName, $vmHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Host Profile with the specified name from the Server.
    #>
    [PSObject] GetHostProfile() {
        $getVMHostProfileParams = @{
            Server = $this.Connection
            Name = $this.HostProfileName
            ErrorAction = 'Stop'
            Verbose = $false
        }

        try {
            $hostProfile = Get-VMHostProfile @getVMHostProfileParams
            return $hostProfile
        }
        catch {
            throw ($this.CouldNotRetrieveHostProfileMessage -f $this.HostProfileName, $this.Connection.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Host Profile associated with the specified VMHost if the VMHost is associated with a Host Profile.
    Otherwise returns $null, which indicates that the VMHost is not associated with a Host Profile.
    #>
    [PSObject] GetHostProfileAssociatedWithVMHost($vmHost) {
        $getVMHostProfileParams = @{
            Server = $this.Connection
            Entity = $vmHost
            ErrorAction = 'SilentlyContinue'
            Verbose = $false
        }

        if (![string]::IsNullOrEmpty($this.HostProfileName)) {
            $getVMHostProfileParams.Name = $this.HostProfileName
        }

        try {
            $hostProfileAssociatedWithVMHost = Get-VMHostProfile @getVMHostProfileParams
            return $hostProfileAssociatedWithVMHost
        }
        catch {
            throw ($this.CouldNotRetrieveHostProfileAssociatedWithVMHostMessage -f $vmHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Kms Cluster with the specified name from the Server.
    #>
    [PSObject] GetKmsCluster() {
        try {
            $kmsCluster = Get-KmsCluster -Server $this.Connection -Name $this.KmsClusterName -ErrorAction Stop -Verbose:$false
            return $kmsCluster
        }
        catch {
            throw ($this.CouldNotRetrieveKmsClusterMessage -f $this.KmsClusterName, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Populates and returns the parameters which should be modified with the Set-VMHost cmdlet.
    #>
    [hashtable] GetVMHostParamsToModify($vmHost) {
        $setVMHostParams = @{
            Server = $this.Connection
            VMHost = $vmHost
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        if (
            ![string]::IsNullOrEmpty($this.LicenseKey) -and
            $this.LicenseKey -ne $vmHost.LicenseKey
        ) { $setVMHostParams.LicenseKey = $this.LicenseKey }

        if (
            ![string]::IsNullOrEmpty($this.TimeZoneName) -and
            $this.TimeZoneName -ne $vmHost.TimeZone.Name
        ) { $setVMHostParams.TimeZone = $this.GetVMHostTimeZone($vmHost) }

        if (
            ![string]::IsNullOrEmpty($this.VMSwapfileDatastoreName) -and
            $this.VMSwapfileDatastoreName -ne $vmHost.VMSwapfileDatastore.Name
        ) { $setVMHostParams.VMSwapfileDatastore = $this.GetVMSwapfileDatastore($vmHost) }

        if (
            $this.VMSwapfilePolicy -ne [VMSwapfilePolicy]::Unset -and
            $this.VMSwapfilePolicy.ToString() -ne $vmHost.VMSwapfilePolicy.ToString()
        ) { $setVMHostParams.VMSwapfilePolicy = $this.VMSwapfilePolicy.ToString() }

        if ($null -ne $this.HostProfileName) {
            if ($this.HostProfileName -eq [string]::Empty) {
                # Profile value '$null' cannot be passed if the specified VMHost does not have a Host Profile associated with it.
                $hostProfileAssociatedWithVMHost = $this.GetHostProfileAssociatedWithVMHost($vmHost)
                if ($null -ne $hostProfileAssociatedWithVMHost) {
                    $setVMHostParams.Profile = $null
                }
            }
            else {
                $setVMHostParams.Profile = $this.GetHostProfile()
            }
        }

        if (
            $this.State -ne [VMHostState]::Unset -and
            $this.State.ToString() -ne $vmHost.ConnectionState.ToString()
        ) {
            $setVMHostParams.State = $this.State.ToString()
            if ($this.State -eq [VMHostState]::Maintenance) {
                if ($null -ne $this.Evacuate) { $setVMHostParams.Evacuate = $this.Evacuate }
                if ($this.VsanDataMigrationMode -ne [VsanDataMigrationMode]::Unset) { $setVMHostParams.VsanDataMigrationMode = $this.VsanDataMigrationMode.ToString() }
            }
        }

        return $setVMHostParams
    }

    <#
    .DESCRIPTION

    Checks if the configuration of the specified VMHost should be modified.
    #>
    [bool] ShouldModifyVMHostConfiguration($vmHost) {
        $shouldModifyVMHostConfiguration = @()

        <#
        Evacuate and VsanDataMigrationMode properties are not used when determining the Desired State because they are applicable only when
        the desired 'State' of the VMHost is 'Maintenance' and the current one is not.
        #>
        $shouldModifyVMHostConfiguration += ($this.State -ne [VMHostState]::Unset -and $this.State.ToString() -ne $vmHost.ConnectionState.ToString())
        $shouldModifyVMHostConfiguration += (![string]::IsNullOrEmpty($this.LicenseKey) -and $this.LicenseKey -ne $vmHost.LicenseKey)
        $shouldModifyVMHostConfiguration += (![string]::IsNullOrEmpty($this.TimeZoneName) -and $this.TimeZoneName -ne $vmHost.TimeZone.Name)
        $shouldModifyVMHostConfiguration += (![string]::IsNullOrEmpty($this.VMSwapfileDatastoreName) -and $this.VMSwapfileDatastoreName -ne $vmHost.VMSwapfileDatastore.Name)
        $shouldModifyVMHostConfiguration += ($this.VMSwapfilePolicy -ne [VMSwapfilePolicy]::Unset -and $this.VMSwapfilePolicy.ToString() -ne $vmHost.VMSwapfilePolicy.ToString())

        <#
        If the Host Profile name is specified and it is an empty string, the VMHost should not be associated with a Host Profile.
        If the Host Profile name is not an empty string, the VMHost should be associated with the specified Host Profile.
        #>
        if ($null -ne $this.HostProfileName) {
            $hostProfileAssociatedWithVMHost = $this.GetHostProfileAssociatedWithVMHost($vmHost)
            if ($this.HostProfileName -eq [string]::Empty) {
                $shouldModifyVMHostConfiguration += ($null -ne $hostProfileAssociatedWithVMHost)
            }
            else {
                $shouldModifyVMHostConfiguration += ($null -eq $hostProfileAssociatedWithVMHost)
            }
        }

        return ($shouldModifyVMHostConfiguration -Contains $true)
    }

    <#
    .DESCRIPTION

    Checks if the CryptoKey of the specified VMHost should be modified.
    #>
    [bool] ShouldModifyCryptoKeyOfVMHost($vmHost) {
        $result = $false

        if (![string]::IsNullOrEmpty($this.KmsClusterName)) {
            $kmsCluster = $this.GetKmsCluster()
            $result = ($kmsCluster.Id -ne $vmHost.ExtensionData.Runtime.CryptoKeyId.ProviderId.Id)
        }

        return $result
    }

    <#
    .DESCRIPTION

    Checks if a Drs recommendation should be generated and applied. A Drs recommendation is generated when the following criteria is met:
    1. State property is specified with 'Maintenance' value.
    2. The current State of the VMHost is not 'Maintenance'.
    3. The VMHost is part of a Drs Cluster and the Cluster is not 'Fully Automated'.
    #>
    [bool] ShouldApplyDrsRecommendation($vmHost) {
        $result = $false
        $vmHostParent = $vmHost.Parent

        if (
            $this.State -ne [VMHostState]::Unset -and
            $this.State -eq [VMHostState]::Maintenance -and
            $vmHost.ConnectionState.ToString() -ne ([VMHostState]::Maintenance).ToString() -and
            $this.IsVIObjectOfTheCorrectType($vmHostParent, $this.ClusterType)
        ) {
            $clusterAutomationLevel = $vmHostParent.DrsAutomationLevel.ToString()
            $result = (
                $vmHostParent.DrsEnabled -and
                $clusterAutomationLevel -ne ([DrsAutomationLevel]::FullyAutomated).ToString()
            )
        }

        return $result
    }

    <#
    .DESCRIPTION

    Modifies the specified configuration parameters of the VMHost.
    Generates and applies the Drs Recommendation from the Cluster of the specified VMHost.
    #>
    [void] ModifyVMHostConfigurationAndApplyDrsRecommendation($setVMHostParams) {
        $setVMHostParams.RunAsync = $true

        try {
            Write-VerboseLog -Message $this.ModifyVMHostConfigurationMessage -Arguments @($setVMHostParams.VMHost.Name)
            $modifyVMHostConfigurationTask = Set-VMHost @setVMHostParams

            # The Drs Recommendation is not generated immediately after 'EnterMaintenance' task generation.
            Start-Sleep -Seconds $this.EnterMaintenanceModeTaskSecondsToSleep

            $getDrsRecommendationParams = @{
                Server = $this.Connection
                Cluster = $setVMHostParams.VMHost.Parent
                Refresh = $true
                ErrorAction = 'Stop'
                Verbose = $false
            }

            $clusterDrsRecommendations = Get-DrsRecommendation @getDrsRecommendationParams
            if ($null -ne $clusterDrsRecommendations) {
                $applyDrsRecommendationParams = @{
                    DrsRecommendation = $clusterDrsRecommendations
                    RunAsync = $true
                    Confirm = $false
                    ErrorAction = 'Stop'
                    Verbose = $false
                }

                # All generated Drs Recommendations from the Cluster should be applied and when the Task is completed all powered on VMs are relocated or powered off.
                Write-VerboseLog -Message $this.ApplyingDrsRecommendationsFromClusterMessage -Arguments @($setVMHostParams.VMHost.Parent.Name)
                $applyDrsRecommendationTask = Apply-DrsRecommendation @applyDrsRecommendationParams
                Wait-Task -Task $applyDrsRecommendationTask -ErrorAction Stop -Verbose:$false
            }

            Wait-Task -Task $modifyVMHostConfigurationTask -ErrorAction Stop -Verbose:$false
            $vmHost = $this.GetVMHost()

            # The state of the VMHost should be verified when the Task completes.
            if ($vmHost.ConnectionState.ToString() -eq ([VMHostState]::Maintenance).ToString()) {
                Write-VerboseLog -Message $this.VMHostStateWasChangedSuccessfullyMessage -Arguments @($vmHost.Name, $vmHost.ConnectionState.ToString())
            }
        }
        catch {
            throw ($this.CouldNotModifyVMHostConfigurationMessage -f $setVMHostParams.VMHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Modifies the specified configuration parameters of the VMHost.
    #>
    [void] ModifyVMHostConfiguration($setVMHostParams) {
        try {
            Write-VerboseLog -Message $this.ModifyVMHostConfigurationMessage -Arguments @($setVMHostParams.VMHost.Name)
            Set-VMHost @setVMHostParams
        }
        catch {
            throw ($this.CouldNotModifyVMHostConfigurationMessage -f $setVMHostParams.VMHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Modifies the CryptoKey of the specified VMHost.
    #>
    [void] ModifyVMHostCryptoKey($vmHost) {
        $setVMHostParams = @{
            Server = $this.Connection
            VMHost = $vmHost
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        $kmsCluster = $this.GetKmsCluster()
        $setVMHostParams.KmsCluster = $kmsCluster

        try {
            Write-VerboseLog -Message $this.ModifyVMHostCryptoKeyMessage -Arguments @($vmHost.Name, $kmsCluster.Name)
            Set-VMHost @setVMHostParams
        }
        catch {
            throw ($this.CouldNotModifyVMHostCryptoKeyMessage -f $vmHost.Name, $kmsCluster.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $vmHost) {
        $result.Server = $this.Connection.Name
        $result.Name = $vmHost.Name
        $result.State = $vmHost.ConnectionState.ToString()
        $result.Evacuate = $this.Evacuate
        $result.VsanDataMigrationMode = $this.VsanDataMigrationMode
        $result.LicenseKey = $vmHost.LicenseKey
        $result.TimeZoneName = $vmHost.TimeZone.Name
        $result.VMSwapfileDatastoreName = $vmHost.VMSwapfileDatastore.Name
        $result.VMSwapfilePolicy = $vmHost.VMSwapfilePolicy.ToString()

        $hostProfileAssociatedWithVMHost = $this.GetHostProfileAssociatedWithVMHost($vmHost)
        $result.HostProfileName = $hostProfileAssociatedWithVMHost.Name

        if (![string]::IsNullOrEmpty($this.KmsClusterName)) {
            $kmsCluster = $this.GetKmsCluster()
            $result.KmsClusterName = if ($kmsCluster.Id -ne $vmHost.ExtensionData.Runtime.CryptoKeyId.ProviderId.Id) { $kmsCluster.Name } else { $null }
        }
        else {
            $result.KmsClusterName = $this.KmsClusterName
        }
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
class VMHostFirewallRuleset : VMHostEntityBaseDSC {
    <#
    .DESCRIPTION

    Specifies the name of the firewall ruleset.
    #>
    [DscProperty(Key)]
    [string] $Name

    <#
    .DESCRIPTION

    Specifies whether the firewall ruleset should be enabled or disabled.
    #>
    [DscProperty()]
    [nullable[bool]] $Enabled

    <#
    .DESCRIPTION

    Specifies whether the firewall ruleset allows connections from any IP address.
    #>
    [DscProperty()]
    [nullable[bool]] $AllIP

    <#
    .DESCRIPTION

    Specifies the list of IP addresses. All IPv4 addresses are specified using dotted decimal format. For example '192.0.20.10'.
    IPv6 addresses are 128-bit addresses represented as eight fields of up to four hexadecimal digits. A colon separates each field (:).
    For example 2001:DB8:101::230:6eff:fe04:d9ff. The address can also consist of symbol '::' to represent multiple 16-bit groups of contiguous 0's only once in an address.
    #>
    [DscProperty()]
    [string[]] $IPAddresses

    hidden [string] $ModifyVMHostFirewallRulesetStateMessage = "Modifying the state of firewall ruleset {0} on VMHost {1}."
    hidden [string] $ModifyVMHostFirewallRulesetAllowedIPAddressesListMessage = "Modifying the allowed IP addresses list of firewall ruleset {0} on VMHost {1}."

    hidden [string] $CouldNotRetrieveFirewallSystemOfVMHostMessage = "Could not retrieve the FirewallSystem managed object of VMHost {0}. For more information: {1}"
    hidden [string] $CouldNotRetrieveFirewallRulesetMessage = "Could not retrieve firewall ruleset {0} from VMHost {1}. For more information: {2}"
    hidden [string] $CouldNotModifyVMHostFirewallRulesetStateMessage = "Could not modify the state of firewall ruleset {0} on VMHost {1}. For more information: {2}"
    hidden [string] $CouldNotModifyVMHostFirewallRulesetAllowedIPAddressesListMessage = "Could not modify the allowed IP addresses list of firewall ruleset {0} on VMHost {1}. For more information: {2}"

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()

            $this.RetrieveVMHost()
            $vmHostFirewallRuleset = $this.GetVMHostFirewallRuleset()

            if ($this.ShouldModifyVMHostFirewallRulesetState($vmHostFirewallRuleset)) {
                $this.ModifyVMHostFirewallRulesetState($vmHostFirewallRuleset)
            }

            if ($this.ShouldModifyVMHostFirewallRulesetAllowedIPAddressesList($vmHostFirewallRuleset)) {
                $vmHostFirewallSystem = $this.GetVMHostFirewallSystem()
                $this.ModifyVMHostFirewallRulesetAllowedIPAddressesList($vmHostFirewallSystem, $vmHostFirewallRuleset)
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

            $this.RetrieveVMHost()
            $vmHostFirewallRuleset = $this.GetVMHostFirewallRuleset()

            $result = !($this.ShouldModifyVMHostFirewallRulesetState($vmHostFirewallRuleset) -or $this.ShouldModifyVMHostFirewallRulesetAllowedIPAddressesList($vmHostFirewallRuleset))

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [VMHostFirewallRuleset] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [VMHostFirewallRuleset]::new()

            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $vmHostFirewallRuleset = $this.GetVMHostFirewallRuleset()

            $this.PopulateResult($result, $vmHostFirewallRuleset)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the FirewallSystem of the specified VMHost.
    #>
    [PSObject] GetVMHostFirewallSystem() {
        try {
            $firewallSystem = Get-View -Server $this.Connection -Id $this.VMHost.ExtensionData.ConfigManager.FirewallSystem -ErrorAction Stop -Verbose:$false
            return $firewallSystem
        }
        catch {
            throw ($this.CouldNotRetrieveFirewallSystemOfVMHostMessage -f $this.VMHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the firewall ruleset with the specified name on the specified VMHost.
    #>
    [PSObject] GetVMHostFirewallRuleset() {
        try {
            $vmHostFirewallRuleset = Get-VMHostFirewallException -Server $this.Connection -Name $this.Name -VMHost $this.VMHost -ErrorAction Stop -Verbose:$false
            return $vmHostFirewallRuleset
        }
        catch {
            throw ($this.CouldNotRetrieveFirewallRulesetMessage -f $this.Name, $this.VMHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Converts the passed string array containing IP networks in the following format: '10.20.120.12/22' to HostFirewallRulesetIpNetwork array,
    where the 'Network' is '10.23.120.12' and the 'PrefixLength' is '22'.
    #>
    [array] ConvertIPNetworksToHostFirewallRulesetIpNetworks($ipNetworks) {
        $hostFirewallRulesetIpNetworks = @()

        foreach ($ipNetwork in $ipNetworks) {
            $ipNetworkParts = $ipNetwork -Split '/'

            $hostFirewallRulesetIpNetwork = New-Object -TypeName VMware.Vim.HostFirewallRulesetIpNetwork
            $hostFirewallRulesetIpNetwork.Network = $ipNetworkParts[0]
            $hostFirewallRulesetIpNetwork.PrefixLength = $ipNetworkParts[1]

            $hostFirewallRulesetIpNetworks += $hostFirewallRulesetIpNetwork
        }

        return $hostFirewallRulesetIpNetworks
    }

    <#
    .DESCRIPTION

    Converts the passed HostFirewallRulesetIpNetwork array containing IP networks in the following format: 'Network' = '10.23.120.12' and 'PrefixLength' = '22' to string array,
    where each IP network is in the following format: '10.23.120.12/22'.
    #>
    [array] ConvertHostFirewallRulesetIpNetworksToIPNetworks($hostFirewallRulesetIpNetworks) {
        $ipNetworks = @()

        foreach ($hostFirewallRulesetIpNetwork in $hostFirewallRulesetIpNetworks) {
            $ipNetwork = $hostFirewallRulesetIpNetwork.Network + '/' + $hostFirewallRulesetIpNetwork.PrefixLength
            $ipNetworks += $ipNetwork
        }

        return $ipNetworks
    }

    <#
    .DESCRIPTION

    Checks if the current firewall ruleset state (enabled or disabled) is equal to the desired firewall ruleset state.
    #>
    [bool] ShouldModifyVMHostFirewallRulesetState($vmHostFirewallRuleset) {
        return ($this.Enabled -ne $null -and $this.Enabled -ne $vmHostFirewallRuleset.Enabled)
    }

    <#
    .DESCRIPTION

    Checks if the current firewall ruleset IP addresses allowed list is equal to the desired firewall ruleset IP addresses allowed list.
    #>
    [bool] ShouldModifyVMHostFirewallRulesetAllowedIPAddressesList($vmHostFirewallRuleset) {
        $vmHostFirewallRulesetAllowedHosts = $vmHostFirewallRuleset.ExtensionData.AllowedHosts

        $shouldModifyVMHostFirewallRulesetAllowedIPAddressesList = @()
        $shouldModifyVMHostFirewallRulesetAllowedIPAddressesList += ($null -ne $this.AllIP -and $this.AllIP -ne $vmHostFirewallRulesetAllowedHosts.AllIp)

        if ($null -ne $this.IPAddresses) {
            $desiredIPAddresses = $this.IPAddresses -NotMatch '/'
            $desiredIPNetworks = $this.IPAddresses -Match '/'

            $shouldModifyVMHostFirewallRulesetAllowedIPAddressesList += $this.ShouldUpdateArraySetting($vmHostFirewallRulesetAllowedHosts.IpAddress, $desiredIPAddresses)
            $shouldModifyVMHostFirewallRulesetAllowedIPAddressesList += $this.ShouldUpdateArraySetting($this.ConvertHostFirewallRulesetIpNetworksToIPNetworks($vmHostFirewallRulesetAllowedHosts.IpNetwork), $desiredIPNetworks)
        }

        return ($shouldModifyVMHostFirewallRulesetAllowedIPAddressesList -Contains $true)
    }

    <#
    .DESCRIPTION

    Modifies the firewall ruleset state depending on the specified value (enables or disables the firewall ruleset).
    #>
    [void] ModifyVMHostFirewallRulesetState($vmHostFirewallRuleset) {
        $setVMHostFirewallExceptionParams = @{
            Exception = $vmHostFirewallRuleset
            Enabled = $this.Enabled
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        try {
            Write-VerboseLog -Message $this.ModifyVMHostFirewallRulesetStateMessage -Arguments @($vmHostFirewallRuleset.Name, $this.VMHost.Name)
            Set-VMHostFirewallException @setVMHostFirewallExceptionParams
        }
        catch {
            throw ($this.CouldNotModifyVMHostFirewallRulesetStateMessage -f $vmHostFirewallRuleset.Name, $this.VMHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Modifies the firewall ruleset IP addresses allowed list.
    #>
    [void] ModifyVMHostFirewallRulesetAllowedIPAddressesList($vmHostFirewallSystem, $vmHostFirewallRuleset) {
        $vmHostFirewallRulesetSpec = New-Object -TypeName VMware.Vim.HostFirewallRulesetRulesetSpec
        $vmHostFirewallRulesetSpec.AllowedHosts = New-Object -TypeName VMware.Vim.HostFirewallRulesetIpList

        if ($null -ne $this.AllIP) { $vmHostFirewallRulesetSpec.AllowedHosts.AllIp = $this.AllIP }

        if ($null -ne $this.IPAddresses) {
            $desiredIPAddresses = $this.IPAddresses -NotMatch '/'
            $desiredIPNetworks = $this.IPAddresses -Match '/'

            $vmHostFirewallRulesetSpec.AllowedHosts.IpAddress = $desiredIPAddresses
            $vmHostFirewallRulesetSpec.AllowedHosts.IpNetwork = $this.ConvertIPNetworksToHostFirewallRulesetIpNetworks($desiredIPNetworks)
        }

        try {
            Write-VerboseLog -Message $this.ModifyVMHostFirewallRulesetAllowedIPAddressesListMessage -Arguments @($vmHostFirewallRuleset.Name, $this.VMHost.Name)
            Update-VMHostFirewallRuleset -VMHostFirewallSystem $vmHostFirewallSystem -VMHostFirewallRulesetId $vmHostFirewallRuleset.ExtensionData.Key -VMHostFirewallRulesetSpec $vmHostFirewallRulesetSpec
        }
        catch {
            throw ($this.CouldNotModifyVMHostFirewallRulesetAllowedIPAddressesListMessage -f $vmHostFirewallRuleset.Name, $this.VMHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $vmHostFirewallRuleset) {
        $result.Server = $this.Connection.Name
        $result.VMHostName = $this.VMHost.Name
        $result.Name = $vmHostFirewallRuleset.Name
        $result.Enabled = $vmHostFirewallRuleset.Enabled

        $vmHostFirewallRulesetAllowedHosts = $vmHostFirewallRuleset.ExtensionData.AllowedHosts
        $result.AllIP = $vmHostFirewallRulesetAllowedHosts.AllIp
        $result.IPAddresses = $vmHostFirewallRulesetAllowedHosts.IpAddress + $this.ConvertHostFirewallRulesetIpNetworksToIPNetworks($vmHostFirewallRulesetAllowedHosts.IpNetwork)
    }
}

[DscResource()]
class VMHostIScsiHba : VMHostIScsiHbaBaseDSC {
    <#
    .DESCRIPTION

    Specifies the name of the iSCSI Host Bus Adapter.
    #>
    [DscProperty(Key)]
    [string] $Name

    hidden [string] $ConfigureIScsiHbaChapMessage = "Configuring CHAP settings of iSCSI Host Bus Adapter {0} from VMHost {1}."

    hidden [string] $CouldNotConfigureIScsiHbaChapMessage = "Could not configure CHAP settings of iSCSI Host Bus Adapter {0} from VMHost {1}. For more information: {2}"

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $iScsiHba = $this.GetIScsiHba($this.Name)

            $this.ConfigureIScsiHbaChap($iScsiHba)
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

            $iScsiHba = $this.GetIScsiHba($this.Name)

            $result = !$this.ShouldModifyCHAPSettings($iScsiHba.AuthenticationProperties)

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [VMHostIScsiHba] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [VMHostIScsiHba]::new()

            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $iScsiHba = $this.GetIScsiHba($this.Name)

            $this.PopulateResult($result, $iScsiHba)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Configures the CHAP properties of the specified iSCSI Host Bus Adapter.
    #>
    [void] ConfigureIScsiHbaChap($iScsiHba) {
        $setVMHostHbaParams = @{
            IScsiHba = $iScsiHba
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        $this.PopulateCmdletParametersWithCHAPSettings($setVMHostHbaParams)

        try {
            Write-VerboseLog -Message $this.ConfigureIScsiHbaChapMessage -Arguments @($iScsiHba.Device, $this.VMHost.Name)
            Set-VMHostHba @setVMHostHbaParams
        }
        catch {
            throw ($this.CouldNotConfigureIScsiHbaChapMessage -f $iScsiHba.Device, $this.VMHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $iScsiHba) {
        $result.Server = $this.Connection.Name
        $result.VMHostName = $this.VMHost.Name
        $result.Name = $iScsiHba.Device
        $result.ChapType = $iScsiHba.AuthenticationProperties.ChapType.ToString()
        $result.ChapName = [string] $iScsiHba.AuthenticationProperties.ChapName
        $result.MutualChapEnabled = $iScsiHba.AuthenticationProperties.MutualChapEnabled
        $result.MutualChapName = [string] $iScsiHba.AuthenticationProperties.MutualChapName
        $result.Force = $this.Force
    }
}

[DscResource()]
class VMHostIScsiHbaTarget : VMHostIScsiHbaBaseDSC {
    <#
    .DESCRIPTION

    Specifies the address of the iSCSI Host Bus Adapter target.
    #>
    [DscProperty(Key)]
    [string] $Address

    <#
    .DESCRIPTION

    Specifies the TCP port of the iSCSI Host Bus Adapter target.
    #>
    [DscProperty(Key)]
    [int] $Port

    <#
    .DESCRIPTION

    Specifies the name of the iSCSI Host Bus Adapter of the iSCSI Host Bus Adapter target.
    #>
    [DscProperty(Key)]
    [string] $IScsiHbaName

    <#
    .DESCRIPTION

    Specifies the type of the iSCSI Host Bus Adapter target.
    #>
    [DscProperty(Key)]
    [IScsiHbaTargetType] $TargetType

    <#
    .DESCRIPTION

    Specifies whether the iSCSI Host Bus Adapter target should be present or absent.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    <#
    .DESCRIPTION

    Specifies the iSCSI name of the iSCSI Host Bus Adapter target. It is required for Static iSCSI Host Bus Adapter targets.
    #>
    [DscProperty()]
    [string] $IScsiName

    <#
    .DESCRIPTION

    Indicates that the CHAP setting is inherited from the iSCSI Host Bus Adapter.
    #>
    [DscProperty()]
    [nullable[bool]] $InheritChap

    <#
    .DESCRIPTION

    Indicates that the Mutual CHAP setting is inherited from the iSCSI Host Bus Adapter.
    #>
    [DscProperty()]
    [nullable[bool]] $InheritMutualChap

    <#
    .DESCRIPTION

    Specifies the <Address>:<Port> that uniquely identifies an iSCSI Host Bus Adapter target.
    #>
    hidden [string] $IPEndPoint

    hidden [string] $CreateIScsiHbaTargetMessage = "Creating iSCSI Host Bus Adapter target with IP address {0} on iSCSI Host Bus Adapter device {1}."
    hidden [string] $ModifyIScsiHbaTargetMessage = "Modifying CHAP settings of iSCSI Host Bus Adapter target with IP address {0} on iSCSI Host Bus Adapter device {1}."
    hidden [string] $RemoveIScsiHbaTargetMessage = "Removing iSCSI Host Bus Adapter target with IP address {0} from iSCSI Host Bus Adapter device {1}."

    hidden [string] $CouldNotCreateIScsiHbaTargetMessage = "Could not create iSCSI Host Bus Adapter target with IP address {0} on iSCSI Host Bus Adapter device {1}. For more information: {2}"
    hidden [string] $CouldNotModifyIScsiHbaTargetMessage = "Could not modify CHAP settings of iSCSI Host Bus Adapter target with IP address {0} on iSCSI Host Bus Adapter device {1}. For more information: {2}"
    hidden [string] $CouldNotRemoveIScsiHbaTargetMessage = "Could not remove iSCSI Host Bus Adapter target with IP address {0} from iSCSI Host Bus Adapter device {1}. For more information: {2}"

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()
            $this.RetrieveVMHost()
            $this.IPEndPoint = $this.Address + ':' + $this.Port.ToString()

            $iScsiHba = $this.GetIScsiHba($this.IScsiHbaName)
            $iScsiHbaTarget = $this.GetIScsiHbaTarget($iScsiHba)

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $iScsiHbaTarget) {
                    $this.NewIScsiHbaTarget($iScsiHba)
                }
                else {
                    $this.ModifyIScsiHbaTarget($iScsiHbaTarget)
                }
            }
            else {
                if ($null -ne $iScsiHbaTarget) {
                    $this.RemoveIScsiHbaTarget($iScsiHbaTarget)
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
            $this.RetrieveVMHost()
            $this.IPEndPoint = $this.Address + ':' + $this.Port.ToString()

            $iScsiHba = $this.GetIScsiHba($this.IScsiHbaName)
            $iScsiHbaTarget = $this.GetIScsiHbaTarget($iScsiHba)

            $result = $null

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $iScsiHbaTarget) {
                    $result = $false
                }
                else {
                    $result = !$this.ShouldModifyCHAPSettings($iScsiHbaTarget.AuthenticationProperties, $this.InheritChap, $this.InheritMutualChap)
                }
            }
            else {
                $result = ($null -eq $iScsiHbaTarget)
            }

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [VMHostIScsiHbaTarget] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [VMHostIScsiHbaTarget]::new()

            $this.ConnectVIServer()
            $this.RetrieveVMHost()
            $this.IPEndPoint = $this.Address + ':' + $this.Port.ToString()

            $iScsiHba = $this.GetIScsiHba($this.IScsiHbaName)
            $iScsiHbaTarget = $this.GetIScsiHbaTarget($iScsiHba)

            $this.PopulateResult($result, $iScsiHbaTarget)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the iSCSI Host Bus Adapter target with the specified IPEndPoint for the specified iSCSI Host Bus Adapter if it exists.
    #>
    [PSObject] GetIScsiHbaTarget($iScsiHba) {
        $getIScsiHbaTargetParams = @{
            Server = $this.Connection
            IScsiHba = $iScsiHba
            IPEndPoint = $this.IPEndPoint
            Type = $this.TargetType.ToString()
            ErrorAction = 'SilentlyContinue'
            Verbose = $false
        }

        return Get-IScsiHbaTarget @getIScsiHbaTargetParams
    }

    <#
    .DESCRIPTION

    Creates a new iSCSI Host Bus Adapter target of the specified type with the specified address for the specified iSCSI Host Bus Adapter.
    #>
    [void] NewIScsiHbaTarget($iScsiHba) {
        $newIScsiHbaTargetParams = @{
            Server = $this.Connection
            Address = $this.Address
            Port = $this.Port
            IScsiHba = $iScsiHba
            Type = $this.TargetType.ToString()
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        if ($this.TargetType -eq [IScsiHbaTargetType]::Static) { $newIScsiHbaTargetParams.IScsiName = $this.IScsiName }
        $this.PopulateCmdletParametersWithCHAPSettings($newIScsiHbaTargetParams, $this.InheritChap, $this.InheritMutualChap)

        try {
            Write-VerboseLog -Message $this.CreateIScsiHbaTargetMessage -Arguments @($this.IPEndPoint, $this.IScsiHbaName)
            New-IScsiHbaTarget @newIScsiHbaTargetParams
        }
        catch {
            throw ($this.CouldNotCreateIScsiHbaTargetMessage -f $this.IPEndPoint, $this.IScsiHbaName, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Modifies the CHAP settings of the specified iSCSI Host Bus Adapter target.
    #>
    [void] ModifyIScsiHbaTarget($iScsiHbaTarget) {
        $setIScsiHbaTargetParams = @{
            Server = $this.Connection
            Target = $iScsiHbaTarget
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        $this.PopulateCmdletParametersWithCHAPSettings($setIScsiHbaTargetParams, $this.InheritChap, $this.InheritMutualChap)

        try {
            Write-VerboseLog -Message $this.ModifyIScsiHbaTargetMessage -Arguments @($this.IPEndPoint, $this.IScsiHbaName)
            Set-IScsiHbaTarget @setIScsiHbaTargetParams
        }
        catch {
            throw ($this.CouldNotModifyIScsiHbaTargetMessage -f $this.IPEndPoint, $this.IScsiHbaName, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Removes the specified iSCSI Host Bus Adapter target from its iSCSI Host Bus Adapter.
    #>
    [void] RemoveIScsiHbaTarget($iScsiHbaTarget) {
        $removeIScsiHbaTargetParams = @{
            Server = $this.Connection
            Target = $iScsiHbaTarget
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        try {
            Write-VerboseLog -Message $this.RemoveIScsiHbaTargetMessage -Arguments @($this.IPEndPoint, $this.IScsiHbaName)
            Remove-IScsiHbaTarget @removeIScsiHbaTargetParams
        }
        catch {
            throw ($this.CouldNotRemoveIScsiHbaTargetMessage -f $this.IPEndPoint, $this.IScsiHbaName, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $iScsiHbaTarget) {
        $result.Server = $this.Connection.Name
        $result.VMHostName = $this.VMHost.Name
        $result.IScsiHbaName = $this.IScsiHbaName
        $result.Force = $this.Force

        if ($null -ne $iScsiHbaTarget) {
            $result.Address = $iScsiHbaTarget.Address
            $result.Port = $iScsiHbaTarget.Port
            $result.TargetType = $iScsiHbaTarget.Type.ToString()
            $result.IScsiName = $iScsiHbaTarget.IScsiName
            $result.InheritChap = $iScsiHbaTarget.AuthenticationProperties.ChapInherited
            $result.ChapType = $iScsiHbaTarget.AuthenticationProperties.ChapType.ToString()
            $result.ChapName = [string] $iScsiHbaTarget.AuthenticationProperties.ChapName
            $result.InheritMutualChap = $iScsiHbaTarget.AuthenticationProperties.MutualChapInherited
            $result.MutualChapEnabled = $iScsiHbaTarget.AuthenticationProperties.MutualChapEnabled
            $result.MutualChapName = [string] $iScsiHbaTarget.AuthenticationProperties.MutualChapName
            $result.Ensure = [Ensure]::Present
        }
        else {
            $result.Address = $this.Address
            $result.Port = $this.Port
            $result.TargetType = $this.TargetType
            $result.IScsiName = $this.IScsiName
            $result.InheritChap = $this.InheritChap
            $result.ChapType = $this.ChapType
            $result.ChapName = $this.ChapName
            $result.InheritMutualChap = $this.InheritMutualChap
            $result.MutualChapEnabled = $this.MutualChapEnabled
            $result.MutualChapName = $this.MutualChapName
            $result.Ensure = [Ensure]::Absent
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
class VMHostPciPassthrough : VMHostRestartBaseDSC {
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
            $result.RestartTimeoutMinutes = $this.RestartTimeoutMinutes

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
class VMHostPermission : BaseDSC {
    <#
    .DESCRIPTION

    Specifies the name of the Entity to which the Permission applies.
    #>
    [DscProperty(Key)]
    [string] $EntityName

    <#
    .DESCRIPTION

    Specifies the location of the Entity with name specified in 'EntityName' key property. Location consists of 0 or more Inventory Items.
    When the Entity is a Datacenter, a VMHost or a Datastore, the property is ignored. If the Entity is a Virtual Machine, a Resource Pool or a vApp and empty location
    is passed, the Entity should be located in the Root Resource Pool of the VMHost. Inventory Item names in the location are separated by '/'.
    Example location for a Datastore Inventory Item: ''. Example location for a Virtual Machine Inventory Item: 'MyResourcePoolOne/MyResourcePoolTwo/MyvApp'.
    #>
    [DscProperty(Key)]
    [string] $EntityLocation

    <#
    .DESCRIPTION

    Specifies the type of the Entity of the Permission. Valid Entity types are: 'Datacenter', 'VMHost', 'Datastore', 'VM', 'ResourcePool' and 'VApp'.
    #>
    [DscProperty(Key)]
    [EntityType] $EntityType

    <#
    .DESCRIPTION

    Specifies the name of the User to which the Permission applies. If the User is a Domain User, the Principal name should be in one of the
    following formats: '<Domain Name>/<User name>' or '<User name>@<Domain Name>'. Example Principal name for Domain User: 'MyDomain/MyDomainUser' or 'MyDomainUser@MyDomain'.
    #>
    [DscProperty(Key)]
    [string] $PrincipalName

    <#
    .DESCRIPTION

    Specifies the name of the Role to which the Permission applies.
    #>
    [DscProperty(Key)]
    [string] $RoleName

    <#
    .DESCRIPTION

    Specifies whether the Permission should be present or absent.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    <#
    .DESCRIPTION

    Specifies whether to propagate the Permission to the child Inventory Items.
    #>
    [DscProperty()]
    [nullable[bool]] $Propagate

    hidden [string] $CreatePermissionMessage = "Creating Permission for Entity {0}, Principal {1} and Role {2} on VMHost {3}."
    hidden [string] $ModifyPermissionMessage = "Modifying Permission for Entity {0} and Principal {1} on VMHost {2}."
    hidden [string] $RemovePermissionMessage = "Removing Permission for Entity {0}, Principal {1} and Role {2} on VMHost {3}."

    hidden [string] $CouldNotRetrieveRootResourcePoolMessage = "Could not retrieve Root Resource Pool from VMHost {0}. For more information: {1}"
    hidden [string] $InvalidEntityLocationMessage = "Location {0} for Entity {1} on VMHost {2} is not valid."
    hidden [string] $CouldNotIdentifyVMMessage = "Could not uniquely identify VM with name {0} on VMHost {1}. {2} VMs with this name exist on the VMHost."
    hidden [string] $CouldNotFindEntityMessage = "Entity {0} of type {1} was not found on VMHost {2}."
    hidden [string] $CouldNotRetrievePrincipalMessage = "Could not retrieve Principal {0} from VMHost {1}. For more information: {2}"
    hidden [string] $CouldNotRetrieveRoleMessage = "Could not retrieve Role from VMHost {1}. For more information: {2}"
    hidden [string] $CouldNotCreatePermissionMessage = "Could not create Permission for Entity {0}, Principal {1} and Role {2} on VMHost {3}. For more information: {4}"
    hidden [string] $CouldNotModifyPermissionMessage = "Could not modify Permission for Entity {0} and Principal {1} on VMHost {2}. For more information: {3}"
    hidden [string] $CouldNotRemovePermissionMessage = "Could not remove Permission for Entity {0}, Principal {1} and Role {2} on VMHost {3}. For more information: {4}"

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()
            $this.EnsureConnectionIsESXi()

            $foundEntityLocation = $this.GetEntityLocation()
            $entity = $this.GetEntity($foundEntityLocation)
            $vmHostPrincipal = $this.GetVMHostPrincipal()

            $vmHostPermission = $this.GetVMHostPermission($entity, $vmHostPrincipal)

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $vmHostPermission) {
                    $this.NewVMHostPermission($entity, $vmHostPrincipal)
                }
                else {
                    $this.ModifyVMHostPermission($vmHostPermission)
                }
            }
            else {
                if ($null -ne $vmHostPermission) {
                    $this.RemoveVMHostPermission($vmHostPermission)
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
            $this.EnsureConnectionIsESXi()

            $foundEntityLocation = $this.GetEntityLocation()
            $entity = $this.GetEntity($foundEntityLocation)
            $vmHostPrincipal = $this.GetVMHostPrincipal()

            $vmHostPermission = $this.GetVMHostPermission($entity, $vmHostPrincipal)
            $result = $null

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $vmHostPermission) {
                    $result = $false
                }
                else {
                    $result = !$this.ShouldModifyVMHostPermission($vmHostPermission)
                }
            }
            else {
                $result = ($null -eq $vmHostPermission)
            }

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [VMHostPermission] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [VMHostPermission]::new()

            $this.ConnectVIServer()
            $this.EnsureConnectionIsESXi()

            $foundEntityLocation = $this.GetEntityLocation()
            $entity = $this.GetEntity($foundEntityLocation)
            $vmHostPrincipal = $this.GetVMHostPrincipal()

            $vmHostPermission = $this.GetVMHostPermission($entity, $vmHostPrincipal)
            $this.PopulateResult($result, $vmHostPermission)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Root Resource Pool from the VMHost.
    #>
    [PSObject] GetRootResourcePool() {
        try {
            $vmHost = Get-VMHost -Server $this.Connection -ErrorAction Stop -Verbose:$false
            $rootResourcePool = Get-ResourcePool -Server $this.Connection -ErrorAction Stop -Verbose:$false |
                                Where-Object -FilterScript { $_.ParentId -eq $vmHost.Id }

            return $rootResourcePool
        }
        catch {
            throw ($this.CouldNotRetrieveRootResourcePoolMessage -f $this.Connection.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the location of the Entity with the specified name on the VMHost if it exists. For VMs, Resource Pools and vApps
    if Ensure is 'Present' and the location is not found, an exception is thrown. If Ensure is 'Absent' and the location is not found, $null is returned.
    #>
    [PSObject] GetEntityLocation() {
        $foundEntityLocation = $null

        if (
            $this.EntityType -eq [EntityType]::Datacenter -or
            $this.EntityType -eq [EntityType]::VMHost -or
            $this.EntityType -eq [EntityType]::Datastore
        ) {
            # The location is not needed to identify the Entity when it is a Datacenter, VMHost or a Datastore.
            $foundEntityLocation = $null
        }
        else {
            $rootResourcePool = $this.GetRootResourcePool()

            if ([string]::IsNullOrEmpty($this.EntityLocation)) {
                # Special case where the Entity location does not contain any Inventory Items. So the Root Resource Pool is the location for the Entity.
                $foundEntityLocation = $rootResourcePool
            }
            elseif ($this.EntityLocation -NotMatch '/') {
                # Special case where the Entity location is just one Resource Pool or vApp. On VMHosts the vApps are also retrieved with the Get-ResourcePool cmdlet.
                $foundEntityLocation = Get-ResourcePool -Server $this.Connection -Name $this.EntityLocation -Location $rootResourcePool -ErrorAction SilentlyContinue -Verbose:$false |
                                       Where-Object -FilterScript { $_.ParentId -eq $rootResourcePool.Id }
            }
            else {
                $entityLocationItems = $this.EntityLocation -Split '/'

                # Reverses the Entity location items so that we can start from the bottom and go to the top of the Inventory.
                [array]::Reverse($entityLocationItems)

                $entityLocationName = $entityLocationItems[0]
                $foundEntityLocations = Get-Inventory -Server $this.Connection -Name $entityLocationName -Location $rootResourcePool -ErrorAction SilentlyContinue -Verbose:$false

                # Removes the name of the Entity location from the Entity location items array as we already retrieved it.
                $entityLocationItems = $entityLocationItems[1..($entityLocationItems.Length - 1)]

                <#
                For every found Entity Location with the specified name we start to go up through the parents to check if the Entity Location is valid.
                If one of the Parents does not meet the criteria of the Entity location, we continue with the next found Entity location.
                If we find a valid Entity location we stop iterating through the Entity locations and mark it as the found Entity location.
                #>
                foreach ($entityLocation in $foundEntityLocations) {
                    $foundEntityLocationAsViewObject = Get-View -Server $this.Connection -Id $entityLocation.Id -Verbose:$false -Property Parent
                    $validEntityLocation = $true

                    foreach ($entityLocationItem in $entityLocationItems) {
                        $foundEntityLocationAsViewObject = Get-View -Server $this.Connection -Id $foundEntityLocationAsViewObject.Parent -Verbose:$false -Property Name, Parent
                        if ($foundEntityLocationAsViewObject.Name -ne $entityLocationItem) {
                            $validEntityLocation = $false
                            break
                        }
                    }

                    if ($validEntityLocation) {
                        $foundEntityLocation = $entityLocation
                        break
                    }
                }
            }

            $exceptionMessage = $this.InvalidEntityLocationMessage -f $this.EntityLocation, $this.EntityName, $this.Connection.Name
            $this.EnsureCorrectBehaviourIfTheEntityIsNotFound($foundEntityLocation, $exceptionMessage)
        }

        return $foundEntityLocation
    }

    <#
    .DESCRIPTION

    Retrieves the Entity with the specified name from the specified location on the VMHost if it exists. For VMs, Resource Pools and vApps
    if Ensure is 'Present' and the Entity is not found, an exception is thrown. If Ensure is 'Absent' and the Entity is not found, $null is returned.
    #>
    [PSObject] GetEntity($entityLocation) {
        $entity = $null

        if ($this.EntityType -eq [EntityType]::Datacenter) {
            # Each VMHost has only one Datacenter, so the name is not needed to retrieve it.
            $entity = Get-Datacenter -Server $this.Connection -ErrorAction SilentlyContinue -Verbose:$false
        }
        elseif ($this.EntityType -eq [EntityType]::VMHost) {
            # If the Entity is a VMHost, the Entity name and location are ignored because the Connection is directly to an ESXi host.
            $entity = Get-VMHost -Server $this.Connection -ErrorAction SilentlyContinue -Verbose:$false
        }
        elseif ($this.EntityType -eq [EntityType]::Datastore) {
            # If the Entity is a Datastore, the Entity location is ignored because the name uniquely identifies the Datastore.
            $entity = Get-Datastore -Server $this.Connection -Name $this.EntityName -ErrorAction SilentlyContinue -Verbose:$false
        }
        elseif ($this.EntityType -eq [EntityType]::VM) {
            <#
            If the Entity is a VM, the Entity location is either a Resource Pool or a vApp where the VM is placed. If the VMHost is managed by a vCenter,
            there is a special case where two VMs could be created with the same name on the same VMHost but on different vCenter folders. And this way the
            VM could not be uniquely identified on the VMHost.
            #>
            $entity = Get-VM -Server $this.Connection -Name $this.EntityName -Location $entityLocation -ErrorAction SilentlyContinue -Verbose:$false

            # Only throw an exception if Ensure is 'Present', otherwise ignore that multiple VMs were found.
            if ($entity.Length -gt 1 -and $this.Ensure -eq [Ensure]::Present) {
                throw ($this.CouldNotIdentifyVMMessage -f $this.EntityName, $this.Connection.Name, $entity.Length)
            }
        }
        else {
            <#
            If the Entity is a Resource Pool or vApp, the Entity location is either a Resource Pool or a vApp where the Entity is placed. For a specific Resource Pool
            or vApp, the name does not uniquely identify the Entity because there can be other Resource Pools or vApps below in the hierarchy with the same name placed in the
            Entity location. So additional filtering is needed to verify that the Entity is directly placed in the specified Entity location.
            #>
            $entity = Get-ResourcePool -Server $this.Connection -Name $this.EntityName -Location $entityLocation -ErrorAction SilentlyContinue -Verbose:$false |
                      Where-Object -FilterScript { $_.ParentId -eq $entityLocation.Id }
        }

        $exceptionMessage = $this.CouldNotFindEntityMessage -f $this.EntityName, $this.EntityType.ToString(), $this.Connection.Name
        $this.EnsureCorrectBehaviourIfTheEntityIsNotFound($entity, $exceptionMessage)

        return $entity
    }

    <#
    .DESCRIPTION

    Retrieves the Principal with the specified name from the VMHost if it exists.
    If the name contains '\' or '@', it means that the Principal is part of a Domain, so the search for the Principal should be done by filtering by Domain.
    If Ensure is 'Present' and the Principal is not found, an exception is thrown. If Ensure is 'Absent' and the Principal is not found, $null is returned.
    #>
    [PSObject] GetVMHostPrincipal() {
        $getVIAccountParams = @{
            Server = $this.Connection
            Verbose = $false
        }

        # If the Principal is a Domain User, we should extact the Domain and User names from the Principal name.
        if ($this.PrincipalName -Match '\\') {
            $principalNameParts = $this.PrincipalName -Split '\\'
            $domainName = $principalNameParts[0]
            $username = $principalNameParts[1]

            $getVIAccountParams.Domain = $domainName
            $getVIAccountParams.User = $true
            $getVIAccountParams.Id = $username
        }
        elseif ($this.PrincipalName -Match '@') {
            $principalNameParts = $this.PrincipalName -Split '@'
            $username = $principalNameParts[0]
            $domainName = $principalNameParts[1]

            $getVIAccountParams.Domain = $domainName
            $getVIAccountParams.User = $true
            $getVIAccountParams.Id = $username
        }
        else {
            $getVIAccountParams.Id = $this.PrincipalName
        }

        if ($this.Ensure -eq [Ensure]::Absent) {
            $getVIAccountParams.ErrorAction = 'SilentlyContinue'
            return Get-VIAccount @getVIAccountParams
        }
        else {
            try {
                $getVIAccountParams.ErrorAction = 'Stop'
                $vmHostPrincipal = Get-VIAccount @getVIAccountParams

                return $vmHostPrincipal
            }
            catch {
                throw ($this.CouldNotRetrievePrincipalMessage -f $this.PrincipalName, $this.Connection.Name, $_.Exception.Message)
            }
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Permission applied to the specified Entity and Principal from the VMHost if it exists.
    If one of the Entity and Principal parameters is $null, $null is returned.
    #>
    [PSObject] GetVMHostPermission($entity, $vmHostPrincipal) {
        if ($null -eq $entity -or $null -eq $vmHostPrincipal) {
            return $null
        }

        return Get-VIPermission -Server $this.Connection -Entity $entity -Principal $vmHostPrincipal -ErrorAction SilentlyContinue -Verbose:$false
    }

    <#
    .DESCRIPTION

    Retrieves the Role with the specified name from the VMHost if it exists.
    Otherwise it throws an exception.
    #>
    [PSObject] GetVMHostRole() {
        try {
            $vmHostRole = Get-VIRole -Server $this.Connection -Name $this.RoleName -ErrorAction Stop -Verbose:$false
            return $vmHostRole
        }
        catch {
            throw ($this.CouldNotRetrieveRoleMessage -f $this.RoleName, $this.Connection.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Ensures the correct behaviour if the Entity is not found based on the passed Ensure value.
    If Ensure is 'Present' and the Entity is not found, the method should throw an exception.
    #>
    [void] EnsureCorrectBehaviourIfTheEntityIsNotFound($entity, $exceptionMessage) {
        if ($null -eq $entity) {
            if ($this.Ensure -eq [Ensure]::Present) {
                throw $exceptionMessage
            }
        }
    }

    <#
    .DESCRIPTION

    Checks if the specified Permission should be modified. The Permission should be modified if the desired Role is different
    from the current one or if the Propagate behaviour should be different.
    #>
    [bool] ShouldModifyVMHostPermission($vmHostPermission) {
        $shouldModifyVMHostPermission = @()

        $shouldModifyVMHostPermission += ($this.RoleName -ne $vmHostPermission.Role)
        $shouldModifyVMHostPermission += ($null -ne $this.Propagate -and $this.Propagate -ne $vmHostPermission.Propagate)

        return ($shouldModifyVMHostPermission -Contains $true)
    }

    <#
    .DESCRIPTION

    Creates a new Permission and applies it to the specified Entity, Principal and Role.
    #>
    [void] NewVMHostPermission($entity, $vmHostPrincipal) {
        $vmHostRole = $this.GetVMHostRole()
        $newVIPermissionParams = @{
            Server = $this.Connection
            Entity = $entity
            Principal = $vmHostPrincipal
            Role = $vmHostRole
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        if ($null -ne $this.Propagate) {
            $newVIPermissionParams.Propagate = $this.Propagate
        }

        try {
            Write-VerboseLog -Message $this.CreatePermissionMessage -Arguments @($entity.Name, $vmHostPrincipal.Name, $vmHostRole.Name, $this.Connection.Name)
            New-VIPermission @newVIPermissionParams
        }
        catch {
            throw ($this.CouldNotCreatePermissionMessage -f $entity.Name, $vmHostPrincipal.Name, $vmHostRole.Name, $this.Connection.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Modifies the properties of the specified Permission. Changes the Role if the desired one is not the same as the current one.
    It also changes the propagate behaviour of the Permission if the 'Propagate' property is specified.
    #>
    [void] ModifyVMHostPermission($vmHostPermission) {
        $setVIPermissionParams = @{
            Server = $this.Connection
            Permission = $vmHostPermission
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        if ($vmHostPermission.Role -ne $this.RoleName) {
            $vmHostRole = $this.GetVMHostRole()
            $setVIPermissionParams.Role = $vmHostRole
        }

        if ($null -ne $this.Propagate) {
            $setVIPermissionParams.Propagate = $this.Propagate
        }

        try {
            Write-VerboseLog -Message $this.ModifyPermissionMessage -Arguments @($vmHostPermission.Entity.Name, $vmHostPermission.Principal, $this.Connection.Name)
            Set-VIPermission @setVIPermissionParams
        }
        catch {
            throw ($this.CouldNotModifyPermissionMessage -f $vmHostPermission.Entity.Name, $vmHostPermission.Principal, $this.Connection.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Removes the specified Permission.
    #>
    [void] RemoveVMHostPermission($vmHostPermission) {
        try {
            Write-VerboseLog -Message $this.RemovePermissionMessage -Arguments @($vmHostPermission.Entity.Name, $vmHostPermission.Principal, $vmHostPermission.Role, $this.Connection.Name)
            $vmHostPermission | Remove-VIPermission -Confirm:$false -ErrorAction Stop -Verbose:$false
        }
        catch {
            throw ($this.CouldNotRemovePermissionMessage -f $vmHostPermission.Entity.Name, $vmHostPermission.Principal, $vmHostPermission.Role, $this.Connection.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $vmHostPermission) {
        $result.Server = $this.Connection.Name
        $result.EntityLocation = $this.EntityLocation
        $result.EntityType = $this.EntityType

        if ($null -ne $vmHostPermission) {
            $result.EntityName = $vmHostPermission.Entity.Name
            $result.PrincipalName = $vmHostPermission.Principal
            $result.RoleName = $vmHostPermission.Role
            $result.Ensure = [Ensure]::Present
            $result.Propagate = $vmHostPermission.Propagate
        }
        else {
            $result.EntityName = $this.EntityName
            $result.PrincipalName = $this.PrincipalName
            $result.RoleName = $this.RoleName
            $result.Ensure = [Ensure]::Absent
            $result.Propagate = $this.Propagate
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
class VMHostRole : BaseDSC {
    <#
    .DESCRIPTION

    Specifies the name of the Role on the VMHost.
    #>
    [DscProperty(Key)]
    [string] $Name

    <#
    .DESCRIPTION

    Specifies whether the Role on the VMHost should be present or absent.
    #>
    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    <#
    .DESCRIPTION

    Specifies the ids of the Privileges for the Role on the VMHost. The Privilege ids should be in the following format: '<Privilege Group id>.<Privilege Item id>'.
    Exampe Privilege id: 'VirtualMachine.Inventory.Create' where 'VirtualMachine.Inventory' is the Privilege Group id and 'Create' is the id of the Privilege item.
    #>
    [DscProperty()]
    [string[]] $PrivilegeIds

    hidden [string] $CreateRoleMessage = "Creating Role {0} on VMHost {1}."
    hidden [string] $CreateRoleWithPrivilegesMessage = "Creating Role {0} with Privileges {1} on VMHost {2}."
    hidden [string] $ModifyPrivilegesOfRoleMessage = "Modifying Privileges of Role {0} on VMHost {1}."
    hidden [string] $RemoveRoleMessage = "Removing Role {0} on VMHost {1}."

    hidden [string] $CouldNotFindPrivilegeMessage = "The passed Privilege {0} was not found and it will be ignored."
    hidden [string] $CouldNotRetrieveRolePrivilegesMessage = "Could not retrieve Privilege {0} of Role {1}. For more information: {2}"
    hidden [string] $CouldNotCreateRoleMessage = "Could not create Role {0} on VMHost {1}. For more information: {2}"
    hidden [string] $CouldNotCreateRoleWithPrivilegesMessage = "Could not create Role {0} with Privileges {1} on VMHost {2}. For more information: {3}"
    hidden [string] $CouldNotModifyPrivilegesOfRoleMessage = "Could not modify Privileges of Role {0} on VMHost {1}. For more information: {2}"
    hidden [string] $CouldNotRemoveRoleMessage = "Could not remove Role {0} on VMHost {1}. For more information: {2}"

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()
            $this.EnsureConnectionIsESXi()

            $vmHostRole = $this.GetVMHostRole()

            if ($this.Ensure -eq [Ensure]::Present) {
                $desiredPrivileges = $this.GetPrivileges()

                if ($null -eq $vmHostRole) {
                    if ($desiredPrivileges.Length -gt 0) {
                        $this.NewVMHostRole($desiredPrivileges)
                    }
                    else {
                        $this.NewVMHostRole()
                    }
                }
                else {
                    $currentPrivileges = $this.GetRolePrivileges($vmHostRole, $desiredPrivileges)
                    $this.ModifyPrivilegesOfVMHostRole($vmHostRole, $currentPrivileges, $desiredPrivileges)
                }
            }
            else {
                if ($null -ne $vmHostRole) {
                    $this.RemoveVMHostRole($vmHostRole)
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
            $this.EnsureConnectionIsESXi()

            $vmHostRole = $this.GetVMHostRole()
            $result = $null

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $vmHostRole) {
                    $result = $false
                }
                else {
                    $desiredPrivileges = $this.GetPrivileges()
                    $desiredPrivilegeIds = if ($desiredPrivileges.Length -eq 0) { $null } else { $desiredPrivileges.Id }

                    $result = !$this.ShouldUpdateArraySetting($vmHostRole.PrivilegeList, $desiredPrivilegeIds)
                }
            }
            else {
                $result = ($null -eq $vmHostRole)
            }

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [VMHostRole] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [VMHostRole]::new()

            $this.ConnectVIServer()
            $this.EnsureConnectionIsESXi()

            $vmHostRole = $this.GetVMHostRole()
            $this.PopulateResult($result, $vmHostRole)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Role with the specified name on the VMHost if it exists, otherwise returns $null.
    #>
    [PSObject] GetVMHostRole() {
        return Get-VIRole -Server $this.Connection -Name $this.Name -ErrorAction SilentlyContinue -Verbose:$false
    }

    <#
    .DESCRIPTION

    Retrieves the Privileges with the specified ids on the VMHost if they exist.
    For every Privilege that does not exist, a warning message is shown to the user without throwing an exception.
    #>
    [array] GetPrivileges() {
        $privileges = @()

        foreach ($privilegeId in $this.PrivilegeIds) {
            $privilege = Get-VIPrivilege -Server $this.Connection -Id $privilegeId -ErrorAction SilentlyContinue -Verbose:$false
            if ($null -eq $privilege) {
                Write-WarningLog -Message $this.CouldNotFindPrivilegeMessage -Arguments @($privilegeId)
            }
            else {
                $privileges += $privilege
            }
        }

        return $privileges
    }

    <#
    .DESCRIPTION

    Retrieves the Privileges of the Role on the VMHost.
    #>
    [array] GetRolePrivileges($vmHostRole, $desiredPrivileges) {
        $rolePrivileges = @()

        foreach ($privilegeId in $vmHostRole.PrivilegeList) {
            <#
            Here we can check if the desired Privilege list already contains the Role Privilege and this way
            we can skip the server call because the Privilege object is already available in the array of Privileges.
            #>
            if ($desiredPrivileges.Length -gt 0 -and $desiredPrivileges.Id.Contains($privilegeId)) {
                $rolePrivileges += ($desiredPrivileges | Where-Object -FilterScript { $_.Id -eq $privilegeId })
            }
            else {
                try {
                    $rolePrivilige = Get-VIPrivilege -Server $this.Connection -Id $privilegeId -ErrorAction Stop -Verbose:$false
                    $rolePrivileges += $rolePrivilige
                }
                catch {
                    throw ($this.CouldNotRetrieveRolePrivilegesMessage -f $privilegeId, $vmHostRole.Name, $_.Exception.Message)
                }
            }
        }

        return $rolePrivileges
    }

    <#
    .DESCRIPTION

    Creates a new Role with the specified name on the VMHost.
    #>
    [void] NewVMHostRole() {
        try {
            Write-VerboseLog -Message $this.CreateRoleMessage -Arguments @($this.Name, $this.Connection.Name)
            New-VIRole -Server $this.Connection -Name $this.Name -Confirm:$false -ErrorAction Stop -Verbose:$false
        }
        catch {
            throw ($this.CouldNotCreateRoleMessage -f $this.Name, $this.Connection.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Creates a new Role with the specified name on the VMHost and applies the provided Privileges.
    #>
    [void] NewVMHostRole($desiredPrivileges) {
        $desiredPrivilegeIds = [string]::Join(', ', $desiredPrivileges.Id)

        try {
            Write-VerboseLog -Message $this.CreateRoleWithPrivilegesMessage -Arguments @($this.Name, $desiredPrivilegeIds, $this.Connection.Name)
            New-VIRole -Server $this.Connection -Name $this.Name -Privilege $desiredPrivileges -Confirm:$false -ErrorAction Stop -Verbose:$false
        }
        catch {
            throw ($this.CouldNotCreateRoleWithPrivilegesMessage -f $this.Name, $desiredPrivilegeIds, $this.Connection.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Modifies the Privileges of the Role on the VMHost. The 'Set-VIRole' cmdlet has two parameters for Privileges - 'AddPrivilege' and 'RemovePrivilege'.
    So based on the provided desired Privileges we need to add those of them that are not yet Privileges of the Role and also remove existing ones
    from the Privilege list of the Role because they are not specified as desired.
    #>
    [void] ModifyPrivilegesOfVMHostRole($vmHostRole, $currentPrivileges, $desiredPrivileges) {
        $setVIRoleParams = @{
            Server = $this.Connection
            Role = $vmHostRole
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }
        $privilegesToAdd = @()
        $privilegesToRemove = @()

        <#
        If the Role does not have Privileges, it means that all desired Privileges need to be marked as Privileges to add.
        Otherwise Privileges to add are those that are not present in the Privilege list of the Role and Privileges
        to remove are those that are not present in the desired Privilege list.
        #>
        if ($currentPrivileges.Length -eq 0) {
            $privilegesToAdd = $desiredPrivileges
        }
        else {
            $privilegesToAdd = $desiredPrivileges | Where-Object -FilterScript { $currentPrivileges -NotContains $_ }
            $privilegesToRemove = $currentPrivileges | Where-Object -FilterScript { $desiredPrivileges -NotContains $_ }
        }

        <#
        If the Privileges to add array is empty, it means that only removal of Privileges is needed. Otherwise, we first add
        all the specified Privileges that are not present in the list of Privileges of the Role and after that check if there are
        Privileges to remove from that list. The 'AddPrivilege' entry needs to be removed from the params hashtable because 'AddPrivilege'
        and 'RemovePrivilege' parameters of 'Set-VIRole' cmdlet are in different parameter sets, so two cmdlet invocations need to be made.
        #>
        try {
            Write-VerboseLog -Message $this.ModifyPrivilegesOfRoleMessage -Arguments @($vmHostRole.Name, $this.Connection.Name)

            if ($privilegesToAdd.Length -eq 0) {
                $setVIRoleParams.RemovePrivilege = $privilegesToRemove
                Set-VIRole @setVIRoleParams
            }
            else {
                $setVIRoleParams.AddPrivilege = $privilegesToAdd
                Set-VIRole @setVIRoleParams

                if ($privilegesToRemove.Length -gt 0) {
                    $setVIRoleParams.Remove('AddPrivilege')
                    $setVIRoleParams.RemovePrivilege = $privilegesToRemove

                    Set-VIRole @setVIRoleParams
                }
            }
        }
        catch {
            throw ($this.CouldNotModifyPrivilegesOfRoleMessage -f $vmHostRole.Name, $this.Connection.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Removes the Role on the VMHost. All Permissions associated with the Role will be removed as well.
    #>
    [void] RemoveVMHostRole($vmHostRole) {
        try {
            Write-VerboseLog -Message $this.RemoveRoleMessage -Arguments @($vmHostRole.Name, $this.Connection.Name)
            $vmHostRole | Remove-VIRole -Server $this.Connection -Force -Confirm:$false -ErrorAction Stop -Verbose:$false
        }
        catch {
            throw ($this.CouldNotRemoveRoleMessage -f $vmHostRole.Name, $this.Connection.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $vmHostRole) {
        $result.Server = $this.Connection.Name

        if ($null -ne $vmHostRole) {
            $result.Name = $vmHostRole.Name
            $result.Ensure = [Ensure]::Present
            $result.PrivilegeIds = $vmHostRole.PrivilegeList
        }
        else {
            $result.Name = $this.Name
            $result.Ensure = [Ensure]::Absent
            $result.PrivilegeIds = $this.PrivilegeIds
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

        $shouldUpdateVMHostSyslog += (![string]::IsNullOrEmpty($this.LogHost) -and $this.LogHost -ne $current.RemoteHost)
        $shouldUpdateVMHostSyslog += ($null -ne $this.CheckSslCerts -and $this.CheckSslCerts -ne $current.EnforceSSLCertificates)
        $shouldUpdateVMHostSyslog += ($null -ne $this.DefaultTimeout -and $this.DefaultTimeout -ne $current.DefaultNetworkRetryTimeout)
        $shouldUpdateVMHostSyslog += ($null -ne $this.QueueDropMark -and $this.QueueDropMark -ne $current.MessageQueueDropMark)
        $shouldUpdateVMHostSyslog += (![string]::IsNullOrEmpty($this.Logdir) -and $this.Logdir -ne $current.LocalLogOutput)
        $shouldUpdateVMHostSyslog += ($null -ne $this.LogdirUnique -and $this.LogdirUnique -ne [System.Convert]::ToBoolean($current.LogToUniqueSubdirectory))
        $shouldUpdateVMHostSyslog += ($null -ne $this.DefaultRotate -and $this.DefaultRotate -ne $current.LocalLoggingDefaultRotations)
        $shouldUpdateVMHostSyslog += ($null -ne $this.DefaultSize -and $this.DefaultSize -ne $current.LocalLoggingDefaultRotationSize)
        $shouldUpdateVMHostSyslog += ($null -ne $this.DropLogRotate -and $this.DropLogRotate -ne $current.DroppedLogFileRotations)
        $shouldUpdateVMHostSyslog += ($null -ne $this.DropLogSize -and $this.DropLogSize -ne $current.DroppedLogFileRotationSize)

        return ($shouldUpdateVMHostSyslog -contains $true)
    }

    <#
    .DESCRIPTION

    Updates the configuration of the VMHostSyslog.
    #>
    [void] UpdateVMHostSyslog($VMHost) {
        Write-VerboseLog -Message "{0} Entering {1}" -Arguments @((Get-Date), (Get-PSCallStack)[0].FunctionName)

        $esxcli = Get-Esxcli -Server $this.Connection -VMHost $vmHost -V2

        $vmHostSyslogConfig = @{
            queuedropmark = $this.QueueDropMark
            defaultrotate = $this.DefaultRotate
            droplogrotate = $this.DropLogRotate
        }

        if ($null -ne $this.CheckSslCerts) { $vmHostSyslogConfig.checksslcerts = $this.CheckSslCerts }
        if ($null -ne $this.DefaultTimeout) { $vmHostSyslogConfig.defaulttimeout = $this.DefaultTimeout }
        if (![string]::IsNullOrEmpty($this.Logdir)) { $vmHostSyslogConfig.logdir = $this.Logdir }
        if ($null -ne $this.LogdirUnique) { $vmHostSyslogConfig.logdirunique = $this.LogdirUnique }
        if ($null -ne $this.DefaultSize) { $vmHostSyslogConfig.defaultsize = $this.DefaultSize }
        if ($null -ne $this.DropLogSize) { $vmHostSyslogConfig.droplogsize = $this.DropLogSize }
        if (![string]::IsNullOrEmpty($this.LogHost)) { $vmHostSyslogConfig.loghost = $this.Loghost }

        Set-VMHostSyslogConfig -EsxCli $esxcli -VMHostSyslogConfig $vmHostSyslogConfig
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
        $syslog.CheckSslCerts = [System.Convert]::ToBoolean($currentVMHostSyslog.EnforceSSLCertificates)
        $syslog.DefaultTimeout = [long] $currentVMHostSyslog.DefaultNetworkRetryTimeout
        $syslog.QueueDropMark = [long] $currentVMHostSyslog.MessageQueueDropMark
        $syslog.Logdir = $currentVMHostSyslog.LocalLogOutput
        $syslog.LogdirUnique = [System.Convert]::ToBoolean($currentVMHostSyslog.LogToUniqueSubdirectory)
        $syslog.DefaultRotate = [long] $currentVMHostSyslog.LocalLoggingDefaultRotations
        $syslog.DefaultSize = [long] $currentVMHostSyslog.LocalLoggingDefaultRotationSize
        $syslog.DropLogRotate = [long] $currentVMHostSyslog.DroppedLogFileRotations
        $syslog.DropLogSize = [long] $currentVMHostSyslog.DroppedLogFileRotationSize
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

            $vmHostTpsSettingsDscResourcePropertyNames = $this.GetType().GetProperties().Name
            foreach ($tpsSetting in $tpsSettings) {
                $tpsSettingName = $tpsSetting.Name.TrimStart($this.MemValue)
                if ($vmHostTpsSettingsDscResourcePropertyNames -Contains $tpsSettingName) {
                    $result.$tpsSettingName = $tpsSetting.Value
                }
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
class NfsDatastore : DatastoreBaseDSC {
    <#
    .DESCRIPTION

    Specifies the Nfs Host for the Datastore.
    #>
    [DscProperty(Mandatory)]
    [string[]] $NfsHost

    <#
    .DESCRIPTION

    Specifies the access mode for the Nfs Datastore. Valid access modes are 'ReadWrite' and 'ReadOnly'.
    The default access mode is 'ReadWrite'.
    #>
    [DscProperty()]
    [AccessMode] $AccessMode = [AccessMode]::ReadWrite

    <#
    .DESCRIPTION

    Specifies the authentication method for the Nfs Datastore. Valid authentication methods are 'AUTH_SYS' and 'Kerberos'.
    The default authentication method is 'AUTH_SYS'.
    #>
    [DscProperty()]
    [AuthenticationMethod] $AuthenticationMethod = [AuthenticationMethod]::AUTH_SYS

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $datastore = $this.GetDatastore()

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $datastore) {
                    $datastore = $this.NewNfsDatastore()
                }

                if ($this.ShouldModifyDatastore($datastore)) {
                    $this.ModifyDatastore($datastore)
                }
            }
            else {
                if ($null -ne $datastore) {
                    $this.RemoveDatastore($datastore)
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
            $this.RetrieveVMHost()

            $datastore = $this.GetDatastore()
            $result = $null

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $datastore) {
                    $result = $false
                }
                else {
                    $result = !$this.ShouldModifyDatastore($datastore)
                }
            }
            else {
                $result = ($null -eq $datastore)
            }

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [NfsDatastore] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [NfsDatastore]::new()

            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $datastore = $this.GetDatastore()
            $this.PopulateResultForNfsDatastore($result, $datastore)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Creates a new Nfs Datastore with the specified name on the VMHost.
    #>
    [PSObject] NewNfsDatastore() {
        $newDatastoreParams = @{
            Nfs = $true
            NfsHost = $this.NfsHost
        }

        if ($this.AccessMode -eq [AccessMode]::ReadOnly) { $newDatastoreParams.ReadOnly = $true }
        if ($this.AuthenticationMethod -eq [AuthenticationMethod]::Kerberos) { $newDatastoreParams.Kerberos = $true }

        return $this.NewDatastore($newDatastoreParams)
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResultForNfsDatastore($result, $datastore) {
        if ($null -ne $datastore) {
            $result.NfsHost = $datastore.RemoteHost
            $result.Path = $datastore.RemotePath
            $result.AccessMode = [AccessMode] $datastore.ExtensionData.Host.MountInfo.AccessMode
            $result.AuthenticationMethod = $datastore.AuthenticationMethod.ToString()
        }
        else {
            $result.NfsHost = $this.NfsHost
            $result.Path = $this.Path
            $result.AccessMode = $this.AccessMode
            $result.AuthenticationMethod = $this.AuthenticationMethod
        }

        $this.PopulateResult($result, $datastore)
    }
}

[DscResource()]
class VmfsDatastore : DatastoreBaseDSC {
    <#
    .DESCRIPTION

    Specifies the maximum file size of Vmfs in megabytes (MB). If no value is specified, the maximum file size for the current system platform is used.
    #>
    [DscProperty()]
    [nullable[int]] $BlockSizeMB

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $datastore = $this.GetDatastore()

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $datastore) {
                    $datastore = $this.NewVmfsDatastore()
                }

                if ($this.ShouldModifyDatastore($datastore)) {
                    $this.ModifyDatastore($datastore)
                }
            }
            else {
                if ($null -ne $datastore) {
                    $this.RemoveDatastore($datastore)
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
            $this.RetrieveVMHost()

            $datastore = $this.GetDatastore()
            $result = $null

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $datastore) {
                    $result = $false
                }
                else {
                    $result = !$this.ShouldModifyDatastore($datastore)
                }
            }
            else {
                $result = ($null -eq $datastore)
            }

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [VmfsDatastore] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [VmfsDatastore]::new()

            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $datastore = $this.GetDatastore()
            $this.PopulateResultForVmfsDatastore($result, $datastore)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Creates a new Vmfs Datastore with the specified name on the VMHost.
    #>
    [PSObject] NewVmfsDatastore() {
        $newDatastoreParams = @{
            Vmfs = $true
        }

        if ($null -ne $this.BlockSizeMB) { $newDatastoreParams.BlockSizeMB = $this.BlockSizeMB }

        return $this.NewDatastore($newDatastoreParams)
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResultForVmfsDatastore($result, $datastore) {
        if ($null -ne $datastore) {
            $result.BlockSizeMB = $datastore.ExtensionData.Info.Vmfs.BlockSizeMB
            $result.Path = $datastore.ExtensionData.Info.Vmfs.Extent | Where-Object -FilterScript { $_.DiskName -eq $this.Path } | Select-Object -ExpandProperty DiskName
        }
        else {
            $result.BlockSizeMB = $this.BlockSizeMB
            $result.Path = $this.Path
        }

        $this.PopulateResult($result, $datastore)
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
    [string[]] $ActiveNic

    <#
    .DESCRIPTION

    Specifies the adapters you want to use if one of the active adapter's connectivity is unavailable.
    #>
    [DscProperty()]
    [string[]] $StandbyNic

    <#
    .DESCRIPTION

    Specifies the adapters you do not want to use.
    #>
    [DscProperty()]
    [string[]] $UnusedNic

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

    Indicates that the values of the ActiveNic, StandbyNic, and UnusedNic parameters are inherited from the virtual switch.
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

        $shouldUpdateVirtualPortGroupTeamingPolicy += $this.ShouldUpdateNicArray($virtualPortGroupTeamingPolicy.ActiveNic, $this.ActiveNic)
        $shouldUpdateVirtualPortGroupTeamingPolicy += $this.ShouldUpdateNicArray($virtualPortGroupTeamingPolicy.StandbyNic, $this.StandbyNic)
        $shouldUpdateVirtualPortGroupTeamingPolicy += $this.ShouldUpdateNicArray($virtualPortGroupTeamingPolicy.UnusedNic, $this.UnusedNic)

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

        $this.PopulateArrayPolicySetting($teamingPolicyParams, $this.MakeNicActiveSettingName, $this.ActiveNic, $this.InheritFailoverOrderSettingName, $this.InheritFailoverOrder)
        $this.PopulateArrayPolicySetting($teamingPolicyParams, $this.MakeNicStandbySettingName, $this.StandbyNic, $this.InheritFailoverOrderSettingName, $this.InheritFailoverOrder)
        $this.PopulateArrayPolicySetting($teamingPolicyParams, $this.MakeNicUnusedSettingName, $this.UnusedNic, $this.InheritFailoverOrderSettingName, $this.InheritFailoverOrder)

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
        $result.ActiveNic = $virtualPortGroupTeamingPolicy.ActiveNic
        $result.StandbyNic = $virtualPortGroupTeamingPolicy.StandbyNic
        $result.UnusedNic = $virtualPortGroupTeamingPolicy.UnusedNic
        $result.InheritFailback = $virtualPortGroupTeamingPolicy.IsFailbackInherited
        $result.InheritNotifySwitches = $virtualPortGroupTeamingPolicy.IsNotifySwitchesInherited
        $result.InheritLoadBalancingPolicy = $virtualPortGroupTeamingPolicy.IsLoadBalancingInherited
        $result.InheritNetworkFailoverDetectionPolicy = $virtualPortGroupTeamingPolicy.IsNetworkFailoverDetectionInherited
        $result.InheritFailoverOrder = $virtualPortGroupTeamingPolicy.IsFailoverOrderInherited
    }
}

[DscResource()]
class VMHostAcceptanceLevel : EsxCliBaseDSC {
    VMHostAcceptanceLevel() {
        $this.EsxCliCommand = 'software.acceptance'
    }

    <#
    .DESCRIPTION

    Specifies the acceptance level of the VMHost. Valid values are VMwareCertified, VMwareAccepted, PartnerSupported and CommunitySupported.
    #>
    [DscProperty(Mandatory)]
    [AcceptanceLevel] $Level

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            # The 'Level' value needs to be converted to a string type before being passed to the base class method.
            $modifyVMHostAcceptanceLevelMethodArguments = @{
                level = $this.Level.ToString()
            }

            $this.ExecuteEsxCliModifyMethod($this.EsxCliSetMethodName, $modifyVMHostAcceptanceLevelMethodArguments)
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

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)
            $esxCliGetMethodResult = $this.ExecuteEsxCliRetrievalMethod($this.EsxCliGetMethodName)

            $result = ($this.Level.ToString() -eq $esxCliGetMethodResult)

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [VMHostAcceptanceLevel] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [VMHostAcceptanceLevel]::new()

            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            $this.PopulateResult($result, $vmHost)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $vmHost) {
        $result.Server = $this.Connection.Name
        $result.Name = $vmHost.Name

        $esxCliGetMethodResult = $this.ExecuteEsxCliRetrievalMethod($this.EsxCliGetMethodName)

        $result.Level = $esxCliGetMethodResult
    }
}

[DscResource()]
class VMHostDCUIKeyboard : EsxCliBaseDSC {
    VMHostDCUIKeyboard() {
        $this.EsxCliCommand = 'system.settings.keyboard.layout'
    }

    <#
    .DESCRIPTION

    Specifies the name of the Direct Console User Interface Keyboard Layout.
    #>
    [DscProperty(Mandatory)]
    [string] $Layout

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            $this.ExecuteEsxCliModifyMethod($this.EsxCliSetMethodName)
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

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)
            $esxCliGetMethodResult = $this.ExecuteEsxCliRetrievalMethod($this.EsxCliGetMethodName)

            $result = ($this.Layout -eq $esxCliGetMethodResult)

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [VMHostDCUIKeyboard] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [VMHostDCUIKeyboard]::new()

            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            $this.PopulateResult($result, $vmHost)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $vmHost) {
        $result.Server = $this.Connection.Name
        $result.Name = $vmHost.Name

        $esxCliGetMethodResult = $this.ExecuteEsxCliRetrievalMethod($this.EsxCliGetMethodName)
        $result.Layout = $esxCliGetMethodResult
    }
}

[DscResource()]
class VMHostNetworkCoreDump : EsxCliBaseDSC {
    VMHostNetworkCoreDump() {
        $this.EsxCliCommand = 'system.coredump.network'
    }

    <#
    .DESCRIPTION

    Specifies whether to enable network coredump.
    #>
    [DscProperty()]
    [nullable[bool]] $Enable

    <#
    .DESCRIPTION

    Specifies the active interface to be used for the network coredump.
    #>
    [DscProperty()]
    [string] $InterfaceName

    <#
    .DESCRIPTION

    Specifies the IP address of the coredump server (IPv4 or IPv6).
    #>
    [DscProperty()]
    [string] $ServerIp

    <#
    .DESCRIPTION

    Specifies the port on which the coredump server is listening.
    #>
    [DscProperty()]
    [nullable[long]] $ServerPort

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            <#
            The 'Enable' argument of the 'set' method of the command should be passed separately from the other method arguments.
            So if any of the other method arguments is passed, the method of the command should be invoked twice - the first time
            without 'Enable' and the second time only with 'Enable' argument.
            #>
            if ($null -ne $this.Enable) {
                if (![string]::IsNullOrEmpty($this.InterfaceName) -or ![string]::IsNullOrEmpty($this.ServerIp) -or $null -ne $this.ServerPort) {
                    <#
                    The desired 'Enable' value must be set to $null, so that the base class can ignore it when constructing the arguments of the method of the command.
                    The value is stored in a separate variable, so that it can be used when the second invocation of the command method occurs.
                    #>
                    $enableArgumentDesiredValue = $this.Enable
                    $this.Enable = $null

                    $this.ExecuteEsxCliModifyMethod($this.EsxCliSetMethodName)

                    # The property value is restored to its initial value.
                    $this.Enable = $enableArgumentDesiredValue

                    # All property values except the desired 'Enable' value should be set to $null, because the command method was invoked with them already and their values are not needed.
                    $this.InterfaceName = $null
                    $this.ServerIp = $null
                    $this.ServerPort = $null

                    $this.ExecuteEsxCliModifyMethod($this.EsxCliSetMethodName)
                }
                else {
                    $this.ExecuteEsxCliModifyMethod($this.EsxCliSetMethodName)
                }
            }
            else {
                $this.ExecuteEsxCliModifyMethod($this.EsxCliSetMethodName)
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

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)
            $esxCliGetMethodResult = $this.ExecuteEsxCliRetrievalMethod($this.EsxCliGetMethodName)

            $result = !$this.ShouldModifyVMHostNetworkCoreDumpConfiguration($esxCliGetMethodResult)

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [VMHostNetworkCoreDump] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [VMHostNetworkCoreDump]::new()

            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            $this.PopulateResult($result, $vmHost)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Checks if the VMHost network coredump configuration should be modified.
    #>
    [bool] ShouldModifyVMHostNetworkCoreDumpConfiguration($esxCliGetMethodResult) {
        $shouldModifyVMHostNetworkCoreDumpConfiguration = @()

        $shouldModifyVMHostNetworkCoreDumpConfiguration += ($null -ne $this.Enable -and $this.Enable -ne [System.Convert]::ToBoolean($esxCliGetMethodResult.Enabled))
        $shouldModifyVMHostNetworkCoreDumpConfiguration += (![string]::IsNullOrEmpty($this.InterfaceName) -and $this.InterfaceName -ne $esxCliGetMethodResult.HostVNic)
        $shouldModifyVMHostNetworkCoreDumpConfiguration += (![string]::IsNullOrEmpty($this.ServerIp) -and $this.ServerIp -ne $esxCliGetMethodResult.NetworkServerIP)
        $shouldModifyVMHostNetworkCoreDumpConfiguration += ($null -ne $this.ServerPort -and $this.ServerPort -ne [long] $esxCliGetMethodResult.NetworkServerPort)

        return ($shouldModifyVMHostNetworkCoreDumpConfiguration -Contains $true)
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $vmHost) {
        $result.Server = $this.Connection.Name
        $result.Name = $vmHost.Name

        $esxCliGetMethodResult = $this.ExecuteEsxCliRetrievalMethod($this.EsxCliGetMethodName)

        $result.Enable = [System.Convert]::ToBoolean($esxCliGetMethodResult.Enabled)
        $result.InterfaceName = $esxCliGetMethodResult.HostVNic
        $result.ServerIp = $esxCliGetMethodResult.NetworkServerIP
        $result.ServerPort = [long] $esxCliGetMethodResult.NetworkServerPort
    }
}

[DscResource()]
class VMHostSharedSwapSpace : EsxCliBaseDSC {
    VMHostSharedSwapSpace() {
        $this.EsxCliCommand = 'sched.swap.system'
    }

    <#
    .DESCRIPTION

    Specifies if the Datastore option should be enabled or not.
    #>
    [DscProperty()]
    [nullable[bool]] $DatastoreEnabled

    <#
    .DESCRIPTION

    Specifies the name of the Datastore used by the Datastore option.
    #>
    [DscProperty()]
    [string] $DatastoreName

    <#
    .DESCRIPTION

    Specifies the order of the Datastore option in the preference of the options of the system-wide shared swap space.
    #>
    [DscProperty()]
    [nullable[long]] $DatastoreOrder

    <#
    .DESCRIPTION

    Specifies if the host cache option should be enabled or not.
    #>
    [DscProperty()]
    [nullable[bool]] $HostCacheEnabled

    <#
    .DESCRIPTION

    Specifies the order of the host cache option in the preference of the options of the system-wide shared swap space.
    #>
    [DscProperty()]
    [nullable[long]] $HostCacheOrder

    <#
    .DESCRIPTION

    Specifies if the host local swap option should be enabled or not.
    #>
    [DscProperty()]
    [nullable[bool]] $HostLocalSwapEnabled

    <#
    .DESCRIPTION

    Specifies the order of the host local swap option in the preference of the options of the system-wide shared swap space.
    #>
    [DscProperty()]
    [nullable[long]] $HostLocalSwapOrder

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            $modifyVMHostSharedSwapSpaceMethodArguments = @{}
            if ($null -ne $this.DatastoreName) { $modifyVMHostSharedSwapSpaceMethodArguments.datastorename = $this.DatastoreName }

            $this.ExecuteEsxCliModifyMethod($this.EsxCliSetMethodName, $modifyVMHostSharedSwapSpaceMethodArguments)
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

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)
            $esxCliGetMethodResult = $this.ExecuteEsxCliRetrievalMethod($this.EsxCliGetMethodName)

            $result = !$this.ShouldModifySystemWideSharedSwapSpaceConfiguration($esxCliGetMethodResult)

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [VMHostSharedSwapSpace] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [VMHostSharedSwapSpace]::new()

            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            $this.PopulateResult($result, $vmHost)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Checks if the system-wide shared swap space configuration should be modified.
    #>
    [bool] ShouldModifySystemWideSharedSwapSpaceConfiguration($esxCliGetMethodResult) {
        $shouldModifySystemWideSharedSwapSpaceConfiguration = @()

        $shouldModifySystemWideSharedSwapSpaceConfiguration += ($null -ne $this.DatastoreEnabled -and $this.DatastoreEnabled -ne [System.Convert]::ToBoolean($esxCliGetMethodResult.DatastoreEnabled))
        $shouldModifySystemWideSharedSwapSpaceConfiguration += ($null -ne $this.DatastoreName -and $this.DatastoreName -ne $esxCliGetMethodResult.DatastoreName)
        $shouldModifySystemWideSharedSwapSpaceConfiguration += ($null -ne $this.DatastoreOrder -and $this.DatastoreOrder -ne [long] $esxCliGetMethodResult.DatastoreOrder)
        $shouldModifySystemWideSharedSwapSpaceConfiguration += ($null -ne $this.HostCacheEnabled -and $this.HostCacheEnabled -ne [System.Convert]::ToBoolean($esxCliGetMethodResult.HostcacheEnabled))
        $shouldModifySystemWideSharedSwapSpaceConfiguration += ($null -ne $this.HostCacheOrder -and $this.HostCacheOrder -ne [long] $esxCliGetMethodResult.HostcacheOrder)
        $shouldModifySystemWideSharedSwapSpaceConfiguration += ($null -ne $this.HostLocalSwapEnabled -and $this.HostLocalSwapEnabled -ne [System.Convert]::ToBoolean($esxCliGetMethodResult.HostlocalswapEnabled))
        $shouldModifySystemWideSharedSwapSpaceConfiguration += ($null -ne $this.HostLocalSwapOrder -and $this.HostLocalSwapOrder -ne [long] $esxCliGetMethodResult.HostlocalswapOrder)

        return ($shouldModifySystemWideSharedSwapSpaceConfiguration -Contains $true)
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $vmHost) {
        $result.Server = $this.Connection.Name
        $result.Name = $vmHost.Name

        $esxCliGetMethodResult = $this.ExecuteEsxCliRetrievalMethod($this.EsxCliGetMethodName)

        $result.DatastoreEnabled = [System.Convert]::ToBoolean($esxCliGetMethodResult.DatastoreEnabled)
        $result.DatastoreName = $esxCliGetMethodResult.DatastoreName
        $result.DatastoreOrder = [long] $esxCliGetMethodResult.DatastoreOrder
        $result.HostCacheEnabled = [System.Convert]::ToBoolean($esxCliGetMethodResult.HostcacheEnabled)
        $result.HostCacheOrder = [long] $esxCliGetMethodResult.HostcacheOrder
        $result.HostLocalSwapEnabled = [System.Convert]::ToBoolean($esxCliGetMethodResult.HostlocalswapEnabled)
        $result.HostLocalSwapOrder = [long] $esxCliGetMethodResult.HostlocalswapOrder
    }
}

[DscResource()]
class VMHostSNMPAgent : EsxCliBaseDSC {
    VMHostSNMPAgent() {
        $this.EsxCliCommand = 'system.snmp'
    }

    <#
    .DESCRIPTION

    Specifies the default authentication protocol. Valid values are none, MD5, SHA1.
    #>
    [DscProperty()]
    [string] $Authentication

    <#
    .DESCRIPTION

    Specifies up to ten communities each no more than 64 characters. Format is: 'community1[,community2,...]'. This overwrites previous settings.
    #>
    [DscProperty()]
    [string] $Communities

    <#
    .DESCRIPTION

    Specifies whether to start or stop the SNMP service.
    #>
    [DscProperty()]
    [nullable[bool]] $Enable

    <#
    .DESCRIPTION

    Specifies the SNMPv3 engine id. Must be between 10 and 32 hexadecimal characters. 0x or 0X are stripped if found as well as colons (:).
    #>
    [DscProperty()]
    [string] $EngineId

    <#
    .DESCRIPTION

    Specifies where to source hardware events - IPMI sensors or CIM Indications. Valid values are indications and sensors.
    #>
    [DscProperty()]
    [string] $Hwsrc

    <#
    .DESCRIPTION

    Specifies whether to support large storage for 'hrStorageAllocationUnits' * 'hrStorageSize'. Controls how the agent reports 'hrStorageAllocationUnits', 'hrStorageSize' and 'hrStorageUsed' in 'hrStorageTable'.
    Setting this directive to $true to support large storage with small allocation units, the agent re-calculates these values so they all fit into 'int' and 'hrStorageAllocationUnits' * 'hrStorageSize' gives real size
    of the storage. Setting this directive to $false turns off this calculation and the agent reports real 'hrStorageAllocationUnits', but it might report wrong 'hrStorageSize' for large storage because the value won't fit
    into 'int'.
    #>
    [DscProperty()]
    [nullable[bool]] $LargeStorage

    <#
    .DESCRIPTION

    Specifies the SNMP agent syslog logging level. Valid values are debug, info, warning and error.
    #>
    [DscProperty()]
    [string] $LogLevel

    <#
    .DESCRIPTION

    Specifies a comma separated list of trap oids for traps not to be sent by the SNMP agent. Use the property 'reset' to clear this setting.
    #>
    [DscProperty()]
    [string] $NoTraps

    <#
    .DESCRIPTION

    Specifies the UDP port to poll SNMP agent on. The default is 'udp/161'. May not use ports 32768 to 40959.
    #>
    [DscProperty()]
    [nullable[long]] $Port

    <#
    .DESCRIPTION

    Specifies the default privacy protocol. Valid values are none and AES128.
    #>
    [DscProperty()]
    [string] $Privacy

    <#
    .DESCRIPTION

    Specifies up to five inform user ids. Format is: 'user/auth-proto/-|auth-hash/priv-proto/-|priv-hash/engine-id[,...]', where user is 32 chars max. 'auth-proto' is 'none', 'MD5' or 'SHA1',
    'priv-proto' is 'none' or 'AES'. '-' indicates no hash. 'engine-id' is hex string '0x0-9a-f' up to 32 chars max.
    #>
    [DscProperty()]
    [string] $RemoteUsers

    <#
    .DESCRIPTION

    Specifies whether to return SNMP agent configuration to factory defaults.
    #>
    [DscProperty()]
    [nullable[bool]] $Reset

    <#
    .DESCRIPTION

    Specifies the System contact as presented in 'sysContact.0'. Up to 255 characters.
    #>
    [DscProperty()]
    [string] $SysContact

    <#
    .DESCRIPTION

    Specifies the System location as presented in 'sysLocation.0'. Up to 255 characters.
    #>
    [DscProperty()]
    [string] $SysLocation

    <#
    .DESCRIPTION

    Specifies up to three targets to send SNMPv1 traps to. Format is: 'ip-or-hostname[@port]/community[,...]'. The default port is 'udp/162'.
    #>
    [DscProperty()]
    [string] $Targets

    <#
    .DESCRIPTION

    Specifies up to five local users. Format is: 'user/-|auth-hash/-|priv-hash/model[,...]', where user is 32 chars max. '-' indicates no hash. Model is one of 'none', 'auth' or 'priv'.
    #>
    [DscProperty()]
    [string] $Users

    <#
    .DESCRIPTION

    Specifies up to three SNMPv3 notification targets. Format is: 'ip-or-hostname[@port]/remote-user/security-level/trap|inform[,...]'.
    #>
    [DscProperty()]
    [string] $V3Targets

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            $modifyVMHostSNMPAgentMethodArguments = @{}
            if ($null -ne $this.NoTraps) { $modifyVMHostSNMPAgentMethodArguments.notraps = $this.NoTraps }
            if ($null -ne $this.SysContact) { $modifyVMHostSNMPAgentMethodArguments.syscontact = $this.SysContact }
            if ($null -ne $this.SysLocation) { $modifyVMHostSNMPAgentMethodArguments.syslocation = $this.SysLocation }

            $this.ExecuteEsxCliModifyMethod($this.EsxCliSetMethodName, $modifyVMHostSNMPAgentMethodArguments)
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

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)
            $esxCliGetMethodResult = $this.ExecuteEsxCliRetrievalMethod($this.EsxCliGetMethodName)

            $result = !$this.ShouldModifyVMHostSNMPAgent($esxCliGetMethodResult)

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [VMHostSNMPAgent] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [VMHostSNMPAgent]::new()

            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            $this.PopulateResult($result, $vmHost)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Checks if the VMHost SNMP Agent should be modified.
    #>
    [bool] ShouldModifyVMHostSNMPAgent($esxCliGetMethodResult) {
        $shouldModifyVMHostSNMPAgent = @()

        $shouldModifyVMHostSNMPAgent += (![string]::IsNullOrEmpty($this.Authentication) -and $this.Authentication -ne $esxCliGetMethodResult.authentication)
        $shouldModifyVMHostSNMPAgent += (![string]::IsNullOrEmpty($this.Communities) -and $this.Communities -ne $esxCliGetMethodResult.communities)
        $shouldModifyVMHostSNMPAgent += ($null -ne $this.Enable -and $this.Enable -ne [System.Convert]::ToBoolean($esxCliGetMethodResult.enable))
        $shouldModifyVMHostSNMPAgent += (![string]::IsNullOrEmpty($this.EngineId) -and $this.EngineId -ne $esxCliGetMethodResult.engineid)
        $shouldModifyVMHostSNMPAgent += (![string]::IsNullOrEmpty($this.Hwsrc) -and $this.Hwsrc -ne $esxCliGetMethodResult.hwsrc)
        $shouldModifyVMHostSNMPAgent += ($null -ne $this.LargeStorage -and $this.LargeStorage -ne [System.Convert]::ToBoolean($esxCliGetMethodResult.largestorage))
        $shouldModifyVMHostSNMPAgent += (![string]::IsNullOrEmpty($this.LogLevel) -and $this.LogLevel -ne $esxCliGetMethodResult.loglevel)
        $shouldModifyVMHostSNMPAgent += ($null -ne $this.NoTraps -and $this.NoTraps -ne [string] $esxCliGetMethodResult.notraps)
        $shouldModifyVMHostSNMPAgent += ($null -ne $this.Port -and $this.Port -ne [int] $esxCliGetMethodResult.port)
        $shouldModifyVMHostSNMPAgent += (![string]::IsNullOrEmpty($this.Privacy) -and $this.Privacy -ne $esxCliGetMethodResult.privacy)
        $shouldModifyVMHostSNMPAgent += (![string]::IsNullOrEmpty($this.RemoteUsers) -and $this.RemoteUsers -ne $esxCliGetMethodResult.remoteusers)
        $shouldModifyVMHostSNMPAgent += ($null -ne $this.SysContact -and $this.SysContact -ne $esxCliGetMethodResult.syscontact)
        $shouldModifyVMHostSNMPAgent += ($null -ne $this.SysLocation -and $this.SysLocation -ne $esxCliGetMethodResult.syslocation)
        $shouldModifyVMHostSNMPAgent += (![string]::IsNullOrEmpty($this.Targets) -and $this.Targets -ne $esxCliGetMethodResult.targets)
        $shouldModifyVMHostSNMPAgent += (![string]::IsNullOrEmpty($this.Users) -and $this.Users -ne $esxCliGetMethodResult.users)
        $shouldModifyVMHostSNMPAgent += (![string]::IsNullOrEmpty($this.V3Targets) -and $this.V3Targets -ne $esxCliGetMethodResult.v3targets)
        $shouldModifyVMHostSNMPAgent += ($null -ne $this.Reset -and $this.Reset)

        return ($shouldModifyVMHostSNMPAgent -Contains $true)
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $vmHost) {
        $result.Server = $this.Connection.Name
        $result.Name = $vmHost.Name
        $result.Reset = $this.Reset

        $esxCliGetMethodResult = $this.ExecuteEsxCliRetrievalMethod($this.EsxCliGetMethodName)

        $result.Authentication = $esxCliGetMethodResult.authentication
        $result.Communities = $esxCliGetMethodResult.communities
        $result.Enable = [System.Convert]::ToBoolean($esxCliGetMethodResult.enable)
        $result.EngineId = $esxCliGetMethodResult.engineid
        $result.Hwsrc = $esxCliGetMethodResult.hwsrc
        $result.LargeStorage = [System.Convert]::ToBoolean($esxCliGetMethodResult.largestorage)
        $result.LogLevel = $esxCliGetMethodResult.loglevel
        $result.NoTraps = $esxCliGetMethodResult.notraps
        $result.Port = [int] $esxCliGetMethodResult.port
        $result.Privacy = $esxCliGetMethodResult.privacy
        $result.RemoteUsers = $esxCliGetMethodResult.remoteusers
        $result.SysContact = $esxCliGetMethodResult.syscontact
        $result.SysLocation = $esxCliGetMethodResult.syslocation
        $result.Targets = $esxCliGetMethodResult.targets
        $result.Users = $esxCliGetMethodResult.users
        $result.V3Targets = $esxCliGetMethodResult.v3targets
    }
}

[DscResource()]
class VMHostSoftwareDevice : EsxCliBaseDSC {
    VMHostSoftwareDevice() {
        $this.EsxCliCommand = 'device.software'
    }

    <#
    .DESCRIPTION

    Specifies the device identifier from the device specification for the software device driver. Valid input is in reverse domain name format (e.g. com.company.device...).
    #>
    [DscProperty(Key)]
    [string] $DeviceIdentifier

    <#
    .DESCRIPTION

    Specifies whether the software device should be present or absent.
    #>
    [DscProperty(Mandatory = $true)]
    [Ensure] $Ensure

    <#
    .DESCRIPTION

    Specifies the unique number to address this instance of the device, if multiple instances of the same device identifier are added. Valid values are integer in the range 0-31. Default is 0.
    #>
    [DscProperty()]
    [nullable[long]] $InstanceAddress

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            $softwareDevice = $this.GetVMHostSoftwareDevice()
            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $softwareDevice) {
                    $this.ExecuteEsxCliModifyMethod($this.EsxCliAddMethodName)
                }
            }
            else {
                if ($null -ne $softwareDevice) {
                    $this.ExecuteEsxCliModifyMethod($this.EsxCliRemoveMethodName)
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

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            $result = $this.IsVMHostSoftwareDeviceInDesiredState()

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [VMHostSoftwareDevice] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [VMHostSoftwareDevice]::new()

            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            $this.PopulateResult($result, $vmHost)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Software device with the specified id and instance address if it exists.
    #>
    [PSObject] GetVMHostSoftwareDevice() {
        $esxCliListMethodResult = $this.ExecuteEsxCliRetrievalMethod($this.EsxCliListMethodName)
        $softwareDeviceInstanceAddress = if ($null -ne $this.InstanceAddress) { $this.InstanceAddress } else { 0 }
        $softwareDevice = $esxCliListMethodResult | Where-Object -FilterScript { $_.DeviceID -eq $this.DeviceIdentifier -and [long] $_.Instance -eq $softwareDeviceInstanceAddress }

        return $softwareDevice
    }

    <#
    .DESCRIPTION

    Checks if the Software device is in a Desired State depending on the value of the 'Ensure' property.
    #>
    [bool] IsVMHostSoftwareDeviceInDesiredState() {
        $softwareDevice = $this.GetVMHostSoftwareDevice()

        $result = $false
        if ($this.Ensure -eq [Ensure]::Present) {
            $result = ($null -ne $softwareDevice)
        }
        else {
            $result = ($null -eq $softwareDevice)
        }

        return $result
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $vmHost) {
        $result.Server = $this.Connection.Name
        $result.Name = $vmHost.Name

        $softwareDevice = $this.GetVMHostSoftwareDevice()
        if ($null -ne $softwareDevice) {
            $result.DeviceIdentifier = $softwareDevice.DeviceID
            $result.InstanceAddress = [long] $softwareDevice.Instance
            $result.Ensure = [Ensure]::Present
        }
        else {
            $result.DeviceIdentifier = $this.DeviceIdentifier
            $result.InstanceAddress = $this.InstanceAddress
            $result.Ensure = [Ensure]::Absent
        }
    }
}

[DscResource()]
class VMHostVMKernelActiveDumpFile : EsxCliBaseDSC {
    VMHostVMKernelActiveDumpFile() {
        $this.EsxCliCommand = 'system.coredump.file'
    }

    <#
    .DESCRIPTION

    Specifies whether the VMKernel dump file should be enabled or disabled.
    #>
    [DscProperty()]
    [nullable[bool]] $Enable

    <#
    .DESCRIPTION

    Specifies whether to select the best available file using the smart selection algorithm. Can only be used when 'Enabled' property is specified with '$true' value.
    #>
    [DscProperty()]
    [nullable[bool]] $Smart

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            $this.ExecuteEsxCliModifyMethod($this.EsxCliSetMethodName)
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

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)
            $esxCliGetMethodResult = $this.ExecuteEsxCliRetrievalMethod($this.EsxCliGetMethodName)

            $result = !$this.ShouldModifyVMKernelDumpFile($esxCliGetMethodResult)

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [VMHostVMKernelActiveDumpFile] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [VMHostVMKernelActiveDumpFile]::new()

            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            $this.PopulateResult($result, $vmHost)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Checks if the VMKernel dump file should be modified.
    #>
    [bool] ShouldModifyVMKernelDumpFile($esxCliGetMethodResult) {
        $result = $null

        if ($null -ne $this.Enable) {
            if ($this.Enable) { $result = [string]::IsNullOrEmpty($esxCliGetMethodResult.Active) }
            else { $result = ![string]::IsNullOrEmpty($esxCliGetMethodResult.Active) }
        }
        else {
            $result = $false
        }

        return $result
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $vmHost) {
        $result.Server = $this.Connection.Name
        $result.Name = $vmHost.Name
        $result.Smart = $this.Smart

        $esxCliGetMethodResult = $this.ExecuteEsxCliRetrievalMethod($this.EsxCliGetMethodName)
        $result.Enable = ![string]::IsNullOrEmpty($esxCliGetMethodResult.Active)
    }
}

[DscResource()]
class VMHostVMKernelActiveDumpPartition : EsxCliBaseDSC {
    VMHostVMKernelActiveDumpPartition() {
        $this.EsxCliCommand = 'system.coredump.partition'
    }

    <#
    .DESCRIPTION

    Specifies whether the VMKernel dump partition should be enabled or disabled.
    #>
    [DscProperty()]
    [nullable[bool]] $Enable

    <#
    .DESCRIPTION

    Specifies whether to select the best available partition using the smart selection algorithm. Can only be used when 'Enabled' property is specified with '$true' value.
    #>
    [DscProperty()]
    [nullable[bool]] $Smart

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            $this.ExecuteEsxCliModifyMethod($this.EsxCliSetMethodName)
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

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)
            $esxCliGetMethodResult = $this.ExecuteEsxCliRetrievalMethod($this.EsxCliGetMethodName)

            $result = !$this.ShouldModifyVMKernelDumpPartition($esxCliGetMethodResult)

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [VMHostVMKernelActiveDumpPartition] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [VMHostVMKernelActiveDumpPartition]::new()

            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            $this.PopulateResult($result, $vmHost)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Checks if the VMKernel dump partition should be modified.
    #>
    [bool] ShouldModifyVMKernelDumpPartition($esxCliGetMethodResult) {
        $result = $null

        if ($null -ne $this.Enable) {
            if ($this.Enable) { $result = [string]::IsNullOrEmpty($esxCliGetMethodResult.Active) }
            else { $result = ![string]::IsNullOrEmpty($esxCliGetMethodResult.Active) }
        }
        else {
            $result = $false
        }

        return $result
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $vmHost) {
        $result.Server = $this.Connection.Name
        $result.Name = $vmHost.Name
        $result.Smart = $this.Smart

        $esxCliGetMethodResult = $this.ExecuteEsxCliRetrievalMethod($this.EsxCliGetMethodName)
        $result.Enable = ![string]::IsNullOrEmpty($esxCliGetMethodResult.Active)
    }
}

[DscResource()]
class VMHostVMKernelDumpFile : EsxCliBaseDSC {
    VMHostVMKernelDumpFile() {
        $this.EsxCliCommand = 'system.coredump.file'
    }

    <#
    .DESCRIPTION

    Specifies the name of the Datastore for the dump file.
    #>
    [DscProperty(Key)]
    [string] $DatastoreName

    <#
    .DESCRIPTION

    Specifies the file name of the dump file.
    #>
    [DscProperty(Key)]
    [string] $FileName

    <#
    .DESCRIPTION

    Specifies whether the VMKernel dump Vmfs file should be present or absent.
    #>
    [DscProperty(Mandatory = $true)]
    [Ensure] $Ensure

    <#
    .DESCRIPTION

    Specifies the size in MB of the dump file. If not provided, a default size for the current machine is calculated.
    #>
    [DscProperty()]
    [nullable[long]] $Size

    <#
    .DESCRIPTION

    Specifies whether to deactivate and unconfigure the dump file being removed. This option is required if the file is active.
    #>
    [DscProperty()]
    [nullable[bool]] $Force

    hidden [string] $CouldNotRetrieveFileSystemsInformationMessage = "Could not retrieve information about File Systems on VMHost {0}. For more information: {1}"

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            if ($this.Ensure -eq [Ensure]::Present) {
                $addVMKernelDumpFileMethodArguments = @{
                    datastore = $this.DatastoreName
                    file = $this.FileName
                }

                $this.ExecuteEsxCliModifyMethod($this.EsxCliAddMethodName, $addVMKernelDumpFileMethodArguments)
            }
            else {
                $esxCliListMethodResult = $this.ExecuteEsxCliRetrievalMethod($this.EsxCliListMethodName)
                $vmKernelDumpFile = $this.GetVMKernelDumpFile($esxCliListMethodResult)
                $removeVMKernelDumpFileMethodArguments = @{
                    file = $vmKernelDumpFile.Path
                }

                $this.ExecuteEsxCliModifyMethod($this.EsxCliRemoveMethodName, $removeVMKernelDumpFileMethodArguments)
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

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)
            $esxCliListMethodResult = $this.ExecuteEsxCliRetrievalMethod($this.EsxCliListMethodName)
            $vmKernelDumpFile = $this.GetVMKernelDumpFile($esxCliListMethodResult)

            $result = $null
            if ($this.Ensure -eq [Ensure]::Present) {
                $result = ($vmKernelDumpFile.Count -ne 0)
            }
            else {
                $result = ($vmKernelDumpFile.Count -eq 0)
            }

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [VMHostVMKernelDumpFile] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [VMHostVMKernelDumpFile]::new()

            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            $this.PopulateResult($result, $vmHost)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Translates the Datastore name from a volume UUID to volume name, if required.
    #>
    [string] TranslateDatastoreName($datastoreName) {
        $foundDatastoreName = $null
        $fileSystemsList = $null

        try {
            $fileSystemsList = Invoke-EsxCliCommandMethod -EsxCli $this.EsxCli -EsxCliCommandMethod 'storage.filesystem.list.Invoke({0})' -EsxCliCommandMethodArguments @{}
        }
        catch {
            throw ($this.CouldNotRetrieveFileSystemsInformationMessage -f $this.Name, $_.Exception.Message)
        }

        foreach ($fileSystem in $fileSystemsList) {
            if ($fileSystem.UUID -eq $datastoreName) {
                $foundDatastoreName = $fileSystem.VolumeName
                break
            }

            if ($fileSystem.VolumeName -eq $datastoreName) {
                $foundDatastoreName = $fileSystem.VolumeName
                break
            }
        }

        return $foundDatastoreName
    }

    <#
    .DESCRIPTION

    Retrieves the name of the specified dump file.
    #>
    [string] GetDumpFileName($dumpFile) {
        $fileParts = $dumpFile -Split '\.'
        return $fileParts[0]
    }

    <#
    .DESCRIPTION

    Converts the passed bytes value to MB value.
    #>
    [double] ConvertBytesValueToMBValue($bytesValue) {
        return [Math]::Round($bytesValue / 1MB)
    }

    <#
    .DESCRIPTION

    Retrieves the VMKernel dump file if it exists.
    #>
    [PSObject] GetVMKernelDumpFile($esxCliListMethodResult) {
        $foundDumpFile = @{}
        $result = @()

        foreach ($dumpFile in $esxCliListMethodResult) {
            $dumpFileParts = $dumpFile.Path -Split '/'
            $dumpFileDatastoreName = $this.TranslateDatastoreName($dumpFileParts[3])
            $dumpFileName = $this.GetDumpFileName($dumpFileParts[5])

            $result += ($this.DatastoreName -eq $dumpFileDatastoreName)
            $result += ($this.FileName -eq $dumpFileName)

            if ($null -ne $this.Size) {
                $result += ($this.Size -eq $this.ConvertBytesValueToMBValue($dumpFile.Size))
            }

            if ($result -NotContains $false) {
                $foundDumpFile.Path = $dumpFile.Path
                $foundDumpFile.Datastore = $dumpFileDatastoreName
                $foundDumpFile.File = $dumpFileName
                $foundDumpFile.Size = $this.ConvertBytesValueToMBValue($dumpFile.Size)

                break
            }

            $result = @()
        }

        return $foundDumpFile
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $vmHost) {
        $result.Server = $this.Connection.Name
        $result.Name = $vmHost.Name
        $result.Force = $this.Force

        $esxCliListMethodResult = $this.ExecuteEsxCliRetrievalMethod($this.EsxCliListMethodName)
        $vmKernelDumpFile = $this.GetVMKernelDumpFile($esxCliListMethodResult)

        if ($vmKernelDumpFile.Count -ne 0) {
            $result.DatastoreName = $vmKernelDumpFile.Datastore
            $result.FileName = $vmKernelDumpFile.File
            $result.Size = $vmKernelDumpFile.Size
            $result.Ensure = [Ensure]::Present
        }
        else {
            $result.DatastoreName = $this.DatastoreName
            $result.FileName = $this.FileName
            $result.Size = $this.Size
            $result.Ensure = [Ensure]::Absent
        }
    }
}

[DscResource()]
class VMHostVMKernelModule : EsxCliBaseDSC {
    VMHostVMKernelModule() {
        $this.EsxCliCommand = 'system.module'
    }

    <#
    .DESCRIPTION

    Specifies the name of the VMKernel module.
    #>
    [DscProperty(Key)]
    [string] $Module

    <#
    .DESCRIPTION

    Specifies whether the module should be enabled or disabled.
    #>
    [DscProperty(Mandatory)]
    [bool] $Enabled

    <#
    .DESCRIPTION

    Specifies whether to skip the VMkernel module validity checks.
    #>
    [DscProperty()]
    [nullable[bool]] $Force

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            $this.ExecuteEsxCliModifyMethod($this.EsxCliSetMethodName)
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

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)
            $esxCliListMethodResult = $this.ExecuteEsxCliRetrievalMethod($this.EsxCliListMethodName)

            $result = !$this.ShouldModifyVMKernelModule($esxCliListMethodResult)

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [VMHostVMKernelModule] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [VMHostVMKernelModule]::new()

            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            $this.PopulateResult($result, $vmHost)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Checks if the specified VMKernel module should be modified.
    #>
    [bool] ShouldModifyVMKernelModule($esxCliListMethodResult) {
        $vmKernelModule = $esxCliListMethodResult | Where-Object -FilterScript { $_.Name -eq $this.Module }
        return ($this.Enabled -ne [System.Convert]::ToBoolean($vmKernelModule.IsEnabled))
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $vmHost) {
        $result.Server = $this.Connection.Name
        $result.Name = $vmHost.Name
        $result.Force = $this.Force

        $esxCliListMethodResult = $this.ExecuteEsxCliRetrievalMethod($this.EsxCliListMethodName)
        $vmKernelModule = $esxCliListMethodResult | Where-Object -FilterScript { $_.Name -eq $this.Module }

        $result.Module = $vmKernelModule.Name
        $result.Enabled = [System.Convert]::ToBoolean($vmKernelModule.IsEnabled)
    }
}

[DscResource()]
class VMHostvSANNetworkConfiguration : EsxCliBaseDSC {
    VMHostvSANNetworkConfiguration() {
        $this.EsxCliCommand = 'vsan.network.ip'
    }

    <#
    .DESCRIPTION

    Specifies the name of the interface.
    #>
    [DscProperty(Key)]
    [string] $InterfaceName

    <#
    .DESCRIPTION

    Specifies whether the IP interface of the vSAN network configuration should be present or absent.
    #>
    [DscProperty(Mandatory = $true)]
    [Ensure] $Ensure

    <#
    .DESCRIPTION

    Specifies the IPv4 multicast address for the agent group.
    #>
    [DscProperty()]
    [string] $AgentMcAddr

    <#
    .DESCRIPTION

    Specifies the IPv6 multicast address for the agent group.
    #>
    [DscProperty()]
    [string] $AgentV6McAddr

    <#
    .DESCRIPTION

    Specifies the multicast address port for the agent group.
    #>
    [DscProperty()]
    [nullable[long]] $AgentMcPort

    <#
    .DESCRIPTION

    Specifies the unicast address port for the VMHost unicast channel.
    #>
    [DscProperty()]
    [nullable[long]] $HostUcPort

    <#
    .DESCRIPTION

    Specifies the IPv4 multicast address for the master group.
    #>
    [DscProperty()]
    [string] $MasterMcAddr

    <#
    .DESCRIPTION

    Specifies the IPv6 multicast address for the master group.
    #>
    [DscProperty()]
    [string] $MasterV6McAddr

    <#
    .DESCRIPTION

    Specifies the multicast address port for the master group.
    #>
    [DscProperty()]
    [nullable[long]] $MasterMcPort

    <#
    .DESCRIPTION

    Specifies the time-to-live for multicast packets.
    #>
    [DscProperty()]
    [nullable[long]] $MulticastTtl

    <#
    .DESCRIPTION

    Specifies the network transmission type of the vSAN traffic through a virtual network adapter. Supported values are vsan and witness. Type 'vsan' means general vSAN transmission, which is used for both
    data and witness transmission, if there is no virtual adapter configured with 'witness' traffic type; Type 'witness' indicates that, vSAN vmknic is used for vSAN witness transmission.
    Once a virtual adapter is configured with 'witness' traffic type, vSAN witness data transmission will stop using virtual adapter with 'vsan' traffic type, and use first dicovered virtual adapter with 'witness' traffic type.
    Multiple traffic types can be provided in format -T type1 -T type2. Default value is 'vsan', if the property is not specified.
    #>
    [DscProperty()]
    [string[]] $TrafficType

    <#
    .DESCRIPTION

    Specifies whether to notify vSAN subsystem of the removal of the IP Interface, even if is not configured.
    #>
    [DscProperty()]
    [nullable[bool]] $Force

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            $vSanNetworkConfigurationIPInterface = $this.GetvSanNetworkConfigurationIPInterface()
            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $vSanNetworkConfigurationIPInterface) {
                    $this.ExecuteEsxCliModifyMethod($this.EsxCliAddMethodName)
                }
            }
            else {
                if ($null -ne $vSanNetworkConfigurationIPInterface) {
                    $this.ExecuteEsxCliModifyMethod($this.EsxCliRemoveMethodName)
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

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            $result = $this.IsvSanNetworkConfigurationIPInterfaceInDesiredState()

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [VMHostvSANNetworkConfiguration] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [VMHostvSANNetworkConfiguration]::new()

            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            $this.PopulateResult($result, $vmHost)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the IP interface with the specified name of the vSAN network configuration.
    #>
    [PSObject] GetvSanNetworkConfigurationIPInterface() {
        <#
        The 'list' method of the command is not on the same element as the 'add' and 'remove' methods. So the different methods
        need to be executed with different commands.
        #>
        $initialEsxCliCommand = $this.EsxCliCommand
        $this.EsxCliCommand = 'vsan.network'

        $esxCliListMethodResult = $this.ExecuteEsxCliRetrievalMethod($this.EsxCliListMethodName)

        # The command needs to be restored to its initial value, so that it can be used by the 'add' and 'remove' methods.
        $this.EsxCliCommand = $initialEsxCliCommand

        return ($esxCliListMethodResult | Where-Object -FilterScript { $_.VmkNicName -eq $this.InterfaceName })
    }

    <#
    .DESCRIPTION

    Checks if the vSan network configuration IP interface is in a Desired State depending on the value of the 'Ensure' property.
    #>
    [bool] IsvSanNetworkConfigurationIPInterfaceInDesiredState() {
        $vSanNetworkConfigurationIPInterface = $this.GetvSanNetworkConfigurationIPInterface()

        $result = $false
        if ($this.Ensure -eq [Ensure]::Present) {
            $result = ($null -ne $vSanNetworkConfigurationIPInterface)
        }
        else {
            $result = ($null -eq $vSanNetworkConfigurationIPInterface)
        }

        return $result
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $vmHost) {
        $result.Server = $this.Connection.Name
        $result.Name = $vmHost.Name
        $result.Force = $this.Force

        $vSanNetworkConfigurationIPInterface = $this.GetvSanNetworkConfigurationIPInterface()
        if ($null -ne $vSanNetworkConfigurationIPInterface) {
            $result.InterfaceName = $vSanNetworkConfigurationIPInterface.VmkNicName
            $result.AgentMcAddr = $vSanNetworkConfigurationIPInterface.AgentGroupMulticastAddress
            $result.AgentMcPort = [long] $vSanNetworkConfigurationIPInterface.AgentGroupMulticastPort
            $result.AgentV6McAddr = $vSanNetworkConfigurationIPInterface.AgentGroupIPv6MulticastAddress
            $result.HostUcPort = [long] $vSanNetworkConfigurationIPInterface.HostUnicastChannelBoundPort
            $result.MasterMcAddr = $vSanNetworkConfigurationIPInterface.MasterGroupMulticastAddress
            $result.MasterMcPort = [long] $vSanNetworkConfigurationIPInterface.MasterGroupMulticastPort
            $result.MasterV6McAddr = $vSanNetworkConfigurationIPInterface.MasterGroupIPv6MulticastAddress
            $result.MulticastTtl = [long] $vSanNetworkConfigurationIPInterface.MulticastTTL
            $result.TrafficType = $vSanNetworkConfigurationIPInterface.TrafficType
            $result.Ensure = [Ensure]::Present
        }
        else {
            $result.InterfaceName = $this.InterfaceName
            $result.AgentMcAddr = $this.AgentMcAddr
            $result.AgentMcPort = $this.AgentMcPort
            $result.AgentV6McAddr = $this.AgentV6McAddr
            $result.HostUcPort = $this.HostUcPort
            $result.MasterMcAddr = $this.MasterMcAddr
            $result.MasterMcPort = $this.MasterMcPort
            $result.MasterV6McAddr = $this.MasterV6McAddr
            $result.MulticastTtl = $this.MulticastTtl
            $result.TrafficType = $this.TrafficType
            $result.Ensure = [Ensure]::Absent
        }
    }
}

[DscResource()]
class VMHostVDSwitchMigration : VMHostNetworkMigrationBaseDSC {
    <#
    .DESCRIPTION

    Specifies the name of the vSphere Distributed Switch to which the VMHost and its Network should be part of.
    VMHost Network consists of the passed Physical Network Adapters, VMKernel Network Adapters and Port Groups.
    #>
    [DscProperty(Key)]
    [string] $VdsName

    <#
    .DESCRIPTION

    Specifies the names of the Port Groups to which the specified VMKernel Network Adapters should be attached. Accepts either one Port Group
    or the same number of Port Groups as the number of VMKernel Network Adapters specified. If one Port Group is specified, all Adapters are attached to that Port Group.
    If the same number of Port Groups as the number of VMKernel Network Adapters are specified, the first Adapter is attached to the first Port Group,
    the second Adapter to the second Port Group, and so on.
    #>
    [DscProperty()]
    [string[]] $PortGroupNames

    [void] Set() {
        try {
            $this.ConnectVIServer()
            $this.EnsureConnectionIsvCenter()

            $this.RetrieveVMHost()
            $distributedSwitch = $this.GetDistributedSwitch()

            if (!$this.IsVMHostAddedToDistributedSwitch($distributedSwitch)) {
                $this.AddVMHostToDistributedSwitch($distributedSwitch)
            }

            $physicalNetworkAdapters = $this.GetPhysicalNetworkAdapters()
            if ($this.VMkernelNicNames.Length -eq 0) {
                $this.AddPhysicalNetworkAdaptersToDistributedSwitch($physicalNetworkAdapters, $distributedSwitch)
            }
            else {
                $vmKernelNetworkAdapters = $this.GetVMKernelNetworkAdapters()
                $this.EnsureVMKernelNetworkAdapterAndPortGroupNamesCountIsCorrect()

                $this.AddPhysicalNetworkAdaptersAndVMKernelNetworkAdaptersToDistributedSwitch($physicalNetworkAdapters, $vmKernelNetworkAdapters, $distributedSwitch)
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

            $this.RetrieveVMHost()
            $distributedSwitch = $this.GetDistributedSwitch()

            if (!$this.IsVMHostAddedToDistributedSwitch($distributedSwitch)) {
                return $false
            }

            if ($this.ShouldAddPhysicalNetworkAdaptersToDistributedSwitch($distributedSwitch)) {
                return $false
            }

            if ($this.VMkernelNicNames.Length -eq 0 -and $this.PortGroupNames.Length -eq 0) {
                return $true
            }
            else {
                return !$this.ShouldAddVMKernelNetworkAdaptersAndPortGroupsToDistributedSwitch($distributedSwitch)
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostVDSwitchMigration] Get() {
        try {
            $result = [VMHostVDSwitchMigration]::new()

            $this.ConnectVIServer()
            $this.EnsureConnectionIsvCenter()

            $this.RetrieveVMHost()
            $distributedSwitch = $this.GetDistributedSwitch()

            $this.PopulateResult($distributedSwitch, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Distributed Switch with the specified name from the server if it exists.
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
            $distributedSwitch = Get-VDSwitch -Server $this.Connection -Name $this.VdsName -ErrorAction Stop
            return $distributedSwitch
        }
        catch {
            throw "Could not retrieve Distributed Switch $($this.VdsName). For more information: $($_.Exception.Message)"
        }
        finally {
            $global:VerbosePreference = $savedVerbosePreference
        }
    }

    <#
    .DESCRIPTION

    Retrieves all connected Physical Network Adapters from the specified array of Physical Network Adapters.
    #>
    [array] GetConnectedPhysicalNetworkAdapters($physicalNetworkAdapters) {
        return ($physicalNetworkAdapters | Where-Object -FilterScript { $_.BitRatePerSec -ne 0 })
    }

    <#
    .DESCRIPTION

    Retrieves all disconnected Physical Network Adapters from the specified array of Physical Network Adapters.
    #>
    [array] GetDisconnectedPhysicalNetworkAdapters($physicalNetworkAdapters) {
        return ($physicalNetworkAdapters | Where-Object -FilterScript { $_.BitRatePerSec -eq 0 })
    }

    <#
    .DESCRIPTION

    Checks if the specified VMHost is part of the Distributed Switch.
    #>
    [bool] IsVMHostAddedToDistributedSwitch($distributedSwitch) {
        $addedVMHost = $this.VMHost.ExtensionData.Config.Network.ProxySwitch | Where-Object -FilterScript { $_.DvsName -eq $distributedSwitch.Name }
        return ($null -ne $addedVMHost)
    }

    <#
    .DESCRIPTION

    Checks if all passed Physical Network Adapters are added to the Distributed Switch.
    #>
    [bool] ShouldAddPhysicalNetworkAdaptersToDistributedSwitch($distributedSwitch) {
        $physicalNetworkAdapters = $this.GetPhysicalNetworkAdapters()
        if ($physicalNetworkAdapters.Length -eq 0) {
            throw 'At least one Physical Network Adapter needs to be specified.'
        }

        if ($null -eq $distributedSwitch.ExtensionData.Config.Host.Config.Backing.PnicSpec) {
            # No Physical Network Adapters are added to the Distributed Switch.
            return $true
        }

        foreach ($physicalNetworkAdapter in $physicalNetworkAdapters) {
            $addedPhysicalNetworkAdapter = $distributedSwitch.ExtensionData.Config.Host.Config.Backing.PnicSpec | Where-Object -FilterScript { $_.PNicDevice -eq $physicalNetworkAdapter.Name }
            if ($null -eq $addedPhysicalNetworkAdapter) {
                return $true
            }
        }

        return $false
    }

    <#
    .DESCRIPTION

    Checks if all passed VMKernel Network Adapters and Port Groups are added to the Distributed Switch.
    #>
    [bool] ShouldAddVMKernelNetworkAdaptersAndPortGroupsToDistributedSwitch($distributedSwitch) {
        $this.EnsureVMKernelNetworkAdapterAndPortGroupNamesCountIsCorrect()

        if ($this.PortGroupNames.Length -eq 1) {
            $portGroupName = $this.PortGroupNames[0]

            foreach ($vmKernelNetworkAdapterName in $this.VMKernelNicNames) {
                $getVMHostNetworkAdapterParams = @{
                    Server = $this.Connection
                    Name = $vmKernelNetworkAdapterName
                    VMHost = $this.VMHost
                    VirtualSwitch = $distributedSwitch
                    PortGroup = $portGroupName
                    VMKernel = $true
                    ErrorAction = 'SilentlyContinue'
                }

                $vmKernelNetworkAdapter = Get-VMHostNetworkAdapter @getVMHostNetworkAdapterParams
                if ($null -eq $vmKernelNetworkAdapter) {
                    return $true
                }
            }
        }
        else {
            for ($i = 0; $i -lt $this.VMKernelNicNames.Length; $i++) {
                $vmKernelNetworkAdapterName = $this.VMKernelNicNames[$i]
                $portGroupName = $this.PortGroupNames[$i]

                $getVMHostNetworkAdapterParams = @{
                    Server = $this.Connection
                    Name = $vmKernelNetworkAdapterName
                    VMHost = $this.VMHost
                    VirtualSwitch = $distributedSwitch
                    PortGroup = $portGroupName
                    VMKernel = $true
                    ErrorAction = 'SilentlyContinue'
                }

                $vmKernelNetworkAdapter = Get-VMHostNetworkAdapter @getVMHostNetworkAdapterParams
                if ($null -eq $vmKernelNetworkAdapter) {
                    return $true
                }
            }
        }

        return $false
    }

    <#
    .DESCRIPTION

    Ensures that the specified Distributed Port Groups exist. If a Distributed Port Group is specified and does not exist,
    it is created on the specified Distributed Switch.
    #>
    [void] EnsureDistributedPortGroupsExist($distributedSwitch) {
        foreach ($distributedPortGroupName in $this.PortGroupNames) {
            $distributedPortGroup = Get-VDPortgroup -Server $this.Connection -Name $distributedPortGroupName -VDSwitch $distributedSwitch -ErrorAction SilentlyContinue
            if ($null -eq $distributedPortGroup) {
                try {
                    New-VDPortgroup -Server $this.Connection -Name $distributedPortGroupName -VDSwitch $distributedSwitch -Confirm:$false -ErrorAction Stop
                }
                catch {
                    throw "Cannot create Distributed Port Group $distributedPortGroupName on Distributed Switch $($distributedSwitch.Name). For more information: $($_.Exception.Message)"
                }
            }
        }
    }

    <#
    .DESCRIPTION

    Ensures that the passed VMKernel Network Adapter names and Port Group names count meets the following criteria:
    If at least one VMKernel Network Adapter is specified, one of the following requirements should be met:
    1. The number of specified Port Groups should be equal to the number of specified VMKernel Network Adapters.
    2. Only one Port Group is passed.
    If no VMKernel Network Adapter names are passed, no Port Group names should be passed as well.
    #>
    [void] EnsureVMKernelNetworkAdapterAndPortGroupNamesCountIsCorrect() {
        if ($this.VMkernelNicNames.Length -gt 0) {
            if ($this.PortGroupNames.Length -eq 0 -or ($this.VMkernelNicNames.Length -ne $this.PortGroupNames.Length -and $this.PortGroupNames.Length -ne 1)) {
                throw "$($this.VMKernelNicNames.Length) VMKernel Network Adapters specified and $($this.PortGroupNames.Length) Port Groups specified which is not valid."
            }
        }
        else {
            if ($this.PortGroupNames.Length -ne 0) {
                throw "$($this.PortGroupNames.Length) Port Groups specified and no VMKernel Network Adapters specified which is not valid."
            }
        }
    }

    <#
    .DESCRIPTION

    Adds the VMHost to the specified Distributed Switch.
    #>
    [void] AddVMHostToDistributedSwitch($distributedSwitch) {
        try {
            Add-VDSwitchVMHost -Server $this.Connection -VDSwitch $distributedSwitch -VMHost $this.VMHost -Confirm:$false -ErrorAction Stop
        }
        catch {
            throw "Could not add VMHost $($this.VMHost.Name) to Distributed Switch $($distributedSwitch.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Adds the specified connected Physical Network Adapter to the specified Distributed Switch.
    #>
    [void] AddConnectedPhysicalNetworkAdapterToDistributedSwitch($connectedPhysicalNetworkAdapter, $distributedSwitch) {
        try {
            $addVDSwitchPhysicalNetworkAdapterParams = @{
                Server = $this.Connection
                DistributedSwitch = $distributedSwitch
                VMHostPhysicalNic = $connectedPhysicalNetworkAdapter
                Confirm = $false
                ErrorAction = 'Stop'
            }

            Add-VDSwitchPhysicalNetworkAdapter @addVDSwitchPhysicalNetworkAdapterParams
        }
        catch {
            throw "Could not migrate Physical Network Adapter $($connectedPhysicalNetworkAdapter.Name) to Distributed Switch $($distributedSwitch.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Adds the Physical Network Adapters to the specified Distributed Switch.
    #>
    [void] AddPhysicalNetworkAdaptersToDistributedSwitch($physicalNetworkAdapters, $distributedSwitch) {
        if ($physicalNetworkAdapters.Length -eq 1) {
            try {
                $addVDSwitchPhysicalNetworkAdapterParams = @{
                    Server = $this.Connection
                    DistributedSwitch = $distributedSwitch
                    VMHostPhysicalNic = $physicalNetworkAdapters
                    Confirm = $false
                    ErrorAction = 'Stop'
                }

                Add-VDSwitchPhysicalNetworkAdapter @addVDSwitchPhysicalNetworkAdapterParams
                return
            }
            catch {
                throw "Could not migrate Physical Network Adapter $($physicalNetworkAdapters) to Distributed Switch $($distributedSwitch.Name). For more information: $($_.Exception.Message)"
            }
        }

        $connectedPhysicalNetworkAdapters = $this.GetConnectedPhysicalNetworkAdapters($physicalNetworkAdapters)
        $disconnectedPhysicalNetworkAdapters = $this.GetDisconnectedPhysicalNetworkAdapters($physicalNetworkAdapters)

        if ($connectedPhysicalNetworkAdapters.Length -eq 0) {
            try {
                $addVDSwitchPhysicalNetworkAdapterParams = @{
                    Server = $this.Connection
                    DistributedSwitch = $distributedSwitch
                    VMHostPhysicalNic = $disconnectedPhysicalNetworkAdapters
                    Confirm = $false
                    ErrorAction = 'Stop'
                }

                Add-VDSwitchPhysicalNetworkAdapter @addVDSwitchPhysicalNetworkAdapterParams
            }
            catch {
                throw "Could not migrate Physical Network Adapters $($disconnectedPhysicalNetworkAdapters) to Distributed Switch $($distributedSwitch.Name). For more information: $($_.Exception.Message)"
            }
        }
        else {
            <#
            If they are connected Physical Network Adapters passed, we need to first move only one of them to the specified Distributed Switch and
            after that move the remaining ones. This is to ensure that the ESXi is not disconnected from the vCenter Server.
            #>
            $this.AddConnectedPhysicalNetworkAdapterToDistributedSwitch($connectedPhysicalNetworkAdapters[0], $distributedSwitch)

            # The first connected Physical Network Adapter is already migrated, so we only need the remaining connected Physical Network Adapters.
            $connectedPhysicalNetworkAdapters = $connectedPhysicalNetworkAdapters[1..($connectedPhysicalNetworkAdapters.Length - 1)]
            $physicalNetworkAdaptersToMigrate = $connectedPhysicalNetworkAdapters + $disconnectedPhysicalNetworkAdapters

            try {
                $addVDSwitchPhysicalNetworkAdapterParams = @{
                    Server = $this.Connection
                    DistributedSwitch = $distributedSwitch
                    VMHostPhysicalNic = $physicalNetworkAdaptersToMigrate
                    Confirm = $false
                    ErrorAction = 'Stop'
                }

                Add-VDSwitchPhysicalNetworkAdapter @addVDSwitchPhysicalNetworkAdapterParams
            }
            catch {
                throw "Could not migrate Physical Network Adapters $($physicalNetworkAdaptersToMigrate) to Distributed Switch $($distributedSwitch.Name). For more information: $($_.Exception.Message)"
            }
        }
    }

    <#
    .DESCRIPTION

    Adds the Physical Network Adapters and VMKernel Network Adapters to the specified Distributed Switch.
    #>
    [void] AddPhysicalNetworkAdaptersAndVMKernelNetworkAdaptersToDistributedSwitch($physicalNetworkAdapters, $vmKernelNetworkAdapters, $distributedSwitch) {
        $this.EnsureDistributedPortGroupsExist($distributedSwitch)

        if ($physicalNetworkAdapters.Length -eq 1) {
            try {
                $addVDSwitchPhysicalNetworkAdapterParams = @{
                    Server = $this.Connection
                    DistributedSwitch = $distributedSwitch
                    VMHostPhysicalNic = $physicalNetworkAdapters
                    VMHostVirtualNic = $vmKernelNetworkAdapters
                    VirtualNicPortgroup = $this.PortGroupNames
                    Confirm = $false
                    ErrorAction = 'Stop'
                }

                Add-VDSwitchPhysicalNetworkAdapter @addVDSwitchPhysicalNetworkAdapterParams
                return
            }
            catch {
                throw "Could not migrate Physical Network Adapter $($physicalNetworkAdapters) to Distributed Switch $($distributedSwitch.Name). For more information: $($_.Exception.Message)"
            }
        }

        $connectedPhysicalNetworkAdapters = $this.GetConnectedPhysicalNetworkAdapters($physicalNetworkAdapters)
        $disconnectedPhysicalNetworkAdapters = $this.GetDisconnectedPhysicalNetworkAdapters($physicalNetworkAdapters)

        if ($connectedPhysicalNetworkAdapters.Length -eq 0) {
            try {
                $addVDSwitchPhysicalNetworkAdapterParams = @{
                    Server = $this.Connection
                    DistributedSwitch = $distributedSwitch
                    VMHostPhysicalNic = $disconnectedPhysicalNetworkAdapters
                    VMHostVirtualNic = $vmKernelNetworkAdapters
                    VirtualNicPortgroup = $this.PortGroupNames
                    Confirm = $false
                    ErrorAction = 'Stop'
                }

                Add-VDSwitchPhysicalNetworkAdapter @addVDSwitchPhysicalNetworkAdapterParams
            }
            catch {
                throw "Could not migrate Physical Network Adapters $($disconnectedPhysicalNetworkAdapters) and $($vmKernelNetworkAdapters) to Distributed Switch $($distributedSwitch.Name). For more information: $($_.Exception.Message)"
            }
        }
        else {
            <#
            If they are connected Physical Network Adapters passed, we need to first move only one of them to the specified Distributed Switch and
            after that move the remaining ones. This is to ensure that the ESXi is not disconnected from the vCenter Server.
            #>
            $this.AddConnectedPhysicalNetworkAdapterToDistributedSwitch($connectedPhysicalNetworkAdapters[0], $distributedSwitch)

            # The first connected Physical Network Adapter is already migrated, so we only need the remaining connected Physical Network Adapters.
            $connectedPhysicalNetworkAdapters = $connectedPhysicalNetworkAdapters[1..($connectedPhysicalNetworkAdapters.Length - 1)]
            $physicalNetworkAdaptersToMigrate = $connectedPhysicalNetworkAdapters + $disconnectedPhysicalNetworkAdapters

            try {
                $addVDSwitchPhysicalNetworkAdapterParams = @{
                    Server = $this.Connection
                    DistributedSwitch = $distributedSwitch
                    VMHostPhysicalNic = $physicalNetworkAdaptersToMigrate
                    VMHostVirtualNic = $vmKernelNetworkAdapters
                    VirtualNicPortgroup = $this.PortGroupNames
                    Confirm = $false
                    ErrorAction = 'Stop'
                }

                Add-VDSwitchPhysicalNetworkAdapter @addVDSwitchPhysicalNetworkAdapterParams
            }
            catch {
                throw "Could not migrate Physical Network Adapters $($physicalNetworkAdaptersToMigrate) and VMKernel Network Adapters $($vmKernelNetworkAdapters) to Distributed Switch $($distributedSwitch.Name). For more information: $($_.Exception.Message)"
            }
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method.
    #>
    [void] PopulateResult($distributedSwitch, $result) {
        $result.Server = $this.Connection.Name
        $result.VMHostName = $this.VMHost.Name
        $result.VdsName = $distributedSwitch.Name

        if ($null -eq $distributedSwitch.ExtensionData.Config.Host.Config.Backing.PnicSpec) {
            $result.PhysicalNicNames = @()
        }
        else {
            $result.PhysicalNicNames = [string[]]($distributedSwitch.ExtensionData.Config.Host.Config.Backing.PnicSpec | Select-Object -ExpandProperty PNicDevice)
        }

        $result.VMkernelNicNames = @()
        $result.PortGroupNames = @()

        if ($this.VMKernelNicNames.Length -eq 0) {
            return
        }

        $vmKernelNetworkAdapters = Get-VMHostNetworkAdapter -Server $this.Connection -VMHost $this.VMHost -VirtualSwitch $distributedSwitch -VMKernel -ErrorAction SilentlyContinue |
                                   Where-Object -FilterScript { $this.VMKernelNicNames.Contains($_.Name) }

        foreach ($vmKernelNetworkAdapter in $vmKernelNetworkAdapters) {
            $result.VMkernelNicNames += $vmKernelNetworkAdapter.Name
            $result.PortGroupNames += $vmKernelNetworkAdapter.PortGroupName
        }
    }
}

[DscResource()]
class VMHostVssMigration : VMHostNetworkMigrationBaseDSC {
    <#
    .DESCRIPTION

    Specifies the name of the Standard Switch to which the passed Physical Network Adapters, VMKernel Network Adapters and Port Groups should be part of.
    #>
    [DscProperty(Key)]
    [string] $VssName

    <#
    .DESCRIPTION

    Specifies the names of the Port Groups to which the specified VMKernel Network Adapters should be attached. Accepts the same number of
    Port Groups as the number of VMKernel Network Adapters specified. The first Adapter is attached to the first Port Group,
    the second Adapter to the second Port Group, and so on.
    #>
    [DscProperty()]
    [string[]] $PortGroupNames

    [void] Set() {
        try {
            $this.ConnectVIServer()
            $this.EnsureConnectionIsvCenter()

            $this.RetrieveVMHost()
            $standardSwitch = $this.GetStandardSwitch()

            $physicalNetworkAdapters = $this.GetPhysicalNetworkAdapters()
            if ($this.VMkernelNicNames.Length -eq 0) {
                $this.AddPhysicalNetworkAdaptersToStandardSwitch($physicalNetworkAdapters, $standardSwitch)
            }
            else {
                $vmKernelNetworkAdapters = $this.GetVMKernelNetworkAdapters()
                $this.EnsureVMKernelNetworkAdapterAndPortGroupNamesCountIsCorrect()

                $this.AddPhysicalNetworkAdaptersAndVMKernelNetworkAdaptersToStandardSwitch($physicalNetworkAdapters, $vmKernelNetworkAdapters, $standardSwitch)
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

            $this.RetrieveVMHost()
            $standardSwitch = $this.GetStandardSwitch()

            if ($this.ShouldAddPhysicalNetworkAdaptersToStandardSwitch($standardSwitch)) {
                return $false
            }

            if ($this.VMkernelNicNames.Length -eq 0 -and $this.PortGroupNames.Length -eq 0) {
                return $true
            }
            else {
                return !$this.ShouldAddVMKernelNetworkAdaptersAndPortGroupsToStandardSwitch($standardSwitch)
            }
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    [VMHostVssMigration] Get() {
        try {
            $result = [VMHostVssMigration]::new()

            $this.ConnectVIServer()
            $this.EnsureConnectionIsvCenter()

            $this.RetrieveVMHost()
            $standardSwitch = $this.GetStandardSwitch()

            $this.PopulateResult($standardSwitch, $result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
        }
    }

    <#
    .DESCRIPTION

    Retrieves the Standard Switch with the specified name from the specified VMHost if it exists.
    Otherwise it throws an exception.
    #>
    [PSObject] GetStandardSwitch() {
        try {
            $standardSwitch = Get-VirtualSwitch -Server $this.Connection -Name $this.VssName -VMHost $this.VMHost -Standard -ErrorAction Stop
            return $standardSwitch
        }
        catch {
            throw "Could not retrieve Standard Switch $($this.VssName). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Checks if all passed Physical Network Adapters are added to the Standard Switch.
    #>
    [bool] ShouldAddPhysicalNetworkAdaptersToStandardSwitch($standardSwitch) {
        $physicalNetworkAdapters = $this.GetPhysicalNetworkAdapters()
        if ($physicalNetworkAdapters.Length -eq 0) {
            throw 'At least one Physical Network Adapter needs to be specified.'
        }

        if ($null -eq $standardSwitch.Nic) {
            # No Physical Network Adapters are added to the Standard Switch.
            return $true
        }

        foreach ($physicalNetworkAdapter in $physicalNetworkAdapters) {
            $addedPhysicalNetworkAdapter = $standardSwitch.Nic | Where-Object -FilterScript { $_ -eq $physicalNetworkAdapter.Name }
            if ($null -eq $addedPhysicalNetworkAdapter) {
                return $true
            }
        }

        return $false
    }

    <#
    .DESCRIPTION

    Checks if all passed VMKernel Network Adapters and Port Groups are added to the Standard Switch.
    #>
    [bool] ShouldAddVMKernelNetworkAdaptersAndPortGroupsToStandardSwitch($standardSwitch) {
        $this.EnsureVMKernelNetworkAdapterAndPortGroupNamesCountIsCorrect()

        for ($i = 0; $i -lt $this.VMKernelNicNames.Length; $i++) {
            $vmKernelNetworkAdapterName = $this.VMKernelNicNames[$i]

            $getVMHostNetworkAdapterParams = @{
                Server = $this.Connection
                Name = $vmKernelNetworkAdapterName
                VMHost = $this.VMHost
                VirtualSwitch = $standardSwitch
                VMKernel = $true
                ErrorAction = 'SilentlyContinue'
            }

            if ($this.PortGroupNames.Length -gt 0) {
                $getVMHostNetworkAdapterParams.PortGroup = $this.PortGroupNames[$i]
            }

            $vmKernelNetworkAdapter = Get-VMHostNetworkAdapter @getVMHostNetworkAdapterParams
            if ($null -eq $vmKernelNetworkAdapter) {
                return $true
            }
        }

        return $false
    }

    <#
    .DESCRIPTION

    Ensures that the passed VMKernel Network Adapter names and Port Group names count meets the following criteria:
    If VMKernel Network Adapter names are passed, the following requirements should be met:
    No Port Group names are passed or the number of Port Group names is the same as the number of VMKernel Network Adapter names.
    If no VMKernel Network Adapter names are passed, no Port Group names should be passed as well.
    #>
    [void] EnsureVMKernelNetworkAdapterAndPortGroupNamesCountIsCorrect() {
        if ($this.VMKernelNicNames.Length -gt 0) {
            if ($this.PortGroupNames.Length -gt 0 -and $this.VMkernelNicNames.Length -ne $this.PortGroupNames.Length) {
                throw "$($this.VMKernelNicNames.Length) VMKernel Network Adapters specified and $($this.PortGroupNames.Length) Port Groups specified which is not valid."
            }
        }
        else {
            if ($this.PortGroupNames.Length -gt 0) {
                throw "$($this.VMKernelNicNames.Length) VMKernel Network Adapters specified and $($this.PortGroupNames.Length) Port Groups specified which is not valid."
            }
        }
    }

    <#
    .DESCRIPTION

    Ensures that the specified Standard Port Groups exist. If a Standard Port Group is specified and does not exist,
    it is created on the specified Standard Switch.
    #>
    [void] EnsureStandardPortGroupsExist($standardSwitch) {
        foreach ($standardPortGroupName in $this.PortGroupNames) {
            $standardPortGroup = Get-VirtualPortGroup -Server $this.Connection -Name $standardPortGroupName -VirtualSwitch $standardSwitch -Standard -ErrorAction SilentlyContinue
            if ($null -eq $standardPortGroup) {
                try {
                    New-VirtualPortGroup -Server $this.Connection -Name $standardPortGroupName -VirtualSwitch $standardSwitch -Confirm:$false -ErrorAction Stop
                }
                catch {
                    throw "Cannot create Standard Port Group $standardPortGroupName on Standard Switch $($standardSwitch.Name). For more information: $($_.Exception.Message)"
                }
            }
        }
    }

    <#
    .DESCRIPTION

    Adds the Physical Network Adapters to the specified Standard Switch.
    #>
    [void] AddPhysicalNetworkAdaptersToStandardSwitch($physicalNetworkAdapters, $standardSwitch) {
        try {
            $addVirtualSwitchPhysicalNetworkAdapterParams = @{
                Server = $this.Connection
                VirtualSwitch = $standardSwitch
                VMHostPhysicalNic = $physicalNetworkAdapters
                Confirm = $false
                ErrorAction = 'Stop'
            }

            Add-VirtualSwitchPhysicalNetworkAdapter @addVirtualSwitchPhysicalNetworkAdapterParams
        }
        catch {
            throw "Could not migrate Physical Network Adapters $($physicalNetworkAdapters) to Standard Switch $($standardSwitch.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Adds the Physical Network Adapters and VMKernel Network Adapters to the specified Standard Switch.
    #>
    [void] AddPhysicalNetworkAdaptersAndVMKernelNetworkAdaptersToStandardSwitch($physicalNetworkAdapters, $vmKernelNetworkAdapters, $standardSwitch) {
        $this.EnsureStandardPortGroupsExist($standardSwitch)

        try {
            $addVirtualSwitchPhysicalNetworkAdapterParams = @{
                Server = $this.Connection
                VirtualSwitch = $standardSwitch
                VMHostPhysicalNic = $physicalNetworkAdapters
                VMHostVirtualNic = $vmKernelNetworkAdapters
                Confirm = $false
                ErrorAction = 'Stop'
            }

            if ($this.PortGroupNames.Length -gt 0) {
                $addVirtualSwitchPhysicalNetworkAdapterParams.VirtualNicPortgroup = $this.PortGroupNames
            }

            Add-VirtualSwitchPhysicalNetworkAdapter @addVirtualSwitchPhysicalNetworkAdapterParams
        }
        catch {
            throw "Could not migrate Physical Network Adapters $($physicalNetworkAdapters) and VMKernel Network Adapters $($vmKernelNetworkAdapters) to Standard Switch $($standardSwitch.Name). For more information: $($_.Exception.Message)"
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get() method.
    #>
    [void] PopulateResult($standardSwitch, $result) {
        $result.Server = $this.Connection.Name
        $result.VMHostName = $this.VMHost.Name
        $result.VssName = $standardSwitch.Name
        $result.PhysicalNicNames = $standardSwitch.Nic
        $result.VMkernelNicNames = @()
        $result.PortGroupNames = @()

        if ($this.VMKernelNicNames.Length -eq 0) {
            return
        }

        $vmKernelNetworkAdapters = Get-VMHostNetworkAdapter -Server $this.Connection -VMHost $this.VMHost -VirtualSwitch $standardSwitch -VMKernel -ErrorAction SilentlyContinue |
                                   Where-Object -FilterScript { $this.VMKernelNicNames.Contains($_.Name) }

        foreach ($vmKernelNetworkAdapter in $vmKernelNetworkAdapters) {
            $result.VMkernelNicNames += $vmKernelNetworkAdapter.Name
            $result.PortGroupNames += $vmKernelNetworkAdapter.PortGroupName
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
class VMHostVssNic : VMHostNicBaseDSC {
    <#
    .DESCRIPTION

    Specifies the name of the Virtual Switch to which the VMKernel Network Adapter should be connected.
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
                    $vmHostNetworkAdapter = $this.AddVMHostNetworkAdapter($virtualSwitch, $null)
                }

                if ($this.ShouldUpdateVMHostNetworkAdapter($vmHostNetworkAdapter)) {
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

            $this.ConnectVIServer()
            $this.RetrieveVMHost()

            $virtualSwitch = $this.GetVirtualSwitch()
            $vmHostNetworkAdapter = $this.GetVMHostNetworkAdapter($virtualSwitch)

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
}

[DscResource()]
class VMHostIPRoute : VMHostBaseDSC {
    <#
    .DESCRIPTION

    Specifies the gateway IPv4/IPv6 address of the route.
    #>
    [DscProperty(Key)]
    [string] $Gateway

    <#
    .DESCRIPTION

    Specifies the destination IPv4/IPv6 address of the route.
    #>
    [DscProperty(Key)]
    [string] $Destination

    <#
    .DESCRIPTION

    Specifies the prefix length of the destination IP address. For IPv4, the valid values are from 0 to 32, and for IPv6 - from 0 to 128.
    #>
    [DscProperty(Key)]
    [int] $PrefixLength

    <#
    .DESCRIPTION

    Specifies whether the IPv4/IPv6 route should be present or absent.
    #>
    [DscProperty(Mandatory = $true)]
    [Ensure] $Ensure

    hidden [string] $CreateVMHostIPRouteMessage = "Creating IP Route with Gateway address {0} and Destination address {1} on VMHost {2}."
    hidden [string] $RemoveVMHostIPRouteMessage = "Removing IP Route with Gateway address {0} and Destination address {1} on VMHost {2}."

    hidden [string] $CouldNotCreateVMHostIPRouteMessage = "Could not create IP Route with Gateway address {0} and Destination address {1} on VMHost {2}. For more information: {3}"
    hidden [string] $CouldNotRemoveVMHostIPRouteMessage = "Could not remove IP Route with Gateway address {0} and Destination address {1} on VMHost {2}. For more information: {3}"

    [void] Set() {
        try {
            Write-VerboseLog -Message $this.SetMethodStartMessage -Arguments @($this.DscResourceName)
            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $vmHostIPRoute = $this.GetVMHostIPRoute($vmHost)

            if ($this.Ensure -eq [Ensure]::Present) {
                if ($null -eq $vmHostIPRoute) {
                    $this.NewVMHostIPRoute($vmHost)
                }
            }
            else {
                if ($null -ne $vmHostIPRoute) {
                    $this.RemoveVMHostIPRoute($vmHostIPRoute)
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

            $vmHost = $this.GetVMHost()
            $vmHostIPRoute = $this.GetVMHostIPRoute($vmHost)

            $result = $null
            if ($this.Ensure -eq [Ensure]::Present) {
                $result = ($null -ne $vmHostIPRoute)
            }
            else {
                $result = ($null -eq $vmHostIPRoute)
            }

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.TestMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    [VMHostIPRoute] Get() {
        try {
            Write-VerboseLog -Message $this.GetMethodStartMessage -Arguments @($this.DscResourceName)
            $result = [VMHostIPRoute]::new()

            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $vmHostIPRoute = $this.GetVMHostIPRoute($vmHost)

            $this.PopulateResult($result, $vmHostIPRoute)

            return $result
        }
        finally {
            $this.DisconnectVIServer()
            Write-VerboseLog -Message $this.GetMethodEndMessage -Arguments @($this.DscResourceName)
        }
    }

    <#
    .DESCRIPTION

    Retrieves the configured IPv4/IPv6 route with the specified Gateway and Destination addresses if it exists.
    #>
    [PSObject] GetVMHostIPRoute($vmHost) {
        return (Get-VMHostRoute -Server $this.Connection -VMHost $vmHost -ErrorAction SilentlyContinue -Verbose:$false |
                Where-Object -FilterScript { $_.Gateway -eq $this.Gateway -and $_.Destination -eq $this.Destination -and $_.PrefixLength -eq $this.PrefixLength })
    }

    <#
    .DESCRIPTION

    Creates a new IP route with the specified Gateway and Destination addresses.
    #>
    [void] NewVMHostIPRoute($vmHost) {
        $newVMHostRouteParams = @{
            Server = $this.Connection
            VMHost = $vmHost
            Gateway = $this.Gateway
            Destination = $this.Destination
            PrefixLength = $this.PrefixLength
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        try {
            Write-VerboseLog -Message $this.CreateVMHostIPRouteMessage -Arguments @($this.Gateway, $this.Destination, $vmHost.Name)
            New-VMHostRoute @newVMHostRouteParams
        }
        catch {
            throw ($this.CouldNotCreateVMHostIPRouteMessage -f $this.Gateway, $this.Destination, $vmHost.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Removes the IP route with the specified Gateway and Destination addresses.
    #>
    [void] RemoveVMHostIPRoute($vmHostIPRoute) {
        $removeVMHostRouteParams = @{
            VMHostRoute = $vmHostIPRoute
            Confirm = $false
            ErrorAction = 'Stop'
            Verbose = $false
        }

        try {
            Write-VerboseLog -Message $this.RemoveVMHostIPRouteMessage -Arguments @($this.Gateway, $this.Destination, $this.Name)
            Remove-VMHostRoute @removeVMHostRouteParams
        }
        catch {
            throw ($this.CouldNotRemoveVMHostIPRouteMessage -f $this.Gateway, $this.Destination, $this.Name, $_.Exception.Message)
        }
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $vmHostIPRoute) {
        $result.Server = $this.Connection.Name
        $result.Name = $this.Name

        if ($null -ne $vmHostIPRoute) {
            $result.Ensure = [Ensure]::Present
            $result.Gateway = $vmHostIPRoute.Gateway
            $result.Destination = $vmHostIPRoute.Destination
            $result.PrefixLength = $vmHostIPRoute.PrefixLength
        }
        else {
            $result.Ensure = [Ensure]::Absent
            $result.Gateway = $this.Gateway
            $result.Destination = $this.Destination
            $result.PrefixLength = $this.PrefixLength
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
            $result.RestartTimeoutMinutes = $this.RestartTimeoutMinutes

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
            $result.RestartTimeoutMinutes = $this.RestartTimeoutMinutes

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
        $vssTest += ($null -eq $this.Mtu -or $vss.MTU -eq $this.MTU)

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

        $vssBridgeTest += !$this.ShouldUpdateArraySetting($vss.Spec.Bridge.NicDevice, $this.NicDevice)
        $vssBrdigeTest += ($null -eq $this.BeaconInterval -or $vss.Spec.Bridge.Beacon.Interval -eq $this.BeaconInterval)

        if ($this.LinkDiscoveryProtocolOperation -ne [LinkDiscoveryProtocolOperation]::Unset) {
            if ($null -eq $vss.Spec.Bridge.LinkDiscoveryProtocolConfig.Operation) { $vssBridgeTest += $false }
            else { $vssBridgeTest += ($vss.Spec.Bridge.LinkDiscoveryProtocolConfig.Operation.ToString() -eq $this.LinkDiscoveryProtocolOperation.ToString()) }
        }

        if ($this.LinkDiscoveryProtocolProtocol -ne [LinkDiscoveryProtocolProtocol]::Unset) {
            if ($null -eq $vss.Spec.Bridge.LinkDiscoveryProtocolConfig.Protocol) { $vssBridgeTest += $false }
            else { $vssBridgeTest += ($vss.Spec.Bridge.LinkDiscoveryProtocolConfig.Protocol.ToString() -eq $this.LinkDiscoveryProtocolProtocol.ToString()) }
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
        }

        # The Bridge configuration of the Standard Switch should be populated only when the Nic devices are passed.
        if ($this.NicDevice.Count -gt 0) {
            if ($null -ne $this.BeaconInterval) { $vssBridgeArgs.BeaconInterval = $this.BeaconInterval }
            if ($this.LinkDiscoveryProtocolProtocol -ne [LinkDiscoveryProtocolProtocol]::Unset) {
                $vssBridgeArgs.Add('LinkDiscoveryProtocolProtocol', $this.LinkDiscoveryProtocolProtocol.ToString())
                $vssBridgeArgs.Add('LinkDiscoveryProtocolOperation', $this.LinkDiscoveryProtocolOperation.ToSTring())
            }
        }

        $vss = $this.GetVss()

        if ($this.Ensure -eq 'Present') {
            if ($this.Equals($vss)) {
                return
            }
        }
        else {
            $vssBridgeArgs.NicDevice = @()
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
        $vssSecurityTest += ($null -eq $this.AllowPromiscuous -or $vss.Spec.Policy.Security.AllowPromiscuous -eq $this.AllowPromiscuous)
        $vssSecurityTest += ($null -eq $this.ForgedTransmits -or $vss.Spec.Policy.Security.ForgedTransmits -eq $this.ForgedTransmits)
        $vssSecurityTest += ($null -eq $this.MacChanges -or $vss.Spec.Policy.Security.MacChanges -eq $this.MacChanges)

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
        $vssShapingTest += ($null -eq $this.AverageBandwidth -or $vss.Spec.Policy.ShapingPolicy.AverageBandwidth -eq $this.AverageBandwidth)
        $vssShapingTest += ($null -eq $this.BurstSize -or $vss.Spec.Policy.ShapingPolicy.BurstSize -eq $this.BurstSize)
        $vssShapingTest += ($null -eq $this.Enabled -or $vss.Spec.Policy.ShapingPolicy.Enabled -eq $this.Enabled)
        $vssShapingTest += ($null -eq $this.PeakBandwidth -or $vss.Spec.Policy.ShapingPolicy.PeakBandwidth -eq $this.PeakBandwidth)

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
    [NicTeamingPolicy] $Policy = [NicTeamingPolicy]::Unset

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
        $vssTeamingTest += ($null -eq $this.CheckBeacon -or $vss.Spec.Policy.NicTeaming.FailureCriteria.CheckBeacon -eq $this.CheckBeacon)
        $vssTeamingTest += !$this.ShouldUpdateArraySetting($vss.Spec.Policy.NicTeaming.NicOrder.ActiveNic, $this.ActiveNic)
        $vssTeamingTest += !$this.ShouldUpdateArraySetting($vss.Spec.Policy.NicTeaming.NicOrder.StandbyNic, $this.StandbyNic)
        $vssTeamingTest += ($null -eq $this.NotifySwitches -or $vss.Spec.Policy.NicTeaming.NotifySwitches -eq $this.NotifySwitches)
        $vssTeamingTest += ($null -eq $this.RollingOrder -or $vss.Spec.Policy.NicTeaming.RollingOrder -eq $this.RollingOrder)

        # The Network Adapter teaming policy should determine the Desired State only when it is specified.
        if ($this.Policy -ne [NicTeamingPolicy]::Unset) { $vssTeamingTest += ($vss.Spec.Policy.NicTeaming.Policy -eq $this.Policy.ToString().ToLower()) }

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
            ActiveNic = $this.ActiveNic
            StandbyNic = $this.StandbyNic
            NotifySwitches = $this.NotifySwitches
            RollingOrder = $this.RollingOrder
        }

        if ($null -ne $this.CheckBeacon) { $vssTeamingArgs.CheckBeacon = $this.CheckBeacon }
        if ($this.Policy -ne [NicTeamingPolicy]::Unset) { $vssTeamingArgs.Policy = $this.Policy.ToString().ToLower() }

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

        # High Availability settings cannot be passed to the cmdlets if 'HAEnabled' is $false.
        if ($null -eq $this.HAEnabled -or $this.HAEnabled) {
            $this.PopulateClusterParams($clusterParams, $this.HAAdmissionControlEnabledParameterName, $this.HAAdmissionControlEnabled)
            $this.PopulateClusterParams($clusterParams, $this.HAFailoverLevelParameterName, $this.HAFailoverLevel)
            $this.PopulateClusterParams($clusterParams, $this.HAIsolationResponseParameterName, $this.HAIsolationResponse)
            $this.PopulateClusterParams($clusterParams, $this.HARestartPriorityParemeterName, $this.HARestartPriority)
        }

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
