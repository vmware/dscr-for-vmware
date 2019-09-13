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

$script:moduleName = 'VMware.vSphereDSC'

InModuleScope -ModuleName $script:moduleName {
    try {
        $unitTestsFolder = Join-Path (Join-Path (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase 'Tests') 'Unit'
        $modulePath = $env:PSModulePath
        $baseDSCClassName = 'BaseDSC'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        Describe 'BaseDSC\ShouldUpdateArraySetting' -Tag 'ShouldUpdateArraySetting' {
            It 'Should return $false when the desired array is $null' {
                # Arrange
                $baseDSCClass = New-Object -TypeName $baseDSCClassName

                # Act
                $result = $baseDSCClass.ShouldUpdateArraySetting(@(), $null)

                # Assert
                $result | Should -Be $false
            }

            It 'Should return $true when the desired array is an empty array and the current one has elements' {
                # Arrange
                $baseDSCClass = New-Object -TypeName $baseDSCClassName

                # Act
                $result = $baseDSCClass.ShouldUpdateArraySetting(@(1), @())

                # Assert
                $result | Should -Be $true
            }

            It 'Should return $true when the current array does not contain at least one element from the desired array' {
                # Arrange
                $baseDSCClass = New-Object -TypeName $baseDSCClassName

                # Act
                $result = $baseDSCClass.ShouldUpdateArraySetting(@(1, 2, 3), @(1, 2, 3, 4))

                # Assert
                $result | Should -Be $true
            }

            It 'Should return $true when the desired array is a subset of the current array.' {
                # Arrange
                $baseDSCClass = New-Object -TypeName $baseDSCClassName

                # Act
                $result = $baseDSCClass.ShouldUpdateArraySetting(@(1, 2, 3), @(1, 2))

                # Assert
                $result | Should -Be $true
            }

            It 'Should return $false when the desired array has the same elements as the current array.' {
                # Arrange
                $baseDSCClass = New-Object -TypeName $baseDSCClassName

                # Act
                $result = $baseDSCClass.ShouldUpdateArraySetting(@(1, 2, 3), @(1, 2, 3))

                # Assert
                $result | Should -Be $false
            }
        }
    }

    finally {
        # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
        Invoke-TestCleanup -ModulePath $modulePath
    }
}
