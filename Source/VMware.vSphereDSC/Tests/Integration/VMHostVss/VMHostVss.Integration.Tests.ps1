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

$script:moduleName = 'VMware.vSphereDSC'
$script:dscResourceName = 'VMHostVss'
$script:moduleFolderPath = (Get-Module -Name $script:moduleName -ListAvailable).ModuleBase
$script:integrationTestsFolderPath = Join-Path (Join-Path $moduleFolderPath 'Tests') 'Integration'
$script:configurationFile = "$script:integrationTestsFolderPath\Configurations\$($script:dscResourceName)\$($script:dscResourceName)_Config.ps1"

$script:configWithNewVss = "$($script:dscResourceName)_New_Config"
$script:configWithModifyVss = "$($script:dscResourceName)_Modify_Config"
$script:configWithRemoveVss = "$($script:dscResourceName)_Remove_Config"

$script:VssName = 'VSSDSC'
$script:Mtu = 1500
$script:Present = 'Present'
$script:Absent = 'Absent'

$script:resourceWithNewVss = @{
    Name = $Name
    Server = $Server
    Ensure = $script:Present
    VssName = $script:VssName
    Mtu = $script:Mtu
}
$script:resourceWithModifyVss = @{
    Name = $Name
    Server = $Server
    Ensure = $script:Present
    VssName = $script:VssName
    Mtu = $script:Mtu + 1
}
$script:resourceWithRemoveVss = @{
    Name = $Name
    Server = $Server
    Ensure = $script:Absent
    VssName = $script:VssName
    Mtu = $script:Mtu
}

. $script:configurationFile -Name $Name -Server $Server -User $User -Password $Password

$script:mofFileWithNewVss = "$script:integrationTestsFolderPath\$($script:configWithNewVss)\"
$script:mofFileWithModifyVss = "$script:integrationTestsFolderPath\$($script:configWithModifyVss)\"
$script:mofFileWithRemoveVss = "$script:integrationTestsFolderPath\$($script:configWithRemoveVss)\"

try {
    Describe "$($script:dscResourceName)_Integration" {
        Context "When using configuration $($script:configWithNewVss)" {
            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithNewVss
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters
            }

            It 'Should compile and apply the MOF without throwing' {
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithNewVss
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Assert
                { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                # Assert
                { Get-DscConfiguration } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration and all the parameters should match' {
                # Act
                $configuration = Get-DscConfiguration

                # Assert
                $configuration.Server | Should -Be $script:resourceWithNewVss.Server
                $configuration.Name | Should -Be $script:resourceWithNewVss.Name
                $configuration.Ensure | Should -Be $script:resourceWithNewVss.Ensure
                $configuration.VssName | Should -Be $script:resourceWithNewVss.VssName
                $configuration.Mtu | Should -Be $script:resourceWithNewVss.Mtu
                $configuration.Ensure | Should -Be $script:resourceWithNewVss.Ensure
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }
        }

        Context "When using configuration $($script:configWithModifyVss)" {
            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithModifyVss
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Act
                Start-DscConfiguration @startDscConfigurationParameters
            }

            It 'Should compile and apply the MOF without throwing' {
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithModifyVss
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Assert
                { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                # Assert
                { Get-DscConfiguration } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration and all the parameters should match' {
                # Act
                $configuration = Get-DscConfiguration

                # Assert
                $configuration.Server | Should -Be $script:resourceWithModifyVss.Server
                $configuration.Name | Should -Be $script:resourceWithModifyVss.Name
                $configuration.Ensure | Should -Be $script:resourceWithModifyVss.Ensure
                $configuration.VssName | Should -Be $script:resourceWithModifyVss.VssName
                $configuration.Mtu | Should -Be $script:resourceWithModifyVss.Mtu
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }
        }

        Context "When using configuration $($script:configWithRemoveVss)" {
            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithRemoveVss
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
                    Path = $script:mofFileWithRemoveVss
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }

                # Assert
                { Start-DscConfiguration @startDscConfigurationParameters } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                # Assert
                { Get-DscConfiguration } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration and all the parameters should match' {
                # Act
                $configuration = Get-DscConfiguration

                # Assert
                $configuration.Server | Should -Be $script:resourceWithRemoveVss.Server
                $configuration.Name | Should -Be $script:resourceWithRemoveVss.Name
                $configuration.VssName | Should -Be $script:resourceWithRemoveVss.VssName
                $configuration.Ensure | Should -Be $script:resourceWithRemoveVss.Ensure
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }
        }
    }
}
finally {
}
