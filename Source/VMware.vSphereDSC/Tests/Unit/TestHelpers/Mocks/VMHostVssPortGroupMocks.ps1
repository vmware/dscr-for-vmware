<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

function New-VMHostVssPortGroupProperties {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssPortGroupProperties = @{
        Server = $script:constants.VIServerName
        Credential = $script:credential
        VMHostName = $script:constants.VMHostName
        VssName = $script:constants.VirtualSwitchName
    }

    $vmHostVssPortGroupProperties
}

function New-MocksForVMHostVssPortGroup {
    [CmdletBinding()]

    $viServerMock = $script:viServer
    $vmHostMock = $script:vmHost
    $virtualSwitchMock = $script:virtualSwitch

    Mock -CommandName Connect-VIServer -MockWith { return $viServerMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VMHost -MockWith { return $vmHostMock }.GetNewClosure() -Verifiable
    Mock -CommandName Get-VirtualSwitch -MockWith { return $virtualSwitchMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VirtualSwitchName -and $VMHost -eq $script:vmHost -and $Standard } -Verifiable
}

function New-MocksInSetWhenEnsurePresentAndNonExistingPortGroup {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssPortGroupProperties = New-VMHostVssPortGroupProperties
    $vmHostVssPortGroupProperties.Name = $script:constants.VirtualPortGroupName
    $vmHostVssPortGroupProperties.Ensure = 'Present'

    Mock -CommandName Get-VirtualPortGroup -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VirtualPortGroupName -and $VirtualSwitch -eq $script:virtualSwitch -and $VMHost -eq $script:vmHost } -Verifiable
    Mock -CommandName New-VirtualPortGroup -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostVssPortGroupProperties
}

function New-MocksWhenEnsurePresentExistingPortGroupAndNegativeVLanId {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssPortGroupProperties = New-VMHostVssPortGroupProperties
    $vmHostVssPortGroupProperties.Name = $script:constants.VirtualPortGroupName
    $vmHostVssPortGroupProperties.Ensure = 'Present'
    $vmHostVssPortGroupProperties.VLanId = -1

    $virtualPortGroupMock = $script:virtualPortGroup

    Mock -CommandName Get-VirtualPortGroup -MockWith { return $virtualPortGroupMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VirtualPortGroupName -and $VirtualSwitch -eq $script:virtualSwitch -and $VMHost -eq $script:vmHost } -Verifiable

    $vmHostVssPortGroupProperties
}

function New-MocksWhenEnsurePresentExistingPortGroupAndVLanIdBiggerThanTheMaxValidValue {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssPortGroupProperties = New-VMHostVssPortGroupProperties
    $vmHostVssPortGroupProperties.Name = $script:constants.VirtualPortGroupName
    $vmHostVssPortGroupProperties.Ensure = 'Present'
    $vmHostVssPortGroupProperties.VLanId = $script:constants.VLanId + 1

    $virtualPortGroupMock = $script:virtualPortGroup

    Mock -CommandName Get-VirtualPortGroup -MockWith { return $virtualPortGroupMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VirtualPortGroupName -and $VirtualSwitch -eq $script:virtualSwitch -and $VMHost -eq $script:vmHost } -Verifiable

    $vmHostVssPortGroupProperties
}

function New-MocksWhenEnsurePresentExistingPortGroupAndValidVLanId {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssPortGroupProperties = New-VMHostVssPortGroupProperties
    $vmHostVssPortGroupProperties.Name = $script:constants.VirtualPortGroupName
    $vmHostVssPortGroupProperties.Ensure = 'Present'
    $vmHostVssPortGroupProperties.VLanId = $script:constants.VLanId

    $virtualPortGroupMock = $script:virtualPortGroup

    Mock -CommandName Get-VirtualPortGroup -MockWith { return $virtualPortGroupMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VirtualPortGroupName -and $VirtualSwitch -eq $script:virtualSwitch -and $VMHost -eq $script:vmHost } -Verifiable
    Mock -CommandName Set-VirtualPortGroup -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostVssPortGroupProperties
}

function New-MocksInSetWhenEnsureAbsentAndNonExistingPortGroup {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssPortGroupProperties = New-VMHostVssPortGroupProperties
    $vmHostVssPortGroupProperties.Name = $script:constants.VirtualPortGroupName
    $vmHostVssPortGroupProperties.Ensure = 'Absent'

    Mock -CommandName Get-VirtualPortGroup -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VirtualPortGroupName -and $VirtualSwitch -eq $script:virtualSwitch -and $VMHost -eq $script:vmHost } -Verifiable
    Mock -CommandName Remove-VirtualPortGroup -MockWith { return $null }.GetNewClosure()

    $vmHostVssPortGroupProperties
}

function New-MocksInSetWhenEnsureAbsentAndExistingPortGroup {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssPortGroupProperties = New-VMHostVssPortGroupProperties
    $vmHostVssPortGroupProperties.Name = $script:constants.VirtualPortGroupName
    $vmHostVssPortGroupProperties.Ensure = 'Absent'

    $virtualPortGroupMock = $script:virtualPortGroup

    Mock -CommandName Get-VirtualPortGroup -MockWith { return $virtualPortGroupMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VirtualPortGroupName -and $VirtualSwitch -eq $script:virtualSwitch -and $VMHost -eq $script:vmHost } -Verifiable
    Mock -CommandName Remove-VirtualPortGroup -MockWith { return $null }.GetNewClosure() -Verifiable

    $vmHostVssPortGroupProperties
}

function New-MocksWhenEnsurePresentAndNonExistingPortGroup {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssPortGroupProperties = New-VMHostVssPortGroupProperties
    $vmHostVssPortGroupProperties.Name = $script:constants.VirtualPortGroupName
    $vmHostVssPortGroupProperties.Ensure = 'Present'

    Mock -CommandName Get-VirtualPortGroup -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VirtualPortGroupName -and $VirtualSwitch -eq $script:virtualSwitch -and $VMHost -eq $script:vmHost } -Verifiable

    $vmHostVssPortGroupProperties
}

function New-MocksWhenEnsurePresentExistingPortGroupAndNoVLanIdSpecified {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssPortGroupProperties = New-VMHostVssPortGroupProperties
    $vmHostVssPortGroupProperties.Name = $script:constants.VirtualPortGroupName
    $vmHostVssPortGroupProperties.Ensure = 'Present'

    $virtualPortGroupMock = $script:virtualPortGroup

    Mock -CommandName Get-VirtualPortGroup -MockWith { return $virtualPortGroupMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VirtualPortGroupName -and $VirtualSwitch -eq $script:virtualSwitch -and $VMHost -eq $script:vmHost } -Verifiable

    $vmHostVssPortGroupProperties
}

function New-MocksWhenEnsurePresentExistingPortGroupAndVLanIdNotEqualToPortGroupVLanId {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssPortGroupProperties = New-VMHostVssPortGroupProperties
    $vmHostVssPortGroupProperties.Name = $script:constants.VirtualPortGroupName
    $vmHostVssPortGroupProperties.Ensure = 'Present'
    $vmHostVssPortGroupProperties.VLanId = $script:constants.VLanId - 1

    $virtualPortGroupMock = $script:virtualPortGroup

    Mock -CommandName Get-VirtualPortGroup -MockWith { return $virtualPortGroupMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VirtualPortGroupName -and $VirtualSwitch -eq $script:virtualSwitch -and $VMHost -eq $script:vmHost } -Verifiable

    $vmHostVssPortGroupProperties
}

function New-MocksWhenEnsurePresentExistingPortGroupAndVLanIdEqualToPortGroupVLanId {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssPortGroupProperties = New-VMHostVssPortGroupProperties
    $vmHostVssPortGroupProperties.Name = $script:constants.VirtualPortGroupName
    $vmHostVssPortGroupProperties.Ensure = 'Present'
    $vmHostVssPortGroupProperties.VLanId = $script:constants.VLanId

    $virtualPortGroupMock = $script:virtualPortGroup

    Mock -CommandName Get-VirtualPortGroup -MockWith { return $virtualPortGroupMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VirtualPortGroupName -and $VirtualSwitch -eq $script:virtualSwitch -and $VMHost -eq $script:vmHost } -Verifiable

    $vmHostVssPortGroupProperties
}

function New-MocksWhenEnsureAbsentAndNonExistingPortGroup {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssPortGroupProperties = New-VMHostVssPortGroupProperties
    $vmHostVssPortGroupProperties.Name = $script:constants.VirtualPortGroupName
    $vmHostVssPortGroupProperties.Ensure = 'Absent'

    Mock -CommandName Get-VirtualPortGroup -MockWith { return $null }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VirtualPortGroupName -and $VirtualSwitch -eq $script:virtualSwitch -and $VMHost -eq $script:vmHost } -Verifiable

    $vmHostVssPortGroupProperties
}

function New-MocksWhenEnsureAbsentAndExistingPortGroup {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssPortGroupProperties = New-VMHostVssPortGroupProperties
    $vmHostVssPortGroupProperties.Name = $script:constants.VirtualPortGroupName
    $vmHostVssPortGroupProperties.Ensure = 'Absent'

    $virtualPortGroupMock = $script:virtualPortGroup

    Mock -CommandName Get-VirtualPortGroup -MockWith { return $virtualPortGroupMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VirtualPortGroupName -and $VirtualSwitch -eq $script:virtualSwitch -and $VMHost -eq $script:vmHost } -Verifiable

    $vmHostVssPortGroupProperties
}

function New-MocksWhenEnsurePresentAndExistingPortGroup {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    $vmHostVssPortGroupProperties = New-VMHostVssPortGroupProperties
    $vmHostVssPortGroupProperties.Name = $script:constants.VirtualPortGroupName
    $vmHostVssPortGroupProperties.Ensure = 'Present'

    $virtualPortGroupMock = $script:virtualPortGroup

    Mock -CommandName Get-VirtualPortGroup -MockWith { return $virtualPortGroupMock }.GetNewClosure() -ParameterFilter { $Server -eq $script:viServer -and $Name -eq $script:constants.VirtualPortGroupName -and $VirtualSwitch -eq $script:virtualSwitch -and $VMHost -eq $script:vmHost } -Verifiable

    $vmHostVssPortGroupProperties
}
