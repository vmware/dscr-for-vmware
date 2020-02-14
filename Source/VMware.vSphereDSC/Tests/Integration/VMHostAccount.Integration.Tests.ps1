<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

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

$script:dscResourceName = 'VMHostAccount'
$script:moduleFolderPath = (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase
$script:integrationTestsFolderPath = Join-Path (Join-Path $moduleFolderPath 'Tests') 'Integration'
$script:configurationFile = "$script:integrationTestsFolderPath\Configurations\$($script:dscResourceName)\$($script:dscResourceName)_Config.ps1"

$script:configWithVMHostAccountToAdd = "$($script:dscResourceName)_WithAccountToAdd_Config"
$script:configWithVMHostAccountToUpdate = "$($script:dscResourceName)_WithAccountToUpdate_Config"
$script:configWithVMHostAccountToRemove = "$($script:dscResourceName)_WithAccountToRemove_Config"

$script:viServer = Connect-VIServer -Server $Server -User $User -Password $Password

$script:vmHostAccountId = 'MyTestVMHostAccount'

$script:vmHostAccountToAdd = @{
    Ensure = 'Present'
    Role = 'Admin'
    AccountPassword = 'MyTestAccountPass1!'
    Description = 'MyTestVMHostAccount Description'
}

$script:vmHostAccountToUpdate = @{
    Role = 'ReadOnly'
    Description = 'MyTestVMHostAccount Description 2'
}

$script:vmHostAccountToRemove = @{
    Ensure = 'Absent'
    Description = [string]::Empty
}

. $script:configurationFile -Server $Server -User $User -Password $Password

$script:mofFileWithVMHostAccountToAddPath = "$script:integrationTestsFolderPath\$($script:configWithVMHostAccountToAdd)\"
$script:mofFileWithVMHostAccountToUpdatePath = "$script:integrationTestsFolderPath\$($script:configWithVMHostAccountToUpdate)\"
$script:mofFileWithVMHostAccountToRemovePath = "$script:integrationTestsFolderPath\$($script:configWithVMHostAccountToRemove)\"

function Invoke-TestSetup {
    $vmHostAccountParams = @{
        Server = $script:viServer
        Id = $script:vmHostAccountId
        Password = $script:vmHostAccountToAdd.AccountPassword
        Description = $script:vmHostAccountToAdd.Description
        Confirm = $false
        ErrorAction = 'Stop'
    }

    New-VMHostAccount @vmHostAccountParams
}

function Invoke-TestCleanup {
    Get-VMHostAccount -Server $script:viServer -Id $script:vmHostAccountId -ErrorAction SilentlyContinue | Remove-VMHostAccount -Server $script:viServer -Confirm:$false
}

try {
    Describe "$($script:dscResourceName)_Integration" {
        Context "When using configuration $($script:configWithVMHostAccountToAdd)" {
            AfterAll {
                Invoke-TestCleanup
            }

            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithVMHostAccountToAddPath
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
                    Path = $script:mofFileWithVMHostAccountToAddPath
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
                $configuration.Id | Should -Be $script:vmHostAccountId
                $configuration.Ensure | Should -Be $script:vmHostAccountToAdd.Ensure
                $configuration.Role | Should -Be $script:vmHostAccountToAdd.Role
                $configuration.Description | Should -Be $script:vmHostAccountToAdd.Description
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }
        }

        Context "When using configuration $($script:configWithVMHostAccountToUpdate)" {
            BeforeAll {
                Invoke-TestSetup
            }

            AfterAll {
                Invoke-TestCleanup
            }

            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithVMHostAccountToUpdatePath
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
                    Path = $script:mofFileWithVMHostAccountToUpdatePath
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
                $configuration.Id | Should -Be $script:vmHostAccountId
                $configuration.Ensure | Should -Be $script:vmHostAccountToAdd.Ensure
                $configuration.Role | Should -Be $script:vmHostAccountToUpdate.Role
                $configuration.Description | Should -Be $script:vmHostAccountToUpdate.Description
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }
        }

        Context "When using configuration $($script:configWithVMHostAccountToRemove)" {
            BeforeAll {
                Invoke-TestSetup
            }

            AfterAll {
                Invoke-TestCleanup
            }

            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithVMHostAccountToRemovePath
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
                    Path = $script:mofFileWithVMHostAccountToRemovePath
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
                $configuration.Id | Should -Be $script:vmHostAccountId
                $configuration.Ensure | Should -Be $script:vmHostAccountToRemove.Ensure
                $configuration.Role | Should -Be $script:vmHostAccountToUpdate.Role
                $configuration.Description | Should -Be $script:vmHostAccountToRemove.Description
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
