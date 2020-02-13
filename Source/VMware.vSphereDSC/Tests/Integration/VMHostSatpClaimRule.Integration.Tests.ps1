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

$script:dscResourceName = 'VMHostSatpClaimRule'
$script:moduleFolderPath = (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase
$script:integrationTestsFolderPath = Join-Path (Join-Path $moduleFolderPath 'Tests') 'Integration'
$script:configurationFile = "$script:integrationTestsFolderPath\Configurations\$($script:dscResourceName)\$($script:dscResourceName)_Config.ps1"

$script:configWithClaimRuleToAdd = "$($script:dscResourceName)_WithClaimRuleToAdd_Config"
$script:configWithClaimRuleToRemove = "$($script:dscResourceName)_WithClaimRuleToRemove_Config"

$script:ruleName = "VMW_SATP_LOCAL"
$script:pspOptions = "VMW_SATP_LOCAL PSPOption"
$script:transport = "VMW_SATP_LOCAL Transport"
$script:description = "Description of VMW_SATP_LOCAL Claim Rule."
$script:type = "transport"
$script:psp = "VMW_PSP_MRU"
$script:options = "VMW_PSP_MRUOption"

$script:resourceWithClaimRuleToAdd = @{
    Name = $Name
    Server = $Server
    Ensure = "Present"
    RuleName = $script:ruleName
    PSPOptions = $script:pspOptions
    Transport = $script:transport
    Description = $script:description
    Type = $script:type
    Psp = $script:psp
    Options = $script:options
}
$script:resourceWithClaimRuleToRemove = @{
    Name = $Name
    Server = $Server
    Ensure = "Absent"
    RuleName = $script:ruleName
    PSPOptions = $script:pspOptions
    Transport = $script:transport
    Description = $script:description
    Type = $script:type
    Psp = $script:psp
    Options = $script:options
}

. $script:configurationFile -Name $Name -Server $Server -User $User -Password $Password

$script:mofFileWithClaimRuleToAdd = "$script:integrationTestsFolderPath\$($script:configWithClaimRuleToAdd)\"
$script:mofFileWithClaimRuleToRemove = "$script:integrationTestsFolderPath\$($script:configWithClaimRuleToRemove)\"

try {
    Describe "$($script:dscResourceName)_Integration" {
        Context "When using configuration $($script:configWithClaimRuleToAdd)" {
            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithClaimRuleToAdd
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
                    Path = $script:mofFileWithClaimRuleToAdd
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
                # Arrange
                $emptyProperty = [string]::Empty

                # Act
                $configuration = Get-DscConfiguration

                # Assert
                $configuration.Name | Should -Be $script:resourceWithClaimRuleToAdd.Name
                $configuration.Server | Should -Be $script:resourceWithClaimRuleToAdd.Server
                $configuration.Ensure | Should -Be $script:resourceWithClaimRuleToAdd.Ensure
                $configuration.RuleName | Should -Be $script:resourceWithClaimRuleToAdd.RuleName
                $configuration.PSPOptions | Should -Be $script:resourceWithClaimRuleToAdd.PSPOptions
                $configuration.Transport | Should -Be $script:resourceWithClaimRuleToAdd.Transport
                $configuration.Description | Should -Be $script:resourceWithClaimRuleToAdd.Description
                $configuration.Vendor | Should -Be $emptyProperty
                $configuration.Boot | Should -Be $false
                $configuration.Type | Should -Be $script:resourceWithClaimRuleToAdd.Type
                $configuration.Device | Should -Be $emptyProperty
                $configuration.Driver | Should -Be $emptyProperty
                $configuration.ClaimOptions | Should -Be $emptyProperty
                $configuration.Psp | Should -Be $script:resourceWithClaimRuleToAdd.Psp
                $configuration.Options | Should -Be $script:resourceWithClaimRuleToAdd.Options
                $configuration.Model | Should -Be $emptyProperty
                $configuration.Force | Should -Be $false
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }
        }

        Context "When using configuration $($script:configWithClaimRuleToRemove)" {
            BeforeEach {
                # Arrange
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithClaimRuleToRemove
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
                    Path = $script:mofFileWithClaimRuleToRemove
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
                # Arrange
                $emptyProperty = [string]::Empty

                # Act
                $configuration = Get-DscConfiguration

                # Assert
                $configuration.Name | Should -Be $script:resourceWithClaimRuleToRemove.Name
                $configuration.Server | Should -Be $script:resourceWithClaimRuleToRemove.Server
                $configuration.Ensure | Should -Be $script:resourceWithClaimRuleToRemove.Ensure
                $configuration.RuleName | Should -Be $script:resourceWithClaimRuleToRemove.RuleName
                $configuration.PSPOptions | Should -Be $script:resourceWithClaimRuleToRemove.PSPOptions
                $configuration.Transport | Should -Be $script:resourceWithClaimRuleToRemove.Transport
                $configuration.Description | Should -Be $script:resourceWithClaimRuleToRemove.Description
                $configuration.Vendor | Should -Be $emptyProperty
                $configuration.Boot | Should -Be $false
                $configuration.Type | Should -Be $script:resourceWithClaimRuleToRemove.Type
                $configuration.Device | Should -Be $emptyProperty
                $configuration.Driver | Should -Be $emptyProperty
                $configuration.ClaimOptions | Should -Be $emptyProperty
                $configuration.Psp | Should -Be $script:resourceWithClaimRuleToRemove.Psp
                $configuration.Options | Should -Be $script:resourceWithClaimRuleToRemove.Options
                $configuration.Model | Should -Be $emptyProperty
                $configuration.Force | Should -Be $false
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
