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
#>
function Invoke-TestSetup {
    $viServer = Connect-VIServer -Server $Server -User $User -Password $Password -ErrorAction Stop
    $vmHost = Get-VMHost -Server $viServer -Name $Name -ErrorAction Stop
    $datacenter = Get-Datacenter -Server $viServer -VMHost $vmHost -ErrorAction Stop

    $script:datacenterName = $datacenter.Name
    $script:datacenterLocation = $null

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
}

Invoke-TestSetup

$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (ConvertTo-SecureString -String $Password -AsPlainText -Force)

$script:dscResourceName = 'VMHostVdsNic'
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
            VDSwitchResourceName = 'VDSwitch'
            VDSwitchResourceId = '[VDSwitch]VDSwitch'
            VDPortGroupResourceName = 'VDPortGroup'
            VDPortGroupResourceId = '[VDPortGroup]VDPortGroup'
            VDSwitchVMHostResourceName = 'VDSwitchVMHost'
            VDSwitchNicResourceName = 'VMHostVDSwitchNic'
            VDSwitchNicResourceId = '[VMHostVdsNic]VMHostVDSwitchNic'
            VDSwitchName = 'MyTestVDSwitch'
            VDSwitchLocation = [string]::Empty
            DatacenterName = $script:datacenterName
            DatacenterLocation = $script:datacenterLocation
            VDPortGroupName = 'MyTestVDPortGroup'
            PortId = '1'
            DefaultPortId = '0'
            IP1 = '192.168.0.1'
            IP2 = '10.23.123.234'
            DefaultIP = '0.0.0.0'
            SubnetMask1 = '255.255.255.0'
            SubnetMask2 = '255.255.254.0'
            DefaultSubnetMask = '0.0.0.0'
            Mac = '00:50:56:63:5b:0e'
            AutomaticIPv6 = $true
            IPv6 = @('fe80::250:56ff:fe63:5b0e/64', '200:2342::1/32')
            DefaultIPv6 = @('fe80::250:56ff:fe63:5b0e/64')
            IPv6ThroughDhcp = $true
            VMKernelNetworkAdapterMtu = 4000
            VMKernelNetworkAdapterUpdatedMtu = 5000
            ManagementTrafficEnabled = $true
            FaultToleranceLoggingEnabled = $true
            VMotionEnabled = $true
            VsanTrafficEnabled = $true
            Dhcp = $true
            IPv6Enabled = $true
        }
    )
}

$script:configCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitch = "$($script:dscResourceName)_CreateVDSwitchVDPortGroupAndAddVMHostToVDSwitch_Config"
$script:configCreateVMHostVDSwitchNicWithoutPortId = "$($script:dscResourceName)_CreateVMHostVDSwitchNicWithoutPortId_Config"
$script:configCreateVMHostVDSwitchNicWithPortId = "$($script:dscResourceName)_CreateVMHostVDSwitchNicWithPortId_Config"
$script:configUpdateVMHostVDSwitchNicMtuAndAvailableServices = "$($script:dscResourceName)_UpdateVMHostVDSwitchNicMtuAndAvailableServices_Config"
$script:configUpdateVMHostVDSwitchNicIPAndSubnetMask = "$($script:dscResourceName)_UpdateVMHostVDSwitchNicIPAndSubnetMask_Config"
$script:configUpdateVMHostVDSwitchNicIPv6Settings = "$($script:dscResourceName)_UpdateVMHostVDSwitchNicIPv6Settings_Config"
$script:configUpdateVMHostVDSwitchNicDhcpAndIPv6 = "$($script:dscResourceName)_UpdateVMHostVDSwitchNicDhcpAndIPv6_Config"
$script:configRemoveVMHostVDSwitchNic = "$($script:dscResourceName)_RemoveVMHostVDSwitchNic_Config"
$script:configRemoveVMHostVDSwitchNicVDPortGroupAndVDSwitch = "$($script:dscResourceName)_RemoveVMHostVDSwitchNicVDPortGroupAndVDSwitch_Config"

. $script:configurationFile -ErrorAction Stop

$script:mofFileCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitchPath = "$script:integrationTestsFolderPath\$script:configCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitch\"
$script:mofFileCreateVMHostVDSwitchNicWithoutPortIdPath = "$script:integrationTestsFolderPath\$script:configCreateVMHostVDSwitchNicWithoutPortId\"
$script:mofFileCreateVMHostVDSwitchNicWithPortIdPath = "$script:integrationTestsFolderPath\$script:configCreateVMHostVDSwitchNicWithPortId\"
$script:mofFileUpdateVMHostVDSwitchNicMtuAndAvailableServicesPath = "$script:integrationTestsFolderPath\$script:configUpdateVMHostVDSwitchNicMtuAndAvailableServices\"
$script:mofFileUpdateVMHostVDSwitchNicIPAndSubnetMaskPath = "$script:integrationTestsFolderPath\$script:configUpdateVMHostVDSwitchNicIPAndSubnetMask\"
$script:mofFileUpdateVMHostVDSwitchNicIPv6SettingsPath = "$script:integrationTestsFolderPath\$script:configUpdateVMHostVDSwitchNicIPv6Settings\"
$script:mofFileUpdateVMHostVDSwitchNicDhcpAndIPv6Path = "$script:integrationTestsFolderPath\$script:configUpdateVMHostVDSwitchNicDhcpAndIPv6\"
$script:mofFileRemoveVMHostVDSwitchNicPath = "$script:integrationTestsFolderPath\$script:configRemoveVMHostVDSwitchNic\"
$script:mofFileRemoveVMHostVDSwitchNicVDPortGroupAndVDSwitchPath = "$script:integrationTestsFolderPath\$script:configRemoveVMHostVDSwitchNicVDPortGroupAndVDSwitch\"

try {
    Describe "$($script:dscResourceName)_Integration" {
        Context "When using configuration $script:configCreateVMHostVDSwitchNicWithoutPortId" {
            BeforeAll {
                # Arrange
                & $script:configCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitch `
                    -OutputPath $script:mofFileCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitchPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                & $script:configCreateVMHostVDSwitchNicWithoutPortId `
                    -OutputPath $script:mofFileCreateVMHostVDSwitchNicWithoutPortIdPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                $startDscConfigurationParametersCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitch = @{
                    Path = $script:mofFileCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitchPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                $startDscConfigurationParametersCreateVMHostVDSwitchNicWithoutPortId = @{
                    Path = $script:mofFileCreateVMHostVDSwitchNicWithoutPortIdPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParametersCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitch
                Start-DscConfiguration @startDscConfigurationParametersCreateVMHostVDSwitchNicWithoutPortId
            }

            It 'Should apply the MOF without throwing' {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileCreateVMHostVDSwitchNicWithoutPortIdPath
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
                $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configCreateVMHostVDSwitchNicWithoutPortId }

                # Assert
                $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
                $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
                $configuration.VdsName | Should -Be $script:configurationData.AllNodes.VDSwitchName
                $configuration.PortGroupName | Should -Be $script:configurationData.AllNodes.VDPortGroupName
                $configuration.PortId | Should -Be $script:configurationData.AllNodes.DefaultPortId
                $configuration.Ensure | Should -Be 'Present'
                $configuration.IP | Should -Be $script:configurationData.AllNodes.IP1
                $configuration.SubnetMask | Should -Be $script:configurationData.AllNodes.SubnetMask1
                $configuration.Mac | Should -Be $script:configurationData.AllNodes.Mac
                $configuration.AutomaticIPv6 | Should -Be $script:configurationData.AllNodes.AutomaticIPv6
                $configuration.IPv6 | Should -Be $script:configurationData.AllNodes.IPv6
                $configuration.IPv6ThroughDhcp | Should -Be $script:configurationData.AllNodes.IPv6ThroughDhcp
                $configuration.Mtu | Should -Be $script:configurationData.AllNodes.VMKernelNetworkAdapterMtu
                $configuration.ManagementTrafficEnabled | Should -Be $script:configurationData.AllNodes.ManagementTrafficEnabled
                $configuration.FaultToleranceLoggingEnabled | Should -Be $script:configurationData.AllNodes.FaultToleranceLoggingEnabled
                $configuration.VMotionEnabled | Should -Be $script:configurationData.AllNodes.VMotionEnabled
                $configuration.VsanTrafficEnabled | Should -Be $script:configurationData.AllNodes.VsanTrafficEnabled
                $configuration.Dhcp | Should -Be $false
                $configuration.IPv6Enabled | Should -Be $script:configurationData.AllNodes.IPv6Enabled
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange
                $testDscConfigurationParameters = @{
                    ReferenceConfiguration = "$script:mofFileCreateVMHostVDSwitchNicWithoutPortIdPath\$($script:configurationData.AllNodes.NodeName).mof"
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act && Assert
                (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
            }

            AfterAll {
                # Arrange
                & $script:configRemoveVMHostVDSwitchNicVDPortGroupAndVDSwitch `
                    -OutputPath $script:mofFileRemoveVMHostVDSwitchNicVDPortGroupAndVDSwitchPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                $startDscConfigurationParameters = @{
                    Path = $script:mofFileRemoveVMHostVDSwitchNicVDPortGroupAndVDSwitchPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters

                Remove-Item -Path $script:mofFileCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
                Remove-Item -Path $script:mofFileCreateVMHostVDSwitchNicWithoutPortIdPath -Recurse -Confirm:$false -ErrorAction Stop
                Remove-Item -Path $script:mofFileRemoveVMHostVDSwitchNicVDPortGroupAndVDSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            }
        }

        Context "When using configuration $script:configCreateVMHostVDSwitchNicWithPortId" {
            BeforeAll {
                # Arrange
                & $script:configCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitch `
                    -OutputPath $script:mofFileCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitchPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                & $script:configCreateVMHostVDSwitchNicWithPortId `
                    -OutputPath $script:mofFileCreateVMHostVDSwitchNicWithPortIdPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                $startDscConfigurationParametersCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitch = @{
                    Path = $script:mofFileCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitchPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                $startDscConfigurationParametersCreateVMHostVDSwitchNicWithPortId = @{
                    Path = $script:mofFileCreateVMHostVDSwitchNicWithPortIdPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParametersCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitch
                Start-DscConfiguration @startDscConfigurationParametersCreateVMHostVDSwitchNicWithPortId
            }

            It 'Should apply the MOF without throwing' {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileCreateVMHostVDSwitchNicWithPortIdPath
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
                $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configCreateVMHostVDSwitchNicWithPortId }

                # Assert
                $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
                $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
                $configuration.VdsName | Should -Be $script:configurationData.AllNodes.VDSwitchName
                $configuration.PortGroupName | Should -Be $script:configurationData.AllNodes.VDPortGroupName
                $configuration.PortId | Should -Be $script:configurationData.AllNodes.PortId
                $configuration.Ensure | Should -Be 'Present'
                $configuration.IP | Should -Be $script:configurationData.AllNodes.IP1
                $configuration.SubnetMask | Should -Be $script:configurationData.AllNodes.SubnetMask1
                $configuration.Mac | Should -Be $script:configurationData.AllNodes.Mac
                $configuration.AutomaticIPv6 | Should -Be $script:configurationData.AllNodes.AutomaticIPv6
                $configuration.IPv6 | Should -Be $script:configurationData.AllNodes.IPv6
                $configuration.IPv6ThroughDhcp | Should -Be $script:configurationData.AllNodes.IPv6ThroughDhcp
                $configuration.Mtu | Should -Be $script:configurationData.AllNodes.VMKernelNetworkAdapterMtu
                $configuration.ManagementTrafficEnabled | Should -Be $script:configurationData.AllNodes.ManagementTrafficEnabled
                $configuration.FaultToleranceLoggingEnabled | Should -Be $script:configurationData.AllNodes.FaultToleranceLoggingEnabled
                $configuration.VMotionEnabled | Should -Be $script:configurationData.AllNodes.VMotionEnabled
                $configuration.VsanTrafficEnabled | Should -Be $script:configurationData.AllNodes.VsanTrafficEnabled
                $configuration.Dhcp | Should -Be $false
                $configuration.IPv6Enabled | Should -Be $script:configurationData.AllNodes.IPv6Enabled
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange
                $testDscConfigurationParameters = @{
                    ReferenceConfiguration = "$script:mofFileCreateVMHostVDSwitchNicWithPortIdPath\$($script:configurationData.AllNodes.NodeName).mof"
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act && Assert
                (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
            }

            AfterAll {
                # Arrange
                & $script:configRemoveVMHostVDSwitchNicVDPortGroupAndVDSwitch `
                    -OutputPath $script:mofFileRemoveVMHostVDSwitchNicVDPortGroupAndVDSwitchPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                $startDscConfigurationParameters = @{
                    Path = $script:mofFileRemoveVMHostVDSwitchNicVDPortGroupAndVDSwitchPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters

                Remove-Item -Path $script:mofFileCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
                Remove-Item -Path $script:mofFileCreateVMHostVDSwitchNicWithPortIdPath -Recurse -Confirm:$false -ErrorAction Stop
                Remove-Item -Path $script:mofFileRemoveVMHostVDSwitchNicVDPortGroupAndVDSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            }
        }

        Context "When using configuration $script:configUpdateVMHostVDSwitchNicMtuAndAvailableServices" {
            BeforeAll {
                # Arrange
                & $script:configCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitch `
                    -OutputPath $script:mofFileCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitchPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                & $script:configCreateVMHostVDSwitchNicWithPortId `
                    -OutputPath $script:mofFileCreateVMHostVDSwitchNicWithPortIdPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                & $script:configUpdateVMHostVDSwitchNicMtuAndAvailableServices `
                    -OutputPath $script:mofFileUpdateVMHostVDSwitchNicMtuAndAvailableServicesPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                $startDscConfigurationParametersCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitch = @{
                    Path = $script:mofFileCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitchPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                $startDscConfigurationParametersCreateVMHostVDSwitchNicWithPortId = @{
                    Path = $script:mofFileCreateVMHostVDSwitchNicWithPortIdPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                $startDscConfigurationParametersUpdateVMHostVDSwitchNicMtuAndAvailableServices = @{
                    Path = $script:mofFileUpdateVMHostVDSwitchNicMtuAndAvailableServicesPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParametersCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitch
                Start-DscConfiguration @startDscConfigurationParametersCreateVMHostVDSwitchNicWithPortId
                Start-DscConfiguration @startDscConfigurationParametersUpdateVMHostVDSwitchNicMtuAndAvailableServices
            }

            It 'Should apply the MOF without throwing' {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileUpdateVMHostVDSwitchNicMtuAndAvailableServicesPath
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
                $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configUpdateVMHostVDSwitchNicMtuAndAvailableServices }

                # Assert
                $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
                $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
                $configuration.VdsName | Should -Be $script:configurationData.AllNodes.VDSwitchName
                $configuration.PortGroupName | Should -Be $script:configurationData.AllNodes.VDPortGroupName
                $configuration.PortId | Should -Be $script:configurationData.AllNodes.PortId
                $configuration.Ensure | Should -Be 'Present'
                $configuration.IP | Should -Be $script:configurationData.AllNodes.IP1
                $configuration.SubnetMask | Should -Be $script:configurationData.AllNodes.SubnetMask1
                $configuration.Mac | Should -Be $script:configurationData.AllNodes.Mac
                $configuration.AutomaticIPv6 | Should -Be $script:configurationData.AllNodes.AutomaticIPv6
                $configuration.IPv6 | Should -Be $script:configurationData.AllNodes.IPv6
                $configuration.IPv6ThroughDhcp | Should -Be $script:configurationData.AllNodes.IPv6ThroughDhcp
                $configuration.Mtu | Should -Be $script:configurationData.AllNodes.VMKernelNetworkAdapterUpdatedMtu
                $configuration.ManagementTrafficEnabled | Should -Be $false
                $configuration.FaultToleranceLoggingEnabled | Should -Be $false
                $configuration.VMotionEnabled | Should -Be $false
                $configuration.VsanTrafficEnabled | Should -Be $false
                $configuration.Dhcp | Should -Be $false
                $configuration.IPv6Enabled | Should -Be $script:configurationData.AllNodes.IPv6Enabled
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange
                $testDscConfigurationParameters = @{
                    ReferenceConfiguration = "$script:mofFileUpdateVMHostVDSwitchNicMtuAndAvailableServicesPath\$($script:configurationData.AllNodes.NodeName).mof"
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act && Assert
                (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
            }

            AfterAll {
                # Arrange
                & $script:configRemoveVMHostVDSwitchNicVDPortGroupAndVDSwitch `
                    -OutputPath $script:mofFileRemoveVMHostVDSwitchNicVDPortGroupAndVDSwitchPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                $startDscConfigurationParameters = @{
                    Path = $script:mofFileRemoveVMHostVDSwitchNicVDPortGroupAndVDSwitchPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters

                Remove-Item -Path $script:mofFileCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
                Remove-Item -Path $script:mofFileCreateVMHostVDSwitchNicWithPortIdPath -Recurse -Confirm:$false -ErrorAction Stop
                Remove-Item -Path $script:mofFileUpdateVMHostVDSwitchNicMtuAndAvailableServicesPath -Recurse -Confirm:$false -ErrorAction Stop
                Remove-Item -Path $script:mofFileRemoveVMHostVDSwitchNicVDPortGroupAndVDSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            }
        }

        Context "When using configuration $script:configUpdateVMHostVDSwitchNicIPAndSubnetMask" {
            BeforeAll {
                # Arrange
                & $script:configCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitch `
                    -OutputPath $script:mofFileCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitchPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                & $script:configCreateVMHostVDSwitchNicWithPortId `
                    -OutputPath $script:mofFileCreateVMHostVDSwitchNicWithPortIdPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                & $script:configUpdateVMHostVDSwitchNicIPAndSubnetMask `
                    -OutputPath $script:mofFileUpdateVMHostVDSwitchNicIPAndSubnetMaskPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                $startDscConfigurationParametersCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitch = @{
                    Path = $script:mofFileCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitchPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                $startDscConfigurationParametersCreateVMHostVDSwitchNicWithPortId = @{
                    Path = $script:mofFileCreateVMHostVDSwitchNicWithPortIdPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                $startDscConfigurationParametersUpdateVMHostVDSwitchNicIPAndSubnetMask = @{
                    Path = $script:mofFileUpdateVMHostVDSwitchNicIPAndSubnetMaskPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParametersCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitch
                Start-DscConfiguration @startDscConfigurationParametersCreateVMHostVDSwitchNicWithPortId
                Start-DscConfiguration @startDscConfigurationParametersUpdateVMHostVDSwitchNicIPAndSubnetMask
            }

            It 'Should apply the MOF without throwing' {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileUpdateVMHostVDSwitchNicIPAndSubnetMaskPath
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
                $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configUpdateVMHostVDSwitchNicIPAndSubnetMask }

                # Assert
                $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
                $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
                $configuration.VdsName | Should -Be $script:configurationData.AllNodes.VDSwitchName
                $configuration.PortGroupName | Should -Be $script:configurationData.AllNodes.VDPortGroupName
                $configuration.PortId | Should -Be $script:configurationData.AllNodes.PortId
                $configuration.Ensure | Should -Be 'Present'
                $configuration.IP | Should -Be $script:configurationData.AllNodes.IP2
                $configuration.SubnetMask | Should -Be $script:configurationData.AllNodes.SubnetMask2
                $configuration.Mac | Should -Be $script:configurationData.AllNodes.Mac
                $configuration.AutomaticIPv6 | Should -Be $script:configurationData.AllNodes.AutomaticIPv6
                $configuration.IPv6 | Should -Be $script:configurationData.AllNodes.IPv6
                $configuration.IPv6ThroughDhcp | Should -Be $script:configurationData.AllNodes.IPv6ThroughDhcp
                $configuration.Mtu | Should -Be $script:configurationData.AllNodes.VMKernelNetworkAdapterMtu
                $configuration.ManagementTrafficEnabled | Should -Be $script:configurationData.AllNodes.ManagementTrafficEnabled
                $configuration.FaultToleranceLoggingEnabled | Should -Be $script:configurationData.AllNodes.FaultToleranceLoggingEnabled
                $configuration.VMotionEnabled | Should -Be $script:configurationData.AllNodes.VMotionEnabled
                $configuration.VsanTrafficEnabled | Should -Be $script:configurationData.AllNodes.VsanTrafficEnabled
                $configuration.Dhcp | Should -Be $false
                $configuration.IPv6Enabled | Should -Be $script:configurationData.AllNodes.IPv6Enabled
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange
                $testDscConfigurationParameters = @{
                    ReferenceConfiguration = "$script:mofFileUpdateVMHostVDSwitchNicIPAndSubnetMaskPath\$($script:configurationData.AllNodes.NodeName).mof"
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act && Assert
                (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
            }

            AfterAll {
                # Arrange
                & $script:configRemoveVMHostVDSwitchNicVDPortGroupAndVDSwitch `
                    -OutputPath $script:mofFileRemoveVMHostVDSwitchNicVDPortGroupAndVDSwitchPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                $startDscConfigurationParameters = @{
                    Path = $script:mofFileRemoveVMHostVDSwitchNicVDPortGroupAndVDSwitchPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters

                Remove-Item -Path $script:mofFileCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
                Remove-Item -Path $script:mofFileCreateVMHostVDSwitchNicWithPortIdPath -Recurse -Confirm:$false -ErrorAction Stop
                Remove-Item -Path $script:mofFileUpdateVMHostVDSwitchNicIPAndSubnetMaskPath -Recurse -Confirm:$false -ErrorAction Stop
                Remove-Item -Path $script:mofFileRemoveVMHostVDSwitchNicVDPortGroupAndVDSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            }
        }

        Context "When using configuration $script:configUpdateVMHostVDSwitchNicIPv6Settings" {
            BeforeAll {
                # Arrange
                & $script:configCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitch `
                    -OutputPath $script:mofFileCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitchPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                & $script:configCreateVMHostVDSwitchNicWithPortId `
                    -OutputPath $script:mofFileCreateVMHostVDSwitchNicWithPortIdPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                & $script:configUpdateVMHostVDSwitchNicIPv6Settings `
                    -OutputPath $script:mofFileUpdateVMHostVDSwitchNicIPv6SettingsPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                $startDscConfigurationParametersCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitch = @{
                    Path = $script:mofFileCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitchPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                $startDscConfigurationParametersCreateVMHostVDSwitchNicWithPortId = @{
                    Path = $script:mofFileCreateVMHostVDSwitchNicWithPortIdPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                $startDscConfigurationParametersUpdateVMHostVDSwitchNicIPv6Settings = @{
                    Path = $script:mofFileUpdateVMHostVDSwitchNicIPv6SettingsPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParametersCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitch
                Start-DscConfiguration @startDscConfigurationParametersCreateVMHostVDSwitchNicWithPortId
                Start-DscConfiguration @startDscConfigurationParametersUpdateVMHostVDSwitchNicIPv6Settings
            }

            It 'Should apply the MOF without throwing' {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileUpdateVMHostVDSwitchNicIPv6SettingsPath
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
                $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configUpdateVMHostVDSwitchNicIPv6Settings }

                # Assert
                $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
                $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
                $configuration.VdsName | Should -Be $script:configurationData.AllNodes.VDSwitchName
                $configuration.PortGroupName | Should -Be $script:configurationData.AllNodes.VDPortGroupName
                $configuration.PortId | Should -Be $script:configurationData.AllNodes.PortId
                $configuration.Ensure | Should -Be 'Present'
                $configuration.IP | Should -Be $script:configurationData.AllNodes.IP1
                $configuration.SubnetMask | Should -Be $script:configurationData.AllNodes.SubnetMask1
                $configuration.Mac | Should -Be $script:configurationData.AllNodes.Mac
                $configuration.AutomaticIPv6 | Should -Be $false
                $configuration.IPv6 | Should -Be $script:configurationData.AllNodes.DefaultIPv6
                $configuration.IPv6ThroughDhcp | Should -Be $false
                $configuration.Mtu | Should -Be $script:configurationData.AllNodes.VMKernelNetworkAdapterMtu
                $configuration.ManagementTrafficEnabled | Should -Be $script:configurationData.AllNodes.ManagementTrafficEnabled
                $configuration.FaultToleranceLoggingEnabled | Should -Be $script:configurationData.AllNodes.FaultToleranceLoggingEnabled
                $configuration.VMotionEnabled | Should -Be $script:configurationData.AllNodes.VMotionEnabled
                $configuration.VsanTrafficEnabled | Should -Be $script:configurationData.AllNodes.VsanTrafficEnabled
                $configuration.Dhcp | Should -Be $false
                $configuration.IPv6Enabled | Should -Be $false
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange
                $testDscConfigurationParameters = @{
                    ReferenceConfiguration = "$script:mofFileUpdateVMHostVDSwitchNicIPv6SettingsPath\$($script:configurationData.AllNodes.NodeName).mof"
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act && Assert
                (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
            }

            AfterAll {
                # Arrange
                & $script:configRemoveVMHostVDSwitchNicVDPortGroupAndVDSwitch `
                    -OutputPath $script:mofFileRemoveVMHostVDSwitchNicVDPortGroupAndVDSwitchPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                $startDscConfigurationParameters = @{
                    Path = $script:mofFileRemoveVMHostVDSwitchNicVDPortGroupAndVDSwitchPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters

                Remove-Item -Path $script:mofFileCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
                Remove-Item -Path $script:mofFileCreateVMHostVDSwitchNicWithPortIdPath -Recurse -Confirm:$false -ErrorAction Stop
                Remove-Item -Path $script:mofFileUpdateVMHostVDSwitchNicIPv6SettingsPath -Recurse -Confirm:$false -ErrorAction Stop
                Remove-Item -Path $script:mofFileRemoveVMHostVDSwitchNicVDPortGroupAndVDSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            }
        }

        Context "When using configuration $script:configUpdateVMHostVDSwitchNicDhcpAndIPv6" {
            BeforeAll {
                # Arrange
                & $script:configCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitch `
                    -OutputPath $script:mofFileCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitchPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                & $script:configCreateVMHostVDSwitchNicWithPortId `
                    -OutputPath $script:mofFileCreateVMHostVDSwitchNicWithPortIdPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                & $script:configUpdateVMHostVDSwitchNicDhcpAndIPv6 `
                    -OutputPath $script:mofFileUpdateVMHostVDSwitchNicDhcpAndIPv6Path `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                $startDscConfigurationParametersCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitch = @{
                    Path = $script:mofFileCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitchPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                $startDscConfigurationParametersCreateVMHostVDSwitchNicWithPortId = @{
                    Path = $script:mofFileCreateVMHostVDSwitchNicWithPortIdPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                $startDscConfigurationParametersUpdateVMHostVDSwitchNicDhcpAndIPv6 = @{
                    Path = $script:mofFileUpdateVMHostVDSwitchNicDhcpAndIPv6Path
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParametersCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitch
                Start-DscConfiguration @startDscConfigurationParametersCreateVMHostVDSwitchNicWithPortId
                Start-DscConfiguration @startDscConfigurationParametersUpdateVMHostVDSwitchNicDhcpAndIPv6

                <#
                IP and SubnetMask values on the server are not updated instantly so we
                need to suspend the activity before the execution of the tests begins.
                #>
                Start-Sleep -Seconds 30
            }

            It 'Should apply the MOF without throwing' {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileUpdateVMHostVDSwitchNicDhcpAndIPv6Path
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
                $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configUpdateVMHostVDSwitchNicDhcpAndIPv6 }

                # Assert
                $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
                $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
                $configuration.VdsName | Should -Be $script:configurationData.AllNodes.VDSwitchName
                $configuration.PortGroupName | Should -Be $script:configurationData.AllNodes.VDPortGroupName
                $configuration.PortId | Should -Be $script:configurationData.AllNodes.PortId
                $configuration.Ensure | Should -Be 'Present'
                $configuration.IP | Should -Be $script:configurationData.AllNodes.DefaultIP
                $configuration.SubnetMask | Should -Be $script:configurationData.AllNodes.DefaultSubnetMask
                $configuration.Mac | Should -Be $script:configurationData.AllNodes.Mac
                $configuration.AutomaticIPv6 | Should -Be $false
                $configuration.IPv6 | Should -Be $script:configurationData.AllNodes.DefaultIPv6
                $configuration.IPv6ThroughDhcp | Should -Be $false
                $configuration.Mtu | Should -Be $script:configurationData.AllNodes.VMKernelNetworkAdapterMtu
                $configuration.ManagementTrafficEnabled | Should -Be $script:configurationData.AllNodes.ManagementTrafficEnabled
                $configuration.FaultToleranceLoggingEnabled | Should -Be $script:configurationData.AllNodes.FaultToleranceLoggingEnabled
                $configuration.VMotionEnabled | Should -Be $script:configurationData.AllNodes.VMotionEnabled
                $configuration.VsanTrafficEnabled | Should -Be $script:configurationData.AllNodes.VsanTrafficEnabled
                $configuration.Dhcp | Should -Be $script:configurationData.AllNodes.Dhcp
                $configuration.IPv6Enabled | Should -Be $false
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange
                $testDscConfigurationParameters = @{
                    ReferenceConfiguration = "$script:mofFileUpdateVMHostVDSwitchNicDhcpAndIPv6Path\$($script:configurationData.AllNodes.NodeName).mof"
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act && Assert
                (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
            }

            AfterAll {
                # Arrange
                & $script:configRemoveVMHostVDSwitchNicVDPortGroupAndVDSwitch `
                    -OutputPath $script:mofFileRemoveVMHostVDSwitchNicVDPortGroupAndVDSwitchPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                $startDscConfigurationParameters = @{
                    Path = $script:mofFileRemoveVMHostVDSwitchNicVDPortGroupAndVDSwitchPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters

                Remove-Item -Path $script:mofFileCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
                Remove-Item -Path $script:mofFileCreateVMHostVDSwitchNicWithPortIdPath -Recurse -Confirm:$false -ErrorAction Stop
                Remove-Item -Path $script:mofFileUpdateVMHostVDSwitchNicDhcpAndIPv6Path -Recurse -Confirm:$false -ErrorAction Stop
                Remove-Item -Path $script:mofFileRemoveVMHostVDSwitchNicVDPortGroupAndVDSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            }
        }

        Context "When using configuration $script:configRemoveVMHostVDSwitchNic" {
            BeforeAll {
                # Arrange
                & $script:configCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitch `
                    -OutputPath $script:mofFileCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitchPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                & $script:configCreateVMHostVDSwitchNicWithPortId `
                    -OutputPath $script:mofFileCreateVMHostVDSwitchNicWithPortIdPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                & $script:configRemoveVMHostVDSwitchNic `
                    -OutputPath $script:mofFileRemoveVMHostVDSwitchNicPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                $startDscConfigurationParametersCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitch = @{
                    Path = $script:mofFileCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitchPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                $startDscConfigurationParametersCreateVMHostVDSwitchNicWithPortId = @{
                    Path = $script:mofFileCreateVMHostVDSwitchNicWithPortIdPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                $startDscConfigurationParametersRemoveVMHostVDSwitchNic = @{
                    Path = $script:mofFileRemoveVMHostVDSwitchNicPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParametersCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitch
                Start-DscConfiguration @startDscConfigurationParametersCreateVMHostVDSwitchNicWithPortId
                Start-DscConfiguration @startDscConfigurationParametersRemoveVMHostVDSwitchNic
            }

            It 'Should apply the MOF without throwing' {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileRemoveVMHostVDSwitchNicPath
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
                $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configRemoveVMHostVDSwitchNic }

                # Assert
                $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
                $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
                $configuration.VdsName | Should -Be $script:configurationData.AllNodes.VDSwitchName
                $configuration.PortGroupName | Should -Be $script:configurationData.AllNodes.VDPortGroupName
                $configuration.PortId | Should -Be $script:configurationData.AllNodes.PortId
                $configuration.Ensure | Should -Be 'Absent'
                $configuration.IP | Should -BeNullOrEmpty
                $configuration.SubnetMask | Should -BeNullOrEmpty
                $configuration.Mac | Should -BeNullOrEmpty
                $configuration.AutomaticIPv6 | Should -BeNullOrEmpty
                $configuration.IPv6 | Should -BeNullOrEmpty
                $configuration.IPv6ThroughDhcp | Should -BeNullOrEmpty
                $configuration.Mtu | Should -BeNullOrEmpty
                $configuration.ManagementTrafficEnabled | Should -BeNullOrEmpty
                $configuration.FaultToleranceLoggingEnabled | Should -BeNullOrEmpty
                $configuration.VMotionEnabled | Should -BeNullOrEmpty
                $configuration.VsanTrafficEnabled | Should -BeNullOrEmpty
                $configuration.Dhcp | Should -BeNullOrEmpty
                $configuration.IPv6Enabled | Should -BeNullOrEmpty
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange
                $testDscConfigurationParameters = @{
                    ReferenceConfiguration = "$script:mofFileRemoveVMHostVDSwitchNicPath\$($script:configurationData.AllNodes.NodeName).mof"
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act && Assert
                (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
            }

            AfterAll {
                # Arrange
                & $script:configRemoveVMHostVDSwitchNicVDPortGroupAndVDSwitch `
                    -OutputPath $script:mofFileRemoveVMHostVDSwitchNicVDPortGroupAndVDSwitchPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                $startDscConfigurationParameters = @{
                    Path = $script:mofFileRemoveVMHostVDSwitchNicVDPortGroupAndVDSwitchPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters

                Remove-Item -Path $script:mofFileCreateVDSwitchVDPortGroupAndAddVMHostToVDSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
                Remove-Item -Path $script:mofFileCreateVMHostVDSwitchNicWithPortIdPath -Recurse -Confirm:$false -ErrorAction Stop
                Remove-Item -Path $script:mofFileRemoveVMHostVDSwitchNicPath -Recurse -Confirm:$false -ErrorAction Stop
                Remove-Item -Path $script:mofFileRemoveVMHostVDSwitchNicVDPortGroupAndVDSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            }
        }
    }
}
finally {
    Disconnect-VIServer -Server $Server -Confirm:$false
}
