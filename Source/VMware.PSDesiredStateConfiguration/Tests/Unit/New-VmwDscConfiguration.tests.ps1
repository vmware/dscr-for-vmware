<#
Desired State Configuration Resources for VMware

Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

$root = Split-Path (Split-Path $PSScriptRoot)

$module = Join-Path $root 'VMware.PSDesiredStateConfiguration.psd1'

Import-Module $module -Force

InModuleScope -ModuleName 'VMware.PSDesiredStateConfiguration' {
    try {
        $rootTestPath = Split-Path $PSScriptRoot

        $Script:configFolder = Join-Path $rootTestPath 'Sample Configurations'
    
        $util = Join-Path $rootTestPath 'Utility.ps1'
        . $util
    
        $Global:OldProgressPreference = $ProgressPreference
        $Global:ProgressPreference = 'SilentlyContinue'
    
        Describe 'New-VmwDscConfiguration' {
            It 'Should Compile configuration with a single correctly' {
                # arrange
                $configToUse = 'simple.ps1'
                $configFile = Join-Path $Script:configFolder $configToUse
    
                . $configFile
    
                # act
                $res = New-VmwDscConfiguration 'Test'
    
                # assert
    
                Script:AssertConfigurationEqual $res $Script:expectedCompiled
            }
            It 'Should Compile configuration with multiple resources correctly' {
                # arrange
                $configToUse = 'manyResources.ps1'
                $configFile = Join-Path $Script:configFolder $configToUse
    
                . $configFile
    
                # act
                $res = New-VmwDscConfiguration 'Test'
    
                # assert
    
                Script:AssertConfigurationEqual $res $Script:expectedCompiled
            }
            It 'Should Compile configuration with parameters in file correctly' {
                # arrange
                $configToUse = 'fileParams.ps1'
                $configFile = Join-Path $Script:configFolder $configToUse
    
                . $configFile 'Test path'
    
                # act
                $res = New-VmwDscConfiguration 'Test'
    
                # assert
    
                Script:AssertConfigurationEqual $res $Script:expectedCompiled
            }
            It 'Should Compile configuration with a dependsOn correctly and order resources properly' {
                # arrange
                $configToUse = 'dependsOnOrder.ps1'
                $configFile = Join-Path $Script:configFolder $configToUse
    
                . $configFile
    
                # act
                $res = New-VmwDscConfiguration 'Test'
    
                # assert
    
                Script:AssertConfigurationEqual $res $Script:expectedCompiled
            }
            It 'Should compile configuration with parameters correctly' {
                # arrange
                $configToUse = 'configParams.ps1'
                $configFile = Join-Path $Script:configFolder $configToUse
                $paramsToUse = @{
                    Path = 'parameter path'
                    SourcePath = 'parameter sourcepath'
                    Ensure = 'present'
                }
    
                . $configFile
    
                $Script:expectedCompiled.Resources[0].Property = $paramsToUse
    
                # act
                $res = New-VmwDscConfiguration 'Test' -CustomParams $paramsToUse
    
                # assert
    
                Script:AssertConfigurationEqual $res $Script:expectedCompiled
            }
            It 'Should compile configuration with multiple DependsOn resources in a single resource' {
                # arrange
                $configToUse = 'multipleDependsOnResource.ps1'
                $configFile = Join-Path $Script:configFolder $configToUse
    
                . $configFile
                # act
                $res = New-VmwDscConfiguration 'Test' -CustomParams $paramsToUse
    
                # assert
                Script:AssertConfigurationEqual $res $Script:expectedCompiled
            }
            #TODO Remove when node logic is implemented
            It 'Should throw if configuration contains nodes' {
                # arrange
                $configToUse = 'manyNodes.ps1'
                $configFile = Join-Path $Script:configFolder $configToUse
    
                . $configFile
    
                # assert
    
                { New-VmwDscConfiguration 'Test' } | Should -Throw
            }
            It 'Should throw if given an invaid configuration name' {
                # arrange
                $configName = 'Non-Existing Configuration'
    
                # assert
    
                { New-VmwDscConfiguration $configName } | Should -Throw ($Script:ConfigurationNotFoundException -f $configName)
            }
            It 'Should throw if given a configuration with duplicate resources' {
                # arrange
                $configToUse = 'duplicateResources.ps1'
                $configFile = Join-Path $Script:configFolder $configToUse
    
                . $configFile
    
                # assert
    
                { New-VmwDscConfiguration 'Test' } | Should -Throw ($Script:DuplicateResourceException -f 'file', 'FileResource')
            }
            It 'Should throw if given a configuration with a resource that contains an invalid dependsOn property' {
                # arrange
                $configToUse = 'invalidDependsOn.ps1'
                $configFile = Join-Path $Script:configFolder $configToUse
    
                . $configFile
    
                # assert
                { New-VmwDscConfiguration 'Test' } | Should -Throw ($Script:DependsOnResourceNotFoundException -f 'file', 'Something else')
                #"DependsOn resource of $($Resources[$key]) with name $dependency was not found"
            }
            It 'Should throw if configuration contains code that causes an exception' {
                # arrange
                $configToUse = 'innerException.ps1'
                $configFile = Join-Path $Script:configFolder $configToUse
    
                . $configFile
    
                # assert
                { New-VmwDscConfiguration 'Test' } | Should -Throw
            }
            It 'Should throw if configName is not a configuration' {
                # arrange
                function ImpostorConfig { }
    
                # assert
                { New-VmwDscConfiguration 'ImpostorConfig' } | Should -Throw ($Script:CommandIsNotAConfigurationException -f 'ImpostorConfig', 'function')
            }
            Context 'Nested Configurations' {
                It 'Should compile nested configuration correctly' {
                    # arrange
                    $configToUse = 'nestedConfig.ps1'
                    $configFile = Join-Path $Script:configFolder $configToUse
    
                    . $configFile
                    # act
                    $res = New-VmwDscConfiguration 'Test'
    
                    # assert
                    Script:AssertConfigurationEqual $res $Script:expectedCompiled
                }
                It 'Should compile composite resource correctly' {

                    $os = $PSVersionTable['OS']

                    # null check because the OS key is not present on PowerShell 5.1
                    if ([string]::IsNullOrEmpty($os)) {
                        $os = 'Microsoft Windows'
                    }

                    if (-not $os.Contains('Microsoft Windows')) {
                        Write-Warning 'Composite Resources are not discoverable in non windows OS due to a bug in Powershell'

                        $true | Should -Be $true
                        
                        return
                    }

                    # arrange
                    $configToUse = 'compositeResourceConfig.ps1'
                    $configFile = Join-Path $Script:configFolder $configToUse
    
                    .$configFile
                    # act
                    $res = New-VmwDscConfiguration 'Test'
    
                    # assert
                    Script:AssertConfigurationEqual $res $Script:expectedCompiled
                }
            }
        }
    }
    finally {
        if ($null -eq $Global:OldProgressPreference) {
            $Global:OldProgressPreference = 'continue'
        }
        
        $Global:ProgressPreference = $Global:OldProgressPreference
    }
}

