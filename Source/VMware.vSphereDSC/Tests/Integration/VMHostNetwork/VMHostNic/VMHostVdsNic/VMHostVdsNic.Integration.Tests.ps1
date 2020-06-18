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

    [Parameter()]
    [string]
    $Name
)

<#
    The VMHostVdsNic DSC Resource Integration Tests require a vCenter Server with at
    least one Datacenter and at least one VMHost located in that Datacenter.
#>

# The 'Name' parameter is not used in the Integration Tests, so it is set to $null.
$Name = $null

$newObjectParamsForCredential = @{
    TypeName = 'System.Management.Automation.PSCredential'
    ArgumentList = @(
        $User,
        (ConvertTo-SecureString -String $Password -AsPlainText -Force)
    )
}
$script:Credential = New-Object @newObjectParamsForCredential

$script:DscResourceName = 'VMHostVdsNic'
$script:ConfigurationsPath = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DscResourceName)_Config.ps1"

. "$PSScriptRoot\$script:DscResourceName.Integration.Tests.Helpers.ps1"
Test-Setup

$script:ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
            Server = $Server
            Credential = $script:Credential
            VMHostVdsNicDscResourceName = 'VMHostVdsNic'
            VMHostName = $script:VMHost.Name
            VDSwitchName = $script:VDSwitch.Name
            VDPortGroupName = $script:VDPortGroup.Name
            VMKernelNicName = $script:VMKernelNic.Name
            IP = '10.23.112.245'
            SubnetMask = '255.255.255.0'
            Mtu = 4000
            VMotionEnabled = $true
            VsanTrafficEnabled = $true
        }
    )
}

. $script:ConfigurationsPath -Verbose:$true -ErrorAction Stop

$script:EnableVMotionAndVsanTrafficConfigurationName = "$($script:DscResourceName)_EnableVMotionAndVsanTraffic_Config"
$script:UpdateIPSubnetMaskAndMTUConfigurationName = "$($script:DscResourceName)_UpdateIPSubnetMaskAndMTU_Config"
$script:RemoveVMKernelNicConfigurationName = "$($script:DscResourceName)_RemoveVMKernelNic_Config"

$script:EnableVMotionAndVsanTrafficMofFilePath = Join-Path -Path $PSScriptRoot -ChildPath $script:EnableVMotionAndVsanTrafficConfigurationName
$script:UpdateIPSubnetMaskAndMTUMofFilePath = Join-Path -Path $PSScriptRoot -ChildPath $script:UpdateIPSubnetMaskAndMTUConfigurationName
$script:RemoveVMKernelNicMofFilePath = Join-Path -Path $PSScriptRoot -ChildPath $script:RemoveVMKernelNicConfigurationName

Describe "$($script:DscResourceName)_Integration" {
    AfterAll {
        # Arrange
        & $script:RemoveVMKernelNicConfigurationName `
            -OutputPath $script:RemoveVMKernelNicMofFilePath `
            -ConfigurationData $script:ConfigurationData `
            -ErrorAction Stop

        $startDscConfigurationParamsRemoveVMKernelNic = @{
            Path = $script:RemoveVMKernelNicMofFilePath
            ComputerName = $script:ConfigurationData.AllNodes.NodeName
            Wait = $true
            Force = $true
            Verbose = $true
            ErrorAction = 'Stop'
        }

        # Act && Assert
        { Start-DscConfiguration @startDscConfigurationParamsRemoveVMKernelNic } | Should -Not -Throw
        Test-CleanUp

        Remove-Item -Path $script:RemoveVMKernelNicMofFilePath -Recurse -Confirm:$false -Verbose:$true -ErrorAction Stop
    }

    Context 'When enabling VMotion and Vsan traffic' {
        BeforeAll {
            # Arrange
            & $script:EnableVMotionAndVsanTrafficConfigurationName `
                -OutputPath $script:EnableVMotionAndVsanTrafficMofFilePath `
                -ConfigurationData $script:ConfigurationData `
                -ErrorAction Stop

            $startDscConfigurationParamsEnableVMotionAndVsanTraffic = @{
                Path = $script:EnableVMotionAndVsanTrafficMofFilePath
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParamsEnableVMotionAndVsanTraffic } | Should -Not -Throw

            It 'Should compile and apply the MOF without throwing' {
                # Arrange
                & $script:EnableVMotionAndVsanTrafficConfigurationName `
                    -OutputPath $script:EnableVMotionAndVsanTrafficMofFilePath `
                    -ConfigurationData $script:ConfigurationData `
                    -ErrorAction Stop

                $startDscConfigurationParamsEnableVMotionAndVsanTraffic = @{
                    Path = $script:EnableVMotionAndVsanTrafficMofFilePath
                    ComputerName = $script:ConfigurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act && Assert
                { Start-DscConfiguration @startDscConfigurationParamsEnableVMotionAndVsanTraffic } | Should -Not -Throw
            }
        }

        It 'Should be able to call Test-DscConfiguration without throwing' {
            # Arrange
            $joinPathParams = @{
                Path = $script:EnableVMotionAndVsanTrafficMofFilePath
                ChildPath = "$($script:ConfigurationData.AllNodes.NodeName).mof"
            }

            $testDscConfigurationParams = @{
                ReferenceConfiguration = Join-Path @joinPathParams
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Test-DscConfiguration @testDscConfigurationParams } | Should -Not -Throw
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $joinPathParams = @{
                Path = $script:EnableVMotionAndVsanTrafficMofFilePath
                ChildPath = "$($script:ConfigurationData.AllNodes.NodeName).mof"
            }

            $testDscConfigurationParams = @{
                ReferenceConfiguration = Join-Path @joinPathParams
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParams).InDesiredState | Should -BeTrue
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            # Arrange && Act && Assert
            { Get-DscConfiguration -Verbose:$true -ErrorAction Stop } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration and all parameters should match' {
            # Arrange
            $whereObjectParams = @{
                FilterScript = {
                    $_.ConfigurationName -eq $script:EnableVMotionAndVsanTrafficConfigurationName
                }
            }

            # Act
            $VMHostVdsNicDscResource = Get-DscConfiguration -Verbose:$true -ErrorAction Stop | Where-Object @whereObjectParams

            # Assert
            $VMHostVdsNicDscResource.Server | Should -Be $script:ConfigurationData.AllNodes.Server
            $VMHostVdsNicDscResource.Name | Should -Be $script:ConfigurationData.AllNodes.VMKernelNicName
            $VMHostVdsNicDscResource.VMHostName | Should -Be $script:ConfigurationData.AllNodes.VMHostName
            $VMHostVdsNicDscResource.VdsName | Should -Be $script:ConfigurationData.AllNodes.VDSwitchName
            $VMHostVdsNicDscResource.PortGroupName | Should -Be $script:ConfigurationData.AllNodes.VDPortGroupName
            $VMHostVdsNicDscResource.Ensure | Should -Be 'Present'
            $VMHostVdsNicDscResource.VMotionEnabled | Should -Be $script:ConfigurationData.AllNodes.VMotionEnabled
            $VMHostVdsNicDscResource.VsanTrafficEnabled | Should -Be $script:ConfigurationData.AllNodes.VsanTrafficEnabled
        }

        AfterAll {
            Remove-Item -Path $script:EnableVMotionAndVsanTrafficMofFilePath -Recurse -Confirm:$false -Verbose:$true -ErrorAction Stop
        }
    }

    Context 'When updating the IP address, Subnet mask and MTU size' {
        BeforeAll {
            # Arrange
            & $script:UpdateIPSubnetMaskAndMTUConfigurationName `
                -OutputPath $script:UpdateIPSubnetMaskAndMTUMofFilePath `
                -ConfigurationData $script:ConfigurationData `
                -ErrorAction Stop

            $startDscConfigurationParamsUpdateIPSubnetMaskAndMTU = @{
                Path = $script:UpdateIPSubnetMaskAndMTUMofFilePath
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParamsUpdateIPSubnetMaskAndMTU } | Should -Not -Throw

            It 'Should compile and apply the MOF without throwing' {
                # Arrange
                & $script:UpdateIPSubnetMaskAndMTUConfigurationName `
                    -OutputPath $script:UpdateIPSubnetMaskAndMTUMofFilePath `
                    -ConfigurationData $script:ConfigurationData `
                    -ErrorAction Stop

                $startDscConfigurationParamsUpdateIPSubnetMaskAndMTU = @{
                    Path = $script:UpdateIPSubnetMaskAndMTUMofFilePath
                    ComputerName = $script:ConfigurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act && Assert
                { Start-DscConfiguration @startDscConfigurationParamsUpdateIPSubnetMaskAndMTU } | Should -Not -Throw
            }
        }

        It 'Should be able to call Test-DscConfiguration without throwing' {
            # Arrange
            $joinPathParams = @{
                Path = $script:UpdateIPSubnetMaskAndMTUMofFilePath
                ChildPath = "$($script:ConfigurationData.AllNodes.NodeName).mof"
            }

            $testDscConfigurationParams = @{
                ReferenceConfiguration = Join-Path @joinPathParams
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Test-DscConfiguration @testDscConfigurationParams } | Should -Not -Throw
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $joinPathParams = @{
                Path = $script:UpdateIPSubnetMaskAndMTUMofFilePath
                ChildPath = "$($script:ConfigurationData.AllNodes.NodeName).mof"
            }

            $testDscConfigurationParams = @{
                ReferenceConfiguration = Join-Path @joinPathParams
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParams).InDesiredState | Should -BeTrue
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            # Arrange && Act && Assert
            { Get-DscConfiguration -Verbose:$true -ErrorAction Stop } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration and all parameters should match' {
            # Arrange
            $whereObjectParams = @{
                FilterScript = {
                    $_.ConfigurationName -eq $script:UpdateIPSubnetMaskAndMTUConfigurationName
                }
            }

            # Act
            $VMHostVdsNicDscResource = Get-DscConfiguration -Verbose:$true -ErrorAction Stop | Where-Object @whereObjectParams

            # Assert
            $VMHostVdsNicDscResource.Server | Should -Be $script:ConfigurationData.AllNodes.Server
            $VMHostVdsNicDscResource.Name | Should -Be $script:ConfigurationData.AllNodes.VMKernelNicName
            $VMHostVdsNicDscResource.VMHostName | Should -Be $script:ConfigurationData.AllNodes.VMHostName
            $VMHostVdsNicDscResource.VdsName | Should -Be $script:ConfigurationData.AllNodes.VDSwitchName
            $VMHostVdsNicDscResource.PortGroupName | Should -Be $script:ConfigurationData.AllNodes.VDPortGroupName
            $VMHostVdsNicDscResource.Ensure | Should -Be 'Present'
            $VMHostVdsNicDscResource.IP | Should -Be $script:ConfigurationData.AllNodes.IP
            $VMHostVdsNicDscResource.SubnetMask | Should -Be $script:ConfigurationData.AllNodes.SubnetMask
            $VMHostVdsNicDscResource.Mtu | Should -Be $script:ConfigurationData.AllNodes.Mtu
        }

        AfterAll {
            Remove-Item -Path $script:UpdateIPSubnetMaskAndMTUMofFilePath -Recurse -Confirm:$false -Verbose:$true -ErrorAction Stop
        }
    }

    Context 'When removing the VMKernel NIC' {
        BeforeAll {
            # Arrange
            & $script:RemoveVMKernelNicConfigurationName `
                -OutputPath $script:RemoveVMKernelNicMofFilePath `
                -ConfigurationData $script:ConfigurationData `
                -ErrorAction Stop

            $startDscConfigurationParamsRemoveVMKernelNic = @{
                Path = $script:RemoveVMKernelNicMofFilePath
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParamsRemoveVMKernelNic } | Should -Not -Throw

            It 'Should compile and apply the MOF without throwing' {
                # Arrange
                & $script:RemoveVMKernelNicConfigurationName `
                    -OutputPath $script:RemoveVMKernelNicMofFilePath `
                    -ConfigurationData $script:ConfigurationData `
                    -ErrorAction Stop

                $startDscConfigurationParamsRemoveVMKernelNic = @{
                    Path = $script:RemoveVMKernelNicMofFilePath
                    ComputerName = $script:ConfigurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act && Assert
                { Start-DscConfiguration @startDscConfigurationParamsRemoveVMKernelNic } | Should -Not -Throw
            }
        }

        It 'Should be able to call Test-DscConfiguration without throwing' {
            # Arrange
            $joinPathParams = @{
                Path = $script:RemoveVMKernelNicMofFilePath
                ChildPath = "$($script:ConfigurationData.AllNodes.NodeName).mof"
            }

            $testDscConfigurationParams = @{
                ReferenceConfiguration = Join-Path @joinPathParams
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Test-DscConfiguration @testDscConfigurationParams } | Should -Not -Throw
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $joinPathParams = @{
                Path = $script:RemoveVMKernelNicMofFilePath
                ChildPath = "$($script:ConfigurationData.AllNodes.NodeName).mof"
            }

            $testDscConfigurationParams = @{
                ReferenceConfiguration = Join-Path @joinPathParams
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParams).InDesiredState | Should -BeTrue
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            # Arrange && Act && Assert
            { Get-DscConfiguration -Verbose:$true -ErrorAction Stop } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration and all parameters should match' {
            # Arrange
            $whereObjectParams = @{
                FilterScript = {
                    $_.ConfigurationName -eq $script:RemoveVMKernelNicConfigurationName
                }
            }

            # Act
            $VMHostVdsNicDscResource = Get-DscConfiguration -Verbose:$true -ErrorAction Stop | Where-Object @whereObjectParams

            # Assert
            $VMHostVdsNicDscResource.Server | Should -Be $script:ConfigurationData.AllNodes.Server
            $VMHostVdsNicDscResource.Name | Should -Be $script:ConfigurationData.AllNodes.VMKernelNicName
            $VMHostVdsNicDscResource.VMHostName | Should -Be $script:ConfigurationData.AllNodes.VMHostName
            $VMHostVdsNicDscResource.VdsName | Should -Be $script:ConfigurationData.AllNodes.VDSwitchName
            $VMHostVdsNicDscResource.PortGroupName | Should -Be $script:ConfigurationData.AllNodes.VDPortGroupName
            $VMHostVdsNicDscResource.Ensure | Should -Be 'Absent'
        }

        AfterAll {
            Remove-Item -Path $script:RemoveVMKernelNicMofFilePath -Recurse -Confirm:$false -Verbose:$true -ErrorAction Stop
        }
    }
}
