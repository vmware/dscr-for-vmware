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
    $VMHostName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $VMHostUser,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $VMHostPassword
)

. "$PSScriptRoot\vCenterVMHost.Integration.Tests.Helpers.ps1"

$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (ConvertTo-SecureString -String $Password -AsPlainText -Force)
$VMHostCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $VMHostUser, (ConvertTo-SecureString -String $VMHostPassword -AsPlainText -Force)

$script:dscResourceName = 'vCenterVMHost'
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
            VMHostName = $VMHostName
            VMHostCredential = $VMHostCredential
            DatacenterResourceName = 'Datacenter'
            FolderResourceName = 'Folder'
            ClusterResourceName = 'Cluster'
            vCenterVMHostResourceName = 'vCenterVMHost'
            DatacenterName = 'MyTestDatacenter'
            DatacenterLocation = [string]::Empty
            FolderName = 'MyTestFolder'
            FolderLocation = [string]::Empty
            HostFolderType = 'Host'
            ClusterName = 'MyTestCluster'
            ClusterLocation = 'MyTestFolder'
            DrsEnabled = $true
            VAppName = 'MyTestVApp'
            ResourcePoolName = 'MyTestResourcePool'
            ResourcePoolLocation = 'MyTestResourcePool/MyTestVApp/MyTestResourcePool'
            VMHostDatacenterLocation = [string]::Empty
            VMHostFolderLocation = 'MyTestFolder'
            VMHostClusterLocation = 'MyTestFolder/MyTestCluster'
            VMHostPort = 443
            Force = $true
        }
    )
}

$script:configCreateDatacenter = "$($script:dscResourceName)_CreateDatacenter_Config"
$script:configCreateFolder = "$($script:dscResourceName)_CreateFolder_Config"
$script:configCreateCluster = "$($script:dscResourceName)_CreateCluster_Config"
$script:configAddVMHostTovCenter = "$($script:dscResourceName)_AddVMHostTovCenter_Config"
$script:configMoveVMHostToFolder = "$($script:dscResourceName)_MoveVMHostToFolder_Config"
$script:configMoveVMHostToCluster = "$($script:dscResourceName)_MoveVMHostToCluster_Config"
$script:configMoveVMHostToClusterAndImportResourcePoolHierarchy = "$($script:dscResourceName)_MoveVMHostToClusterAndImportResourcePoolHierarchy_Config"
$script:configRemoveVMHostFromvCenter = "$($script:dscResourceName)_RemoveVMHostFromvCenter_Config"
$script:configRemoveCluster = "$($script:dscResourceName)_RemoveCluster_Config"
$script:configRemoveFolder = "$($script:dscResourceName)_RemoveFolder_Config"
$script:configRemoveDatacenter = "$($script:dscResourceName)_RemoveDatacenter_Config"

. $script:configurationFile -ErrorAction Stop

$script:mofFileCreateDatacenterPath = "$script:integrationTestsFolderPath\$script:configCreateDatacenter\"
$script:mofFileCreateFolderPath = "$script:integrationTestsFolderPath\$script:configCreateFolder\"
$script:mofFileCreateClusterPath = "$script:integrationTestsFolderPath\$script:configCreateCluster\"
$script:mofFileAddVMHostTovCenterPath = "$script:integrationTestsFolderPath\$script:configAddVMHostTovCenter\"
$script:mofFileMoveVMHostToFolderPath = "$script:integrationTestsFolderPath\$script:configMoveVMHostToFolder\"
$script:mofFileMoveVMHostToClusterPath = "$script:integrationTestsFolderPath\$script:configMoveVMHostToCluster\"
$script:mofFileMoveVMHostToClusterAndImportResourcePoolHierarchyPath = "$script:integrationTestsFolderPath\$script:configMoveVMHostToClusterAndImportResourcePoolHierarchy\"
$script:mofFileRemoveVMHostFromvCenterPath = "$script:integrationTestsFolderPath\$script:configRemoveVMHostFromvCenter\"
$script:mofFileRemoveClusterPath = "$script:integrationTestsFolderPath\$script:configRemoveCluster\"
$script:mofFileRemoveFolderPath = "$script:integrationTestsFolderPath\$script:configRemoveFolder\"
$script:mofFileRemoveDatacenterPath = "$script:integrationTestsFolderPath\$script:configRemoveDatacenter\"

Describe "$($script:dscResourceName)_Integration" {
    Context "When using configuration $script:configAddVMHostTovCenter" {
        BeforeAll {
            # Arrange
            & $script:configCreateDatacenter `
                -OutputPath $script:mofFileCreateDatacenterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configAddVMHostTovCenter `
                -OutputPath $script:mofFileAddVMHostTovCenterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersCreateDatacenter = @{
                Path = $script:mofFileCreateDatacenterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersAddVMHostTovCenter = @{
                Path = $script:mofFileAddVMHostTovCenterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersCreateDatacenter
            Start-DscConfiguration @startDscConfigurationParametersAddVMHostTovCenter
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileAddVMHostTovCenterPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configAddVMHostTovCenter }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.Name | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.Location | Should -Be $script:configurationData.AllNodes.VMHostDatacenterLocation
            $configuration.DatacenterName | Should -Be $script:configurationData.AllNodes.DatacenterName
            $configuration.DatacenterLocation | Should -Be $script:configurationData.AllNodes.DatacenterLocation
            $configuration.Ensure | Should -Be 'Present'
            $configuration.Port | Should -Be $script:configurationData.AllNodes.VMHostPort
            $configuration.Force | Should -Be $script:configurationData.AllNodes.Force
            $configuration.ResourcePoolLocation | Should -BeNullOrEmpty
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileAddVMHostTovCenterPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configRemoveVMHostFromvCenter `
                -OutputPath $script:mofFileRemoveVMHostFromvCenterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configRemoveDatacenter `
                -OutputPath $script:mofFileRemoveDatacenterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersRemoveVMHostFromvCenter = @{
                Path = $script:mofFileRemoveVMHostFromvCenterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersRemoveDatacenter = @{
                Path = $script:mofFileRemoveDatacenterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersRemoveVMHostFromvCenter
            Start-DscConfiguration @startDscConfigurationParametersRemoveDatacenter

            Remove-Item -Path $script:mofFileCreateDatacenterPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileAddVMHostTovCenterPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVMHostFromvCenterPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveDatacenterPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configMoveVMHostToFolder" {
        BeforeAll {
            # Arrange
            & $script:configCreateDatacenter `
                -OutputPath $script:mofFileCreateDatacenterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configCreateFolder `
                -OutputPath $script:mofFileCreateFolderPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configAddVMHostTovCenter `
                -OutputPath $script:mofFileAddVMHostTovCenterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configMoveVMHostToFolder `
                -OutputPath $script:mofFileMoveVMHostToFolderPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersCreateDatacenter = @{
                Path = $script:mofFileCreateDatacenterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersCreateFolder = @{
                Path = $script:mofFileCreateFolderPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersAddVMHostTovCenter = @{
                Path = $script:mofFileAddVMHostTovCenterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersMoveVMHostToFolder = @{
                Path = $script:mofFileMoveVMHostToFolderPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersCreateDatacenter
            Start-DscConfiguration @startDscConfigurationParametersCreateFolder
            Start-DscConfiguration @startDscConfigurationParametersAddVMHostTovCenter
            Start-DscConfiguration @startDscConfigurationParametersMoveVMHostToFolder
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileMoveVMHostToFolderPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configMoveVMHostToFolder }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.Name | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.Location | Should -Be $script:configurationData.AllNodes.VMHostFolderLocation
            $configuration.DatacenterName | Should -Be $script:configurationData.AllNodes.DatacenterName
            $configuration.DatacenterLocation | Should -Be $script:configurationData.AllNodes.DatacenterLocation
            $configuration.Ensure | Should -Be 'Present'
            $configuration.Port | Should -Be $script:configurationData.AllNodes.VMHostPort
            $configuration.Force | Should -BeNullOrEmpty
            $configuration.ResourcePoolLocation | Should -BeNullOrEmpty
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileMoveVMHostToFolderPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configRemoveVMHostFromvCenter `
                -OutputPath $script:mofFileRemoveVMHostFromvCenterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configRemoveFolder `
                -OutputPath $script:mofFileRemoveFolderPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configRemoveDatacenter `
                -OutputPath $script:mofFileRemoveDatacenterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersRemoveVMHostFromvCenter = @{
                Path = $script:mofFileRemoveVMHostFromvCenterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersRemoveFolder = @{
                Path = $script:mofFileRemoveFolderPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersRemoveDatacenter = @{
                Path = $script:mofFileRemoveDatacenterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersRemoveVMHostFromvCenter
            Start-DscConfiguration @startDscConfigurationParametersRemoveFolder
            Start-DscConfiguration @startDscConfigurationParametersRemoveDatacenter

            Remove-Item -Path $script:mofFileCreateDatacenterPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileCreateFolderPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileAddVMHostTovCenterPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileMoveVMHostToFolderPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVMHostFromvCenterPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveFolderPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveDatacenterPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configMoveVMHostToCluster" {
        BeforeAll {
            # Arrange
            & $script:configCreateDatacenter `
                -OutputPath $script:mofFileCreateDatacenterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configCreateFolder `
                -OutputPath $script:mofFileCreateFolderPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configCreateCluster `
                -OutputPath $script:mofFileCreateClusterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configAddVMHostTovCenter `
                -OutputPath $script:mofFileAddVMHostTovCenterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configMoveVMHostToCluster `
                -OutputPath $script:mofFileMoveVMHostToClusterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersCreateDatacenter = @{
                Path = $script:mofFileCreateDatacenterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersCreateFolder = @{
                Path = $script:mofFileCreateFolderPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersCreateCluster = @{
                Path = $script:mofFileCreateClusterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersAddVMHostTovCenter = @{
                Path = $script:mofFileAddVMHostTovCenterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersMoveVMHostToCluster = @{
                Path = $script:mofFileMoveVMHostToClusterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersCreateDatacenter
            Start-DscConfiguration @startDscConfigurationParametersCreateFolder
            Start-DscConfiguration @startDscConfigurationParametersCreateCluster
            Start-DscConfiguration @startDscConfigurationParametersAddVMHostTovCenter
            Start-DscConfiguration @startDscConfigurationParametersMoveVMHostToCluster
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileMoveVMHostToClusterPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configMoveVMHostToCluster }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.Name | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.Location | Should -Be $script:configurationData.AllNodes.VMHostClusterLocation
            $configuration.DatacenterName | Should -Be $script:configurationData.AllNodes.DatacenterName
            $configuration.DatacenterLocation | Should -Be $script:configurationData.AllNodes.DatacenterLocation
            $configuration.Ensure | Should -Be 'Present'
            $configuration.Port | Should -Be $script:configurationData.AllNodes.VMHostPort
            $configuration.Force | Should -BeNullOrEmpty
            $configuration.ResourcePoolLocation | Should -BeNullOrEmpty
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileMoveVMHostToClusterPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configRemoveCluster `
                -OutputPath $script:mofFileRemoveClusterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configRemoveFolder `
                -OutputPath $script:mofFileRemoveFolderPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configRemoveDatacenter `
                -OutputPath $script:mofFileRemoveDatacenterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersRemoveCluster = @{
                Path = $script:mofFileRemoveClusterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersRemoveFolder = @{
                Path = $script:mofFileRemoveFolderPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersRemoveDatacenter = @{
                Path = $script:mofFileRemoveDatacenterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersRemoveCluster
            Start-DscConfiguration @startDscConfigurationParametersRemoveFolder
            Start-DscConfiguration @startDscConfigurationParametersRemoveDatacenter

            Remove-Item -Path $script:mofFileCreateDatacenterPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileCreateFolderPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileCreateClusterPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileAddVMHostTovCenterPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileMoveVMHostToClusterPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveClusterPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveFolderPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveDatacenterPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configMoveVMHostToClusterAndImportResourcePoolHierarchy" {
        BeforeAll {
            # Arrange
            & $script:configCreateDatacenter `
                -OutputPath $script:mofFileCreateDatacenterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configCreateFolder `
                -OutputPath $script:mofFileCreateFolderPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configCreateCluster `
                -OutputPath $script:mofFileCreateClusterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configAddVMHostTovCenter `
                -OutputPath $script:mofFileAddVMHostTovCenterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configMoveVMHostToClusterAndImportResourcePoolHierarchy `
                -OutputPath $script:mofFileMoveVMHostToClusterAndImportResourcePoolHierarchyPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersCreateDatacenter = @{
                Path = $script:mofFileCreateDatacenterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersCreateFolder = @{
                Path = $script:mofFileCreateFolderPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersCreateCluster = @{
                Path = $script:mofFileCreateClusterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersAddVMHostTovCenter = @{
                Path = $script:mofFileAddVMHostTovCenterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersMoveVMHostToClusterAndImportResourcePoolHierarchy = @{
                Path = $script:mofFileMoveVMHostToClusterAndImportResourcePoolHierarchyPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersCreateDatacenter
            Start-DscConfiguration @startDscConfigurationParametersCreateFolder
            Start-DscConfiguration @startDscConfigurationParametersCreateCluster

            Invoke-ClusterSetup

            Start-DscConfiguration @startDscConfigurationParametersAddVMHostTovCenter
            Start-DscConfiguration @startDscConfigurationParametersMoveVMHostToClusterAndImportResourcePoolHierarchy
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileMoveVMHostToClusterAndImportResourcePoolHierarchyPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configMoveVMHostToClusterAndImportResourcePoolHierarchy }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.Name | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.Location | Should -Be $script:configurationData.AllNodes.VMHostClusterLocation
            $configuration.DatacenterName | Should -Be $script:configurationData.AllNodes.DatacenterName
            $configuration.DatacenterLocation | Should -Be $script:configurationData.AllNodes.DatacenterLocation
            $configuration.Ensure | Should -Be 'Present'
            $configuration.Port | Should -Be $script:configurationData.AllNodes.VMHostPort
            $configuration.Force | Should -BeNullOrEmpty
            $configuration.ResourcePoolLocation | Should -Be $script:configurationData.AllNodes.ResourcePoolLocation
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileMoveVMHostToClusterAndImportResourcePoolHierarchyPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configRemoveCluster `
                -OutputPath $script:mofFileRemoveClusterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configRemoveFolder `
                -OutputPath $script:mofFileRemoveFolderPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configRemoveDatacenter `
                -OutputPath $script:mofFileRemoveDatacenterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersRemoveCluster = @{
                Path = $script:mofFileRemoveClusterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersRemoveFolder = @{
                Path = $script:mofFileRemoveFolderPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersRemoveDatacenter = @{
                Path = $script:mofFileRemoveDatacenterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Invoke-ClusterCleanup

            Start-DscConfiguration @startDscConfigurationParametersRemoveCluster
            Start-DscConfiguration @startDscConfigurationParametersRemoveFolder
            Start-DscConfiguration @startDscConfigurationParametersRemoveDatacenter

            Remove-Item -Path $script:mofFileCreateDatacenterPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileCreateFolderPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileCreateClusterPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileAddVMHostTovCenterPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileMoveVMHostToClusterAndImportResourcePoolHierarchyPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveClusterPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveFolderPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveDatacenterPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configRemoveVMHostFromvCenter" {
        BeforeAll {
            # Arrange
            & $script:configCreateDatacenter `
                -OutputPath $script:mofFileCreateDatacenterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configAddVMHostTovCenter `
                -OutputPath $script:mofFileAddVMHostTovCenterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configRemoveVMHostFromvCenter `
                -OutputPath $script:mofFileRemoveVMHostFromvCenterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersCreateDatacenter = @{
                Path = $script:mofFileCreateDatacenterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersAddVMHostTovCenter = @{
                Path = $script:mofFileAddVMHostTovCenterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersRemoveVMHostFromvCenter = @{
                Path = $script:mofFileRemoveVMHostFromvCenterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersCreateDatacenter
            Start-DscConfiguration @startDscConfigurationParametersAddVMHostTovCenter
            Start-DscConfiguration @startDscConfigurationParametersRemoveVMHostFromvCenter
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileRemoveVMHostFromvCenterPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configRemoveVMHostFromvCenter }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.Name | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.Location | Should -Be $script:configurationData.AllNodes.VMHostDatacenterLocation
            $configuration.DatacenterName | Should -Be $script:configurationData.AllNodes.DatacenterName
            $configuration.DatacenterLocation | Should -Be $script:configurationData.AllNodes.DatacenterLocation
            $configuration.Ensure | Should -Be 'Absent'
            $configuration.Port | Should -BeNullOrEmpty
            $configuration.Force | Should -BeNullOrEmpty
            $configuration.ResourcePoolLocation | Should -BeNullOrEmpty
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileRemoveVMHostFromvCenterPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configRemoveDatacenter `
                -OutputPath $script:mofFileRemoveDatacenterPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileRemoveDatacenterPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileCreateDatacenterPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileAddVMHostTovCenterPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveVMHostFromvCenterPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveDatacenterPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }
}
