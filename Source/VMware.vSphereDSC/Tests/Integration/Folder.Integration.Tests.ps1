<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]
    $Name,

    [Parameter(Mandatory = $true)]
    [string]
    $Server,

    [Parameter(Mandatory = $true)]
    [string]
    $User,

    [Parameter(Mandatory = $true)]
    [string]
    $Password
)

# Mandatory Integration Tests parameter unused so set to null.
$Name = $null

$script:dscResourceName = 'Folder'
$script:moduleFolderPath = (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase
$script:integrationTestsFolderPath = Join-Path (Join-Path $moduleFolderPath 'Tests') 'Integration'
$script:configurationFile = "$script:integrationTestsFolderPath\Configurations\$($script:dscResourceName)\$($script:dscResourceName)_Config.ps1"

$script:configWithFolderToAddInInventory = "$($script:dscResourceName)_WithFolderToAddInInventory_Config"
$script:configWithFolderToAddInDatacenter = "$($script:dscResourceName)_WithFolderToAddInDatacenter_Config"
$script:configWithFolderToRemoveInInventory = "$($script:dscResourceName)_WithFolderToRemoveInInventory_Config"
$script:configWithFolderToRemoveInDatacenter = "$($script:dscResourceName)_WithFolderToRemoveInDatacenter_Config"

$script:viServer = Connect-VIServer -Server $Server -User $User -Password $Password

$script:folderName = 'MyTestFolder'
$script:folderPath = [string]::Empty
$script:datacenter = 'Datacenter'

$script:resourceWithFolderToAddInInventory = @{
    Ensure = 'Present'
    FolderType = 'Datacenter'
    Datacenter = [string]::Empty
}

$script:resourceWithFolderToAddInDatacenter = @{
    Ensure = 'Present'
    FolderType = 'Vm'
}

$script:resourceWithFolderToRemoveInInventory = @{
    Ensure = 'Absent'
    FolderType = 'Datacenter'
    Datacenter = [string]::Empty
}

$script:resourceWithFolderToRemoveInDatacenter = @{
    Ensure = 'Absent'
    FolderType = 'Vm'
}

. $script:configurationFile -Server $Server -User $User -Password $Password

$script:mofFileWithFolderToAddInInventoryPath = "$script:integrationTestsFolderPath\$($script:configWithFolderToAddInInventory)\"
$script:mofFileWithFolderToAddInDatacenterPath = "$script:integrationTestsFolderPath\$($script:configWithFolderToAddInDatacenter)\"
$script:mofFileWithFolderToRemoveInInventoryPath = "$script:integrationTestsFolderPath\$($script:configWithFolderToRemoveInInventory)"
$script:mofFileWithFolderToRemoveInDatacenterPath = "$script:integrationTestsFolderPath\$($script:configWithFolderToRemoveInDatacenter)"

function Invoke-TestSetup {
    $inventoryRootFolderAsViewObject = Get-View -Server $script:viServer -Id $script:viServer.ExtensionData.Content.RootFolder
    $inventoryRootFolder = Get-Inventory -Server $script:viServer -Id $inventoryRootFolderAsViewObject.MoRef

    # Folder Location is the root folder of the Inventory.
    $folderWithInventoryRootFolderAsLocationParams = @{
        Server = $script:viServer
        Name = $script:folderName
        Location = $inventoryRootFolder
        Confirm = $false
        ErrorAction = 'Stop'
    }

    New-Folder @folderWithInventoryRootFolderAsLocationParams

    $datacenter = Get-Datacenter -Server $script:viServer -Name $script:datacenter -ErrorAction SilentlyContinue | Where-Object { $_.ParentFolderId -eq $inventoryRootFolder.Id }
    if ($null -eq $datacenter) {
        throw "Datacenter $($script:datacenter) was not found in $($script:viServer.Name)."
    }

    $vmFolderOfDatacenterAsViewObject = Get-View -Server $script:viServer -Id $datacenter.ExtensionData.VmFolder
    $vmFolderOfDatacenter = Get-Inventory -Server $script:viServer -Id $vmFolderOfDatacenterAsViewObject.MoRef

    # Folder Location is the Vm folder of the Datacenter.
    $folderWithDatacenterVmFolderAsLocationParams = @{
        Server = $script:viServer
        Name = $script:folderName
        Location = $vmFolderOfDatacenter
        Confirm = $false
        ErrorAction = 'Stop'
    }

    New-Folder @folderWithDatacenterVmFolderAsLocationParams
}

function Invoke-TestCleanup {
    Get-Folder -Server $script:viServer -Name $script:folderName -ErrorAction SilentlyContinue | Remove-Folder -Server $script:viServer -Confirm:$false
}

try {
    Describe "$($script:dscResourceName)_Integration" {
        Context "When using configuration $($script:configWithFolderToAddInInventory)" {
            AfterAll {
                Invoke-TestCleanup
            }

            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithFolderToAddInInventoryPath
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters
            }

            It 'Should compile and apply the MOF without throwing' {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithFolderToAddInInventoryPath
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Assert
                { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                # Arrange && Act && Assert
                { Get-DscConfiguration } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration and all parameters should match' {
                # Arrange && Act
                $configuration = Get-DscConfiguration

                # Assert
                $configuration.Server | Should -Be $Server
                $configuration.Name | Should -Be $script:folderName
                $configuration.Path | Should -Be $script:folderPath
                $configuration.Ensure | Should -Be $script:resourceWithFolderToAddInInventory.Ensure
                $configuration.FolderType | Should -Be $script:resourceWithFolderToAddInInventory.FolderType
                $configuration.Datacenter | Should -Be $script:resourceWithFolderToAddInInventory.Datacenter
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }
        }

        Context "When using configuration $($script:configWithFolderToAddInDatacenter)" {
            AfterAll {
                Invoke-TestCleanup
            }

            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithFolderToAddInDatacenterPath
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters
            }

            It 'Should compile and apply the MOF without throwing' {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithFolderToAddInDatacenterPath
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Assert
                { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                # Arrange && Act && Assert
                { Get-DscConfiguration } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration and all parameters should match' {
                # Arrange && Act
                $configuration = Get-DscConfiguration

                # Assert
                $configuration.Server | Should -Be $Server
                $configuration.Name | Should -Be $script:folderName
                $configuration.Path | Should -Be $script:folderPath
                $configuration.Ensure | Should -Be $script:resourceWithFolderToAddInDatacenter.Ensure
                $configuration.FolderType | Should -Be $script:resourceWithFolderToAddInDatacenter.FolderType
                $configuration.Datacenter | Should -Be $script:datacenter
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }
        }

        Context "When using configuration $($script:configWithFolderToRemoveInInventory)" {
            BeforeAll {
                Invoke-TestSetup
            }

            AfterAll {
                Invoke-TestCleanup
            }

            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithFolderToRemoveInInventoryPath
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters
            }

            It 'Should compile and apply the MOF without throwing' {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithFolderToRemoveInInventoryPath
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Assert
                { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                # Arrange && Act && Assert
                { Get-DscConfiguration } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration and all parameters should match' {
                # Arrange && Act
                $configuration = Get-DscConfiguration

                # Assert
                $configuration.Server | Should -Be $Server
                $configuration.Name | Should -Be $script:folderName
                $configuration.Path | Should -Be $script:folderPath
                $configuration.Ensure | Should -Be $script:resourceWithFolderToRemoveInInventory.Ensure
                $configuration.FolderType | Should -Be $script:resourceWithFolderToRemoveInInventory.FolderType
                $configuration.Datacenter | Should -Be $script:resourceWithFolderToRemoveInInventory.Datacenter
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }
        }

        Context "When using configuration $($script:configWithFolderToRemoveInDatacenter)" {
            BeforeAll {
                Invoke-TestSetup
            }

            AfterAll {
                Invoke-TestCleanup
            }

            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithFolderToRemoveInDatacenterPath
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters
            }

            It 'Should compile and apply the MOF without throwing' {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithFolderToRemoveInDatacenterPath
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Assert
                { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                # Arrange && Act && Assert
                { Get-DscConfiguration } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration and all parameters should match' {
                # Arrange && Act
                $configuration = Get-DscConfiguration

                # Assert
                $configuration.Server | Should -Be $Server
                $configuration.Name | Should -Be $script:folderName
                $configuration.Path | Should -Be $script:folderPath
                $configuration.Ensure | Should -Be $script:resourceWithFolderToRemoveInDatacenter.Ensure
                $configuration.FolderType | Should -Be $script:resourceWithFolderToRemoveInDatacenter.FolderType
                $configuration.Datacenter | Should -Be $script:datacenter
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }
        }
    }
}
finally {
    Disconnect-VIServer -Server $Server -Confirm:$false
}
