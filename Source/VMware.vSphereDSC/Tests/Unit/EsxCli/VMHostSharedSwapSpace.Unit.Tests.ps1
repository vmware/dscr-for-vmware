<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

Using module VMware.vSphereDSC

$script:moduleName = 'VMware.vSphereDSC'

InModuleScope -ModuleName $script:moduleName {
    try {
        $unitTestsFolder = Join-Path (Join-Path (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase 'Tests') 'Unit'
        $modulePath = $env:PSModulePath
        $resourceName = 'VMHostSharedSwapSpace'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
        . "$unitTestsFolder\TestHelpers\Mocks\VMHostSharedSwapSpaceMocks.ps1"

        Describe 'VMHostSharedSwapSpace\Set' -Tag 'Set' {
            BeforeAll {
                # Arrange
                $resourceProperties = New-MocksInSetForVMHostSharedSwapSpace
                $resource = New-Object -TypeName $resourceName -Property $resourceProperties
            }

            It 'Should invoke all defined mocks with the correct parameters' {
                # Act
                $resource.Set()

                # Assert
                Assert-VerifiableMock
            }
        }

        Describe 'VMHostSharedSwapSpace\Test' -Tag 'Test' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostSharedSwapSpace
            }

            Context 'When the VMHost shared swap space configuration should be modified' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTheVMHostSharedSwapSpaceConfigurationShouldBeModified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when the VMHost shared swap space configuration should be modified' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'When the VMHost shared swap space configuration should not be modified' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenTheVMHostSharedSwapSpaceConfigurationShouldNotBeModified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should invoke all defined mocks with the correct parameters' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when the VMHost shared swap space configuration should not be modified' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }
        }

        Describe 'VMHostSharedSwapSpace\Get' -Tag 'Get' {
            BeforeAll {
                # Arrange
                $resourceProperties = New-MocksForVMHostSharedSwapSpace
                $resource = New-Object -TypeName $resourceName -Property $resourceProperties
            }

            It 'Should invoke all defined mocks with the correct parameters' {
                # Act
                $resource.Get()

                # Assert
                Assert-VerifiableMock
            }

            It 'Should retrieve and return the correct values' {
                # Act
                $result = $resource.Get()

                # Assert
                $result.Server | Should -Be $script:viServer.Name
                $result.Name | Should -Be $script:vmHost.Name
                $result.DatastoreEnabled | Should -Be $script:constants.DatastoreEnabled
                $result.DatastoreName | Should -Be $script:constants.DatastoreName
                $result.DatastoreOrder | Should -Be $script:constants.DatastoreOrder
                $result.HostCacheEnabled | Should -Be $script:constants.HostCacheEnabled
                $result.HostCacheOrder | Should -Be $script:constants.HostCacheOrder
                $result.HostLocalSwapEnabled | Should -Be $script:constants.HostLocalSwapEnabled
                $result.HostLocalSwapOrder | Should -Be $script:constants.HostLocalSwapOrder
            }
        }
    }
    finally {
        # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
        Invoke-TestCleanup -ModulePath $modulePath
    }
}
