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
