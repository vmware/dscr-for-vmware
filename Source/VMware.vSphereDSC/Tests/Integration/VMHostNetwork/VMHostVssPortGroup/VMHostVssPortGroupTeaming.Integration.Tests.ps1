<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

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
Retrieves the Physical Nics that are not used by a Standard Switch from the specified VMHost.
If there are no available unused Physical Nics on the VMHost, it throws an exception.
#>
function Invoke-TestSetup {
    $viServer = Connect-VIServer -Server $Server -User $User -Password $Password -ErrorAction Stop
    $vmHost = Get-VMHost -Server $viServer -Name $Name -ErrorAction Stop
    $standardSwitches = Get-VirtualSwitch -Server $viServer -VMHost $vmHost -Standard -ErrorAction Stop
    $physicalNetworkAdapters = Get-VMHostNetworkAdapter -Server $viServer -VMHost $vmHost -Physical -ErrorAction Stop

    $availablePhysicalNetworkAdapters = @()

    foreach ($physicalNetworkAdapter in $physicalNetworkAdapters) {
        $isPhysicalNicUsed = $false

        foreach ($standardSwitch in $standardSwitches) {
            $physicalNetworkAdapterExists = $standardSwitch.Nic | Where-Object -FilterScript { $_ -eq $physicalNetworkAdapter.Name }
            if ($null -ne $physicalNetworkAdapterExists) {
                $isPhysicalNicUsed = $true
                break
            }
        }

        if (!$isPhysicalNicUsed) {
            $availablePhysicalNetworkAdapters += $physicalNetworkAdapter
        }
    }

    if ($availablePhysicalNetworkAdapters.Length -lt 2) {
        throw "The Standard Switch that is used in the Integration Tests requires 2 unused Physical Network Adapters to be available on the ESXi node."
    }

    $script:physicalNic1 = $availablePhysicalNetworkAdapters[0].Name
    $script:physicalNic2 = $availablePhysicalNetworkAdapters[1].Name
}

Invoke-TestSetup

$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (ConvertTo-SecureString -String $Password -AsPlainText -Force)

$script:dscResourceName = 'VMHostVssPortGroupTeaming'
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
            Name = $Name
            StandardSwitchResourceName = 'StandardSwitch'
            StandardSwitchResourceId = '[VMHostVss]StandardSwitch'
            StandardSwitchBridgeResourceName = 'StandardSwitchBridge'
            StandardSwitchBridgeResourceId = '[VMHostVssBridge]StandardSwitchBridge'
            StandardSwitchTeamingPolicyResourceName = 'StandardSwitchTeamingPolicy'
            StandardSwitchTeamingPolicyResourceId = '[VMHostVssTeaming]StandardSwitchTeamingPolicy'
            VirtualPortGroupResourceName = 'VirtualPortGroup'
            VirtualPortGroupResourceId = '[VMHostVssPortGroup]VirtualPortGroup'
            VirtualPortGroupTeamingPolicyResourceName = 'VirtualPortGroupTeamingPolicy'
            VirtualPortGroupTeamingPolicyResourceId = '[VMHostVssPortGroupTeaming]VirtualPortGroupTeamingPolicy'
            StandardSwitchName = 'MyStandardSwitch'
            Mtu = 1500
            BeaconInterval = 1
            LinkDiscoveryProtocolOperation = 'Listen'
            LinkDiscoveryProtocolProtocol = 'CDP'
            Nic = @($script:physicalNic1, $script:physicalNic2)
            StandardSwitchActiveNic = @($script:physicalNic1, $script:physicalNic2)
            StandardSwitchStandbyNic = @()
            CheckBeacon = $true
            NotifySwitches = $false
            NicTeamingPolicy = 'Loadbalance_ip'
            RollingOrder = $true
            VirtualPortGroupName = 'MyVirtualPortGroup'
            VlanId = 0
            FailbackEnabled = $false
            LoadBalancingPolicy = 'LoadBalanceIP'
            ActiveNic = @($script:physicalNic1)
            StandbyNic = @($script:physicalNic2)
            DefaultStandbyNic = @()
            UnusedNic = @($script:physicalNic2)
            DefaultUnusedNic = @()
            NetworkFailoverDetectionPolicyLinkStatus = 'LinkStatus'
            NetworkFailoverDetectionPolicyBeaconProbing = 'BeaconProbing'
            InheritFailback = $false
            InheritFailoverOrder = $false
            InheritLoadBalancingPolicy = $false
            InheritNetworkFailoverDetectionPolicy = $false
            InheritNotifySwitches = $false
        }
    )
}

$script:configWhenAddingVirtualPortGroupAndStandardSwitch = "$($script:dscResourceName)_WhenAddingVirtualPortGroupAndStandardSwitch_Config"
$script:configWhenUpdatingTeamingPolicyWithoutInheritSettings = "$($script:dscResourceName)_WhenUpdatingTeamingPolicyWithoutInheritSettings_Config"
$script:configWhenUpdatingTeamingPolicyWithInheritSettingsSetToFalse = "$($script:dscResourceName)_WhenUpdatingTeamingPolicyWithInheritSettingsSetToFalse_Config"
$script:configWhenUpdatingTeamingPolicyWithInheritSettingsSetToTrue = "$($script:dscResourceName)_WhenUpdatingTeamingPolicyWithInheritSettingsSetToTrue_Config"
$script:configWhenRemovingVirtualPortGroupAndStandardSwitch = "$($script:dscResourceName)_WhenRemovingVirtualPortGroupAndStandardSwitch_Config"

. $script:configurationFile -ErrorAction Stop

$script:mofFileWhenAddingVirtualPortGroupAndStandardSwitchPath = "$script:integrationTestsFolderPath\$script:configWhenAddingVirtualPortGroupAndStandardSwitch\"
$script:mofFileWhenUpdatingTeamingPolicyWithoutInheritSettingsPath = "$script:integrationTestsFolderPath\$script:configWhenUpdatingTeamingPolicyWithoutInheritSettings\"
$script:mofFileWhenUpdatingTeamingPolicyWithInheritSettingsSetToFalsePath = "$script:integrationTestsFolderPath\$script:configWhenUpdatingTeamingPolicyWithInheritSettingsSetToFalse\"
$script:mofFileWhenUpdatingTeamingPolicyWithInheritSettingsSetToTruePath = "$script:integrationTestsFolderPath\$script:configWhenUpdatingTeamingPolicyWithInheritSettingsSetToTrue\"
$script:mofFileWhenRemovingVirtualPortGroupAndStandardSwitchPath = "$script:integrationTestsFolderPath\$script:configWhenRemovingVirtualPortGroupAndStandardSwitch\"

try {
    Describe "$($script:dscResourceName)_Integration" {
        Context "When using configuration $script:configWhenUpdatingTeamingPolicyWithoutInheritSettings" {
            BeforeAll {
                # Arrange
                & $script:configWhenAddingVirtualPortGroupAndStandardSwitch `
                    -OutputPath $script:mofFileWhenAddingVirtualPortGroupAndStandardSwitchPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                & $script:configWhenUpdatingTeamingPolicyWithoutInheritSettings `
                    -OutputPath $script:mofFileWhenUpdatingTeamingPolicyWithoutInheritSettingsPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                $startDscConfigurationParametersWhenAddingVirtualPortGroupAndStandardSwitch = @{
                    Path = $script:mofFileWhenAddingVirtualPortGroupAndStandardSwitchPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                $startDscConfigurationParametersWhenUpdatingTeamingPolicyWithoutInheritSettings = @{
                    Path = $script:mofFileWhenUpdatingTeamingPolicyWithoutInheritSettingsPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParametersWhenAddingVirtualPortGroupAndStandardSwitch
                Start-DscConfiguration @startDscConfigurationParametersWhenUpdatingTeamingPolicyWithoutInheritSettings
            }

            It 'Should apply the MOF without throwing' {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenUpdatingTeamingPolicyWithoutInheritSettingsPath
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
                $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configWhenUpdatingTeamingPolicyWithoutInheritSettings }

                # Assert
                $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
                $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.Name
                $configuration.Name | Should -Be $script:configurationData.AllNodes.VirtualPortGroupName
                $configuration.Ensure | Should -Be 'Present'
                $configuration.FailbackEnabled | Should -Be $script:configurationData.AllNodes.FailbackEnabled
                $configuration.LoadBalancingPolicy | Should -Be $script:configurationData.AllNodes.LoadBalancingPolicy
                $configuration.ActiveNic | Should -Be $script:configurationData.AllNodes.ActiveNic
                $configuration.StandbyNic | Should -Be $script:configurationData.AllNodes.StandbyNic
                $configuration.UnusedNic | Should -Be $script:configurationData.AllNodes.DefaultUnusedNic
                $configuration.NetworkFailoverDetectionPolicy | Should -Be $script:configurationData.AllNodes.NetworkFailoverDetectionPolicyLinkStatus
                $configuration.NotifySwitches | Should -Be $script:configurationData.AllNodes.NotifySwitches
                $configuration.InheritFailback | Should -Be $script:configurationData.AllNodes.InheritFailback
                $configuration.InheritFailoverOrder | Should -Be $script:configurationData.AllNodes.InheritFailoverOrder
                $configuration.InheritLoadBalancingPolicy | Should -Be $script:configurationData.AllNodes.InheritLoadBalancingPolicy
                $configuration.InheritNetworkFailoverDetectionPolicy | Should -Be $script:configurationData.AllNodes.InheritNetworkFailoverDetectionPolicy
                $configuration.InheritNotifySwitches | Should -Be $script:configurationData.AllNodes.InheritNotifySwitches
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange
                $testDscConfigurationParameters = @{
                    ReferenceConfiguration = "$script:mofFileWhenUpdatingTeamingPolicyWithoutInheritSettingsPath\$($script:configurationData.AllNodes.NodeName).mof"
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act && Assert
                (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
            }

            AfterAll {
                # Arrange
                & $script:configWhenRemovingVirtualPortGroupAndStandardSwitch `
                    -OutputPath $script:mofFileWhenRemovingVirtualPortGroupAndStandardSwitchPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenRemovingVirtualPortGroupAndStandardSwitchPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters

                Remove-Item -Path $script:mofFileWhenAddingVirtualPortGroupAndStandardSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
                Remove-Item -Path $script:mofFileWhenUpdatingTeamingPolicyWithoutInheritSettingsPath -Recurse -Confirm:$false -ErrorAction Stop
                Remove-Item -Path $script:mofFileWhenRemovingVirtualPortGroupAndStandardSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            }
        }

        Context "When using configuration $script:configWhenUpdatingTeamingPolicyWithInheritSettingsSetToFalse" {
            BeforeAll {
                # Arrange
                & $script:configWhenAddingVirtualPortGroupAndStandardSwitch `
                    -OutputPath $script:mofFileWhenAddingVirtualPortGroupAndStandardSwitchPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                & $script:configWhenUpdatingTeamingPolicyWithInheritSettingsSetToFalse `
                    -OutputPath $script:mofFileWhenUpdatingTeamingPolicyWithInheritSettingsSetToFalsePath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                $startDscConfigurationParametersWhenAddingVirtualPortGroupAndStandardSwitch = @{
                    Path = $script:mofFileWhenAddingVirtualPortGroupAndStandardSwitchPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                $startDscConfigurationParametersWhenUpdatingTeamingPolicyWithInheritSettingsSetToFalse = @{
                    Path = $script:mofFileWhenUpdatingTeamingPolicyWithInheritSettingsSetToFalsePath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParametersWhenAddingVirtualPortGroupAndStandardSwitch
                Start-DscConfiguration @startDscConfigurationParametersWhenUpdatingTeamingPolicyWithInheritSettingsSetToFalse
            }

            It 'Should apply the MOF without throwing' {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenUpdatingTeamingPolicyWithInheritSettingsSetToFalsePath
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
                $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configWhenUpdatingTeamingPolicyWithInheritSettingsSetToFalse }

                # Assert
                $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
                $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.Name
                $configuration.Name | Should -Be $script:configurationData.AllNodes.VirtualPortGroupName
                $configuration.Ensure | Should -Be 'Present'
                $configuration.FailbackEnabled | Should -Be $script:configurationData.AllNodes.FailbackEnabled
                $configuration.LoadBalancingPolicy | Should -Be $script:configurationData.AllNodes.LoadBalancingPolicy
                $configuration.ActiveNic | Should -Be $script:configurationData.AllNodes.ActiveNic
                $configuration.StandbyNic | Should -Be $script:configurationData.AllNodes.DefaultStandbyNic
                $configuration.UnusedNic | Should -Be $script:configurationData.AllNodes.UnusedNic
                $configuration.NetworkFailoverDetectionPolicy | Should -Be $script:configurationData.AllNodes.NetworkFailoverDetectionPolicyLinkStatus
                $configuration.NotifySwitches | Should -Be $script:configurationData.AllNodes.NotifySwitches
                $configuration.InheritFailback | Should -Be $script:configurationData.AllNodes.InheritFailback
                $configuration.InheritFailoverOrder | Should -Be $script:configurationData.AllNodes.InheritFailoverOrder
                $configuration.InheritLoadBalancingPolicy | Should -Be $script:configurationData.AllNodes.InheritLoadBalancingPolicy
                $configuration.InheritNetworkFailoverDetectionPolicy | Should -Be $script:configurationData.AllNodes.InheritNetworkFailoverDetectionPolicy
                $configuration.InheritNotifySwitches | Should -Be $script:configurationData.AllNodes.InheritNotifySwitches
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange
                $testDscConfigurationParameters = @{
                    ReferenceConfiguration = "$script:mofFileWhenUpdatingTeamingPolicyWithInheritSettingsSetToFalsePath\$($script:configurationData.AllNodes.NodeName).mof"
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act && Assert
                (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
            }

            AfterAll {
                # Arrange
                & $script:configWhenRemovingVirtualPortGroupAndStandardSwitch `
                    -OutputPath $script:mofFileWhenRemovingVirtualPortGroupAndStandardSwitchPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenRemovingVirtualPortGroupAndStandardSwitchPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters

                Remove-Item -Path $script:mofFileWhenAddingVirtualPortGroupAndStandardSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
                Remove-Item -Path $script:mofFileWhenUpdatingTeamingPolicyWithInheritSettingsSetToFalsePath -Recurse -Confirm:$false -ErrorAction Stop
                Remove-Item -Path $script:mofFileWhenRemovingVirtualPortGroupAndStandardSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            }
        }

        Context "When using configuration $script:configWhenUpdatingTeamingPolicyWithInheritSettingsSetToTrue" {
            BeforeAll {
                # Arrange
                & $script:configWhenAddingVirtualPortGroupAndStandardSwitch `
                    -OutputPath $script:mofFileWhenAddingVirtualPortGroupAndStandardSwitchPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                & $script:configWhenUpdatingTeamingPolicyWithInheritSettingsSetToTrue `
                    -OutputPath $script:mofFileWhenUpdatingTeamingPolicyWithInheritSettingsSetToTruePath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                $startDscConfigurationParametersWhenAddingVirtualPortGroupAndStandardSwitch = @{
                    Path = $script:mofFileWhenAddingVirtualPortGroupAndStandardSwitchPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                $startDscConfigurationParametersWhenUpdatingTeamingPolicyWithInheritSettingsSetToTrue = @{
                    Path = $script:mofFileWhenUpdatingTeamingPolicyWithInheritSettingsSetToTruePath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParametersWhenAddingVirtualPortGroupAndStandardSwitch
                Start-DscConfiguration @startDscConfigurationParametersWhenUpdatingTeamingPolicyWithInheritSettingsSetToTrue
            }

            It 'Should apply the MOF without throwing' {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenUpdatingTeamingPolicyWithInheritSettingsSetToTruePath
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
                $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configWhenUpdatingTeamingPolicyWithInheritSettingsSetToTrue }

                # Assert
                $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
                $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.Name
                $configuration.Name | Should -Be $script:configurationData.AllNodes.VirtualPortGroupName
                $configuration.Ensure | Should -Be 'Present'
                $configuration.FailbackEnabled | Should -Be $script:configurationData.AllNodes.FailbackEnabled
                $configuration.LoadBalancingPolicy | Should -Be $script:configurationData.AllNodes.LoadBalancingPolicy
                $configuration.ActiveNic | Should -Be $script:configurationData.AllNodes.Nic
                $configuration.StandbyNic | Should -Be $script:configurationData.AllNodes.DefaultStandbyNic
                $configuration.UnusedNic | Should -Be $script:configurationData.AllNodes.DefaultUnusedNic
                $configuration.NetworkFailoverDetectionPolicy | Should -Be $script:configurationData.AllNodes.NetworkFailoverDetectionPolicyBeaconProbing
                $configuration.NotifySwitches | Should -Be $script:configurationData.AllNodes.NotifySwitches
                $configuration.InheritFailback | Should -Be $true
                $configuration.InheritFailoverOrder | Should -Be $true
                $configuration.InheritLoadBalancingPolicy | Should -Be $true
                $configuration.InheritNetworkFailoverDetectionPolicy | Should -Be $true
                $configuration.InheritNotifySwitches | Should -Be $true
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange
                $testDscConfigurationParameters = @{
                    ReferenceConfiguration = "$script:mofFileWhenUpdatingTeamingPolicyWithInheritSettingsSetToTruePath\$($script:configurationData.AllNodes.NodeName).mof"
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act && Assert
                (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
            }

            AfterAll {
                # Arrange
                & $script:configWhenRemovingVirtualPortGroupAndStandardSwitch `
                    -OutputPath $script:mofFileWhenRemovingVirtualPortGroupAndStandardSwitchPath `
                    -ConfigurationData $script:configurationData `
                    -ErrorAction Stop

                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWhenRemovingVirtualPortGroupAndStandardSwitchPath
                    ComputerName = $script:configurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters

                Remove-Item -Path $script:mofFileWhenAddingVirtualPortGroupAndStandardSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
                Remove-Item -Path $script:mofFileWhenUpdatingTeamingPolicyWithInheritSettingsSetToTruePath -Recurse -Confirm:$false -ErrorAction Stop
                Remove-Item -Path $script:mofFileWhenRemovingVirtualPortGroupAndStandardSwitchPath -Recurse -Confirm:$false -ErrorAction Stop
            }
        }
    }
}
finally {
    Disconnect-VIServer -Server $Server -Confirm:$false
}
