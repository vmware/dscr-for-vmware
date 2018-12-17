<#
Copyright (c) 2018 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

using module VMware.vSphereDSC

$script:modulePath = $env:PSModulePath
$script:unitTestsFolder = Join-Path (Join-Path (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase 'Tests') 'Unit'
$script:mockModuleLocation = "$script:unitTestsFolder\TestHelpers"

$script:moduleName = 'VMware.vSphereDSC'
$script:resourceName = 'VMHostSettings'

$user = 'user'
$password = 'password' | ConvertTo-SecureString -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($user, $password)

$script:resourceProperties = @{
  Name       = '10.23.82.112'
  Server     = '10.23.82.112'
  Credential = $credential
}

Describe 'VMHostSettings' {
  BeforeAll {
    $env:PSModulePath = $script:mockModuleLocation
    $vimAutomationModule = Get-Module -Name VMware.VimAutomation.Core
    if ($null -ne $vimAutomationModule -and $vimAutomationModule.Path -NotMatch 'TestHelpers') {
      throw 'The Original VMware.VimAutomation.Core Module is loaded in the current session. If you want to run the unit tests please open a new PowerShell session.'
    }

    Import-Module -Name VMware.VimAutomation.Core
  }

  AfterAll {
    Remove-Module -Name VMware.VimAutomation.Core
    $env:PSModulePath = $script:modulePath
  }

  Describe 'VMHostSettings\Set' {
    AfterEach {
      $script:resourceProperties.Motd = [string]::Empty
      $script:resourceProperties.Issue = [string]::Empty
    }

    Context 'Invoking with empty settings' {
      BeforeAll {
        # Arrange
        $viServer = [VMware.Vim.VIServer] @{ Name = '10.23.82.112'; User = 'user' }
        $vmhost = [VMware.Vim.VMHost] @{ Id = 'VMHostId' }

        $viServerMock = {
          return [VMware.Vim.VIServer] @{ Name = '10.23.82.112'; User = 'user' }
        }
        $vmHostMock = {
          return [VMware.Vim.VMHost] @{ Id = 'VMHostId' }
        }

        Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
        Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
        Mock -CommandName Get-AdvancedSetting -MockWith { return $null } -ModuleName $script:moduleName
      }

      # Arrange
      $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

      It 'Should call the Connect-VIServer mock with the passed server and credentials once' {
        # Act
        $resource.Set()

        # Assert
        Assert-MockCalled -CommandName Connect-VIServer `
          -ParameterFilter { $Server -eq $script:resourceProperties.Server -and $Credential -eq $script:resourceProperties.Credential } `
          -ModuleName $script:moduleName -Exactly 1 -Scope It
      }

      It 'Should call Get-VMHost mock with the passed server and name once' {
        # Act
        $resource.Set()

        # Assert
        Assert-MockCalled -CommandName Get-VMHost `
          -ParameterFilter { $Server -eq $viServer -and $Name -eq $script:resourceProperties.Name } `
          -ModuleName $script:moduleName -Exactly 1 -Scope It
      }

      It 'Should call Get-AdvancedSetting mock with the passed server and vmhost once' {
        # Act
        $resource.Set()

        # Assert
        Assert-MockCalled -CommandName Get-AdvancedSetting `
          -ParameterFilter { $Server -eq $viServer -and $Entity -eq $vmhost } `
          -ModuleName $script:moduleName -Exactly 1 -Scope It
      }
    }

    Context 'Invoking with Advanced Settings To Update' {
      BeforeAll {
        # Arrange
        $script:resourceProperties.Motd = 'Hello World from motd!'
        $script:resourceProperties.Issue = 'Hello World from isue!'

        $advancedSettings = @(
          [VMware.Vim.AdvancedSetting] @{ Name = 'Config.Etc.motd'; Value = 'Hello World from motd!' }
          [VMware.Vim.AdvancedSetting] @{ Name = 'Config.Etc.issue'; Value = 'Hello World from issue!' }
        )

        $viServerMock = {
          return [VMware.Vim.VIServer] @{ Name = '10.23.82.112'; User = 'user' }
        }

        $vmHostMock = {
          return [VMware.Vim.VMHost] @{ Id = 'VMHostId' }
        }

        $advancedSettingsMock = {
          return @(
            [VMware.Vim.AdvancedSetting] @{ Name = 'Config.Etc.motd'; Value = '' }
            [VMware.Vim.AdvancedSetting] @{ Name = 'Config.Etc.issue'; Value = '' }
          )
        }

        Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
        Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
        Mock -CommandName Get-AdvancedSetting -MockWith $advancedSettingsMock -ModuleName $script:moduleName
        Mock -CommandName Set-AdvancedSetting -MockWith { return $null } -ModuleName $script:moduleName
      }

      # Arrange
      $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

      It 'Should call Set-AdvancedSetting for each setting that needs to be updated' {
        # Act
        $resource.Set()

        # Assert
        Assert-MockCalled -CommandName Set-AdvancedSetting `
          -ParameterFilter { $AdvancedSetting -eq $advancedSettings[0] -and $Value -eq $script:resourceProperties.Motd -and !$Confirm } `
          -ModuleName $script:moduleName -Exactly 1 -Scope It
        Assert-MockCalled -CommandName Set-AdvancedSetting `
          -ParameterFilter { $AdvancedSetting -eq $advancedSettings[1] -and $Value -eq $script:resourceProperties.Issue -and !$Confirm } `
          -ModuleName $script:moduleName -Exactly 1 -Scope It
      }
    }

    Context 'Invoking without Advanced Settings To Update' {
      BeforeAll {
        # Arrange
        $script:resourceProperties.Motd = 'Hello World from motd!'
        $script:resourceProperties.Issue = 'Hello World from issue!'

        $advancedSettings = @(
          [VMware.Vim.AdvancedSetting] @{ Name = 'Config.Etc.motd'; Value = 'Hello World from motd!' }
          [VMware.Vim.AdvancedSetting] @{ Name = 'Config.Etc.issue'; Value = 'Hello World from issue!' }
        )

        $viServerMock = {
          return [VMware.Vim.VIServer] @{ Name = '10.23.82.112'; User = 'user' }
        }

        $vmHostMock = {
          return [VMware.Vim.VMHost] @{ Id = 'VMHostId' }
        }

        $advancedSettingsMock = {
          return @(
            [VMware.Vim.AdvancedSetting] @{ Name = 'Config.Etc.motd'; Value = 'Hello World from motd!' }
            [VMware.Vim.AdvancedSetting] @{ Name = 'Config.Etc.issue'; Value = 'Hello World from issue!' }
          )
        }

        Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
        Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
        Mock -CommandName Set-AdvancedSetting -MockWith { return $null } -ModuleName $script:moduleName
      }

      # Arrange
      $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

      It 'Should not call Set-AdvancedSetting for each setting that does not need to be updated' {
        # Act
        $resource.Set()

        # Assert
        Assert-MockCalled -CommandName Set-AdvancedSetting `
          -ParameterFilter { $AdvancedSetting -eq $advancedSettings[0] -and $Value -eq $script:resourceProperties.Motd -and !$Confirm } `
          -ModuleName $script:moduleName -Exactly 0 -Scope It
        Assert-MockCalled -CommandName Set-AdvancedSetting `
          -ParameterFilter { $AdvancedSetting -eq $advancedSettings[1] -and $Value -eq $script:resourceProperties.Issue -and !$Confirm } `
          -ModuleName $script:moduleName -Exactly 0 -Scope It
      }
    }
  }

  Describe 'VMHostSettings\Test' {
    AfterEach {
      $script:resourceProperties.Motd = [string]::Empty
      $script:resourceProperties.Issue = [string]::Empty
      $script:resourceProperties.MotdClear = $false
      $script:resourceProperties.IssueClear = $false
    }

    Context 'Invoking with default resource properties' {
      BeforeAll {
        # Arrange
        $viServer = [VMware.Vim.VIServer] @{ Name = '10.23.82.112'; User = 'user' }
        $vmhost = [VMware.Vim.VMHost] @{ Id = 'VMHostId' }

        $viServerMock = {
          return [VMware.Vim.VIServer] @{ Name = '10.23.82.112'; User = 'user' }
        }
        $vmHostMock = {
          return [VMware.Vim.VMHost] @{ Id = 'VMHostId' }
        }

        Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
        Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
        Mock -CommandName Get-AdvancedSetting -MockWith { return $null } -ModuleName $script:moduleName
      }

      # Arrange
      $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

      It 'Should call the Connect-VIServer mock with the passed server and credentials once' {
        # Act
        $resource.Test()

        # Assert
        Assert-MockCalled -CommandName Connect-VIServer `
          -ParameterFilter { $Server -eq $script:resourceProperties.Server -and $Credential -eq $script:resourceProperties.Credential } `
          -ModuleName $script:moduleName -Exactly 1 -Scope It
      }

      It 'Should call Get-VMHost mock with the passed server and name once' {
        # Act
        $resource.Test()

        # Assert
        Assert-MockCalled -CommandName Get-VMHost `
          -ParameterFilter { $Server -eq $viServer -and $Name -eq $script:resourceProperties.Name } `
          -ModuleName $script:moduleName -Exactly 1 -Scope It
      }

      It 'Should call Get-AdvancedSetting mock with the passed server and vmhost once' {
        # Act
        $resource.Test()

        # Assert
        Assert-MockCalled -CommandName Get-AdvancedSetting `
          -ParameterFilter { $Server -eq $viServer -and $Entity -eq $vmhost } `
          -ModuleName $script:moduleName -Exactly 1 -Scope It
      }
    }

    Context 'Invoking with equal motd and issue Configs' {
      BeforeAll {
        # Arrange
        $script:resourceProperties.Motd = 'Hello World!'
        $script:resourceProperties.MotdClear = $false
        $script:resourceProperties.Issue = 'Hello World!'
        $script:resourceProperties.IssueClear = $false

        $viServer = [VMware.Vim.VIServer] @{ Name = '10.23.82.112'; User = 'user' }
        $vmhost = [VMware.Vim.VMHost] @{ Id = 'VMHostId' }
        $viServerMock = {
          return [VMware.Vim.VIServer] @{ Name = '10.23.82.112'; User = 'user' }
        }
        $vmHostMock = {
          return [VMware.Vim.VMHost] @{ Id = 'VMHostId' }
        }
        $advancedSettingsMock = {
          return @(
            [VMware.Vim.AdvancedSetting] @{ Name = 'Config.Etc.issue'; Value = 'Hello World!' }
            [VMware.Vim.AdvancedSetting] @{ Name = 'Config.Etc.motd'; Value = 'Hello World!' }
          )
        }

        Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
        Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
        Mock -CommandName Get-AdvancedSetting -MockWith $advancedSettingsMock -ModuleName $script:moduleName
        Mock -CommandName Set-AdvancedSetting -MockWith { return $null } -ModuleName $script:moduleName
      }

      # Arrange
      $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

      It 'Should call the Connect-VIServer mock with the passed server and credentials once' {
        # Act
        $resource.Test()

        # Assert
        Assert-MockCalled -CommandName Connect-VIServer `
          -ParameterFilter { $Server -eq $script:resourceProperties.Server -and $Credential -eq $script:resourceProperties.Credential } `
          -ModuleName $script:moduleName -Exactly 1 -Scope It
      }

      It 'Should call Get-VMHost mock with the passed server and name once' {
        # Act
        $resource.Test()

        # Assert
        Assert-MockCalled -CommandName Get-VMHost `
          -ParameterFilter { $Server -eq $viServer -and $Name -eq $script:resourceProperties.Name } `
          -ModuleName $script:moduleName -Exactly 1 -Scope It
      }

      It 'Should call Get-AdvancedSetting mock with the passed server and vCenter once' {
        # Act
        $resource.Test()

        # Assert
        Assert-MockCalled -CommandName Get-AdvancedSetting `
          -ParameterFilter { $Server -eq $viServer -and $Entity -eq $vmhost } `
          -ModuleName $script:moduleName -Exactly 1 -Scope It
      }

      It 'Shall not call Set-AdvancedSetting mock with the passed server and vCenter' {
        # Act
        $resource.Test()

        # Assert
        Assert-MockCalled -CommandName Set-AdvancedSetting `
          -ParameterFilter { $Server -eq $viServer -and $Entity -eq $vmhost } `
          -ModuleName $script:moduleName -Exactly 0 -Scope It
      }
    }

    Context 'Invoking with Advanced Settings To Update' {
      BeforeAll {
        # Arrange
        $script:resourceProperties.Motd = 'Hello World!'
        $script:resourceProperties.MotdClear = $false
        $script:resourceProperties.Issue = 'Hello World!'
        $script:resourceProperties.IssueClear = $false

        $advancedSettings = @(
          [VMware.Vim.AdvancedSetting] @{ Name = 'Config.Etc.issue'; Value = 'Hello World!' }
          [VMware.Vim.AdvancedSetting] @{ Name = 'Config.Etc.motd'; Value = 'Hello World!' }
        )

        $viServer = [VMware.Vim.VIServer] @{ Name = '10.23.82.112'; User = 'user' }
        $vmhost = [VMware.Vim.VMHost] @{ Id = 'VMHostId' }
        $viServerMock = {
          return [VMware.Vim.VIServer] @{ Name = '10.23.82.112'; User = 'user' }
        }
        $vmHostMock = {
          return [VMware.Vim.VMHost] @{ Id = 'VMHostId' }
        }
        $advancedSettingsMock = {
          return @(
            [VMware.Vim.AdvancedSetting] @{ Name = 'Config.Etc.issue'; Value = 'Hello Brave New World!' }
            [VMware.Vim.AdvancedSetting] @{ Name = 'Config.Etc.motd'; Value = 'Hello Brave New World!' }
          )
        }

        Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
        Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
        Mock -CommandName Get-AdvancedSetting -MockWith $advancedSettingsMock -ModuleName $script:moduleName
      }

      # Arrange
      $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

      It 'Should call the Connect-VIServer mock with the passed server and credentials once' {
        # Act
        $resource.Test()

        # Assert
        Assert-MockCalled -CommandName Connect-VIServer `
          -ParameterFilter { $Server -eq $script:resourceProperties.Server -and $Credential -eq $script:resourceProperties.Credential } `
          -ModuleName $script:moduleName -Exactly 1 -Scope It
      }

      It 'Should call Get-VMHost mock with the passed server and name once' {
        # Act
        $resource.Test()

        # Assert
        Assert-MockCalled -CommandName Get-VMHost `
          -ParameterFilter { $Server -eq $viServer -and $Name -eq $script:resourceProperties.Name } `
          -ModuleName $script:moduleName -Exactly 1 -Scope It
      }

      It 'Should call Get-AdvancedSetting mock with the passed server and vCenter once' {
        # Act
        $resource.Test()

        # Assert
        Assert-MockCalled -CommandName Get-AdvancedSetting `
          -ParameterFilter { $Server -eq $viServer -and $Entity -eq $vmhost } `
          -ModuleName $script:moduleName -Exactly 1 -Scope It
      }
    }
  }

  Describe 'VMHostSettings\Get' {
    AfterEach {
      $script:resourceProperties.Server = '10.23.82.112'
      $script:resourceProperties.Name = '10.23.82.112'
      $script:resourceProperties.Motd = 'Hello World!'
      $script:resourceProperties.MotdClear = $false
      $script:resourceProperties.Issue = 'Hello World!'
      $script:resourceProperties.IssueClear = $false
    }

    BeforeAll {
      # Arrange
      $viServer = [VMware.Vim.VIServer] @{ Name = '10.23.82.112'; User = 'user' }
      $vmhost = [VMware.Vim.VMHost] @{ Id = 'VMHostId' }
      $advancedSettings = @(
        [VMware.Vim.AdvancedSetting] @{ Name = 'Config.Etc.issue'; Value = 'Hello Brave New World!' }
        [VMware.Vim.AdvancedSetting] @{ Name = 'Config.Etc.motd'; Value = 'Hello Brave New World!' }
      )

      $viServerMock = {
        return [VMware.Vim.VIServer] @{ Name = '10.23.82.112'; User = 'user' }
      }
      $vmHostMock = {
        return [VMware.Vim.VMHost] @{ Id = 'VMHostId' }
      }
      $advancedSettingsMock = {
        return @(
          [VMware.Vim.AdvancedSetting] @{ Name = 'Config.Etc.issue'; Value = 'Hello World!' }
          [VMware.Vim.AdvancedSetting] @{ Name = 'Config.Etc.motd'; Value = 'Hello World!' }
        )
      }

      Mock -CommandName Connect-VIServer -MockWith $viServerMock -ModuleName $script:moduleName
      Mock -CommandName Get-VMHost -MockWith $vmHostMock -ModuleName $script:moduleName
      Mock -CommandName Get-AdvancedSetting -MockWith $advancedSettingsMock -ModuleName $script:moduleName
    }

    # Arrange
    $resource = New-Object -TypeName $script:resourceName -Property $script:resourceProperties

    It 'Should call the Connect-VIServer mock with the passed server and credentials once' {
      # Act
      $resource.Get()

      # Assert
      Assert-MockCalled -CommandName Connect-VIServer `
        -ParameterFilter { $Server -eq $script:resourceProperties.Server -and $Credential -eq $script:resourceProperties.Credential } `
        -ModuleName $script:moduleName -Exactly 1 -Scope It
    }

    It 'Should call Get-VMHost mock with the passed server and name once' {
      # Act
      $resource.Get()

      # Assert
      Assert-MockCalled -CommandName Get-VMHost `
        -ParameterFilter { $Server -eq $viServer -and $Name -eq $script:resourceProperties.Name } `
        -ModuleName $script:moduleName -Exactly 1 -Scope It
    }

    It 'Should call Get-AdvancedSetting mock with the passed server and vCenter once' {
      # Act
      $resource.Get()

      # Assert
      Assert-MockCalled -CommandName Get-AdvancedSetting `
        -ParameterFilter { $Server -eq $viServer -and $Entity -eq $vmhost } `
        -ModuleName $script:moduleName -Exactly 1 -Scope It
    }

    It 'Should match the properties retrieved from the server' {
      # Act
      $result = $resource.Get()

      # Assert
      $result.Motd | Should -Be 'Hello World!'
      $result.Issue | Should -Be 'Hello World!'
    }
  }
}