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

$script:dscResourceName = 'VMHostVssSecurity'
$script:dscDependResourceName = 'VMHostVss'
$script:dscConfig = $null
$script:moduleFolderPath = (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase
$script:integrationTestsFolderPath = Join-Path (Join-Path (Join-Path $moduleFolderPath 'Tests') 'Integration') $script:dscResourceName
$script:configurationFile = "$script:integrationTestsFolderPath\Configurations\$($script:dscResourceName)\$($script:dscResourceName)_Config.ps1"

$script:configWithModifyVssSecurity = "$($script:dscResourceName)_Modify_Config"
$script:configWithRemoveVssSecurity = "$($script:dscResourceName)_Remove_Config"

$script:connection = Connect-VIServer -Server $Server -User $User -Password $Password
$script:vmHost = $null

$script:VssName = 'VSSDSC'
$script:AllowPromiscuous = $false
$script:ForgedTransmits = $true
$script:MacChanges = $true
$script:Present = 'Present'
$script:Absent = 'Absent'

$script:resourceWithModifyVssSecurity = @{
    Name = $Name
    Server = $Server
    Ensure = $script:Present
    VssName = $script:VssName
    AllowPromiscuous = -not $script:AllowPromiscuous
    ForgedTransmits = -not $script:ForgedTransmits
    MacChanges = -not $script:MacChanges
}
$script:resourceWithRemoveVssSecurity = @{
    Name = $Name
    Server = $Server
    Ensure = $script:Absent
    VssName = $script:VssName
    AllowPromiscuous = $script:AllowPromiscuous
    ForgedTransmits = $script:ForgedTransmits
    MacChanges = $script:MacChanges
}

. $script:configurationFile -Name $Name -Server $Server -User $User -Password $Password

$script:mofFileWithModifyVssSecurity = "$script:integrationTestsFolderPath\$($script:configWithModifyVssSecurity)\"
$script:mofFileWithRemoveVssSecurity = "$script:integrationTestsFolderPath\$($script:configWithRemoveVssSecurity)\"

try {
    Describe "$($script:dscResourceName)_Integration" {
        Context "When using configuration $($script:configWithModifyVssSecurity)" {
            It 'Should compile and apply the MOF without throwing' {
                # Assert
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithWithModifyVssSecurity
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
                $configuration.Server | Should -Be $script:resourceWithModifyVssSecurity.Server
                $configuration.Name | Should -Be $script:resourceWithModifyVssSecurity.Name
                $configuration.Ensure | Should -Be $script:resourceWithModifyVssSecurity.Ensure
                $configuration.VssName | Should -Be $script:resourceWithModifyVssSecurity.VssName
                $configuration.AllowPromiscuous | Should -Be $script:resourceWithModifyVssSecurity.AllowPromiscuous
                $configuration.ForgedTransmits | Should -Be $script:resourceWithModifyVssSecurity.ForgedTransmits
                $configuration.MacChanges | Should -Be $script:resourceWithModifyVssSecurity.MacChanges
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }

            It 'Should depend on resource VMHostVss' {
                $currentResource = Get-DscConfiguration | Where-Object { $_.Name -eq $script:dscResourceName }

                $currentResource.DependsOn | Should -Be $script:dscDependResourceName
            }
        }

        Context "When using configuration $($script:configWithRemoveVssSecurity)" {
            It 'Should compile and apply the MOF without throwing' {
                # Assert
                $startDscConfigurationParameters = @{
                    Path = $script:mofFileWithRemoveVssSecurity
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
                $configuration.Server | Should -Be $script:resourceWithRemoveVssSecurity.Server
                $configuration.Name | Should -Be $script:resourceWithRemoveVssSecurity.Name
                $configuration.Ensure | Should -Be $script:resourceWithRemoveVssSecurity.Ensure
                $configuration.VssName | Should -Be $script:resourceWithRemoveVssSecurity.VssName
                $configuration.AllowPromiscuous | Should -Be $script:resourceWithRemoveVssSecurity.AllowPromiscuous
                $configuration.ForgedTransmits | Should -Be $script:resourceWithRemoveVssSecurity.ForgedTransmits
                $configuration.MacChanges | Should -Be $script:resourceWithRemoveVssSecurity.MacChanges
            }

            It 'Should return $true when Test-DscConfiguration is run' {
                # Arrange && Act && Assert
                Test-DscConfiguration | Should -Be $true
            }

            It 'Should depend on resource VMHostVss' {
                $currentResource = Get-DscConfiguration | Where-Object { $_.Name -eq $script:dscResourceName }

                $currentResource.DependsOn | Should -Be $script:dscDependResourceName
            }
        }
    }
}
finally {
    Disconnect-VIServer -Server $Server -Confirm:$false
}