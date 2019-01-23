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

$script:dscResourceName = 'VMHostVss'
$script:dscConfig = $null
$script:moduleFolderPath = (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase
$script:integrationTestsFolderPath = Join-Path (Join-Path (Join-Path $moduleFolderPath 'Tests') 'Integration') $script:dscResourceName

$script:configWithNewVss = "$($script:dscResourceName)_New_Config"
$script:configWithModifyVss = "$($script:dscResourceName)_Modify_Config"
$script:configWithRemoveVss = "$($script:dscResourceName)_Remove_Config"

$script:connection = Connect-VIServer -Server $Server -User $User -Password $Password
$script:vmHost = $null

$script:VssName = 'VSSDSC'
$script:NumPorts = 1
$script:Mtu = 1500
$script:Present = 'Present'
$script:Absent = 'Absent'

$script:resourceWithNewVss = @{
    Name = $Name
    Server = $Server
    Ensure = $script:Present
    VssName = $script:VssName
    Mtu = $script:Mtu
    NumPorts = $script:NumPorts
}
$script:resourceWithModifyVss = @{
    Name = $Name
    Server = $Server
    Ensure = $script:Present
    VssName = $script:VssName
    Mtu = $script:Mtu + 1
    NumPorts = $script:NumPorts + 1
}
$script:resourceWithRemoveVss = @{
    Name = $Name
    Server = $Server
    Ensure = $script:Absent
    VssName = $script:VssName
    Mtu = $script:Mtu
    NumPorts = $script:NumPorts
}

. $script:configurationFile -Name $Name -Server $Server -User $User -Password $Password

$script:mofFileWithNewVss = "$script:integrationTestsFolderPath\$($script:configWithNewVss)\"
$script:mofFileWithModifyVss = "$script:integrationTestsFolderPath\$($script:configWithModifyVss)\"
$script:mofFileWithRemoveVss = "$script:integrationTestsFolderPath\$($script:configWithRemoveVss)\"

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
            # Assert
            $startDscConfigurationParameters = @{
                Path = $script:mofFileWithNewVss
                ComputerName = 'localhost'
                Wait = $true
                Force = $true
            }
            Start-DscConfiguration @startDscConfigurationParameters | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            # Assert
            { Get-DscConfiguration } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration and all the parameters should match' {
            # Act
            $configuration = Get-DscConfiguration

            # Assert
            $configuration.VssName | Should -Be $script:resourceWithNewVss.VssName
            $configuration.NumPorts | Should -Be $script:resourceWithNewVss.NumPorts
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
            # Assert
            {
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithWithModifyVss
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }
                Start-DscConfiguration @startDscConfigurationParameters | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                # Assert
                { Get-DscConfiguration} | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration and all the parameters should match' {
                # Act
                $configuration = Get-DscConfiguration

                # Assert
                $configuration.VssName | Should -Be $script:resourceWithModifyVss.VssName
                $configuration.NumPorts | Should -Be $script:resourceWithModifyVss.NumPorts
                $configuration.Mtu | Should -Be $script:resourceWithModifyVss.Mtu
                $configuration.Ensure | Should -Be $script:resourceWithModifyVss.Ensure
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }
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
            # Assert
            {
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithRemoveVss
                    ComputerName = 'localhost'
                    Wait = $true
                    Force = $true
                }
                Start-DscConfiguration @startDscConfigurationParameters | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                # Assert
                { Get-DscConfiguration } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration and all the parameters should match' {
                # Act
                $configuration = Get-DscConfiguration

                # Assert
                $configuration.VssName | Should -Be $script:resourceWithRemoveVss.VssName
                $configuration.NumPorts | Should -Be $script:resourceWithRemoveVss.NumPorts
                $configuration.Mtu | Should -Be $script:resourceWithRemoveVss.Mtu
                $configuration.Ensure | Should -Be $script:resourceWithRemoveVss.Ensure
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }
        }
    }
}