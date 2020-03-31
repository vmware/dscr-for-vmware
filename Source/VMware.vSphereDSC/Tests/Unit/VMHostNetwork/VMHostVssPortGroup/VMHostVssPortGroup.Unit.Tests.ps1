<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

Using module '..\..\..\..\VMware.vSphereDSC.psm1'

$script:moduleName = 'VMware.vSphereDSC'

InModuleScope -ModuleName $script:moduleName {
    try {
        $unitTestsFolder = Join-Path (Join-Path (Get-Module VMware.vSphereDSC -ListAvailable).ModuleBase 'Tests') 'Unit'
        $modulePath = $env:PSModulePath
        $resourceName = 'VMHostVssPortGroup'

        . "$unitTestsFolder\TestHelpers\TestUtils.ps1"

        # Calls the function to Import the mocked VMware.VimAutomation.Core module before all tests.
        Invoke-TestSetup

        . "$unitTestsFolder\TestHelpers\Mocks\MockData.ps1"
        . "$unitTestsFolder\TestHelpers\Mocks\VMHostVssPortGroupMocks.ps1"

        Describe 'VMHostVssPortGroup\Set' -Tag 'Set' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostVssPortGroup
            }

            Context 'Invoking with Ensure Present and non existing Port Group' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksInSetWhenEnsurePresentAndNonExistingPortGroup
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the New-VirtualPortGroup mock once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'New-VirtualPortGroup'
                        ParameterFilter = { $Server -eq $script:viServer -and $Name -eq $script:constants.VirtualPortGroupName -and $VirtualSwitch -eq $script:virtualSwitch -and !$Confirm }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Invoking with Ensure Present, existing Port Group and negative VLanId' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsurePresentExistingPortGroupAndNegativeVLanId
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    try {
                        # Act
                        $resource.Set()
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw the correct error when the VLanId is negative' {
                    # Act && Assert
                    { $resource.Set() } | Should -Throw "The passed VLanId value $($resourceProperties.VLanId) is not valid. The valid values are in the following range: [0, $($resource.VLanIdMaxValue)]."
                }
            }

            Context 'Invoking with Ensure Present, existing Port Group and VLanId bigger than the Max valid value' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsurePresentExistingPortGroupAndVLanIdBiggerThanTheMaxValidValue
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    try {
                        # Act
                        $resource.Set()
                    }
                    catch {
                        # Assert
                        Assert-VerifiableMock
                    }
                }

                It 'Should throw the correct error when the VLanId is bigger than the Max valid value' {
                    # Act && Assert
                    { $resource.Set() } | Should -Throw "The passed VLanId value $($resourceProperties.VLanId) is not valid. The valid values are in the following range: [0, $($resource.VLanIdMaxValue)]."
                }
            }

            Context 'Invoking with Ensure Present, existing Port Group and valid VLanId' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsurePresentExistingPortGroupAndValidVLanId
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Set-VirtualPortGroup mock once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Set-VirtualPortGroup'
                        ParameterFilter = { $VirtualPortGroup -eq $script:virtualPortGroup -and $VLanId -eq $script:constants.VLanId -and !$Confirm }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Invoking with Ensure Absent and non existing Port Group' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksInSetWhenEnsureAbsentAndNonExistingPortGroup
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should not call the Remove-VirtualPortGroup mock' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Remove-VirtualPortGroup'
                        ParameterFilter = { $VirtualPortGroup -eq $script:virtualPortGroup -and !$Confirm }
                        Exactly = $true
                        Times = 0
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }

            Context 'Invoking with Ensure Absent and existing Port Group' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksInSetWhenEnsureAbsentAndExistingPortGroup
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Set()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should call the Remove-VirtualPortGroup mock once' {
                    # Act
                    $resource.Set()

                    # Assert
                    $assertMockCalledParams = @{
                        CommandName = 'Remove-VirtualPortGroup'
                        ParameterFilter = { $VirtualPortGroup -eq $script:virtualPortGroup -and !$Confirm }
                        Exactly = $true
                        Times = 1
                        Scope = 'It'
                    }

                    Assert-MockCalled @assertMockCalledParams
                }
            }
        }

        Describe 'VMHostVssPortGroup\Test' -Tag 'Test' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostVssPortGroup
            }

            Context 'Invoking with Ensure Present and non existing Port Group' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsurePresentAndNonExistingPortGroup
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when the Port Group does not exist' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'Invoking with Ensure Present, existing Port Group and no VLanId specified' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsurePresentExistingPortGroupAndNoVLanIdSpecified
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when no VLanId is specified' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }

            Context 'Invoking with Ensure Present, existing Port Group and VLanId not equal to Port Group VLanId' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsurePresentExistingPortGroupAndVLanIdNotEqualToPortGroupVLanId
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when the passed VLanId is not equal to the Port Group VLanId' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }

            Context 'Invoking with Ensure Present, existing Port Group and VLanId equal to Port Group VLanId' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsurePresentExistingPortGroupAndVLanIdEqualToPortGroupVLanId
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when the passed VLanId is equal to the Port Group VLanId' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }

            Context 'Invoking with Ensure Absent and non existing Port Group' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureAbsentAndNonExistingPortGroup
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $true when the Port Group does not exist' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $true
                }
            }

            Context 'Invoking with Ensure Absent and existing Port Group' {
                BeforeAll {
                    # Arrange
                    $resourceProperties = New-MocksWhenEnsureAbsentAndExistingPortGroup
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Test()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should return $false when the Port Group exists' {
                    # Act
                    $result = $resource.Test()

                    # Assert
                    $result | Should -Be $false
                }
            }
        }

        Describe 'VMHostVssGroup\Get' -Tag 'Get' {
            BeforeAll {
                # Arrange
                New-MocksForVMHostVssPortGroup
            }

            Context 'Invoking with Ensure Present and non existing Port Group' {
                BeforeAll {
                    $resourceProperties = New-MocksWhenEnsurePresentAndNonExistingPortGroup
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Get()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should retrieve the correct settings from the Resource properties and Ensure should be set to Absent' {
                    # Act
                    $result = $resource.Get()

                    # Assert
                    $result.Server | Should -Be $resourceProperties.Server
                    $result.VMHostName | Should -Be $resourceProperties.VMHostName
                    $result.Name | Should -Be $resourceProperties.Name
                    $result.VssName | Should -Be $resourceProperties.VssName
                    $result.Ensure | Should -Be 'Absent'
                    $result.VLanId | Should -Be $resourceProperties.VLanId
                }
            }

            Context 'Invoking with Ensure Present and existing Port Group' {
                BeforeAll {
                    $resourceProperties = New-MocksWhenEnsurePresentAndExistingPortGroup
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Get()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should retrieve the correct settings from the Server and Ensure should be set to Present' {
                    # Act
                    $result = $resource.Get()

                    # Assert
                    $result.Server | Should -Be $resourceProperties.Server
                    $result.VMHostName | Should -Be $script:vmHost.Name
                    $result.Name | Should -Be $script:virtualPortGroup.Name
                    $result.VssName | Should -Be $script:virtualPortGroup.VirtualSwitch.Name
                    $result.Ensure | Should -Be 'Present'
                    $result.VLanId | Should -Be $script:virtualPortGroup.VLanId
                }
            }

            Context 'Invoking with Ensure Absent and non existing Port Group' {
                BeforeAll {
                    $resourceProperties = New-MocksWhenEnsureAbsentAndNonExistingPortGroup
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Get()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should retrieve the correct settings from the Resource properties and Ensure should be set to Absent' {
                    # Act
                    $result = $resource.Get()

                    # Assert
                    $result.Server | Should -Be $resourceProperties.Server
                    $result.VMHostName | Should -Be $resourceProperties.VMHostName
                    $result.Name | Should -Be $resourceProperties.Name
                    $result.VssName | Should -Be $resourceProperties.VssName
                    $result.Ensure | Should -Be 'Absent'
                    $result.VLanId | Should -Be $resourceProperties.VLanId
                }
            }

            Context 'Invoking with Ensure Absent and existing Port Group' {
                BeforeAll {
                    $resourceProperties = New-MocksWhenEnsureAbsentAndExistingPortGroup
                    $resource = New-Object -TypeName $resourceName -Property $resourceProperties
                }

                It 'Should call all defined mocks' {
                    # Act
                    $resource.Get()

                    # Assert
                    Assert-VerifiableMock
                }

                It 'Should retrieve the correct settings from the Server and Ensure should be set to Present' {
                    # Act
                    $result = $resource.Get()

                    # Assert
                    $result.Server | Should -Be $resourceProperties.Server
                    $result.VMHostName | Should -Be $script:vmHost.Name
                    $result.Name | Should -Be $script:virtualPortGroup.Name
                    $result.VssName | Should -Be $script:virtualPortGroup.VirtualSwitch.Name
                    $result.Ensure | Should -Be 'Present'
                    $result.VLanId | Should -Be $script:virtualPortGroup.VLanId
                }
            }
        }
    }
    finally {
        # Calls the function to Remove the mocked VMware.VimAutomation.Core module after all tests.
        Invoke-TestCleanup -ModulePath $modulePath
    }
}
