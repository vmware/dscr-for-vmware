<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

Param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Server,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $User,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Password,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Name
)

<#
Retrieves the name and the location of the Datacenter where the specified VMHost is located.
Retrieves one connected Physical Network Adapter and two disconnected Physical Network Adapters from the specified VMHost.
The connected Physical Network Adapter should not be part of a Standard Switch which has VMKernel Network Adapter that has
Management Traffic enabled.
If the criteria is not met, it throws an exception.
#>
function Invoke-TestSetup {
    # Data that is going to be passed as Configuration Data in the Integration Tests.
    $script:datacenterName = $null
    $script:datacenterLocation = $null
    $script:physicalNetworkAdapters = @()
    $script:virtualSwitchesWithPhysicalNics = @{}

    $viServer = Connect-VIServer -Server $Server -User $User -Password $Password -ErrorAction Stop
    $vmHost = Get-VMHost -Server $viServer -Name $Name -ErrorAction Stop
    $networkSystem = Get-View -Server $viServer -Id $vmHost.ExtensionData.ConfigManager.NetworkSystem -ErrorAction Stop
    $datacenter = Get-Datacenter -Server $viServer -VMHost $vmHost -ErrorAction Stop

    $script:datacenterName = $datacenter.Name

    # If the Parent of the Parent Folder is $null, the Datacenter is located in the Root Folder of the Inventory.
    if ($null -eq $datacenter.ParentFolder.Parent) {
        $script:datacenterLocation = [string]::Empty
    }
    else {
        $locationItems = @()
        $child = $datacenter.ParentFolder
        $parent = $datacenter.ParentFolder.Parent

        while ($true) {
            if ($null -eq $parent) {
                break
            }

            $locationItems += $child.Name
            $child = $parent
            $parent = $parent.Parent
        }

        # The Parent Folder of the Datacenter should be the last item in the array.
        [array]::Reverse($locationItems)

        # Folder names for Datacenter Location should be separated by '/'.
        $script:datacenterLocation = [string]::Join('/', $locationItems)
    }

    $disconnectedPhysicalNetworkAdapters = Get-VMHostNetworkAdapter -Server $viServer -VMHost $vmHost -Physical -ErrorAction Stop |
                                           Where-Object -FilterScript { $_.BitRatePerSec -eq 0 } |
                                           Select-Object -First 2
    if ($disconnectedPhysicalNetworkAdapters.Length -lt 2) {
        throw 'The Integration Tests require at least two disconnected Physical Network Adapters to be available on the ESXi node.'
    }

    $script:physicalNetworkAdapters += $disconnectedPhysicalNetworkAdapters[0].Name
    $script:physicalNetworkAdapters += $disconnectedPhysicalNetworkAdapters[1].Name

    <#
    Store the initial Standard Switches for every Physical Network Adapter in the Virtual Switches hashtable, so
    a migration can be performed after the Tests have executed. The Physical Network Adapter will be added again to
    their initial Standard Switches.
    #>
    foreach ($physicalNetworkAdapter in $disconnectedPhysicalNetworkAdapters) {
        $virtualSwitch = Get-VirtualSwitch -Server $viServer -VMHost $vmHost -ErrorAction Stop | Where-Object { $null -ne $_.Nic -and $_.Nic.Contains($physicalNetworkAdapter.Name) }
        if ($null -eq $virtualSwitch) {
            continue
        }

        $virtualSwitchName = $virtualSwitch.Name
        $virtualSwitchNicTeamingPolicy = $networkSystem.NetworkConfig.Vswitch |
                                         Where-Object { $_.Name -eq $virtualSwitch.Name } |
                                         Select-Object -ExpandProperty Spec |
                                         Select-Object -ExpandProperty Policy |
                                         Select-Object -ExpandProperty NicTeaming

        $script:virtualSwitchesWithPhysicalNics.$virtualSwitchName = @{
            Nic = $virtualSwitch.Nic
            ActiveNic = $virtualSwitchNicTeamingPolicy.NicOrder.ActiveNic
            StandbyNic = $virtualSwitchNicTeamingPolicy.NicOrder.StandbyNic
            CheckBeacon = $virtualSwitchNicTeamingPolicy.FailureCriteria.CheckBeacon
            NotifySwitches = $virtualSwitchNicTeamingPolicy.NotifySwitches
            Policy = $virtualSwitchNicTeamingPolicy.Policy
            RollingOrder = $virtualSwitchNicTeamingPolicy.RollingOrder
        }
    }

    $connectedPhysicalNetworkAdapters = Get-VMHostNetworkAdapter -Server $viServer -VMHost $vmHost -Physical -ErrorAction Stop |
                                        Where-Object -FilterScript { $_.BitRatePerSec -ne 0 }
    if ($connectedPhysicalNetworkAdapters.Length -lt 1) {
        throw 'The Integration Tests require at least one connected Physical Network Adapter to be available on the ESXi node.'
    }

    <#
    Here we retrieve the names of the Port Groups to which VMKernel Network Adapters with Management Traffic enabled are connected.
    #>
    $portGroupNamesOfVMKernelsWithManagementTrafficEnabled = Get-VMHostNetworkAdapter -Server $viServer -VMHost $vmHost -VMKernel -ErrorAction Stop |
                                                             Where-Object { $_.ManagementTrafficEnabled } |
                                                             Select-Object -ExpandProperty PortGroupName

    <#
    For connected Physical Network Adapters, we need to retrieve only one of them that meets the following criteria:
    The Physical Network Adapter should not be part of a Standard Switch or the Physical Network Adapter is part of a Standard Switch
    that does not have a VMKernel Network Adapter that has Management Traffic enabled.
    #>
    foreach ($physicalNetworkAdapter in $connectedPhysicalNetworkAdapters) {
        $virtualSwitch = Get-VirtualSwitch -Server $viServer -VMHost $vmHost -ErrorAction Stop | Where-Object { $null -ne $_.Nic -and $_.Nic.Contains($physicalNetworkAdapter.Name) }
        if ($null -eq $virtualSwitch) {
            $script:physicalNetworkAdapters += $physicalNetworkAdapter.Name
            break
        }

        $virtualPortGroups = Get-VirtualPortGroup -Server $viServer -VMHost $vmHost -VirtualSwitch $virtualSwitch -ErrorAction Stop |
                             Where-Object { $_.VirtualSwitchName -eq $virtualSwitch.Name -and $portGroupNamesOfVMKernelsWithManagementTrafficEnabled.Contains($_.Name) }
        if ($virtualPortGroups.Length -gt 0) {
            continue
        }
        else {
            $script:physicalNetworkAdapters += $physicalNetworkAdapter.Name
            $virtualSwitchName = $virtualSwitch.Name
            $virtualSwitchNicTeamingPolicy = $networkSystem.NetworkConfig.Vswitch |
                                         Where-Object { $_.Name -eq $virtualSwitch.Name } |
                                         Select-Object -ExpandProperty Spec |
                                         Select-Object -ExpandProperty Policy |
                                         Select-Object -ExpandProperty NicTeaming

            $script:virtualSwitchesWithPhysicalNics.$virtualSwitchName = @{
                Nic = $virtualSwitch.Nic
                ActiveNic = $virtualSwitchNicTeamingPolicy.NicOrder.ActiveNic
                StandbyNic = $virtualSwitchNicTeamingPolicy.NicOrder.StandbyNic
                CheckBeacon = $virtualSwitchNicTeamingPolicy.FailureCriteria.CheckBeacon
                NotifySwitches = $virtualSwitchNicTeamingPolicy.NotifySwitches
                Policy = $virtualSwitchNicTeamingPolicy.Policy
                RollingOrder = $virtualSwitchNicTeamingPolicy.RollingOrder
            }

            break
        }
    }

    Disconnect-VIServer -Server $Server -Confirm:$false
}

function Add-PhysicalNetworkAdaptersToStandardSwitch {
    [CmdletBinding()]

    $standardSwitchName = $script:configurationData.AllNodes.StandardSwitchName
    $physicalNetworkAdapterNames = $script:configurationData.AllNodes.PhysicalNetworkAdapterNames

    $viServer = Connect-VIServer -Server $Server -User $User -Password $Password -ErrorAction Stop
    $vmHost = Get-VMHost -Server $viServer -Name $Name -ErrorAction Stop
    $standardSwitch = Get-VirtualSwitch -Server $viServer -VMHost $vmHost -Name $standardSwitchName -ErrorAction Stop

    $physicalNetworkAdapters = @()
    foreach ($physicalNetworkAdapterName in $physicalNetworkAdapterNames) {
        $physicalNetworkAdapter = Get-VMHostNetworkAdapter -Server $viServer -VMHost $vmHost -Name $physicalNetworkAdapterName -Physical -ErrorAction Stop
        $physicalNetworkAdapters += $physicalNetworkAdapter
    }

    Add-VirtualSwitchPhysicalNetworkAdapter -Server $viServer -VirtualSwitch $standardSwitch -VMHostPhysicalNic $physicalNetworkAdapters -Confirm:$false -ErrorAction Stop

    Disconnect-VIServer -Server $Server -Confirm:$false
}

function Get-VMKernelNetworkAdapterNames {
    [CmdletBinding()]

    $standardSwitchName = $script:configurationData.AllNodes.StandardSwitchName
    $managementPortGroupName = $script:configurationData.AllNodes.ManagementPortGroupName
    $vMotionPortGroupName = $script:configurationData.AllNodes.VMotionPortGroupName

    $viServer = Connect-VIServer -Server $Server -User $User -Password $Password -ErrorAction Stop
    $vmHost = Get-VMHost -Server $viServer -Name $Name -ErrorAction Stop
    $standardSwitch = Get-VirtualSwitch -Server $viServer -VMHost $vmHost -Name $standardSwitchName -ErrorAction Stop
    $managementPortGroup = Get-VirtualPortGroup -Server $viServer -VMHost $vmHost -Name $managementPortGroupName -ErrorAction Stop
    $vMotionPortGroup = Get-VirtualPortGroup -Server $viServer -VMHost $vmHost -Name $vMotionPortGroupName -ErrorAction Stop

    $vmKernelNetworkAdapterWithManagementTrafficEnabled = Get-VMHostNetworkAdapter -Server $viServer -VMHost $vmHost -VirtualSwitch $standardSwitch -PortGroup $managementPortGroup -VMKernel -ErrorAction Stop
    $vmKernelNetworkAdapterWithvMotionEnabled = Get-VMHostNetworkAdapter -Server $viServer -VMHost $vmHost -VirtualSwitch $standardSwitch -PortGroup $vMotionPortGroup -VMKernel -ErrorAction Stop

    # Here we need to modify the Configuration Data passed to each Configuration to include the retrieved VMKernel Network Adapter names.
    $script:configurationData.AllNodes[0].VMKernelNetworkAdapterNames = @($vmKernelNetworkAdapterWithManagementTrafficEnabled.Name, $vmKernelNetworkAdapterWithvMotionEnabled.Name)

    Disconnect-VIServer -Server $Server -Confirm:$false
}

Invoke-TestSetup

$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (ConvertTo-SecureString -String $Password -AsPlainText -Force)

$script:dscResourceName = 'VMHostVDSwitchMigration'
$script:moduleFolderPath = (Get-Module -Name 'VMware.vSphereDSC' -ListAvailable).ModuleBase
$script:integrationTestsFolderPath = Join-Path -Path (Join-Path -Path $moduleFolderPath -ChildPath 'Tests') -ChildPath 'Integration'
$script:configurationFile = "$script:integrationTestsFolderPath\Configurations\$script:dscResourceName\$($script:dscResourceName)_Config.ps1"

$script:configurationData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
            Server = $Server
            Credential = $Credential
            VMHostName = $Name
            VMHostVssResourceName = 'VMHostVss'
            VMHostVssResourceId = '[VMHostVss]VMHostVss'
            VMHostVssPortGroupResourceName = 'VMHostVssPortGroup'
            VMHostVssPortGroupResourceId = '[VMHostVssPortGroup]VMHostVssPortGroup'
            VDSwitchResourceName = 'VDSwitch'
            VDSwitchResourceId = '[VDSwitch]VDSwitch'
            VDSwitchVMHostResourceName = 'VDSwitchVMHost'
            VMHostVDSwitchMigrationResourceName = 'VMHostVDSwitchMigration'
            VMHostVssBridgeResourceName = 'VMHostVssBridge'
            VMHostVssTeamingResourceName = 'VMHostVssTeaming'
            VMHostVssManagementNicResourceName = 'VMHostVssManagementNic'
            VMHostVssvMotionNicResourceName = 'VMHostVssvMotionNic'
            VMHostVdsNicResourceName = 'VMHostVdsNic'
            VMHostVdsManagementNicResourceName = 'VMHostVdsManagementNic'
            VMHostVdsvMotionNicResourceName = 'VMHostVdsvMotionNic'
            StandardSwitchName = 'MyTestStandardSwitch'
            VDSwitchName = 'MyTestVDSwitch'
            VDSwitchLocation = [string]::Empty
            DatacenterName = $script:datacenterName
            DatacenterLocation = $script:datacenterLocation
            PhysicalNetworkAdapterNames = $script:physicalNetworkAdapters
            VirtualSwitches = $script:virtualSwitchesWithPhysicalNics
            LinkDiscoveryProtocolOperation = 'Listen'
            LinkDiscoveryProtocolProtocol = 'CDP'
            PortGroupName = 'Management Network'
            ManagementPortGroupName = 'MyManagementPortGroup'
            VMotionPortGroupName = 'MyvMotionPortGroup'
            ManagementTrafficEnabled = $true
            VMotionEnabled = $true
        }
    )
}

$script:configCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitch = "$($script:dscResourceName)_CreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitch_Config"
$script:configCreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapter = "$($script:dscResourceName)_CreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapter_Config"
$script:configMigrateOneDisconnectedPhysicalNetworkAdapter = "$($script:dscResourceName)_MigrateOneDisconnectedPhysicalNetworkAdapter_Config"
$script:configMigrateTwoDisconnectedPhysicalNetworkAdapters = "$($script:dscResourceName)_MigrateTwoDisconnectedPhysicalNetworkAdapters_Config"
$script:configMigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdapters = "$($script:dscResourceName)_MigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdapters_Config"
$script:configMigrateOneDisconnectedPhysicalNetworkAdapterTwoVMKernelNetworkAdaptersAndOnePortGroup = "$($script:dscResourceName)_MigrateOneDisconnectedPhysicalNetworkAdapterTwoVMKernelNetworkAdaptersAndOnePortGroup_Config"
$script:configMigrateOneDisconnectedPhysicalNetworkAdapterTwoVMKernelNetworkAdaptersAndTwoPortGroups = "$($script:dscResourceName)_MigrateOneDisconnectedPhysicalNetworkAdapterTwoVMKernelNetworkAdaptersAndTwoPortGroups_Config"
$script:configMigrateTwoDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndOnePortGroup = "$($script:dscResourceName)_MigrateTwoDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndOnePortGroup_Config"
$script:configMigrateTwoDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndTwoPortGroups = "$($script:dscResourceName)_MigrateTwoDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndTwoPortGroups_Config"
$script:configMigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndOnePortGroup = "$($script:dscResourceName)_MigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndOnePortGroup_Config"
$script:configMigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndTwoPortGroups = "$($script:dscResourceName)_MigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndTwoPortGroups_Config"
$script:configRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToTheSamePortGroup = "$($script:dscResourceName)_RemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToTheSamePortGroup_Config"
$script:configRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToDifferentPortGroups = "$($script:dscResourceName)_RemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToDifferentPortGroups_Config"
$script:configRemoveVDSwitchStandardSwitchAndStandardPortGroup = "$($script:dscResourceName)_RemoveVDSwitchStandardSwitchAndStandardPortGroup_Config"
$script:configMigratePhysicalNetworkAdaptersToInitialVirtualSwitches = "$($script:dscResourceName)_MigratePhysicalNetworkAdaptersToInitialVirtualSwitches_Config"

. $script:configurationFile -ErrorAction Stop

$script:mofFileCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitchPath = "$script:integrationTestsFolderPath\$script:configCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitch\"
$script:mofFileCreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterPath = "$script:integrationTestsFolderPath\$script:configCreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapter\"
$script:mofFileMigrateOneDisconnectedPhysicalNetworkAdapterPath = "$script:integrationTestsFolderPath\$script:configMigrateOneDisconnectedPhysicalNetworkAdapter\"
$script:mofFileMigrateTwoDisconnectedPhysicalNetworkAdaptersPath = "$script:integrationTestsFolderPath\$script:configMigrateTwoDisconnectedPhysicalNetworkAdapters\"
$script:mofFileMigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdaptersPath = "$script:integrationTestsFolderPath\$script:configMigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdapters\"
$script:mofFileMigrateOneDisconnectedPhysicalNetworkAdapterTwoVMKernelNetworkAdaptersAndOnePortGroupPath = "$script:integrationTestsFolderPath\$script:configMigrateOneDisconnectedPhysicalNetworkAdapterTwoVMKernelNetworkAdaptersAndOnePortGroup\"
$script:mofFileMigrateOneDisconnectedPhysicalNetworkAdapterTwoVMKernelNetworkAdaptersAndTwoPortGroupsPath = "$script:integrationTestsFolderPath\$script:configMigrateOneDisconnectedPhysicalNetworkAdapterTwoVMKernelNetworkAdaptersAndTwoPortGroups\"
$script:mofFileMigrateTwoDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndOnePortGroupPath = "$script:integrationTestsFolderPath\$script:configMigrateTwoDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndOnePortGroup\"
$script:mofFileMigrateTwoDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndTwoPortGroupsPath = "$script:integrationTestsFolderPath\$script:configMigrateTwoDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndTwoPortGroups\"
$script:mofFileMigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndOnePortGroupPath = "$script:integrationTestsFolderPath\$script:configMigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndOnePortGroup\"
$script:mofFileMigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndTwoPortGroupsPath = "$script:integrationTestsFolderPath\$script:configMigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndTwoPortGroups\"
$script:mofFileRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToTheSamePortGroupPath = "$script:integrationTestsFolderPath\$script:configRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToTheSamePortGroup\"
$script:mofFileRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToDifferentPortGroupsPath = "$script:integrationTestsFolderPath\$script:configRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToDifferentPortGroups\"
$script:mofFileRemoveVDSwitchStandardSwitchAndStandardPortGroupPath = "$script:integrationTestsFolderPath\$script:configRemoveVDSwitchStandardSwitchAndStandardPortGroup\"
$script:mofFileMigratePhysicalNetworkAdaptersToInitialVirtualSwitchesPath = "$script:integrationTestsFolderPath\$script:configMigratePhysicalNetworkAdaptersToInitialVirtualSwitches\"

Describe "$($script:dscResourceName)_Integration" {
    Context "When using configuration $script:configMigrateOneDisconnectedPhysicalNetworkAdapter" {
        BeforeAll {
            # Arrange
            & $script:configCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitch `
                -OutputPath $script:mofFileCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configMigrateOneDisconnectedPhysicalNetworkAdapter `
                -OutputPath $script:mofFileMigrateOneDisconnectedPhysicalNetworkAdapterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitch = @{
                Path = $script:mofFileCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersMigrateOneDisconnectedPhysicalNetworkAdapter = @{
                Path = $script:mofFileMigrateOneDisconnectedPhysicalNetworkAdapterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitch

            # TODO: Replace with DSC Resource that migrates Physical Network Adapters to the specified Standard Switch.
            Add-PhysicalNetworkAdaptersToStandardSwitch

            Start-DscConfiguration @startDscConfigurationParametersMigrateOneDisconnectedPhysicalNetworkAdapter
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileMigrateOneDisconnectedPhysicalNetworkAdapterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            # Arrange && Act && Assert
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration and all parameters should match' {
            # Arrange && Act
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configMigrateOneDisconnectedPhysicalNetworkAdapter }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.VdsName | Should -Be $script:configurationData.AllNodes.VDSwitchName
            $configuration.PhysicalNicNames | Should -Be $script:configurationData.AllNodes.PhysicalNetworkAdapterNames[0]
            $configuration.VMKernelNicNames | Should -Be @()
            $configuration.PortGroupNames | Should -Be @()
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileMigrateOneDisconnectedPhysicalNetworkAdapterPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configRemoveVDSwitchStandardSwitchAndStandardPortGroup `
                -OutputPath $script:mofFileRemoveVDSwitchStandardSwitchAndStandardPortGroupPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configMigratePhysicalNetworkAdaptersToInitialVirtualSwitches `
                -OutputPath $script:mofFileMigratePhysicalNetworkAdaptersToInitialVirtualSwitchesPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersRemoveVDSwitchStandardSwitchAndStandardPortGroup = @{
                Path = $script:mofFileRemoveVDSwitchStandardSwitchAndStandardPortGroupPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersMigratePhysicalNetworkAdaptersToInitialVirtualSwitches = @{
                Path = $script:mofFileMigratePhysicalNetworkAdaptersToInitialVirtualSwitchesPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersRemoveVDSwitchStandardSwitchAndStandardPortGroup
            Start-DscConfiguration @startDscConfigurationParametersMigratePhysicalNetworkAdaptersToInitialVirtualSwitches

            Remove-Item -Path $script:mofFileCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileMigrateOneDisconnectedPhysicalNetworkAdapterPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVDSwitchStandardSwitchAndStandardPortGroupPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileMigratePhysicalNetworkAdaptersToInitialVirtualSwitchesPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configMigrateTwoDisconnectedPhysicalNetworkAdapters" {
        BeforeAll {
            # Arrange
            & $script:configCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitch `
                -OutputPath $script:mofFileCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configMigrateTwoDisconnectedPhysicalNetworkAdapters `
                -OutputPath $script:mofFileMigrateTwoDisconnectedPhysicalNetworkAdaptersPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitch = @{
                Path = $script:mofFileCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersMigrateTwoDisconnectedPhysicalNetworkAdapters = @{
                Path = $script:mofFileMigrateTwoDisconnectedPhysicalNetworkAdaptersPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitch

            # TODO: Replace with DSC Resource that migrates Physical Network Adapters to the specified Standard Switch.
            Add-PhysicalNetworkAdaptersToStandardSwitch

            Start-DscConfiguration @startDscConfigurationParametersMigrateTwoDisconnectedPhysicalNetworkAdapters
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileMigrateTwoDisconnectedPhysicalNetworkAdaptersPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            # Arrange && Act && Assert
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration and all parameters should match' {
            # Arrange && Act
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configMigrateTwoDisconnectedPhysicalNetworkAdapters }

            # Assert
            # The Physical Network Adapters for a Distributed Switch are sorted by name on the Server.
            $expectedPhysicalNetworkAdapterNames = @(
                $script:configurationData.AllNodes.PhysicalNetworkAdapterNames[0],
                $script:configurationData.AllNodes.PhysicalNetworkAdapterNames[1]
            ) | Sort-Object

            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.VdsName | Should -Be $script:configurationData.AllNodes.VDSwitchName
            $configuration.PhysicalNicNames | Should -Be $expectedPhysicalNetworkAdapterNames
            $configuration.VMKernelNicNames | Should -Be @()
            $configuration.PortGroupNames | Should -Be @()
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileMigrateTwoDisconnectedPhysicalNetworkAdaptersPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configRemoveVDSwitchStandardSwitchAndStandardPortGroup `
                -OutputPath $script:mofFileRemoveVDSwitchStandardSwitchAndStandardPortGroupPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configMigratePhysicalNetworkAdaptersToInitialVirtualSwitches `
                -OutputPath $script:mofFileMigratePhysicalNetworkAdaptersToInitialVirtualSwitchesPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersRemoveVDSwitchStandardSwitchAndStandardPortGroup = @{
                Path = $script:mofFileRemoveVDSwitchStandardSwitchAndStandardPortGroupPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersMigratePhysicalNetworkAdaptersToInitialVirtualSwitches = @{
                Path = $script:mofFileMigratePhysicalNetworkAdaptersToInitialVirtualSwitchesPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersRemoveVDSwitchStandardSwitchAndStandardPortGroup
            Start-DscConfiguration @startDscConfigurationParametersMigratePhysicalNetworkAdaptersToInitialVirtualSwitches

            Remove-Item -Path $script:mofFileCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileMigrateTwoDisconnectedPhysicalNetworkAdaptersPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVDSwitchStandardSwitchAndStandardPortGroupPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileMigratePhysicalNetworkAdaptersToInitialVirtualSwitchesPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configMigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdapters" {
        BeforeAll {
            # Arrange
            & $script:configCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitch `
                -OutputPath $script:mofFileCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configMigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdapters `
                -OutputPath $script:mofFileMigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdaptersPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitch = @{
                Path = $script:mofFileCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersMigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdapters = @{
                Path = $script:mofFileMigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdaptersPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitch

            # TODO: Replace with DSC Resource that migrates Physical Network Adapters to the specified Standard Switch.
            Add-PhysicalNetworkAdaptersToStandardSwitch

            Start-DscConfiguration @startDscConfigurationParametersMigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdapters
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileMigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdaptersPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            # Arrange && Act && Assert
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration and all parameters should match' {
            # Arrange && Act
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configMigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdapters }

            # Assert
            # The Physical Network Adapters for a Distributed Switch are sorted by name on the Server.
            $expectedPhysicalNetworkAdapterNames = $script:configurationData.AllNodes.PhysicalNetworkAdapterNames | Sort-Object

            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.VdsName | Should -Be $script:configurationData.AllNodes.VDSwitchName
            $configuration.PhysicalNicNames | Should -Be $expectedPhysicalNetworkAdapterNames
            $configuration.VMKernelNicNames | Should -Be @()
            $configuration.PortGroupNames | Should -Be @()
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileMigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdaptersPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configRemoveVDSwitchStandardSwitchAndStandardPortGroup `
                -OutputPath $script:mofFileRemoveVDSwitchStandardSwitchAndStandardPortGroupPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configMigratePhysicalNetworkAdaptersToInitialVirtualSwitches `
                -OutputPath $script:mofFileMigratePhysicalNetworkAdaptersToInitialVirtualSwitchesPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersRemoveVDSwitchStandardSwitchAndStandardPortGroup = @{
                Path = $script:mofFileRemoveVDSwitchStandardSwitchAndStandardPortGroupPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersMigratePhysicalNetworkAdaptersToInitialVirtualSwitches = @{
                Path = $script:mofFileMigratePhysicalNetworkAdaptersToInitialVirtualSwitchesPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersRemoveVDSwitchStandardSwitchAndStandardPortGroup
            Start-DscConfiguration @startDscConfigurationParametersMigratePhysicalNetworkAdaptersToInitialVirtualSwitches

            Remove-Item -Path $script:mofFileCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileMigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdaptersPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVDSwitchStandardSwitchAndStandardPortGroupPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileMigratePhysicalNetworkAdaptersToInitialVirtualSwitchesPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configMigrateOneDisconnectedPhysicalNetworkAdapterTwoVMKernelNetworkAdaptersAndOnePortGroup" {
        BeforeAll {
            # Arrange
            & $script:configCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitch `
                -OutputPath $script:mofFileCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configCreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapter `
                -OutputPath $script:mofFileCreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitch = @{
                Path = $script:mofFileCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersCreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapter = @{
                Path = $script:mofFileCreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitch
            Start-DscConfiguration @startDscConfigurationParametersCreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapter

            # TODO: Replace with DSC Resource that migrates Physical Network Adapters to the specified Standard Switch.
            Add-PhysicalNetworkAdaptersToStandardSwitch

            Get-VMKernelNetworkAdapterNames

            & $script:configMigrateOneDisconnectedPhysicalNetworkAdapterTwoVMKernelNetworkAdaptersAndOnePortGroup `
                -OutputPath $script:mofFileMigrateOneDisconnectedPhysicalNetworkAdapterTwoVMKernelNetworkAdaptersAndOnePortGroupPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersMigrateOneDisconnectedPhysicalNetworkAdapterTwoVMKernelNetworkAdaptersAndOnePortGroup = @{
                Path = $script:mofFileMigrateOneDisconnectedPhysicalNetworkAdapterTwoVMKernelNetworkAdaptersAndOnePortGroupPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            Start-DscConfiguration @startDscConfigurationParametersMigrateOneDisconnectedPhysicalNetworkAdapterTwoVMKernelNetworkAdaptersAndOnePortGroup
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileMigrateOneDisconnectedPhysicalNetworkAdapterTwoVMKernelNetworkAdaptersAndOnePortGroupPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            # Arrange && Act && Assert
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration and all parameters should match' {
            # Arrange && Act
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configMigrateOneDisconnectedPhysicalNetworkAdapterTwoVMKernelNetworkAdaptersAndOnePortGroup }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.VdsName | Should -Be $script:configurationData.AllNodes.VDSwitchName
            $configuration.PhysicalNicNames | Should -Be @($script:configurationData.AllNodes.PhysicalNetworkAdapterNames[0])
            $configuration.VMKernelNicNames | Should -Be $script:configurationData.AllNodes.VMKernelNetworkAdapterNames
            $configuration.PortGroupNames | Should -Be @($script:configurationData.AllNodes.PortGroupName, $script:configurationData.AllNodes.PortGroupName)
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileMigrateOneDisconnectedPhysicalNetworkAdapterTwoVMKernelNetworkAdaptersAndOnePortGroupPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToTheSamePortGroup `
                -OutputPath $script:mofFileRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToTheSamePortGroupPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configRemoveVDSwitchStandardSwitchAndStandardPortGroup `
                -OutputPath $script:mofFileRemoveVDSwitchStandardSwitchAndStandardPortGroupPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configMigratePhysicalNetworkAdaptersToInitialVirtualSwitches `
                -OutputPath $script:mofFileMigratePhysicalNetworkAdaptersToInitialVirtualSwitchesPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToTheSamePortGroup = @{
                Path = $script:mofFileRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToTheSamePortGroupPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersRemoveVDSwitchStandardSwitchAndStandardPortGroup = @{
                Path = $script:mofFileRemoveVDSwitchStandardSwitchAndStandardPortGroupPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersMigratePhysicalNetworkAdaptersToInitialVirtualSwitches = @{
                Path = $script:mofFileMigratePhysicalNetworkAdaptersToInitialVirtualSwitchesPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToTheSamePortGroup
            Start-DscConfiguration @startDscConfigurationParametersRemoveVDSwitchStandardSwitchAndStandardPortGroup
            Start-DscConfiguration @startDscConfigurationParametersMigratePhysicalNetworkAdaptersToInitialVirtualSwitches

            Remove-Item -Path $script:mofFileCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileCreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileMigrateOneDisconnectedPhysicalNetworkAdapterTwoVMKernelNetworkAdaptersAndOnePortGroupPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToTheSamePortGroupPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVDSwitchStandardSwitchAndStandardPortGroupPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileMigratePhysicalNetworkAdaptersToInitialVirtualSwitchesPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configMigrateOneDisconnectedPhysicalNetworkAdapterTwoVMKernelNetworkAdaptersAndTwoPortGroups" {
        BeforeAll {
            # Arrange
            & $script:configCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitch `
                -OutputPath $script:mofFileCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configCreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapter `
                -OutputPath $script:mofFileCreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitch = @{
                Path = $script:mofFileCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersCreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapter = @{
                Path = $script:mofFileCreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitch
            Start-DscConfiguration @startDscConfigurationParametersCreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapter

            # TODO: Replace with DSC Resource that migrates Physical Network Adapters to the specified Standard Switch.
            Add-PhysicalNetworkAdaptersToStandardSwitch

            Get-VMKernelNetworkAdapterNames

            & $script:configMigrateOneDisconnectedPhysicalNetworkAdapterTwoVMKernelNetworkAdaptersAndTwoPortGroups `
                -OutputPath $script:mofFileMigrateOneDisconnectedPhysicalNetworkAdapterTwoVMKernelNetworkAdaptersAndTwoPortGroupsPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersMigrateOneDisconnectedPhysicalNetworkAdapterTwoVMKernelNetworkAdaptersAndTwoPortGroups = @{
                Path = $script:mofFileMigrateOneDisconnectedPhysicalNetworkAdapterTwoVMKernelNetworkAdaptersAndTwoPortGroupsPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            Start-DscConfiguration @startDscConfigurationParametersMigrateOneDisconnectedPhysicalNetworkAdapterTwoVMKernelNetworkAdaptersAndTwoPortGroups
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileMigrateOneDisconnectedPhysicalNetworkAdapterTwoVMKernelNetworkAdaptersAndTwoPortGroupsPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            # Arrange && Act && Assert
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration and all parameters should match' {
            # Arrange && Act
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configMigrateOneDisconnectedPhysicalNetworkAdapterTwoVMKernelNetworkAdaptersAndTwoPortGroups }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.VdsName | Should -Be $script:configurationData.AllNodes.VDSwitchName
            $configuration.PhysicalNicNames | Should -Be @($script:configurationData.AllNodes.PhysicalNetworkAdapterNames[0])
            $configuration.VMKernelNicNames | Should -Be $script:configurationData.AllNodes.VMKernelNetworkAdapterNames
            $configuration.PortGroupNames | Should -Be @($script:configurationData.AllNodes.ManagementPortGroupName, $script:configurationData.AllNodes.VMotionPortGroupName)
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileMigrateOneDisconnectedPhysicalNetworkAdapterTwoVMKernelNetworkAdaptersAndTwoPortGroupsPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToDifferentPortGroups `
                -OutputPath $script:mofFileRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToDifferentPortGroupsPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configRemoveVDSwitchStandardSwitchAndStandardPortGroup `
                -OutputPath $script:mofFileRemoveVDSwitchStandardSwitchAndStandardPortGroupPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configMigratePhysicalNetworkAdaptersToInitialVirtualSwitches `
                -OutputPath $script:mofFileMigratePhysicalNetworkAdaptersToInitialVirtualSwitchesPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToDifferentPortGroups = @{
                Path = $script:mofFileRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToDifferentPortGroupsPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersRemoveVDSwitchStandardSwitchAndStandardPortGroup = @{
                Path = $script:mofFileRemoveVDSwitchStandardSwitchAndStandardPortGroupPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersMigratePhysicalNetworkAdaptersToInitialVirtualSwitches = @{
                Path = $script:mofFileMigratePhysicalNetworkAdaptersToInitialVirtualSwitchesPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToDifferentPortGroups
            Start-DscConfiguration @startDscConfigurationParametersRemoveVDSwitchStandardSwitchAndStandardPortGroup
            Start-DscConfiguration @startDscConfigurationParametersMigratePhysicalNetworkAdaptersToInitialVirtualSwitches

            Remove-Item -Path $script:mofFileCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileCreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileMigrateOneDisconnectedPhysicalNetworkAdapterTwoVMKernelNetworkAdaptersAndTwoPortGroupsPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToDifferentPortGroupsPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVDSwitchStandardSwitchAndStandardPortGroupPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileMigratePhysicalNetworkAdaptersToInitialVirtualSwitchesPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configMigrateTwoDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndOnePortGroup" {
        BeforeAll {
            # Arrange
            & $script:configCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitch `
                -OutputPath $script:mofFileCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configCreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapter `
                -OutputPath $script:mofFileCreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitch = @{
                Path = $script:mofFileCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersCreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapter = @{
                Path = $script:mofFileCreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitch
            Start-DscConfiguration @startDscConfigurationParametersCreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapter

            # TODO: Replace with DSC Resource that migrates Physical Network Adapters to the specified Standard Switch.
            Add-PhysicalNetworkAdaptersToStandardSwitch

            Get-VMKernelNetworkAdapterNames

            & $script:configMigrateTwoDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndOnePortGroup `
                -OutputPath $script:mofFileMigrateTwoDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndOnePortGroupPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersMigrateTwoDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndOnePortGroup = @{
                Path = $script:mofFileMigrateTwoDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndOnePortGroupPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            Start-DscConfiguration @startDscConfigurationParametersMigrateTwoDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndOnePortGroup
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileMigrateTwoDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndOnePortGroupPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            # Arrange && Act && Assert
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration and all parameters should match' {
            # Arrange && Act
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configMigrateTwoDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndOnePortGroup }

            # Assert
            # The Physical Network Adapters for a Distributed Switch are sorted by name on the Server.
            $expectedPhysicalNetworkAdapterNames = @(
                $script:configurationData.AllNodes.PhysicalNetworkAdapterNames[0],
                $script:configurationData.AllNodes.PhysicalNetworkAdapterNames[1]
            ) | Sort-Object

            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.VdsName | Should -Be $script:configurationData.AllNodes.VDSwitchName
            $configuration.PhysicalNicNames | Should -Be $expectedPhysicalNetworkAdapterNames
            $configuration.VMKernelNicNames | Should -Be $script:configurationData.AllNodes.VMKernelNetworkAdapterNames
            $configuration.PortGroupNames | Should -Be @($script:configurationData.AllNodes.PortGroupName, $script:configurationData.AllNodes.PortGroupName)
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileMigrateTwoDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndOnePortGroupPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToTheSamePortGroup `
                -OutputPath $script:mofFileRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToTheSamePortGroupPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configRemoveVDSwitchStandardSwitchAndStandardPortGroup `
                -OutputPath $script:mofFileRemoveVDSwitchStandardSwitchAndStandardPortGroupPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configMigratePhysicalNetworkAdaptersToInitialVirtualSwitches `
                -OutputPath $script:mofFileMigratePhysicalNetworkAdaptersToInitialVirtualSwitchesPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToTheSamePortGroup = @{
                Path = $script:mofFileRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToTheSamePortGroupPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersRemoveVDSwitchStandardSwitchAndStandardPortGroup = @{
                Path = $script:mofFileRemoveVDSwitchStandardSwitchAndStandardPortGroupPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersMigratePhysicalNetworkAdaptersToInitialVirtualSwitches = @{
                Path = $script:mofFileMigratePhysicalNetworkAdaptersToInitialVirtualSwitchesPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToTheSamePortGroup
            Start-DscConfiguration @startDscConfigurationParametersRemoveVDSwitchStandardSwitchAndStandardPortGroup
            Start-DscConfiguration @startDscConfigurationParametersMigratePhysicalNetworkAdaptersToInitialVirtualSwitches

            Remove-Item -Path $script:mofFileCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileCreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileMigrateTwoDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndOnePortGroupPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToTheSamePortGroupPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVDSwitchStandardSwitchAndStandardPortGroupPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileMigratePhysicalNetworkAdaptersToInitialVirtualSwitchesPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configMigrateTwoDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndTwoPortGroups" {
        BeforeAll {
            # Arrange
            & $script:configCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitch `
                -OutputPath $script:mofFileCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configCreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapter `
                -OutputPath $script:mofFileCreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitch = @{
                Path = $script:mofFileCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersCreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapter = @{
                Path = $script:mofFileCreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitch
            Start-DscConfiguration @startDscConfigurationParametersCreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapter

            # TODO: Replace with DSC Resource that migrates Physical Network Adapters to the specified Standard Switch.
            Add-PhysicalNetworkAdaptersToStandardSwitch

            Get-VMKernelNetworkAdapterNames

            & $script:configMigrateTwoDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndTwoPortGroups `
                -OutputPath $script:mofFileMigrateTwoDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndTwoPortGroupsPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersMigrateTwoDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndTwoPortGroups = @{
                Path = $script:mofFileMigrateTwoDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndTwoPortGroupsPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            Start-DscConfiguration @startDscConfigurationParametersMigrateTwoDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndTwoPortGroups
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileMigrateTwoDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndTwoPortGroupsPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            # Arrange && Act && Assert
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration and all parameters should match' {
            # Arrange && Act
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configMigrateTwoDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndTwoPortGroups }

            # Assert
            # The Physical Network Adapters for a Distributed Switch are sorted by name on the Server.
            $expectedPhysicalNetworkAdapterNames = @(
                $script:configurationData.AllNodes.PhysicalNetworkAdapterNames[0],
                $script:configurationData.AllNodes.PhysicalNetworkAdapterNames[1]
            ) | Sort-Object

            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.VdsName | Should -Be $script:configurationData.AllNodes.VDSwitchName
            $configuration.PhysicalNicNames | Should -Be $expectedPhysicalNetworkAdapterNames
            $configuration.VMKernelNicNames | Should -Be $script:configurationData.AllNodes.VMKernelNetworkAdapterNames
            $configuration.PortGroupNames | Should -Be @($script:configurationData.AllNodes.ManagementPortGroupName, $script:configurationData.AllNodes.VMotionPortGroupName)
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileMigrateTwoDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndTwoPortGroupsPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToDifferentPortGroups `
                -OutputPath $script:mofFileRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToDifferentPortGroupsPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configRemoveVDSwitchStandardSwitchAndStandardPortGroup `
                -OutputPath $script:mofFileRemoveVDSwitchStandardSwitchAndStandardPortGroupPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configMigratePhysicalNetworkAdaptersToInitialVirtualSwitches `
                -OutputPath $script:mofFileMigratePhysicalNetworkAdaptersToInitialVirtualSwitchesPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToDifferentPortGroups = @{
                Path = $script:mofFileRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToDifferentPortGroupsPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersRemoveVDSwitchStandardSwitchAndStandardPortGroup = @{
                Path = $script:mofFileRemoveVDSwitchStandardSwitchAndStandardPortGroupPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersMigratePhysicalNetworkAdaptersToInitialVirtualSwitches = @{
                Path = $script:mofFileMigratePhysicalNetworkAdaptersToInitialVirtualSwitchesPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToDifferentPortGroups
            Start-DscConfiguration @startDscConfigurationParametersRemoveVDSwitchStandardSwitchAndStandardPortGroup
            Start-DscConfiguration @startDscConfigurationParametersMigratePhysicalNetworkAdaptersToInitialVirtualSwitches

            Remove-Item -Path $script:mofFileCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileCreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileMigrateTwoDisconnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndTwoPortGroupsPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToDifferentPortGroupsPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVDSwitchStandardSwitchAndStandardPortGroupPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileMigratePhysicalNetworkAdaptersToInitialVirtualSwitchesPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configMigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndOnePortGroup" {
        BeforeAll {
            # Arrange
            & $script:configCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitch `
                -OutputPath $script:mofFileCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configCreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapter `
                -OutputPath $script:mofFileCreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitch = @{
                Path = $script:mofFileCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersCreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapter = @{
                Path = $script:mofFileCreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitch
            Start-DscConfiguration @startDscConfigurationParametersCreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapter

            # TODO: Replace with DSC Resource that migrates Physical Network Adapters to the specified Standard Switch.
            Add-PhysicalNetworkAdaptersToStandardSwitch

            Get-VMKernelNetworkAdapterNames

            & $script:configMigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndOnePortGroup `
                -OutputPath $script:mofFileMigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndOnePortGroupPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersMigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndOnePortGroup = @{
                Path = $script:mofFileMigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndOnePortGroupPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            Start-DscConfiguration @startDscConfigurationParametersMigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndOnePortGroup
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileMigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndOnePortGroupPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            # Arrange && Act && Assert
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration and all parameters should match' {
            # Arrange && Act
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configMigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndOnePortGroup }

            # Assert
            # The Physical Network Adapters for a Distributed Switch are sorted by name on the Server.
            $expectedPhysicalNetworkAdapterNames = $script:configurationData.AllNodes.PhysicalNetworkAdapterNames | Sort-Object

            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.VdsName | Should -Be $script:configurationData.AllNodes.VDSwitchName
            $configuration.PhysicalNicNames | Should -Be $expectedPhysicalNetworkAdapterNames
            $configuration.VMKernelNicNames | Should -Be $script:configurationData.AllNodes.VMKernelNetworkAdapterNames
            $configuration.PortGroupNames | Should -Be @($script:configurationData.AllNodes.PortGroupName, $script:configurationData.AllNodes.PortGroupName)
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileMigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndOnePortGroupPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToTheSamePortGroup `
                -OutputPath $script:mofFileRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToTheSamePortGroupPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configRemoveVDSwitchStandardSwitchAndStandardPortGroup `
                -OutputPath $script:mofFileRemoveVDSwitchStandardSwitchAndStandardPortGroupPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configMigratePhysicalNetworkAdaptersToInitialVirtualSwitches `
                -OutputPath $script:mofFileMigratePhysicalNetworkAdaptersToInitialVirtualSwitchesPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToTheSamePortGroup = @{
                Path = $script:mofFileRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToTheSamePortGroupPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersRemoveVDSwitchStandardSwitchAndStandardPortGroup = @{
                Path = $script:mofFileRemoveVDSwitchStandardSwitchAndStandardPortGroupPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersMigratePhysicalNetworkAdaptersToInitialVirtualSwitches = @{
                Path = $script:mofFileMigratePhysicalNetworkAdaptersToInitialVirtualSwitchesPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToTheSamePortGroup
            Start-DscConfiguration @startDscConfigurationParametersRemoveVDSwitchStandardSwitchAndStandardPortGroup
            Start-DscConfiguration @startDscConfigurationParametersMigratePhysicalNetworkAdaptersToInitialVirtualSwitches

            Remove-Item -Path $script:mofFileCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileCreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileMigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndOnePortGroupPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToTheSamePortGroupPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVDSwitchStandardSwitchAndStandardPortGroupPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileMigratePhysicalNetworkAdaptersToInitialVirtualSwitchesPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configMigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndTwoPortGroups" {
        BeforeAll {
            # Arrange
            & $script:configCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitch `
                -OutputPath $script:mofFileCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitchPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configCreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapter `
                -OutputPath $script:mofFileCreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitch = @{
                Path = $script:mofFileCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitchPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersCreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapter = @{
                Path = $script:mofFileCreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitch
            Start-DscConfiguration @startDscConfigurationParametersCreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapter

            # TODO: Replace with DSC Resource that migrates Physical Network Adapters to the specified Standard Switch.
            Add-PhysicalNetworkAdaptersToStandardSwitch

            Get-VMKernelNetworkAdapterNames

            & $script:configMigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndTwoPortGroups `
                -OutputPath $script:mofFileMigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndTwoPortGroupsPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersMigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndTwoPortGroups = @{
                Path = $script:mofFileMigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndTwoPortGroupsPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            Start-DscConfiguration @startDscConfigurationParametersMigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndTwoPortGroups
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileMigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndTwoPortGroupsPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            # Arrange && Act && Assert
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration and all parameters should match' {
            # Arrange && Act
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configMigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndTwoPortGroups }

            # Assert
            # The Physical Network Adapters for a Distributed Switch are sorted by name on the Server.
            $expectedPhysicalNetworkAdapterNames = $script:configurationData.AllNodes.PhysicalNetworkAdapterNames | Sort-Object

            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.VdsName | Should -Be $script:configurationData.AllNodes.VDSwitchName
            $configuration.PhysicalNicNames | Should -Be $expectedPhysicalNetworkAdapterNames
            $configuration.VMKernelNicNames | Should -Be $script:configurationData.AllNodes.VMKernelNetworkAdapterNames
            $configuration.PortGroupNames | Should -Be @($script:configurationData.AllNodes.ManagementPortGroupName, $script:configurationData.AllNodes.VMotionPortGroupName)
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileMigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndTwoPortGroupsPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToDifferentPortGroups `
                -OutputPath $script:mofFileRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToDifferentPortGroupsPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configRemoveVDSwitchStandardSwitchAndStandardPortGroup `
                -OutputPath $script:mofFileRemoveVDSwitchStandardSwitchAndStandardPortGroupPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configMigratePhysicalNetworkAdaptersToInitialVirtualSwitches `
                -OutputPath $script:mofFileMigratePhysicalNetworkAdaptersToInitialVirtualSwitchesPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToDifferentPortGroups = @{
                Path = $script:mofFileRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToDifferentPortGroupsPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersRemoveVDSwitchStandardSwitchAndStandardPortGroup = @{
                Path = $script:mofFileRemoveVDSwitchStandardSwitchAndStandardPortGroupPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersMigratePhysicalNetworkAdaptersToInitialVirtualSwitches = @{
                Path = $script:mofFileMigratePhysicalNetworkAdaptersToInitialVirtualSwitchesPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToDifferentPortGroups
            Start-DscConfiguration @startDscConfigurationParametersRemoveVDSwitchStandardSwitchAndStandardPortGroup
            Start-DscConfiguration @startDscConfigurationParametersMigratePhysicalNetworkAdaptersToInitialVirtualSwitches

            Remove-Item -Path $script:mofFileCreateStandardSwitchStandardPortGroupVDSwitchAndAddVMHostToVDSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileCreateManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileMigrateTwoDisconnectedAndOneConnectedPhysicalNetworkAdaptersTwoVMKernelNetworkAdaptersAndTwoPortGroupsPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveManagementVMKernelNetworkAdapterAndvMotionVMKernelNetworkAdapterConnectedToDifferentPortGroupsPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVDSwitchStandardSwitchAndStandardPortGroupPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileMigratePhysicalNetworkAdaptersToInitialVirtualSwitchesPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }
}
