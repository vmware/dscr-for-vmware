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

    [Parameter()]
    [string]
    $Name
)

<#
    The DatastoreClusterAddDatastore DSC Resource Integration Tests require a vCenter Server with at
    least one Datacenter and at least one VMHost located in that Datacenter.
#>

# The 'Name' parameter is not used in the Integration Tests, so it is set to $null.
$Name = $null

$newObjectParamsForCredential = @{
    TypeName = 'System.Management.Automation.PSCredential'
    ArgumentList = @(
        $User,
        (ConvertTo-SecureString -String $Password -AsPlainText -Force)
    )
}
$script:Credential = New-Object @newObjectParamsForCredential

$script:DscResourceName = 'DatastoreClusterAddDatastore'
$script:ConfigurationsPath = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DscResourceName)_Config.ps1"

. "$PSScriptRoot\$script:DscResourceName.Integration.Tests.Helpers.ps1"
Test-Setup

$script:ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
            Server = $Server
            Credential = $script:Credential
            DatastoreClusterDscResourceId = '[DatastoreCluster]DatastoreCluster'
            DatastoreClusterDscResourceName = 'DatastoreCluster'
            VmfsDatastoreDscResourceIds = @('[VmfsDatastore]VmfsDatastoreOne', '[VmfsDatastore]VmfsDatastoreTwo')
            VmfsDatastoreOneDscResourceName = 'VmfsDatastoreOne'
            VmfsDatastoreTwoDscResourceName = 'VmfsDatastoreTwo'
            DatastoreClusterAddDatastoreDscResourceName = 'DatastoreClusterAddDatastore'
            DatastoreClusterName = 'DscDatastoreCluster'
            DatastoreClusterLocation = [string]::Empty
            DatacenterName = $script:Datacenter.Name
            DatacenterLocation = $script:DatacenterLocation
            VMHostName = $script:VMHost.Name
            VmfsDatastoreOneName = 'DscVmfsDatastoreOne'
            VmfsDatastoreTwoName = 'DscVmfsDatastoreTwo'
            VmfsDatastoreNames = @('DscVmfsDatastoreOne', 'DscVmfsDatastoreTwo')
            ScsiLunOneCanonicalName = $script:ScsiLunCanonicalNames[0]
            ScsiLunTwoCanonicalName = $script:ScsiLunCanonicalNames[1]
        }
    )
}

. $script:ConfigurationsPath -Verbose:$true -ErrorAction Stop

$script:CreateDatastoreClusterAndDatastoresConfigurationName = "$($script:DscResourceName)_CreateDatastoreClusterAndTwoVmfsDatastores_Config"
$script:AddDatastoresToDatastoreClusterConfigurationName = "$($script:DscResourceName)_AddTwoVmfsDatastoresToDatastoreCluster_Config"
$script:RemoveDatastoreClusterAndDatastoresConfigurationName = "$($script:DscResourceName)_RemoveDatastoreClusterAndTwoVmfsDatastores_Config"

$script:CreateDatastoreClusterAndDatastoresMofFilePath = Join-Path -Path $PSScriptRoot -ChildPath $script:CreateDatastoreClusterAndDatastoresConfigurationName
$script:AddDatastoresToDatastoreClusterMofFilePath = Join-Path -Path $PSScriptRoot -ChildPath $script:AddDatastoresToDatastoreClusterConfigurationName
$script:RemoveDatastoreClusterAndDatastoresMofFilePath = Join-Path -Path $PSScriptRoot -ChildPath $script:RemoveDatastoreClusterAndDatastoresConfigurationName

Describe "$($script:DscResourceName)_Integration" {
    Context 'When adding two Datastores to Datastore Cluster' {
        BeforeAll {
            # Arrange
            & $script:CreateDatastoreClusterAndDatastoresConfigurationName `
                -OutputPath $script:CreateDatastoreClusterAndDatastoresMofFilePath `
                -ConfigurationData $script:ConfigurationData `
                -ErrorAction Stop

            $startDscConfigurationParamsCreateDatastoreClusterAndDatastores = @{
                Path = $script:CreateDatastoreClusterAndDatastoresMofFilePath
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParamsCreateDatastoreClusterAndDatastores } | Should -Not -Throw

            It 'Should compile and apply the MOF without throwing' {
                # Arrange
                & $script:AddDatastoresToDatastoreClusterConfigurationName `
                    -OutputPath $script:AddDatastoresToDatastoreClusterMofFilePath `
                    -ConfigurationData $script:ConfigurationData `
                    -ErrorAction Stop

                $startDscConfigurationParamsAddDatastoresToDatastoreCluster = @{
                    Path = $script:AddDatastoresToDatastoreClusterMofFilePath
                    ComputerName = $script:ConfigurationData.AllNodes.NodeName
                    Wait = $true
                    Force = $true
                    Verbose = $true
                    ErrorAction = 'Stop'
                }

                # Act && Assert
                { Start-DscConfiguration @startDscConfigurationParamsAddDatastoresToDatastoreCluster } | Should -Not -Throw
            }
        }

        It 'Should be able to call Test-DscConfiguration without throwing' {
            # Arrange
            $joinPathParams = @{
                Path = $script:AddDatastoresToDatastoreClusterMofFilePath
                ChildPath = "$($script:ConfigurationData.AllNodes.NodeName).mof"
            }

            $testDscConfigurationParams = @{
                ReferenceConfiguration = Join-Path @joinPathParams
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Test-DscConfiguration @testDscConfigurationParams } | Should -Not -Throw
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            # Arrange
            $joinPathParams = @{
                Path = $script:AddDatastoresToDatastoreClusterMofFilePath
                ChildPath = "$($script:ConfigurationData.AllNodes.NodeName).mof"
            }

            $testDscConfigurationParams = @{
                ReferenceConfiguration = Join-Path @joinPathParams
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            (Test-DscConfiguration @testDscConfigurationParams).InDesiredState | Should -BeTrue
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            # Arrange && Act && Assert
            { Get-DscConfiguration -Verbose:$true -ErrorAction Stop } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration and all parameters should match' {
            # Arrange
            $whereObjectParams = @{
                FilterScript = {
                    $_.ConfigurationName -eq $script:AddDatastoresToDatastoreClusterConfigurationName
                }
            }

            # Act
            $DatastoreClusterAddDatastoreDscResource = Get-DscConfiguration -Verbose:$true -ErrorAction Stop | Where-Object @whereObjectParams

            # Assert
            $DatastoreClusterAddDatastoreDscResource.Server | Should -Be $script:ConfigurationData.AllNodes.Server
            $DatastoreClusterAddDatastoreDscResource.DatacenterName | Should -Be $script:ConfigurationData.AllNodes.DatacenterName
            $DatastoreClusterAddDatastoreDscResource.DatacenterLocation | Should -Be $script:ConfigurationData.AllNodes.DatacenterLocation
            $DatastoreClusterAddDatastoreDscResource.DatastoreClusterName | Should -Be $script:ConfigurationData.AllNodes.DatastoreClusterName
            $DatastoreClusterAddDatastoreDscResource.DatastoreClusterLocation | Should -Be $script:ConfigurationData.AllNodes.DatastoreClusterLocation

            $actualDatastoreNames = $DatastoreClusterAddDatastoreDscResource.DatastoreNames | Sort-Object
            $expectedDatastoreNames = $script:ConfigurationData.AllNodes.VmfsDatastoreNames | Sort-Object
            $actualDatastoreNames | Should -Be $expectedDatastoreNames
        }

        AfterAll {
            # Arrange
            & $script:RemoveDatastoreClusterAndDatastoresConfigurationName `
                -OutputPath $script:RemoveDatastoreClusterAndDatastoresMofFilePath `
                -ConfigurationData $script:ConfigurationData `
                -ErrorAction Stop

            $startDscConfigurationParamsRemoveDatastoreClusterAndDatastores = @{
                Path = $script:RemoveDatastoreClusterAndDatastoresMofFilePath
                ComputerName = $script:ConfigurationData.AllNodes.NodeName
                Wait = $true
                Force = $true
                Verbose = $true
                ErrorAction = 'Stop'
            }

            # Act && Assert
            { Start-DscConfiguration @startDscConfigurationParamsRemoveDatastoreClusterAndDatastores } | Should -Not -Throw

            Remove-Item -Path $script:CreateDatastoreClusterAndDatastoresMofFilePath -Recurse -Confirm:$false -Verbose:$true -ErrorAction Stop
            Remove-Item -Path $script:AddDatastoresToDatastoreClusterMofFilePath -Recurse -Confirm:$false -Verbose:$true -ErrorAction Stop
            Remove-Item -Path $script:RemoveDatastoreClusterAndDatastoresMofFilePath -Recurse -Confirm:$false -Verbose:$true -ErrorAction Stop
        }
    }
}
