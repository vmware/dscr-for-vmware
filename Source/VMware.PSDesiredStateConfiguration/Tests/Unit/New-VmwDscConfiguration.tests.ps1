<#
Copyright (c) 2018-2021 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

$root = Split-Path -Path (Split-Path -Path $PSScriptRoot)

$module = Join-Path -Path $root -ChildPath 'VMware.PSDesiredStateConfiguration.psd1'

Import-Module $module -Force

InModuleScope -ModuleName 'VMware.PSDesiredStateConfiguration' {
    try {
        $rootTestPath = Split-Path $PSScriptRoot

        $script:configFolder = Join-Path -Path $rootTestPath -ChildPath 'Sample Configurations'
        $script:configurationDataFolder = Join-Path -Path $script:configFolder -ChildPath 'ConfigurationData'
        $script:nodeConfigFolder = Join-Path -Path $script:configFolder -ChildPath 'Nodes'

        $util = Join-Path -Path $rootTestPath -ChildPath 'Utility.ps1'
        . $util

        $Global:OldProgressPreference = $ProgressPreference
        $Global:ProgressPreference = 'SilentlyContinue'

        Describe 'New-VmwDscConfiguration Tests' {
            It 'Should compile a DSC Configuration with one DSC Resource correctly' {
                # Arrange
                $configFile = Join-Path -Path $script:configFolder -ChildPath 'simple.ps1'

                # Act
                $dscConfiguration = New-VmwDscConfiguration -Path $configFile

                # Assert
                Script:AssertConfigurationEqual $dscConfiguration $script:expectedCompiled
            }

            It 'Should compile a DSC Configuration with many DSC Resources correctly' {
                # Arrange
                $configFile = Join-Path -Path $script:configFolder -ChildPath 'manyResources.ps1'

                # Act
                $dscConfiguration = New-VmwDscConfiguration -Path $configFile

                # Assert
                Script:AssertConfigurationEqual $dscConfiguration $script:expectedCompiled
            }

            It 'Should compile a DSC Configuration with script parameters correctly' {
                # Arrange
                $configFile = Join-Path -Path $script:configFolder -ChildPath 'fileParams.ps1'

                # Act
                $dscConfiguration = New-VmwDscConfiguration -Path $configFile -Parameters @{ PathToUse = 'C:\Users\temp' }

                # Assert
                Script:AssertConfigurationEqual $dscConfiguration $script:expectedCompiled
            }

            It 'Should compile a DSC Configuration with dependencies and order the DSC Resources correctly' {
                # Arrange
                $configFile = Join-Path -Path $script:configFolder -ChildPath 'dependsOnOrder.ps1'

                # Act
                $dscConfiguration = New-VmwDscConfiguration -Path $configFile

                # Assert
                Script:AssertConfigurationEqual $dscConfiguration $script:expectedCompiled
            }

            It 'Should compile a DSC Configuration with multiple dependencies on a DSC Resource and order the DSC Resources correctly' {
                # Arrange
                $configFile = Join-Path -Path $script:configFolder -ChildPath 'multipleDependsOnResource.ps1'

                # Act
                $dscConfiguration = New-VmwDscConfiguration -Path $configFile

                # Assert
                Script:AssertConfigurationEqual $dscConfiguration $script:expectedCompiled
            }

            It 'Should compile all DSC Configurations defined in the script file correctly' {
                # Arrange
                $configFile = Join-Path -Path $script:configFolder -ChildPath 'Multiple_DSCConfigurations.ps1'

                # Act
                $dscConfigurations = New-VmwDscConfiguration -Path $configFile

                # Assert
                Script:AssertConfigurationEqual $dscConfigurations[0] $script:expectedCompiledOne
                Script:AssertConfigurationEqual $dscConfigurations[1] $script:expectedCompiledTwo
            }

            It 'Should compile only the DSC Configuration with the specified name correctly' {
                # Arrange
                $configFile = Join-Path -Path $script:configFolder -ChildPath 'Multiple_DSCConfigurations.ps1'

                # Act
                $dscConfiguration = New-VmwDscConfiguration -Path $configFile -ConfigurationName 'DSC_Configuration_Two'

                # Assert
                Script:AssertConfigurationEqual $dscConfiguration $script:expectedCompiledTwo
            }

            It 'Should throw an exception with the correct message for a DSC Configuration with duplicate DSC Resources' {
                # Arrange
                $configFile = Join-Path -Path $script:configFolder -ChildPath 'duplicateResources.ps1'

                # Act && Assert
                { New-VmwDscConfiguration -Path $configFile } | Should -Throw ($script:DuplicateResourceException -f 'file', 'FileResource')
            }

            It 'Should throw an exception with the correct message for a DSC Configuration with a DSC Resource with invalid dependency' {
                # Arrange
                $configFile = Join-Path -Path $script:configFolder -ChildPath 'invalidDependsOn.ps1'

                # Act && Assert
                { New-VmwDscConfiguration -Path $configFile } | Should -Throw ($script:DependsOnResourceNotFoundException -f 'file', 'Something else')
            }

            It 'Should throw an exception for a DSC Configuration that contains an invalid code' {
                # Arrange
                $configFile = Join-Path -Path $script:configFolder -ChildPath 'innerException.ps1'

                # Act && Assert
                { New-VmwDscConfiguration -Path $configFile } | Should -Throw
            }

            Context 'New-VmwDscConfiguration ConfigurationData Tests' {
                It 'Should throw an exception with the correct message for a ConfigurationData where AllNodes key is not an array' {
                    # Arrange
                    $configFile = Join-Path -Path $script:configurationDataFolder -ChildPath 'AllNodes_NotAnArray.ps1'

                    # Act && Assert
                    { New-VmwDscConfiguration -Path $configFile } | Should -Throw $script:ConfigurationDataAllNodesKeyIsNotAnArrayException
                }

                It 'Should throw an exception with the correct message for a ConfigurationData where AllNodes array contains a value which is not a hashtable' {
                    # Arrange
                    $configFile = Join-Path -Path $script:configurationDataFolder -ChildPath 'AllNodes_ArrayWithNonHashtable_Value.ps1'

                    # Act && Assert
                    { New-VmwDscConfiguration -Path $configFile } | Should -Throw $script:ConfigurationDataNodeEntryInAllNodesIsNotAHashtableException
                }

                It 'Should throw an exception with the correct message for a ConfigurationData where AllNodes array contains a hashtable value without NodeName key' {
                    # Arrange
                    $configFile = Join-Path -Path $script:configurationDataFolder -ChildPath 'AllNodes_HashtableValue_Without_NodeNameKey.ps1'

                    # Act && Assert
                    { New-VmwDscConfiguration -Path $configFile } | Should -Throw $script:ConfigurationDataNodeEntryInAllNodesDoesNotContainNodeNameException
                }

                It 'Should throw an exception with the correct message for a ConfigurationData where AllNodes array contains values with duplicate NodeName keys' {
                    # Arrange
                    $configFile = Join-Path -Path $script:configurationDataFolder -ChildPath 'AllNodes_Values_With_Duplicate_NodeNameKeys.ps1'

                    # Act && Assert
                    { New-VmwDscConfiguration -Path $configFile } | Should -Throw $script:DuplicateEntryInAllNodesException
                }

                It 'Should compile a DSC Configuration with ConfigurationData correctly' {
                    # Arrange
                    $configFile = Join-Path -Path $script:configFolder -ChildPath 'configurationDataConfig.ps1'

                    # Act
                    $dscConfiguration = New-VmwDscConfiguration -Path $configFile

                    # Assert
                    Script:AssertConfigurationEqual $dscConfiguration $script:expectedCompiled
                }
            }

            Context 'New-VmwDscConfiguration Composite DSC Resources Tests' {
                if ($PSVersionTable.OS -Match 'Microsoft Windows') {
                    It 'Should compile a DSC Configuration with Composite DSC Resource correctly' {
                        # Arrange
                        $configFile = Join-Path -Path $script:configFolder -ChildPath 'compositeResourceConfig.ps1'

                        # Act
                        $dscConfiguration = New-VmwDscConfiguration -Path $configFile

                        # Assert
                        Script:AssertConfigurationEqual $dscConfiguration $script:expectedCompiled
                    }
                }
            }

            Context 'New-VmwDscConfiguration Node Tests' {
                It 'Should compile a DSC Configuration with a single Node correctly' {
                    # Arrange
                    $configFile = Join-Path -Path $script:nodeConfigFolder -ChildPath 'singleNode.ps1'

                    # Act
                    $dscConfiguration = New-VmwDscConfiguration -Path $configFile

                    # Assert
                    Script:AssertConfigurationEqual $dscConfiguration $script:expectedCompiled
                }

                It 'Should compile a DSC Configuration and group the DSC Resources from one vSphereNode which value is array correctly' {
                    # Arrange
                    $configFile = Join-Path -Path $script:nodeConfigFolder -ChildPath 'oneNodeManyConnections.ps1'

                    # Act
                    $dscConfiguration = New-VmwDscConfiguration -Path $configFile

                    # Assert
                    Script:AssertConfigurationEqual $dscConfiguration $script:expectedCompiled
                }

                It 'Should compile a DSC Configuration with multiple Nodes correctly' {
                    # Arrange
                    $configFile = Join-Path -Path $script:nodeConfigFolder -ChildPath 'manyNodes.ps1'

                    # Act
                    $dscConfiguration = New-VmwDscConfiguration -Path $configFile

                    # Assert
                    Script:AssertConfigurationEqual $dscConfiguration $script:expectedCompiled
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
