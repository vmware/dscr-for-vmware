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

$script:dscResourceName = 'VMHostSettings'
$script:dscConfig = $null
$script:moduleFolderPath = (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase
$script:integrationTestsFolderPath = Join-Path (Join-Path $moduleFolderPath 'Tests') 'Integration'
$script:configurationFile = "$script:integrationTestsFolderPath\Configurations\$($script:dscResourceName)\$($script:dscResourceName)_Config.ps1"

$script:config = "$($script:dscResourceName)_Config"

$script:connection = Connect-VIServer -Server $Server -User $User -Password $Password
$script:vmHost = $null

$script:motd = 'VMHostSettings motd test'
$script:issue = 'VMHostSettings issue test'

$script:resourceProperties = @{
  Name   = $Name
  Server = $Server
  Motd   = $script:motd
  Issue  = $script:issue
}

. $script:configurationFile -Name $Name -Server $Server -User $User -Password $Password

$script:mofFilePath = "$script:integrationTestsFolderPath\$($script:config)\"

function BeforeAllTests {
  $script:vmHost = Get-VMHost -Server $script:connection -Name $script:resourceProperties.Name

  $script:motd = Get-AdvancedSetting -Server $script:connection -Entity $script:vmHost -Name "Config.Etc.motd"
  $script:issue = Get-AdvancedSetting -Server $script:connection -Entity $script:vmHost -Name "Config.Etc.issue"
}

function AfterAllTests {
  $script:vmHost = Get-VMHost -Server $script:connection -Name $script:resourceProperties.Name

  Set-AdvancedSetting -AdvancedSetting $script:motd -Value $script:motd.Value -Confirm:$false
  Set-AdvancedSetting -AdvancedSetting $script:issue -Value $script:issue.Value -Confirm:$false
}

Describe "$($script:dscResourceName)_Integration" {
  Context "When using configuration $($script:config)" {
    BeforeAll {
      BeforeAllTests
    }

    AfterAll {
      AfterAllTests
    }

    BeforeEach {
      # Arrange
      $startDscConfigurationParameters = @{
        Path         = $script:mofFilePath
        ComputerName = 'localhost'
        Wait         = $true
        Force        = $true
      }

      # Act
      $script:dscConfig = Start-DscConfiguration @startDscConfigurationParameters
    }

    It 'Should compile and apply the MOF without throwing' {
      # Assert
      { $script:dscConfig } | Should -Not -Throw
    }

    It 'Should be able to call Get-DscConfiguration without throwing and all the parameters should match' {
      # Arrange && Act
      $script:dscConfig = Get-DscConfiguration `
        | Where-Object {$_.configurationName -eq $script:config }

      $configuration = $script:dscConfig `
        | Select-Object -Last 1

      # Assert
      { $script:dscConfig } | Should -Not -Throw

      $configuration.Name | Should -Be $script:resourceProperties.Name
      $configuration.Server | Should -Be $script:resourceProperties.Server
      $configuration.Motd | Should -Be $script:motd
      $configuration.Issue | Should -Be $script:issue
    }

    It 'Should return $true when Test-DscConfiguration is run' {
      # Arrange && Act && Assert
      Test-DscConfiguration | Should -Be $true
    }
  }
}

Disconnect-VIServer -Server $Server -Confirm:$false