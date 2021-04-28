<#
Copyright (c) 2018-2021 VMware, Inc.  All rights reserved

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
    $Script:SampleDscConfiguration = [VmwDscConfiguration]::new(
        'Test',
        @(
            [VmwDscNode]::new(
                'localhost',
                @(
                    [VmwDscResource]::new(
                        'file',
                        'FileResource',
                        @{ ModuleName = 'MyDscResource'; RequiredVersion = '1.0.0.0' },
                        @{
                            Path = "path"
                            SourcePath = "path"
                            Ensure = "present"
                        }
                    ),
                    [VmwDscResource]::new(
                        'file2',
                        'FileResource',
                        @{ ModuleName = 'MyDscResource'; RequiredVersion = '1.0.0.0' },
                        @{
                            Path = "path2"
                            SourcePath = "path2"
                            Ensure = "absent"
                        }
                    )
                )
            )
        )
    )

    $Script:SampleDscConfigurationWithVsphereNode = [VmwDscConfiguration]::new(
        'Test',
        @(
            [VmwVsphereDscNode]::new(
                '10.10.10.10',
                @(
                    [VmwDscResource]::new(
                        'MyDatacenterFolder',
                        'DatacenterFolder',
                        @{ ModuleName = 'VMware.vSphereDSC'; RequiredVersion = (Get-Module -Name 'VMware.vSphereDSC' -ListAvailable).Version.ToString() },
                        @{
                            Location = ''
                            Name = 'MyDatacenterFolder'
                            Ensure = 'Present'
                        }
                    )
                )
            )
        )
    )

    $Script:SampleDscConfigurationWithDuplicateKeyPropertiesResource = [VmwDscConfiguration]::new(
        'Test',
        @(
            [VmwDscNode]::new(
                'localhost',
                @(
                    [VmwDscResource]::new(
                        'file',
                        'FileResource',
                        @{ ModuleName = 'MyDscResource'; RequiredVersion = '1.0.0.0' },
                        @{
                            Path = "path"
                            SourcePath = "path"
                            Ensure = "present"
                        }
                    ),
                    [VmwDscResource]::new(
                        'file2',
                        'FileResource',
                        @{ ModuleName = 'MyDscResource'; RequiredVersion = '1.0.0.0' },
                        @{
                            Path = "path"
                            SourcePath = "path"
                            Ensure = "present"
                        }
                    )
                )
            )
        )
    )

    $Script:SampleDscConfigurationWithMultipleNodes = [VmwDscConfiguration]::new(
        'Test',
        @(
            [VmwDscNode]::new(
                'firstNode',
                @(
                    [VmwDscResource]::new(
                        'file',
                        'FileResource',
                        @{ ModuleName = 'MyDscResource'; RequiredVersion = '1.0.0.0' },
                        @{
                            Path = "path"
                            SourcePath = "path"
                            Ensure = "present"
                        }
                    )
                )
            ),
            [VmwDscNode]::new(
                'secondNode',
                @(
                    [VmwDscResource]::new(
                        'file2',
                        'FileResource',
                        @{ ModuleName = 'MyDscResource'; RequiredVersion = '1.0.0.0' },
                        @{
                            Path = "path2"
                            SourcePath = "path2"
                            Ensure = "absent"
                        }
                    )
                )
            ),
            [VmwDscNode]::new(
                'thirdNode',
                @(
                    [VmwDscResource]::new(
                        'file3',
                        'FileResource',
                        @{ ModuleName = 'MyDscResource'; RequiredVersion = '1.0.0.0' },
                        @{
                            Path = "path3"
                            SourcePath = "path3"
                            Ensure = "present"
                        }
                    )
                )
            )
        )
    )

    Describe 'Get-VmwDscConfiguration' {
        It 'Should return the last executed configuration resources when ExecuteLastConfiguration switch is used' {
            # arrange
            Mock Invoke-DscResource {
                Param(
                    $Method
                )

                if ($Method -eq 'Get') {
                    [PSCustomObject]@{
                        Prop = 'MyProp'
                    }
                }
            } -Verifiable

            $Script:LastExecutedConfiguration = $Script:SampleDscConfiguration

            # act
            $result = Get-VmwDscConfiguration -ExecuteLastConfiguration

            # assert
            Assert-VerifiableMock
            ($null -ne $result) | Should -Be $true
        }
        It 'Should throw when there is no old configuration to be used with ExecuteLastConfiguration switch' {
            #assert
            {
                $Script:LastExecutedConfiguration = $null

                Get-VmwDscConfiguration -ExecuteLastConfiguration
            } | Should -Throw $Script:NoConfigurationDetectedForInvokeException
        }
    }
    Describe 'Test-VmwDscConfiguration' {
        Context 'Detailed switch is on' {
            It 'Should place resources in desired state in ResourcesInDesiredState property' {
                Mock Invoke-DscResource {
                    Param(
                        $Name
                    )

                    [PSCustomObject]@{
                        InDesiredState = $true
                    }
                } -Verifiable

                # act
                $res = Test-VmwDscConfiguration $Script:SampleDscConfiguration -Detailed

                # assert
                Assert-VerifiableMock
                $res.InDesiredState | Should -Be $true
                $res.ResourcesInDesiredState.Count | Should -Be 2
                $res.ResourcesNotInDesiredState.Count | Should -Be 0
            }
            It 'Should place resources not in desired state in ResourcesNotInDesiredState property' {
                Mock Invoke-DscResource {
                    Param(
                        $Name
                    )

                    [PSCustomObject]@{
                        InDesiredState = $false
                    }
                } -Verifiable

                # act
                $res = Test-VmwDscConfiguration $Script:SampleDscConfiguration -Detailed

                # assert
                Assert-VerifiableMock
                $res.InDesiredState | Should -Be $false
                $res.ResourcesInDesiredState.Count | Should -Be 0
                $res.ResourcesNotInDesiredState.Count | Should -Be 2
            }
        }
        Context 'Detailed switch is off' {
            It 'Should return $true if state is desired' {
                Mock Invoke-DscResource {
                    [PSCustomObject]@{
                        InDesiredState = $true
                    }
                } -Verifiable

                # act
                $res = Test-VmwDscConfiguration $Script:SampleDscConfiguration

                # assert
                Assert-VerifiableMock
                $res | Should -Be $true
            }
            It 'Should return $false if state is not desired' {
                Mock Invoke-DscResource {
                    [PSCustomObject]@{
                        InDesiredState = $false
                    }
                } -Verifiable

                # act
                $res = Test-VmwDscConfiguration $Script:SampleDscConfiguration

                # assert
                Assert-VerifiableMock
                $res | Should -Be $false
            }
        }
    }
    Describe 'Start-VmwDscConfiguration' {
        It 'Should not execute set method if resource is in desired state' {
            try {
                # arrange
                $Global:_IsSetExecuted = $false

                Mock Invoke-DscResource {
                    Param(
                        $Method
                    )

                    if ($Method -eq 'Test') {
                        [PSCustomObject]@{
                            InDesiredState = $true
                        }
                    } else {
                        $Global:_IsSetExecuted = $true
                    }
                } -Verifiable

                # act
                Start-VmwDscConfiguration $Script:SampleDscConfiguration

                # assert
                Assert-VerifiableMock
                $Global:_IsSetExecuted | Should -Be $false
            }
            finally {
                Remove-Variable -Name '_IsSetExecuted' -Scope 'Global'
            }
        }
        It 'Should execute set method if resource is not in desired state' {
            try {
                # arrange
                $Global:_IsSetExecuted = $false

                Mock Invoke-DscResource {
                    Param(
                        $Method
                    )

                    if ($Method -eq 'Test') {
                        [PSCustomObject]@{
                            InDesiredState = $false
                        }
                    } else {
                        $Global:_IsSetExecuted = $true
                    }
                } -Verifiable

                # act
                Start-VmwDscConfiguration $Script:SampleDscConfiguration

                # assert
                Assert-VerifiableMock
                $Global:_IsSetExecuted | Should -Be $true
            }
            finally {
                Remove-Variable -Name '_IsSetExecuted' -Scope 'Global'
            }
        }
    }
    Describe 'Invoke-VmwDscConfiguration' {
        It 'Should throw if invalid method is given' {
            # assert
            {
                $splat = @{
                    Configuration = $Script:SampleDscConfiguration
                    Method = 'Invalid Method'
                }

                Invoke-VmwDscConfiguration @splat
            } | Should -Throw
        }
        It 'Should throw if node contains a resource with duplicate key property values' {
            # assert
            {
                $splat = @{
                    Configuration = $Script:SampleDscConfigurationWithDuplicateKeyPropertiesResource
                    Method = 'Test'
                }

                Invoke-VmwDscConfiguration @splat
            } | Should -Throw ($Script:DscResourcesWithDuplicateKeyPropertiesException -f $Script:SampleDscConfigurationWithDuplicateKeyPropertiesResource.Nodes[0].Resources[0].ResourceType)
        }
        It 'Should correctly filter configuration nodes based on ConnectionFilter parameter with string input' {
            # arrange
            $nodeToUse = 'secondNode'

            Mock Invoke-DscResource {
                [PsObject]@{
                    Result = 'myResult'
                }
            } -Verifiable

            # act
            $splat = @{
                Configuration = $Script:SampleDscConfigurationWithMultipleNodes
                ConnectionFilter = $nodeToUse
                Method = 'Test'
            }

            $res = Invoke-VmwDscConfiguration @splat

            # assert
            Assert-VerifiableMock
            $res.OriginalNode.InstanceName | Should -Be $nodeToUse
        }
        It 'Should correctly filter configuration nodes based on ConnectionFilter parameter with object input' {
            # arrange
            $nodeToUse = [PsObject]@{
                Name = 'secondNode'
            }

            Mock Invoke-DscResource {
                [PsObject]@{
                    Result = 'myResult'
                }
            } -Verifiable

            # act
            $splat = @{
                Configuration = $Script:SampleDscConfigurationWithMultipleNodes
                ConnectionFilter = $nodeToUse
                Method = 'Test'
            }

            $res = Invoke-VmwDscConfiguration @splat

            # assert
            Assert-VerifiableMock
            $res.OriginalNode.InstanceName | Should -Be $nodeToUse.Name
        }
        It 'Should correctly filter configuration nodes based on ConnectionFilter parameter with array input' -Skip {
            # arrange
            $nodesToUse = @(
                'secondNode',
                'thirdNode'
            )

            Mock Invoke-DscResource {
                [PsObject]@{
                    Result = 'myResult'
                }
            } -Verifiable

            # act
            $splat = @{
                Configuration = $Script:SampleDscConfigurationWithMultipleNodes
                ConnectionFilter = $nodesToUse
                Method = 'Test'
            }

            $results = Invoke-VmwDscConfiguration @splat

            # assert
            Assert-VerifiableMock
            $results.Count | Should -Be $nodesToUse.Count

            foreach($res in $results) {
                $nodesToUse | Should -Contain $res.OriginalNode.InstanceName
            }
        }
    }
    Describe 'vSphereNode functionality' {
        It 'Should throw if DefaultViServers is null' {
            # assert
            {
                $splat = @{
                    Configuration = $Script:SampleDscConfigurationWithVsphereNode
                    Method = 'Test'
                }

                Invoke-VmwDscConfiguration @splat
            } | Should -Throw $Script:NoVsphereConnectionsFoundException
        }
        It 'Should throw if there are multiple connections to the same vSphere server' {
            try {
                # arrange
                $Global:DefaultViServers = @(
                    [PsObject]@{
                        Name = $Script:SampleDscConfigurationWithVsphereNode.Nodes[0].InstanceName
                    }
                    [PsObject]@{
                        Name = $Script:SampleDscConfigurationWithVsphereNode.Nodes[0].InstanceName
                    }
                )

                # assert
                {
                    $splat = @{
                        Configuration = $Script:SampleDscConfigurationWithVsphereNode
                        Method = 'Test'
                    }
                    Invoke-VmwDscConfiguration @splat
                } | Should -Throw ($Script:TooManyConnectionOnASingleVCenterException -f $Script:SampleDscConfigurationWithVsphereNode.Nodes[0].InstanceName)
            }
            finally {
                Remove-Variable -Name 'DefaultViServers' -Scope 'Global'
            }
        }
        It 'Should Set Connection property of resources correctly' {
            try {
                $Global:_IsConnectionPropertySet = $false
                $Global:DefaultViServers = @(
                    [PsObject]@{
                        Name = $Script:SampleDscConfigurationWithVsphereNode.Nodes[0].InstanceName
                    }
                )

                Mock Invoke-DscResource {
                    Param(
                        $Property
                    )

                    $Global:_IsConnectionPropertySet = $Property.ContainsKey('Connection')

                    [PSCustomObject]@{
                        InDesiredState = $true
                    }
                } -Verifiable

                # act
                $splat = @{
                    Configuration = $Script:SampleDscConfigurationWithVsphereNode
                    Method = 'Test'
                }
                Invoke-VmwDscConfiguration @splat | Out-Null

                # assert
                Assert-VerifiableMock
                $Global:_IsConnectionPropertySet | Should -Be $true
            }
            finally {
                Remove-Variable -Name 'DefaultViServers' -Scope 'Global'
                Remove-Variable -Name '_IsConnectionPropertySet' -Scope 'Global'
            }
        }
    }
}
