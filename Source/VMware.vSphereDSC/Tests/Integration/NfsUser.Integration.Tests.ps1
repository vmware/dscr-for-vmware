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
    $Name,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $DomainName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $DomainUsername,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $DomainPassword
)

$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (ConvertTo-SecureString -String $Password -AsPlainText -Force)
$DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUsername, (ConvertTo-SecureString -String $DomainPassword -AsPlainText -Force)

$script:dscResourceName = 'NfsUser'
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
            VMHostName = $Name
            DomainName = $DomainName
            DomainCredential = $DomainCredential
            VMHostAuthenticationResourceName = 'VMHostAuthentication'
            NfsUserResourceName = 'NfsUser'
            DomainActionJoin = 'Join'
            DomainActionLeave = 'Leave'
            NfsUsername = 'MyTestNfsUsername'
            NfsUserPasswordOne = 'MyTestNfsUserPasswordOne'
            NfsUserPasswordTwo = 'MyTestNfsUserPasswordTwo'
            Force = $true
        }
    )
}

$script:configJoinDomain = "$($script:dscResourceName)_JoinDomain_Config"
$script:configCreateNfsUser = "$($script:dscResourceName)_CreateNfsUser_Config"
$script:configChangeNfsUserPassword = "$($script:dscResourceName)_ChangeNfsUserPassword_Config"
$script:configRemoveNfsUser = "$($script:dscResourceName)_RemoveNfsUser_Config"
$script:configLeaveDomain = "$($script:dscResourceName)_LeaveDomain_Config"

. $script:configurationFile -ErrorAction Stop

$script:mofFileJoinDomainPath = "$script:integrationTestsFolderPath\$script:configJoinDomain\"
$script:mofFileCreateNfsUserPath = "$script:integrationTestsFolderPath\$script:configCreateNfsUser\"
$script:mofFileChangeNfsUserPasswordPath = "$script:integrationTestsFolderPath\$script:configChangeNfsUserPassword\"
$script:mofFileRemoveNfsUserPath = "$script:integrationTestsFolderPath\$script:configRemoveNfsUser\"
$script:mofFileLeaveDomainPath = "$script:integrationTestsFolderPath\$script:configLeaveDomain\"

Describe "$($script:dscResourceName)_Integration" {
    Context "When using configuration $script:configCreateNfsUser" {
        BeforeAll {
            # Arrange
            & $script:configJoinDomain `
                -OutputPath $script:mofFileJoinDomainPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configCreateNfsUser `
                -OutputPath $script:mofFileCreateNfsUserPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersJoinDomain = @{
                Path = $script:mofFileJoinDomainPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersCreateNfsUser = @{
                Path = $script:mofFileCreateNfsUserPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersJoinDomain
            Start-DscConfiguration @startDscConfigurationParametersCreateNfsUser
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileCreateNfsUserPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configCreateNfsUser }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.Name | Should -Be $script:configurationData.AllNodes.NfsUsername
            $configuration.Ensure | Should -Be 'Present'
            $configuration.Force | Should -BeNullOrEmpty
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileCreateNfsUserPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configRemoveNfsUser `
                -OutputPath $script:mofFileRemoveNfsUserPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configLeaveDomain `
                -OutputPath $script:mofFileLeaveDomainPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersRemoveNfsUser = @{
                Path = $script:mofFileRemoveNfsUserPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersLeaveDomain = @{
                Path = $script:mofFileLeaveDomainPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersRemoveNfsUser
            Start-DscConfiguration @startDscConfigurationParametersLeaveDomain

            Remove-Item -Path $script:mofFileJoinDomainPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileCreateNfsUserPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveNfsUserPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileLeaveDomainPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configChangeNfsUserPassword" {
        BeforeAll {
            # Arrange
            & $script:configJoinDomain `
                -OutputPath $script:mofFileJoinDomainPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configCreateNfsUser `
                -OutputPath $script:mofFileCreateNfsUserPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configChangeNfsUserPassword `
                -OutputPath $script:mofFileChangeNfsUserPasswordPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersJoinDomain = @{
                Path = $script:mofFileJoinDomainPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersCreateNfsUser = @{
                Path = $script:mofFileCreateNfsUserPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersChangeNfsUserPassword = @{
                Path = $script:mofFileChangeNfsUserPasswordPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersJoinDomain
            Start-DscConfiguration @startDscConfigurationParametersCreateNfsUser
            Start-DscConfiguration @startDscConfigurationParametersChangeNfsUserPassword
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileChangeNfsUserPasswordPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configChangeNfsUserPassword }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.Name | Should -Be $script:configurationData.AllNodes.NfsUsername
            $configuration.Ensure | Should -Be 'Present'
            $configuration.Force | Should -Be $script:configurationData.AllNodes.Force
        }

        It 'Should return $false when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileChangeNfsUserPasswordPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $false
        }

        AfterAll {
            # Arrange
            & $script:configRemoveNfsUser `
                -OutputPath $script:mofFileRemoveNfsUserPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configLeaveDomain `
                -OutputPath $script:mofFileLeaveDomainPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersRemoveNfsUser = @{
                Path = $script:mofFileRemoveNfsUserPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersLeaveDomain = @{
                Path = $script:mofFileLeaveDomainPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersRemoveNfsUser
            Start-DscConfiguration @startDscConfigurationParametersLeaveDomain

            Remove-Item -Path $script:mofFileJoinDomainPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileCreateNfsUserPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileChangeNfsUserPasswordPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveNfsUserPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileLeaveDomainPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }

    Context "When using configuration $script:configRemoveNfsUser" {
        BeforeAll {
            # Arrange
            & $script:configJoinDomain `
                -OutputPath $script:mofFileJoinDomainPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configCreateNfsUser `
                -OutputPath $script:mofFileCreateNfsUserPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            & $script:configRemoveNfsUser `
                -OutputPath $script:mofFileRemoveNfsUserPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParametersJoinDomain = @{
                Path = $script:mofFileJoinDomainPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersCreateNfsUser = @{
                Path = $script:mofFileCreateNfsUserPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            $startDscConfigurationParametersRemoveNfsUser = @{
                Path = $script:mofFileRemoveNfsUserPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParametersJoinDomain
            Start-DscConfiguration @startDscConfigurationParametersCreateNfsUser
            Start-DscConfiguration @startDscConfigurationParametersRemoveNfsUser
        }

        It 'Should apply the MOF without throwing' {
            # Arrange
            $startDscConfigurationParameters = @{
                Path = $script:mofFileRemoveNfsUserPath
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
            $configuration = Get-DscConfiguration -Verbose -ErrorAction Stop | Where-Object -FilterScript { $_.ConfigurationName -eq $script:configRemoveNfsUser }

            # Assert
            $configuration.Server | Should -Be $script:configurationData.AllNodes.Server
            $configuration.VMHostName | Should -Be $script:configurationData.AllNodes.VMHostName
            $configuration.Name | Should -Be $script:configurationData.AllNodes.NfsUsername
            $configuration.Ensure | Should -Be 'Absent'
            $configuration.Force | Should -BeNullOrEmpty
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $testDscConfigurationParameters = @{
                ReferenceConfiguration = "$script:mofFileRemoveNfsUserPath\$($script:configurationData.AllNodes.NodeName).mof"
                ComputerName = $script:configurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParameters).InDesiredState | Should -Be $true
        }

        AfterAll {
            # Arrange
            & $script:configLeaveDomain `
                -OutputPath $script:mofFileLeaveDomainPath `
                -ConfigurationData $script:configurationData `
                -ErrorAction Stop

            $startDscConfigurationParameters = @{
                Path = $script:mofFileLeaveDomainPath
                ComputerName = $script:configurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act
            Start-DscConfiguration @startDscConfigurationParameters

            Remove-Item -Path $script:mofFileJoinDomainPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileCreateNfsUserPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileRemoveNfsUserPath -Recurse -Confirm:$false -ErrorAction Stop
            Remove-Item -Path $script:mofFileLeaveDomainPath -Recurse -Confirm:$false -ErrorAction Stop
        }
    }
}
