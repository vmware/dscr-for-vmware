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
    The VMHostIScsiHbaVMKernelNic DSC Resource Integration Tests require a VMHost with at
    least one iSCSI Host Bus Adapter.
#>

$newObjectParamsForCredential = @{
    TypeName = 'System.Management.Automation.PSCredential'
    ArgumentList = @(
        $User,
        (ConvertTo-SecureString -String $Password -AsPlainText -Force)
    )
}
$script:Credential = New-Object @newObjectParamsForCredential

$script:DscResourceName = 'VMHostIScsiHbaVMKernelNic'
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
            VMHostName = $Name
            StandardSwitchDscResourceName = 'StandardSwitch'
            StandardSwitchDscResourceId = '[StandardSwitch]StandardSwitch'
            ManagementStandardPortGroupDscResourceName = 'ManagementStandardPortGroup'
            ManagementStandardPortGroupDscResourceId = '[StandardPortGroup]ManagementStandardPortGroup'
            VMotionStandardPortGroupDscResourceName = 'VMotionStandardPortGroup'
            VMotionStandardPortGroupDscResourceId = '[StandardPortGroup]VMotionStandardPortGroup'
            ManagementVMHostVssNicResourceName = 'ManagementVMHostVssNic'
            ManagementVMHostVssNicResourceId = '[VMHostVssNic]ManagementVMHostVssNic'
            VMotionVMHostVssNicResourceName = 'VMotionVMHostVssNic'
            VMotionVMHostVssNicResourceId = '[VMHostVssNic]VMotionVMHostVssNic'
            VMHostIScsiHbaVMKernelNicDscResourceName = 'VMHostIScsiHbaVMKernelNic'
            StandardSwitchName = 'MyTestStandardSwitch'
            PhysicalNicNames = $script:PhysicalNicNames
            ManagementStandardPortGroupName = 'MyTestManagementStandardPortGroup'
            VMotionStandardPortGroupName = 'MyTestvMotionStandardPortGroup'
            ManagementTrafficEnabled = $true
            VMotionEnabled = $true
            IScsiHbaName = $script:IScsiHbaName
            UnbindVMKernelNicsForce = $true
        }
    )
}

. $script:ConfigurationsPath -Verbose:$true -ErrorAction Stop

$script:CreateStandardSwitchStandardPortGroupsAndVMKernelNicsConfigurationName = "$($script:DscResourceName)_CreateStandardSwitchStandardPortGroupsAndVMKernelNics_Config"
$script:BindVMKernelNicsToIscsiHbaConfigurationName = "$($script:DscResourceName)_BindVMKernelNicsToIscsiHba_Config"
$script:UnbindVMKernelNicsToIscsiHbaConfigurationName = "$($script:DscResourceName)_UnbindVMKernelNicsToIscsiHba_Config"
$script:RemoveStandardSwitchStandardPortGroupsAndVMKernelNicsConfigurationName = "$($script:DscResourceName)_RemoveStandardSwitchStandardPortGroupsAndVMKernelNics_Config"

$script:CreateStandardSwitchStandardPortGroupsAndVMKernelNicsMofFilePath = Join-Path -Path $PSScriptRoot -ChildPath $script:CreateStandardSwitchStandardPortGroupsAndVMKernelNicsConfigurationName
$script:BindVMKernelNicsToIscsiHbaMofFilePath = Join-Path -Path $PSScriptRoot -ChildPath $script:BindVMKernelNicsToIscsiHbaConfigurationName
$script:UnbindVMKernelNicsToIscsiHbaMofFilePath = Join-Path -Path $PSScriptRoot -ChildPath $script:UnbindVMKernelNicsToIscsiHbaConfigurationName
$script:RemoveStandardSwitchStandardPortGroupsAndVMKernelNicsMofFilePath = Join-Path -Path $PSScriptRoot -ChildPath $script:RemoveStandardSwitchStandardPortGroupsAndVMKernelNicsConfigurationName

Describe "$($script:DscResourceName)_Integration" {
    BeforeAll {
        # Arrange
        & $script:CreateStandardSwitchStandardPortGroupsAndVMKernelNicsConfigurationName `
            -OutputPath $script:CreateStandardSwitchStandardPortGroupsAndVMKernelNicsMofFilePath `
            -ConfigurationData $script:ConfigurationData `
            -ErrorAction Stop

        $startDscConfigurationParamsCreateStandardSwitchStandardPortGroupsAndVMKernelNics = @{
            Path = $script:CreateStandardSwitchStandardPortGroupsAndVMKernelNicsMofFilePath
            ComputerName = $script:ConfigurationData.AllNodes.NodeName
            Wait = $true
            Force = $true
            Verbose = $true
            ErrorAction = 'Stop'
        }

        # Act && Assert
        { Start-DscConfiguration @startDscConfigurationParamsCreateStandardSwitchStandardPortGroupsAndVMKernelNics } | Should -Not -Throw

        Get-VMKernelNicNames
    }

    AfterAll {
        # Arrange
        & $script:RemoveStandardSwitchStandardPortGroupsAndVMKernelNicsConfigurationName `
            -OutputPath $script:RemoveStandardSwitchStandardPortGroupsAndVMKernelNicsMofFilePath `
            -ConfigurationData $script:ConfigurationData `
            -ErrorAction Stop

        $startDscConfigurationParamsRemoveStandardSwitchStandardPortGroupsAndVMKernelNics = @{
            Path = $script:RemoveStandardSwitchStandardPortGroupsAndVMKernelNicsMofFilePath
            ComputerName = $script:ConfigurationData.AllNodes.NodeName
            Wait = $true
            Force = $true
            Verbose = $true
            ErrorAction = 'Stop'
        }

        # Act && Assert
        { Start-DscConfiguration @startDscConfigurationParamsRemoveStandardSwitchStandardPortGroupsAndVMKernelNics } | Should -Not -Throw

        Remove-Item -Path $script:CreateStandardSwitchStandardPortGroupsAndVMKernelNicsMofFilePath -Recurse -Confirm:$false -ErrorAction Stop
        Remove-Item -Path $script:RemoveStandardSwitchStandardPortGroupsAndVMKernelNicsMofFilePath -Recurse -Confirm:$false -ErrorAction Stop
    }

    Context 'When binding VMKernel Network Adapters to iSCSI Host Bus Adapter' {
        BeforeAll {
            # Arrange
            & $script:UnbindVMKernelNicsToIscsiHbaConfigurationName `
                -OutputPath $script:UnbindVMKernelNicsToIscsiHbaMofFilePath `
                -ConfigurationData $script:ConfigurationData `
                -ErrorAction Stop

            $startDscConfigurationParamsUnbindVMKernelNicsToIscsiHba = @{
                Path = $script:UnbindVMKernelNicsToIscsiHbaMofFilePath
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParamsUnbindVMKernelNicsToIscsiHba } | Should -Not -Throw

            It 'Should compile and apply the MOF without throwing' {
                # Arrange
                & $script:BindVMKernelNicsToIscsiHbaConfigurationName `
                    -OutputPath $script:BindVMKernelNicsToIscsiHbaMofFilePath `
                    -ConfigurationData $script:ConfigurationData `
                    -ErrorAction Stop

                $startDscConfigurationParamsBindVMKernelNicsToIscsiHba = @{
                    Path = $script:BindVMKernelNicsToIscsiHbaMofFilePath
                    ComputerName = $script:ConfigurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act && Assert
                { Start-DscConfiguration @startDscConfigurationParamsBindVMKernelNicsToIscsiHba } | Should -Not -Throw
            }
        }

        It 'Should be able to call Test-DscConfiguration without throwing' {
            # Arrange
            $joinPathParams = @{
                Path = $script:BindVMKernelNicsToIscsiHbaMofFilePath
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
                Path = $script:BindVMKernelNicsToIscsiHbaMofFilePath
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
                    $_.ConfigurationName -eq $script:BindVMKernelNicsToIscsiHbaConfigurationName
                }
            }

            # Act
            $VMHostIScsiHbaVMKernelNicDscResource = Get-DscConfiguration -Verbose:$true -ErrorAction Stop | Where-Object @whereObjectParams

            # Assert
            $VMHostIScsiHbaVMKernelNicDscResource.Server | Should -Be $script:ConfigurationData.AllNodes.Server
            $VMHostIScsiHbaVMKernelNicDscResource.VMHostName | Should -Be $script:ConfigurationData.AllNodes.VMHostName
            $VMHostIScsiHbaVMKernelNicDscResource.IScsiHbaName | Should -Be $script:ConfigurationData.AllNodes.IScsiHbaName
            $VMHostIScsiHbaVMKernelNicDscResource.VMKernelNicNames | Should -Be $script:ConfigurationData.AllNodes.VMKernelNicNames
            $VMHostIScsiHbaVMKernelNicDscResource.Ensure | Should -Be 'Present'
            $VMHostIScsiHbaVMKernelNicDscResource.Force | Should -BeNullOrEmpty
        }

        AfterAll {
            & $script:UnbindVMKernelNicsToIscsiHbaConfigurationName `
                -OutputPath $script:UnbindVMKernelNicsToIscsiHbaMofFilePath `
                -ConfigurationData $script:ConfigurationData `
                -ErrorAction Stop

            $startDscConfigurationParamsUnbindVMKernelNicsToIscsiHba = @{
                Path = $script:UnbindVMKernelNicsToIscsiHbaMofFilePath
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParamsUnbindVMKernelNicsToIscsiHba } | Should -Not -Throw

            Remove-Item -Path $script:BindVMKernelNicsToIscsiHbaMofFilePath -Recurse -Confirm:$false -Verbose:$true -ErrorAction Stop
            Remove-Item -Path $script:UnbindVMKernelNicsToIscsiHbaMofFilePath -Recurse -Confirm:$false -Verbose:$true -ErrorAction Stop
        }
    }

    Context 'When unbinding VMKernel Network Adapters from iSCSI Host Bus Adapter' {
        BeforeAll {
            # Arrange
            & $script:BindVMKernelNicsToIscsiHbaConfigurationName `
                -OutputPath $script:BindVMKernelNicsToIscsiHbaMofFilePath `
                -ConfigurationData $script:ConfigurationData `
                -ErrorAction Stop

            $startDscConfigurationParamsBindVMKernelNicsToIscsiHba = @{
                Path = $script:BindVMKernelNicsToIscsiHbaMofFilePath
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParamsBindVMKernelNicsToIscsiHba } | Should -Not -Throw

            It 'Should compile and apply the MOF without throwing' {
                # Arrange
                & $script:UnbindVMKernelNicsToIscsiHbaConfigurationName `
                    -OutputPath $script:UnbindVMKernelNicsToIscsiHbaMofFilePath `
                    -ConfigurationData $script:ConfigurationData `
                    -ErrorAction Stop

                $startDscConfigurationParamsUnbindVMKernelNicsToIscsiHba = @{
                    Path = $script:UnbindVMKernelNicsToIscsiHbaMofFilePath
                    ComputerName = $script:ConfigurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act && Assert
                { Start-DscConfiguration @startDscConfigurationParamsUnbindVMKernelNicsToIscsiHba } | Should -Not -Throw
            }
        }

        It 'Should be able to call Test-DscConfiguration without throwing' {
            # Arrange
            $joinPathParams = @{
                Path = $script:UnbindVMKernelNicsToIscsiHbaMofFilePath
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
                Path = $script:UnbindVMKernelNicsToIscsiHbaMofFilePath
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
                    $_.ConfigurationName -eq $script:UnbindVMKernelNicsToIscsiHbaConfigurationName
                }
            }

            # Act
            $VMHostIScsiHbaVMKernelNicDscResource = Get-DscConfiguration -Verbose:$true -ErrorAction Stop | Where-Object @whereObjectParams

            # Assert
            $VMHostIScsiHbaVMKernelNicDscResource.Server | Should -Be $script:ConfigurationData.AllNodes.Server
            $VMHostIScsiHbaVMKernelNicDscResource.VMHostName | Should -Be $script:ConfigurationData.AllNodes.VMHostName
            $VMHostIScsiHbaVMKernelNicDscResource.IScsiHbaName | Should -Be $script:ConfigurationData.AllNodes.IScsiHbaName
            $VMHostIScsiHbaVMKernelNicDscResource.VMKernelNicNames | Should -Be $script:ConfigurationData.AllNodes.VMKernelNicNames
            $VMHostIScsiHbaVMKernelNicDscResource.Ensure | Should -Be 'Absent'
            $VMHostIScsiHbaVMKernelNicDscResource.Force | Should -Be $script:ConfigurationData.AllNodes.UnbindVMKernelNicsForce
        }

        AfterAll {
            Remove-Item -Path $script:BindVMKernelNicsToIscsiHbaMofFilePath -Recurse -Confirm:$false -Verbose:$true -ErrorAction Stop
            Remove-Item -Path $script:UnbindVMKernelNicsToIscsiHbaMofFilePath -Recurse -Confirm:$false -Verbose:$true -ErrorAction Stop
        }
    }
}
